classdef ExplicitlyTypedUserAnnotation < UserAnnotation
    %ExplicitlyTypedUserAnnotation A user-created annotation with an
    %explicit type
    %   Has a specified FrameNumber
	% Used by UserAnnotationsManager
    
    properties
        typeName
    end
    
    methods
        function obj = ExplicitlyTypedUserAnnotation(frameNumber, comment, creatingUser, creationDatetime, modifiedDatetime, typeName)
            %ExplicitlyTypedUserAnnotation Construct an instance of this class             
            % Call superclass (UserAnnotation) constructor
            obj@UserAnnotation(frameNumber, comment, creatingUser, creationDatetime, modifiedDatetime);
            obj.typeName = typeName;
        end

    end
    methods (Static)
      % Creates an explictly typed annotation from a regular one.
      function obj = createExplicitlyTypedFromRegular(userAnnotation, typeName)
         obj = ExplicitlyTypedUserAnnotation(userAnnotation.CreatingUser,userAnnotation.CreationDateTime,userAnnotation.ModifiedDateTime,userAnnotation.FrameNumber,userAnnotation.Comment, typeName);
      end
    end
end
