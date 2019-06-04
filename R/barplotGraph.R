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
#' @param computedDF data of rdf Type from \code{\link{collectData}} function
#' @param parameterOfInterest variable to perform the decomposition (can be Installation, Type, Year, Experiments)
#' @param groupBy variable to groupBy and color can be (Installation, Type, Year, Experiments)
#' @param print boolean, either to print or save the image
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
barplotGraph = function(computedDF, parameterOfInterest, filteredInstallation = FALSE, groupBy = "Installation", print = T){
  ##---- DATA
  if(!is.data.frame(computedDF)){
    computedDF = fromJSON(computedDF)
  }
  if(filteredInstallation != FALSE){
    computedDF = computedDF%>%
      filter( Installation == filteredInstallation)
  }
  typeData = computedDF%>%
    group_by(Installation, Type, Year, Experiments)%>%
    count()
  ##---- VIZ
  g1 = ggplot(data = typeData) +
    geom_col(aes(x = eval(parse(text = parameterOfInterest)), y = n, fill =  eval(parse(text = groupBy)))) + 
    labs(x = paste(parameterOfInterest)) + 
    labs(y = "Number of Scientific Objects") + 
    labs(fill = groupBy) +
    labs(title = paste("Number of Scientific Objects per", parameterOfInterest), subtitle = paste("Colored by", groupBy))+
    coord_flip()
  if(print == TRUE){
    g1  
  }else{
    ggsave(filename = "Graph.png", plot = g1)
  }
}
