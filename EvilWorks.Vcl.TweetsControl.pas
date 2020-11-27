//
// EvilLibrary by Vedran Vuk 2010-2012
//
// Name: 					EvilWorks.Vcl.TweetsControl
// Description: 			A control that displays Twitter data.
// File last change date:   December 16th. 2012
// File version: 			Dev 0.0.0
// Licence:                 Free.
//

unit EvilWorks.Vcl.TweetsControl;

interface

uses
	Winapi.Windows,
	WinApi.Messages,
	System.SysUtils,
	System.Classes,
	Vcl.Graphics,
	Vcl.Controls,
	Vcl.StdCtrls,
	Vcl.ExtCtrls,
	EvilWorks.Generics.List;

type
	{ Forward declarations }
	TTweetItem     = class;
	TTweetItems    = class;
	TTweetsControl = class;

    { TTweetItemType }
	TTweetItemType = (
	  titTweet,
	  titRetweets,
	  titFavorites,
	  titFollows
	  );

	TTweetItemState = (
	  tisNormal,
	  tisOver,
	  tisDown
	  );

    { TTweetItemAction }
	TTweetItemAction = (
	  tiaMouseEnter,
	  tiaMouseLeave,
	  tiaMouseMove,
	  tiaMouseDown,
	  tiaMouseUp,
	  tiaMouseClick
	  );

    { TTweetItemData }
	TTweetItemData = class(TPersistent)
	private
		FTweetItem: TTweetItem;
		FDate : TDateTime;
		procedure SetDate(const Value: TDateTime);
	public
		constructor Create(aTweetItem: TTweetItem); virtual;
		procedure Assign(aSource: TPersistent); override;
	published
		property Date: TDateTime read FDate write SetDate;
	end;

    { TTweetItemDataTweet }
	TTweetItemDataTweet = class(TTweetItemData)
	private
		FScreenName: string;
		FText      : string;
		FUserName  : string;
		FUserURL   : string;
		FUserAvatar: TPicture;
		FSourceUrl : string;
		FSource    : string;
		procedure SetScreenName(const Value: string);
		procedure SetUserName(const Value: string);
		procedure SetUserURL(const Value: string);
		procedure SetText(const Value: string);
		procedure SetUserAvatar(const Value: TPicture);
	public
		constructor Create(aTweetItem: TTweetItem); virtual;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;
	published
		property ScreenName: string read FScreenName write SetScreenName; // @user
		property UserName  : string read FUserName write SetUserName; // user name
		property UserURL   : string read FUserURL write SetUserURL; // Url to user profile
		property UserAvatar: TPicture read FUserAvatar write SetUserAvatar; // User's picture/avatar
		property Text      : string read FText write SetText; // Tweet text
		property Source    : string read FSource write FSource; // Name of app used to post tweet
		property SourceUrl : string read FSourceUrl write FSourceUrl; // Url of app used to post tweet
	end;

    { TTweetItemDataInteractionUser }
	TTweetItemDataInteractionUser = record
		UserName, ScreenName, UserURL, TweetText: string;
		UserAvatar: TPicture;
	end;

    { TTweetItemDataInteractionUsers }
	TTweetItemDataInteractionUsers = TList<TTweetItemDataInteractionUser>;

    { TTweetItemDataInteraction }
	TTweetItemDataInteraction = class(TTweetItemData)
	private
		FInteractionUsers: TTweetItemDataInteractionUsers;
		procedure SetInteractionUsers(const Value: TTweetItemDataInteractionUsers);
	public
		constructor Create(aTweetItem: TTweetItem); override;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;

		property InteractionUsers: TTweetItemDataInteractionUsers read FInteractionUsers write SetInteractionUsers;
	end;

	{ TTweetItem }
	TTweetItem = class(TCollectionItem)
	private
		FItemType: TTweetItemType;
		FItemData: TTweetItemData;
		function GetHeight: integer;
		procedure SetHeight(const Value: integer);
		procedure SetItemType(const Value: TTweetItemType);
		procedure SetItemData(const Value: TTweetItemData);
	protected
		FRect : TRect;
		FState: TTweetItemState;
		function GetDisplayName: string; override;
		function TweetsControl: TTweetsControl;
		procedure Repaint;

		function ProcessMouseEvent(const aX, aY: integer; const aAction: TTweetItemAction): boolean;
	public
		constructor Create(aCollection: TCollection); override;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;

		property Height: integer read GetHeight write SetHeight;
	published
		property ItemType: TTweetItemType read FItemType write SetItemType;
		property ItemData: TTweetItemData read FItemData write SetItemData;
	end;

    { TTweetItems }
	TTweetItems = class(TCollection)
	private
		FOwner: TTweetsControl;
		function GetItem(const aIndex: integer): TTweetItem;
		procedure SetItem(const aIndex: integer; const Value: TTweetItem);
	protected
		function GetOwner: TPersistent; override;
		procedure Update(aItem: TCollectionItem); override;
	public
		constructor Create(aOwner: TTweetsControl);

		function Add: TTweetItem;
		function Insert(aIndex: integer): TTweetItem;
		property Items[const aIndex: integer]: TTweetItem read GetItem write SetItem; default;
	end;

	{ TTweetColors }
	TTweetColors = class(TPersistent)
	private
		FOwner : TTweetsControl;
		FColors: array [0 .. 8] of TColor;
		function GetColor(const Index: Integer): TColor;
		procedure SetColor(const Index: Integer; const Value: TColor);
	protected
		procedure InvalidateOwner;
	public
		constructor Create(aOwner: TTweetsControl);
		procedure Assign(aSource: TPersistent); override;
	published
		property TweetBGNormal      : TColor index 0 read GetColor write SetColor;
		property TweetBGHot         : TColor index 1 read GetColor write SetColor;
		property TweetBGDown        : TColor index 2 read GetColor write SetColor;
		property ReplyBGNormal      : TColor index 3 read GetColor write SetColor;
		property ReplyBGHot         : TColor index 4 read GetColor write SetColor;
		property ReplyBGDown        : TColor index 5 read GetColor write SetColor;
		property InteractionBGNormal: TColor index 6 read GetColor write SetColor;
		property InteractionBGHot   : TColor index 7 read GetColor write SetColor;
		property InteractionBGDown  : TColor index 8 read GetColor write SetColor;
	end;

    { Events }
	TOnTweetItemAction = procedure(aSender: TTweetsControl; aItem: TTweetItem; const aAction: TTweetItemAction) of object;

	{ TTweetsControl }
	TTweetsControl = class(TCustomControl)
	private
		FItems: TTweetItems;

		FGlyphMore    : TPicture;
		FGlyphReply   : TPicture;
		FGlyphRetweet : TPicture;
		FGlyphFavorite: TPicture;

		FTweetBackground       : TColor;
		FTweetRepliesBackground: TColor;
		FTweetSeparator        : TColor;
		FGlyphProtected        : TPicture;
		FOnItemAction          : TOnTweetItemAction;
		FTweetColors           : TTweetColors;

		procedure SetGlyphFavorite(const aValue: TPicture);
		procedure SetGlyphMore(const aValue: TPicture);
		procedure SetGlyphReply(const aValue: TPicture);
		procedure SetGlyphRetweet(const aValue: TPicture);
		procedure SetGlyphProtected(const aValue: TPicture);
		procedure SetItems(const Value: TTweetItems);
		procedure SetTweetColors(const Value: TTweetColors);
	protected
		FScrollPos : integer;
		FActiveItem: integer;
		FClickItem : integer;

		procedure CreateParams(var aParams: TCreateParams); override;
		function CanResize(var aNewWidth, aNewHeight: integer): boolean; override;
		procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
		procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
		procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
		function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
		procedure Resize; override;
		procedure Paint; override;

		function GetItemAtPos(const aX, aY: integer): integer;
		procedure PaintItem(const aIndex: integer; const aRect: TRect);
		procedure UpdateScrollBarRange;
		procedure UpdateItemRectangles;
		procedure ItemAction(const aIndex: integer; const aX, aY: integer; const aAction: TTweetItemAction);

		procedure WMKeyDown(var aMsg: TWMKeyDown); message WM_KEYDOWN;
		procedure WMKillFocus(var aMsg: TWMKillFocus); message WM_KILLFOCUS;
		procedure WMVScroll(var aMsg: TWMVScroll); message WM_VSCROLL;
		procedure WMMouseLeave(var aMsg: TMessage); message WM_MOUSELEAVE;
	public
		constructor Create(aOwner: TComponent); override;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;

		procedure ScrollItemIntoView(const aIndex: integer);
	published
		property Align;
		property Anchors;
		property Color;
		property DoubleBuffered;
		property TabStop;
		property ParentColor;
		property Visible;

		property Items: TTweetItems read FItems write SetItems;

		property GlyphRetweet  : TPicture read FGlyphRetweet write SetGlyphRetweet;
		property GlyphReply    : TPicture read FGlyphReply write SetGlyphReply;
		property GlyphFavorite : TPicture read FGlyphFavorite write SetGlyphFavorite;
		property GlyphMore     : TPicture read FGlyphMore write SetGlyphMore;
		property GlyphProtected: TPicture read FGlyphProtected write SetGlyphProtected;

		property TweetColors: TTweetColors read FTweetColors write SetTweetColors;

		property OnItemAction: TOnTweetItemAction read FOnItemAction write FOnItemAction;
	end;

