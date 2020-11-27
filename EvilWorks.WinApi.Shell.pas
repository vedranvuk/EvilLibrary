(*============================================================================================================

 EvilLibrary by Vedran Vuk 2010-2012

 Name: 					EvilWorks.WinApi.Shell
 Description: 			Various shell related functions.
 File last change date: August 21th. 2012
 File version: 			0.1.1
 Licence:				Free as in beer.

 ===========================================================================================================*)

 unit EvilWorks.WinApi.Shell;

interface

uses
	Winapi.Windows,
    Winapi.ActiveX,
    Winapi.ShLwApi,
    Winapi.ShellAPi,
    Winapi.ShlObj,
    Winapi.SHFolder,
	Winapi.KnownFolders,
	System.SysUtils;

function GetUserDocumentsDir: string;
function GetAllUsersDocumentsDir: string;
function GetUserDocumentsPath: string;
function GetAllUsersDocumentsPath: string;
function GetUserAppDataDir: string;
function GetUserAppDataPath: string;
function GetCommonAppDataDir: string;
function GetCommonAppDataPath: string;

function GetClsIDDisplayName(const aClsID: string): string;
function GetAssociatedIconFileName(const aFileName: string; out aIconFileName: string; out aIconIndex: integer): boolean;
function LoadIcon(const aIconString: string; const aSmallIcon: boolean = False): HICON;
function LoadAssociatedIcon(const aFileName: string; const aSmallIcon: boolean = False): HICON;
function PickIconDlg(const aParent: HWND; var aPath: string): integer;

implementation

uses
	EvilWorks.System.SysUtils, EvilWorks.System.StrUtils;

{ Retrieves a shell path. }
function GetShlPath(aCSIDL: integer; aFID: KNOWNFOLDERID): string;
var
	buffer: pointer;
begin
	Result := EmptyStr;

    if (TOSVersion.Check(6, 1)) then
	begin
		// Vista+
		if (SHGetKnownFolderPath(aFID, 0, 0, PChar(buffer)) = S_OK) then
		begin
			Result := PChar(buffer);
			CoTaskMemFree(buffer);
		end;
	end
	else
	// XP
	begin
		buffer := AllocMem(MAX_PATH * SizeOf(char));
		try
			if (SHGetFolderPath(0, aCSIDL, 0, 0, buffer) = S_OK) then
				Result := PChar(buffer);
		finally
			FreeMem(buffer);
		end;
	end;
end;

{ Gets "My Documents" directory for current user. }
function GetUserDocumentsDir: string;
begin
	Result := GetShlPath(CSIDL_PERSONAL, FOLDERID_Documents);
end;

{ Gets "Documents" directory for all users. }
function GetAllUsersDocumentsDir: string;
begin
	Result := GetShlPath(CSIDL_COMMON_DOCUMENTS, FOLDERID_PublicDocuments);
end;

{ Gets "My Documents" path for current user. }
function GetUserDocumentsPath: string;
begin
	Result := IncludeTrailingPathDelimiter(GetUserDocumentsDir);
end;

{ Gets "Documents" path for all users. }
function GetAllUsersDocumentsPath: string;
begin
	Result := IncludeTrailingPathDelimiter(GetAllUsersDocumentsDir);
end;

{ Gets "Application data" directory for current user. }
function GetUserAppDataDir: string;
begin
	Result := GetShlPath(CSIDL_APPDATA, FOLDERID_RoamingAppData);
end;

{ Gets "Application data" path for current user. }
function GetUserAppDataPath: string;
begin
	Result := IncludeTrailingPathDelimiter(GetUserAppDataDir);
end;

{ Gets "Application data" directory for all users (ProgramData on Vista+). }
function GetCommonAppDataDir: string;
begin
	Result := GetShlPath(CSIDL_COMMON_APPDATA, FOLDERID_ProgramData);
end;

{ Gets "Application data" path for all users (ProgramData on Vista+). }
function GetCommonAppDataPath: string;
begin
	Result := IncludeTrailingPathDelimiter(GetCommonAppDataDir);
end;

{ Returns a display name associated with a classID. For instance shl folders. }
function GetClsIDDisplayName(const aClsID: string): string;
var
	ShlFolder: IShellFolder;
	PIDL     : PItemIDList;
	STR      : STRRET;
	name     : LPTSTR;
