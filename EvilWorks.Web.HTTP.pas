//
// EvilLibrary by Vedran Vuk 2010-2012
//
// Name: 					EvilWorks.Web.HTTP
// Description: 			HTTP Client.
// File last change date:   October 21st. 2012
// File version: 			Dev 0.0.0
// Licence:                 Free.
//

{ TODO: Implement request octet-stream type sending. }
{ TODO: Implement gzip/deflate for posting/requests. }

unit EvilWorks.Web.HTTP;

interface

uses
	Winapi.Windows,
	System.Classes,
	System.SysUtils,
	EvilWorks.Api.Winsock2,
	EvilWorks.Api.ZLib,
	EvilWorks.System.SysUtils,
	EvilWorks.System.StrUtils,
	EvilWorks.System.DateUtils,
	EvilWorks.Web.Utils,
	EvilWorks.Web.AsyncSockets,
	EvilWorks.Web.Base64,
	EvilWorks.Web.URI,
	EvilWorks.Crypto.HMAC_SHA1;

const
	{ HTTP header fields }
	CAccept           = 'Accept';
	CAcceptCharset    = 'Accept-Charset';
	CAcceptEncoding   = 'Accept-Encoding';
	CAcceptLanguage   = 'Accept-Language';
	CAuthorization    = 'Authorization';
	CConnection       = 'Connection';
	CContentEncoding  = 'Content-Encoding';
	CContentLength    = 'Content-Length';
	CContentType      = 'Content-Type';
	CHost             = 'Host';
	CTransferEncoding = 'Transfer-Encoding';
	CUserAgent        = 'User-Agent';

    { OAuth parameters }
	COAuthConsumerKey     = 'oauth_consumer_key';
	COAuthNonce           = 'oauth_nonce';
	COAuthSignature       = 'oauth_signature';
	COAuthSignatureMethod = 'oauth_signature_method';
	COAuthTimestamp       = 'oauth_timestamp';
	COAuthToken           = 'oauth_token';
	COAuthVersion         = 'oauth_version';

    { OAuth signature methods }
	CHMACSHA1 = 'HMAC-SHA1';

    { OAuth versions}
	C1Point0 = '1.0';

	{ Authorization values }
	CBasic = 'basic';
	COAuth = 'OAuth';

    { Transfer-Encoding values }
	CChunked = 'chunked';

    { Connection values }
	CClose     = 'close';
	CKeepALive = 'keep-alive';

    { Content-Encoding values }
	CDeflate = 'deflate';
	CGZip    = 'gzip';

    { Content-Type values }
	CContentTypeForm        = 'application/x-www-form-urlencoded';
	CContentTypeOctetStream = 'application/octet-stream';
	CContentTypeJSON        = 'application/json';

	{ THTTPMethods }
	THTTPMethods: array [0 .. 8] of string = (
	  'HEAD', 'GET', 'POST', 'OPTIONS', 'TRACE', 'PUT', 'DELETE', 'CONNECT', 'UPDATE'
	  );

    { THTTPVersions }
	THTTPVersions: array [0 .. 1] of string = (
	  'HTTP/1.0', 'HTTP/1.1'
	  );