implementation

{ TTweetItemData }

constructor TTweetItemData.Create(aTweetItem: TTweetItem);
begin
	FTweetItem := aTweetItem;
end;

procedure TTweetItemData.Assign(aSource: TPersistent);
begin
	if (aSource is TTweetItemData) then
	begin
		Date := TTweetItemData(aSource).Date;
	end;
end;

procedure TTweetItemData.SetDate(const Value: TDateTime);
begin
	if (FDate = Value) then
		Exit;
	FDate := Value;

	FTweetItem.Repaint;
end;

{ TTweetItemDataTweet }

constructor TTweetItemDataTweet.Create(aTweetItem: TTweetItem);
begin
	FUserAvatar := TPicture.Create;
end;

destructor TTweetItemDataTweet.Destroy;
begin
	FUserAvatar.Free;
	inherited;
end;

procedure TTweetItemDataTweet.Assign(aSource: TPersistent);
begin
	inherited;

	if (aSource is TTweetItemDataTweet) then
	begin
		ScreenName := TTweetItemDataTweet(aSource).ScreenName;
		UserName   := TTweetItemDataTweet(aSource).UserName;
		UserURL    := TTweetItemDataTweet(aSource).UserURL;
		UserAvatar := TTweetItemDataTweet(aSource).UserAvatar;
		Text       := TTweetItemDataTweet(aSource).Text;
	end;
