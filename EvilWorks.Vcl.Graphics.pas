unit EvilWorks.Vcl.Graphics;

interface

uses
	Winapi.Windows,
	System.Classes,
    System.SysUtils,
	Vcl.Graphics,
    Vcl.Imaging.PNGImage,
    EvilWorks.System.SysUtils;

type
	// These first two structs represent how the icon information is stored
	// when it is bound into a EXE or DLL file. Structure members are WORD
	// aligned and the last member of the structure is the ID instead of
	// the imageoffset.

{$ALIGN 2}
	TGrpIconDirEntry = record
		bWidth: BYTE;        // Width of the image
		bHeight: BYTE;       // Height of the image (times 2)
		bColorCount: BYTE;   // Number of colors in image (0 if >=8bpp)
		bReserved: BYTE;     // Reserved
		wPlanes: WORD;       // Color Planes
		wBitCount: WORD;     // Bits per pixel
		dwBytesInRes: DWORD; // how many bytes in this resource?
		nID: WORD;           // the ID
	end;

	PGrpIconDirEntry = ^TGrpIconDirEntry;

	TGrpIconDir = record
		idReserved: WORD;                              // Reserved
		idType: WORD;                                  // resource type (1 for icons)
		idCount: WORD;                                 // how many images?
		idEntries: array [0 .. 0] of TGrpIconDirEntry; // the entries for each image
	end;

	PGrpIconDir = ^TGrpIconDir;

{$ALIGN 8}

	// These next two structs represent how the icon information is stored
	// in an ICO file.

	TIconDirEntry = record
		bWidth: BYTE;         // Width of the image
		bHeight: BYTE;        // Height of the image (times 2)
		bColorCount: BYTE;    // Number of colors in image (0 if >=8bpp)
		bReserved: BYTE;      // Reserved
		wPlanes: WORD;        // Color Planes
		wBitCount: WORD;      // Bits per pixel
		dwBytesInRes: DWORD;  // how many bytes in this resource?
		dwImageOffset: DWORD; // where in the file is this image
	end;

	PIconDirEntry = ^TIconDirEntry;

	TIconDir = record
		idReserved: WORD;                           // Reserved
		idType: WORD;                               // resource type (1 for icons)
		idCount: WORD;                              // how many images?
		idEntries: array [0 .. 0] of TIconDirEntry; // the entries for each image
	end;

	PIconDir = TIconDir;

	{ Forward declarations }
	TIconImage     = class;
	TIconDirectory = class;
	TIconList      = class;

	{ TIconImage }
	{ Contains one bitmap for an icon file. }
	TIconImage = class
	private
		FHandle  : HICON;
		FWidth   : integer;
		FBitDepth: WORD;
		FHeight  : integer;
		FSize    : cardinal;
	public
		constructor Create;
		destructor Destroy; override;

		procedure Draw(const aDC: HDC; const aX, aY: integer);
		function Duplicate: HICON;
		function To32BitBitmap: HBITMAP;

		property Handle: HICON read FHandle;
		property Width: integer read FWidth;
		property Height: integer read FHeight;
		property BitDepth: WORD read FBitDepth;
		property Size: cardinal read FSize;
	end;

	{ TIconDirectory }
	{ Contains all bitmaps for a complete icon file. }
	TIconDirectory = class
	private
		FImages: array of TIconImage;
		FCount : integer;
		function GetImage(aIndex: integer): TIconImage;
	protected
		function ReadIconHeader(const aFile: HFILE): cardinal;
		function Add: TIconImage;
		procedure Clear;
	public
		constructor Create;
		destructor Destroy; override;

		function GetFormat(const aWidth, aHeight, aBitDepth: integer): HICON;
		function To32BitBitmap(const aWidth, aHeight, aBitDepth: integer): HBITMAP;

		function LoadFromIco(const aFileName: string): boolean;

		property Images[aIndex: integer]: TIconImage read GetImage; default;
		property Count: integer read FCount;
	end;

	{ TIconList }
	{ Extracts icons from executables and contains a list of extracted icons. }
	TIconList = class
	private
		FResourceNames: array of string;
		FResourceCount: integer;

		FIcons: array of TIconDirectory;
		FCount: integer;
		function GetIcon(aIndex: integer): TIconDirectory;
	protected
		class function EnumResourceNamesProc(aModule: HINST; aType, aName: PChar; aLParam: LPARAM): BOOL; stdcall; static;
		function Add: TIconDirectory;
		procedure Clear;
	public
		constructor Create; overload;
		destructor Destroy; override;

		function LoadFromIco(const aFileName: string): boolean;
		function LoadFromExe(const aFileName: string; const aIconIndex, aCount: integer): boolean;

		property Icons[aIndex: integer]: TIconDirectory read GetIcon; default;
		property Count: integer read FCount;
	end;

	{ Icon functions }
function IconTo32BitBitmap(const aIcon: HICON; const aSize: cardinal): HBITMAP;

{ Bitmap functions }
function LoadBitmapFromBuffer(const aBuffer: pointer; const aBufferSize: cardinal; const aPremultiplyAlpha: boolean = False): HBITMAP;
function LoadBitmapFromFile(const aFileName: string; const aPremultiplyAlpha: boolean = False): HBITMAP;
function SaveBitmapToBuffer(const aBitmap: HBITMAP; out aBuffer: pointer): cardinal;
function SaveBitmapToFile(const aBitmap: HBITMAP; const aFileName: string): boolean;
function IsBitmapValid(const aBitmap: HBITMAP): boolean;
function DuplicateBitmap(const aBitmap: HBITMAP): HBITMAP;
function GetBitmapSize(const aBitmap: HBITMAP; var aSize: TSize): boolean;
function GetBitmapBitDepth(const aBitmap: HBITMAP): WORD;
function GetBitmapInfo(const aBitmap: HBITMAP; var aBitmapInfo: TBitmapInfoHeader): boolean;
function DrawBitmap(const aDC: HDC; const aBitmap: HBITMAP; const aDestX, aDestY: integer; const aBlend: boolean = False): boolean; overload;
function DrawBitmap(const aDC: HDC; const aBitmap: HBITMAP; const aDestX, aDestY, aDestCX, aDestCY: integer; const aBlend: boolean = False): boolean; overload;
function DrawBitmap(const aDC: HDC; const aBitmap: HBITMAP; const aDestX, aDestY, aDestCX, aDestCY, aSrcX, aSrcY: integer; const aBlend: boolean = False): boolean; overload;
function DrawBitmap(const aDC: HDC; const aBitmap: HBITMAP; const aDestX, aDestY, aDestCX, aDestCY, aSrcX, aSrcY, aSrcCX, aSrcCY: integer; const aBlend: boolean = False): boolean; overload;
function CreateSpectrumPalette: HPALETTE;
function PremultiplyBitmapAlpha(const aBitmap: HBITMAP; const aFloat: boolean = False): boolean;
function PremultiplyBitmapBits(const aBits: pointer; const aBitsCount: cardinal; const aFloat: boolean = False): boolean;
function CreateBitmap(const aWidth, aHeight: cardinal; const aBits: WORD): HBITMAP;
function Create32BitBitmap(aWidth, aHeight: integer): HBITMAP; overload;
function Create32BitBitmap(const aWidth, aHeight: integer; out aBits: pointer): HBITMAP; overload;
function GetBitmapBits(const aBitmap: HBITMAP; var aBits: pointer): integer;
function PNGtoBitmap(aPNG: TPNGImage): HBITMAP; overload;
function PNGtoBitmap(const aFileName: string): HBITMAP; overload;
procedure PremultiplyBitmap(aBitmap: TBitmap);

implementation

