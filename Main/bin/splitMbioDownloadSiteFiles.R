#!/usr/bin/env Rscript
library(data.table)

args <- commandArgs(TRUE)

dataDir <- args[1]
if (is.null(dataDir)) {
  stop("No directory provided for shiny files!")
} else {
  if (!file.exists(dataDir)) {
    stop("Directory provided for shiny files does not exist!")
  }
}
baseFileName <- args[2]
#can change if we dont want to assume anything
if (is.null(baseFileName)) {
  baseFileName <- "downloadSite"
}

#and create ontology downloadable file
metadata.temp <- fread(paste0(dataDir, "/ontologyMetadata.txt"))
message("read in temp ontology file...")
if (!any(grepl("Error", metadata.temp[1]))) {
    #ontology file first
    metadata.file <- metadata.temp
    names(metadata.file) <- tolower(names(metadata.file))
    fwrite(metadata.file, paste0(dataDir, "/", baseFileName, "_ontologyMetadata.txt"), sep = '\t', na = "NA")
    message("ontology file written.. removing temp ontology file now.")
    file.remove(paste0(dataDir, "/ontologyMetadata.txt"))
} else {
  stop("Ontology file missing or unreadable. Cannot create download files!")
}

data <- fread(paste0(dataDir, "/", baseFileName, "_masterDataTable.txt"))
message("read in temp data file...")
#split master file into individual datasets
datasets <- lapply(split(data, data$DATASET_NAME), as.data.table)

for (i in seq_along(datasets)) {
  df <- datasets[[i]]
  df <- df[,which(unlist(lapply(df, function(x)!all(is.na(x))))),with=F]
  df <- df[,which(unlist(lapply(df, function(x)!all(x == "")))),with=F]
  filename <- paste0(baseFileName, "_", df$DATASET_NAME[i], ".txt")
  fwrite(df, file.path(dataDir, filename), sep='\t', na="NA")
  message("data file written for ", df$DATASET_NAME[i])
}
file.remove(paste0(dataDir, "/", baseFileName, "_masterDataTable.txt"))
message("temp data file removed...")
