#' getToken
#'
#' @export
#'
#' @param tenantID String the tenant Id.
#' @param clientID String the client Id.
#' @param apiKet String the API secret.
#'
#' @return String the access token
getToken <- function(tenantID, clientID, apiKey) {
  body <- list(
    grant_type="client_credentials",
    resource="https://management.core.windows.net/",
    client_id=clientID,
    client_secret=apiKey
  )

  url <- paste0("https://login.microsoftonline.com/", tenantID, "/oauth2/token")
  res <- httr::POST(url, body = body)
  if (res$status_code == 200) {
    js <- httr::content(res, as = "parsed")
    js$access_token
  }
  else {
    print(res)
    stop("HTTP Error")
  }
}


#' listFolder
#'
#' @export
#'
#' @param datalake String the data lake name.
#' @param folder String the subfolder name.
#' @param token String the Bearer token.
#'
#' @return List complete contents of a folder.
listFolder <- function(datalake, folder, token) {
  url <- paste0("https://", datalake, ".azuredatalakestore.net/webhdfs/v1/", folder, "?op=LISTSTATUS")
  res <- httr::GET(url, httr::add_headers(Authorization = paste0("Bearer ", token)))
  if (res$status_code == 200) {
    js <- httr::content(res, as = "parsed")
    js$FileStatuses[[1]]
  }
  else {
    print(res)
    stop("HTTP Error")
  }
}


#' listFiles
#'
#' @export
#'
#' @param datalake String the data lake name.
#' @param folder String the subfolder name.
#' @param token String the Bearer token.
#'
#' @return List pathSuffix for each file in the folder.
listFiles <- function(datalake, folder, token) {
  folders <- listFolder(datalake, folder, token)
  vapply(folders, function(x) { x$pathSuffix }, FUN.VALUE = character(1))
}


#' getFile
#'
#' @export
#'
#' @param datalake String the data lake name.
#' @param folder String the subfolder name.
#' @param filename String the file name.
#' @param token String the Bearer token.
#'
#' @return String text contents of a file.
getFile <- function(datalake, folder, filename, token) {
  url <- paste0("https://", datalake, ".azuredatalakestore.net/webhdfs/v1/", folder, "/", filename, "?op=OPEN&read=true")
  res <- httr::GET(url, httr::add_headers(Authorization = paste0("Bearer ", token)))
  if (res$status_code == 200) {
    js <- httr::content(res, as = "text")
    js
  }
  else {
    print(res)
    stop("HTTP Error")
  }
}


#' putFile
#'
#' @description NOTE: File must be stored on disk in the current directory.
#'
#' @export
#'
#' @param datalake String the data lake name.
#' @param folder String the subfolder name.
#' @param filename String the file name.
#' @param token String the Bearer token.
#'
#' @return List the `httr` response.
putFile <- function(datalake, folder, filename, token) {

  url <- paste0("https://", datalake, ".azuredatalakestore.net/webhdfs/v1/", folder, "/", filename, "?op=CREATE&write=true")
  res <- httr::PUT(
    url,
    body = httr::upload_file(filename),
    config = httr::add_headers(
      Authorization = paste0("Bearer ", token),
      `Transfer-Encoding` = "chunked"
    ),
    httr::content_type_json()
  )
  if (res$status_code == 201) {
    res
  }
  else {
    print(res)
    stop("HTTP Error")
  }
}


#' downloadFiles
#'
#' @description Downloads all files in a datalake folder. Assumes files are ndjson format.
#'
#' @export
#'
#' @param datalake String the data lake name.
#' @param folder String the subfolder name.
#' @param token String the Bearer token.
#'
#' @return data.table
downloadFiles <- function(datalake, folder, token) {
  fileList <- listFiles(datalake, folder, token)
  xs <- lapply(fileList, function(filename){
    jsonlite::stream_in(textConnection(getFile(datalake, folder, filename, token)))
  })
  data.table::rbindlist(xs)
}