procedure _RGBTripleToQuad(var ColorTable);
type
	PRGBTripleArray = ^TRGBTripleArray;
	TRGBTripleArray = array [BYTE] of TRGBTriple;
	PRGBQuadArray   = ^TRGBQuadArray;
	TRGBQuadArray   = array [BYTE] of TRGBQuad;
var
	I : integer;
	P3: PRGBTripleArray;
	P4: PRGBQuadArray;
begin
	P3    := PRGBTripleArray(@ColorTable);
	P4    := pointer(P3);
	for I := 255 downto 1 do // don't move zeroth item
		with P4^[I], P3^[I] do
		begin // order is significant for last item moved
			rgbRed      := rgbtRed;
			rgbGreen    := rgbtGreen;
			rgbBlue     := rgbtBlue;
			rgbReserved := 0;
		end;
	P4^[0].rgbReserved := 0;
end;

// convert RGB to BGR and vice-versa.  TRGBQuad <-> TPaletteEntry
procedure _ByteSwapColors(var Colors; Count: integer);
var
	localCPU: integer;
begin
	localCPU := Test8086;
	asm
		MOV   EDX, Colors
		MOV   ECX, Count
		DEC   ECX
		JS    @@END
		CMP   localCPU, CPUi386
		JLE    @@386
	@@1:  MOV   EAX, [EDX+ECX*4]
		BSWAP EAX
		SHR   EAX,8
		MOV   [EDX+ECX*4],EAX
		DEC   ECX
		JNS   @@1
		JMP   @@END
	@@386:
		PUSH  EBX
	@@2:  XOR   EBX,EBX
		MOV   EAX, [EDX+ECX*4]
		MOV   BH, AL
		MOV   BL, AH
		SHR   EAX,16
		SHL   EBX,8
		MOV   BL, AL
		MOV   [EDX+ECX*4],EBX
		DEC   ECX
		JNS   @@2
		POP   EBX
	@@END:
	end;
end;

function _PaletteFromDIBColorTable(DIBHandle: THandle; ColorTable: pointer; ColorCount: integer): HPALETTE;
var
	DC  : HDC;
	Save: THandle;
	Pal : TMaxLogPalette;
begin
	Result         := 0;
	Pal.palVersion := $300;
	if DIBHandle <> 0 then
	begin
		DC                := CreateCompatibleDC(0);
		Save              := SelectObject(DC, DIBHandle);
		Pal.palNumEntries := GetDIBColorTable(DC, 0, 256, Pal.palPalEntry);
		SelectObject(DC, Save);
		DeleteDC(DC);
	end
	else
	begin
		Pal.palNumEntries := ColorCount;
		Move(ColorTable^, Pal.palPalEntry, ColorCount * 4);
	end;
	if Pal.palNumEntries = 0 then
		Exit;
	if (Pal.palNumEntries <> 16) then
		_ByteSwapColors(Pal.palPalEntry, Pal.palNumEntries);
	Result := CreatePalette(PLogPalette(@Pal)^);
end;

function _BytesPerScanline(PixelsPerScanline, BitsPerPixel, Alignment: Longint): Longint;
begin
	DEC(Alignment);
	Result := ((PixelsPerScanline * BitsPerPixel) + Alignment) and not Alignment;
	Result := Result div 8;
end;

function _BytesPerLine(const aWidth, aBPP: DWORD): WORD;
begin
	Result := WORD(((DWORD(aWidth) * DWORD(aBPP) + 31) shr 5) shl 2);
end;

function _BitmapImageBitsSize(const aBitmapInfo: PBitmapInfo): cardinal;
begin
	case aBitmapInfo^.bmiHeader.biCompression of

		BI_RLE4, BI_RLE8:
		begin
			Result := aBitmapInfo^.bmiHeader.biSizeImage;
		end;

		BI_RGB, BI_BITFIELDS:
		begin
			Result := _BytesPerLine(aBitmapInfo^.bmiHeader.biWidth, aBitmapInfo^.bmiHeader.biBitCount * aBitmapInfo^.bmiHeader.biPlanes) * aBitmapInfo^.bmiHeader.biHeight;
		end;

		else
		begin
			Result := 0;
		end;

	end; { case }
end;

function _BitmapColorTableSize(const aBitmapInfo: PBitmapInfo): DWORD;
var
	Colors: DWORD;
begin
	if (aBitmapInfo^.bmiHeader.biClrUsed <> 0) then
		Colors := aBitmapInfo^.bmiHeader.biClrUsed
	else
	  if (aBitmapInfo^.bmiHeader.biBitCount > 8) then
		Colors := 0
	else
		Colors := 1 shl (aBitmapInfo^.bmiHeader.biBitCount * aBitmapInfo^.bmiHeader.biPlanes);

	if (aBitmapInfo^.bmiHeader.biCompression = BI_BITFIELDS) then
		Exit((SizeOf(DWORD) * 3) + (Colors * SizeOf(TRGBQuad)));
	Result := Colors * SizeOf(TRGBQuad);
end;

function IconTo32BitBitmap(const aIcon: HICON; const aSize: cardinal): HBITMAP;
var
	MainDC : HDC;
	TempDC : HDC;
	OutBits: pointer;

	function HasAlphaInternal(const aBits: pointer; const aBitsCount: cardinal): boolean;
	var
		P: PRGBQuad;
		c: cardinal;
	begin
		Result := False;
		P      := aBits;
		c      := aBitsCount;
		while (c > 0) do
		begin
			if (P.rgbReserved <> 0) then
			begin
				Result := True;
				Exit;
			end
			else
			begin
				Inc(P);
				DEC(c);
			end;
		end;
	end;

var
	MaskBitmap    : HBITMAP;
	MaskBitmapBits: pointer;
	c             : cardinal;
	PC            : PRGBQuad;
	PM            : PRGBQuad;
begin
	Result := 0;
	if (aIcon = 0) then
		Exit;

	MainDC := GetDC(0);
	if (MainDC <> 0) then
	begin
		TempDC := CreateCompatibleDC(MainDC);
		ReleaseDC(0, MainDC);
	end
	else
		Exit;

	if (TempDC <> 0) then
	begin
		Result := Create32BitBitmap(aSize, aSize, OutBits);
		SelectObject(TempDC, Result);
		DrawIconEx(TempDC, 0, 0, aIcon, aSize, aSize, 0, 0, DI_NORMAL);
		SelectObject(TempDC, 0);
		if (HasAlphaInternal(OutBits, aSize * aSize) = False) then
		begin
			MaskBitmap := Create32BitBitmap(aSize, aSize, MaskBitmapBits);
			if (MaskBitmap <> 0) then
			begin
				SelectObject(TempDC, MaskBitmap);
				DrawIconEx(TempDC, 0, 0, aIcon, aSize, aSize, 0, 0, DI_MASK);
				SelectObject(TempDC, 0);
				PC := OutBits;
				PM := MaskBitmapBits;
				c  := aSize * aSize;
				while (c > 0) do
				begin
					if (cardinal(PM^) and $FFFFFF00 <> 0) then
						RGBQUAD(PC^).rgbReserved := 0
					else
						RGBQUAD(PC^).rgbReserved := 255;
					Inc(PC);
					Inc(PM);
					DEC(c);
				end;
				DeleteObject(MaskBitmap);
			end;
		end;
		DeleteDC(TempDC);
	end;
end;

function LoadBitmapFromBuffer(const aBuffer: pointer; const aBufferSize: cardinal; const aPremultiplyAlpha: boolean): HBITMAP;
const
	DIBPalSizes: array [boolean] of BYTE = (SizeOf(TRGBQuad), SizeOf(TRGBTriple));
