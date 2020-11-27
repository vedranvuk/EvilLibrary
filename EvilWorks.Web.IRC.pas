//
// EvilLibrary by Vedran Vuk 2010-2012
//
// Name: 					EvilWorks.Web.IRC
// Description: 			IRC client.
// File last change date:   October 27th. 2012
// File version: 			Dev 0.0.0
// Licence:                 Free.
//

{ TODO: Finish IRC. }

unit EvilWorks.Web.IRC platform;

interface

uses
	Winapi.Windows,
	Winapi.Messages,
	System.Classes,
	System.SysUtils,
	EvilWorks.Api.Winsock2,
	EvilWorks.System.SysUtils,
	EvilWorks.System.StrUtils,
    EvilWorks.Web.Utils,
	EvilWorks.Web.AsyncSockets;

const
	CWHO: string     = 'WHO';
	CTIME: string    = 'TIME';
	CPASS: string    = 'PASS';
	CNICK: string    = 'NICK';
	CUSER: string    = 'USER';
	CPING: string    = 'PING';
	CPONG: string    = 'PONG';
	CJOIN: string    = 'JOIN';
	CPART: string    = 'PART';
	CKICK: string    = 'KICK';
	CMODE: string    = 'MODE';
	CQUIT: string    = 'QUIT';
	CKILL: string    = 'KILL';
	CWHOIS: string   = 'WHOIS';
	CTOPIC: string   = 'TOPIC';
	CNAMES: string   = 'NAMES';
	CERROR: string   = 'ERROR';
	CINVITE: string  = 'INVITE';
	CNOTICE: string  = 'NOTICE';
	CACTION: string  = 'ACTION';
	CFINGER: string  = 'FINGER';
	CSAMODE: string  = 'SAMODE';
	CVERSION: string = 'VERSION';
	CWALLOPS: string = 'WALLOPS';
	CPRIVMSG: string = 'PRIVMSG';

	CBold: char      = #$02;
	CColor: char     = #$03;
	COrdinary: char  = #$0F;
	CReverse: char   = #$16;
	CItalic: char    = #$1D;
	CUnderline: char = #$1F;

type
    { Forward declarations. }
	TIRCCmdParser = class;
	TIRCClient    = class;

    { Events. }
	TOnRaw = procedure(aSender: TIRCClient; const aMsg: TIRCCmdParser; var aBlock: boolean) of object;

	{ TIrcCmdParser }
	{ Parses an IRC message/command. }
	TIRCCmdParser = class
	strict private
	type
		TSourceType = (stServer, stUser, stNotPresent);

		TWordMarker = record
			Start: integer;
			Length: integer;
		end;
	strict private
		FRaw           : string; { Parsed IRC command }
		FSourceType    : TSourceType;
		FSource        : TWordMarker;
		FSourceNickName: TWordMarker;
		FSourceUserName: TWordMarker;
		FSourceHostName: TWordMarker;
		FCommand       : TWordMarker;
		FParams        : TWordMarker;
		FParamsArray   : array of TWordMarker;
		FParamCount    : integer;
		FTrailings     : TWordMarker;
		FTrailingsArray: array of TWordMarker;
		FTrailingCount : integer;
		function GetParam(aIndex: integer): string;
		function GetTrailing(aIndex: integer): string;
	private
		procedure AddParam(const aStart, aLength: integer);
		procedure AddTrailing(const aStart, aLength: integer);
		procedure Clear;
	public
		constructor Create;
		destructor Destroy; override;

		{ Parses a RAW IRC message. }
		function Parse(const aRaw: string): boolean;

		{ Returns the last RAW passed to Parse(); }
		property Raw: string read FRaw;

		{ Type of message source prefix. }
		property SourceType: TSourceType read FSourceType;

		{ Returns the message source if present; Client or Server that created the message. }
		function Source: string;
		{ Returns NickName from Source if Source is a Client, full source string otherwise. }
		function SourceNickName: string;
		{ Returns UserName from Source if Source is a Client, full source string otherwise. }
		function SourceUserName: string;
		{ Returns HostName from Source if Source is a Client, full source string otherwise. }
		function SourceHostName: string;

		{ Returns IRC Command or Numeric that was parsed from RAW }
		function Command: string;

		{ Array of parsed Parameters. This excludes trailing Parameters. }
		property Param[aIndex: integer]: string read GetParam;
		{ Number of parsed Parameters. }
		property ParamCount: integer read FParamCount;
		{ Returns all Parameters as a single string }
		function Params: string;
		{ Returns parameters from and including token at aIndex. }
		function ParamsFrom(const aIndex: integer): string;

		{ Array of parsed trailing Parameters. }
		property Trailing[aIndex: integer]: string read GetTrailing;
		{ Number of parsed trailing Parameters. }
		property TrailingCount: integer read FTrailingCount;
		{ Returns all trailing Parameters as a single string }
		function Trailings: string;
		{ Returns trailing parameters from and including token at aIndex. }
		function TrailingsFrom(const aIndex: integer): string;

		{ Returns params and trailing as single string. No COlon is included between them. }
		function AllParams: string;
	end;

	{ TIRCClient }
	TIRCClient = class(TCustomAsyncTCPClient)
	private
		FNickname: string;
		FRealname: string;
		FUsername: string;
		FUsermode: string;
		FPassword: string;
		FBuffer  : TBuffer;
		FParser  : TIRCCmdParser;
		FOnRaw   : TOnRaw;
	protected
		procedure EventConnect; override;
		procedure EventDisconnect; override;
		procedure EventDataAvailable(const aSize: integer); override;

		procedure HandleCommand(const aCmd: string);
	public
		constructor Create(aOwner: TComponent); override;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;
	published
		property AddressFamily;
		property BindHost;
		property BindPort;
		property ConnectTimeout;
		property ProxyChain;
		property RemoteHost;
		property RemotePort;
		property SocketState;
		property SSL;

		property OnResolving;
		property OnResolved;
		property OnConnecting;
		property OnProxyConnecting;
		property OnProxyConnected;
		property OnProxyChainConnected;
		property OnConnectTimeout;
		property OnConnected;
		property OnDataAvailable;
		property OnDisconnected;
		property OnError;
		property OnLog;

		property Nickname: string read FNickname write FNickname; // Nickname
		property Username: string read FUsername write FUsername; // Username/IDENT
		property Realname: string read FRealname write FRealname; // Realname/GECKOS
		property Usermode: string read FUsermode write FUsermode; // Usermode string e.g.: +ix
		property Password: string read FPassword write FPassword; // Server password

		property OnRaw: TOnRaw read FOnRaw write FOnRaw;
	end;

