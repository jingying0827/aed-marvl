function marvl_plot_sheet(MARVLs)

%--------------------------------------------------------------------------
disp('plot_sheet: START');
%
%clear; close all;
%run('E:\database\AED-MARVl-v0.2\Examples\Cockburn\MARVL.m');
master=MARVLs.master;
config=MARVLs.sheet;
def=config;
ncfile=master.ncfile;
%--------------------------------------------------------------------------
%disp('plottfv_transect: START')
disp('')


% read in basic data
dat = tfv_readnetcdf(ncfile(1).name,'time',1);
timesteps = double(dat.Time);

dat = tfv_readnetcdf(ncfile(1).name,'timestep',1);
vert(:,1) = dat.node_X;
vert(:,2) = dat.node_Y;
faces = dat.cell_node';

%--% Fix the triangles
faces(faces(:,4)== 0,4) = faces(faces(:,4)== 0,1);

if strcmpi(config.style,'m_map') == 1
    
    LONG=vert(:,1);LAT=vert(:,2);
    [X,Y]=m_ll2xy(LONG,LAT);
    vert(:,1)=X;vert(:,2)=Y;
end

if strcmpi(config.plotdepth{1},'bottom') == 1
    cells(1:length(dat.idx3)-1) = dat.idx3(2:end) - 1;
    cells(length(dat.idx3)) = length(dat.idx3);
else
    cells=dat.idx3(dat.idx3 > 0);
end

ts=find(abs(timesteps-def.datearray(1))==min(abs(timesteps-def.datearray(1))));
tf=find(abs(timesteps-def.datearray(2))==min(abs(timesteps-def.datearray(2))));


