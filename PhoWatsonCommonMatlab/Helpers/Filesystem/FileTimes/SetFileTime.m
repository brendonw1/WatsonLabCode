function SetFileTime(File)  %#ok<INUSD>
% Set Creation, Access, or Write time of a file
% On NTFS file systems, creation, access and write time are stored for each
% file. SetFileTime can set these times for writable files.
%
% SetFileTime(FileName, TimeSpec, Time, Type)
% INPUT:
%   FileName: String, file or folder name with or without absolute or relative
%             path. Unicode names are considered.
%   TimeSpec: String specifying the time type to set:
%               'Creation': Time of creation,
%               'Access':   Time of last access,
%               'Write':    Time of last modification.
%   Time:     Current local time as [1 x 6] double vector in DATEVEC format,
%             e.g. as replied from CLOCK. Milliseconds are considered.
%             The time is converted to UTC.
%   Type:     String, type of the conversion from local time to UTC file time.
%             Optional, default: "Local". Just the 1st character matters.
%             "Local":   The file time is converted from the local time
%                        considering the daylight saving setting of the
%                        specific time.
%             "Windows": The time conversion considers the current daylight
%                        saving time as usual for Windows (e.g. the Windows
%                        Explorer). If the daylight saving changes, the file
%                        times can change also.
%             "UTC":     The input is written as UTC time without a conversion.
%             "native":  Time as UINT64 (0.1 mysec ticks since 01-Jan-1601).
%
% OUTPUT:
%   none.
%
% The function stops with an error if:
%   - the file does not exist or cannot be opened in write mode,
%   - the time conversions fail,
%   - the number or type of inputs/outputs is wrong.
%
% EXAMPLE:
%   File = tempname;
%   FID = fopen(File, 'w'); fclose(FID);
%   D = dir(File)
%   SetFileTime(File, 'Write', [2009, 12, 24, 16, 32, 29]);
%   D = dir(File)
%
% NOTES:
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
% COMPILE:
% The C-file must be compiled before using. See SetFileTime.c for instructions.
%
% Tested: Matlab 6.5, 7.7, 7.8, WinXP, 32bit
%         Compiler: LCC3.8, OWC1.8, MSVC2008
% Assumed Compatibility: higher Matlab versions, 64bit
% Author: Jan Simon, Heidelberg, (C) 2009-2011 matlab.THISYEAR(a)nMINUSsimon.de
%
% See also DIR, CLOCK, DATEVEC, DATESTR, GetFileTime.

% $JRev: R-p V:021 Sum:JBYvNUq+RK76 Date:22-Jun-2011 02:58:12 $
% $License: BSD (use/copy/change/redistribute on own risk, mention the author) $
% $UnitTest: uTest_FileTime $
% $File: Tools\GLFile\SetFileTime.m $
% History:
% 010: 09-Jul-2009 00:42, TimeSpec 'Modify' -> 'Write'.
% 017: 01-Oct-2010 15:07, Unicode names.

error(['*** ', mfilename, ': Cannot find compiled Mex file!']);
