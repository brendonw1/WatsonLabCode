% function ACGCCGsBySleepDiv = ACGCCGByState(basepath,basename)
% % Gets and saves CCGs, ACGs, ISIHistos for all cells across states
% % specified in basename_StateIntervals.mat (which is from
% % GatherStateIntervalSets.m)
% % Brendon Watson 2015
% if ~exist('basepath','var')
%     [~,basename,~] = fileparts(cd);
%     basepath = cd;
% end
% ISIHforBurstIndex = 2;%30ms
% 
% load(fullfile(basepath,[basename '_SStable.mat']));
% 
% 
% %% Parameters
% %Static
% CCGHalfWidthsinMs = [10 30 100 300 1000 3000];
% numHalfBins = [50 60 50 60 1000 60];%static
% SampleRate = 10000;%%Based on usual TSD object sample rate<< NEED TO GENERALIZE THIS, HAVEN'T FIGURED OUT HOW YET
% 
% %Calculated
% msBinSizes = (CCGHalfWidthsinMs./numHalfBins);
% numSampsBinSizes = msBinSizes*SampleRate/1000;
% HalfWidthInS = CCGHalfWidthsinMs/1000;
% BinSizeInS = CCGHalfWidthsinMs./numHalfBins/1000;
% numcells = length(S);
% %% Get state-wise acgs
% slnames = {'Sleep';'SWS';'REM'};
% ACGCCGsByState = v2struct(slnames,NumWS,CCGHalfWidthsinMs,numHalfBins);
% for sl = 1:length(slnames)
% %     for a = 1:NumSleepDiv;
% %         for b = 1:NumWS%Make combined intervalSet for this quartile across all WSEpisodes
% %             if b == 1
% %                 eval([slnames{sl} 'Ints{a} = SleepDivisions.' slnames{sl} 'Divisions{b,a};'])
% %             else
% %                 eval([slnames{sl} 'Ints{a} = cat(' slnames{sl} 'Ints{a},SleepDivisions.' slnames{sl} 'Divisions{b,a});'])
% %             end
% %         end
%         eval(['thisInt = ' slnames{sl} 'Ints{a};'])
%         thisS = Restrict(S,thisInt);
%         [T,G] = oneSeries(thisS);
%         T = TimePoints(T);
%         if isempty(T)% if no spikes in interval:
%             for b = 1:length(CCGHalfWidthsinMs)
%                 Times{b} = linspace(-CCGHalfWidthsinMs(b),CCGHalfWidthsinMs(b),numHalfBins(b)*2+1);
%                 CCGs{b} = nan(length(Times{b}),numcells,numcells);
%                 ACGs{b} = nan(1+2*numHalfBins(b),numcells);
%                 ISIH{b} = nan(1+numHalfBins(b),numcells);
%                 ISIHTimes{b} = (-HalfWidthInS(b)/2 : HalfWidthInS(b) : HalfWidthInS(b)+BinSizeInS(b)/2)*1000;
%             end
%             BurstIndex(a,:) = nan(1,numcells);
%             BurstMaxPoint(a,:) = nan(1,numcells);
%             for b = 1:size(BurstMaxPoint,2)
%                 BurstDecay.decaytime{a,b} = nan;
%                 BurstDecay.decayvals{a,b} = nan;
%                 BurstDecay.ConstantVal(a,b) = nan;
%                 BurstDecay.ExponentVal(a,b) = nan; 
%                 BurstDecay.ConstantCI(a,b,:) = nan(1,1,2);
%                 BurstDecay.ExponentCI(a,b,:) = nan(1,1,2);
%             end
%         else
% !!!
%             for b = 1:length(CCGHalfWidthsinMs)%for each size of correlogram
%                 [CCGs{a,b}, Times{b}] = CCG_noPairs(T, G, numSampsBinSizes(b), numHalfBins(b), SampleRate, unique(G), 'count'); %calc cross correlograms, output as counts... 3D output array
%                 if length(unique(G))<size(S,1)%account for a cell not firing in a state
%                     missing = setdiff(1:length(S),unique(G));%find the missing cells
%                     CCGs{b} = fillinmissingccg(CCGs{a,b},missing);
%                 end
%                 for c = 1:size(CCGs{b},2)
%                     ACGs{b}(:,c) = CCGs{b}(:,c,c); 
%                 end
%                 [ISIH{b},ISIHTimes{b}] = ISIHistogram(thisS,HalfWidthInS(b),BinSizeInS(b));
%                 ISIH{b} = ISIH{a,b}'*1000;
%             end
%             if size(ACGs{b},2) ~= size(ISIH{b},2)
%                 1;
%             end
%             
%             %% Some Burst metrics
% %             BurstIndex4(a,:) = BurstIndex_TsdArray(thisS,0.004);
% %             BurstIndex10(a,:) = BurstIndex_TsdArray(thisS,0.010);
%             BurstIndex15(a,:) = BurstIndex_TsdArray(thisS,0.015);
% %             BurstIndex20(a,:) = BurstIndex_TsdArray(thisS,0.020);
%             BurstMaxPoint(a,:) = MaxACGTimePoint(ISIH{a,ISIHforBurstIndex},ISIHTimes{ISIHforBurstIndex});%use 30ms ISIH
%             warning off
%             for b = 1:size(BurstMaxPoint,2)
%                 [~,midx] = min(abs(BurstMaxPoint(a,1)-ISIHTimes{4}));
%                 BurstDecay.decaytime{a,b} = ISIHTimes{4}(midx:end)';
%                 BurstDecay.decayvals{a,b} = ISIH{a,4}(midx:end,b);
%                 [BurstDecay.ConstantVal(a,b),BurstDecay.ExponentVal(a,b),BurstDecay.ConstantCI(a,b,:),BurstDecay.ExponentCI(a,b,:)] =...
%                     fitexponential(BurstDecay.decaytime{a,b},BurstDecay.decayvals{a,b});
%             end
%             warning on
%         end
%     end
% %     eval(['ACGCCGsBySleepDiv.' slnames{sl} 'CCGs = CCGs;'])
%     eval(['ACGCCGsBySleepDiv.' slnames{sl} 'ACGs = ACGs;'])
%     eval(['ACGCCGsBySleepDiv.' slnames{sl} 'ISIHs = ISIH;'])
% %     eval(['ACGCCGsBySleepDiv.' slnames{sl} 'BurstIndex4 = BurstIndex4;'])
% %     eval(['ACGCCGsBySleepDiv.' slnames{sl} 'BurstIndex10 = BurstIndex10;'])
%     eval(['ACGCCGsBySleepDiv.' slnames{sl} 'BurstIndex15 = BurstIndex15;'])
% %     eval(['ACGCCGsBySleepDiv.' slnames{sl} 'BurstIndex20 = BurstIndex20;'])
%     eval(['ACGCCGsBySleepDiv.' slnames{sl} 'BurstMaxPoint = BurstMaxPoint;'])
%     eval(['ACGCCGsBySleepDiv.' slnames{sl} 'BurstDecay = BurstDecay;'])
%     clear CCGs ACGs ISIH BurstIndex BurstMaxPoint BurstDecay
% end
% ACGCCGsBySleepDiv.SleepInts = SleepInts;
% ACGCCGsBySleepDiv.SWSInts = SWSInts;
% ACGCCGsBySleepDiv.REMInts = REMInts;
% ACGCCGsBySleepDiv.Times = Times;
% ACGCCGsBySleepDiv.ISIHTimes = ISIHTimes;%convert to ms to match Times
% 
% 
% save(fullfile(basepath,[basename '_ACGCCGsBySleepDiv' num2str(NumSleepDivisions) '.mat']),'ACGCCGsBySleepDiv')
% 1;
% 
% 
% 
% function incomparray = fillinmissingccg(incomparray,missing)
% %adds missing elements into incomp array, 3d array (ie output from CCG)
% 
% origins = mergemissing(1:size(incomparray,2),missing);
% 
% filler = zeros(size(incomparray,1),1,size(incomparray,2));
% o = [];
% ccgnext = 1;
% for a = 1:length(origins)
%     if origins(a) == 1;
%         o = cat(2,o,incomparray(:,ccgnext,:));
%         ccgnext = ccgnext+1;
%     elseif origins(a) == 2;
%         o = cat(2,o,filler);
%     end
%     
% end
% incomparray = o;
% 
% filler = zeros(size(incomparray,1),size(incomparray,2),1);
% o = [];
% ccgnext = 1;
% for a = 1:length(origins)
%     if origins(a) == 1;
%         o = cat(3,o,incomparray(:,:,ccgnext));
%         ccgnext = ccgnext+1;
%     elseif origins(a) == 2;
%         o = cat(3,o,filler);
%     end
% end
% incomparray = o;
% 
