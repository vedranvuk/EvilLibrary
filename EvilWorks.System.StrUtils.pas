//
// EvilLibrary by Vedran Vuk 2010-2012
//
// Name: 					EvilWorks.System.StrUtils
// Description: 			A collection of pure pascal string parsing functions! :)
//                          And still ~100x faster than Python, PHP, javascript... :P
// File last change date:   October 30th. 2012
// File version: 			Dev 0.0.0
// Licence:                 Free.
//

unit EvilWorks.System.StrUtils;

interface

uses
	System.SysUtils,
	System.StrUtils;

{$I EvilWorks.System.StrUtils.inc}

type
	{ Forward declarations }
	TTokensEnumerator = class;

	{ TSplitOption }
	{ Options for TextSplit(), TextTokenize() }
	TSplitOption = (
	  soNoDelSep,  // Tokens will be added to list along with their trailing separators.
	  soCSSep,     // Token separators are treated as Case Sensitive. SPEEDS UP! parsing.
	  soCSQot,     // Quote character/string is treated as Case Sensitive. SPEEDS UP! parsing if [soQuoted].
	  soSingleSep, // Splitting will stop after the first separator; Two tokens total.
	  soQuoted,    // Treat strings quoted/enclosed in Quote as single token.
	  soRemQuotes  // Remove Quote from parsed out tokens.
	  );
	TSplitOptions = set of TSplitOption;

    { TPair }
    { Your standard Key=Value pair record. }
	TPair = record
		Key: string;
		Val: string;
	end;

    { TTokens }
    { A helpful text array container for all sorts of formatting and parsing. }
    { Can be declared as standalone (initialize with Clear), or returned by TextTokenize(). }
	TTokens = record
	private
		FTokens: TArray<string>;
		FCount : Integer;
		function GetToken(const aIndex: Integer): string;
		procedure QuickSort(aStart, aEnd: Integer);
		function GetPair(const aIndex: integer): TPair;
	public
		function GetEnumerator: TTokensEnumerator;

		function FromToken(const aIndex: Integer; const aDelimiter: string = CSpace): string;
		function ToToken(const aIndex: Integer; const aDelimiter: string = CSpace): string;
		function AllTokens(const aDelimiter: string = CSpace): string;

		procedure Add(const aText: string); overload;

		procedure Add(const aKey, aVal: string); overload;
		procedure Add(const aKey: string; const aVal: integer); overload;
		procedure Add(const aKey: string; const aVal: boolean); overload;

		procedure AddQ(const aKey, aVal: string); overload;
		procedure AddQ(const aKey: string; const aVal: integer); overload;
		procedure AddQ(const aKey: string; const aVal: boolean); overload;

		procedure Exchange(aIndexA, aIndexB: Integer);
		procedure Sort;
		procedure Clear;

		function ToArray(const aFromToken: integer = 0; const aToToken: integer = maxint): TArray<string>; overload;

		property Token[const aIndex: Integer]: string read GetToken; default;
		property Pair[const aIndex: integer]: TPair read GetPair;
		property Count: Integer read FCount;
		function Empty: boolean;
	end;

    { TTokensEnumerator }
    { Enumerator for TTokens. }
	TTokensEnumerator = class
	private
		FIndex : integer;
		FTokens: TTokens;
	public
		constructor Create(aTokens: TTokens);
		function GetCurrent: string; inline;
		function MoveNext: Boolean; inline;
		property Current: string read GetCurrent;
	end;

{ Basic string handling }
function TextPos(const aText, aSubText: string; const aCaseSens: boolean = False; const aOfs: Integer = 1): Integer;
function TextCopy(const aText: string; const aStartIdx, aCount: Integer): string;
function TextUpCase(const aText: string): string;
function TextLoCase(const aText: string): string;
function TextReplace(const aText, aSubText, aNewText: string; const aCaseSens: boolean = False): string;
procedure TextAppend(var aText: string; const aAppendWith: string);

{ More exotic functions of basic variety }
procedure TextAppendWithFeed(var aText: string; const aAppendWith: string);
procedure TextKeyValueAppend(var aOutStr: string; const aKey, aValue: string; const aAnd: boolean = True);
function TextEscStr(const aText, aEscape: string): string;

{ Comparison, extraction, splitting, tokenizing... }
function TextLeft(const aText: string; const aCount: Integer): string;
function TextRight(const aText: string; const aCount: Integer): string;
function TextBegins(const aText, aBeginsWith: string; aCaseSens: boolean = False): boolean;
function TextEnds(const aText, aEndsWith: string; aCaseSens: boolean = False): boolean;
function TextSame(const aTextA, aTextB: string; const aCaseSens: boolean = False): boolean; inline;
function TextEquals(const aTextA, aTextB: string; const aCaseSens: boolean = False): boolean;
function TextInText(const aText, aContainsText: string; const aCaseSens: boolean = False): boolean;
function TextInArray(const aText: string; const aArray: array of string; const aAnywhere: boolean = True; const aCaseSens: boolean = False): boolean;
function TextWildcard(const aText, aWildCard: string): boolean;
function TextEnclosed(const aText, aLeftSide, aRightSide: string; const aCaseSens: boolean = False): boolean; overload;
function TextEnclosed(const aText, aEnclosedWith: string; const aCaseSens: boolean = False): boolean; overload;
function TextEnclose(const aText, aEncloseWith: string): string;
function TextUnEnclose(const aText, aEnclosedWith: string; const aCaseSens: boolean = False): string; overload;
function TextUnEnclose(const aText, aLeftSide, aRightSide: string; const aCaseSens: boolean = False): string; overload;
function TextFindEnclosed(const aText, aEnclLeft, aEnclRight: string; const aIdx: Integer; const aRemEncl: boolean = True; const aCaseSens: boolean = False): string; overload;
function TextFindEnclosed(const aText, aEncl: string; const aIdx: Integer; const aRemEncl: boolean = True; const aCaseSens: boolean = False): string; overload;
function TextQuote(const aText: string): string;
function TextUnquote(const aText: string): string;
function TextRemoveLineFeeds(const aText: string): string;
function TextExtractLeft(var aText: string; const aSep: string; const aCaseSens: boolean = False; const aDelSep: boolean = True): string;
function TextExtractRight(var aText: string; const aSep: string; const aCaseSens: boolean = False; const aDelSep: boolean = True): string;
function TextFetchLeft(const aText, aSep: string; const aCaseSens: boolean = False; const aEmptyIfNoSep: boolean = True): string;
function TextFetchRight(const aText, aSep: string; const aCaseSens: boolean = False; const aEmptyIfNoSep: boolean = True; const aSepFromRight: boolean = True): string;
function TextFetchLine(const aText: string): string;
function TextRemoveLeft(const aText, aRemove: string; const aCaseSens: boolean = False): string;
function TextRemoveRight(const aText, aRemove: string; const aCaseSens: boolean = False): string;
function TextSplit(const aText: string; const aSep: string = CSpace; const aQotStr: string = CDoubleQuote; const aOptions: TSplitOptions = [soCSSep, soCSQot]): TArray<string>;
function TextSplitMarkup(const aText: string; const aTrim: boolean = True): TArray<string>;
function TextTokenize(const aText: string; const aSep: string = CSpace; const aQotStr: string = CDoubleQuote; const aOptions: TSplitOptions = [soCSSep, soCSQot]): TTokens;
function TextToken(const aText: string; const aIndex: integer; const aSeparator: string = CSpace): string;

