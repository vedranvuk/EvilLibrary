//
// EvilLibrary by Vedran Vuk 2010-2012
//
// Name: 					EvilWorks.Web.ThreadSockets
// Description: 			Sockets designed for ease of use.
// File last change date:   November 29th. 2012
// File version: 			Dev 0.0.0
// Licence:                 Free.
//

unit EvilWorks.Web.ThreadSockets;

interface

uses
	Winapi.Windows,
	Winapi.Winsock,
	System.Classes,
	System.SysUtils,
	EvilWorks.Api.Winsock2,
	EvilWorks.Api.OpenSSL;

type
	{ Forward declarations }
	ITcpSocket = interface;
	ITcpClient = interface;
	ITcpServer = interface;

	{ Exceptions }
	ESocket = class(Exception);

    { Events }
	TOnSocketStateChange = reference to procedure(const aSocket: ITcpSocket);
	TOnSocketAccept      = reference to procedure(const aServer: ITcpServer; const aNewClient: ITcpSocket);
	TOnSocketLog         = reference to procedure(const aSocket: ITcpSocket; const aText: string);

    { TSocketState }
	TSocketState = (
	  ssDisconnected, // Socket is disconnected and uninitialized.
	  ssConnected,    // Socket is connected and ready for read/write operations.
	  ssListening,    // Socket is listening for incomming TCP connections.
	  ssLoaded        // For Async socket modes. Sent when there is data to be read from socket.
	  );

    { TSocketAF }
	TSocketAF = (
	  safUnspec = AF_UNSPEC,
	  safIPv4 = AF_INET,
	  safIPv6 = AF_INET6
	  );

    { ITcpSocket }
    { An interface returned by ITcpServer in OnSocketAccept when a new connection is accepted. }
    { Basic socket interface providing read, write and close functions for a connected socket. }
	ITcpSocket = interface
		['{10B05372-D64E-42D9-BBF4-19E2E3629121}']
		function Pending: integer;
		function SendBuf(const aBuf; const aSize: integer): integer;
		function RecvBuf(out aBuf; const aSize: integer): integer;
		procedure SendLine(const aText: rawbytestring);
		function RecvLine(
		  const aTerminator: rawbytestring = #13#10; const aMaxSize: integer = 8192
		  ): rawbytestring;
		procedure Close;

		function State: TSocketState;
		function Connected: boolean;
	end;

	{ ITcpClient }
    { An interface returned by CreateTcpClient(). }
    { Provides functions to establish a TCP connection then send and receive data over it. }
	ITcpClient = interface
		['{63075918-EFB4-40C6-AFA2-E253354A33E1}']
{$REGION 'PropertyAccessors'}
		function GetBindHost: string;
		function GetBindPort: string;
		function GetProxyHost: string;
		function GetProxyPass: string;
		function GetProxyPort: string;
		function GetProxyType: TProxyType;
		function GetProxyUser: string;
		function GetRemoteHost: string;
		function GetRemotePort: string;
		function GetSSLCertificateFile: string;
		function GetSSLClientAuthorityFile: string;
		function GetSSLEnabled: boolean;
		function GetSSLPassword: string;
		function GetSSLVerifyPeer: boolean;
		function GetSSLPrivateKeyFile: string;
		procedure SetBindHost(const Value: string);
		procedure SetBindPort(const Value: string);
		procedure SetProxyHost(const Value: string);
		procedure SetProxyPass(const Value: string);
		procedure SetProxyPort(const Value: string);
		procedure SetProxyType(const Value: TProxyType);
		procedure SetProxyUser(const Value: string);
		procedure SetRemoteHost(const Value: string);
		procedure SetRemotePort(const Value: string);
		procedure SetSSLCertificateFile(const Value: string);
		procedure SetSSLClientAuthorityFile(const Value: string);
		procedure SetSSLEnabled(const Value: boolean);
		procedure SetSSLPassword(const Value: string);
		procedure SetSSLVerifyPeer(const Value: boolean);
		procedure SetSSLPrivateKeyFile(const Value: string);
{$ENDREGION}
		property BindHost: string read GetBindHost write SetBindHost;
		property BindPort: string read GetBindPort write SetBindPort;
		property RemoteHost: string read GetRemoteHost write SetRemoteHost;
		property RemotePort: string read GetRemotePort write SetRemotePort;
		property ProxyType: TProxyType read GetProxyType write SetProxyType;
		property ProxyHost: string read GetProxyHost write SetProxyHost;
		property ProxyPort: string read GetProxyPort write SetProxyPort;
		property ProxyUser: string read GetProxyUser write SetProxyUser;
		property ProxyPass: string read GetProxyPass write SetProxyPass;
		property SSLEnabled: boolean read GetSSLEnabled write SetSSLEnabled;
		property SSLVerifyPeer: boolean read GetSSLVerifyPeer write SetSSLVerifyPeer;
		property SSLPassword: string read GetSSLPassword write SetSSLPassword;
		property SSLCertificateFile: string read GetSSLCertificateFile write SetSSLCertificateFile;
		property SSLPrivateKeyFile: string read GetSSLPrivateKeyFile write SetSSLPrivateKeyFile;
		property SSLClientAuthorityFile: string read GetSSLClientAuthorityFile write SetSSLClientAuthorityFile;

		procedure Connect(
		  const aRemoteHost, aRemotePort: string;
		  const aSSL: boolean = False; const aSSLVerifyPeer: boolean = False;
		  const aProxyType: TProxyType = ptNone;
		  const aProxyHost: string = ''; const aProxyPort: string = '';
		  const aProxyUser: string = ''; const aProxyPass: string = '';
		  const aSSLPassword: string = ''; const aSSLCertificatefile: string = '';
		  const aSSLPrivateKeyFile: string = ''; const aSSLClientAuthorityFile: string = '';
		  const aBindHost: string = ''; const aBindPort: string = ''
		  ); overload;
		procedure Connect; overload;
		procedure Close;

		function Pending: integer;
		function SendBuf(const aBuf; const aSize: integer): integer;
		function RecvBuf(out aBuf; const aSize: integer): integer;
		procedure SendLine(const aText: rawbytestring);
		function RecvLine(
		  const aTerminator: rawbytestring = #13#10; const aMaxSize: integer = 8192
		  ): rawbytestring;

		function State: TSocketState;
		function Connected: boolean;
	end;

    { ITcpServer }
    { An interface returned by CreateTcpServer(). }
    { Provides functions to create a TCP listener to accept incomming TCP connections. }
	ITcpServer = interface
		['{F001ACA8-6018-4A42-8542-312182D7A10B}']
{$REGION 'PropertyAccessors'}
		function GetBindHost: string;
		function GetBindPort: string;
		function GetSSLCertificateFile: string;
		function GetSSLClientAuthorityFile: string;
		function GetSSLEnabled: boolean;
		function GetSSLPassword: string;
		function GetSSLVerifyPeer: boolean;
		function GetSSLPrivateKeyFile: string;
		procedure SetBindHost(const Value: string);
		procedure SetBindPort(const Value: string);
		procedure SetSSLCertificateFile(const Value: string);
		procedure SetSSLClientAuthorityFile(const Value: string);
		procedure SetSSLEnabled(const Value: boolean);
		procedure SetSSLPassword(const Value: string);
		procedure SetSSLVerifyPeer(const Value: boolean);
		procedure SetSSLPrivateKeyFile(const Value: string);
{$ENDREGION}
		property BindHost: string read GetBindHost write SetBindHost;
		property BindPort: string read GetBindPort write SetBindPort;
		property SSLEnabled: boolean read GetSSLEnabled write SetSSLEnabled;
		property SSLVerifyPeer: boolean read GetSSLVerifyPeer write SetSSLVerifyPeer;
		property SSLPassword: string read GetSSLPassword write SetSSLPassword;
		property SSLCertificateFile: string read GetSSLCertificateFile write SetSSLCertificateFile;
		property SSLPrivateKeyFile: string read GetSSLPrivateKeyFile write SetSSLPrivateKeyFile;
		property SSLClientAuthorityFile: string read GetSSLClientAuthorityFile write SetSSLClientAuthorityFile;

		procedure Listen(
		  const aBindHost, aBindPort: string;
		  const aSSL: boolean = False; const aSSLVerifyPeer: boolean = False;
		  const aSSLPassword: string = ''; const aSSLCertificateFile: string = '';
		  const aSSLPrivateKeyFile: string = ''; const aSSLClientAuthorityFile: string = ''
		  ); overload;
		procedure Listen; overload;
		procedure Close;

		function State: TSocketState;
	end;

