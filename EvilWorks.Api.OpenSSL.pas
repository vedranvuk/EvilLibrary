//
// EvilLibrary by Vedran Vuk 2010-2012
//
// Name: 					EvilWorks.Api.OpenSSL
// Description: 			Basic imports from OpenSSL library and a few helpers.
// File last change date:   October 1st. 2012
// File version: 			Dev 0.0.0
// Licence:                 Free.
//

unit EvilWorks.Api.OpenSSL;

interface

uses
	Winapi.Windows,
	EvilWorks.Api.Winsock2;

const
	ssleay32 = 'ssleay32.dll';
	libeay32 = 'libeay32.dll';

const
	SSL_ERROR_NONE             = 0;
	SSL_ERROR_SSL              = 1;
	SSL_ERROR_WANT_READ        = 2;
	SSL_ERROR_WANT_WRITE       = 3;
	SSL_ERROR_WANT_X509_LOOKUP = 4;
	SSL_ERROR_SYSCALL          = 5;
	SSL_ERROR_ZERO_RETURN      = 6;
	SSL_ERROR_WANT_CONNECT     = 7;
	SSL_ERROR_WANT_ACCEPT      = 8;

	SSL_ST_CONNECT     = $1000;
	SSL_ST_ACCEPT      = $2000;
	SSL_ST_MASK        = $0FFF;
	SSL_ST_INIT        = SSL_ST_CONNECT or SSL_ST_ACCEPT;
	SSL_ST_BEFORE      = $4000;
	SSL_ST_OK          = $03;
	SSL_ST_RENEGOTIATE = $04 or SSL_ST_INIT;

	SSL_OP_ALL = $80000BFF;

	SSL_OP_NO_SSLv2   = $01000000;
	SSL_OP_NO_SSLv3   = $02000000;
	SSL_OP_NO_TLSv1   = $04000000;
	SSL_OP_NO_TLSv1_2 = $08000000;
	SSL_OP_NO_TLSv1_1 = $10000000;

	SSL_CTRL_OPTIONS = 32;
	SSL_CTRL_MODE    = 33;

    SSL_MODE_AUTO_RETRY = $00000004;

	SSL_VERIFY_NONE                 = $00;
	SSL_VERIFY_PEER                 = $01;
	SSL_VERIFY_FAIL_IF_NO_PEER_CERT = $02;
	SSL_VERIFY_CLIENT_ONCE          = $04;

	X509_FILETYPE_PEM     = 1;
	X509_FILETYPE_ASN1    = 2;
	X509_FILETYPE_DEFAULT = 3;

	SSL_FILETYPE_ASN1 = X509_FILETYPE_ASN1;
	SSL_FILETYPE_PEM  = X509_FILETYPE_PEM;

	BIO_NOCLOSE = $00;
	BIO_CLOSE   = $01;

	BIO_CTRL_RESET     = 1;  // opt - rewind/zero etc */
	BIO_CTRL_EOF       = 2;  // opt - are we at the eof */
	BIO_CTRL_INFO      = 3;  // opt - extra tit-bits */
	BIO_CTRL_SET       = 4;  // man - set the 'IO' type */
	BIO_CTRL_GET       = 5;  // man - get the 'IO' type */
	BIO_CTRL_PUSH      = 6;  // opt - internal, used to signify change */
	BIO_CTRL_POP       = 7;  // opt - internal, used to signify change */
	BIO_CTRL_GET_CLOSE = 8;  // man - set the 'close' on free */
	BIO_CTRL_SET_CLOSE = 9;  // man - set the 'close' on free */
	BIO_CTRL_PENDING   = 10; // opt - is their more data buffered */
	BIO_CTRL_FLUSH     = 11; // opt - 'flush' buffered output */
	BIO_CTRL_DUP       = 12; // man - extra stuff for 'duped' BIO */
	BIO_CTRL_WPENDING  = 13; // opt - number of bytes still to write */

	BIO_FLAGS_READ         = $01;
	BIO_FLAGS_WRITE        = $02;
	BIO_FLAGS_IO_SPECIAL   = $04;
	BIO_FLAGS_RWS          = BIO_FLAGS_READ or BIO_FLAGS_WRITE or BIO_FLAGS_IO_SPECIAL;
	BIO_FLAGS_SHOULD_RETRY = $08;

	SSL_NOTHING     = 1;
	SSL_WRITING     = 2;
	SSL_READING     = 3;
	SSL_X509_LOOKUP = 4;

