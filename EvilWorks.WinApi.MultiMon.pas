unit EvilWorks.WinApi.MultiMon;

interface

uses
	Winapi.Windows,
	Winapi.MultiMon;

type
	TWinPos = (wpTopLeft, wpTopCenter, wpTopRight, wpMidLeft, wpMidCenter, wpMidRight,
	  wpBottomLeft, wpBottomCenter, wpBottomRight
	  );

	TWinAlign = (waLeft, waTop, waRight, waBottom);

function CalcPosXY(aClient, aParent: TRect; aPos: TWinPos = wpMidCenter): TPoint; overload;
function CalcPosX(aClient, aParent: TRect; aPositioning: TWinPos = wpMidCenter): integer; overload;
function CalcPosY(aClient, aParent: TRect; aPositioning: TWinPos = wpMidCenter): integer; overload;
function CalcPosXY(aClientCX, aClientCY: integer; aParent: TRect; aPos: TWinPos = wpMidCenter): TPoint; overload;
function CalcPosX(aClientCX: integer; aParent: TRect; aPos: TWinPos = wpMidCenter): integer; overload;
function CalcPosY(aClientCY: integer; aParent: TRect; aPos: TWinPos = wpMidCenter): integer; overload;
function Min(const aMin: integer; aValues: array of integer): integer;
function Max(const aMax: integer; aValues: array of integer): integer;
function Clip(const aMin, aMax, aValue: integer): integer;

function PositionWindow(aWindow: HWND; aPosition: TWinPos; bUseWorkArea: boolean = True): boolean;
function AlignWindow(const aWindow: HWND; const aAlign: TWinAlign; const aStretch: boolean): boolean;

implementation

uses
	EvilWorks.System.SysUtils;

function CalcPosXY(aClient, aParent: TRect; aPos: TWinPos = wpMidCenter): TPoint; overload;
begin
	Result := CalcPosXY(aClient.Width, aClient.Height, aParent, aPos);
end;

// -----------------------------------------------------------------------------------------------------------
// Get horizontal positioning coordinates for a rectangle.
// -----------------------------------------------------------------------------------------------------------

function CalcPosX(aClient, aParent: TRect; aPositioning: TWinPos = wpMidCenter): integer; overload;
begin
	Result := CalcPosX(aClient.Width, aParent, aPositioning);
end;

// -----------------------------------------------------------------------------------------------------------
// Get vertical positioning coordinates for a rectangle.
// -----------------------------------------------------------------------------------------------------------

function CalcPosY(aClient, aParent: TRect; aPositioning: TWinPos = wpMidCenter): integer; overload;
begin
	Result := CalcPosY(aClient.Height, aParent, aPositioning);
end;

// -----------------------------------------------------------------------------------------------------------
// Get positioning coordinates for a rectangle.
// -----------------------------------------------------------------------------------------------------------

function CalcPosXY(aClientCX, aClientCY: integer; aParent: TRect; aPos: TWinPos = wpMidCenter): TPoint;
begin
	case aPos of

		wpTopLeft:
		begin
			Result.X := aParent.Left;
			Result.Y := aParent.Top;
		end;

		wpTopCenter:
		begin
			Result.X := aParent.Left + ((aParent.Width - aClientCX) div 2);
			Result.Y := aParent.Top;
		end;

		wpTopRight:
		begin
			Result.X := aParent.Right - aClientCX;
			Result.Y := aParent.Top;
		end;

		wpMidLeft:
		begin
			Result.X := aParent.Left;
			Result.Y := aParent.Top + ((aParent.Height - aClientCY) div 2);
		end;

		wpMidCenter:
		begin
			Result.X := aParent.Left + ((aParent.Width - aClientCX) div 2);
			Result.Y := aParent.Top + ((aParent.Height - aClientCY) div 2);

		end;

		wpMidRight:
		begin
			Result.X := aParent.Right - aClientCX;
			Result.Y := aParent.Top + ((aParent.Height - aClientCY) div 2);
		end;

		wpBottomLeft:
		begin
			Result.X := aParent.Left;
			Result.Y := aParent.Bottom - aClientCY;
		end;

		wpBottomCenter:
		begin
			Result.X := aParent.Left + ((aParent.Width - aClientCX) div 2);
			Result.Y := aParent.Bottom - aClientCY;
		end;

		wpBottomRight:
		begin
			Result.X := aParent.Right - aClientCX;
			Result.Y := aParent.Bottom - aClientCY;
		end;

	end; { case }
end;

// -----------------------------------------------------------------------------------------------------------
// Get horizontal positioning coordinates for a rectangle.
// -----------------------------------------------------------------------------------------------------------

function CalcPosX(aClientCX: integer; aParent: TRect; aPos: TWinPos = wpMidCenter): integer;
begin
	Result := 0;

	case aPos of

		wpTopLeft, wpMidLeft, wpBottomLeft:
		Result := aParent.Left;
		wpTopCenter, wpMidCenter, wpBottomCenter:
		Result := aParent.Left + ((aParent.Width - aClientCX) div 2);
		wpTopRight, wpMidRight, wpBottomRight:
		Result := aParent.Right - aClientCX;

	end; { case }
end;

// -----------------------------------------------------------------------------------------------------------
// Get vertical positioning coordinates for a rectangle.
// -----------------------------------------------------------------------------------------------------------

function CalcPosY(aClientCY: integer; aParent: TRect; aPos: TWinPos = wpMidCenter): integer;
begin
	Result := 0;

	case aPos of

		wpTopLeft, wpTopCenter, wpTopRight:
		Result := aParent.Top;
		wpMidLeft, wpMidCenter, wpMidRight:
		Result := aParent.Top + ((aParent.Height - aClientCY) div 2);
		wpBottomLeft, wpBottomCenter, wpBottomRight:
		Result := aParent.Bottom - aClientCY;

	end; { case }
