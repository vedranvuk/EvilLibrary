unit EvilWorks.System.ProcessUtils;

interface

uses
	WinApi.Windows,
    WinApi.PsApi,
	System.SysUtils;

const
{$EXTERNALSYM PROCESS_QUERY_LIMITED_INFORMATION}
	PROCESS_QUERY_LIMITED_INFORMATION = $1000;

{$EXTERNALSYM BELOW_NORMAL_PRIORITY_CLASS}
	BELOW_NORMAL_PRIORITY_CLASS = $00004000;

{$EXTERNALSYM ABOVE_NORMAL_PRIORITY_CLASS}
	ABOVE_NORMAL_PRIORITY_CLASS = $00008000;

type
	TGetProcessImageFileName  = function(hProcess: THandle; lpImageFileName: LPWSTR; nSize: DWORD): DWORD; stdcall;
	TGetProcessImageFileNameA = function(hProcess: THandle; lpImageFileName: LPSTR; nSize: DWORD): DWORD; stdcall;
	TGetProcessImageFileNameW = function(hProcess: THandle; lpImageFileName: LPWSTR; nSize: DWORD): DWORD; stdcall;

{$EXTERNALSYM GetProcessImageFileName}
function GetProcessImageFileName(hProcess: THandle; lpImageFileName: LPWSTR; nSize: DWORD): DWORD; stdcall;
{$EXTERNALSYM GetProcessImageFileNameA}
function GetProcessImageFileNameA(hProcess: THandle; lpImageFileName: LPSTR; nSize: DWORD): DWORD; stdcall;
{$EXTERNALSYM GetProcessImageFileNameW}
function GetProcessImageFileNameW(hProcess: THandle; lpImageFileName: LPWSTR; nSize: DWORD): DWORD; stdcall;

{$EXTERNALSYM AttachConsole}
function AttachConsole(dwProcessId: DWORD): BOOL; stdcall; external kernel32 name 'AttachConsole';

function GetWindowModuleName(const aHandle: HWND): string;
function GetPIDModuleName(const aProcessID: DWORD): string;

function SetWindowProcessPriorityClass(const aWindow: HWND; const aPriority: cardinal): boolean;
function GetWindowProcessPriorityClass(const aWindow: HWND): cardinal;

function GetProcessIDs: TArray<DWORD>;

implementation

uses
	EvilWorks.System.SysUtils;

const
	PsApi = 'PSAPI.dll';

var
	hPSAPI                   : THandle;
	hKernel32                : THandle;
	_GetProcessImageFileName : TGetProcessImageFileName;
	_GetProcessImageFileNameA: TGetProcessImageFileNameA;
	_GetProcessImageFileNameW: TGetProcessImageFileNameW;

function CheckStubsLoaded: boolean;
begin
	if (hPSAPI = 0) then
	begin
		hPSAPI := LoadLibrary('PSAPI.dll');
		if (hPSAPI < 32) then
		begin
			hPSAPI := 0;
			Result := False;
			Exit;
		end;
		// Kernel32.lib on Windows 7 and Windows Server 2008 R2;
		// Psapi.lib if PSAPI_VERSION=1 on Windows 7 and Windows Server 2008 R2;
		// Psapi.lib on Windows Server 2008, Windows Vista, Windows Server 2003, and Windows XP/2000
		@_GetProcessImageFileName  := GetProcAddress(hPSAPI, 'GetProcessImageFileNameW');
		@_GetProcessImageFileNameA := GetProcAddress(hPSAPI, 'GetProcessImageFileNameA');
		@_GetProcessImageFileNameW := GetProcAddress(hPSAPI, 'GetProcessImageFileNameW');
	end;

	if (Assigned(_GetProcessImageFileName) = False) then
	begin
		hKernel32 := LoadLibrary(kernel32);
		if (hKernel32 < 32) then
		begin
			hKernel32 := 0;
			Result    := False;
			Exit;
		end;
		@_GetProcessImageFileName  := GetProcAddress(hKernel32, 'GetProcessImageFileNameW');
		@_GetProcessImageFileNameA := GetProcAddress(hKernel32, 'GetProcessImageFileNameA');
		@_GetProcessImageFileNameW := GetProcAddress(hKernel32, 'GetProcessImageFileNameW');
	end;
	Result := True;
end;

