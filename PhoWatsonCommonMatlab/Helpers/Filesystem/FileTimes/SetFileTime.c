// SetFileTime.c
// Set Creation, Access, or Write time of a file
// On NTFS file systems, creation, access and write time are stored for each
// file. SetFileTime can set these times for writable files.
//
// SetFileTime(FileName, TimeSpec, Time, Type)
// INPUT:
//   FileName: String, file or folder name with or without absolute or relative
//             path. Unicode names are considered.
//   TimeSpec: String specifying the time type to set:
//               'Creation': Time of creation,
//               'Access':   Time of last access,
//               'Write':    Time of last modification.
//   Time:     Current local time as [1 x 6] double vector in DATEVEC format,
//             e.g. as replied from CLOCK. Milliseconds are considered.
//             The time is converted to UTC.
//   Type:     String, type of the conversion from local time to UTC file time.
//             Optional, default: "Local". Just the 1st character matters.
//             "Local":   The file time is converted from the local time
//                        considering the daylight saving setting of the
//                        specific time.
//             "Windows": The time conversion considers the current daylight
//                        saving time as usual for Windows (e.g. the Windows
//                        Explorer). If the daylight saving changes, the file
//                        times can change also.
//             "UTC":     The input is written as UTC time without a conversion.
//             "native":  Time as UINT64 (0.1 mysec ticks since 01-Jan-1601).
//
// OUTPUT:
//   none.
//
// The function stops with an error if:
//   - the file does not exist or cannot be opened in write mode,
//   - the time conversions fail,
//   - the number or type of inputs/outputs is wrong.
//
// EXAMPLE:
//   File = tempname;
//   FID = fopen(File, 'w'); fclose(FID);
//   D = dir(File)
//   SetFileTime(File, 'Write', [2009, 12, 24, 16, 32, 29]);
//   D = dir(File)
//
// NOTES:
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
// Compilation of MEX source (after "mex -setup" on demand):
//   Not compatible with LCC2.4 shipped with Matlab!
//   Windows: mex -O SetFileTime.c
//   Linux:   mex -O CFLAGS="\$CFLAGS -std=c99" SetFileTime.c
// Precompiled MEX files can be found at: http://www.n-simon.de/mex
//
// Tested: Matlab 6.5, 7.7, 7.8, WinXP, 32bit
//         Compiler: LCC/3.8, OWC1.8, MSVC2008
// Assumed Compatibility: higher Matlab versions, 64bit
// Author: Jan Simon, Heidelberg, (C) 2007-2011 matlab.THISYEAR(a)nMINUSsimon.de
//
// See also: DIR, CLOCK, DATEVEC, DATESTR, GetFileTime.

/*
% $JRev: R-B V:027 Sum:n85jQPzXkBC/ Date:21-Jun-2011 22:19:58 $
% $License: BSD (use/copy/change/redistribute on own risk, mention the author) $
% $UnitTest: uTest_FileTime $
% $File: Tools\Mex\Source\SetFileTime.c $
% History:
% 001: 21-Aug-2007 00:37, Initial version.
% 008: 09-Jul-2009 00:35, Input TimeSpec: 'Modification' -> 'Write'.
% 011: 10-Nov-2009 11:01, UTC->Local/Windows/UTC conversion.
% 012: 15-Nov-2009 00:43, Works with directories also now.
% 020: 24-Sep-2010 08:51, Unicode file names, 64bit compatible.
% 022: 13-Oct-2010 00:16, The old example had an invalid date.
% 027: 21-Jun-2011 20:53, Native UINT64 time input.
*/

#if defined(__WINDOWS__) || defined(WIN32) || defined(_WIN32) || defined(_WIN64)
#include <windows.h>
#else
#error Implemented for Windows only now!
#endif

#include "mex.h"
#include <math.h>
#include <wchar.h>

// Assume 32 bit addressing for Matlab 6.5:
// See MEX option "compatibleArrayDims" for MEX in Matlab >= 7.7.
#ifndef MWSIZE_MAX
#define mwSize  int32_T           // Defined in tmwtypes.h
#define mwIndex int32_T
#define MWSIZE_MAX MAX_int32_T
#endif

#if defined(__LCC__)
typedef unsigned long long uint64_T;
#endif

