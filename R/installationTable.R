#-------------------------------------------------------------------------------
# Program: installation address
# Objective: set the list of address and names of installations
# Creation: 24/05/2019
# Update:
#-------------------------------------------------------------------------------

#' @title Set the list of address and names of installations
#'
#' @param instancesNames the name of the installation(s)
#' @param instancesApi the address of the REST API of the installation(s)
#' @return installation
#' @export
#'
#' @examples
#' \donttest{
#' }
installationTable <- function(instancesNames, instancesApi ){
  inst = data.frame(name = instancesNames, api = instancesApi)
  return(inst)
}
  
  