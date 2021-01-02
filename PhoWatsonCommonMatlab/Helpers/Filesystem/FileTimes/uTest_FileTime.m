function uTest_FileTime(doSpeed)  %#ok<INUSD>
% Automatic test: Set/GetFileTime
% This is a routine for automatic testing. It is not needed for processing and
% can be deleted or moved to a folder, where it does not bother.
%
% uTest_FileTime(doSpeed)
% INPUT:
%   doSpeed: Optional logical flag to trigger time consuming speed tests.
%            Default: TRUE. If no speed tested are defined, this is ignored.
% OUTPUT:
%   On failure the test stops with an error.
%
% Tested: Matlab 6.5, 7.7, 7.8, WinXP
% Author: Jan Simon, Heidelberg, (C) 2009-2011 matlab.THISYEAR(a)nMINUSsimon.de

% $JRev: R-t V:014 Sum:1rB+khqWYEDs Date:22-Jun-2011 02:58:12 $
% $License: BSD $
% $File: Tools\UnitTests_\uTest_FileTime.m $
% History:
% 001: 10-Nov-2009 13:18, Need a test for new features.
% 005: 20-Aug-2010 10:36, BUGFIX: DIR replies the date in the local language.
%      In Germany the date of DIR can be "01-Dez-2010" and the comparison with
%      DATESTR(GetFileTime) failed, because it replies English month names.
%      Now DATENUM is used to compare the times.
% 008: 01-Oct-2010 14:24, BUGFIX: The same problem appeared again.
% 013: 04-May-2011 00:33, 3rd input for GetFileTime.

% Initialize: ==================================================================
% Global Interface: ------------------------------------------------------------
ErrID = ['JSimon:', mfilename, ':'];

% Initial values: --------------------------------------------------------------
% Program Interface: -----------------------------------------------------------
if nargin == 0
   doSpeed = true;  %#ok<NASGU>
end

% User Interface: --------------------------------------------------------------
% Do the work: =================================================================
disp(['===  Test SetFileTime / GetFileTime  ', datestr(now, 0)]);

% Create a test file:
disp('Create test file:');
File = fullfile(tempdir, 'FileTime__.test');
if exist(File, 'file')
   delete(File);
end
FID = fopen(File, 'w');
if FID < 0
   error([ErrID, 'NoTestFile'], 'Cannot create test file?!');
end
fclose(FID);

% Get WRITE time with Matlab's DIR:
FileDir = dir(File);
disp(FileDir);

% Get file times:
disp('GetFileTime:');
Reply = GetFileTime(File);
disp(Reply);

% DIR does apply FLOOR to the seconds:
fprintf('\n');
if isequal(round(datevec(FileDir.date)), floor(Reply.Write))
   disp('  ok: DIR and GetFileTime reply the same WRITE time');
else
   error([ErrID, 'DIRneGetFileTime'], ...
      'DIR and GetFileTime reply different WRITE time');
end

% Working with folders now (15-Nov-2009): --------------------------------------
FolderName = 'FileTime_Dir__.test';
Folder     = fullfile(tempdir, FolderName);
if ~exist(Folder, 'dir')
   [Succ, Msg] = mkdir(tempdir, FolderName);
   if Succ == 0
      error([ErrID, 'CannotCreateFolder'], ['Cannot create test folder:', ...
            char(10), '  ', Folder, char(10), '  ', Msg]);
   end
end

try
   theTime = [2001, 8, 13, 15, 41, 12];      % Arbitrary
   SetFileTime(Folder, 'Write',    theTime);
   SetFileTime(Folder, 'Access',   theTime); % NTFS can delay change for 1 hour!
   SetFileTime(Folder, 'Creation', theTime);
   
   FolderTime = GetFileTime(Folder);
   if abs(etime(FolderTime.Write, theTime)) <= 2 && ...
      abs(etime(FolderTime.Creation, theTime)) <= 2
      disp('  ok: Set/Get of folder time');
   else
      error([ErrID, 'BadFolderAccess'], ...
         'Cannot set or get folder times correctly.');
   end
catch
   error([ErrID, 'SetTimeFolderCrash'], ...
      ['Setting the times of a folder crashed:', char(10), lasterr]);
end

[Succ, Msg] = rmdir(Folder);
if Succ == 0
   error([ErrID, 'CannotDeleteFolder'], ['Cannot delete test folder:', ...
         char(10), '  ', Folder, char(10), '  ', Msg]);
end