end;

procedure TTweetItemDataTweet.SetScreenName(const Value: string);
begin
	if (FScreenName = Value) then
		Exit;
	FScreenName := Value;
	FTweetItem.Repaint;
end;

procedure TTweetItemDataTweet.SetText(const Value: string);
begin
	if (FText = Value) then
		Exit;
	FText := Value;
	FTweetItem.Repaint;
end;

procedure TTweetItemDataTweet.SetUserAvatar(const Value: TPicture);
begin
	FUserAvatar.Assign(Value);
	FTweetItem.Repaint;
end;

procedure TTweetItemDataTweet.SetUserName(const Value: string);
begin
	if (FUserName = Value) then
		Exit;
	FUserName := Value;
	FTweetItem.Repaint;
end;

procedure TTweetItemDataTweet.SetUserURL(const Value: string);
begin
	if (FUserURL = Value) then
		Exit;
	FUserURL := Value;
	FTweetItem.Repaint;
end;

{ TTweetItemDataInteraction }

constructor TTweetItemDataInteraction.Create(aTweetItem: TTweetItem);
begin
	inherited;

	FInteractionUsers := TTweetItemDataInteractionUsers.Create(

		function: TTweetItemDataInteractionUser
		begin
			Result.UserAvatar := TPicture.Create;
		end,

		procedure(var aItem: TTweetItemDataInteractionUser)
		begin
			aItem.ScreenName := '';
			aItem.UserName := '';
			aItem.UserURL := '';
			aItem.UserAvatar.Free;
		end,

		procedure(const aFromItem: TTweetItemDataInteractionUser; var aToItem: TTweetItemDataInteractionUser)
		begin
			aToItem.ScreenName := aFromItem.ScreenName;
			aToItem.UserName := aFromItem.UserName;
			aToItem.UserURL := aFromItem.UserURL;
			aToItem.UserAvatar.Assign(aFromItem.UserAvatar);
		end,

		function(const aItemA, aItemB: TTweetItemDataInteractionUser): integer
		begin
			if (aItemA.ScreenName < aItemB.ScreenName) then
				Result := - 1
			else if (aItemA.ScreenName > aItemB.ScreenName) then
				Result := 1
			else
				Result := 0;
		end

	  );
