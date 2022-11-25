[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)

# csiem-marvl
MARVL: The AED Model Assessment, Reporting and Visualisation Library

## Overview
The AED-MARVL repository is a collection of previously-developed scripts that have been used for comparing the model and monitored datasets such as time series plots and transect plots, but has been refined with uniform and easier user interfaces. At the moment, the AED-MARVL was designed with the following features:
- One configuration file for all functions;
- Uniform outlook (e.g. font style and size, figure resolution) of the figures and animations;
- Option to use YAML style of configurations that can be shared with other plotting software such as R and python;
- Improved function on model prediction confidence reporting;

Currently, following plotting modules are available in AED-MARVL: 
- Time series (with options to show observational data and perform model skill assessment);
- Transect (with options to show observational data on same transect);
- Transect stacked area for comparing water quality compositions;
- Transect exceedance for comparing water quality levels against guidelines;
- Site profiling of selected water quality variables;
- Nutrient budgeting;
- Sheet plotting and animations;
- Curtain plotting and animations;

## Folder Structure
- Matlab: matlab plotting scripts and libraries for MARVL;
- Project: site-specific configurations and recommended place for plotting results;
- Common: place holder for common files such as unit conversion and agency information;
- R: place holder for future development in R environment;

## Execution Instruction
- Colone the 'csiem-marvl' repository onto local computer
- Open Matlab (version 2020 or later versions), go to ‘csiem-marvl’ folder and enter ‘addpath(genpath('./'))’ to add the tools/libraries;
- Go to ‘csiem-marvl\{your project}\’ path, edit the ‘MARVL.m’ to configure the plots;
- Run ‘run_AEDmarvl('./MARVL.m','matlab')’, or ‘run_AEDmarvl('./MARVL.m','yaml')’ if you wish to use YAML style configuration


 