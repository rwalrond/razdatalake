library(razdatalake)

# Directory ID (Tenant ID)
tenantID <- ""
# Application ID (Client ID)
clientID <- ""
# Api Key
apiKey <- ""


# Authenticate ----
token <- getToken(tenantID, clientID, apiKey)

# Download contents of folder into single `data.table` ----
dt <- downloadFiles("DATA LAKE NAME", "FOLDER NAME", token)

# Persist in Azure Data Lake ----
jsonlite::stream_out(dt, file("dt.json"))
putFile("DATA LAKE NAME", "NEW FOLDER NAME", "dt.json", token)