type
	{ Forward declarations. }
	THTTPAuthorization  = class;
	THTTPContentDecoder = class;
	TCustomHTTPClient   = class;

	{ THTTPMethod }
	THTTPMethod = (hmHead, hmGet, hmPost, hmOptions, hmTrace, hmPut, hmDelete, hmConnect);

    { THTTPVersion }
	THTTPVersion = (hv10, hv11);

    { THTTPClientOption }
	THTTPClientOption = (
	  hcoAllowResponseWithoutMessage,  // Allow responses without an HTTP message (Some REST APIs).
	  hcoExpectResponseWithoutMessage, // For streaming REST APIs. Does not parse response, only returns data.
	  hcoReceiveExtraData,             // Receive data that exceeds Content-Length.
	  hcoCombineChunks,                // Combine chunked transfer. For small responses like JSON. Extremely slow and memory hungry with big responses and should be avoided.
	  hcoEnableCompression             // Enable gzip and/or deflate compression.
	  );
	THTTPClientOptions = set of THTTPClientOption;

    { THTTPRequestLine }
    { First line in an HTTP request message, e.g. "GET /path/to/file.json HTTP/1.1" }
	THTTPRequestLine = class(TPersistent)
	private
		FVersion: string;
		FPath   : string;
		FMethod : string;
		FValid  : boolean;
		FURI    : string;
	public
		procedure Assign(aSource: TPersistent); override;
	public
		procedure Parse(const aText: string);
		function AsString: string;
		function AsStringCRLF: string;
		procedure Clear;
	public
		property URI: string read FURI write FURI;

		property Method : string read FMethod write FMethod;
		property Path   : string read FPath write FPath;
		property Version: string read FVersion write FVersion;

		property Valid: boolean read FValid write FValid;
	end;

    { THTTPStatusLine }
    { First line in an HTTP response message, e.g. "HTTP/1.1 200 OK" }
	THTTPStatusLine = class(TPersistent)
	private
		FVersion: string;
		FCode   : string;
		FComment: string;
		FValid  : boolean;
	public
		procedure Assign(aSource: TPersistent); override;
	public
		procedure Parse(const aText: string);
		function AsString: string;
		function AsStringCRLF: string;
		procedure Clear;
	public
		property Version: string read FVersion write FVersion;
		property Code   : string read FCode write FCode;
		property Comment: string read FComment write FComment;

		property Valid: boolean read FValid write FValid;
	end;

    { THTTPHeaderLine }
    { A "Key: Value" header in an HTTP message. e.g. "Accept: */*" }
	THTTPHeaderLine = class(TPersistent)
	private
		FKey  : string;
		FVal  : string;
		FValid: boolean;
	public
		procedure Assign(aSource: TPersistent); override;
	public
		procedure Parse(const aText: string);
		function AsString: string;
		function AsStringCRLF: string;
		procedure Clear;
	public
		property Key: string read FKey write FKey;
		property Val: string read FVal write FVal;

		property Valid: boolean read FValid write FValid;
	end;

    { THTTPMessage }
    { An HTTP message containing a request|response header and a list of HTTP headers. }
	THTTPMessage = class(TPersistent)
	public type
		THTTPMessageType = (htUndefined, htRequest, htResponse);
	private
		FItems          : array of THTTPHeaderLine;
		FCount          : integer;
		FMessageType    : THTTPMessageType;
		FRequestHeader  : THTTPRequestLine;
		FResponseHeader : THTTPStatusLine;
		FPostData       : TStream;
		FPostDataIsLocal: boolean;
		function Find(const aKey: string): integer;
		function GetItem(const aIndex: integer): THTTPHeaderLine;
		procedure SetItem(const aIndex: integer; const aValue: THTTPHeaderLine);
		procedure SetRequestHeader(const aValue: THTTPRequestLine);
		procedure SetResponseHeader(const aValue: THTTPStatusLine);
		function GetValidRequest: boolean;
		function GetValidresponse: boolean;
	public
		constructor Create;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;
	public
		procedure Parse(const aText: string);
		function AsString: string;

		procedure Add(const aKey, aVal: string); overload;
		procedure Add(const aText: string); overload;
		procedure DelKey(const aKey: string);
		procedure DelVal(const aKey: string);
		procedure Clear;

		function Val(const aKey: string): string;
		property Items[const aIndex: integer]: THTTPHeaderLine read GetItem write SetItem; default;
		property Count: integer read FCount;

		property MessageType: THTTPMessageType read FMessageType write FMessageType;
		property RequestHeader: THTTPRequestLine read FRequestHeader write SetRequestHeader;
		property ResponseHeader: THTTPStatusLine read FResponseHeader write SetResponseHeader;
		property ValidRequest: boolean read GetValidRequest;
		property ValidResponse: boolean read GetValidResponse;
		property PostData: TStream read FPostData write FPostData;
		property PostDataIsLocal: boolean read FPostDataIsLocal write FPostDataIsLocal;
	end;

    { THTTPAuth }
    { Base Authorization type-specific class. }
	THTTPAuth = class(TPersistent)
	private
		FAuthorization: THTTPAuthorization;
	protected
		procedure AuthorizeRequest(var aRequest: THTTPMessage); virtual; abstract;
	public
		constructor Create(aOwner: THTTPAuthorization); virtual;
	end;

    { THTTPAuthBasic }
    { Implements "Authorization: basic <signature>" header. }
	THTTPAuthBasic = class(THTTPAuth)
	private
		FPassword: string;
		FUsername: string;
	protected
		procedure AuthorizeRequest(var aRequest: THTTPMessage); override;
	public
		procedure Assign(aSource: TPersistent); override;
	published
		property Username: string read FUsername write FUsername;
		property Password: string read FPassword write FPassword;
	end;

    { THTTPAuthOAuth1Mode }
    { Type of OAuth1.0 signing performed on an HTTP request. }
	THTTPAuthOAuth1Mode = (
	  hao3Step, // If you have 2 public and secret oauth tokens after performing 3step auth on behalf of a user.
	  hao4Keys  // If you have all 4 tokens; public + secret for both consumer and user. (Usually devs only).
	  );

    { THTTPAuthOAuth1 }
    { Implements "Authorization: OAuth <oauth_params>" (v1.0a) Authorization header. }
    { 3-step authentication process is not directly implemented in THTTPClient/THTTPOAuth1. }
    { You will have to do the authentication flow manually to obtain oauth_token and oauth_token_secret. }
    { This is because of the browser involvement and redirection required in this process. }
	THTTPAuthOAuth1 = class(THTTPAuth)
	private
		FMode             : THTTPAuthOAuth1Mode;
		FOAuthTokenSecret : string;
		FOAuthToken       : string;
		FConsumerKeySecret: string;
		FAccessTokenPublic: string;
		FAccessTokenSecret: string;
		FConsumerKeyPublic: string;
	protected
		procedure AuthorizeRequest(var aRequest: THTTPMessage); override;
	public
		constructor Create(aOwner: THTTPAuthorization); override;
		procedure Assign(aSource: TPersistent); override;
	published
		property AccessTokenPublic: string read FAccessTokenPublic write FAccessTokenPublic;
		property AccessTokenSecret: string read FAccessTokenSecret write FAccessTokenSecret;
		property ConsumerKeyPublic: string read FConsumerKeyPublic write FConsumerKeyPublic;
		property ConsumerKeySecret: string read FConsumerKeySecret write FConsumerKeySecret;

		property Mode: THTTPAuthOAuth1Mode read FMode write FMode default hao3Step;

		property OAuthToken      : string read FOAuthToken write FOAuthToken;
		property OAuthTokenSecret: string read FOAuthTokenSecret write FOAuthTokenSecret;
	end;

    { THTTPAuthorizationType }
	THTTPAuthorizationType = (hatBasic, hatOAuth1);

    { THTTPAuthorization }
    { Handles HTTP Authorization header. }
	THTTPAuthorization = class(TPersistent)
	private
		FHTTPClient       : TCustomHTTPClient;
		FAuthorizationType: THTTPAuthorizationType;
		FAuth             : THTTPAuth;
		FEnabled          : boolean;
		procedure SetAuthorizationType(const aValue: THTTPAuthorizationType);
		procedure SetAuth(const Value: THTTPAuth);
	protected
		procedure AuthorizeRequest(var aRequest: THTTPMessage);
	public
		constructor Create(aOwner: TCustomHTTPClient);
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;
	published
		property AuthorizationType: THTTPAuthorizationType read FAuthorizationType write SetAuthorizationType;
		property Auth             : THTTPAuth read FAuth write SetAuth;
		property Enabled          : boolean read FEnabled write FEnabled default False;
	end;

    { TContentDecoder events. }
	TOnContentDecoderError   = procedure(aSender: THTTPContentDecoder; const aError: string) of object;
	TOnContentDecoderDecoded = procedure(aSender: THTTPContentDecoder; const aSize: integer) of object;

    { TContentDecoder }
    { Decodes raw deflate, ZLib and GZip files/response body. Acts much like TSSLFilter. }
    { Give data with Decode(), wait for OnDecoded, read with ReadDecoded(). }
	THTTPContentDecoder = class
	private
		FHTTPClient: TCustomHTTPClient;

		FStream     : TZStreamRec;
		FBuffer     : TBuffer;
		FReadBuf    : pbyte;
		FReadBufSize: integer;

		FOnDecoded: TOnContentDecoderDecoded;
		FOnError  : TOnContentDecoderError;
	protected
		procedure EventError(const aError: string);
		procedure EventDecoded(const aSize: integer);
	public
		constructor Create(aClient: TCustomHTTPClient);
		destructor Destroy; override;

		procedure Decode(const aData: pByte; const aSize: integer);
		function ReadDecoded(const aData: pByte; const aSize: integer): integer;

		property OnError: TOnContentDecoderError read FOnError write FOnError;
		property OnDecoded: TOnContentDecoderDecoded read FOnDecoded write FOnDecoded;
	end;

    { TCustomHTTPClient events. }
	TOnHeadersAvailable = procedure(aSender: TCustomHTTPClient; const aHeaders: THTTPMessage) of object;
	TOnDataAvailable    = procedure(aSender: TCustomHTTPClient; aResponse: TStream) of object;

    { TCustomHTTPClient }
	TCustomHTTPClient = class(TCustomAsyncTCPClient)
	private
        // Property variables
		FOptions       : THTTPClientOptions;
		FUserAgent     : string;
		FAcceptCharset : string;
		FAcceptLanguage: string;
		FAccept        : string;
		FAuthorization : THTTPAuthorization;

        // Request variables
        // These are initialized before each request, connected or not
        // and are initialized using ResetSession();
		FRequestHeaders: THTTPMessage; // Request message

    	// Response variables
        // These are initialized before each request, connected or not
        // and are initialized using ResetSession();
		FResponseMessage       : THTTPMessage;        // Response HTTP message.
		FResponseStream        : TStream;             // Stream provided by application in request methods.
		FResponseBuffer        : TBuffer;             // Receive buffer.
		FResponseMessageParsed : boolean;             // Flag for EventDataAvailable
		FResponseSize          : integer;             // Content-Length, as int.
		FResponseChunked       : boolean;             // Is response body chunked?
		FResponseChunkBytes    : integer;             // Bytes in the next chunk.
		FResponseContentDecoder: THTTPContentDecoder; // Name says it. Created on demand after response read.
		FResponseSkipContent   : boolean;             // If HEAD is issued, ignores Content-Length.

        // Events
		FOnRequestHeaders : TOnHeadersAvailable;
		FOnResponseHeaders: TOnHeadersAvailable;
		FOnDataAvailable  : TOnDataAvailable;
		FConnection       : string;

    	// Session functions.
		procedure ResetSession;

        // Event handlers
		procedure EventDecoderError(aSender: THTTPContentDecoder; const aError: string);
		procedure EventDecoderDataDecoded(aSender: THTTPContentDecoder; const aSize: integer);

        // Getters/setters.
		procedure SetOptions(const Value: THTTPClientOptions);
		procedure SetRequestHeaders(const aValue: THTTPMessage);
		procedure SetUserAgent(const Value: string);
		procedure SetAuthorization(const Value: THTTPAuthorization);
	protected
		procedure ConstructRequest(const aMethod: THTTPMethod; const aURI, aContentType: string; aPostData: TStream);

        // Overriden events.
		procedure EventConnect; override;
		procedure EventDataAvailable(const aSize: integer); override;

		// Introduced events.
		procedure EventRequestHeaders(aHeaders: THTTPMessage); virtual;
		procedure EventResponseHeaders(aHeaders: THTTPMessage); virtual;
		procedure EventBodyAvailable(aData: TStream); virtual;

        // Introduced properties for lowering in descendants.
		property Accept: string read FAccept write FAccept;
		property AcceptCharset: string read FAcceptCharset write FAcceptCharset;
		property AcceptLanguage: string read FAcceptLanguage write FAcceptLanguage;
		property Authorization: THTTPAuthorization read FAuthorization write SetAuthorization;
		property Connection: string read FConnection write FConnection;
		property Options: THTTPClientOptions read FOptions write SetOptions;
		property RequestHeaders: THTTPMessage read FRequestHeaders write SetRequestHeaders;
		property UserAgent: string read FUserAgent write SetUserAgent;

		// Introduced events
		property OnDataAvailable: TOnDataAvailable read FOnDataAvailable write FOnDataAvailable;
		property OnRequestHeaders: TOnHeadersAvailable read FOnRequestHeaders write FOnRequestHeaders;
		property OnResponseHeaders: TOnHeadersAvailable read FOnResponseHeaders write FOnResponseHeaders;
	public
		constructor Create(aOwner: TComponent); override;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;

		procedure Connect; override;
		procedure Disconnect; override;

        // Request methods.
		function GET(const aURI: string; aResponse: TStream): boolean;
		function POSTForm(const aURI, aFormData: string; aResponse: TStream): boolean;
		function POSTOctetStream(const aURI: string; aPostData, aResponse: TStream): boolean; overload;
	end;

    { THTTPClient }
	THTTPClient = class(TCustomHTTPClient)
	published
    	// From TCustomAsyncTCPClient
		property AddressFamily;
		property Authorization;
		property BindHost;
		property BindPort;
		property Connection;
		property ConnectTimeout;
		property ProxyChain;
		property RemoteHost;
		property RemotePort;
		property SocketState;
		property SSL;

		property OnConnected;
		property OnConnecting;
		property OnConnectTimeout;
		property OnDisconnected;
		property OnError;
		property OnLog;
		property OnProxyChainConnected;
		property OnProxyConnecting;
		property OnProxyConnected;
		property OnResolved;
		property OnResolving;

        // Introduced
		property Accept;
		property AcceptCharset;
		property AcceptLanguage;
		property Options default [hcoEnableCompression];
		property RequestHeaders;
		property UserAgent;

		property OnRequestHeaders;
		property OnResponseHeaders;
		property OnDataAvailable;
	end;

