unit EvilWorks.Vcl.Fullscreen;

interface

uses
	WinApi.Windows,
	System.Classes,
	System.SysUtils,
	Vcl.Forms;

type
	TFullscreen = class(TComponent)
	private
		FShortcut       : TShortcut;
		FFullscreen     : boolean;
		FSaveRect       : TRect;
		FSaveBorderStyle: TFormBorderStyle;
    public
		constructor Create(aOwner: TComponent); override;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;

		procedure EnterFullscreen;
		procedure ExitFullscreen;
		procedure ToggleFullscreen;
	published
		property Hotkey: TShortcut read FShortcut write FShortcut default VK_F11;
	end;

implementation

{ TFullscreen }

constructor TFullscreen.Create(aOwner: TComponent);
begin
	if (aOwner is TCustomForm = False) then
		raise Exception.Create('TFullscreen owner must be placed on a TCustomForm descendant.');

	inherited;
	FShortcut := VK_F11;
end;

destructor TFullscreen.Destroy;
begin

	inherited;
end;

procedure TFullscreen.EnterFullscreen;
begin
	if (FFullscreen) then
		Exit;

	FSaveRect        := TCustomForm(Owner).BoundsRect;
	FSaveBorderStyle := TCustomForm(Owner).BorderStyle;

	with (Owner as TCustomForm) do
	begin
		FSaveRect        := BoundsRect;
		FSaveBorderStyle := BorderStyle;

		BorderStyle := bsNone;
		Left        := Screen.DesktopLeft;
		Top         := Screen.DesktopTop;
		Width       := Screen.DesktopWidth;
		Height      := Screen.DesktopHeight;
	end;

	FFullscreen := True;
end;

procedure TFullscreen.ExitFullscreen;
begin
	if (FFullscreen = False) then
		Exit;

	with (Owner as TCustomForm) do
	begin
		BoundsRect  := FSaveRect;
		BorderStyle := FSaveBorderStyle;

		Left   := FSaveRect.Left;
		Top    := FSaveRect.Top;
		Width  := FSaveRect.Width;
		Height := FSaveRect.Height;
	end;

    FFullscreen := False;
end;

procedure TFullscreen.ToggleFullscreen;
begin
	if (FFullscreen) then
		ExitFullscreen
	else
		EnterFullscreen;
end;

procedure TFullscreen.Assign(aSource: TPersistent);
begin
	inherited;

	if (aSource is TFullscreen) then
	begin
		Hotkey := TFullscreen(aSource).Hotkey;
	end;
end;

end.