type
	// lol dem all pointers
	SslPtr         = Pointer;
	PSSL           = SslPtr;
	PSSL_CTX       = SslPtr;
	PSSL_METHOD    = SslPtr;
	PBIO           = SslPtr;
	PBIO_METHOD    = SslPtr;
	X509           = SslPtr;
	PX509          = ^X509;
	X509_STORE_CTX = SslPtr;
	X509_NAME      = SslPtr; // record!
	PSSL_CIPHER    = SslPtr;

	TVerify_Callback = function(ok: integer; store: Pointer): integer;

const
	X509_V_OK = 0;

function SSL_library_init: integer; cdecl; external ssleay32 name 'SSL_library_init';
procedure SSL_load_error_strings; cdecl; external ssleay32 name 'SSL_load_error_strings';
function SSL_state_string_long(const s: PSSL): pansichar; cdecl; external ssleay32 name 'SSL_state_string_long';

function SSL_new(pCTX: PSSL_CTX): PSSL; cdecl; external ssleay32 name 'SSL_new';
procedure SSL_free(aSSL: PSSL); cdecl; external ssleay32 name 'SSL_free';

function SSL_state(const ssl: PSSL): integer; cdecl; external ssleay32 name 'SSL_state';
function SSL_get_error(const s: PSSL; ret_code: integer): integer; cdecl; external ssleay32 name 'SSL_get_error';

function SSL_connect(ssl: PSSL): integer; cdecl; external ssleay32 name 'SSL_connect';
function SSL_accept(ssl: PSSL): integer; cdecl; external ssleay32 name 'SSL_accept';
function SSL_read(ssl: PSSL; buf: Pointer; num: integer): integer; cdecl; external ssleay32 name 'SSL_read';
function SSL_write(ssl: PSSL; const buf: Pointer; num: integer): integer; cdecl; external ssleay32 name 'SSL_write';
function SSL_pending(ssl: PSSL): integer; cdecl; external ssleay32 name 'SSL_pending';
function SSL_shutdown(ssl: PSSL): integer; cdecl; external ssleay32 name 'SSL_shutdown';
function SSL_peek(s: PSSL; buf: Pointer; num: integer): integer; cdecl; external ssleay32 name 'SSL_peek';

function SSL_set_fd(ssl: PSSL; fd: integer): integer; cdecl; external ssleay32 name 'SSL_set_fd';
procedure SSL_set_connect_state(s: PSSL); cdecl; external ssleay32 name 'SSL_set_connect_state';
procedure SSL_set_accept_state(s: PSSL); cdecl; external ssleay32 name 'SSL_set_accept_state';
procedure SSL_set_bio(s: PSSL; rbio, wbio: PBIO); cdecl; external ssleay32 name 'SSL_set_bio';
procedure SSL_set_shutdown(s: PSSL; mode: integer); cdecl; external ssleay32 name 'SSL_set_shutdown';
function SSL_get_shutdown(s: PSSL): integer; cdecl; external ssleay32 name 'SSL_get_shutdown';

function SSL_want(const s: PSSL): integer; cdecl; external ssleay32 name 'SSL_want';

function SSL_get_peer_certificate(const ssl: PSSL): PX509;
cdecl external ssleay32 name 'SSL_get_peer_certificate';

function SSL_CTX_new(pMeth: PSSL_METHOD): PSSL_CTX; cdecl; external ssleay32 name 'SSL_CTX_new';
procedure SSL_CTX_free(pCTX: PSSL_CTX); cdecl; external ssleay32 name 'SSL_CTX_free';

function SSL_CTX_ctrl(ctx: PSSL_CTX; cmd: integer; larg: LongInt; parg: Pointer): LongInt; cdecl;
  external ssleay32 name 'SSL_CTX_ctrl';
function SSL_CTX_set_cipher_list(ctx: PSSL_CTX; const str: pansichar): integer; cdecl;
  external ssleay32 name 'SSL_CTX_set_cipher_list';

//procedure SSL_CTX_set_default_passwd_cb(ctx: PSSL_CTX, pem_password_cb * cb); cdecl;
//  external ssleay32 name 'SSL_CTX_set_default_passwd_cb';
//procedure SSL_CTX_set_default_passwd_cb_userdata(SSL_CTX * ctx, void * u); cdecl;
//  external ssleay32 name 'SSL_CTX_set_default_passwd_cb_userdata';

