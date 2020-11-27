unit EvilWorks.Vcl.TextDisplay;

interface

uses
	WinApi.Windows,
	WinApi.Messages,
	System.Classes,
	System.SysUtils,
	System.RTLConsts,
	System.Math,
	System.StrUtils,
	Vcl.Forms,
	Vcl.Graphics,
	Vcl.Controls,
	Vcl.StdCtrls;

type
	{ Forward declarations. }
	TStyledLine        = class;
	TCustomTextDisplay = class;

	{ TLinePart }
	{ Defines a styled part of text in a line. }
	TLinePart = class(TPersistent)
	private
		FStart      : integer;
		FLength     : integer;
		FForeground : TColor;
		FBackground : TColor;
		FFontStyle  : TFontStyles;
		FStyledWidth: integer;
	public
		constructor Create;
		procedure Assign(aSource: TPersistent); override;
	published
		{ Begin index of this part in a string. }
		property Start: integer read FStart write FStart;
		{ Length of the text styled by this part. }
		property Length: integer read FLength write FLength;
		{ Foreground color / text color. }
		property Foreground: TColor read FForeground write FForeground;
		{ Background color / text background. }
		property Background: TColor read FBackground write FBackground;
		{ Font style. }
		property FontStyle: TFontStyles read FFontStyle write FFontStyle;
		{ Width in pixels of this parts text. }
		property StyledWidth: integer read FStyledWidth write FStyledWidth;
	end;

	{ TLineParts }
	{ Manages a list of TLinePart (TTextPart or TImagePart). }
	TLineParts = class(TPersistent)
	private
		FList: TList;
		function GetCount: integer;
		function GetPart(const aIndex: integer): TLinePart;
		procedure SetPart(const aIndex: integer; const aValue: TLinePart);
	public
		constructor Create;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;

		function Add: TLinePart; overload; inline;
		function Add(const aStart, aLength: integer): TLinePart; overload; inline;
		function Insert(const aIndex, aStart, aLength: integer): TLinePart;
		procedure Delete(const aIndex: integer);
		procedure Clear;

		property Parts[const aIndex: integer]: TLinePart read GetPart write SetPart; default;
		property Count: integer read GetCount;
	end;

	{ TBreakPosition }
	{ Defines a position in a line where line is wrappable. }
	TBreakPosition = class(TPersistent)
	private
		FPosition: integer;
	public
		constructor Create;
		procedure Assign(aSource: TPersistent); override;
	published
		{ Position in the string where the line is wrappable. }
		property Position: integer read FPosition write FPosition;
	end;

	{ TBreakPositions }
	{ Manages a list of TBreakPosition. }
	TBreakPositions = class(TPersistent)
	private
		FList: TList;
		function GetCount: integer;
		function GetPosition(const aIndex: integer): TBreakPosition;
		procedure SetPosition(const aIndex: integer; const aValue: TBreakPosition);
	public
		constructor Create;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;

		function Add: TBreakPosition; overload; inline;
		function Add(const aPosition: integer): TBreakPosition; overload; inline;
		function Insert(const aIndex, aPosition: integer): TBreakPosition;
		procedure Delete(const aIndex: integer);
		procedure Clear;

		property Positions[const aIndex: integer]: TBreakPosition read GetPosition write SetPosition; default;
		property Count: integer read GetCount;
	end;

	{ TStyledLine }
	{ Defines a line in TTextDisplayStrings. }
	TStyledLine = class(TPersistent)
	private
		FLineParts     : TLineParts;
		FBreakPositions: TBreakPositions;
		FText          : string;
		function GetStyledWidth: integer;
		procedure SetBreakPositions(const Value: TBreakPositions);
		procedure SetLineParts(const Value: TLineParts);
		procedure SetText(const Value: string);
	protected
		FLinesNeeded  : integer;
		FUnstyledWidth: integer;
	public
		constructor Create;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;

		{ Temporary variable for calculation of scrollbars when WordWrap is on. }
		property LinesNeeded: integer read FLinesNeeded write FLinesNeeded;
		{ Width of Text in pixels before styling. }
		property UnstyledWidth: integer read FUnstyledWidth write FUnstyledWidth;
		{ Width of Text in pixels after styling. }
		property StyledWidth: integer read GetStyledWidth;
	published
		{ Raw line text. }
		property Text: string read FText write SetText;
		{ Parts of the Text after styling. }
		property LineParts: TLineParts read FLineParts write SetLineParts;
		{ Positions where Text is wrappable. }
		property BreakPositions: TBreakPositions read FBreakPositions write SetBreakPositions;
	end;

	{ TTextDisplayStyler }
	{ Base class defining a styler component (tokenizer) for TTextDisplay. }
	TTextDisplayStyler = class(TComponent)
	private
		FTextDisplay       : TCustomTextDisplay;
		FHighLightColor    : TColor;
		FHighlightTextColor: TColor;
		procedure SetHighlightColor(const Value: TColor);
		procedure SetHighlightTextColor(const Value: TColor);
	protected
		procedure TokenizeLine(aStyledLine: TStyledLine); virtual; abstract;
	public
		constructor Create(aOwner: TComponent); override;
		procedure Assign(aSource: TPersistent); override;
	published
		property HighlightColor    : TColor read FHighLightColor write SetHighlightColor default clHighlight;
		property HighlightTextColor: TColor read FHighlightTextColor write SetHighlightTextColor default clHighlightText;
	end;

	{ TTextDisplayStylerIRC }
	{ Styles text with (m)IRC control codes. }
	TTextDisplayStylerIRC = class(TTextDisplayStyler)
	private
		FColors: array [00 .. 15] of TColor;
		function GetColor(const aIndex: integer): TColor;
		procedure SetColor(const aIndex: integer; const aValue: TColor);
	protected
		procedure TokenizeLine(aStyledLine: TStyledLine); override;
	public
		constructor Create(aOwner: TComponent); override;
		procedure Assign(aSource: TPersistent); override;
	published
		property Color00: TColor index 00 read GetColor write SetColor default $FFFFFF;
		property Color01: TColor index 01 read GetColor write SetColor default $000000;
		property Color02: TColor index 02 read GetColor write SetColor default $7F0000;
		property Color03: TColor index 03 read GetColor write SetColor default $009300;
		property Color04: TColor index 04 read GetColor write SetColor default $0000FF;
		property Color05: TColor index 05 read GetColor write SetColor default $00007F;
		property Color06: TColor index 06 read GetColor write SetColor default $9C009C;
		property Color07: TColor index 07 read GetColor write SetColor default $007FFC;
		property Color08: TColor index 08 read GetColor write SetColor default $00FFFF;
		property Color09: TColor index 09 read GetColor write SetColor default $00FC00;
		property Color10: TColor index 10 read GetColor write SetColor default $939300;
		property Color11: TColor index 11 read GetColor write SetColor default $FFFF00;
		property Color12: TColor index 12 read GetColor write SetColor default $FC0000;
		property Color13: TColor index 13 read GetColor write SetColor default $FF00FF;
		property Color14: TColor index 14 read GetColor write SetColor default $7F7F7F;
		property Color15: TColor index 15 read GetColor write SetColor default $D2D2D2;
	end;

	{ TTextDisplayStrings }
	{ TStrings descendant for out TextDisplay.Lines property. }
	TTextDisplayStrings = class(TStrings)
	private
		FTextDisplay: TCustomTextDisplay;
		FUpdating   : boolean;
		FList       : TList;
		function GetStyledLine(const aIndex: integer): TStyledLine;
	protected
		procedure TokenizeLines;
		procedure RecalculateLineBreaks;

		function Get(aIndex: integer): string; override;
		function GetCount: integer; override;

		procedure Put(aIndex: integer; const aString: string); override;
		procedure Changed;

		property StyledLines[const aIndex: integer]: TStyledLine read GetStyledLine;
		procedure SetUpdateState(aUpdating: boolean); override;
	public
		constructor Create; overload;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;

		procedure Insert(aIndex: integer; const aString: string); override;
		procedure Delete(aIndex: integer); override;
		procedure Clear; override;
	end;

	{ TLinesAnchor }
	TLinesAnchor = (laTop, laBottom);

	{ TCustomTextDisplay }
	TCustomTextDisplay = class(TCustomControl)
	private
		FLines         : TStrings;
		FStyler        : TTextDisplayStyler;
		FBorderStyle   : TBorderStyle;
		FWordWrapIndent: integer;
		FWordWrap      : boolean;
		FCopyOnSelect  : boolean;
		FLinesAnchor   : TLinesAnchor;
		procedure SetLines(const aValue: TStrings);
		procedure SetStyler(const Value: TTextDisplayStyler);
		procedure SetBorderStyle(const Value: TBorderStyle);
		procedure SetWordWrap(const Value: boolean);
		procedure SetWordWrapIndent(const Value: integer);
		procedure SetLinesAnchor(const Value: TLinesAnchor);
	protected
		FFontHeight: integer;
		FFontWidth : integer;

		FWindowLines      : integer;
		FWindowColumns    : integer;
		FWindowLinesLast  : integer;
		FLastWindowColumns: integer;

		FLongestLine: integer;

		FVScrollPos: integer;
		FHScrollPos: integer;
		FVScrollMax: integer;
		FHScrollMax: integer;
		procedure CreateHandle; override;
		procedure CreateParams(var aParams: TCreateParams); override;
		procedure Notification(aComponent: TComponent; aOperation: TOperation); override;
		procedure Loaded; override;
		procedure Resize; override;
		procedure Paint; override;

		procedure TokenizeLine(aStyledLine: TStyledLine);
		procedure PaintLine(const aLine: integer; const aOffset: word);

		function GetTrackPos(nBar: integer): LONG;
		procedure CalculateScrollbars;
		procedure Scroll(const aDX, aDY: integer);

		procedure StringsChanged;

		procedure CMColorchanged(var Message: TMessage); message CM_COLORCHANGED;
		procedure CMFontchanged(var Message: TMessage); message CM_FONTCHANGED;
		procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
		procedure WMHScroll(var Message: TWMHScroll); message WM_HSCROLL;
	public
		constructor Create(aOwner: TComponent); override;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;

		property Color default clWindow;

		property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
		property CopyOnSelect: boolean read FCopyOnSelect write FCopyOnSelect default False;
		property Lines: TStrings read FLines write SetLines;
		property LinesAnchor: TLinesAnchor read FLinesAnchor write SetLinesAnchor default laTop;
		property Styler: TTextDisplayStyler read FStyler write SetStyler;

		property WordWrap: boolean read FWordWrap write SetWordWrap default False;
		property WordWrapIndent: integer read FWordWrapIndent write SetWordWrapIndent default 10;
	end;

	{ TTextDisplay }
	TTextDisplay = class(TCustomTextDisplay)
	published
		{ Inherited }
		property Align;
		property Anchors;
		property Color;
		property DoubleBuffered;
		property Font;

		{ Introducted in TCustomTextDisplay }
		property BorderStyle;
		property Lines;
		property LinesAnchor;
		property Styler;
		property WordWrap;
		property WordWrapIndent;
	end;

