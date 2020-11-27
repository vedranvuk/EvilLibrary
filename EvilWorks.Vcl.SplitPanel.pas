unit EvilWorks.Vcl.SplitPanel;

interface

uses
	WinApi.Windows,
	WinAPi.Messages,
	System.Classes,
	System.SysUtils,
	System.Math,
	Vcl.Graphics,
	Vcl.Controls,
	Vcl.Forms;

type

	{ Forward declarations }
	TSplitPanel = class;

	{ Enums }
	TAnimationType = (
	  atExpand,
	  atCollapse
	  );

	TOrientation = (
	  orHorizontal,
	  orVertical
	  );

	TResizeStyle = (
	  rsUpdate,
	  rsPattern,
	  rsCannotResize
	  );

	TSplitterButton = (
	  sbTopLeft,
	  sbBottomRight,
	  sbCenter,
	  sbRestore
	  );

	TButtonsSize = (
	  bsSmall,
	  bsNormal,
	  bsLarge
	  );

	TMaximizeButtons = (
	  mbxTopLeft,
	  mbxBottomRight,
	  mbxBoth,
	  mbxNone
	  );

	TButtonGlyph = (
	  bgLeft,
	  bgUp,
	  bgRight,
	  bgDown,
	  bgRestore
	  );

	TMaximizeState = (
	  msTopLeft,
	  msBottomRight,
	  msCenter,
	  msRestore
	  );

	{ Events }
	TOnDrawButtonEvent    = procedure(Sender: TObject; ACanvas: TCanvas; ButtonRect: TRect; ArrowDir: TButtonGlyph; Highlighted: boolean) of object;
	TOnMaximizePaneEvent  = procedure(Sender: TObject; MaximizeState: TMaximizeState) of object;
	TOnSplitterMovedEvent = procedure(Sender: TObject; SplitterPosition: integer) of object;

	TSplitPanel = class(TCustomControl)
	private type
		TAnimationThread = class(TThread)
		private
			FStart        : integer;
			FEnd          : integer;
			FDuration     : word;
			FAnimationType: TAnimationType;
			FValue        : integer;
			FControl      : TControl;
		protected
			procedure SetSize;
		public
			constructor Create(A, B, Duration: integer; AnimationType: TAnimationType; Finish: TNotifyEvent; Control: TSplitPanel);
			procedure Execute; override;
		end;

		TPane = class(TCustomControl)
		private
			FDesignActive: boolean;
			FIndex       : byte;
			FSplitPanel  : TSplitPanel;
			procedure SetIndex(const Value: byte);
			procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
		protected
			procedure DefineProperties(Filer: TFiler); override;
			procedure LoadIndex(Reader: TReader);
			procedure SaveIndex(Writer: TWriter);
			procedure CMDesignHitTest(var Msg: TCMDesignHitTest); message CM_DESIGNHITTEST;
			property PaneIndex: byte read FIndex write SetIndex;
		public
			constructor Create(AOwner: TComponent); override;
			procedure Paint; override;
		published
			property DoubleBuffered;
			property ParentDoubleBuffered;
		end;
	private
		FAnimated            : boolean;
		FAnimationThread     : TAnimationThread;
		FAnimationDuration   : cardinal;
		FSaveSize            : integer;
		FButtonsSize         : TButtonsSize;
		FMaximizeButtons     : TMaximizeButtons;
		FRestoreButton       : boolean;
		FDragging            : boolean;
		FTopLeftHighlight    : boolean;
		FBottomRightHighlight: boolean;
		FRestoreHighlight    : boolean;
		FTopLeftClick        : boolean;
		FBottomRightClick    : boolean;
		FRestoreClick        : boolean;
		FOrientation         : TOrientation;
		FPaneA               : TPane;
		FPaneB               : TPane;
		FMaximizeState       : TMaximizeState;
		FMemBitmap           : TBitmap;
		FMinSizeTopLeft      : integer;
		FMinSizeBottomRight  : integer;
		FPaneControlListA    : TStringList;
		FPaneControlListB    : TStringList;
		FProportional        : boolean;
		FRatio               : single;
		FResizeStyle         : TResizeStyle;
		FSplitterColor       : TColor;
		FSplitterPosition    : integer;
		FSplitterSize        : byte;
		FPatternDC           : HDC;
		FPatternBrush        : TBrush;
		FLineVisible         : boolean;
		FPatternPosition     : integer;

		FOnDrawButtonEvent     : TOnDrawButtonEvent;
		FOnMaximizePaneEvent   : TOnMaximizePaneEvent;
		FOnSplitterMovedEvent  : TOnSplitterMovedEvent;
		FButtonNormalBackground: TColor;
		FButtonNormalBorder    : TColor;
		FButtonHotBackground   : TColor;
		FButtonHotBorder       : TColor;
		FPaintPanes            : boolean;

		procedure SetButtonsSize(const Value: TButtonsSize);
		procedure SetSplitterPosition(const Value: integer);
		procedure SetSplitterColor(const Value: TColor);
		procedure SetOrientation(const Value: TOrientation);
		procedure SetProportional(const Value: boolean);
		procedure SetSplitterSize(const Value: byte);
		procedure SetMaximizeState(const Value: TMaximizeState);
		procedure SetResizeStyle(const Value: TResizeStyle);

		function GetSplitterRect: TRect;
		function GetButtonRect(Button: TSplitterButton): TRect;

		procedure AnimationFinished(Sender: TObject);
		procedure Animate;
		procedure CreatePanes;
		procedure SplitButtonClick(AButton: TSplitterButton);
		procedure ResetRatio;
		procedure ResizePanes;
		procedure UpdateSplitterPosition;
		procedure CheckMaxMin;
		procedure MaximizePane;
		procedure AllocatePatternDC;
		procedure ReleasePatternDC;
		procedure DrawBackground;
		procedure DrawSplitter(HighlightedTopLeft, HighlightedBottomRight, HighlightedRestore: boolean);
		procedure DrawPattern;

		procedure SetRestoreButton(const Value: boolean);
		procedure SetButtonColor(const Index: integer; const Value: TColor);
		function GetPaneA: TPane;
		function GetPaneB: TPane;
		procedure SetMaximizeButtons(const Value: TMaximizeButtons);
	protected
		procedure DefineProperties(Filer: TFiler); override;
		procedure ReadPaneControlsA(Reader: TReader);
		procedure ReadPaneControlsB(Reader: TReader);
		procedure WritePaneControlsA(Writer: TWriter);
		procedure WritePaneControlsB(Writer: TWriter);
		procedure ReadSaveSize(Reader: TReader);
		procedure WriteSaveSize(Writer: TWriter);
		procedure Loaded; override;
		procedure SetName(const Value: TComponentName); override;
		procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X: integer; Y: integer); override;
		procedure MouseMove(Shift: TShiftState; X: integer; Y: integer); override;
		procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X: integer; Y: integer); override;
		procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;
		procedure CMDesignHitTest(var Msg: TCMDesignHitTest); message CM_DESIGNHITTEST;
		procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
		procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
	public
		constructor Create(AOwner: TComponent); override;
		destructor Destroy; override;
		procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
		procedure Paint; override;
		procedure Resize; override;

		procedure SwapPanes;

		procedure MaximizeTopLeft;
		procedure MaximizeBottomRight;
		procedure MaximizeCenter;
		procedure MaximizeRestore;

	published
		property Align;
		property Anchors;
		property PopupMenu;
		property Padding;
		property DoubleBuffered;
		property ParentDoubleBuffered;

		property Animated              : boolean read FAnimated write FAnimated default True;
		property AnimationDuration     : cardinal read FAnimationDuration write FAnimationDuration default 250;
		property ButtonsSize           : TButtonsSize read FButtonsSize write SetButtonsSize default bsNormal;
		property MaximizeState         : TMaximizeState read FMaximizeState write SetMaximizeState default msRestore;
		property MaximizeButtons       : TMaximizeButtons read FMaximizeButtons write SetMaximizeButtons default mbxBoth;
		property MinSizeTopLeft        : integer read FMinSizeTopLeft write FMinSizeTopLeft default 20;
		property MinSizeBottomRight    : integer read FMinSizeBottomRight write FMinSizeBottomRight default 20;
		property Orientation           : TOrientation read FOrientation write SetOrientation default orHorizontal;
		property Proportional          : boolean read FProportional write SetProportional default True;
		property ResizeStyle           : TResizeStyle read FResizeStyle write SetResizeStyle default rsUpdate;
		property RestoreButton         : boolean read FRestoreButton write SetRestoreButton default True;
		property SplitterColor         : TColor read FSplitterColor write SetSplitterColor default clBtnFace;
		property SplitterPosition      : integer read FSplitterPosition write SetSplitterPosition;
		property SplitterSize          : byte read FSplitterSize write SetSplitterSize default 8;
		property ButtonNormalBorder    : TColor index 0 read FButtonNormalBorder write SetButtonColor default clHighlight;
		property ButtonNormalBackground: TColor index 1 read FButtonNormalBackground write SetButtonColor default clHighlightText;
		property ButtonHotBorder       : TColor index 2 read FButtonHotBorder write SetButtonColor default clHighlightText;
		property ButtonHotBackground   : TColor index 3 read FButtonHotBackground write SetButtonColor default clHighlight;
		property PaneA                 : TPane read GetPaneA;
		property PaneB                 : TPane read GetPaneB;
		property PaintPanes            : boolean read FPaintPanes write FPaintPanes default True;

		property OnClick;
		property OnDblClick;
		property OnContextPopup;
		property OnMouseDown;
		property OnMouseUp;
		property OnResize;

		property OnDrawButton   : TOnDrawButtonEvent read FOnDrawButtonEvent write FOnDrawButtonEvent;
		property OnMaximizePane : TOnMaximizePaneEvent read FOnMaximizePaneEvent write FOnMaximizePaneEvent;
		property OnSplitterMoved: TOnSplitterMovedEvent read FOnSplitterMovedEvent write FOnSplitterMovedEvent;
	end;

