//
// EvilLibrary by Vedran Vuk 2010-2012
//
// Name: 					EvilWorks.Web.AsyncSockets
// Description: 			WSAAsyncSelect type of sockets. Windows only. Solid, lightweight, easy to use.
//                          Base sockets for other clients in EvilWorks.Web.* portion of EvilLibrary.
// File last change date:   October 19th. 2012
// File version: 			Dev 0.0.0
// Licence:                 Free.
//

{ TODO: FIX fast Connect/Disconnect lockup with resolve thread. }
{ TODO: Tweak TBuffer.Consume with ReallocMem. }
{ TODO: Bandwidth limiting. }
{ TODO: SSL context setup, loading keyfiles etc. }
{ TODO: Handle EventDisconnect better in TCPClient. }
{ TODO: Fix SSL for servers. }
{ TODO: Finish TCP server. }

unit EvilWorks.Web.AsyncSockets platform;

interface

uses
	Winapi.Windows,
	Winapi.Messages,
	System.Classes,
	System.SysUtils,
	EvilWorks.Api.Winsock2,
	EvilWorks.Api.OpenSSL,
	EvilWorks.System.SysUtils,
	EvilWorks.System.StrUtils,
	EvilWorks.Web.Base64,
    EvilWorks.Web.Utils,
    EvilWorks.Web.SSLFilter;

