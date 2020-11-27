//
// EvilLibrary by Vedran Vuk 2010-2012
//
// Name: 					EvilWorks.Api.ZLib
// Description: 			ZLib header. Taken from ZLibExApi.pas 1.2.7 by Brent Sherwood.
// File last change date:   October 20th. 2012
// File version: 			Dev 0.0.0
// Licence:                 See below.
//
// Original author          Brent Sherwood - http://www.base2ti.com
// Original file            ZLibExApi.pas 1.2.7
// Original copyright       copyright (c) 2000-2012 base2 technologies
//                          copyright (c) 1995-2002 Borland Software Corporation
//

unit EvilWorks.Api.ZLib;

interface

const

    //
    // Version IDs
    //

	ZLIB_VERSION: PAnsiChar = '1.2.7';

	ZLIB_VERNUM = $1270;

	ZLIB_VER_MAJOR       = 1;
	ZLIB_VER_MINOR       = 2;
	ZLIB_VER_REVISION    = 7;
	ZLIB_VER_SUBREVISION = 0;

    //
    // Compression methods
    //

	Z_DEFLATED = 8;

    //
    // Information flags
    //

	Z_INFO_FLAG_SIZE  = $1;
	Z_INFO_FLAG_CRC   = $2;
	Z_INFO_FLAG_ADLER = $4;

	Z_INFO_NONE    = 0;
	Z_INFO_DEFAULT = Z_INFO_FLAG_SIZE or Z_INFO_FLAG_CRC;

    //
    // Flush constants
    //

	Z_NO_FLUSH      = 0;
	Z_PARTIAL_FLUSH = 1;
	Z_SYNC_FLUSH    = 2;
	Z_FULL_FLUSH    = 3;
	Z_FINISH        = 4;
	Z_BLOCK         = 5;
	Z_TREES         = 6;

    //
    // Return codes
    //

	Z_OK            = 0;
	Z_STREAM_END    = 1;
	Z_NEED_DICT     = 2;
	Z_ERRNO         = ( - 1);
	Z_STREAM_ERROR  = ( - 2);
	Z_DATA_ERROR    = ( - 3);
	Z_MEM_ERROR     = ( - 4);
	Z_BUF_ERROR     = ( - 5);
	Z_VERSION_ERROR = ( - 6);

    //
    // Compression levels
    //

	Z_NO_COMPRESSION      = 0;
	Z_BEST_SPEED          = 1;
	Z_BEST_COMPRESSION    = 9;
	Z_DEFAULT_COMPRESSION = ( - 1);

    //
    // Compression strategies
    //

	Z_FILTERED         = 1;
	Z_HUFFMAN_ONLY     = 2;
	Z_RLE              = 3;
	Z_FIXED            = 4;
	Z_DEFAULT_STRATEGY = 0;

    //
    // Data types
    //

	Z_BINARY  = 0;
	Z_ASCII   = 1;
	Z_TEXT    = Z_ASCII;
	Z_UNKNOWN = 2;

    //
    // Return code messages
    //

	z_errmsg: array [0 .. 9] of string = (
	  'Need dictionary',      // Z_NEED_DICT      (2)
	  'Stream end',           // Z_STREAM_END     (1)
	  'OK',                   // Z_OK             (0)
	  'File error',           // Z_ERRNO          (-1)
	  'Stream error',         // Z_STREAM_ERROR   (-2)
	  'Data error',           // Z_DATA_ERROR     (-3)
	  'Insufficient memory',  // Z_MEM_ERROR      (-4)
	  'Buffer error',         // Z_BUF_ERROR      (-5)
	  'Incompatible version', // Z_VERSION_ERROR  (-6)
	  ''
	  );

type
	TZAlloc = function(opaque: Pointer; items, size: Integer): Pointer; cdecl;
	TZFree  = procedure(opaque, block: Pointer); cdecl;

    //
    // TZStreamRec
    //

	TZStreamRec = packed record
		next_in: PByte;     // next input byte
		avail_in: Cardinal; // number of bytes available at next_in
		total_in: Longword; // total nb of input bytes read so far

		next_out: PByte;     // next output byte should be put here
		avail_out: Cardinal; // remaining free space at next_out
		total_out: Longword; // total nb of bytes output so far

		msg: PAnsiChar; // last error message, NULL if no error
		state: Pointer; // not visible by applications

		zalloc: TZAlloc; // used to allocate the internal state
		zfree: TZFree;   // used to free the internal state
		opaque: Pointer; // private data object passed to zalloc and zfree

		data_type: Integer; // best guess about the data type: ascii or binary
		adler: Longword;    // adler32 value of the uncompressed data
		reserved: Longword; // reserved for future use
	end;

{ Macros }
function deflateInit(var strm: TZStreamRec; level: Integer): Integer; inline;
function deflateInit2(var strm: TZStreamRec; level, method, windowBits, memLevel, strategy: Integer): Integer; inline;
function inflateInit(var strm: TZStreamRec): Integer; inline;
function inflateInit2(var strm: TZStreamRec; windowBits: Integer): Integer; inline;

{ External routines }
function deflateInit_(var strm: TZStreamRec; level: Integer; version: PAnsiChar; recsize: Integer): Integer;
function deflateInit2_(var strm: TZStreamRec; level, method, windowBits, memLevel, strategy: Integer; version: PAnsiChar; recsize: Integer): Integer;
function deflate(var strm: TZStreamRec; flush: Integer): Integer;
function deflateEnd(var strm: TZStreamRec): Integer;
function deflateReset(var strm: TZStreamRec): Integer;
function inflateInit_(var strm: TZStreamRec; version: PAnsiChar; recsize: Integer): Integer;
function inflateInit2_(var strm: TZStreamRec; windowBits: Integer; version: PAnsiChar; recsize: Integer): Integer;
function inflate(var strm: TZStreamRec; flush: Integer): Integer;
function inflateEnd(var strm: TZStreamRec): Integer;
function inflateReset(var strm: TZStreamRec): Integer;
function adler32(adler: Longint; const buf; len: Integer): Longint;
function crc32(crc: Longint; const buf; len: Integer): Longint;