implementation

{ TSplitPanel.TAnimationThread }

constructor TSplitPanel.TAnimationThread.Create(A, B, Duration: integer; AnimationType: TAnimationType; Finish: TNotifyEvent; Control: TSplitPanel);
begin
	inherited Create(True);
	FStart           := A;
	FEnd             := B;
	FDuration        := Duration;
	FAnimationType   := AnimationType;
	Self.OnTerminate := Finish;
	FControl         := Control;
	FreeOnTerminate  := True;
	Self.Suspended   := False;
end;

procedure TSplitPanel.TAnimationThread.Execute;
var
	StartTime, EndTime: TDateTime;
	Percent           : integer;
	Delta, Chunk      : extended;
begin
	StartTime := Now;
	EndTime   := Now + (FDuration / (24 * 60 * 60 * 1000));

	Delta := (FEnd - FStart);
	Chunk := Delta / (Sqr(100));

	while (Now < EndTime) and not (Terminated) do
	begin
		Percent := Trunc((100 * (Now - StartTime)) / (EndTime - StartTime));
		if FAnimationType = atCollapse then
			FValue := FStart + Trunc(Chunk * Sqr(Percent))
		else
			FValue := FStart + Trunc(( - Chunk) * Sqr(Percent - 100) + Delta);
		Synchronize(SetSize);
	end;

	FValue := FEnd;
	Synchronize(SetSize);