type
	{ Forward declarations }
	TAsyncSocket          = class;
	TProxyConnector       = class;
	TProxyItem            = class;
	TProxyChain           = class;
	TCustomAsyncTCPClient = class;
	TCustomAsyncTCPServer = class;
	TAsyncTCPClient       = class;
    TAsyncTCPServer       = class;

    { Shared events }
	TOnSocketLog = procedure(aSender: TObject; const aText: string) of object;

    { TProxyConnector Events }
	TOnProxyEvent         = procedure(aSender: TProxyConnector) of object;
	TOnProxyConnecting    = procedure(aSender: TProxyConnector; const aHost, aPort: string; const aProxyType: TProxyType) of object;
	TOnProxyDataForSocket = procedure(aSender: TProxyConnector; const aData: pByte; const aSize: integer; var aResult: integer) of object;
	TOnProxyNeedDetails   = procedure(aSender: TProxyConnector; var aHost, aPort, aUser, aPass: ansistring) of object;
	TOnProxyError         = procedure(aSender: TProxyConnector; const aError: string) of object;

    { TProxyChainer Events }
	TOnProxyChainConnected = procedure(aSender: TProxyChain) of object;

    { TAsyncSocket Events }
	TOnSocketEvent               = procedure(aSender: TAsyncSocket) of object;
	TOnSocketClientEvent         = procedure(aSender: TAsyncSocket; const aClient: TSocket) of object;
	TOnSocketResolving           = procedure(aSender: TAsyncSocket; const aHost, aPort: string; const aBindAddr: boolean) of object;
	TOnSocketResolved            = procedure(aSender: TAsyncSocket; const aCount: integer; const aBindAddr: boolean) of object;
	TOnSocketAccept              = procedure(aSender: TAsyncSocket; aClient: TAsyncTCPClient) of object;
	TOnSocketDataAvailable       = procedure(aSender: TAsyncSocket; const aDataAvailable: integer) of object;
	TOnSocketClientDataAvailable = procedure(aSender: TAsyncSocket; const aClient: TSocket; const aDataAvailable: integer) of object;
	TOnSocketError               = procedure(aSender: TAsyncSocket; const aErrorText: string) of object;

    { TSocketList }
    { Always sorted socket list for fast lookups of TAsyncSocket instances from TAsyncSocket.WndProc. }
	TSocketList = record
	private
		FItems: array of TAsyncSocket;
		FCount: integer;
		function Find(const aHandle: TSocket): integer;
		function GetSocket(const aIndex: integer): TAsyncSocket;
	public
		procedure Clear; // Constructor/Destructor!

		procedure Add(aSocket: TAsyncSocket);
		function Get(const aHandle: TSocket): TAsyncSocket; overload;
		procedure Del(aSocket: TAsyncSocket);

		property Items[const aIndex: integer]: TAsyncSocket read GetSocket;
		property Count: integer read FCount;
	end;

    { TProxyConnector }
    { Abstract class for proxy handshake methods. }
	TProxyConnector = class
	private
		FProxyItem: TProxyItem;

		FOnDataForSocket: TOnProxyDataForSocket;
		FOnNeedDetails  : TOnProxyNeedDetails;
		FOnConnecting   : TonProxyConnecting;
		FOnConnected    : TOnProxyEvent;
		FOnLog          : TOnSocketLog;
		FOnError        : TOnProxyError;

        // Error handling.
		function HandleError(const aErr, aNeed: integer; const aError: string): boolean;
	protected
    	// Descendants implement this perform the proxy handshake.
		procedure RunConnector(const aData: pByte; const aSize: integer); virtual; abstract;

        // Event handler callers
		procedure EventConnecting(const aHost, aPort: string; const aProxyType: TProxyType);
		procedure EventDataForSocket(const aData: pByte; const aSize: integer; var aResult: integer);
		procedure EventNeedDetails(aSender: TProxyConnector; var aHost, aPort, aUser, aPass: ansistring);
		procedure EventConnected;
		procedure EventLog(const aText: string);
		procedure EventError(const aError: string);
	public
		constructor Create(aProxyItem: TProxyItem);
		procedure Assign(aSource: TProxyConnector);

        // Handshake methods.
		procedure ResetHandshake; virtual; abstract;
		procedure StartHandshake;
		procedure DataForProxy(const aData: pByte; const aSize: integer);

        // Helpers.
		function Index: integer;

        // Events.
		property OnConnecting: TOnProxyConnecting read FOnConnecting write FOnConnecting;
		property OnDataForSocket: TOnProxyDataForSocket read FOnDataForSocket write FOnDataForSocket;
		property OnOnNeedDetails: TOnProxyNeedDetails read FOnNeedDetails write FOnNeedDetails;
		property OnConnected: TOnProxyEvent read FOnConnected write FOnConnected;
		property OnLog: TOnSocketLog read FOnLog write FOnLog;
		property OnError: TOnProxyError read FOnError write FOnError;
	end;

    { THTTPProxyConnector }
    { Implements HTTP tunnel proxy handshake. }
	THTTPProxyConnector = class(TProxyConnector)
	type
		THTTPHandshake = (hpStart, hpGetReply, hpDone);
	private
		FStage: THTTPHandshake;
	protected
		procedure RunConnector(const aData: pByte; const aSize: integer); override;
	public
		procedure ResetHandshake; override;
	end;

    { TSocks4Connector }
    { Implements socks4/4a handshake. }
	TSocks4Connector = class(TProxyConnector)
	type
		TSocks4Handshake = (h4Start, h4Done);
	private
		FStage: TSocks4Handshake;
	protected
		procedure RunConnector(const aData: pByte; const aSize: integer); override;
	public
		procedure ResetHandshake; override;
	end;

    { TSocks5Connector }
    { Implements socks5 handshake. }
	TSocks5Connector = class(TProxyConnector)
	type
		TSocks5Handshake = (h5Start, h5GetAuthSelReply, h5GetAuthReqReply, h5GetConnReqReply, h5Done);
	private
		FStage: TSocks5Handshake;
	protected
		procedure RunConnector(const aData: pByte; const aSize: integer); override;
	public
		procedure ResetHandshake; override;
	end;

    { TProxyItem }
    { TCollectionItem container for TProxyConnector designtime. }
	TProxyItem = class(TCollectionItem)
	private
		FProxyType: TProxyType;
		FPort     : string;
		FPass     : string;
		FHost     : string;
		FUser     : string;
		procedure SetProxyType(const Value: TProxyType);
	protected
		FConnector: TProxyConnector;
		function GetDisplayName: string; override;
	public
		constructor Create(aCollection: TCollection); override;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;

		property Connector: TProxyConnector read FConnector write FConnector;
	published
		property ProxyType: TProxyType read FProxyType write SetProxyType;
		property Host     : string read FHost write FHost;
		property Port     : string read FPort write FPort;
		property User     : string read FUser write FUser;
		property Pass     : string read FPass write FPass;
	end;

    { TProxyChain. }
    { Container for a list of TProxyItem. Defines and manages a proxy chain and the handshakes. }
	TProxyChain = class(TCollection)
	private
		FOwner           : TCustomAsyncTCPClient;
		FOnLog           : TOnSocketLog;
		FOnDataForSocket : TOnProxyDataForSocket;
		FOnConnecting    : TOnProxyConnecting;
		FOnConnected     : TOnProxyEvent;
		FOnChainConnected: TOnProxyChainConnected;
		FOnError         : TOnProxyError;

    	// TProxyConnector handshake cycling stuff
		FChainIndex: integer;
		FFinished  : boolean;
		procedure BindCurrentProxy;

        // Property getters/setters.
		function GetItem(const aIndex: integer): TProxyItem;
		procedure SetItem(const aIndex: integer; const aValue: TProxyItem);
	protected
        // TCollection overrides
		function GetOwner: TPersistent; override;

        // TProxyConnector event handlers
		procedure EventConnecting(aSender: TProxyConnector; const aHost, aPort: string; const aProxyType: TProxyType);
		procedure EventDataForSocket(aSender: TProxyConnector; const aData: pByte; const aSize: integer; var aResult: integer);
		procedure EventNeedDetails(aSender: TProxyConnector; var aHost, aPort, aUser, aPass: ansistring);
		procedure EventConnected(aSender: TProxyConnector);
		procedure EventLog(aSender: TObject; const aText: string);
		procedure EventError(aSender: TProxyConnector; const aError: string);
	public
		constructor Create(aSocket: TCustomAsyncTCPClient);
		procedure Assign(aSource: TPersistent); override;

        // TCollection overrides
		function Add: TProxyItem;
		function Insert(aIndex: integer): TProxyItem;
		property Items[const aIndex: integer]: TProxyItem read GetItem write SetItem; default;

        // Handshake methods
		procedure ResetHandshake;
		function NeedsHandshake: boolean;
		procedure StartHandshake;
		function GetTCPConnectAddr(var aHost, aPort: string): boolean;
		procedure DataForProxy(const aData: pByte; const aSize: integer);

        // Introduced events
		property OnDataForSocket: TOnProxyDataForSocket read FOnDataForSocket write FOnDataForSocket;
		property OnConnecting: TOnProxyConnecting read FOnConnecting write FOnConnecting;
		property OnConnected: TOnProxyEvent read FOnConnected write FOnConnected;
		property OnChainConnected: TOnProxyChainConnected read FOnChainConnected write FOnChainConnected;
		property OnLog: TOnSocketLog read FOnLog write FOnLog;
		property OnError: TOnProxyError read FOnError write FOnError;
	end;

	{ TAsyncSocket }
    { Base AsyncSocket class that manages messages and contains base functionality. }
	TAsyncSocket = class(TComponent)
	private const
		CMsgWndCls = 'EvilAsyncSocketWndCls'; { Do not localize. }
	public type
        { TSocketState }
		TSocketState = (
		  ssResolvingBind,    // Resolving address for binding the socket.
		  ssSocketCreated,    // Socket created [and bound].
		  ssResolvingConnect, // Resolving target for connecting the socket.
		  ssResolvingListen,  // Resolving listen address.
		  ssResolvedListen,   // Resolved listen address, just before bind().
		  ssConnecting,       // Connecting the socket.
		  ssConnected,        // Socket connected.
		  ssDisconnecting,    // Socket is disconnecting.
		  ssDisconnected,     // Socket disconnected.
		  ssListening         // Socket listening.
		  );
	private
	class var
    	// Class variables for managing message window and socket messages.
		FWSData     : TWSAData;    // Winsock startup structure.
		FWndCls     : TWndClass;   // Message receiver window class.
		FClsAtm     : ATOM;        // Message Window class atom.
		FMsgWnd     : HWND;        // Message receiver window handle.
		FSckLst     : TSocketList; // List of TAsyncSocket instances.
		FSckMsg     : integer;     // Windows message that forwards socket messages.
		FInitialized: boolean;     // If class vars and objects are initialized properly, will be true.
		FInitError  : string;      // Initialization string stored because we must not error in constructor.
	private
	var
    	// Socket variables.
		FAddressFamily: TAddressFamily;        // Address family used with RemoteHost:RemotePort
		FBindPort     : string;                // Bind/Listen address.
		FBindHost     : string;                // Bind/Listen port.
		FSocket       : TSocket;               // Socket handle.
		FSocketState  : TSocketState;          // State of the socket.
		FResolveData  : TGetAddrPoolAsyncData; // ResolveAddress() data.
		FMutex        : TMutex;                // Messages mutex.

        // Events
		FOnResolving: TOnSocketResolving;
		FOnResolved : TOnSocketResolved;
		FOnLog      : TOnSocketLog;
		FOnError    : TOnSocketError;

		procedure EventSocketCreated(const aError: integer); virtual;
		procedure EventBindAddressResolved(const aAddrPool: PAddrInfo; const aError: integer);

        // Socket message management functions and events.
		procedure MsgAccept(const aError: word); virtual;
		procedure MsgConnect(const aError: word); virtual;
		procedure MsgRead(const aError: word); virtual;
		procedure MsgWrite(const aError: word); virtual;
		procedure MsgClose(const aError: word); virtual;
		procedure MsgTimer(const aTimerID: cardinal); virtual;
		class function WndProc(aHwnd: HWND; aMsg: UINT; aWPar: WPARAM; aLPar: LPARAM): LRESULT; stdcall; static;
	protected
        // Mutex.
		procedure Lock;
		procedure Unlock;

        // Timer utility
		procedure TimerStart(const aTimerID, aElapse: cardinal);
		procedure TimerStop(const aTimerID: cardinal);

        // Socket management and class var access.
		function CheckInitialized: boolean;
		function MsgWnd: HWND;
		function SetSocketMessages(const aMask: cardinal): integer;
		procedure CreateSocket(const aSockType: TSocketType; const aListenSocket: boolean = False); virtual;
		procedure DestroySocket; virtual;
		procedure SetSocket(const aSocket: TSocket);
		procedure SetSocketState(const aState: TSocketState);
		procedure ResolveAddress(const aHost, aPort: string; const aAf: TAddressFamily; const aSt: TSocketType; aOnDone: TOnResolved; const aPassive: boolean = False);
		property Socket: TSocket read FSocket write FSocket;

        // Events.
		procedure EventResolving(const aHost, aPort: string; const aBindAddr: boolean);
		procedure EventResolved(const aCount: integer; const aBindAddr: boolean);
		procedure EventLog(aSender: TObject; const aText: string);
		procedure EventError(const aError: string);

        // Error handling.
		function HandleError(const aErr: integer; const aError: string): boolean; virtual;

        // Properties for lowering in descendants.
		property AddressFamily: TAddressFamily read FAddressFamily write FAddressFamily;
		property SocketState: TSocketState read FSocketState;
		property BindHost: string read FBindHost write FBindHost;
		property BindPort: string read FBindPort write FBindPort;

		property OnResolving: TOnSocketResolving read FOnResolving write FOnResolving;
		property OnResolved: TOnSocketResolved read FOnResolved write FOnResolved;
		property OnLog: TOnSocketLog read FOnLog write FOnLog;
		property OnError: TOnSocketError read FOnError write FOnError;
	public
		class constructor Create;
		class destructor Destroy;
		constructor Create(aOwner: TComponent); overload; override;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;
	end;

	{ TCustomAsyncTCPClient }
    { TCP client. }
	TCustomAsyncTCPClient = class(TAsyncSocket)
	type
		TTimerMode = (tmOff, tmWaitRetry, tmConnectTimeout);
	private
    	// Properties
		FRemoteHost    : string;
		FRemotePort    : string;
		FConnectTimeout: cardinal;

        // Connection variables.
		FProxyChain    : TProxyChain;
		FSSL           : TSSLFilter;
		FAddress       : PAddrInfo;  // Holds resolved address pool.
		FCurrentAddress: PAddrInfo;  // Current address we are trying to connect to in address pool.
		FTimerMode     : TTimerMode; // Marks what EventTimer means when received.

        // Events
		FOnConnected          : TOnSocketEvent;
		FOnProxyConnecting    : TOnProxyConnecting;
		FOnProxyConnected     : TOnProxyEvent;
		FOnProxyChainConnected: TOnSocketEvent;
		FOnDisconnected       : TOnSocketEvent;
		FOnConnecting         : TOnSocketEvent;
		FOnDataAvailable      : TOnSocketDataAvailable;
		FOnConnectTimeout     : TOnSocketEvent;

        // Misc handlers.
		procedure EventSocketCreated(const aError: integer); override;
		procedure EventTargetAddressResolved(const aAddrPool: PAddrInfo; const aError: integer);

        // ProxyChain event handlers.
		procedure EventProxyHave(aSender: TProxyConnector; const aData: pByte; const aSize: integer; var aResult: integer);
		procedure EventProxyConnecting(aSender: TProxyConnector; const aHost, aPort: string; const aProxyType: TProxyType);
		procedure EventProxyConnected(aSender: TProxyConnector);
		procedure EventProxyChainConnected(aSender: TProxyChain);
		procedure EventProxyLog(aSender: TObject; const aText: string);
		procedure EventProxyError(aSender: TProxyConnector; const aError: string);

        // TSSLFilter event handlers.
		procedure EventSSLDataEncrypted(aSender: TSSLFilter; const aDataSize: integer);
		procedure EventSSLDataDecrypted(aSender: TSSLFilter; const aDataSize: integer);
		procedure EventSSLLog(aSender: TObject; const aText: string);
		procedure EventSSLError(aSender: TSSLFilter; const aErrorText: string);

        // FD_* messages from WndProc
        // Overriden to handle TCP connections.
		procedure MsgConnect(const aError: word); override;
		procedure MsgRead(const aError: word); override;
		procedure MsgClose(const aError: word); override;
		procedure MsgTimer(const aTimerID: cardinal); override;

        // Connect() procedure helpers.
		function ConnectCycleAddressPool: boolean;
		procedure ConnectToCurrentAddress;

        // Getters/Setters
		procedure SetProxyChain(const aValue: TProxyChain);
		procedure SetSSL(const aValue: TSSLFilter);
		procedure SetConnectTimeout(const Value: cardinal);
		procedure SetRemoteHost(const Value: string);
		procedure SetRemotePort(const Value: string);
	protected
        // For descendants to override.
		procedure EventConnecting; virtual;
		procedure EventConnect; virtual;
		procedure EventDataAvailable(const aSize: integer); virtual;
		procedure EventDisconnect; virtual;

        // Error handling.
		function HandleError(const aErr: integer; const aError: string): boolean; override;

        // Properties for lowering in descendants.
		property RemoteHost: string read FRemoteHost write SetRemoteHost;
		property RemotePort: string read FRemotePort write SetRemotePort;
		property ProxyChain: TProxyChain read FProxyChain write SetProxyChain;
		property SSL: TSSLFilter read FSSL write SetSSL;
        // If not connected in under this time (milliseconds), fail.
        // For connecting over proxy chain, the value is applied to each proxy in chain.
        // Default and maximum is 60 seconds (60000) - which is also a hard coded value in Winsock.
		property ConnectTimeout: cardinal read FConnectTimeout write SetConnectTimeout;

        // Events for lowering in descendants.
		property OnConnecting: TOnSocketEvent read FOnConnecting write FOnConnecting;
		property OnProxyConnecting: TOnProxyConnecting read FOnProxyConnecting write FOnProxyConnecting;
		property OnProxyConnected: TOnProxyEvent read FOnProxyConnected write FOnProxyConnected;
		property OnProxyChainConnected: TOnSocketEvent read FOnProxyChainConnected write FOnProxyChainConnected;
		property OnConnectTimeout: TOnSocketEvent read FOnConnectTimeout write FOnConnectTimeout;
		property OnConnected: TOnSocketEvent read FOnConnected write FOnConnected;
		property OnDataAvailable: TOnSocketDataAvailable read FOnDataAvailable write FOnDataAvailable;
		property OnDisconnected: TOnSocketEvent read FOnDisconnected write FOnDisconnected;
	public
		constructor Create(aOwner: TComponent); override;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;

        // TCP connect/disconnect.
		procedure Connect; overload; virtual;
		procedure Connect(const aHost, aPort: string); overload;
		procedure Disconnect; virtual;

        // Send/Recv functions.
		function Send(const aData: pointer; const aSize: integer): integer;
		function SendString(const aString: string): integer;
		function SendLine(const aLine: string): integer;
		function Recv(const aData: pointer; const aSize: integer): integer;
		function RecvString: string;

		property Socket;
	end;

    { TAsyncTCPClient }
	TAsyncTCPClient = class(TCustomAsyncTCPClient)
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
	end;

