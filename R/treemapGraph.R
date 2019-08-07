#-------------------------------------------------------------------------------
# Program: treemapGraph
# Objective: create a treemap to vizualize scientific objects
# Creation: 05/07/2019
# Update:
#-------------------------------------------------------------------------------

#' @title create a treemap to vizualize scientific object across the network
#' @importFrom dplyr group_by_all
#' @importFrom dplyr count
#' @importFrom treemap treemap
#' @importFrom RColorBrewer brewer.pal
#' @importFrom grDevices dev.off
#' @importFrom grDevices png
#' @param computedDF data of rdf Type from collectData (\code{\link{collectSensor}}, \code{\link{collectVariable}}, \code{\link{collectScientificObject}}) functions
#' @param class1 variable to perform the first decomposition (can be Installation, Type, Year, Experiments)
#' @param class2 variable to perform the second decomposition (can be Installation, Type, Year, Experiments)
#' @return treemap of scientific objects colored by the argument.
#' @export
#'
#' @examples
#' \donttest{
#' INST = installationTable(
#'            instancesApi = c("opensilex.org/openSilexAPI/rest/"),
#'            instancesNames = c("opensilexDemo")
#'        )
#' DATA = collectData(INST)
#' pieGraph(DATA, parameterOfInterest = "Type")
#' } 


treemapGraph <- function(computedDF, class1, class2){
  ##---- DATA
  if(!is.data.frame(computedDF)){
    computedDF <- fromJSON(computedDF)
  }
  typeData <- computedDF%>%
    group_by_all()%>%
    count()
  pal <- RColorBrewer::brewer.pal(name = "Set2", n = 6)
  png(filename = "image/Graph.png", width = 500, height = 500)
  treemap::treemap(dtf = typeData, index = c(class1, class2), vSize = "n" ,
          palette =  pal, title = "PHENOME network", type = "index",
          fontsize.labels=c(15,12),bg.labels = 0,
          fontcolor.labels = c("navy", "snow"), border.lwds = c(3, 0.5))
  dev.off()
  treemap::treemap(dtf = typeData, index = c(class1, class2), vSize = "n" ,
          palette =  pal, title = "PHENOME network", type = "index",
          fontsize.labels=c(15,12),bg.labels = 0,
          fontcolor.labels = c("navy", "snow"), border.lwds = c(3, 0.5))
}


