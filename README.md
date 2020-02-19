# rdistiller
Make an Atlantis model input file based on the output for an existing run

Functions are in distiller_function.R, the code to call is in slice_results.R
The code leverages NCO, a collection of utilities to manipulate and analyze netCDF files http://nco.sourceforge.net/nco.html

The code has been tested on Linux, with outputs from several Atlantis models.
It requires two inputs, the current initial conditions NC file and the run output NC file. The user should also specify the desired name of the output file. The code will automatically extract the last time step from the file and reads all variables and attributes from the nc file. No additional inputs or files are needed.