end;

procedure TSplitPanel.TAnimationThread.SetSize;
begin
	TSplitPanel(FControl).SplitterPosition := FValue;
end;

{ TSplitPanel.TPane }

constructor TSplitPanel.TPane.Create(AOwner: TComponent);
begin
	inherited Create(AOwner);
	ControlStyle := ControlStyle + [csAcceptsControls, csOpaque];
end;

procedure TSplitPanel.TPane.DefineProperties(Filer: TFiler);
begin
	inherited;
	Filer.DefineProperty('PaneIndex', LoadIndex, SaveIndex, True);
end;

procedure TSplitPanel.TPane.LoadIndex(Reader: TReader);
begin
	PaneIndex := Reader.ReadInteger;
end;

procedure TSplitPanel.TPane.SaveIndex(Writer: TWriter);
begin
	Writer.WriteInteger(PaneIndex);
end;

procedure TSplitPanel.TPane.SetIndex(const Value: byte);
begin
	FIndex := Value;
end;

procedure TSplitPanel.TPane.Paint;
begin
	if (FSplitPanel.FPaintPanes) then
		Canvas.FillRect(GetClientRect);

	if FDesignActive and (csDesigning in ComponentState) then
	begin
		Canvas.Pen.Style := psDash;
		Canvas.Rectangle(GetClientRect);
	end;
end;

procedure TSplitPanel.TPane.CMDesignHitTest(var Msg: TCMDesignHitTest);
var
	State: TShiftState;
begin
	State := KeysToShiftState(Msg.Keys);
	if (ssLeft in State) then
	begin
		Msg.Result := 1;

		if Self = FSplitPanel.FPaneA then
		begin
			FSplitPanel.FPaneB.FDesignActive := False;
			FSplitPanel.FPaneB.BringToFront;
		end
		else
		begin
			FSplitPanel.FPaneA.FDesignActive := False;
			FSplitPanel.FPaneA.BringToFront;
		end;

		Self.FDesignActive := True;
		Invalidate;

		FDesignActive := True;
	end;
	inherited;
end;

procedure TSplitPanel.TPane.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
	Msg.Result := 1;
end;

{ TSplitPanel }

constructor TSplitPanel.Create(AOwner: TComponent);
begin
	inherited Create(AOwner);
	ControlStyle := ControlStyle + [csOpaque, csDoubleClicks];

	Height                  := 150;
	Width                   := 250;
	FOrientation            := orHorizontal;
	FProportional           := True;
	FResizeStyle            := rsUpdate;
	FSplitterColor          := clBtnFace;
	FSplitterPosition       := Height div 2;
	FSaveSize               := FSplitterPosition;
	FRatio                  := FSplitterPosition / Height;
	FSplitterSize           := 8;
	FMinSizeTopLeft         := 20;
	FMinSizeBottomRight     := 20;
	FButtonsSize            := bsNormal;
	FMaximizeState          := msRestore;
	FMaximizeButtons        := mbxBoth;
	FRestoreButton          := True;
	FMemBitmap              := TBitmap.Create;
	FAnimated               := True;
	FAnimationDuration      := 250;
	FButtonNormalBorder     := clHighlight;
	FButtonNormalBackground := clHighlightText;
	FButtonHotBorder        := clHighlightText;
	FButtonHotBackground    := clHighlight;
	FPaintPanes             := True;

	CreatePanes;
end;

destructor TSplitPanel.Destroy;
begin
	FPaneA.Free;
	FPaneB.Free;
	FPaneControlListA.Free;
	FPaneControlListB.Free;
	FMemBitmap.Free;
	inherited;
end;

procedure TSplitPanel.AllocatePatternDC;
begin
	FPatternDC := GetDCEx(Parent.Handle, 0, DCX_CACHE or DCX_CLIPSIBLINGS or DCX_LOCKWINDOWUPDATE);
	if FResizeStyle = rsPattern then
	begin
		if FPatternBrush = nil then
		begin
			FPatternBrush        := TBrush.Create;
			FPatternBrush.Bitmap := AllocPatternBitmap(clBlack, clWhite);
		end;
		//FPrevBrush := SelectObject(FLineDC, FPatternBrush.Handle);
	end;
end;

procedure TSplitPanel.Animate;
begin
	//	if (FAnimationThread <> nil) then
	//		FAnimationThread.Free;

	case FOrientation of
		orHorizontal:
		case FMaximizeState of
			msTopLeft:
			FAnimationThread := TAnimationThread.Create(FSplitterPosition, 0, FAnimationDuration, atCollapse, AnimationFinished, Self);
			msBottomRight:
			FAnimationThread := TAnimationThread.Create(FSplitterPosition, Height, FAnimationDuration, atCollapse, AnimationFinished, Self);
			msCenter:
			FAnimationThread := TAnimationThread.Create(FSplitterPosition, ClientHeight div 2, FAnimationDuration, atExpand, AnimationFinished, Self);
			msRestore:
			FAnimationThread := TAnimationThread.Create(FSplitterPosition, FSaveSize, FAnimationDuration, atExpand, AnimationFinished, Self);
		end;
		orVertical:
		case FMaximizeState of
			msTopLeft:
			FAnimationThread := TAnimationThread.Create(FSplitterPosition, 0, FAnimationDuration, atCollapse, AnimationFinished, Self);
			msBottomRight:
			FAnimationThread := TAnimationThread.Create(FSplitterPosition, Width, FAnimationDuration, atCollapse, AnimationFinished, Self);
			msCenter:
			FAnimationThread := TAnimationThread.Create(FSplitterPosition, ClientWidth div 2, FAnimationDuration, atExpand, AnimationFinished, Self);
			msRestore:
			FAnimationThread := TAnimationThread.Create(FSplitterPosition, FSaveSize, FAnimationDuration, atExpand, AnimationFinished, Self);
		end;
	end;
	if Assigned(FOnMaximizePaneEvent) then
		FOnMaximizePaneEvent(Self, FMaximizeState);