{ Create a new ITcpClient instance to establish a TCP connection to a remote peer. }
function CreateTcpClient(
  const aOnStateChange: TOnSocketStateChange;  // Method to receive socket state change notifications.
  const aAsync: boolean = False;               // Create in Asynchronous mode.
  const aAddressFamily: TSocketAF = safUnspec; // Socket address family (AF_UNSPEC, AF_INET or AF_INET6);
  const aOnLog: TOnSocketLog = nil             // Optional method to receive debug log messages.
  ): ITcpClient;

{ Create a new ITcpServer instance to lissten and accept incomming Tcp connections. }
{ ITcpSocket instances returned in OnAccept inherit properties specified in this constructor. }
function CreateTcpServer(
  const aOnStateChange: TOnSocketStateChange;  // Method to receive socket state change notifications.
  const aOnAccept: TOnSocketAccept;            // Method to accept notifications of new accepted connections.
  const aAsync: boolean = False;               // Create in Asynchronous mode.
  const aAddressFamily: TSocketAF = safUnspec; // Socket address family (AF_UNSPEC, AF_INET or AF_INET6);
  const aOnLog: TOnSocketLog = nil             // Optional method to receive debug log messages.
  ): ITcpServer;

implementation

type
    { TTcpSocket }
	TTcpSocket = class(TInterfacedObject, ITcpSocket)
	private type
		TErrorType = (etLocal, etWinsock, etSSL);

		TCheckForDataThread = class(TThread)
		private
			FSocket: TTcpSocket;
		protected
			procedure Execute; override;
		public
			constructor Create(const aSocket: TTcpSocket);
		end;

	private
		FCritSect     : TRTLCriticalSection;
		FAsync        : boolean;
		FState        : TSocketState;
		FAddressFamily: integer;
		FSocket       : TSocket;
		FSSL          : PSSL;
		FSSLCTX       : PSSL_CTX;
		FCheckForData : TCheckForDataThread;

		FOnStateChange: TOnSocketStateChange;
		FOnAccept     : TOnSocketAccept;
		FOnLog        : TOnSocketLog;

		FBindHost              : string;
		FBindPort              : string;
		FRemoteHost            : string;
		FRemotePort            : string;
		FProxyType             : TProxyType;
		FProxyHost             : string;
		FProxyPort             : string;
		FProxyUser             : string;
		FProxyPass             : string;
		FSSLEnabled            : boolean;
		FSSLVerifyPeer         : boolean;
		FSSLPassword           : string;
		FSSLCertificateFile    : string;
		FSSLPrivateKeyFile     : string;
		FSSLClientAuthorityFile: string;

		constructor CreateFromSocket(
		  const aSocket: TSocket;
		  const aAsync: boolean; const aOnStateChange: TOnSocketStateChange; const aOnLog: TOnSocketLog;
		  const aSSL: boolean; const aSSLVerifyPeer: boolean;
		  const aSSLPassword: string = ''; const aSSLCertificatefile: string = '';
		  const aSSLPrivateKeyFile: string = ''; const aSSLClientAuthorityFile: string = ''
		  );

		procedure Lock;
		procedure Unlock;

		procedure SetSocketState(const aState: TSocketState);
		procedure RunCheckThread;
		procedure DoDataAvailable;
		function ResolveAddress(const aHost, aPort: string; const aAf: integer = AF_UNSPEC; const aPassive: boolean = False): PAddrInfo;
		procedure FreeAddrPool(var aAddrPool: PAddrInfo);
		procedure InternalConnect;
		procedure ConnectSSL(
		  const aVerifyPeer: boolean;
		  const aSSLPassword, aSSLCertificateFile, aSSLPrivateKeyFile, aSSLClientAuthorityFile: string;
		  const aAccept: boolean = False
		  );

		function GetWinsockError(const aErr: integer): string;
		function GetSSLError(const aErr: integer): string;
		procedure ThrowError(const aMessage: string; const aErrVal: integer = 0; aType: TErrorType = etLocal);
		procedure Log(const aText: string);
		procedure Cleanup; virtual;

		class function SSLPasswordCallback(
		  aBuf: pansichar; aSize, aRWFlag: integer; aSocket: TTcpSocket
		  ): integer; static; cdecl;

		function GetBindHost: string;
		function GetBindPort: string;
		function GetProxyHost: string;
		function GetProxyPass: string;
		function GetProxyPort: string;
		function GetProxyType: TProxyType;
		function GetProxyUser: string;
		function GetRemoteHost: string;
		function GetRemotePort: string;
		function GetSSLCertificateFile: string;
		function GetSSLClientAuthorityFile: string;
		function GetSSLEnabled: boolean;
		function GetSSLPassword: string;
		function GetSSLVerifyPeer: boolean;
		function GetSSLPrivateKeyFile: string;
		procedure SetBindHost(const Value: string);
		procedure SetBindPort(const Value: string);
		procedure SetProxyHost(const Value: string);
		procedure SetProxyPass(const Value: string);
		procedure SetProxyPort(const Value: string);
		procedure SetProxyType(const Value: TProxyType);
		procedure SetProxyUser(const Value: string);
		procedure SetRemoteHost(const Value: string);
		procedure SetRemotePort(const Value: string);
		procedure SetSSLCertificateFile(const Value: string);
		procedure SetSSLClientAuthorityFile(const Value: string);
		procedure SetSSLEnabled(const Value: boolean);
		procedure SetSSLPassword(const Value: string);
		procedure SetSSLVerifyPeer(const Value: boolean);
		procedure SetSSLPrivateKeyFile(const Value: string);
	protected
		function State: TSocketState;
		function Connected: boolean;

		procedure Connect(
		  const aRemoteHost, aRemotePort: string;
		  const aSSL: boolean = False; const aSSLVerifyPeer: boolean = False;
		  const aProxyType: TProxyType = ptNone;
		  const aProxyHost: string = ''; const aProxyPort: string = '';
		  const aProxyUser: string = ''; const aProxyPass: string = '';
		  const aSSLPassword: string = ''; const aSSLCertificatefile: string = '';
		  const aSSLPrivateKeyFile: string = ''; const aSSLClientAuthorityFile: string = '';
		  const aBindHost: string = ''; const aBindPort: string = ''
		  ); overload;
		procedure Connect; overload;

		procedure Listen(
		  const aBindHost, aBindPort: string;
		  const aSSL: boolean = False; const aSSLVerifyPeer: boolean = False;
		  const aSSLPassword: string = ''; const aSSLCertificateFile: string = '';
		  const aSSLPrivateKeyFile: string = ''; const aSSLClientAuthorityFile: string = ''
		  ); overload;
		procedure Listen; overload;

		procedure Close;

		function Pending: integer;
		function SendBuf(const aBuf; const aSize: integer): integer;
		function RecvBuf(out aBuf; const aSize: integer): integer;
		procedure SendLine(const aText: rawbytestring);
		function RecvLine(
		  const aTerminator: rawbytestring = #13#10; const aMaxSize: integer = 8192
		  ): rawbytestring;

		property BindHost: string read GetBindHost write SetBindHost;
		property BindPort: string read GetBindPort write SetBindPort;
		property RemoteHost: string read GetRemoteHost write SetRemoteHost;
		property RemotePort: string read GetRemotePort write SetRemotePort;
		property ProxyType: TProxyType read GetProxyType write SetProxyType;
		property ProxyHost: string read GetProxyHost write SetProxyHost;
		property ProxyPort: string read GetProxyPort write SetProxyPort;
		property ProxyUser: string read GetProxyUser write SetProxyUser;
		property ProxyPass: string read GetProxyPass write SetProxyPass;
		property SSLEnabled: boolean read GetSSLEnabled write SetSSLEnabled;
		property SSLVerifyPeer: boolean read GetSSLVerifyPeer write SetSSLVerifyPeer;
		property SSLPassword: string read GetSSLPassword write SetSSLPassword;
		property SSLCertificateFile: string read GetSSLCertificateFile write SetSSLCertificateFile;
		property SSLPrivateKeyFile: string read GetSSLPrivateKeyFile write SetSSLPrivateKeyFile;
		property SSLClientAuthorityFile: string read GetSSLClientAuthorityFile write SetSSLClientAuthorityFile;
	public
		constructor Create(const aOnStateChange: TOnSocketStateChange; const aAsync: boolean = False;
		  const aAddressFamily: TSocketAF = safUnspec; const aOnLog: TOnSocketLog = nil
		  );

		destructor Destroy; override;
	end;

    { TTcpClient }
	TTcpClient = class(TTcpSocket, ITcpClient)
	public
		constructor CreateClient(const aOnStateChange: TOnSocketStateChange; const aAsync: boolean = False;
		  const aAddressFamily: TSocketAF = safUnspec; const aOnLog: TOnSocketLog = nil
		  );
	end;

    { TTcpServer }
	TTcpServer = class(TTcpSocket, ITcpServer)
		constructor CreateServer(const aOnStateChange: TOnSocketStateChange; const aOnAccept: TOnSocketAccept;
		  const aAsync: boolean = False; const aAddressFamily: TSocketAF = safUnspec;
		  const aOnLog: TOnSocketLog = nil
		  );
	end;

