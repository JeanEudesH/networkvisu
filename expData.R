#-------------------------------------------------------------------------------
# Program: typeData
# Objective: create dataframe for experiments Data
# Creation: 24/05/2019
# Update:
#-------------------------------------------------------------------------------

#' @title create dataframe for experiments Data
#'
#' @param inst informations of the installations from \code{\link{installationTable}}
#' @return installation experiments data
#' @export
#'
#' @examples
#' \donttest{
#' }
expData = function(inst){
  graphData = apply(X = inst, MARGIN = 1, FUN = collectData)
  typeData = data.frame()
  for( i in 1:length(graphData)){
    expData = rbind(expData, graphData[[i]][[2]])
  }
  return(expData)
}