end;

procedure TSplitPanel.AnimationFinished(Sender: TObject);
begin
	FAnimationThread := nil;

	if (FMaximizeState = msRestore) then
		FSaveSize := FSplitterPosition;
end;

procedure TSplitPanel.CheckMaxMin;
begin
	if FOrientation = orHorizontal then
	begin
		if FSplitterPosition < FMinSizeTopLeft then
			FSplitterPosition := FMinSizeTopLeft;
		if FSplitterPosition > Height - FMinSizeBottomRight then
			FSplitterPosition := Height - FMinSizeBottomRight;
	end
	else
	begin
		if FSplitterPosition < FMinSizeTopLeft then
			FSplitterPosition := FMinSizeTopLeft;
		if FSplitterPosition > Width - FMinSizeBottomRight then
			FSplitterPosition := Width - FMinSizeBottomRight;
	end;
end;

procedure TSplitPanel.CreatePanes;
begin
	FPaneA               := TPane.Create(Self);
	FPaneA.Parent        := Self;
	FPaneA.Name          := Self.Name + 'PaneA';
	FPaneA.PaneIndex     := 0;
	FPaneA.FSplitPanel   := Self;
	FPaneA.FDesignActive := True;

	FPaneB               := TPane.Create(Self);
	FPaneB.Parent        := Self;
	FPaneB.Name          := Self.Name + 'PaneB';
	FPaneB.PaneIndex     := 0;
	FPaneB.FSplitPanel   := Self;
	FPaneB.FDesignActive := False;

	FPaneControlListA := TStringList.Create;
	FPaneControlListB := TStringList.Create;
end;

procedure TSplitPanel.SplitButtonClick(AButton: TSplitterButton);
begin
	case AButton of
		sbTopLeft:
		begin
			FTopLeftClick  := False;
			FMaximizeState := msTopLeft;
			if FAnimated then
				Animate
			else
				MaximizePane;
		end;

		sbBottomRight:
		begin
			FBottomRightClick := False;
			FMaximizeState    := msBottomRight;
			if FAnimated then
				Animate
			else
				MaximizePane;
		end;

		sbCenter:
		begin
			FTopLeftClick  := False;
			FMaximizeState := msCenter;
			if FAnimated then
				Animate
			else
			begin
				SetSplitterPosition(ClientWidth div 2);
				Invalidate;
				if Assigned(FOnMaximizePaneEvent) then
					FOnMaximizePaneEvent(Self, FMaximizeState);
				FMaximizeState := msCenter;
			end;
		end;

		sbRestore:
		begin
			FRestoreClick  := False;
			FMaximizeState := msRestore;
			if FAnimated then
				Animate
			else
			begin
				SetSplitterPosition(FSaveSize);
				Invalidate;
				if Assigned(FOnMaximizePaneEvent) then
					FOnMaximizePaneEvent(Self, FMaximizeState);
				FMaximizeState := msRestore;
			end;
		end;
	end;
end;

procedure TSplitPanel.DefineProperties(Filer: TFiler);
begin
	// Define two string lists which will hold the controls contained in the panes. This will be used to search
	// for those contols when Self is created, and set their parent to the respective panes.
	Filer.DefineProperty('PaneControlListA', ReadPaneControlsA, WritePaneControlsA, True);
	Filer.DefineProperty('PaneControlListB', ReadPaneControlsB, WritePaneControlsB, True);
	Filer.DefineProperty('SaveSize', ReadSaveSize, WriteSaveSize, FSaveSize <> 0);
end;

procedure TSplitPanel.DrawBackground;
begin
	//
end;

procedure TSplitPanel.DrawPattern;
begin
	FLineVisible := not FLineVisible;
	case FOrientation of
		orHorizontal:
		PatBlt(FPatternDC, Left, FPatternPosition - (FSplitterSize div 2), Width, FSplitterSize, PATINVERT);
		orVertical:
		PatBlt(FPatternDC, FPatternPosition - (FSplitterSize div 2), Top, FSplitterSize, Height, PATINVERT);
	end;
end;

procedure TSplitPanel.DrawSplitter(HighlightedTopLeft, HighlightedBottomRight, HighlightedRestore: boolean);

	procedure AdjustColors(Highlighted: boolean);
	begin
		with Canvas do
			if Highlighted then
			begin
				Pen.Color   := FButtonHotBorder;
				Brush.Color := FButtonHotBackground;
			end
			else
			begin
				Pen.Color   := FButtonNormalBorder;
				Brush.Color := FButtonNormalBackground;
			end;
	end;

	procedure DrawButtonGlyph(var ARect: TRect; AGlyph: TButtonGlyph);
	var
		n: integer;
	begin
		InflateRect(ARect, - 1, - 1);
		Canvas.Brush.Color := FMemBitmap.Canvas.Pen.Color;

		with ARect do
		begin
			case FOrientation of
				orHorizontal:
				begin
					n           := ARect.Bottom - ARect.Top;
					ARect.Left  := ARect.Left + ((ARect.Right - ARect.Left) div 2) - n;
					ARect.Right := ARect.Left + n * 2;
					if AGlyph = bgRestore then
						InflateRect(ARect, - 1, 0);
				end;
				orVertical:
				begin
					n      := ARect.Right - ARect.Left;
					Top    := ARect.Top + ((ARect.Bottom - ARect.Top) div 2) - n;
					Bottom := ARect.Top + n * 2;
					if AGlyph = bgRestore then
						InflateRect(ARect, 0, - 1);
				end;
			end;

			case AGlyph of
				bgLeft:
				Canvas.Polygon([Point(Right, Top), Point(Right, Bottom), Point(Left, Top + ((Bottom - Top) div 2)), Point(Right, Top)]);
				bgUp:
				Canvas.Polygon([Point(Left, Bottom), Point(Right + 1, Bottom + 1), Point(Left + ((Right - Left) div 2), Top), Point(Left, Bottom)]);
				bgRight:
				Canvas.Polygon([Point(Left - 1, Top), Point(Left - 1, Bottom), Point(Right - 1, Top + ((Bottom - Top) div 2)), Point(Left - 1, Top)]);
				bgDown:
				Canvas.Polygon([Point(Left, Top - 1), Point(Right, Top - 1), Point(Left + ((Right - Left) div 2), Bottom - 1), Point(Left, Top - 1)]);
				bgRestore:
				Canvas.FillRect(ARect);
			end;
		end;
	end;

