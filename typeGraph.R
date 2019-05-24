#-------------------------------------------------------------------------------
# Program: typeGraph
# Objective: create a graph to vizualize rdfType of objects
# Creation: 24/05/2019
# Update:
#-------------------------------------------------------------------------------

#' @title create a graph to vizualize rdfType of objects
#'
#' @param typeData data of rdf Type from \code{\link{typeData}} function
#' @param groupBy variable to groupBy and color
#' @param print boolean, either to print or save the image
#' @return barplot of rdfType of scientific objects
#' @export
#'
#' @examples
#' \donttest{
#' }
typeGraph = function(typeData = typeData, groupBy = "Installation", print = T){
  g1 = ggplot(data = typeData) +
    geom_col(aes(x = rdfType, y = Freq, fill = eval(parse(text = groupBy)))) + 
    labs(x = "Type of Scientific Object") + 
    labs(y = "Number of Scientific Objects") + 
    labs(fill = groupBy) +
    labs(title = "Number of Scientific Objects of various type", subtitle = paste("Colored by", groupBy))
  if(print == TRUE){
    g1  
  }else{
    ggsave(filename = "typeGraph.html", plot = g1)
  }
}