var
	P         : PByte;
	ImageSize : cardinal;
	DC, MemDC : HDC;
	BitsMem   : pointer;
	OS2Header : TBitmapCoreHeader;
	PBI       : PBitmapInfo;
	ColorTable: pointer;
	HeaderSize: DWORD;
	OS2Format : boolean;
	OldBMP    : HBITMAP;
	Pal       : HPALETTE;
	OldPal    : HPALETTE;
	BFH       : TBitmapFileHeader;
begin
	// Initialize variables.
	Result    := 0;
	P         := aBuffer;
	ImageSize := aBufferSize;

	// Read in Bitmap file header if present.
	CopyMemory(@BFH, P, SizeOf(TBitmapFileHeader));
	if (BFH.bfType = $4D42) then
		Inc(P, SizeOf(TBitmapFileHeader));

	// Get Bitmap header size.
	HeaderSize := TBitmapCoreHeader(pointer(P)^).bcSize;

	// Determine type of bitmap.
	OS2Format := (HeaderSize = SizeOf(OS2Header));
	if (OS2Format) then
		HeaderSize := SizeOf(TBitmapInfoHeader);

	// Get enough memory for Bitmap header and palette entries
	// no matter what the Bitmap bit depth or format is.
	// 3 quads for bitfields and 256 quads for palette.
	GetMem(PBI, HeaderSize + (3 * SizeOf(TRGBQuad)) + (256 * SizeOf(TRGBQuad)));

	if (PBI <> nil) then
	begin
		if (OS2Format) then
		begin
			// Convert OS2 DIB to Win DIB.
			CopyMemory(@OS2Header, P, SizeOf(OS2Header));
			Inc(P, SizeOf(OS2Header));
			FillChar(PBI^.bmiHeader, SizeOf(PBI^.bmiHeader), 0);
			PBI^.bmiHeader.biWidth    := OS2Header.bcWidth;
			PBI^.bmiHeader.biHeight   := OS2Header.bcHeight;
			PBI^.bmiHeader.biPlanes   := OS2Header.bcPlanes;
			PBI^.bmiHeader.biBitCount := OS2Header.bcBitCount;
			DEC(ImageSize, SizeOf(OS2Header));
		end
		else
		begin
			// Support bitmap headers larger than TBitmapInfoHeader
			// such as PBitmapV4Header, PBitmapV5Header.
			CopyMemory(PBI, P, HeaderSize);
			Inc(P, HeaderSize);
			DEC(ImageSize, HeaderSize);
		end;

		PBI^.bmiHeader.biSize := HeaderSize;
		ColorTable            := PByte(PBI) + HeaderSize;

		// Check number of planes. DIBs must be 1 color plane (packed pixels).
		if (PBI^.bmiHeader.biPlanes = 1) then
		begin
			// 3 DWORD color element bit masks (ie 888 or 565) can precede colors
			// TBitmapInfoHeader sucessors include these masks in the headersize
			if (HeaderSize = SizeOf(TBitmapInfoHeader)) and ((PBI^.bmiHeader.biBitCount = 16) or (PBI^.bmiHeader.biBitCount = 32)) and (PBI^.bmiHeader.biCompression = BI_BITFIELDS) then
			begin
				CopyMemory(ColorTable, P, (3 * SizeOf(DWORD)));
				Inc(Longint(ColorTable), 3 * SizeOf(DWORD));
				DEC(ImageSize, (3 * SizeOf(DWORD)));
			end;

			// Read the color palette.
			if (PBI^.bmiHeader.biClrUsed = 0) then
			begin
				if (PBI^.bmiHeader.biBitCount in [1, 4, 8]) then
					PBI^.bmiHeader.biClrUsed := (1 shl PBI^.bmiHeader.biBitCount)
				else
					PBI^.bmiHeader.biClrUsed := 0;
			end;
			CopyMemory(ColorTable, P, PBI^.bmiHeader.biClrUsed * DIBPalSizes[OS2Format]);
			Inc(P, PBI^.bmiHeader.biClrUsed * DIBPalSizes[OS2Format]);
			DEC(ImageSize, PBI^.bmiHeader.biClrUsed * DIBPalSizes[OS2Format]);

			// biSizeImage can be zero. If zero or RGB, compute the size.
			// top-down DIBs have negative height
			if (PBI^.bmiHeader.biSizeImage = 0) or (PBI^.bmiHeader.biCompression = BI_RGB) then
				PBI^.bmiHeader.biSizeImage := _BytesPerScanline(PBI^.bmiHeader.biWidth, PBI^.bmiHeader.biBitCount, 32) * Abs(PBI^.bmiHeader.biHeight);

			if (PBI^.bmiHeader.biSizeImage < ImageSize) then
				ImageSize := PBI^.bmiHeader.biSizeImage;

			// convert OS2 color table to DIB color table.
			if (OS2Format) then
				_RGBTripleToQuad(ColorTable^);

			// Create Bitmap.
			DC := GetDC(0);
			if (DC <> 0) then
			begin
				if ((PBI^.bmiHeader.biCompression <> BI_RGB) and (PBI^.bmiHeader.biCompression <> BI_BITFIELDS)) then
				begin
					GetMem(BitsMem, ImageSize);
					if (BitsMem <> nil) then
					begin
						CopyMemory(BitsMem, P, ImageSize);
						MemDC := CreateCompatibleDC(DC);
						if (MemDC <> 0) then
						begin
							OldBMP := SelectObject(MemDC, CreateCompatibleBitmap(DC, 1, 1));
							OldPal := 0;
							if (PBI^.bmiHeader.biClrUsed > 0) then
							begin
								Pal    := _PaletteFromDIBColorTable(0, ColorTable, PBI^.bmiHeader.biClrUsed);
								OldPal := SelectPalette(MemDC, Pal, False);
								RealizePalette(MemDC);
							end;
							Result := CreateDIBitmap(MemDC, PBI^.bmiHeader, CBM_INIT, BitsMem, PBI^, DIB_RGB_COLORS);
							if (OldPal <> 0) then
								SelectPalette(MemDC, OldPal, True);
							DeleteObject(SelectObject(MemDC, OldBMP));
							DeleteDC(MemDC);
						end;
						FreeMem(BitsMem);
					end;
				end
				else
				begin
					Result := CreateDIBSection(DC, PBI^, DIB_RGB_COLORS, BitsMem, 0, 0);
					CopyMemory(BitsMem, P, ImageSize);
					if (PBI^.bmiHeader.biBitCount = 32) and (aPremultiplyAlpha) then
						PremultiplyBitmapBits(BitsMem, ImageSize);
				end;
				ReleaseDC(0, DC);
			end;
		end;
		FreeMem(PBI);
	end;
end;

// Loads a aBitmap form a aFileName.
function LoadBitmapFromFile(const aFileName: string; const aPremultiplyAlpha: boolean): HBITMAP;
var
	F: TFileStream;
	H: TBitmapFileHeader;
	P: pointer;
	B: PByte;
begin
	Result := 0;

	F := TFileStream.Create(aFileName, fmOpenRead);
	try
		if (F.Read(H, SizeOf(TBitmapFileHeader)) = SizeOf(TBitmapFileHeader)) then
		begin
			P := GetMemory(H.bfSize);
			if (P <> nil) then
			begin
				B := P;
				CopyMemory(B, @H, SizeOf(TBitmapFileHeader));
				Inc(B, SizeOf(TBitmapFileHeader));
				if (F.Read(B^, F.Size - SizeOf(TBitmapFileHeader)) = F.Size - SizeOf(TBitmapFileHeader)) then
					Result := LoadBitmapFromBuffer(P, cardinal(F.Size), aPremultiplyAlpha);
				FreeMemory(P);
			end;
		end;
	finally
		F.Free;
	end;
end;