var
	R: TRect;
begin
	if (FResizeStyle = rsCannotResize) or (FMaximizeButtons = mbxNone) then
	begin
		Canvas.Brush.Color := FSplitterColor;
		Canvas.FillRect(GetSplitterRect);
	end
	else
	begin
		with Canvas do
		begin
			Brush.Color := FSplitterColor;
			FillRect(GetSplitterRect);

			case FOrientation of
				orHorizontal:
				begin
					R := GetButtonRect(sbTopLeft);
					if Assigned(FOnDrawButtonEvent) then
						FOnDrawButtonEvent(Self, Canvas, R, bgUp, HighlightedTopLeft)
					else
					begin
						AdjustColors(HighlightedTopLeft);
						Roundrect(R.Left, R.Top, R.Right, R.Bottom, 2, 2);
						DrawButtonGlyph(R, bgUp);
					end;

					R := GetButtonRect(sbBottomRight);
					if Assigned(FOnDrawButtonEvent) then
						FOnDrawButtonEvent(Self, Canvas, R, bgDown, HighlightedBottomRight)
					else
					begin
						AdjustColors(HighlightedBottomRight);
						Roundrect(R.Left, R.Top, R.Right, R.Bottom, 2, 2);
						DrawButtonGlyph(R, bgDown);
					end;

					if FRestoreButton then
					begin
						R := GetButtonRect(sbRestore);
						if Assigned(FOnDrawButtonEvent) then
							FOnDrawButtonEvent(Self, Canvas, R, bgDown, HighlightedRestore)
						else
						begin
							AdjustColors(HighlightedRestore);
							Roundrect(R.Left, R.Top, R.Right, R.Bottom, 2, 2);
							DrawButtonGlyph(R, bgRestore);
						end;
					end;

				end;
				orVertical:
				begin
					R := GetButtonRect(sbTopLeft);
					if Assigned(FOnDrawButtonEvent) then
						FOnDrawButtonEvent(Self, Canvas, R, bgLeft, HighlightedTopLeft)
					else
					begin
						AdjustColors(HighlightedTopLeft);
						Roundrect(R.Left, R.Top, R.Right, R.Bottom, 2, 2);
						DrawButtonGlyph(R, bgLeft);
					end;

					R := GetButtonRect(sbBottomRight);
					if Assigned(FOnDrawButtonEvent) then
						FOnDrawButtonEvent(Self, Canvas, R, bgRight, HighlightedBottomRight)
					else
					begin
						AdjustColors(HighlightedBottomRight);
						Roundrect(R.Left, R.Top, R.Right, R.Bottom, 2, 2);
						DrawButtonGlyph(R, bgRight);
					end;

					if FRestoreButton then
					begin
						R := GetButtonRect(sbRestore);
						if Assigned(FOnDrawButtonEvent) then
							FOnDrawButtonEvent(Self, Canvas, R, bgRight, HighlightedRestore)
						else
						begin
							AdjustColors(HighlightedRestore);
							Roundrect(R.Left, R.Top, R.Right, R.Bottom, 2, 2);
							DrawButtonGlyph(R, bgRestore);
						end;
					end;

				end;
			end;
		end;
	end;

//	case FOrientation of
//		orHorizontal:
//		Canvas.Draw(0, FSplitterPosition - (FSplitterSize div 2), FMemBitmap);
//		orVertical:
//		Canvas.Draw(FSplitterPosition - (FSplitterSize div 2), 0, FMemBitmap);
//	end;
end;

function TSplitPanel.GetButtonRect(Button: TSplitterButton): TRect;
var
	Size  : integer;
	Center: integer;
begin
	Center := IfThen(FOrientation = orHorizontal, Width, Height) div 2;
	Size   := 0;

	case FButtonsSize of
		bsSmall:
		if FOrientation = orHorizontal then
			Size := Width div 24
		else
			Size := Height div 24;
		bsNormal:
		if FOrientation = orHorizontal then
			Size := Width div 16
		else
			Size := Height div 16;
		bsLarge:
		if FOrientation = orHorizontal then
			Size := Width div 8
		else
			Size := Height div 8;
	end;

	Result := GetSplitterRect;

	case FOrientation of
		orHorizontal:
		if Button = sbTopLeft then
		begin
			Result.Right := Center - (Size div 2);
			Result.Left  := Result.Right - Size;
		end
		else
		  if Button = sbBottomRight then
		begin
			Result.Left  := Center + (Size div 2);
			Result.Right := Result.Left + Size;
		end
		else
		  if Button = sbRestore then
		begin
			Result.Left  := Center - (Size div 3);
			Result.Right := Center + (Size div 3);
		end;
		orVertical:
		if Button = sbTopLeft then
		begin
			Result.Bottom := Center - (Size div 2);
			Result.Top    := Result.Bottom - Size;
		end
		else
		  if Button = sbBottomRight then
		begin
			Result.Top    := Center + (Size div 2);
			Result.Bottom := Result.Top + Size;
		end
		else
		  if Button = sbRestore then
		begin
			Result.Top    := Center - (Size div 3);
			Result.Bottom := Center + (Size div 3);
		end;
	end;
