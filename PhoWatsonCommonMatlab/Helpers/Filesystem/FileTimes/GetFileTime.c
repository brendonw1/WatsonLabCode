// GetFileTime.c
// Get Creation, Access, and Write time of a file
// Time = GetFileTime(FileName, TimeType, OutputType)
// INPUT:
//   FileName: String, file or folder name with or without absolute or relative
//             path. Unicode characters are considered.
//   TimeType: String, type of the conversion from UTC file time to local time.
//             Optional, default: 'Local'.
//             Just the 1st character matters, not case-sensitive.
//             'Local':   The file times are converted from the local time
//                        considering the daylight saving setting of the
//                        specific times.
//             'Windows': The time conversions consider the current daylight
//                        saving time as usual for Windows (e.g. the Windows
//                        Explorer). If the daylight saving changes, the file
//                        times can change also.
//             'UTC':     The UTC times are replied without daylight saving time
//                        adjustment.
//             'native':  The UTC times are replied as UINT64 values.
//                        (0.1 mysec ticks since 01-Jan-1601)
//   OutputType: String, define the output. Optional, default: 'Struct'.
//             Just the 1st character matters, not case-sensitive.
//             'Struct':  Reply a struct with fields:
//                        {"Creation", "Access", "Write"}.
//             'Creation', 'Access', 'Write': Reply just the specified time.
//
// OUTPUT:
//   Time:     Struct, vector or scalar.
//             For the TimeType 'native' the values are replied as UINT64.
//             Otherwise the values are replied as [1 x 6] DOUBLE vector as by
//             DATEVEC:
//               [year, month, day, hour, minute, second.millisecond]
//
// The function stops with an error if:
//   - the file does not exist,
//   - the time conversion fails,
//   - the number or type of inputs/outputs is wrong.
//
// EXAMPLES:
//   File = which('GetFileTime.m');
//   GetFileTime(File)
//   GetFileTime(File, 'UTC')
//   GetFileTime(File, 'Windows')
//   GetFileTime(File, [], 'Write')
//
// NOTES:
// - The function is tested for NTFS and FAT formatted disks only.
// - The "Windows" method replies the times according to the currently active
//   DST: The file time changes, when the DST is switched! Although this is
//   strange, it is a consistent method to handle the hour at the DST switch.
// - With the "Local" conversion, the times at the DST switches cannot be
//   converted consistently, e.g. 2009-Mar-08 02:30:00 (does not exist) and
//   2009-Nov-01 02:30:00 (exists twice). But for ths other 8758 hours of the
//   year, "Local" is more consistent than the "Windows" conversion.
// - Matlab's DIR command showed the "Windows" write time until 6.5.1 and the
//   "Local" value for higher versions.
// - This function needs WindowsXP or Windows Server 2003 and higher, because
//   the API function TzSpecificLocalTimeToSystemTime is called. The prototype
//   of this function is not included in the header file <windows.h> of LCC2.4
//   (shipped with Matlab up to 2009a and higher?!) and BCC5.5. LCC 3.8 and
//   OpenWatcom 1.8 can compile it.
// - No Unix and MacOS support.
// - Run the function uTest_FileTime after compiling the MEX files.
//
// COMPILE: ("mex -setup" on demand)
//   Not compatible with LCC2.4 shipped with Matlab!
//   Windows: mex -O GetFileTime.c
//   Linux:   mex -O CFLAGS="\$CFLAGS -std=c99" GetFileTime.c
// Precompiled MEX files can be found at: http://www.n-simon.de/mex
//
// Tested: Matlab 6.5, 7.7, 7.8, WinXP, 32bit
//         Compiler: LCC3.8, OWC1.8, MSVC2008,
//         Failing: LCC2.4 shipped with Matlab
// Assumed Compatibility: higher Matlab versions, 64bit
// Author: Jan Simon, Heidelberg, (C) 2009-2011 matlab.THISYEAR(a)nMINUSsimon.de
//
// See also: DIR, CLOCK, DATEVEC, DATESTR, SetFileTime.

