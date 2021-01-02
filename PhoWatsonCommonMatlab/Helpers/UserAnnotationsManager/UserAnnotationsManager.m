classdef UserAnnotationsManager < handle & matlab.mixin.CustomDisplay
    %FramesListManager Keeps track of user-annotated frames in a class
    %   Holds an array of UserAnnotation objects
	% This file is used by SliderVideoPlayer to keep track of a list of annotations
    
    properties
        VideoFileInfo
        UserAnnotationArrayNames
        UserAnnotationArrayDescriptions
        UserAnnotationObjMaps
        AnnotatingUser
		BackingFile
    end
    
    methods
        function obj = UserAnnotationsManager(videoFileIdentifier, videoFileNumFrames, annotatingUser, backingFilePath)
            %UserAnnotationsManager Construct an instance of this class
            currVideoFileInfo.videoFileIdentifier = videoFileIdentifier;
            currVideoFileInfo.videoFileNumFrames = videoFileNumFrames;
            
            if ~exist('annotatingUser','var')
                annotatingUser = 'Anonymous';
            end  
            obj.AnnotatingUser = annotatingUser;
			
			if (~exist('backingFilePath','var') || isempty(backingFilePath))
				[filename,path,~] = uiputfile('*.mat','User Annotations Backing File',['UAnnotations-', currVideoFileInfo.videoFileIdentifier, '.mat']);
				if isequal(filename,0) || isequal(path,0)
				   error('User clicked Cancel.')
				end
