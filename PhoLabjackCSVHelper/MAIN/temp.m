current_bbIDs = {'02','04','06','09','12','14','15','16'};

%% Gather data from all boxes
CSVOutputDirectoryPath = BuildAllCombinedCSVs(current_bbIDs);

%% Process and plot for each box
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
			thisfilepath = fullfile(DigitalOutputDir,d(a).name);
			[~,~,~,CompressedFilePath] = ProcessConcatenatedCSV(thisfilepath);
			fighandles{BBCounter} = PlotCompressedCSVs(CompressedFilePath);
			
			thisBB = current_bbIDs{BBCounter};
			thisfigname = ['BB' thisBB '_DigitalData'];
			saveas(fighandles{BBCounter},fullfile(FigureSavePath,thisfigname),'fig')
			saveas(fighandles{BBCounter},fullfile(FigureSavePath,thisfigname),'png')
		end
	end
end

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
