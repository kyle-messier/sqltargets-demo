################################################################################
############################         STAGE          ############################

# Check .libPaths().
cat("Active library paths:\n")
.libPaths()

# Check PATH.
cat("Active PATH:\n")
Sys.getenv("PATH")

# Check LD_LIBRARY_PATH
cat("Active LD_LIBRARY_PATH:\n")
Sys.getenv("LD_LIBRARY_PATH")

############################      RUN PIPELINE      ############################
targets::tar_make(reporter = "verbose_positives")
