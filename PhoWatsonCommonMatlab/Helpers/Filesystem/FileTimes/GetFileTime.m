function Time = GetFileTime(FileName, TimeType, OutputType)  %#ok<STOUT,INUSD>
% Get Creation, Access, and Write time of a file
% Time = GetFileTime(FileName, TimeType, OutputType)
% INPUT:
%   FileName: String, file or folder name with or without absolute or relative
%             path. Unicode characters are considered.
%   TimeType: String, type of the conversion from UTC file time to local time.
%             Optional, default: 'Local'.
%             Just the 1st character matters, not case-sensitive.
%             'Local':   The file times are converted from the local time
%                        considering the daylight saving setting of the
%                        specific times.
%             'Windows': The time conversions consider the current daylight
%                        saving time as usual for Windows (e.g. the Windows
%                        Explorer). If the daylight saving changes, the file
%                        times can change also.
%             'UTC':     The UTC times are replied without daylight saving time
%                        adjustment.
%             'native':  The UTC times are replied as UINT64 values.
%                        (0.1 mysec ticks since 01-Jan-1601)
%   OutputType: String, define the output. Optional, default: 'Struct'.
%             Just the 1st character matters, not case-sensitive.
%             'Struct':  Reply a struct with fields:
%                        {"Creation", "Access", "Write"}.
%             'Creation', 'Access', 'Write': Reply just the specified time.
%
% OUTPUT:
%   Time:     Struct, vector or scalar.
%             For the TimeType 'native' the values are replied as UINT64.
%             Otherwise the values are replied as [1 x 6] DOUBLE vector as by
%             DATEVEC:
%               [year, month, day, hour, minute, second.millisecond]
%
% The function stops with an error if:
%   - the file does not exist,
%   - the time conversion fails,
%   - the number or type of inputs/outputs is wrong.
%
% EXAMPLES:
%   File = which('GetFileTime.m');
%   GetFileTime(File)
%   GetFileTime(File, 'UTC')
%   GetFileTime(File, 'Windows')
%   GetFileTime(File, [], 'Write')
%
% NOTES:
% - The function is tested for NTFS and FAT formatted disks only.
% - The "Windows" method replies the times according to the currently active
%   DST: The file time changes, when the DST is switched! Although this is
%   strange, it is a consistent method to handle the hour at the DST switch.
% - With the "Local" conversion, the times at the DST switches cannot be
%   converted consistently, e.g. 2009-Mar-08 02:30:00 (does not exist) and
%   2009-Nov-01 02:30:00 (exists twice). But for ths other 8758 hours of the
%   year, "Local" is more consistent than the "Windows" conversion.
% - Matlab's DIR command showed the "Windows" write time until 6.5.1 and the
%   "Local" value for higher versions.
% - This function needs WindowsXP or Windows Server 2003 and higher, because
%   the API function TzSpecificLocalTimeToSystemTime is called. The prototype
%   of this function is not included in the header file <windows.h> of LCC2.4
%   (shipped with Matlab up to 2009a and higher?!) and BCC5.5. LCC 3.8 and
%   OpenWatcom 1.8 can compile it.
% - No Unix and MacOS support.
% - Run the function uTest_FileTime after compiling the MEX files.
%
% COMPILATION:
% The C-file must be compiled before using. See GetFileTime.c for instructions.
%
% Tested: Matlab 6.5, 7.7, 7.8, WinXP, 32bit
%         Compiler: LCC3.8, OWC1.8, MSVC2008
% Assumed Compatibility: higher Matlab versions, 64bit
% Author: Jan Simon, Heidelberg, (C) 2009-2011 matlab.THISYEAR(a)nMINUSsimon.de
%
% See also DIR, CLOCK, DATEVEC, DATESTR, SetFileTime.

% $JRev: R-w V:014 Sum:UHa9kkYiutAN Date:22-Jun-2011 02:58:12 $
% $License: BSD (use/copy/change/redistribute on own risk, mention the author) $
% $UnitTest: uTest_FileTime $
% $File: Tools\GLFile\GetFileTime.m $
% History:
% 001: 09-Jul-2009 00:12, Initial version.
% 002: 11-Nov-2009 12:11, 2nd input for time conversion.
% 008: 01-Oct-2010 15:07, Unicode names.
% 012: 06-Apr-2011 14:18, 'native' UTC times as UINT64.

error(['*** ', mfilename, ': Cannot find compiled Mex file!']);