function CreateTcpClient(
  const aOnStateChange: TOnSocketStateChange;
  const aAsync: boolean = False;
  const aAddressFamily: TSocketAF = safUnspec;
  const aOnLog: TOnSocketLog = nil
  ): ITcpClient;
begin
	Result := TTcpClient.CreateClient(aOnStateChange, aAsync, aAddressFamily, aOnLog);
end;

function CreateTcpServer(
  const aOnStateChange: TOnSocketStateChange;
  const aOnAccept: TOnSocketAccept;
  const aAsync: boolean = False;
  const aAddressFamily: TSocketAF = safUnspec;
  const aOnLog: TOnSocketLog = nil
  ): ITcpServer;
begin
	Result := TTcpServer.CreateServer(aOnStateChange, aOnAccept, aAsync, aAddressFamily, aOnLog);
end;

{ TTcpSocket.TCheckForDataThread }

constructor TTcpSocket.TCheckForDataThread.Create(const aSocket: TTcpSocket);
begin
	inherited Create(True);
	FreeOnTerminate := True;
	FSocket         := aSocket;
	ResumeThread(Handle);
end;

procedure TTcpSocket.TCheckForDataThread.Execute;
begin
	while (Terminated = False) do
	begin
		if (FSocket.Pending > 0) then
			Break
		else
			Sleep(1);
	end;
	FSocket.FCheckForData := nil;
	Synchronize(Self, FSocket.DoDataAvailable);
