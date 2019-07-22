#-------------------------------------------------------------------------------
# Program: radarData
# Objective: collect data from the installations and turn into radar dataset
# Creation: 09/07/2019
# Update:
#-------------------------------------------------------------------------------

#' @title radarData from the different installations
#' @import dplyr
# @import d3radarR
#' @param DATA Data of the installations from \code{\link{collectScientificObject}}
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
radarData <- function(DATA = NULL, object = 'Installation', variable = 'Year'){

  DATA = DATA%>%
    group_by(eval(parse(text = object)), eval(parse(text = variable)))%>%
    count()%>%
    rename(key = 'eval(parse(text = object))', value = n)%>%
    spread(key = 'eval(parse(text = variable))', value = value, fill = 0)
    

  LDATA = apply(DATA, MARGIN = 1, FUN =  function(x){
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
    )
  
  d3radarR::d3radar(LDATA)
}