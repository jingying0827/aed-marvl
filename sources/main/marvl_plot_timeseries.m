function marvl_plot_timeseries(MARVLs,style)
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
disp('plot_timeseries: START');
% 
% clear; close all;
% run('E:\database\MARVL\examples\Cockburn_Sound\MARVL.m');
master=MARVLs.master;
config=MARVLs.timeseries;
%style='matlab';
% load in and check configurations
config=check_TS_configs(config);

% load in model geometry (layers, depth etc)
if config.plotmodel==1
    [t_data, d_data]=pre_load_model_GEOs_ROMS(master.ncfile);
end

shp = shaperead(config.polygon_file);
    for kk = 1:length(shp)
        shp(kk).Name = regexprep(shp(kk).Name,' ','_');
        shp(kk).Name = regexprep(shp(kk).Name,'\.','');
    end
    
% check and define sites for plotting
%[shp, sites]=refine_SHP(shp, config);

if config.plotAllsites == 0
    sites=config.plotsite;
else
    sites=1:length(shp);
end
fdata = struct;
isvalidation=master.add_fielddata;

if isvalidation
field = load(master.fielddata_matfile);
fdata = field.(master.fielddata); clear field;
end
       
% place-holder for model skill matrix
errorMatrix=struct;

% start plotting, loop through selected variables
for var = config.start_plot_ID:config.end_plot_ID
    
    loadname = master.varname{var,1};       % AED name
    loadname_human = master.varname{var,2}; % User-define name
    
    if strcmpi(style,'matlab')
        savedir = [config.outputdirectory,loadname,'/']; % output path
    elseif strcmpi(style,'yaml')
        savedir = [config.outputdirectory{1},loadname,'/']; % output path
    end
    
    if ~exist(savedir,'dir')
        mkdir(savedir);
     %  mkdir([savedir,'eps/']);
    end
    
    % load in raw model data
    if config.plotmodel
        allvars = tfv_infonetcdf(master.ncfile(1).name);
        raw=struct;
        for mod = 1:length(master.ncfile)
            disp(['Loading Model ',num2str(mod)]);
          %  rawdata=load_AED_vars(master.ncfile,mod,loadname,allvars);
            if isfield(master.ncfile(mod),'tag') && strcmpi(master.ncfile(mod).tag,'ROMS')
                rawdata.data = [];
