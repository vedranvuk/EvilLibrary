unit blocksock;

interface

uses
	windows, winsock;

const
	WINSOCK_VERSION = $0202;
	WINSOCK2_DLL    = 'ws2_32.dll';

type
	PADDRINFOA  = ^ADDRINFOA;
	PPADDRINFOA = ^PADDRINFOA;

	ADDRINFOA = record
		ai_flags: integer;
		ai_family: integer;
		ai_socktype: integer;
		ai_protocol: integer;
		ai_addrlen: cardinal; // size_t
		AI_CANONNAME: PAnsiChar;
		ai_addr: PSockAddr;
		ai_next: PADDRINFOA;
	end;

	TAddrInfoA = ADDRINFOA;

	PADDRINFOW  = ^ADDRINFOW;
	PPADDRINFOW = ^PADDRINFOW;

	ADDRINFOW = record
		ai_flags: integer;
		ai_family: integer;
		ai_socktype: integer;
		ai_protocol: integer;
		ai_addrlen: cardinal; // size_t
		AI_CANONNAME: PWideChar;
		ai_addr: PSockAddr;
		ai_next: PADDRINFOW;
	end;

	TAddrInfoW = ADDRINFOW;

{$IFDEF UNICODE}
	addrinfo   = ADDRINFOW;
	TAddrInfo  = TAddrInfoW;
	PAddrInfo  = PADDRINFOW;
	PPAddrInfo = PPADDRINFOW;
{$ELSE}
	addrinfo   = ADDRINFOA;
	TAddrInfo  = TAddrInfoA;
	PAddrInfo  = PADDRINFOA;
	PPAddrInfo = PPADDRINFOA;
{$ENDIF}

function GetAddrInfo(const nodename, servname: PChar; const hints: PAddrInfo; res: PPAddrInfo): integer;
  stdcall; external WINSOCK2_DLL name 'GetAddrInfoW';
procedure FreeAddrInfo(ai: PAddrInfo); stdcall; external WINSOCK2_DLL name 'FreeAddrInfoW';

function GetAddrPool(
  const aHost, aPort: string;
  var aAddrInfo: PAddrInfo;
  const aAf: integer = AF_INET;
  const aSockType: integer = SOCK_STREAM;
  const aProtocol: integer = IPPROTO_TCP;
  const aFlags: integer = 0
  ): integer;
procedure FreeAddrPool(var aAddrInfo: PAddrInfo);

implementation

function GetSockError(const aError: integer = SOCKET_ERROR): string;
var
	buffer: array [0 .. 255] of Char;
	flags : DWORD;
begin
	FillChar(buffer, 256, #0);
	flags := FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_IGNORE_INSERTS or FORMAT_MESSAGE_ARGUMENT_ARRAY;
	FormatMessage(flags, nil, aError, 0, buffer, SizeOf(buffer), nil);
	Result := buffer;
	while (Result[Length(Result)] in [#13, #10]) do
		Delete(Result, Length(Result), 1);
end;

function GetAddrPool(
  const aHost, aPort: string; var aAddrInfo: PAddrInfo; const aAf: integer;
  const aSockType: integer; const aProtocol: integer; const aFlags: integer
  ): integer;
var
	hints: TAddrInfo;
begin
	ZeroMemory(@hints, SizeOf(hints));
	hints.ai_family   := aAf;
	hints.ai_socktype := aSockType;
	hints.ai_protocol := aProtocol;
	hints.ai_flags    := aFlags;

	Result := GetAddrInfo(PChar(aHost), PChar(aPort), @hints, @aAddrInfo);
end;

{ Frees PAddrInfo. }
procedure FreeAddrPool(var aAddrInfo: PAddrInfo);
begin
	if (aAddrInfo = nil) then
		Exit;
	FreeAddrInfo(aAddrInfo);
	aAddrInfo := nil;
end;

function CreateTcpSock(const aAf: integer): TSocket;
begin
	Result := socket(aAf, SOCK_STREAM, IPPROTO_TCP);
end;

function ConnectTCPSock(const aSock: TSocket; const aAddrPool: PAddrInfo): Boolean;
var
	curr: PAddrInfo;
begin
	Result := True;

	curr := aAddrPool;
	while (curr <> nil) do
	begin
		if (connect(aSock, curr^.ai_addr^, curr^.ai_addrlen) <> 0) then
			curr := curr^.ai_next
		else
			Break;

		if (curr = nil) then
			Exit(False);
	end;
end;

function MakeTcpConnection(const aHost, aPort: string; const aAf: integer): TSocket;
label Error;
var
	addr: PAddrInfo;
begin
	Result := CreateTcpSock(aAf);
	if (Result = INVALID_SOCKET) then
		Exit;

	if (GetAddrPool(aHost, aPort, addr, aAf) <> 0) then
		goto Error;

	if (ConnectTCPSock(Result, addr) = False) then
		goto Error;

	Exit;

Error:
	FreeAddrPool(addr);
	closesocket(Result);
end;

function MakeTcpConnectionSocks5(const aHost, aPort, aProxyHost, aProxyPort, aProxyUser, aProxyPass: string; const aAf: TAddressFamily): TSocket;
begin
	Result := MakeTcpConnection(aProxyHost, aProxyPort, aAf);
	if (Result = INVALID_SOCKET) then
		Exit;

	if (NegotiateSocks5(Result, aHost, aPort, aProxyUser, aProxyPass) = SOCKET_ERROR) then
	begin
		DeleteSock(Result);
		Result := INVALID_SOCKET;
	end;
end;

var
	wsadata: TWSAData;

initialization

WSAStartup($0202, wsadata);

finalization

WSACleanup;

end.
