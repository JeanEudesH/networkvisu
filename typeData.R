#-------------------------------------------------------------------------------
# Program: typeData
# Objective: create dataframe for rdfType Data
# Creation: 24/05/2019
# Update:
#-------------------------------------------------------------------------------

#' @title create dataframe for rdfType Data
#'
#' @param inst informations of the installations from \code{\link{installationTable}}
#' @return installation rdfType data
#' @export
#'
#' @examples
#' \donttest{
#' }
typeData = function(inst){
  graphData = apply(X = inst, MARGIN = 1, FUN = collectData)
  typeData = data.frame()
  for( i in 1:length(graphData)){
    typeData = rbind(typeData, graphData[[i]][[1]])
  }
  return(typeData)
}