end;

destructor TTweetItemDataInteraction.Destroy;
begin
	FInteractionUsers.Free;
	inherited;
end;

procedure TTweetItemDataInteraction.Assign(aSource: TPersistent);
begin
	inherited;

	if (aSource is TTweetItemDataInteraction) then
	begin
		InteractionUsers := TTweetItemDataInteraction(aSource).InteractionUsers;
	end;
end;

procedure TTweetItemDataInteraction.SetInteractionUsers(const Value: TTweetItemDataInteractionUsers);
var
	i: integer;
	t: TTweetItemDataInteractionUser;
begin
	FInteractionUsers.Clear;
	for i := 0 to Value.Count - 1 do
	begin
		t.ScreenName := Value[i].ScreenName;
		t.UserName   := Value[i].UserName;
		t.UserURL    := Value[i].UserURL;
		t.UserAvatar := TPicture.Create;
		t.UserAvatar.Assign(Value[i].UserAvatar);
		FInteractionUsers.Add(t);
	end;
	FTweetItem.Repaint;
end;

{ TTweetItem }

constructor TTweetItem.Create(aCollection: TCollection);
begin
	inherited Create(aCollection);
	FRect.Create(0, 0, 0, 25);
	FState   := tisNormal;
	ItemType := titTweet;
end;

destructor TTweetItem.Destroy;
begin
	if (FItemData <> nil) then
		FItemData.Free;
	inherited;
end;

procedure TTweetItem.Assign(aSource: TPersistent);
begin
	inherited;

	if (aSource is TTweetItem) then
	begin
		ItemType := TTweetItem(aSource).ItemType;
		ItemData.Assign(TTweetItem(aSource).ItemData);
	end;
end;

function TTweetItem.GetDisplayName: string;
begin
	Result := 'TweetItem';
end;

function TTweetItem.TweetsControl: TTweetsControl;
begin
	Result := TTweetsControl(Collection.Owner);
end;

procedure TTweetItem.Repaint;
begin
	if (Collection <> nil) then
		if (Collection.Owner <> nil) then
			TTweetsControl(Collection.Owner).PaintItem(Self.Index, FRect);
end;

function TTweetItem.ProcessMouseEvent(const aX, aY: integer; const aAction: TTweetItemAction): boolean;
begin
	Result := True;

	case aAction of
		tiaMouseEnter:
		begin
			FState := tisOver;
		end;
		tiaMouseLeave:
		begin
			FState := tisNormal;
		end;
		tiaMouseMove:
		begin
			if (FState <> tisDown) then
				FState := tisOver;
		end;
		tiaMouseDown:
		begin
			FState := tisDown;
		end;
		tiaMouseUp:
		begin
			FState := tisOver;
		end;
		tiaMouseClick:
		begin
			FState := tisOver;
		end;
	end;
