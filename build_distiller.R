#' @title  Code to run Distiller on NoBA to capture result from the end of an Atlantis run
#' @description  Runs Distiller and creates a new input nc file
#' @details INPUT: 1) nc initial conditions file,  2) nc file results from a run, 3) run.sh for Distiller, 4) run.prm for Distiller, 5) bgm file
#' @details OUTPUT: 1) output nc file with last time step of results file, 2) ShinyRAtlantis will open window to review output nc file
#' @details see Atlantis Wiki https://confluence.csiro.au/display/Atlantis/CDFDistiller
#' @details We used a version of Distiller corrected for the current version of Atlantis
#' @details made by Javier Porobic jporobicg@gmail.com 
#' @author Hem Nalini Morzaria Luna hmorzarialuna@gmail.com
#' @date June 2019

# set locale to avoid multibyte errors
Sys.setlocale("LC_CTYPE", "en_US.UTF-8")
# https://www.r-bloggers.com/web-scraping-and-invalid-multibyte-string/

# List of packages for session
.packages = c("devtools","here","tidyverse","R.utils",
              "RNetCDF","ReactiveAtlantis","shinyrAtlantis")

# Install CRAN packages (if not already installed)
.inst <- .packages %in% installed.packages()
if(length(.packages[!.inst]) > 0) install.packages(.packages[!.inst])

# Load packages into session 
lapply(.packages, require, character.only=TRUE)

devtools::install_github('jporobicg/shinyrAtlantis')
devtools::install_github('Atlantis-Ecosystem-Model/ReactiveAtlantis')

# Load packages into session, for packages installed from github
lapply(.packages, require, character.only=TRUE)

#### User specifications

#modify run.sh manually, should have CDFDistiller -i <name results.nc> -o <name ouput.nc> -r run.prm
#also edit run.prm
sh.file <- "run.sh"

#initial conditions file
initial.conditions.nc <- "nordic_biol_v23.nc"
#run ouput file
results.nc <- "nordic_runresults_01.nc"
#name for the output nc file from Distiller, should match the one specified in run.sh
output.nc <- "testJune12.nc"
#bgm file, needed for ShinyRAtlantis
bgm.file <- 'Nordic02.bgm'

#this should be the folder where Distiller folder is located
folder.distiller <- "~/cdfdistiller/"
#work directory where nc files are stored
target.dir <- "~/distiller"

####

# We used a version of Distiller corrected for the current version of Atlantis not on SVN
# obtained from Javier Porobic jporobicg@gmail.com 

# Get code from CSIRO SVN
#system("svn co https://svnserv.csiro.au/svn/ext/atlantis/cdfDistiller --username hmorzarialuna.992 --password Bybevhg6 --quiet", wait = TRUE)
#

#give write read permission to Distiller folder
system("sudo chmod -R a+rwx ~/distiller", wait = TRUE)

# Rebuild recompile via MAKE: 
system(paste("cd ",folder.distiller, "; aclocal; autoheader; autoconf; automake -a; ./configure; sudo make CFLAGS='-Wno-misleading-indentation -Wno-format -Wno-implicit-fallthrough'; sudo make -d install",sep=""), wait = TRUE)

# copy Distiller executable to work dir
system(paste("sudo cp -u",target.dir), wait = TRUE)

setwd(target.dir)

#run Distiller

system(paste("sudo flip -uv *; sudo chmod +x ", sh.file,"; sudo sh ./", sh.file, sep=""), wait = TRUE)

#unpack to compare manually 
system(paste("ncdump",initial.conditions.nc,"> ini_conditions.cdf"), wait = TRUE)

#unpack run results nc
system(paste("ncdump",results.nc,"> results.cdf"), wait = TRUE)

# view the new nc file from Distiller using Shiny Atlantis

init.obj <- make.sh.init.object(bgm.file, output.nc)
sh.init(init.obj)

#use this if you want to also look at the initial conditions file
# view the initial conditions file

#init.obj <- make.sh.init.object(bgm.file, initial.conditions.nc)
#sh.init(init.obj)


