function marvl_plot_profile(MARVLs)
%**************************************************************************
%
% This is AED-Marvl version 1.0 (SEPT-2022)
%
% AEDmarvl_plot_timeseries is a MATLAB-version tool for visualizing and
%    assessing AED model results. It plots the time series of selected
%    variables at selected locations (defined by site polygon GIS file),
%    and has options to add observational data (when isvalidation==1)
%    and calculate the model performance statistics.
%
% Please note that his software is intended to be used for AED-users,
%    meaning that the configuration (e.g. model names, variable name)
%    should be consistent with AED conventions. For info of AED model
%    please refer to https://aquaticecodynamics.github.io/aed-science/
%
% For more info please have a look at:
%    Huang et al., 2022. AED-MARVL - The AED Model Assessment, Reporting
%    and Visualisation Library, AED Research Group, UWA.
%    http://github ***************
%
%**************************************************************************
%
%  **** SYNTAX:
%  AEDmarvl_plot_timeseries(masterConfig, siteConfig)
%    where: masterConfig is the master (general) configuration file;
%           siteConfig is the site/style specific configuraton file;
%
%  **** SYNTAX EXAMPLES:
%  masterConfig = '../../../Configs/Coorong/Coorong_master_config.m';
%  siteConfig = '../../../Configs/Coorong/Coorong_timeseries_config.m';
%  AEDmarvl_plot_timeseries(masterConfig, siteConfig)

%**************************************************************************
% NOTHING BELOW THIS SHOULD REQUIRE EDITING BY USER!
%**************************************************************************

%--------------------------------------------------------------------------
disp('plot_profile: START');

%clear; close all;
%run('E:\database\AED-MARVl-v0.2\Examples\Cockburn\MARVL.m');
master=MARVLs.master;
config=MARVLs.profile;
def=config;
ncfile=master.ncfile;

%[config, def]=check_TS_config_vars_F(config, def);

% load in model geometry (layers, depth etc)
% [t_data, d_data]=pre_load_model_GEOs(ncfile);

% check and define sites for plotting
%[shp, sites]=refine_SHP(shp, config);

% place-holder for model skill matrix
%errorMatrix=struct;

% start plotting, loop through selected variables
for var = config.start_plot_ID:config.end_plot_ID
    
    loadname = master.varname{var,1};       % AED name
    loadname_human = master.varname{var,2}; % User-define name
    savedir = [config.outputdirectory,loadname,'/']; % output path
    if ~exist(savedir,'dir')
        mkdir(savedir);
        mkdir([savedir,'eps/']);
    end
    
    % load in raw model data
    if config.plotmodel
        allvars = tfv_infonetcdf(ncfile(1).name);
        raw=struct;
        for site = 1:length(config.sitenames)
            disp(['Loading ',config.sitenames{site}]);
            rawData=load_AED_vars(ncfile,1,loadname,allvars);
            [rawData.data.(loadname),c_units,isConv]  = tfv_Unit_Conversion(rawData.data.(loadname),loadname);
            raw(site).data = tfv_getmodeldatalocation(ncfile(1).name,rawData.data,config.siteX(site),config.siteY(site),{loadname});
           % raw(site).data=rawdata2; clear rawdata;
        end
    end
    % save(['E:\database\AED-MARVl-v0.2\Examples\Swan\',loadname,'.mat'],'raw','-mat','-v7.3');
    % loop though sites, do data processing and plotting
    for site = 1:length(config.sitenames)
        disp(strcat(' >>> var',num2str(var),'=',loadname,'; site=',...
            num2str(site),[': ',regexprep(config.sitenames{site},'_',' ')]))
        
        gcf=figure('visible',master.visible);
        pos=get(gcf,'Position');
        xSize = def.dimensions(1);
        ySize = def.dimensions(2);
        newPos3=(pos(3)+pos(4))*xSize/(xSize+ySize);
        newPos4=(pos(3)+pos(4))*ySize/(xSize+ySize);
        set(gcf,'Position',[pos(1) pos(2) newPos3 newPos4]);
        set(0,'DefaultAxesFontName',master.font);
        set(0,'DefaultAxesFontSize',master.fontsize);
        
        %--% Paper Size
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf,'paperposition',[0 0 xSize ySize]);
        
        hfig=pcolor(raw(site).data.date,raw(site).data.depths,raw(site).data.profile);
        shading flat;
        hc=colorbar;
        title(hc,c_units);
        
        % polishing the figure (ticks, labels, titles, legends)
        % Y axis and label

            if def.isylabel
               ylabel('Depth (m)','fontsize',6,'FontWeight','bold',...
                        'color',[0.4 0.4 0.4],'horizontalalignment','center');
            end

        if def.isYlim
            if ~isempty(def.cAxis(var).value)
                ylim([def.cAxis(var).value]);
            end
        else
            def.cAxis(var).value = get(gca,'ylim');
            def.cAxis(var).value(1) = 0;
            
        end
        
        % X axis and label
        xlim([def.datearray(1) def.datearray(end)]);
        

            set(gca,'Xtick',def.datearray,...
                'XTickLabel',datestr(def.datearray,def.dateformat),...
                'FontSize',master.xlabelsize);

        % title
        if def.istitled
            if master.add_human
            title([regexprep(config.sitenames{site},'_',' '),': ',loadname_human, ' profile'],...
                'FontSize',master.titlesize,...
                'FontWeight','bold');
            else
                title([regexprep(config.sitenames{site},'_',' '),': ',loadname, ' profile'],...
                'FontSize',master.titlesize,...
                'FontWeight','bold');
            end
        end
%         
%         % legend
%         if def.islegend
%             leg = legend('show');
%             set(leg,'location',def.legendlocation,'fontsize',def.legendsize);
%         else
%             leg = legend('location',def.legendlocation);
%             set(leg,'fontsize',def.legendsize);
%         end
%         
%         if  def.isGridon
%             grid on;
%         end
%         
        
                
        % export the figure

            final_sitename = [config.sitenames{site},'.eps'];

        finalname_p = [savedir,final_sitename];
        
        if exist('filetype','var')
            if strcmpi(filetype,'png')
                print(gcf,'-dpng',regexprep(finalname_p,'.eps','.png'),'-opengl');
            else
                saveas(gcf,regexprep(finalname_p,'.eps','.png'));
            end
        else
            saveas(gcf,regexprep(finalname_p,'.eps','.png'));
        end
               
    end
    
    if config.isHTML
        create_html_for_directory_onFly(savedir,loadname,config.htmloutput);
    end
    
    close all force;
    clear data rawData raw;
end

%--------------------------------------------------------------------------
% export HTML file for figures
if config.isHTML
    create_html_for_directory(config.outputdirectory,config.htmloutput);
end

%end