end;

function TTweetItem.GetHeight: integer;
begin
	Result := FRect.Height;
end;

procedure TTweetItem.SetHeight(const Value: integer);
begin
	if (Height = Value) then
		Exit;
	FRect.Height := Value;
	TTweetsControl(Collection.Owner).Resize;
end;

procedure TTweetItem.SetItemType(const Value: TTweetItemType);
begin
	if (FItemType = Value) and (FItemData <> nil) then
		Exit;
	if (FItemData <> nil) then
		FItemData.Free;
	FItemType := Value;
	case FItemType of
		titTweet:
		FItemData := TTweetItemDataTweet.Create(Self);
		titRetweets, titFavorites, titFollows:
		FItemData := TTweetItemDataInteraction.Create(Self);
		else
		FItemData := nil;
	end;
end;

procedure TTweetItem.SetItemData(const Value: TTweetItemData);
begin
	FItemData.Assign(Value);
end;

{ TTweetItems }

constructor TTweetItems.Create(aOwner: TTweetsControl);
begin
	inherited Create(TTweetItem);
	FOwner := aOwner;
end;

function TTweetItems.Add: TTweetItem;
begin
	Result := TTweetItem(inherited Add);
	if (UpdateCount = 0) then
		TTweetsControl(Owner).Resize;
end;

function TTweetItems.Insert(aIndex: integer): TTweetItem;
begin
	Result := TTweetItem(inherited Insert(aIndex));
	if (UpdateCount = 0) then
		TTweetsControl(Owner).Resize;
end;

procedure TTweetItems.Update(aItem: TCollectionItem);
begin
	inherited;

	if (aItem = nil) then
		TTweetsControl(Owner).Resize;
end;

function TTweetItems.GetOwner: TPersistent;
begin
	Result := FOwner;
end;

function TTweetItems.GetItem(const aIndex: integer): TTweetItem;
begin
	Result := TTweetItem(inherited GetItem(aIndex));
end;

procedure TTweetItems.SetItem(const aIndex: integer; const Value: TTweetItem);
begin
	inherited SetItem(aIndex, Value);
end;

{ TTweetColors }

constructor TTweetColors.Create(aOwner: TTweetsControl);
begin
	FOwner := aOwner;

	FColors[0] := clBtnFace;
	FColors[1] := clBtnHighlight;
	FColors[2] := clBtnShadow;
	FColors[3] := clBtnFace;
	FColors[4] := clBtnHighlight;
	FColors[5] := clBtnShadow;
	FColors[6] := clBtnFace;
	FColors[7] := clBtnHighlight;
	FColors[8] := clBtnShadow;
end;

procedure TTweetColors.Assign(aSource: TPersistent);
begin
	if (aSource is TTweetColors) then
	begin
		Move(TTweetColors(aSource).FColors, FColors, Length(FColors) * SizeOf(TColor));
		InvalidateOwner;
	end;
end;

procedure TTweetColors.InvalidateOwner;
begin
	if (FOwner <> nil) then
		FOwner.Invalidate;
end;

function TTweetColors.GetColor(const Index: Integer): TColor;
begin
	Result := FColors[index];
end;

procedure TTweetColors.SetColor(const Index: Integer; const Value: TColor);
begin
	FColors[index] := Value;
end;

{ TTweetsControl }

constructor TTweetsControl.Create(aOwner: TComponent);
begin
	inherited;
	FTweetColors := TTweetColors.Create(Self);
	FItems       := TTweetItems.Create(Self);
	FActiveItem  := - 1;
	FClickItem   := - 1;

	FGlyphFavorite  := TPicture.Create;
	FGlyphMore      := TPicture.Create;
	FGlyphReply     := TPicture.Create;
	FGlyphRetweet   := TPicture.Create;
	FGlyphProtected := TPicture.Create;

	TabStop := True;

	Height := 121;
	Width  := 201;