implementation

{ TIRCCmdParser }

constructor TIRCCmdParser.Create;
begin
	Clear;
end;

destructor TIRCCmdParser.Destroy;
begin
	Clear;
	inherited;
end;

procedure TIRCCmdParser.AddParam(const aStart, aLength: integer);
begin
	Inc(FParamCount);
	SetLength(FParamsArray, FParamCount);
	FParamsArray[FParamCount - 1].Start  := aStart;
	FParamsArray[FParamCount - 1].Length := aLength;
end;

procedure TIRCCmdParser.AddTrailing(const aStart, aLength: integer);
begin
	Inc(FTrailingCount);
	SetLength(FTrailingsArray, FTrailingCount);
	FTrailingsArray[FTrailingCount - 1].Start  := aStart;
	FTrailingsArray[FTrailingCount - 1].Length := aLength;
end;

procedure TIRCCmdParser.Clear;
begin
	FRaw := CEmpty;

	FSourceType    := stNotPresent;
	FSource.Start  := 0;
	FSource.Length := 0;

	FSourceNickName.Start  := 0;
	FSourceNickName.Length := 0;
	FSourceUserName.Start  := 0;
	FSourceUserName.Length := 0;
	FSourceHostName.Start  := 0;
	FSourceHostName.Length := 0;

	FCommand.Start  := 0;
	FCommand.Length := 0;

	FParams.Start  := 0;
	FParams.Length := 0;
	SetLength(FParamsArray, 0);
	FParamCount := 0;

	FTrailings.Start  := 0;
	FTrailings.Length := 0;
	SetLength(FTrailingsArray, 0);
	FTrailingCount := 0;
end;

function TIRCCmdParser.Parse(const aRaw: string): boolean;
var
	a: integer; // Copy start/Last Copy end position.
	B: integer; // Parse cursor.
	t: integer; // Temp cursor.
	l: integer; // Length of input string.

	function DoTrim: boolean;
	begin
		Result := False;
		while (B <= l) do
		begin
			if (B > l) then
				Exit(False);
			if (FRaw[B] <= CSpace) then
				Inc(B)
			else
			begin
				a := B;
				Exit(True);
			end;
		end;
	end;

	function FindSpace: boolean;
	begin
		B      := TextPos(FRaw, CSpace, True, B);
		Result := (B <> 0);
	end;