implementation

{ TTextDisplayStyler }

constructor TTextDisplayStyler.Create(aOwner: TComponent);
begin
	inherited;
	FHighLightColor     := clHighlight;
	FHighlightTextColor := clHighlightText;
end;

procedure TTextDisplayStyler.Assign(aSource: TPersistent);
begin
	inherited;

	if (aSource is TTextDisplayStyler) then
	begin
		HighlightColor     := TTextDisplayStyler(aSource).HighlightColor;
		HighlightTextColor := TTextDisplayStyler(aSource).HighlightTextColor;
	end;
end;

procedure TTextDisplayStyler.SetHighlightColor(const Value: TColor);
begin
	if (FHighLightColor = Value) then
		Exit;
	FHighLightColor := Value;
	if (FTextDisplay <> nil) then
		FTextDisplay.Invalidate;
end;

procedure TTextDisplayStyler.SetHighlightTextColor(const Value: TColor);
begin
	if (FHighlightTextColor = Value) then
		Exit;
	FHighlightTextColor := Value;
	if (FTextDisplay <> nil) then
		FTextDisplay.Invalidate;
end;

{ TTextDisplayStylerIRC }

constructor TTextDisplayStylerIRC.Create(aOwner: TComponent);
begin
	inherited;
	FColors[00] := $FFFFFF;
	FColors[01] := $000000;
	FColors[02] := $7F0000;
	FColors[03] := $009300;
	FColors[04] := $0000FF;
	FColors[05] := $00007F;
	FColors[06] := $9C009C;
	FColors[07] := $007FFC;
	FColors[08] := $00FFFF;
	FColors[09] := $00FC00;
	FColors[10] := $939300;
	FColors[11] := $FFFF00;
	FColors[12] := $FC0000;
	FColors[13] := $FF00FF;
	FColors[14] := $7F7F7F;
	FColors[15] := $D2D2D2;
