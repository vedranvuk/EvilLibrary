unit EvilWorks.System.DateUtils;

interface

uses
	WinApi.Windows,
	System.SysUtils,
	System.DateUtils;

function DateNowUTC: TDateTime;
function DateTimeFromFileTime(aFileTime: TFileTime): TDateTime;
function DateHTTPTimestamp: string;
function DateTimeFromTwitterTimestamp(const aTimeStamp: string; var aDateTime: TDateTime): boolean;

var
	EnUsFormatSettings: TFormatSettings;

implementation

uses
	EvilWorks.System.StrUtils;

{ Now() equivalent returns time in UTC/GMT timezone. }
function DateNowUTC: TDateTime;
var
	sysTime: TSystemTime;
begin
	GetSystemTime(sysTime);
	Result := SystemTimeToDateTime(sysTime);
end;

{ Converts TFileTime to TDateTime. }
function DateTimeFromFileTime(aFileTime: TFileTime): TDateTime;
var
	temp           : TDateTime;
	localFileTime  : TFileTime;
	localSystemTime: TSystemTime;
begin
	FileTimeToLocalFileTime(aFileTime, localFileTime);
	FileTimeToSystemTime(localFileTime, localSystemTime);
	TryEncodeDate(localSystemTime.wYear, localSystemTime.wMonth, localSystemTime.wDay, temp);
	Result := temp;
	TryEncodeTime(localSystemTime.wHour, localSystemTime.wMinute, localSystemTime.wSecond, localSystemTime.wMilliseconds, temp);
	Result := Result + temp;
end;

{ Creates a HTTP timestamp. }
function DateHTTPTimestamp: string;
begin
	Result := FormatDateTime('ddd, dd mmm yyyy hh:nn:ss', DateNowUTC, EnUsFormatSettings) + ' GMT';
end;

{ Converts Twitter's timestamp string to TDateTime. Don't look at the code when you look at the code. }
function DateTimeFromTwitterTimestamp(const aTimeStamp: string; var aDateTime: TDateTime): boolean;
var
	tokens: TTokens;
	eYear, eMonth, eDay, eHour, eMinute, eSecond: word;
	eOffset, i: integer;
begin
	Result := False;
	if (aTimeStamp = '') then
		Exit;

	tokens := TextTokenize(aTimeStamp);
	if (tokens.Count <> 6) then
		Exit;

	eMonth := $FFFF;
	for i  := 1 to high(EnUsFormatSettings.ShortMonthNames) do
	begin
		if (SameText(tokens[1], EnUsFormatSettings.ShortMonthNames[i])) then
		begin
			eMonth := i;
			Break;
		end;
	end;
	if (eMonth = $FFFF) then
		Exit;

	eDay := TextToInt(tokens[2], $FFFF);
	if (eday = $FFFF) then
		Exit;

	eOffset := TextToInt(tokens[4], MaxInt);
	if (eOffset = maxInt) then
		Exit;

	eYear := TextToInt(tokens[5], $FFFF);
	if (eYear = $FFFF) then
		Exit;

	tokens := TextTokenize(tokens[3], ':');
	if (tokens.Count <> 3) then
		Exit;

	eHour := TextToInt(tokens[0], $FFFF);
	if (eHour = $FFFF) then
		Exit;

	eMinute := TextToInt(tokens[1], $FFFF);
	if (eMinute = $FFFF) then
		Exit;

	eSecond := TextToInt(tokens[2], $FFFF);
	if (eSecond = $FFFF) then
		Exit;

	if (TryEncodeDateTime(eYear, eMonth, eDay, eHour, eMinute, eSecond, 0, aDateTime) = False) then
		Exit;

	aDateTime := IncHour(aDateTime, eOffset);
	Result    := True;
end;

initialization

EnUsFormatSettings := TFormatSettings.Create('en-us');

end.