end;

destructor TTweetsControl.Destroy;
begin
	FItems.Free;
	FTweetColors.Free;

	FGlyphFavorite.Free;
	FGlyphMore.Free;
	FGlyphReply.Free;
	FGlyphRetweet.Free;
	FGlyphProtected.Free;
	inherited;
end;

procedure TTweetsControl.Assign(aSource: TPersistent);
begin
	inherited;

	if (aSource is TTweetsControl) then
	begin
		FItems.Assign(TTweetsControl(aSource).Items);

		GlyphReply.Assign(TTweetsControl(aSource).GlyphReply);
		GlyphFavorite.Assign(TTweetsControl(aSource).GlyphFavorite);
		GlyphRetweet.Assign(TTweetsControl(aSource).GlyphRetweet);
		GlyphMore.Assign(TTweetsControl(aSource).GlyphMore);
		GlyphProtected.Assign(TTweetsControl(aSource).GlyphProtected);

		TweetColors := TTweetsControl(aSource).TweetColors;

		OnItemAction := TTweetsControl(aSource).OnItemAction;
	end;
end;

procedure TTweetsControl.CreateParams(var aParams: TCreateParams);
begin
	inherited CreateParams(aParams);

	aParams.Style             := aParams.Style or WS_VSCROLL;
	aParams.WindowClass.Style := aParams.WindowClass.Style and not (CS_HREDRAW or CS_VREDRAW);
end;

function TTweetsControl.CanResize(var aNewWidth, aNewHeight: integer): boolean;
begin
	if (aNewWidth < 300) then
		aNewWidth := 300;
	Result        := True;
end;

procedure TTweetsControl.MouseMove(Shift: TShiftState; X, Y: Integer);
var
	i: integer;
begin
	inherited;

	i := GetItemAtPos(X, Y);
	if (i <> FActiveItem) then
	begin
		ItemAction(FActiveItem, X, Y, tiaMouseLeave);
		FActiveItem := i;
		ItemAction(FActiveItem, X, Y, tiaMouseEnter);
	end
	else
	begin
		FActiveItem := i;
		ItemAction(FActiveItem, X, Y, tiaMouseMove);
	end;
end;

procedure TTweetsControl.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
	inherited;
	SetFocus;
	FClickItem := GetItemAtPos(X, Y);
	ItemAction(FClickItem, X, Y, tiaMouseDown);
end;

procedure TTweetsControl.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
	i: integer;
begin
	inherited;
	i := GetItemAtPos(X, Y);
	ItemAction(i, X, Y, tiaMouseUp);
	if (i = FClickItem) then
		ItemAction(FClickItem, X, Y, tiaMouseClick);
	FClickItem := - 1;
end;

function TTweetsControl.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
var
	w: word;
begin
	if (WheelDelta > 0) then
		w := SB_PAGEUP
	else if (WheelDelta < 0) then
		w := SB_PAGEDOWN;
	SendMessage(Handle, WM_VSCROLL, w, 0);
	Result := True;
end;

procedure TTweetsControl.Resize;
begin
	inherited;
	UpdateScrollBarRange;
	UpdateItemRectangles;
	Paint;
end;

procedure TTweetsControl.Paint;
var
	i: integer;
	r: TRect;
begin
	for i := 0 to Items.Count - 1 do
	begin
		if (Items[i].FRect.Top > Height) then
			Break;
		if (Items[i].FRect.Bottom > 0) then
			PaintItem(i, Items[i].FRect);
	end;

	r := ClientRect;
	if (Items.Count > 0) then
		r.Top := Items[Items.Count - 1].FRect.Bottom;

	if (r.Top <= Height) then
	begin
		Canvas.Brush.Color := Color;
		Canvas.FillRect(r);
	end;
end;

function TTweetsControl.GetItemAtPos(const aX, aY: integer): integer;
var
	i: integer;
