function marvl_plot_curtain(MARVLs)

%--------------------------------------------------------------------------
disp('plot_sheet_animation: START');
%
%clear; close all;
%run('E:\database\AED-MARVl-v0.2\Examples\Cockburn\MARVL.m');
master=MARVLs.master;
config=MARVLs.curtain;
def=config;
ncfile=master.ncfile;
%--------------------------------------------------------------------------
%disp('plottfv_transect: START')
disp('')

% line config
shp = shaperead(config.polyline);
for kk = 1:length(shp)
    line(kk,1) = shp(kk).X;
    line(kk,2)  = shp(kk).Y;
end

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
    
    % read in basic data
    dat = tfv_readnetcdf(ncfile(1).name,'time',1);
    timesteps = double(dat.Time);
    
    dat = tfv_readnetcdf(ncfile(1).name,'timestep',1);
    vert(:,1) = dat.node_X;
    vert(:,2) = dat.node_Y;
    faces = dat.cell_node';
    
    %--% Fix the triangles
    faces(faces(:,4)== 0,4) = faces(faces(:,4)== 0,1);
    
    geo = tfv_readnetcdf(config.geofile);
    [pt_id,geodata,cells_idx2] = tfv_searchnearest(line,geo);
    
    sXX = geodata.X(1:end);
    sYY = geodata.Y(1:end);
    
    curt.dist(1:length(geodata.X)) = 0;
    for ii = 1:length(geodata.X)-1
        temp_d = sqrt((sXX(ii+1)-sXX(ii)) .^2 + (sYY(ii+1) - sYY(ii)).^2);
        curt.dist(ii+1) = curt.dist(ii) + temp_d;
    end
    
    DX(:,1) = sXX;
    DX(:,2) = sYY;
    curt.base = geodata.Z;
    
    fillX = [min(curt.dist /1000) sort(curt.dist /1000) max(curt.dist /1000)];
    fillY =[-20;curt.base;-20];
    
    % define time
    first_plot = 1;
    ts=find(abs(timesteps-def.datearray(1))==min(abs(timesteps-def.datearray(1))));
    tf=find(abs(timesteps-def.datearray(2))==min(abs(timesteps-def.datearray(2))));
    
    % loop through time
    for i = ts:def.plot_interval:tf
        tdat = tfv_readnetcdf(ncfile(1).name,'timestep',i);
        [plotdata,c_units,isConv,ylab] = tfv_Unit_Conversion(tdat.(loadname),loadname);
        % Build Patch Grid_________________________________________________
        N = length(geodata.X);
        
        for n = 1 : (N - 1)
            i2 = cells_idx2(n);
            % Traditionl
            NL = tdat.NL(i2);
            i3 = tdat.idx3(i2);
            i3z = i3 + i2 -1;
            
            xv{n} = repmat([curt.dist(n);...
                curt.dist(n);...
                curt.dist(n+1);...
                curt.dist(n+1)],...
                [1 NL]);
            
            zv{n} = zeros(4,NL);
            for ii = 1 : NL
                zv{n}(:,ii) = [tdat.layerface_Z(i3z); ...
                    tdat.layerface_Z(i3z+1); ...
                    tdat.layerface_Z(i3z+1); ...
                    tdat.layerface_Z(i3z)];
                i3z = i3z + 1;
            end
            
            tt.var1{n} = plotdata(i3:i3+NL-1);
            
            
        end
        
        model.x = cell2mat(xv);
        model.z = cell2mat(zv);
        
        model.var1 = cell2mat(tt.var1');
        
        if first_plot
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
            
            axes('position',[0.1 0.12 0.80 0.80]);
            
            patFig = patch(model.x /1000,model.z,model.var1','edgecolor','none');hold on
            F1 = fill(fillX,fillY,[0.6 0.6 0.6]);
            % patFig = patch('faces',faces,'vertices',vert,'FaceVertexCData',cdata);shading flat
            set(gca,'box','on');
            
            set(findobj(gca,'type','surface'),...
                'FaceLighting','phong',...
                'AmbientStrength',.3,'DiffuseStrength',.8,...
                'SpecularStrength',.9,'SpecularExponent',25,...
                'BackFaceLighting','unlit');
            set(gca,'xlim',def.xlim,'XTick',def.xticks);
            xlabel(def.xlabel,'fontsize',master.xlabelsize,'FontWeight','bold','color','k','FontName',master.font);
            ylabel('Depth (m)','fontsize',master.ylabelsize,'FontWeight','bold','color','k','FontName',master.font);
            caxis(def.cAxis(1).value);
            colormap(config.colormap);
            cb = colorbar;
            
            set(cb,'position',def.colorbarposition,...
                'units','normalized','ycolor','k');
            
            colorTitleHandle = get(cb,'Title');
            set(colorTitleHandle,'String',c_units);
            % axis off;
            % axis equal;
            
            if isConv
                if master.add_human
                    title_str=[regexprep(loadname_human,'_',' '),' (',c_units,')'];
                else
                    title_str=[regexprep(loadname,'_',' '),' (',c_units,')'];
                end
            else
                if master.add_human
                    title_str=[regexprep(loadname_human,'_',' '),' (model units)'];
                else
                    title_str=[regexprep(loadname,'_',' '),' '];
                end
            end
            
            title([title_str,' at ', datestr(timesteps(i),'dd mmm yyyy HH:MM')],...
                'Units','Normalized',...
                'Fontname',master.font,...
                'Fontsize',master.titlesize,...
                'color','k');
            first_plot = 0;
            
        else
            disp(['Plotting ',datestr(timesteps(i),'dd mmm yyyy HH:MM'),'...']);
            set(patFig,'Cdata',model.var1);
            drawnow;
            %   set(txtDate,'String',datestr(timesteps(i),'dd mmm yyyy HH:MM'));
            title([title_str,' at ', datestr(timesteps(i),'dd mmm yyyy HH:MM')],...
                'Units','Normalized',...
                'Fontname',master.font,...
                'Fontsize',master.titlesize,...
                'color','k');
            caxis(def.cAxis(1).value);
            set(gca,'xlim',def.xlim,'XTick',def.xticks);
            xlabel(def.xlabel,'fontsize',master.xlabelsize,'FontWeight','bold','color','k','FontName',master.font);
            ylabel('Depth (m)','fontsize',master.ylabelsize,'FontWeight','bold','color','k','FontName',master.font);
            
            
        end
        writeVideo(hvid,getframe(gcf));
        
        if config.save_images
            img_dir = [config.outputdirectory,loadname,'/'];
            if ~exist(img_dir,'dir')
                mkdir(img_dir);
            end
            img_name =[img_dir,datestr(timesteps(i),'yyyymmddHHMM'),'.png'];
            saveas(gcf,img_name);
        end
        clear data cdata
    end
    
    % close movie handle
    close(hvid);
end