%             elseif strcmp(loadname,'TPTN')
%                 TN =  ncread(master.ncfile(mod).name,'WQ_DIAG_TOT_TN'); %tfv_readnetcdf(master.ncfile(mod).name,'names',{'WQ_DIAG_TOT_TN'});
%                 TP =  ncread(master.ncfile(mod).name,'WQ_DIAG_TOT_TP'); %tfv_readnetcdf(master.ncfile(mod).name,'names',{'WQ_DIAG_TOT_TP'});
%                 rawdata.data = TN./TP;
%                 rawdata.data(TN==0)=16;
%                 clear TN TP;
%                 
            else
                rawdata=load_AED_vars(master.ncfile,mod,loadname,allvars);
            end
            raw(mod).data=rawdata.data; clear rawdata;
        end
    end
    
    % loop though sites, do data processing and plotting
    for site = sites
        disp(strcat(' >>> var',num2str(var),'=',loadname,'; site=',...
            num2str(site),[': ',regexprep(shp(site).Name,'_',' ')]))
        
        gcf=figure('visible',master.visible);
        pos=get(gcf,'Position');
        xSize = config.dimensions(1);
        ySize = config.dimensions(2);
        newPos3=(pos(3)+pos(4))*xSize/(xSize+ySize);
        newPos4=(pos(3)+pos(4))*ySize/(xSize+ySize);
        set(gcf,'Position',[pos(1) pos(2) newPos3 newPos4]);
        set(0,'DefaultAxesFontName',master.font);
        set(0,'DefaultAxesFontSize',master.fontsize);
        
        %--% Paper Size
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf,'paperposition',[0 0 xSize ySize]);

        isConv=0;
        if config.plotmodel
        for mod = 1:length(master.ncfile)
            if (isfield(t_data(mod).fields,loadname) || find(contains({'TNTP','PONDON','DINDIP'},loadname))>0)
                tStart = tic;

                if isfield(master.ncfile(mod),'tag') && strcmpi(master.ncfile(mod).tag,'ROMS')
                     [data(mod),c_units,isConv] = ...
                         marvl_getmodeldatapolygon_quick_ROMS(master.ncfile(mod).name,shp(site),{loadname},d_data(mod),config);
                 else
                [data(mod),c_units,isConv] = ...
                    marvl_getmodeldatapolygon_quick(raw(mod).data,...
                    shp(site),{loadname},d_data(mod),config,0);
                
                end
                 
                if find(contains({'TNTP','PONDON','DINDIP'},loadname))>0
                    isConv=1;
                    c_units='-';
                end
                
                % sort model/observation data and add to plot
                for ll=1:length(config.plotdepth)
                    layer=config.plotdepth{ll};
                [~,~,~,~,MatchedData0] = ...
                    sort_plot_data_1layer(data,fdata,config,...
                    isvalidation,mod,shp,site,loadname,var,master,layer,style);
                if ll==1
                    MatchedData=MatchedData0;
                else
                    MatchedData(size(MatchedData,1)+1:size(MatchedData,1)+size(MatchedData0,1),:)=MatchedData0;
                end
                end
                
                tEnd = toc(tStart);
                disp(['Processing time: ',...
                    num2str(tEnd,'%4.4f'),' seconds']);
            end
        end
        
        else
            for ll=1:length(config.plotdepth)
                    layer=config.plotdepth{ll};
            [~,~] = plot_field_data_only(fdata,config,...
                    isvalidation,shp,site,loadname,var,master,layer,style);
            end
        end
        % Optional code to add long-term montly observed data percentile
        if master.add_fielddata && config.isFieldRange
            outdata = calc_data_ranges(fdata,shp(site).X,shp(site).Y,...
                config.fieldprctile,loadname);
            if sum(~isnan(outdata.low)) > config.fieldrange_min
                plot(outdata.Date,outdata.low, 'color',...
                    [0.2 0.2 0.2],'linestyle',':','displayname',...
                    ['Obs \itP_{',num2str(config.fieldprctile(1)),'}']);
                hold on;
                plot(outdata.Date,outdata.high,'color',[0.5 0.2 0.2],...
                    'linestyle',':','displayname',...
                    ['Obs \itP_{',num2str(config.fieldprctile(2)),'}']);
                hold on;
            end
        end
        
        % polishing the figure (ticks, labels, titles, legends)
        % Y axis and label
        if isConv
            if config.isylabel
                if master.add_human
                    ylabel([loadname_human,' (',c_units,')'],...
                        'fontsize',master.ylabelsize,'color',[0.0 0.0 0.0],...
                        'horizontalalignment','center');
                else
                    ylabel([regexprep(loadname,'_',' '),' (',c_units,')'],...
                        'fontsize',master.ylabelsize,'color',[0.0 0.0 0.0],...
                        'horizontalalignment','center');
                end
            end
        else
            if config.isylabel
                if config.add_human
                    ylabel([loadname_human,' (model units)'],...
                        'fontsize',master.ylabelsize,'color',[0.0 0.0 0.0],...
                        'horizontalalignment','center');
                else
                    ylabel([regexprep(loadname,'_',' '),' '],'fontsize',master.ylabelsize,'color',...
                        [0.0 0.0 0.0],'horizontalalignment','center');
                end
            end
        end
        
        if config.isYlim
            if ~isempty(config.cAxis(var).value)
                ylim([config.cAxis(var).value]);
            end
        else
            config.cAxis(var).value = get(gca,'ylim');
            config.cAxis(var).value(1) = 0;
            
        end
        
        % X axis and label
        xlim([config.datearray(1) config.datearray(end)]);
        
        if ~config.custom_datestamp
            %disp('hi')
            set(gca,'Xtick',config.datearray,...
                'XTickLabel',datestr(config.datearray,config.dateformat),...
                'FontSize',master.xlabelsize);
        else
            new_dates = config.datearray  - zero_day;
            new_dates = new_dates - 1;
            
            ttt = find(new_dates >= 0);
            
            set(gca,'Xtick',config.datearray(ttt),...
                'XTickLabel',num2str(new_dates(ttt)'),...
                'FontSize',master.xlabelsize);
        end
        
        % title
        if config.istitled
            title([regexprep(shp(site).Name,'_',' ')],...
                'FontSize',master.titlesize,...
                'FontWeight','bold');
        end
        
        % legend
        if config.islegend
            leg = legend('show');
            set(leg,'location',config.legendlocation,'fontsize',master.legendsize);
        else
            leg = legend('location',config.legendlocation);
            set(leg,'fontsize',master.legendsize);
        end
        
        if  config.isGridon
            grid on;
        end
        
        
        %% adding error output

        if master.add_fielddata && config.plotmodel
            [errorMatrix,T,skill_summary] = cal_model_skills(MatchedData,...
                config,shp,site,loadname,errorMatrix);
            if config.showSkill && ~isempty(skill_summary)
                if ~isnan(errorMatrix.(regexprep(shp(site).Name,' ','_')).(loadname).R)
                hlp=get(leg,'Position');
                
                if strcmpi(config.SkillStyle,'tailor')
                dim=[hlp(1)-0.08 0.15 0.35 0.4];
                
                axes('Position',dim);
                obs=errorMatrix.(regexprep(shp(site).Name,' ','_')).(loadname).rawOBS;
                sim=errorMatrix.(regexprep(shp(site).Name,' ','_')).(loadname).rawSIM;
                statm=allstats_tailor(obs,sim);statm=statm';
                
                std=statm(1,2);
                
                if std<0.01
                    trmss=0:0.002:0.01;
                else
                    brp=1;
                    for i=-2:5
                        if std<10.^(i) && brp==1
                            trmss=0:10.^(i)/5:10.^(i);
                            brp=0;
                        end
                    end
                end
                
                [pp tt axl] = taylordiag_marvl(squeeze(statm(:,2)),squeeze(statm(:,3)),squeeze(statm(:,4)),...
            'tickRMS',trmss,'titleRMS',0,'tickRMSangle',135,'showlabelsRMS',0,'widthRMS',1,...
            'tickSTD',trmss,'limSTD',max(trmss),...
            'tickCOR',[.1:.1:.9 .95 .99],'showlabelsCOR',1,'titleCOR',1);
        set(gca,'FontSize',5);

for ii = 1 : length(tt)
    set(tt(ii),'fontsize',5,'fontweight','bold')
    set(pp(ii),'markersize',12)
    if ii == 1
        set(tt(ii),'String','Obs');
    else
        set(tt(ii),'String','Mod');
    end
end
%title(sprintf('%s: Taylor Diagram at CLIMODE Buoy','B'),'fontweight','bold');

tt = axl(2).handle;
for ii = 1 : length(tt)
    set(tt(ii),'fontsize',5,'fontweight','normal');
end
set(axl(1).handle,'fontweight','normal');

                else
                dim=[hlp(1)+0.025 0.25 0.15 0.1];    
                ha=annotation('textbox',dim,'String',...
                    skill_summary,'FitBoxToText','on','FontName',master.font,'Interpreter','tex'); %'FixedWidth'
                set(ha,'FontSize',master.legendsize);

                end
                end
            end
        end
        
        % export the figure
        if isfield(shp(site),'Plot_Order')
            final_sitename = [sprintf('%04d',shp(site).Plot_Order),...
                '_',shp(site).Name,'.eps'];
        else
            final_sitename = [shp(site).Name,'.eps'];
        end

        finalname_p = [savedir,final_sitename];
        
        if isfield(config,'filetype')
            if strcmpi(config.filetype,'png')
                print(gcf,'-dpng',regexprep(finalname_p,'.eps','.png'),'-r300');
            else
                %saveas(gcf,regexprep(finalname_p,'.eps','.png'));
              %  finalname_p2 = [savedir,'eps/',final_sitename];
              %  saveas(gcf,finalname_p2,'epsc');
                exportgraphics(gcf,regexprep(finalname_p,'.eps','.jpg'),'Resolution',300)
            end
        else
            %saveas(gcf,regexprep(finalname_p,'.eps','.png'));
            finalname_p2 = [savedir,'eps/',final_sitename];
          %  saveas(gcf,finalname_p2,'epsc');
            exportgraphics(gcf,regexprep(finalname_p,'.eps','.jpg'),'Resolution',300)
        end
        
        close all force;
        clear data;
        
    end
    
    if config.isHTML
            
    if strcmpi(style,'matlab')
        create_html_for_directory_onFly(savedir,loadname,config.htmloutput);
    elseif strcmpi(style,'yaml')
        create_html_for_directory_onFly(savedir,loadname,config.htmloutput{1});
    end
        
    end
end

%--------------------------------------------------------------------------
% export HTML file for figures
if config.isHTML
    if strcmpi(style,'matlab')
        create_html_for_directory(config.outputdirectory,config.htmloutput);
    elseif strcmpi(style,'yaml')
        create_html_for_directory(config.outputdirectory{1},config.htmloutput{1});
    end
    
end

%--------------------------------------------------------------------------
% export the performance matrix, optional
if config.add_error && config.isSaveErr==1
    save(config.ErrFilename,'errorMatrix','-mat');
end

disp('');
disp('plottfv_polygon: DONE');

end

%%
% *************************************************************
%{ function to process model/observations data, and add onto the plot
%   xdata: model time;
%   ydata: model data;
%   xdata_dt: observation time;
%   ydata_dt: observation data;
%   MatchedData: matched model and observation dataset
   %}
   
function [xdata,ydata,xdata_dt,ydata_dt,MatchedData] = ...
    sort_plot_data_1layer(data,fdata,config,...
    isvalidation,mod,shp,site,loadname,var,master,layer,style)

% allocate arrays for matching modelled and observed data
MatchedData=[];

% allocate arrays for observed data
xdata_dt=[];
ydata_dt=[];

% if isvalidatoin, finding field sites within each polygon
if isvalidation
    sitenames = fieldnames(fdata);
    
    X=zeros(size(sitenames));
    Y=zeros(size(sitenames));
    for i = 1:length(sitenames)
        vars = fieldnames(fdata.(sitenames{i}));
        X(i) = fdata.(sitenames{i}).(vars{1}).X;
        Y(i) = fdata.(sitenames{i}).(vars{1}).Y;
    end
    
    inpol = inpolygon(X,Y,shp(site).X,shp(site).Y);
    sss = find(inpol == 1);
end

% going through surface or bottom layers (only one selection, default surf)
if strcmpi(layer,'bottom') == 1
    data_to_plot=data(mod).pred_lim_ts_b;
else
    data_to_plot=data(mod).pred_lim_ts;
end

if strcmpi(style,'matlab')
    leg=master.ncfile(mod).legend;
elseif strcmpi(style,'yaml')
    leg=master.ncfile(mod).legend{1};
end

%option to plot percentile band
if config.plotmodel && config.isModelRange == 1
    num_lims = length(config.pred_lims);
    nn = (num_lims+1)/2;
    if strcmpi(layer,'bottom') == 1
    fig = fillyy(data(mod).date,data_to_plot(1,:),data_to_plot(2*nn-1,:),...
        config.dimc,config.ncfile(mod).col_pal_color_bot(1,:));hold on
    set(fig,'DisplayName',[leg,' (Bot 5^{th}-95^{th})']); %Surf
    set(fig,'FaceAlpha', config.alph);
    uistack(fig,'bottom');
    hold on;
    
    for plim_i=2:(nn-1)
        fig2 = fillyy(data(mod).date,data_to_plot(plim_i,:),...
            data_to_plot(2*nn-plim_i,:),config.dimc.*0.9.^(plim_i-1),...
            config.ncfile(mod).col_pal_color_bot(plim_i,:));hold on;
        set(fig2,'DisplayName',[leg,' (Bot 25^{th}-75^{th})']); %Surf
       % set(fig2,'HandleVisibility','off');
        set(fig2,'FaceAlpha', config.alph);
        uistack(fig2,'bottom');
    end
    
        
    else
        
        fig = fillyy(data(mod).date,data_to_plot(1,:),data_to_plot(2*nn-1,:),...
        config.dimc,config.ncfile(mod).col_pal_color_surf(1,:));hold on
    set(fig,'DisplayName',[leg,' (5^{th}-95^{th})']); %Surf
    set(fig,'FaceAlpha', config.alph);
    hold on;
    uistack(fig,'bottom');
    
    for plim_i=2:(nn-1)
        fig2 = fillyy(data(mod).date,data_to_plot(plim_i,:),...
            data_to_plot(2*nn-plim_i,:),config.dimc.*0.9.^(plim_i-1),...
            config.ncfile(mod).col_pal_color_surf(plim_i,:));hold on;
       % set(fig2,'HandleVisibility','off');
        set(fig2,'DisplayName',[leg,' (25^{th}-75^{th})']); %Surf
        set(fig2,'FaceAlpha', config.alph);
        uistack(fig2,'bottom');
    end
    
    end

end


if config.plotmodel
    [xdata,ydata] = tfv_averaging(data(mod).date,data_to_plot(3,:),config);
    diagVar = regexp(loadname,'DIAG');
    
    if diagVar>0 % removes inital zero value (eg in diganostics)
        xdata(1:2) = NaN;
    end
end

if config.plotmodel
    
    if strcmpi(style,'matlab')
        colour=config.ncfile(mod).colour;
    elseif strcmpi(style,'yaml')
        colour{1}=config.ncfile(mod).colour(1,:);
        colour{2}=config.ncfile(mod).colour(2,:);
    end
    
    if strcmpi(layer,'bottom') == 1
        plot(xdata,ydata,'color',colour{2},'linewidth',0.5,...
        'DisplayName',[leg,' (Bot Median)'],...
        'linestyle',config.ncfile(mod).symbol{2});hold on;
    else

    plot(xdata,ydata,'color',colour{1},'linewidth',0.5,...
        'DisplayName',[leg,' (Median)'],...
        'linestyle',config.ncfile(mod).symbol{1});hold on;
    end
end

%  add field data if isvalidation
if isvalidation && mod == 1
    if ~isempty(sss)
        
        site_string = ['     field: '];
        agencyused = [];
        for j = 1:length(sss)
            if isfield(fdata.(sitenames{sss(j)}),loadname)
                xdata_t = [];
                ydata_t = [];
                
                if ~config.validation_raw
%                     [xdata_ta,ydata_ta,ydata_max_ta,ydata_min_ta] = ...
%                         get_field_at_depth_thresh(fdata.(sitenames{sss(j)}).(loadname).Date,...
%                         fdata.(sitenames{sss(j)}).(loadname).Data,...
%                         fdata.(sitenames{sss(j)}).(loadname).Depth,layer,config.depthTHRESH);
                    [xdata_ta,ydata_ta,ydata_max_ta,ydata_min_ta] = ...
                        get_field_at_depth(fdata.(sitenames{sss(j)}).(loadname).Date,...
                        fdata.(sitenames{sss(j)}).(loadname).Data,...
                        fdata.(sitenames{sss(j)}).(loadname).Depth,layer);
                else
                    [xdata_ta,ydata_ta,ydata_max_ta,ydata_min_ta] = ...
                        get_field_at_depth_raw_thresh(fdata.(sitenames{sss(j)}).(loadname).Date,...
                        fdata.(sitenames{sss(j)}).(loadname).Data,...
                        fdata.(sitenames{sss(j)}).(loadname).Depth,layer,config.depthTHRESH);
                end
                
                gfg = find(xdata_ta >= config.datearray(1) & xdata_ta <= config.datearray(end));
                
                if ~isempty(gfg)
                    xdata_t = xdata_ta(gfg);
                    ydata_t = ydata_ta(gfg);
                    if ~config.validation_raw
                        ydata_max_t = ydata_max_ta(gfg);
                        ydata_min_t = ydata_min_ta(gfg);
                    else
                        ydata_max_t = [];
                        ydata_min_t = [];
                    end
                end
                
                if ~isempty(xdata_t)
                    if ~config.validation_raw
                      %  [xdata_d,ydata_d] = process_daily(xdata_t,ydata_t);
                        xdata_d =  xdata_t;
                        ydata_d = ydata_t;
                        [~,ydata_max_d] = process_daily(xdata_t,ydata_max_t);
                        [~,ydata_min_d] = process_daily(xdata_t,ydata_min_t);
                    else
                        xdata_d =  xdata_t;
                        ydata_d = ydata_t;
                        ydata_max_d = [];
                        ydata_min_d = [];
                    end
                    
                    [ydata_d,c_units,isConv] = tfv_Unit_Conversion(ydata_d,loadname);
                    [ydata_max_d,~,~] = tfv_Unit_Conversion(ydata_max_d,loadname);
                    [ydata_min_d,~,~] = tfv_Unit_Conversion(ydata_min_d,loadname);
                    
                  %  save('testing_depth.mat','xdata_dt','xdata_d','ydata_dt','ydata_d','-mat','-v7.3');
                    xdata_d=xdata_d(:);
                    ydata_d=ydata_d(:);
                    xdata_dt=[xdata_dt xdata_d'];
                    ydata_dt=[ydata_dt ydata_d'];
                    
                    if isfield(fdata.(sitenames{sss(j)}).(loadname),'Agency')
                        agency = fdata.(sitenames{sss(j)}).(loadname).Agency;
                    else
                        agency = 'Observations';
                    end
                    site_string = [site_string,' ',sitenames{sss(j)},'(',agency,'),'];
                    
                    % define symbols and colors for different agencies, for new sites simply add the 
                    %   new agency names into the 'AgencyNameCollection' list in the 
                    %   'marvl_sort_agency_information.m' script;
                    [mface,mcolor,agencyname] = marvl_sort_agency_information(agency);
                    agencyused = [agencyused;{agencyname}];
                    
                    if strcmpi(style,'matlab')
                        edge_color=config.edge_color;
                        colour=config.ncfile(mod).colour;
                    elseif strcmpi(style,'yaml')
                        edge_color{1}=config.edge_color(1,:);
                        edge_color{2}=config.edge_color(2,:);
                        colour{1}=config.ncfile(mod).colour(1,:);
                        colour{2}=config.ncfile(mod).colour(2,:);
                    end
                    
                    if config.plotvalidation
                        fgf = sum(strcmpi(agencyused,agencyname));
                        if strcmpi(layer,'bottom') == 1
                        if fgf > 1
                            fp = plot(xdata_d,ydata_d,mface,'markeredgecolor',...
                                edge_color{2},'markerfacecolor',...
                                edge_color{2},'markersize',3,'HandleVisibility','off');hold on
                            uistack(fp,'top');
                            if config.validation_minmax
                                fp = plot(xdata_d,ydata_max_d,'+','color',[0.6 0.6 0.6],...
                                    'HandleVisibility','off');hold on
                                fp = plot(xdata_d,ydata_min_d,'+','color',[0.6 0.6 0.6],...
                                    'HandleVisibility','off');hold on
                            end
                            uistack(fp,'top');
                        else
                            fp = plot(xdata_d,ydata_d,mface,'markeredgecolor',...
                                edge_color{2},'markerfacecolor',edge_color{2},...
                                'markersize',3,'displayname',[agency,' (Bot)']);hold on; %,' Surf'
                            uistack(fp,'top');
                            if config.validation_minmax
                                fp = plot(xdata_d,ydata_max_d,'+','color',[0.6 0.6 0.6],...
                                    'HandleVisibility','off');hold on
                                fp = plot(xdata_d,ydata_min_d,'+','color',[0.6 0.6 0.6],...
                                    'HandleVisibility','off');hold on
                            end
                            uistack(fp,'top');
                        end
                        
                        else
                        % if fgf > 1
                        %     fp = plot(xdata_d,ydata_d,mface,'markeredgecolor',...
                        %         edge_color{1},'markerfacecolor',...
                        %         edge_color{1},'markersize',3,'HandleVisibility','off');hold on
                        %     uistack(fp,'top');
                        %     if config.validation_minmax
                        %         fp = plot(xdata_d,ydata_max_d,'+','color',[0.6 0.6 0.6],...
                        %             'HandleVisibility','off');hold on
                        %         fp = plot(xdata_d,ydata_min_d,'+','color',[0.6 0.6 0.6],...
                        %             'HandleVisibility','off');hold on
                        %     end
                        %     uistack(fp,'top');
                        % else
                        %     fp = plot(xdata_d,ydata_d,mface,'markeredgecolor',...
                        %         edge_color{1},'markerfacecolor',edge_color{1},...
                        %         'markersize',3,'displayname',[agency,' (Surf)']);hold on; %,' Surf'
                        %     uistack(fp,'top');
                        %     if config.validation_minmax
                        %         fp = plot(xdata_d,ydata_max_d,'+','color',[0.6 0.6 0.6],...
                        %             'HandleVisibility','off');hold on
                        %         fp = plot(xdata_d,ydata_min_d,'+','color',[0.6 0.6 0.6],...
                        %             'HandleVisibility','off');hold on
                        %     end
                        %     uistack(fp,'top');
                        % end
                        if fgf > 1
                            fp = plot(xdata_d,ydata_d,mface,'markeredgecolor',...
                                'k','markerfacecolor',...
                                mcolor,'markersize',5, 'Color', mcolor, 'HandleVisibility','off');hold on
                            uistack(fp,'top');
                            if config.validation_minmax
                                fp = plot(xdata_d,ydata_max_d,'+','color',[0.6 0.6 0.6],...
                                    'HandleVisibility','off');hold on
                                fp = plot(xdata_d,ydata_min_d,'+','color',[0.6 0.6 0.6],...
                                    'HandleVisibility','off');hold on
                            end
                            uistack(fp,'top');
                        else
                            fp = plot(xdata_d,ydata_d,mface,'markeredgecolor',...
                                'k','markerfacecolor',mcolor,...
                                'markersize',5,'Color', mcolor,'displayname',[agency]);hold on; %,' Surf'
                            uistack(fp,'top');
                            if config.validation_minmax
                                fp = plot(xdata_d,ydata_max_d,'+','color',[0.6 0.6 0.6],...
                                    'HandleVisibility','off');hold on
                                fp = plot(xdata_d,ydata_min_d,'+','color',[0.6 0.6 0.6],...
                                    'HandleVisibility','off');hold on
                            end
                            uistack(fp,'top');
                        end
                            
                        end
                        
                        if config.isYlim
                            if ~isempty(config.cAxis(var).value)
                                ggg = find(ydata_d > config.cAxis(var).value(2));
                                
                                if ~isempty(ggg)
                                    if strcmpi(layer,'bottom') == 1
                                        agencyused = [agencyused;{'Outside Range (Bot)'}];
                                        fgf = sum(strcmpi(agencyused,'Outside Range (Bot)'));
                                    else
                                        agencyused = [agencyused;{'Outside Range (Surf)'}];
                                        fgf = sum(strcmpi(agencyused,'Outside Range (Surf)'));
                                    end
                                    rdata = [];
                                    rdata(1:length(ggg),1) = config.cAxis(var).value(2);
                                    hhh = find(xdata_d(ggg) >= config.datearray(1) & ...
                                        xdata_d(ggg) <= config.datearray(end));
                                    
                                    if ~isempty(hhh)
                                        if strcmpi(layer,'bottom') == 1
                                        if fgf > 1
                                            fp = plot(xdata_d(ggg),rdata,'b+',...
                                                'markersize',4,'linewidth',1,'HandleVisibility','off');hold on
                                            uistack(fp,'top');
                                        else
                                            fp = plot(xdata_d(ggg),rdata,'b+',...
                                                'markersize',4,'linewidth',1,'displayname','Outside Range (Bot)');hold on
                                            uistack(fp,'top');
                                        end
                                        else
                                            if fgf > 1
                                            fp = plot(xdata_d(ggg),rdata,'k+',...
                                                'markersize',4,'linewidth',1,'HandleVisibility','off');hold on
                                            uistack(fp,'top');
                                            else
                                            fp = plot(xdata_d(ggg),rdata,'k+',...
                                                'markersize',4,'linewidth',1,'displayname','Outside Range (Surf)');hold on
                                            uistack(fp,'top');
                                            end
                                        end
                                        uistack(fp,'top');
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        if(strlength(site_string)>7)
            disp(site_string)
        end
        clear site_string;
    end
end

if config.add_error && mod==1
    if (exist('xdata_dt','var') && ~isempty(xdata_dt))
        
        disp('find field data ...');
        
        if strcmpi(config.scoremethod, 'range') == 1
		
		alldayso=floor(xdata_dt);
       % unidayso=unique(alldayso);
       % obsData(:,1)=unidayso;
        
       % for uuo=1:length(unidayso)
       %     tmpinds=find(alldayso==unidayso(uuo));
       %     tmpydatatt=ydata_dt(tmpinds);
       %     obsData(uuo,2)=mean(tmpydatatt(~isnan(tmpydatatt)));
       %     clear tmpydatatt;
       % end
        
            alldays=floor(data(mod).date); 
            simrange=data_to_plot; %(3,:)
       %     unidays=unique(alldays);
            inc=1;
            MatchedData=[];
            for uu=1:length(alldayso)
                tmpinds=find(alldays==alldayso(uu));
                if ~isempty(tmpinds)
                    tmprange0=simrange(:,tmpinds);
                    tmprange=sort(tmprange0(:));
               % tmprange=mean(simrange(:,tmpinds),2);
               % tmpobs=obsData(uu,2);
               tmpobs=ydata_dt(uu);
                
                if (isnan(tmpobs) || (tmpobs<=tmprange(end) && tmpobs>=tmprange(1)))
                   % simData(uu,2)=tmpobs;
                    tmpsim=tmpobs;
                else
                    tmpdiff=abs(tmprange-tmpobs);
                    tmpind=find(tmpdiff==min(tmpdiff));
                   % simData(uu,2)=tmprange(tmpind(1));
                   tmpsim=tmprange(tmpind(1));
                    
                end
             %   else
             %       simData(uu,2)=NaN;
             MatchedData(inc,2)=tmpobs;
             MatchedData(inc,3)=tmpsim;
             inc=inc+1;
                 end
             %   simData(uu,1)=unidayso(uu);
                
            end
          %  [v, loc_obs, loc_sim] = intersect(obsData(:,1), simData(:,1));
          %  MatchedData = [v obsData(loc_obs,2) simData(loc_sim,2)];
          %save('matcheddata.mat','MatchedData','-mat','-v7.3');
        else
		alldayso=floor(xdata_dt);
        unidayso=unique(alldayso);
        obsData(:,1)=unidayso;
        
        for uuo=1:length(unidayso)
            tmpinds=find(alldayso==unidayso(uuo));
            tmpydatatt=ydata_dt(tmpinds);
            obsData(uuo,2)=mean(tmpydatatt(~isnan(tmpydatatt)));
            clear tmpydatatt;
        end
        
            alldays=floor(xdata);
            unidays=unique(alldays);
            simData(:,1)=unidays;
            
            for uu=1:length(unidays)
                tmpinds=find(alldays==unidays(uu));
                simData(uu,2)=mean(ydata(tmpinds));
            end
            
            [v, loc_obs, loc_sim] = intersect(obsData(:,1), simData(:,1));
            MatchedData = [v obsData(loc_obs,2) simData(loc_sim,2)];
           % save('matcheddata_median.mat','MatchedData','-mat','-v7.3');
        end
        clear simData obsData v loc* alldays unidays
        clear xdata_d ydata_d
    end
end

end

%%
% *************************************************************
%{ function to process model/observations data, and add onto the plot
%   xdata: model time;
%   ydata: model data;
%   xdata_dt: observation time;
%   ydata_dt: observation data;
%   MatchedData: matched model and observation dataset
   %}
   
% function [xdata,ydata,xdata_dt,ydata_dt,MatchedData] = ...
%     sort_plot_data_1layer(data,fdata,config,...
%     isvalidation,mod,shp,site,loadname,var,master,layer,style)
function [xdata_dt,ydata_dt] = plot_field_data_only(fdata,config,...
    isvalidation,shp,site,loadname,var,master,layer,style)

% allocate arrays for observed data
xdata_dt=[];
ydata_dt=[];

% if isvalidatoin, finding field sites within each polygon
if isvalidation
    sitenames = fieldnames(fdata);
    
    X=zeros(size(sitenames));
    Y=zeros(size(sitenames));
    for i = 1:length(sitenames)
        vars = fieldnames(fdata.(sitenames{i}));
        X(i) = fdata.(sitenames{i}).(vars{1}).X;
        Y(i) = fdata.(sitenames{i}).(vars{1}).Y;
    end
    
    inpol = inpolygon(X,Y,shp(site).X,shp(site).Y);
    sss = find(inpol == 1);
end


%  add field data if isvalidation
if isvalidation 
    if ~isempty(sss)
        
        site_string = ['     field: '];
        agencyused = [];
        for j = 1:length(sss)
            if isfield(fdata.(sitenames{sss(j)}),loadname)
                xdata_t = [];
                ydata_t = [];
                
                if ~config.validation_raw
%                     [xdata_ta,ydata_ta,ydata_max_ta,ydata_min_ta] = ...
%                         get_field_at_depth_thresh(fdata.(sitenames{sss(j)}).(loadname).Date,...
%                         fdata.(sitenames{sss(j)}).(loadname).Data,...
%                         fdata.(sitenames{sss(j)}).(loadname).Depth,layer,config.depthTHRESH);
                    [xdata_ta,ydata_ta,ydata_max_ta,ydata_min_ta] = ...
                        get_field_at_depth(fdata.(sitenames{sss(j)}).(loadname).Date,...
                        fdata.(sitenames{sss(j)}).(loadname).Data,...
                        fdata.(sitenames{sss(j)}).(loadname).Depth);
                else
                    [xdata_ta,ydata_ta,ydata_max_ta,ydata_min_ta] = ...
                        get_field_at_depth_raw_thresh(fdata.(sitenames{sss(j)}).(loadname).Date,...
                        fdata.(sitenames{sss(j)}).(loadname).Data,...
                        fdata.(sitenames{sss(j)}).(loadname).Depth,layer,config.depthTHRESH);
                end
                
                gfg = find(xdata_ta >= config.datearray(1) & xdata_ta <= config.datearray(end));
                
                if ~isempty(gfg)
                    xdata_t = xdata_ta(gfg);
                    ydata_t = ydata_ta(gfg);
                    if ~config.validation_raw
                        ydata_max_t = ydata_max_ta(gfg);
                        ydata_min_t = ydata_min_ta(gfg);
                    else
                        ydata_max_t = [];
                        ydata_min_t = [];
                    end
                end
                
                if ~isempty(xdata_t)
                    if ~config.validation_raw
                        [xdata_d,ydata_d] = process_daily(xdata_t,ydata_t);
                        [~,ydata_max_d] = process_daily(xdata_t,ydata_max_t);
                        [~,ydata_min_d] = process_daily(xdata_t,ydata_min_t);
                    else
                        xdata_d =  xdata_t;
                        ydata_d = ydata_t;
                        ydata_max_d = [];
                        ydata_min_d = [];
                    end
                    
                    [ydata_d,c_units,isConv] = tfv_Unit_Conversion(ydata_d,loadname);
                    [ydata_max_d,~,~] = tfv_Unit_Conversion(ydata_max_d,loadname);
                    [ydata_min_d,~,~] = tfv_Unit_Conversion(ydata_min_d,loadname);
                    
                    xdata_dt=[xdata_dt xdata_d'];
                    ydata_dt=[ydata_dt ydata_d']; %BB Added '
                    
                    if isfield(fdata.(sitenames{sss(j)}).(loadname),'Agency')
                        agency = fdata.(sitenames{sss(j)}).(loadname).Agency;
                    else
                        agency = 'Observations';
                    end
                    site_string = [site_string,' ',sitenames{sss(j)},'(',agency,'),'];
                    
                    % define symbols and colors for different agencies, for new sites simply add the 
                    %   new agency names into the 'AgencyNameCollection' list in the 
                    %   'marvl_sort_agency_information.m' script;
                    [mface,mcolor,agencyname] = marvl_sort_agency_information(agency);
                    agencyused = [agencyused;{agencyname}];
                    
                    if strcmpi(style,'matlab')
                        edge_color=config.edge_color;
                        colour=config.ncfile(1).colour;
                    elseif strcmpi(style,'yaml')
                        edge_color{1}=config.edge_color(1,:);
                        edge_color{2}=config.edge_color(2,:);
                        colour{1}=config.ncfile(1).colour(1,:);
                        colour{2}=config.ncfile(1).colour(2,:);
                    end
                    
                    if config.plotvalidation
                        fgf = sum(strcmpi(agencyused,agencyname));
                        if strcmpi(layer,'bottom') == 1
                        if fgf > 1
                            fp = plot(xdata_d,ydata_d,mface,'markeredgecolor',...
                                edge_color{2},'markerfacecolor',...
                                mcolor,'markersize',3,'HandleVisibility','off');hold on
                            uistack(fp,'top');
                            if config.validation_minmax
                                fp = plot(xdata_d,ydata_max_d,'+','color',[0.6 0.6 0.6],...
                                    'HandleVisibility','off');hold on
                                fp = plot(xdata_d,ydata_min_d,'+','color',[0.6 0.6 0.6],...
                                    'HandleVisibility','off');hold on
                            end
                            uistack(fp,'top');
                        else
                            fp = plot(xdata_d,ydata_d,mface,'markeredgecolor',...
                                edge_color{2},'markerfacecolor',mcolor,...
                                'markersize',3,'displayname',[agency,' (Bot)']);hold on; %,' Surf'
                            uistack(fp,'top');
                            if config.validation_minmax
                                fp = plot(xdata_d,ydata_max_d,'+','color',[0.6 0.6 0.6],...
                                    'HandleVisibility','off');hold on
                                fp = plot(xdata_d,ydata_min_d,'+','color',[0.6 0.6 0.6],...
                                    'HandleVisibility','off');hold on
                            end
                            uistack(fp,'top');
                        end
                        
                        else
                        if fgf > 1
                            fp = plot(xdata_d,ydata_d,mface,'markeredgecolor',...
                                'k','markerfacecolor',...
                                mcolor,'markersize',5, 'Color', mcolor, 'HandleVisibility','off');hold on
                            uistack(fp,'top');
                            if config.validation_minmax
                                fp = plot(xdata_d,ydata_max_d,'+','color',[0.6 0.6 0.6],...
                                    'HandleVisibility','off');hold on
                                fp = plot(xdata_d,ydata_min_d,'+','color',[0.6 0.6 0.6],...
                                    'HandleVisibility','off');hold on
                            end
                            uistack(fp,'top');
                        else
                            fp = plot(xdata_d,ydata_d,mface,'markeredgecolor',...
                                'k','markerfacecolor',mcolor,...
                                'markersize',5,'Color', mcolor,'displayname',[agency]);hold on; %,' Surf'
                            uistack(fp,'top');
                            if config.validation_minmax
                                fp = plot(xdata_d,ydata_max_d,'+','color',[0.6 0.6 0.6],...
                                    'HandleVisibility','off');hold on
                                fp = plot(xdata_d,ydata_min_d,'+','color',[0.6 0.6 0.6],...
                                    'HandleVisibility','off');hold on
                            end
                            uistack(fp,'top');
                        end
                            
                        end
                        
                        if config.isYlim
                            if ~isempty(config.cAxis(var).value)
                                ggg = find(ydata_d > config.cAxis(var).value(2));
                                
                                if ~isempty(ggg)
                                    agencyused = [agencyused;{'Outside Range'}];
                                    fgf = sum(strcmpi(agencyused,'Outside Range'));
                                    rdata = [];
                                    rdata(1:length(ggg),1) = config.cAxis(var).value(2);
                                    hhh = find(xdata_d(ggg) >= config.datearray(1) & ...
                                        xdata_d(ggg) <= config.datearray(end));
                                    
                                    if ~isempty(hhh)
                                        if fgf > 1
                                            fp = plot(xdata_d(ggg),rdata,'k+',...
                                                'markersize',4,'linewidth',1,'HandleVisibility','off');hold on
                                            uistack(fp,'top');
                                        else
                                            fp = plot(xdata_d(ggg),rdata,'k+',...
                                                'markersize',4,'linewidth',1,'displayname','Outside Range');hold on
                                            uistack(fp,'top');
                                        end
                                        uistack(fp,'top');
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        if(strlength(site_string)>7)
            disp(site_string)
        end
        clear site_string;
    end
end

end
