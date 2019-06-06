#-------------------------------------------------------------------------------
# Program: barplotGraph
# Objective: create barplot from cumputed Data
# Creation: 24/05/2019
# Update:
#-------------------------------------------------------------------------------

#' @title create a barplot with different point of view from computed Data
#' @import dplyr
#' @import phisWSClientR
#' @import ggplot2
#' @import stringr
#' @import jsonlite
#' @param computedDF data of rdf Type from collectData (\code{\link{collectSensor}}, \code{\link{collectVariable}}, \code{\link{collectScientificObject}}) functions
#' @param parameterOfInterest variable to perform the decomposition (can be Installation, Type, Year, Experiments)
#' @param filteredInstallation FALSE if you don't want to filter on installations, or the name of the installation(s) (same as \code{\link{installationTable}})
#' @return installation rdfType data
#' @export
#'
#' @examples
#' \donttest{
#' INST = installationTable(
#'            instancesApi = c("opensilex.org/openSilexAPI/rest/"),
#'            instancesNames = c("opensilexDemo")
#'        )
#' DATA = collectData(INST)
#' barplotGraph(DATA, parameterOfInterest = "Year", groupBy = "Experiments")
#' barplotGraph(DATA, parameterOfInterest = "Year", groupBy = "Type")
#' }
boxplotGraph = function(computedDF, parameterOfInterest, filteredInstallation = FALSE){
  ##---- DATA
  if(!is.data.frame(computedDF)){
    computedDF = fromJSON(computedDF)
  }
  if(filteredInstallation != FALSE){
    computedDF = computedDF%>%
      filter( Installation == filteredInstallation)
  }
  typeData = computedDF%>%
    group_by_all()%>%
    count()
  ##---- VIZ
  g1 = ggplot(data = typeData) +
    geom_boxplot(aes(x = eval(parse(text = parameterOfInterest)), y = n, fill =  eval(parse(text = parameterOfInterest)))) + 
    labs(x = paste(parameterOfInterest)) + 
    labs(y = "Number of Scientific Objects") + 
    labs(fill = parameterOfInterest) +
    labs(title = paste("Number of Scientific Objects per", parameterOfInterest))+
    coord_flip()
    g1  
 
    ggsave(filename = "Graph.png", plot = g1)
  
}
