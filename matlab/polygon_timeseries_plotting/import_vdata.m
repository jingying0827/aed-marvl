function vdataout = import_vdata(vdata)


for i = 1:length(vdata)
    
    tmp = load(vdata(i).matfile);
    vdataout(i).Data = tmp.(vdata(i).fieldname);
    vdataout(i).polygon = vdata(i).polygon; 
    vdataout(i).legend = vdata(i).legend;
    vdataout(i).plotcolor = vdata(i).plotcolor;
    
    clear tmp;
end

