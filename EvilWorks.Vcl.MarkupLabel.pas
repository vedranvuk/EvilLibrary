unit EvilWorks.Vcl.MarkupLabel;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
	THTMLElement = class(TObject)
	private
		FFontSize : integer;
		FText     : string;
		FFontName : string;
		FFontStyle: TFontStyles;
		FFontColor: TColor;
		FAscent   : integer;
		FHeight   : integer;
		FWidth    : integer;
		FSolText  : string;
		FEolText  : string;
		FBreakLine: boolean;
		procedure SetFontName(const Value: string);
		procedure SetFontSize(const Value: integer);
		procedure SetFontStyle(const Value: TFontStyles);
		procedure SetText(const Value: string);
		procedure SetFontColor(const Value: TColor);
		procedure SetAscent(const Value: integer);
		procedure SetHeight(const Value: integer);
		procedure SetWidth(const Value: integer);
		procedure SetEolText(const Value: string);
		procedure SetSolText(const Value: string);
		procedure SetBreakLine(const Value: boolean);
	public
		procedure Break(ACanvas: TCanvas; available: integer);
		property Text: string read FText write SetText;
		property SolText: string read FSolText write SetSolText;
		property EolText: string read FEolText write SetEolText;
		property FontName: string read FFontName write SetFontName;
		property FontSize: integer read FFontSize write SetFontSize;
		property FontStyle: TFontStyles read FFontStyle write SetFontStyle;
		property FontColor: TColor read FFontColor write SetFontColor;
		property Height: integer read FHeight write SetHeight;
		property Width: integer read FWidth write SetWidth;
		property Ascent: integer read FAscent write SetAscent;
		property BreakLine: boolean read FBreakLine write SetBreakLine;
	end;

	THTMLElementStack = class(TList)
	public
		destructor Destroy; override;
		procedure Clear; override;
    	// will free ALL elements in the stack
		procedure push(Element: THTMLElement);
		function pop: THTMLElement;
    	// calling routine is responsible for freeing the element.
		function peek: THTMLElement;
    	// calling routine must NOT free the element
	end;

	TMarkupLabel = class(TGraphicControl)
	private
    { Private declarations }
		ElementStack: THTMLElementStack;
		TagStack    : THTMLElementStack;
		FText       : string;
		FBackColor  : TColor;
		FMarginLeft : integer;
		FMarginRight: integer;
		FMarginTop  : integer;
		procedure ParseHTML(S: string);
		procedure RenderHTML;
		procedure HTMLClearBreaks;
		procedure HTMLElementDimensions;
		procedure SetBackColor(const Value: TColor);
		procedure SetText(const Value: string);
		procedure SetMarginLeft(const Value: integer);
		procedure SetMarginRight(const Value: integer);
		procedure SetMarginTop(const Value: integer);
	protected
    { Protected declarations }
	public
    { Public declarations }
		constructor Create(AOwner: TComponent); override;
		destructor Destroy; override;
		procedure Paint; override;
	published
    { Published declarations }
		property Text       : string read FText write SetText;
		property BackColor  : TColor read FBackColor write SetBackColor default clBtnFace;
		property MarginLeft : integer read FMarginLeft write SetMarginLeft default 5;
		property MarginRight: integer read FMarginRight write SetMarginRight default 5;
		property MarginTop  : integer read FMarginTop write SetMarginTop default 5;
	end;

implementation

{ THTMLElement }

procedure THTMLElement.Break(ACanvas: TCanvas; available: integer);
var
	S   : string;
	i, w: integer;
begin
	Acanvas.font.Name  := fontname;
	Acanvas.font.size  := fontsize;
	Acanvas.font.style := fontstyle;
	Acanvas.font.Color := fontcolor;
	if solText = '' then
		S := Text
	else
		S := Eoltext;
	if acanvas.TextWidth(S) <= available then
	begin
		soltext := S;
		eoltext := '';
		exit;
	end;
	for i := length(S) downto 1 do
	begin
		if S[i] = ' ' then
		begin
			w := acanvas.TextWidth(copy(S, 1, i));
			if w <= available then
			begin
				soltext := copy(S, 1, i);
				eoltext := copy(S, i + 1, length(S));
				exit;
			end;
		end;
	end;
