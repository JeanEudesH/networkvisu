## Test Interoperabilité  -  Nombre d'objects par installation.
library(remotes)
library(phisWSClientR)
library(RColorBrewer)
library(ggplot2)
library(stringr)
library(data.table)
library(dplyr)
library(treemap)
library(networkVisu)
library(roxygen2)
library(devtools)
instancesApi = c("147.100.175.121:8080/phenomeDiaphenAPI/rest/", "opensilex.org/openSilexAPI/rest/", "147.100.175.121:8080/phenomeAgrophenAPI/rest/", "http://147.100.175.121:8080/phenomePheno3cAPI/rest/", "http://147.100.175.121:8080/phenomePhenoviaAPI/rest/", "http://147.100.175.121:8080/phenomePhenofieldAPI/rest/", "http://138.102.159.36:8080/phenomeEphesiaAPI/rest/")
instancesNames = c("diaphen", "opensilexDemo", "agrophen", "pheno3C", "phenovia", "PhenoField", "ephesia")

inst = data.frame(name = instancesNames, api = instancesApi)

scientificObjectOverview = function(inst){
  initializeClientConnection(apiID="ws_private", url = '147.100.175.121:8080/phenomeDiaphenAPI/rest/')
  aToken = getToken("guest@opensilex.org","guest")
  count <- getVariables2(aToken$data, pageSize = 1)$totalCount
  sensors <- getVariables2(aToken$data, pageSize = count)
  wsQuery = sensors$data
  
  count <- getExperiments2(aToken$data, pageSize = 1)$totalCount
  exp <- getExperiments2(aToken$data, pageSize = count)
  wsQueryV = exp$data$variables 
  varsExp = data.frame(uri = colnames(wsQueryV), experiment =  exp$data$uri)
  computedDF = full_join(varsExp, wsQuery, by="uri")
  
  computedDF = computedDF%>%
      select(rdfType, brand, experiment)%>%
      mutate(Experiments = sapply(str_split(experiment, pattern = "/"), FUN = function(X){X[5]}))%>%
      mutate(Type = str_sub(rdfType, start = str_locate(rdfType, pattern = "#")[,1]+1, end = str_locate(rdfType, pattern = "#")[,1]+16))%>%
      mutate(Year = str_sub(experiment, start = str_locate(experiment, pattern = "20")[,1], end = str_locate(experiment, pattern = "20")[,2]+2))%>%
      mutate(Installation = inst['name'])%>%
      select(-experiment, -rdfType)
  return(data = computedDF)
}

#--------  Experiments
##---- DATA
expData = data.frame()
for( i in 1:length(graphData)){
  expData = rbind(expData, graphData[[i]][[2]])
}
expData = data.table(expData, keep.rownames = F)
expData$Year = ordered(x = expData$Year, c("2015","2016","2017","2018","2019"))
expData[order(Year),]

expDF = expData[ Installation == "diaphen",]
##---- VIZ
#barplot(exp, col = pal, names.arg = str_sub(names(exp), start = str_locate(names(exp), pattern = "diaphen/")[,2]+1, end = str_locate(names(exp), pattern = "diaphen/")[,2]+16))
g21 = ggplot(data = DATA2) +
  geom_bar(aes(x = brand, weight = n, fill = Installation)) +
  labs(x = "Experiments") + 
  labs(y = "Number of Sensors") + 
  labs(title = "Number of Sensors across different experiments", subtitle = "Colored by Type")+
  coord_flip()
g21


#---- Pie chart
count.data <- typeData %>%
  dplyr::group_by(eval(parse(text = parameterOfInterest)))%>%
  summarise(total = sum(n))%>%
  mutate(prop = round(total/sum(total), digits = 2))%>%
  mutate(lab.ypos = 1-round(cumsum(prop) - 0.5*prop, digits = 2))%>%
  arrange(desc(prop))
count.data

g4 = ggplot(count.data, aes(x = "", y = prop, fill = `eval(parse(text = parameterOfInterest))`)) +
  geom_bar(width = 1, stat = "identity", color = "white") +
  coord_polar("y", start = 0, direction = 1)+
  geom_text(aes(y = lab.ypos, label = prop), color = "white", size=5)+
  theme_void() +
  labs(fill = parameterOfInterest) +
  labs(title = "Proportion of Scientific Objects within the network")
g4


# ---- V2

source("/home/jeaneudes/Documents/PHISanalysis/RShiny/NetworkVisu/R/installationTable.R")
source("/home/jeaneudes/Documents/PHISanalysis/RShiny/NetworkVisu/R/collectData.R")
source("/home/jeaneudes/Documents/PHISanalysis/RShiny/NetworkVisu/R/barplotGraph.R")
source('/home/jeaneudes/Documents/PHISanalysis/RShiny/NetworkVisu/R/pieGraph.R')

INST = installationTable(instancesApi = c("opensilex.org/openSilexAPI/rest/"),
                         instancesNames = c("opensilexDemo")
 )
# INST = installationTable(instancesApi = c("147.100.175.121:8080/phenomeDiaphenAPI/rest/", "opensilex.org/openSilexAPI/rest/", "147.100.175.121:8080/phenomeAgrophenAPI/rest/", "147.100.175.121:8080/phenomePheno3cAPI/rest/", "147.100.175.121:8080/phenomePhenoviaAPI/rest/", "147.100.175.121:8080/phenomePhenofieldAPI/rest/", "138.102.159.36:8080/phenomeEphesiaAPI/rest/"),
#                          instancesNames = c("diaphen", "opensilexDemo", "agrophen", "pheno3C", "phenovia", "PhenoField", "ephesia")
#  )


DATA = collectScientificObject(INST)
DATA2 = DATA%>%
  group_by(Installation, Type, Year, Experiments)%>%
  count()

SENSORS = collectSensor(INST)
DATA2 = SENSORS%>%
  group_by_all()%>%
  count()
VARS = collectVariable(INST)
DATA2 = VARS%>%
  group_by_all()%>%
  count()

barplotGraph(DATA, parameterOfInterest = "Installation", groupBy = "Experiments")
barplotGraph(DATA, parameterOfInterest = "Installation", groupBy = "Year")
barplotGraph(DATA2, parameterOfInterest = "Installation", groupBy = "Type")
barplotGraph(DATA, parameterOfInterest = "Type", groupBy = "Year")
barplotGraph(DATA, parameterOfInterest = "Type", groupBy = "Experiments")
barplotGraph(DATA, parameterOfInterest = "Type", groupBy = "Experiments", filteredInstallation = "diaphen")

boxplotGraph(DATA2, parameterOfInterest = "Type")

pieGraph(DATA2, parameterOfInterest = "Type")


# ---- treemap
treemap(dtf = DATA2, index = c("Year","Installation"), vSize = "n" ,
        palette =  pal, title = "PHENOME network", type = "index",
        fontsize.labels=c(15,12),bg.labels = 0,
        fontcolor.labels = c("navy", "snow"), border.lwds = c(3, 0.5))
  