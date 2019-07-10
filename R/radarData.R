#-------------------------------------------------------------------------------
# Program: radarData
# Objective: collect data from the installations and turn into radar dataset
# Creation: 09/07/2019
# Update:
#-------------------------------------------------------------------------------

#' @title radarData from the different installations
#' @import dplyr
#' @import tidyverse
#' @importFrom  jsonlite fromJSON
#' @param DATA Data of the installations from \code{\link{collectScientificObjects}}
#' @param object The object layer for the radar plot (can be 'Installation', 'Year', 'Experiments', 'Type')
#' @param variable The variable on which to explore the objects (can be 'Installation', 'Year', 'Experiments', 'Type')
#' @return Data for scientific objects into a format suitable for radarplot (d3radarR)
#' @export
#'
#' @examples
#' \donttest{
#' INST = installationTable(
#'            instancesApi = c("opensilex.org/openSilexAPI/rest/"),
#'            instancesNames = c("opensilexDemo")
#'        )
#' DATA = collectScientificObject(INST)
#' 
#' 
#' }
radarData <- function(DATA = NULL, object, variable){

  DATA = DATA%>%
    group_by(eval(parse(text = object)), eval(parse(text = variable)))%>%
    count()%>%
    rename(key = eval(parse(text = object)), value = n)%>%
    spread(key = eval(parse(text = variable)), value = value, fill = 0)

  LDATA = apply(DATA3, MARGIN = 1, FUN =  formatage)
  
  return(data = computedDF)
}



#' @title formatage data for radar
#' @param x the line of the dataset to perform the function on 
#' @return Data for scientific objects into a format suitable for radarplot (d3radarR)
#' @internal

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