/*
% $JRev: R-K V:027 Sum:lVELG9HnTRZL Date:21-Jun-2011 22:19:58 $
% $License: BSD (use/copy/change/redistribute on own risk, mention the author) $
% $UnitTest: uTest_FileTime $
% $File: Tools\Mex\Source\GetFileTime.c $
% History:
% 001: 09-Jul-2009 00:12, Initial version.
% 005: 08-Nov-2009 13:43, Reply UTC file time as: Windows, Local, UTC.
%      No support of LCC 2.4 (shipped with Matlab) and BCC5.5.
% 006: 15-Nov-2009 00:37, Works with directories also.
% 013: 18-May-2010 10:19, BUGFIX: "HANDLE *H" -> "HANDLE H"
% 018: 24-Sep-2010 08:48, Unicode file names, 64bit.
% 019: 06-Apr-2011 14:18, 'native' UTC times as UINT64.
% 025: 11-Apr-2011 01:54, 64 bit numbers with LCC3.8.
%      The compilation fails with LCC2.4 (shipped with Matlab).
% 026: 04-May-2011 00:33, 3rd input to specify a single access type.
*/

#if defined(__WINDOWS__) || defined(WIN32) || defined(_WIN32) || defined(_WIN64)
#include <windows.h>
#else
#error Implemented for Windows only now!
#endif

#include "mex.h"
#include <math.h>
#include <wchar.h>

// Works with LCC3.8, fails with LCC2.4 shipped with Matlab 32 bit:
#if defined(__LCC__)
typedef unsigned long long uint64_T;
#endif

// Assume 32 bit addressing for Matlab 6.5:
// See MEX option "compatibleArrayDims" for MEX in Matlab >= 7.7.
#ifndef MWSIZE_MAX
#define mwSize  int32_T           // Defined in tmwtypes.h
#define mwIndex int32_T
#define MWSIZE_MAX MAX_int32_T
#endif

// Error messages do not contain the function name in Matlab 6.5! This is not
// necessary in Matlab 7, but it does not bother:
#define ERR_ID   "JSimon:GetFileTime:"
#define ERR_HEAD "*** GetFileTime[mex]: "

// Enumerator for types of time conversion:
static enum TimeType_Enum {WIN_TIME, LOCAL_TIME, UTC_TIME, UTC_RAW};
static enum OutputType_Enum {STRUCT_OUT, CREATE_OUT, ACCESS_OUT, WRITE_OUT};

// Prototypes:
mxArray *FileTimeToDateVec_Win(const FILETIME *UTC, enum TimeType_Enum Type);

