function [copyableCode] = FnPrintWorkspaceVariablesAsCode(print_variable_names)
%FNPRINTWORKSPACEVARIABLESASCODE Tries to get the values of the variables with names passed in via print_variable_names from the workspace, and print the values as code.
%   Detailed explanation goes here
	num_variables = length(print_variable_names);
	for i = 1:num_variables
		varname = deblank(print_variable_names{i});
		if ischar(varname)
			currValue = evalin('base', varname);
		else
			error(['Failed to evaluate variable ', varname, ' in workspace!'])
		end
		
		% Perform the print:
% 		currValue = eval(varname);
		[copyableCodeString, copyableCodeLines] = FnPrintValueAsCode(currValue);
		currCodeString = sprintf('%s = %s;', varname, copyableCodeString);
		copyableCode{i} = currCodeString;
		disp(currCodeString);
	end % end for

end

