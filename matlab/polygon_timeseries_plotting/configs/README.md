# Configuration Files

The configuration files contain all of the paths to the field data, region shape file, model output and well as specifying the location of the output images and HTML files.

Configuring one from scratch is not recommended, so it's best to use an existing one as a template. I would recommend either Erie or HN conf files as a good base.

Below is some of the most common flags:
___
#### Function Path (required)
```
addpath(genpath('tuflowfv'));
```
___

#### Path to field data matfile, main variable name within the matfile, and the regional shapefile
```
fielddata_matfile = '..\..\..\Hawkesbury\matlab\modeltools\matfiles\hawkesbury_all.mat';
fielddata = 'hawkesbury_all';

polygon_file = '..\..\..\Hawkesbury\matlab\modeltools\gis\HN_Calibration_v3.shp';
```
The user can configure a partial subset of the polygons to be plotted. 
```
sites = [17,18,20];  % Sites in shapefile (polygon IDs) to plot
start_plot_ID = 24; % Skip vars and start plotting at this var;
end_plot_ID = 24; % Skip vars and end plotting at this var;
```
The above three flags can be set to run partial subsets of your variables and sites. This is handy in regions with highly variable data across sites.

___

#### Variables to be plotted, and their ylimits
```
plottype = 'timeseries'; 

varname = {...
    'WQ_NCS_SS1',...
    'WQ_OXY_OXY',...
};

def.cAxis(1).value = [0 300];    		%'WQ_NCS_SS1',...
def.cAxis(2).value = [0 12.5];            %'WQ_OXY_OXY',...
```
The varname cell uses Tuflowfv variables names and specifies which variables will be plotted. The def.cAxis variable will define the limits ylimits of the plot

If def.cAxis(1).value is left empty (def.cAxis(1).value = []) then no ylimit will be applied to that variables plot. If the flag isYlim (described below) is set to 0 no ylimit will be applied to all variables.



Only plotting a specified subset of variable to be implimented later.

___
#### Turn on or off field data
```
% Add field data to figure
plotvalidation = true; % true or false
```
___
#### Choose to plot and compare either surface data, bottom data or both.

This applies to both mode and field data
```
plotdepth = {'surface'};%{'surface';'bottom'} % Cell with either one or both
```

___
#### Configuration flags
```
plottype = 'timeseries'; % Used at the mopment and to be remove

istitled = 1; % Uses the Name field from the shapefile as the plot title (0 for no title)
isylabel = 1; % Adds the variable name and units (if known) to the ylabel (0 for no ylabel)
islegend = 1; % Adds the legend to the plot (0 for no legend)
isYlim = 1; % uses the def.cAxis variable to set the ylimits for each variable (0 for no limits)
isRange = 1; % Adds the color range for the surface model data to the plot
isRange_Bottom = 1; % Adds the color range for the bottom model data to the plot
```
Multiple models can be configured on the same plot, this will add ranges to all models. If set to 0, only the first model will get a range. Useful when joining models.
```
Range_ALL = 1; 
```


The isFieldRange adds the percentile lines calculated from all field data years onto the plot. The fieldprctile variable defines the different percentile ranges.
```
isFieldRange = 1;
fieldprctile = [10 90];
```

It is sometimes useful to only plot shallow or deep cells. The depth_range var specifies the depths to be included on the plot.
```
depth_range = [0.5 100];
```

___
#### Input / Output paths

```
outputdirectory = 'F:\Temp_Plots\Hawkesbury\HN_Cal_v4\Plots A5\';
htmloutput = ['F:\Cloudstor\Shared\Aquatic Ecodynamics (AED)\AED_Hawkesbury\Model_Results\HN_Cal_v4_A5\2013_2014\'];
```
The outputdirectory specifies where the raw plots are saved to. However, these an number in the 100's if enough variables and regions are plotted. The htlmoutput directory specifies where the html output is saved. The function will add all plots for a variable into a html document which can be easier to use than the raw plots.

```
 ncfile(1).name = 'T:\HN_Cal_v4\output\HN_Cal_2013_2014_2D_WQ.nc';
 ncfile(1).tfv = 'T:\HN_Cal_v4\output\HN_Cal_2013_2014_2D_HYDRO.nc';
 ncfile(1).symbol = {'-';'--'};
 ncfile(1).colour = {[0 96 100]./255,[62 39 35]./255}; % Surface and Bottom % Surface and Bottom
 ncfile(1).legend = '2013';
 
 ncfile(2).name = 'T:\HN_Cal_v4\output\HN_Cal_2014_WQ.nc';
 ncfile(2).tfv = 'I:\Hawkesbury\HN_Cal_v3_noIC\output\HN_Cal_2013_HYDRO.nc';
 ncfile(2).symbol = {'-';'--'};
 ncfile(2).colour = {[0.749019607843137 0.227450980392157 0.0039215686274509],[0.0509803921568627         0.215686274509804         0.968627450980392]}; % Surface and Bottom
 ncfile(2).legend = '2014';
 ```
Multiple models can be plotted on the same graph, and these are configured in this section:

+ ncfile(1).name: File location of the netcdf
+ ncfile(1).tfv: the function requires the "d" (depth) variable to work. Sometimes this is in a different netcdf, in which case configure this variable (else remove it entirely). However, it's best to just configure tuflow to output d in all netcdf's
+ ncfile(1).symbol: The user can configure different surface and bottom line styles
+ ncfile(1).colour: the colour of the surface and bottom median lines
+ ncfile(1).legeng: The string for that model that will appear in the legend


___
#### Start, End, tick intervals & format for the plot
```
% Makes start date, end date and datetick array

yr = 2013;
def.datearray = datenum(yr,05:04:25,01);

def.dateformat = 'mm-yy';
% Must have same number as variable to plot & in same order
```
___
#### Final configuration flags

```
def.dimensions = [14 6]; % Width & Height in cm
```
Plot dimensions
```
def.dailyave = 0; % 1 for daily average, 0 for off. Daily average turns off smoothing.
def.smoothfactor = 3; % Must be odd number (set to 3 if none)
```
If the user wants the model data to be daily averaged

```
def.font = 'Arial';

def.xlabelsize = 7;
def.ylabelsize = 7;
def.titlesize = 12;
def.legendsize = 6;
```
Font sizes
```
def.legendlocation = 'northeastoutside';
```
Legend location
```
def.visible = 'off'; % on or off
```
Display plot to screen
