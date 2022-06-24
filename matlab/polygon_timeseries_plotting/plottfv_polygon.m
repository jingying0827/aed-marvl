function plottfv_polygon(conf)

close all;


%--------------------------------------------------------------------------
disp('plottfv_polygon: START')
disp('')
addpath(genpath('configs'));
addpath(genpath('../tuflowfv'));

run(conf);
warning('off','all')
%--------------------------------------------------------------------------
sheet_vars_list;

% Style 1 == PLIM = arithmetic mean  = mean-cell

% If var found on sheet_var_list is will use mean-area, else mean-vol
%Style 2 == volume-weighted mean = mean-vol
			%area-weighted mean = mean-area
%--------------------------------------------------------------------------
if exist('mean_style','var') == 0
	mean_style = 1;
end
if exist('mean_line_style','var') == 0
	mean_line_style = {'-'};
end

if exist('add_trigger_values','var') == 0
	add_trigger_values = 0
	
end

if exist('use_matfiles','var') == 0
    use_matfiles = 0;
end


if exist('add_vdata','var') == 0
    add_vdata = 0;
end

if exist('isHTML','var') == 0
    isHTML = 1;
end
if ~exist('htmloutput','var')
    htmloutput = outputdirectory;
end

if ~exist('add_error','var')
    add_error = 1;
end

if ~exist('add_human','var')
    add_human = 0;
end

if ~exist('fieldrange_min','var')
    fieldrange_min = 200;
end

if exist('validation_minmax','var') == 0
    validation_minmax = 0;
end

if exist('isRange','var') == 0
    isRange = 1;
end
if exist('Range_ALL','var') == 0
    Range_ALL = 0;
end
if exist('isRange_Bottom','var') == 0
    isRange_Bottom = 0;
end
if ~exist('custom_datestamp','var')
    custom_datestamp = 0;
end
if ~exist('add_triangle','var')
    add_triangle = 0;
end
if ~exist('add_coorong','var')
    add_coorong = 0;
end

if ~exist('start_plot_ID','var')
    start_plot_ID = 1;
end

if ~exist('end_plot_ID','var')
    end_plot_ID = length(varname);
end

if ~exist('validation_raw','var')
    validation_raw = 0;
    
end

if validation_raw
    validation_minmax = 0;
end

if ~exist('alph','var')
    alph = 0.5;
end

if ~isfield(def,'visible')
    def.visible = 'on';
end

if ~exist('fielddata_matfile','var')
    fielddata_matfile = ['matfiles/',fielddata,'.mat'];
end

if ~exist('surface_offset','var')
    surface_offset = 0;
end
if ~exist('plot_array','var')
	plot_array = [];
end


isConv = 0;

if ~exist('plotmodel','var')
    plotmodel = 1;
end
if plotmodel
    allvars = tfv_infonetcdf(ncfile(1).name);
end

shp = shaperead(polygon_file);



if ~exist('isFieldRange','var')
    isFieldRange = 0;
end

if ~exist('single_precision','var')
    single_precision = 0;
end


max_depth = 5000;
if ~exist('depth_range','var')
    depth_range = [0 max_depth];
end

if add_trigger_values
	[snum,sstr] = xlsread(trigger_file,'A2:D1000');
	
	trigger_vars = sstr(:,1);
	trigger_values = snum(:,1);
	trigger_label = sstr(:,3);
end



if exist('plotsite','var')
    shp_t = shp;
    clear shp;
    inc = 1;
    disp('Removing plotting sites');
	plotsite
    for bhb = 1:length(shp_t)
        
        if ismember(shp_t(bhb).Plot_Order,plotsite)
            
            shp(inc) = shp_t(bhb);
            inc = inc + 1;
        end
    end
end

if exist('plotsites_ID','var')
    shp_t = shp;
    clear shp;
    inc = 1;
    disp('Removing plotting sites');
	plotsites_ID
    for bhb = plotsites_ID
        
            
            shp(inc) = shp_t(bhb);
            inc = inc + 1;
    end
end


if ~plotmodel
    add_error = 0;
end

for kk = 1:length(shp)
    shp(kk).Name = regexprep(shp(kk).Name,' ','_');
    shp(kk).Name = regexprep(shp(kk).Name,'\.','');
end

if ~exist('sites','var')
    sites = [1:1:1:length(shp)];
end

disp('SHP sites:')
disp(sites)

%--------------------------------------------------------------------------



%--------------------------------------------------------------------------
% Color Palette (Default)
% Checkout this link for color palette options: https://htmlcolors.com/flat-colors

surface_edge_color = [ 30  50  53]./255;
surface_face_color = [ 68 108 134]./255;
surface_line_color = [  0  96 100]./255;  %[69  90 100]./255;
col_pal            =[[176 190 197]./255;[162 190 197]./255;[150 190 197]./255];

bottom_edge_color = [33  33  33]./255;
bottom_face_color = [141 110 99]./255;
bottom_line_color = [62  39  35]./255;
col_pal_bottom    =[[215 204 200]./255; [200 204 200]./255; [185 204 200]./255 ];
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Load Field Data and Get site names
field = load(fielddata_matfile);
fdata = field.(fielddata);
sitenames = fieldnames(fdata);

for i = 1:length(sitenames)
    vars = fieldnames(fdata.(sitenames{i}));
    X(i) = fdata.(sitenames{i}).(vars{1}).X;
    Y(i) = fdata.(sitenames{i}).(vars{1}).Y;
end
%--------------------------------------------------------------------------
if isempty(plot_array)
	plot_array = [start_plot_ID:end_plot_ID];
