#-------------------------------------------------------------------------------
# Program: collectSensor
# Objective: collect data from the installations
# Creation: 06/06/2019
# Update:
#-------------------------------------------------------------------------------

#' @title collectSensor from the different installations
#' @import dplyr
#' @import phisWSClientR
#' @import stringr
#' @import jsonlite
#' @param inst informations of the installations from \code{\link{installationTable}}
#' @param instancesNames the name of the installation(s)
#' @param instancesApi the address of the REST API of the installation(s)
#' @return installation rdfType and Experiments Data
#' @export
#'
#' @examples
#' \donttest{
#' INST = installationTable(
#'            instancesApi = c("opensilex.org/openSilexAPI/rest/"),
#'            instancesNames = c("opensilexDemo")
#'        )
#' DATA = collectSensor(INST)
#' }
collectSensor = function(inst=NULL, instancesNames, instancesApi){
  #Tests
  if(is.null(inst)){
    inst = data.frame(name = instancesNames, api=instancesApi)
  }else{
    if(!is.data.frame(inst)){
      inst = from_JSON(inst)
    }
  }
  tempData = apply(X = inst, MARGIN = 1, FUN = function(installation){
    connectToPHISWS(apiID="ws_private", url = installation['api'], username = "guest@opensilex.org", password = "guest")
    count <- getSensors(pageSize = 1)$totalCount
    sensors <- getSensors(pageSize = count)
    wsQuery = sensors$data  
    
    count <- getExperiments2(pageSize = 1)$totalCount
    exp <- getExperiments2(pageSize = count)
    wsQueryE = exp$data$sensors
    sensExp = data.frame(uri = colnames(wsQueryE), experiment =  exp$data$uri)
    computedDF = full_join(sensExp, wsQuery, by="uri")

    computedDF = computedDF%>%
      select(rdfType, brand)%>%
      mutate(Type = str_sub(rdfType, start = str_locate(rdfType, pattern = "#")[,1]+1, end = str_locate(rdfType, pattern = "#")[,1]+16))%>%
      mutate(Experiments = sapply(str_split(experiment, pattern = "/"), FUN = function(X){X[5]}))%>%
      mutate(Year = str_sub(experiment, start = str_locate(experiment, pattern = "20")[,1], end = str_locate(experiment, pattern = "20")[,2]+2))%>%
      mutate(Installation = installation['name'])%>%
      select( -rdfType)
    return(computedDF)
  }
  )
  computedDF = data.frame()
  for( i in 1:length(tempData)){
    computedDF = rbind(computedDF, tempData[[i]])
  }
  
  return(data = computedDF)
}
