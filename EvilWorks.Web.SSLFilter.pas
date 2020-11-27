//
// EvilLibrary by Vedran Vuk 2010-2012
//
// Name: 					EvilWorks.Web.SSLFilter
// Description: 			An abstract async SSL filter.
// File last change date:   December 28th. 2012
// File version: 			Dev 0.0.0
// Licence:                 Free.
//

unit EvilWorks.Web.SSLFilter;

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
	EvilWorks.Web.Utils;

type
	TSSLFilter = class;

    { Shared events }
	TOnSocketLog = procedure(aSender: TObject; const aText: string) of object;

    { TSSLFilter Events }
	TOnSSLFilterError = procedure(aSender: TSSLFilter; const aErrorText: string) of object;
	TOnSSLFilterData  = procedure(aSender: TSSLFilter; const aDataSize: integer) of object;

    { TSSLFilter }
    { An SSL filter that encrypts/decrypts data to be sent/received over a socket asynchronously.            }
    { Give transparent app data with EncryptData(), wait OnDataEncrypted, read with ReadEncrypted().         }
    { Give opaque socket received data with DecryptData(), wait OnDataDecrypted, read with ReadDecrypted().  }
    { SSL handshake is performed automatically. Just call Connect() or Accept() before feeding me any data.  }
	TSSLFilter = class(TPersistent)
	type
		TSSLState = (ssUndefined, ssAccept, ssConnect);
	private
		FSSLContext          : PSSL_CTX;
		FSSL                 : PSSL;
		FBioIn               : PBIO;
		FBioOut              : PBIO;
		FEncryptBuff         : TBuffer;
		FDecryptBuff         : TBuffer;
		FReadRequired        : Boolean;
		FWriteRequired       : boolean;
		FSSLMethod           : TSSLMethod;
		FSSLState            : TSSLState;
		FEnabled             : Boolean;
		FCertificate         : TFileName;
		FPrivateKey          : TFileName;
		FVerifyCertificates  : boolean;
		FCertificateVerified : boolean;
		FOnDataEncrypted     : TOnSSLFilterData;
		FOnDataDecrypted     : TOnSSLFilterData;
		FOnLog               : TOnSocketLog;
		FOnError             : TOnSSLFilterError;
		FPassword            : string;
		FCertificateAuthority: string;

		// Creates/Disposes of SSL session data for Connect(), Accept() and Disconnect().
		function CreateSSLSession: Boolean;
		procedure DestroySSLSession;

        // Internal SSL data processing methods.
		function DoEncrypt(const aData: pByte; const aSize: integer): integer;
		function DoDecrypt(const aData: pByte; const aSize: integer): integer;
		procedure RunSSL;

        // SSL functions and utilities.
		function VerifyPeerCertificate: boolean;

        // Property getters/setters.
		procedure SetEnabled(const aValue: Boolean);
		procedure SetSSLMethod(const aValue: TSSLMethod);
	protected
        // Event callers.
		procedure DoOnLog(const aText: string);

        // Error handling.
		function HandleError(const aErr: integer; const aError: string): Boolean;
	public
		constructor Create;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;

        // Call Accept() or Connect() before using EncryptData() or DecryptData().
		function Accept: Boolean;
		function Connect: Boolean;
		procedure Disconnect;

		function EncryptPending: boolean;
		function DecryptPending: boolean;

		// Send data to be en/de
		function EncryptData(const aData: pByte; const aSize: integer): integer;
		function DecryptData(const aData: pByte; const aSize: integer): integer;

        // Get data after you get OnDataDecrypted/OnDataEncrypted.
		function ReadEncrypted(const aData: pByte; const aSize: integer): integer;
		function ReadDecrypted(const aData: pByte; const aSize: integer): integer;
	published
        // Master turn on.
		property Enabled  : Boolean read FEnabled write SetEnabled default False;
		property SSLMethod: TSSLMethod read FSSLMethod write SetSSLMethod default smTLSv1;

		property Password            : string read FPassword write FPassword;
		property Certificate         : TFileName read FCertificate write FCertificate;
		property PrivateKey          : TFileName read FPrivateKey write FPrivateKey;
		property CertificateAuthority: string read FCertificateAuthority write FCertificateAuthority;

        // Verify peer certificate after connecting (and disconnect if invalid).
		property VerifyCertificates: boolean read FVerifyCertificates write FVerifyCertificates default False;

        // Notifies if theres processed data to be read. After you receive this event you
        // should read out the whole aDataSize from the buffer, as you will only receive one
        // event when data is available.
		property OnDataEncrypted: TOnSSLFilterData read FOnDataEncrypted write FOnDataEncrypted;
		property OnDataDecrypted: TOnSSLFilterData read FOnDataDecrypted write FOnDataDecrypted;

        // Logging.
		property OnLog: TOnSocketLog read FOnLog write FOnLog;
        // If OnError is fired, socket that's using TSSLFilter should close the connection.
		property OnError: TOnSSLFilterError read FOnError write FOnError;
	end;

