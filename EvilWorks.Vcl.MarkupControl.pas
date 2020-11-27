//
// Supported elements:
// <b>Bold text</b>
// <i>Italic text</i>
// <u>Underlined text<u>
// <s>Strinkeout text</s>
// <font name="Segoe UI" size="10pt" color="#FF0000">Defines a font</font>
// <a href="http://www.example.com>Link text</a>
// <p>Paragraph</p>
// <br>Line break
//

unit EvilWorks.Vcl.MarkupControl;

interface

uses
	Winapi.Windows,
	WinApi.Messages,
	System.SysUtils,
	System.Classes,
	System.Math,
	Vcl.Graphics,
	Vcl.Controls,
	EvilWorks.System.StrUtils;

type
	{ TMarkupCell }
	TMarkupCell = class
	private
		FRect: TRect;
	public
		property Rect: TRect read FRect write FRect;
	end;

	{ TMarkupControl }
	TMarkupControl = class(TCustomControl)
	private
		FText : string;
		procedure SetText(const Value: string);
		function GetTransparent: Boolean;
		procedure SetTransparent(const Value: Boolean);
	protected
		procedure ParseMarkup;

		procedure CreateParams(var aParams: TCreateParams); override;
		procedure Resize; override;
		procedure Paint; override;

		procedure CMFontChanged(var aMsg: TMessage); message CM_FONTCHANGED;
	public
		constructor Create(aOwner: TComponent); override;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;
	published
    	property Anchors;
        property Align;
        property DoubleBuffered;
		property Font;

		property Text       : string read FText write SetText;
		property Transparent: Boolean read GetTransparent write SetTransparent default True;
	end;

implementation

{ TMarkupControl }

constructor TMarkupControl.Create(aOwner: TComponent);
begin
	inherited;
	ControlStyle := ControlStyle - [csOpaque];
end;

destructor TMarkupControl.Destroy;
begin
	inherited;
end;

procedure TMarkupControl.CreateParams(var aParams: TCreateParams);
begin
	inherited CreateParams(aParams);

	if (Transparent) then
		aParams.ExStyle := aParams.ExStyle or WS_EX_TRANSPARENT;
end;

procedure TMarkupControl.Assign(aSource: TPersistent);
begin
	inherited;

	if (aSource is TMarkupControl) then
	begin

		Text := TMarkupControl(aSource).Text;
	end;
end;

procedure TMarkupControl.Resize;
begin
	inherited;

end;

procedure TMarkupControl.Paint;
begin
	inherited;

end;

procedure TMarkupControl.ParseMarkup;
begin
	if (FText = '') then
		Exit;
end;

procedure TMarkupControl.SetText(const Value: string);
begin
	if (FText = Value) then
		Exit;
	FText := Value;
	ParseMarkup;
	Invalidate;
end;

function TMarkupControl.GetTransparent: Boolean;
begin
	Result := not (csOpaque in ControlStyle);
end;

procedure TMarkupControl.SetTransparent(const Value: Boolean);
begin
	if (Value) then
		ControlStyle := ControlStyle - [csOpaque]
	else
		ControlStyle := ControlStyle + [csOpaque];

	RecreateWnd;
end;

procedure TMarkupControl.CMFontChanged(var aMsg: TMessage);
begin
	Canvas.Font.Assign(Font);
end;

end.
