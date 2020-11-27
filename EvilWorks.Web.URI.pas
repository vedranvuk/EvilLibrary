//
// EvilLibrary by Vedran Vuk 2010-2012
//
// Name: 					EvilWorks.Web.URI
// Description: 			URI and encoding/decoding utilities.
// 							Contains code from Peter Johnson (http://www.delphidabbler.com/)
//
// File last change date: September 28th. 2012
// File version: 			0.0.1
// Comment:               	Slightly modified, trimmed and integrated with EvilLibrary. And OCD formated.
// 							Some extra helper classes added.
//
// URIEncode functions:
// Original Name:         UURIEncode.pas
// Original Date:         2010-05-28 04:34
// Original Author:       Peter Johnson (http://www.delphidabbler.com/)
// Original Licence:	  MPL 1.1/GPL 2.0/LGPL 2.1
//

unit EvilWorks.Web.URI;

interface

uses
	EvilWorks.System.StrUtils;

const
	cPercentEncodedSpace = '%20';
	cURIGenReservedChars = [':', '/', '?', '#', '[', ']', '@'];
	cURISubReservedChars = ['!', '$', '&', '''', '(', ')', '*', '+', ',', ';', '='];
	cURLUnreservedChars  = ['A' .. 'Z', 'a' .. 'z', '0' .. '9', '-', '_', '.', '~'];
	cURIReservedChars    = cURIGenReservedChars + cURISubReservedChars + [cPercent];

type
	{ TURIParser }
    { Parses an URI. https://user:pass@www.host.com:80/path/to/file.ext?par1=val1&par2=val2 }
    { URI MUST start with a scheme for parser to work. }
	TURIParser = record
	private
		FScheme: string;
		FUser  : string;
		FPass  : string;
		FHost  : string;
		FPort  : string;
		FPath  : string;
		FQuery : string;
		procedure Clear;
	public
		constructor Create(const aURI: string);
		function Parse(const aURI: string): boolean;

		property Scheme: string read FScheme;
		property User: string read FUser;
		property Pass: string read FPass;
		property Host: string read FHost;
		property Port: string read FPort;
		property Path: string read FPath;
		property Query: string read FQuery;

		function HostPort: string;

		function URI: string;
		function URIFromPath: string;
		function URIEncoded: string;
		function URIEncodedFromPath: string;
	end;

function URIEncode(const aStr: ansistring): string; overload;
function URIEncode(const aStr: UTF8String): string; overload;
function URIEncode(const aStr: unicodestring): string; overload;
function URIDecode(const aStr: string): string;

function URIEncodeQueryString(const aStr: UTF8String): string; overload;
function URIEncodeQueryString(const aStr: unicodestring): string; overload;
function URIEncodeQueryString(const aStr: ansistring): string; overload;
function URIDecodeQueryString(const aStr: string): string;

implementation

uses
	EvilWorks.Web.Base64,
    EvilWorks.Web.Punycode;

{ URI encodes aStr. }
function URIEncode(const aStr: ansistring): string; overload;
begin
	Result := URIEncode(UTF8Encode(aStr));
end;

{ URI encodes aStr. }
function URIEncode(const aStr: UTF8String): string; overload;
var
	ch: AnsiChar;
begin
	Result := CEmpty;

	for ch in aStr do
	begin
		if (ch in cURLUnreservedChars) then
			Result := Result + WideChar(ch)
		else
			Result := Result + cPercent + TextIntToHex(Ord(ch), 2);
	end;
end;

{ URI encodes aStr. }
function URIEncode(const aStr: unicodestring): string; overload;
begin
	Result := URIEncode(UTF8Encode(aStr));
end;

{ Decodes a URI encoded string. }
function URIDecode(const aStr: string): string;

	{ Counts number of '%' characters in a UTF8 string. }
	function CountPercent(const S: UTF8String): Integer;
	var
		i: Integer;
	begin
		Result := 0;
		for i  := 1 to Length(S) do
			if S[i] = cPercent then
				Inc(Result);
	end;

var
	srcUTF8: UTF8String; // input string as UTF-8
	srcIdx : Integer;    // index into source UTF-8 string
	resUTF8: UTF8String; // output string as UTF-8
	resIdx : Integer;    // index into result UTF-8 string
	hex    : string;     // hex component of % encoding
	chVal  : Integer;    // character ordinal value from a % encoding
begin
    // Convert input string to UTF-8
	srcUTF8 := UTF8Encode(aStr);
    // Size the decoded UTF-8 string: each 3 byte sequence starting with '%' is
    // replaced by a single byte. All other bytes are copied unchanged.
	SetLength(resUTF8, Length(srcUTF8) - 2 * CountPercent(srcUTF8));
	srcIdx := 1;
	resIdx := 1;
	while srcIdx <= Length(srcUTF8) do
	begin
		if srcUTF8[srcIdx] = cPercent then
		begin
      		// % encoding: decode following two hex chars into required code point
			if Length(srcUTF8) < srcIdx + 2 then
				Exit('');
			hex   := '$' + string(srcUTF8[srcIdx + 1] + srcUTF8[srcIdx + 2]);
			chVal := TextToInt(hex, - 1);
			if (chVal = - 1) then
				Exit('');
			resUTF8[resIdx] := AnsiChar(chVal);
			Inc(resIdx);
			Inc(srcIdx, 3);
		end
		else
		begin
      		// plain char or UTF-8 continuation character: copy unchanged
			resUTF8[resIdx] := srcUTF8[srcIdx];
			Inc(resIdx);
			Inc(srcIdx);
		end;
	end;

  	// Convert back to native string type for result
	Result := UTF8ToString(resUTF8);
end;

{ URI encodes query aStr component. Spaces in original string are encoded as "+".}
function URIEncodeQueryString(const aStr: ansistring): string; overload;
begin
	Result := URIEncodeQueryString(UTF8Encode(aStr));
end;

{ URI encodes query aStr component. Spaces in original string are encoded as "+".}
function URIEncodeQueryString(const aStr: UTF8String): string; overload;
begin
    // First we URI encode the string. This so any existing '+' symbols get
    // encoded because we use them to replace spaces and we can't confuse '+'
    // already in URI with those that we add. After this step spaces get encoded
    // as %20. So next we replace all occurences of %20 with '+'.
	Result := TextReplace(URIEncode(aStr), cPercentEncodedSpace, cPlus);
end;

{ URI encodes query aStr component. Spaces in original string are encoded as "+".}
function URIEncodeQueryString(const aStr: unicodestring): string; overload;
begin
	Result := URIEncodeQueryString(UTF8Encode(aStr));
end;

{ Decodes a URI encoded query aStr where spaces have been encoded as '+'. }
function URIDecodeQueryString(const aStr: string): string;
begin
    // First replace plus signs with spaces. We use percent-encoded spaces here
    // because string is still URI encoded and space is not one of unreserved
    // chars and therefor should be percent-encoded. Finally we decode the
    // percent-encoded string.
	Result := URIDecode(TextReplace(aStr, cPlus, cPercentEncodedSpace, True));
end;

{ ========== }
{ TURIParser }
{ ========== }

{ Parses an URI. Get parts via public properties. }
constructor TURIParser.Create(const aURI: string);
begin
	Parse(aURI);
end;

{ Clears internal vars. }
procedure TURIParser.Clear;
begin
	FScheme := CEmpty;
	FUser   := CEmpty;
	FPass   := CEmpty;
	FHost   := CEmpty;
	FPort   := CEmpty;
	FPath   := CEmpty;
	FQuery  := CEmpty;
end;

{ Parses a URI. Get parts via public properties. }
function TURIParser.Parse(const aURI: string): boolean;
var
	str: string;
begin
	if (aURI = CEmpty) then
		Exit(False)
	else
		Result := True;

	str := aURI;

    // Get scheme
	FScheme := TextExtractLeft(str, CURISchemeDelimiter, True);
	if (FScheme = CEmpty) then
		FScheme := TextExtractLeft(str, CColon, True);
	if (FScheme = CEmpty) then
	begin
		Clear;
		Exit(False);
	end;

    // Extract optional user:pass@
	FUser := TextExtractLeft(str, CMonkey, True);

    // Extract optional pass.
	if (FUser <> CEmpty) then
		FPass := TextExtractRight(FUser, CColon, True);

    // Extract host.
	FHost := TextExtractLeft(str, CFrontSlash, True, False);
	if (FHost = CEmpty) then
	begin
		FHost := str;
		if (FHost = CEmpty) then
		begin
			Clear;
			Exit(False);
		end
		else
			str := CEmpty;
	end;

    // Extract optional port.
	FPort := TextExtractRight(FHost, CColon, True);

    // Extract optional path.
	FPath := TextExtractLeft(str, CQuestionMark, True);
	if (FPath = CEmpty) then
	begin
		FPath := str;
		if (FPath = CEmpty) then
			FPath := CFrontSlash;
		Exit;
	end;

    // What's left is the query.
	FQuery := str;
end;

{ Returns "Host:Port" }
function TURIParser.HostPort: string;
begin
	if (Host = '') then
		Exit('')
	else
		Result := FHost;
	if (FPort <> '') then
		Result := Result + ':' + FPort;
end;

{ Returns the parsed URI joined and encoded for HTTP method line. }
{ 'GET' + ' ' + TURIParser.URIEncoded }
function TURIParser.URI: string;
begin
	Result := CEmpty;
	if (FScheme = CEmpty) or (FHost = CEmpty) then
		Exit;

	Result := FScheme + CURISchemeDelimiter;
	if (FUser <> CEmpty) then
		Result := Result + FUser;

	if (FPass <> CEmpty) then
		Result := Result + CColon + FPass + CMonkey
	else if (FUser <> CEmpty) then
		Result := Result + CMonkey;

	Result := Result + FHost;
	Result := Result + URIFromPath;
end;

function TURIParser.URIFromPath: string;
var
	pathTokens: TTokens;
	i         : integer;
begin
	Result := CEmpty;
	if (FPath = CEmpty) then
		Exit;

    // Encode path parts, but don't encode path delimiters.
	pathTokens := TextTokenize(FPath, CFrontSlash);
	for i      := 0 to pathTokens.Count - 1 do
		Result := Result + CFrontSlash + pathTokens[i];
	if (TextEnds(FPath, CFrontSlash, True)) then
		Result := Result + CFrontSlash;

    // Encode query.
	if (FQuery <> CEmpty) then
		Result := Result + CQuestionMark + FQuery;
end;

function TURIParser.URIEncoded: string;
begin
	Result := CEmpty;
	if (FScheme = CEmpty) or (FHost = CEmpty) then
		Exit;

	Result := FScheme + CURISchemeDelimiter;
	if (FUser <> CEmpty) then
		Result := Result + FUser;

	if (FPass <> CEmpty) then
		Result := Result + CColon + FPass + CMonkey
	else if (FUser <> CEmpty) then
		Result := Result + CMonkey;

	Result := Result + FHost;
	Result := Result + URIEncodedFromPath;
end;

{ Same as URIEncoded(), but starts from path: /path/to/file.json?par1%3Dval1%26par2%3Dval2 }
function TURIParser.URIEncodedFromPath: string;
var
	pathTokens: TTokens;
	i         : integer;
begin
	Result := CEmpty;
	if (FPath = CEmpty) then
		Exit;

    // Encode path parts, but don't encode path delimiters.
	pathTokens := TextTokenize(FPath, CFrontSlash);
	for i      := 0 to pathTokens.Count - 1 do
		Result := Result + CFrontSlash + URIEncode(pathTokens[i]);
	if (TextEnds(FPath, CFrontSlash, True)) then
		Result := Result + CFrontSlash;

    // Encode query.
	if (FQuery <> CEmpty) then
		Result := Result + CQuestionMark + URIEncodeQueryString(FQuery);
end;

end.