// Saves a aBitmap to a aBuffer. Function will return the allocated buffer in aBuffer. When you are done, call
// FreeMem() on it. aBuffer might return nil if allocation failed. Result is the size of allocation on aBuffer
// or 0 if an error occurs.
function SaveBitmapToBuffer(const aBitmap: HBITMAP; out aBuffer: pointer): cardinal;
var
	BFH       : TBitmapFileHeader;
	PBI       : PBitmapInfo;
	DS        : DIBSECTION;
	PRGB      : PRGBQuad;
	DC        : HDC;
	OldBM     : HBITMAP;
	Pal       : HPALETTE;
	PE        : array [0 .. 255] of TPaletteEntry;
	I         : integer;
	TotalBytes: DWORD;
	P         : PByte;
	Size      : cardinal;
	TempQuad  : array [0 .. 255] of TRGBQuad;
begin
	aBuffer := nil;
	Result  := 0;

	if (IsBitmapValid(aBitmap) = False) then
		Exit;

	// Get the BITMAPINFO for the DIBSection

	GetObject(aBitmap, SizeOf(DS), @DS);
	// load the header and the bitmasks if present
	// per function comments above, we allocate space for a color
	// table even if it is not needed
	if (DS.dsBmih.biCompression = BI_BITFIELDS) then
	begin
		// has a bitmask - be sure to allocate for and copy them
		PBI := GetMemory(SizeOf(TBitmapInfoHeader) + (3 * SizeOf(DWORD)) + (256 * SizeOf(TRGBQuad)));
		CopyMemory(@PBI^.bmiHeader, @DS.dsBmih, SizeOf(TBitmapInfoHeader) + (3 * SizeOf(DWORD)));
		PRGB := PRGBQuad(@PBI^.bmiColors[0]);
		Inc(PRGB, 3);
	end
	else
	begin
		// no bitmask - just the header and color table
		PBI := GetMemory(SizeOf(TBitmapInfoHeader) + (256 * SizeOf(TRGBQuad)));
		CopyMemory(@PBI^.bmiHeader, @DS.dsBmih, SizeOf(TBitmapInfoHeader));
		PRGB := @PBI^.bmiColors[0];
	end;

	// at this point, prgb points to the color table, even
	// if bitmasks are present

	// Now for the color table
	if ((DS.dsBm.bmBitsPixel * DS.dsBm.bmPlanes) <= 8) then
	begin
		// the DIBSection is 256 color or less (has color table)
		DC    := CreateCompatibleDC(0);
		OldBM := SelectObject(DC, aBitmap);
		ZeroMemory(@TempQuad[0], (256 * SizeOf(TRGBQuad)));
		Size := GetDIBColorTable(DC, 0, 1 shl (DS.dsBm.bmBitsPixel * DS.dsBm.bmPlanes), TempQuad);
		if (Size > 0) then
			CopyMemory(@PBI^.bmiColors[0], @TempQuad[0], Size * SizeOf(TRGBQuad));
		SelectObject(DC, OldBM);
		DeleteDC(DC);
	end
	else
	begin
		// the DIBSection is >8bpp (has no color table) so make one up
		// where are we going to get the colors? from a spectrum palette
		Pal := CreateSpectrumPalette;
		GetPaletteEntries(Pal, 0, 256, PE);
		for I := 0 to 255 do
		begin
			PRGB^.rgbRed      := PE[I].peRed;
			PRGB^.rgbGreen    := PE[I].peGreen;
			PRGB^.rgbBlue     := PE[I].peBlue;
			PRGB^.rgbReserved := 0;
			Inc(PRGB);
		end;
		DeleteObject(Pal);
	end;

	// What's the total size of the DIB information (not counting file header)?
	TotalBytes := _BitmapImageBitsSize(PBI) + SizeOf(TBitmapInfoHeader) + _BitmapColorTableSize(PBI);

	// Construct the file header
	ZeroMemory(@BFH, SizeOf(TBitmapFileHeader));
	BFH.bfType      := $4D42;
	BFH.bfSize      := TotalBytes + SizeOf(TBitmapFileHeader);
	BFH.bfReserved1 := 0;
	BFH.bfReserved2 := 0;
	BFH.bfOffBits   := SizeOf(TBitmapFileHeader) + PBI^.bmiHeader.biSize + _BitmapColorTableSize(PBI);

	aBuffer := GetMemory(BFH.bfSize);
	if (aBuffer <> nil) then
	begin
		Result := BFH.bfSize;
		P      := aBuffer;

		CopyMemory(P, @BFH, SizeOf(TBitmapFileHeader));
		Inc(P, SizeOf(TBitmapFileHeader));

		Size := SizeOf(TBitmapInfoHeader) + _BitmapColorTableSize(PBI);
		CopyMemory(P, PBI, Size);
		Inc(P, Size);

		Size := _BitmapImageBitsSize(PBI);
		CopyMemory(P, DS.dsBm.bmBits, Size);
	end;

	FreeMem(PBI);
end;

// Saves a aBitmap to a aFileName.
function SaveBitmapToFile(const aBitmap: HBITMAP; const aFileName: string): boolean;
var
	P: pointer;
	c: cardinal;
	F: TFileStream;
begin
	Result := False;

	c := SaveBitmapToBuffer(aBitmap, P);
	if (c <> 0) then
	begin
		F := TFileStream.Create(aFileName, fmOpenWrite);
		try
			if (P <> nil) then
			begin
				if (F.Write(P^, c) = integer(c)) then
					Result := True;
				FreeMem(P);
			end;
		finally
			F.Free;
		end;
	end;
end;

// Checks if bitmap handle is valid.
function IsBitmapValid(const aBitmap: HBITMAP): boolean;
begin
	Result := (GetObjectType(aBitmap) = OBJ_BITMAP);
end;

// Duplicates aBitmap. You need to free the returned bitmap yourself.
function DuplicateBitmap(const aBitmap: HBITMAP): HBITMAP;
var
	c: cardinal;
	P: pointer;
begin
	Result := 0;

	c := SaveBitmapToBuffer(aBitmap, P);
	if (c <> 0) then
	begin
		Result := LoadBitmapFromBuffer(P, c);
		FreeMem(P);
	end;
end;

// Gets aBitmap size in pixels.
function GetBitmapSize(const aBitmap: HBITMAP; var aSize: TSize): boolean;
var
	BIH: TBitmapInfoHeader;
begin
	Result := GetBitmapInfo(aBitmap, BIH);
	if (Result) then
	begin
		aSize.cx := BIH.biWidth;
		aSize.cy := BIH.biHeight;
	end;
end;

// Gets aBitmap bit depth.
function GetBitmapBitDepth(const aBitmap: HBITMAP): WORD;
var
	BIH: TBitmapInfoHeader;
begin
	if (GetBitmapInfo(aBitmap, BIH)) then
		Result := BIH.biBitCount
	else
		Result := 0;
end;

// Gets aBitmap info.
function GetBitmapInfo(const aBitmap: HBITMAP; var aBitmapInfo: TBitmapInfoHeader): boolean;
var
	DC : HDC;
	BI : TBitmapInfo;
	Res: integer;
begin
	Result := False;

	DC := GetDC(0);
	if (DC <> 0) then
	begin
		ZeroMemory(@BI, SizeOf(BI));
		BI.bmiHeader.biSize := SizeOf(TBitmapInfoHeader);
		Res                 := GetDIBits(DC, aBitmap, 0, 0, nil, BI, DIB_RGB_COLORS);
		if (Res <> 0) then
		begin
			aBitmapInfo := BI.bmiHeader;
			Result      := True;
		end;
		ReleaseDC(0, DC);
	end;
end;

// Draws aBitmap to a DeviceContext.
function DrawBitmap(const aDC: HDC; const aBitmap: HBITMAP; const aDestX, aDestY: integer; const aBlend: boolean = False): boolean; overload;
var
	SrcSZ: TSize;