{ Conversion and formating rotines }
function TextToInt(const aText: string; const aDefault: Integer): Integer;
function TextFromBool(const aBoolean: boolean; const aUseBoolStrings: boolean = True): string;
function TextFromInt(const aByte: byte): string; overload;
function TextFromInt(const aInteger: integer): string; overload;
function TextFromInt(const aCardinal: cardinal): string; overload;
function TextFromInt(const aInt64: int64): string; overload;
function TextFromFloat(const aFloat: double; const aDecimals: byte = 6): string; overload;
function TextFromFloat(const aExtended: extended; const aDecimals: byte = 6): string; overload;
function TextHexToDec(const aHexStr: string): cardinal;
function TextIntToHex(const aValue, aDigits: integer): string;
function TextMake(const aArgs: array of const; const aSeparator: string = ' '): string;

{ URI text related functions }
function TextURISplit(const aURI: string; var aPrefix, aHost, aPath: string): boolean; overload;
function TextURISplit(const aURI: string; var aPrefix, aHost, aPath, aParams: string): boolean; overload;
function TextURIGetPath(const aURI: string): string;
function TextURIExtractParams(const aURI: string): string;
function TextURIWithoutParams(const aURI: string): string;

{ Various utility functions }
function TextDump(const aData: pByte; const aSize: integer; const aBytesPerLine: byte = 16): string;
procedure TextSave(const aText, aFileName: string);
function TextOfChar(const aChar: char; const aLength: integer): string;

{ IRC related functions }
function SplitHostMask(const aHostMask: string; var aNickname, aIdent, aHost: string): boolean;

{ Random string generation functions }
function RandomNum: char;
function RandomNums(const aLength: byte): string;
function RandomAlphaLower: char;
function RandomAlphaLowers(const aLength: byte): string;
function RandomAlphaUpper: char;
function RandomAlphaUppers(const aLength: byte): string;
function RandomVowelLower: char;
function RandomVowelUpper: char;
function RandomVowel: char;
function RandomConsonantLower: char;
function RandomConsonantUpper: char;
function RandomConsonant: char;
function RandomString(const aLength: Integer; const aLowerCase, aUpperCase, aNumeric: boolean): string; overload;

type
	TTextHelper = record helper for string
    public
		function Len: integer;
		function Size: integer; inline;
		function Pos(const aSubText: string; const aCaseSens: boolean = False; const aOfs: Integer = 1): Integer;
		function Copy(const aStartIdx, aCount: Integer): string;
		function UpCase: string;
		function LoCase: string;
		function Replace(const aSubText, aNewText: string; const aCaseSens: boolean = False): string;
		function Append(const aAppendWith: string; const aOnlyIfNotExists: boolean = False;
		  const aCaseSensitive: boolean = False): string;
		function Left(const aLen: integer): string;
		function Right(const aLen: integer): string;
        function Begins(const aWith: string; const aCaseSensitive: boolean = False): boolean;
        function Ends(const aWith: string; const aCaseSensitive: boolean = False): boolean;
		function Equals(const aToText: string; const aCaseSensitive: boolean = False): boolean;
        function ToInt(const aDefault: integer = -1): integer;
	end;

implementation

{ TTextHelper }

{ Length of Self in characters. }
function TTextHelper.Len: integer;
begin
	Result := Length(Self);
end;

{ Size of Self in memory. Len * Self element size. }
function TTextHelper.Size: integer;
begin
	Result := (Self.Len * StringElementSize(Self));
end;

{ Convert to int. Return aDefault on fail. }
function TTextHelper.ToInt(const aDefault: integer): integer;
var
	code: Integer;
begin
	Val(Self, Result, code);
	if (code <> 0) then
		Result := aDefault;
end;

{ Get position of substring aSubText. 0 if not found. aOfs sets search start offset. }
function TTextHelper.Pos(const aSubText: string; const aCaseSens: boolean; const aOfs: Integer): Integer;
begin
	Result := EvilWorks.System.StrUtils.TextPos(Self, aSubText, acaseSens, aOfs);
end;

{ Copy part of the string defined with aStartIdx and aCount. Returns nothing on invalid params or empty. }
function TTextHelper.Copy(const aStartIdx, aCount: Integer): string;
begin
	Result := EvilWorks.System.StrUtils.TextCopy(Self, aStartIdx, aCount);
end;

{ Return UPPERCASE formatted self. }
function TTextHelper.UpCase: string;
begin
	Result := EvilWorks.System.StrUtils.TextUpCase(Self);
end;

{ Return lowercase formatted self. }
function TTextHelper.LoCase: string;
begin
	Result := EvilWorks.System.StrUtils.TextLoCase(Self);
end;

{ Replace aSubText in Self with aNewText, return result. aCaseSens sets case sensitivity of the search. }
{ If aSubText is not found Self is just copied to result. }
function TTextHelper.Replace(const aSubText, aNewText: string; const aCaseSens: boolean): string;
begin
	Result := EvilWorks.System.StrUtils.TextReplace(Self, aSubText, aNewText, aCaseSens);
end;

{ Append self with aAppendWith. If aOnlyIfExists will be appended only if Self is not already suffixed. }
{ aCaseSensitive sets case sensitivity of existing aAppendWith suffix. }
function TTextHelper.Append(const aAppendWith: string; const aOnlyIfNotExists: boolean;
  const aCaseSensitive: boolean): string;
begin
	if (aOnlyIfNotExists) then
		if (TextEquals(Self.Right(aAppendWith.Len), aAppendWith, aCaseSensitive)) then
			Exit(Self);
	Result := Self + aAppendWith;
end;

{ Return aLen chars from left of Self. If aLen > than Self.Len, just return all there is. }
function TTextHelper.Left(const aLen: integer): string;
begin
	Result := TextCopy(Self, 1, aLen);
end;

{ Return aLen chars from right of Self. If aLen > than Self.Len, just return all there is. }
function TTextHelper.Right(const aLen: integer): string;
begin
	Result := Self.Copy(Self.Len - aLen + 1, aLen);
end;

{ Checks if Self begins with aWith. aCaseSensitive sets search case sensitivity. }
function TTextHelper.Begins(const aWith: string; const aCaseSensitive: boolean): boolean;
begin
	Result := TextEquals(Self.Left(aWith.Len), aWith, aCaseSensitive);
end;

{ Checks if Self ends with aWith. aCaseSensitive sets search case sensitivity. }
function TTextHelper.Ends(const aWith: string; const aCaseSensitive: boolean): boolean;
begin
	Result := TextEquals(Self.Right(aWith.Len), aWith, aCaseSensitive);
end;

{ Checks if Self equals aToText. aCaseSensitive sets search case sensitivity. }
function TTextHelper.Equals(const aToText: string; const aCaseSensitive: boolean): boolean;
begin
	if (aCaseSensitive) then
		Result := (Self = aToText)
	else
		Result := SameText(Self, aToText);
