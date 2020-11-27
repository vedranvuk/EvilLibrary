unit EvilWorks.Vcl.ConsoleIO;

interface

uses
	WinApi.Windows,
    WinApi.Messages,
	System.Classes,
    System.SysUtils,
	Vcl.Forms;

const
	MIO_OFFSET             = $1911;
	MIO_RECEIVE_OUTPUT     = WM_USER + MIO_OFFSET + 0;
	MIO_RECEIVE_ERROR      = WM_USER + MIO_OFFSET + 1;
	MIO_ERROR              = WM_USER + MIO_OFFSET + 2;
	MIO_PROCESS_TERMINATED = WM_USER + MIO_OFFSET + 3;

type
	TReceiveEvent             = procedure(Sender: TObject; const Cmd: string) of object;
	TProcessStatusChangeEvent = procedure(Sender: TObject; IsRunning: Boolean) of object;
	TSplitMode                = (smNone, sm0D0A, smSplitchar);

    { TConsoleIO }
	TConsoleIO = class(TComponent)
	private
		FWindowHandle                  : HWND;
		InputReadPipe, InputWritePipe  : THandle;
		OutputReadPipe, OutputWritePipe: THandle;
		ErrorReadPipe, ErrorWritePipe  : THandle;
		FProcessHandle                 : THandle;
		FTerminateCommand              : string;
		FEnableKill                    : Boolean;
		FWaitTimeout                   : Integer;
		FStopProcessOnFree             : Boolean;
		FOutputBuffer                  : string;
		FSplitReceive                  : Boolean;
		FSplitSend                     : Boolean;
		FSplitChar                     : Char;
		FSplitMode                     : TSplitMode;
		FOnReceiveError                : TReceiveEvent;
		FOnReceiveOutput               : TReceiveEvent;
		FOnError                       : TReceiveEvent;
		FOnProcessStatusChange         : TProcessStatusChangeEvent;
		function GetIsRunning: Boolean;
		procedure SetProcessHandle(const Value: THandle);
		procedure ReceiveOutput(Buf: Pointer; Size: Integer);
		procedure ReceiveError(Buf: Pointer; Size: Integer);
		procedure Error(const Msg: string);
		procedure ReaderProc(Handle: THandle; MessageCode: Integer);
		procedure ProcessTerminated;
		procedure CloseProcessHandle;
		function SplitSendAvail: string;
		property ProcessHandle: THandle read FProcessHandle write SetProcessHandle;
		property OutputBuffer: string read FOutputBuffer write FOutputBuffer;
	protected
		procedure WndProc(var Msg: TMessage);
	public
		constructor Create(AOwner: TComponent); override;
		destructor Destroy; override;
		procedure ClosePipes;
		procedure SendInput(Msg: string);
		procedure RunProcess(const CmdLine: string; CurrentDir: string = ''; ShowWindow: Boolean = False);
		procedure StopProcess;
	published
		property EnableKill       : Boolean read FEnableKill write FEnableKill default False;
		property IsRunning        : Boolean read GetIsRunning;
		property SplitChar        : Char read FSplitChar write FSplitChar default #10;
		property SplitMode        : TSplitMode read FSplitMode write FSplitMode default sm0D0A;
		property SplitReceive     : Boolean read FSplitReceive write FSplitReceive default True;
		property SplitSend        : Boolean read FSplitSend write FSplitSend default True;
		property StopProcessOnFree: Boolean read FStopProcessOnFree write FStopProcessOnFree default True;
		property TerminateCommand : string read FTerminateCommand write FTerminateCommand;
		property WaitTimeout      : Integer read FWaitTimeout write FWaitTimeout default 1000;

		property OnError              : TReceiveEvent read FOnError write FOnError;
		property OnProcessStatusChange: TProcessStatusChangeEvent read FOnProcessStatusChange write FOnProcessStatusChange;
		property OnReceiveError       : TReceiveEvent read FOnReceiveError write FOnReceiveError;
		property OnReceiveOutput      : TReceiveEvent read FOnReceiveOutput write FOnReceiveOutput;
	end;

implementation

{ Win API wrappers }

procedure WinCheck(Result: Boolean);
begin
	if not Result then
		RaiseLastOSError;
end;

procedure InprocessDuplicateHandle(Source: THandle; var Destination: THandle);
var
	CurrentProcess: THandle;
begin
	CurrentProcess := GetCurrentProcess;
	WinCheck(DuplicateHandle(CurrentProcess, Source, CurrentProcess, @Destination, 0, False, DUPLICATE_SAME_ACCESS));
end;

procedure CloseAndZeroHandle(var Handle: THandle);
var
	SaveHandle: THandle;
begin
	SaveHandle := Handle;
	Handle     := 0;
	WinCheck(CloseHandle(SaveHandle));
end;

function ToPChar(const St: string): PChar;
begin
	if (St = EmptyStr) then
		Result := nil
	else
		Result := PChar(St);