begin
	Result := - 1;

	for i := 0 to Items.Count - 1 do
		if (Items[i].FRect.Contains(Point(aX, aY))) then
			Exit(i);
end;

procedure TTweetsControl.PaintItem(const aIndex: integer; const aRect: TRect);
var
	r: TRect;
	s: string;
begin
	case Items[aIndex].FState of
		tisNormal:
		begin
			Canvas.Brush.Color := TweetColors.TweetBGNormal;
		end;
		tisOver:
		begin
			Canvas.Brush.Color := TweetColors.TweetBGHot;
		end;
		tisDown:
		begin
			Canvas.Brush.Color := TweetColors.TweetBGDown;
		end;
	end;
	Canvas.Pen.Color := clDkGray;
	Canvas.FillRect(aRect);
	Canvas.MoveTo(aRect.Left, aRect.Bottom - 1);
	Canvas.LineTo(aRect.Width, aRect.Bottom - 1);

	r := aRect;
	s := IntToStr(aIndex);
	Canvas.Font.Assign(Font);
	Canvas.TextRect(r, s, [tfSingleLine, tfCenter, tfVerticalCenter]);
end;

procedure TTweetsControl.UpdateScrollBarRange;
var
	si: TScrollInfo;
	i : integer;
	r : integer;
	d : integer;
begin
	r     := 0;
	for i := 0 to Items.Count - 1 do
		Inc(r, Items[i].Height);

	FillChar(si, SizeOf(si), 0);
	si.cbSize := SizeOf(si);
	si.fMask  := SIF_RANGE or SIF_PAGE or SIF_POS;
	GetScrollInfo(Handle, SB_VERT, si);

	si.nMax := (r - 1);
	if (si.nMax < 0) then
		si.nMax := 0;
	si.nPage    := ClientHeight;

	d := (si.nMax - integer(si.nPage));
	if (d < 0) then
		d := 0;

	if (si.nPos > d) then
		si.nPos := d;
	FScrollPos  := si.nPos;
	SetScrollInfo(Handle, SB_VERT, si, True);
end;

procedure TTweetsControl.UpdateItemRectangles;
var
	h: integer;
	i: integer;
	t: integer;
begin
	t     := (0 - FScrollPos);
	for i := 0 to Items.Count - 1 do
	begin
		h                     := Items[i].Height;
		Items[i].FRect.Top    := t;
		Items[i].FRect.Right  := Width;
		Items[i].FRect.Bottom := Items[i].FRect.Top + h;
		Inc(t, Items[i].Height);
	end;
end;

procedure TTweetsControl.ItemAction(const aIndex: integer; const aX, aY: integer; const aAction: TTweetItemAction);
begin
	if (aIndex < 0) or (aIndex >= FItems.Count) or (Assigned(FOnItemAction) = False) then
		Exit;

	FOnItemAction(Self, Items[aIndex], aAction);

	if (Items[aIndex].ProcessMouseEvent(aX, aY, aAction)) then
		PaintItem(aIndex, FItems[aIndex].FRect);
end;

procedure TTweetsControl.ScrollItemIntoView(const aIndex: integer);
var
	i : integer;
	t : integer;
	ri: TRect;
	rc: TRect;
	si: TScrollInfo;
begin
	if (aIndex >= Items.Count) then
		Exit;

	rc := ClientRect;
	ri := rc;
	t  := 0;

	for i := 0 to Items.Count - 1 do
	begin
		ri.Top    := (t - FScrollPos);
		ri.Bottom := (ri.Top + Items[i].Height);
		if (i = aIndex) then
			Break;
		Inc(t, Items[i].Height);
	end;

	if (rc.Contains(ri)) then
		Exit;

	FillChar(si, SizeOf(si), 0);
	si.cbSize := SizeOf(si);
	si.fMask  := SIF_ALL;
	GetScrollInfo(Self.Handle, SB_VERT, si);

	if (ri.Top < rc.Top) then
	begin
		si.nPos := (FScrollPos + ri.Top);
		SetScrollInfo(Handle, SB_VERT, si, True);
		FScrollPos := si.nPos;
		UpdateItemRectangles;
		Paint;
		Exit;
	end;

	if (ri.Bottom > rc.Bottom) then
	begin
		si.nPos := ((FScrollPos + ri.Bottom) - rc.Height);
		SetScrollInfo(Handle, SB_VERT, si, True);
		FScrollPos := si.nPos;
		UpdateItemRectangles;
		Paint;
		Exit;
	end;
