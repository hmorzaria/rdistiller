#' @title Distiller
#' @description Make initial condition nc file by slicing last time dimension for run output.nc file
#' @details Uses the NCO http://nco.sourceforge.net/ netCDF Operators, a tool kit to manipulates and analyzes data stored
#' @author Hem Nalini Morzaria Luna, email hmorzarialuna@gmail.com
#' @date February 2020

# *** NOTE: To use you need the NCO netCDF operators installed
# this script includes installation in Linux Ubuntu 
# Instructions to install in other operating systems are here http://nco.sourceforge.net/

system("sudo apt-get install -y nco", wait=TRUE)


# List of packages for session, will install automatically if not available
.packages = c("devtools","rcdo","dplyr","ncdf4")
# Load packages into session 
lapply(.packages, require, character.only=TRUE)

devtools::install_github("r4ecology/rcdo", dependencies = TRUE)

# Install CRAN packages (if not already installed)
.inst <- .packages %in% installed.packages()
if(length(.packages[!.inst]) > 0) install.packages(.packages[!.inst], dependencies = TRUE)

# Load packages into session 
lapply(.packages, require, character.only=TRUE)

#select your work folder
setwd("~/distiller")
source("distiller_function.R")

# initial conditions file, willnot be modified
file.innc <- "AMPSnm.nc"

#output file from the run that will be sliced
this.outnc <- "AMPS_OUT_B286.nc"

#name of final new input nc file
this.new.innc <- "AMPSnm_B286.nc"

#assumes that habitats used in Atlantis are 
habitat.list <- c("reef","flat","soft","canyon","eddy")

#Create an input nc file using the ouput file from the run selected
#negative 
make_distiller(file.innc,this.outnc,this.new.innc,habitat.list)


#NoBa example

# initial conditions file, willnot be modified
file.innc <- "nordic_biol_v23.nc"

#output file from the run that will be sliced
this.outnc <- "nordic_runresults_01.nc"

#name of final new input nc file
this.new.innc <- "NoBa_test01.nc"

#assumes that habitats used in Atlantis are 
habitat.list <- c("reef","flat","soft","canyon","eddy")

#Create an input nc file using the ouput file from the run selected
#negative 
make_distiller(file.innc,this.outnc,this.new.innc,habitat.list)


  