end;

{ Thread functions }

procedure IOReadOutput(Handler: TConsoleIO);
begin
	Handler.ReaderProc(Handler.OutputReadPipe, MIO_RECEIVE_OUTPUT);
end;

procedure IOReadError(Handler: TConsoleIO);
begin
	Handler.ReaderProc(Handler.ErrorReadPipe, MIO_RECEIVE_ERROR);
end;

procedure WaitProcess(Handler: TConsoleIO);
begin
	if WaitForSingleObject(Handler.ProcessHandle, INFINITE) = WAIT_OBJECT_0 then
		SendMessage(Handler.FWindowHandle, MIO_PROCESS_TERMINATED, 0, 0);
end;

{ TConsoleIO }

constructor TConsoleIO.Create(AOwner: TComponent);
begin
	inherited;
	FTerminateCommand  := 'quit';
	FSplitChar         := #10;
	FSplitMode         := sm0D0A;
	FSplitReceive      := True;
	FSplitSend         := True;
	FStopProcessOnFree := True;
	FWaitTimeout       := 1000;
	FWindowHandle      := AllocateHWnd(WndProc);
end;

destructor TConsoleIO.Destroy;
begin
	if StopProcessOnFree then
		StopProcess;
	CloseProcessHandle;
	DeallocateHWnd(FWindowHandle);
	FWindowHandle := 0;
	inherited;
end;

procedure TConsoleIO.ClosePipes;
begin
	CloseAndZeroHandle(InputReadPipe);
	CloseAndZeroHandle(OutputWritePipe);
	CloseAndZeroHandle(ErrorWritePipe);
	CloseAndZeroHandle(InputWritePipe);
	CloseAndZeroHandle(OutputReadPipe);
	CloseAndZeroHandle(ErrorReadPipe);
end;

procedure TConsoleIO.ReceiveOutput(Buf: Pointer; Size: Integer);
var
	Cmd        : string;
	TastyStrPos: Integer;