end;

// -----------------------------------------------------------------------------------------------------------
// Limits an integer to floor value.
// -----------------------------------------------------------------------------------------------------------

function Min(const aMin: integer; aValues: array of integer): integer;
var
	i: integer;
begin
	Result := aMin;
	for i  := 0 to high(aValues) do
		if (aValues[i] < Result) then
			Result := aValues[i];
end;

// -----------------------------------------------------------------------------------------------------------
// Limits an integer to ceil value.
// -----------------------------------------------------------------------------------------------------------

function Max(const aMax: integer; aValues: array of integer): integer;
var
	i: integer;
begin
	Result := aMax;
	for i  := 0 to high(aValues) do
		if (aValues[i] > Result) then
			Result := aValues[i];
end;

// -----------------------------------------------------------------------------------------------------------
// Limits an integer to floor and ceil values.
// -----------------------------------------------------------------------------------------------------------

function Clip(const aMin, aMax, aValue: integer): integer;
begin
	Result := aValue;
	if (aValue < aMin) then
		Result := aMin;
	if (aValue > aMax) then
		Result := aMax;
end;

// -----------------------------------------------------------------------------------------------------------
// Positions a window on the current desktop.
//
// aWindow: Window to move.
// aPosition: Position where to move it.
// bUseWorkArea: If TRUE use screen work area (Desktop - Taskbar), se whole screen.
// -----------------------------------------------------------------------------------------------------------

function PositionWindow(aWindow: HWND; aPosition: TWinPos; bUseWorkArea: boolean = True): boolean;
type
	TMonitorInfoW = record
		cbSize: DWORD;
		rcMonitor: TRect;
		rcWork: TRect;
		dwFlags: DWORD;
	end;
var
	RW     : TRect;
	RA     : TRect;
	P      : TPoint;
	Monitor: integer;
	MI     : TMonitorInfoW;
begin
	Result := False;

	if (IsWindow(aWindow) = False) then
	begin
		SetLastError(ERROR_INVALID_HANDLE);
		Exit;
	end;

	Result := GetWindowRect(aWindow, RW);
	if (Result = False) then
		Exit;

	Monitor := MonitorFromRect(@RW, 0);
	if (Monitor <> 0) then
	begin
		FillChar(MI, SizeOf(MI), 0);
		MI.cbSize := SizeOf(MI);
		if (GetMonitorInfoW(Monitor, @MI)) then
		begin
			if (bUseWorkArea) then
				RA := MI.rcWork
			else
				RA := MI.rcMonitor;
			Result := True;
		end;
	end
	else
		Result := False;

	if (Result) then
	begin
		P      := CalcPosXY(RW.Width, RW.Height, RA, aPosition);
		Result := SetWindowPos(aWindow, 0, P.X, P.Y, 0, 0, SWP_NOZORDER or SWP_NOSIZE);
	end;
end;

{ Aligns a window inside a monitor work area. }
function AlignWindow(const aWindow: HWND; const aAlign: TWinAlign; const aStretch: boolean): boolean;
var
	RW     : TRect;
	RP     : TRect;
	MI     : TMonitorInfo;
	Monitor: integer;
begin
	Result := False;

	if (IsZoomed(aWindow)) then
		RestoreWindowWithoutAnimations(aWindow);

	if (GetWindowRect(aWindow, RW) = False) then
		Exit;

	Monitor := MonitorFromRect(@RW, 0);
	if (Monitor = 0) then
		Exit;

	FillChar(MI, SizeOf(MI), 0);
	MI.cbSize := SizeOf(MI);
	if (GetMonitorInfo(Monitor, @MI) = False) then
		Exit;

	if (RW.Width > MI.rcWork.Width) then
		RW.Right := RW.Left + MI.rcWork.Width;

	if (RW.Height > MI.rcWork.Height) then
		RW.Bottom := RW.Top + MI.rcWork.Height;

	case aAlign of

		waLeft:
		begin
			RP.Left   := MI.rcWork.Left;
			RP.Top    := MI.rcWork.Top;
			RP.Bottom := MI.rcWork.Bottom;
			if (aStretch) then
				RP.Right := RW.Right
			else
				RP.Right := (RP.Left + RW.Width);
		end;

		waTop:
		begin
			RP.Left  := MI.rcWork.Left;
			RP.Top   := MI.rcWork.Top;
			RP.Right := MI.rcWork.Right;
			if (aStretch) then
				RP.Bottom := RW.Bottom
			else
				RP.Bottom := (MI.rcWork.Top + RW.Height);
		end;

		waRight:
		begin
			RP.Top    := MI.rcWork.Top;
			RP.Right  := MI.rcWork.Right;
			RP.Bottom := MI.rcWork.Bottom;
			if (aStretch) then
				RP.Left := RW.Left
			else
				RP.Left := (MI.rcWork.Right - RW.Width);
		end;

		waBottom:
		begin
			RP.Right  := MI.rcWork.Right;
			RP.Bottom := MI.rcWork.Bottom;
			RP.Left   := MI.rcWork.Left;
			if (aStretch) then
				RP.Top := RW.Top
			else
				RP.Top := (MI.rcWork.Bottom - RW.Height);
		end;

	end; { case }

	Result := SetWindowPos(aWindow, 0, RP.Left, RP.Top, RP.Width, RP.Height, SWP_NOZORDER);
end;

end.
