clear; close all;

simID='IPV3'; % make sure the simID matches the one in step1
outdir=['./',simID,'/'];
% 
% ncfile='W:\Erie\erie_tfv_aed_2013_ver012_rev0\Output_IP\erie_12_k_NDIP_ALL.nc';
% %'W:\Erie\erie_tfv_aed_2013_ver012_rev0\erie_tfv_aed_2013_ver012_rev0\Output\erie_12_j_AED.nc';
% dat=tfv_readnetcdf(ncfile,'timestep',1);
% cellX=dat.cell_X;
% cellY=dat.cell_Y;
% 
% surfinds = dat.idx3(dat.idx3 > 0);
% bottom_cells(1:length(dat.idx3)-1) = dat.idx3(2:end) - 1;
% bottom_cells(length(dat.idx3)) = length(dat.idx3);
% 
% dat2=tfv_readnetcdf(ncfile,'time',1);
% timestep=double(dat2.Time);
% modtime=floor(timestep);
% 
% 
% polygon_file = 'E:\database\AED-MARVL-v0.4\Projects\Erie\GIS\erie_validation_v6.shp';
% shp=shaperead(polygon_file);

% define variables and their plotting features
vars={'WQ_DIAG_TOT_TP','WQ_PHS_FRP','WQ_DIAG_TOT_TN','WQ_NIT_NIT','WQ_DIAG_PHY_TCHLA','WQ_SIL_RSI','WQ_OGM_DOP','WQ_DIAG_TOT_EXTC'};
facs=[31 31 14 14 1000 28 31 1000]./1000;
varnames={'TP','FRP','TN','NOx','TCHLA','RSI','DOP','EXTC'};
units={'(mg/L)','(mg/L)','(mg/L)','(mg/L)','(\mug/L)','(mg/L)','(mg/L)','(-)'};
ylimits= [0.15 0.03  2.0  2.0  80  4 0.05  5];
axisLim2=[0.08 0.02  0.8  0.8  60  3 0.04  4];
axisInt2=[0.02 0.01  0.2  0.2  20  1 0.01  1];

% general plotting features
master.font = 'Times New Roman';
master.fontsize   = 6;
master.xlabelsize = 9;
master.ylabelsize = 9;
master.titlesize  = 10;
master.legendsize = 6;
master.visible = 'on'; % on or off
def.dimensions=[28 7.5];

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

pos1=[0.08 0.15 0.6 0.8];
pos2=[0.75 0.16 0.2 0.8];

color1=[43,140,190]./255;

% catelogical definition of zones
cattt=["WB1","WB2","WB3","WB4","WB5","WB6","CB7","CB8","CB9","CB10","CB11",...
    "CB12","CB13","CB14","CB15","CB16","CB17","CB18","CB19","CB20","CB21","CB22","CB23",...
    "CB24","CB25","CB26","CB27","CB28","CB29","CB30","CB31","EB32","EB33",...
    "EB34","EB35","EB36","EB37","EB38","EB39","EB40","EB41","EB42","EB43",...
    "EB44","EB45"];

% go through variables for plotting
for vv=1:length(vars)
    clf;
    disp(['working on ',vars{vv},'...']);
    load([outdir,'saved_data_',vars{vv},'.mat']);
    
    % catelog the polygon zones
    namesites=categorical(plotdata.Site,cattt);
    
    % factor to convert model unit to mg/L
    fac=facs(vv);
    
    % calculate the median values of each polygon zones
    inc=1;
    for jj=1:length(cattt)
        s0=cattt(jj);
        s1=cellstr(s0);
        S2F=s1{1};
        tmpdata=find(contains(plotdata.Site,S2F) & contains(plotdata.Source,'observed'));
        
        if (vv==3 && jj==45)
           plotdata.Data(tmpdata)=nan;
        end
    
        if ~isempty(tmpdata)
            tmpdataD= plotdata.Data(tmpdata);
            tmpdataN=tmpdataD(~isnan(tmpdataD));
            m1(jj)=median(tmpdataN);
        else
            m1(jj)=nan;
        end
        
        tmpdata2=find(contains(plotdata.Site,S2F) & contains(plotdata.Source,'modelled'));
        if (vv==3 && jj==45)
           plotdata.Data(tmpdata2)=nan;
        end
        
        if ~isempty(tmpdata2)
            tmpdataD2 = plotdata.Data(tmpdata2);
            tmpdataN2=tmpdataD2(~isnan(tmpdataD2));
            m2(jj)=median(tmpdataN2);
        else
            m2(jj)=nan;
        end
    end
    
    axes('position',pos1);
    l1=6; l2=31;
    boxchart(namesites,plotdata.Data*fac,'GroupByColor',plotdata.Source,'MarkerStyle','none')
    
    %set(gca,'xlim',[0 46],'ylim',[0 0.15],'XTick',[]);
    
    ylabel([varnames{vv},' ',units{vv}]);
    hold on;
    aa=get(gca,'XTick');
    plot([aa(7) aa(7)],[0 ylimits(vv)],'k:');
    
    hold on;
    plot([aa(32) aa(32)],[0 ylimits(vv)],'k:');
    hold on;
    text(aa(35),ylimits(vv)*0.9,'Eastern Basin');
    hold on;
    text(aa(16),ylimits(vv)*0.9,'Central Basin');
    hold on;
    text(aa(1),ylimits(vv)*0.9,'Western Basin');
    box on;
    set(gca,'ylim',[0 ylimits(vv)]);
    hl=legend('modelled','observed','Location','east');
    %title('(a) modelled vs. observed TP: box chart');
    
    axes('position',pos2);
    
    % IDs for WB, CB, and EB zones
    indss=[1 7 32];
    indsf=[6 31 45];
    
    colors=[127,201,127;...
        190,174,212;...
        253,192,134]./255;
    
    for kk=1:length(indss)
        ms=m1(indss(kk):indsf(kk));
        ms2=m2(indss(kk):indsf(kk));
        indm=find(~isnan(ms) & ms>0);
        
        if ~isempty(indm)
            
            scatter(ms(indm)*fac,ms2(indm)*fac,'MarkerEdgeColor',colors(kk,:),...
                'LineWidth',1.0);
            hold on;
        end
    end
    
    plot([0 axisLim2(vv)],[0 axisLim2(vv)],'k:');
    hold on;
    
    if vv==3 % because no TN data at WB
        hl=legend('CB','EB','1:1 ratio','Location','southeast');
    else
      hl=legend('WB','CB','EB','1:1 ratio','Location','southeast');
    end
    
    ind1=find(~isnan(m1) & m1>0);
    
    R = corrcoef(m1(ind1),m2(ind1));hold on;
    rf=R(1,2);
    text(axisLim2(vv)*0.6,axisLim2(vv)*0.4,['R=',num2str(rf,'%1.4f')]);
    set(gca,'xlim',[0 axisLim2(vv)],'XTick',0:axisInt2(vv):axisLim2(vv),'ylim',[0 axisLim2(vv)],'YTick',0:axisInt2(vv):axisLim2(vv));
    box on;
    xlabel(['observed median ',varnames{vv},' ',units{vv}]);
    ylabel(['modelled median ',varnames{vv},' ',units{vv}]);
    %title('(b) modelled vs. observed TP: median');
    
    %hl=legend('observed','simulated');
    
    img_name =[outdir,'boxchart_',vars{vv},'_polygons.png'];
    saveas(gcf,img_name);
    
    clear plotdata;
    
end
%clearvars -except ncfile dat surfinds bottom_cells erie shp vars facs labels cellX cellY
%end

%allnames={sitenamesWB,sitenamesCB};

