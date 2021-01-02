function [copyableCodeString, copyableCodeLines] = FnPrintValueAsCode(value)
%FNPRINTVALUEASCODE This function attempts to print the passed-in value in a format that it could be copy and pasted back into code.
%   Detailed explanation goes here
copyableCodeString = '';
pvac_Settings.SingleLineArrays = false; % if true, array definintions are output on a single line

if ischar(value)
	currCodeLine = sprintf('''%s''', value);
	copyableCodeString = currCodeLine;
	copyableCodeLines = {currCodeLine};

elseif iscellstr(value)
	array_length = length(value);
	if array_length == 0
		currCodeLine = '{}';
		copyableCodeString = currCodeLine;
		copyableCodeLines = {currCodeLine};
	else
		% First entry:
		currCodeLine = sprintf('{''%s'',', value{1});
		if ~pvac_Settings.SingleLineArrays
			currCodeLine = sprintf('%s\n', currCodeLine);
		end

		copyableCodeString = currCodeLine;
		copyableCodeLines = {currCodeLine};
		for i = 2:array_length
			if i<array_length
				% if it isn't the last element, include the trailing comma
				currCodeLine = sprintf('\t''%s'',', value{i});
				if ~pvac_Settings.SingleLineArrays
					currCodeLine = sprintf('%s\n', currCodeLine);
				end
			else
				% IF it is the last element, include the trailing close cellarray symbol instead of the comma:
				currCodeLine = sprintf('\t''%s''}', value{i});
			end

			copyableCodeString = [copyableCodeString, currCodeLine];
			copyableCodeLines{end+1} = currCodeLine;
		end % end for array_length
	end % end if array_length == 0
else
	error(['Failed to format value ', value, '!'])
end % end if types

end