// Error messages do not contain the function name in Matlab 6.5! This is not
// necessary in Matlab 7, but it does not bother:
#define ERR_ID   "JSimon:SetFileTime:"
#define ERR_HEAD "*** SetFileTime[mex]: "

// Enumerator for types of time conversion:
typedef enum {WIN_TIME, LOCAL_TIME, UTC_TIME, RAW_TIME} ConversionType_t;

// Prototypes:
void DropError(const char *ErrorID, const char *Msg, HANDLE *H);

// Main function ===============================================================
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  wchar_t    *Name;
  mwSize     NameLen;
  char       TimeSpec, TypeIn;
  double     *Time, Second;
  uint64_T   Time64;
  HANDLE     H;
  FILETIME   localT, utcT;
  SYSTEMTIME ST, ST2;
  BOOL       Success, doubleTimeIn = true;
  
  // Default: Use conversion with DST at the specified date and time:
  ConversionType_t Type = LOCAL_TIME;
  
  // Get 4th input, if it is used: ---------------------------------------------
  if (nrhs == 4) {
    // Check type of 4th input:
    if (!mxIsChar(prhs[3]) || mxGetNumberOfElements(prhs[3]) == 0) {
      mexErrMsgIdAndTxt(ERR_ID "BadType",
                    ERR_HEAD "SetFileTime: 4th input [Type] must be a string.");
    }
    
    // "W" for "Windows", "U" for "UTC", "L" for real local time (default):
    TypeIn = (char) tolower(*(char *)mxGetData(prhs[3]));
    if (TypeIn == 'w') {          // As Windows: Adjust to current DST
      Type = WIN_TIME;
    } else if (TypeIn == 'u')  {  // UTC time: Not affected by DST
      Type = UTC_TIME;
    } else if (TypeIn == 'n')  {  // UTC raw: Not affected by DST, UINT64
      Type         = RAW_TIME;
      doubleTimeIn = false;
    } else if (TypeIn != 'l')  {  // Local DST of time
      mexErrMsgIdAndTxt(ERR_ID   "BadInput4",
                        ERR_HEAD "Unknown time type.");
    }
    
  } else if (nrhs != 3) {
    mexErrMsgIdAndTxt(ERR_ID   "BadNInput",
                      ERR_HEAD "3 or 4 inputs required.");
  }
  
  // Type and size of input arguments: -----------------------------------------
  if (!mxIsChar(prhs[0])) {
    mexErrMsgIdAndTxt(ERR_ID   "BadName",
                      ERR_HEAD "1st input must be the file name.");
  }
  if (!mxIsChar(prhs[1]) || mxIsEmpty(prhs[1])) {
    mexErrMsgIdAndTxt(ERR_ID   "BadTimeSpec",
                      ERR_HEAD "2nd input is no time specifier.");
  }
  if (doubleTimeIn) {
    if (!mxIsDouble(prhs[2]) || mxGetNumberOfElements(prhs[2]) != 6) {
      mexErrMsgIdAndTxt(ERR_ID   "BadDateVector",
                        ERR_HEAD "3rd input must be a date vector.");
    }
  } else if(!mxIsUint64(prhs[2]) && mxGetNumberOfElements(prhs[2]) != 1) {
    mexErrMsgIdAndTxt(ERR_ID   "BadDateNumber",
                      ERR_HEAD "3rd input must be a scalar UINT64.");
  }
  
  // Check number of outputs: --------------------------------------------------
  if (nlhs != 0) {
    mexErrMsgIdAndTxt(ERR_ID   "BadNOutput",
                      ERR_HEAD "No outputs allowed.");
  }
  
  // Get the file name: --------------------------------------------------------
  NameLen = mxGetNumberOfElements(prhs[0]);
  Name    = (wchar_t *) mxMalloc((NameLen + 1) * sizeof(mxChar));
  if (Name == NULL) {
    mexErrMsgIdAndTxt(ERR_ID   "NoMemory",
                      ERR_HEAD "Cannot get memory for file name.");
  }
  memcpy(Name, mxGetData(prhs[0]), NameLen * sizeof(mxChar));
  Name[NameLen] = L'\0';
  
  // Get a file handle: --------------------------------------------------------
  // Call DropError afterwards in case of errors to close the handle!
  H = CreateFileW(
        (LPCWSTR) Name,             // pointer to name of the file
        GENERIC_WRITE,              // access (read-write) mode
        FILE_SHARE_READ, NULL,      // share mode and security
        OPEN_EXISTING,              // do not create
        FILE_FLAG_BACKUP_SEMANTICS, // attributes
        NULL);                      // attribute template handle
  
  mxFree(Name);                     // Release as soon as possible
  
  if (H == INVALID_HANDLE_VALUE) {
     DropError(ERR_ID   "MissingFile",
               ERR_HEAD "File is not existing or a folder.", H);
  }
  
  // Get time specificator and time: -------------------------------------------
  TimeSpec = (char) tolower(*(char *) mxGetData(prhs[1]));
  
  // Create system time struct containing local time:
  if (doubleTimeIn) {
    // Special rounding for milliseconds, split seconds as integer part:
    Time       = mxGetPr(prhs[2]);
    ST.wMilliseconds = (WORD) (modf(Time[5], &Second) * 1000 + 0.5);
    ST.wYear   = (WORD) Time[0];
    ST.wMonth  = (WORD) Time[1];
    ST.wDay    = (WORD) Time[2];
    ST.wHour   = (WORD) Time[3];
    ST.wMinute = (WORD) Time[4];
    ST.wSecond = (WORD) Second;   // AFTER wMilliseconds due to modf call !!!
  }
  
  // Convert input date to UTC with different methods:
  switch (Type) {
    case LOCAL_TIME:
      // Convert UTC FILETIME to system time:
      if (TzSpecificLocalTimeToSystemTime(NULL, &ST, &ST2) == 0) {
        DropError(ERR_ID   "BadLocal_UTC2SysTime",
                  ERR_HEAD "Specific SYSTEMTIME to UTC failed. Invalid date?",
                  H);
      }
      
      // UTC system time to UTC file time:
      if (SystemTimeToFileTime(&ST2, &utcT) == 0) {
        DropError(ERR_ID   "BadLocal_Sys2FileTime",
                  ERR_HEAD "Time to FILETIME failed!", H);
      }
      break;
      
    case WIN_TIME:
      // System to FILETIME:
      if (SystemTimeToFileTime(&ST, &localT) == 0) {
        DropError(ERR_ID   "BadWin_Sys2FileTime",
                  ERR_HEAD "Time to FILETIME failed. Invalid date?", H);
      }
      
      // Local time to UTC with current DST value:
      if (LocalFileTimeToFileTime(&localT, &utcT) == 0) {
        DropError(ERR_ID   "BadWin_Local2UTC",
                  ERR_HEAD "Local to UTC FILETIME failed!", H);
      }
      break;
      
    case UTC_TIME:
      // System to FILETIME, input is UTC already:
      if (SystemTimeToFileTime(&ST, &utcT) == 0) {
        DropError(ERR_ID   "BadUTC_Sys2FileTime",
                  ERR_HEAD "Time to FILETIME failed. Invalid date?", H);
      }
      break;
      
    case RAW_TIME:
      // UINT64 to FileTime:
      Time64              = *(uint64_T *) mxGetData(prhs[2]);
      utcT.dwHighDateTime = (DWORD) ((Time64 >> 32) & 0xFFFFFFFF);
      utcT.dwLowDateTime  = (DWORD) (Time64 & 0xFFFFFFFF);
      break;

    default:
      DropError(ERR_ID   "BadTypeSwitch",
                ERR_HEAD "Bad switch type - programming error!", H);
  }
  
  // Set the file time: --------------------------------------------------------
  if (TimeSpec == 'c') {
    Success = SetFileTime(H, &utcT, NULL, NULL);
  } else if (TimeSpec == 'a') {
    Success = SetFileTime(H, NULL, &utcT, NULL);
  } else if (TimeSpec == 'w') {
    Success = SetFileTime(H, NULL, NULL, &utcT);
  } else {
    DropError(ERR_ID "BadTimeSpec", ERR_HEAD "Bad TimeSpec!", H);
  }
  
  // Close the file before checking success:
  CloseHandle(H);

  if (Success == 0) {
    mexErrMsgIdAndTxt(ERR_ID   "SetTimeFailed",
                      ERR_HEAD "Windows-API call SetFileTime failed.");
  }
    
  return;
}

// =============================================================================
void DropError(const char *ErrorID, const char *Msg, HANDLE *H)
{
  // Close handle before stopping with an error:
  CloseHandle(H);
  mexErrMsgIdAndTxt(ErrorID, Msg);
}