implementation

function PasswordCallback(aBuf: pansichar; aSize, aRWFlag: integer; aSSL: TSSLFilter): integer; cdecl;
var
	password: AnsiString;
begin
	password := ansistring(aSSL.FPassword);
	if (Length(password) > (aSize - 1)) then
		SetLength(password, aSize - 1);
	Result := Length(password);
	Move(PAnsiChar(password)^, aBuf^, Result + 1);
end;

{ ========== }
{ TSSLFilter }
{ ========== }

{ Constructor. }
constructor TSSLFilter.Create;
begin
	FEnabled  := False;
	FSSLState := ssUndefined;

	FSSLMethod := smTLSv1;

	FVerifyCertificates := False;
end;

{ Destructor. }
destructor TSSLFilter.Destroy;
begin
	Disconnect;
	inherited;
end;

{ Assign. }
procedure TSSLFilter.Assign(aSource: TPersistent);
begin
	inherited;

	if (aSource is TSSLFilter) then
	begin
		Enabled              := TSSLFilter(aSource).Enabled;
		SSLMethod            := TSSLFilter(aSource).SSLMethod;
		Password             := TSSLFilter(aSource).Password;
		Certificate          := TSSLFilter(aSource).Certificate;
		PrivateKey           := TSSLFilter(aSource).PrivateKey;
		CertificateAuthority := TSSLFilter(aSource).CertificateAuthority;
		OnDataEncrypted      := TSSLFilter(aSource).OnDataEncrypted;
		OnDataDecrypted      := TSSLFilter(aSource).OnDataDecrypted;
	end;
end;

{ Creates and initializes the SSL session variables. }
function TSSLFilter.CreateSSLSession: Boolean;
begin
	Result := False;

	FEncryptBuff.Clear;
	FDecryptBuff.Clear;
	FCertificateVerified := False;

	// Create a TLS context.
	case FSSLMethod of
		smSSLv2:
		FSSLContext := SSL_CTX_new(SSLv2_method);
		smSSLv23:
		FSSLContext := SSL_CTX_new(SSLv23_method);
		smSSLv3:
		FSSLContext := SSL_CTX_new(SSLv3_method);
		smTLSv1:
		FSSLContext := SSL_CTX_new(TLSv1_method);
	end;

	if (FSSLContext = nil) then
	begin
		HandleError( - 2, 'SSL_CTX_new() failed');
		Exit;
	end;

//	if (HandleError(SSL_CTX_set_cipher_list(FSSLContext, 'DEFAULT'), 'SSL_CTX_set_cipher_list() failed')) then
//		Exit;