end;

procedure THTMLElement.SetAscent(const Value: integer);
begin
	FAscent := Value;
end;

procedure THTMLElement.SetBreakLine(const Value: boolean);
begin
	FBreakLine := Value;
end;

procedure THTMLElement.SetEolText(const Value: string);
begin
	FEolText := Value;
end;

procedure THTMLElement.SetFontColor(const Value: TColor);
begin
	FFontColor := Value;
end;

procedure THTMLElement.SetFontName(const Value: string);
begin
	FFontName := Value;
end;

procedure THTMLElement.SetFontSize(const Value: integer);
begin
	FFontSize := Value;
end;

procedure THTMLElement.SetFontStyle(const Value: TFontStyles);
begin
	FFontStyle := Value;
end;

procedure THTMLElement.SetHeight(const Value: integer);
begin
	FHeight := Value;
end;

procedure THTMLElement.SetSolText(const Value: string);
begin
	FSolText := Value;
end;

procedure THTMLElement.SetText(const Value: string);
begin
	FText := Value;
end;

procedure THTMLElement.SetWidth(const Value: integer);
begin
	FWidth := Value;
end;

{ THTMLElementStack }

procedure THTMLElementStack.Clear;
var
	i, c: integer;
begin
	c := Count;
	if c > 0 then
		for i := 0 to c - 1 do
			THTMLElement(items[i]).Free;
	inherited;
end;

destructor THTMLElementStack.Destroy;
begin
	Clear;
	inherited;
end;

function THTMLElementStack.peek: THTMLElement;
var
	c: integer;
begin
	c := Count;
	if c = 0 then
		Result := nil
	else
	begin
		Result := THTMLElement(items[c - 1]);
	end;
end;

function THTMLElementStack.pop: THTMLElement;
var
	c: integer;
begin
	c := Count;
	if c = 0 then
		Result := nil
	else
	begin
		Result := THTMLElement(items[c - 1]);
		Delete(c - 1);
	end;
end;

procedure THTMLElementStack.push(Element: THTMLElement);
begin
	add(Element);
end;

{ TvvMarkupLabel }

constructor TMarkupLabel.Create(AOwner: TComponent);
begin
	inherited;
	Elementstack := THTMLElementStack.Create;
	TagStack     := THTMLElementStack.Create;
	FBackcolor   := clBtnFace;
	Width        := 200;
	Height       := 100;
	FMarginLeft  := 5;
	FMarginRight := 5;
	FMargintop   := 5;
end;

destructor TMarkupLabel.Destroy;
begin
	ElementStack.Free;
	TagStack.Free;
	inherited;
end;

procedure TMarkupLabel.HTMLClearBreaks;
var
	i, c: integer;
	El  : THTMLElement;
begin
	c := ElementStack.Count;
	if c = 0 then
		exit;
	for i := 0 to c - 1 do
	begin
		el         := THTMLElement(ElementStack.items[i]);
		el.SolText := '';
		el.EolText := '';
	end;
end;

procedure TMarkupLabel.HTMLElementDimensions;
var
	i, c   : integer;
	El     : THTMLElement;
	h, a, w: integer;
	tm     : Textmetric;
	S      : string;
begin
	c := ElementStack.Count;
	if c = 0 then
		exit;
	for i := 0 to c - 1 do
	begin
		el                := THTMLElement(ElementStack.items[i]);
		S                 := el.Text;
		Canvas.font.Name  := el.FontName;
		Canvas.font.size  := el.FontSize;
		Canvas.font.style := el.FontStyle;
		Canvas.font.Color := el.FontColor;
		gettextmetrics(Canvas.handle, tm);
		h         := tm.tmHeight;
		a         := tm.tmAscent;
		w         := Canvas.TextWidth(S);
		el.Height := h;
		el.Ascent := a;
		el.Width  := w;
	end;
end;

procedure TMarkupLabel.Paint;
begin
	RenderHTML;
end;

