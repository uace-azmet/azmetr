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

cff_write_citation(cff, file = "inst/CITATION")
cff_write(cff)
