function GatherCurrentLabjackData(current_bbIDs,dataPath,CSVOutputDirectoryPath,CurrentExpt,CurrentCohort)
%Gathers data from .csv files that were made by labjack and stored in
%Overseer.  Finds times of value changes in each value ("Deltas") and the
%timestamps of thsoe and saves them in .mat format.  Then plots
% 
% Note: Limited now to only "digital" data from csvs - ie no analog runningwheel
% data
% Ideas to add: 
%    - Plot only most recent week - possibly by hour
%    - Running wheel data: gather and save
%    - 24hr rhthyms: Gather data hourly, then average each 24hrs, bar plot 
%
% 2020, Pho Hale, Brendon Watson


%% Preferences:
makenewcombinedcsv = false;
% newcombinedcsv = true;

makefigs = true;
% makefigs = false;

%% which computer are we in
isbalrog = false;
if isunix
    [~,name] = system('hostname');
    if strcmp(name(1:6),'balrog')
        isbalrog = true;
    end
end

%% making sure we have all variables
if ~exist('current_bbIDs','var')
	current_bbIDs = {'02','04','06','09','12','14','15','16'};
end

if ~exist('dataPath','var')
    if isbalrog
        dataPath = '/overseer/FDrive/EventData/BB';
    else
        dataPath = 'F:\EventData\BB';
    end
end

if ~exist('CSVOutputDirectoryPath','var')
    if isbalrog
        CSVOutputDirectoryPath = '/data/DigitalBox/ConcatenatedEventDataCSVs';
    else
        CSVOutputDirectoryPath = '/data/DigitalBox/ConcatenatedEventDataCSVs';
    end
end

if ~exist('CurrentExpt')
	CurrentExpt = '01';
end
if ~exist('CurrentCohort')
	CurrentCohort = '00';
end


%% Gather data from all boxes
if makenewcombinedcsv
    CSVOutputDirectoryPath = BuildAllCombinedCSVs(current_bbIDs,dataPath,CSVOutputDirectoryPath,CurrentExpt,CurrentCohort);
end

%% Import Lookup table for DIOs to food/water type
try
    dispenserLUT = GetGoogleSpreadsheet_NoCookies('1kSJgVS7loS6y1TLcr0y7l9IybzDgWw24hRPaCn2RNBM');
catch
    warning('Could not load LUT from webpage')
    load('/data/DigitalBox/DispenserLUTDec2020.mat')%works on my mac, can download and save
end
%% Import times when people in room:
try %pending some troubleshooting 12/28/2020... this works on mac and pc but not linux (?)
    [RoomEntryIns,RoomEntryOuts] = ReadBoxRoomEntry;
catch
    warning('Could not load RoomEntries from webpage')
    load('/data/DigitalBox/InsOutsDec2020.mat')%works on my mac, can download and save
end

%% Process each box
%Get names of files in Digital Output Directory
DigitalOutputDir = fullfile(CSVOutputDirectoryPath,'Digital');
FigureSavePath = fullfile(CSVOutputDirectoryPath,'DigitalDataFigures',string(yyyymmdd(datetime('today'))));
if ~exist(FigureSavePath,'dir')
	mkdir(FigureSavePath)
end
d = dir(DigitalOutputDir);
BBCounter = 0;
for a = 1:length(d)
	if ~d(a).isdir
		if strcmp('.csv',d(a).name(end-3:end))
			BBCounter = BBCounter+1;
			Data(BBCounter).BBName = current_bbIDs{BBCounter};
			thiscsvfilepath = fullfile(DigitalOutputDir,d(a).name);
			[Data(BBCounter).DeltaIdxs,...
                Data(BBCounter).DeltaTimestamps,...
                Data(BBCounter).labjackData] = ExtractDataFromCSVs(thiscsvfilepath);
                        
%           %Change names to match dispenser types
            Data(BBCounter) = RenameDIOsFromLUT(Data(BBCounter),dispenserLUT);
