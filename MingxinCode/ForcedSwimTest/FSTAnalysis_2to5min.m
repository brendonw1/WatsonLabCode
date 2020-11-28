function FSTAnalysis_2to5min(dates)
path = cd;
Namesdir = dir(path);
FSTData2to5 = zeros(8, length(dates(:,1)), 3);

k=0;
for i = 1:length(Namesdir)
    name = Namesdir(i).name;
    k=k+1;
    for j = 1:length(dates(:,1))
        sppath = strcat(name, '_', dates(j,:));
        if exist(sppath,'dir')
            filenamedir = dir(fullfile(path,name, sppath,'*FSTScoring.mat'));
            filename = filenamedir.name;
            load(filename, 'RawChunkBehavVals');
            firstchunk = find(~isnan(RawChunkBehavVals),1,'first');
            lastchunk = firstchunk+60-1;
            UsedChunks = RawChunkBehavVals(firstchunk+12:lastchunk);
            for a = 1:3;
                FSTData2to5(k,j,a) = sum(UsedChunks==a-1);
            end
        else
            k=k-1;
            break
        end
    end
end

save('FSTData_2to5min.mat', 'FSTData2to5');
% mkdir('fig');
% 
% TitleBehav = ['Immobile';'Swimming';'Climbing'];
% for i = 1:3
%     for j = 1:length(FSTData2to5(1,:,1))
%         for k = 1:length(FSTData2to5(:,1,1))
%             if j==1
%                 ByBehav(j,k) = FSTData2to5(k,j,i)/180;
%             else
%                 ByBehav(j,k) = FSTData2to5(k,j,i)/60;
%             end
%             NormBehavP(j,k) = ByBehav(j,k)/ByBehav(1,k);
%             FigLegends(k,:) = ['Animal ' num2str(k)];
%         end
%         ByBehav(j,9) = mean(ByBehav(j,1:8));
%         NormBehavP(j,9) = ByBehav(j,9)/ByBehav(1,9);
%         FigLegends(9,:) = 'Mean    ';
%     end
%     figure; p = plot(ByBehav);
%     p(9).LineWidth = 2;
%     p(9).LineStyle = '--';
%     p(9).Marker = 'o';
%     title(TitleBehav(i,:));
%     legend(FigLegends(1:9,:));
%     print(fullfile('fig',TitleBehav(i,:)),'-dpng','-r0');
%     
%     figure; pn = plot(log(NormBehavP));
%     pn(9).LineWidth = 2;
%     pn(9).LineStyle = '--';
%     pn(9).Marker = 'o';
%     title([TitleBehav(i,:) '(Normalized by Pretest)']);
%     legend(FigLegends(1:9,:));
%     print(fullfile('fig',[TitleBehav(i,:) '(NormalizedByPretest)']),'-dpng','-r0');
%     
%     
%     for j = 1:length(FSTData2to5(1,:,1))
%         for k = 1:(length(FSTData2to5(:,1,1))+1)
%             NormBehav1(j,k) = ByBehav(j,k)/ByBehav(2,k);
%         end
%     end
%     figure; pn1 = plot(log(NormBehav1));
%     pn1(9).LineWidth = 2;
%     pn1(9).LineStyle = '--';
%     pn1(9).Marker = 'o';
%     title([TitleBehav(i,:) '(Normalized by 1st Test)']);
%     legend(FigLegends(1:9,:));
%     print(fullfile('fig',[TitleBehav(i,:) '(NormalizedBy1stTest)']),'-dpng','-r0');
% end
% 
% end