%                 backingFilePath = 'UserAnnotationsBackingFile.mat';
				backingFilePath = fullfile(path,filename);
			end
						
            obj.UserAnnotationArrayNames = {};
            obj.UserAnnotationArrayDescriptions = {};
            
            obj.VideoFileInfo = currVideoFileInfo;
            
            obj.UserAnnotationObjMaps = {};
            
			% Setup backing file
			obj.BackingFile.fullPath = backingFilePath;
			obj.BackingFile.hasBackingFile = false;
            obj.BackingFile.shouldAutosaveToBackingFile = true;
			% obj.BackingFile.shouldAutosaveInTransactions:  
				% if true, saves most efficiently to the backing file (only what's been updated in the object) (not currently implemented.
				% otherwise, it saves the whole object each time using saveToBackingFile() which is less efficient.
			obj.BackingFile.shouldAutosaveInTransactions = true;
			
			
			obj.tryOpenBackingFile();
			
            % Add a default type
            obj.addAnnotationType('Temp');

        end
        
        
        %% Annotation Type Objects:
        function TF = addAnnotationType(obj, typeName, typeDescription)
            %addAnnotationType Adds a new annotation type

            if ~exist('typeDescription','var')
                typeDescription = '';
            end            
            
%             if isempty(ismember(typeName, obj.UserAnnotationArrayNames))
            if any(strcmp(obj.UserAnnotationArrayNames,typeName))
                % Type already exists
                TF = false;
            else
                % type doesn't yet exist, create it
                TF = true;
                obj.UserAnnotationArrayNames{end+1} = typeName;
                obj.UserAnnotationArrayDescriptions{end+1} = typeDescription;
                obj.UserAnnotationObjMaps.(typeName) = containers.Map('KeyType','uint32','ValueType','any'); % might need to be 'any'
				
				if obj.BackingFile.shouldAutosaveToBackingFile
					if ~obj.BackingFile.shouldAutosaveInTransactions
						obj.BackingFile.matFile.obj.UserAnnotationArrayNames{end+1} = typeName;
						obj.BackingFile.matFile.obj.UserAnnotationArrayDescriptions{end+1} = typeDescription;
						obj.BackingFile.matFile.obj.UserAnnotationObjMaps.(typeName) = containers.Map('KeyType','uint32','ValueType','any'); % might need to be 'any'
					else
						obj.saveToBackingFile();
					end
				end
				
            end
            
        end
        
        function TF = modifyAnnotationType(obj, originalTypeName, modifiedTypeName, modifiedTypeDescription)
            %METHOD1 Changes an existing annotation type's name or
            %modifiedType description.
            %   Pass empty strings if you don't want them to change.
         
            matchingArrayNameIndicies = strcmp(obj.UserAnnotationArrayNames, originalTypeName);
            if any(matchingArrayNameIndicies)
                % Type already exists, modify it
                TF = true;
                if exist('modifiedTypeName','var')
                    if ~isempty(modifiedTypeName)
                        obj.UserAnnotationArrayNames{matchingArrayNameIndicies} = modifiedTypeName;
                    end
                end            
                if exist('modifiedTypeDescription','var')
                    if ~isempty(modifiedTypeDescription)
                        obj.UserAnnotationArrayDescriptions{matchingArrayNameIndicies} = modifiedTypeDescription;
                    end
                end                  
                
            else
                % type doesn't yet exist
                TF = false;
                error('Type attempting to be modified does not exist!')
                
            end
            
        end
        
        %% Annotation Objects:
		function isAnnotationActive = toggleAnnotation(obj, typeName, frameNumber, comment)
		% toggles the annotation on or off by deleting it. Note when deleting it the comment is lost.
			didRemove = obj.removeAnnotation(typeName, frameNumber);
			if didRemove
				isAnnotationActive = false;
			else
				if ~exist('comment','var')
					comment = '';
				end				
				isAnnotationActive = obj.createAnnotation(typeName, frameNumber, comment);
			end
		end
		
        function TF = createAnnotation(obj, typeName, frameNumber, comment)
            %createAnnotation Adds a new annotation object to an existing typeArray
			% returns true if it was created.
            if ~exist('frameNumber','var')
                error('Requires the frameNumber!')
            end
            
            if ~exist('comment','var')
                comment = '';
            end  
            
            if any(strcmp(obj.UserAnnotationArrayNames,typeName))
                % Type already exists
                if isKey(obj.UserAnnotationObjMaps.(typeName),frameNumber)
                   % frame already exists
                   obj.UserAnnotationObjMaps.(typeName)(frameNumber).modifyComment(comment);
				   TF = false;
                else
                   % frame does not yet exist
                   newAnnotationObj = UserAnnotation(frameNumber, comment, obj.AnnotatingUser);
                   obj.UserAnnotationObjMaps.(typeName)(frameNumber) = newAnnotationObj;
				   TF = true;
				end
				
				if obj.BackingFile.shouldAutosaveToBackingFile
					if ~obj.BackingFile.shouldAutosaveInTransactions
						obj.BackingFile.matFile.obj.UserAnnotationObjMaps.(typeName)(frameNumber) = obj.UserAnnotationObjMaps.(typeName)(frameNumber);
					else
						obj.saveToBackingFile();
					end
				end
				
            else
                % type doesn't yet exist, create it
                error('type does not exist!')
            end
            
        end
        
        function TF = removeAnnotation(obj, typeName, frameNumber)
            %removeAnnotation Removes an existing annotation object at a given frameNumber for an existing typeArray
			% returns true if it was removed.
            if ~exist('frameNumber','var')
                error('Requires the frameNumber!')
            end

            if any(strcmp(obj.UserAnnotationArrayNames,typeName))
                % Type already exists
                
                if isKey(obj.UserAnnotationObjMaps.(typeName),frameNumber)
                   % frame already exists
				   remove(obj.UserAnnotationObjMaps.(typeName),frameNumber); % remove the frame
				   TF = true;
					if obj.BackingFile.shouldAutosaveToBackingFile
						if ~obj.BackingFile.shouldAutosaveInTransactions
							remove(obj.BackingFile.matFile.obj.UserAnnotationObjMaps.(typeName),frameNumber);
						else
							obj.saveToBackingFile();
						end
					end	
				
                else
                   % frame does not yet exist
					warning('frame does not exist!')
					TF = false;
                end
            else
                % type doesn't yet exist
                error('type does not exist!')
			end
			
            
		end
		
		
		%% Backing File Methods:
		function tryOpenBackingFile(obj)
			% see if the file exists at the provided path
			if ~exist(obj.BackingFile.fullPath,'file')
                % if it doesn't exist, create it
				disp(['Creating new backing file at ' obj.BackingFile.fullPath])
			else
				disp(['Opening existing backing file at ' obj.BackingFile.fullPath])
				% TODO: load from backing file:
				obj = UserAnnotationsManager.loadFromExistingBackingFile(obj.BackingFile.fullPath); % will this work?
				error('Not yet finished!')
			end
			
			obj.BackingFile.matFile = matfile(obj.BackingFile.fullPath,'Writable',true);
			obj.createBackingFile();
			obj.BackingFile.hasBackingFile = true;

		end
		
		function createBackingFile(obj)
			save(obj.BackingFile.fullPath,'obj','-v7.3');
		end
		
		
		function saveToBackingFile(obj)
			save(obj.BackingFile.fullPath,'obj','-v7.3');
		end
		
		function saveToUserSelectableCopyMat(obj)
			% allows the user to select a file path to save a copy of the current annotation object out to a .mat file.
			uisave({'obj'},['UAnnotations-', currVideoFileInfo.videoFileIdentifier, '.mat'])
		end
        
        %% Getters:
        function name = getAnnotationName(obj, idx)
            %METHOD1 Gets the name of an annotation type at a given index
            name = obj.UserAnnotationArrayNames{idx};   
        end
        
        function map = getAnnotationMap(obj, typeName)
            %getAnnotationMap Gets the map at a given typeName
            map = obj.UserAnnotationObjMaps.(typeName);   
        end
        
        function array = getAnnotationsArray(obj, typeName)
            %METHOD1 Gets the array at a given typeName
            array = obj.getAnnotationMap(typeName).values;   
        end
        
        function array = getAnnotationsFrames(obj, typeName)
            %METHOD1 Gets the array at a given typeName
            array = obj.getAnnotationMap(typeName).keys;   
		end
        
        function doesAnnotationExist = DoesAnnotationExist(obj, typeName, frameNumber)
            %doesAnnotationExist Returns true if an annotation exists at the specified frameNumber for a given typeName 
		   doesAnnotationExist = isKey(obj.getAnnotationMap(typeName), frameNumber);
		end
		
		
        function [annotation, doesAnnotationExist] = tryGetAnnotation(obj, typeName, frameNumber)
            %tryGetAnnotation Gets the array at a given typeName
            foundFrameAnnotationObjs = getAllAnnotationsForFrame(obj, frameNumber, {typeName});
			
			doesAnnotationExist = ~isempty(foundFrameAnnotationObjs);
			if doesAnnotationExist
				annotation = foundFrameAnnotationObjs{1};
			else
				annotation = {};
			end
			
		end
		
		
		
		%% Aggregate and Combined:
        
        function foundFrameAnnotationObjs = getAllAnnotationsForFrame(obj, frameNumber, typeNames)
            %getAllAnnotationsForFrame Gets all annotations for the specified frameNumber
            %that are of the types listed in typeNames, or all if
            %unspecified.
            if ~exist('frameNumber','var')
                error('Requires the frameNumber!')
            end
            
            if ~exist('typeNames','var')
                typeNames = obj.UserAnnotationArrayNames;
			end
            
			foundFrameAnnotationObjs = {};
			
            for i=1:length(typeNames)
               currTypeName = typeNames{i};
               currAnnotationMap = obj.getAnnotationMap(currTypeName);
               % if this frame exists as a key, add it to the output array:       
               if isKey(currAnnotationMap, frameNumber)
                   currExplicitAnnotation = ExplicitlyTypedUserAnnotation.createExplicitlyTypedFromRegular(currAnnotationMap(frameNumber), currTypeName);
%                    foundFrameAnnotationObjs{end+1} = currAnnotationMap(frameNumber);
                   foundFrameAnnotationObjs{end+1} = currExplicitAnnotation;
               end
            end  
        end
        
        function flatMap = flattenAnnotationsToFrames(obj)
            %flattenAnnotationsToFrames Produces a flat map with a list of one or more ExplictlyTypedUserAnnotations at any frame in UserAnnotationObjMaps. the array at a given typeName
            flatMap = containers.Map('KeyType','uint32','ValueType','any');
            
            for i=1:length(obj.UserAnnotationArrayNames)
                currTypeName = obj.getAnnotationName(i);
                currAnnotationMap = obj.getAnnotationMap(currTypeName);
                currFrames = currAnnotationMap.keys;
                for j = 1:length(currFrames)
                    currFrame = currFrames{j};
                    currExplicitAnnotation = ExplicitlyTypedUserAnnotation.createExplicitlyTypedFromRegular(currAnnotationMap(currFrame), currTypeName);
					if isKey(flatMap, currFrame)
					   % already exists from another type, add it to the array
					   flatMap(currFrame) = {flatMap(currFrame), currExplicitAnnotation};
					else
					   flatMap(currFrame) = {currExplicitAnnotation};
					end
                end
            end
              
        end
        
        
	end % end methods
	methods (Static)
      % Creates an explictly typed annotation from a regular one.
      function obj = loadFromExistingBackingFile(backingFilePath)
		if ~exist('backingFilePath','var')
			backingFilePath = 'UserAnnotationsBackingFile.mat';
		end  
		 L = load(backingFilePath,'obj');
		 obj = L.obj;
	  end
	
	end % end methods static
	
end

