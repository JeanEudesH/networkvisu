## Test Interoperabilité  -  Nombre d'objects par installation.
library(remotes)
library(phisWSClientR)
library(RColorBrewer)
library(ggplot2)
library(stringr)
library(data.table)
library(dplyr)
library(treemap)

instancesApi = c("147.100.175.121:8080/phenomeDiaphenAPI/rest/", "opensilex.org/openSilexAPI/rest/", "147.100.175.121:8080/phenomeAgrophenAPI/rest/", "http://147.100.175.121:8080/phenomePheno3cAPI/rest/", "http://147.100.175.121:8080/phenomePhenoviaAPI/rest/", "http://147.100.175.121:8080/phenomePhenofieldAPI/rest/", "http://138.102.159.36:8080/phenomeEphesiaAPI/rest/")
instancesNames = c("diaphen", "opensilexDemo", "agrophen", "pheno3C", "phenovia", "PhenoField", "ephesia")

inst = data.frame(name = instancesNames, api = instancesApi)
#inst = c("147.100.175.121:8080/phenomeDiaphenAPI/rest/")

pal = brewer.pal(name = 'Set3', n = 12)
pal2 = brewer.pal(name = 'Dark2', n = 8)

scientificObjectOverview = function(inst){
  initializeClientConnection(apiID="ws_private", url = inst['api'])
  aToken = getToken("guest@opensilex.org","guest")
  count <- getScientificObjects(aToken$data, pageSize = 1)$totalCount
  scientificObjects <- getScientificObjects(aToken$data, pageSize = count)
  wsQuery = scientificObjects$data  
  
  computedDF = wsQuery%>%
      select(rdfType, experiment)%>%
      mutate(Type = str_sub(rdfType, start = str_locate(rdfType, pattern = "#")[,1]+1, end = str_locate(rdfType, pattern = "#")[,1]+16))%>%
      mutate(Experiments = sapply(str_split(experiment, pattern = "/"), FUN = function(X){X[5]}))%>%
      mutate(Year = str_sub(experiment, start = str_locate(experiment, pattern = "20")[,1], end = str_locate(experiment, pattern = "20")[,2]+2))%>%
      mutate(Installation = inst['name'])%>%
      select(-experiment, -rdfType)
  return(data = computedDF)
}

graphData = apply(X = inst, MARGIN = 1, FUN = scientificObjectOverview)
computedDF = data.frame()
for( i in 1:length(graphData)){
  computedDF = rbind(computedDF, graphData[[i]])
}
#--------  RDFTYPE
##---- DATA
typeData = computedDF%>%
  group_by(Installation, Type, Year, Experiments)%>%
  count()
##---- VIZ
g1 = ggplot(data = typeData) +
  geom_col(aes(x = Experiments, y = n, fill = Installation)) + 
  labs(x = "Type of Scientific Object") + 
  labs(y = "Number of Scientific Objects") + 
  labs(title = "Number of Scientific Objects of various type", subtitle = "Colored by Installation")
g1

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
g21 = ggplot(data = expData) +
  geom_bar(aes(x = Experiments, weight = Freq, fill = Installation)) +
  labs(x = "Experiments") + 
  labs(y = "Number of Scientific Objects") + 
  labs(title = "Number of Scientific Objects across different experiments", subtitle = "Colored by Installations")
g21

g22 = ggplot(data = expDF, aes(Experiments)) +
  geom_bar(aes(weight = Freq), fill = c(pal, pal2)[1:15]) +
  labs(x = "Experiments") + 
  labs(y = "Number of Scientific Objects") + 
  labs(title = "Number of Scientific Objects across different experiments", subtitle = "Installation : DIAPHEN")
g22

#--------  Year
g31 = ggplot(data = expData) +
  geom_col(mapping = aes(x = Year, y = Freq, fill = Installation ), position = "stack") +
  #geom_bar(aes(weight = Freq), fill = c(pal, pal2)[1:15]) +
  labs(x = "Year") + 
  labs(y = "Number of Scientific Objects") + 
  labs(title = "Evolution of Scientific Objects over time" , subtitle = "Colored by different installations")+ 
  theme(axis.text.x =  element_text(size = 7, angle = 80,  hjust = 1))
g31
g32 = ggplot(data = expDF) +
  geom_col(mapping = aes(x = Year, y = Freq, fill = Experiments ), position = "stack") +
  #geom_bar(aes(weight = Freq), fill = c(pal, pal2)[1:15]) +
  labs(x = "Year") + 
  labs(y = "Number of Scientific Objects") + 
  labs(title = "Evolution of Scientific Objects over time" , subtitle = "Installation: DIAPHEN \nColored by different Experiments")+ 
  theme(axis.text.x =  element_text(size = 7, angle = 80,  hjust = 1))
g32

#---- Pie chart
mycols <- c("#0073C2FF", "#EFC000FF", "#868686FF", "#CD534CFF")

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

source("/home/jeaneudes/Documents/PHISanalysis/RShiny/NetworkVisu/installationTable.R")
source("/home/jeaneudes/Documents/PHISanalysis/RShiny/NetworkVisu/collectData.R")
source("/home/jeaneudes/Documents/PHISanalysis/RShiny/NetworkVisu/barplotGraph.R")
source('~/Documents/PHISanalysis/RShiny/NetworkVisu/pieGraph.R', echo=TRUE)

INST = installationTable(instancesApi = c("147.100.175.121:8080/phenomeDiaphenAPI/rest/", "opensilex.org/openSilexAPI/rest/", "147.100.175.121:8080/phenomeAgrophenAPI/rest/", "147.100.175.121:8080/phenomePheno3cAPI/rest/", "147.100.175.121:8080/phenomePhenoviaAPI/rest/", "147.100.175.121:8080/phenomePhenofieldAPI/rest/", "138.102.159.36:8080/phenomeEphesiaAPI/rest/"),
                         instancesNames = c("diaphen", "opensilexDemo", "agrophen", "pheno3C", "phenovia", "PhenoField", "ephesia")
)

DATA = collectData(INST)
DATA2 = collectData(INST)%>%
  group_by(Installation, Type, Year, Experiments)%>%
  count()

barplotGraph(DATA, parameterOfInterest = "Installation", groupBy = "Experiments")
barplotGraph(DATA, parameterOfInterest = "Installation", groupBy = "Year")
barplotGraph(DATA, parameterOfInterest = "Installation", groupBy = "Type")
barplotGraph(DATA, parameterOfInterest = "Type", groupBy = "Year")
barplotGraph(DATA, parameterOfInterest = "Type", groupBy = "Experiments")
barplotGraph(DATA, parameterOfInterest = "Type", groupBy = "Experiments", filteredInstallation = "diaphen")

pieGraph(DATA, parameterOfInterest = "Type")


# ---- treemap
pipo = brewer.pal(name =  "Accent", 5)
treemap(dtf = DATA2, index = c("Year","Installation"), vSize = "n" ,
        palette =  pal, title = "PHENOME network", type = "index",
        fontsize.labels=c(15,12),bg.labels = 0,
        fontcolor.labels = c("navy", "snow"), border.lwds = c(3, 0.5))
  