begin
	Result := GetBitmapSize(aBitmap, SrcSZ);
	if (Result) then
		Result := DrawBitmap(aDC, aBitmap, aDestX, aDestY, SrcSZ.cx, SrcSZ.cy, 0, 0, SrcSZ.cx, SrcSZ.cy, aBlend);
end;

// Draws aBitmap to a DeviceContext.
function DrawBitmap(const aDC: HDC; const aBitmap: HBITMAP; const aDestX, aDestY, aDestCX, aDestCY: integer; const aBlend: boolean = False): boolean; overload;
var
	SrcSZ: TSize;
begin
	Result := GetBitmapSize(aBitmap, SrcSZ);
	if (Result) then
		Result := DrawBitmap(aDC, aBitmap, aDestX, aDestY, aDestCX, aDestCY, 0, 0, SrcSZ.cx, SrcSZ.cy, aBlend);
end;

// Draws aBitmap to a DeviceContext.
function DrawBitmap(const aDC: HDC; const aBitmap: HBITMAP; const aDestX, aDestY, aDestCX, aDestCY, aSrcX, aSrcY: integer; const aBlend: boolean = False): boolean; overload;
var
	SrcSZ: TSize;
begin
	Result := GetBitmapSize(aBitmap, SrcSZ);
	if (Result) then
		Result := DrawBitmap(aDC, aBitmap, aDestX, aDestY, aDestCX, aDestCY, aSrcX, aSrcY, SrcSZ.cx - aSrcX, SrcSZ.cy - aSrcY, aBlend);
end;

// Draws aBitmap to a DeviceContext.
function DrawBitmap(const aDC: HDC; const aBitmap: HBITMAP; const aDestX, aDestY, aDestCX, aDestCY, aSrcX, aSrcY, aSrcCX, aSrcCY: integer; const aBlend: boolean = False): boolean; overload;
var
	DC: HDC;
	BF: TBlendFunction;
begin
	Result := False;

	if (aDC = 0) or (aBitmap = 0) then
	begin
		SetLastError(ERROR_INVALID_PARAMETER);
		Exit;
	end;

	DC := CreateCompatibleDC(aDC);
	if (DC <> 0) then
	begin
		SelectObject(DC, aBitmap);

		if (aBlend) and (GetBitmapBitDepth(aBitmap) = 32) then
		begin
			BF.BlendOp             := AC_SRC_OVER;
			BF.BlendFlags          := 0;
			BF.SourceConstantAlpha := 255;
			BF.AlphaFormat         := AC_SRC_ALPHA;
			Result                 := AlphaBlend(aDC, aDestX, aDestY, aDestCX, aDestCY, DC, aSrcX, aSrcY, aSrcCX, aSrcCY, BF);
		end
		else
		begin
			Result := StretchBlt(aDC, aDestX, aDestY, aDestCX, aDestCY, DC, aSrcX, aSrcY, aSrcCX, aSrcCY, SRCCOPY);
		end;
		SelectObject(DC, 0);
		DeleteDC(DC);
	end;
end;

// Pre-multiplies aBitmap bits with its Alpha channel for proper alpha-blending drawing.
function PremultiplyBitmapAlpha(const aBitmap: HBITMAP; const aFloat: boolean = False): boolean;
var
	BIH  : TBitmapInfoHeader;
	Bits : pointer;
	Count: integer;
	I    : integer;
	Q    : PRGBQuad;
begin
	Result := False;

	if (aBitmap = 0) then
	begin
		SetLastError(ERROR_INVALID_PARAMETER);
		Exit;
	end;

	if (GetBitmapInfo(aBitmap, BIH) = False) then
		Exit;

	if (BIH.biBitCount < 32) then
	begin
		SetLastError(ERROR_INVALID_DATATYPE);
		Exit;
	end;

	Bits := GetMemory(BIH.biSizeImage);
	if (Bits = nil) then
		Exit;

	Count := Winapi.Windows.GetBitmapBits(aBitmap, BIH.biSizeImage, Bits);
	if (Count = 0) then
	begin
		FreeMemory(Bits);
		Exit;
	end;

	Q := Bits;
	I := 0;
	while (I < Count) do
	begin
		if (aFloat) then
		begin
			Q^.rgbBlue  := Round(Q^.rgbBlue * Q^.rgbReserved / 255);
			Q^.rgbGreen := Round(Q^.rgbGreen * Q^.rgbReserved / 255);
			Q^.rgbRed   := Round(Q^.rgbRed * Q^.rgbReserved / 255);
		end
		else
		begin
			Q^.rgbBlue  := Q^.rgbBlue * Q^.rgbReserved div 255;
			Q^.rgbGreen := Q^.rgbGreen * Q^.rgbReserved div 255;
			Q^.rgbRed   := Q^.rgbRed * Q^.rgbReserved div 255;
		end;
		Inc(Q);
		Inc(I, 4);
	end;

	Result := (SetBitmapBits(aBitmap, BIH.biSizeImage, Bits) <> 0);
	FreeMemory(Bits);
end;

// Pre-multiplies Bitmap aBits with its Alpha channel for proper alpha-blending drawing.
function PremultiplyBitmapBits(const aBits: pointer; const aBitsCount: cardinal; const aFloat: boolean = False): boolean;
var
	I: cardinal;
	Q: PRGBQuad;
begin
	Result := False;

	if (aBits = nil) then
	begin
		SetLastError(ERROR_INVALID_PARAMETER);
		Exit;
	end;

	Q := aBits;
	I := 0;
	while (I < aBitsCount) do
	begin
		if (aFloat) then
		begin
			Q^.rgbBlue  := Round(Q^.rgbBlue * Q^.rgbReserved / 255);
			Q^.rgbGreen := Round(Q^.rgbGreen * Q^.rgbReserved / 255);
			Q^.rgbRed   := Round(Q^.rgbRed * Q^.rgbReserved / 255);
		end
		else
		begin
			Q^.rgbBlue  := Q^.rgbBlue * Q^.rgbReserved div 255;
			Q^.rgbGreen := Q^.rgbGreen * Q^.rgbReserved div 255;
			Q^.rgbRed   := Q^.rgbRed * Q^.rgbReserved div 255;
		end;
		Inc(Q);
		Inc(I, 4);
	end;

	Result := True;
end;

// Creates a 256 coloe default spectrum palette for 8 bit bitmaps.
function CreateSpectrumPalette: HPALETTE;
var
	hPal  : HPALETTE;
	LogPal: PLogPalette;
	Red   : cardinal;
	Green : cardinal;
	Blue  : cardinal;
	I     : integer;
	Entry : PPaletteEntry;
begin
	LogPal := GetMemory(SizeOf(TLogPalette) + (SizeOf(TPaletteEntry) * 256));
	if (LogPal = nil) then
		Exit(0);

	LogPal^.palVersion    := $300;
	LogPal^.palNumEntries := 256;

	Red   := 0;
	Green := 0;
	Blue  := 0;

	Entry := @LogPal^.palPalEntry;
	for I := 0 to 255 do
	begin
		Entry^.peRed   := Red;
		Entry^.peGreen := Green;
		Entry^.peBlue  := Blue;
		Entry.peFlags  := 0;
		Inc(Entry);

		{
		 if (!(red += 32))
		 if (!(green += 32))
		 blue += 64;
		}

		Red := (Red + 32) mod 256;
		if (Red = 0) then
		begin
			Green := (Green + 32) mod 256;
			if (Green = 0) then
			begin
				Blue := (Blue + 64) mod 256;
			end;
		end;

	end;
	hPal := CreatePalette(LogPal^);
	FreeMem(LogPal);
	Result := hPal;
end;

