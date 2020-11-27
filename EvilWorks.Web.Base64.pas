//
// EvilLibrary by Vedran Vuk 2010-2012
//
// Name: 					EvilWorks.Web.Base64
// Description: 			Base64 encoding/decoding.
// 							Contains code from Ararat Synapse (http://www.ararat.cz/synapse/)
//
// File last change date: September 28th. 2012
// File version: 			0.0.1
// Comment:               	Slightly modified, trimmed and integrated with EvilLibrary. And OCD formated.
// 							Some extra helper classes added.
//
// Base64 Encode/Decode functions (Modified):
// Original Name:         synacode.pas
// Original Author:       Ararat Synapse (http://www.ararat.cz/synapse/)
// Original Licence:	  modified BSD style license
//

unit EvilWorks.Web.Base64;

interface

function Base64Encode(const aData: pByte; const aSize: integer): string; overload;
function Base64Encode(const aString: ansistring): string; overload;
function Base64Encode(const aString: UTF8String): string; overload;
function Base64Encode(const aString: unicodestring): string; overload;

procedure Base64Decode(const aString: string; var aData: pByte; var aSize: integer); overload;
function Base64Decode(const aString: string): string; overload;

implementation

{ Base64Encode encode aData of aSize. }
function Base64Encode(const aData: pByte; const aSize: integer): string;
const
	ENCODE_TABLE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
var
	p    : PByte;
	c    : Byte;
	n, l : Integer;
	Count: Integer;
	DOut : array [0 .. 3] of Byte;
begin
	p := aData;
	SetLength(Result, ((aSize + 2) div 3) * 4);
	l     := 1;
	Count := 0;
	while (Count < aSize) do
	begin
		c := Ord(p^);
		Inc(p);
		Inc(Count);
		DOut[0] := (c and $FC) shr 2;
		DOut[1] := (c and $03) shl 4;
		if (Count < aSize) then
		begin
			c := Ord(p^);
			Inc(p);
			Inc(Count);
			DOut[1] := DOut[1] + (c and $F0) shr 4;
			DOut[2] := (c and $0F) shl 2;
			if (Count < aSize) then
			begin
				c := Ord(p^);
				Inc(p);
				Inc(Count);
				DOut[2] := DOut[2] + (c and $C0) shr 6;
				DOut[3] := (c and $3F);
			end
			else
			begin
				DOut[3] := $40;
			end;
		end
		else
		begin
			DOut[2] := $40;
			DOut[3] := $40;
		end;
		for n := 0 to 3 do
		begin
			if (DOut[n] + 1) <= Length(ENCODE_TABLE) then
			begin
				Result[l] := ENCODE_TABLE[DOut[n] + 1];
				Inc(l);
			end;
		end;
	end;
	SetLength(Result, l - 1);
end;

{ Base64Encode overload for ansistring type.}
function Base64Encode(const aString: ansistring): string; overload;
begin
	Result := Base64Encode(@aString[1], Length(aString));
end;

{ Base64Encode overload for UTF8String type.}
function Base64Encode(const aString: UTF8String): string; overload;
begin
	Result := Base64Encode(@aString[1], Length(aString));
end;

{ Base64Encode overload for string/widestring type. }
function Base64Encode(const aString: unicodestring): string;
var
	str: UTF8String;
	len: integer;
begin
	str    := UTF8Encode(aString);
	len    := Length(str);
	Result := Base64Encode(@str[1], len);
end;

{ Decode base64 encoded aString to aData of aSize. Free aData with FreeMem when you're done! }
procedure Base64Decode(const aString: string; var aData: pByte; var aSize: integer);
const
	DECODE_TABLE =
	  #$40 + #$40 + #$40 + #$40 + #$40 + #$40 + #$40 + #$40 + #$40 + #$40 + #$3E + #$40 +
	  #$40 + #$40 + #$3F + #$34 + #$35 + #$36 + #$37 + #$38 + #$39 + #$3A + #$3B + #$3C +
	  #$3D + #$40 + #$40 + #$40 + #$40 + #$40 + #$40 + #$40 + #$00 + #$01 + #$02 + #$03 +
	  #$04 + #$05 + #$06 + #$07 + #$08 + #$09 + #$0A + #$0B + #$0C + #$0D + #$0E + #$0F +
	  #$10 + #$11 + #$12 + #$13 + #$14 + #$15 + #$16 + #$17 + #$18 + #$19 + #$40 + #$40 +
	  #$40 + #$40 + #$40 + #$40 + #$1A + #$1B + #$1C + #$1D + #$1E + #$1F + #$20 + #$21 +
	  #$22 + #$23 + #$24 + #$25 + #$26 + #$27 + #$28 + #$29 + #$2A + #$2B + #$2C + #$2D +
	  #$2E + #$2F + #$30 + #$31 + #$32 + #$33 + #$40 + #$40 + #$40 + #$40 + #$40 + #$40;
var
	x, y, lv: Integer;
	d       : Integer;
	dl      : Integer;
	c       : Byte;
	p       : Integer;
	b       : array of byte;
begin
	lv := Length(aString);
	SetLength(b, lv);
	x  := 1;
	dl := 4;
	d  := 0;
	p  := 0;
	while (x <= lv) do
	begin
		y := Ord(aString[x]);
		if y in [33 .. 127] then
			c := Ord(DECODE_TABLE[y - 32])
		else
			c := 64;
		Inc(x);
		if c > 63 then
			continue;
		d := ((d shl 6) or c);
		Dec(dl);
		if dl <> 0 then
			continue;
		b[p] := ((d shr 16) and $FF);
		Inc(p);
		b[p] := ((d shr 8) and $FF);
		Inc(p);
		b[p] := (d and $FF);
		Inc(p);
		d  := 0;
		dl := 4;
	end;
	case dl of
		1:
		begin
			d    := (d shr 2);
			b[p] := ((d shr 8) and $FF);
			Inc(p);
			b[p] := (d and $FF);
			Inc(p);
		end;
		2:
		begin
			d    := (d shr 4);
			b[p] := (d and $FF);
			Inc(p);
		end;
	end;
	SetLength(b, p);
	aSize := Length(b);
	aData := GetMemory(Length(b));
	Move(b[0], aData^, Length(b));
end;

{ Base64Decode overload for casting to strings directly. }
function Base64Decode(const aString: string): string; overload;
var
	buff: pbyte;
	size: integer;
begin
	Base64Decode(aString, buff, size);
	Result := UTF8ToString(pansichar(buff));
	FreeMem(buff, size);
end;

end.
