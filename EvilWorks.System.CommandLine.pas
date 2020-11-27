unit EvilWorks.System.CommandLine;

interface

uses
	Winapi.Windows,
	EvilWorks.System.StrUtils;

type
	{ TCmdLine }
	{ Gets current command line and splits it into Tokens. Switch prefixes ARE "-" OR "/". }
	{ Call Parse to split, Result indicates success. Double quotes around stuff mean ONE token. }
	{ -switch1 param1 -switch2 "param 2" -"switch 3" param3 -switch4 -"switch 5" ... }
	TCmdLine = record
	public type
		PCmdLineItem = ^TCmdLineItem;
		TCmdLineItem = record
			Switch: string;
			Param: string;
		end;	
	private
		FApp  : string;
		FItems: array of TCmdLineItem;
		function GetItem(aIndex: integer): TCmdLineItem;
		function GetCount: integer;
		function GetSwitch(const aName: string): TCmdLineItem;
	public
		function Parse: boolean;

		function SwitchExists(const aSwitch: string): boolean;
		function SwitchIs(const aIndex: integer; const aText: string): boolean;

		property App: string read FApp; // First item in command line, application path
		property Items[aIndex: integer]: TCmdLineItem read GetItem; default;
		property Switch[const aName: string]: TCmdLineItem read GetSwitch;
		property Count: integer read GetCount; // Does not count first param (app path)
	end;

implementation

{ TCmdLine }

function TCmdLine.Parse: boolean;
var
	tokens: TTokens;
	item  : PCmdLineItem;
	i     : integer;
begin
	Result := False;

	tokens := TextTokenize(GetCommandLine, CSpace, CDoubleQuote, [soCSSep, soQuoted, soCSQot]);
	if (tokens.Count = 0) then
		Exit;
	FApp := tokens[0];
	i    := 1;
	while (i < tokens.Count) do
	begin
		if (TextLeft(tokens[i], 1) = CMinus) or (TextLeft(tokens[i], 1) = CFrontSlash) then
		begin
			SetLength(FItems, Length(FItems) + 1);
			item         := @FItems[Length(FItems) - 1];
			item^.Switch := TextUnquote(TextRight(tokens[i], Length(tokens[i]) - 1));
			if (tokens[i + 1] <> CEmpty) then
			begin
				if (TextLeft(tokens[i + 1], 1) <> CMinus) and (TextLeft(tokens[i + 1], 1) <> CFrontSlash) then
				begin
					item^.Param := TextUnquote(tokens[i + 1]);
					Inc(i, 2);
				end
				else
					Inc(i, 1);
			end
			else
				Break;
		end
		else
			Exit;
	end;
	Result := True;
end;

function TCmdLine.SwitchExists(const aSwitch: string): boolean;
var
	i: integer;
begin
	Result := False;
	for i  := 0 to GetCount - 1 do
		if (TextEquals(FItems[i].Switch, aSwitch)) then
			Exit(True);
end;

function TCmdLine.SwitchIs(const aIndex: integer; const aText: string): boolean;
begin
	Result := TextEquals(GetItem(aIndex).Switch, aText);
end;

function TCmdLine.GetCount: integer;
begin
	Result := Length(FItems);
end;

function TCmdLine.GetItem(aIndex: integer): TCmdLineItem;
begin
	if (aIndex < 0) or (aIndex >= Count) then
	begin
		Result.Param  := '';
		Result.Switch := '';
	end
	else
		Result := FItems[aIndex];
end;

function TCmdLine.GetSwitch(const aName: string): TCmdLineItem;
var
	i: integer;
begin
	for i := 0 to Count - 1 do
	begin
		if (TextEquals(FItems[i].Switch, aName)) then
			Exit(FItems[i]);
	end;
	Result.Switch := '';
	Result.Param  := '';
end;

end.