// Creates a bitmap of aWidth x aHeight x aBits.
function CreateBitmap(const aWidth, aHeight: cardinal; const aBits: WORD): HBITMAP;
const
	RGB: array [0 .. 15] of TRGBTriple = ((rgbtBlue: $00; rgbtGreen: $00; rgbtRed: $00), // black
	  (rgbtBlue: $80; rgbtGreen: $00; rgbtRed: $00), // dark red
	  (rgbtBlue: $00; rgbtGreen: $80; rgbtRed: $00), // dark green
	  (rgbtBlue: $80; rgbtGreen: $80; rgbtRed: $00), // dark yellow
	  (rgbtBlue: $00; rgbtGreen: $00; rgbtRed: $80), // dark blue
	  (rgbtBlue: $80; rgbtGreen: $00; rgbtRed: $80), // dark magenta
	  (rgbtBlue: $00; rgbtGreen: $80; rgbtRed: $80), // dark cyan
	  (rgbtBlue: $C0; rgbtGreen: $C0; rgbtRed: $C0), // light gray
	  (rgbtBlue: $80; rgbtGreen: $80; rgbtRed: $80), // medium gray
	  (rgbtBlue: $FF; rgbtGreen: $00; rgbtRed: $00), // red
	  (rgbtBlue: $00; rgbtGreen: $FF; rgbtRed: $00), // green
	  (rgbtBlue: $FF; rgbtGreen: $FF; rgbtRed: $00), // yellow
	  (rgbtBlue: $00; rgbtGreen: $00; rgbtRed: $FF), // blue
	  (rgbtBlue: $FF; rgbtGreen: $00; rgbtRed: $FF), // magenta
	  (rgbtBlue: $00; rgbtGreen: $FF; rgbtRed: $FF), // cyan
	  (rgbtBlue: $FF; rgbtGreen: $FF; rgbtRed: $FF)  // white
	  );
var
	Bitmap: HBITMAP;
	Bits  : pointer;
	Size  : integer;
	BI    : PBitmapInfo;
	DC    : HDC;
	Masks : PDWORD;
	hPal  : HPALETTE;
	PE    : array [0 .. 255] of PALETTEENTRY;
	I     : integer;
	Quads : PRGBQuad;
begin
	Size := SizeOf(TBitmapInfoHeader);
	if (aBits <= 8) then
		Size := Size + SizeOf(TRGBQuad) * (1 shl aBits);
	if (aBits = 16) then
		Size := Size + (3 * SizeOf(cardinal));

	// Create the header big enough to contain color table and bitmasks if needed
	BI := GetMemory(Size);
	ZeroMemory(BI, Size);
	BI^.bmiHeader.biSize        := SizeOf(TBitmapInfoHeader);
	BI^.bmiHeader.biWidth       := aWidth;
	BI^.bmiHeader.biHeight      := aHeight;
	BI^.bmiHeader.biPlanes      := 1;
	BI^.bmiHeader.biBitCount    := aBits;
	BI^.bmiHeader.biCompression := BI_RGB; // Override below for 16 and 32bpp

	case aBits of

		32:
		begin
			// If it's 32bpp, fill in the masks and override the compression
			// these are the default masks - you could change them if needed
			Masks := @BI^.bmiColors;

			Masks^ := $00FF0000;
			Inc(Masks);
			Masks^ := $0000FF00;
			Inc(Masks);
			Masks^ := $000000FF;

			BI^.bmiHeader.biCompression := BI_BITFIELDS;
		end;

		24:
		begin
			// 24bpp requires no special handling
		end;

		16:
		begin
			// If it's 32bpp, fill in the masks and override the compression
			// these are the default masks - you could change them if needed
			Masks  := @BI^.bmiColors;
			Masks^ := $00007C00;
			Inc(Masks);
			Masks^ := $000003E0;
			Inc(Masks);
			Masks^                      := $0000001F;
			BI^.bmiHeader.biCompression := BI_BITFIELDS;
		end;

		8:
		begin
			// At this point, prgb points to the color table, even
			// if bitmasks are present
			hPal := CreateSpectrumPalette;
			GetPaletteEntries(hPal, 0, 256, PE);
			Quads := @BI^.bmiColors;
			for I := 0 to 255 do
			begin
				Quads^.rgbRed      := PE[I].peRed;
				Quads^.rgbGreen    := PE[I].peGreen;
				Quads^.rgbBlue     := PE[I].peBlue;
				Quads^.rgbReserved := 0;
				Inc(Quads);
			end;
			DeleteObject(hPal);
			BI^.bmiHeader.biClrUsed := 256;
		end;

		4:
		begin
			// Use a default 16 color table for 4bpp DIBSections
			for I := 0 to 16 - 1 do
			begin
				BI^.bmiColors[I].rgbRed      := RGB[I].rgbtRed;
				BI^.bmiColors[I].rgbGreen    := RGB[I].rgbtGreen;
				BI^.bmiColors[I].rgbBlue     := RGB[I].rgbtBlue;
				BI^.bmiColors[I].rgbReserved := 0;
			end;
			BI^.bmiHeader.biClrUsed := 16;
		end;

		1:
		begin
			// BW
			Quads := @BI^.bmiColors;

			Quads^.rgbRed      := 0;
			Quads^.rgbGreen    := 0;
			Quads^.rgbBlue     := 0;
			Quads^.rgbReserved := 0;

			Inc(Quads);

			Quads^.rgbRed      := 255;
			Quads^.rgbGreen    := 255;
			Quads^.rgbBlue     := 255;
			Quads^.rgbReserved := 255;
		end;

	end; { case }
	DC     := GetDC(0);
	Bitmap := CreateDIBSection(DC, BI^, DIB_RGB_COLORS, Bits, 0, 0);
	ReleaseDC(0, DC);
	FreeMem(BI);
	Result := Bitmap;
end;

// Creates a 32bit bitmap of the specified size.
function Create32BitBitmap(aWidth, aHeight: integer): HBITMAP; overload;
var
	TempBits: pointer;
begin
	Result := Create32BitBitmap(aWidth, aHeight, TempBits);
end;

// Creates a 32bit bitmap of the specified size and passes the pointer to its aBits.
function Create32BitBitmap(const aWidth, aHeight: integer; out aBits: pointer): HBITMAP;
var
	BI: BITMAPINFO;
begin
	ZeroMemory(@BI, SizeOf(BITMAPINFO));
	BI.bmiHeader.biSize        := SizeOf(BI.bmiHeader);
	BI.bmiHeader.biWidth       := aWidth;
	BI.bmiHeader.biHeight      := aHeight;
	BI.bmiHeader.biPlanes      := 1;
	BI.bmiHeader.biBitCount    := 32;
	BI.bmiHeader.biCompression := BI_RGB;

	aBits := nil;

	Result := CreateDIBSection(0, PBitmapInfo(@BI)^, DIB_RGB_COLORS, aBits, 0, 0);
end;

// Gets bitmap bits. Returns bits in aBits. Returns number of bits, -1 if failed. Free aBits yourself.
function GetBitmapBits(const aBitmap: HBITMAP; var aBits: pointer): integer;
var
	DC           : HDC;
	BMPInfoHeader: TBitmapInfoHeader;
	BMPInfo      : BITMAPINFO;
begin
	Result := - 1;

	DC := GetDC(0);
	if (DC <> 0) then
	begin
		try
			if (GetBitmapInfo(aBitmap, BMPInfoHeader)) then
			begin
				ZeroMemory(@BMPInfo, SizeOf(BMPInfo));
				CopyMemory(@BMPInfo, @BMPInfoHeader, SizeOf(BMPInfoHeader));
				Result := BMPInfoHeader.biSizeImage;
				aBits  := GetMemory(Result);
				if (GetDIBits(DC, aBitmap, 0, BMPInfoHeader.biHeight, aBits, BMPInfo, DIB_RGB_COLORS) <> BMPInfo.bmiHeader.biHeight) then
				begin
					FreeMem(aBits, Result);
					Result := - 1;
				end;
			end;
		finally
			ReleaseDC(0, DC);
		end;
	end;