end;

procedure TTextDisplayStylerIRC.Assign(aSource: TPersistent);
begin
	inherited Assign(aSource);

	if (aSource is TTextDisplayStylerIRC) then
	begin
		Color00 := TTextDisplayStylerIRC(aSource).Color00;
		Color01 := TTextDisplayStylerIRC(aSource).Color01;
		Color02 := TTextDisplayStylerIRC(aSource).Color02;
		Color03 := TTextDisplayStylerIRC(aSource).Color03;
		Color04 := TTextDisplayStylerIRC(aSource).Color04;
		Color05 := TTextDisplayStylerIRC(aSource).Color05;
		Color06 := TTextDisplayStylerIRC(aSource).Color06;
		Color07 := TTextDisplayStylerIRC(aSource).Color07;
		Color08 := TTextDisplayStylerIRC(aSource).Color08;
		Color09 := TTextDisplayStylerIRC(aSource).Color09;
		Color10 := TTextDisplayStylerIRC(aSource).Color10;
		Color11 := TTextDisplayStylerIRC(aSource).Color11;
		Color12 := TTextDisplayStylerIRC(aSource).Color12;
		Color13 := TTextDisplayStylerIRC(aSource).Color13;
		Color14 := TTextDisplayStylerIRC(aSource).Color14;
		Color15 := TTextDisplayStylerIRC(aSource).Color15;
	end;
end;

function TTextDisplayStylerIRC.GetColor(const aIndex: integer): TColor;
begin
	if (aIndex >= 00) and (aIndex <= 15) then
		Result := FColors[aIndex]
	else
		Result := clDefault;
end;

procedure TTextDisplayStylerIRC.SetColor(const aIndex: integer; const aValue: TColor);
begin
	if (aIndex >= 00) and (aIndex <= 15) then
		FColors[aIndex] := aValue;
	if (FTextDisplay <> nil) then
		FTextDisplay.Invalidate;
end;

procedure TTextDisplayStylerIRC.TokenizeLine(aStyledLine: TStyledLine);
const
	// IRC string control codes.
	CC_SPACE     = #$20; // 32
	CC_BOLD      = #$02; // 02
	CC_ITALIC    = #$1D; // 29
	CC_UNDERLINE = #$1F; // 31
	CC_REVERSE   = #$16; // 22
	CC_ORDINARY  = #$0F; // 15
	CC_COLOR     = #$03; // 03

	// Parse states
type
	TColorParse = (
	  cpParsed,
	  cpTwoFgDigits,
	  cpOneFgDigitOrComma,
	  cpCommaOrEnd,
	  cpTwoBgDigits,
	  cpOneBgDigitOrEnd
	  );
var
	l: integer;
	p: TLinePart;
	i: integer;
	c: TColorParse;
	n: smallint;

	procedure NewToken;
	begin
    	// If marked as parsing out color index(es) and
        // a new token is requested, reset color parser.
		if (c <> cpParsed) then
		begin
			p.Foreground := - 1;
			p.Background := - 2;
		end;
		c := cpParsed;
		p := aStyledLine.LineParts.Add;
	end;

	procedure CountNonCtrlChar;
	begin
		if (p.Start = 0) then
			p.Start := 1;
        p.Length := (p.Length + 1);
	end;

