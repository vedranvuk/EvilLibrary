unit EvilWorks.System.RTTI;

interface

uses
	System.Classes,
	System.SysUtils,
	System.TypInfo,
	System.IniFiles,
	System.RTTI;

type
	EEvilRTTI       = class(Exception);
	EMethodNotFound = class(EEvilRTTI);

function GetTypeKindName(const aTypeKind: TTypeKind): string;
function InvokeObjectMethod(aClassInstance: TObject; const aMethod: string; const aParams: array of string): string;

type
	{ Exceptions }
	ERTTIIni = class(Exception);

	{ TRTTIIni }
	TRTTIIni = class(TPersistent)
	strict private
		FFileName: string;
	protected
		{ Override to set the name of the section where properties will be written. }
        { If not overiden, ClassName will be used instead. }
		function GetSectionName: string; virtual;

		{ Save and load to FileName. }
		procedure Save;
		procedure Load;
	public
		{ Set the FileName to/from which to Save/Load. Do it before Load() or Save()... }
		property FileName: string read FFileName write FFileName;
	published
		{ Auto-Streamable properties go here. See Load() and Save() methods for supported data types. }
        { If you nest TRTTIIni object properties, they get auto saved as well to FileName. You'll have }
        { to declare them first (and their GetSectionName if you don't want auto-names). }
	end;

implementation

uses
	EvilWorks.System.StrUtils;

resourcestring
	SErrTypeNotFound = 'TRttiType %s not found.';
	SErrTypeMethodNotFound = 'TRttiMethod %s not found.';

function GetTypeKindName(const aTypeKind: TTypeKind): string;
const
	TTypeKindNames: array [0 .. 21] of string = (
	  'tkUnknown', 'tkInteger', 'tkChar', 'tkEnumeration', 'tkFloat', 'tkString', 'tkSet', 'tkClass',
	  'tkMethod', 'tkWChar', 'tkLString', 'tkWString', 'tkVariant', 'tkArray', 'tkRecord', 'tkInterface',
	  'tkInt64', 'tkDynArray', 'tkUString', 'tkClassRef', 'tkPointer', 'tkProcedure'
	  );
begin
	Result := TTypeKindNames[Ord(aTypeKind)];
end;

function InvokeObjectMethod(aClassInstance: TObject; const aMethod: string; const aParams: array of string): string;
var
	rttiCtx   : TRttiContext;
	rttiType  : TRttiType;
	rttiMethod: TRttiMethod;

	rttiParams: TArray<TRttiParameter>;
	rttiValues: TArray<TValue>;
	i         : integer;
	intVal    : integer;
begin
	rttiCtx := TRttiContext.Create;
	try
		rttiType := rttiCtx.GetType(aClassInstance.ClassInfo);
		if (rttiType = nil) then
			raise EEvilRTTI.CreateFmt(SErrTypeNotFound, [aClassInstance.ClassName]);

		rttiMethod := rttiType.GetMethod(aMethod);
		if (rttiMethod = nil) then
			raise EMethodNotFound.CreateFmt(SErrTypeMethodNotFound, [aMethod]);

		rttiParams := rttiMethod.GetParameters;
		if (Length(rttiParams) > 0) then
		begin
			if (Length(rttiParams) > Length(aParams)) then
				raise Exception.Create(Format('RTTIInvokeTypeMethod: Parameter counts differ: Given %d, expected %d.', [Length(aParams), Length(rttiParams)]));

			SetLength(rttiValues, Length(rttiParams));
			for i := 0 to Length(rttiParams) - 1 do
			begin
				case rttiParams[i].ParamType.TypeKind of
					tkUnknown:
					begin
						raise Exception.Create(Format('RTTIInvokeTypeMethod: Unknown parameter type for Method "%s" at index %d.', [aMethod, i]));
					end;
					tkChar, tkWChar, tkLString, tkUString, tkString:
					begin
						rttiValues[i] := aParams[i];
					end;
					tkWString:
					begin
						rttiValues[i] := TValue.From(widestring(aParams[i]));
					end;
					tkInteger:
					begin
						rttiValues[i] := StrToInt(aParams[i]);
					end;
					tkInt64:
					begin
						rttiValues[i] := StrToInt64(aParams[i]);
					end;
					tkFloat:
					begin
						rttiValues[i] := StrToFloat(aParams[i]);
					end;
					tkEnumeration:
					begin
						rttiValues[i] := TValue.FromOrdinal(rttiParams[i].ParamType.Handle, GetEnumValue(rttiParams[i].ParamType.Handle, aParams[i]));
					end;
					tkSet:
					begin
						intVal := StringToSet(rttiParams[i].ParamType.Handle, aParams[i]);
						TValue.Make(@intVal, rttiParams[i].ParamType.Handle, rttiValues[i]);
					end;
					tkVariant:
					begin
						rttiValues[i] := TValue.FromVariant(variant(aParams[i]));
					end;
					tkMethod:
					begin

					end;
					tkProcedure:
					begin

					end;
					tkClass:
					begin

					end;
					tkArray:
					begin

					end;
					tkRecord:
					begin

					end;
					tkInterface:
					begin

					end;
					tkDynArray:
					begin

					end;
					tkClassRef:
					begin

					end;
					tkPointer:
					begin

					end;
				end; { case }
			end;     { for }
		end;         { if }

		Result := rttiMethod.Invoke(aClassInstance, rttiValues).ToString;
	finally
		rttiCtx.Free;
	end;
end;

{ TRTTIIni }

function TRTTIIni.GetSectionName: string;
begin
	Result := Self.ClassName;
end;

procedure TRTTIIni.Load;
var
	ini           : TIniFile;
	sub           : TRTTIIni;
	sl            : TStringList;
	i             : integer;
	v             : integer;
	def           : string;
	data          : string;
	rttiContext   : TRttiContext;
	rttiType      : TRttiType;
	rttiProperty  : TRttiProperty;
	rttiProperties: TArray<TRttiProperty>;
	rttiVal       : TValue;
begin
	ini         := TIniFile.Create(FileName);
	sl          := TStringList.Create;
	rttiContext := TRttiContext.Create;
	try
		rttiType := rttiContext.GetType(Self.ClassInfo);
		if (rttiType = nil) then
			raise ERTTIIni.Create('TRTTIIni.Load(): Context.GetType() failed.');

		ini.ReadSection(GetSectionName, sl);
		for i := 0 to sl.Count - 1 do
		begin
			rttiProperty := rttiType.GetProperty(sl[i]);
			if (rttiProperty <> nil) then
			begin
				if (rttiProperty.Visibility <> mvPublished) or (not rttiProperty.IsWritable) or (not rttiProperty.IsReadable) then
					Continue;

				def  := rttiProperty.GetValue(Self).ToString;
				data := ini.ReadString(GetSectionName, sl[i], def);

				case rttiProperty.GetValue(Self).Kind of
					tkWChar, tkLString, tkWString, tkString, tkChar, tkUString:
					rttiVal := data;
					tkInteger, tkInt64:
					rttiVal := StrToInt(data);
					tkFloat:
					rttiVal := StrToFloat(data);
					tkEnumeration:
					rttiVal := TValue.FromOrdinal(rttiProperty.GetValue(Self).TypeInfo, GetEnumValue(rttiProperty.GetValue(Self).TypeInfo, data));
					tkSet:
					begin
						v := StringToSet(rttiVal.TypeInfo, data);
						TValue.Make(@v, rttiVal.TypeInfo, rttiVal);
					end;
				end;
				rttiProperty.SetValue(Self, rttiVal);
			end;
		end;

		rttiProperties := rttiType.GetProperties;
		for rttiProperty in rttiProperties do
		begin
			if (rttiProperty.Visibility <> mvPublished) or (not rttiProperty.IsReadable) or (not rttiProperty.IsWritable) then
				Continue;

			if (rttiProperty.GetValue(Self).IsObject) then
			begin
				if (rttiProperty.GetValue(Self).AsObject is TRTTIIni) then
				begin
					sub          := TRTTIIni(rttiProperty.GetValue(Self).AsObject);
					sub.FileName := Self.FileName;
					sub.Load;
				end;
			end;
		end;

	finally
		rttiContext.Free;
		sl.Free;
		ini.Free;
	end;
end;

procedure TRTTIIni.Save;
var
	ini           : TIniFile;
	sub           : TRTTIIni;
	rttiContext   : TRttiContext;
	rttiType      : TRttiType;
	rttiProperties: TArray<TRttiProperty>;
	rttiProperty  : TRttiProperty;
begin
	if (FFileName = '') then
		raise ERTTIIni.Create('TRTTIIni.Save(): FileName not specified.');

	ini         := TIniFile.Create(FileName);
	rttiContext := TRttiContext.Create;
	try
		ForceDirectories(ExtractFileDir(FileName));
		rttiType := rttiContext.GetType(Self.ClassInfo);
		if (rttiType = nil) then
			raise ERTTIIni.Create('TRTTIIni.Save(): Failed to get TRTTIType.');

		rttiProperties := rttiType.GetProperties;
		for rttiProperty in rttiProperties do
		begin
			if (rttiProperty.Visibility <> mvPublished) or (not rttiProperty.IsReadable) or (not rttiProperty.IsWritable) then
				Continue;

			if rttiProperty.GetValue(Self).Kind in [
			  tkWChar, tkLString, tkWString, tkString, tkChar, tkUString,
			  tkInteger, tkInt64, tkFloat, tkEnumeration, tkSet] then
				ini.WriteString(GetSectionName, rttiProperty.Name, rttiProperty.GetValue(Self).ToString);

			if (rttiProperty.GetValue(Self).IsObject) then
			begin
				if (rttiProperty.GetValue(Self).AsObject is TRTTIIni) then
				begin
					sub          := TRTTIIni(rttiProperty.GetValue(Self).AsObject);
					sub.FileName := Self.FileName;
					sub.Save;
				end;
			end;
		end;
	finally
		rttiContext.Free;
		ini.Free;
	end;
end;

end.