implementation

{ =========== }
{ TSocketList }
{ =========== }

{ Get index of item, -1 if not found. }
function TSocketList.Find(const aHandle: TSocket): integer;
var
	loIdx, hiIdx, res, i: integer;
begin
	loIdx := 0;
	hiIdx := (FCount - 1);
	while (loIdx <= hiIdx) do
	begin
		i := ((loIdx + hiIdx) shr 1);

		if (FItems[i].Socket < aHandle) then
			res := - 1
		else if (FItems[i].Socket > aHandle) then
			res := 1
		else
			res := 0;

		if (res < 0) then
			loIdx := (i + 1)
		else
		begin
			if (res = 0) then
				Exit(i);
			hiIdx := (i - 1);
		end;
	end;

	Result := - 1;
end;

{ Bisect-right insertion. List is always sorted. }
procedure TSocketList.Add(aSocket: TAsyncSocket);
var
	loIdx, hiIdx, i: integer;
begin
	if (FCount <> 0) then
	begin
		loIdx := 0;
		hiIdx := FCount;
		while (loIdx < hiIdx) do
		begin
			i := ((loIdx + hiIdx) shr 1);
			if (aSocket.Socket < FItems[i].Socket) then
				hiIdx := i
			else
				loIdx := i + 1;
		end;
		i := loIdx;
	end
	else
		i := 0;

	SetLength(FItems, FCount + 1);
	if (i < FCount) then
		Move(FItems[i], FItems[i + 1], (FCount - i) * SizeOf(TAsyncSocket));
	Inc(FCount);
	FItems[i] := aSocket;
end;

{ Get item at aIndex. }
function TSocketList.Get(const aHandle: TSocket): TAsyncSocket;
var
	idx: integer;
begin
	idx := Find(aHandle);
	if (idx < 0) then
		Exit(nil);
	Result := FItems[idx];
end;

{ Removes a TAsyncSocket instance from the list. }
procedure TSocketList.Del(aSocket: TAsyncSocket);
var
	idx: integer;
begin
	idx := Find(aSocket.Socket);
	if (idx < 0) then
		Exit;

	Dec(FCount);
	if (idx < FCount) then
		Move(FItems[idx + 1], FItems[idx], (FCount - idx) * SizeOf(TAsyncSocket));
	SetLength(FItems, FCount);
end;

{ Clears/creates/initializes the list. }
procedure TSocketList.Clear;
begin
	SetLength(FItems, 0);
	FCount := 0;
end;

{ Items getter. }
function TSocketList.GetSocket(const aIndex: integer): TAsyncSocket;
begin
	if (aIndex < 0) or (aIndex >= FCount) then
		Exit(nil);
	Result := FItems[aIndex];
end;

{ =============== }
{ TProxyConnector }
{ =============== }

{ Constructor. }
constructor TProxyConnector.Create(aProxyItem: TProxyItem);
begin
	FProxyItem := aProxyItem;
end;

{ Assign. }
procedure TProxyConnector.Assign(aSource: TProxyConnector);
begin
	OnDataForSocket := aSource.OnDataForSocket;
	OnConnected     := aSource.OnConnected;
	OnError         := aSource.OnError;
end;

{ Starts the handshake. }
procedure TProxyConnector.StartHandshake;
begin
	ResetHandshake;
	RunConnector(nil, 0);
end;

{ aData of aSize available for proxy for reading. }
procedure TProxyConnector.DataForProxy(const aData: pByte; const aSize: integer);
begin
	RunConnector(aData, aSize);
end;

{ Gets index in proxy chain. }
function TProxyConnector.Index: integer;
begin
	Result := FProxyItem.Index;
end;

{ Checks aErr, returns True if handled, False otherwise. Returns False if (aErr != aNeed) as well. }
function TProxyConnector.HandleError(const aErr, aNeed: integer; const aError: string): boolean;
begin
	if (aErr <> aNeed) or (aErr < 0) then
	begin
		Result := False;
		ResetHandshake;
		EventError(aError);
	end
	else
		Result := True;
end;

{ Calls OnConnecting handler. }
procedure TProxyConnector.EventConnecting(const aHost, aPort: string; const aProxyType: TProxyType);
begin
	if (Assigned(FOnConnecting)) then
		FOnConnecting(Self, aHost, aPort, aProxyType);
end;

{ Calls OnProxyHave handler. This tells socket to send aData of aSize to peer and return send() result to aResult. }
procedure TProxyConnector.EventDataForSocket(const aData: pByte; const aSize: integer; var aResult: integer);
begin
	if (Assigned(FOnDataForSocket)) then
		FOnDataForSocket(Self, aData, aSize, aResult);
end;

{ Calls OnNeedNexInChain which returns connect details from next proxy in chain. }
procedure TProxyConnector.EventNeedDetails(aSender: TProxyConnector; var aHost, aPort, aUser, aPass: ansistring);
begin
	if (Assigned(FOnNeedDetails)) then
		FOnNeedDetails(aSender, aHost, aPort, aUser, aPass);
end;

{ Calls OnConnected handler. Proxy negotiation successfully completed and connected. }
procedure TProxyConnector.EventConnected;
begin
	if (Assigned(FOnConnected)) then
		FOnConnected(Self);
end;

{ Calls OnLog handler. }
procedure TProxyConnector.EventLog(const aText: string);
begin
	if (Assigned(FOnLog)) then
		FOnLog(Self, aText);
end;

{ Calls OnError handler. Negotiation error occured. Disconnect socket! }
procedure TProxyConnector.EventError(const aError: string);
begin
	if (Assigned(FOnError)) then
		FOnError(Self, Format('[%s]: %s', [Self.ClassName, aError]));
end;

{ =================== }
{ THTTPProxyConnector }
{ =================== }

{ Resets handshake state, gets ready to start new negotiation. }
procedure THTTPProxyConnector.ResetHandshake;
begin
	inherited;
	FStage := hpStart;
end;

{ Implements HTTP proxy handshake. }
procedure THTTPProxyConnector.RunConnector(const aData: pByte; const aSize: integer);
var
	ret: integer;

	procedure SendConnectRequest;
	var
		host, port, user, pass, data: ansistring;
	begin
		EventNeedDetails(Self, host, port, user, pass);

		data := 'CONNECT ' + ansistring(host + ':' + port) + ' HTTP/1.1' + CCrLf;
		if (user <> CEmpty) and (pass <> CEmpty) then
			data := data + 'Authorization: Basic ' + ansistring(Base64Encode(user + ':' + pass)) + CCrLf;
		data     := data + CCrLf;

		EventDataForSocket(@data[1], Length(data), ret);
		if (HandleError(ret, Length(data), 'SendConnectRequest() failed.') = False) then
			Exit;
		FStage := hpGetReply;
	end;

	procedure RecvConnectReqResponse;
	var
		data: string;
	begin
		data := string(pansichar(aData));
		data := TextToken(data, 1);

		if (TextToInt(data, - 1) = - 1) then
		begin
			HandleError(0, 1, 'RecvConnectReqResponse(): Invalid reply.');
			Exit;
		end;

		if (data <> '200') then
		begin
			HandleError(0, 1, 'RecvConnectReqResponse(): Connect failed: ' + data);
			Exit;
		end;
		FStage := hpDone;
		EventConnected;
	end;

begin
	case FStage of
		hpStart:
		SendConnectRequest;
		hpGetReply:
		RecvConnectReqResponse;
	end; { case }
end;

{ ================ }
{ TSocks4Connector }
{ ================ }

{ Resets handshake state, gets ready to start new negotiation. }
procedure TSocks4Connector.ResetHandshake;
begin
	inherited;
	FStage := h4Start;
end;

{ Implements Socks4/4a proxy handshake. }
procedure TSocks4Connector.RunConnector(const aData: pByte; const aSize: integer);
begin

end;

{ ================ }
{ TSocks5Connector }
{ ================ }

{ Resets handshake state, gets ready to start new negotiation. }
procedure TSocks5Connector.ResetHandshake;
begin
	inherited;
	FStage := h5Start;
end;