begin
	aStyledLine.LineParts.Clear;
	l := Length(aStyledLine.Text);
	if (l = 0) then
		Exit;

	p             := aStyledLine.LineParts.Add;
	p.Start      := 0;
	p.Style      := Font.Style;
	p.Foreground := - 1;
	p.Background := - 2;
	i             := 1;
	c             := cpParsed;
	while (i < l) do
	begin
		case aStyledLine^.Text[i] of
			CC_SPACE:
			begin
            	// Each space char is a potential wrap position.
				aStyledLine^.Wrappable.Add(i);
			end;
			CC_BOLD:
			begin
				NewToken;
                // Negate last token Bold style.
				if (fsBold in p^.Style) then
					Exclude(p^.Style, fsBold)
				else
					Include(p^.Style, fsBold);
			end;
			CC_ITALIC:
			begin
				NewToken;
                // Negate last token Italic style.
				if (fsBold in p^.Style) then
					Exclude(p^.Style, fsItalic)
				else
					Include(p^.Style, fsItalic);
			end;
			CC_UNDERLINE:
			begin
				NewToken;
                // Negate last token Underline style.
				if (fsBold in p^.Style) then
					Exclude(p^.Style, fsUnderline)
				else
					Include(p^.Style, fsUnderline);
			end;
			CC_REVERSE:
			begin
				NewToken;
                // Reverse FG/BG colors of our text view.
				p^.Foreground := - 2;
				p^.Background := - 1;
			end;
			CC_ORDINARY:
			begin
				NewToken;
                // Default colors of our text view.
				p^.Foreground := - 1;
				p^.Background := - 2;
				p^.Style      := Font.Style;
			end;
			CC_COLOR:
			begin
				NewToken;
                // Mark to start parsing color index(es).
				c := cpTwoFgDigits;
			end;
			else
			begin
				case c of
					cpParsed:
					begin
						CountNonCtrlChar;
					end;
					cpTwoFgDigits:
					begin
						n := StrToIntDef(aStyledLine^.Text[i], - 1);
						if (n <> - 1) then
						begin
							p^.Foreground := n;
							c             := cpOneFgDigitOrComma;
						end
						else
							NewToken;
					end;
					cpOneFgDigitOrComma:
					begin
						n := StrToIntDef(aStyledLine^.Text[i], - 1);
						if (n <> - 1) then
						begin
							p^.Foreground := ((p^.Foreground * 10) + n);
							c             := cpCommaOrEnd;
						end
						else if (aStyledLine^.Text[i] = ',') then
							c := cpTwoBgDigits
						else
							c := cpParsed;
					end;
					cpCommaOrEnd:
					begin
						if (aStyledLine^.Text[i] <> ',') then
						begin
							c := cpParsed;
							CountNonCtrlChar;
						end
						else
							c := cpTwoBgDigits;
					end;
					cpTwoBgDigits:
					begin
						n := StrToIntDef(aStyledLine^.Text[i], - 1);
						if (n <> - 1) then
						begin
							p^.Background := n;
							c             := cpOneBgDigitOrEnd;
						end
						else
							NewToken;
					end;
					cpOneBgDigitOrEnd:
					begin
						n := StrToIntDef(aStyledLine^.Text[i], - 1);
						if (n <> - 1) then
							p^.Background := ((p^.Background * 10) + n);
						c                 := cpParsed;
					end;
				end;
			end;
		end;
		Inc(i);
	end;

    // Calculate part widths.
	for i := 0 to aStyledLine^.LineParts.Count - 1 do
	begin
		p := aStyledLine.LineParts.Part(i);
		if (p^.Length > 0) then
		begin
			Canvas.Font.Style := p^.Style;
			p^.Width          := Canvas.TextWidth(Copy(aStyledLine^.Text, p^.Start, p^.Length));
		end;
	end;
	Canvas.Font.Assign(Font);

    // Update longest line.
	l     := 0;
	for i := 0 to aStyledLine^.LineParts.Count - 1 do
		l := l + aStyledLine^.LineParts.Part(i)^.Width;
	if (l > FLongestLine) then
		FLongestLine := l;
end;

{ TLinePart }

constructor TLinePart.Create;
begin
	inherited;

	FStart       := 0;
	FLength      := 0;
	FForeground  := clDefault;
	FBackground  := clDefault;
	FFontStyle   := [];
	FStyledWidth := 0;
end;

procedure TLinePart.Assign(aSource: TPersistent);
begin
	inherited;

	if (aSource is TLinePart) then
	begin
		Start       := TLinePart(aSource).Start;
		Length      := TLinePart(aSource).Length;
		Foreground  := TLinePart(aSource).Foreground;
		Background  := TLinePart(aSource).Background;
		FontStyle   := TLinePart(aSource).FontStyle;
		StyledWidth := TLinePart(aSource).StyledWidth;
	end;
end;

{ TLineParts }

constructor TLineParts.Create;
begin
	FList := TList.Create;
end;

destructor TLineParts.Destroy;
begin
	Clear;
	FList.Free;
	inherited;
end;

procedure TLineParts.Assign(aSource: TPersistent);
var
	i: integer;
begin
	if (aSource is TLineParts) then
	begin
		Clear;
		for i := 0 to TLineParts(aSource).Count - 1 do
			Add.Assign(TLineParts(aSource)[i]);
	end;
end;

function TLineParts.Add: TLinePart;
begin
	Result := Insert(Count, 0, 0);
end;

