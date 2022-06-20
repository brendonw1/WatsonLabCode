%Combine Sleep States
wholeset = {REMBoutDat112,REMBoutDat210,REMBoutDat413,REMBoutDatBeast,REMBoutDatCyclops,REMBoutDatMoriarty,REMBoutDatProfessorX,REMBoutDatQuiksilver,REMBoutDatTHRASH,REMBoutDatWolverine};
names = {'rat112','rat210','rat413','Beast','Cyclops','Moriarty','ProfessorX','Quiksilver','THRASH','Wolverine'};
allremhourbouts = {};
allinterremhours = {};

allInter = [];
allREM = [];

for i = 1:length(wholeset)
    allremhourbouts = cellapp(allremhourbouts, {wholeset{i}.remhourbouts});
    allinterremhours = cellapp(allremhourbouts,{wholeset{i}.reminterhours});
    allInter = vertapp(allInter, wholeset{i}(1).interrems);
    allREM = vertapp(allREM, wholeset{i}(1).rembouts);
end

tabInter = array2table(allInter);
tabInter.Properties.VariableNames = names;
tabREM = array2table(allREM);
tabREM.Properties.VariableNames = names;
writetable(tabInter,'AllRatsInterREMs.csv');
writetable(tabREM,'AllRatsREMBouts.csv');

figure;
bar(cell2mat(cellmean(allremhourbouts)),'Facealpha',.5);
hold on;
bar(cell2mat(cellmean(allinterremhours)),'Facealpha',.5);
legend('Mean REM Hour Bouts','Mean InterREM Bouts');
title('Average REM and InterREM Bouts for All Animals Binned Hourly');
xlabel('Hour')
ylabel('Seconds')



function [set] = vertapp(hana,dul)
    if length(hana) >= length(dul)
        set = hana;
        temp = zeros(length(hana),1);
        for i = 1:length(dul)
            temp(i) = dul(i);
        end
        set = [hana temp];
    elseif isempty(hana)
         set = dul;
    else
        hansize = size(hana);
        temp = zeros(length(dul),hansize(2));
        for i = 1:hansize(1)
            temp(i,:) = hana(i,:);
        end
        set = vertapp(temp,dul);
    end
end

function [set] = cellmean(hana)
    set = hana;
    for i = 1:length(hana)
        set{i} = mean(hana{i});
    end
end


function [set] = cellapp(hana,dul)
    
    if length(hana) > length(dul)
        set = hana;
        for j = 1:length(dul)
            set{j} = [hana{j}; dul{j}];
        end
    else
        set = dul;
        for j = 1:length(hana)
            set{j} = [hana{j}; dul{j}];
        end 
    end
end

function [set] = begsum(hana, dul)
    if length(hana) > length(dul)
        set = hana;
        for i = 1:length(dul)
            set(i) = set(i) + dul(i);
        end
    else
        set = dul;
        for i = 1:length(hana)
            set(i) = set(i) + hana(i);
        end
    end
end