end;

procedure TTweetsControl.SetGlyphFavorite(const aValue: TPicture);
begin
	FGlyphFavorite.Assign(aValue);
end;

procedure TTweetsControl.SetGlyphMore(const aValue: TPicture);
begin
	FGlyphMore.Assign(aValue);
end;

procedure TTweetsControl.SetGlyphProtected(const aValue: TPicture);
begin
	FGlyphProtected.Assign(aValue);
end;

procedure TTweetsControl.SetGlyphReply(const aValue: TPicture);
begin
	FGlyphReply.Assign(aValue);
end;

procedure TTweetsControl.SetGlyphRetweet(const aValue: TPicture);
begin
	FGlyphRetweet.Assign(aValue);
end;

procedure TTweetsControl.SetItems(const Value: TTweetItems);
begin
	FItems.Assign(Value);
end;

procedure TTweetsControl.SetTweetColors(const Value: TTweetColors);
begin
	FTweetColors.Assign(Value);
end;

procedure TTweetsControl.WMKeyDown(var aMsg: TWMKeyDown);
var
	w: word;
begin
	w := $FFFF;
	case aMsg.CharCode of
		VK_UP:
		w := SB_LINEUP;
		VK_DOWN:
		w := SB_LINEDOWN;
		VK_PRIOR:
		w := SB_PAGEUP;
		VK_NEXT:
		w := SB_PAGEDOWN;
		VK_HOME:
		w := SB_TOP;
		VK_END:
		w := SB_BOTTOM;
	end;

	if (w <> $FFFF) then
		SendMessage(Handle, WM_VSCROLL, MakeLong(w, 0), 0);
end;

procedure TTweetsControl.WMKillFocus(var aMsg: TWMKillFocus);
begin
	FClickItem := - 1;
end;

procedure TTweetsControl.WMVScroll(var aMsg: TWMVScroll);
var
	si: TScrollInfo;
	v : integer;
begin
	aMsg.Result := 0;

	FillChar(si, SizeOf(si), 0);
	si.cbSize := SizeOf(si);
	si.fMask  := SIF_ALL;
	GetScrollInfo(Self.Handle, SB_VERT, si);

	case aMsg.ScrollCode of
		SB_TOP:
		v := - si.nPos;
		SB_BOTTOM:
		v := (si.nMax - si.nPos);
		SB_LINEUP:
		v := - 1;
		SB_LINEDOWN:
		v := 1;
		SB_PAGEUP:
		v := - si.nPage;
		SB_PAGEDOWN:
		v := si.nPage;
		SB_THUMBTRACK:
		v := (si.nTrackPos - si.nPos);
		else
		Exit;
	end;

	if (v > 0) then
		if (v > (si.nMax - integer(si.nPage) - si.nPos + 1)) then
			v := (si.nMax - integer(si.nPage) - si.nPos + 1);

	if (v < 0) then
		if (Abs(v) > si.nPos) then
			v := - si.nPos;

	si.nPos    := (si.nPos + v);
	FScrollPos := si.nPos;
	SetScrollInfo(Handle, SB_VERT, si, True);
	UpdateItemRectangles;
	Paint;
end;

procedure TTweetsControl.WMMouseLeave(var aMsg: TMessage);
var
	p: TPoint;
begin
	GetCursorPos(p);
	ItemAction(FActiveItem, p.X, p.Y, tiaMouseLeave);
	FActiveItem := - 1;
end;

end.
