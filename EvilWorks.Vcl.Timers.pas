unit EvilWorks.VCL.Timers;

interface

uses
    Winapi.Windows, WinApi.Messages,
    System.Classes, System.SysUtils;

type
    { Forward Declarations }
    TNamedTimer     = class;
    TNamedTimerList = class;

    { Events }
    TOnNamedTimer = procedure(aTimer: TNamedTimer; const aName: string) of object;

    { TNamedTimer }
    TNamedTimer = class
    private
        FTimerList : TNamedTimerList;
        FName      : string;
        FID        : cardinal;
        FOnTimer   : TOnNamedTimer;
        FRepeats   : cardinal;
        FTimesFired: cardinal;
    public
        constructor Create(aList: TNamedTimerList; const aName: string; const aID: cardinal; aOnTimer: TOnNamedTimer; const aInterval, aRepeats: cardinal);
        destructor Destroy; override;

        property Repeats: cardinal read FRepeats;
        property TimesFired: cardinal read FTimesFired;
    end;

    { TNamedTimerList }
    TNamedTimerList = class(TComponent)
    private
    class var
        FWindowHandle: HWND;
        FTimerCount  : integer;
        FTimerList   : array of TNamedTimer;
        class function Find(const aID: cardinal): integer; overload;
        class function Find(const aName: string): integer; overload;
        class function FindFreeID: cardinal;
        class procedure DelTimer(const aIndex: integer); overload;
    protected
        procedure CreateMsgWindow;
        procedure DestroyMsgWindow;
        procedure WndProc(var Msg: TMessage);
    public
        constructor Create(aOwner: TComponent); override;
        destructor Destroy; override;

        procedure AddTimer(const aName: string; aOnTimer: TOnNamedTimer; const aInterval, aRepeats: cardinal);
        procedure DelTimer(const aName: string); overload;
    end;

implementation

{ TNamedTimer }

constructor TNamedTimer.Create(aList: TNamedTimerList; const aName: string; const aID: cardinal; aOnTimer: TOnNamedTimer; const aInterval, aRepeats: cardinal);
begin
    FTimerList  := aList;
    FName       := aName;
    FID         := aID;
    FOnTimer    := aOnTimer;
    FRepeats    := aRepeats;
    FTimesFired := 0;
    SetTimer(FTimerList.FWindowHandle, FID, aInterval, nil);
end;

destructor TNamedTimer.Destroy;
begin
    KillTimer(FTimerList.FWindowHandle, FID);
    inherited;
end;

{ TNamedTimerList }

constructor TNamedTimerList.Create(aOwner: TComponent);
begin
    inherited;
    CreateMsgWindow;
end;

destructor TNamedTimerList.Destroy;
begin
    DestroyMsgWindow;
    inherited;
end;

procedure TNamedTimerList.CreateMsgWindow;
begin
    if (FWindowHandle <> 0) then
        Exit;

    FTimerCount   := 0;
    FWindowHandle := AllocateHWnd(WndProc);
end;

procedure TNamedTimerList.DestroyMsgWindow;
begin
    if (FTimerCount <> 0) then
        Exit;

    DeallocateHWnd(FWindowHandle);
    FWindowHandle := 0;
end;

procedure TNamedTimerList.WndProc(var Msg: TMessage);
var
    idx: integer;
    tmr: TNamedTimer;
begin
    if (Msg.Msg = WM_TIMER) then
    begin
        idx := Find(Msg.WParam);
        if (idx > -1) then
        begin
            tmr := FTimerList[idx];
            Inc(tmr.FTimesFired);
            if (Assigned(tmr.FOnTimer)) then
                tmr.FOnTimer(tmr, tmr.FName);
            if (tmr.FRepeats <> 0) then
                if (tmr.FTimesFired >= tmr.FRepeats) then
                    DelTimer(idx);
            Msg.Result := 0;
        end;
    end
    else
        Msg.Result := DefWindowProc(FWindowHandle, Msg.Msg, Msg.WParam, Msg.LParam);
end;

{ aName     = name of your timer. }
{ aOnTimer  = event which gets called when the timer fires. }
{ aInterval = interval in milliseconds. }
{ aRepeats  = number of repeats before the timer destroys itself. 0 for infinite. }
{ Timer starts as soon as its added. Theres no Enabled property. Use DelTimer if you don't need it anymore. }
{ If a timer with same name already exists it's re-added. }
procedure TNamedTimerList.AddTimer(const aName: string; aOnTimer: TOnNamedTimer; const aInterval, aRepeats: cardinal);
var
    i : integer;
    id: cardinal;
begin
    i := Find(aName);
    if (i <> -1) then
        DelTimer(i);

    id := FindFreeID;
    Inc(FTimerCount);
    SetLength(FTimerList, FTimerCount);
    FTimerList[FTimerCount - 1] := TNamedTimer.Create(Self, aName, id, aOnTimer, aInterval, aRepeats);
end;

procedure TNamedTimerList.DelTimer(const aName: string);
begin
    DelTimer(Find(aName));
end;

class procedure TNamedTimerList.DelTimer(const aIndex: integer);
begin
    if (aIndex < 0) or (aIndex >= FTimerCount) then
        Exit;

    FTimerList[aIndex].Free;
    Dec(FTimerCount);
    if (aIndex < FTimerCount) then
        System.Move(FTimerList[aIndex + 1], FTimerList[aIndex], (FTimerCount - aIndex) * SizeOf(TNamedTimer));
    SetLength(FTimerList, FTimerCount);
end;

class function TNamedTimerList.Find(const aName: string): integer;
var
    i: integer;
begin
    Result := -1;
    for i  := 0 to FTimerCount - 1 do
        if (SameText(FTimerList[i].FName, aName)) then
            Exit(i);
end;

class function TNamedTimerList.Find(const aID: cardinal): integer;
var
    i: integer;
begin
    Result := -1;
    for i  := 0 to FTimerCount - 1 do
        if (FTimerList[i].FID = aID) then
            Exit(i);
end;

class function TNamedTimerList.FindFreeID: cardinal;
var
    i: integer;
begin
    Result := 0;

    while (True) do
    begin
        for i := 0 to FTimerCount - 1 do
        begin
            if (FTimerList[i].FID = Result) then
            begin
                Inc(Result);
                Break;
            end;
        end;
        if (i = FTimerCount) then
            Break;
    end;
end;

end.