end;

{ TTcpSocket }

constructor TTcpSocket.Create(const aOnStateChange: TOnSocketStateChange; const aAsync: boolean;
  const aAddressFamily: TSocketAF; const aOnLog: TOnSocketLog);
begin
	InitializeCriticalSection(FCritSect);

	FSocket := INVALID_SOCKET;
	FSSL    := nil;
	FSSLCTX := nil;

	FState := ssDisconnected;

	FOnStateChange := aOnStateChange;
	FAsync         := aAsync;
	FAddressFamily := integer(aAddressFamily);
	FOnLog         := aOnLog;
end;

{ Creates a new TTcpSocket instance from a socket with an established connection. For TTcpListener. }
constructor TTcpSocket.CreateFromSocket(const aSocket: TSocket; const aAsync: boolean;
  const aOnStateChange: TOnSocketStateChange; const aOnLog: TOnSocketLog; const aSSL, aSSLVerifyPeer: boolean;
  const aSSLPassword, aSSLCertificatefile, aSSLPrivateKeyFile, aSSLClientAuthorityFile: string);
begin
	Create(aOnStateChange, aAsync, safUnspec, aOnLog);
	FSocket := aSocket;
end;

destructor TTcpSocket.Destroy;
begin
	Close;
	DeleteCriticalSection(FCritSect);
	inherited;
end;

procedure TTcpSocket.DoDataAvailable;
begin
	SetSocketState(ssLoaded);
end;

procedure TTcpSocket.Lock;
begin
	EnterCriticalSection(FCritSect);
end;

procedure TTcpSocket.Unlock;
begin
	LeaveCriticalSection(FCritSect);
end;

procedure TTcpSocket.SetSocketState(const aState: TSocketState);
begin
	if (aState = ssConnected) and (FState <> ssConnected) then
		RunCheckThread;

	FState := aState;

	if (Assigned(FOnStateChange)) then
	begin
		if (FAsync) then
			TThread.Synchronize(nil, procedure
				begin
					FOnStateChange(Self);
				end
			  )
		else
			FOnStateChange(Self);
	end;
end;

function TTcpSocket.ResolveAddress(
  const aHost, aPort: string; const aAf: integer; const aPassive: boolean): PAddrInfo;
