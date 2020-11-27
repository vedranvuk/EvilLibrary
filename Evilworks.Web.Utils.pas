//
// EvilLibrary by Vedran Vuk 2010-2012
//
// Name: 					EvilWorks.Web.Utils
// Description: 			Helper classes for Async Sockets.
// File last change date:   December 28th. 2012
// File version: 			Dev 0.0.0
// Licence:                 Free.
//

unit EvilWorks.Web.Utils;

interface

uses
	WinApi.Windows,
	EvilWorks.System.StrUtils;

type

	{ TBuffer }
    { Linear FIFO buffer for sockets. Add to end of buffer with Append(), }
    { Read and remove with Consume(). Use Size() and Peek() to READ-ONLY! }
    { Designed for small buffers, appending to large buffer can be slow!! }
	TBuffer = record
	private
		FBuffer: pbyte;
		FSize  : integer;
	public
		procedure Clear; // Constructor/Destructor!
		function Empty: Boolean;

		function Append(const aData: pByte; const aSize: integer): integer; overload;
		function Append(const aSize: integer): pByte; overload;
		function Consume(const aData: pByte; const aSize: integer): integer; overload;
		function ConsumeLine(const aWideChars: boolean = False; const aDelFeeds: boolean = True): string;

		property Peek: pbyte read FBuffer;
		property Size: integer read FSize;
	end;

    { TMutex }
    { Simple mutex helper for ensuring socket messages get processed sequentially. }
	TMutex = class
	private
		FCritSect: TRTLCriticalSection;
	public
		constructor Create;
		destructor Destroy; override;

		procedure Lock;
		procedure Unlock;
	end;

implementation

{ ======= }
{ TBuffer }
{ ======= }

{ Clears/creates/initializes the buffer. }
procedure TBuffer.Clear;
begin
	if (FSize > 0) then
		FreeMem(FBuffer, FSize);
	FBuffer := nil;
	FSize   := 0;
end;

{ Checks if the internal buffer is empty. }
function TBuffer.Empty: Boolean;
begin
	Result := (FSize = 0);
end;

{ Append data to the end of internal buffer. }
function TBuffer.Append(const aData: pByte; const aSize: integer): integer;
var
	p: pbyte;
begin
	if (aSize <= 0) then
		Exit(0);

	if (FSize = 0) then
	begin
		FBuffer := GetMemory(aSize);
        Move(aData^, FBuffer^, aSize);
		FSize := aSize;
		Exit(aSize);
	end;

	ReallocMem(FBuffer, FSize + aSize);
	p := FBuffer;
	Inc(p, FSize);
	Move(aData^, p^, aSize);
	Inc(FSize, aSize);
	Result := aSize;
end;

{ Appends memory of aSize at the end of the internal buffer and returns it. }
function TBuffer.Append(const aSize: integer): pByte;
begin
	if (aSize <= 0) then
		Exit(nil);

	if (FSize = 0) then
	begin
		FBuffer := GetMemory(aSize);
		FSize   := aSize;
		Exit(FBuffer);
	end;

	ReallocMem(FBuffer, FSize + aSize);
	Result := FBuffer;
	Inc(Result, FSize);
	Inc(FSize, aSize);
end;

{ Consume data from internal buffer; Copies aSize of bytes to aData and removes from internal buffer. }
{ If aData = nil then the data is just removed from internal buffer without being copied to aData. }
function TBuffer.Consume(const aData: pByte; const aSize: integer): integer;
var
	Buff: pointer;
begin
	if (aSize <= 0) or (FSize = 0) then
		Exit(0);

	if (aSize >= FSize) then
	begin
		if (aData <> nil) then
        	Move(FBuffer^, aData^, FSize);
		Result := FSize;
		FreeMem(FBuffer, FSize);
		FBuffer := nil;
		FSize   := 0;
		Exit;
	end;

	if (aData <> nil) then
    	Move(FBuffer^, aData^, aSize);
	Buff := GetMemory(FSize - aSize);
	Move((PByte(FBuffer) + aSize)^, Buff^, FSize - aSize);
	FreeMem(FBuffer);
	FBuffer := Buff;
	Dec(FSize, aSize);
	Result := aSize;
end;

{ Tries to read the buffer as a string from the beginning. If a CRLF terminator is found }
{ Data from the start of the buffer is read as a string, returned and removed from the buffer. }
{ If aWideChars, two bytes are read as one char. Text is returned without line feeds. }
function TBuffer.ConsumeLine(const aWideChars: boolean; const aDelFeeds: boolean): string;
var
	p: pbyte;
	m: integer;
begin
	Result := '';
	p      := Peek;
	m      := 0;
	while (p < pbyte(FBuffer + FSize)) do
	begin
		case m of
			0:
			begin
				if (p^ = 13) then
					m := 1;
			end;
			1:
			begin
				if (p^ = 10) then
				begin
					if (aWideChars) then
						SetString(Result, PChar(FBuffer), p - FBuffer + 1)
					else
						SetString(Result, PAnsiChar(FBuffer), p - FBuffer + 1);

					if (aDelFeeds) then
						Result := TextRemoveLineFeeds(Result);

					Consume(nil, p - FBuffer + 1);
					Exit;
				end;
			end;
		end;
		Inc(p);
	end;
end;

{ ====== }
{ TMutex }
{ ====== }

{ Constructor. }
constructor TMutex.Create;
begin
	InitializeCriticalSection(FCritSect);
end;

{ Destructor. }
destructor TMutex.Destroy;
begin
	DeleteCriticalSection(FCritSect);
	inherited;
end;

{ Enter critical section. }
procedure TMutex.Lock;
begin
	EnterCriticalSection(FCritSect);
end;

{ Leave critical section. }
procedure TMutex.Unlock;
begin
	LeaveCriticalSection(FCritSect);
end;

end.
