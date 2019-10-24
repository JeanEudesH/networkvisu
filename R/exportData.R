#-------------------------------------------------------------------------------
# Program: exportData
# Objective: Export data to the desired format
# Creation: 09/07/2019
# Update:
#-------------------------------------------------------------------------------

#' @title Export the data to desired format
#' @import dplyr
#' @importFrom  jsonlite toJSON
#' @importFrom  utils write.csv
#' @importFrom  tidyr replace_na
#' @param DATA Data of the installations from \code{\link{collectScientificObject}}
#' @param format The format desired
#' @param rawData Want to download the raw data or the refined ones ?
#' @param filename name of the file to download (default is 'file')
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
      group_by_all()%>%
      count()
    
    switch(EXPR = format,
           csv = write.csv(x = DATA, file = paste(filename, format, sep = ".")),
           # xml = ,
           json = write(x = toJSON(DATA), file = paste(filename, format, sep = "."))
    )
  }
  return(DATA)
}