procedure SSL_CTX_set_default_passwd_cb(ctx: PSSL_CTX; cb: pointer); cdecl;
  external ssleay32 name 'SSL_CTX_set_default_passwd_cb';
procedure SSL_CTX_set_default_passwd_cb_userdata(ctx: PSSL_CTX; u: pointer); cdecl;
  external ssleay32 name 'SSL_CTX_set_default_passwd_cb_userdata';

procedure SSL_CTX_set_verify(ctx: PSSL_CTX; mode: integer; callback: TVerify_Callback); cdecl;
  external ssleay32 name 'SSL_CTX_set_verify';
procedure SSL_CTX_set_verify_depth(ctx: PSSL_CTX; depth: integer); cdecl;
  external ssleay32 name 'SSL_CTX_set_verify_depth';

function SSL_CTX_use_RSAPrivateKey_file(ctx: PSSL_CTX; const filename: pansichar; typ: integer): integer;
  cdecl; external ssleay32 name 'SSL_CTX_use_RSAPrivateKey_file';
function SSL_CTX_use_certificate_file(pCTX: PSSL_CTX; const aFile: pansichar; typ: integer): integer; cdecl;
  external ssleay32 name 'SSL_CTX_use_certificate_file';
function SSL_CTX_load_verify_locations(ctx: PSSL_CTX; const CAFile, CAPath: pansichar): integer; cdecl;
  external ssleay32 name 'SSL_CTX_load_verify_locations';
function SSL_CTX_set_default_verify_paths(ctx: PSSL_CTX): integer; cdecl;
  external ssleay32 name 'SSL_CTX_set_default_verify_paths';
function SSL_CTX_use_certificate_chain_file(ctx: PSSL_CTX; const aFile: pansichar): integer; cdecl;
  external ssleay32 name 'SSL_CTX_use_certificate_chain_file';
function SSL_CTX_use_PrivateKey_file(ssl: PSSL; const aFile: pansichar; typ: integer): integer; cdecl;
  external ssleay32 name 'SSL_CTX_use_PrivateKey_file';
function SSL_CTX_check_private_key(const ctx: PSSL_CTX): integer; cdecl;
  external ssleay32 name 'SSL_CTX_check_private_key';

function SSL_get_current_cipher(const s: PSSL): PSSL_CIPHER; cdecl; external ssleay32 name 'SSL_get_current_cipher';
function SSL_CIPHER_get_name(const c: PSSL_CIPHER): pansichar; cdecl; external ssleay32 name 'SSL_CIPHER_get_name';

procedure SSL_set_verify_result(ssl: PSSL; v: long); cdecl; external ssleay32 name 'SSL_set_verify_result';
function SSL_get_verify_result(ssl: PSSL): long; cdecl; external ssleay32 name 'SSL_get_verify_result';

function SSLv2_method: PSSL_METHOD; cdecl; external ssleay32 name 'SSLv2_method';
function SSLv23_method: PSSL_METHOD; cdecl; external ssleay32 name 'SSLv23_method';
function SSLv3_method: PSSL_METHOD; cdecl; external ssleay32 name 'SSLv3_method';
function TLSv1_method: PSSL_METHOD; cdecl; external ssleay32 name 'TLSv1_method';

function BIO_new(b: PBIO_METHOD): PBIO; cdecl; external libeay32 name 'BIO_new';
function BIO_new_socket(sock, close_flag: integer): PBIO; cdecl; external libeay32 name 'BIO_new_socket';
function BIO_free(b: PBIO): integer; cdecl; external libeay32 name 'BIO_free';

function BIO_push(b: PBIO; append: PBIO): PBIO; cdecl; external libeay32 name 'BIO_push';
function BIO_pop(b: PBIO): PBIO; cdecl; external libeay32 name 'BIO_pop';

function BIO_read(b: PBIO; buf: Pointer; len: integer): integer; cdecl; external libeay32 name 'BIO_read';
function BIO_write(b: PBIO; const buf: Pointer; len: integer): integer; cdecl; external libeay32 name 'BIO_write';
function BIO_ctrl(b: PBIO; cmd: integer; larg: long; parg: Pointer): long; cdecl; external libeay32 name 'BIO_ctrl';

function BIO_s_mem: PBIO_METHOD; cdecl; external libeay32 name 'BIO_s_mem';
function BIO_s_socket: PBIO_METHOD; cdecl; external libeay32 name 'BIO_s_socket';