//	SSL_CTX_set_default_passwd_cb_userdata(FSSLContext, Self);
//	SSL_CTX_set_default_passwd_cb(FSSLContext, @PasswordCallback);

	if (FCertificate <> '') then
		if (SSL_CTX_use_certificate_chain_file(FSSLContext, PAnsiChar(ansistring(FCertificate))) <> 1) then
			if (SSL_CTX_use_certificate_file(FSSLContext, PAnsiChar(ansistring(FCertificate)), SSL_FILETYPE_PEM) <> 1) then
				if (SSL_CTX_use_certificate_file(FSSLContext, PAnsiChar(ansistring(FCertificate)), SSL_FILETYPE_ASN1) <> 1) then
				begin
					HandleError( - 2, 'SSL_CTX_use_certificate_file() failed');
					Exit(False);
				end;

	if (FPrivateKey <> '') then
		if (SSL_CTX_use_RSAPrivateKey_file(FSSLContext, PAnsiChar(ansistring(FPrivateKey)), SSL_FILETYPE_PEM) <> 1) then
			if (SSL_CTX_use_RSAPrivateKey_file(FSSLContext, pansichar(AnsiString(FPrivateKey)), SSL_FILETYPE_ASN1) <> 1) then
			begin
				HandleError( - 2, 'SSL_CTX_use_PrivateKey_file() failed');
				Exit(False);
			end;

	if (FCertificate <> '') and (FPrivateKey <> '') then
	begin
		DoOnLog('Checking if certificate and private key match...');
		if (SSL_CTX_check_private_key(FSSLContext) <= 0) then
		begin
			HandleError( - 2, 'SSL_CTX_check_private_key() failed: Private key does not match the certificate public key');
			Exit(False);
		end;
		DoOnLog('Certificate and private key match.');
	end;

	if (FCertificateAuthority <> '') then
		if (SSL_CTX_load_verify_locations(FSSLContext, pansichar(ansistring(FCertificateAuthority)), nil) <> 1) then
		begin
			HandleError( - 2, 'SSL_CTX_load_verify_locations() failed');
			Exit(False);
		end;

	FSSL    := SSL_new(FSSLContext);    // Create SSL
	FBioIn  := BIO_new(BIO_s_mem);      // Create In BIO
	FBioOut := BIO_new(BIO_s_mem);      // Create Out BIO
	SSL_set_bio(FSSL, FBioIn, FBioOut); // Select In/Out BIO into SSL.

	FReadRequired  := False; // Async read flag.
	FWriteRequired := False;

	Result := True;
end;

{ Disposes of SSL session variables. }
procedure TSSLFilter.DestroySSLSession;
begin
	if (FSSLContext <> nil) then
	begin
		SSL_CTX_free(FSSLContext);
		FSSLContext := nil;
	end;

	if (FSSL <> nil) then
	begin
		SSL_shutdown(FSSL);
		SSL_free(FSSL);
		FSSL := nil;
	end;

	FEncryptBuff.Clear;
	FDecryptBuff.Clear;
	FReadRequired  := False;
	FWriteRequired := False;
	FSSLState      := ssUndefined;
end;

{ Sends the pending data in FEncryptBuff to SSL for encryption. }
function TSSLFilter.DoEncrypt(const aData: pByte; const aSize: integer): integer;
var
	ret: integer;
begin
	DoOnLog('DoEncrypt();');

	if (FSSLState = ssUndefined) or (aSize = 0) then
		Exit(0);

	FWriteRequired := False;

	Result := SSL_write(FSSL, FEncryptBuff.Peek, FEncryptBuff.Size);
	if (HandleError(Result, 'DoEncrypt(): SSL_write() failed') = False) then
		Exit;

	if (SSL_want_read(FSSL)) then
		FReadRequired := True;

	while (FSSLState <> ssUndefined) do
	begin
		ret := BIO_pending(FBioOut);
		if (ret <= 0) then
			Exit;

		if (Assigned(FOnDataEncrypted)) then
			FOnDataEncrypted(Self, ret);
	end;
end;

{ Gives data to SSL for decryption. }
function TSSLFilter.DoDecrypt(const aData: pByte; const aSize: integer): integer;
const
	BUFFER_SIZE = 4096;
var
	buf: pointer;
	ret: integer;
begin
	DoOnLog('DoDecrypt();');

	if (FSSLState = ssUndefined) or (aSize = 0) then
		Exit(0);

	FReadRequired := False;

	Result := BIO_write(FBioIn, aData, aSize);
	if (HandleError(Result, 'DoDecrypt(): BIO_write() failed') = False) then
		Exit;

	if (SSL_want_write(FSSL)) then
		FWriteRequired := True;

	while (FSSLState <> ssUndefined) do
	begin
    	{
        // Doesn't return the same amount SSL_read returns
        // Usually some small numbers.
		ret := BIO_pending(FBioIn);
		if (ret <= 0) then
			Exit;
        }

		buf := GetMemory(BUFFER_SIZE);
		ret := SSL_read(FSSL, buf, BUFFER_SIZE);
		if (ret <= 0) then
		begin
			FreeMem(buf);
			HandleError(ret, 'DoDecrypt(): SSL_read failed');
			Exit;
		end;

		FDecryptBuff.Append(buf, ret);
		FreeMem(buf);

		if (FDecryptBuff.Empty = False) then
			if (Assigned(FOnDataDecrypted)) then
				FOnDataDecrypted(Self, FDecryptBuff.Size);
	end;
