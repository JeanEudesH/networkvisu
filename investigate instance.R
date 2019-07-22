## Test Interoperabilité  -  Nombre d'objects par installation.
devtools::install_github("timelyportfolio/d3radarR")
library(remotes)
library(phisWSClientR)
library(RColorBrewer)
library(ggplot2)
library(stringr)
library(data.table)
library(dplyr)
library(tidyverse)
library(treemap)
library(networkVisu)
library(roxygen2)
library(devtools)
library(jsonlite)
library(d3radarR)


INST = installationTable(instancesApi = c("147.100.175.121:8080/phenomeDiaphenAPI/rest/"),
                         instancesNames = c( "Diaphen")
 )
# INST = installationTable(instancesApi = c("147.100.175.121:8080/phenomeDiaphenAPI/rest/", "opensilex.org/openSilexAPI/rest/", "147.100.175.121:8080/phenomeAgrophenAPI/rest/", "147.100.175.121:8080/phenomePheno3cAPI/rest/", "147.100.175.121:8080/phenomePhenoviaAPI/rest/", "147.100.175.121:8080/phenomePhenofieldAPI/rest/", "138.102.159.36:8080/phenomeEphesiaAPI/rest/"),
#                          instancesNames = c("Diaphen", "OpensilexDemo", "Agrophen", "Pheno3C", "Phenovia", "PhenoField", "Ephesia")
#  )

system.time({
  DATAZ1 = collectScientificObject(INST)  
})

# try to export into JSON (ok) csv (ok) XML (not OK)
as_xml_document(DATAZ1)
write(x = toJSON(DATAZ1), file = "file.json")
write(x = DATAZ1, file = "file.xml")


aggregatedData = bind_rows(DATA, DATAZ, DATAZ1)
groupped_DATA = aggregatedData%>%
  group_by(Installation, Type, Year, Experiments)%>%
  count()
radar_groupped_DATA = aggregatedData %>%
  group_by(Installation, Year)%>%
  count()%>%
  rename(key = Installation, value =  n)%>%
  spread(key = Year, value = value)
radar_groupped_DATA = apply(radar_groupped_DATA, MARGIN = 1, FUN =  formatage)
d3radar(radar_groupped_DATA)

radarData(DATA = aggregatedData, object = "Installation", variable = "Year")

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
