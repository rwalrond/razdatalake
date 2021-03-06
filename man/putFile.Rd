% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/apiUtils.r
\name{putFile}
\alias{putFile}
\title{putFile}
\usage{
putFile(datalake, folder, filename, token)
}
\arguments{
\item{datalake}{String the data lake name.}

\item{folder}{String the subfolder name.}

\item{filename}{String the file name.}

\item{token}{String the Bearer token.}
}
\value{
List the `httr` response.
}
\description{
NOTE: File must be stored on disk in the current directory.
}
