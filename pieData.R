#-------------------------------------------------------------------------------
# Program: pieData
# Objective: create dataframe for rdf Type Data
# Creation: 24/05/2019
# Update:
#-------------------------------------------------------------------------------

#' @title create dataframe for piechart visualization
#'
#' @param typeData rdf Type data of the scientific objects from \code{\link{typeData}}
#' @return installation experiments data
#' @export
#'
#' @examples
#' \donttest{
#' }
pieData = function(typeData){
  count.data <- typeData %>%
    dplyr::group_by(rdfType)%>%
    summarise(total = sum(Freq))%>%
    mutate(prop = round(total/sum(total), digits = 2))%>%
    mutate(lab.ypos = 1-round(cumsum(prop) - 0.5*prop, digits = 2))%>%
    arrange(desc(prop))
  count.data
}