begin
	if (Size <= 0) then
		Exit;
	SetString(Cmd, PAnsiChar(Buf), Size);
	OutputBuffer := OutputBuffer + Cmd;
	if not Assigned(FOnReceiveOutput) then
		Exit;

	if not SplitReceive or (SplitMode = smNone) then
	begin
		FOnReceiveOutput(Self, OutputBuffer);
		OutputBuffer := '';
	end
	else if SplitMode = sm0D0A then
		repeat
			TastyStrPos := Pos(#13#10, OutputBuffer);
			if TastyStrPos = 0 then
				Break;
			FOnReceiveOutput(Self, Copy(OutputBuffer, 1, TastyStrPos - 1));
			OutputBuffer := Copy(OutputBuffer, TastyStrPos + 2, Length(OutputBuffer));
		until False
	else if SplitMode = smSplitchar then
		repeat
			TastyStrPos := Pos(SplitChar, OutputBuffer);
			if TastyStrPos = 0 then
				Break;
			FOnReceiveOutput(Self, Copy(OutputBuffer, 1, TastyStrPos - 1));
			OutputBuffer := Copy(OutputBuffer, TastyStrPos + 1, Length(OutputBuffer));
		until False;
end;

procedure TConsoleIO.ReceiveError(Buf: Pointer; Size: Integer);
var
	Cmd: string;
begin
	if (Size <= 0) then
		Exit;
	if not Assigned(FOnReceiveOutput) then
		Exit;
	SetString(Cmd, PAnsiChar(Buf), Size);
	FOnReceiveError(Self, Cmd);
end;

procedure TConsoleIO.RunProcess(const CmdLine: string; CurrentDir: string = ''; ShowWindow: Boolean = False);
var
	buffer: array [0 .. MAX_PATH] of Char;
	SA    : TSecurityAttributes;
	SI    : TStartupInfo;
	PI    : TProcessInformation;

	InputWriteTmp: THandle;
	OutputReadTmp: THandle;
	ErrorReadTmp : THandle;

	ThreadId: Cardinal;
begin
	SA.nLength              := SizeOf(SA);
	SA.lpSecurityDescriptor := nil;
	SA.bInheritHandle       := True;

	WinCheck(CreatePipe(InputReadPipe, InputWriteTmp, @SA, 0));
	WinCheck(CreatePipe(OutputReadTmp, OutputWritePipe, @SA, 0));
	WinCheck(CreatePipe(ErrorReadTmp, ErrorWritePipe, @SA, 0));

	InprocessDuplicateHandle(InputWriteTmp, InputWritePipe);
	InprocessDuplicateHandle(OutputReadTmp, OutputReadPipe);
	InprocessDuplicateHandle(ErrorReadTmp, ErrorReadPipe);

	CloseAndZeroHandle(InputWriteTmp);
	CloseAndZeroHandle(OutputReadTmp);
	CloseAndZeroHandle(ErrorReadTmp);

	FillChar(SI, SizeOf(SI), $00);
	SI.cb         := SizeOf(SI);
	SI.dwFlags    := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
	SI.hStdInput  := InputReadPipe;
	SI.hStdOutput := OutputWritePipe;
	SI.hStdError  := ErrorWritePipe;
	if (ShowWindow) then
		SI.wShowWindow := SW_SHOW
	else
		SI.wShowWindow := SW_HIDE;

	ZeroMemory(@buffer, SizeOf(buffer));
	CopyMemory(@buffer[0], @CmdLine[1], Length(CmdLine) * StringElementSize(CmdLine));
	WinCheck(CreateProcess(nil, buffer, @SA, nil, True, CREATE_NEW_CONSOLE, nil, ToPChar(CurrentDir), SI, PI));

	CloseAndZeroHandle(PI.hThread);
	ProcessHandle := PI.hProcess;
	WinCheck(BeginThread(nil, 0, @IOReadOutput, Self, 0, ThreadId) <> 0);
	WinCheck(BeginThread(nil, 0, @IOReadError, Self, 0, ThreadId) <> 0);
	WinCheck(BeginThread(nil, 0, @WaitProcess, Self, 0, ThreadId) <> 0);
end;

procedure TConsoleIO.SendInput(Msg: string);
var
	BytesWritten: Cardinal;
	bfr         : ansistring;
begin
	Msg := Msg + SplitSendAvail;
    bfr := ansistring(Msg);
	WinCheck(WriteFile(InputWritePipe, bfr[1], Length(Msg), BytesWritten, nil));
end;

procedure TConsoleIO.WndProc(var Msg: TMessage);
var
	Unhandled: Boolean;
begin
	with Msg do
	begin
		Unhandled := False;
		try
			case Msg of
				MIO_RECEIVE_OUTPUT:
				ReceiveOutput(Pointer(wParam), LParam);
				MIO_RECEIVE_ERROR:
				ReceiveError(Pointer(wParam), LParam);
				MIO_PROCESS_TERMINATED:
				ProcessTerminated;
				MIO_ERROR:
				Error(string(Pointer(wParam)))
				else
				Unhandled := True;
			end;
		except
			Application.HandleException(Self);
		end;
		if Unhandled then
			Result := DefWindowProc(FWindowHandle, Msg, wParam, LParam);
	end;
end;

procedure TConsoleIO.Error(const Msg: string);
begin
	if Assigned(FOnError) then
		FOnError(Self, Msg);
end;

procedure TConsoleIO.ReaderProc(Handle: THandle; MessageCode: Integer);
var
	Buf      : array [0 .. 1024] of Char;
	BytesRead: Cardinal;
	Err      : string;
begin
	repeat
		if not ReadFile(Handle, Buf, SizeOf(Buf), BytesRead, nil) then
			try
				if not IsRunning then
					Exit;
				RaiseLastOSError;
			except
				on E: Exception do
				begin
					Err := E.Message;
					SendMessage(FWindowHandle, MIO_ERROR, Integer(PChar(Err)), Length(Err) + 1);
				end;
			end;

		if BytesRead > 0 then
			SendMessage(FWindowHandle, MessageCode, Integer(@Buf), BytesRead);
	until False;
end;

procedure TConsoleIO.ProcessTerminated;
begin
	if Assigned(FOnReceiveOutput) then
		FOnReceiveOutput(Self, OutputBuffer);
	OutputBuffer := '';
	CloseProcessHandle;
	ClosePipes;
end;

function TConsoleIO.GetIsRunning: Boolean;
begin
	Result := ProcessHandle <> 0;
end;

procedure TConsoleIO.SetProcessHandle(const Value: THandle);
begin
	if FProcessHandle = Value then
		Exit;
	Assert((ProcessHandle = 0) or (Value = 0));
	FProcessHandle := Value;
	if Assigned(FOnProcessStatusChange) then
		FOnProcessStatusChange(Self, IsRunning);
end;

procedure TConsoleIO.CloseProcessHandle;
begin
	if ProcessHandle = 0 then
		Exit;
	WinCheck(CloseHandle(ProcessHandle));
	ProcessHandle := 0;
end;

procedure TConsoleIO.StopProcess;
begin
	if not IsRunning then
		Exit;
	if TerminateCommand <> '' then
		SendInput(TerminateCommand);
	if not EnableKill then
		Exit;
	if TerminateCommand <> '' then
		if WaitForSingleObject(ProcessHandle, WaitTimeout) = WAIT_OBJECT_0 then
			Exit;
	TerminateProcess(ProcessHandle, 4);
end;

function TConsoleIO.SplitSendAvail: string;
begin
	Result := '';
	if not SplitSend then
		Exit;
	if SplitMode = smNone then
		Exit;
	if SplitMode = sm0D0A
	then
		Result := #$0D#$0A
	else
		Result := SplitChar
end;

end.