%             
%           %Exclude times of room entry from all fields from all fields
            Data(BBCounter) = ExcludeRoomEntryTimes(Data(BBCounter),RoomEntryIns,RoomEntryOuts);
            
            %Concatenate with previously-saved data
            %Also, could save a Pho version of just DeltaIdxs and DeltaTimestamps
            %(no metadata) next to csvs (default is not to do this).
            shouldsave = false;
            [Data(BBCounter).DeltaIdxs, Data(BBCounter).DeltaTimestamps, Data(BBCounter).DeltasFilePath] = ConcatenateAndSaveDeltas(Data(BBCounter).DeltaIdxs, Data(BBCounter).DeltaTimestamps, thiscsvfilepath, [], shouldsave);
		end
	end
end

%% Save
Data(1).dispenserLUT = dispenserLUT;
Data(1).RoomEntryIns = RoomEntryIns;
Data(1).RoomEntryOuts = RoomEntryOuts;

LabJackData = Data;
savepath = '/data/DigitalBox/LabJackData.mat';
save(savepath,'LabJackData')

%% Make figures
if makefigs
    %set up directory to save into
    thisfigdir = fullfile(filesep,'data','DigitalBox','DigitalBoxFigures',['Experiment' CurrentExpt 'Cohort' CurrentCohort '_' datestr(now,'YYYY-mm-DD')]);
    if ~exist(thisfigdir,'dir')
        mkdir(thisfigdir);
    end
    
    fighandles_BBDispense = PlotLabjackData_BBVsDispense(LabJackData,'daily');
    savefigsasindir(thisfigdir,fighandles_BBDispense,'fig');
    savefigsasindir(thisfigdir,fighandles_BBDispense,'png');
    
    fighandles_CompareDispenses = PlotLabjackData_CompareDispenses(LabJackData,'daily');
    savefigsasindir(thisfigdir,fighandles_CompareDispenses,'fig');
    savefigsasindir(thisfigdir,fighandles_CompareDispenses,'png');
    
    %might add
    % just plot the most recent week
    % ?
    
end


%
% 
% BBCounter = 0;
% for a = 1:length(d)
% 	if ~d(a).isdir
% 		if strcmp('.csv',d(a).name(end-3:end))
% 			BBCounter = BBCounter+1;
%             fighandles{BBCounter} = PlotCompressedCSVs(Data(BBCounter).CompressedFilePath);
% 			
% 			thisBB = current_bbIDs{BBCounter};
% 			thisfigname = ['BB' thisBB '_DigitalData'];
% 			saveas(fighandles{BBCounter},fullfile(FigureSavePath,thisfigname),'fig')
% 			saveas(fighandles{BBCounter},fullfile(FigureSavePath,thisfigname),'png')
%         end
%     end
% end

% 		
% 
% filename{1} = 'C:\Users\watsonlab\source\repos\PhoLabjackCSVHelper\MAIN\Data\Digital\out_file_BB02_1598296493807_1_Combined.csv';
% filename{2} = [];
% filename{3} = 'C:\Users\watsonlab\source\repos\PhoLabjackCSVHelper\MAIN\Data\Digital\out_file_BB06_1598059329294-1600895997165_4_Combined.csv';
% filename{4} = 'C:\Users\watsonlab\source\repos\PhoLabjackCSVHelper\MAIN\Data\Digital\out_file_BB09_1598296810180-1600897908534_3_Combined.csv';
% filename{5} = 'C:\Users\watsonlab\source\repos\PhoLabjackCSVHelper\MAIN\Data\Digital\out_file_BB12_1598059646033-1600213609188_4_Combined.csv';
% filename{6} = 'C:\Users\watsonlab\source\repos\PhoLabjackCSVHelper\MAIN\Data\Digital\out_file_BB14_1598059828780-1598296883865_2_Combined.csv';
% filename{7} = 'C:\Users\watsonlab\source\repos\PhoLabjackCSVHelper\MAIN\Data\Digital\out_file_BB15_1598297036142-1601155374007_2_Combined.csv';
% filename{8} = 'C:\Users\watsonlab\source\repos\PhoLabjackCSVHelper\MAIN\Data\Digital\out_file_BB16_1598048565842-1601417013026_3_Combined.csv';
% 
% for a = 1:length(filename)
% 	if ~isempty(filename{a})
% 		[~,~,~,outputFullpath] = ProcessConcatenatedCSV(inputFilePath,dataDestinationDirectory);
% 		PlotCompressedCSVs
% 	end
% end