end;

procedure TSplitPanel.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
	i: integer;
begin
	inherited GetChildren(Proc, Root);

	for i := 0 to FPaneA.ControlCount - 1 do
		if FPaneA.Controls[i].Owner = GetParentForm(Self) then
			Proc(FPaneA.Controls[i]);

	for i := 0 to FPaneB.ControlCount - 1 do
		if FPaneB.Controls[i].Owner = GetParentForm(Self) then
			Proc(FPaneB.Controls[i]);
end;

function TSplitPanel.GetPaneA: TPane;
begin
	Result := FPaneA;
end;

function TSplitPanel.GetPaneB: TPane;
begin
	Result := FPaneB;
end;

function TSplitPanel.GetSplitterRect: TRect;
begin
	case FOrientation of
		orHorizontal:
		Result :=
		  Rect(0, FSplitterPosition - (FSplitterSize div 2), Width, FSplitterPosition + (FSplitterSize div 2));
		orVertical:
		Result :=
		  Rect(FSplitterPosition - (FSplitterSize div 2), 0, FSplitterPosition + (FSplitterSize div 2), Height);
	end;
end;

procedure TSplitPanel.Loaded;
var
	i: integer;
	C: TComponent;
begin
	inherited Loaded;

	// Iterate over the list of controls for the respective panes and set them to their original parents.
	for i := 0 to FPaneControlListA.Count - 1 do
	begin
		C := GetParentForm(Self).FindComponent(FPaneControlListA[i]);
		if C <> nil then
			TControl(C).Parent := FPaneA;
	end;

	for i := 0 to FPaneControlListB.Count - 1 do
	begin
		C := GetParentForm(Self).FindComponent(FPaneControlListB[i]);
		if C <> nil then
			TControl(C).Parent := FPaneB;
	end;

	ResetRatio;
	Invalidate;
end;

procedure TSplitPanel.MaximizePane;
begin
	case FOrientation of
		orHorizontal:
		if FMaximizeState = msTopLeft then
			SetSplitterPosition(0)
		else
			SetSplitterPosition(Height);
		orVertical:
		if FMaximizeState = msTopLeft then
			SetSplitterPosition(0)
		else
			SetSplitterPosition(Width);
	end;
	if Assigned(FOnMaximizePaneEvent) then
		FOnMaximizePaneEvent(Self, FMaximizeState);
end;

procedure TSplitPanel.MaximizeTopLeft;
begin
	SplitButtonClick(sbTopLeft);
end;

procedure TSplitPanel.MaximizeBottomRight;
begin
	SplitButtonClick(sbBottomRight);
end;

procedure TSplitPanel.MaximizeCenter;
begin
	SplitButtonClick(sbCenter);
end;

procedure TSplitPanel.MaximizeRestore;
begin
	SplitButtonClick(sbRestore);
end;

procedure TSplitPanel.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
	inherited;

	if (FResizeStyle = rsCannotResize) then
		Exit;

	// Begin drag
	if PtInRect(GetSplitterRect, Point(X, Y)) and not PtInRect(GetButtonRect(sbTopLeft), Point(X, Y)) and not PtInRect(GetButtonRect(sbBottomRight), Point(X, Y)) and
	  not PtInRect(GetButtonRect(sbRestore), Point(X, Y)) and (FResizeStyle <> rsCannotResize) and (Button = mbLeft) then
		FDragging := True;

	if FResizeStyle <> rsCannotResize then
	begin
		// TopLeft click
		if PtInRect(GetButtonRect(sbTopLeft), Point(X, Y)) then
			FTopLeftClick := True;

		// BottomRight click
		if PtInRect(GetButtonRect(sbBottomRight), Point(X, Y)) then
			FBottomRightClick := True;

		// Restore click
		if PtInRect(GetButtonRect(sbRestore), Point(X, Y)) then
			FRestoreClick := True;
	end;

	if FDragging and (FResizeStyle = rsPattern) then
	begin
		AllocatePatternDC;
		FPatternPosition := FSplitterPosition;
		DrawPattern;
	end;
end;