{ Utilities }
function ZResultToString(const aResult: integer): string;

implementation

function ZResultToString(const aResult: integer): string;
begin
	case aResult of
		Z_OK:
		Result := 'Z_OK';
		Z_STREAM_END:
		Result := 'Z_STREAM_END';
		Z_NEED_DICT:
		Result := 'Z_NEED_DICT';
		Z_ERRNO:
		Result := 'Z_ERRNO';
		Z_STREAM_ERROR:
		Result := 'Z_STREAM_ERROR';
		Z_DATA_ERROR:
		Result := 'Z_DATA_ERROR';
		Z_MEM_ERROR:
		Result := 'Z_MEM_ERROR';
		Z_BUF_ERROR:
		Result := 'Z_BUF_ERROR';
		Z_VERSION_ERROR:
		Result := 'Z_VERSION_ERROR';
		else
		Result := 'Unknown return value.';
	end;
end;

{*************************************************************************************************
*  link zlib code                                                                                *
*                                                                                                *
*  bcc32 flags                                                                                   *
*    -c -O2 -Ve -X -pr -a8 -b -d -k- -vi -tWM -u-                                                *
*                                                                                                *
*  note: do not reorder the following -- doing so will result in external                        *
*  functions being undefined                                                                     *
*************************************************************************************************}

{$IFDEF WIN64}
{$L ..\Lib\ZLib\win64\deflate.obj}
{$L ..\Lib\ZLib\win64\inflate.obj}
{$L ..\Lib\ZLib\win64\inftrees.obj}
{$L ..\Lib\ZLib\win64\infback.obj}
{$L ..\Lib\ZLib\win64\inffast.obj}
{$L ..\Lib\ZLib\win64\trees.obj}
{$L ..\Lib\ZLib\win64\compress.obj}
{$L ..\Lib\ZLib\win64\adler32.obj}
{$L ..\Lib\ZLib\win64\crc32.obj}
{$ELSE}
{$L ..\Lib\ZLib\win32\deflate.obj}
{$L ..\Lib\ZLib\win32\inflate.obj}
{$L ..\Lib\ZLib\win32\inftrees.obj}
{$L ..\Lib\ZLib\win32\infback.obj}
{$L ..\Lib\ZLib\win32\inffast.obj}
{$L ..\Lib\ZLib\win32\trees.obj}
{$L ..\Lib\ZLib\win32\compress.obj}
{$L ..\Lib\ZLib\win32\adler32.obj}
{$L ..\Lib\ZLib\win32\crc32.obj}
{$ENDIF}

{ ====== }
{ Macros }
{ ====== }

function deflateInit(var strm: TZStreamRec; level: Integer): Integer;
begin
	result := deflateInit_(strm, level, ZLIB_VERSION, SizeOf(TZStreamRec));
end;

function deflateInit2(var strm: TZStreamRec; level, method, windowBits, memLevel, strategy: Integer): Integer;
begin
	result := deflateInit2_(strm, level, method, windowBits, memLevel, strategy, ZLIB_VERSION, SizeOf(TZStreamRec));
end;

function inflateInit(var strm: TZStreamRec): Integer;
begin
	result := inflateInit_(strm, ZLIB_VERSION, SizeOf(TZStreamRec));
end;

function inflateInit2(var strm: TZStreamRec; windowBits: Integer): Integer;
begin
	result := inflateInit2_(strm, windowBits, ZLIB_VERSION, SizeOf(TZStreamRec));
end;

{ ================= }
{ External routines }
{ ================= }

function deflateInit_(var strm: TZStreamRec; level: Integer; version: PAnsiChar; recsize: Integer): Integer; external;

function deflateInit2_(var strm: TZStreamRec; level, method, windowBits, memLevel, strategy: Integer; version: PAnsiChar; recsize: Integer): Integer; external;

function deflate(var strm: TZStreamRec; flush: Integer): Integer; external;

function deflateEnd(var strm: TZStreamRec): Integer; external;

function deflateReset(var strm: TZStreamRec): Integer; external;

function inflateInit_(var strm: TZStreamRec; version: PAnsiChar; recsize: Integer): Integer; external;

function inflateInit2_(var strm: TZStreamRec; windowBits: Integer; version: PAnsiChar; recsize: Integer): Integer; external;

function inflate(var strm: TZStreamRec; flush: Integer): Integer; external;

function inflateEnd(var strm: TZStreamRec): Integer; external;

function inflateReset(var strm: TZStreamRec): Integer; external;

function adler32(adler: Longint; const buf; len: Integer): Longint; external;

function crc32(crc: Longint; const buf; len: Integer): Longint; external;

{ ============================= }
{ ZLib function implementations }
{ ============================= }

function zcalloc(opaque: Pointer; items, size: Integer): Pointer;
begin
	GetMem(result, items * size);
end;

procedure zcfree(opaque, block: Pointer);
begin
	FreeMem(block);
end;

{ ========================== }
{ C function implementations }
{ ========================== }

function memset(p: Pointer; b: Byte; count: Integer): Pointer; cdecl;
begin
	FillChar(p^, count, b);

	result := p;
end;

procedure memcpy(dest, source: Pointer; count: Integer); cdecl;
begin
	Move(source^, dest^, count);
end;

{$IFNDEF WIN64}


procedure _llmod;
asm
	jmp System.@_llmod;
end;

{$ENDIF}

end.