{ Implements Socks5 proxy handshake. }
procedure TSocks5Connector.RunConnector(const aData: pByte; const aSize: integer);
var
	ret                   : integer;
	p                     : PByte;
	Buff                  : array of Byte;
	host, port, user, pass: ansistring;

	procedure SendSupportedAuthMethods;
	begin
        // Send auth methods.
		SetLength(Buff, 4);
		Buff[0] := $05; // Socks version, must be $05.
		Buff[1] := $02; // Num of methods supported.
		Buff[2] := $00; // Method 1 - No auth.
		Buff[3] := $02; // Method 2 - Username/Password.
		EventDataForSocket(@Buff[0], 4, ret);
		if (HandleError(ret, 4, 'SendSupportedAuthMethods(): Send failed.') = False) then
			Exit;
		FStage := h5GetAuthSelReply;
	end;

	procedure SendConnectRequest;
	var
		w: word;
	begin
		EventNeedDetails(Self, host, port, user, pass);

		// Send connect request.
		ServToPortNum(string(port), w);
		SetLength(Buff, 7 + Length(host));
		Buff[0] := $05;                        // Socks version.
		Buff[1] := $01;                        // Establish TCP connection.
		Buff[2] := $00;                        // Reserved.
		Buff[3] := $03;                        // Destination type: Domain name.
		Buff[4] := Length(host);               // Length of hostname
		Move(host[1], Buff[5], Buff[4]);       // Hostname
		Move(w, Buff[Buff[4] + 5], SizeOf(w)); // Port
		EventDataForSocket(@Buff[0], Length(Buff), ret);
		if (HandleError(ret, Length(Buff), 'SendConnectRequest(): Send failed.') = False) then
			Exit;
		FStage := h5GetConnReqReply;
	end;

	procedure RecvSelAuthMethod;
	begin
        // Recieve selected Auth method.
		p := aData;
		if (HandleError(p^, $05, 'RecvSelAuthMethod(): Invalid reply version.') = False) then
			Exit;
		Inc(p);

        // User:pass auth requested, send user:pass.
		if (p^ = 2) then
		begin
			EventNeedDetails(Self, host, port, user, pass);

            // Send Username/Password
			SetLength(Buff, 3 + Length(user) + Length(pass));
			Buff[0] := $01; // Sending user:pass auth.

            // Put username
			Buff[1] := Length(user);
			if (Buff[1] > 0) then
				Move(user[1], Buff[2], Length(user));

            // Put password
			Buff[2 + Length(user) + 1] := Length(pass);
			if (Buff[2 + Length(user) + 1] > 0) then
				Move(pass[1], Buff[2 + Length(user) + 1], Length(pass));

            // Send Username:Password auth.
			EventDataForSocket(@Buff[0], Length(Buff), ret);
			if (HandleError(ret, Length(Buff), 'RecvSelAuthMethod(): Send failed.') = False) then
				Exit;

			FStage := h5GetAuthReqReply;
		end
		else if (p^ <> 0) then // Some unsupported auth method requested.
			HandleError(0, 1, 'RecvSelAuthMethod(): No supported auth methods.')
		else
			SendConnectRequest; // No auth requested, do connect request.
	end;

	procedure RecvUserPassResponse;
	begin
        // Get auth response.
		p := aData;
		if (HandleError(p^, $05, 'RecvSelAuthMethod(): Invalid reply version.') = False) then
			Exit;
		Inc(p);

		if (p^ <> 0) then
		begin
			HandleError(0, 1, 'RecvSelAuthMethod(): Authentication failed.');
			Exit;
		end;
		SendConnectRequest;
	end;

	procedure RecvConnectReqResponse;
	begin
        // Recieve connect response.
		p := aData;
		if (HandleError(p^, $05, 'RecvConnectReqResponse(): Invalid reply version.') = False) then
			Exit;
		Inc(p);

        // Check for final "OK!".
		if (p^ <> $00) then
		begin
			HandleError(0, 1, 'RecvConnectReqResponse(): Connect failed: ' + GetSocks5ErrorText(p^));
			Exit;
		end;

        // Done with this proxy in chain.
		FStage := h5Done;
		EventConnected;
	end;

begin
	case FStage of
		h5Start:
		SendSupportedAuthMethods;
		h5GetAuthSelReply:
		RecvSelAuthMethod;
		h5GetAuthReqReply:
		RecvUserPassResponse;
		h5GetConnReqReply:
		RecvConnectReqResponse;
	end; { case }

	if (Length(Buff) <> 0) then
		SetLength(Buff, 0);
end;

{ ========== }
{ TProxyItem }
{ ========== }

{ Constructor. }
constructor TProxyItem.Create(aCollection: TCollection);
begin
	inherited Create(aCollection);

	FProxyType := ptNone;
	FConnector := nil;
end;

{ Destructor. }
destructor TProxyItem.Destroy;
begin
	if (FConnector <> nil) then
		FConnector.Free;

	inherited;
end;

{ Assign. }
procedure TProxyItem.Assign(aSource: TPersistent);
begin
	inherited;

	if (aSource is TProxyItem) then
	begin
		ProxyType := TProxyItem(aSource).ProxyType;
		Host      := TProxyItem(aSource).Host;
		Port      := TProxyItem(aSource).Port;
		User      := TProxyItem(aSource).User;
		Pass      := TProxyItem(aSource).Pass;
	end;
end;

{ GetDisplayName override. }
function TProxyItem.GetDisplayName: string;
begin
	case FProxyType of
		ptNone:
		Result := '<Proxy disabled>';
		ptHTTP:
		Result := 'proxy://';
		ptSocks4:
		Result := 'socks4://';
		ptSocks5:
		Result := 'socks5://';
	end;

	if (Host <> '') and (Port <> '') then
		Result := Result + Host + ':' + Port;
end;

{ ProxyType setter. }
procedure TProxyItem.SetProxyType(const Value: TProxyType);
begin
	if (FProxyType = Value) then
		Exit;
	FProxyType := Value;
	if (FConnector <> nil) then
		FConnector.Free;
	case FProxyType of
		ptHTTP:
		FConnector := THTTPProxyConnector.Create(Self);
		ptSocks4:
		FConnector := TSocks4Connector.Create(Self);
		ptSocks5:
		FConnector := TSocks5Connector.Create(Self);
	end;
end;

{ =========== }
{ TProxyChain }
{ =========== }

{ Constructor. }
constructor TProxyChain.Create(aSocket: TCustomAsyncTCPClient);
begin
	inherited Create(TProxyItem);

	FOwner := aSocket;

	FChainIndex := 0;
	FFinished   := False;
end;

{ Assign. }
procedure TProxyChain.Assign(aSource: TPersistent);
begin
	inherited;

	if (aSource is TProxyChain) then
	begin
		OnDataForSocket  := TProxyChain(aSource).OnDataForSocket;
		OnConnecting     := TProxyChain(aSource).OnConnecting;
		OnConnected      := TProxyChain(aSource).OnConnected;
		OnChainConnected := TProxyChain(aSource).OnChainConnected;
		OnLog            := TProxyChain(aSource).OnLog;
		OnError          := TProxyChain(aSource).OnError;
	end;
end;

{ TCollection.GetOwner() override. }
function TProxyChain.GetOwner: TPersistent;
begin
	Result := FOwner;
end;

{ TCollection.Add() override. }
function TProxyChain.Add: TProxyItem;
begin
	Result := TProxyItem(inherited Add);
end;

{ TCollection.Insert() override. }
function TProxyChain.Insert(aIndex: integer): TProxyItem;
begin
	Result := TProxyItem(inherited Insert(aIndex));
end;

{ Binds events of current TProxyConnector in handshake chain to internal event handlers. }
procedure TProxyChain.BindCurrentProxy;
begin
	Items[FChainIndex].Connector.OnOnNeedDetails := EventNeedDetails;
	Items[FChainIndex].Connector.OnDataForSocket := EventDataForSocket;
	Items[FChainIndex].Connector.OnConnecting    := EventConnecting;
	Items[FChainIndex].Connector.OnConnected     := EventConnected;
	Items[FChainIndex].Connector.OnLog           := EventLog;
	Items[FChainIndex].Connector.OnError         := EventError;
end;

{ Reset chain handshake, get ready to start new negotiation.}
procedure TProxyChain.ResetHandshake;
var
	i: integer;
begin
	FChainIndex := 0;
	FFinished   := False;

	for i := 0 to Count - 1 do
		Items[i].Connector.ResetHandshake;

	if (Count < 1) then
		Exit;

	BindCurrentProxy;
end;

{ Checks if the handshake is completed. }
function TProxyChain.NeedsHandshake: boolean;
begin
	Result := (not FFinished) and (Count > 0);
end;

{ Starts the chain handshake. }
procedure TProxyChain.StartHandshake;
begin
	ResetHandshake;
	Items[FChainIndex].Connector.StartHandshake;
end;

{ Gets address of first proxy in chain for Socket to connect to. Rest of negotiation follows through chain. }
function TProxyChain.GetTCPConnectAddr(var aHost, aPort: string): boolean;
var
	i: integer;
begin
	for i := 0 to Count - 1 do
	begin
		if (Items[i].Connector <> nil) then
		begin
			aHost := Items[i].Host;
			aPort := Items[i].Port;
			Exit(True);
		end;
	end;
	aHost  := '';
	aPort  := '';
	Result := False;
end;

{ aData of aSize available for proxy chain for reading. }
procedure TProxyChain.DataForProxy(const aData: pByte; const aSize: integer);
begin
	Items[FChainIndex].Connector.DataForProxy(aData, aSize);
end;

{ TProxyConnector OnConnecting handler. }
procedure TProxyChain.EventConnecting(aSender: TProxyConnector; const aHost, aPort: string; const aProxyType: TProxyType);
begin
	if (Assigned(FOnConnecting)) then
		FOnConnecting(aSender, aHost, aPort, aProxyType);
end;