function GetProcessImageFileName(hProcess: THandle; lpImageFileName: LPWSTR; nSize: DWORD): DWORD;
begin
	if (CheckStubsLoaded) then
		Result := _GetProcessImageFileName(hProcess, lpImageFileName, nSize)
	else
		Result := 0;
end;

function GetProcessImageFileNameA(hProcess: THandle; lpImageFileName: LPSTR; nSize: DWORD): DWORD;
begin
	if (CheckStubsLoaded) then
		Result := _GetProcessImageFileNameA(hProcess, lpImageFileName, nSize)
	else
		Result := 0;
end;

function GetProcessImageFileNameW(hProcess: THandle; lpImageFileName: LPWSTR; nSize: DWORD): DWORD;
begin
	if (CheckStubsLoaded) then
		Result := _GetProcessImageFileNameW(hProcess, lpImageFileName, nSize)
	else
		Result := 0;
end;

{ Gets filename of the executable to which a window belongs. }
function GetWindowModuleName(const aHandle: HWND): string;
var
	processID    : DWORD;
	processHandle: THandle;
	moduleArray  : array of hModule;
	arrayLen     : DWORD;
	len          : DWORD;
begin
	Result    := '';
	processID := 1;
	GetWindowThreadProcessId(aHandle, @processID);
	processHandle := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, processID);
	if (processHandle <= 0) then
		RaiseLastOSError;
	EnumProcessModules(processHandle, nil, 0, arrayLen);
	SetLength(moduleArray, arrayLen div SizeOf(moduleArray[0]));
	if (EnumProcessModules(processHandle, PDWord(@moduleArray[0]), arrayLen, arrayLen) = False) then
		RaiseLastOSError;
	SetLength(Result, MAX_PATH);
	len := GetModuleFileNameEx(processHandle, moduleArray[0], PChar(Result), Length(Result));
	if (len > 0) then
		SetLength(Result, len);
	CloseHandle(processHandle);
end;

{ Gets filename of the executable for a Process ID. }
function GetPIDModuleName(const aProcessID: DWORD): string;
var
	processHandle: THandle;
	ret          : DWORD;
	buffer       : PChar;
begin
	Result := '';
	if (aProcessID = 0) then
		Exit('<Unknown>');
	processHandle := OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION or PROCESS_VM_READ, False, aProcessID);
	if (processHandle <= 0) then
	begin
		ret := GetLastError;
		if (ret = ERROR_ACCESS_DENIED) then
			Exit('System');
		RaiseLastOSError;
	end;
	buffer := AllocMem(MAX_PATH);
	ret    := GetModuleFileNameEx(processHandle, 0, buffer, MAX_PATH);
	CloseHandle(processHandle);
	if (ret = 0) then
	begin
		FreeMem(buffer);
		RaiseLastOSError;
	end
	else
	begin
		SetString(Result, buffer, ret);
		FreeMem(buffer);
	end;
end;

{ Sets priority of the process that owns the aWindow .}
function SetWindowProcessPriorityClass(const aWindow: HWND; const aPriority: cardinal): boolean;
var
	processID    : DWORD;
	processHandle: THandle;
begin
	Result := False;

	processID := 1;
	GetWindowThreadProcessId(aWindow, @processID);

	processHandle := OpenProcess(PROCESS_SET_INFORMATION, False, processID);
	if (processHandle = 0) then
		Exit;

	Result := SetPriorityClass(processHandle, aPriority);
end;

{ Gets priority of the process that owns the aWindow. If failed returns 0. }
function GetWindowProcessPriorityClass(const aWindow: HWND): cardinal;
var
	processID    : DWORD;
	processHandle: THandle;
begin
	Result := 0;

	processID := 1;
	GetWindowThreadProcessId(aWindow, @processID);

	if (TOSVersion.Check(6)) then
		processHandle := OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, False, processID)
	else
		processHandle := OpenProcess(PROCESS_QUERY_INFORMATION, False, processID);

	if (processHandle = 0) then
		Exit;

	Result := GetPriorityClass(processHandle);
end;

{ Retrieves the process identifier for each process object in the system. }
function GetProcessIDs: TArray<DWORD>;
var
	numReturned: DWORD;
begin
	SetLength(Result, 1024);

	if (EnumProcesses(@Result[0], Length(Result) * SizeOf(DWORD), numReturned) = False) then
		SetLength(Result, 0)
	else if (numReturned > 0) then
		SetLength(Result, numReturned div SizeOf(DWORD));
end;

end.
