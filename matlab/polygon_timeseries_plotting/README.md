# Plottfv Polygon
**ver. 0.9**

## Overview

Plottfv_polygon.m is a series of matlab functions to allow the user to visualise TuflowfV model output against field data within a polygon region. 

Model data is plotted as the median value of surface or bottom data within a region, as well as adding option range bands at specified intervals.

![alt text](https://github.com/AquaticEcoDynamics/aed_matlab_modeltools/blob/master/TUFLOWFV/polygon_timeseries_plotting/example_files/Example1.png "Example 1")

Additionally the script will also plot the historical percentage bands at user specified intervals across the entire field dataset.

## Getting Started

Before running the plottfv_polygon function the user needs to create / configure three separate files:

+ A Field Data Matfile
+ A Regional Polygon Shapefile
+ A configuration file contains the links to all of the different input files, output directories and setting for the function.

Once all three are configured correctly, the function is called by:

```matlab
plottfv_polygon config
```
Where "config" is the name of your configuration file outlined below.

**NOTE: The field data, regional shapefile and the model all need to be in the same projection**

### Field Data Matfile

This file is the most complex to create, as it requires a very specific format. A word document outlining the format can be found [in the examples directory](https://github.com/AquaticEcoDynamics/aed_matlab_modeltools/blob/master/TUFLOWFV/polygon_timeseries_plotting/example_files/Mat%20File%20data%20structure.docx)

### Regional Polygon Shapefile

This file will define each region to be plotted. The file itself is reletively easy to create, with an example file in the examples directory. However there are some requirements:

+ The file must be in the same project as the model and field data
+ The file must be of type polygon and NOT polygonz (matlab has trouble reading it)
+ The shape file must contain the folowing fields, Name and Plot_Order.

### Configuration file

Once the other two files have been created, it is the configuration file that ties them together with the model output. All configurations are stored in the config directory. More information about the flags and settings requried can be found in the readme file.

## Units

By default the function will plot the data in "model units". However, for a small number of common variables there is a subfunction that will convert both the model and field data into different units.

https://github.com/AquaticEcoDynamics/aed_matlab_modeltools/blob/master/TUFLOWFV/polygon_timeseries_plotting/tuflowfv/tfv_Unit_Conversion.m