{ Handles an OnDataForSocket event from current proxy that's in handshake and forwards }
{ the event to TCP class owning TProxyChainer to send the aData of aSize. }
procedure TProxyChain.EventDataForSocket(aSender: TProxyConnector; const aData: pByte; const aSize: integer; var aResult: integer);
begin
	if (Assigned(FOnDataForSocket)) then
		FOnDataForSocket(aSender, aData, aSize, aResult);
end;

{ TProxyConnector OnNeedDetails handler. }
{ Called by a TProxyConnector in chain when it needs connection details. This method }
{ determines what it should return depending on calling proxy's position in chain. }
procedure TProxyChain.EventNeedDetails(aSender: TProxyConnector; var aHost, aPort, aUser, aPass: ansistring);
var
	i: integer;
begin
	// See if theres a proxy in chain pending...
	for i := FChainIndex + 1 to Count - 1 do
	begin
		if (Items[i].Connector <> nil) then
		begin
			aHost := ansistring(Items[i].Host);
			aPort := ansistring(Items[i].Port);
			aUser := ansistring(Items[i].User);
			aPass := ansistring(Items[i].Pass);
			Exit;
		end;
	end;

    // ..If not and that was last proxy in chain,
    // return our actual destination address to
    // instruct the last proxy to connect to it.
	aHost := ansistring(FOwner.RemoteHost);
	aPort := ansistring(FOwner.RemotePort);
	aUser := '';
	aPass := '';
end;

{ TProxyConnector OnConnected handler and OnProxyConnected dispatcher.}
{ A proxy in the chain connected and called OnConnected. Fire the notification events or
{ Start the handshake on next proxy in chain. }
procedure TProxyChain.EventConnected(aSender: TProxyConnector);
begin
	if (Assigned(FOnConnected)) then
		FOnConnected(aSender);

	Inc(FChainIndex);
	if (FChainIndex < Count) then
	begin
		BindCurrentProxy;
		Items[FChainIndex].Connector.StartHandshake;
	end
	else
	begin
		FFinished := True;
		if (Assigned(FOnChainConnected)) then
			FOnChainConnected(Self);
	end;
end;

{ TProxyConnector OnError handler.}
procedure TProxyChain.EventError(aSender: TProxyConnector; const aError: string);
begin
	ResetHandshake;
	if (Assigned(FOnError)) then
		FOnError(aSender, aError);
end;

{ TProxyConnector OnLog handler. }
procedure TProxyChain.EventLog(aSender: TObject; const aText: string);
begin
	if (Assigned(FOnLog)) then
		FOnLog(Self, aText);
end;

{ Items getter. }
function TProxyChain.GetItem(const aIndex: integer): TProxyItem;
begin
	Result := TProxyItem(inherited GetItem(aIndex));
end;

{ Items setter. }
procedure TProxyChain.SetItem(const aIndex: integer; const aValue: TProxyItem);
begin
	inherited SetItem(aIndex, aValue);
end;

{ ============ }
{ TAsyncSocket }
{ ============ }

{ Class constructor. }
class constructor TAsyncSocket.Create;
label Error;
var
	ret: integer;
begin
    // Resolves need a thread. :S
	IsMultiThread := True;

    // Initialize Winsock.
	ZeroMemory(@FWSData, SizeOf(FWSData));
	ret := WSAStartup($0202, FWSData);
	if (ret <> 0) then
	begin
		FInitError := 'WinSocketInstanceCreated(): WSAStartup() failed: ' + GetWinsockErrorText(ret);
		goto Error;
	end;

    // Initialize SSL
	SSL_library_init;
	SSL_load_error_strings;

    // Create Message receiver window class.
	ZeroMemory(@FWndCls, SizeOf(FWndCls));
	FWndCls.lpszClassName := CMsgWndCls;
	FWndCls.lpfnWndProc   := @WndProc;
	FWndCls.hInstance     := hInstance;

	FClsAtm := Winapi.Windows.RegisterClass(FWndCls);
	if (FClsAtm = 0) then
	begin
		FInitError := 'WinSocketInstanceCreated(): RegisterClass() failed: ' + GetLastErrorText;
		goto Error;
	end;

    // Create message window.
	FMsgWnd := CreateWindow(CMsgWndCls, nil, 0, 0, 0, 0, 0, HWND_MESSAGE, 0, hInstance, nil);
	if (FMsgWnd = 0) then
	begin
		FInitError := 'WinSocketInstanceCreated(): CreateWindow() failed: ' + GetLastErrorText;
		goto Error;
	end;

    // Create the instance list.
	FSckLst.Clear;

    // Initialized OK.
	FInitialized := True;
	FInitError   := '';

    // Exit before Error cleanup.
	Exit;

Error:

	// Frees up class vars on error.
	if (FMsgWnd <> 0) then
	begin
		DestroyWindow(FMsgWnd);
		FMsgWnd := 0;
	end;

	if (FClsAtm <> 0) then
	begin
		Winapi.Windows.UnregisterClass(CMsgWndCls, hInstance);
		FClsAtm := 0;
		ZeroMemory(@FWndCls, SizeOf(FWndCls));
	end;

	ERR_free_strings;

	if (FWSData.wVersion <> 0) then
	begin
		WSACleanup;
		ZeroMemory(@FWSData, SizeOf(FWSData));
	end;

	FInitialized := False;

end;

{ Class destructor. }
class destructor TAsyncSocket.Destroy;
begin
	if (FInitialized = False) then
		Exit;

	// If we were the last instance being destroyed, finalize the class.
	if (FSckLst.Count <> 0) then
		Exit;

    // Clear the instance list.
	FSckLst.Clear;

    // Destroy message window.
	DestroyWindow(FMsgWnd);
	FMsgWnd := 0;

    // Unregister message window class.
	Winapi.Windows.UnregisterClass(CMsgWndCls, hInstance);
	FClsAtm := 0;
	ZeroMemory(@FWndCls, SizeOf(FWndCls));

    // Finalize SSL.
	ERR_free_strings;

    // Finalize winsock.
	WSACleanup;
	ZeroMemory(@FWSData, SizeOf(FWSData));

	FInitialized := False;
end;

{ Constructor. }
constructor TAsyncSocket.Create(aOwner: TComponent);
begin
	inherited;

	FMutex := TMutex.Create;

	FAddressFamily := afIPv4;
	FSocket        := INVALID_SOCKET;
	FSocketState   := ssDisconnected;

	FResolveData.Initialize;
end;

{ Destructor. }
destructor TAsyncSocket.Destroy;
begin
	FResolveData.Abort; // Just in case the resolve thread is still running.
	FMutex.Free;
	inherited;
end;

{ Assign. }
procedure TAsyncSocket.Assign(aSource: TPersistent);
begin
	inherited;

	if (aSource is TAsyncSocket) then
	begin
		AddressFamily := TAsyncSocket(aSource).AddressFamily;
		BindHost      := TAsyncSocket(aSource).BindHost;
		BindPort      := TAsyncSocket(aSource).BindPort;
		OnResolving   := TAsyncSocket(aSource).OnResolving;
		OnResolved    := TAsyncSocket(aSource).OnResolved;
		OnLog         := TAsyncSocket(aSource).OnLog;
		OnError       := TAsyncSocket(aSource).OnError;
	end;
end;

{ Checks if the TWinSocket class has been initialized properly for issuing Winsock operations. }
function TAsyncSocket.CheckInitialized: boolean;
begin
	Result := FInitialized;

	if (Result = False) then
		HandleError( - 2, FInitError)
end;

{ Sets the socket to AsyncSelect mode, requesting messages specified by aMask (FD_ACCEPT, FD_CONNECT...). }
{ Returns True if successfull, False otherwise - use WSAGetlastError. }
function TAsyncSocket.SetSocketMessages(const aMask: cardinal): integer;
begin
	Result := WSAAsyncSelect(FSocket, FMsgWnd, FSckMsg, aMask);
end;

{ Sets FSocketState value. }
procedure TAsyncSocket.SetSocketState(const aState: TSocketState);
begin
	FSocketState := aState;
end;

{ FMsgWnd classvar getter. }
function TAsyncSocket.MsgWnd: HWND;
begin
	Result := FMsgWnd;
end;

{ Enter mutex. }
procedure TAsyncSocket.Lock;
begin
	FMutex.Lock;
end;

{ Exit mutex. }
procedure TAsyncSocket.Unlock;
begin
	FMutex.Unlock;
end;

{ Creates the socket descriptor. Descendant classes override this and create the socket with appropriate }
{ protocol parameters. Finaly, they call inherited to have this method add self to instance list. }
procedure TAsyncSocket.CreateSocket(const aSockType: TSocketType; const aListenSocket: boolean);
begin
	if (CheckInitialized = False) then
		Exit;

	// Create socket.
	case aSockType of
		stStream:
		FSocket := CreateTcpSock(AddressFamily);
		stDGram:
		FSocket := CreateUdpSock(AddressFamily);
	end;

	if (HandleError(Socket, 'socket() failed.') = False) then
		Exit;

	FSckLst.Add(Self);

	if (BindHost <> '') then
	begin
		SetSocketState(ssResolvingBind);
		ResolveAddress(BindHost, BindPort, AddressFamily, aSockType, EventBindAddressResolved, aListenSocket);
	end
	else
	begin
		SetSocketState(ssSocketCreated);
		EventSocketCreated(0);
	end;
end;

{ Destroys the socket if it's allocated. }
procedure TAsyncSocket.DestroySocket;
begin
	// Ensure all states are reset and variables are freed.
	FResolveData.Abort;

    // Exit if no socket to act upon.
	if (FSocket = INVALID_SOCKET) then
	begin
		SetSocketState(ssDisconnected);
		Exit;
	end;

    // Remove socket from socket list, destroy the socket
    // descriptor, its reference and all other base session variables.
	FSckLst.Del(Self);
	SetSocketMessages(0);
	closesocket(FSocket);
	FSocket      := INVALID_SOCKET;
	FSocketState := ssDisconnected;
end;

{ Sets the FSocket value and adds to socket list. This is for when TAsyncTCPClient is used with accept(). }
procedure TAsyncSocket.SetSocket(const aSocket: TSocket);
begin
	FSocket := aSocket;
	SetSocketState(ssConnected);
	FSckLst.Add(Self);
end;

{ Run a timer on the message window. Timer events are returned in EventTimer(). }
procedure TAsyncSocket.TimerStart(const aTimerID, aElapse: cardinal);
begin
	SetTimer(FMsgWnd, aTimerID, aElapse, nil);
end;

{ Stop a timer in message window. }
procedure TAsyncSocket.TimerStop(const aTimerID: cardinal);
begin
	KillTimer(FMsgWnd, aTimerID);
end;

{ Request an address resolve, fire EventAddressResolved when done. }
procedure TAsyncSocket.ResolveAddress(const aHost, aPort: string; const aAf: TAddressFamily; const aSt: TSocketType; aOnDone: TOnResolved; const aPassive: boolean);
begin
	EventResolving(aHost, aPort, SocketState = ssResolvingBind);
	FResolveData.Abort; // In case the resolve thread is already running...
	FResolveData.AddressFamily := aAf;
	FResolveData.SocketType    := aSt;
	FResolveData.host          := aHost;
	FResolveData.port          := aPort;
	if (aPassive) then
		FResolveData.Flags := AI_PASSIVE
	else
		FResolveData.Flags  := 0;
	FResolveData.OnResolved := aOnDone;
	GetAddrPoolAsync(FResolveData);
end;

{ Checks if the error return value of a Winsock function is non-passable. }
{ Returns True if passable, False if fatal error. Pass -2 to aErr to force fatal.}
function TAsyncSocket.HandleError(const aErr: integer; const aError: string): boolean;
var
	str: string;
begin
	if (aErr = SOCKET_ERROR) then
		Result := (WSAGetLastError = WSAEWOULDBLOCK)
	else if (aErr = - 2) then
		Result := False
	else
		Exit(True);

	str := Self.ClassName + ': ' + aError;
	if (aErr = SOCKET_ERROR) then
		str := str + ': ' + TextRemoveLineFeeds(GetLastWinsockErrorText);
	DestroySocket;
	EventError(str);
end;

{ Called from WndProc on WM_TIMER messages. See TimerStart() and TimerStop(). }
procedure TAsyncSocket.MsgTimer(const aTimerID: cardinal);
begin
	{ Virtual }
end;

{ Returns aAddrPool after successfull ResolveAddress(), or a non-zero aError on fail. }
{ aAddrPool must be freed manually after you're done with it. }
procedure TAsyncSocket.EventBindAddressResolved(const aAddrPool: PAddrInfo; const aError: integer);
var
	p: PAddrInfo;
	c: integer;
begin
	// Initialize resolve thread data.
	FResolveData.Initialize;

    // Check error.
	if (aError <> 0) then
	begin
		HandleError( - 2, 'Resolve bind address failed');
		Exit;
	end;

	if (HandleError(EvilWorks.Api.Winsock2.bind(Socket, aAddrPool^.ai_addr, aAddrPool^.ai_addrlen), 'bind() failed') = False) then
		Exit;

    // Get number of addresses resolved.
	c := 0;
	p := aAddrPool;
	while (p <> nil) do
	begin
		Inc(c);
		p := p^.ai_next;
	end;

    // Fire events.
	EventResolved(c, True);
	if (SocketState = ssResolvingBind) then
	begin
		SetSocketState(ssSocketCreated);
		EventSocketCreated(0);
	end;
end;

{ Called after CreateSocket() finishes its procedure of creating the socket handle, resolving a local }
{ address and binding the socket to it. }
procedure TAsyncSocket.EventSocketCreated(const aError: integer);
begin
	{ Virtual }
end;

{ Calls OnResolving event.}
procedure TAsyncSocket.EventResolving(const aHost, aPort: string; const aBindAddr: boolean);
begin
	if (Assigned(FOnResolving)) then
		FOnResolving(Self, aHost, aPort, aBindAddr);
end;

{ Calls OnResolved event. }
procedure TAsyncSocket.EventResolved(const aCount: integer; const aBindAddr: boolean);
begin
	if (Assigned(FOnResolved)) then
		FOnResolved(Self, aCount, aBindAddr);
end;

{ Calls OnLog event. }
procedure TAsyncSocket.EventLog(aSender: TObject; const aText: string);
begin
	if (Assigned(FOnLog)) then
		FOnLog(aSender, aText);
end;

{ Calls OnError event.}
procedure TAsyncSocket.EventError(const aError: string);
begin
	if (Assigned(FOnError)) then
		FOnError(Self, aError);
end;

{ FD_ACCEPT handler }
procedure TAsyncSocket.MsgAccept(const aError: word);
begin
	{ Virtual }
end;

{ FD_CONNECT handler. }
procedure TAsyncSocket.MsgConnect(const aError: word);
begin
	{ Virtual }
end;

{ FD_READ handler. }
procedure TAsyncSocket.MsgRead(const aError: word);
begin
	{ Virtual }
end;

{ FD_WRITE handler. }
procedure TAsyncSocket.MsgWrite(const aError: word);
begin
	{ Virtual }
end;

{ FD_CLOSE handler. }
procedure TAsyncSocket.MsgClose(const aError: word);
begin
	{ Virtual }
end;

{ Forwards windows socket messages to TAsyncSocket instances. }
class function TAsyncSocket.WndProc(aHwnd: HWND; aMsg: UINT; aWPar: WPARAM; aLPar: LPARAM): LRESULT;
var
	sock: TAsyncSocket;
begin
	if (aMsg = UINT(FSckMsg)) then
	begin
		sock := TAsyncSocket.FSckLst.Get(aWPar);
		if (sock = nil) then
			Exit( - 1)
		else
			Result := 0;

		sock.Lock;
		case WSAGetSelectEvent(aLPar) of
			FD_ACCEPT:
			sock.MsgAccept(WSAGetSelectError(aLPar));
			FD_CONNECT:
			sock.MsgConnect(WSAGetSelectError(aLPar));
			FD_READ:
			sock.MsgRead(WSAGetSelectError(aLPar));
			FD_WRITE:
			sock.MsgWrite(WSAGetSelectError(aLPar));
			FD_CLOSE:
			sock.MsgClose(WSAGetSelectError(aLPar));
		end;
		sock.Unlock;
	end
	else if (aMsg = WM_TIMER) then
	begin
		sock := TAsyncSocket.FSckLst.Get(aWPar);
		if (sock = nil) then
			Exit( - 1)
		else
			Result := 0;
		sock.MsgTimer(aWPar);
	end
	else
		Result := DefWindowProc(aHwnd, aMsg, aWPar, aLPar);
end;

{ ===================== }
{ TCustomAsyncTCPClient }
{ ===================== }

{ Constructor. }
constructor TCustomAsyncTCPClient.Create(aOwner: TComponent);
begin
	inherited;

    // Create and link the Proxy chain.
	FProxyChain                  := TProxyChain.Create(Self);
	FProxyChain.OnConnecting     := EventProxyConnecting;
	FProxyChain.OnDataForSocket  := EventProxyHave;
	FProxyChain.OnConnected      := EventProxyConnected;
	FProxyChain.OnChainConnected := EventProxyChainConnected;
	FProxyChain.OnLog            := EventProxyLog;
	FProxyChain.OnError          := EventProxyError;

    // Create and link SSL object.
	FSSL                 := TSSLFilter.Create;
	FSSL.OnLog           := EventSSLLog;
	FSSL.OnError         := EventSSLError;
	FSSL.OnDataDecrypted := EventSSLDataDecrypted;
	FSSL.OnDataEncrypted := EventSSLDataEncrypted;

    // Initialize vars.
	FConnectTimeout := 60000;
	FTimerMode      := tmOff;
end;

{ Destructor. }
destructor TCustomAsyncTCPClient.Destroy;
begin
	Disconnect;
	FSSL.Free;
	FProxyChain.Free;
	inherited;
end;

{ Assign. }
procedure TCustomAsyncTCPClient.Assign(aSource: TPersistent);
begin
	inherited;

	if (aSource is TCustomAsyncTCPClient) then
	begin
		ProxyChain.Assign(TCustomAsyncTCPClient(aSource).ProxyChain);
		SSL.Assign(TCustomAsyncTCPClient(aSource).SSL);

		RemoteHost     := TCustomAsyncTCPClient(aSource).RemoteHost;
		RemotePort     := TCustomAsyncTCPClient(aSource).RemotePort;
		ConnectTimeout := TCustomAsyncTCPClient(aSource).ConnectTimeout;

		OnConnecting          := TCustomAsyncTCPClient(aSource).OnConnecting;
		OnProxyConnecting     := TCustomAsyncTCPClient(aSource).OnProxyConnecting;
		OnProxyConnected      := TCustomAsyncTCPClient(aSource).OnProxyConnected;
		OnProxyChainConnected := TCustomAsyncTCPClient(aSource).OnProxyChainConnected;
		OnConnectTimeout      := TCustomAsyncTCPClient(aSource).OnConnectTimeout;
		OnConnected           := TCustomAsyncTCPClient(aSource).OnConnected;
		OnDataAvailable       := TCustomAsyncTCPClient(aSource).OnDataAvailable;
		OnDisconnected        := TCustomAsyncTCPClient(aSource).OnDisconnected;
	end;
end;

{ Cycles to next address in resolved address pool for connect procedure. If exhausted, throws an error. }
function TCustomAsyncTCPClient.ConnectCycleAddressPool: boolean;
begin
	FCurrentAddress := FCurrentAddress^.ai_next;

    // If we exhausted all addresses in pool, then connect failed.
	if (FCurrentAddress = nil) then
	begin
		Result := False;
		HandleError( - 2, 'Connect failed.');
	end
	else
	begin
		Result := True;
		ConnectToCurrentAddress;
	end;
end;

{ Tries to connect to next address in address pool. }
procedure TCustomAsyncTCPClient.ConnectToCurrentAddress;
var
	ret: integer;
begin
	// Set connect timeout timer.
	FTimerMode := tmConnectTimeout;
	TimerStart(Socket, FConnectTimeout);

	// Issue a Connect on current address in pool and wait for EventConnect().
    // We can't use HandleError() here because we might still have addresses in
    // pool to try and connect to if current one failed

	ret := EvilWorks.Api.Winsock2.Connect(Socket, FCurrentAddress^.ai_addr, FCurrentAddress^.ai_addrlen);
	if (ret = SOCKET_ERROR) and (WSAGetLastError <> WSAEWOULDBLOCK) then
	begin
		TimerStop(Socket);

        // Try next in pool.
		if (ConnectCycleAddressPool = False) then
			Exit;
	end;
end;

{ Connect to Host:Port }
procedure TCustomAsyncTCPClient.Connect;
begin
	// Do basic checks.

	if (SocketState <> ssDisconnected) then
	begin
		HandleError( - 2, 'Cannot connect, busy.');
		Exit;
	end;

	if (RemoteHost = CEmpty) then
	begin
		HandleError( - 2, 'RemoteHost not specified.');
		Exit;
	end;

	if (RemotePort = CEmpty) then
	begin
		HandleError( - 2, 'RemotePort not specified.');
		Exit;
	end;

	CreateSocket(stStream);
end;

{ Connect to aHost:aPort }
procedure TCustomAsyncTCPClient.Connect(const aHost, aPort: string);
begin
	// Do basic checks.

	if (SocketState <> ssDisconnected) then
	begin
		HandleError( - 2, 'Cannot connect, busy.');
		Exit;
	end;

	if (aHost = CEmpty) then
	begin
		HandleError( - 2, 'RemoteHost not specified.');
		Exit;
	end;

	if (aPort = CEmpty) then
	begin
		HandleError( - 2, 'RemotePort not specified.');
		Exit;
	end;

	RemoteHost := aHost;
	RemotePort := aPort;
	Connect;
end;

{ Disconnect the socket. }
procedure TCustomAsyncTCPClient.Disconnect;
begin
	// Already disconnected, exit.
	if (SocketState = ssDisconnected) then
		Exit;

    // We are waiting for resolve thread. Mark as disconnecting
    // for when the thread finishes.
	if (SocketState = ssResolvingConnect) and (csDestroying in ComponentState = False) then
	begin
		SetSocketState(ssDisconnecting);
		Exit;
	end;

	FSSL.Disconnect;
	FreeAddrPool(FAddress);
	FTimerMode := tmOff;

    // Normal disconnect or via error.
	if (SocketState = ssConnected) then
	begin
		DestroySocket;
		EventDisconnect;
	end
	else
		DestroySocket;
end;

{ Send data to the peer. }
function TCustomAsyncTCPClient.Send(const aData: pointer; const aSize: integer): integer;
begin
	if (SocketState <> ssConnected) then
		Exit(0);

	if (SSL.Enabled) and (FProxyChain.NeedsHandshake = False) then
	begin
		Result := SSL.EncryptData(aData, aSize);
	end
	else
	begin
		Result := EvilWorks.Api.Winsock2.Send(Socket, aData^, aSize, 0);
		if (HandleError(Result, 'send() failed.') = False) then
			Exit;
	end;
end;

{ Sends a string to the peer. }
function TCustomAsyncTCPClient.SendString(const aString: string): integer;
var
	s: UTF8String;
begin
	s      := UTF8Encode(aString);
	Result := Send(@s[1], Length(s));
end;

{ Sends a string terminated with carriage-return+line-feed. }
function TCustomAsyncTCPClient.SendLine(const aLine: string): integer;
begin
	Result := SendString(aLine + CCrLf);
end;

{ Receive data from socket. Call this only after OnDataAvailable. }
function TCustomAsyncTCPClient.Recv(const aData: pointer; const aSize: integer): integer;
begin
	if (SocketState <> ssConnected) then
		Exit(0);

	if (SSL.Enabled) and (FProxyChain.NeedsHandshake = False) then
	begin
		Result := FSSL.ReadDecrypted(aData, aSize);
		Exit;
	end;

	Result := EvilWorks.Api.Winsock2.Recv(Socket, aData^, aSize, 0);
	HandleError(Result, 'recv() failed.');
end;

{ Receives data as string. Received data might be partial, and the string as well.. }
function TCustomAsyncTCPClient.RecvString: string;
const
	BUFFER_SIZE = 4096;
var
	len: u_long;
	buf: pointer;
	ret: integer;
	str: string;
begin
	if (SocketState <> ssConnected) then
		Exit(CEmpty);

	if (SSL.Enabled) then
	begin
		str := '';
		repeat
			buf := AllocMem(BUFFER_SIZE);
			ret := Recv(buf, BUFFER_SIZE);
			if (ret < 0) then
			begin
				Result := CEmpty;
				FreeMem(buf);
				Break;
			end;
			SetString(str, pansichar(buf), ret);
			FreeMem(buf);
			Result := Result + str;
		until (ret = 0);
	end
	else
	begin
		ret := ioctlsocket(Socket, FIONREAD, len);
		if (HandleError(ret, 'RecvString(): ioctlsocket() failed.') = False) then
			Exit;

		buf := AllocMem(len);
		ret := Recv(buf, len);
		SetString(Result, pansichar(buf), ret);
		FreeMem(buf);
	end;
end;

{ Checks if the error return value of a Winsock function is non-passable. }
{ Returns True if handled, False if fatal error. pass -2 to aErr to }
{ force a Fail, handle the cleanup and pass the aError on.}
function TCustomAsyncTCPClient.HandleError(const aErr: integer; const aError: string): boolean;
begin
	if (aErr = SOCKET_ERROR) then
		Result := (WSAGetLastError = WSAEWOULDBLOCK)
	else if (aErr = - 2) then
		Result := False
	else
		Exit(True);

	Disconnect;
	inherited;
end;

{ FD_CONNECT event. }
procedure TCustomAsyncTCPClient.MsgConnect(const aError: word);
begin
	inherited;

    // If Disconnect() was called between Connect() and EventConnect()
    // disconnect the socket.
	if (SocketState = ssDisconnecting) then
	begin
		Disconnect;
		Exit;
	end;

    // We can't use HandleError() here because we might still have addresses in
    // pool to try and connect to if current one failed to connect and returned an error.
	if (aError <> 0) and (aError <> WSAEWOULDBLOCK) then
	begin
		TimerStop(Socket);

		EventError('Error connecting: ' + TextRemoveLineFeeds(GetWinsockErrorText(aError)));

        // Try switching to next address in pool, exit if no more.
        // ConnectCycleAddressPool() does the cleanup.
		if (ConnectCycleAddressPool = False) then
			Exit;
	end
	else
	begin
        // Connected OK.
		TimerStop(Socket);

        // Check if we are connecting over proxy and start the handshake if needed.
		if (FProxyChain.NeedsHandshake) then
		begin
			FProxyChain.StartHandshake;
			Exit;
		end;

        // Set SSL connect/accept state. SSL negotiation will be done
        // as soon as we send first data. See TSSLFilter class. If the
        // owner is TCustomAsyncTCPServer we have been created by it
        // as a result of an Accept event.
		if (FSSL.Enabled) then
			FSSL.Connect;

        // At this point we're ready to communicate. Mark as connected...
		SetSocketState(ssConnected);

        // ... and fire connect event.
		EventConnect;
	end;
end;

{ FD_READ event. }
procedure TCustomAsyncTCPClient.MsgRead(const aError: word);
var
	buf: pointer;
	len: u_long;
	ret: integer;
begin
	inherited;

    // FD_READ *could* occur after FD_CLOSE, and it will probably be with 0 bytes
    // cause of what we do in EventDisconnect, check that method.
	if (SocketState <> ssConnected) then
		Exit;

	ret := ioctlsocket(Socket, FIONREAD, len);
	if (HandleError(ret, 'EventRead(): ioctlsocket() failed.') = False) then
		Exit;

    // If proxy chain needs handshake data, notify it and exit.
	if (FProxyChain.NeedsHandshake) then
	begin
		buf := GetMemory(len);
		try
			ret := EvilWorks.Api.Winsock2.recv(Socket, buf^, len, 0);
			if (HandleError(ret, 'EventRead(): recv() failed.') = False) then
				Exit;
			FProxyChain.DataForProxy(buf, len);
			Exit;
		finally
			FreeMem(buf);
		end;
	end;

	// If SSL is enabled, we need to send the data to SSL object to be processed.
    // SSL will Fire EventSSLDataDecrypted when decrypted data is available.
	if (FSSL.Enabled) then
	begin
		buf := GetMemory(len);
		try
			ret := EvilWorks.Api.Winsock2.recv(Socket, buf^, len, 0);
			if (HandleError(ret, 'EventRead(): recv() failed.') = False) then
				Exit;

            // Append to SSL decrypt buffer.
			SSL.DecryptData(buf, len);

            // If we didn't read out everything, loop?
			if (ret < integer(len)) then
				MsgRead(0);
		finally
			FreeMem(buf);
		end;

		Exit;
	end;

	// ...else, send it to appliction.
	EventDataAvailable(len);
end;

{ FD_CLOSE event. }
procedure TCustomAsyncTCPClient.MsgClose(const aError: word);
var
	ret: integer;
	len: u_long;
	dif: u_long;
begin
	inherited;

    // From MSDN:
    // FD_CLOSE should only be posted after all data is read from a socket, but an application
    // should check for remaining data upon receipt of FD_CLOSE to avoid any possibility of losing data.
    //
    // In other words, it's possible you get FD_READ *after* FD_CLOSE, meaning there's still data on socket
    // even tho you receive a disconnect event first.
	while (True) do
	begin
    	// Check if socket is still valid, if it is, check for data on socket.
		ret := ioctlsocket(Socket, FIONREAD, len);
		if (ret = SOCKET_ERROR) and (WSAGetLastError = WSAENOTSOCK) then
			Break;

		if (HandleError(ret, 'EventDisconnect(): ioctlsocket() failed.') = False) then
			Exit;

        // If there's some data on socket do the read event.
		if (len > 0) then
			MsgRead(0)
		else
			Break;

        // Check again for data on socket after we fired onData.
		ret := ioctlsocket(Socket, FIONREAD, dif);
		if (ret = SOCKET_ERROR) and (WSAGetLastError = WSAENOTSOCK) then
			Break;

		if (HandleError(ret, 'EventDisconnect(): ioctlsocket() failed.') = False) then
			Exit;

        // If something was read, continue loop.
        // If nothing was read, break to avoid infinite loop.
		if (dif = len) then
			Break;
	end;

	Disconnect;
	if (aError <> 0) then
		EventError('Disconnected: ' + GetWinsockErrorText(aError));
end;

{ Event from WndProc. Socket connected. }
procedure TCustomAsyncTCPClient.EventConnect;
begin
	if (Assigned(FOnConnected)) then
		FOnConnected(Self);
end;

{ }
procedure TCustomAsyncTCPClient.EventConnecting;
begin
	if (Assigned(FOnConnecting)) then
		FOnConnecting(Self);
end;

{ Event from WndProc. Socket disconnected. }
procedure TCustomAsyncTCPClient.EventDisconnect;
begin
	if (Assigned(FOnDisconnected)) then
		FOnDisconnected(Self);
end;

{ Handle Timer messages. For connect timeout and retry delay.}
procedure TCustomAsyncTCPClient.MsgTimer(const aTimerID: cardinal);
begin
	inherited;

	if (FTimerMode = tmConnectTimeout) then
	begin
		TimerStop(Socket);
		if (Assigned(FOnConnectTimeout)) then
			FOnConnectTimeout(Self);
		if (ConnectCycleAddressPool = False) then
			Exit;
	end;
end;

{ TAsyncResolver OnResolved handler. }
procedure TCustomAsyncTCPClient.EventTargetAddressResolved(const aAddrPool: PAddrInfo; const aError: integer);
var
	p: PAddrInfo;
	c: integer;
begin
    // We are waiting for resolve thread to free the socket.
    // See Disconnect() method.
	if (SocketState = ssDisconnecting) then
	begin
		Disconnect;
		Exit;
	end;

    // Advance the socket state.
	SetSocketState(ssConnecting);

	// An error occured during resolving, fail.
	if (aError <> 0) then
	begin
		HandleError( - 1, 'Resolve failed');
		Exit;
	end;

    // Get number of addresses resolved.
	c := 0;
	p := aAddrPool;
	while (p <> nil) do
	begin
		Inc(c);
		p := p^.ai_next;
	end;

	EventResolved(c, False);

    // Now start the actual connect process.
	FAddress        := aAddrPool; // Save the resolved address.
	FCurrentAddress := FAddress;  // Set the connect-to pointer to first address in pool.
	if (Assigned(FOnConnecting)) then
		FOnConnecting(Self);
	ConnectToCurrentAddress; // Now start connecting to addresses.
end;

{ Fires after CreateSocket() has finished creating, resolving BindHost and bound the socket to the address. }
procedure TCustomAsyncTCPClient.EventSocketCreated(const aError: integer);
var
	Host, Port: string;
	ret       : integer;
begin
	inherited;

    // Set socket to async mode
	ret := SetSocketMessages(FD_CONNECT or FD_READ or FD_CLOSE);
	if (HandleError(ret, 'WSAAsyncSelect failed.') = False) then
		Exit;

	// Resolve the right address. If Proxy chain is enabled, get address of
    // first proxy in chain to resolve and connect to, otherwise, our RemoteHost.
	SetSocketState(ssResolvingConnect);
	if (FProxyChain.GetTCPConnectAddr(Host, Port)) then
	begin
		FProxyChain.ResetHandshake; // Reset ProxyChain before connect.
		ResolveAddress(Host, Port, AddressFamily, stStream, EventTargetAddressResolved);
	end
	else
		ResolveAddress(RemoteHost, RemotePort, AddressFamily, stStream, EventTargetAddressResolved);
end;

{ Data available event for descendants, instead of EventRead. }
procedure TCustomAsyncTCPClient.EventDataAvailable(const aSize: integer);
begin
	if (Assigned(FOnDataAvailable)) then
		FOnDataAvailable(Self, aSize);
end;

{ TProxyChain OnHaveForSocket handler. Proxy has data to send. }
procedure TCustomAsyncTCPClient.EventProxyHave(aSender: TProxyConnector; const aData: pByte; const aSize: integer; var aResult: integer);
var
	ret: integer;
begin
	ret     := EvilWorks.Api.Winsock2.send(Socket, aData^, aSize, 0);
	aResult := ret;
	if (HandleError(ret, 'EventProxyHave(): send() failed.') = False) then
		Exit;
end;

{ TProxyChain OnConnecting handler. A proxy in chain is connnecting. }
procedure TCustomAsyncTCPClient.EventProxyConnecting(aSender: TProxyConnector; const aHost, aPort: string; const aProxyType: TProxyType);
begin
	if (Assigned(FOnProxyConnecting)) then
		FOnProxyConnecting(aSender, aHost, aPort, aProxyType);
end;

{ TProxyChain OnConnected handler. A proxy in chain connected. }
procedure TCustomAsyncTCPClient.EventProxyConnected(aSender: TProxyConnector);
begin
	TimerStop(Socket);
	TimerStart(Socket, FConnectTimeout);
	if (Assigned(FOnProxyConnected)) then
		FOnProxyConnected(aSender);
end;

{ TProxyChain OnChainConnected handler. The whole proxy chain handshake is complete. }
procedure TCustomAsyncTCPClient.EventProxyChainConnected(aSender: TProxyChain);
begin
	if (Assigned(FOnProxyChainConnected)) then
		FOnProxyChainConnected(Self);
	EventConnect;
end;

{ TProxyChain Onlog handler. }
procedure TCustomAsyncTCPClient.EventProxyLog(aSender: TObject; const aText: string);
begin
	EventLog(aSender, aText);
end;

{ TProxyChain OnError handler. }
procedure TCustomAsyncTCPClient.EventProxyError(aSender: TProxyConnector; const aError: string);
begin
	HandleError( - 2, 'ProxyChain error: ' + aError);
end;

{ Get data for giving to application. }
procedure TCustomAsyncTCPClient.EventSSLDataDecrypted(aSender: TSSLFilter; const aDataSize: integer);
begin
	EventDataAvailable(aDataSize);
end;

{ Get data for sending via socket. }
procedure TCustomAsyncTCPClient.EventSSLDataEncrypted(aSender: TSSLFilter; const aDataSize: integer);
var
	buf: pointer;
	ret: integer;
begin
	buf := GetMemory(aDataSize);
	try
		ret := FSSL.ReadEncrypted(buf, aDataSize);
		if (HandleError(ret, 'EventSSLDataEncrypted(): SSL.ReadEncrypted() failed.') = False) then
			Exit;

		ret := EvilWorks.Api.Winsock2.Send(Socket, buf^, ret, 0);
		if (HandleError(ret, 'EventSSLDataEncrypted(): send() failed.') = False) then
			Exit;

    	// If there's more, please take it.
		if (ret < aDataSize) then
			EventSSLDataEncrypted(aSender, aDataSize - ret);
	finally
		FreeMem(buf);
	end;
end;

{ SSL OnLog handler. }
procedure TCustomAsyncTCPClient.EventSSLLog(aSender: TObject; const aText: string);
begin
	EventLog(aSender, aText);
end;

{ SSL OnError handler. }
procedure TCustomAsyncTCPClient.EventSSLError(aSender: TSSLFilter; const aErrorText: string);
begin
	HandleError( - 2, 'SSL error: ' + aErrorText);
end;

{ ProxyChain setter. }
procedure TCustomAsyncTCPClient.SetProxyChain(const aValue: TProxyChain);
begin
	FProxyChain.Assign(aValue);
end;

{ SSL setter. }
procedure TCustomAsyncTCPClient.SetSSL(const aValue: TSSLFilter);
begin
	if (SocketState <> ssDisconnected) then
		Exit;
	FSSL.Assign(aValue);
end;

{ ConnectTimeout setter. }
procedure TCustomAsyncTCPClient.SetConnectTimeout(const Value: cardinal);
begin
	if (FConnectTimeout = Value) then
		Exit;
	FConnectTimeout := Value;
	if (FConnectTimeout > 60000) then
		FConnectTimeout := 60000;
end;

{ RemoteHost setter. }
procedure TCustomAsyncTCPClient.SetRemoteHost(const Value: string);
begin
	if (FRemoteHost = Value) then
		Exit;
	FRemoteHost := Value;
end;

{ RemotePort setter. }
procedure TCustomAsyncTCPClient.SetRemotePort(const Value: string);
begin
	if (FRemotePort = Value) then
		Exit;
	FRemotePort := Value;
end;

end.
