#-------------------------------------------------------------------------------
# Program: pieGraph
# Objective: create a piechart to vizualize rdfType of objects
# Creation: 24/05/2019
# Update:
#-------------------------------------------------------------------------------

#' @title create a piechart to vizualize scientific object across the network
#' @import dplyr
#' @import phisWSClientR
#' @import ggplot2
#' @import stringr
#' @param computedDF data of rdf Type from \code{\link{collectData}} function
#' @param parameterOfInterest variable to perform the decomposition (can be Installation, Type, Year, Experiments)
#' @param filteredInstallation name of the installation to focus on
#' @param print boolean, either to print or save the image
#' @return piechart of scientific objects colored by the argument.
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
pieGraph = function(computedDF, parameterOfInterest, filteredInstallation = FALSE, print = T){
  ##---- DATA
  if(!is.data.frame(computedDF)){
    computedDF = fromJSON(computedDF)
  }
  if(filteredInstallation != FALSE){
    computedDF = computedDF%>%
      filter( Installation == filteredInstallation)
  }

  count.data <- computedDF %>%
    group_by_all()%>%
    count()%>%
    dplyr::group_by(eval(parse(text = parameterOfInterest)))%>%
    summarise(total = sum(n))%>%
    mutate(prop = round(total/sum(total), digits = 2))%>%
    mutate(lab.ypos = 1-round(cumsum(prop) - 0.5*prop, digits = 2))
  count.data
  
  g4 = ggplot(count.data, aes(x = "", y = prop, fill = `eval(parse(text = parameterOfInterest))`)) +
    geom_bar(width = 1, stat = "identity", color = "white") +
    coord_polar("y", start = 0, direction = 1)+
    geom_text(aes(y = lab.ypos, label = prop), color = "white", size=5)+
    theme_void() +
    labs(fill = parameterOfInterest) +
    labs(title = "Proportion of Scientific Objects within the network")
  g4
  if(print == TRUE){
    g4  
  }else{
    ggsave(filename = "Graph.png", plot = g4)
  }
}
