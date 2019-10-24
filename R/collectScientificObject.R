#-------------------------------------------------------------------------------
# Program: collectScientificObject
# Objective: collect data from the installations
# Creation: 24/05/2019
# Update:
#-------------------------------------------------------------------------------

#' @title collectScientificObject from the different installations
#' @import dplyr
#' @import phisWSClientR
#' @import stringr
#' @import parallel
#' @import doParallel
#' @import foreach
#' @importFrom jsonlite fromJSON
#' @importFrom foreach %dopar%
#' @param inst informations of the installations from \code{\link{installationTable}}
#' @param instancesNames the name of the installation(s)
#' @param instancesApi the address of the REST API of the installation(s)
#' @return installation rdfType and Experiments Data
#' @export
#'
#' @examples
#' \donttest{
#' INST = list(
#'            instancesApi = c("opensilex.org/openSilexAPI/rest/"),
#'            instancesNames = c("opensilexDemo")
#'        )
#' DATA = collectScientificObject(INST)
#' }
collectScientificObject <- function(inst=NULL, instancesNames, instancesApi){
 #Tests
   if(is.null(inst)){
    inst <- data.frame(name = instancesNames, api=instancesApi)
  }else{
    if(!is.data.frame(inst)){
      inst <- fromJSON(inst)
    }
  }
  cl <- min(dim(inst)[1], parallel::detectCores()-2)
  doParallel::registerDoParallel(cl)
  tempData = foreach::foreach(i = 1:dim(inst)[1], .combine=rbind) %dopar% {

    installation = as.matrix(inst[i,])
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
      select(-experiment, -rdfType)%>%
      filter(!(Year =="<NA>"))
  }
  
  return(data = tempData)
}