var
	hints: TAddrInfo;
	ret  : integer;
begin
	FillChar(hints, SizeOf(hints), 0);
	hints.ai_family   := aAf;
	hints.ai_protocol := IPPROTO_TCP;
	hints.ai_socktype := SOCK_STREAM;
	if (aPassive) then
		hints.ai_flags := AI_PASSIVE;

	ret := GetAddrInfo(PChar(aHost), PChar(aPort), @hints, @Result);
	if (ret <> 0) then
		ThrowError(Format('Error resolving address "%s:%s"', [aHost, aPort]), ret, etWinsock);
end;

procedure TTcpSocket.RunCheckThread;
begin
	if (FCheckForData <> nil) then
		FCheckForData.Free;

	FCheckForData := TCheckForDataThread.Create(Self);
end;

procedure TTcpSocket.FreeAddrPool(var aAddrPool: PAddrInfo);
begin
	if (aAddrPool <> nil) then
	begin
		FreeAddrInfo(aAddrPool);
		aAddrPool := nil;
	end;
end;

procedure TTcpSocket.InternalConnect;
var
	bindaddr  : PAddrInfo;
	remoteaddr: PAddrInfo;
	serv      : PServEnt;
	ret       : integer;
	curr      : PAddrInfo;
	t         : timeval;
begin

	Lock;
	try
		if (FBindHost <> '') then
		begin
			Log(Format('Resolving bind address "%s:%s"...', [FBindHost, FBindPort]));
			bindaddr       := ResolveAddress(FBindHost, FBindPort, FAddressFamily, True);
			FAddressFamily := bindaddr^.ai_family;
		end
		else
			bindaddr := nil;

		if (FProxyType <> ptNone) then
		begin
			Log(Format('Resolving proxy address "%s:%s"...', [FProxyHost, FProxyPort]));
			remoteaddr := ResolveAddress(FProxyHost, FProxyPort, FAddressFamily)
		end
		else
		begin
			Log(Format('Resolving remote address "%s:%s"...', [FRemoteHost, FRemotePort]));
			remoteaddr := ResolveAddress(FRemoteHost, FRemotePort, FAddressFamily);
		end;

		curr := remoteaddr;
		Log('Connecting...');
		while (curr <> nil) do
		begin
			FSocket := EvilWorks.Api.Winsock2.socket(curr^.ai_family, SOCK_STREAM, IPPROTO_TCP);
			if (FSocket = INVALID_SOCKET) then
				ThrowError('Error creating socket', WSAGetLastError, etWinsock);

			if (bindaddr <> nil) then
				if (EvilWorks.Api.Winsock2.bind(FSocket, bindaddr^.ai_addr, bindaddr^.ai_addrlen) <> 0) then
					ThrowError('Error binding socket', WSAGetLastError, etWinsock);

			if (EvilWorks.Api.Winsock2.connect(FSocket, curr^.ai_addr, curr^.ai_addrlen) <> 0) then
			begin
				Log(Format('Error connecting to address in pool: "%s", trying next one...', [GetWinsockError(WSAGetLastError)]));
				EvilWorks.Api.Winsock2.closesocket(FSocket);
				FSocket := INVALID_SOCKET;
			end
			else
				Break;
			curr := curr^.ai_next;
		end;

		if (FSocket = INVALID_SOCKET) then
			ThrowError('Error connecting.');

		t.tv_sec  := 1000;
		t.tv_usec := 0;
		setsockopt(FSocket, SOL_SOCKET, SO_RCVTIMEO, @t, SizeOf(t));

		if (FSSLEnabled) then
			ConnectSSL(
			  FSSLVerifyPeer, FSSLPassword, FSSLCertificateFile, FSSLPrivateKeyFile, FSSLClientAuthorityFile
			  )
		else
			SetSocketState(ssConnected);
	finally
		FreeAddrPool(bindaddr);
		FreeAddrPool(remoteaddr);
		Unlock;
	end;
end;

procedure TTcpSocket.ConnectSSL(const aVerifyPeer: boolean;
const aSSLPassword, aSSLCertificateFile, aSSLPrivateKeyFile, aSSLClientAuthorityFile: string;
const aAccept: boolean);
var
	ret: integer;
	crt: PX509;
	buf: pansichar;
	str: string;
	cip: PSSL_CIPHER;
begin
	FSSLCTX := SSL_CTX_new(TLSv1_method);

    // In case of renegotiation on a blocking socket, SSL_read/SSL_write will return only
    // once it's complete instead of -1 with SSL_WANT_READ/SSL_WANT_WRITE in description.
	SSL_CTX_ctrl(FSSLCTX, SSL_CTRL_MODE, SSL_MODE_AUTO_RETRY, nil);

	ret := SSL_CTX_set_cipher_list(FSSLCTX, 'DEFAULT');
	if (ret <> 1) then
		ThrowError('Error setting cipher list', ret, etSSL);