procedure TSplitPanel.MouseMove(Shift: TShiftState; X, Y: integer);
begin
	inherited;

	if (FResizeStyle = rsCannotResize) then
		Exit;

	// Do drag
	if FDragging then
	begin
		if FOrientation = orHorizontal then
			FSplitterPosition := Y
		else
			FSplitterPosition := X;

		CheckMaxMin;

		FMaximizeState := msRestore;
		FSaveSize      := FSplitterPosition;

		if (FResizeStyle = rsUpdate) then
			Repaint
		else
		begin
			DrawPattern;
			FPatternPosition := FSplitterPosition;
			DrawPattern;
		end;

		if Assigned(FOnSplitterMovedEvent) then
			FOnSplitterMovedEvent(Self, FSplitterPosition);
	end
	else
	begin
		// Set cursor
		if PtInRect(GetSplitterRect, Point(X, Y)) and not PtInRect(GetButtonRect(sbTopLeft), Point(X, Y)) and not PtInRect(GetButtonRect(sbBottomRight), Point(X, Y)) and
		  not PtInRect(GetButtonRect(sbRestore), Point(X, Y)) and (FResizeStyle <> rsCannotResize) then
			case FOrientation of
				orHorizontal:
				Self.Cursor := crVSplit;
				orVertical:
				Self.Cursor := crHSplit;
			end
		else
			Self.Cursor := crDefault;

		// Button highlight
		if (FResizeStyle <> rsCannotResize) then
		begin
			// Button TopLeft highlight
			if PtInRect(GetButtonRect(sbTopLeft), Point(X, Y)) then
			begin
				if not FTopLeftHighlight then
				begin
					DrawSplitter(True, False, False);
					FTopLeftHighlight := True;
				end;
			end
			else
			  if FTopLeftHighlight then
			begin
				DrawSplitter(False, False, False);
				FTopLeftHighlight := False;
			end;

			// Button sbBottomRight highlight
			if PtInRect(GetButtonRect(sbBottomRight), Point(X, Y)) then
			begin
				if not FBottomRightHighlight then
				begin
					DrawSplitter(False, True, False);
					FBottomRightHighlight := True;
				end;
			end
			else
			  if FBottomRightHighlight then
			begin
				DrawSplitter(False, False, False);
				FBottomRightHighlight := False;
			end;

			// Button Restore highlight
			if PtInRect(GetButtonRect(sbRestore), Point(X, Y)) then
			begin
				if not FRestoreHighlight then
				begin
					DrawSplitter(False, False, True);
					FRestoreHighlight := True;
				end;
			end
			else
			  if FRestoreHighlight then
			begin
				DrawSplitter(False, False, False);
				FRestoreHighlight := False;
			end;
		end;
	end;
end;

procedure TSplitPanel.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
	inherited;

	if (FResizeStyle = rsCannotResize) then
		Exit;

	// End drag
	if FDragging then
	begin
		if FResizeStyle = rsPattern then
		begin
			DrawPattern;
			if FLineVisible then
				DrawPattern;
			ReleasePatternDC;
		end;
		ResetRatio;
		FDragging := False;
		Invalidate;
	end;

	if (FResizeStyle <> rsCannotResize) and (Button = mbLeft) then
	begin
		if PtInRect(GetButtonRect(sbTopLeft), Point(X, Y)) and FTopLeftClick then
			SplitButtonClick(sbTopLeft);

		if PtInRect(GetButtonRect(sbBottomRight), Point(X, Y)) and FBottomRightClick then
			SplitButtonClick(sbBottomRight);

		if PtInRect(GetButtonRect(sbRestore), Point(X, Y)) and FRestoreClick then
			SplitButtonClick(sbRestore);
	end;

end;

procedure TSplitPanel.Paint;
begin
	ResizePanes;
	DrawBackground;
	FPaneA.Invalidate;
	FPaneB.Invalidate;
	DrawSplitter(False, False, False);
end;

procedure TSplitPanel.Resize;
begin
	if (FPaneA <> nil) and (FPaneB <> nil) then
	begin
		if not (FMaximizeState in [msRestore, msCenter]) then
			MaximizePane
		else
		begin
			if (FProportional) then
				UpdateSplitterPosition;
			FSaveSize := FSplitterPosition;
		end;
		CheckMaxMin;
	end;
	inherited;
end;

procedure TSplitPanel.ResizePanes;
begin
	case FOrientation of
		orHorizontal:
		begin
			FPaneA.BoundsRect := Rect(0, 0, Width, FSplitterPosition - (FSplitterSize div 2));
			FPaneB.BoundsRect := Rect(0, FSplitterPosition + (FSplitterSize div 2), Width, Height);
		end;
		orVertical:
		begin
			FPaneA.BoundsRect := Rect(0, 0, FSplitterPosition - (FSplitterSize div 2), Height);
			FPaneB.BoundsRect := Rect(FSplitterPosition + (FSplitterSize div 2), 0, Width, Height);
		end;
	end;
end;

procedure TSplitPanel.ResetRatio;
begin
	case FOrientation of
		orHorizontal:
		FRatio := IfThen(Height = 0, 0.5, FSplitterPosition / Height);
		orVertical:
		FRatio := IfThen(Width = 0, 0.5, FSplitterPosition / Width);
	end;
end;

procedure TSplitPanel.ReadPaneControlsA(Reader: TReader);
begin
	FPaneControlListA.Clear;
	Reader.ReadListBegin;
	while not Reader.EndOfList do
		FPaneControlListA.Add(Reader.ReadIdent);
	Reader.ReadListEnd;
end;

procedure TSplitPanel.ReadPaneControlsB(Reader: TReader);
begin
	FPaneControlListB.Clear;
	Reader.ReadListBegin;
	while not Reader.EndOfList do
		FPaneControlListB.Add(Reader.ReadIdent);
	Reader.ReadListEnd;
end;

procedure TSplitPanel.ReadSaveSize(Reader: TReader);
begin
	FSaveSize := Reader.ReadInteger;
end;

procedure TSplitPanel.ReleasePatternDC;
begin
	ReleaseDC(Parent.Handle, FPatternDC);
	if FPatternBrush <> nil then
	begin
		FPatternBrush.Free;
		FPatternBrush := nil;
	end;
end;

procedure TSplitPanel.SwapPanes;
var
	Pane: TPane;
begin
	Pane   := FPaneA;
	FPaneA := FPaneB;
	FPaneB := Pane;
	Invalidate;
	// TODO: Invalidate won't update. Do something better.
end;

procedure TSplitPanel.SetButtonColor(const Index: integer; const Value: TColor);
begin
	case index of
		0:
		begin
			if FButtonNormalBorder = Value then
				Exit;
			FButtonNormalBorder := Value;
		end;

		1:
		begin
			if FButtonNormalBackground = Value then
				Exit;
			FButtonNormalBackground := Value;
		end;

		2:
		begin
			if FButtonHotBorder = Value then
				Exit;
			FButtonHotBorder := Value;
		end;

		3:
		begin
			if FButtonHotBackground = Value then
				Exit;
			FButtonHotBackground := Value;
		end;
	end;
	Invalidate;