function HTTPMethodToString(const aMethod: THTTPMethod): string;

implementation

{ THTTPMethod to text. }
function HTTPMethodToString(const aMethod: THTTPMethod): string;
begin
	case aMethod of
		hmHead:
		Result := 'HEAD';
		hmGet:
		Result := 'GET';
		hmPost:
		Result := 'POST';
		hmOptions:
		Result := 'OPTIONS';
		hmTrace:
		Result := 'TRACE';
		hmPut:
		Result := 'PUT';
		hmDelete:
		Result := 'DELETE';
		hmConnect:
		Result := 'CONNECT';
	end;
end;

{ ================ }
{ THTTPRequestLine }
{ ================ }

{ Assign. }
procedure THTTPRequestLine.Assign(aSource: TPersistent);
begin
	if (aSource is THTTPRequestLine) then
	begin
		Method  := THTTPRequestLine(aSource).Method;
		Path    := THTTPRequestLine(aSource).Path;
		Version := THTTPRequestLine(aSource).Version;
	end;
end;

{ Clears the values. }
procedure THTTPRequestLine.Clear;
begin
	FURI     := '';
	FMethod  := '';
	FPath    := '';
	FVersion := '';
	FValid   := False;
end;

{ Parses an HTTP request line to property values. }
procedure THTTPRequestLine.Parse(const aText: string);
var
	tokens: TArray<string>;
	i     : integer;
begin
	// Split by space, count must be 3 for a valid request line.
	tokens := TextSplit(TextRemoveLineFeeds(aText));
	if (Length(tokens) > 3) or (Length(tokens) < 2) then
		Exit;

    // Check for known method at index 0.
	for i := 0 to high(THTTPMethods) do
	begin
		if (TextEquals(tokens[0], THTTPMethods[i])) then
		begin
			FMethod := tokens[0];
			Break;
		end;
	end;

    // If no recognized methods found, abort.
	if (FMethod = '') then
		Exit;

	FPath    := tokens[1];
	FVersion := tokens[2];
	FValid   := True;

    // Double check for valid version if exists.
	if (FVersion <> '') then
	begin
		for i := 0 to high(THTTPVersions) do
			if (TextEquals(FVersion, THTTPVersions[i])) then
				Exit;
	end
	else
		Exit;

	FMethod  := '';
	FPath    := '';
	FVersion := '';
	FValid   := False;
end;

{ Returns property values formated as an HTTP request line. }
function THTTPRequestLine.AsString: string;
begin
	if (Method = '') or (Path = '') or (Version = '') then
		Exit('');

	Result := UpperCase(Method) + ' ' + Path + ' ' + UpperCase(Version);
end;

{ Same as AsString + CR LF. }
function THTTPRequestLine.AsStringCRLF: string;
begin
	Result := AsString;
	if (Result = '') then
		Exit;
	Result := Result + #13#10;
end;

{ =============== }
{ THTTPStatusLine }
{ =============== }

{ Assign. }
procedure THTTPStatusLine.Assign(aSource: TPersistent);
begin
	if (aSource is THTTPStatusLine) then
	begin
		Version := THTTPStatusLine(aSource).Version;
		Code    := THTTPStatusLine(aSource).Code;
		Comment := THTTPStatusLine(aSource).Comment;
	end;
end;

{ Clears the values. }
procedure THTTPStatusLine.Clear;
begin
	FVersion := '';
	FCode    := '';
	FComment := '';
	Fvalid   := False;
end;

{ Parses an HTTP status line to property values. }
procedure THTTPStatusLine.Parse(const aText: string);
var
	s: string;
begin
	s        := aText;
	FVersion := TextExtractLeft(s, ' ', True);
	FCode    := TextExtractLeft(s, ' ', True);
	FComment := TextRemoveLineFeeds(s);

    // Check that code can be converted to integer.
    // If not, this is not a status line.
	if (TextToInt(FCode, - 1) = - 1) then
	begin
		FVersion := '';
		FCode    := '';
		FComment := '';
	end
	else
		FValid := True;
end;

{ Returns property values formated as an HTTP status line. }
function THTTPStatusLine.AsString: string;
begin
	if (Version = '') or (Code = '') then
		Exit('');

	Result := Version + ' ' + Code;
	if (Comment <> '') then
		Result := Result + ' ' + Comment;

	Result := Result;
end;

{ Same as AsString + CR LF. }
function THTTPStatusLine.AsStringCRLF: string;
begin
	Result := AsString;
	if (Result = '') then
		Exit;
	Result := Result + #13#10;
end;

{ =============== }
{ THTTPHeaderLine }
{ =============== }

{ Assign. }
procedure THTTPHeaderLine.Assign(aSource: TPersistent);
begin
	if (aSource is THTTPHeaderLine) then
	begin
		Key := THTTPHeaderLine(aSource).Key;
		Val := THTTPHeaderLine(aSource).Val;
	end;
end;

{ Clears THTTPHeaderLine. }
procedure THTTPHeaderLine.Clear;
begin
	FKey   := CEmpty;
	FVal   := CEmpty;
	FValid := False;
end;

{ Parses an HTTP header line. }
procedure THTTPHeaderLine.Parse(const aText: string);
begin
	FKey   := Trim(TextFetchLeft(aText, ':', True));
	FVal   := Trim(TextFetchRight(aText, ':', True));
	FValid := (FKey <> '');
end;

{ Returns the header in form of "Key: Val;" }
function THTTPHeaderLine.AsString: string;
begin
	if (Key = CEmpty) then
		Exit(CEmpty);

	Result := Key + CColon + CSpace + Val;
end;

{ Get + CRLF }
function THTTPHeaderLine.AsStringCRLF: string;
begin
	Result := AsString;
	if (Result = CEmpty) then
		Exit;
	Result := Result + CCrLf;
end;

{ ============ }
{ THTTPMessage }
{ ============ }

{ Constructor. }
constructor THTTPMessage.Create;
begin
	FMessageType    := htUndefined;
	FRequestHeader  := THTTPRequestLine.Create;
	FResponseHeader := THTTPStatusLine.Create;
	FCount          := 0;
end;

{ Destructor. }
destructor THTTPMessage.Destroy;
begin
	Clear;
	FResponseHeader.Free;
	FRequestHeader.Free;
	inherited;
