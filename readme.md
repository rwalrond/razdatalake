# R Azure Data Lake REST API Wrapper

A simple wrapper around the REST API for Azure's Data Lake. Simplifies authentication, downloading, and `PUT`ing files back into the Data Lake.  

# Installation

```{R}
devtools::install_github("rwalrond/razdatalake")
```

# Example Usage

```{R}
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
## Create file with contents
putFile("DATA LAKE NAME", "NEW FOLDER NAME", "dtContents.json", token, contents=jsonlite::toJSON(dt))
```