end
%--------------------------------------------------------------------------
if plotmodel
    for mod = 1:length(ncfile)
        tdata = tfv_readnetcdf(ncfile(mod).name,'timestep',1);
        all_cells(mod).X = double(tdata.cell_X);
        all_cells(mod).Y = double(tdata.cell_Y);
        
        if isfield(ncfile(mod),'tfv')
            ttdata = tfv_readnetcdf(ncfile(mod).tfv,'names','D');
        else
            if sum(strcmpi(allvars,'D')) == 1
                ttdata = tfv_readnetcdf(ncfile(mod).name,'names','D');
            else
                tttdata = tfv_readnetcdf(ncfile(mod).name,'names',{'cell_Zb';'H'}); clear functions
                ttdata.D = tttdata.H - tttdata.cell_Zb;clear tttdata;
				clear tttdata;
            end
        end
        %ttdata = tfv_readnetcdf(ncfile(mod).name,'names','D');
        
        d_data(mod).D = single(ttdata.D);
		
		if surface_offset
			ttdata_1 = tfv_readnetcdf(ncfile(mod).name,'names',{'layerface_Z';'NL'});
			d_data(mod).layerface = single(ttdata_1.layerface_Z);
			d_data(mod).NL = single(ttdata_1.NL);
			clear ttdata_1
		else
			d_data(mod).layerface = [];
			d_data(mod).NL = [];
		end
		clear ttdata;
    end
end
if plotmodel
    allvars = tfv_infonetcdf(ncfile(1).name);
end
clear ttdata
%D = 0;
%--------------------------------------------------------------------------

if add_vdata
    vdataout = import_vdata(vdata);
end

if use_matfiles
disp('Using Pre Processed Matfiles');
	for i = 1:length(ncfile)
		ncfile(i).dir = regexprep(ncfile(i).name,'.nc','/');
	end
end

