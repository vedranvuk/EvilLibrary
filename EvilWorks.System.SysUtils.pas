//
// EvilLibrary by Vedran Vuk 2010-2012
//
// Name: 					EvilWorks.System.SysUtils
// Description: 			Stuff I'd like to see in Delphi's SysUtils. And more.
// File last change date:   October 1st. 2012
// File version: 			Dev 0.0.0
//

unit EvilWorks.System.SysUtils;

interface

uses
	WinApi.Windows,
	WinApi.Messages,
	System.SysUtils;

{ Error retrieval }

function GetErrorText(const aError: cardinal): string;
function GetLastErrorText: string;

{ Dialog boxes }

procedure ShowMessage(const aMessage: string);
procedure ShowInformation(const aInformation: string);
procedure ShowWarning(const aWarning: string);
procedure ShowError(const aError: string);
procedure ShowLastError(const aCustomMessage: string = '');

{ Window properties }

function GetWindowFileName(const aWindow: HWND): string;
function GetWindowCaption(const aWindow: HWND): string;
function GetWindowClassName(const aWindow: HWND): string;
function GetWindowShowState(const aWindow: HWND): integer;
function GetWindowIcon(const aWindow: HWND; const aBigIcon: boolean = False): HICON;
function GetWindowAppIcon(const aWindow: HWND; const aBigIcon: boolean = False): HICON;
function GetWindowHeight(const aWindow: HWND): integer;
function GetWindowWidth(const aWindow: HWND): integer;
function SetWindowHeight(const aWindow: HWND; const aHeight: integer): boolean;
function SetWindowWidth(const aWindow: HWND; const aWidth: integer): boolean;
function IsWindowResizeable(const aWindow: HWND): integer;

{ Window manipulation }

function RestoreWindowWithoutAnimations(const aWindow: HWND): boolean;
function FindChildWindow(const aParent: HWND; const aClsName, aWndName: string; const aID: integer): HWND;
function GetFileVersion(const aFileName: string): string;

{ Keyboard shortcut utilities }

procedure SeparateShortcut(const aShortcut: cardinal; var aKey, aModifier: Word);
function IsKeyPressed(aKey: Word): boolean;
function IsModifierPressed(aModifier: Word): boolean;
function KeyToText(aKey: Word): string;
function ModifiersToText(aModifiers: Word): string;
function ShortcutToText(const aKey, aModifiers: Word): string; overload;
function ShortcutToText(const aShortcut: cardinal): string; overload;
function IsShortcutReserved(const aModifiers, aKey: Word): boolean; overload;
function IsShortcutReserved(const aShortcut: cardinal): boolean; overload;

{ TODO: Sort us. }

function NumElementsInSet(var aSet): Byte;

function RandomRange(const aMin, aMax: integer): integer;
function RandomBool: boolean;

function HexToText(const aHexStr: string): string;
function HexToDec(const aHexStr: string): cardinal;

function BytesToFriendlyString(Value: Dword): string;
function BitsToFriendlyString(Value: Dword): string;

function GetSelfFileName: string;
function GetSelfFileNameOnly: string;
function GetSelfDir: string;
function GetSelfPath: string;
function GetWindowsDir: string;
function GetWindowsPath: string;
function GetSystemDir: string;
function GetSystemPath: string;

function RemoveExtension(const aFileName: string): string;
function ExtractFileNameOnly(const aFileName: string): string;
function ExtractFileDirOnly(const aFileName: string): string;
function ExtractLastPathElement(const aFileName: string): string;
function ExtractParentDir(const aFileName: string): string;
function ExtractParentPath(const aFileName: string): string;

function ExpandEnvironmentVariable(const aString: string): string;
function ExpandEnvironmentVariables(const aString: string): string;

function GetLayeredWindowAttributes(
  HWND: HWND; var crKey: COLORREF; var bAlpha: byte; var dwFlags: DWORD
  ): BOOL; stdcall; external user32 name 'GetLayeredWindowAttributes';

function SetLayeredWindowAttributes(
  HWND: HWND; crKey: COLORREF; bAlpha: byte; dwFlags: DWORD
  ): BOOL; stdcall; external user32 name 'SetLayeredWindowAttributes';

