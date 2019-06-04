#-------------------------------------------------------------------------------
# Program: collectData
# Objective: collect data from the installations
# Creation: 24/05/2019
# Update:
#-------------------------------------------------------------------------------

#' @title collectData from the different installations
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
#' DATA = collectData(INST)
#' }
collectData = function(inst=NULL, instancesNames, instancesApi){
 #Tests
   if(is.null(inst)){
    inst = data.frame(name = instancesNames, api=instancesApi)
  }else{
    if(!is.data.frame(inst)){
      inst = from_JSON(inst)
    }
  }
  tempData = apply(X = inst, MARGIN = 1, FUN = function(installation){
    initializeClientConnection(apiID="ws_private", url = installation['api'])
    aToken = getToken("guest@opensilex.org","guest")
    count <- getScientificObjects(aToken$data, pageSize = 1)$totalCount
    scientificObjects <- getScientificObjects(aToken$data, pageSize = count)
    wsQuery = scientificObjects$data  
    
    computedDF = wsQuery%>%
      select(rdfType, experiment)%>%
      mutate(Type = str_sub(rdfType, start = str_locate(rdfType, pattern = "#")[,1]+1, end = str_locate(rdfType, pattern = "#")[,1]+16))%>%
      mutate(Experiments = sapply(str_split(experiment, pattern = "/"), FUN = function(X){X[5]}))%>%
      mutate(Year = str_sub(experiment, start = str_locate(experiment, pattern = "20")[,1], end = str_locate(experiment, pattern = "20")[,2]+2))%>%
      mutate(Installation = installation['name'])%>%
      select(-experiment, -rdfType)
    return(computedDF)
  }
  )
  computedDF = data.frame()
  for( i in 1:length(tempData)){
    computedDF = rbind(computedDF, tempData[[i]])
  }
  
  return(data = computedDF)
}