% Set the file times and compare them after Get: -------------------------------
TypeList = {'', 'Windows', 'Local', 'UTC'};
SpecList = {'Write', 'Creation', 'Access'};
DateList = {[2009 6 1 14 15 16], [2009 12 1 14 15 16]};  % Summer and winter
DSTList  = {'Summer time', 'Winter time'};
for iDate = 1:length(DateList)
   aDate = DateList{iDate};
   fprintf('\n- %s: [%d %d %d %d %d %d]\n', DSTList{iDate}, aDate);
   
   for iSpec = 1:length(SpecList)
      aSpec = SpecList{iSpec};
      for iType = 1:length(TypeList)
         % Call SetFileTime:
         aTimeType = TypeList{iType};
         try
            if isempty(aTimeType)  % Default:
               SetFileTime(File, aSpec, aDate);
            else
               SetFileTime(File, aSpec, aDate, aTimeType);
            end
         catch  % TRY-CATCH compatible with Matlab 6.5:
            error([ErrID, 'CrashedSet'], ...
               ['Crash in SetFileTime (', aSpec, ', ', aTimeType ')', ...
                  char(10), lasterr]);
         end
         
         % Call GetfileTime:
         try
            if isempty(aTimeType)  % Default:
               Reply = GetFileTime(File);
            else
               Reply = GetFileTime(File, aTimeType);
            end
         catch
            error([ErrID, 'CrashedGet'], ...
               ['Crash in GetFileTime (', aTimeType ')', ...
                  char(10), lasterr]);
         end
         
         % Compare the results:
         if isequal(Reply.(aSpec), aDate)
            if isempty(aTimeType)
               fprintf('  ok: Get(Set(%s, date)\n', aSpec);
            else
               fprintf('  ok: Get(Set(%s, date, %s)\n', aSpec, aTimeType);
            end
         else
            error([ErrID, 'GetSetDiffers'], ...
               ['GetFileTime(SetFileTime(', aSpec, ', ', ...
                  sprintf('[%d %d %d %d %d %d], ', aDate), aTimeType, ...
                  ') = ', sprintf('[%d %d %d %d %d %d]', Reply.(aSpec))]);
         end
         
         % Compare with DIR:
         if strcmp(aSpec, 'Write')
            if (sscanf(version, '%d') >= 7 && strcmp(aTimeType, 'Local')) || ...
                  (sscanf(version, '%d') < 7 && strcmp(aTimeType, 'Windows'))
               FileDir = dir(File);
               % No "datenum" field in Matlab 6.5...
               if isequal(datevec(FileDir.date), floor(Reply.Write))
                  disp('  ok: Reply equals DIR');
               else
                  error([ErrID, 'DiffersFromDIR'], ...
                     'Get(Set()) differs from DIR');
               end
            end
         end
         
         % Get a single time:
         S = GetFileTime(File, aTimeType, 'struct');
         T = GetFileTime(File, aTimeType, aSpec);
         if ~isequal(S.(aSpec), T)
            error([ErrID, 'SpecTime'], '3rd input not caught correctly.');
         end
      end
   end
end

% Special test for native data type:
i64Time = uint64(129672225161500000);
SetFileTime(File, 'Write', [2011, 12, 1, 14, 15, 16.15], 'UTC');
aTime   = GetFileTime(File, 'native');
if isequal(aTime.Write, i64Time)
   disp('  ok: Read native UTC time');
else
   error([ErrID, 'NativeUTCFailed'], 'Read native UTC time failed');
end

SetFileTime(File, 'Write',    i64Time, 'native');
SetFileTime(File, 'Access',   i64Time, 'native');
SetFileTime(File, 'Creation', i64Time, 'native');
aTime   = GetFileTime(File, 'native');
if isequal(aTime.Write, aTime.Access, aTime.Creation, i64Time)
   disp('  ok: Write native UTC time');
else
   error([ErrID, 'NativeUTCFailed'], 'Write native UTC time failed');
end

% Check bad inputs/outputs: ----------------------------------------------------
fprintf('\nTest bad inputs and outputs:\n');
tooLazy  = false;
testDate = clock;
try
   SetFileTime([], 'Write', testDate);
   tooLazy = true;
catch
   disp(['  ok: Bad file refused:', FormattedErrMsg]);
end
if tooLazy
   error([ErrID, 'BadFileAccepted'], 'Bad file accepted.');
end

try
   SetFileTime('this_is_a_not_existing_file%&%$', 'Write', testDate);
   tooLazy = true;
catch
   disp(['  ok: Missing file refused: ', FormattedErrMsg]);
end
if tooLazy
   error([ErrID, 'MissFileAccepted'], 'Missing file accepted.');
end

try
   SetFileTime(File, '_No_valid_spec', testDate);
   tooLazy = true;
catch
   disp(['  ok: Invalid time specifier refused: ', FormattedErrMsg]);
end
if tooLazy
   error([ErrID, 'BadSpecAccepted'], 'Bad time specifier accepted.');
end

try
   SetFileTime(File, 'Access', 'badate');  % String, but 6 chars
   tooLazy = true;
catch
   disp(['  ok: Date as string refused: ', FormattedErrMsg]);
end
if tooLazy
   error([ErrID, 'BadDateStrAccepted'], 'Date as string accepted.');
end

try
   SetFileTime(File, 'Access', 1:7);  % date with 7 elements
   tooLazy = true;
catch
   disp(['  ok: Date with 7 numbers refused: ', FormattedErrMsg]);
end
if tooLazy
   error([ErrID, 'BadDateNumAccepted'], 'Date with 7 numbers accepted.');
end

try
   SetFileTime(File, 'Access', zeros(1, 6));
   tooLazy = true;
catch
   disp(['  ok: date ZEROS(1, 6) refused: ', FormattedErrMsg]);
end
if tooLazy
   error([ErrID, 'ZeroDateNumAccepted'], 'Date ZEROS(1, 6) accepted.');
end

% Success! Goodbye: ------------------------------------------------------------
delete(File);
fprintf('\n== SetFileTime and GetFileTime passed the tests\n');

return;

% ******************************************************************************
function Str = FormattedErrMsg
Str = [char(10), '      ', strrep(lasterr, char(10), [char(10), '      '])];
return;