function TLineParts.Add(const aStart, aLength: integer): TLinePart;
begin
	Result := Insert(Count, aStart, aLength);
end;

function TLineParts.Insert(const aIndex, aStart, aLength: integer): TLinePart;
begin
	if (aIndex < 0) or (aIndex > FList.Count) then
		raise EListError.CreateFmt(SListIndexError, [aIndex]);

	Result        := TLinePart.Create;
	Result.Start  := aStart;
	Result.Length := aLength;
	FList.Insert(aIndex, Result);
end;

procedure TLineParts.Delete(const aIndex: integer);
begin
	TLinePart(FList[aIndex]).Free;
	FList.Delete(aIndex);
end;

procedure TLineParts.Clear;
var
	i: integer;
begin
	for i := 0 to Count - 1 do
		TLinePart(FList[i]).Free;
	FList.Clear;
end;

function TLineParts.GetCount: integer;
begin
	Result := FList.Count;
end;

function TLineParts.GetPart(const aIndex: integer): TLinePart;
begin
	Result := TLinePart(FList[aIndex]);
end;

procedure TLineParts.SetPart(const aIndex: integer; const aValue: TLinePart);
begin
	TLinePart(FList[aIndex]).Assign(aValue);
end;

{ TBreakPosition }

constructor TBreakPosition.Create;
begin
	FPosition := 0;
end;

procedure TBreakPosition.Assign(aSource: TPersistent);
begin
	if (aSource is TBreakPosition) then
	begin
		Position := TBreakPosition(aSource).Position;
	end;
end;

{ TBreakPositions }

constructor TBreakPositions.Create;
begin
	FList := TList.Create;
end;

destructor TBreakPositions.Destroy;
begin
	Clear;
	FList.Free;
	inherited;
end;

procedure TBreakPositions.Assign(aSource: TPersistent);
var
	i: integer;
begin
	if (aSource is TBreakPositions) then
	begin
		Clear;
		for i := 0 to TBreakPositions(aSource).Count - 1 do
			Add.Assign(TBreakPositions(aSource)[i]);
	end;
end;

function TBreakPositions.Add: TBreakPosition;
begin
	Result := Insert(Count, 0);
end;

function TBreakPositions.Add(const aPosition: integer): TBreakPosition;
begin
	Result := Insert(Count, aPosition);
end;

function TBreakPositions.Insert(const aIndex, aPosition: integer): TBreakPosition;
begin
	if (aIndex < 0) or (aIndex > FList.Count) then
		raise EListError.CreateFmt(SListIndexError, [aIndex]);

	Result          := TBreakPosition.Create;
	Result.Position := aPosition;

	FList.Insert(aIndex, Result);
end;

procedure TBreakPositions.Delete(const aIndex: integer);
begin
	TBreakPosition(FList[aIndex]).Free;
	FList.Delete(aIndex);
end;

procedure TBreakPositions.Clear;
var
	i: integer;
begin
	for i := 0 to Count - 1 do
		TBreakPosition(FList[i]).Free;
	FList.Clear;
end;

function TBreakPositions.GetCount: integer;
begin
	Result := FList.Count;
end;

function TBreakPositions.GetPosition(const aIndex: integer): TBreakPosition;
begin
	Result := TBreakPosition(FList[aIndex]);
end;

procedure TBreakPositions.SetPosition(const aIndex: integer; const aValue: TBreakPosition);
begin
	TBreakPosition(FList[aIndex]).Assign(aValue);
end;

{ TStyledLine }

constructor TStyledLine.Create;
begin
	FLineParts      := TLineParts.Create;
	FBreakPositions := TBreakPositions.Create;

	FLinesNeeded   := 0;
	FUnstyledWidth := 0;
end;

destructor TStyledLine.Destroy;
begin
	FBreakPositions.Free;
	FLineParts.Free;
	inherited;
end;

procedure TStyledLine.Assign(aSource: TPersistent);
begin
	if (aSource is TStyledLine) then
	begin
		Text := TStyledLine(aSource).Text;
		LineParts.Assign(TStyledLine(aSource).LineParts);
		BreakPositions.Assign(TStyledLine(aSource).BreakPositions);
	end;
end;

function TStyledLine.GetStyledWidth: integer;
var
	i: integer;
begin
	Result := 0;
	for i  := 0 to LineParts.Count - 1 do
		Inc(Result, LineParts[i].StyledWidth);
end;

procedure TStyledLine.SetBreakPositions(const Value: TBreakPositions);
begin
	FBreakPositions.Assign(Value);
end;

procedure TStyledLine.SetLineParts(const Value: TLineParts);
begin
	FLineParts.Assign(Value);
end;

procedure TStyledLine.SetText(const Value: string);
begin
	if (FText = Value) then
		Exit;
	FText := Value;
end;

{ TTextDisplayStrings }

constructor TTextDisplayStrings.Create;
begin
	inherited Create;
	FList     := TList.Create;
	FUpdating := False;
end;

destructor TTextDisplayStrings.Destroy;
begin
	Clear;
	FList.Free;
	inherited;
end;

procedure TTextDisplayStrings.Assign(aSource: TPersistent);
begin
	inherited;
	TokenizeLines;
end;

procedure TTextDisplayStrings.Insert(aIndex: integer; const aString: string);
var
	line: TStyledLine;
begin
	if (aIndex < 0) or (aIndex > Count) then
		Error(@SListIndexError, aIndex);

	line      := TStyledLine.Create;
	line.Text := aString;
	FList.Insert(aIndex, line);

	if (FTextDisplay <> nil) then
		FTextDisplay.TokenizeLine(line);
	Changed;
