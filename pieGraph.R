#-------------------------------------------------------------------------------
# Program: pieGraph
# Objective: create a piechart to vizualize rdfType of objects
# Creation: 24/05/2019
# Update:
#-------------------------------------------------------------------------------

#' @title create a piechart to vizualize rdfType of objects
#'
#' @param count.data data of rdf Type from \code{\link{pieData}} function
#' @param print boolean, either to print or save the image
#' @return piechart of rdfType of scientific objects
#' @export
#'
#' @examples
#' \donttest{
#' }
pieGraph = function(count.data, print = T){
  g4 = ggplot(count.data, aes(x = "", y = prop, fill = rdfType)) +
    geom_bar(width = 1, stat = "identity", color = "white") +
    coord_polar("y", start = 0, direction = -1)+
    geom_text(aes(y = lab.ypos, label = prop), color = "white", size=7)+
    scale_fill_manual(values = pal2) +
    theme_void() +
    labs(title = "Proportion of Scientific Objects within the network", subtitle = "Across all years")
  if(print == TRUE){
    g4  
  }else{
    ggsave(filename = "pieGraph.html", plot = g4)
  }
}