begin
	// <message> ::=
	//
	// [':' <prefix> <SPACE> ] <command> <Trailing> <crlf>
	//
	// <prefix> ::=
	// <servername> | <nick> [ '!' <user> ] [ '@' <host> ]
	//
	// <command> ::=
	// <letter> { <letter> } | <number> <number> <number>
	//
	// <SPACE> ::=
	// ' ' { ' ' }
	//
	// <Trailing> ::=
	// <SPACE> [ ':' <Trailings> | <middle> <Trailing> ]
	//
	// <middle> ::=
	// <Any *non-empty* sequence of octets not including SPACE or NUL or CR or LF, the first of which may not be ':'>
	//
	// <Trailings> ::=
	// <Any, possibly *empty*, sequence of octets not including NUL or CR or LF>
	//
	// <crlf> ::=
	// CR LF

	{ Check and initialize }
	Result := False;
	l      := Length(aRaw);
	if (l = 0) then
		Exit;

	Clear;
	FRaw := aRaw;
	a    := 1;
	B    := 1;

	if (DoTrim = False) then
		Exit;

	{ Optional Message Source Prefix. }
	if (FRaw[B] = CColon) then
	begin
		if (FindSpace = False) then
			Exit;

		Inc(a);
		FSource.Start  := a;
		FSource.Length := (B - a);

		{ If msg source is an user, split it to <nick>!<user>@<host>. }
		t := TextPos(FRaw, CExclam, True, a);
		if (t > 0) and (t < B) then
		begin
			FSourceNickName.Start  := a;
			FSourceNickName.Length := (t - a);

			a := t;
			Inc(a);
			t := TextPos(FRaw, CMonkey, True, a);
			if (t > 0) and (t < B) then
			begin
				FSourceUserName.Start  := a;
				FSourceUserName.Length := (t - a);

				a := t;
				Inc(a);
				t := TextPos(FRaw, CSpace, True, a);
				if (t = B) then
				begin
					FSourceHostName.Start  := a;
					FSourceHostName.Length := (t - a);

					FSourceType := stUser;
				end;
			end;
		end
		else
			FSourceType := stServer;

		a := B;

		{ Trim }
		if (DoTrim = False) then
			Exit;
	end;

	{ Parse out command }
	if (FindSpace) then
	begin
		FCommand.Start  := a;
		FCommand.Length := (B - a);

		a := B;
		{ If no params, exit. }
		if (DoTrim = False) then
			Exit(True);
	end
	else
	begin
		{ If no params, exit }
		FCommand.Start  := a;
		FCommand.Length := (l - a);
		Exit(True);
	end;

	{ Parse parameters }

	{ If there are trailing params, parse middle first }
	t := TextPos(FRaw, CColon, True, a);
	if (t <> 0) then
	begin
		FParams.Start  := a;
		FParams.Length := (t - a);
		// Get the pre-Trailings params.
		while (B < t) and (FindSpace) do
		begin
			AddParam(a, B - a);
			Inc(B);
			a := B;
		end;

		// If no space before Trailings colon..
		if (a < t) then
			AddParam(a, t - a);

		// Move cursor to start of Trailings.
		a := t + 1;
		B := a;
	end
	else
	begin
		FParams.Start  := a;
		FParams.Length := (l + 1 - a);
	end;

	if (t <> 0) then
	begin
		FTrailings.Start  := t + 1;
		FTrailings.Length := (l + 1 - a);
	end;

	while (FindSpace) do
	begin
		if (t <> 0) then
			AddTrailing(a, B - a)
		else
			AddParam(a, B - a);
		Inc(B);
		a := B;
	end;

	// Last chunk.
	if (B < l) then
	begin
		if (t <> 0) then
			AddTrailing(a, MaxInt)
		else
			AddParam(a, MaxInt);
	end;

	// Done.
	Result := True;
end;

function TIRCCmdParser.Source: string;
begin
	if (FSource.Length = 0) then
		Result := CEmpty
	else
		Result := TextCopy(FRaw, FSource.Start, FSource.Length);
end;

function TIRCCmdParser.SourceNickName: string;
begin
	if (FSourceNickName.Length = 0) then
		Result := CEmpty
	else
		Result := TextCopy(FRaw, FSourceNickName.Start, FSourceNickName.Length);
end;

function TIRCCmdParser.SourceUserName: string;
begin
	if (FSourceUserName.Length = 0) then
		Result := CEmpty
	else
		Result := TextCopy(FRaw, FSourceUserName.Start, FSourceUserName.Length);
end;

function TIRCCmdParser.SourceHostName: string;
begin
	if (FSourceHostName.Length = 0) then
		Result := CEmpty
	else
		Result := TextCopy(FRaw, FSourceHostName.Start, FSourceHostName.Length);
end;