end;

function PNGtoBitmap(aPNG: TPNGImage): HBITMAP;
const
	MaxRGBQuads = MaxInt div SizeOf(TRGBQuad) - 1;
type
	TRGBQuadArray = array [0 .. MaxRGBQuads] of TRGBQuad;
	PRGBQuadArray = ^TRGBQuadArray;
var
	imageBits              : PRGBQuadArray;
	x, y                   : integer;
	alphaLine              : Vcl.Imaging.PByteArray;
	hasAlpha, hasBitmap    : boolean;
	color, transparentColor: TColor;
begin
	imageBits := nil;

	Result := Create32BitBitmap(aPNG.Width, aPNG.Height, pointer(imageBits));
	if (Result = 0) then
		Exit;

	try
		alphaLine        := nil;
		hasAlpha         := aPNG.Header.ColorType in [COLOR_GRAYSCALEALPHA, COLOR_RGBALPHA];
		hasBitmap        := aPNG.TransparencyMode = ptmBit;
		transparentColor := aPNG.transparentColor;
		for y            := 0 to aPNG.Height - 1 do
		begin
			if hasAlpha then
				alphaLine := aPNG.AlphaScanline[aPNG.Height - y - 1];
			for x         := 0 to aPNG.Width - 1 do
			begin
				color                                   := aPNG.Pixels[x, aPNG.Height - y - 1];
				imageBits^[y * aPNG.Width + x].rgbRed   := color and $FF;
				imageBits^[y * aPNG.Width + x].rgbGreen := color shr 8 and $FF;
				imageBits^[y * aPNG.Width + x].rgbBlue  := color shr 16 and $FF;
				if hasAlpha then
					imageBits^[y * aPNG.Width + x].rgbReserved := alphaLine^[x]
				else
				  if hasBitmap then
					imageBits^[y * aPNG.Width + x].rgbReserved := integer(color <> transparentColor) * 255;
			end;
		end;
	except
		DeleteObject(Result);
		Result := 0;
	end;
end;

function PNGtoBitmap(const aFileName: string): HBITMAP; overload;
var
	PNGImage: TPNGImage;
begin
	PNGImage := TPNGImage.Create;
	try
		PNGImage.LoadFromFile(aFileName);
		Result := PNGtoBitmap(PNGImage);
	finally
		PNGImage.Free;
	end;
end;

procedure PremultiplyBitmap(aBitmap: TBitmap);
var
	x, y : integer;
	Pixel: PRGBQuad;
begin
	Assert(aBitmap.PixelFormat = pf32Bit);
	with aBitmap do
	begin
		for y := Height - 1 downto 0 do
		begin
			Pixel := ScanLine[y];
			for x := Width - 1 downto 0 do
			begin
				Pixel.rgbBlue  := MulDiv(Pixel.rgbBlue, Pixel.rgbReserved, 255);
				Pixel.rgbGreen := MulDiv(Pixel.rgbGreen, Pixel.rgbReserved, 255);
				Pixel.rgbRed   := MulDiv(Pixel.rgbRed, Pixel.rgbReserved, 255);
				Inc(Pixel);
			end;
		end;
	end;
end;

{ TIconImage }

constructor TIconImage.Create;
begin
	FHandle   := 0;
	FWidth    := 0;
	FHeight   := 0;
	FBitDepth := 0;
	FSize     := 0;
end;

destructor TIconImage.Destroy;
begin
	DestroyIcon(FHandle);
	inherited;
end;

procedure TIconImage.Draw(const aDC: HDC; const aX, aY: integer);
begin
	DrawIconEx(aDC, aX, aY, FHandle, 0, 0, 0, 0, DI_NORMAL);
end;

function TIconImage.Duplicate: HICON;
begin
	Result := CopyIcon(FHandle);
end;

function TIconImage.To32BitBitmap: HBITMAP;
var
	MainDC : HDC;
	TempDC : HDC;
	OutBits: pointer;

	function HasAlphaInternal(const aBits: pointer; const aBitsCount: cardinal): boolean;
	var
		P: PRGBQuad;
		c: cardinal;
	begin
		Result := False;
		P      := aBits;
		c      := aBitsCount;
		while (c > 0) do
		begin
			if (P.rgbReserved <> 0) then
			begin
				Result := True;
				Exit;
			end
			else
			begin
				Inc(P);
				DEC(c);
			end;
		end;
	end;

var
	MaskBitmap    : HBITMAP;
	MaskBitmapBits: pointer;
	c             : cardinal;
	PC            : PRGBQuad;
	PM            : PRGBQuad;
begin
	Result := 0;
	if (FHandle = 0) then
		Exit;

	MainDC := GetDC(0);
	if (MainDC <> 0) then
	begin
		TempDC := CreateCompatibleDC(MainDC);
		ReleaseDC(0, MainDC);
	end
	else
		Exit;

	if (TempDC <> 0) then
	begin
		Result := Create32BitBitmap(FWidth, FHeight, OutBits);
		SelectObject(TempDC, Result);
		DrawIconEx(TempDC, 0, 0, FHandle, 0, 0, 0, 0, DI_NORMAL);
		SelectObject(TempDC, 0);
		if (HasAlphaInternal(OutBits, FWidth * FWidth) = False) then
		begin
			MaskBitmap := Create32BitBitmap(FWidth, FHeight, MaskBitmapBits);
			if (MaskBitmap <> 0) then
			begin
				SelectObject(TempDC, MaskBitmap);
				DrawIconEx(TempDC, 0, 0, FHandle, 0, 0, 0, 0, DI_MASK);
				SelectObject(TempDC, 0);
				PC := OutBits;
				PM := MaskBitmapBits;
				c  := FWidth * FWidth;
				while (c > 0) do
				begin
					if (cardinal(PM^) and $FFFFFF00 <> 0) then
						RGBQUAD(PC^).rgbReserved := 0
					else
						RGBQUAD(PC^).rgbReserved := 255;
					Inc(PC);
					Inc(PM);
					DEC(c);
				end;
				DeleteObject(MaskBitmap);
			end;
		end;
		DeleteDC(TempDC);
	end;
end;

{ TIcon }

constructor TIconDirectory.Create;
begin
	FCount := 0;
end;

destructor TIconDirectory.Destroy;
begin
	Clear;
	inherited;
end;

function TIconDirectory.Add: TIconImage;
begin
	Inc(FCount);
	SetLength(FImages, FCount);
	FImages[FCount - 1] := TIconImage.Create;
	Result              := FImages[FCount - 1];
end;

procedure TIconDirectory.Clear;
var
	I: integer;
begin
	for I := 0 to FCount - 1 do
		FImages[I].Free;
	SetLength(FImages, 0);
	FCount := 0;
end;

function TIconDirectory.GetImage(aIndex: integer): TIconImage;
begin
	if (aIndex < 0) or (aIndex >= FCount) then
		Result := nil
	else
		Result := FImages[aIndex];
end;

function TIconDirectory.GetFormat(const aWidth, aHeight, aBitDepth: integer): HICON;
var
	I: integer;
begin
	Result := 0;

	for I := 0 to FCount - 1 do
	begin
		if (FImages[I].Width = aWidth) and (FImages[I].Height = aHeight) and (FImages[I].BitDepth = aBitDepth) then
			Exit(FImages[I].Handle);
	end;
end;

function TIconDirectory.ReadIconHeader(const aFile: HFILE): cardinal;
var
	Input    : WORD;
	BytesRead: DWORD;