begin
	if (Succeeded(SHGetDesktopFolder(ShlFolder))) then
	begin
		if (ShlFolder.ParseDisplayName(0, nil, PChar(aClsID), ULONG(nil^), PIDL, ULONG(nil^)) = S_OK) then
		begin
			if (ShlFolder.GetDisplayNameOf(PIDL, SHGDN_FORADDRESSBAR, STR) = S_OK) then
			begin
				StrRetToStr(@STR, PIDL, name);
				Result := name;
				CoTaskMemFree(name);
				CoTaskMemFree(STR.pOleStr);
				CoTaskMemFree(STR.pStr);
			end;
			CoTaskMemFree(PIDL);
		end;
	end;
end;

{ Returns the filename of the icon associated with aFileName or ClsID. }
function GetAssociatedIconFileName(const aFileName: string; out aIconFileName: string; out aIconIndex: integer): boolean;
var
	SFI: TSHFileInfo;
begin
	aIconFileName := CEmpty;
	aIconIndex    := 0;
	ZeroMemory(@SFI, SizeOf(SFI));

	Result := (SHGetFileInfo(PChar(aFileName), FILE_ATTRIBUTE_NORMAL, SFI, SizeOf(SFI), SHGFI_ICONLOCATION or SHGFI_USEFILEATTRIBUTES) = 0);
	if (Result) then
	begin
		aIconFileName := string(PChar(@SFI.szDisplayName[0]));
		aIconIndex    := SFI.iIcon;
	end;
end;

{ Loads an icon from an executable, dll or an Icon file. }
{ aIconString is in the format: }
{ C:\PathToMyFile.exe,1 or C:\PathToMyFile.exe,AppIcon }
function LoadIcon(const aIconString: string; const aSmallIcon: boolean = False): HICON; overload;
var
	FileName : string;
	Resource : string;
	IconIndex: integer;
	SmallIcon: HICON;
	LargeIcon: HICON;
begin
	Result := 0;

	Resource  := aIconString;
	FileName  := TextExtractLeft(Resource, CComma);
	IconIndex := StrToIntDef(Resource, - 1);
	if (IconIndex <> - 1) then
	begin
		if (aSmallIcon) then
		begin
			LargeIcon := 0;
			SmallIcon := 1;
		end
		else
		begin
			LargeIcon := 1;
			SmallIcon := 0;
		end;

		if (ExtractIconEx(PChar(FileName), cardinal(IconIndex), LargeIcon, SmallIcon, 1) > 0) then
		begin
			if (aSmallIcon) then
				Result := SmallIcon
			else
				Result := LargeIcon;
		end;
	end;
end;

{ Returns the associated icon for a file, path or a ClsID. }
function LoadAssociatedIcon(const aFileName: string; const aSmallIcon: boolean = False): HICON;
var
	SFI      : TSHFileInfo;
	ShlFolder: IShellFolder;
	PIDL     : PItemIDList;
begin
	Result := 0;
	ZeroMemory(@PIDL, SizeOf(TItemIDList));
	ZeroMemory(@SFI, SizeOf(SFI));
	if (Succeeded(SHGetDesktopFolder(ShlFolder))) then
	begin
		if (ShlFolder.ParseDisplayName(0, nil, PChar(aFileName), ULONG(nil^), PIDL, ULONG(nil^)) = S_OK) then
		begin
			if (aSmallIcon) then
			begin
				if (Succeeded(SHGetFileInfo(PChar(PIDL), 0, SFI, SizeOf(SFI), SHGFI_PIDL or SHGFI_ICON or SHGFI_SMALLICON))) then
					Result := SFI.HICON;
			end
			else
			begin
				if (Succeeded(SHGetFileInfo(PChar(PIDL), 0, SFI, SizeOf(SFI), SHGFI_PIDL or SHGFI_ICON))) then
					Result := SFI.HICON;
			end;
			CoTaskMemFree(PIDL);
		end;
	end;
end;

{ Windows Pick Icon dialog. }
{ If user picked an icon Return is IconIndex (>= 0), or -1 on cancel. }
{ Set aPath to initially selected resource path, will return selected file path (Icon, Exe, resource...) }
function PickIconDlg(const aParent: HWND; var aPath: string): integer;
var
	buffer   : array [0 .. MAX_PATH] of char;
	IconIndex: integer;
begin
	FillChar(buffer, MAX_PATH + 1, 0);
	if (aPath <> CEmpty) then
		CopyMemory(@buffer[0], @aPath[1], Length(aPath) * StringElementSize(aPath));
	if (Winapi.ShlObj.PickIconDlg(aParent, buffer, MAX_PATH + 1, IconIndex) = 1) then
	begin
		Result := IconIndex;
		aPath  := PChar(@buffer[0]);
	end
	else
		Result := - 1;
end;

end.
