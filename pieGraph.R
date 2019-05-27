#-------------------------------------------------------------------------------
# Program: pieGraph
# Objective: create a piechart to vizualize rdfType of objects
# Creation: 24/05/2019
# Update:
#-------------------------------------------------------------------------------

#' @title create a piechart to vizualize scientific object across the network
#'
#' @param count.data data of rdf Type from \code{\link{pieData}} function
#' @param parameterOfInterest variable to perform the decomposition (can be Installation, Type, Year, Experiments)
#' @param print boolean, either to print or save the image
#' @return piechart of scientific objects colored by the argument.
#' @export
#'
#' @examples
#' \donttest{
#' }
pieGraph = function(collectData, parameterOfInterest, print = T){
  count.data <- collectData %>%
    group_by(Installation, Type, Year, Experiments)%>%
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
    ggsave(filename = "pieGraph.html", plot = g4)
  }
}
