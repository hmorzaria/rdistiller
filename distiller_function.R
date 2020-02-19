#' @title Distiller
#' @description Make initial condition nc file by slicing last time dimension for run output.nc file
#' @details Uses the NCO http://nco.sourceforge.net/ netCDF Operators, a tool kit to manipulates and analyzes data stored
#' @author Hem Nalini Morzaria Luna, email hmorzarialuna@gmail.com
#' @date February 2020
#'

ncatt_habitat <- function(thishabitat, this.innc) {
  system(paste(
    "ncatted -a bmtype,",
    thishabitat,
    ",o,c,'tracer' ",
    this.innc,
    sep = ""
  ),
  wait = TRUE)
  
}

ncatt_nitrogen <-
  function(thisattribute, this.new.innc, fill_value) {
    system(
      paste(
        "ncatted -a _FillValue,",
        thisattribute,
        ",o,d,",
        fill_value,
        " ",
        this.new.innc,
        sep = ""
      ),
      wait = TRUE
    )
    system(
      paste(
        "ncatted -a fill.value,",
        thisattribute,
        ",o,d,",
        fill_value,
        " ",
        this.new.innc,
        sep = ""
      ),
      wait = TRUE
    )
  }

fix_negative <- function(thisvariable, nc.in,this.new.innc) {
  
  print(thisvariable)
  thisvariable.data <- ncvar_get(nc.in, thisvariable)
  
  if(!is.na(any(thisvariable.data < 0))){
    
    print(paste(thisvariable,"has negative values"))
    print("Negative N values are not allowed in input.nc files")
    
   system(
      paste(
        "ncatted -a _FillValue,",
        thisvariable,
        ",o,d,",
        1e+99,
        " ",
        this.new.innc,
        sep = ""
      ),
      wait = TRUE
    )
    system(
      paste(
        "ncatted -a fill.value,",
        thisvariable,
        ",o,d,",
        1e+99,
        " ",
        this.new.innc,
        sep = ""
      ),
      wait = TRUE
    )
    
    system(
      paste(
      "ncap2 -A -s 'where(",
      thisvariable,
      "<0.) ",
      thisvariable,
      "=0.' ./",
      this.new.innc,
      sep = ""
    ), 
    wait=TRUE
    )
    
  system(
      paste(
        "ncatted -a _FillValue,",
        thisvariable,
        ",o,d,",
        0,
        " ",
        this.new.innc,
        sep = ""
      ),
      wait = TRUE
    )
  
  "Replace ne"
    system(
      paste(
        "ncatted -a fill.value,",
        thisvariable,
        ",o,d,",
        0,
        " ",
        this.new.innc,
        sep = ""
      ),
      wait = TRUE
    )
    
  } else {
    
    print(paste(thisvariable, "has no negative values"))
    
  }
  
  
}


make_distiller <-
  function(file.innc,
           this.outnc,
           this.new.innc,
           habitat.list) {
    print("Get list of output variables")
    #get output variables as a tibble
    output.variables <- nc_variables(this.outnc, detailed = TRUE)
    
    str.res.nitrogen.variables <- output.variables %>%
      filter(grepl("StructN", variable) |
               grepl("ResN", variable)) %>%
      pull(variable)
    
    #these have different fill values and should not be changed "Carrion_N" "Lab_Det_N" "Ref_Det_N" "Sed_Bact_N" "Pelag_Bact_N"
    
    nitrogen.variables <- output.variables %>%
      filter(grepl("_N$", variable)) %>%
      filter(
        !variable %in% c(
          "Carrion_N",
          "Lab_Det_N",
          "Ref_Det_N",
          "Sed_Bact_N",
          "Pelag_Bact_N"
        )
      ) %>%
      pull(variable)
    
    Sys.sleep(0.5)
    print("Create a copy of initial conditions file, this is a temporary file")
    
    this.innc <- gsub(".nc", "_distiller.nc", file.innc)
    file.copy(file.innc, this.innc)
    
    Sys.sleep(0.5)
    print("Creating cdf of the initial conditions file")
    
    #dump initial conditions file to cdf for later comparison
    system(paste("ncdump", this.innc, ">", gsub(".nc", ".cdf", this.innc), sep = " "), wait = TRUE)
    
    Sys.sleep(0.5)
    print("Slicing output file for last time dimension")
    
    
    #temporary file that will hold the last time step from the output file
    this.time.slice <- gsub(".nc", "_time.nc", this.outnc)
    
    #take last time dimension from out nc
    system(paste("ncks -O -F -d t,-1", this.outnc, this.time.slice, sep =
                   " "),
           wait = TRUE)
    #dump last time dimension nc file to cdf
    system(paste(
      "ncdump",
      this.time.slice,
      ">",
      gsub(".nc", ".cdf", this.time.slice),
      sep = " "
    ), wait = TRUE)
    
    Sys.sleep(0.5)
    print("Append variable values from the last time slice")
    
    #append variables, transfer variable values from the time slice to the initial conditions nc
    #note this will update the copy of the initial conditions file
    system(paste("ncks -A", this.time.slice, this.innc, sep = " "), wait =
             TRUE)
    
    #dump modified initial conditions file to cdf for testing
    #system(paste("ncdump", this.innc, ">", gsub(".nc",".cdf",this.innc), sep= " "), wait = TRUE)
    
    #change some variable attributes that are different in the output file
    
    Sys.sleep(0.5)
    print("Change variable attributes so they match the initial conditions file")
    
    system(paste("ncatted -a units,numlayers,o,d,1", this.innc, sep = " "),
           wait = TRUE)
    system(paste("ncatted -a units,topk,o,d,1", this.innc, sep = " "),
           wait = TRUE)
    
    
    lapply(habitat.list, ncatt_habitat, this.innc)
    
    #eliminate the is_boundary variable which is not used in the initial nc file
    # --no_abc turns off alphabetization of variables
    system(
      paste(
        "ncks --no_abc -C -O -x -v is_boundary",
        this.innc,
        this.new.innc,
        sep = " "
      ),
      wait = TRUE
    )
    
    
    nc.in <- nc_open(this.new.innc)
    
    lapply(nitrogen.variables, fix_negative, nc.in,this.new.innc)
    
    #this replaces the fill values for Structural and Residual Nitrogen
    #so that the rN ans Snvalues at the last time step can be used
    
    N.attributes <- c("'ResN$'", "'StructN$'")
    
    Sys.sleep(0.5)
    print("Replace the fill values for _N variables")
    
    lapply(N.attributes, ncatt_nitrogen, this.new.innc, fill_value = 0)
    
    Sys.sleep(0.5)
    print("Remove temporary files")
    
    file.remove(this.innc, this.time.slice)
    
    Sys.sleep(0.5)
    print("Create cdf of new initial conditions file")
    
    #dump new initial conditions file
    system(paste(
      "ncdump",
      this.new.innc,
      ">",
      gsub(".nc", ".cdf", this.new.innc),
      sep = " "
    ), wait = TRUE)
    
   print(paste("Done creating",this.new.innc))
   print("History of changes to the *.nc file will be appended, this will not affect your run")
  }