procedure BIO_set_flags(b: PBIO; flags: integer); cdecl; external libeay32 name 'BIO_set_flags';
function BIO_test_flags(const b: PBIO; flags: integer): integer; cdecl; external libeay32 name 'BIO_test_flags';
procedure BIO_clear_flags(b: PBIO; flags: integer); cdecl; external libeay32 name 'BIO_clear_flags';

function X509_STORE_CTX_get_current_cert(ctx: X509_STORE_CTX): X509; cdecl;
  external libeay32 name 'X509_STORE_CTX_get_current_cert';
function X509_STORE_CTX_get_error_depth(ctx: X509_STORE_CTX): integer; cdecl;
  external libeay32 name 'X509_STORE_CTX_get_error_depth';
function X509_STORE_CTX_get_error(ctx: X509_STORE_CTX): integer; cdecl;
  external libeay32 name 'X509_STORE_CTX_get_error';

function X509_NAME_oneline(a: X509_NAME; buf: pansichar; size: integer): pansichar; cdecl;
  external libeay32 name 'X509_NAME_oneline';

function X509_get_issuer_name(a: X509): X509_NAME; cdecl; external libeay32 name 'X509_get_issuer_name';
function X509_get_subject_name(a: X509): X509_NAME; cdecl; external libeay32 name 'X509_get_issuer_name';

function X509_verify_cert_error_string(n: LongInt): pansichar; cdecl;
  external libeay32 name 'X509_verify_cert_error_string';

procedure ERR_print_errors(bp: PBIO); cdecl; external libeay32 name 'ERR_print_errors';
procedure ERR_print_errors_fp(aFilePointer: THandle); cdecl; external libeay32 name 'ERR_print_errors_fp';

procedure ERR_free_strings; cdecl; external libeay32 name 'ERR_free_strings';
function ERR_get_error: LongInt; cdecl; external libeay32 name 'ERR_get_error';
function ERR_error_string(e: LongInt; buf: pansichar): pansichar; cdecl; external libeay32 name 'ERR_error_string';
procedure ERR_error_string_n(e: LongInt; buf: pansichar; len: longword); cdecl; external libeay32 name 'ERR_error_string_n';

function ERR_lib_error_string(e: LongInt): pansichar; cdecl; external libeay32 name 'ERR_lib_error_string';
function ERR_func_error_string(e: LongInt): pansichar; cdecl; external libeay32 name 'ERR_func_error_string';
function ERR_reason_error_string(e: LongInt): pansichar; cdecl; external libeay32 name 'ERR_reason_error_string';

procedure OPENSSL_add_all_algorithms_noconf; cdecl; external libeay32 name 'OPENSSL_add_all_algorithms_noconf';
procedure OPENSSL_add_all_algorithms_conf; cdecl; external libeay32 name 'OPENSSL_add_all_algorithms_conf';
procedure OpenSSL_add_all_digests; cdecl; external libeay32 name 'OpenSSL_add_all_digests';
procedure OpenSSL_add_all_ciphers; cdecl; external libeay32 name 'OpenSSL_add_all_ciphers';
procedure EVP_cleanup; cdecl; external libeay32 name 'EVP_cleanup';

procedure CRYPTO_free(p: Pointer); cdecl; external libeay32 name 'CRYPTO_free';

{ Macros }
function SSL_get_state(ssl: PSSL): integer;
function SSL_is_init_finished(ssl: PSSL): boolean;
function SSL_in_init(ssl: PSSL): boolean;
function SSL_in_before(ssl: PSSL): boolean;
function SSL_in_connect_init(ssl: PSSL): boolean;
function SSL_in_accept_init(ssl: PSSL): boolean;

function SSL_want_nothing(const s: PSSL): boolean;
function SSL_want_read(const s: PSSL): boolean;
function SSL_want_write(const s: PSSL): boolean;
function SSL_want_x509_lookup(const s: PSSL): boolean;

function BIO_pending(b: PBIO): integer;

function BIO_should_read(const b: PBIO): integer;
function BIO_should_write(const b: PBIO): integer;
function BIO_should_io_special(const b: PBIO): integer;
function BIO_retry_type(const b: PBIO): integer;
function BIO_should_retry(const b: PBIO): integer;

procedure OPENSSL_free(p: Pointer);

function SSL_CTX_set_options(ctx: PSSL_CTX; op: LongInt): LongInt;

{ ============================================================ }
{ ====================== Helper types ======================== }
{ ============================================================ }

type
	TSSLMethod = (smSSLv2, smSSLv23, smSSLv3, smTLSv1);

