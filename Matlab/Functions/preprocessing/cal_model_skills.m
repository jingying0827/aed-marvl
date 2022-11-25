function [errorMatrix,T,str] = cal_model_skills(MatchedData,config,shp,site,loadname,errorMatrix)   

            MatchedData_obs=[];
            MatchedData_sim=[];
            str={};
            SkillNames={};
            SkillScores={};
            
            if (exist('MatchedData','var') && ~isempty(MatchedData))
                MatchedData_obs=[MatchedData_obs, MatchedData(:,2)];
                MatchedData_sim=[MatchedData_sim, MatchedData(:,3)];
            end
%             if (exist('MatchedData_bottom','var') && ~isempty(MatchedData_bottom))
%                 MatchedData_obs=[MatchedData_obs', MatchedData_bottom(:,2)'];
%                 MatchedData_sim=[MatchedData_sim', MatchedData_bottom(:,3)'];
%             end
          %  clear MatchedData_surf MatchedData_bottom
            
            MatchedData_obs(isnan(MatchedData_obs))=mean(MatchedData_obs(~isnan(MatchedData_obs)));
            MatchedData_obs(MatchedData_obs<0)=mean(MatchedData_obs);
            ind0=(MatchedData_obs>10*(mean(MatchedData_obs)));
            MatchedData_obs(ind0)=mean(MatchedData_obs(~ind0));
            
            if length(MatchedData_obs)>config.obsTHRESH
                
                if size(MatchedData_obs,2)>1
                    [stat_mae,stat_r,stat_rms,stat_nash,stat_nmae,stat_nrms]=do_error_calculation_2layers(MatchedData_obs',MatchedData_sim');
                else
                    [stat_mae,stat_r,stat_rms,stat_nash,stat_nmae,stat_nrms]=do_error_calculation_2layers(MatchedData_obs,MatchedData_sim);
                end
                
                devia=(mean(MatchedData_sim)-mean(MatchedData_obs))/mean(MatchedData_obs);
                
                if abs(devia)>10
                    deviaS='Out of range';
                    %deviaSn=NaN;
                    deviaSn=devia*100;
                    disp(['warning here ....',num2str(devia,'%3.2f')]);
                    
                else
                    deviaS=[num2str(devia*100,'%3.2f'),'%'];
                    deviaSn=devia*100;
                end
                
                headers='\bfModel Skills:\rm';
                str{1}=headers;
                inc=2;
                for i=1:length(config.skills)
                    if config.skills(i)==1
                        switch i
                            case 1
                                str{inc}=['  R    = ',num2str(stat_r,'%1.4f')];
                                SkillNames{inc}='R';
                                SkillScores{inc}=num2str(stat_r,'%1.4f');
                                inc=inc+1;
                                
                            case 2
                                str{inc}=['  BIAS = ',deviaS];
                                SkillNames{inc}='BIAS';
                                SkillScores{inc}=deviaS;
                                inc=inc+1;
                                
                            case 3
                                str{inc}=['  MAE  = ',num2str(stat_mae,'%2.4f')];
                                SkillNames{inc}='MAE';
                                SkillScores{inc}=num2str(stat_mae,'%2.4f');
                                inc=inc+1;
                                
                            case 4
                                str{inc}=['  RMS  = ',num2str(stat_rms,'%2.4f')];
                                SkillNames{inc}='RMS';
                                SkillScores{inc}=num2str(stat_rms,'%2.4f');
                                inc=inc+1;
                                
                            case 5
                                str{inc}=['  NMAE = ',num2str(stat_nmae*100,'%2.2f'),'%'];
                                SkillNames{inc}='NMAE';
                                SkillScores{inc}=[num2str(stat_nmae*100,'%2.2f'),'%'];
                                inc=inc+1;
                                
                            case 6
                                str{inc}=['  NRMS = ',num2str(stat_nrms*100,'%2.2f'),'%'];
                                SkillNames{inc}='NRMS';
                                SkillScores{inc}=[num2str(stat_nrms*100,'%2.2f'),'%'];
                                inc=inc+1;
                               
                            case 7
                                str{inc}=['  MEF  = ',num2str(stat_nash,'%2.4f')];
                                SkillNames{inc}='MEF';
                                SkillScores{inc}=num2str(stat_nash,'%2.4f');
                                inc=inc+1;
                                
                            otherwise
                                disp('Error skill option out of range');
                        end
                      
                    end
                end

                errorMatrix.(regexprep(shp(site).Name,' ','_')).(loadname).R=stat_r;
                errorMatrix.(regexprep(shp(site).Name,' ','_')).(loadname).BIAS=deviaSn;
                errorMatrix.(regexprep(shp(site).Name,' ','_')).(loadname).MAE=stat_mae;
                errorMatrix.(regexprep(shp(site).Name,' ','_')).(loadname).RMS=stat_rms;
                errorMatrix.(regexprep(shp(site).Name,' ','_')).(loadname).NMAE=stat_nmae;
                errorMatrix.(regexprep(shp(site).Name,' ','_')).(loadname).NRMS=stat_nrms;
                errorMatrix.(regexprep(shp(site).Name,' ','_')).(loadname).MEF=stat_nash;
               % clear str stat*;
            else
                errorMatrix.(regexprep(shp(site).Name,' ','_')).(loadname).R=NaN;
                errorMatrix.(regexprep(shp(site).Name,' ','_')).(loadname).BIAS=NaN;
                errorMatrix.(regexprep(shp(site).Name,' ','_')).(loadname).MAE=NaN;
                errorMatrix.(regexprep(shp(site).Name,' ','_')).(loadname).RMS=NaN;
                errorMatrix.(regexprep(shp(site).Name,' ','_')).(loadname).NMAE=NaN;
                errorMatrix.(regexprep(shp(site).Name,' ','_')).(loadname).NRMS=NaN;
                errorMatrix.(regexprep(shp(site).Name,' ','_')).(loadname).MEF=NaN;
            end
            T = table(SkillNames',SkillScores','VariableNames',{'Skils','Scores'}); 
   end
        
   