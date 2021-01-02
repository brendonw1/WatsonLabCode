Pho Matlab Conventions:
Written 4-27-2020
The purpose of this document is to standardize the conventions used within MATLAB code to provide a more reliable, referencable, and modifable code base.


Script/Function Prefix:
	Each set of scripts/functions that share a common purpose should have an identifying prefix, similar to the MacOS Cocoa namespace conventions.
	The prefix should be specified in all lower-case characters, and prepended to any shared structure variables and types.

	Example: For the repository PhoMatlabBBVideoAnalyzer, the prefix is "bbva". The structures shared within in them are named "bbvaSettings", "bbvaVideoFile"

Function Input Settings:

Functions often need to be passed a large number of user-configurable runtime parameters, and listing them all as optional parameters is undesirable due to the MATLAB line-length issues.
To work around this, a MATLAB structure object will be used. Ease of implementation, and the lack of need of another file in the project, make this better than writting a custom class to hold the settings.
The disadvantage is that it's difficult to document these structure objects as fields can be added dynamically in MATLAB. This creates ordering dependencies in the code (the field must be set before it is referenced) and makes it difficult to reuse/repurpose code.
To work around this, a "struct description" will be added as a comment in the function, explaining the contents of the struct and enumerating all of its fields.

Types of Structure Fields:
	Computed Fields are fields that will be created or overwritten by the software, and user-specification of them in the input will not have any affect on program operation.
	The most common example of a computed field is a full_path field, constructed by something of the form of: full_path_field = fullfile(parent_path_field, input_name_field);

	User-Provided Field:
		Indicated by a field description line starting with '%-'
			%- field_name - field description
	
	Computed Field:
		Indicated by a field description line starting with '%='
		A computed field is guaranteed to be accessible after program execution, but not prior to that.
			%= field_name - field description

	
Real-world Examples:
	%%%+S- pca_exportSettings
		%- should_export_image_to_disk - if true, saves the processed result to disk
		%- curr_fig_export_path -
		%= curr_output_name - constructed from the actual frame index
		%= curr_output_path - 
	%


	%%%+S- curr_output_bbvaSettings
		%- video_frame_string - video_frame_string is string containing the current frames processed in this segment
		%- final_output_path - final_output_path is the final path of the actigrpahy output file produced by this script
		%- final_output_name - final_output_name is the final name of the actigrpahy output file produced by this script
	%


	%%%+S- bbvaVideoFile
		%- filename* - filename is the filename with extension
		%- relative_file_path - relative_file_path is a 
		%- basename - basename is a 
		%- extension - extension is a 
		%- full_parent_path - full_parent_path is a 
		%= full_path - full_path is a 
		%- boxID - boxID is a 
		%- parsedDateTime - parsedDateTime is a 
		%- FrameRate - FrameRate is a 
		%- DurationSeconds - DurationSeconds is a 
		%- parsedEndDateTime - parsedEndDateTime is a 
		%- startFrameIndex - startFrameIndex is a 
		%- endFrameIndex - endFrameIndex is a 
		%- frameIndexes - frameIndexes is a 
		%- frameTimestamps - frameTimestamps is a 
		%- FIELDNAME - FIELDNAME is a 
	%


Change Log:

// July 02, 2020: Changing the convention for user-entered vs. computed fields. "The astrisk (*) after the field indicates that it's not a computed quanity." to "
