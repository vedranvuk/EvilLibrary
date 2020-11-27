unit EvilWorks.VCL.FormSettings;

{ by lhaymehr@gmail.com, 2010. Part of EvilLibrary. Works with Delphi XE and up. }

interface

uses
	WinApi.Windows, WinApi.Messages,
	System.SysUtils, System.Classes, System.IniFiles,
	Vcl.Forms;

type
	{ TFormSettings }
	TFormSettings = class(TComponent)
	private const
		CX: string     = 'X';
		CY: string     = 'Y';
		CCX: string    = 'CX';
		CCY: string    = 'CY';
		CState: string = 'State';
	private
		FSaveWndProc: TWndMethod;
	private
		FTempLeft: integer;
		FTempTop : integer;
		FLeft    : integer;
		FTop     : integer;
		FWidth   : integer;
		FHeight  : integer;
		FState   : TWindowState;
	protected
		procedure SubclassOwnerForm(const aEnable: boolean);
		procedure SubClassWndProc(var aMsg: TMessage);

		procedure GetParentFormProperties;
		procedure SetParentFormProperties;
	public
		constructor Create(aOwner: TComponent); override;
		destructor Destroy; override;

		procedure SaveToIni(const aFileName, aSectionName: string);
		procedure LoadFromIni(const aFileName, aSectionName: string);
	end;

implementation

{ TFormSettings }

constructor TFormSettings.Create(aOwner: TComponent);
begin
	if not(aOwner is TCustomForm) then
		raise Exception.Create('TFormSettings owner must be a TCustomForm descendant');

	inherited;

	SubclassOwnerForm(True);

	GetParentFormProperties;
end;

destructor TFormSettings.Destroy;
begin
	SubclassOwnerForm(False);
	inherited;
end;

procedure TFormSettings.GetParentFormProperties;
begin
	FLeft   := TCustomForm(Owner).Left;
	FTop    := TCustomForm(Owner).Top;
	FWidth  := TCustomForm(Owner).Width;
	FHeight := TCustomForm(Owner).Height;
	FState  := TCustomForm(Owner).WindowState;
end;

procedure TFormSettings.SetParentFormProperties;
var
	tempState: TWindowState;
begin
	tempState := FState;
	SetWindowPos(TCustomForm(Owner).Handle, 0, FLeft, FTop, FWidth, FHeight, 0);
	FState := tempState;
	case FState of
		wsMinimized:
		ShowWindow(TCustomForm(Owner).Handle, SW_MINIMIZE);
		wsMaximized:
		ShowWindow(TCustomForm(Owner).Handle, SW_MAXIMIZE);
	end;
end;

procedure TFormSettings.SubclassOwnerForm(const aEnable: boolean);
begin
	if (aEnable) then
	begin
		FSaveWndProc                  := TCustomForm(Owner).WindowProc;
		TCustomForm(Owner).WindowProc := SubClassWndProc;
	end
	else
	begin
		if (Assigned(FSaveWndProc) = False) then
			Exit;
		TCustomForm(Owner).WindowProc := FSaveWndProc;
		FSaveWndProc                  := nil;
	end;
end;

procedure TFormSettings.SubClassWndProc(var aMsg: TMessage);
var
	r: TRect;
begin
	case aMsg.Msg of

		WM_DESTROY:
		begin
			SubclassOwnerForm(False);
		end;

		WM_SIZE:
		begin
			case aMsg.WParam of
				SIZE_MAXIMIZED:
				FState := wsMaximized;
				SIZE_MINIMIZED:
				FState := wsMinimized;
				SIZE_RESTORED:
				FState := wsNormal;
			end;

			GetWindowRect(TCustomForm(Owner).Handle, r);

			if (aMsg.WParam = SIZE_RESTORED) then
			begin
				FWidth  := r.Width;
				FHeight := r.Height;
			end
			else
			begin
				FLeft := FTempLeft;
				FTop  := FTempTop;
			end;
		end;

		WM_MOVE:
		begin
			GetWindowRect(TCustomForm(Owner).Handle, r);
			FTempLeft := FLeft;
			FTempTop  := FTop;
			FLeft     := r.Left;
			FTop      := r.Top;
		end;

	end;

	if (Assigned(FSaveWndProc)) then
		FSaveWndProc(aMsg);
end;

procedure TFormSettings.SaveToIni(const aFileName, aSectionName: string);
var
	ini: TIniFile;
begin
	ForceDirectories(ExtractFilePath(aFileName));
	ini := TIniFile.Create(aFileName);
	try
		ini.WriteInteger(aSectionName, CX, FLeft);
		ini.WriteInteger(aSectionName, CY, FTop);
		ini.WriteInteger(aSectionName, CCX, FWidth);
		ini.WriteInteger(aSectionName, CCY, FHeight);
		ini.WriteInteger(aSectionName, CState, integer(FState));
	finally
		ini.Free;
	end;
end;

procedure TFormSettings.LoadFromIni(const aFileName, aSectionName: string);
var
	ini: TIniFile;
begin
	if (FileExists(aFileName) = False) then
	begin
		SaveToIni(aFileName, aSectionName);
		Exit;
	end;

	ini := TIniFile.Create(aFileName);
	try
		FLeft   := ini.ReadInteger(aSectionName, CX, TCustomForm(Owner).Left);
		FTop    := ini.ReadInteger(aSectionName, CY, TCustomForm(Owner).Top);
		FWidth  := ini.ReadInteger(aSectionName, CCX, TCustomForm(Owner).Width);
		FHeight := ini.ReadInteger(aSectionName, CCY, TCustomForm(Owner).Height);
		FState  := TWindowState(ini.ReadInteger(aSectionName, CState, integer(TCustomForm(Owner).WindowState)));
		SetParentFormProperties;
	finally
		ini.Free;
	end;
end;

end.