end;

{ Runs the read/write loop. }
procedure TSSLFilter.RunSSL;
var
	encryptPending: Boolean;
	decryptPending: Boolean;
	ret           : integer;
begin
	DoOnLog('RunSSL();');

	while (FSSLState <> ssUndefined) do
	begin
		if (FVerifyCertificates) and (FCertificateVerified = False) then
			if (SSL_in_init(FSSL) = False) then
				if (VerifyPeerCertificate = False) then
					Exit;

		if (SSL_in_init(FSSL)) then
			DoOnLog('SSL in handshake: ' + SSL_state_string_long(FSSL));

		encryptPending := (FEncryptBuff.Empty = False);
		decryptPending := (FDecryptBuff.Empty = False);

		if (FWriteRequired = False) and (decryptPending) then
		begin
			ret := DoDecrypt(FDecryptBuff.Peek, FDecryptBuff.Size);
			FDecryptBuff.Consume(nil, ret);
		end
		else if (FReadRequired = False) and (encryptPending) then
		begin
			ret := DoEncrypt(FEncryptBuff.Peek, FEncryptBuff.Size);
			FEncryptBuff.Consume(nil, ret);
		end
		else
			Break;
	end;
end;

{ Verifies peer certificate after SSL connected. True if verified, False if failed. }
function TSSLFilter.VerifyPeerCertificate: boolean;
var
	server_cert: PX509;
	ansibuf    : pansichar;
	str        : string;
	ret        : integer;
	cipher     : PSSL_CIPHER;
