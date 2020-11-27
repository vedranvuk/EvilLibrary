//
// EvilLibrary by Vedran Vuk 2010-2012
//
// Name: 					EvilWorks.VCL.GenericControl
// Description: 			Generic control exposing canvas and OnPaint event.
// File last change date:   September 2nd. 2012
// File version: 			0.0.9
// Licence:                 Free.
//

{ TODO: Fix Ctrl3D and border props. }

unit EvilWorks.VCL.GenericControl;

interface

uses
	WinApi.Windows,
	WinApi.Messages,
	System.Classes,
	System.SysUtils,
	Vcl.Controls,
	Vcl.Graphics;

type
	{ Forward declarations }
	TGenericControl = class;

	{ TMouseState }
	TMouseState = (msOut, msOver, msDown);

	{ Events }
	TOnPaint = procedure(aSender: TGenericControl; const aCanvas: TCanvas; const aRect: TRect; const aMouseState: TMouseState) of object;

	{ TGenericControl }
	TGenericControl = class(TCustomControl)
	private
		FInvalidating      : boolean;
		FTransparent       : boolean;
		FMouseTriggersPaint: boolean;
		FOnPaint           : TOnPaint;
		procedure SetTransparent(const Value: boolean);
	protected
		FMouseState: TMouseState;

		procedure Paint; override;

		procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
		procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;

		procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
		procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
		procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
		procedure CMColorchanged(var Message: TMessage); message CM_COLORCHANGED;
		procedure CMFontchanged(var Message: TMessage); message CM_FONTCHANGED;
	public
		constructor Create(aOwner: TComponent); override;
		procedure Assign(aSource: TPersistent); override;
		procedure Invalidate; override;

		property Canvas;
	published
		property Align;
		property Anchors;
		property AutoSize;
		property BevelEdges;
		property BevelInner;
		property BevelKind;
		property BevelOuter;
		property BevelWidth;
		property BiDiMode;
		property BorderWidth;
		property Color;
		property Constraints;
		property Ctl3D;
		property DockSite;
		property DoubleBuffered;
		property DragCursor;
		property DragKind;
		property DragMode;
		property Enabled;
		property Font;
		property Padding;
		property ParentBackground;
		property ParentBiDiMode;
		property ParentColor;
		property ParentCtl3D;
		property ParentDoubleBuffered;
		property ParentFont;
		property ParentShowHint;
		property PopupMenu;
		property ShowHint;
		property TabOrder;
		property TabStop;
		property Touch;
		property UseDockManager default True;
		property Visible;

		property MouseTriggersPaint: boolean read FMouseTriggersPaint write FMouseTriggersPaint default True;
		property Transparent       : boolean read FTransparent write SetTransparent default False;

		property OnAlignInsertBefore;
		property OnAlignPosition;
		property OnCanResize;
		property OnClick;
		property OnConstrainedResize;
		property OnContextPopup;
		property OnDockDrop;
		property OnDockOver;
		property OnDblClick;
		property OnDragDrop;
		property OnDragOver;
		property OnEndDock;
		property OnEndDrag;
		property OnEnter;
		property OnExit;
		property OnGesture;
		property OnGetSiteInfo;
		property OnMouseActivate;
		property OnMouseDown;
		property OnMouseEnter;
		property OnMouseLeave;
		property OnMouseMove;
		property OnMouseUp;
		property OnResize;
		property OnStartDock;
		property OnStartDrag;
		property OnUnDock;

		property OnPaint: TOnPaint read FOnPaint write FOnPaint;
	end;

implementation

{ TGenericControl }

constructor TGenericControl.Create(aOwner: TComponent);
begin
	inherited;
	FMouseTriggersPaint := True;
	FMouseState         := msOut;
	ControlStyle        := ControlStyle + [csAcceptsControls];
end;

procedure TGenericControl.Assign(aSource: TPersistent);
begin
	inherited;

	if (aSource is TGenericControl) then
	begin
		MouseTriggersPaint := TGenericControl(aSource).MouseTriggersPaint;
		Transparent        := TGenericControl(aSource).Transparent;

		OnPaint := TGenericControl(aSource).OnPaint;
	end;
end;

procedure TGenericControl.Paint;
begin
	if (csDesigning in ComponentState) then
	begin
		Canvas.FillRect(ClientRect);
		Exit;
	end;

	if (Assigned(FOnPaint)) then
	begin
		FOnPaint(Self, Canvas, ClientRect, FMouseState);
		Exit;
	end;
end;

procedure TGenericControl.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
	inherited;
	FMouseState := msDown;
	if (FMouseTriggersPaint) then
		Invalidate;
end;

procedure TGenericControl.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
	inherited;
	FMouseState := msOver;
	if (FMouseTriggersPaint) then
		Invalidate;
end;

procedure TGenericControl.Invalidate;
var
	i: integer;
	b: boolean;
begin
	if (FInvalidating = False) then
	begin
		FInvalidating := True;
		Parent.Invalidate;
		for i := 0 to Self.ControlCount - 1 do
			Self.Controls[i].Invalidate;
        FInvalidating := False;
	end;
	inherited Invalidate;
end;

procedure TGenericControl.SetTransparent(const Value: boolean);
begin
	if (FTransparent = Value) then
		Exit;
	FTransparent := Value;

	if (FTransparent) then
	begin
		SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_TRANSPARENT);
		SetBkMode(Canvas.Handle, WinApi.Windows.Transparent);
		ControlStyle := ControlStyle - [csOpaque];
	end
	else
	begin
		SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) and not WS_EX_TRANSPARENT);
		SetBkMode(Canvas.Handle, WinApi.Windows.OPAQUE);
		ControlStyle := ControlStyle + [csOpaque];
	end;
	Invalidate;
end;

procedure TGenericControl.CMColorchanged(var Message: TMessage);
begin
	Canvas.Brush.Color := Color;
	Invalidate;
end;

procedure TGenericControl.CMFontchanged(var Message: TMessage);
begin
	Canvas.Font.Assign(Font);
end;

procedure TGenericControl.CMMouseEnter(var Message: TMessage);
begin
	inherited;
	FMouseState := msOver;
	if (FMouseTriggersPaint) then
		Invalidate;
end;

procedure TGenericControl.CMMouseLeave(var Message: TMessage);
begin
	inherited;
	FMouseState := msOut;
	if (FMouseTriggersPaint) then
		Invalidate;
end;

procedure TGenericControl.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
	if (FTransparent) then
	begin
		SetBkMode(message.DC, WinApi.Windows.TRANSPARENT);
		message.Result := 0;
	end
	else
		inherited;
end;

end.
