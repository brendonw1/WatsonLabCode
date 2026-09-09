function [PhaseDeviationOutputs,Params] = humanREMinfraslow_PhaseDeviation(InfraslowPhasePref,varargin)
%
% [PhaseDeviationOutputs,Params] = humanREMinfraslow_PhaseDeviation(InfraslowPhasePref)
%
% Calculates the phase deviation of each participant or analysis unit from
% a group-level reference phase. This metric can be used to quantify
% individual differences in the phase alignment between discrete events,
% such as rapid eye movements, and continuous infraslow fluctuations.
%
% [PhaseDeviationOutputs,Params] = humanREMinfraslow_PhaseDeviation(InfraslowPhasePref,Name,Value)
%
% Specifies optional parameters using name-value arguments.
%
% INPUTS:
%   InfraslowPhasePref
%     Cell vector containing timestamped phase values in radians.
%     Each cell should contain the phase values from one participant or
%     analysis unit. These values may be obtained per participant using
%     humanREM_InfraslowQuantif.
%
% NAME-VALUE ARGUMENTS:
%   'PhaseDeviationReferenceMethod'
%                          Method used to calculate the group-level
%                          reference phase:
%
%                          'pooled' calculates the circular mean after
%                          pooling all phase values across participants.
%                          Participants with more timestamps therefore
%                          contribute more values to the reference phase.
%
%                          'participant' first calculates the circular mean
%                          for each participant and then calculates the
%                          circular mean across participants. Each
%                          participant therefore contributes equally.
%
%                          Default: 'pooled'
%
% OUTPUTS:
%   PhaseDeviationOutputs
%     Table containing:
%       mean_phase
%           Vector containing the circular mean phase for each participant
%           or analysis unit, in radians.
%
%       phase_deviation
%           Vector containing the signed circular difference between each
%           mean phase and the group-level reference phase, in radians.
%           Values are wrapped to the range -pi to pi.
%
%       reference_phase
%           Scalar containing the group-level reference phase in radians.
%
%   Params
%     Optional structure containing the parameters used.
%
% Lezio S. Bueno-Junior, Brendon O. Watson (2026-7), University of Michigan

%% Parse inputs
p = inputParser;

addParameter(p,'PhaseDeviationReferenceMethod','pooled',...
    @(x) ischar(x) || (isstring(x) && isscalar(x)));

parse(p,varargin{:})

PhaseDeviationReferenceMethod = validatestring(...
    p.Results.PhaseDeviationReferenceMethod,...
    {'pooled','participant'});



%% Orient and validate the phase-preference cell vector
if ~iscell(InfraslowPhasePref) || ~isvector(InfraslowPhasePref) ||...
        isempty(InfraslowPhasePref)
    error('InfraslowPhasePref must be a nonempty cell vector.')
end

InfraslowPhasePref = InfraslowPhasePref(:);

for CellIdx = 1:numel(InfraslowPhasePref)

    TempPhase = InfraslowPhasePref{CellIdx};

    if ~isnumeric(TempPhase) ||...
            ~(isvector(TempPhase) || isempty(TempPhase)) ||...
            ~isreal(TempPhase) || any(~isfinite(TempPhase))
        error(['Each cell in InfraslowPhasePref must contain a numeric ',...
            'vector of finite phase values or an empty numeric vector.'])
    end

    InfraslowPhasePref{CellIdx} = TempPhase(:);
end



%% Calculate circular mean phase for each participant or analysis unit
NumPhaseGroups = numel(InfraslowPhasePref);
MeanPhase      = NaN(NumPhaseGroups,1);
NumPhaseValues = zeros(NumPhaseGroups,1);

for GroupIdx = 1:NumPhaseGroups

    TempPhase = InfraslowPhasePref{GroupIdx};
    NumPhaseValues(GroupIdx) = numel(TempPhase);

    if ~isempty(TempPhase)
        MeanPhase(GroupIdx) = angle(mean(exp(1i*TempPhase)));
    end
end



%% Calculate group-level reference phase
switch PhaseDeviationReferenceMethod

    case 'pooled'

        % Pool all phase values before calculating the circular mean. This
        % preserves the original analysis, in which participants with more
        % timestamps contribute more values to the reference phase.
        AllPhaseValues = vertcat(InfraslowPhasePref{:});

        ReferencePhase = angle(mean(exp(1i*AllPhaseValues)));

    case 'participant'

        % Calculate the circular mean across participant-level mean phases.
        % This gives each participant with available phase values equal
        % weight in the group-level reference phase.
        AvailableMeanPhase = MeanPhase(~isnan(MeanPhase));

        ReferencePhase = angle(mean(exp(1i*AvailableMeanPhase)));
end



%% Calculate signed phase deviation from the group-level reference phase
% The circular difference is wrapped to -pi to pi.
PhaseDeviation = angle(exp(1i*(MeanPhase-ReferencePhase)));



%% Output table, can be combined with outputs from other functions
PhaseDeviationOutputs = cell2table(...
    [{MeanPhase} {PhaseDeviation} {ReferencePhase}],...
    'VariableNames',{'mean_phase','phase_deviation','reference_phase'});



%% Parameters used, optionally returned for traceability
Params.PhaseDeviationReferenceMethod = PhaseDeviationReferenceMethod;
Params.PhaseDeviationReferenceRad    = ReferencePhase;
Params.PhaseDeviationNumGroups       = NumPhaseGroups;
Params.PhaseDeviationNumValues       = NumPhaseValues;

end