//	SSL_CTX_set_default_passwd_cb_userdata(FSSLCtx, Self);
	SSL_CTX_set_default_passwd_cb(FSSLCtx, @SSLPasswordCallback);

	if (aSSLCertificateFile <> '') then
		if (SSL_CTX_use_certificate_chain_file(FSSLCTX, PAnsiChar(ansistring(aSSLCertificateFile))) <> 1) then
			if (SSL_CTX_use_certificate_file(FSSLCTX, PAnsiChar(ansistring(aSSLCertificateFile)), SSL_FILETYPE_PEM) <> 1) then
				if (SSL_CTX_use_certificate_file(FSSLCTX, PAnsiChar(ansistring(aSSLCertificateFile)), SSL_FILETYPE_ASN1) <> 1) then
					ThrowError('Error loading SSL certificate file.');

	if (aSSLPrivateKeyFile <> '') then
		if (SSL_CTX_use_RSAPrivateKey_file(FSSLCTX, PAnsiChar(ansistring(aSSLPrivateKeyFile)), SSL_FILETYPE_PEM) <> 1) then
			if (SSL_CTX_use_RSAPrivateKey_file(FSSLCTX, pansichar(AnsiString(aSSLPrivateKeyFile)), SSL_FILETYPE_ASN1) <> 1) then
				ThrowError('Error loading SSL private key file.');

	if (aSSLClientAuthorityFile <> '') then
		if (SSL_CTX_load_verify_locations(FSSLCTX, pansichar(ansistring(aSSLClientAuthorityFile)), nil) <> 1) then
			ThrowError('Error loading SSL CA file.');

	FSSL := SSL_new(FSSLCTX);
	SSL_set_fd(FSSL, FSocket);

	if (aAccept) then
		ret := SSL_accept(FSSL)
	else
		ret := SSL_connect(FSSL);
	if (ret <> 1) then
		ThrowError('Error connecting SSL', ret, etSSL);

	if (aVerifyPeer = False) then
	begin
		Unlock;
		SetSocketState(ssConnected);
		Exit;
	end;

	cip := SSL_get_current_cipher(FSSL);
	if (cip <> nil) then
		if (Assigned(FOnLog)) then
			FOnLog(Self, Format('SSL connection using cipher: %s', [SSL_CIPHER_get_name(cip)]));

	SSL_CTX_set_verify_depth(FSSLCTX, 9);

	crt := SSL_get_peer_certificate(FSSL);
	if (crt = nil) then
		ThrowError('Error getting peer certificate.');

	if (Assigned(FOnLog)) then
	begin
		FOnLog(Self, 'Server certificate:');

		buf := X509_NAME_oneline(X509_get_subject_name(crt), nil, 0);
		FOnLog(Self, #9 + 'subject:' + buf);
		OPENSSL_free(buf);

		buf := X509_NAME_oneline(X509_get_issuer_name(crt), nil, 0);
		FOnLog(Self, #9 + 'issuer:' + buf);
		OPENSSL_free(buf);
	end;

	ret := SSL_get_verify_result(FSSL);
	if (ret <> X509_V_OK) then
	begin
		buf := X509_verify_cert_error_string(ret);
		str := string(pansichar(buf));
		OPENSSL_free(buf);
		ThrowError(Format('Error verifying peer certificate: %s', [str]));
	end;

	SetSocketState(ssConnected);
end;

function TTcpSocket.GetWinsockError(const aErr: integer): string;
var
	buffer: array [0 .. 255] of Char;
	flags : DWORD;
begin
	FillChar(buffer, 256, #0);
	flags := FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_IGNORE_INSERTS or FORMAT_MESSAGE_ARGUMENT_ARRAY;
	FormatMessage(flags, nil, aErr, 0, buffer, SizeOf(buffer), nil);
	Result := buffer;
	if (Result <> '') then
		while (CharInSet(Result[Length(Result)], [#13, #10])) do
			Delete(Result, Length(Result), 1);
end;

function TTcpSocket.GetSSLError(const aErr: integer): string;
var
	err: integer;
	buf: array [0 .. 255] of ansichar;
begin
	Result := '';
	err    := SSL_get_error(FSSL, aErr);
	case err of
		SSL_ERROR_NONE:
		Exit;
		else
		begin
			while (err <> 0) do
			begin
				ERR_error_string_n(err, buf, SizeOf(buf));
				Result := Result + string(pansichar(@buf[0]));
				err    := ERR_get_error;
			end;
		end;
	end;
end;

procedure TTcpSocket.ThrowError(const aMessage: string; const aErrVal: integer; aType: TErrorType);
var
	details: string;
begin
	if (aType = etWinsock) then
		details := GetWinsockError(aErrVal)
	else if (aType = etSSL) then
		details := GetSSLError(aErrVal)
	else
		details := '';

	FState := ssDisconnected;
	Cleanup;

	if (details = '') then
		raise ESocket.Create(aMessage)
	else
		raise ESocket.Create(Format('%s: %s', [aMessage, details]));
end;

procedure TTcpSocket.Log(const aText: string);
begin
	if (Assigned(FOnLog)) then
		FOnLog(Self, aText);
end;

procedure TTcpSocket.Cleanup;
begin
	if (Connected) then
		if (FSSL <> nil) then
			SSL_shutdown(FSSL);

	if (FSSLCTX <> nil) then
	begin
		SSL_CTX_free(FSSLCTX);
		FSSLCTX := nil;
	end;

	if (FSSL <> nil) then
	begin
		SSL_free(FSSL);
		FSSL := nil;
	end;

	if (FSocket <> INVALID_SOCKET) then
	begin
		EvilWorks.Api.Winsock2.closesocket(FSocket);
		FSocket := INVALID_SOCKET;
	end;

	FState := ssDisconnected;
end;

class function TTcpSocket.SSLPasswordCallback(aBuf: pansichar; aSize, aRWFlag: integer;
aSocket: TTcpSocket): integer;
var
	password: AnsiString;
begin
	password := ansistring(aSocket.FSSLPassword);
	if (Length(password) > (aSize - 1)) then
		SetLength(password, aSize - 1);
	Result := Length(password);
	Move(PAnsiChar(password)^, aBuf^, Result + 1);
end;

function TTcpSocket.State: TSocketState;
begin
	Result := FState;
end;

function TTcpSocket.Connected: boolean;
begin
	Result := (FState >= ssConnected);
end;

procedure TTcpSocket.Connect(const aRemoteHost, aRemotePort: string; const aSSL, aSSLVerifyPeer: boolean;
const aProxyType: TProxyType; const aProxyHost, aProxyPort, aProxyUser, aProxyPass, aSSLPassword,
  aSSLCertificatefile, aSSLPrivateKeyFile, aSSLClientAuthorityFile, aBindHost, aBindPort: string);
begin
	FRemoteHost             := aRemoteHost;
	FRemotePort             := aRemotePort;
	FSSLEnabled             := aSSL;
	FSSLVerifyPeer          := aSSLVerifyPeer;
	FProxyType              := aProxyType;
	FProxyHost              := aProxyHost;
	FProxyPort              := aProxyPort;
	FProxyUser              := aProxyUser;
	FProxyPass              := aProxyPass;
	FSSLPassword            := aSSLPassword;
	FSSLCertificateFile     := aSSLCertificatefile;
	FSSLPrivateKeyFile      := aSSLPrivateKeyFile;
	FSSLClientAuthorityFile := aSSLClientAuthorityFile;
	FBindHost               := aBindHost;
	FBindPort               := aBindPort;
	Connect;
end;

procedure TTcpSocket.Connect;
begin
	if (FState <> ssDisconnected) then
		ThrowError('Socket is busy.');

	if (FRemoteHost = '') then
		ThrowError('Remote host not specified.');

	if (FRemotePort = '') then
		ThrowError('Remote port not specified.');

	if (FProxyType <> ptNone) then
	begin
		if (FProxyHost = '') then
			ThrowError('Proxy host not specified.');

		if (FProxyPort = '') then
			ThrowError('Proxy port not specified.');
	end;

	if (FAsync) then
		TThread.CreateAnonymousThread(InternalConnect).Suspended := False
	else
		InternalConnect;
end;

procedure TTcpSocket.Listen(const aBindHost, aBindPort: string; const aSSL,
  aSSLVerifyPeer: boolean; const aSSLPassword, aSSLCertificateFile, aSSLPrivateKeyFile,
  aSSLClientAuthorityFile: string);
begin
	FBindHost           := aBindHost;
	FBindPort           := aBindPort;
	FSSLEnabled         := aSSL;
	FSSLVerifyPeer      := aSSLVerifyPeer;
	FSSLPassword        := aSSLPassword;
	FSSLCertificateFile := aSSLCertificateFile;
	FSSLPrivateKeyFile  := aSSLPrivateKeyFile;
	Listen;
end;

procedure TTcpSocket.Listen;
begin
	if (FState <> ssDisconnected) then
		ThrowError('Socket is busy.');

	if (FBindHost = '') then
		ThrowError('Bind host not specified.');

	if (FBindPort = '') then
		ThrowError('Bind port not specified.');
end;

procedure TTcpSocket.Close;
begin
	if (Connected) then
	begin
		Cleanup;
		SetSocketState(ssDisconnected);
	end
	else
		Cleanup;
end;

function TTcpSocket.Pending: integer;
var
	len: u_long;
begin
	if (Connected = False) then
		Exit(0);

	if (FSSL <> nil) then
		Result := SSL_pending(FSSL)
	else
	begin
		Result := ioctlsocket(FSocket, FIONREAD, len);
		if (Result > - 1) then
			Result := integer(len);
	end;
end;

function TTcpSocket.SendBuf(const aBuf; const aSize: integer): integer;
begin
	if (FSSL <> nil) then
		Result := SSL_write(FSSL, @aBuf, aSize)
	else
		Result := send(FSocket, aBuf, aSize, 0);

	if (Result = 0) then
	begin
		Close;
		Exit;
	end;

	if (Result < 0) then
	begin
		if (WSAGetLastError = WSAETIMEDOUT) then
			ThrowError('SendBuf timed out.');

		if (FSSL <> nil) then
			ThrowError('SendBuf() failed', Result, etSSL)
		else
			ThrowError('SendBuf() failed', WSAGetLastError, etWinsock);
	end;
end;

function TTcpSocket.RecvBuf(out aBuf; const aSize: integer): integer;
begin
	if (FSSL <> nil) then
		Result := SSL_read(FSSL, @aBuf, aSize)
	else
		Result := recv(FSocket, aBuf, aSize, 0);

	if (Result = 0) then
	begin
		Close;
		Exit;
	end;

	if (Result < 0) then
	begin
		if (WSAGetLastError = WSAETIMEDOUT) then
			ThrowError('RecvBuf timed out.');

		if (FSSL <> nil) then
			ThrowError('RecvBuf() failed', Result, etSSL)
		else
			ThrowError('RecvBuf() failed', WSAGetLastError, etWinsock);
	end;
end;

procedure TTcpSocket.SendLine(const aText: rawbytestring);
var
	buf: rawbytestring;
	len: integer;
begin
	buf := aText + #13#10;
	len := Length(buf);
	if (SendBuf(buf[1], len) <> len) then
		ThrowError('SendLine() failed.');
end;

function TTcpSocket.RecvLine(const aTerminator: rawbytestring; const aMaxSize: integer): rawbytestring;
var
	ret: integer;
	buf: array of byte;
	len: integer;
	tsz: integer;
begin
	SetLength(buf, aMaxSize);
	FillChar(buf[0], aMaxSize, 0);
	tsz := Length(aTerminator);
	len := 0;

	while (len <= aMaxSize) do
	begin
		ret := RecvBuf(buf[len], 1);
		if (ret <> 1) then
			Exit('');
		Inc(len);
		if (len < tsz) then
			Continue;

		if (CompareMem(@buf[len - tsz], @aTerminator[1], tsz)) then
		begin
			SetLength(Result, len - tsz);
			Move(buf[0], Result[1], len - tsz);
			RunCheckThread;
			Exit;
		end;
	end;
	ThrowError('RecvLine() exceeded MaxSize waiting for Terminator.');
end;

function TTcpSocket.GetBindHost: string;
begin
	Result := FBindHost;
end;

function TTcpSocket.GetBindPort: string;
begin
	Result := FBindPort;
end;

function TTcpSocket.GetRemoteHost: string;
begin
	Result := FRemoteHost;
end;

function TTcpSocket.GetRemotePort: string;
begin
	Result := FRemotePort;
end;

function TTcpSocket.GetProxyType: TProxyType;
begin
	Result := FProxyType;
end;

function TTcpSocket.GetProxyHost: string;
begin
	Result := FProxyHost;
end;

function TTcpSocket.GetProxyPort: string;
begin
	Result := FProxyPort;
end;

function TTcpSocket.GetProxyUser: string;
begin
	Result := FProxyUser;
end;

function TTcpSocket.GetProxyPass: string;
begin
	Result := FProxyPass;
end;

function TTcpSocket.GetSSLEnabled: boolean;
begin
	Result := FSSLEnabled;
end;

function TTcpSocket.GetSSLVerifyPeer: boolean;
begin
	Result := FSSLVerifyPeer;
end;

function TTcpSocket.GetSSLPassword: string;
begin
	Result := FSSLPassword;
end;

function TTcpSocket.GetSSLCertificateFile: string;
begin
	Result := FSSLCertificateFile;
end;

function TTcpSocket.GetSSLPrivateKeyFile: string;
begin
	Result := FSSLPrivateKeyFile;
end;

function TTcpSocket.GetSSLClientAuthorityFile: string;
begin
	Result := FSSLClientAuthorityFile;
end;

procedure TTcpSocket.SetBindHost(const Value: string);
begin
	FBindHost := Value;
end;

procedure TTcpSocket.SetBindPort(const Value: string);
begin
	FBindPort := Value;
end;

procedure TTcpSocket.SetRemoteHost(const Value: string);
begin
	FRemoteHost := Value;
end;

procedure TTcpSocket.SetRemotePort(const Value: string);
begin
	FRemotePort := Value;
end;

procedure TTcpSocket.SetProxyType(const Value: TProxyType);
begin
	FProxyType := Value;
end;

procedure TTcpSocket.SetProxyHost(const Value: string);
begin
	FProxyHost := Value;
end;

procedure TTcpSocket.SetProxyPort(const Value: string);
begin
	FProxyPort := Value;
end;

procedure TTcpSocket.SetProxyUser(const Value: string);
begin
	FProxyUser := Value;
end;

procedure TTcpSocket.SetProxyPass(const Value: string);
begin
	FProxyPass := Value;
end;

procedure TTcpSocket.SetSSLEnabled(const Value: boolean);
begin
	FSSLEnabled := Value;
end;

procedure TTcpSocket.SetSSLVerifyPeer(const Value: boolean);
begin

end;

procedure TTcpSocket.SetSSLPassword(const Value: string);
begin
	FSSLPassword := Value;
end;

procedure TTcpSocket.SetSSLCertificateFile(const Value: string);
begin
	FSSLCertificateFile := Value;
end;

procedure TTcpSocket.SetSSLPrivateKeyFile(const Value: string);
begin
	FSSLPrivateKeyFile := Value;
end;

procedure TTcpSocket.SetSSLClientAuthorityFile(const Value: string);
begin
	FSSLClientAuthorityFile := Value;
end;

var
	wsaData: TWSAData;

{ TTcpClient }

constructor TTcpClient.CreateClient(const aOnStateChange: TOnSocketStateChange; const aAsync: boolean;
const aAddressFamily: TSocketAF; const aOnLog: TOnSocketLog);
begin
	inherited Create(aOnStateChange, aAsync, aAddressFamily, aOnLog);
end;

{ TTcpServer }

constructor TTcpServer.CreateServer(const aOnStateChange: TOnSocketStateChange; const aOnAccept: TOnSocketAccept;
const aAsync: boolean; const aAddressFamily: TSocketAF;
const aOnLog: TOnSocketLog);
begin
	inherited Create(aOnStateChange, aAsync, aAddressFamily, aOnLog);
	FOnAccept := aOnAccept;
end;

initialization

WSAStartup($0202, wsaData);
SSL_library_init;
SSL_load_error_strings;
OPENSSL_add_all_algorithms_noconf;

finalization

EVP_cleanup;
ERR_free_strings;
WSACleanup;

end.
