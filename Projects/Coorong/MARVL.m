% .*((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((*.%
%.((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((%
%                                 ____    _    _   _                      %
%.(((((((      |\    /|    /\    |    \  \ \  / / | |          (((((((((((%
%.(((((((      | \  / |   /  \   | Π  /   \ \/ /  | |          (((((((((((%
%.(((((((      |  \/  |  / Δ  \  | |\ \    \  /   | |____      (((((((((((%
%.(((((((      |_|\/|_| /_/  \_\ |_| \_\    \/    |______|     (((((((((((%
%                                                                         %
%.((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((%
% .*((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((*.%
% The AED Model Assessment, Reporting and Visualisation Library
%--------------------------------------------------------------------------
% MARVL configuration for Coorong
MARVLs = struct;

%% master configuration: --------------------------------------------------
%
% List here the available MARVL modules, state variables, model outputs,
%   processed field data, and general plotting features to be included
%   in the plotting.
%
% Note: if multiple NetCDF outpus are listed, some modules only deal with
%  the first NetCDF output such as the transect_stackedArea module.
%
%--------------------------------------------------------------------------
master.modules = {...
       'timeseries';...
    %   'transect';  ...
    %   'transect_stackedArea'; ...
    %   'transect_exceedance'; ...
    %   'sheet'; ...
    %   'curtain'; ...
    %   'site_profiling'; ...
    %   'sediment_profiling'; ...
    };

% state variable Configuration
%    column 1: AED names;
%    column 2: user-defined names
master.varname = {...
    'WQ_NIT_AMM','NH_4';...
    'WQ_NIT_NIT','NO_3';...
    'WQ_PHS_FRP','PO_4';...
    'WQ_OXY_OXY','DO';...
    'WQ_OGM_DON','DON';...
    'WQ_OGM_DOP','DOP';...
    'WQ_OGM_POC','POC';...
    'WQ_OGM_PON','PON';...
    'WQ_OGM_POP','POP';...
    'SAL','Salinity';...
    'TEMP','Temperature';...
    'WQ_OGM_DOC','DOC';...
    'WQ_PHY_GRN','GRN';...
    'WQ_PHY_DIATOM','DIATOM';...
    'WQ_PHY_CRYPT','CRYPT';...
    'WQ_PHY_DINO','DINO';...
    'WQ_DIAG_TOT_TN','TN';...
    'WQ_DIAG_TOT_TP','TP';...
    'WQ_DIAG_PHY_TCHLA','TCHLA';...
    'WQ_DIAG_NIT_AMM_DSF','AMMDSF';...
    'WQ_DIAG_NIT_NIT_DSF','NITDSF';...
    'WQ_DIAG_PHS_FRP_DSF','FRPDDF';...
    'WQ_DIAG_OGM_POC_SWI','POCSWI';...
    'WQ_DIAG_OGM_DOC_SWI','DOCSWI';...
    'WQ_DIAG_OGM_DON_SWI','DONSWI';...
    'WQ_DIAG_OGM_DOP_SWI','DOPSWI';...
    'WQ_DIAG_OGM_DOC_MIN','DOCMIN';...
    'WQ_DIAG_OGM_DON_MIN','DONMIN';...
    'WQ_DIAG_OGM_DOP_MIN','DOPMIN';...
    'WQ_DIAG_TOT_TSS','TSS';...
    'WQ_DIAG_TOT_TOC','TOC';...
    'WQ_DIAG_TOT_TURBIDITY','Turbidity';...
    'WQ_DIAG_PHY_TPHY','TPHY';...
    'WQ_DIAG_PHY_PHY_SWI_N','PHYSWIN';...
    'WQ_DIAG_PHY_PHY_SWI_P','PHYSWIP';...
    'WQ_DIAG_MAG_MAG_BEN','MAGBEN';...
    'WQ_DIAG_PHY_MPB_BEN','MPBBEN';...
    'WQ_DIAG_PHY_UPT_NH4','PHYUPTNH4';...
    'WQ_DIAG_PHY_UPT_NO3','PHYUPTNO3';...
    'WQ_DIAG_PHY_UPT_PO4','PHYUPTPO4';...
    'WQ_DIAG_NIT_NITRIF','NITRIF';...
    'WQ_DIAG_NIT_DENIT','DENIT';...
    'WQ_DIAG_MAG_PUP_BEN','MAG-PUP-BEN';...
    'WQ_DIAG_MAG_NUP_BEN','MAG-NUP-BEN';...
    'WQ_DIAG_MAG_IN_BEN','MAG-IN-BEN';...
    'WQ_DIAG_MAG_IP_BEN','MAG-IP-BEN';...
    'WQ_DIAG_MAG_MAG_BEN','MAG-MAG-BEN';...
    'WQ_DIAG_MAG_ULVA_A_C2P_BEN','ULVA-A-C2P-BEN';...
    'WQ_DIAG_MAG_ULVA_A_C2N_BEN','ULVA-A-C2N-BEN';...
    'WQ_DIAG_MAG_ULVA_A_N2P_BEN','ULVA-A-N2P-BEN';...
    'WQ_DIAG_MAG_ULVA_B_C2P_BEN','ULVA-B-C2P-BEN';...
    'WQ_DIAG_MAG_ULVA_B_C2N_BEN','ULVA-B-C2N-BEN';...
    'WQ_DIAG_MAG_ULVA_B_N2P_BEN','ULVA-B-N2P-BEN';...
    'WQ_DIAG_MAG_ULVA_C_C2P_BEN','ULVA-C-C2P-BEN';...
    'WQ_DIAG_MAG_ULVA_C_C2N_BEN','ULVA-C-C2N-BEN';...
    'WQ_DIAG_MAG_ULVA_C_N2P_BEN','ULVA-C-N2P-BEN';...
    'WQ_DIAG_PHY_DINO_NTOP','DINO-NTOP';...
    'WQ_DIAG_PHY_DIATOM_NTOP','DIATOM-NTOP';...
    'WQ_DIAG_PHY_CRYPT_NTOP','CRYPT-NTOP';...
    'WQ_DIAG_PHY_GRN_NTOP','GRN-NTOP';...
    };
master.add_human = 1; % option to use user-define names, if 0 use AED names

% Models
master.ncfile(1).name = '/Projects2/CDM2022/HCHB-paper-warmup-newBathy-MAG-DONV2-fixedV4/output_basecase_005/eWater_basecase_005V4_test_all.nc';
%'/Projects2/CDM2022/HCHB-paper-warmup-newBathy-MAG/output_basecase_005V4Boobook//eWater_basecase_005V4_test_all.nc';
%'/Projects2/CDM2022/eWater2022-scenarios-VH-paper-warmup-newtestV2/output_basecase_005/eWater_basecase_005_all.nc';
%'/Projects2/CDM2022/CDM22_newMesh_newMZ_testing/output_basecase_005/eWater_basecase_newMesh_BB_TEST_v4_all.nc';
%'/Projects2/CDM2022/eWater2022-scenarios-VH-paper-warmup-newtest/output_basecase_005_t1/eWater_basecase_005_all.nc';
%'/Projects2/CDM2022/eWater2022-scenarios-VH-paper-warmup/output_basecase_005/eWater_basecase_005_all.nc';
%'/Projects2/CDM2022/eWater2022-scenarios-VH/output_basecase/eWater_basecase_all.nc';
%'/Projects2/CDM2022/eWater2022-scenarios-VH-paper-warmup-nit-Xsp/output_basecase_005/eWater_basecase_005_allV1.nc';
master.ncfile(1).legend = 'V4';
master.ncfile(1).tag = 'TFV';

% master.ncfile(2).name = '/Projects2/CDM2022/HCHB-paper-warmup-newBathy-MAG-DONV2-fixedV3/output_basecase_005/eWater_basecase_005V4_test_all.nc';
 %'/Projects2/CDM2022/HCHB-paper-warmup-newBathy-MAG/output_basecase_005V5Sittella/eWater_basecase_005V4_test_all.nc';
 %'/Projects2/CDM2022/eWater2022-scenarios-VH-paper-warmup-newtest/output_basecase_005_t1/eWater_basecase_005_all.nc';
 %'/Projects2/CDM2022/eWater2022-scenarios-VH-paper-warmup-nit/output_basecase_005/eWater_basecase_005_all.nc';
% master.ncfile(2).legend = 'V3';
% master.ncfile(2).tag = 'TFV';

 %master.ncfile(3).name = '/Projects2/CDM2022/HCHB-paper-warmup-newBathy-MAG-DONV2-fixedV4/output_basecase_005/eWater_basecase_005V4_test_all.nc';
 %master.ncfile(3).legend = 'V4';
 %master.ncfile(3).tag = 'TFV';
% 
% master.ncfile(4).name = '/Projects2/CDM2022/eWater2022-scenarios-VH/output_NE3/eWater_NE3_all.nc';
% master.ncfile(4).legend = 'NE3';
% master.ncfile(4).tag = 'TFV';
% 
% master.ncfile(5).name = '/Projects2/CDM2022/eWater2022-scenarios-VH/output_NE4/eWater_NE4_all.nc';
% master.ncfile(5).legend = 'NE4';
% master.ncfile(5).tag = 'TFV';
%  
% master.ncfile(6).name = '/Projects2/CDM2022/eWater2022-scenarios-VH/output_NE5/eWater_NE5_all.nc';
% master.ncfile(6).legend = 'NE5';
% master.ncfile(6).tag = 'TFV';

% field data, stored in standard AED .mat format
master.add_fielddata = 1;
master.fielddata_matfile = '/Projects2/busch_github/CDM/data/store/archive/cllmm_noALS.mat';
master.fielddata = 'cllmm';

% general plotting features
master.font = 'Times New Roman';
master.fontsize   = 8;
master.xlabelsize = 9;
master.ylabelsize = 9;
master.titlesize  = 10;
master.legendsize = 6;
master.visible = 'off'; % on or off

MARVLs.master = master; clear master;

%% timeseries setting:-----------------------------------------------------
%  configurations for the marvl_plot_timeseries.m function.
% -------------------------------------------------------------------------

timeseries.start_plot_ID = 1; % select which variable to plot
timeseries.end_plot_ID = 16;

timeseries.plotvalidation = true; % Add field data to figure (true or false)
timeseries.plotmodel = 1;

timeseries.plotdepth = {'surface'};  %  {'surface','bottom'} Cell-array with either one
timeseries.depth_range = [0.2 100];
timeseries.validation_minmax = 0;    % option to add max/min observations
timeseries.isModelRange = 1;         % option to plot model range with below percentile
timeseries.pred_lims = [0.10,0.25,0.5,0.75,0.90];

timeseries.isFieldRange = 0;         % option to add plot field data range
timeseries.fieldprctile = [10 90];
timeseries.isHTML = 1;

% polygon file define the site areas
timeseries.polygon_file = '/Projects2/busch_github/CDM/gis/supplementary/HCHB_Report_Sites.shp';
%'/Projects2/busch_github/CDM/gis/supplementary/Coorong/Coorong_obs_sites.shp';

% option to plot all sites or selected sites
timeseries.plotAllsites = 1;
if timeseries.plotAllsites == 0
    timeseries.plotsite = [8 9];
end

% section for model skill calculations
timeseries.add_error = 1;
timeseries.isSaveErr = 1;
timeseries.obsTHRESH = 5;
timeseries.showSkill = 1;
timeseries.scoremethod = 'range'; % 'range' or 'median'

% selection of model skill assessment, 1: activated; 0: not activated
timeseries.skills = [1,... % r: regression coefficient (0-1)
    1,... % BIAS: bias relative to mean observation (%)
    1,... % MAE: mean absolute error
    1,... % RMSE: root mean square error
    1,... % NMAE: MAE normalized to mean observation
    1,... % NRMS: RMSE normalized to mean observation
    1,... % MEF: model efficienty, Nash-Sutcliffe Efficiency
    ];
timeseries.outputdirectory = '/Projects2/CDM2022/AED-MARVL-v0.4/Projects/Coorong/V4_validation_range/RAW/';
timeseries.htmloutput = '/Projects2/CDM2022/AED-MARVL-v0.4/Projects/Coorong/V4_validation_range/HTML/';
timeseries.ErrFilename = '/Projects2/CDM2022/AED-MARVL-v0.4/Projects/Coorong/V4_validation_range/errormatrix.mat';

timeseries.ncfile(1).symbol = {'-'};
timeseries.ncfile(1).translate = 1;
timeseries.ncfile(1).colour = {[166,86,40]./255;[8,88,158]./255};% Surface and Bottom
timeseries.ncfile(1).edge_color = {[166,86,40]./255;[8,88,158]./255};
timeseries.ncfile(1).col_pal_color_surf =[[176 190 197]./255;[162 190 197]./255;[150 190 197]./255;[150 190 197]./255];
timeseries.ncfile(1).col_pal_color_bot  =[[237,248,251]./255;[204,236,230]./255;[153,216,201]./255;[102,194,164]./255];

timeseries.ncfile(2).symbol = {'-'};
timeseries.ncfile(2).translate = 1;
timeseries.ncfile(2).colour = {[27,158,119]./255;[27,158,119]./255};% Surface and Bottom
timeseries.ncfile(2).edge_color = {[8,88,158]./255;[8,88,158]./255};
timeseries.ncfile(2).col_pal_color_surf =[[102,194,164]./255;[162 190 197]./255;[150 190 197]./255;[150 190 197]./255];
timeseries.ncfile(2).col_pal_color_bot  =[[102,194,164]./255;[204,236,230]./255;[153,216,201]./255;[102,194,164]./255];

timeseries.ncfile(3).symbol = {'-'};
timeseries.ncfile(3).translate = 1;
timeseries.ncfile(3).colour = {[217,95,2]./255;[217,95,2]./255};% Surface and Bottom
timeseries.ncfile(3).edge_color = {[215,48,39]./255;[215,48,39]./255};
timeseries.ncfile(3).col_pal_color_surf =[[102,194,164]./255;[162 190 197]./255;[150 190 197]./255;[150 190 197]./255];
timeseries.ncfile(3).col_pal_color_bot  =[[102,194,164]./255;[204,236,230]./255;[153,216,201]./255;[102,194,164]./255];

timeseries.ncfile(4).symbol = {'-'};
timeseries.ncfile(4).translate = 1;
timeseries.ncfile(4).colour = {[117,112,179]./255;[117,112,179]./255};% Surface and Bottom
timeseries.ncfile(4).edge_color = {[127,191,123]./255;[127,191,123]./255};
timeseries.ncfile(4).col_pal_color_surf =[[102,194,164]./255;[162 190 197]./255;[150 190 197]./255;[150 190 197]./255];
timeseries.ncfile(4).col_pal_color_bot  =[[102,194,164]./255;[204,236,230]./255;[153,216,201]./255;[102,194,164]./255];

timeseries.ncfile(5).symbol = {'-'};
timeseries.ncfile(5).translate = 1;
timeseries.ncfile(5).colour = {[231,41,138]./255;[231,41,138]./255};% Surface and Bottom
timeseries.ncfile(5).edge_color = {[44,162,95]./255;[44,162,95]./255};
timeseries.ncfile(5).col_pal_color_surf =[[102,194,164]./255;[162 190 197]./255;[150 190 197]./255;[150 190 197]./255];
timeseries.ncfile(5).col_pal_color_bot  =[[102,194,164]./255;[204,236,230]./255;[153,216,201]./255;[102,194,164]./255];

timeseries.ncfile(6).symbol = {'-'};
timeseries.ncfile(6).translate = 1;
timeseries.ncfile(6).colour = {[230,171,2]./255;[230,171,2]./255};% Surface and Bottom
timeseries.ncfile(6).edge_color = {[44,162,95]./255;[44,162,95]./255};
timeseries.ncfile(6).col_pal_color_surf =[[102,194,164]./255;[162 190 197]./255;[150 190 197]./255;[150 190 197]./255];
timeseries.ncfile(6).col_pal_color_bot  =[[102,194,164]./255;[204,236,230]./255;[153,216,201]./255;[102,194,164]./255];

% plotting configuration
timeseries.datearray = datenum(2017,1:6:67,01);
timeseries.dateformat = 'mm/yy';

timeseries.dimc = [0.9 0.9 0.9]; % dimmest (lightest) color
timeseries.istitled = 1;
timeseries.isylabel = 1;
timeseries.islegend = 1;
timeseries.isYlim   = 1;
timeseries.isGridon = 1;
timeseries.dimensions = [20 10]; % Width & Height in cm

timeseries.dailyave = 0; % 1 for daily average, 0 for off. Daily average turns off smoothing.
timeseries.smoothfactor = 1; % Must be odd number (set to 3 if none)

timeseries.fieldsymbol = {'.','.'}; % Cell with same number of levels
timeseries.fieldcolour = {'m',[0.6 0.6 0.6]}; % Cell with same number of levels

timeseries.legendlocation = 'northeastoutside';

% ylim
% 'SAL','Salinity';...
%     'TEMP','Temperature';...
%     'WQ_OXY_OXY','DO';...
%     'WQ_DIAG_PHY_TCHLA','TCHLA';...
%     'WQ_DIAG_TOT_TN','TN';...
%     'WQ_DIAG_TOT_TP','TP';...
%     'WQ_NIT_AMM','NH_4';...
%     'WQ_NIT_NIT','NO_3';...
%     'WQ_PHS_FRP','PO_4';...
%     'WQ_DIAG_TOT_TSS','TSS';...
%     'WQ_DIAG_TOT_TOC','TOC';...
%     'WQ_OGM_DOC','DOC';...
%     'WQ_DIAG_TOT_TURBIDITY','Turbidity';...
% timeseries.cAxis(1).value = [0 220];
% timeseries.cAxis(2).value = [5 30];
% timeseries.cAxis(3).value = [0 12];
% timeseries.cAxis(4).value = [0 140];
% timeseries.cAxis(5).value = [0 8];
% timeseries.cAxis(6).value = [0 0.5];

for vvvv=1:size(MARVLs.master.varname,1)
    timeseries.cAxis(vvvv).value = [ ];
end

MARVLs.timeseries = timeseries; clear timeseries;

%% Transect setting:-----------------------------------------------------
%  The is the configuration file for the marvl_plot_transect.m function.
% -------------------------------------------------------------------------

transect.start_plot_ID = 1;
transect.end_plot_ID = 13;

transect.polygon_file = '/Projects2/CDM2022/AED-MARVL-v0.4/Projects/Coorong/GIS/Coorong/Transect_Coorong.shp';
% Add field data to figure
transect.plotvalidation = 1; % 1 or 0
transect.pred_lims = [0.05,0.25,0.5,0.75,0.95];

transect.isRange = 1;
transect.istitled = 1;
transect.isylabel = 1;
transect.islegend = 0;
transect.isYlim = 1;
transect.isHTML = 1;
transect.isSurf = 1; %plot surface (1) or bottom (0)
transect.isSpherical = 0;
transect.use_matfiles = 0;
transect.add_obs_num = 1;
%config.boxon = 1;

% ___
transect.outputdirectory = '/Projects2/CDM2022/AED-MARVL-v0.4/Projects/Coorong/transect_BBV4/RAW/';
transect.htmloutput = '/Projects2/CDM2022/AED-MARVL-v0.4/Projects/Coorong/transect_BBV4/HTML/';

% plotting configuration
transect.dimc = [0.9 0.9 0.9]; % dimmest (lightest) color
transect.boxlegend = 'southeast';
transect.rangelegend = 'northwest';
transect.dimensions = [20 10]; % Width & Height in cm

for i=1:20
transect.pdates(i).value = [datenum(2017,7+(i-1)*3,01) datenum(2017,07+i*3,01)-1];
end
transect.binfielddata = 1;
% radius distance to include field data. Used to bin data where number of
% sites is higher, but the frequency of sampling is low. The specified
% value will also make where on the line each polygon will be created. So
% if radius == 5, then there will be a search polygon found at r*2, so 0km, 10km, 20km etc. In windy rivers these polygons may overlap.
transect.binradius = 0.5;% in km;


%distance from model polyline to be consided.
%Field data further than specified distance won't be included.
%Even if found with search radius. This is to attempt to exclude data
%sampled outside of the domain.
transect.linedist = 1500;%  in m

transect.xlim = [0 110];% xlim in KM
transect.xticks = [0:10:110];
transect.xlabel = 'Distance from Goolwa to South Lagoon (km)';

transect.cAxis(1).value = [0 200];

% ylim
for vvvv=2:size(MARVLs.master.varname,1)
    transect.cAxis(vvvv).value = [ ];
end
transect.ncfile(1).symbol = {'-'};
transect.ncfile(1).translate = 1;
transect.ncfile(1).colour = [166,86,40]./255;% Surface and Bottom
transect.ncfile(1).edge_color = [166,86,40]./255;
transect.ncfile(1).col_pal_color =[[176 190 197]./255;[162 190 197]./255;[150 190 197]./255;[150 190 197]./255];

transect.ncfile(2).symbol = {'-'};
transect.ncfile(2).translate = 1;
transect.ncfile(2).colour = [27,158,119]./255;% Surface and Bottom
transect.ncfile(2).edge_color = [8,88,158]./255;
transect.ncfile(2).col_pal_color =[[102,194,164]./255;[162 190 197]./255;[150 190 197]./255;[150 190 197]./255];

transect.ncfile(3).symbol = {'-'};
transect.ncfile(3).translate = 1;
transect.ncfile(3).colour = [217,95,2]./255;% Surface and Bottom
transect.ncfile(3).edge_color = [8,88,158]./255;
transect.ncfile(3).col_pal_color =[[102,194,164]./255;[162 190 197]./255;[150 190 197]./255;[150 190 197]./255];

transect.ncfile(4).symbol = {'-'};
transect.ncfile(4).translate = 1;
transect.ncfile(4).colour = [117,112,179]./255;% Surface and Bottom
transect.ncfile(4).edge_color = [8,88,158]./255;
transect.ncfile(4).col_pal_color =[[102,194,164]./255;[162 190 197]./255;[150 190 197]./255;[150 190 197]./255];

transect.ncfile(5).symbol = {'-'};
transect.ncfile(5).translate = 1;
transect.ncfile(5).colour = [231,41,138]./255;% Surface and Bottom
transect.ncfile(5).edge_color = [8,88,158]./255;
transect.ncfile(5).col_pal_color =[[102,194,164]./255;[162 190 197]./255;[150 190 197]./255;[150 190 197]./255];

transect.ncfile(6).symbol = {'-'};
transect.ncfile(6).translate = 1;
transect.ncfile(6).colour = [230,171,2]./255;% Surface and Bottom
transect.ncfile(6).edge_color = [8,88,158]./255;
transect.ncfile(6).col_pal_color =[[102,194,164]./255;[162 190 197]./255;[150 190 197]./255;[150 190 197]./255];

MARVLs.transect = transect; clear transect;

%% Transect stacked area setting:------------------------------------------
%  The is the configuration file for the marvl_plot_transect.m function.
% -------------------------------------------------------------------------
transectSA.thevars = {...
    'WQ_PHY_GRN';...
    'WQ_PHY_DINO';...
    'WQ_PHY_DIATOM';...
    'WQ_PHY_CRYPT';...
    };
transectSA.thelabels = {...
    'Green Algae';...
    'Dino';...
    'Diatom';...
    'Crypt';...
    };
transectSA.thevars_conv = [50 50 50 50]/12;

transectSA.varname = {...
    'WQ_DIAG_PHY_TCHLA','TChla (\mug/L)';...
    };
%transectSA.add_human = 1;

transectSA.polygon_file = 'E:\database\AED-MARVl-v0.2\Examples\Cockburn\GIS\Curtain_polyline_100m_QC.shp';
% Add field data to figure
transectSA.plotvalidation = 1; % 1 or 0
transectSA.pred_lims = [0.05,0.25,0.5,0.75,0.95];

transectSA.isRange = 1;
transectSA.istitled = 1;
transectSA.isylabel = 1;
transectSA.islegend = 0;
transectSA.isYlim = 1;
transectSA.isHTML = 1;
transectSA.isSurf = 1; %plot surface (1) or bottom (0)
transectSA.isSpherical = 0;
transectSA.use_matfiles = 0;
transectSA.add_obs_num = 1;
%config.boxon = 1;

% ___
transectSA.outputdirectory = 'plotting/transectSA/RAW/';
transectSA.htmloutput = 'plotting/transectSA/HTML/';

% plotting configuration
transectSA.dimc = [0.9 0.9 0.9]; % dimmest (lightest) color
transectSA.boxlegend = 'southeast';
transectSA.rangelegend = 'northwest';
transectSA.dimensions = [20 10]; % Width & Height in cm

i=1;
transectSA.pdates(1).value = [datenum(2021,06,16) datenum(2021,07,01)];i=i+1;
transectSA.pdates(2).value = [datenum(2021,07,01) datenum(2021,07,15)];i=i+1;
transectSA.pdates(3).value = [datenum(2021,07,16) datenum(2021,08,01)];i=i+1;

transectSA.binfielddata = 1;
% radius distance to include field data. Used to bin data where number of
% sites is higher, but the frequency of sampling is low. The specified
% value will also make where on the line each polygon will be created. So
% if radius == 5, then there will be a search polygon found at r*2, so 0km, 10km, 20km etc. In windy rivers these polygons may overlap.
transectSA.binradius = 0.5;% in km;


%distance from model polyline to be consided.
%Field data further than specified distance won't be included.
%Even if found with search radius. This is to attempt to exclude data
%sampled outside of the domain.
transectSA.linedist = 1500;%  in m

transectSA.xlim = [0 45];% xlim in KM
transectSA.xticks = [0:5:45];
transectSA.xlabel = 'Distance from Southern CS (km)';

% ylim
transectSA.cAxis(1).value = [0 20];

MARVLs.transectSA = transectSA; clear transectSA;

%% Site profiling setting:------------------------------------------
%  The is the configuration file for the marvl_plot_profile.m function.
% -------------------------------------------------------------------------
for vvvv=1:length(MARVLs.master.varname)
    profile.cAxis(vvvv).value = [ ];
end

profile.start_plot_ID = 1;
profile.end_plot_ID = 1;

profile.sitenames={'Cockburn','Swan'};
profile.siteX=[ 380000, 388340];
profile.siteY=[6433760,6458300];

profile.plotvalidation = false; % Add field data to figure (true or false)
profile.plotmodel = 1;

profile.filetype = 'eps';
profile.expected = 1; % plot expected WL

profile.isHTML = 1;

profile.datearray = datenum(2021,6,15:15:60);

profile.dateformat = 'dd/mm/yyyy';

profile.dimc = [0.9 0.9 0.9]; % dimmest (lightest) color
profile.istitled = 1;
profile.isylabel = 1;
profile.islegend = 1;
profile.isYlim   = 1;
profile.isGridon = 1;
profile.dimensions = [20 10]; % Width & Height in cm

profile.outputdirectory = 'plotting/profile/RAW/';
profile.htmloutput = 'plotting/profile/HTML/';

MARVLs.profile = profile; clear profile;

%% Sheet plotting setting:------------------------------------------
%  The is the configuration file for the marvl_plot_sheet.m function.
% -------------------------------------------------------------------------
sheet.cAxis(1).value = [28 35];
sheet.start_plot_ID = 1;
sheet.end_plot_ID = 1;

sheet.plotdepth = {'bottom'};  %  {'surface','bottom'} Cell-array with either one
sheet.plottype = 'figure'; % choose 'movie' or 'figure';

if strcmpi(sheet.plottype,'movie')
    sheet.FileFormat='mp4'; % choose 'mp4' or 'avi'
    sheet.Quality   =100;   % movie quality
    sheet.FrameRate =6;     % frame rate
    sheet.resolution = [1024,768]; % frame rosolution
    sheet.colormap = 'jet'; % colormap options, see Matlab manual
    sheet.save_images = 1;  % option to save slide images
    sheet.datearray = [datenum(2021,07,01) datenum(2021,07,21)];
    sheet.dateformat = 'mm/yyyy';
    sheet.plot_interval = 6;
elseif strcmpi(sheet.plottype,'figure')
    sheet.datearray = [datenum(2021,07,01) datenum(2021,07,21)];
    sheet.resolution = [1024,768]; % frame rosolution
    sheet.colormap = 'jet'; % colormap options, see Matlab manual
else
    msg=['Error: type of ',sheet.plottype,' is not recognized'];
    error(msg);
end

sheet.outputdirectory = 'plotting/sheet/';

sheet.clip_depth = 0.05; % remove the shallow NaN cells

sheet.dimc = [0.9 0.9 0.9]; % dimmest (lightest) color
sheet.istitled = 1;
sheet.isColorbar = 1;
sheet.Xlim     = [ ];
sheet.Ylim     = [ ];
sheet.isAxison = 1;
sheet.dimensions = [20 10]; % Width & Height in cm

MARVLs.sheet = sheet; clear sheet;

%% Curtain plotting setting:------------------------------------------
%  The is the configuration file for the marvl_plot_curtain.m function.
% -------------------------------------------------------------------------
curtain.cAxis(1).value = [28 35];
curtain.start_plot_ID = 1;
curtain.end_plot_ID = 1;
curtain.geofile = 'W:\Jayden\Simulations\Cockburn_Base\Input/Cockburn_kw_020_geo.nc';
curtain.polyline = 'W:/Jayden/plotting/Curtain_polyline_100m_QC.shp';

curtain.plottype = 'movie'; % choose 'movie' or 'figure';

if strcmpi(curtain.plottype,'movie')
    curtain.FileFormat='mp4'; % choose 'mp4' or 'avi'
    curtain.Quality   =100;   % movie quality
    curtain.FrameRate =6;     % frame rate
    curtain.resolution = [1024,768]; % frame rosolution
    curtain.colormap = 'jet'; % colormap options, see Matlab manual
    curtain.save_images = 1;  % option to save slide images
    curtain.datearray = [datenum(2021,07,01) datenum(2021,07,21)];
    curtain.dateformat = 'mm/yyyy';
    curtain.plot_interval = 6;
elseif strcmpi(curtain.plottype,'figure')
    curtain.datearray = [datenum(2021,07,01) datenum(2021,07,21)];
    curtain.resolution = [1024,768]; % frame rosolution
    curtain.colormap = 'jet'; % colormap options, see Matlab manual
else
    msg=['Error: type of ',curtain.plottype,' is not recognized'];
    error(msg);
end

curtain.outputdirectory = 'plotting/curtain/';

curtain.clip_depth = 0.05; % remove the shallow NaN cells

curtain.dimc = [0.9 0.9 0.9]; % dimmest (lightest) color
curtain.istitled = 1;
curtain.isColorbar = 1;
curtain.xlim = [0 45];% xlim in KM
curtain.xticks = [0:5:45];
curtain.xlabel = 'Distance from CS South (km)';
curtain.isAxison = 1;
curtain.dimensions = [20 10]; % Width & Height in cm
curtain.colorbarposition = [0.92 0.25 0.01 0.45];

MARVLs.curtain = curtain; clear curtain;

%% Transect exceedance setting:-----------------------------------------------------
%  The is the configuration file for the marvl_plot_transect.m function.
% -------------------------------------------------------------------------

transectExc.start_plot_ID = 13;
transectExc.end_plot_ID = 13;

transectExc.polygon_file = 'E:\database\AED-MARVl-v0.2\Examples\Cockburn\GIS\Curtain_polyline_100m_QC.shp';
% Add field data to figure
transectExc.plotvalidation = 0; % 1 or 0
transectExc.pred_lims = [0.05,0.25,0.5,0.75,0.95];

transectExc.isRange = 1;
transectExc.istitled = 1;
transectExc.isylabel = 1;
transectExc.islegend = 0;
transectExc.isYlim = 1;
transectExc.isHTML = 1;
transectExc.isSurf = 1; %plot surface (1) or bottom (0)
transectExc.isSpherical = 0;
transectExc.use_matfiles = 0;
transectExc.add_obs_num = 1;
%config.boxon = 1;

transectExc.thresh(13).value = [0.5 1];
transectExc.thresh(13).legend = {'%time > 0.5NTU',...
    '%time > 1NTU'};
% ___
transectExc.outputdirectory = 'plotting/transect_exceedance/RAW/';
transectExc.htmloutput = 'plotting/transect_exceedance/HTML/';

% plotting configuration
transectExc.dimc = [0.9 0.9 0.9]; % dimmest (lightest) color
transectExc.boxlegend = 'southeast';
transectExc.rangelegend = 'northwest';
transectExc.dimensions = [20 10]; % Width & Height in cm

i=1;
transectExc.pdates(1).value = [datenum(2021,06,16) datenum(2021,07,01)];i=i+1;
transectExc.pdates(2).value = [datenum(2021,07,01) datenum(2021,07,15)];i=i+1;
transectExc.pdates(3).value = [datenum(2021,07,16) datenum(2021,08,01)];i=i+1;

transectExc.binfielddata = 1;
% radius distance to include field data. Used to bin data where number of
% sites is higher, but the frequency of sampling is low. The specified
% value will also make where on the line each polygon will be created. So
% if radius == 5, then there will be a search polygon found at r*2, so 0km, 10km, 20km etc. In windy rivers these polygons may overlap.
transectExc.binradius = 0.5;% in km;


%distance from model polyline to be consided.
%Field data further than specified distance won't be included.
%Even if found with search radius. This is to attempt to exclude data
%sampled outside of the domain.
transectExc.linedist = 1500;%  in m

transectExc.xlim = [0 45];% xlim in KM
transectExc.xticks = [0:5:45];
transectExc.xlabel = 'Distance from Southern CS (km)';

% ylim
for vvvv=1:size(MARVLs.master.varname,1)
    transectExc.cAxis(vvvv).value = [0 100];
end

transectExc.ncfile(1).symbol = {'-'};
transectExc.ncfile(1).translate = 1;
transectExc.ncfile(1).colour = [166,86,40]./255;% Surface and Bottom
transectExc.ncfile(1).edge_color = [166,86,40]./255;
transectExc.ncfile(1).col_pal_color =[[176 190 197]./255;[162 190 197]./255;[150 190 197]./255;[150 190 197]./255];

MARVLs.transectExc = transectExc; clear transectExc;