end;

procedure TTextDisplayStrings.Delete(aIndex: integer);
begin
	TStyledLine(FList[aIndex]).Free;
	FList.Delete(aIndex);
end;

procedure TTextDisplayStrings.Changed;
begin
	if (FUpdating) then
		Exit;
	if (FTextDisplay <> nil) then
		FTextDisplay.StringsChanged;
end;

procedure TTextDisplayStrings.Clear;
var
	i: integer;
begin
	for i := 0 to Count - 1 do
		TStyledLine(FList[i]).Free;
	FList.Clear;
	Changed;
end;

procedure TTextDisplayStrings.TokenizeLines;
var
	i: integer;
begin
	if (FTextDisplay = nil) then
		Exit;

	for i := 0 to Count - 1 do
		FTextDisplay.TokenizeLine(TStyledLine(FList[i]));
end;

procedure TTextDisplayStrings.RecalculateLineBreaks;
begin

end;

procedure TTextDisplayStrings.SetUpdateState(aUpdating: boolean);
begin
	inherited;
	FUpdating := aUpdating;
	if (FUpdating = False) then
		Changed;
end;

function TTextDisplayStrings.Get(aIndex: integer): string;
begin
	Result := TStyledLine(FList[aIndex]).Text;
end;

function TTextDisplayStrings.GetCount: integer;
begin
	Result := FList.Count;
end;

function TTextDisplayStrings.GetStyledLine(const aIndex: integer): TStyledLine;
begin
	Result := TStyledLine(FList[aIndex]);
end;

procedure TTextDisplayStrings.Put(aIndex: integer; const aString: string);
begin
	TStyledLine(FList[aIndex]).Text := aString;
	if (FTextDisplay <> nil) then
		FTextDisplay.TokenizeLine(TStyledLine(FList[aIndex]));
	Changed;
end;

{ TCustomTextDisplay }

constructor TCustomTextDisplay.Create(aOwner: TComponent);
begin
	inherited;

	Color  := clWindow;
	Width  := 320;
	Height := 240;

	ParentColor  := False;
	FBorderStyle := bsSingle;
	FLinesAnchor := laTop;

	FLines                                   := TTextDisplayStrings.Create;
	TTextDisplayStrings(FLines).FTextDisplay := Self;
	FWordWrap                                := False;
	FWordWrapIndent                          := 10;

	FFontHeight := 0;
	FFontWidth  := 0;

	FWindowLines     := 0;
	FWindowColumns   := 0;
	FWindowLinesLast := 0;

	FLongestLine := 0;

	FVScrollPos := 0;
	FHScrollPos := 0;

	FVScrollMax := 0;
	FHScrollMax := 0;
end;

destructor TCustomTextDisplay.Destroy;
begin
	FLines.Free;
	inherited;
end;

procedure TCustomTextDisplay.Assign(aSource: TPersistent);
begin
	inherited;

	if (aSource is TCustomTextDisplay) then
	begin
		BorderStyle  := TCustomTextDisplay(aSource).BorderStyle;
		CopyOnSelect := TCustomTextDisplay(aSource).CopyOnSelect;
		Styler       := TCustomTextDisplay(aSource).Styler;
		Lines.Assign(TCustomTextDisplay(aSource).Lines);
		LinesAnchor    := TCustomTextDisplay(aSource).LinesAnchor;
		WordWrap       := TCustomTextDisplay(aSource).WordWrap;
		WordWrapIndent := TCustomTextDisplay(aSource).WordWrapIndent;
	end;
end;

procedure TCustomTextDisplay.CreateHandle;
begin
	if (Parent = nil) then
		Exit;
	inherited CreateHandle;
end;

procedure TCustomTextDisplay.CreateParams(var aParams: TCreateParams);
begin
	inherited CreateParams(aParams);

	aParams.Style := aParams.Style or WS_HSCROLL or WS_VSCROLL;

	if (FBorderStyle = bsSingle) then
	begin
		aParams.Style   := aParams.Style and not WS_BORDER;
		aParams.ExStyle := aParams.ExStyle or WS_EX_CLIENTEDGE;
	end;
	aParams.WindowClass.Style := aParams.WindowClass.Style and not (CS_HREDRAW or CS_VREDRAW);
end;

procedure TCustomTextDisplay.Notification(aComponent: TComponent; aOperation: TOperation);
begin
	inherited Notification(aComponent, aOperation);

	if (aOperation = opRemove) and (aComponent = Styler) then
		SetStyler(nil);
end;

procedure TCustomTextDisplay.Loaded;
begin
	inherited;
	Resize;
end;

procedure TCustomTextDisplay.Resize;
begin
	inherited;

	if (WordWrap) then
		TTextDisplayStrings(FLines).RecalculateLineBreaks;

	if (FFontHeight <> 0) then
	begin
		FWindowLines := Min(ClientHeight div FFontHeight, FLines.Count);
		if (FVScrollPos + FWindowLines > FLines.Count) then
		begin
			FVScrollPos := FLines.Count - FWindowLines;
			InvalidateRect(Handle, nil, False);
		end;
	end;

	if (FFontWidth <> 0) then
	begin
		FWindowColumns := Min(ClientWidth div FFontWidth, FLongestLine);
		if (FHScrollPos + FWindowColumns > FLongestLine) then
		begin
			FHScrollPos := FLongestLine - FWindowColumns;
			InvalidateRect(Handle, nil, False);
		end;
	end;

	CalculateScrollbars;
	Repaint;