// Main function ===============================================================
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  wchar_t    *Name;
  mwSize     NameLen;
  const char *ReplyFields[3] = {"Creation", "Access", "Write"};
  mxArray    *Reply;
  HANDLE     H;
  FILETIME   CreationUTC, AccessUTC, WriteUTC;
  BOOL       Success;
   
  // Default conversion: Adjust to local with daylight saving setting of the
  // specific time:
  enum TimeType_Enum TimeType = LOCAL_TIME;
  
  // Type of the output:
  enum OutputType_Enum OutType = STRUCT_OUT;
          
  // Check number of inputs:
  if (nrhs == 0 || nrhs > 3) {
     mexErrMsgIdAndTxt(ERR_ID "BadNInput", ERR_HEAD "1 to 3 inputs required.");
  }
  
  // 2nd input is the [TimeType] of the output as string:
  if (nrhs >= 2) {
     if (!mxIsEmpty(prhs[1])) {
        // Check type of input:
        if (!mxIsChar(prhs[1])) {
           mexErrMsgIdAndTxt(ERR_ID   "BadTimeType",
                             ERR_HEAD "2nd input [TimeType] must be a string.");
        }
        
        // "W"indows, "U"TC", "L"ocal time (default), "N"ative:
        switch ((char) tolower(*(char *) mxGetData(prhs[1]))) {
           case 'l':  TimeType = LOCAL_TIME;  break;  // Local time
           case 'w':  TimeType = WIN_TIME;    break;  // Adjust to current DST
           case 'u':  TimeType = UTC_TIME;    break;  // UTC not affected by DST
           case 'n':  TimeType = UTC_RAW;     break;  // Raw UTC time as UINT64
           default:
              mexErrMsgIdAndTxt(ERR_ID   "BadTimeType",
                                ERR_HEAD "[TimeType] string not recognized.");
        }
     }
     
     // 3rd input:
     if (nrhs == 3) {
        if (!mxIsEmpty(prhs[2])) {
           // Check type of input:
           if (!mxIsChar(prhs[2])) {
              mexErrMsgIdAndTxt(ERR_ID "BadFieldType",
                      ERR_HEAD "2nd input [TimeType] must be a string.");
           }

           // "S"truct (default), "C"reate, "W"rite, "A"ccess:
           switch ((char) tolower(*(char *) mxGetData(prhs[2]))) {
              case 's':  OutType = STRUCT_OUT;  break;
              case 'c':  OutType = CREATE_OUT;  break;
              case 'a':  OutType = ACCESS_OUT;  break;
              case 'w':  OutType = WRITE_OUT;   break;
              default:
                 mexErrMsgIdAndTxt(ERR_ID   "BadOutputType",
                                ERR_HEAD "[TimeType] string not recognized.");
           }  // default: OutType = STRUCT_OUT
        }
     }
  }
    
  // For nlhs == 0, the reply is store in [ans]:
  if (nlhs > 1) {
     mexErrMsgIdAndTxt(ERR_ID "BadNOutput", ERR_HEAD "1 output allowed.");
  }
  
  // Get file name:
  if (!mxIsChar(prhs[0])) {
     mexErrMsgIdAndTxt(ERR_ID "BadFileName",
     ERR_HEAD "1st input must be the file name.");
  }
  NameLen = mxGetNumberOfElements(prhs[0]);
  Name    = (wchar_t *) mxMalloc((NameLen + 1) * sizeof(mxChar));
  if (Name == NULL) {
     mexErrMsgIdAndTxt(ERR_ID "NoMemory",
             ERR_HEAD "Cannot get memory for FileName.");
  }
  memcpy(Name, mxGetData(prhs[0]), NameLen * sizeof(mxChar));
  Name[NameLen] = L'\0';
  
  // Get a file or directory handle:
  H = CreateFileW(
          (LPCWSTR) Name,             // Pointer to file name
          0,                          // Access mode (GENERIC_READ)
          FILE_SHARE_READ, NULL,      // Share mode and security
          OPEN_EXISTING,              // How to create
          FILE_FLAG_BACKUP_SEMANTICS, // Attributes, accept directory
          NULL);                      // Attribute template handle
  
  mxFree(Name);                       // Release memory as soon as possible
  
  if (H == INVALID_HANDLE_VALUE) {
     mexErrMsgIdAndTxt(ERR_ID   "MissFile",
                       ERR_HEAD "File or folder is not existing!");
  }
  
  // Obtain the file times:
  Success = GetFileTime(H,
          &CreationUTC,   // Creation time as UTC
          &AccessUTC,     // Last access time as UTC
          &WriteUTC);     // Last write time as UTC
  
  // Close the file before checking success:
  CloseHandle(H);
  if (Success == 0) {
     mexErrMsgIdAndTxt(ERR_ID   "CreateFileFailed",
                       ERR_HEAD "GetFileTime[win] failed!");
  }
  
  // Create output:
  switch (OutType) {
     case STRUCT_OUT:
        plhs[0] = mxCreateStructMatrix(1, 1, 3, ReplyFields);
        Reply   = plhs[0];
        mxSetFieldByNumber(Reply, 0, 0,
                           FileTimeToDateVec_Win(&CreationUTC, TimeType));
        
        mxSetFieldByNumber(Reply, 0, 1,
                           FileTimeToDateVec_Win(&AccessUTC, TimeType));
        
        mxSetFieldByNumber(Reply, 0, 2,
                           FileTimeToDateVec_Win(&WriteUTC, TimeType));
        break;
        
     case WRITE_OUT:
        plhs[0] = FileTimeToDateVec_Win(&WriteUTC, TimeType);
        break;
        
     case ACCESS_OUT:
        plhs[0] = FileTimeToDateVec_Win(&AccessUTC, TimeType);
        break;
        
     case CREATE_OUT:
        plhs[0] = FileTimeToDateVec_Win(&CreationUTC, TimeType);
        break;
  }
  
  return;
}

