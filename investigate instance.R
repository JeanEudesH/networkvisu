## Test Interoperabilité  -  Nombre d'objects par installation.
# devtools::install_github("timelyportfolio/d3radarR")
library(remotes)
library(phisWSClientR)
library(RColorBrewer)
library(ggplot2)
library(stringr)
library(data.table)
library(purrr)
library(dplyr)
library(tidyverse)
library(treemap)
library(roxygen2)
library(devtools)
library(jsonlite)
library(d3radarR)
library(magrittr)
library(parallel)
library(doParallel)
library(networkVisu)


INST = installationTable(instancesApi = c("147.100.175.121:8080/phenomeDiaphenAPI/rest/","opensilex.org/openSilexAPI/rest/", "147.100.175.121:8080/phenomePheno3cAPI/rest/", "147.100.175.121:8080/phenomePhenoviaAPI/rest/","138.102.159.36:8080/phenomeEphesiaAPI/rest/"),
                         instancesNames = c("Diaphen", "OpensilexDemo", "Pheno3C", "Phenovia", "Ephesia")
)
# INST = installationTable(instancesApi = c("147.100.175.121:8080/phenomeDiaphenAPI/rest/", "opensilex.org/openSilexAPI/rest/", "147.100.175.121:8080/phenomeAgrophenAPI/rest/", "147.100.175.121:8080/phenomePheno3cAPI/rest/", "147.100.175.121:8080/phenomePhenoviaAPI/rest/", "147.100.175.121:8080/phenomePhenofieldAPI/rest/", "138.102.159.36:8080/phenomeEphesiaAPI/rest/"),
#                          instancesNames = c("Diaphen", "OpensilexDemo", "Agrophen", "Pheno3C", "Phenovia", "PhenoField", "Ephesia")
#                           durée =         c(12,             6,              155   ,     17   ,      61  ,    crash,      3     )                                                             
#  )

system.time(expr = {
  DATAZ1 = collectScientificObject(INST)  
})

system.time({
  cl <- min(dim(INST)[1], detectCores()-2)
  registerDoParallel(cl)
  tempData = foreach(i = 1:dim(INST)[1], .combine=rbind) %dopar% {
    #browser()
    installation = as.matrix(INST[i,])
    connectToPHISWS(apiID="ws_private", url = installation[2], username = "guest@opensilex.org", password = "guest")
    count <- getScientificObjects(pageSize = 1)$totalCount
    scientificObjects <- getScientificObjects(pageSize = count)
    wsQuery <- as.data.frame(scientificObjects$data[-7]) #the properties columns being from various size, triplets, for the moment just ignore it.
    
    computedDF <- wsQuery%>%
      select(rdfType, experiment)%>%
      mutate(Type = str_sub(rdfType, start = str_locate(rdfType, pattern = "#")[,1]+1, end = str_locate(rdfType, pattern = "#")[,1]+16))%>%
      mutate(Experiments = sapply(str_split(experiment, pattern = "/"), FUN = function(X){X[5]}))%>%
      mutate(Year = str_sub(experiment, start = str_locate(experiment, pattern = "20")[,1], end = str_locate(experiment, pattern = "20")[,2]+2))%>%
      mutate(Installation = installation[1])%>%
      select(-experiment, -rdfType)
  }
  
})
#157 - 3db
#158 - 5db

jio = exportData(DATA = DATAZ1, format = "csv", rawData = FALSE, filename = "unessaicsv.csv")
DATA = DATAZ1%>%
  filter(!(Year =="<NA>"))%>%
  group_by_all()%>%
  count()

# try to export into JSON (ok) csv (ok) XML (not OK)
as_xml_document(DATAZ1)
write(x = toJSON(DATAZ1), file = "file.json")
write(x = DATAZ1, file = "file.xml")

barplotGraph(DATA, parameterOfInterest = "Year", groupBy = "Installation")

aggregatedData = bind_rows(DATA, DATAZ, DATAZ1)
groupped_DATA = DATAZ1%>%
  group_by(Installation, Type, Year, Experiments)%>%
  count()
radar_groupped_DATA = aggregatedData %>%
  group_by(Installation, Year)%>%
  count()%>%
  rename(key = Installation, value =  n)%>%
  spread(key = Year, value = value)
radar_groupped_DATA = apply(radar_groupped_DATA, MARGIN = 1, FUN =  formatage)
d3radar(radar_groupped_DATA)

networkVisu::radarGraph(DATA = DATAZ1, object = "Installation", variable = "Year")

formatage = function(x){
  values = list()
  for(col in names(x[-1])){
    axis = col
    value = as.numeric(x[col])
    values = c(values, list(list('axis' = axis, 'value' = value)))
  }
  format = list('key' = as.character(x[1]),
                'values' = values
  )
  return( format)
}


# ___________________________________

SENSORS = collectSensor(INST)
DATA2 = SENSORS%>%
  group_by_all()%>%
  count()
VARS = collectVariable(INST)
DATA2 = VARS%>%
  group_by_all()%>%
  count()
