function [CentralPhase,CFCstrength] = ...
    REM_CFCsummValues(ComodMap,Params,varargin)
%
% [CentralPhase,CFCstrength] = REM_CFCsummValues(ComodMap,Params,varargin)
%
% Summary values from a cross-frequency comodulation map. Values are
% obtained using a contour matrix. See also REM_CFCmapSubEpoch.
%
% USAGE
%   - ComodMap: comodulation map (amplitude frequencies in dimension 1,
%               phase frequencies in dimension 2).
%   - Params: a structure
%       - .PhaseAxis:  list of CFC phase frequencies
%       - .AmplitAxis: list of CFC amplitude frequencies
%       - .PhaseLims:  in Hz, to delimit CFC blob in relation to
%                      phase frequencies (e.g., [6 11])
%       - .AmplitLims: in Hz, to delimit CFC blob in relation to
%                      amplitude frequencies (e.g., [80 160])
%   - varargin: please see input parser section
%
% OUTPUTS
%   - CentralPhase: in Hz, phase value at the center of the CFC blob
%   - CFCstrength:  CFC value of the delimited blob
%
% Bueno-Junior et al. (2023)

%% Input parser (default parameters)
p = inputParser;

addParameter(p,'NumContLevels',20,@isnumeric) % contourf parameter
addParameter(p,'ContourMultipl',1000000,@isnumeric) % to magnify heights

parse(p,varargin{:})
NumContLevels  = p.Results.NumContLevels;
ContourMultipl = p.Results.ContourMultipl;



%% Required inputs. Throw error messages if parameters are lacking.
PhaseAxis  = Params.PhaseAxis;
AmplitAxis = Params.AmplitAxis;
PhaseLims  = Params.PhaseLims;
AmplitLims = Params.AmplitLims;



%% Delimit the blob
[~,PhaseLims(1)] = min(abs(PhaseAxis-PhaseLims(1)));
[~,PhaseLims(2)] = min(abs(PhaseAxis-PhaseLims(2)));
PhaseIdx = PhaseLims(1):PhaseLims(2);

[~,AmplitLims(1)] = min(abs(AmplitAxis-AmplitLims(1)));
[~,AmplitLims(2)] = min(abs(AmplitAxis-AmplitLims(2)));
AmplitIdx = AmplitLims(1):AmplitLims(2);



%% Contour matrix
ContourMat = contourf(ComodMap(AmplitIdx,PhaseIdx)*...
    ContourMultipl,NumContLevels); 
close % no need to plot



%% Locate highest level in the contour matrix
WhereLevels = [0 diff(ContourMat(1,:))];
WhereLevels = find(WhereLevels>ContourMultipl*0.0001);
HighestContour = sort(ContourMat(1,WhereLevels(end)+1:end));



%% Central phase axis value
CentralPhase = PhaseAxis(round(...
    mean([HighestContour(1) HighestContour(end)])+PhaseLims(1)));



%% CFC strength from the contour level itself. Revert the multiplication
% used to localize the levels.
CFCstrength = ContourMat(1,WhereLevels(end))/ContourMultipl;

end
