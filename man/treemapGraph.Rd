% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/treemapGraph.R
\name{treemapGraph}
\alias{treemapGraph}
\title{create a treemap to vizualize scientific object across the network}
\usage{
treemapGraph(computedDF, class1, class2)
}
\arguments{
\item{computedDF}{data of rdf Type from collectData (\code{\link{collectSensor}}, \code{\link{collectVariable}}, \code{\link{collectScientificObject}}) functions}

\item{class1}{variable to perform the first decomposition (can be Installation, Type, Year, Experiments)}

\item{class2}{variable to perform the second decomposition (can be Installation, Type, Year, Experiments)}
}
\value{
treemap of scientific objects colored by the argument.
}
\description{
create a treemap to vizualize scientific object across the network
}
\examples{
\donttest{
INST = installationTable(
           instancesApi = c("opensilex.org/openSilexAPI/rest/"),
           instancesNames = c("opensilexDemo")
       )
DATA = collectScientificObject(INST)
pieGraph(DATA, parameterOfInterest = "Type")
} 
}