{ ============================================================ }
{ ==================== Helper functions ====================== }
{ ============================================================ }

{ Extra 'macros' }
function SSL_in_renegotiation(ssl: PSSL): boolean;

{ Error functions }
function GetSSLErrorText(const aErr: integer): string;
function GetLastOpenSSLErrorText: string;

implementation

function SSL_get_state(ssl: PSSL): integer;
begin
	Result := SSL_state(ssl);
end;

function SSL_is_init_finished(ssl: PSSL): boolean;
begin
	Result := (SSL_state(ssl) = SSL_ST_OK);
end;

function SSL_in_init(ssl: PSSL): boolean;
begin
	Result := (SSL_state(ssl) and SSL_ST_INIT <> 0);
end;

function SSL_in_before(ssl: PSSL): boolean;
begin
	Result := (SSL_state(ssl) and SSL_ST_BEFORE <> 0);
end;

function SSL_in_connect_init(ssl: PSSL): boolean;
begin
	Result := (SSL_state(ssl) and SSL_ST_CONNECT <> 0);
end;

function SSL_in_accept_init(ssl: PSSL): boolean;
begin
	Result := (SSL_state(ssl) and SSL_ST_ACCEPT <> 0);
end;

function SSL_want_nothing(const s: PSSL): boolean;
begin
	Result := (SSL_want(s) = SSL_NOTHING);
end;

function SSL_want_read(const s: PSSL): boolean;
begin
	Result := (SSL_want(s) = SSL_READING);
end;

function SSL_want_write(const s: PSSL): boolean;
begin
	Result := (SSL_want(s) = SSL_WRITING);
end;

function SSL_want_x509_lookup(const s: PSSL): boolean;
begin
	Result := (SSL_want(s) = SSL_X509_LOOKUP);
end;

function BIO_pending(b: PBIO): integer;
begin
	Result := BIO_ctrl(b, BIO_CTRL_PENDING, 0, nil);
end;

function BIO_should_read(const b: PBIO): integer;
begin
	Result := BIO_test_flags(b, BIO_FLAGS_READ);
end;

function BIO_should_write(const b: PBIO): integer;
begin
	Result := BIO_test_flags(b, BIO_FLAGS_WRITE);
end;

function BIO_should_io_special(const b: PBIO): integer;
begin
	Result := BIO_test_flags(b, BIO_FLAGS_IO_SPECIAL);
end;

function BIO_retry_type(const b: PBIO): integer;
begin
	Result := BIO_test_flags(b, BIO_FLAGS_RWS);
end;

function BIO_should_retry(const b: PBIO): integer;
begin
	Result := BIO_test_flags(b, BIO_FLAGS_SHOULD_RETRY);
end;

procedure OPENSSL_free(p: Pointer);
begin
	CRYPTO_free(p);
end;

function SSL_CTX_set_options(ctx: PSSL_CTX; op: LongInt): LongInt;
begin
	Result := SSL_CTX_ctrl(ctx, SSL_CTRL_OPTIONS, op, nil);
end;

function SSL_in_renegotiation(ssl: PSSL): boolean;
begin
	Result := (SSL_state(ssl) and SSL_ST_RENEGOTIATE <> 0);
end;

function GetLastOpenSSLErrorText: string;
begin
	Result := string(ERR_error_string(ERR_get_error, nil));
end;

function GetSSLErrorText(const aErr: integer): string;
begin
	case aErr of
		SSL_ERROR_NONE:
		Result := 'SSL_ERROR_NONE';
		SSL_ERROR_SSL:
		Result := 'SSL_ERROR_SSL';
		SSL_ERROR_WANT_READ:
		Result := 'SSL_ERROR_WANT_READ';
		SSL_ERROR_WANT_WRITE:
		Result := 'SSL_ERROR_WANT_WRITE';
		SSL_ERROR_WANT_X509_LOOKUP:
		Result := 'SSL_ERROR_WANT_X509_LOOKUP';
		SSL_ERROR_SYSCALL:
		Result := 'SSL_ERROR_SYSCALL';
		SSL_ERROR_ZERO_RETURN:
		Result := 'SSL_ERROR_ZERO_RETURN';
		SSL_ERROR_WANT_CONNECT:
		Result := 'SSL_ERROR_WANT_CONNECT';
		SSL_ERROR_WANT_ACCEPT:
		Result := 'SSL_ERROR_WANT_ACCEPT';
	end;
end;

end.
