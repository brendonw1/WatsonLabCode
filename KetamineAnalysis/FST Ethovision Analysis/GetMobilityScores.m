% Per Jonathan Dale @ Noldus
% Mobility = AreaChange / (Area in previous sample + Area in current sample)
% AreaChange is column 6
% Area is column 5
% Now add mobility as column 12 to each array
% Also save as separate thing

lengthMobilityVectors = 5000;
lengthOKMobilityVectors = 3000;

load('allraw.mat')

stressnames = {'nostress','mildstress','ucsstress'};
dosenames = {'veh','ket10','ket30'};
for sn = 1:length(stressnames)
    for dn = 1:length(dosenames)
        eval(['Mobilities.' stressnames{sn} '.' dosenames{dn} ' = [];'])
        eval(['MobilitiesMins2to6.' stressnames{sn} '.' dosenames{dn} ' = [];'])
        
        eval(['AnimalNames = fieldnames(allraw.' stressnames{sn} '.' dosenames{dn} ');'])
        for an = 1:length(AnimalNames)
            eval(['temp = allraw.' stressnames{sn} '.' dosenames{dn} '.' AnimalNames{an} ';'])
            CurrentAreaChange = temp(2:end,6);
            CurrentArea = temp(2:end,5);
            PreviousArea = temp(1:end-1,5);
            Mobility = CurrentAreaChange ./ (CurrentArea + PreviousArea);
            Mobility = cat(1,nan,Mobility);
            Mobility(Mobility>0.99) = nan;%this basically results from errors
            temp = cat(2,temp,Mobility);

            eval(['AllRawWMobility.' stressnames{sn} '.' dosenames{dn} '.' AnimalNames{an} '= temp;'])

            catmobility = cat(1,Mobility,nan(lengthMobilityVectors-length(Mobility),1));%make all even length (=lengthMobilityVectors)
            eval(['Mobilities.' stressnames{sn} '.' dosenames{dn} ' = cat(2,Mobilities.' stressnames{sn} '.' dosenames{dn} ',catmobility);'])
            
            % just extract minutes 2-6
            Times = temp(:,2);
            okidxs = Times>=120 & Times<360;
            okmobility = temp(okidxs,end);
            if length(okmobility)<lengthOKMobilityVectors
                okmobility = cat(1,okmobility,nan(lengthOKMobilityVectors-length(okmobility),1));%make all even length (=lengthOKMobilityVectors)
            end
            eval(['MobilitiesMins2to6.' stressnames{sn} '.' dosenames{dn} ' = cat(2,MobilitiesMins2to6.' stressnames{sn} '.' dosenames{dn} ',okmobility);'])

        end
%         eval(['Mobilities.' stressnames{sn} '.' dosenames{dn} ' = Mobilities.' stressnames{sn} '.' dosenames{dn} '(:,2:end);'])
    end
end

save('AllRawWMobility','AllRawWMobility')
save('Mobilities','Mobilities')
save('MobilitiesMins2to6','MobilitiesMins2to6')


% 
% 
% temp = allraw.nostress.veh.Animal1;
% 
% 
% CurrentAreaChange = temp(2:end,6);
% CurrentArea = temp(2:end,5);
% PreviousArea = temp(1:end-1,5);
% Mobility = CurrentAreaChange ./ (CurrentArea + PreviousArea);
% Mobility = cat(1,nan,Mobility);
% temp = cat(2,temp,Mobility);
% 
% AllRawWMobility.nostess.veh.Animal1 = temp;
% 
% Mobilities.nostress.veh = cat(2,Mobilities.nostress.veh,Mobility);
