function preprocess_matfile(conf)
addpath(genpath('configs'));

addpath(genpath('../tuflowfv'));

run(conf);


field = load(fielddata_matfile);
fdata = field.(fielddata);




%
for i = 1:length(ncfile)
	ncfile(i).dir = regexprep(ncfile(i).name,'.nc','/');
end


for i = [2]%1:length(ncfile)

	rawGeo = tfv_readnetcdf(ncfile(i).name,'timestep',1);
	
	mkdir(ncfile(i).dir);
	
	
	disp(ncfile(i).name);
	
	
	bottom_cells(1:length(rawGeo.idx3)-1) = rawGeo.idx3(2:end) - 1;
	bottom_cells(length(rawGeo.idx3)) = length(rawGeo.idx3);
	
	allvars = tfv_infonetcdf(ncfile(i).name);
	allvars
	
	single_precision = 1;
	
	use_matfiles = 0;
	
	
	for j = 1:length(varname)
	
		[data,~]  = import_netcdf_data(ncfile,i,varname,j,fdata,varname{j},allvars,single_precision,use_matfiles);clear functions
	
		outdata.surface = data.(varname{j})(rawGeo.idx3(rawGeo.idx3 > 0),:);

    
		outdata.bottom = data.(varname{j})(bottom_cells,:);
		
		outfile = [ncfile(i).dir,varname{j},'.mat'];
		
		save(outfile,'outdata','-mat','-v7.3');
		
		clear data outdata outfile;
		
	end
	
	clear rawGeo bottom_cells;	
end
		
	
	