% start plotting, loop through selected variables
for var = config.start_plot_ID:config.end_plot_ID
    
    loadname = master.varname{var,1};       % AED name
    loadname_human = master.varname{var,2}; % User-define name
    savedir = [config.outputdirectory,loadname,'/']; % output path
    if ~exist(savedir,'dir')
        mkdir(savedir);
    end
    
    disp(['Plotting ',loadname]);
    
    % create movie file
    
    if strcmpi(config.plottype,'movie')
        if strcmpi(config.FileFormat,'mp4')==1
            sim_name = [config.outputdirectory,loadname,'.mp4'];
            hvid = VideoWriter(sim_name,'MPEG-4');
        else
            sim_name = [config.outputdirectory,loadname,'.avi'];
            hvid = VideoWriter(sim_name,'avi');
        end
        
        set(hvid,'Quality',config.Quality);
        set(hvid,'FrameRate',config.FrameRate);
        framepar.resolution = config.resolution;
        
        open(hvid);
        
        if strcmpi(config.style,'m_map') == 1
            m_proj('miller','lon',config.xlim,'lat',config.ylim);
            hold on;
        end
        
        % define time
        first_plot = 1;
        
        % loop through time
        for i = ts:def.plot_interval:tf
            tdat = tfv_readnetcdf(ncfile(1).name,'timestep',i);
            
            if strcmpi(loadname,'H') == 0
                cdata = tdat.(loadname)(cells);
            else
                cdata = tdat.(loadname);
            end
            
            [cdata,c_units,isConv,ylab] = tfv_Unit_Conversion(cdata,loadname);
            
            Depth = tdat.D;
            
            if def.clip_depth < 900
                Depth(Depth < def.clip_depth) = 0;
                cdata(Depth == 0) = NaN;
            end
            
            if first_plot
                hfig = figure('visible','on','position',[304 166 config.resolution(1) config.resolution(2)]);
                set(gcf, 'PaperPositionMode', 'manual');
                set(gcf, 'PaperUnits', 'centimeters');
                set(gcf,'paperposition',[0.635 6.35 config.resolution(1)/80 config.resolution(2)/80]);
                
                axes('position',[0.15 0.1 0.8 0.8]);
                
                patFig = patch('faces',faces,'vertices',vert,'FaceVertexCData',cdata);shading flat
                set(gca,'box','on');
                
                set(findobj(gca,'type','surface'),...
                    'FaceLighting','phong',...
                    'AmbientStrength',.3,'DiffuseStrength',.8,...
                    'SpecularStrength',.9,'SpecularExponent',25,...
                    'BackFaceLighting','unlit');
                
                caxis(def.cAxis(var).value);
                colormap(config.colormap);
                cb = colorbar;
                
                %   set(cb,'position',[0.85 0.12 0.01 0.45],...
                %       'units','normalized','ycolor','k');
                if strcmpi(config.style,'none') == 1
                    colorTitleHandle = get(cb,'Title');
                    set(colorTitleHandle,'String',c_units);
                    axis equal;
                    
                    if ~isempty(config.xlim)
                        set(gca,'xlim',config.xlim,'ylim',config.ylim);
                    end
                    
                    if config.isAxison
                        axis on;
                        xlim=get(gca,'xlim');
                        set(gca,'XTick',xlim(1):(xlim(2)-xlim(1))/3:xlim(2));
                        ylim=get(gca,'ylim');
                        set(gca,'YTick',ylim(1):(ylim(2)-ylim(1))/3:ylim(2));
                        ax = ancestor(gca, 'axes');
                        ax.XAxis.Exponent = 0;
                        xtickformat('%.3f');
                        ax.YAxis.Exponent = 0;
                        ytickformat('%.3f');
                    else
                        axis off;
                    end
                    
                else
                    m_grid('box','fancy','tickdir','out');
                    hold on;
                end
                
                if isConv
                    if master.add_human
                        title_str=[regexprep(loadname_human,'_',' '),' (',c_units,')'];
                        %                     text(0.1,0.9,[regexprep(loadname_human,'_',' '),' (',c_units,')'],...
                        %                         'Units','Normalized',...
                        %                         'Fontname',def.font,...
                        %                         'Fontsize',16,...
                        %                         'fontweight','Bold',...
                        %                         'color','k');
                        
                    else
                        title_str=[regexprep(loadname,'_',' '),' (',c_units,')'];
                        %                     text(0.1,0.9,[regexprep(loadname,'_',' '),' (',c_units,')'],...
                        %                         'Units','Normalized',...
                        %                         'Fontname',def.font,...
                        %                         'Fontsize',16,...
                        %                         'fontweight','Bold',...
                        %                         'color','k');
                        
                    end
                else
                    if config.add_human
                        title_str=[regexprep(loadname_human,'_',' '),' (model units)'];
                        %                     text(0.1,0.9,[regexprep(loadname_human,'_',' '),' (model units)'],...
                        %                         'Units','Normalized',...
                        %                         'Fontname',def.font,...
                        %                         'Fontsize',16,...
                        %                         'fontweight','Bold',...
                        %                         'color','k');
                        
                    else
                        title_str=[regexprep(loadname,'_',' '),' '];
                        %                     text(0.1,0.9,[regexprep(loadname,'_',' '),' '],...
                        %                         'Units','Normalized',...
                        %                         'Fontname',def.font,...
                        %                         'Fontsize',16,...
                        %                         'fontweight','Bold',...
                        %                         'color','k');
                        
                    end
                end
                
                title([title_str,' at ', datestr(timesteps(i),'dd mmm yyyy HH:MM')],...
                    'Units','Normalized',...
                    'Fontname',master.font,...
                    'Fontsize',master.titlesize,...
                    'color','k');
                %             txtDate = text(0.1,0.1,datestr(timesteps(i),'dd mmm yyyy HH:MM'),...
                %                 'Units','Normalized',...
                %                 'Fontname',def.font,...
                %                 'Fontsize',16,...
                %                 'color','k');
                
                first_plot = 0;
                
            else
                disp(['Plotting ',datestr(timesteps(i),'dd mmm yyyy HH:MM'),'...']);
                set(patFig,'Cdata',cdata);
                drawnow;
                %   set(txtDate,'String',datestr(timesteps(i),'dd mmm yyyy HH:MM'));
                title([title_str,' at ', datestr(timesteps(i),'dd mmm yyyy HH:MM')],...
                    'Units','Normalized',...
                    'Fontname',master.font,...
                    'Fontsize',master.titlesize,...
                    'color','k');
                caxis(def.cAxis(1).value);
                
            end
            writeVideo(hvid,getframe(hfig));
            
            if config.save_images
                img_dir = [config.outputdirectory,loadname,'/'];
                if ~exist(img_dir,'dir')
                    mkdir(img_dir);
                end
                img_name =[img_dir,datestr(timesteps(i),'yyyymmddHHMM'),'.png'];
               % saveas(gcf,img_name);
                print(gcf,'-dpng',img_name,'-opengl');
            end
            clear data cdata
        end
        
        % close movie handle
        close(hvid);
        
    else
        tmpdata=ncread(ncfile(1).name,loadname);
        tmpdata2=tmpdata(cells,ts:tf);
        
        [tmpdata2,c_units,isConv,ylab] = tfv_Unit_Conversion(tmpdata2,loadname);
        
        Depth0 = ncread(ncfile(1).name,'D');
        Depth2=Depth0(:,ts:tf);
        
        if def.clip_depth < 900
            Depth2(Depth2 < def.clip_depth) = 0;
            tmpdata2(Depth2 == 0) = NaN;
        end
        cdata=mean(tmpdata2,2);
        % clear tmpdata tmpdata2 Depth0 depth2 cdata0;
        
        hfig = figure('visible','on','position',[304 166 config.resolution(1) config.resolution(2)]);
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf,'paperposition',[0.635 6.35 config.resolution(1)/80 config.resolution(2)/80]);
        
        axes('position',[0.15 0.1 0.8 0.8]);
        
        if strcmpi(config.style,'m_map') == 1
            m_proj('miller','lon',config.xlim,'lat',config.ylim);
            hold on;
        end
        
        patFig = patch('faces',faces,'vertices',vert,'FaceVertexCData',cdata);shading flat;
        set(gca,'box','on');
        
        set(findobj(gca,'type','surface'),...
            'FaceLighting','phong',...
            'AmbientStrength',.3,'DiffuseStrength',.8,...
            'SpecularStrength',.9,'SpecularExponent',25,...
            'BackFaceLighting','unlit');
        
        %   caxis(def.cAxis(1).value);
        colormap(config.colormap);
        cb = colorbar;
        caxis(def.cAxis(var).value);
        
        if strcmpi(config.style,'none') == 1
            set(cb,'position',[0.85 0.12 0.01 0.45],...
                'units','normalized','ycolor','k');
            
            colorTitleHandle = get(cb,'Title');
            set(colorTitleHandle,'String',c_units);
            axis equal;
            if ~isempty(config.xlim)
                set(gca,'xlim',config.xlim,'ylim',config.ylim);
            end
            
            if config.isAxison
                axis on;
                xlim=get(gca,'xlim');
                set(gca,'XTick',xlim(1):(xlim(2)-xlim(1))/3:xlim(2));
                ylim=get(gca,'ylim');
                set(gca,'YTick',ylim(1):(ylim(2)-ylim(1))/3:ylim(2));
                ax = ancestor(gca, 'axes');
                ax.XAxis.Exponent = 0;
                xtickformat('%.3f');
                ax.YAxis.Exponent = 0;
                ytickformat('%.3f');
            else
                axis off;
            end
            
        else
            m_grid('box','fancy','tickdir','out');
            hold on;
        end
        
        if isConv
            if master.add_human
                title_str=[regexprep(loadname_human,'_',' '),' (',c_units,')'];
            else
                title_str=[regexprep(loadname,'_',' '),' (',c_units,')'];
            end
        else
            if config.add_human
                title_str=[regexprep(loadname_human,'_',' '),' (model units)'];
            else
                title_str=[regexprep(loadname,'_',' '),' '];
            end
        end
        
        title([title_str,': ', datestr(def.datearray(1),'dd/mmm/yyyy'),...
            ' - ',datestr(def.datearray(2),'dd/mmm/yyyy')],...
            'Units','Normalized',...
            'Fontname',master.font,...
            'Fontsize',master.titlesize,...
            'color','k');
        img_dir = [config.outputdirectory,loadname,'/'];
        if ~exist(img_dir,'dir')
            mkdir(img_dir);
        end
        img_name =[img_dir,loadname,' ', datestr(def.datearray(1),'dd-mmm-yyyy'),...
            ' to ',datestr(def.datearray(2),'dd-mmm-yyyy'),'.png'];
       % saveas(gcf,img_name);
        print(gcf,'-dpng',img_name,'-opengl');
    end
    
end