begin
	if (ReadFile(aFile, Input, SizeOf(WORD), BytesRead, nil) = False) then
		Exit(cardinal( - 1));
	if (BytesRead <> SizeOf(WORD)) then
		Exit(cardinal( - 1));
	if (Input <> 0) then
		Exit(cardinal( - 1));
	if (ReadFile(aFile, Input, SizeOf(WORD), BytesRead, nil) = False) then
		Exit(cardinal( - 1));
	if (BytesRead <> SizeOf(WORD)) then
		Exit(cardinal( - 1));
	if (Input <> 1) then
		Exit(cardinal( - 1));
	if (ReadFile(aFile, Input, SizeOf(WORD), BytesRead, nil) = False) then
		Exit(cardinal( - 1));
	if (BytesRead <> SizeOf(WORD)) then
		Exit(cardinal( - 1));
	Result := Input;
end;

function TIconDirectory.To32BitBitmap(const aWidth, aHeight, aBitDepth: integer): HBITMAP;
var
	I: integer;
begin
	Result := 0;

	for I := 0 to FCount - 1 do
	begin
		if (FImages[I].BitDepth = aBitDepth) then
		begin
			if (FImages[I].Width = aWidth) and (FImages[I].Height = aHeight) then
				Exit(FImages[I].To32BitBitmap);
		end;
	end;
end;

function TIconDirectory.LoadFromIco(const aFileName: string): boolean;
var
	F        : HFILE;
	NumImages: cardinal;
	Image    : TIconImage;
	Entry    : TIconDirEntry;
	BytesRead: cardinal;
	I        : integer;
	Buffer   : pointer;
begin
	Result := False;

	F := CreateFile(PChar(aFileName), GENERIC_READ, 0, nil, OPEN_EXISTING, FILE_SHARE_READ, 0);
	if (F <> INVALID_HANDLE_VALUE) then
	begin
		NumImages := ReadIconHeader(F);
		if (NumImages <> cardinal( - 1)) then
		begin
			for I := 0 to NumImages - 1 do
			begin
				Image := Self.Add;
				if (ReadFile(F, Entry, SizeOf(TIconDirEntry), BytesRead, nil) = False) then
				begin
					Self.Clear;
					CloseHandle(F);
					Exit;
				end;
				Image.FWidth    := Entry.bWidth;
				Image.FHeight   := Entry.bHeight;
				Image.FBitDepth := Entry.wBitCount;
				Image.FSize     := Entry.dwBytesInRes;
			end;

			for I := 0 to NumImages - 1 do
			begin
				Buffer := AllocMem(FImages[I].FSize);

				if (Buffer = nil) then
				begin
					Self.Clear;
					CloseHandle(F);
					Exit;
				end;

				if (ReadFile(F, Buffer^, FImages[I].Size, BytesRead, nil) = False) then
				begin
					FreeMem(Buffer, FImages[I].Size);
					Self.Clear;
					CloseHandle(F);
					Exit;
				end;

				if (BytesRead <> FImages[I].Size) then
				begin
					FreeMem(Buffer, FImages[I].Size);
					Self.Clear;
					CloseHandle(F);
					Exit;
				end;

				FImages[I].FHandle := CreateIconFromResourceEx(Buffer, FImages[I].Size, True, $00030000, FImages[I].Width, FImages[I].Height, 0);
				FreeMem(Buffer, FImages[I].Size);
			end;

			Result := True;
		end;
		CloseHandle(F);
	end;
end;

{ TIcons }

constructor TIconList.Create;
begin
	FCount         := 0;
	FResourceCount := 0;
end;

destructor TIconList.Destroy;
begin
	Clear;
	inherited;
end;

function TIconList.Add: TIconDirectory;
begin
	Inc(FCount);
	SetLength(FIcons, FCount);
	FIcons[FCount - 1] := TIconDirectory.Create;
	Result             := FIcons[FCount - 1];
end;

procedure TIconList.Clear;
var
	I: integer;
begin
	for I := 0 to FCount - 1 do
		FIcons[I].Free;
	SetLength(FIcons, 0);
	FCount         := 0;
	FResourceCount := 0;
	SetLength(FResourceNames, 0);
end;

function TIconList.GetIcon(aIndex: integer): TIconDirectory;
begin
	if (aIndex < 0) or (aIndex >= FCount) then
		Result := nil
	else
		Result := FIcons[aIndex];
end;

class function TIconList.EnumResourceNamesProc(aModule: HINST; aType, aName: PChar; aLParam: LPARAM): BOOL;
var
	c: TIconList;
begin
	Result := False;
	c      := TIconList(aLParam);
	if (c <> nil) then
	begin
		Inc(c.FResourceCount);
		SetLength(c.FResourceNames, c.FResourceCount);
		if (ULONG_PTR(aName) shr 16 = 0) then // if (HiWord(WORD(aName)) = 0) then
			c.FResourceNames[c.FResourceCount - 1] := '#' + IntToStr(DWORD(aName))
		else
			c.FResourceNames[c.FResourceCount - 1] := aName;
		Result                                     := True;
	end;
end;

function TIconList.LoadFromIco(const aFileName: string): boolean;
var
	Icon: TIconDirectory;
begin
	Clear;
	Icon   := Self.Add;
	Result := Icon.LoadFromIco(ExpandEnvironmentVariables(aFileName));
end;

function TIconList.LoadFromExe(const aFileName: string; const aIconIndex, aCount: integer): boolean;
var
	Module       : HINST;
	Res          : HRSRC;
	Global       : HGLOBAL;
	Icon         : PGrpIconDir;
	Entry        : PGrpIconDirEntry;
	I            : integer;
	j            : integer;
	TempIcon     : TIconDirectory;
	TempIconImage: TIconImage;
begin
	Result := False;

	Clear;
	Module := LoadLibrary(PChar(ExpandEnvironmentVariables(aFileName)));
	if (Module <> 0) then
	begin
		if (EnumResourceNames(Module, RT_GROUP_ICON, @EnumResourceNamesProc, LPARAM(Self))) then
		begin
			if (aIconIndex < 0) then
				I := 0
			else
				I := aIconIndex;

			while (True) do
			begin
				Res := FindResource(Module, PChar(FResourceNames[I]), RT_GROUP_ICON);
				if (Res <> 0) then
				begin
					Global := LoadResource(Module, Res);
					if (Global <> 0) then
					begin
						Icon := LockResource(Global);
						if (Icon <> nil) then
						begin
							TempIcon := Self.Add;
							Entry    := @Icon^.idEntries;

							for j := 0 to Icon^.idCount - 1 do
							begin
								TempIconImage           := TempIcon.Add;
								TempIconImage.FWidth    := Entry^.bWidth;
								TempIconImage.FHeight   := Entry^.bHeight;
								TempIconImage.FBitDepth := Entry^.wBitCount;
								TempIconImage.FSize     := Entry^.dwBytesInRes;
								Res                     := FindResource(Module, MAKEINTRESOURCE(Entry^.nID), RT_ICON);
								if (Res <> 0) then
								begin
									Global := LoadResource(Module, Res);
									if (Global <> 0) then
									begin
										TempIcon[j].FHandle := CreateIconFromResourceEx(PByte(Global), TempIcon[j].FSize, True, $00030000, TempIcon[j].FWidth, TempIcon[j].Height, 0);
									end;
								end;
								Inc(Entry);
							end;
							Result := True;
						end;
					end;
				end;
				Inc(I);
				if (I >= FResourceCount) then
					Break;
				if (aCount > 0) then
				begin
					if (aIconIndex > 0) then
					begin
						if (I - aIconIndex = aCount) then
						begin
							Break;
						end;
					end;
				end;

			end;
		end;
		FreeLibrary(Module);
	end;
end;

end.
