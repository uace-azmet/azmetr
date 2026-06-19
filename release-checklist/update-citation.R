library(cffr)
fs::file_delete("inst/CITATION")
cff <- cff_create(
  dependencies = FALSE,
  keys = list(
    # This DOI always re-directs to the most recent version on Zenodo
    doi = "10.5281/zenodo.7675685",
    `date-released` = Sys.Date()
  )
)

# Write inst/CITATION
cff_write_citation(cff, file = "inst/CITATION")

# Append citation for data source
con <- file("inst/CITATION", open = "a")
writeLines(text = 
  '
bibentry(
  bibtype = "misc",
  header  = "Please also cite the data source:",
  title = "Arizona Meteorological Network (AZMet) Data",
  author = person(family = "Arizona Meteorological Network"),
  year    = format(Sys.Date(), "%Y"),
  note = paste("Accessed", format(Sys.Date())),
  url = "https://azmet.arizona.edu"
)
',
  con = con
)
close(con)

# write CITATION.cff
cff_write(cff)
