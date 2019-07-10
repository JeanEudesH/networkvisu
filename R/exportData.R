#-------------------------------------------------------------------------------
# Program: exportData
# Objective: Export data to the desired format
# Creation: 09/07/2019
# Update:
#-------------------------------------------------------------------------------

#' @title Export the data to desired format
#' @import dplyr
#' @import tidyverse
#' @importFrom  jsonlite fromJSON
#' @importFrom  jsonlite toJSON
#' @importFrom  xml2 as_xml_document
#' @param DATA Data of the installations from \code{\link{collectScientificObjects}}
#' @param format The format desired
#' @param rawData Want to download the raw data or the refined ones ?
#' @return Data in a desired format
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
exportData <- function(DATA = NULL, format = 'csv', rawData = TRUE, filename = 'file'){
  if(rawData == TRUE){
    switch(EXPR = format,
        csv = write.csv(x = DATA, file = paste(filename, format, sep = ".")),
       # xml = ,
        json = write(x = toJSON(DATA), file = paste(filename, format, sep = "."))
    )
  }else{
    DATA = DATA%>%
      group_by(eval(parse(text = object)), eval(parse(text = variable)))%>%
      count()
    
    switch(EXPR = format,
           csv = write.csv(x = DATA, file = paste(filename, format, sep = ".")),
           # xml = ,
           json = write(x = toJSON(DATA), file = paste(filename, format, sep = "."))
    )
  }
}

