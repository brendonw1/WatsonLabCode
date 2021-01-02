classdef UserAnnotation
    %UserAnnotation A user-created annotation for a video file
    %   Has a specified FrameNumber
    % Doesn't include an explicit annotation type to save memory.
	% Base class for 
    
    properties
        FrameNumber
        CreationDateTime
        ModifiedDateTime
        CreatingUser
        Comment
    end
    
    methods
        function obj = UserAnnotation(frameNumber, comment, creatingUser, creationDatetime, modifiedDatetime)
            %UserAnnotation Construct an instance of this class
            %   Detailed explanation goes here
            
            if ~exist('creationDatetime','var')
                creationDatetime = datetime('today');
            end
            
            if ~exist('creatingUser','var')
                creatingUser = 'Unknown';
            end
            
            if ~exist('comment','var')
                comment = '';
            end    
            
            if ~exist('modifiedDatetime','var')
                modifiedDatetime = creationDatetime;
            end   
            
            obj.CreatingUser = creatingUser;
            obj.CreationDateTime = creationDatetime;
            obj.ModifiedDateTime = modifiedDatetime;
            obj.FrameNumber = frameNumber;
            obj.Comment = comment;
            
        end
        
        function obj = modifyComment(obj, comment)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.Comment = comment;
            obj.ModifiedDateTime = datetime('today');
        end
        
    end
end