// *****************************************************************************
mxArray *FileTimeToDateVec_Win(const FILETIME *UTC, enum TimeType_Enum Type)
{
  // The input UTC file time is converted to the local time according with
  // different methods. The result is converted to a Matlab date vector.
  SYSTEMTIME ST, ST2;
  FILETIME   Local;
  mxArray    *R;
  double     *DateVec;
  uint64_T   *Integer64;
          
  switch (Type) {
     case LOCAL_TIME:
        // Convert UTC FILETIME to system time:
        if (FileTimeToSystemTime(UTC, &ST2) == 0) {
           mexErrMsgIdAndTxt(ERR_ID   "BadToSystemTimeLOCAL",
                             ERR_HEAD "FILETIME to SYTEMTIME failed!");
        }
        
        // Convert UTC system time to local system time considering daylight
        // saving time at the specified time:
        if (SystemTimeToTzSpecificLocalTime(NULL, &ST2, &ST) == 0) {
           mexErrMsgIdAndTxt(ERR_ID "BadToTzSystemTime",
                   ERR_HEAD "FILETIME to specific SYTEMTIME failed!");
        }
        break;
        
     case WIN_TIME:
        // Convert UTC file time to local file time:
        if (FileTimeToLocalFileTime(UTC, &Local) == 0) {
           mexErrMsgIdAndTxt(ERR_ID "BadUTC2Local",
                   ERR_HEAD "UTC to local FILETIME failed!");
        }
        
        // Convert local file time to system time:
        if (FileTimeToSystemTime(&Local, &ST) == 0) {
           mexErrMsgIdAndTxt(ERR_ID "BadToSystemTimeWIN",
                   ERR_HEAD "FILETIME to SYTEMTIME failed!");
        }
        
        break;
        
     case UTC_TIME:
        // Convert local file time to system time:
        if (FileTimeToSystemTime(UTC, &ST) == 0) {
           mexErrMsgIdAndTxt(ERR_ID "BadToSystemTimeUTC",
                   ERR_HEAD "FILETIME to SYTEMTIME failed!");
        }
        
        break;
        
     case UTC_RAW:
        R          = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
        Integer64  = (uint64_T *) mxGetData(R);
        *Integer64 = (uint64_T) UTC->dwHighDateTime << 32 | UTC->dwLowDateTime;
        return R;
        
     default:  // Actually impossible if "enum ConversionType" is well defined:
        mexErrMsgIdAndTxt(ERR_ID "BadTypeSwitch", ERR_HEAD "Programming error!");
  }
  
  // Create a Matlab date vector (see DATEVEC):
  R          = mxCreateDoubleMatrix(1, 6, mxREAL);
  DateVec    = mxGetPr(R);
  *DateVec++ = (double) ST.wYear;
  *DateVec++ = (double) ST.wMonth;
  *DateVec++ = (double) ST.wDay;
  *DateVec++ = (double) ST.wHour;
  *DateVec++ = (double) ST.wMinute;
  *DateVec   = (double) ST.wSecond + ((double) ST.wMilliseconds) / 1000;
  
  return R;
}
