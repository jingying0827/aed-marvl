
clear; close all;

simID='IPV3';
outdir=['./',simID,'/'];

if ~exist(outdir,'dir')
    mkdir(outdir);
end

% reading polygon and NC files, 'W:\' is the 'Projects2' drive
polygon_file = 'W:\Erie\Plotting\MARVL\Projects\Erie\GIS\erie_validation_v6.shp';
shp=shaperead(polygon_file);

ncfile='W:\Erie\erie_tfv_aed_2013_ver012_rev0\Output_IP_V3\erie_12_k_NDIP_ALL.nc';
dat=tfv_readnetcdf(ncfile,'timestep',1);
cellX=dat.cell_X;
cellY=dat.cell_Y;

surfinds = dat.idx3(dat.idx3 > 0);
bottom_cells(1:length(dat.idx3)-1) = dat.idx3(2:end) - 1;
bottom_cells(length(dat.idx3)) = length(dat.idx3);

dat2=tfv_readnetcdf(ncfile,'time',1);
timestep=double(dat2.Time);
modtime=floor(timestep);

% define variables for boxchart
vars={'WQ_DIAG_TOT_TP','WQ_PHS_FRP','WQ_DIAG_TOT_TN','WQ_NIT_NIT','WQ_DIAG_PHY_TCHLA','WQ_SIL_RSI','WQ_OGM_DOP','WQ_DIAG_TOT_EXTC'};

% define field data file
fielddata='W:\Erie\Plotting\MARVL\Projects\Erie\data\erie.mat';
load(fielddata);

% time period to extract data
t1=datenum(2013,5,1);
t2=datenum(2013,10,1);

% go through variables for preprocessing
for vv=1:length(vars)
    
    disp(['working on ',vars{vv},'...']);
    
    % read in surface and bottom model outputs

    data=ncread(ncfile,vars{vv});
    
    datasurf=data(surfinds,:);
    databot=data(bottom_cells,:);
    %TNmean=(TNsurf+TNbot)/2;
    
    % find out the field data sites and coordinates
    allsites=fieldnames(erie);
    newsites={};
    xx=[];
    yy=[];
    cellID=[];
    
    inc=1;
    for ss=1:length(allsites)
        tmpsite=erie.(allsites{ss});
        
        if isfield(tmpsite,vars{vv})
            newsites{inc}=allsites{ss};
            xx(inc)=tmpsite.(vars{vv}).X;
            yy(inc)=tmpsite.(vars{vv}).Y;
            
            distx=cellX-xx(inc);
            disty=cellY-yy(inc);
            distt=sqrt(distx.^2+disty.^2);
            indtmp=find(distt==min(distt));
            cellID(inc)=indtmp(1);
            inc=inc+1;
        end
    end

    
    %%
    incT=1;
    for pp=1:length(shp)
        IDs=inpolygon(xx,yy,shp(pp).X,shp(pp).Y);       % field data sites within polygon
        IDsM=inpolygon(cellX,cellY,shp(pp).X,shp(pp).Y);% model cells within polygon
        
        % go through all sites within polygon for field data
        for ii=1:length(IDs)
            if IDs(ii)==1
                disp(newsites{ii});
                tmpdate=erie.(newsites{ii}).(vars{vv}).Date;
                tmpind=find(tmpdate>t1 & tmpdate<t2);
                
                if (~isempty(tmpind))
                    tmpdata=erie.(newsites{ii}).(vars{vv}).Data(tmpind);
                    
                    if strcmp(vars{vv},'WQ_PHS_FRP')
                        tmpdata=tmpdata(tmpdata<2); % filter out the unrealistic high FRP data at EB45
                    end
                    
                    % store field data in format of 'source','polygon name'
                    % and 'data'
                    for tt=1:length(tmpdata)
                        plotdata.Source{incT}='observed';
                        plotdata.Site{incT}=upper(shp(pp).Name);
                        plotdata.Data(incT)=tmpdata(tt);
                        incT=incT+1;
                    end
                    
                    % find model data at same dates of observation and save
                    % the mean data of all cells 
                    newdate=floor(tmpdate(tmpind));
                    uninewdate=unique(newdate);
                    
                    for uu=1:length(uninewdate)
                        timeind=find(modtime==uninewdate(uu));
                        if ~isempty(timeind)
                            disp(datestr(timestep(timeind(4)))); % 4th is the 12pm output
                          % merge surface and bottom data
                          tmpmodSurf=datasurf(IDsM,timeind(4));
                          tmpmodBot=databot(IDsM,timeind(4));
                          tmpmod=[tmpmodSurf;tmpmodBot];
                          
                          % sub-sample the model output to reduce size
                          tmpmod2=tmpmod(1:5:end);

                            % save the model output in same format
                            for tt=1:length(tmpmod2)
                                plotdata.Source{incT}='modelled';
                                plotdata.Site{incT}=upper(shp(pp).Name);
                                plotdata.Data(incT)=tmpmod2(tt);
                                incT=incT+1;
                            end
                        end
                    end
                end
            end
        end
        
        
    end
    
    save([outdir,'saved_data_',vars{vv},'.mat'],'plotdata','-mat','-v7.3');
end