procedure TMarkupLabel.ParseHTML(S: string);
var
	p             : integer;
	se, st        : string;
	ftext         : string;
	fstyle        : TfontStyles;
	fname         : string;
	fsize         : integer;
	fbreakLine    : boolean;
	aColor, fColor: Tcolor;
	Element       : THTMLElement;

	function HTMLStringToColor(v: string; var col: Tcolor): boolean;
	var
		vv: string;
	begin
		if copy(v, 1, 1) <> '#' then
		begin
			vv := 'cl' + v;
			try
				col    := stringtoColor(vv);
				Result := True;
			except
				Result := False;
			end;
		end
		else
		begin
			try
				vv     := '$' + copy(v, 6, 2) + copy(v, 4, 2) + copy(v, 2, 2);
				col    := stringtocolor(vv);
				Result := True;
			except
				Result := False;
			end;
		end;
	end;

	procedure pushTag;
	begin
		Element           := THTMLElement.Create;
		element.FontName  := fname;
		element.FontSize  := fsize;
		element.FontStyle := fstyle;
		element.FontColor := fColor;
		TagStack.push(Element);
	end;

	procedure popTag;
	begin
		Element := TagStack.pop;
		if element <> nil then
		begin
			fname  := element.FontName;
			fsize  := element.FontSize;
			fstyle := element.FontStyle;
			fcolor := element.FontColor;
			Element.Free;
		end;
	end;

	procedure pushElement;
	begin
		Element           := THTMLElement.Create;
		Element.Text      := ftext;
		element.FontName  := fname;
		element.FontSize  := fsize;
		element.FontStyle := fstyle;
		element.FontColor := fColor;
		element.BreakLine := fBreakLine;
		fBreakLine        := False;
		ElementStack.push(Element);
	end;

	procedure parseTag(ss: string);
	var
		pp              : integer;
		atag, apar, aval: string;
		havepar         : boolean;
	begin
		ss      := trim(ss);
		havepar := False;
		pp      := pos(' ', ss);
		if pp = 0 then
		begin // tag only
			atag := ss;
		end
		else
		begin // tag + atrributes
			atag    := copy(ss, 1, pp - 1);
			ss      := trim(copy(ss, pp + 1, length(ss)));
			havepar := True;
		end;
    // handle atag
		atag := lowercase(atag);
		if atag = 'br' then
			fBreakLine := True
		else
		  if atag = 'b' then
		begin // bold
			pushtag;
			fstyle := fstyle + [fsbold];
		end
		else
		  if atag = '/b' then
		begin // cancel bold
			fstyle := fstyle - [fsbold];
			poptag;
		end
		else
		  if atag = 'i' then
		begin // italic
			pushtag;
			fstyle := fstyle + [fsitalic];
		end
		else
		  if atag = '/i' then
		begin // cancel italic
			fstyle := fstyle - [fsitalic];
			poptag;
		end
		else
		  if atag = 'u' then
		begin // underline
			pushtag;
			fstyle := fstyle + [fsunderline];
		end
		else
		  if atag = '/u' then
		begin // cancel underline
			fstyle := fstyle - [fsunderline];
			poptag;
		end
		else
		  if atag = 'font' then
		begin
			pushtag;
		end
		else
		  if atag = '/font' then
		begin
			poptag;
		end;
		if havepar then
		begin
			repeat
				pp := pos('="', ss);
				if pp > 0 then
				begin
					aPar := lowercase(trim(copy(ss, 1, pp - 1)));
					Delete(ss, 1, pp + 1);
					pp := pos('"', ss);
					if pp > 0 then
					begin
						aVal := copy(ss, 1, pp - 1);
						Delete(ss, 1, pp);
						if aPar = 'face' then
						begin
							fname := aVal;
						end
						else
						  if aPar = 'size' then
							try
								fsize := StrToInt(aval);
							except
							end
						else
						  if aPar = 'color' then
							try
								if HTMLStringToColor(aval, aColor) then
									fcolor := aColor;
							except
							end;
					end;
				end;
			until pp = 0;
		end;
	end;

begin
	ElementStack.Clear;
	TagStack.Clear;
	fstyle     := [];
	fname      := 'arial';
	fsize      := 12;
	fColor     := clblack;
	fBreakLine := False;
	repeat
		p := pos('<', S);
		if p = 0 then
		begin
			fText := S;
			PushElement;
		end
		else
		begin
			if p > 1 then
			begin
				se    := copy(S, 1, p - 1);
				ftext := se;
				pushElement;
				Delete(S, 1, p - 1);
			end;
			p := pos('>', S);
			if p > 0 then
			begin
				st := copy(S, 2, p - 2);
				Delete(S, 1, p);
				parseTag(st);
			end;
		end;
	until p = 0;