end;

procedure TCustomTextDisplay.Paint;
var
	first, last, extra, i: integer;
	offset               : word;
begin
	inherited;

	// Find first and last line to paint.
	first := (FVScrollPos + (ClientRect.Top div FFontHeight));
	last  := (FVScrollPos + (ClientRect.Bottom div FFontHeight));
	if (LinesAnchor = laBottom) then
		offset := (ClientRect.Bottom mod FFontHeight)
	else
		offset := 0;

	// Calculate extra lines from 0 to first needed because of WordWarp.
	extra := 0;
	for i := 0 to first - 1 do
	begin

	end;

	// Offset last by extra lines.
	Dec(last, extra);

	// Check if anything needs painting at all.
	if (last < first) then
		Exit;

	// Paint 'em.
	for i := first to last do
		PaintLine(i, offset);
end;

procedure TCustomTextDisplay.TokenizeLine(aStyledLine: TStyledLine);
var
	lp: TLinePart;
	i : integer;
begin
	if (aStyledLine.Text = EmptyStr) then
		Exit;

	if (Styler = nil) then
	begin
		// With no Styler, treat string as one styled part.
		lp        := aStyledLine.LineParts.Add;
		lp.Start  := 1;
		lp.Length := Length(aStyledLine.Text);

		if (lp.Length > FLongestLine) then
			FLongestLine := lp.Length;

		// Find all places where string is wrappable.
		i := 1;
		while (i <> 0) do
		begin
			i := PosEx(#32, aStyledLine.Text, i);
			if (i = 0) then
				Break;
			aStyledLine.BreakPositions.Add.Position := i;
			Inc(i);
		end;

		// Get unstyled string width
		aStyledLine.UnstyledWidth := Canvas.TextWidth(aStyledLine.Text);

		// Get num of lines needed for WordWrap.
		aStyledLine.LinesNeeded := Max(1, (aStyledLine.UnstyledWidth div ClientWidth));
	end
	else
		Styler.TokenizeLine(aStyledLine);
end;

procedure TCustomTextDisplay.PaintLine(const aLine: integer; const aOffset: word);
var
	r: TRect;
begin
	if (aLine < 0) or (aLine >= FLines.Count) then
		Exit;

	r := ClientRect;

	r.Left   := - FHScrollPos * FFontWidth;
	r.Top    := (aLine - FVScrollPos) * FFontHeight;
	r.Right  := r.Right;
	r.Bottom := r.Top + FFontHeight;

	// Remainder
	r.Top    := r.Top + aOffset;
	r.Bottom := r.Bottom + aOffset;

	if (aLine >= FLines.Count) then
		Exit;

	Canvas.FillRect(r);

	//Canvas.TextOut(r.Left, r.Top, IntToStr(TTextDisplayStrings(FLines).StyledLines[aLine].LinesNeeded));

	Canvas.TextOut(r.Left, r.Top, FLines[aLine]);
end;

function TCustomTextDisplay.GetTrackPos(nBar: integer): LONG;
var
	si: TScrollInfo;
begin
	ZeroMemory(@si, SizeOf(si));
	si.cbSize := SizeOf(si);
	si.fMask  := SIF_TRACKPOS;
	GetScrollInfo(Handle, nBar, si);
	Result := si.nTrackPos;
end;

procedure TCustomTextDisplay.CalculateScrollbars;
var
	si: TScrollInfo;
begin
	// Init ScrollInfo.
	ZeroMemory(@si, SizeOf(si));
	si.cbSize := SizeOf(si);
	si.fMask  := SIF_PAGE or SIF_POS or SIF_RANGE or SIF_DISABLENOSCROLL;

	//	Vertical scrollbar
	if (FLinesAnchor = laBottom) then
	begin
		FVScrollPos := FVScrollPos - (FWindowLines - FWindowLinesLast);
		if (FVScrollPos < 0) then
			FVScrollPos := 0;
		if (FVScrollPos > FLines.Count - 1) then
			FVScrollPos := FLines.Count - 1;
	end;
	FWindowLinesLast := FWindowLines;

	si.nPos  := FVScrollPos;  // scrollbar thumb position
	si.nPage := FWindowLines; // number of lines in a page
	si.nMin  := 0;
	si.nMax  := FLines.Count - 1; // total number of lines in file

	SetScrollInfo(Handle, SB_VERT, &si, True);
	// adjust our interpretation of the max scrollbar range to make
	// range-checking easier. The scrollbars don't use these values, they
	// are for our own use.
	FVScrollMax := FLines.Count - FWindowLines;

	// If we're wordwrapped exit before setting horizontal scollbar infos.
	if (FWordWrap) then
		Exit;

	//	Horizontal scrollbar
	si.nPos  := FHScrollPos;    // scrollbar thumb position
	si.nPage := FWindowColumns; // number of lines in a page
	si.nMin  := 0;
	si.nMax  := FLongestLine - 1; // total number of lines in file

	SetScrollInfo(Self.Handle, SB_HORZ, &si, True);
	// adjust our interpretation of the max scrollbar range to make
	// range-checking easier. The scrollbars don't use these values, they
	// are for our own use.
	FHScrollMax := FLongestLine - FWindowColumns;
end;

procedure TCustomTextDisplay.Scroll(const aDX, aDY: integer);
var
	dy: integer;
	dx: integer;
begin
	dx := aDX;
	dy := aDY;

	// Make sure that dx, dy don't scroll us past the edge of the document!

	if (dy < 0) then
		dy := - integer(Min(ULONG( - dy), FVScrollPos)) // scroll up
	else if (dy > 0) then
		dy := Min(ULONG(dy), FVScrollMax - FVScrollPos); // scroll down

	if (dx < 0) then
		dx := - integer(Min( - dx, FHScrollPos)) // scroll left
	else if (dx > 0) then
		dx := Min(dx, FHScrollMax - FHScrollPos); // scroll right

	// adjust the scrollbar thumb position
	Inc(FHScrollPos, dx);
	Inc(FVScrollPos, dy);

	// perform the scroll
	if ((dx = 0) and (dy = 0)) then
		Exit;

	ScrollWindowEx(Handle, - dx * FFontWidth, - dy * FFontHeight, nil, nil, 0, nil, SW_INVALIDATE);
	CalculateScrollbars;
end;

procedure TCustomTextDisplay.StringsChanged;
begin
	if ((FVScrollPos = FVScrollMax) and (FLinesAnchor = laBottom)) then
	begin
		Resize;
		Repaint;
		Scroll(0, MaxInt);
		Exit;
	end;

	Resize;
	Repaint;
end;

procedure TCustomTextDisplay.SetBorderStyle(const Value: TBorderStyle);
begin
	if (FBorderStyle = Value) then
		Exit;
	FBorderStyle := Value;
	RecreateWnd;
end;

procedure TCustomTextDisplay.SetLines(const aValue: TStrings);
begin
	FLines.Assign(aValue);
end;

procedure TCustomTextDisplay.SetLinesAnchor(const Value: TLinesAnchor);
begin
	if (FLinesAnchor = Value) then
		Exit;
	FLinesAnchor := Value;
	Resize;
	Repaint;
end;

procedure TCustomTextDisplay.SetStyler(const Value: TTextDisplayStyler);
begin
	if (Styler <> nil) then
		Styler.FTextDisplay := nil;

	FStyler := Value;

	if (Styler <> nil) then
	begin
		FStyler.FTextDisplay := Self;
		Styler.FreeNotification(Self);
	end;
	TTextDisplayStrings(FLines).TokenizeLines;

	{ Update everything! }
end;

procedure TCustomTextDisplay.SetWordWrap(const Value: boolean);
begin
	if (FWordWrap = Value) then
		Exit;
	FWordWrap := Value;
	ShowScrollBar(Handle, SB_HORZ, not FWordWrap);
	Resize;
	Repaint;
end;

procedure TCustomTextDisplay.SetWordWrapIndent(const Value: integer);
begin
	if (FWordWrapIndent = Value) then
		Exit;
	FWordWrapIndent := Value;
	Resize;
	Repaint;
end;

procedure TCustomTextDisplay.CMColorchanged(var Message: TMessage);
begin
	Canvas.Brush.Color := Color;
	Repaint;
end;

procedure TCustomTextDisplay.CMFontchanged(var Message: TMessage);
var
	tm: TTextMetric;
begin
	Canvas.Font.Assign(Font);

	GetTextMetrics(Canvas.Handle, tm);

	FFontHeight := tm.tmHeight;
	FFontWidth  := tm.tmAveCharWidth;

	Resize;
end;

procedure TCustomTextDisplay.WMVScroll(var Message: TWMVScroll);
var
	oldpos: integer;
begin
	oldpos := FVScrollPos;

	case message.ScrollCode of
		SB_TOP:
		begin
			FVScrollPos := 0;
			InvalidateRect(Handle, nil, False);
		end;

		SB_BOTTOM:
		begin
			FVScrollPos := FVScrollMax;
			InvalidateRect(Handle, nil, False);
		end;

		SB_LINEUP:
		Scroll(0, - 1);

		SB_LINEDOWN:
		Scroll(0, 1);

		SB_PAGEUP:
		Scroll(0, - FWindowLines);

		SB_PAGEDOWN:
		Scroll(0, FWindowLines);

		SB_THUMBPOSITION, SB_THUMBTRACK:
		begin
			FVScrollPos := GetTrackPos(SB_VERT);
			InvalidateRect(Handle, nil, False);
		end;
	end;

	if (oldpos <> FVScrollPos) then
		CalculateScrollbars;

	message.Result := 0;
end;

procedure TCustomTextDisplay.WMHScroll(var Message: TWMHScroll);
var
	oldpos: integer;
begin
	oldpos := FHScrollPos;

	case message.ScrollCode of
		SB_LEFT:
		begin
			FHScrollPos := 0;
			InvalidateRect(Handle, nil, False);
		end;

		SB_RIGHT:
		begin
			FHScrollPos := FHScrollMax;
			InvalidateRect(Handle, nil, False);
		end;

		SB_LINELEFT:
		Scroll( - 1, 0);

		SB_LINERIGHT:
		Scroll(1, 0);

		SB_PAGELEFT:
		Scroll( - FWindowColumns, 0);

		SB_PAGERIGHT:
		Scroll(FWindowColumns, 0);

		SB_THUMBPOSITION, SB_THUMBTRACK:
		begin
			FHScrollPos := GetTrackPos(SB_HORZ);
			InvalidateRect(Handle, nil, False);
		end;
	end;

	if (oldpos <> FHScrollPos) then
		CalculateScrollbars;

	message.Result := 0;
end;

end.