begin
	DoOnLog('VerifyPeerCertificate();');

	Result := True;

	cipher := SSL_get_current_cipher(FSSL);
	if (cipher <> nil) then
		DoOnLog(Format('SSL connection using cipher: %s', [SSL_CIPHER_get_name(cipher)]));

	SSL_CTX_set_verify_depth(FSSLContext, 9);

	server_cert := SSL_get_peer_certificate(FSSL);
	if (server_cert = nil) then
	begin
		HandleError( - 2, 'VerifyPeerCertificate(): SSL_get_peer_certificate() failed');
		Exit(False);
	end;

	DoOnLog('Server certificate:');

	ansibuf := X509_NAME_oneline(X509_get_subject_name(server_cert), nil, 0);
	DoOnLog(#9 + 'subject:' + ansibuf);
	OPENSSL_free(ansibuf);

	ansibuf := X509_NAME_oneline(X509_get_issuer_name(server_cert), nil, 0);
	DoOnLog(#9 + 'issuer:' + ansibuf);
	OPENSSL_free(ansibuf);

	ret := SSL_get_verify_result(FSSL);
	if (ret <> X509_V_OK) then
	begin
		ansibuf := X509_verify_cert_error_string(ret);
		str     := string(pansichar(ansibuf));
		OPENSSL_free(ansibuf);
		HandleError( - 2, 'VerifyPeerCertificate(): SSL_get_verify_result() failed: ' + str);
		Exit(False);
	end;

    // X509_free(server_cert);

	FCertificateVerified := True;
end;

{ Call this method prior to receiving any data to set the SSL into server mode and to have it }
{ perform a server handshake with the peer as soon as first data is received from peer. }
function TSSLFilter.Accept: Boolean;
begin
	Result := False;

	if (FSSLState <> ssUndefined) then
		Exit;

	if (CreateSSLSession) then
	begin
		FSSLState := ssAccept;
		SSL_set_accept_state(FSSL);
	end;
end;

{ Call this method prior to sending any data to set the SSL into client mode and to have it }
{ perform a client handshake with the peer as soon as first data is sent over SSL. }
function TSSLFilter.Connect: Boolean;
begin
	Result := False;

	if (FSSLState <> ssUndefined) then
		Exit;

	if (CreateSSLSession) then
	begin
		FSSLState := ssConnect;
		SSL_set_connect_state(FSSL);
	end;
end;

{ Tell SSL to close the SSL session. }
procedure TSSLFilter.Disconnect;
begin
	if (FSSLState = ssUndefined) then
		Exit;

	DestroySSLSession;
end;

{ Checks if there is data in internal buffer waiting for encryption. }
function TSSLFilter.EncryptPending: boolean;
begin
	Result := not FEncryptBuff.Empty;
end;

{ Checks if there is data in internal buffer waiting for decryption. }
function TSSLFilter.DecryptPending: boolean;
begin
	Result := (BIO_pending(FBioIn) > 0);
end;

{ Give unencrypted data to SSL to be encrypted for sending over socket. }
function TSSLFilter.EncryptData(const aData: pByte; const aSize: integer): integer;
begin
	if (FSSLState = ssUndefined) then
		Exit(0);

	Result := FEncryptBuff.Append(aData, aSize);
	RunSSL;
end;

{ Give data received over socket to SSL to be decrypted for application. }
function TSSLFilter.DecryptData(const aData: pByte; const aSize: integer): integer;
begin
	if (FSSLState = ssUndefined) then
		Exit(0);

	Result := DoDecrypt(aData, aSize);
	RunSSL;
end;

{ Get data after receiving OnDataEncrypted. }
function TSSLFilter.ReadEncrypted(const aData: pByte; const aSize: integer): integer;
begin
	if (FSSLState = ssUndefined) then
		Exit(0);

	Result := BIO_read(FBioOut, aData, aSize);
	if (Result <= 0) then
		if (BIO_should_retry(FBioOut) = 0) then
			if (HandleError(Result, 'ReadEncrypted(): BIO_read failed') = False) then
				Exit;
end;

{ Get data after receiving OnDataDecrypted. }
function TSSLFilter.ReadDecrypted(const aData: pByte; const aSize: integer): integer;
begin
	if (FSSLState = ssUndefined) then
		Exit(0);

	Result := FDecryptBuff.Consume(aData, aSize);

    // If there's more, please take it.
	if (FDecryptBuff.Empty = False) then
		if (Assigned(FOnDataDecrypted)) then
			FOnDataDecrypted(Self, FDecryptBuff.Size);
end;

{ Checks if the error return value of an ssl function is non-passable. }
{ Returns True if handled, False if fatal error. pass -2 to aErr to }
{ have SSL Fail, handle the cleanup and pass the aError on.}
function TSSLFilter.HandleError(const aErr: integer; const aError: string): Boolean;
var
	err: integer;
	buf: array [0 .. 255] of ansichar;
	str: string;
begin
	if (aErr > 0) then
		Exit(True);

	if (aErr <= - 2) then
	begin
		Disconnect;
		if (Assigned(FOnError)) then
			FOnError(Self, aError);
		Exit(False);
	end;

	err := SSL_get_error(FSSL, aErr);
	case err of
		SSL_ERROR_ZERO_RETURN, SSL_ERROR_NONE, SSL_ERROR_WANT_READ:
		Result := True;
		else
		begin
			Result := False;
			str    := '';
			while (err <> 0) do
			begin
				ERR_error_string_n(err, buf, SizeOf(buf));
				str := str + string(pansichar(@buf[0]));
				err := ERR_get_error;
			end;
			Disconnect;
			if (Assigned(FOnError)) then
				FOnError(Self, aError + ': ' + str);
		end;
	end;
end;

{ Calls OnLog event. }
procedure TSSLFilter.DoOnLog(const aText: string);
begin
	if (Assigned(FOnLog)) then
		FOnLog(Self, aText);
end;

{ Enabled setter.}
procedure TSSLFilter.SetEnabled(const aValue: Boolean);
begin
	// Don't allow switching enabled state if not idle.
	if (FSSLState <> ssUndefined) then
		Exit;
	if (FEnabled = aValue) then
		Exit;
	FEnabled := aValue;
end;

{ SSLMethod setter }
procedure TSSLFilter.SetSSLMethod(const aValue: TSSLMethod);
begin
	// Don't allow switching method if not idle.
	if (FSSLState <> ssUndefined) then
		Exit;
	if (FSSLMethod = aValue) then
		Exit;
	FSSLMethod := aValue;
end;

end.