end;

{ Combines Pos and PosEx. }
function TextPos(const aText, aSubText: string; const aCaseSens: boolean = False; const aOfs: Integer = 1): Integer;
begin
	if (aCaseSens = False) then
		Result := PosEx(LowerCase(aSubText), LowerCase(aText), aOfs)
	else
		Result := PosEx(aSubText, aText, aOfs);
end;

{ Safe Copy. Won't go apeshit if aStartIdx is > Length(aText), instead it just returns empty string. }
function TextCopy(const aText: string; const aStartIdx, aCount: Integer): string;
begin
	{ Safe Copy. Won't go apeshit if aStartIdx is > Length(aText). }
	if (aStartIdx > Length(aText)) then
		Exit(CEmpty);
	Result := Copy(aText, aStartIdx, aCount);
end;

{ Uppercase }
function TextUpCase(const aText: string): string;
var
	i: integer;
begin
	SetLength(Result, Length(aText));
	for i         := 0 to Length(aText) - 1 do
		Result[1] := UpCase(aText[i]);
end;

{ Lowercase }
function TextLoCase(const aText: string): string;
begin
	Result := LowerCase(aText);
end;

{ Replaces all occurances of aSubText with aNewText in aText. }
function TextReplace(const aText, aSubText, aNewText: string; const aCaseSens: boolean = False): string;
var
	i: Integer;
	j: Integer;
begin
	Result := CEmpty;

	if (aText = CEmpty) then
		Exit;

	j := 1;
	while (True) do
	begin
		i := TextPos(aText, aSubText, aCaseSens, j);
		if (i > 0) then
		begin
			Result := Result + TextCopy(aText, j, i - j) + aNewText;
			i      := i + Length(aSubText);
			j      := i;
		end
		else
		begin
			Result := Result + TextRight(aText, Length(aText) - j + 1);
			Exit;
		end;
	end;
end;

{ Append aText with aAppendWith }
procedure TextAppend(var aText: string; const aAppendWith: string);
begin
	aText := aText + aAppendWith;
end;

{ Append aText with aAppendWith and CRLF. }
procedure TextAppendWithFeed(var aText: string; const aAppendWith: string);
begin
	aText := aText + aAppendWith + CCrLf;
end;

{ Append aKey="aValue" pair to aOutStr and add ', ' if aAnd: aKey="aValue",  }
procedure TextKeyValueAppend(var aOutStr: string; const aKey, aValue: string; const aAnd: boolean = True);
begin
	if (aAnd) then
		aOutStr := aOutStr + aKey + '="' + aValue + '", '
	else
		aOutStr := aOutStr + aKey + '="' + aValue + '"';
end;

{ Escape/replace all %s tokens in aText with aEscape}
function TextEscStr(const aText, aEscape: string): string;
begin
	Result := TextReplace(aText, '%s', aEscape, False);
end;

{ Copies aCount chars from Left of aText. }
function TextLeft(const aText: string; const aCount: Integer): string;
begin
	Result := TextCopy(aText, 1, aCount);
end;

{ Copies aCount chars from Right of aText. }
function TextRight(const aText: string; const aCount: Integer): string;
begin
	Result := TextCopy(aText, Length(aText) - aCount + 1, aCount);
end;

{ Checks if aText begins with aBeginsWith. }
function TextBegins(const aText, aBeginsWith: string; aCaseSens: boolean = False): boolean;
begin
	if (aCaseSens) then
		Result := (TextLeft(aText, Length(aBeginsWith)) = aBeginsWith)
	else
		Result := (SameText(TextLeft(aText, Length(aBeginsWith)), aBeginsWith));
end;

{ Checks if aText ends with aEndsWith. }
function TextEnds(const aText, aEndsWith: string; aCaseSens: boolean = False): boolean;
begin
	if (aCaseSens) then
		Result := (TextRight(aText, Length(aEndsWith)) = aEndsWith)
	else
		Result := (SameText(TextRight(aText, Length(aEndsWith)), aEndsWith));
end;

{ Checks if aTextA is same as aTextB. Alias for TextEquals. }
function TextSame(const aTextA, aTextB: string; const aCaseSens: boolean): boolean; inline;
begin
	Result := TextEquals(aTextA, aTextB, aCaseSens);
end;

{ Checks if aTextA is same as aTextB. }
function TextEquals(const aTextA, aTextB: string; const aCaseSens: boolean): boolean;
begin
	if (aCaseSens) then
		Result := (aTextA = aTextB)
	else
		Result := SameText(aTextA, aTextB);
end;

{ Checks if aText contains aContainsText. }
function TextInText(const aText, aContainsText: string; const aCaseSens: boolean): boolean;
begin
	Result := (TextPos(aText, aContainsText, aCaseSens) <> 0);
end;

{ Checks if aText matches any entries in aArray. If aAnywhere, aText matches anywhere in an aArray item. }
function TextInArray(const aText: string; const aArray: array of string; const aAnywhere: boolean; const aCaseSens: boolean): boolean;
var
	i: integer;
begin
	Result := False;
	for i  := 0 to high(aArray) do
	begin
		if (aAnywhere) then
		begin
			if (TextInText(aArray[i], aText, aCaseSens)) then
				Exit(True);
		end
		else
		begin
			if (TextEquals(aArray[i], aText, aCaseSens)) then
				Exit(True);
		end;
	end;
end;

{ Matches aText agains aWildCard. Case insensitive. * and ? supported. For IRC. }
function TextWildcard(const aText, aWildCard: string): boolean;
var
	ps: pchar;
	pw: pchar;
	mp: pchar;
	cp: pchar;
begin
	if (aText = '') or (aWildCard = '') then
		Exit(False);

	ps := @aText[1];
	pw := @aWildCard[1];
	mp := nil;
	cp := nil;

	while ((ps^ <> #0) and (pw^ <> CAsterisk)) do
	begin
		if ((pw^ <> CQuestionMark) and (SameText(ps^, pw^) = False)) then
			Exit(False);
		Inc(ps);
		Inc(pw);
	end;

	while (ps^ <> #0) do
	begin
		if (pw^ = CAsterisk) then
		begin
			Inc(pw);
			if (pw^ = #0) then
				Exit(True);
			mp := pw;
			cp := @ps[1];
		end
		else
		begin
			if (SameText(ps^, pw^)) or (pw^ = CQuestionMark) then
			begin
				Inc(ps);
				Inc(pw);
			end
			else
			begin
				ps := cp;
				Inc(cp);
				pw := mp;
			end;
		end;
	end;

	while (pw^ = CAsterisk) do
		Inc(pw);

	Result := (pw^ = #0);
end;

{ Checks if left of aText is prefixed with aLeftSide and right of aText is suffixed with aRightSide. }
function TextEnclosed(const aText, aLeftSide, aRightSide: string; const aCaseSens: boolean = False): boolean;
begin
	if (aCaseSens) then
		Result := ((TextLeft(aText, Length(aLeftSide)) = aLeftSide) and (TextRight(aText, Length(aRightSide)) = aRightSide))
	else
		Result := (SameText(TextLeft(aText, Length(aLeftSide)), aLeftSide) and SameText(TextRight(aText, Length(aRightSide)), aRightSide));
end;

{ Checks if aText is prefixed and suffixed with aEnclosedWith. e.g. xXxTeenageDawgxXx }
function TextEnclosed(const aText, aEnclosedWith: string; const aCaseSens: boolean = False): boolean;
begin
	Result := TextEnclosed(aText, aEnclosedWith, aEnclosedWith, aCaseSens);
end;

{ Encloses a aText within aEncloseWith. }
function TextEnclose(const aText, aEncloseWith: string): string;
begin
	Result := aEncloseWith + aText + aEncloseWith;
end;

{ Removes aEnclosedWith prefix AND/OR suffix from aText. }
function TextUnEnclose(const aText, aEnclosedWith: string; const aCaseSens: boolean = False): string;
begin
	Result := TextUnEnclose(aText, aEnclosedWith, aEnclosedWith, aCaseSens);
end;

{ Removes aLeftSide prefix from Left AND/OR aRightSide suffix from Right side of aText. }
function TextUnEnclose(const aText, aLeftSide, aRightSide: string; const aCaseSens: boolean = False): string; overload;
begin
	if (aCaseSens) then
	begin
		if (TextLeft(aText, Length(aLeftSide)) = aLeftSide) then
			Result := TextCopy(aText, Length(aLeftSide) + 1, MaxInt)
		else
			Result := aText;

		if (TextRight(Result, Length(aRightSide)) = aRightSide) then
			Delete(Result, Length(Result), Length(aRightSide));
	end
	else
	begin
		if (SameText(TextLeft(aText, Length(aLeftSide)), aLeftSide)) then
			Result := TextCopy(aText, Length(aLeftSide) + 1, MaxInt)
		else
			Result := aText;

		if (SameText(TextRight(Result, Length(aRightSide)), aRightSide)) then
			Delete(Result, Length(Result), Length(aRightSide));
	end;
end;

{ Find and return aIdx(th) (0-based) occurance of text in aText that is enlosed with aEnclLeft on left and }
{ aEnclRight on the right of text. If aRemEncl, aEnclLeft and aEnclRight are removed from result, aCaseSens }
{ makes the search Case-sensitive. If no enclosed text is found, result is an empty string. }
function TextFindEnclosed(const aText, aEnclLeft, aEnclRight: string; const aIdx: Integer; const aRemEncl: boolean = True; const aCaseSens: boolean = False): string;
var
	a : Integer;
	b : Integer;
	ea: integer;
	eb: integer;
	l : Integer;
	i : Integer;
begin
	Result := CEmpty;

	if (aText = CEmpty) then
		Exit;

	a  := 1;
	b  := 1;
	l  := Length(aText);
	ea := Length(aEnclLeft);
	eb := Length(aEnclRight);
	i  := 0;
	while (i <= aIdx) and (a < l) and (b < l) do
	begin
		a := TextPos(aText, aEnclLeft, aCaseSens, b);
		if (a = 0) then
			Exit;

		b := TextPos(aText, aEnclRight, aCaseSens, a + ea);
		if (b <= a) then
			Exit;

		if (i = aIdx) then
		begin
			if (aRemEncl) then
				Result := TextCopy(aText, a + ea, b - a - ea)
			else
				Result := TextCopy(aText, a, b - a + eb);
		end;
		a := b + eb;
		b := a;
		Inc(i);
	end; { while }
end;

{ Find and return aIdx occurance of text in aText that is enlosed with aEncl. If aRemEncl, aEncl is removed }
{ from result. aCase sens makes the search Case-sensitive. If no enclosed text is found, result is empty. }
function TextFindEnclosed(const aText, aEncl: string; const aIdx: Integer; const aRemEncl: boolean; const aCaseSens: boolean): string;
begin
	Result := TextFindEnclosed(aText, aEncl, aEncl, aIdx, aRemEncl, aCaseSens);
end;

{ Encloses aText with Double quotes. "Got it?" }
function TextQuote(const aText: string): string;
begin
	Result := TextEnclose(aText, CDoubleQuote);
end;

{ Removes Double quote prefix AND/OR suffix from aText. }
function TextUnquote(const aText: string): string;
begin
	Result := TextUnEnclose(aText, CDoubleQuote);
end;

{ Strips $0D and $0A from end of text until it finds no more. }
function TextRemoveLineFeeds(const aText: string): string;
var
	i: Integer;
begin
	i := Length(aText);
	while (i > 0) and ((aText[i] = CCr) or (aText[i] = CLf)) do
		Dec(i);
	Result := TextCopy(aText, 1, i);
end;

{ Removes string from Left of aText to aSep. If aSep is not found, nothing is returned or removed. }
{ aSep search begins from Left of aText. If aDelSep is false returns aSep as well. }
function TextExtractLeft(var aText: string; const aSep: string; const aCaseSens: boolean = False; const aDelSep: boolean = True): string;
var
	i: Integer;
begin
	i := TextPos(aText, aSep, aCaseSens);
	if (i > 0) then
	begin
		Result := TextCopy(aText, 1, i - 1);
		Delete(aText, 1, i - 1);
		if (aDelSep) then
			Delete(aText, 1, Length(aSep));
	end;
end;

{ Removes string from Right of aText to aSep. If aSep is not found, nothing is returned or removed. }
{ aSep search begins from Right of aText. If aDelSep is false returns aSep as well. }
function TextExtractRight(var aText: string; const aSep: string; const aCaseSens: boolean = False; const aDelSep: boolean = True): string;
var
	i, ofs: Integer;
begin
	i   := 0;
	ofs := 1;
	while (ofs <> 0) do
	begin
		ofs := TextPos(aText, aSep, aCaseSens, ofs);
		if (ofs <> 0) then
		begin
			i := ofs;
			Inc(ofs);
		end
		else
			Break;
	end;

	if (i <> 0) then
	begin
		Result := TextRight(aText, Length(aText) - i);
		Delete(aText, i, MaxInt);
	end;
end;

{ Copies string from Left of aText to aSep. If aSep is not found, returns nothing. }
{ aSep search begins from Left of aText. }
function TextFetchLeft(const aText, aSep: string; const aCaseSens: boolean = False; const aEmptyIfNoSep: boolean = True): string;
var
	i: Integer;
begin
	i := TextPos(aText, aSep, aCaseSens);
	if (i > 0) then
		Result := TextLeft(aText, i - 1)
	else if (aEmptyIfNoSep) then
		Result := CEmpty
	else
		Result := aText;
end;

{ Copies string from Right of aText to aSep. If aSep is not found returns nothing. }
{ If aSepFromRight aSep search begins from Right of aText, else from left. }
function TextFetchRight(const aText, aSep: string; const aCaseSens: boolean; const aEmptyIfNoSep: boolean; const aSepFromRight: boolean): string;
var
	i, ofs: Integer;
begin
	if (aSepFromRight) then
	begin
		i   := 0;
		ofs := 1;
		while (ofs <> 0) do
		begin
			ofs := TextPos(aText, aSep, aCaseSens, ofs);
			if (ofs <> 0) then
			begin
				i := ofs;
				Inc(ofs);
			end
			else
				Break;
		end;

		if (i = 0) then
			if (aEmptyIfNoSep) then
				Exit(CEmpty)
			else
				Exit(aText);
		Result := TextRight(aText, Length(aText) - i - Length(aSep) + 1);
	end
	else
	begin
		i := TextPos(aText, aSep, aCaseSens);
		if (i > 0) then
			Result := TextRight(aText, Length(aText) - i - Length(aSep) + 1)
		else if (aEmptyIfNoSep) then
			Result := CEmpty
		else
			Result := aText;
	end;
end;

{ Copies string from Left of aText to first CRLF separator. If aSep is not found, returns nothing. }
function TextFetchLine(const aText: string): string;
begin
	Result := TextFetchLeft(atext, #13#10, True);
end;

{ Removes aRemove from the Left of aText, returns the rest. }
function TextRemoveLeft(const aText, aRemove: string; const aCaseSens: boolean = False): string;
begin
	if (TextBegins(aText, aRemove, aCaseSens)) then
		Result := TextCopy(aText, Length(aRemove) + 1, MaxInt)
	else
		Result := aText;
end;

{ Removes aRemove from the Right of aText, returns the rest. }
function TextRemoveRight(const aText, aRemove: string; const aCaseSens: boolean = False): string;
begin
	if (TextEnds(aText, aRemove, aCaseSens)) then
		Result := TextCopy(aText, 1, Length(aText) - Length(aRemove))
	else
		Result := aText;
end;

{ Splits aText on aSep(s), returns an array of strings. }
function TextSplit(const aText: string; const aSep: string; const aQotStr: string; const aOptions: TSplitOptions): TArray<string>;
var
	Count: Integer;

	procedure Add(const aString: string);
	begin
		if (aString = CEmpty) then
			Exit;
		Inc(Count);
		SetLength(Result, Count);
		Result[Count - 1] := aString;
	end;

var
	strLen: Integer;
	sepLen: Integer;
	qotLen: Integer;
	cpyPos: Integer;
	ofsPos: Integer;
	tokPos: Integer;
	qotPos: Integer;

begin
	if ((aText = CEmpty) or (aSep = CEmpty)) then
		Exit;

	if (soQuoted in aOptions) then
		if (aQotStr = CEmpty) then
			Exit;

	Count := 0;

	strLen := Length(aText);
	sepLen := Length(aSep);

	cpyPos := 1;
	ofsPos := 1;

	if (soQuoted in aOptions) then
	begin
		qotLen := Length(aQotStr);
		qotPos := 1;
		while (True) do
		begin
			tokPos := TextPos(aText, aSep, (soCSSep in aOptions), ofsPos);
			qotPos := TextPos(aText, aQotStr, (soCSQot in aOptions), qotPos);
			if (qotPos < tokPos) and (qotPos <> 0) then
			begin
				qotPos := TextPos(aText, aQotStr, (soCSQot in aOptions), qotPos + qotLen);
				if (qotPos <> 0) then
				begin
					ofsPos := qotPos;
					qotPos := qotPos + qotLen;
				end
				else
					qotPos := MaxInt;
			end
			else
			begin
				if (tokPos = 0) then
				begin
					Add(TextCopy(aText, cpyPos, MaxInt));
					Exit;
				end
				else
				begin
					if (soNoDelSep in aOptions) then
					begin
						if (soRemQuotes in aOptions) then
							Add(TextUnEnclose(TextCopy(aText, cpyPos, tokPos - cpyPos + sepLen), aQotStr, (soCSQot in aOptions)))
						else
							Add(TextCopy(aText, cpyPos, tokPos - cpyPos + sepLen))
					end
					else
					begin
						if (soRemQuotes in aOptions) then
							Add(TextUnEnclose(TextCopy(aText, cpyPos, tokPos - cpyPos), aQotStr, (soCSQot in aOptions)))
						else
							Add(TextCopy(aText, cpyPos, tokPos - cpyPos));
					end;
					ofsPos := tokPos + sepLen;
					qotPos := ofsPos;
					cpyPos := ofsPos;
				end;
			end;
		end;
	end
	else
	begin
		while (True) do
		begin
			tokPos := TextPos(aText, aSep, (soCSSep in aOptions), ofsPos);
			if (tokPos > 0) then
			begin
				if (soNoDelSep in aOptions) then
					Add(TextCopy(aText, ofsPos, tokPos - ofsPos + sepLen))
				else
					Add(TextCopy(aText, ofsPos, tokPos - ofsPos));
				ofsPos := tokPos + sepLen;
				if (soSingleSep in aOptions) then
				begin
					Add(TextCopy(aText, ofsPos, MaxInt));
					Exit;
				end;
			end
			else
			begin
				Add(TextRight(aText, strLen - ofsPos + 1));
				Exit;
			end;
		end;
	end;
end;

{ Splits the line with HTML/XML markup into a list of tokens. No pair matching performed. Example: }
{ <tag1>text1</tag1><tag2>text2</tag2> to <tag1>, text1, </tag1>, <tag2>, text2 and </tag2>. }
function TextSplitMarkup(const aText: string; const aTrim: boolean): TArray<string>;
var
	Count: Integer;

	procedure Add(const aString: string);
	begin
		if (aString = CEmpty) then
			Exit;
		Inc(Count);
		SetLength(Result, Count);
		if (aTrim) then
			Result[Count - 1] := Trim(aString)
		else
			Result[Count - 1] := aString;
	end;

var
	strLen: Integer;
	cpyPos: Integer;
	ofsPos: Integer;
begin
	strLen := Length(aText);
	if (strLen = 0) then
		Exit;

	Count  := 0;
	ofsPos := 1;
	cpyPos := 1;

	while (cpyPos <= strLen) do
	begin
		if (aText[cpyPos] = CLessThan) then
		begin
			if (ofsPos <> cpyPos) then
			begin
				Add(TextCopy(aText, ofsPos, cpyPos - ofsPos));
				ofsPos := cpyPos;
			end
			else
				Inc(cpyPos);
		end
		else if (aText[cpyPos] = CGreaterThan) then
		begin
			if (ofsPos <> cpyPos) then
			begin
				Add(TextCopy(aText, ofsPos, cpyPos - ofsPos + 1));
				Inc(cpyPos);
				ofsPos := cpyPos;
			end
			else
				Inc(cpyPos);
		end
		else
			Inc(cpyPos);
	end;

	if (ofsPos < cpyPos) then
		Add(TextCopy(aText, ofsPos, MaxInt));
end;

{ Splits aText on aSep(s), returns TTokens record. }
function TextTokenize(const aText: string; const aSep: string; const aQotStr: string; const aOptions: TSplitOptions): TTokens;
begin
	Result.FTokens := TextSplit(aText, aSep, aQotStr, aOptions);
	Result.FCount  := Length(Result.FTokens);
end;

{ Returns token at aIndex from aText split by aSeparator. }
function TextToken(const aText: string; const aIndex: integer; const aSeparator: string = CSpace): string;
var
	tokens: TTokens;
begin
	tokens := TextTokenize(aText);
	Result := tokens[aIndex];
end;

{ Converts a string to an integer. }
function TextToInt(const aText: string; const aDefault: Integer): Integer;
var
	code: Integer;
begin
	Val(aText, Result, code);
	if (code <> 0) then
		Result := aDefault;
end;

{ Converts a byte to a string. }
function TextFromInt(const aByte: byte): string;
begin
{$WARNINGS OFF}
	Str(aByte, Result);
{$WARNINGS ON}
end;

{ Converts an integer to a string. }
function TextFromInt(const aInteger: integer): string;
begin
{$WARNINGS OFF}
	Str(aInteger, Result);
{$WARNINGS ON}
end;

{ Converts a cardinal to a string. }
function TextFromInt(const aCardinal: cardinal): string;
begin
{$WARNINGS OFF}
	Str(aCardinal, Result);
{$WARNINGS ON}
end;

{ Converts an int64 to a string. }
function TextFromInt(const aInt64: int64): string;
begin
{$WARNINGS OFF}
	Str(aInt64, Result);
{$WARNINGS ON}
end;

{ Converts a boolean to string. }
function TextFromBool(const aBoolean: boolean; const aUseBoolStrings: boolean): string;
begin
	if (aBoolean) then
		if (aUseBoolStrings) then
			Exit('True')
		else
			Exit('1');

	if (aBoolean = False) then
		if (aUseBoolStrings) then
			Exit('False')
		else
			Exit('0');
end;

{ Converts a float to string. }
function TextFromFloat(const aFloat: double; const aDecimals: byte): string;
begin
{$WARNINGS OFF}
	Str(aFloat: 1: aDecimals, Result);
{$WARNINGS ON}
end;

{ Converts an extended to string. }
function TextFromFloat(const aExtended: extended; const aDecimals: byte = 6): string;
begin
{$WARNINGS OFF}
	Str(aExtended: 1: aDecimals, Result);
{$WARNINGS ON}
end;

{ Converts a hex string to an integer. Input example: "DEADBEEF". }
function TextHexToDec(const aHexStr: string): cardinal;
var
	c: cardinal;
	b: byte;
begin
	Result := 0;
	if (Length(aHexStr) <> 0) then
	begin
		c := 1;
		b := Length(aHexStr) + 1;
		repeat
			Dec(b);
			if (aHexStr[b] <= '9') then
				Result := (Result + (cardinal(aHexStr[b]) - 48) * c)
			else
				Result := (Result + (cardinal(aHexStr[b]) - 55) * c);

			c := c * 16;
		until (b = 1);
	end;
end;

{ Converts aValue to Hex string with aDigits minimum width. }
function TextIntToHex(const aValue, aDigits: integer): string;
begin
	Result := IntToHex(aValue, aDigits);
end;

{ Converts and appends all parameters together. Parameters can be of mixed types, but not constants. }
function TextMake(const aArgs: array of const; const aSeparator: string): string;
var
	i: integer;
begin
	Result := '';
	for i  := 0 to high(aArgs) do
	begin
		case aArgs[i].VType of
			vtInteger:
			Result := Result + TextFromInt(aArgs[i].VInteger);
			vtBoolean:
			Result := Result + TextFromBool(aArgs[i].VBoolean);
			vtChar:
			Result := Result + string(aArgs[i].VChar);
			vtExtended:
			Result := Result + TextFromFloat(aArgs[i].VExtended^);
			vtString:
			Result := Result + string(aArgs[i].VString^);
			vtPChar:
			Result := Result + string(aArgs[i].VPChar);
			vtObject:
			Result := Result + aArgs[i].VObject.ClassName;
			vtClass:
			Result := Result + aArgs[i].VClass.ClassName;
			vtAnsiString:
			Result := Result + string(aArgs[i].VAnsiString);
			vtUnicodeString:
			Result := Result + string(aArgs[i].VUnicodeString);
			vtCurrency:
			Result := Result + TextFromFloat(aArgs[i].VCurrency^);
			vtVariant:
			Result := Result + string(aArgs[i].VVariant^);
			vtInt64:
			Result := Result + TextFromInt(aArgs[i].VInt64^);
		end;

		if (i <> high(aArgs)) then
			Result := Result + aSeparator;
	end;
end;

{ Splits an URI into parts: http://goatse.cx/images/goatse.jpg = http, goatse.cx, images/goatse.jpg }
function TextURISplit(const aURI: string; var aPrefix, aHost, aPath: string): boolean;
var
	rPrefix, rHost, rPath, rParams: string;
begin
	Result := TextURISplit(aURI, rPrefix, rHost, rPath, rParams);
end;

{ Splits an URI into parts: http://goatse.cx/images/goatse.jpg = http, goatse.cx, images/goatse.jpg, par=val&par2=val2 }
function TextURISplit(const aURI: string; var aPrefix, aHost, aPath, aParams: string): boolean; overload;
var
	offs: Integer;
	i   : Integer;
begin
	Result := False;

	if (aURI = CEmpty) then
		Exit;

	offs := 0;

	// Extract prefix.
	i := TextPos(aURI, CURIPrefixDelimiter);
	if (i > 0) then
	begin
		aPrefix := TextLeft(aURI, i - 1);
		offs    := i + Length(CURIPrefixDelimiter);
	end;

	// Extract host.
	if (offs = 0) then
	begin
		i := TextPos(aURI, CFrontSlash);
		if (i > 0) then
		begin
			aHost := TextCopy(aURI, offs, i - 1);
			offs  := i;
		end;
	end
	else
	begin
		i := TextPos(aURI, CFrontSlash, True, offs);
		if (i > 0) then
		begin
			aHost := TextCopy(aURI, offs, i - offs);
			offs  := i;
		end;
	end;

	// Extract path.
	if (offs = 0) then
	begin
		i := TextPos(aURI, CQuestionMark);
		if (i > 0) then
		begin
			aPath := TextCopy(aURI, offs, i - 1);
            // The rest are params
			aParams := TextCopy(aURI, i + 1, MaxInt);
		end
		else
		begin
			aPath := TextCopy(aURI, offs, MaxInt);
			Exit(True);
		end;
	end
	else
	begin
		i := TextPos(aURI, CQuestionMark, True, offs);
		if (i > 0) then
		begin
			aPath := TextCopy(aURI, offs, i - offs);
            // The rest are params
			aParams := TextCopy(aURI, i + 1, MaxInt);
		end
		else
		begin
			aPath := TextCopy(aURI, offs, MaxInt);
			Exit(True);
		end;
	end;

	Result := True;
end;

{ Extracts Path from an URL }
function TextURIGetPath(const aURI: string): string;
var
	prefix, domain, path: string;
begin
	if (TextURISplit(aURI, prefix, domain, path)) then
		Result := path
	else
		Result := CEmpty;
end;

{ Url encodes(percent encodes) a string. }
function TextURIEncode(const aText: string): string;
var
	i : Integer;
	Ch: char;
begin
	Result := '';
	for i  := 1 to Length(aText) do
	begin
		Ch := aText[i];
		if ((Ch >= '0') and (Ch <= '9')) or ((Ch >= 'a') and (Ch <= 'z')) or
		  ((Ch >= 'A') and (Ch <= 'Z')) or (Ch = '.') or (Ch = '-') or (Ch = '_')
		  or (Ch = '~') then
			Result := Result + Ch
		else
		begin
			Result := Result + '%' + IntToHex(Ord(Ch), 2);
		end;
	end;
end;

{ Url decodes(percent decodes) a string. }
function TextURIDecode(const aText: string): string;
var
	i: Integer;
	l: Integer;
begin
	Result := CEmpty;

	i := 1;
	l := Length(aText);
	while (i <= l) do
	begin
		if (aText[i] = CPercent) then
		begin
			Result := Result + Chr(TextHexToDec(aText[i + 1] + aText[i + 2]));
			i      := Succ(Succ(i));
		end
		else
		begin
			if aText[i] = CPlus then
				Result := (Result + CSpace)
			else
				Result := (Result + aText[i]);
		end;
		i := Succ(i);
	end;
end;

{ Returns "file.ext" from "http://www.site.com/path/here/file.ext". }
function TextURIExtractParams(const aURI: string): string;
begin
	Result := TextFetchRight(aURI, '?', True);
end;

{ Returns "http://www.site.com/path/here/" from "http://www.site.com/path/here/file.ext" }
function TextURIWithoutParams(const aURI: string): string;
var
	rPrefix, rHost, rPath, rParams: string;
begin
	// Have to do everything here. If we go too deep on the stack
    // Delphi forgets string refcount and returns nothing :S.
	if (TextPos(aURI, CQuestionMark, True) > 0) then
		Exit(TextFetchLeft(aURI, CQuestionMark, True))
	else
		Result := CEmpty;

	if (TextURISplit(aURI, rPrefix, rHost, rPath, rParams)) then
		Result := rPrefix + CURISchemeDelimiter + rHost + rPath;
end;

{ Returns a hex display style string from aData of aSize. }
function TextDump(const aData: pByte; const aSize: integer; const aBytesPerLine: byte): string;
var
	p: pbyte;
	i: integer;
	h: string;
	t: string;
begin
	if (aData = nil) or (aSize <= 0) or (aBytesPerLine = 0) then
		Exit;

	i := 0;
	p := aData;
	while (i < aSize) do
	begin
		if ((i mod aBytesPerLine = 0) and (i <> 0)) or (i = aSize) then
		begin
			Result := Result + h + CSpace + CMinus + CSpace + t + CCrLf;
			h      := CEmpty;
			t      := CEmpty;
		end;

		if (h <> CEmpty) then
		begin
			if (i mod 8 = 0) then
				h := h + CSpace + CSpace
			else
				h := h + CSpace;
		end;

		h := h + IntToHex(p^, 2);
		if (p^ >= 20) and (p^ <= 127) then
			t := t + Chr(p^)
		else
			t := t + CDot;

		Inc(p);
		Inc(i);
	end;

	if (h <> CEmpty) then
	begin
		Result := Result + h;
		while (i mod aBytesPerLine <> 0) do
		begin
			if (i mod 8 = 0) then
				Result := Result + CSpace + CSpace + CSpace + CSpace
			else
				Result := Result + CSpace + CSpace + CSpace;
			Inc(i);
		end;
		Result := Result + CSpace + CMinus + CSpace + t;
	end;
end;

{ Save aText to aFileName. }
procedure TextSave(const aText, aFileName: string);
var
	f: TextFile;
begin
	AssignFile(f, aFileName, 65001);
	Rewrite(f);
	write(f, aText);
	CloseFile(f);
end;

{ Returns a string of length aLength composed entirely of aChar. }
function TextOfChar(const aChar: char; const aLength: integer): string;
var
	i: integer;
begin
	if (aLength <= 0) then
		Exit('');
	SetLength(Result, alength);
	for i         := 1 to aLength do
		Result[i] := aChar;
end;

{ Splits IRC hostmask nickname!ident@host.name into parts. }
function SplitHostMask(const aHostMask: string; var aNickname, aIdent, aHost: string): boolean;
begin
	if (Length(aHostMask) = 0) then
		Exit(False);

	aHost     := aHostMask;
	aIdent    := TextExtractLeft(aHost, CMonkey);
	aNickname := TextExtractLeft(aIdent, CExclam);
	Result    := (aHost <> CEmpty) and (aIdent <> CEmpty) and (aNickname <> CEmpty);
end;

{ Returns a random number character. }
function RandomNum: char;
begin
	Result := pchar(CNums)[Random(Length(CNums))];
end;

{ Returns a random string of number characters of aLength. }
function RandomNums(const aLength: byte): string;
var
	i: Integer;
begin
	Result := CEmpty;

	for i      := 0 to aLength - 1 do
		Result := Result + RandomNum;
end;

{ Returns a random lowercase letter. }
function RandomAlphaLower: char;
begin
	Result := pchar(CAlphaLower)[Random(Length(CAlphaLower))];
end;

{ Returns a random string of lowercase letters of aLength. }
function RandomAlphaLowers(const aLength: byte): string;
var
	i: Integer;
begin
	Result := CEmpty;

	for i      := 0 to aLength - 1 do
		Result := Result + RandomAlphaLower;
end;

{ Returns a random uppercase letter. }
function RandomAlphaUpper: char;
begin
	Result := pchar(CAlphaUpper)[Random(Length(CAlphaUpper))];
end;

{ Returns a random string of uppercase letters of aLength. }
function RandomAlphaUppers(const aLength: byte): string;
var
	i: Integer;
begin
	Result := CEmpty;

	for i      := 0 to aLength - 1 do
		Result := Result + RandomAlphaUpper;
end;

{ Returns a random lowercase vowel. }
function RandomVowelLower: char;
begin
	Result := pchar(CVowelsLower)[Random(Length(CVowelsLower))];
end;

{ Returns a random uppercase vowel. }
function RandomVowelUpper: char;
begin
	Result := pchar(CVowelsUpper)[Random(Length(CVowelsUpper))];
end;

{ Returns a random vowel. }
function RandomVowel: char;
begin
	Result := pchar(CVowels)[Random(Length(CVowels))];
end;

{ Returns a random lowercase consonant. }
function RandomConsonantLower: char;
begin
	Result := pchar(CConsonantsLower)[Random(Length(CConsonantsLower))];
end;

{ Returns a random uppercase consonant. }
function RandomConsonantUpper: char;
begin
	Result := pchar(CConsonantsUpper)[Random(Length(CConsonantsUpper))];
end;

{ Returns a random consonant. }
function RandomConsonant: char;
begin
	Result := pchar(CConsonants)[Random(Length(CConsonants))];
end;

{ Generates a random string of aLength. }
function RandomString(const aLength: Integer; const aLowerCase, aUpperCase, aNumeric: boolean): string;
type
	TRandomFunc  = function: char;
	TRandomFuncs = array of TRandomFunc;
var
	i: Integer;
	f: TRandomFuncs;
begin
	Result := CEmpty;

	if (aLowerCase) then
	begin
		SetLength(f, Length(f) + 1);
		f[Length(f) - 1] := RandomAlphaLower;
	end;

	if (aUpperCase) then
	begin
		SetLength(f, Length(f) + 1);
		f[Length(f) - 1] := RandomAlphaUpper;
	end;

	if (aNumeric) then
	begin
		SetLength(f, Length(f) + 1);
		f[Length(f) - 1] := RandomNum;
	end;

	for i      := 0 to aLength - 1 do
		Result := Result + f[Random(Length(f))];
end;

{ Returns an integer in range >= aMin and <= aMax. }
function RandomRange(const aMin, aMax: Integer): Integer;
begin
	Result := Random(aMax - aMin) + aMin;
end;

{ Returns a random boolean. Fiddy fiddy bitch money dawg yo sup sup u down. }
function RandomBool: boolean;
begin
	Result := (Random > 0.5);
end;

{ ======= }
{ TTokens }
{ ======= }

{ GetEnumerator implement. }
function TTokens.GetEnumerator: TTokensEnumerator;
begin
	Result := TTokensEnumerator.Create(Self);
end;

{ Returns tokens from and including token at aIndex as a string delimited by aDelimiter. }
function TTokens.FromToken(const aIndex: Integer; const aDelimiter: string): string;
var
	i: Integer;
begin
	Result := CEmpty;

	for i := aIndex to FCount - 1 do
	begin
		if (i = aIndex) then
			Result := Result + GetToken(i)
		else
			Result := Result + aDelimiter + GetToken(i);
	end;
end;

{ Returns tokens from start to and including token at aIndex as a string delimited by aDelimiter. }
function TTokens.ToToken(const aIndex: Integer; const aDelimiter: string): string;
var
	i: Integer;
begin
	Result := CEmpty;

	for i := 0 to aIndex do
	begin
		if (i = 0) then
			Result := Result + GetToken(i)
		else
			Result := Result + aDelimiter + GetToken(i);
	end;
end;

{ Adds a string to the array. }
procedure TTokens.Add(const aText: string);
begin
	if (aText = CEmpty) then
		Exit;
	Inc(FCount);
	SetLength(FTokens, FCount);
	FTokens[FCount - 1] := aText;
end;

{ Adds aKey=aVal as one string to the array. String aVal overload. }
procedure TTokens.Add(const aKey, aVal: string);
begin
	Add(aKey + '=' + aVal);
end;

{ Adds aKey=aVal as one string to the array. Integer aVal overload. }
procedure TTokens.Add(const aKey: string; const aVal: integer);
begin
	Add(aKey, TextFromInt(aVal));
end;

{ Adds aKey=aVal as one string to the array. Boolean aVal overload. }
procedure TTokens.Add(const aKey: string; const aVal: boolean);
begin
	Add(aKey, TextFromBool(aVal));
end;

{ Adds aKey="aVal" as one string to the array. String aVal overload. }
procedure TTokens.AddQ(const aKey, aVal: string);
begin
	Add(aKey + '="' + aVal + '"');
end;

{ Adds aKey="aVal" as one string to the array. Integer aVal overload. }
procedure TTokens.AddQ(const aKey: string; const aVal: integer);
begin
	Add(aKey + '="' + TextFromInt(aVal) + '"');
end;

{ Adds aKey="aVal" as one string to the array. Boolean aVal overload. }
procedure TTokens.AddQ(const aKey: string; const aVal: boolean);
begin
	Add(aKey + '="' + TextFromBool(aVal) + '"');
end;

{ Returns all tokens in one string separated by aDelimiter. }
function TTokens.AllTokens(const aDelimiter: string): string;
var
	i: Integer;
begin
	Result := CEmpty;

	for i := 0 to FCount - 1 do
	begin
		if (i = 0) then
			Result := Result + GetToken(i)
		else
			Result := Result + aDelimiter + GetToken(i);
	end;
end;

{ Clears all tokens. }
procedure TTokens.Clear;
begin
	SetLength(FTokens, 0);
	Finalize(FTokens);
	FCount := 0;
end;

{ Checks if empty. }
function TTokens.Empty: boolean;
begin
	Result := (FCount = 0);
end;

{ Returns an array of string from and including token at aFromToken to and including token at aToToken. }
function TTokens.ToArray(const aFromToken, aToToken: Integer): TArray<string>;
var
	i: Integer;
begin
	if (aFromToken < 0) or (aFromToken >= FCount) or (aToToken < aFromToken) then
		Exit;

	SetLength(Result, FCount - (aToToken - aFromToken));

	for i         := aFromToken to aToToken do
		Result[i] := Token[i];
end;

{ Token getter. Get as string. }
function TTokens.GetToken(const aIndex: Integer): string;
begin
	if ((aIndex < 0) or (aIndex >= FCount)) then
		Result := CEmpty
	else
		Result := FTokens[aIndex];
end;

{ Pair getter. Get as TPair. }
function TTokens.GetPair(const aIndex: integer): TPair;
begin
	if ((aIndex < 0) or (aIndex >= FCount)) then
	begin
		Result.Key := '';
		Result.Val := '';
	end
	else
	begin
		Result.Key := TextFetchLeft(FTokens[aIndex], '=', True);
		Result.Val := TextFetchRight(FTokens[aIndex], '=', True, False);
	end;
end;

{ Exchanges two items in tokens. }

procedure TTokens.Exchange(aIndexA, aIndexB: Integer);
var
	temp: string;
begin
	temp             := FTokens[aIndexB];
	FTokens[aIndexB] := FTokens[aIndexA];
	FTokens[aIndexA] := temp;
end;

{ QuickSorts tokens. }
procedure TTokens.QuickSort(aStart, aEnd: Integer);
var
	a: Integer;
	i: Integer;
	j: Integer;
	p: Integer;
begin
	if (FCount <= 1) then
		Exit;
	a := aStart;
	repeat
		i := a;
		j := aEnd;
		p := (a + aEnd) shr 1;
		repeat
			while (CompareText(FTokens[i], FTokens[p]) < 0) do
				Inc(i);
			while (CompareText(FTokens[j], FTokens[p]) > 0) do
				Dec(j);
			if (i <= j) then
			begin
				if (i <> j) then
					Exchange(i, j);
				if (p = i) then
					p := j
				else
				  if (p = j) then
					p := i;
				Inc(i);
				Dec(j);
			end;
		until (i > j);
		if (a < j) then
			QuickSort(a, j);
		a := i;
	until (i >= aEnd);
end;

{ Sorts the items. }
procedure TTokens.Sort;
begin
	QuickSort(0, FCount - 1);
end;

{ ================= }
{ TTokensEnumerator }
{ ================= }

{ Constructor. }
constructor TTokensEnumerator.Create(aTokens: TTokens);
begin
	inherited Create;
	FIndex  := - 1;
	FTokens := aTokens;
end;

{ GetCurrent implementaiton. }
function TTokensEnumerator.GetCurrent: string;
begin
	Result := FTokens[FIndex];
end;

{ MoveNext Implementation. }
function TTokensEnumerator.MoveNext: Boolean;
begin
	Result := (FIndex < FTokens.Count - 1);
	if Result then
		Inc(FIndex);
end;

end.