end;

procedure TSplitPanel.SetButtonsSize(const Value: TButtonsSize);
begin
	if FButtonsSize = Value then
		Exit;
	FButtonsSize := Value;
	Invalidate;
end;

procedure TSplitPanel.SetMaximizeButtons(const Value: TMaximizeButtons);
begin
	if (FMaximizeButtons = Value) then
		Exit;
	FMaximizeButtons := Value;
	Invalidate;
end;

procedure TSplitPanel.SetMaximizeState(const Value: TMaximizeState);
begin
	if (FMaximizeState = Value) then
		Exit;
	FMaximizeState := Value;
	case FMaximizeState of
		msTopLeft:
		SplitButtonClick(sbTopLeft);
		msBottomRight:
		SplitButtonClick(sbBottomRight);
		msCenter:
		SplitButtonClick(sbCenter);
		msRestore:
		SplitButtonClick(sbRestore);
	end;

	//	if FMaximizeState <> msNone then
	//		MaximizePane
	//	else
	//	  if FOrientation = orHorizontal then
	//		SetSplitterPosition(Height div 2)
	//	else
	//		SetSplitterPosition(Width div 2);
end;

procedure TSplitPanel.SetName(const Value: TComponentName);
var
	S: string;
begin
	inherited;
	if not (csLoading in Self.Owner.ComponentState) then
	begin
		S           := FPaneA.Name;
		FPaneA.Name := Self.Name + S;

		S           := FPaneB.Name;
		FPaneB.Name := Self.Name + S;
	end;
end;

procedure TSplitPanel.SetOrientation(const Value: TOrientation);
begin
	if FOrientation = Value then
		Exit;
	FOrientation := Value;
	if FProportional then
		UpdateSplitterPosition;
	Invalidate;
end;

procedure TSplitPanel.SetProportional(const Value: boolean);
begin
	if FProportional = Value then
		Exit;
	FProportional := Value;
	ResetRatio;
end;

procedure TSplitPanel.SetResizeStyle(const Value: TResizeStyle);
begin
	if (FResizeStyle = Value) then
		Exit;
	FResizeStyle := Value;
	Invalidate;
end;

procedure TSplitPanel.SetRestoreButton(const Value: boolean);
begin
	if FRestoreButton = Value then
		Exit;
	FRestoreButton := Value;
	Invalidate;
end;

procedure TSplitPanel.SetSplitterColor(const Value: TColor);
begin
	if FSplitterColor = Value then
		Exit;
	FSplitterColor := Value;
	Invalidate;
end;

procedure TSplitPanel.SetSplitterPosition(const Value: integer);
begin
	if FSplitterPosition = Value then
		Exit;
	FSplitterPosition := Value;
	if not (csLoading in ComponentState) then
	begin
		CheckMaxMin;
		Invalidate;
		ResetRatio;
	end;
end;

procedure TSplitPanel.SetSplitterSize(const Value: byte);
begin
	if FSplitterSize = Value then
		Exit;
	FSplitterSize := Value;
	if not (csLoading in ComponentState) then
	begin
		Invalidate;
	end;
end;

procedure TSplitPanel.UpdateSplitterPosition;
begin
	case FOrientation of
		orHorizontal:
		if Height = 0 then
			Exit
		else
			FSplitterPosition := Round(Height * FRatio);
		orVertical:
		if Width = 0 then
			Exit
		else
			FSplitterPosition := Round(Width * FRatio);
	end;
end;

procedure TSplitPanel.WritePaneControlsA(Writer: TWriter);
var
	i: integer;
begin
	Writer.WriteListBegin;
	for i := 0 to FPaneA.ControlCount - 1 do
		Writer.WriteIdent(FPaneA.Controls[i].Name);
	Writer.WriteListEnd;
end;

procedure TSplitPanel.WritePaneControlsB(Writer: TWriter);
var
	i: integer;
begin
	Writer.WriteListBegin;
	for i := 0 to FPaneB.ControlCount - 1 do
		Writer.WriteIdent(FPaneB.Controls[i].Name);
	Writer.WriteListEnd;
end;

procedure TSplitPanel.WriteSaveSize(Writer: TWriter);
begin
	Writer.WriteInteger(FSaveSize);
end;

procedure TSplitPanel.CMColorChanged(var Message: TMessage);
begin
	Self.Canvas.Brush.Color  := Self.Color;
	PaneA.Canvas.Brush.Color := Self.Color;
	PaneB.Canvas.Brush.Color := Self.Color;
end;

procedure TSplitPanel.CMDesignHitTest(var Msg: TCMDesignHitTest);
var
	State: TShiftState;
begin
	// Allow splitter moving at design time with Ctrl-LeftClick
	State := KeysToShiftState(Msg.Keys);
	if (ssCtrl in State) and (ssLeft in State) then
		Msg.Result := 1
	else
		Msg.Result := 0;
end;

procedure TSplitPanel.CMMouseLeave(var Msg: TMessage);
begin
	if FTopLeftHighlight then
	begin
		DrawSplitter(False, False, False);
		FTopLeftHighlight := False;
	end;

	if FBottomRightHighlight then
	begin
		DrawSplitter(False, False, False);
		FBottomRightHighlight := False;
	end;

	if FRestoreHighlight then
	begin
		DrawSplitter(False, False, False);
		FRestoreHighlight := False;
	end;
end;

procedure TSplitPanel.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
	MSG.Result := 1;
end;

//initialization
//  RegisterClass(TvvPane);

end.