end;

procedure TMarkupLabel.RenderHTML;
var
	R                   : TRect;
	X, Y, xav, clw      : integer;
	baseline            : integer;
	i, c                : integer;
	el                  : THTMLElement;
	eol                 : boolean;
	ml                  : integer; // margin left
	isol, ieol          : integer;
	maxheight, maxascent: integer;
	pendingBreak        : boolean;

	procedure SetFont(ee: THTMLElement);
	begin
		with Canvas do
		begin
			font.Name  := ee.FontName;
			font.Size  := ee.FontSize;
			font.Style := ee.FontStyle;
			font.Color := ee.FontColor;
		end;
	end;

	procedure RenderString(ee: THTMLElement);
	var
		ss: string;
		ww: integer;
	begin
		SetFont(ee);
		if ee.soltext <> '' then
		begin
			ss := ee.SolText;
			ww := Canvas.TextWidth(ss);
			Canvas.TextOut(X, Y + baseline - ee.Ascent, ss);
			X := X + ww;
		end;
	end;

begin
	R                  := clientrect;
	Canvas.Brush.Color := BackColor;
	Canvas.FillRect(R);
	c := ElementStack.Count;
	if c = 0 then
		exit;
	HTMLClearBreaks;
	clw                := ClientWidth - FMarginRight;
	ml                 := MarginLeft;
	Canvas.Brush.style := bsclear;
	Y                  := FMarginTop;
	isol               := 0;
	ieol               := 0;
	pendingBreak       := False;
	repeat
		i         := isol;
		xav       := clw;
		maxHeight := 0;
		maxAscent := 0;
		eol       := False;
		repeat // scan line
			el := THTMLElement(ElementStack.items[i]);
			if el.BreakLine then
			begin
				if not pendingBreak then
				begin
					pendingBreak := True;
					ieol         := i;
					break;
				end
				else
					pendingBreak := False;
			end;
			if el.Height > maxheight then
				maxheight := el.Height;
			if el.Ascent > maxAscent then
				maxAscent := el.Ascent;
			el.Break(Canvas, xav);
			if el.soltext <> '' then
			begin
				xav := xav - Canvas.TextWidth(el.Soltext);
				if el.EolText = '' then
				begin
					if i >= c - 1 then
					begin
						eol  := True;
						ieol := i;
					end
					else
					begin
						Inc(i);
					end;
				end
				else
				begin
					eol  := True;
					ieol := i;
				end;
			end
			else
			begin // eol
				eol  := True;
				ieol := i;
			end;
		until eol;
    // render line
		X        := ml;
		baseline := maxAscent;
		for i    := isol to ieol do
		begin
			el := THTMLElement(ElementStack.items[i]);
			RenderString(el);
		end;
		Y    := Y + maxHeight;
		isol := ieol;
	until (ieol >= c - 1) and (el.EolText = '');
end;

procedure TMarkupLabel.SetBackColor(const Value: TColor);
begin
	if Value <> FBackColor then
	begin
		FBackcolor := Value;
		Invalidate;
	end;
end;

procedure TMarkupLabel.SetMarginLeft(const Value: integer);
begin
	FMarginLeft := Value;
	Invalidate;
end;

procedure TMarkupLabel.SetMarginRight(const Value: integer);
begin
	FMarginRight := Value;
	Invalidate;
end;

procedure TMarkupLabel.SetMarginTop(const Value: integer);
begin
	FMarginTop := Value;
	Invalidate;
end;

procedure TMarkupLabel.SetText(const Value: string);
const
	cr  = chr(13) + chr(10);
	tab = chr(9);
var
	S: string;
begin
	if Value = FText then
		exit;
	S := Value;
	S := stringreplace(S, cr, ' ', [rfreplaceall]);
	S := Trimright(S);
	parseHTML(S);
	HTMLElementDimensions;
	FText := S;
	Invalidate;
end;

end.