end;

{ Clears/initializes the THTTPHeaders. }
procedure THTTPMessage.Assign(aSource: TPersistent);
var
	i: integer;
begin
	if (aSource is THTTPMessage) then
	begin
		Clear;
		for i := 0 to THTTPMessage(aSource).Count - 1 do
			Add(THTTPMessage(aSource)[i].Key, THTTPMessage(aSource)[i].Val);

		RequestHeader.Assign(THTTPMessage(aSource).RequestHeader);
		ResponseHeader.Assign(THTTPMessage(aSource).ResponseHeader);
	end;
end;

{ Gets the index of item whose Key matches aKey. -1 if not found. }
function THTTPMessage.Find(const aKey: string): integer;
var
	i: integer;
begin
	for i := 0 to Count - 1 do
		if (TextEquals(FItems[i].Key, aKey)) then
			Exit(i);

	Result := - 1;
end;

{ Adds aKey:aVal to list of HTTP headers. }
{ If an aKey already exists, its' value is replaced with aVal. }
procedure THTTPMessage.Add(const aKey, aVal: string);
var
	i: integer;
begin
	i := Find(aKey);
	if (i < 0) then
	begin
		Inc(FCount);
		SetLength(FItems, FCount);
		FItems[FCount - 1]      := THTTPHeaderLine.Create;
		FItems[FCount - 1].FKey := aKey;
		FItems[FCount - 1].FVal := aVal;
		Exit;
	end;

	FItems[i].Val := aVal;
end;

{ Parses aText as an HTTP message header line. }
procedure THTTPMessage.Add(const aText: string);
var
	s, k, v: string;
begin
	s := aText;
	k := Trim(TextExtractLeft(s, ':', True));
	if (k = '') then
		Exit;
	v := Trim(s);
	Add(k, v);
end;

{ Get Val of aKey. }
function THTTPMessage.Val(const aKey: string): string;
var
	i: integer;
begin
	for i := 0 to Count - 1 do
		if (TextSame(Items[i].Key, aKey)) then
			Exit(Items[i].Val);
	Result := CEmpty;
end;

{ Parse aText as a possible complete HTTP message or as just one line. }
{ aText needs to be valid by being CRLF terminated. }
{ Partial data will possibly break the parse procedure. }
procedure THTTPMessage.Parse(const aText: string);
var
	tokens: TArray<string>;
	token : string;
begin
	tokens := TextSplit(aText, CCrLf);
	for token in tokens do
	begin
		if (token = CEmpty) then
			Continue;

		if (TextBegins(token, 'HTTP')) then
			FResponseHeader.Parse(token)
		else if (TextInArray(token, THTTPMethods, False)) then
			FRequestHeader.Parse(token)
		else
			Add(token);
	end;
end;

{ Deletes an item whose Key matches aKey. }
procedure THTTPMessage.DelKey(const aKey: string);
var
	i: integer;
begin
	i := Find(aKey);
	if (i < 0) then
		Exit;

	FItems[i].Free;
	Dec(FCount);
	if (i < FCount) then
		Move(FItems[i + 1], FItems[i], (FCount - i) * SizeOf(THTTPHeaderLine));
	SetLength(FItems, FCount);
end;

{ Deletes Val of item whose Key equals aVal. }
procedure THTTPMessage.DelVal(const aKey: string);
var
	i: integer;
begin
	i := Find(aKey);
	if (i < 0) then
		Exit;

	FItems[FCount - 1].FVal := CEmpty;
end;

{ Clears the THTTPHeader. }
procedure THTTPMessage.Clear;
var
	i: integer;
begin
	for i := 0 to Count - 1 do
		Items[i].Free;
	SetLength(FItems, 0);
	FCount := 0;

	FRequestHeader.Clear;
	FResponseHeader.Clear;
	FMessageType := htUndefined;
	if (FPostDataIsLocal) then
		FPostData.Free;
	FPostData        := nil;
	FPostDataIsLocal := False;
end;

{ All headers in one string. }
function THTTPMessage.AsString: string;
var
	i: integer;
begin
	Result := '';

	case FMessageType of
		htUndefined:
		Result := '';
		htRequest:
		Result := FRequestHeader.AsStringCRLF;
		htResponse:
		Result := FResponseHeader.AsStringCRLF;
	end;

	for i      := 0 to Count - 1 do
		Result := Result + Items[i].AsStringCRLF;

	Result := Result + #13#10;

	if (FPostData <> nil) then
		if (FPostData is TStringStream) then
			Result := Result + TStringStream(FPostData).DataString;
end;

{ Items getter. }
function THTTPMessage.GetItem(const aIndex: integer): THTTPHeaderLine;
begin
	if (aIndex < 0) or (aIndex >= FCount) then
		Exit(nil);

	Result := FItems[aIndex];
end;

{ ValidRequest getter. }
function THTTPMessage.GetValidRequest: boolean;
begin
	Result := FRequestHeader.Valid;
end;

{ ValidResponse getter. }
function THTTPMessage.GetValidResponse: boolean;
begin
	Result := FResponseHeader.Valid;
end;

{ Items setter. }
procedure THTTPMessage.SetItem(const aIndex: integer; const aValue: THTTPHeaderLine);
begin
	if (aIndex < 0) or (aIndex >= FCount) then
		Exit;

	FItems[aIndex].Assign(aValue);
end;

{ RequestHeader setter. }
procedure THTTPMessage.SetRequestHeader(const aValue: THTTPRequestLine);
begin
	FRequestHeader.Assign(aValue);
end;

{ ResponseHeader setter. }
procedure THTTPMessage.SetResponseHeader(const aValue: THTTPStatusLine);
begin
	FResponseHeader.Assign(aValue);
end;

{ ========= }
{ THTTPAuth }
{ ========= }

{ Constructor. }
constructor THTTPAuth.Create(aOwner: THTTPAuthorization);
begin
	FAuthorization := aOwner;
end;

{ ============== }
{ THTTPAuthBasic }
{ ============== }

{ Assign }
procedure THTTPAuthBasic.Assign(aSource: TPersistent);
begin
	inherited;

	if (aSource is THTTPAuthBasic) then
	begin
		Username := THTTPAuthBasic(aSource).Username;
		Password := THTTPAuthBasic(aSource).Password;
	end;
end;

{ Sign/Authorize the request message. }
procedure THTTPAuthBasic.AuthorizeRequest(var aRequest: THTTPMessage);
begin
	aRequest.Add(CAuthorization, CBasic + ' ' + Base64Encode(Username + ':' + Password));
end;

{ =============== }
{ THTTPAuthOAuth1 }
{ =============== }

{ Constructor. }
constructor THTTPAuthOAuth1.Create(aOwner: THTTPAuthorization);
begin
	inherited;
	FMode := hao3Step;
end;

{ Assign }
procedure THTTPAuthOAuth1.Assign(aSource: TPersistent);
begin
	inherited;

	if (aSource is THTTPAuthOAuth1) then
	begin
		Mode              := THTTPAuthOAuth1(aSource).Mode;
		OAuthToken        := THTTPAuthOAuth1(aSource).OAuthToken;
		OAuthTokenSecret  := THTTPAuthOAuth1(aSource).OAuthTokenSecret;
		ConsumerKeyPublic := THTTPAuthOAuth1(aSource).ConsumerKeyPublic;
		ConsumerKeySecret := THTTPAuthOAuth1(aSource).ConsumerKeySecret;
		AccessTokenPublic := THTTPAuthOAuth1(aSource).AccessTokenPublic;
		AccessTokenSecret := THTTPAuthOAuth1(aSource).AccessTokenSecret;
	end;
end;

{ Sign/Authorize the request message. }
procedure THTTPAuthOAuth1.AuthorizeRequest(var aRequest: THTTPMessage);

	function GenerateNonce: string;
	begin
		Result := RandomString(42, True, True, True);
	end;

	function GenerateTimestamp: string;
	var
		utc: TSystemTime;
		t  : TDateTime;
	begin
		GetSystemTime(utc);
		t      := SystemTimeToDateTime(utc);
		Result := UIntToStr(Round((t - 25569) * 86400));
	end;

var
	tokens   : TTokens;
	temp     : string;
	nonce    : string;
	timestamp: string;
	hashData : string;
	hashKey  : string;
	digest   : T160BitDigest;
	signature: string;
	post     : TTokens;
begin
	inherited;

	nonce     := GenerateNonce;
	timestamp := GenerateTimestamp;

	{ Create HMAC-SHA1 data }

	hashData := aRequest.RequestHeader.Method + CAmpersand;

	temp := TextURIWithoutParams(aRequest.RequestHeader.URI);
	if (temp <> CEmpty) then
		hashData := hashData + URIEncode(temp) + CAmpersand;

	temp := TextURIExtractParams(aRequest.RequestHeader.URI);
	if (temp <> CEmpty) then
		tokens := TextTokenize(temp, CAmpersand)
	else
		tokens.Clear;

	tokens.Add(COAuthConsumerKey, ConsumerKeyPublic);
	tokens.Add(COAuthNonce, nonce);
	tokens.Add(COAuthSignatureMethod, CHMACSHA1);
	tokens.Add(COAuthTimestamp, timestamp);
	if (Mode = hao3Step) then
		tokens.Add(COAuthToken, OAuthToken)
	else
		tokens.Add(COAuthToken, AccessTokenPublic);
	tokens.Add(COAuthVersion, C1Point0);

	if (SameText(aRequest.Val(CContentType), CContentTypeForm)) and (aRequest.PostData <> nil) then
	begin
		post := TextTokenize(TStringStream(aRequest.PostData).DataString, CAmpersand);
		for temp in post do
			tokens.Add(temp);
	end;
	tokens.Sort;
	hashData := hashData + URIEncode(tokens.AllTokens(CAmpersand));

	FAuthorization.FHTTPClient.EventLog(Self, '** HMAC-SHA1 DATA: ');
	FAuthorization.FHTTPClient.EventLog(Self, #9 + hashData);
	FAuthorization.FHTTPClient.EventLog(Self, '');

	{ Create HMAC-SHA1 key }

	if (Mode = hao3Step) then
		hashKey := URIEncode(ConsumerKeySecret) + CAmpersand + URIEncode(OAuthTokenSecret)
	else
		hashKey := URIEncode(ConsumerKeySecret) + CAmpersand + URIEncode(AccessTokenSecret);

	FAuthorization.FHTTPClient.EventLog(Self, '** HMAC-SHA1 KEY: ');
	FAuthorization.FHTTPClient.EventLog(Self, #9 + hashKey);
	FAuthorization.FHTTPClient.EventLog(Self, CEmpty);

	{ Create HMAC-SHA1 signature }

	digest    := CalcHMAC_SHA1(ansistring(hashKey), ansistring(hashData));
	signature := Base64Encode(@digest, SizeOf(digest));

	FAuthorization.FHTTPClient.EventLog(Self, '** HMAC-SHA1 SIGNATURE: ');
	FAuthorization.FHTTPClient.EventLog(Self, #9 + signature);
	FAuthorization.FHTTPClient.EventLog(Self, CEmpty);

	{ Append OAuth field to HTTP Request }

	tokens.Clear;
	tokens.AddQ(COAuthConsumerKey, ConsumerKeyPublic);
	tokens.AddQ(COAuthNonce, nonce);
	tokens.AddQ(COAuthSignature, URIEncode(signature));
	tokens.AddQ(COAuthSignatureMethod, CHMACSHA1);
	tokens.AddQ(COAuthTimestamp, timestamp);
	if (Mode = hao3Step) then
		tokens.Add(COAuthToken, OAuthToken)
	else
		tokens.Add(COAuthToken, AccessTokenPublic);
	tokens.AddQ(COAuthVersion, C1Point0);

	aRequest.Add(CAuthorization, COAuth + CSpace + tokens.AllTokens(CComma));
end;

{ ================== }
{ THTTPAuthorization }
{ ================== }

{ Constructor. }
constructor THTTPAuthorization.Create(aOwner: TCustomHTTPClient);
begin
	FHTTPClient       := aOwner;
	FEnabled          := False;
	AuthorizationType := hatBasic;
end;

{ Destructor. }
destructor THTTPAuthorization.Destroy;
begin
	if (FAuth <> nil) then
		FAuth.Free;
	inherited;
end;

{ Assign }
procedure THTTPAuthorization.Assign(aSource: TPersistent);
begin
	if (aSource is THTTPAuthorization) then
	begin
		Enabled           := THTTPAuthorization(aSource).Enabled;
		AuthorizationType := THTTPAuthorization(aSource).AuthorizationType;
		Auth.Assign(THTTPAuthorization(aSource).Auth);
	end;
end;

{ Sign/Authorize the request message. }
procedure THTTPAuthorization.AuthorizeRequest(var aRequest: THTTPMessage);
begin
	if (FAuth = nil) or (Enabled = False) then
		Exit;
	FAuth.AuthorizeRequest(aRequest);
end;

{ AuthorizationType setter.}
procedure THTTPAuthorization.SetAuthorizationType(const aValue: THTTPAuthorizationType);
begin
	if (FAuthorizationType = aValue) and (FAuth <> nil) then
		Exit;
	if (FAuth <> nil) then
		FAuth.Free;
	FAuthorizationType := aValue;
	case FAuthorizationType of
		hatBasic:
		FAuth := THTTPAuthBasic.Create(Self);
		hatOAuth1:
		FAuth := THTTPAuthOAuth1.Create(Self);
		else
		FAuth := nil;
	end;
end;

{ Auth setter. }
procedure THTTPAuthorization.SetAuth(const Value: THTTPAuth);
begin
	FAuth.Assign(Value);
end;

{ =============== }
{ TContentDecoder }
{ =============== }

{ Constructor. Initialization code could throw an error, but this class is managed automatically. }
constructor THTTPContentDecoder.Create(aClient: TCustomHTTPClient);
begin
	FHTTPClient := aClient;

	ZeroMemory(@FStream, SizeOf(FStream));
	if (inflateInit2(FStream, 15 or 32) <> Z_OK) then
		EventError('inflateInit() failed: ' + string(FStream.msg));
	FReadBuf     := nil;
	FReadBufSize := 0;
	FBuffer.Clear;
end;

{ Destructor. }
destructor THTTPContentDecoder.Destroy;
begin
	inflateEnd(FStream);
	inherited;
end;

{ Decodes/inflates/uncompresses aData of aSize. }
procedure THTTPContentDecoder.Decode(const aData: pByte; const aSize: integer);
var
	buf: pbyte;
	len: integer;
	ret: integer;
begin
	if (aSize <= 0) or (aData = nil) then
		Exit;

	FStream.avail_in := aSize;
	FStream.next_in  := System.PByte(aData);

	len := (aSize + 255) and not 255;
	buf := GetMemory(len);
	try
		repeat
			FStream.avail_out := len;
			FStream.next_out  := buf;
			ret               := inflate(FStream, Z_NO_FLUSH);
			if (ret in [Z_OK, Z_STREAM_END] = False) then
			begin
				EventError('inflate() failed: ' + string(FStream.msg));
				Exit;
			end;
			FBuffer.Append(buf, cardinal(len) - FStream.avail_out);
			if (ret = Z_STREAM_END) then
			begin
				if (hcoCombineChunks in FHTTPClient.Options) then
					EventDecoded(FBuffer.Size)
				else
					Break;
			end;
		until (FStream.avail_out <> 0);
		if (FBuffer.Size > 0) and (hcoCombineChunks in FHTTPClient.Options = False) then
			EventDecoded(FBuffer.Size);
	finally
		FreeMem(buf);
	end;
end;

{ Read aSize of data from internal buffer to aData. }
function THTTPContentDecoder.ReadDecoded(const aData: pByte; const aSize: integer): integer;
begin
	Result := FBuffer.Consume(aData, aSize);
end;

{ OnError event caller. }
procedure THTTPContentDecoder.EventError(const aError: string);
begin
	if (Assigned(FOnError)) then
		FOnError(Self, aError);
end;

{ OnDecoded event caller. }
procedure THTTPContentDecoder.EventDecoded(const aSize: integer);
begin
	if (Assigned(FOnDecoded)) then
		FOnDecoded(Self, aSize);
end;

{ ================= }
{ TCustomHTTPClient }
{ ================= }

{ Constructor. }
constructor TCustomHTTPClient.Create(aOwner: TComponent);
begin
	inherited;
	FRequestHeaders  := THTTPMessage.Create;
	FResponseMessage := THTTPMessage.Create;
	FAuthorization   := THTTPAuthorization.Create(Self);
	FUserAgent       := 'EvilHTTP/0.1';
	Options          := [hcoEnableCompression];
	FAccept          := '*/*';
	FAcceptLanguage  := 'en';
	FAcceptCharset   := 'UTF-8,*,q=0.5';
	FConnection      := CClose;
end;

{ Destructor. }
destructor TCustomHTTPClient.Destroy;
begin
	FAuthorization.Free;
	FResponseBuffer.Clear;
	FResponseMessage.Free;
	FRequestHeaders.Free;
	inherited;
end;

{ Assign. }
procedure TCustomHTTPClient.Assign(aSource: TPersistent);
begin
	inherited;

	if (aSource is TCustomHTTPClient) then
	begin
		RequestHeaders.Assign(TCustomHTTPClient(aSource).RequestHeaders);

		UserAgent      := TCustomHTTPClient(aSource).UserAgent;
		Options        := TCustomHTTPClient(aSource).Options;
		Accept         := TCustomHTTPClient(aSource).Accept;
		AcceptLanguage := TCustomHTTPClient(aSource).AcceptLanguage;
		AcceptCharset  := TCustomHTTPClient(aSource).AcceptCharset;
		Authorization.Assign(TCustomHTTPClient(aSource).Authorization);
		RequestHeaders.Assign(TCustomHTTPClient(aSource).RequestHeaders);

		OnRequestHeaders  := TCustomHTTPClient(aSource).OnRequestHeaders;
		OnResponseHeaders := TCustomHTTPClient(aSource).OnResponseHeaders;
		OnDataAvailable   := TCustomHTTPClient(aSource).OnDataAvailable;
	end;
end;

{ Issue Connect request. }
procedure TCustomHTTPClient.Connect;
begin
	ResetSession;
	inherited;
end;

{ Disconnect. }
procedure TCustomHTTPClient.Disconnect;
begin
	inherited;
	ResetSession;
end;

{ Constructs an HTTP request message to be sent when the socket connects. }
procedure TCustomHTTPClient.ConstructRequest(const aMethod: THTTPMethod; const aURI, aContentType: string; aPostData: TStream);
var
	uriParser: TURIParser;
begin
	{ Parse URI and set up connection variables. }

	if (uriParser.Parse(aURI) = False) then
	begin
		HandleError( - 2, 'ConstructRequest(): Failed to parse URI.');
		Exit;
	end;

    { Set up remote connection properties. }

	RemoteHost := uriParser.Host;
	if (TextEquals(uriParser.Scheme, 'https')) then
	begin
		SSL.Enabled := True;
		RemotePort  := '443';
	end
	else
	begin
		SSL.Enabled := False;
		RemotePort  := '80';
	end;
	if (uriParser.Port <> CEmpty) then
		RemotePort := uriParser.Port;

    { Adjust session. }

	if (aMethod = hmHead) then
		FResponseSkipContent := True;

	if (hcoExpectResponseWithoutMessage in Options) then
		FResponseMessageParsed := True;

	{ Construct request message. }

	FRequestHeaders.Clear;
	FRequestHeaders.MessageType := htRequest;
	FRequestHeaders.PostData    := aPostData;
	if (aContentType <> '') and (aPostData <> nil) then
	begin
		FRequestHeaders.Add(CContentType, aContentType);
		FRequestHeaders.Add(CContentLength, TextFromInt(aPostData.Size));
	end;

	FRequestHeaders.RequestHeader.URI     := aURI;
	FRequestHeaders.RequestHeader.Method  := HTTPMethodToString(aMethod);
	FRequestHeaders.RequestHeader.Path    := uriParser.URIFromPath;
	FRequestHeaders.RequestHeader.Version := THTTPVersions[Ord(hv11)];
	FRequestHeaders.RequestHeader.FValid  := True;

	FRequestHeaders.Add(CHost, uriParser.HostPort);
	FRequestHeaders.Add(CConnection, FConnection);
	FRequestHeaders.Add(CAccept, FAccept);
	FRequestHeaders.Add(CAcceptCharset, FAcceptCharset);
	FRequestHeaders.Add(CAcceptLanguage, FAcceptLanguage);
	if (hcoEnableCompression in Options) then
		FRequestHeaders.Add(CAcceptEncoding, 'gzip,deflate');
 	FRequestHeaders.Add(CUserAgent, FUserAgent);
	FAuthorization.AuthorizeRequest(FRequestHeaders);
end;

{ Issue a GET request. }
function TCustomHTTPClient.GET(const aURI: string; aResponse: TStream): boolean;
begin
	Result := True;

	if (SocketState <> ssDisconnected) then
	begin
		HandleError( - 2, 'Get(): Socket busy.');
		Exit(False);
	end;

	if (aResponse = nil) then
	begin
		HandleError( - 2, 'Get(): aResponse stream cannot be nil.');
		Exit(False);
	end;

	FResponseStream := aResponse;
	FResponseStream.Seek(0, soFromBeginning);

	ConstructRequest(hmGet, aURI, '', nil);
	if (FRequestHeaders.ValidRequest = False) then
	begin
		HandleError( - 2, 'Error constructing request');
		Exit;
	end;

	Connect;
end;

{ Post application/x-www-form-urlencoded data. }
function TCustomHTTPClient.POSTForm(const aURI, aFormData: string; aResponse: TStream): boolean;
var
	postData: TStringStream;
begin
	Result := True;

	if (SocketState <> ssDisconnected) then
	begin
		HandleError( - 2, 'Post(): Socket busy.');
		Exit(False);
	end;

	if (aResponse = nil) then
	begin
		HandleError( - 2, 'Post(): aResponse stream cannot be nil.');
		Exit(False);
	end;

	FResponseStream := aResponse;
	FResponseStream.Seek(0, soFromBeginning);

	if (aFormData <> '') then
	begin
		postData := TStringStream.Create;
		postData.WriteString(aFormData);
	end
    else
    	postData := nil;

	ConstructRequest(hmPost, aURI, CContentTypeForm, postData);
	if (postData <> nil) then
		FRequestHeaders.PostDataIsLocal := True;

	if (FRequestHeaders.ValidRequest = False) then
	begin
		HandleError( - 2, 'Error constructing request');
		Exit;
	end;

	Connect;
end;

{ Issue a POST request. }
{ Send aPostData as application/octet-stream. }
function TCustomHTTPClient.POSTOctetStream(const aURI: string; aPostData, aResponse: TStream): boolean;
begin
	Result := True;

	if (SocketState <> ssDisconnected) then
	begin
		HandleError( - 2, 'Post(): Socket busy.');
		Exit(False);
	end;

	if (aResponse = nil) then
	begin
		HandleError( - 2, 'Post(): aResponse stream cannot be nil.');
		Exit(False);
	end;

	FResponseStream := aResponse;
	FResponseStream.Seek(0, soFromBeginning);

	ConstructRequest(hmPost, aURI, CContentTypeOctetStream, aPostData);
	if (aPostData <> nil) then
	begin
		aPostData.Seek(0, soFromBeginning);
		FRequestHeaders.PostDataIsLocal := False;
	end;

	if (FRequestHeaders.ValidRequest = False) then
	begin
		HandleError( - 2, 'Error constructing request');
		Exit;
	end;

	Connect;
end;

{ Prepares the HTTP session for Connect()/Frees it after Disconnect(). }
procedure TCustomHTTPClient.ResetSession;
begin
	FResponseMessageParsed := False;
	FResponseChunked       := False;
	FResponseChunkBytes    := 0;
	FResponseBuffer.Clear;
	FResponseMessage.Clear;
	if (FResponseContentDecoder <> nil) then
		FreeAndNil(FResponseContentDecoder);
end;

{ Socket connected. }
procedure TCustomHTTPClient.EventConnect;
begin
	inherited;
	EventRequestHeaders(FRequestHeaders);
	SendString(FRequestHeaders.AsString);
end;

{ Data available for reading. This is pretty much where it all happens. }
procedure TCustomHTTPClient.EventDataAvailable(const aSize: integer);
var
	buf: pByte;
	ret: integer;

    { Parses out an HTTP message from FResponseBuffer into FResponseMessage. }
    { Returns the size of the complete HTTP message if successful. }
    { Returns 0 if FResponseBuffer doesn't start with an HTTP message token/version. }
    { Returns -1 if more data needed to see if there's an HTTP message and/or parse it out. }
	function ReadMessage: integer;
	var
		a: pByte;         // String copy start marker.
		b: pByte;         // Current parse position / String copy end marker.
		i: integer;       // aSize counter.
		m: byte;          // Parse mode.
		s: rawbytestring; // Temp string.
	begin
		a := buf;
		b := buf;
		i := 0;
		m := 0;
		while (i < aSize) do
		begin
			case m of
				0:
				begin
                    // Advance copy start pointer by one char
                    // if we just extracted a header line.
					if (a^ in [13, 10]) then
						Inc(a);

                	// CR found, look for LF.
					if (b^ = 13) then
						m := 1;
				end;
				1:
				begin
                    // LF after CR found, parse out the header line,
                    // move the copy start pointer, and check for 2nd
                    // consecutive CRLF pair by going to mode 2.
					if (b^ = 10) then
					begin
                        // If this is the first CRLF pair in data let's check for
                        // valid HTTP protocol header - and bail early if it isn't.
						if (a = buf) and (i >= 4) then
						begin
							SetLength(s, 4);
							Move(a^, s[1], 4);
							if (s <> 'HTTP') then
								Exit(0);
						end;
						SetLength(s, b - a - 1);
						Move(a^, s[1], b - a - 1);
						FResponseMessage.Parse(UTF8ToString(s));
						a := b;
						m := 2;
					end
					else
					begin
                        // Not a CRLF pair, just the CR, which can be legal.
                        // Move the copy start pointer and switch back to CR search.
						a := b;
						m := 0;
						Continue;
					end;
				end;
				2:
				begin
                    // If not a start of a 2nd consecutive CRLF pair
                    // go back to single CRLF pair search.
					if (b^ <> 13) then
					begin
						m := 0;
						Continue;
					end
					else
						m := 3;
				end;
				3:
				begin
					if (b^ <> 10) then
					begin
                        // Not a double CRLF pair, just the CR, which can be legal.
                        // Move the copy start pointer and switch back to CR search.
						a := b;
						m := 0;
						Continue;
					end
					else
                        // End of HTTP header found, exit and return
                        // its size which is in i.
						Exit(i + 1);
				end;
			end; { case }
			Inc(i);
			Inc(b);
		end;

        // If we reached here, we managed to iterate over all of the data
        // without finding the CRLFCRLF - end HTTP message token.
        // So we don't have enough data yet or the data is malformed.
		Result := - 1;
	end;

    { Parses out chunk size tokens and/or chunk terminators. }
    { token = 1*HEX *[ ";" chunk-ext-name [ "=" chunk_ext_val ]] CR LF }
    { Returns the size of the next chunk if successful. Can be 0. }
    { Returns -1 if CR LF not found and more data needed to read chunk size token. }
    { Returns -2 if FResponseBuffer starts with CR LF, meaning it's a post-chunk or last-chunk terminator. }
    { Returns -3 if parse failed and/or malformed data. }
	function ReadChunkSize: integer;
	var
		p: PByte;
		i: integer;
		m: integer;
		s: rawbytestring;
	begin
		p := FResponseBuffer.Peek;
		i := 0;
		m := 0;
		while (i < FResponseBuffer.Size) do
		begin
			case m of
				0:
				begin
                	// CR found
					if (p^ = 13) then
						m := 1;
				end;
				1:
				begin
                	// LF after CR found.
					if (p^ = 10) then
					begin
						if (i = 1) then
						begin
                            // Buffer starts with CR LF, this is a chunk or last token
                            // terminator. Remove from buffer and return terminator mark.
							FResponseBuffer.Consume(nil, 2);
							Exit( - 2);
						end;
                        // Found data terminated by CR LF. Try converting data as hex to
                        // integer marking upcomming chunk size. If conversion failed
                        // return a parse error value.
						SetLength(s, i + 1);
						Move(FResponseBuffer.Peek^, s[1], i + 1);
						if (Pos(';', string(s)) > 0) then
							Result := StrToIntDef('$' + Trim(TextFetchLeft(string(s), ';')), - 3)
						else
							Result := StrToIntDef('$' + TextRemoveLineFeeds(string(s)), - 3);
						if (Result < 0) then
							Exit( - 3); // Integer overflow or corrupted data.
                        // Remove whats parsed from buffer and exit.
						FResponseBuffer.Consume(nil, i + 1);
						Exit;
					end
					else
						m := 0; // Not a LF after CR, switch back to CR search.
				end;
			end;
			Inc(p);
			Inc(i);
		end;
        // If we reached here, CRLF not found in buffer.
        // Either not enough data or data corrupted.
		Result := - 1;
	end;

    { Reads normal response body. }
	procedure ReadNormal;
	begin
		if (FResponseBuffer.Size <= 0) then
			Exit;

		if (FResponseContentDecoder <> nil) then
			FResponseContentDecoder.Decode(FResponseBuffer.Peek, FResponseBuffer.Size)
		else
		begin
			if (FResponseStream.Size > 0) then
				FResponseStream.Seek(FResponseStream.Size, soFromBeginning);
			FResponseStream.Write(FResponseBuffer.Peek^, FResponseBuffer.Size);
			EventBodyAvailable(FResponseStream);
		end;
		FResponseBuffer.Clear;
	end;

    { Reads chunked response body. }
	procedure ReadChunked;
	begin
		if (FResponseBuffer.Size = 0) then
			Exit;

        // If we don't have the size of next chunk, read it in.
		if (FResponseChunkBytes = 0) then
		begin
			FResponseChunkBytes := ReadChunkSize;
			case FResponseChunkBytes of
				- 3:
				begin
            		// Malformed data, bail.
					HandleError( - 2, 'ReadChunked(): Malformed data getting chunk size.');
					Exit;
				end;
				- 2:
				begin
                	// Post-chunk or post-last token terminator. Call
                    // ReadChunk again to see if theres more data waiting.
					FResponseChunkBytes := 0;
					if (FResponseBuffer.Size > 0) then
						ReadChunked;
					Exit;
				end;
				- 1:
				begin
                	// Not enough data to determine if chunk token
                    // Exit and wait for more data.
					Exit;
				end;
				0:
				begin
                	// Last, 0 size token. Another CR LF expected
                    // after this that marks end of chunks.
					if (ReadChunkSize <> - 2) then
					begin
						HandleError( - 2, 'ReadChunked(): Malformed data getting last terminator.');
						Exit;
					end;
                    // There might be trailing data which is defined as OPTIONAL in RFC.
                    // Mark chunked reads to discard any following data.
					FResponseChunkBytes := - 4;

                    // If we received all chunks and internal combine was requested
                    // it's time to inflate the data or fire the OnDataAvailable.
					if (hcoCombineChunks in Options) then
					begin
						if (FResponseContentDecoder <> nil) then
						begin
							FResponseBuffer.Clear;
							FResponseBuffer.Append(TMemoryStream(FResponseStream).Memory, FResponseStream.Size);
							TMemoryStream(FResponseStream).Clear;
							FResponseContentDecoder.Decode(FResponseBuffer.Peek, FResponseBuffer.Size);
						end
						else
							EventBodyAvailable(FResponseStream);
					end;
				end;
			end;
		end;

        // Discard any OPTIONAL (as defined in RFC) chunk trailing data.
		if (FResponseChunkBytes = - 4) then
		begin
			FResponseBuffer.Clear;
			Exit;
		end;

        // Chunk reading modes.
		if (hcoCombineChunks in Options) then
		begin
        	// Combine chunks to one chunk if requested.
			if (FResponseStream.Size > 0) then
				FResponseStream.Seek(FResponseStream.Size, soFromBeginning);

			if (FResponseChunkBytes > FResponseBuffer.Size) then
			begin
				FResponseStream.Write(FResponseBuffer.Peek^, FResponseBuffer.Size);
				Dec(FResponseChunkBytes, FResponseBuffer.Size);
				FResponseBuffer.Clear;
			end
			else
			begin
				FResponseStream.Write(FResponseBuffer.Peek^, FResponseChunkBytes);
				FResponseBuffer.Consume(nil, FResponseChunkBytes);
				FResponseChunkBytes := 0;
			end;

			if (FResponseBuffer.Size > 0) then
				ReadChunked;
		end
		else
		begin
        	// Read chunk by chunk, read as much data from buffer as available.
			if (FResponseBuffer.Size > 0) and (FResponseChunkBytes > 0) then
			begin
				if (FResponseContentDecoder <> nil) then
				begin
					if (FResponseChunkBytes > FResponseBuffer.Size) then
					begin
						FResponseContentDecoder.Decode(FResponseBuffer.Peek, FResponseBuffer.Size);
						Dec(FResponseChunkBytes, FResponseBuffer.Size);
						FResponseBuffer.Clear;
					end
					else
					begin
						FResponseContentDecoder.Decode(FResponseBuffer.Peek, FResponseChunkBytes);
						FResponseBuffer.Consume(nil, FResponseChunkBytes);
						FResponseChunkBytes := 0;
					end;
				end
				else
				begin
					if (FResponseStream.Size > 0) then
						FResponseStream.Seek(FResponseStream.Size, soFromBeginning);

					if (FResponseChunkBytes > FResponseBuffer.Size) then
					begin
						FResponseStream.Write(FResponseBuffer.Peek^, FResponseBuffer.Size);
						Dec(FResponseChunkBytes, FResponseBuffer.Size);
						FResponseBuffer.Clear;
					end
					else
					begin
						FResponseStream.Write(FResponseBuffer.Peek^, FResponseChunkBytes);
						FResponseBuffer.Consume(nil, FResponseChunkBytes);
						FResponseChunkBytes := 0;
					end;
					EventBodyAvailable(FResponseStream);
				end;

				if (FResponseBuffer.Size > 0) then
					ReadChunked;
			end;
		end;
	end;

begin
	inherited;

    // We need to pull data from socket
    // to a local temp buffer, always.
	buf := FResponseBuffer.Append(aSize);
	ret := Recv(buf, aSize);
	if (ret < 0) then
		Exit; // Recv() handles socket error and disconnect, just Exit.

    // We're reading from Winsock internal buffer.
    // No bullshit tolerated. Exit if not as advertised.
	if (ret <> aSize) then
	begin
		HandleError( - 2, 'EventDataAvailable(): Recv() returned less data than advertised.');
		Exit;
	end;

    // Do we need to parse HTTP response message?
	if (FResponseMessageParsed = False) then
	begin
    	// Try and parse out the header from the data we have buffered.
		ret := ReadMessage;
		if (ret > 0) then
		begin
            // Response message parsed, remove it from buffer to have the rest passed to
            // decoder or reponse stream. Notify app that reponse message is available.
			FResponseBuffer.Consume(nil, ret);
			FResponseMessage.MessageType := htResponse;
			EventResponseHeaders(FResponseMessage);

            // Who knows what app did after that event,
            // check if we're still connected. No local
            // cleanup required, it's automatic on socket
            // state changes.
			if (SocketState <> ssConnected) then
				Exit;

            // Get response size, set up Transfer-Encoding handling.
			FResponseSize := TextToInt(FResponseMessage.Val(CContentLength), 0);
			if (TextEquals(FResponseMessage.Val(CTransferEncoding), CChunked)) then
				FResponseChunked := True
			else if (FResponseMessage.Val(CTransferEncoding) <> '') then
			begin
            	// We don't support any other Transfer-Encoding other than none and chunked.
				HandleError( - 2, 'Unsupported Transfer-Encoding: ' + FResponseMessage.Val(CTransferEncoding));
				Exit;
			end;

			if (TextInText(FResponseMessage.Val(CContentEncoding), CGZip))
			  or (TextInText(FResponseMessage.Val(CContentEncoding), CDeflate)) then
			begin
				FResponseContentDecoder           := THTTPContentDecoder.Create(Self);
				FResponseContentDecoder.OnError   := EventDecoderError;
				FResponseContentDecoder.OnDecoded := EventDecoderDataDecoded;
				if (SocketState <> ssConnected) then
					Exit;
			end
			else if (FResponseMessage.Val(CContentEncoding) <> '') then
			begin
            	// We don't support any other transfer-Encoding other than gzip and deflate.
				HandleError( - 2, 'Unsupported Content-Encoding: ' + FResponseMessage.Val(CContentEncoding));
				Exit;
			end;

			// Mark as parsed and allow continuing the method
            // to read the body from the response buffer.
			FResponseMessageParsed := True;
		end
		else if (ret = 0) then
		begin
            // Response parsed, and it's not an HTTP response header.
            // Mark as parsed and check if we allow responses without
            // HTTP messages, close and bail if we don't.
			FResponseMessageParsed := True;
			if (hcoAllowResponseWithoutMessage in Options = False) then
			begin
				HandleError( - 2, 'Response without HTTP message received.');
				Exit;
			end;
		end
		else
        	// Need more data to parse the header.
            // Exit and wait for more data in buffer.
			Exit;
	end;

	if (FResponseChunked) then
		ReadChunked
	else
		ReadNormal;
end;

{ Error from content decoder. }
procedure TCustomHTTPClient.EventDecoderError(aSender: THTTPContentDecoder; const aError: string);
begin
	HandleError( - 2, 'TContentDecoder: ' + aError);
end;

{ Data ready to be read from response filter. }
procedure TCustomHTTPClient.EventDecoderDataDecoded(aSender: THTTPContentDecoder; const aSize: integer);
var
	p: pbyte;
begin
	p := GetMemory(aSize);
	try
		aSender.ReadDecoded(p, aSize);
		if (FResponseStream.Size > 0) then
			FResponseStream.Seek(FResponseStream.Size, soFromBeginning);
		FResponseStream.Write(p^, aSize);
		EventBodyAvailable(FResponseStream);
	finally
		FreeMem(p);
	end;
end;

{ OnBodyAvailable event caller. Response body available. }
procedure TCustomHTTPClient.EventBodyAvailable(aData: TStream);
begin
	if (Assigned(FOnDataAvailable)) then
		FOnDataAvailable(Self, aData);
end;

{ OnRequestHeaders event caller. Request headers have been constructed. }
procedure TCustomHTTPClient.EventRequestHeaders(aHeaders: THTTPMessage);
begin
	if (Assigned(FOnRequestHeaders)) then
		FOnRequestHeaders(Self, aHeaders);
end;

{ OnResponseHeaders event caller. Response headers have been received. }
procedure TCustomHTTPClient.EventResponseHeaders(aHeaders: THTTPMessage);
begin
	if (Assigned(FOnResponseHeaders)) then
		FOnResponseHeaders(Self, aHeaders);
end;

{ Options setter. }
procedure TCustomHTTPClient.SetOptions(const Value: THTTPClientOptions);
begin
	if (SocketState <> ssDisconnected) then
		Exit;

	if (FOptions = Value) then
		Exit;
	FOptions := Value;
end;

{ RequestHeaders setter. }
procedure TCustomHTTPClient.SetRequestHeaders(const aValue: THTTPMessage);
begin
	if (SocketState <> ssDisconnected) then
		Exit;

	FRequestHeaders.Assign(aValue);
end;

{ UserAgent setter. }
procedure TCustomHTTPClient.SetUserAgent(const Value: string);
begin
	if (SocketState <> ssDisconnected) then
		Exit;

	if (FUserAgent = Value) then
		Exit;
	FUserAgent := Value;
end;

{ HTTPAuthorization setter. }
procedure TCustomHTTPClient.SetAuthorization(const Value: THTTPAuthorization);
begin
	FAuthorization.Assign(Value);
end;

end.