%--------------------------------------------------------------------------
for var = plot_array%start_plot_ID:end_plot_ID
    
    savedir = [outputdirectory,varname{var},'/'];
    mkdir(savedir);
    mkdir([savedir,'eps/']);
    loadname = varname{var};
    
    
    if plotmodel
        
        diagVar = regexp(loadname,'DIAG');
        
        for mod = 1:length(ncfile)
            disp(['Loading Model ',num2str(mod)]);
			
			
            loadname = varname{var};
			
            %
			[raw(mod).data,fdata]  = import_netcdf_data(ncfile,mod,varname,var,fdata,loadname,allvars,single_precision,use_matfiles);clear functions
			
        end
        
        clear functions
        
        switch varname{var}
            
            case 'WQ_OXY_OXY'
                ylab = 'Oxygen (mg/L)';
            case 'SAL'
                ylab = 'Salinity (psu)';
            case 'TEMP'
                ylab = 'Temperature (C)';
            otherwise
                ylab = '';
        end
    end
    
    
    c_units = [];
    for site = sites %1:length(shp)
        
        isepa = 0;
        isdewnr = 0;
        
        dimc = [0.9 0.9 0.9]; % dimmest (lightest) color
        pred_lims = [0.05,0.25,0.5,0.75,0.95];
        num_lims = length(pred_lims);
        nn = (num_lims+1)/2;
        
        leg_inc = 1;

        inpol = inpolygon(X,Y,shp(site).X,shp(site).Y);
        
        sss = find(inpol == 1);
        
        disp(strcat(' >>> var',num2str(var),'=',varname{var},'; site=',num2str(site),[': ',regexprep(shp(site).Name,'_',' ')]))
        
        epa_leg = 0;
        dewnr_leg = 0;
        
        figure('visible',def.visible);
        
        for mod = 1:length(ncfile)
            if plotmodel
			

			
                tic
                [data(mod),c_units,isConv] = tfv_getmodeldatapolygon_faster(raw(mod).data,ncfile(mod).name,all_cells(mod).X,all_cells(mod).Y,shp(site).X,shp(site).Y,{loadname},d_data(mod).D,depth_range,d_data(mod).layerface,d_data(mod).NL,surface_offset,use_matfiles);clear functions
				toc

				
                % tic
                %[data(mod),c_units,isConv] = tfv_getmodeldatapolygon(raw(mod).data,ncfile(mod).name,all_cells(mod).X,all_cells(mod).Y,shp(site).X,shp(site).Y,{loadname},d_data(mod).D,depth_range);
                %toc
                %save data.mat data -mat
                %save data1.mat data1 -mat;
                
            end
            
			xdata_dt = [];
            ydata_dt = [];
            incc=1;					
            for lev = 1:length(plotdepth)
                
                if strcmpi(plotdepth{lev},'bottom') == 1
                    if plotmodel
                        if isfield(data,'date')
                            if mod == 1 | Range_ALL == 1
                                %
                                
                                if isRange_Bottom
                                    fig = fillyy(data(mod).date_b,data(mod).pred_lim_ts_b(1,:),data(mod).pred_lim_ts_b(2*nn-1,:),dimc,col_pal_bottom(1,:));hold on
                                    %fig = fillyy(data(mod).date_b,data(mod).pred_lim_ts_b(1,:),data(mod).pred_lim_ts_b(2*nn-1,:),dimc);hold on
                                    set(fig,'DisplayName',[ncfile(mod).legend,' (Botm Range)']);
                                    set(fig,'FaceAlpha', alph);
                                    hold on
                                    
                                    for plim_i=2:(nn-1)
                                        fig2 = fillyy(data(mod).date_b,data(mod).pred_lim_ts_b(plim_i,:),data(mod).pred_lim_ts_b(2*nn-plim_i,:),dimc.*0.9.^(plim_i-1),col_pal_bottom(plim_i,:));
                                        %fig2 = fillyy(data(mod).date_b,data(mod).pred_lim_ts_b(plim_i,:),data(mod).pred_lim_ts_b(2*nn-plim_i,:),dimc.*0.9.^(plim_i-1));
                                        set(fig2,'HandleVisibility','off');
                                        set(fig2,'FaceAlpha', alph);
                                    end
                                    uistack(fig, 'bottom');
                                    uistack(fig2,'bottom');
                                end
                            end
                        end
                    end
                    if mod == 1
                        if ~isempty(sss)
                            fplotw = 0;
                            fplotm = 0;
                            fplots = 0;
                            fplotmu = 0;
                            agencyused2 = [];
                            site_string = ['     field: '];
		                    xdata_dt=[];
                            ydata_dt=[];
                            for j = 1:length(sss)
                                if isfield(fdata.(sitenames{sss(j)}),varname{var})
                                    
                                    
                                    xdata_t = [];
                                    ydata_t = [];
                                    
                                    if ~validation_raw
                                        
                                        [xdata_ta,ydata_ta,ydata_max_ta,ydata_min_ta] = get_field_at_depth(fdata.(sitenames{sss(j)}).(varname{var}).Date,fdata.(sitenames{sss(j)}).(varname{var}).Data,...
                                            fdata.(sitenames{sss(j)}).(varname{var}).Depth,plotdepth{lev});
                                        
                                    else
                                        [xdata_ta,ydata_ta,ydata_max_ta,ydata_min_ta] = get_field_at_depth_raw(fdata.(sitenames{sss(j)}).(varname{var}).Date,fdata.(sitenames{sss(j)}).(varname{var}).Data,...
                                            fdata.(sitenames{sss(j)}).(varname{var}).Depth,plotdepth{lev});
                                    end
                                    
                                    gfg = find(xdata_ta >= def.datearray(1) & xdata_ta <= def.datearray(end));
                                    
                                    if ~isempty(gfg)
                                        xdata_t = xdata_ta(gfg);
                                        ydata_t = ydata_ta(gfg);
                                        if ~validation_raw
                                            ydata_max_t = ydata_max_ta(gfg);
                                            ydata_min_t = ydata_min_ta(gfg);
                                        else
                                            ydata_max_t = [];
                                            ydata_min_t = [];
                                        end
                                    end
                                    
                                    if ~isempty(xdata_t)
                                        
                                        
                                        if ~validation_raw
                                            [xdata_d,ydata_d] = process_daily(xdata_t,ydata_t);
                                            [~,ydata_max_d] = process_daily(xdata_t,ydata_max_t);
                                            [~,ydata_min_d] = process_daily(xdata_t,ydata_min_t);
                                        else
                                            xdata_d =  xdata_t;
                                            ydata_d = ydata_t;
                                            ydata_max_d = [];
                                            ydata_min_d = [];
                                        end
                                        
										
										
										
                                        [ydata_d,c_units,isConv] = tfv_Unit_Conversion(ydata_d,varname{var});
                                        [ydata_max_d,~,~] = tfv_Unit_Conversion(ydata_max_d,varname{var});
                                        [ydata_min_d,~,~] = tfv_Unit_Conversion(ydata_min_d,varname{var});
                                        
                                        ydata_dt=[ydata_dt ydata_d];


										
                                        if isfield(fdata.(sitenames{sss(j)}).(varname{var}),'Agency')
                                            agency = fdata.(sitenames{sss(j)}).(varname{var}).Agency;
                                            
                                        else
                                            agency = 'WIR';
                                        end
                                        
                                        site_string = [site_string,' ',sitenames{sss(j)},'(',agency,'),'];
                                        
                                        %                     if strcmpi(agency,'DEWNR')
                                        [mface,mcolor,agencyname] = sort_agency_information(agency);
                                        agencyused2 = [agencyused2;{agencyname}];
                                        if plotvalidation
                                            fgf = sum(strcmpi(agencyused2,agencyname));
                                            
                                            if fgf > 1
                                                fp = plot(xdata_d,ydata_d,mface,...
                                                    'markeredgecolor',bottom_edge_color,'markerfacecolor',bottom_face_color,'markersize',3,'HandleVisibility','off');hold on
                                                uistack(fp,'top');
                                                
                                                if validation_minmax
                                                    fp = plot(xdata_d,ydata_max_d,'r+',...
                                                        'HandleVisibility','off');hold on
                                                    fp = plot(xdata_d,ydata_min_d,'r+',...
                                                        'HandleVisibility','off');hold on
                                                end
                                                uistack(fp,'top');
                                                
                                            else
                                                fp = plot(xdata_d,ydata_d,mface,...
                                                    'markeredgecolor',bottom_edge_color,'markerfacecolor',bottom_face_color,'markersize',3,'displayname',[agency, ' Bot']);hold on
                                                if validation_minmax
                                                    fp = plot(xdata_d,ydata_max_d,'r+',...
                                                        'HandleVisibility','off');hold on
                                                    fp = plot(xdata_d,ydata_min_d,'r+',...
                                                        'HandleVisibility','off');hold on
                                                end
                                                uistack(fp,'top');
                                            end
                                            
                                            if isYlim
                                                if ~isempty(def.cAxis(var).value)
                                                    ggg = find(ydata_d > def.cAxis(var).value(2));
                                                    
                                                    if ~isempty(ggg)
                                                        agencyused2 = [agencyused2;{'Outside Range'}];
                                                        fgf = sum(strcmpi(agencyused2,'Outside Range'));
                                                        rdata = [];
                                                        rdata(1:length(ggg),1) = def.cAxis(var).value(2);
                                                        
                                                        hhh = find(ydata_d(ggg) >= def.datearray(1) & ...
                                                            ydata_d(ggg) <= def.datearray(end));
                                                        
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
                    
                    
                    
                    
                    if plotmodel
                    %    [xdata,ydata] = tfv_averaging(data(mod).date_b,data(mod).pred_lim_ts_b(3,:),def);
                    %    if diagVar>0 % removes inital zero value (eg in diganostics)
                    %        xdata(1:2) = NaN;
                    %    end
                    %end
                    %%                 xdata = data(mod).date;
                    %%                 ydata = data(mod).pred_lim_ts(3,:);
                    %if plotmodel
                    %    plot(xdata,ydata,'color',ncfile(mod).colour{lev},'linewidth',0.5,'DisplayName',[ncfile(mod).legend,' (b)'],...
                    %        'linestyle',ncfile(mod).symbol{1});hold on
                    %    plotdate(1:length(xdata),mod) = xdata;
                    %    plotdata(1:length(ydata),mod) = ydata;
                    %end
                    
						if sum(ismember(mean_style,1))
						
							klk = find(mean_style == 1);
							
							[xdata,ydata] = tfv_averaging(data(mod).date,data(mod).pred_lim_ts_b(3,:),def);
							if diagVar>0 % removes inital zero value (eg in diganostics)
								xdata(1:2) = NaN;
							end

							plot(xdata,ydata,'color',ncfile(mod).colour{lev},'linewidth',0.5,'DisplayName',[ncfile(mod).legend,' (b: mean-cell)'],...
								'linestyle',mean_line_style{klk});hold on
							plotdate(1:length(xdata),mod) = xdata;
							plotdata(1:length(ydata),mod) = ydata;
						end
						
						if sum(ismember(mean_style,2))
						
							klk = find(mean_style == 2);
							
							if sum(ismember(sheet_vars,loadname))
							
							[xdata,ydata] = tfv_averaging(data(mod).date,data(mod).bottom_area_mean,def);
							if diagVar>0 % removes inital zero value (eg in diganostics)
								xdata(1:2) = NaN;
							end

							plot(xdata,ydata,'color',ncfile(mod).colour{lev},'linewidth',0.5,'DisplayName',[ncfile(mod).legend,' (b: mean-area)'],...
								'linestyle',mean_line_style{klk});hold on
							plotdate(1:length(xdata),mod) = xdata;
							plotdata(1:length(ydata),mod) = ydata;
							
							else
							
							[xdata,ydata] = tfv_averaging(data(mod).date,data(mod).bottom_vol_mean,def);
							if diagVar>0 % removes inital zero value (eg in diganostics)
								xdata(1:2) = NaN;
							end

							plot(xdata,ydata,'color',ncfile(mod).colour{lev},'linewidth',0.5,'DisplayName',[ncfile(mod).legend,' (b: mean-vol)'],...
								'linestyle',mean_line_style{klk});hold on
							plotdate(1:length(xdata),mod) = xdata;
							plotdata(1:length(ydata),mod) = ydata;
							end
						end	
					
					end
                    
                    
                    if add_error
                        MatchedData_bottom=[];
                        if exist('xdata_d','var') && ~isempty(xdata_dt)
                            % [v, loc_obs, loc_sim] = intersect(floor(xdata_t*10)/10, floor(xdata*10)/10);
                            % MatchedData_obs_surf=ydata_t(loc_obs);
                            % MatchedData_sim_surf=ydata(loc_sim);
                            
                            disp('find field data ...');
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
                            MatchedData_bottom = [v obsData(loc_obs,2) simData(loc_sim,2)];
                            clear simData obsData v loc* alldays unidays
                            clear xdata_dt ydata_dt xdata_d ydata_d
                        end
                        
                    end
                    
                else
                    if plotmodel
                        if isfield(data,'date')
                            if mod == 1 | Range_ALL == 1
                                
                                if isRange
                                    %
                                    fig = fillyy(data(mod).date,data(mod).pred_lim_ts(1,:),data(mod).pred_lim_ts(2*nn-1,:),dimc,col_pal(1,:));hold on
                                    set(fig,'DisplayName',[ncfile(mod).legend,' (Surf Range)']);
                                    set(fig,'FaceAlpha', alph);
                                    hold on
                                    
                                    for plim_i=2:(nn-1)
                                        fig2 = fillyy(data(mod).date,data(mod).pred_lim_ts(plim_i,:),data(mod).pred_lim_ts(2*nn-plim_i,:),dimc.*0.9.^(plim_i-1),col_pal(plim_i,:));
                                        set(fig2,'HandleVisibility','off');
                                        set(fig2,'FaceAlpha', alph);
                                        
                                    end
                                    uistack(fig,'bottom');
                                    uistack(fig2,'bottom');
                                end
                                
                            end
                        end
                    end
                    if mod == 1
                        if ~isempty(sss)
                            fplotw = 0;
                            fplotm = 0;
                            fplots = 0;
                            fplotmu = 0;
                            site_string = ['     field: '];
                            agencyused = [];
                            for j = 1:length(sss)
                                if isfield(fdata.(sitenames{sss(j)}),varname{var})
                                    xdata_t = [];
                                    ydata_t = [];
                                    
                                    if ~validation_raw
                                        
                                        [xdata_ta,ydata_ta,ydata_max_ta,ydata_min_ta] = get_field_at_depth(fdata.(sitenames{sss(j)}).(varname{var}).Date,fdata.(sitenames{sss(j)}).(varname{var}).Data,...
                                            fdata.(sitenames{sss(j)}).(varname{var}).Depth,plotdepth{lev});
                                        
                                    else
                                        [xdata_ta,ydata_ta,ydata_max_ta,ydata_min_ta] = get_field_at_depth_raw(fdata.(sitenames{sss(j)}).(varname{var}).Date,fdata.(sitenames{sss(j)}).(varname{var}).Data,...
                                            fdata.(sitenames{sss(j)}).(varname{var}).Depth,plotdepth{lev});
                                    end
                                    
                                    %                                     [xdata_ta,ydata_ta,ydata_max_ta,ydata_min_ta] = get_field_at_depth(fdata.(sitenames{sss(j)}).(varname{var}).Date,fdata.(sitenames{sss(j)}).(varname{var}).Data,fdata.(sitenames{sss(j)}).(varname{var}).Depth,plotdepth{lev});
                                    
                                    
                                    
                                    gfg = find(xdata_ta >= def.datearray(1) & xdata_ta <= def.datearray(end));
                                    
                                    if ~isempty(gfg)
                                        
                                        xdata_t = xdata_ta(gfg);
                                        ydata_t = ydata_ta(gfg);
                                        if ~validation_raw
                                            ydata_max_t = ydata_max_ta(gfg);
                                            ydata_min_t = ydata_min_ta(gfg);
                                        else
                                            ydata_max_t = [];
                                            ydata_min_t = [];
                                        end
                                    end
                                    
                                    
                                    if ~isempty(xdata_t)
                                        
                                        
                                        if ~validation_raw
                                            [xdata_d,ydata_d] = process_daily(xdata_t,ydata_t);
                                            [~,ydata_max_d] = process_daily(xdata_t,ydata_max_t);
                                            [~,ydata_min_d] = process_daily(xdata_t,ydata_min_t);
                                        else
                                            xdata_d =  xdata_t;
                                            ydata_d = ydata_t;
                                            ydata_max_d = [];
                                            ydata_min_d = [];
                                        end
                                        
                                        
                                        [ydata_d,c_units,isConv] = tfv_Unit_Conversion(ydata_d,varname{var});
                                        [ydata_max_d,~,~] = tfv_Unit_Conversion(ydata_max_d,varname{var});
                                        [ydata_min_d,~,~] = tfv_Unit_Conversion(ydata_min_d,varname{var});

										xdata_dt=[xdata_dt xdata_d'];
                                        ydata_dt=[ydata_dt ydata_d];
										
										
										
                                        if isfield(fdata.(sitenames{sss(j)}).(varname{var}),'Agency')
                                            agency = fdata.(sitenames{sss(j)}).(varname{var}).Agency;
                                        else
                                            agency = 'WIR';
                                        end
                                        site_string = [site_string,' ',sitenames{sss(j)},'(',agency,'),'];
                                        %                     if strcmpi(agency,'DEWNR')
                                        [mface,mcolor,agencyname] = sort_agency_information(agency);
                                        agencyused = [agencyused;{agencyname}];
                                        
                                        if plotvalidation
                                            fgf = sum(strcmpi(agencyused,agencyname));
                                            
                                            if fgf > 1
                                                %fp = plot(xdata_d,ydata_d,mface,'markerfacecolor',mcolor ,'markersize',3,'HandleVisibility','off');hold on
                                                fp = plot(xdata_d,ydata_d,mface,'markeredgecolor',surface_edge_color,'markerfacecolor',surface_face_color,'markersize',3,'HandleVisibility','off');hold on
                                                uistack(fp,'top');
                                                if validation_minmax
                                                    
                                                    fp = plot(xdata_d,ydata_max_d,'+','color',[0.6 0.6 0.6],...
                                                        'HandleVisibility','off');hold on
                                                    fp = plot(xdata_d,ydata_min_d,'+','color',[0.6 0.6 0.6],...
                                                        'HandleVisibility','off');hold on
                                                end
                                                uistack(fp,'top');
                                            else
                                                fp = plot(xdata_d,ydata_d,mface,'markeredgecolor',surface_edge_color,'markerfacecolor',surface_face_color,'markersize',3,'displayname',[agency,' Surf']);hold on
                                                uistack(fp,'top');
                                                if validation_minmax
                                                    
                                                    fp = plot(xdata_d,ydata_max_d,'+','color',[0.6 0.6 0.6],...
                                                        'HandleVisibility','off');hold on
                                                    fp = plot(xdata_d,ydata_min_d,'+','color',[0.6 0.6 0.6],...
                                                        'HandleVisibility','off');hold on
                                                end
                                                uistack(fp,'top');
                                            end
                                            
                                            if isYlim
                                                
                                                if ~isempty(def.cAxis(var).value)
                                                    
                                                    ggg = find(ydata_d > def.cAxis(var).value(2));
                                                    
                                                    if ~isempty(ggg)
                                                        agencyused = [agencyused;{'Outside Range'}];
                                                        fgf = sum(strcmpi(agencyused,'Outside Range'));
                                                        rdata = [];
                                                        rdata(1:length(ggg),1) = def.cAxis(var).value(2);
                                                        hhh = find(xdata_d(ggg) >= def.datearray(1) & ...
                                                            xdata_d(ggg) <= def.datearray(end));
                                                        
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
                                            %
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
                    
                    
                    
                    if plotmodel
					
						if sum(ismember(mean_style,1))
						
							klk = find(mean_style == 1);
							
							[xdata,ydata] = tfv_averaging(data(mod).date,data(mod).pred_lim_ts(3,:),def);
							if diagVar>0 % removes inital zero value (eg in diganostics)
								xdata(1:2) = NaN;
							end

							plot(xdata,ydata,'color',ncfile(mod).colour{1},'linewidth',0.5,'DisplayName',[ncfile(mod).legend,' (s: mean-cell)'],...
								'linestyle',mean_line_style{klk});hold on
							plotdate(1:length(xdata),mod) = xdata;
							plotdata(1:length(ydata),mod) = ydata;
						end
						
						if sum(ismember(mean_style,2))
						
							klk = find(mean_style == 2);
							
							if sum(ismember(sheet_vars,loadname))
							
							[xdata,ydata] = tfv_averaging(data(mod).date,data(mod).surface_area_mean,def);
							if diagVar>0 % removes inital zero value (eg in diganostics)
								xdata(1:2) = NaN;
							end

							plot(xdata,ydata,'color',ncfile(mod).colour{1},'linewidth',0.5,'DisplayName',[ncfile(mod).legend,' (s: mean-area)'],...
								'linestyle',mean_line_style{klk});hold on
							plotdate(1:length(xdata),mod) = xdata;
							plotdata(1:length(ydata),mod) = ydata;
							
							else
							
							[xdata,ydata] = tfv_averaging(data(mod).date,data(mod).surface_vol_mean,def);
							if diagVar>0 % removes inital zero value (eg in diganostics)
								xdata(1:2) = NaN;
							end

							plot(xdata,ydata,'color',ncfile(mod).colour{1},'linewidth',0.5,'DisplayName',[ncfile(mod).legend,' (s: mean-vol)'],...
								'linestyle',mean_line_style{klk});hold on
							plotdate(1:length(xdata),mod) = xdata;
							plotdata(1:length(ydata),mod) = ydata;
							end
						end						
					
						
						
						
						
                    end
                    if add_error
                        MatchedData_surf=[];
                        if (exist('xdata_dt','var') && ~isempty(xdata_dt))
                            % [v, loc_obs, loc_sim] = intersect(floor(xdata_t*10)/10, floor(xdata*10)/10);
                            % MatchedData_obs_surf=ydata_t(loc_obs);
                            % MatchedData_sim_surf=ydata(loc_sim);
                            
                            disp('find field data ...');
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
                            MatchedData_surf = [v obsData(loc_obs,2) simData(loc_sim,2)];
                            clear simData obsData v loc* alldays unidays
                            clear xdata_d ydata_d xdata_dt ydata_dt
                        end
                    end
                    
                    %end
                    
                end
                
                
                
                
                
            end
            
        end
        
        
        % Optional code to add long-term montly observed data percentile
        % bands ontoplots
        if isFieldRange
            shp(site).Name
            outdata = calc_data_ranges(fdata,shp(site).X,shp(site).Y,fieldprctile,varname{var});
            
            if sum(~isnan(outdata.low)) > fieldrange_min
                
                plot(outdata.Date,outdata.low, 'color',surface_edge_color,'linestyle',':','displayname',['Obs \itP_{',num2str(fieldprctile(1)),'}']);hold on
                plot(outdata.Date,outdata.high,'color',surface_edge_color,'linestyle',':','displayname',['Obs \itP_{',num2str(fieldprctile(2)),'}']);hold on
                
            end
        end
        
        if add_trigger_values
		
		trig = find(strcmpi(trigger_vars,loadname) == 1);
		
			if ~isempty(trig)
			
				plot([def.datearray(1) def.datearray(end)],[trigger_values(trig) trigger_values(trig)],'--r','DisplayName',trigger_label{trig});
			end
		end
        
        
        
        %          if strcmpi({loadname},'WQ_OXY_OXY') == 1 & strcmpi(shp(site).Name,'Murray_Bridge') == 1
        %              plot(mon.YSI.MBO.Time,mon.YSI.MBO.ODO_Conc,'color','m','linestyle',':','displayname','YSI Monitoring Data')
        %
        %              plot(Monitoring.YSI.MBO.Time,Monitoring.YSI.MBO.ODO_Conc,'color','m','linestyle',':','displayname','YSI Monitoring Data')
        % %             plot(target.A4261156.Date,target.A4261156.Data);
        %          end
        %          if strcmpi({loadname},'WQ_OXY_OXY') == 1 & strcmpi(shp(site).Name,'TailemBend') == 1
        %              plot(Monitoring.YSI.TAILEM.Time,Monitoring.YSI.TAILEM.ODO_Conc,'color','m','linestyle',':','displayname','YSI Monitoring Data')
        % %             plot(target.A4261156.Date,target.A4261156.Data);
        %          end
        
        grid on;
        
        if isConv
            if isylabel
                if add_human
                    ylabel([regexprep(varname_human{var},'_',' '),' (',c_units,')'],'fontsize',8,'color',[0.0 0.0 0.0],'horizontalalignment','center');
                else
                    ylabel([regexprep(loadname,'_',' '),' (',c_units,')'],'fontsize',6,'color',[0.4 0.4 0.4],'horizontalalignment','center');
                end
            end
            % BB TURN ONtext(1.02,0.5,[regexprep(loadname,'_',' '),' (',c_units,')'],'units','normalized','fontsize',5,'color',[0.4 0.4 0.4],'rotation',90,'horizontalalignment','center');
        else
            if isylabel
                if add_human
                    ylabel([regexprep(varname_human{var},'_',' '),' (model units)'],'fontsize',8,'color',[0.0 0.0 0.0],'horizontalalignment','center');
                else
                    
                    ylabel([regexprep(loadname,'_',' '),' '],'fontsize',6,'color',[0.4 0.4 0.4],'horizontalalignment','center');
                end
            end
            % BB TURN ONtext(1.02,0.5,[regexprep(loadname,'_',' '),' (model units)'],'units','normalized','fontsize',5,'color',[0.4 0.4 0.4],'rotation',90,'horizontalalignment','center');
        end
        
        
        if (depth_range(2)==max_depth)
            depdep = 'max';
        else
            depdep = [num2str(depth_range(2)),'m'];
        end
        % BB TURN ONtext(0.92,1.02,[num2str(depth_range(1)),' : ',depdep],'units','normalized','fontsize',5,'color',[0.4 0.4 0.4],'horizontalalignment','center');
        
        
        if add_triangle
            plot(triangle_date + 1,def.cAxis(var).value(1),'marker','v',...
                'HandleVisibility','off',...
                'markerfacecolor',[0.7 0.7 0.7],'markeredgecolor','k','markersize',3);%'color',[0.7 0.7 0.7]);
        end
        
        
        if add_vdata
            
            for vd = 1:length(vdataout)
                
                %varname{var}
                %site
                if vdataout(vd).polygon == site & ...
                        isfield(vdataout(vd).Data,varname{var})
                    
                    [vd_data,~,~] = tfv_Unit_Conversion(vdataout(vd).Data.(varname{var}).vdata,varname{var});
                    
                    plot(vdataout(vd).Data.(varname{var}).Date,vd_data,...
                        vdataout(vd).plotcolor,'displayname',vdataout(vd).legend);
                end
            end
        end
                
            
            
        
        
        
        if add_coorong
            yrange = def.cAxis(var).value(2) - def.cAxis(var).value(1);
            y10 = yrange* 0.1;
            y20 = y10*2;
            y30 = y10 * 3;
            
            % Add life stage information
            [yyyy,~,~] = datevec(def.datearray);
            
            years = unique(yyyy);
            for st = 1:length(years)
                
                pt = plot([datenum(years(st),01,01) datenum(years(st),01,01)],[def.cAxis(var).value(1) def.cAxis(var).value(end)],'--k');
                set(pt,'HandleVisibility','off');
                pt = plot([datenum(years(st),09,01) datenum(years(st),09,01)],[def.cAxis(var).value(1) def.cAxis(var).value(end)],'--k');
                set(pt,'HandleVisibility','off');
                
                st1 = plot([datenum(years(st),04,01) (datenum(years(st),04,01)+120)],...
                    [(def.cAxis(var).value(2)-y10) (def.cAxis(var).value(2)-y10)],'k');
                set(st1,'HandleVisibility','off');
                
                st1 = plot([datenum(years(st),06,01) (datenum(years(st),06,01)+120)],...
                    [(def.cAxis(var).value(2)-y20) (def.cAxis(var).value(2)-y20)],'k');
                set(st1,'HandleVisibility','off');
                
                st1 = plot([datenum(years(st),08,01) (datenum(years(st),08,01)+150)],...
                    [(def.cAxis(var).value(2)-y30) (def.cAxis(var).value(2)-y30)],'k');
                set(st1,'HandleVisibility','off');
                
            end
            
        end
        
        %         if strcmpi({loadname},'TEMP')
        %             plot([datenum(2015,01,01) datenum(2019,01,01)],[17 17],'--k');
        %             plot([datenum(2015,01,01) datenum(2019,01,01)],[25 25],'--k');
        %         end
        
        xlim([def.datearray(1) def.datearray(end)]);
        if isYlim
            if ~isempty(def.cAxis(var).value)
                ylim([def.cAxis(var).value]);
            end
        else
            def.cAxis(var).value = get(gca,'ylim');
            def.cAxis(var).value(1) = 0;
            %    ylim([def.cAxis(var).value]);
        end
        
        if ~custom_datestamp
            %disp('hi')
            set(gca,'Xtick',def.datearray,...
                'XTickLabel',datestr(def.datearray,def.dateformat),...
                'FontSize',def.xlabelsize);
        else
            new_dates = def.datearray  - zero_day;
            new_dates = new_dates - 1;
            
            ttt = find(new_dates >= 0);
            
            
            set(gca,'Xtick',def.datearray(ttt),...
                'XTickLabel',num2str(new_dates(ttt)'),...
                'FontSize',def.xlabelsize);
        end
        
        
        
        %         if isylabel
        %
        %             %                    if isempty(units)
        %             %                        units = fdata.(sitenames{site}).(varname{var}).Units;
        %             %                    end
        %
        %             ylabel(ylab,...
        %                 'FontSize',def.ylabelsize);
        %         end
        
        
        %         if sum(strcmp(valid_vars,varname{var})) > 0
        %             if isylabel
        %
        %                 if isempty(units)
        %                     units = fdata.(sitenames{site}).(varname{var}).Units;
        %                 end
        %
        %                 ylabel([regexprep(fdata.(sitenames{site}).(varname{var}).Variable_Name,'_',' '),' (',...
        %                     units,')'],...
        %                     'FontSize',def.ylabelsize);
        %             end
        %         end
        if istitled
            %             if sum(strcmp(valid_vars,varname{var})) > 0
            %                 if isfield(fdata.(sitenames{site}).(varname{var}),'Title')
            title([regexprep(shp(site).Name,'_',' ')],...
                'FontSize',def.titlesize,...
                'FontWeight','bold');
            %                 end
            %             else
            %                 if isfield(fdata.(sitenames{site}).SAL,'Title')
            %                     title(fdata.(sitenames{site}).SAL.Title,...
            %                         'FontSize',def.titlesize,...
            %                         'FontWeight','bold');
            %                 end
            %             end
        end
        if exist('islegend','var')
            if islegend
                leg = legend('show');
                set(leg,'location',def.legendlocation,'fontsize',def.legendsize);
            end
        else
            leg = legend('location',def.legendlocation);
            set(leg,'fontsize',def.legendsize);
        end
        %% adding error output
        if add_error
            MatchedData_obs=[];
            MatchedData_sim=[];
            
            if (exist('MatchedData_surf','var') && ~isempty(MatchedData_surf))
                MatchedData_obs=[MatchedData_obs, MatchedData_surf(:,2)];
                MatchedData_sim=[MatchedData_sim, MatchedData_surf(:,3)];
            end
            if (exist('MatchedData_bottom','var') && ~isempty(MatchedData_bottom))
                MatchedData_obs=[MatchedData_obs', MatchedData_bottom(:,2)'];
                MatchedData_sim=[MatchedData_sim', MatchedData_bottom(:,3)'];
            end
            clear MatchedData_surf MatchedData_bottom
            
            if length(MatchedData_obs)>6
                
                if size(MatchedData_obs,2)>1
                    [stat_mae,stat_r,stat_rms,stat_nash,stat_nmae,stat_nrms]=do_error_calculation_2layers(MatchedData_obs',MatchedData_sim');
                else
                    [stat_mae,stat_r,stat_rms,stat_nash,stat_nmae,stat_nrms]=do_error_calculation_2layers(MatchedData_obs,MatchedData_sim);
                end
                
                devia=(mean(MatchedData_sim)-mean(MatchedData_obs))/mean(MatchedData_obs);
                
                if abs(devia)>10
                    deviaS='Out of range';
                    deviaSn=NaN;
                else
                    deviaS=[num2str(devia*100,'%3.2f'),'%'];
                    deviaSn=devia*100;
                end
                str{1}=['R = ',num2str(stat_r,'%1.4f')];
                str{2}=['BIAS = ',deviaS];
                % str{3}=['NMAE = ',num2str(stat_nmae,'%1.4f')];
                % str{4}=['NRMS = ',num2str(stat_nrms,'%1.4f')];
                str{3}=['MAE = ',num2str(stat_mae,'%3.2f'),' (', num2str(stat_nmae*100,'%3.2f'),'%)'];
                str{4}=['RMS = ',num2str(stat_rms,'%3.2f'),' (', num2str(stat_nrms*100,'%3.2f'),'%)'];
                if exist('isSaveErr','var') && isMEF
                    str{5}=['nash = ',num2str(stat_nash,'%1.4f')];
                end
                dim=[0.7 0.1 0.25 0.3];
                ha=annotation('textbox',dim,'String',str,'FitBoxToText','on');
                set(ha,'FontSize',5);
                errorMatrix.(regexprep(shp(site).Name,' ','_')).(loadname).R=stat_r;
                errorMatrix.(regexprep(shp(site).Name,' ','_')).(loadname).BIAS=deviaSn;
                errorMatrix.(regexprep(shp(site).Name,' ','_')).(loadname).MAE=stat_mae;
                errorMatrix.(regexprep(shp(site).Name,' ','_')).(loadname).RMS=stat_rms;
                errorMatrix.(regexprep(shp(site).Name,' ','_')).(loadname).NMAE=stat_nmae;
                errorMatrix.(regexprep(shp(site).Name,' ','_')).(loadname).NRMS=stat_nrms;
                errorMatrix.(regexprep(shp(site).Name,' ','_')).(loadname).MEF=stat_nash;
                clear str stat*;
            else
                errorMatrix.(regexprep(shp(site).Name,' ','_')).(loadname).R=NaN;
                errorMatrix.(regexprep(shp(site).Name,' ','_')).(loadname).BIAS=NaN;
                errorMatrix.(regexprep(shp(site).Name,' ','_')).(loadname).MAE=NaN;
                errorMatrix.(regexprep(shp(site).Name,' ','_')).(loadname).RMS=NaN;
                errorMatrix.(regexprep(shp(site).Name,' ','_')).(loadname).NMAE=NaN;
                errorMatrix.(regexprep(shp(site).Name,' ','_')).(loadname).NRMS=NaN;
                errorMatrix.(regexprep(shp(site).Name,' ','_')).(loadname).MEF=NaN;
            end
            
        end
        %  clear obsData simData v loc_obs loc_sim xdata_tt ydata_tt MatchedData*;
        
        %         if strcmp(varname{var},'WQ_AED_OXYGEN_OXY') == 1
        %
        %             plot([def.datearray(1) def.datearray(end)],[2 2],...
        %                 'color',[0.4 0.4 0.4],'linestyle','--');
        %
        %             plot([def.datearray(1) def.datearray(end)],[4 4],...
        %                 'color',[0.4 0.4 0.4],'linestyle','--');
        %
        %         end
        
        %--% Paper Size
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperUnits', 'centimeters');
        xSize = def.dimensions(1);
        ySize = def.dimensions(2);
        xLeft = (21-xSize)/2;
        yTop = (30-ySize)/2;
        set(gcf,'paperposition',[0 0 xSize ySize])
        
        %             if isfield(fdata.(sitenames{site}).SAL,'Order')
        %                 final_sitename = [sprintf('%04d',fdata.(sitenames{site}).SAL.Order),'_',sitenames{site},'.png'];
        %             else
        %                 final_sitename = [sitenames{site},'.png'];
        %             end
        
        %        tVar = fieldnames(fdata.(sitenames{site}));
        
        %         if isfield(fdata.(sitenames{site}).(tVar{1}),'Order')
        %             final_sitename = [sprintf('%04d',fdata.(sitenames{site}).SAL.Order),'_',sitenames{site},'.eps'];
        %         else
        %
        %         end
        %final_sitename = [sprintf('%04d',shp(site).Plot_Order),'_',shp(site).Name,'.eps'];
        if isfield(shp(site),'Plot_Order')
            final_sitename = [sprintf('%04d',shp(site).Plot_Order),'_',shp(site).Name,'.eps'];
        else
            final_sitename = [shp(site).Name,'.eps'];
        end
        finalname = [savedir,'eps/',final_sitename];
        finalname_p = [savedir,final_sitename];
        
        if exist('filetype','var')
            if strcmpi(filetype,'png');
                %print(gcf,finalname,'-depsc2');
                print(gcf,'-dpng',regexprep(finalname_p,'.eps','.png'),'-opengl');
                %print(gcf,'-dpng',regexprep(finalname,'.eps','.png'),'-opengl');
            else
                %                     print(gcf,'-depsc2',finalname,'-painters');
                %                     print(gcf,'-dpng',regexprep(finalname,'.eps','.png'),'-opengl');
                
                %                 disp('eps');
                %print(gcf,finalname,'-depsc2');
                %disp('png');
                saveas(gcf,regexprep(finalname_p,'.eps','.png'));
            end
        else
            %                 print(gcf,'-depsc2',finalname,'-painters');
            %                 print(gcf,'-dpng',regexprep(finalname,'.eps','.png'),'-opengl');
            
            %             disp('eps');
            %print(gcf,finalname,'-depsc2');
            %disp('png');
            saveas(gcf,regexprep(finalname_p,'.eps','.png'));
        end
        
        %tfv_export_conc(regexprep(finalname,'.eps','.csv'),plotdate,plotdata,ncfile);
        
        close all force
        
        clear data;
        
    end
    
    if isHTML
        
        create_html_for_directory_onFly(savedir,varname{var},htmloutput);
        
    end
end
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
if isHTML
    create_html_for_directory(outputdirectory,htmloutput);
end

disp('')
disp('plottfv_polygon: DONE')
%--------------------------------------------------------------------------
if add_error
    if exist('isSaveErr','var') && isSaveErr
        save(ErrFilename,'errorMatrix','-mat');
    end
end