function TIRCCmdParser.Command: string;
begin
	if (FCommand.Length = 0) then
		Result := CEmpty
	else
		Result := TextCopy(FRaw, FCommand.Start, FCommand.Length);
end;

function TIRCCmdParser.Params: string;
begin
	if (FParams.Length = 0) then
		Result := CEmpty
	else
		Result := Trim(TextCopy(FRaw, FParams.Start, FParams.Length));
end;

function TIRCCmdParser.ParamsFrom(const aIndex: integer): string;
begin
	if (aIndex < 0) or (aIndex >= FParamCount) then
		Result := CEmpty
	else
		Result := TextCopy(FRaw, FParamsArray[aIndex].Start, MaxInt);
end;

function TIRCCmdParser.Trailings: string;
begin
	if (FTrailings.Length = 0) then
		Result := CEmpty
	else
		Result := TextCopy(FRaw, FTrailings.Start, FTrailings.Length);
end;

function TIRCCmdParser.TrailingsFrom(const aIndex: integer): string;
begin
	if (aIndex < 0) or (aIndex >= FTrailingCount) then
		Result := CEmpty
	else
		Result := TextCopy(FRaw, FTrailingsArray[aIndex].Start, MaxInt);
end;

function TIRCCmdParser.AllParams: string;
begin
	if (FParams.Length > 0) then
		Result := Params
	else
		Result := CEmpty;

	if (FParams.Length > 0) then
	begin
		if (FTrailings.Length > 0) then
			Result := Result + CSpace + Trailings;
	end
	else
	begin
		if (FTrailings.Length > 0) then
			Result := Trailings;
	end;
end;

function TIRCCmdParser.GetParam(aIndex: integer): string;
begin
	if (aIndex < 0) or (aIndex >= FParamCount) then
		Result := CEmpty
	else
		Result := TextCopy(FRaw, FParamsArray[aIndex].Start, FParamsArray[aIndex].Length);
end;

function TIRCCmdParser.GetTrailing(aIndex: integer): string;
begin
	if (aIndex < 0) or (aIndex >= FTrailingCount) then
		Result := CEmpty
	else
		Result := TextCopy(FRaw, FTrailingsArray[aIndex].Start, FTrailingsArray[aIndex].Length);
end;

{ TIRCClient }

constructor TIRCClient.Create(aOwner: TComponent);
begin
	inherited;
	FParser := TIRCCmdParser.Create;
end;

destructor TIRCClient.Destroy;
begin
	FParser.Free;
	inherited;
end;

procedure TIRCClient.Assign(aSource: TPersistent);
begin
	inherited;

end;

procedure TIRCClient.EventConnect;
begin
	inherited;
	FBuffer.Clear;
	FParser.Clear;

    // Login
	if (FPassword <> CEmpty) then
		SendLine(CPASS + CSpace + FPassword);
	SendLine(CNICK + CSpace + FNickname);
	SendLine(CUSER + CSpace + FUsername + CSpace + FUsermode + CSpace + CAsterisk + CSpace + CColon + FRealname);
end;

procedure TIRCClient.EventDataAvailable(const aSize: integer);
var
	buf: pbyte;
	ret: integer;
	str: string;
begin
	// Read to internal buffer.
	buf := GetMemory(aSize);
	try
		ret := Recv(buf, aSize);
		FBuffer.Append(buf, ret);
	finally
		FreeMem(buf);
	end;

    // Pull all CRLF terminated strings from buffer.
	while (True) do
	begin
		str := FBuffer.ConsumeLine;
		if (str = CEmpty) then
			Break;
		HandleCommand(str);
	end;
end;

procedure TIRCClient.EventDisconnect;
begin
	inherited;
	FBuffer.Clear;
	FParser.Clear;
end;

procedure TIRCClient.HandleCommand(const aCmd: string);
var
	block: boolean;
begin
	// Handle parse error.
	if (FParser.Parse(aCmd) = False) then
	begin
		EventLog(Self, Format('Error parsing command: "%s"', [aCmd]));
		Exit;
	end;

    // Pass command to OnRaw event.
    // If block requested, ignore this command.
	block := False;
	if (Assigned(FOnRaw)) then
		FOnRaw(Self, FParser, block);
	if (block) then
		Exit;

    // PING
	if (TextEquals(FParser.Command, CPING)) then
	begin
		if (FParser.TrailingCount > 0) then
			SendLine(CPONG + CSpace + CColon + FParser.Trailings)
		else
			SendLine(CPONG);
	end;

    if (TextEquals(FParser.Command, CPRIVMSG)) then
    begin

    end;
end;

end.
