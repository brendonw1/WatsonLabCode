function SpikingAnalysis_SaveOldSpikingData(basename)


[mo,yr] = GetCurrentMonthYearString;
foldername = ['SpikingData_Pre' mo yr];

if exist ('SpikingData_PreNov2014')
    ! mv SpikingData_PreNov2014 SpikingData_PreDec2014
end
if exist ('SpkResFetClu_PreNov2014')
    ! mv SpkResFetClu_PreNov2014 SpikingData_PreDec2014
end
if exist ('SpkResFetClus_PreNov2014')
    ! mv SpkResFetClus_PreNov2014 SpikingData_PreDec2014
end

%Get names of res/fet/clu/spks
if ~exist(foldername,'dir')
    NamesCell = GetResFetCluSpkNames(cd);
else
    NamesCell = {};
end

%Write names of files that should/may be there
PossibleNames = {...
    [basename '_SAll.mat']...
    [basename '_SSubtypes.mat']...
    [basename '_SStable.mat']...
    [basename '_SBurstFiltered.mat']...
    [basename '_CellClassificationOutput.mat']...
    [basename '_CellIDs.mat']...
    [basename '_CellRateVariables.mat']...
    [basename '_CellRateVariablesByMotionBool.mat']...
    [basename '_CellRateVariablesByNoMotion.mat']...
    [basename '_CellRateVariablesByYesMotion.mat']...
    [basename '_ClusterQualityMeasures.mat']...
    [basename '_funcsynapses.mat']...
    [basename '_funcsynapses_preBF.mat']...
    [basename '_SpikePETHs.mat']...
    [basename '_StateEditorOverlay_CombinedAllSpikes.mat']...
    [basename '_StateEditorOverlay_CombinedEAllSpikes.mat']...
    [basename '_StateEditorOverlay_CombinedI+E+AllSpikes.mat']...
    [basename '_StateEditorOverlay_CombinedIAllSpikes.mat']...
    [basename '_TransferStrengthsOverSleep_NormByRateChg.mat']...
    [basename '_TransferStrengthsOverSleep_NormByRatio.mat']...
    [basename '_TransferStrengthsOverSleep_Raw.mat']...
    [basename '_UPDOWNIntervals.mat']...
    'CellClassificationFigs'...
    'CellQualityFigs'...
    'CellRateDistributionFigs'...
    'ConnectionFigs'...
    'ConnectionFigs_preBF'...
    'RawSpikeRateFigs'...
    'TransferStrengthsOverSleepFigs'...
    'ZeroLagAndWideFigs'...
    'ZeroLagAndWideFigs_preBF'...
    [basename '.m']};

% Check to see which of above are present now and save them
FileNames = {};
for a = 1:length(PossibleNames)
    thisname = PossibleNames{a};
    if exist(thisname,'file') | exist(thisname,'dir') 
        FileNames{end+1} = thisname;
    end
end

% Combine Res/Fet/Clu/Spk with Other names of files to move
FileNames = cat(2,NamesCell,FileNames);

% Move those files to a new subdirectory
MakeDirMoveFilesThere(fullfile(cd,foldername),FileNames)

headeridx = strmatch([basename '.m'],FileNames);
if ~isempty(headeridx)
    copyfile(fullfile(cd,foldername,[basename 'm']),cd)
end


function [mo,yr] = GetCurrentMonthYearString

[Y, M, D, H, MN, S] = datevec(date);

switch M
    case 1
        mo = 'Jan';
    case 2
        mo = 'Feb';
    case 3
        mo = 'Mar';
    case 4
        mo = 'Apr';
    case 5
        mo = 'May';
    case 6
        mo = 'Jun';
    case 7
        mo = 'Jul';
    case 8
        mo = 'Aug';
    case 9
        mo = 'Sep';
    case 10
        mo = 'Oct';
    case 11
        mo = 'Nov';
    case 12
        mo = 'Dec';
end
 
yr = num2str(Y);