type
	TOnOutput = procedure(const aOutput: string) of object;

procedure RunConsoleApp(const aTarget, aParams, aRunIn: string; aOutputProc: TOnOutput);

implementation

uses
	EvilWorks.System.StrUtils;

{ Retrieves description for a specified Windows error. }
function GetErrorText(const aError: cardinal): string;
var
	buffer: array [0 .. 255] of char;
	flags : DWORD;
begin
	FillChar(buffer, 256, #0);
	flags := FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_IGNORE_INSERTS or FORMAT_MESSAGE_ARGUMENT_ARRAY;
	FormatMessage(flags, nil, aError, 0, buffer, SizeOf(buffer), nil);
	Result := TextRemoveLineFeeds(buffer);
end;

{ Retrieves last Windows error description.}
function GetLastErrorText: string;
begin
	Result := GetErrorText(WinApi.Windows.GetLastError);
end;

{ Displays a message dialog. }
procedure ShowMessage(const aMessage: string);
begin
	MessageBox(0, PChar(aMessage), PChar(GetSelfFileName), MB_OK);
end;

{ Displays an information dialog. }
procedure ShowInformation(const aInformation: string);
begin
	MessageBox(0, PChar(aInformation), PChar(GetSelfFileName), MB_ICONINFORMATION or MB_OK);
end;

{ Displays a warning dialog. }
procedure ShowWarning(const aWarning: string);
begin
	MessageBox(0, PChar(aWarning), PChar(GetSelfFileName), MB_ICONWARNING or MB_OK);
end;

{ Displays an error dialog. }
procedure ShowError(const aError: string);
begin
	MessageBox(0, PChar(aError), PChar(GetSelfFileName), MB_ICONERROR or MB_OK);
end;

{ Displays last windows error description with optional custom message. }
procedure ShowLastError(const aCustomMessage: string = '');
begin
	if (aCustomMessage <> '') then
		ShowError(aCustomMessage + #13#10#10#10 + GetLastErrorText)
	else
		ShowError(GetLastErrorText);
end;

{ GetWindowModuleFilename wrapper. }
function GetWindowFileName(const aWindow: HWND): string;
var
	buf: PChar;
	ret: integer;
begin
	Result := '';

	buf := AllocMem(MAX_PATH + 1);
	if (buf = nil) then
		Exit;
	try
		ret := GetWindowModuleFileName(aWindow, buf, MAX_PATH);
		SetString(Result, buf, ret);
	finally
		FreeMem(buf);
	end
end;

{ Gets window caption. }
function GetWindowCaption(const aWindow: HWND): string;
var
	buf: PChar;
	ret: integer;
begin
	Result := '';

	buf := AllocMem(MAX_PATH + 1);
	if (buf = nil) then
		Exit;
	try
		ret := GetWindowText(aWindow, buf, MAX_PATH);
		SetString(Result, buf, ret);
	finally
		FreeMem(buf);
	end;
end;

{ Gets window class name. }
function GetWindowClassName(const aWindow: HWND): string;
var
	buf: PChar;
	ret: integer;
begin
	Result := '';

	buf := AllocMem(MAX_PATH + 1);
	if (buf = nil) then
		Exit;
	try
		ret := GetClassName(aWindow, buf, MAX_PATH);
		SetString(Result, buf, ret);
	finally
		FreeMem(buf);
	end;
end;

{ Gets window show state (SW_SHOW, SW_MINIMIZED, SW_MAXIMIZED...). Returns -1 if function failed. }
function GetWindowShowState(const aWindow: HWND): integer;
var
	winPl: TWindowPlacement;
begin
	winPl.Length := SizeOf(winPl);
	if (GetWindowPlacement(aWindow, winPl)) then
		Result := winPl.showCmd
	else
		Result := - 1;
end;

{ Tries to retrieve the icon of a aWindow. }
function GetWindowIcon(const aWindow: HWND; const aBigIcon: boolean = False): HICON;
begin
	if (aBigIcon) then
		Result := SendMessage(aWindow, WM_GETICON, 1, 0)
	else
		Result := SendMessage(aWindow, WM_GETICON, 0, 0);
end;

{ Tries to retrieve the icon of the app that owns the aWindow. }
function GetWindowAppIcon(const aWindow: HWND; const aBigIcon: boolean = False): HICON;
begin
	Result := 0;
end;

{ Gets window Height. - 1 on error. }
function GetWindowHeight(const aWindow: HWND): integer;
var
	R: TRect;
begin
	if (GetWindowRect(aWindow, R)) then
		Result := R.Height
	else
		Result := - 1;
end;

{ Gets window Width. - 1 on error. }
function GetWindowWidth(const aWindow: HWND): integer;
var
	R: TRect;
begin
	if (GetWindowRect(aWindow, R)) then
		Result := R.Width
	else
		Result := - 1;
end;

{ Sets window Height. }
function SetWindowHeight(const aWindow: HWND; const aHeight: integer): boolean;
var
	w: integer;
begin
	w := GetWindowWidth(aWindow);
	if (w <> - 1) then
		Result := SetWindowPos(aWindow, 0, 0, 0, w, aHeight, SWP_NOMOVE or SWP_NOZORDER)
	else
		Result := False;
end;

{ Gets window Width. }
function SetWindowWidth(const aWindow: HWND; const aWidth: integer): boolean;
var
	h: integer;
begin
	h := GetWindowHeight(aWindow);
	if (h <> - 1) then
		Result := SetWindowPos(aWindow, 0, 0, 0, aWidth, h, SWP_NOMOVE or SWP_NOZORDER)
	else
		Result := False;
end;

{ Tries to guess if the window has a sizeable border. Returns 1 if yes, 0 if no, -1 if error occured. }
function IsWindowResizeable(const aWindow: HWND): integer;
var
	gwl: longint;
	sb : HWND;
begin
	gwl := GetWindowLong(aWindow, GWL_STYLE);

	if (gwl = 0) then
		Exit( - 1);

	if (gwl and WS_SIZEBOX <> 0) or (gwl and WS_THICKFRAME <> 0) then
		Exit(1);

	sb := FindWindowEx(aWindow, 0, 'ScrollBar', nil);
	if (sb = 0) then
		Exit(0);

	gwl := GetWindowLong(sb, GWL_EXSTYLE);
	if (gwl = 0) then
		Exit( - 1);

	if (gwl and SBS_SIZEGRIP <> 0) then
		Result := 1
	else
		Result := 0;
end;

{ Recursively searches a window and its children for a child window. }
function FindChildWindow(const aParent: HWND; const aClsName, aWndName: string; const aID: integer): HWND;
// -----------------------------------------------------------------------------------------------------------
//
// Recursivy searches a window and its children for a window with a matching
// ClassName, WindowName and ControlID. Any ommited parameters to be compared are
// a match by default. If all three parameters are ommited, the first child
// found is the result.
//
// aParent: HWND - Handle of the parent window to search.
// aClassName: string - Class name of the child window to find.
// aWindowName: string - Window name of the child window to find.
// aID: integer - Dialog control ID of the child window to find.
//
// -----------------------------------------------------------------------------------------------------------
type
	TEnumChildRec = record
		ClassName: string;
		WindowName: string;
		ControlID: integer;
		ChildHandle: HWND;
	end;

	PEnumChildRec = ^TEnumChildRec;

	function EnumChildProc(aHandle: HWND; aLParam: LPARAM): boolean; stdcall;
	var
		data     : PEnumChildRec;
		passClass: boolean;
		passName : boolean;
		passID   : boolean;
	begin
		if (aHandle = 0) or (aLParam = 0) then
			Exit(False);

		data := PEnumChildRec(aLParam);
		if ((data.ClassName = '') and (data.WindowName = '') and (data.ControlID = 0)) then
		begin
			data^.ChildHandle := aHandle;
			Exit(False);
		end;

		if (data.ClassName = '') then
			passClass := True
		else
			passClass := TextEquals(GetWindowClassName(aHandle), data^.ClassName);

		if (data.WindowName = '') then
			passName := True
		else
			passName := TextEquals(GetWindowCaption(aHandle), data^.WindowName);

		if (data.ControlID = 0) then
			passID := True
		else
			passID := GetDlgCtrlID(aHandle) = data.ControlID;

		if (passClass and passName and passID) then
		begin
			data^.ChildHandle := aHandle;
			Exit(False);
		end
		else
		begin
			data^.ChildHandle := FindChildWindow(aHandle, data^.ClassName, data^.WindowName, data^.ControlID);
			if (data^.ChildHandle = 0) then
				Result := True
			else
				Result := False;
		end;
	end;

var
	EnumChildRec: TEnumChildRec;
begin
	Result := 0;

	EnumChildRec.ClassName   := aClsName;
	EnumChildRec.WindowName  := aWndName;
	EnumChildRec.ControlID   := aID;
	EnumChildRec.ChildHandle := 0;

	EnumChildWindows(aParent, @EnumChildProc, LPARAM(@EnumChildRec));

	if (EnumChildRec.ChildHandle <> 0) then
		Result := EnumChildRec.ChildHandle;
end;

{ Restores a window without window animations (if enabled). }
function RestoreWindowWithoutAnimations(const aWindow: HWND): boolean;
var
	ai    : TAnimationInfo;
	aiTemp: TAnimationInfo;
begin
	Result := False;

	FillChar(ai, SizeOf(ai), 0);
	ai.cbSize := SizeOf(ai);
	if (SystemParametersInfo(SPI_GETANIMATION, SizeOf(ai), @ai, 0)) then
	begin
		if (ai.iMinAnimate <> 0) then
		begin
			FillChar(aiTemp, SizeOf(aiTemp), 0);
			aiTemp.cbSize      := SizeOf(aiTemp);
			aiTemp.iMinAnimate := 0;
			SystemParametersInfo(SPI_SETANIMATION, SizeOf(aiTemp), @aiTemp, 0);
		end;

		Result := ShowWindow(aWindow, SW_RESTORE);
		if (ai.iMinAnimate <> 0) then
			Result := Result and SystemParametersInfo(SPI_SETANIMATION, SizeOf(ai), @ai, 0);
	end;
end;

{ Gets executable file version info }
function GetFileVersion(const aFileName: string): string;
var
	VerInfoSize : DWORD;
	VerInfo     : Pointer;
	VerValueSize: DWORD;
	VerValue    : PVSFixedFileInfo;
	Dummy       : DWORD;
	s           : shortstring;
begin
	Result      := '';
	VerInfoSize := GetFileVersionInfoSize(PChar(aFileName), Dummy);
	if (VerInfoSize = 0) then
		Exit;
	GetMem(VerInfo, VerInfoSize);
	GetFileVersionInfo(PChar(aFileName), 0, VerInfoSize, VerInfo);
	VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
	with VerValue^ do
	begin
		Str(dwFileVersionMS shr 16, s);
		Result := string(s);
		Str(dwFileVersionMS and $FFFF, s);
		Result := Result + '.' + string(s);
		Str(dwFileVersionLS shr 16, s);
		Result := Result + '.' + string(s);
		Str(dwFileVersionLS and $FFFF, s);
		Result := Result + '.' + string(s);
	end;
	FreeMem(VerInfo, VerInfoSize);
end;

{ Separates aShortcut into aKey and aModifier parts. }
procedure SeparateShortcut(const aShortcut: cardinal; var aKey, aModifier: Word);
begin
	aKey      := Word(aShortcut);
	aModifier := HiWord(aShortcut);
end;

{ Checks if aKey on the keyboard is pressed. }
function IsKeyPressed(aKey: Word): boolean;
begin
	Result := (GetAsyncKeyState(aKey) and (1 shl 15) <> 0);
end;

{ Checks if keyboard modifier (MOD_SHIFT, MOD_CTRL, MOD_ALT, MOD_WIN) is pressed. }
function IsModifierPressed(aModifier: Word): boolean;
begin
	Result := False;

	case aModifier of

		MOD_SHIFT:
		Result := (IsKeyPressed(VK_LSHIFT) or IsKeyPressed(VK_RSHIFT) or IsKeyPressed(VK_SHIFT));

		MOD_CONTROL:
		Result := (IsKeyPressed(VK_LCONTROL) or IsKeyPressed(VK_RCONTROL) or IsKeyPressed(VK_CONTROL));

		MOD_ALT:
		Result := (IsKeyPressed(VK_LMENU) or IsKeyPressed(VK_RMENU) or IsKeyPressed(VK_MENU));

		MOD_WIN:
		Result := (IsKeyPressed(VK_LWIN) or IsKeyPressed(VK_RWIN) or IsKeyPressed(VK_APPS));

	end; { case }
end;

{ Returns a text representation of a keyboard key in current system locale. }
function KeyToText(aKey: Word): string;

	function LocalIsExtendedKey(Key: Word): boolean;
	begin
		Result := ((Key >= VK_BROWSER_BACK) and (Key <= VK_LAUNCH_APP2)) or (aKey in [VK_LWIN, VK_RWIN]);
	end;

	function LocalGetExtendedVKName(aKey: Word): string;
	begin
		case aKey of

			VK_LWIN, VK_RWIN:
			Result := 'Win';

			VK_BROWSER_BACK:
			Result := 'Browser Back';

			VK_BROWSER_FORWARD:
			Result := 'Browser Forward';

			VK_BROWSER_REFRESH:
			Result := 'Browser Refresh';

			VK_BROWSER_STOP:
			Result := 'Browser Stop';

			VK_BROWSER_SEARCH:
			Result := 'Browser Search';

			VK_BROWSER_FAVORITES:
			Result := 'Browser Favorites';

			VK_BROWSER_HOME:
			Result := 'Browser Home';

			VK_VOLUME_MUTE:
			Result := 'Volume Mute';

			VK_VOLUME_DOWN:
			Result := 'Volume Down';

			VK_VOLUME_UP:
			Result := 'Volume Up';

			VK_MEDIA_NEXT_TRACK:
			Result := 'Media Next Track';

			VK_MEDIA_PREV_TRACK:
			Result := 'Media Prev Track';

			VK_MEDIA_STOP:
			Result := 'Media Stop';

			VK_MEDIA_PLAY_PAUSE:
			Result := 'Media Play/Pause';

			VK_LAUNCH_MAIL:
			Result := 'Media Launch Mail';

			VK_LAUNCH_MEDIA_SELECT:
			Result := 'Media Sect';

			VK_LAUNCH_APP1:
			Result := 'Media Launch App 1';

			VK_LAUNCH_APP2:
			Result := 'Media Launch App 2';

			else
			Result := '';

		end; { case }
	end;

	function LocalGetVKName(aSpecial: boolean): string;
	var
		ScanCode: cardinal;
		KeyName : array [0 .. 255] of char;
	begin
		Result := '';
		if (aSpecial) then
			ScanCode := (MapVirtualKey(byte(aKey), 0) shl 16) or (1 shl 24)
		else
			ScanCode := (MapVirtualKey(byte(aKey), 0) shl 16);

		if (ScanCode <> 0) then
			if (GetKeyNameText(ScanCode, KeyName, 255) <> 0) then
				Result := KeyName;

		if (Length(Result) <= 1) then
			if (LocalIsExtendedKey(aKey)) then
				Result := LocalGetExtendedVKName(aKey);
	end;

var
	KeyName: string;
begin
	case byte(aKey) of
		$21 .. $28, $2D, $2E:
		KeyName := LocalGetVKName(True);
		else
		KeyName := LocalGetVKName(False);
	end;
	Result := KeyName;
end;

{ Returns modifiers in a format for HotKey controls:  "[Modifier1 + [Modifier2 + ]"... }
function ModifiersToText(aModifiers: Word): string;
const
	SPlus = ' + ';
begin
	if (aModifiers and MOD_SHIFT <> 0) then
		Result := Result + KeyToText(VK_SHIFT) + SPlus;
	if (aModifiers and MOD_CONTROL <> 0) then
		Result := Result + KeyToText(VK_CONTROL) + SPlus;
	if (aModifiers and MOD_ALT <> 0) then
		Result := Result + KeyToText(VK_MENU) + SPlus;
	if (aModifiers and MOD_WIN <> 0) then
		Result := Result + KeyToText(VK_LWIN) + SPlus;
end;

{ Translates a keyboard shortcut to text. }
function ShortcutToText(const aKey, aModifiers: Word): string;
begin
	if (aKey = 0) and (aModifiers = 0) then
	begin
		Result := '(none)';
		Exit;
	end;
	Result := ModifiersToText(aModifiers);
	Result := Result + KeyToText(aKey);
end;

{ Translates a keyboard shortcut to text. }
function ShortcutToText(const aShortcut: cardinal): string; overload;
var
	Key      : Word;
	Modifiers: Word;
begin
	SeparateShortcut(aShortcut, Key, Modifiers);
	Result := ShortcutToText(Key, Modifiers);
end;

{ Checks if a shortcut is already registered by some application. }
function IsShortcutReserved(const aModifiers, aKey: Word): boolean;
var
	tempAtom: Word;
begin
	tempAtom := GlobalAddAtom(PChar('EvilWorks.HotkeyRegistrationTest'));
	Result   := RegisterHotKey(0, tempAtom, aModifiers, aKey);
	if (Result) then
		UnregisterHotKey(0, tempAtom);
	GlobalDeleteAtom(tempAtom);
	Result := (not Result);
end;

{ Checks if a shortcut is already registered by some application. }
function IsShortcutReserved(const aShortcut: cardinal): boolean;
var
	tempKey      : Word;
	tempModifiers: Word;
begin
	SeparateShortcut(aShortcut, tempKey, tempModifiers);
	Result := IsShortcutReserved(tempModifiers, tempKey);
end;

{ }
function NumElementsInSet(var aSet): Byte;
var
	Mask: cardinal;
begin
	Mask   := $80000000;
	Result := 0;
	while (Mask <> 0) do
	begin
		if ((cardinal(aSet) and Mask) <> 0) then
			Inc(Result);
		Mask := Mask shr 1;
	end;
end;

{ }
function RandomRange(const aMin, aMax: integer): integer;
begin
	if (aMin > aMax) then
		Result := Random(aMin - aMax) + aMax
	else
		Result := Random(aMax - aMin) + aMin;
end;

{ }
function RandomBool: boolean;
begin
	Result := (Random > 0.5);
end;

{ }
function HexToText(const aHexStr: string): string;
const
	HexChars   = [#$30 .. #$39] + [#$41 .. #$46] + [#$61 .. #$66];
	HexNums    = [$30 .. $39];
	HexCharsLo = [$41 .. $46];
	HexCharsHi = [$61 .. $66];
var
	InStr  : ansistring;
	i      : integer;
	Len    : integer;
	B      : Byte;
	OutByte: Byte;
begin
	InStr := ansistring(aHexStr);
	i     := 1;
	while (i <= Length(InStr)) do
	begin
		if (InStr[i] in HexChars = False) then
			Delete(InStr, i, 1)
		else
			Inc(i);
	end;

	Len := Length(InStr);
	if (Len = 0) then
		Exit;
	if (Odd(Len)) then
	begin
		InStr := InStr + '0';
		Inc(Len);
	end;

	i := 1;
	while (i <= Len) do
	begin
		B := Byte(InStr[i + 0]);
		if (B in HexNums) then
			B := B - $30
		else
		  if (B in HexCharsLo) then
			B := B - $41 + $0A
		else
		  if (B in HexCharsHi) then
			B   := B - $61 + $0A;
		OutByte := 16 * B;

		B := Byte(InStr[i + 1]);
		if (B in HexNums) then
			B := B - $30
		else
		  if (B in HexCharsLo) then
			B := B - $41 + $0A
		else
		  if (B in HexCharsHi) then
			B   := B - $61 + $0A;
		OutByte := OutByte + B;

		Result := Result + Chr(OutByte);
		Inc(i, 2);
	end;
end;

{ }
function HexToDec(const aHexStr: string): cardinal;
var
	c: cardinal;
	B: Byte;
begin
	Result := 0;
	if (Length(aHexStr) <> 0) then
	begin
		c := 1;
		B := Length(aHexStr) + 1;
		repeat
			dec(B);
			if (aHexStr[B] <= '9') then
				Result := (Result + (cardinal(aHexStr[B]) - 48) * c)
			else
				Result := (Result + (cardinal(aHexStr[B]) - 55) * c);

			c := c * 16;
		until (B = 1);
	end;
end;

{ }
function BytesToFriendlyString(Value: Dword): string;
const
	OneKB = 1024;
	OneMB = OneKB * 1024;
	OneGB = OneMB * 1024;
begin
	if Value < OneKB then
		Result := FormatFloat('#,##0.00 B', Value)
	else
	  if Value < OneMB then
		Result := FormatFloat('#,##0.00 KB', Value / OneKB)
	else
	  if Value < OneGB then
		Result := FormatFloat('#,##0.00 MB', Value / OneMB)
end;

{ }
function BitsToFriendlyString(Value: Dword): string;
const
	OneKB = 1000;
	OneMB = OneKB * 1000;
	OneGB = OneMB * 1000;
begin
	if Value < OneKB then
		Result := FormatFloat('#,##0.00 bps', Value)
	else
	  if Value < OneMB then
		Result := FormatFloat('#,##0.00 Kbps', Value / OneKB)
	else
	  if Value < OneGB then
		Result := FormatFloat('#,##0.00 Mbps', Value / OneMB)
end;

{ Returns a full path for this executable or dll. }
function GetSelfFileName: string;
var
	buffer: array [0 .. MAX_PATH] of char;
begin
	ZeroMemory(@buffer, Length(buffer) * SizeOf(char));
	if (GetModuleFileName(HInstance, buffer, MAX_PATH) > 0) then
		Result := string(buffer)
	else
		Result := '';
end;

{ }
function GetSelfFileNameOnly: string;
begin
	Result := ExtractFileNameOnly(GetSelfFileName);
end;

{ }
function GetSelfDir: string;
begin
	Result := ExtractFileDir(GetSelfFileName);
end;

{ }
function GetSelfPath: string;
begin
	Result := ExtractFilePath(GetSelfFileName);
end;

{ }
function GetWindowsDir: string;
var
	Buffer: array [0 .. MAX_PATH] of char;
begin
	ZeroMemory(@Buffer, MAX_PATH + 2);
	if (GetWindowsDirectory(Buffer, MAX_PATH) > 0) then
	begin
		Result := Buffer;
	end;
end;

{ }
function GetWindowsPath: string;
begin
	Result := IncludeTrailingPathDelimiter(GetWindowsDir);
end;

{ }
function GetSystemDir: string;
var
	Buffer: array [0 .. MAX_PATH] of char;
begin
	ZeroMemory(@Buffer, MAX_PATH + 2);
	if (GetSystemDirectory(Buffer, MAX_PATH) > 0) then
	begin
		Result := Buffer;
	end;
end;

{ }
function GetSystemPath: string;
begin
	Result := IncludeTrailingPathDelimiter(GetSystemDir);
end;

{ }
function RemoveExtension(const aFileName: string): string;
var
	i: integer;
begin
	i := Length(aFileName);
	while (i >= 1) and (aFileName[i] <> '.') do
		dec(i);
	if (i > 0) then
		Result := TextLeft(aFileName, i - 1)
	else
		Result := aFileName;
end;

{ }
function ExtractFileNameOnly(const aFileName: string): string;
begin
	Result := RemoveExtension(ExtractFileName(aFileName));
end;

{ }
function ExtractFileDirOnly(const aFileName: string): string;
begin

end;

{ }
function ExtractLastPathElement(const aFileName: string): string;
var
	tokens: TTokens;
begin
	Result := '';
	tokens := TextTokenize(aFileName, PathDelim);
	Result := tokens[tokens.Count - 1];
end;

{ Gets parent directory of a filesystem object (dir, path or file). }
function ExtractParentDir(const aFileName: string): string;
begin
	if (TextEnds(aFileName, PathDelim)) then
    	Result := ExtractFileDir(aFileName);
    Result := ExtractFileDir(Result);
end;

{ Gets parent directory of a filesystem object (dir, path or file). }
function ExtractParentPath(const aFileName: string): string;
begin
	Result := IncludeTrailingPathDelimiter(ExtractParentDir(aFileName));
end;

{ Expands an environment variable. }
function ExpandEnvironmentVariable(const aString: string): string;
var
	Buffer: PChar;
	Ret   : cardinal;
begin
	Buffer := AllocMem(MAX_PATH + 1);
	if (TextEnclosed(aString, CPercent, True)) then
		Ret := GetEnvironmentVariable(PChar(TextUnEnclose(aString, CPercent, True)), Buffer, MAX_PATH + 1)
	else
		Ret := GetEnvironmentVariable(PChar(aString), Buffer, MAX_PATH + 1);
	if (Ret <> 0) then
		Result := Buffer
	else
		Result := CEmpty;
	FreeMem(Buffer, MAX_PATH + 1);
end;

{ Expands all % enclosed environment variables in the aString. }
function ExpandEnvironmentVariables(const aString: string): string;
var
	s: string;
	v: string;
	i: integer;
begin
	s := aString;
	i := 0;
	while (True) do
	begin
		v := TextFindEnclosed(s, CPercent, i, False, True);
		if (v <> CEmpty) then
			s := TextReplace(s, v, ExpandEnvironmentVariable(v), True)
		else
			Break;
		Inc(i);
	end;
	Result := s;
end;

{ Runs a console application capturing its output. }
procedure RunConsoleApp(const aTarget, aParams, aRunIn: string; aOutputProc: TOnOutput);
const
	READ_BUFFER_SIZE = 1024 * SizeOf(char);
var
	secAttribs : TSecurityAttributes;
	startupInfo: TStartUpInfo;
	processInfo: TProcessInformation;
	Buffer     : array [0 .. READ_BUFFER_SIZE - 1] of ansichar;
	readPipe   : THandle;
	writePipe  : THandle;
	bytesRead  : Dword;
	appRunning : Dword;
	cmdLine    : string;
	msg        : TMsg;
begin
	{ Create Read/Write pipes for child process. }
	ZeroMemory(@secAttribs, SizeOf(secAttribs));
	secAttribs.nLength              := SizeOf(secAttribs);
	secAttribs.lpSecurityDescriptor := nil;
	secAttribs.bInheritHandle       := True;
	if (CreatePipe(readPipe, writePipe, @secAttribs, 0) = False) then
		Exit;

	{ Create startup info. }
	ZeroMemory(@startupInfo, SizeOf(startupInfo));
	startupInfo.cb          := SizeOf(startupInfo);
	startupInfo.hStdError   := writePipe;
	startupInfo.hStdOutput  := writePipe;
	startupInfo.hStdInput   := readPipe;
	startupInfo.dwFlags     := STARTF_USESTDHANDLES + STARTF_USESHOWWINDOW;
	startupInfo.wShowWindow := SW_HIDE;

	ZeroMemory(@processInfo, SizeOf(processInfo));

	{ Format cmdLine string. }
	if (TextEnclosed(aTarget, CDoubleQuote, True)) then
		cmdLine := aTarget
	else
		cmdLine := TextQuote(aTarget);

	if (aParams <> CEmpty) then
		cmdLine := TextQuote(CBackSlash + cmdLine + CSpace + aParams)
	else
		cmdLine := TextQuote(CBackSlash + cmdLine);

	if (CreateProcess(nil, PChar(aTarget + CSpace + aParams), @secAttribs, @secAttribs, True, NORMAL_PRIORITY_CLASS, nil, nil, startupInfo, processInfo)) then
	begin
		repeat
			appRunning := WaitForSingleObject(processInfo.hProcess, 0);

			if (PeekMessage(msg, 0, 0, 0, PM_REMOVE)) then
			begin
				TranslateMessage(msg);
				DispatchMessage(msg);
			end;

			repeat
				bytesRead := 0;
				PeekNamedPipe(readPipe, nil, 0, nil, @bytesRead, nil);
				if (bytesRead > 0) then
				begin
					ReadFile(readPipe, Buffer[0], READ_BUFFER_SIZE, bytesRead, nil);
					if (bytesRead <> 0) then
					begin
						Buffer[bytesRead] := #0;

						OemToAnsi(Buffer, Buffer);
						if (bytesRead <> 0) and (Assigned(aOutputProc)) then
							aOutputProc(string(Buffer));
					end;
				end;
			until (bytesRead = 0);

			SleepEx(1, True);

		until (appRunning <> WAIT_TIMEOUT);

		CloseHandle(processInfo.hProcess);
		CloseHandle(processInfo.hThread);
	end;

	CloseHandle(readPipe);
	CloseHandle(writePipe);
end;

end.
