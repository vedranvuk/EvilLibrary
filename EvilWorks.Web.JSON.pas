//
// EvilLibrary by Vedran Vuk 2010-2012
//
// Name: 					EvilWorks.Web.Json
// Description: 			Json class. Inspired by superobject which is cool, unlike interfaces.
//                          Designed as an intermediate container, with little management functions.
// File last change date:   November 7th. 2012
// File version: 			Dev 0.0.0
// Licence:                 Free.
//

unit EvilWorks.Web.JSON;

interface

uses
	System.Classes,
	System.SysUtils,
	EvilWorks.System.StrUtils,
	EvilWorks.Generics.AVLTree,
	EvilWorks.Generics.List;

type
	{ Exceptions }
	EJson             = class(Exception);
	EJsonMalformed    = class(EJson); // Raised when parsing a malformed json input.
	EJsonConvert      = class(EJson); // Raised when casting Json to an incompatible type.
	EJsonItemNotFound = class(EJson); // Raised when the path does not exist.
	EJsonInvalidPath  = class(EJson); // Raised when an invalid path is passed to O[aKey];

    { TJsonValueType }
    { Json data type contained in TJson. }
	TJsonValueType = (jvtNull, jvtString, jvtInteger, jvtFloat, jvtBool, jvtArray, jvtObject);

    { TJson }
    { Main Json object. }
	TJson = class
	private
		FOwner    : TJson;          // Owner.
		FName     : string;         // Item key.
		FValueType: TJsonValueType; // Json data type currently contained.
		FValue    : pointer;        // Data for the value.
		FValueSize: integer;        // Size of the value data.

        // Checks what value type is contained in this instance.
		function GetIsNull: boolean;
		function GetIsString: boolean;
		function GetIsInteger: boolean;
		function GetIsFloat: boolean;
		function GetIsBool: boolean;
		function GetIsArray: boolean;
		function GetIsObject: boolean;

        // (Re)initializes this instance to a new type.
		procedure SetToString(const aLength: integer);
		procedure SetToInteger;
		procedure SetToFloat;
		procedure SetToBool;
		procedure SetToArray;
		procedure SetToObject;

        // Value getters.
		function GetS: string;
		function GetI: int64;
		function GetF: double;
		function GetB: boolean;
		function GetA(const aIndex: integer): TJson;
		function GetO(const aKey: string): TJson;

        // Value setters.
		procedure SetS(const aValue: string);
		procedure SetI(const aValue: int64);
		procedure SetF(const aValue: double);
		procedure SetB(const aValue: boolean);
		procedure SetA(const aIndex: integer; const aValue: TJson);
		procedure SetO(const aKey: string; const aValue: TJson);

        // Property getters/setters.
		function GetCount: integer;
		procedure SetName(const aValue: string);
	protected
		procedure Rename(const aOldKey, aNewKey: string);
		function Tree: TAVLTree<string, TJson>;
	public
		constructor Create(aOwner: TJson);
		destructor Destroy; override;
		procedure Assign(aSource: TJson);

        // Json is a JavaScript format which is CASE-SENSITIVE, so Name is as well.
		property name: string read FName write SetName;

		procedure Null;

    	// Management functions when TJson is an Array.
        // Using these comverts this Json to array.
		function Add: TJson;
		function Insert(const aIndex: integer): TJson;
		procedure Delete(const aIndex: integer);

        // Check what type of json value is contained in this Json instance.
		property ValueType: TJsonValueType read FValueType;
		property IsNull: boolean read GetIsNull;
		property IsString: boolean read GetIsString;
		property IsInteger: boolean read GetIsInteger;
		property IsFloat: boolean read GetIsFloat;
		property IsBool: boolean read GetIsBool;
		property IsArray: boolean read GetIsArray;
		property IsObject: boolean read GetIsObject;

		procedure AddS(const aKey: string; const aVal: string);
		procedure AddI(const aKey: string; const aVal: integer);
		procedure AddF(const aKey: string; const aVal: double);
		procedure AddB(const aKey: string; const aVal: boolean);
		procedure AddA(const aKey: string; const aVal: array of TJson);
		procedure AddO(const aKey: string; const aVal: TJson);

		// Access this instance value by casting to a specific type.
        // An EJsonConvert is raised if casting to wrong type. Use preceeding Is* functions.
		property S: string read GetS write SetS;
		property I: int64 read GetI write SetI;
		property F: double read GetF write SetF;
		property B: boolean read GetB write SetB;
		property A[const aIndex: integer]: TJson read GetA write SetA;
		property O[const aPath: string]: TJson read GetO write SetO;

        // Number of items contained if object or array.
		property Count: integer read GetCount;
	end;

function ParseJson(const aJson: string): TJson;

implementation

{ Creates a TJson instance from a string. Free it after you're done. }
function ParseJson(const aJson: string): TJson;
type
	TJsonToken = (
	  jtObjectStart,
	  jtObjectEnd,
	  jtArrayStart,
	  jtArrayEnd,
	  jtStringQuote,
	  jtValColon,
	  jtValComma
	  );
	TJsonTokens = set of TJsonToken;

	TParseLocation = (
	  plStart,
	  plObject,
	  plArray,
	  plName,
	  plValue
	  );

var
	i: integer;

	procedure Throw;
	begin
		if (Result <> nil) then
			FreeAndNil(Result);
		raise EJsonMalformed.Create(Format('Malformed Json string at %d.', [i]));
	end;

var
	l: integer;
	c: TJson;
	k: TJsonTokens;
begin
	Result := nil;
	if (aJson = '') then
		Throw;

	Result := TJson.Create(nil);
	c      := Result;
	i      := 1;
	l      := Length(aJson);
	k      := [jtArrayStart, jtObjectStart];

	while (i <= l) do
	begin
		case aJson[i] of

            #8, #9, #10, #12, #13, #32:
			begin
            	{ Skip spaces. }
			end;

			'{':
			begin

			end;

			'}':
			begin

			end;

			'[':
			begin

			end;

			']':
			begin

			end;

			'"':
			begin

			end;

			':':
			begin

			end;

			',':
			begin

			end;

			else
			begin

			end;

		end; { case }

		Inc(i);
	end;
end;

{ ===== }
{ TJson }
{ ===== }

{ Constructor. }
constructor TJson.Create(aOwner: TJson);
begin
	FOwner     := aOwner;
	FValueType := jvtNull;
	FValueSize := 0;
	FValue     := nil;
end;

{ Destructor. }
destructor TJson.Destroy;
begin
	Null;
	inherited;
end;

{ Assign. }
procedure TJson.Assign(aSource: TJson);
var
	i: integer;
	t: TAVLTree<string, TJson>;
	j: TJson;
begin
	Null;
	name := aSource.name;
	case aSource.ValueType of
		jvtNull:
		Exit;
		jvtString:
		Self.S := aSource.S;
		jvtInteger:
		Self.I := aSource.I;
		jvtFloat:
		Self.F := aSource.F;
		jvtBool:
		Self.B := aSource.B;
		jvtArray:
		for i := 0 to aSource.Count - 1 do
			Self.Add.Assign(aSource.A[i]);
		jvtObject:
		begin
			t := aSource.Tree;
			for j in t do
				O[j.name].Assign(j);
		end;
	end;
end;

{ Null this Json instance value and free all its sub-objects (if any). }
procedure TJson.Null;
begin
	if (FValueType = jvtNull) then
		Exit;

	if (FValueType = jvtObject) then
	begin
		TAVLTree<string, TJson>(FValue).Free;
		FValue := nil;
	end;

	if (FValueType = jvtArray) then
	begin
		TList<TJson>(FValue).Free;
		FValue := nil;
	end;

	if (FValue <> nil) then
	begin
		FreeMem(FValue, FValueSize);
		FValue := nil;
	end;
	FValueSize := 0;
	FValueType := jvtNull;
end;

{ Change name of a json in the tree if this json is an object. Required for managing AVL tree. }
procedure TJson.Rename(const aOldKey, aNewKey: string);
begin
	if (FValueType <> jvtObject) then
		raise EJsonConvert.Create('Rename: value is not an object.');

	TAVLTree<string, TJson>(FValue).ReKey(aOldKey, aNewKey);
end;

{ Returns the AVL tree for a Json of value type object. Raises EJsonConvert if Json value is not an object. }
function TJson.Tree: TAVLTree<string, TJson>;
begin
	if (FValueType <> jvtObject) then
		raise EJsonConvert.Create('Tree: value is not an object.');

	Result := TAVLTree<string, TJson>(FValue);
end;

{ Converts this instance to an array if not already one then adds a new json  }
{ to the array and returns it for modification. }
function TJson.Add: TJson;
begin
	SetToArray;
	Result := TList<TJson>(FValue).Add;
end;

{ Converts this instance to an array if not already one then inserts a new json  }
{ to the array at aIndex and returns it for modification. }
function TJson.Insert(const aIndex: integer): TJson;
begin
	SetToArray;
	Result := TList<TJson>(FValue).Insert(aIndex);
end;

{ Deletes an item from the array if Json is an array, otherwise raises EJsonConvert. }
procedure TJson.Delete(const aIndex: integer);
begin
	if (FValueType <> jvtArray) then
		raise EJsonConvert.Create('Delete: value is not an array.');

	TList<TJson>(FValue).Delete(aIndex);
end;

{ Checks if value is Null. }
function TJson.GetIsNull: boolean;
begin
	Result := (FValueType = jvtNull);
end;

{ Checks if value is String. }
function TJson.GetIsString: boolean;
begin
	Result := (FValueType = jvtString);
end;

{ Checks if value is Bool. }
function TJson.GetIsBool: boolean;
begin
	Result := (FValueType = jvtBool);
end;

{ Checks if value is Integer. }
function TJson.GetIsInteger: boolean;
begin
	Result := (FValueType = jvtInteger);
end;

{ Checks if value is Float. }
function TJson.GetIsFloat: boolean;
begin
	Result := (FValueType = jvtFloat);
end;

{ Checks if value is Array. }
function TJson.GetIsArray: boolean;
begin
	Result := (FValueType = jvtArray);
end;

{ Checks if value is Object. }
function TJson.GetIsObject: boolean;
begin
	Result := (FValueType = jvtObject);
end;

{ Returns count of items if item is array or number of contained values if Object. }
function TJson.GetCount: integer;
begin
	if (FValueType = jvtArray) then
		Result := TList<TJson>(FValue).Count
	else if (FValueType = jvtObject) then
		Result := TAVLTree<string, TJson>(FValue).Count
	else
		Result := 0;
end;

{ Returns value as string. If value is not String raises EJsonConvert. }
function TJson.GetS: string;
begin
	if (FValueType <> jvtString) then
		raise EJsonConvert.Create('GetS: value is not a string.');

	Result := string(PChar(FValue))
end;

{ Returns value as int64. If value is not int64 raises EJsonConvert. }
function TJson.GetI: int64;
begin
	if (FValueType <> jvtInteger) then
		raise EJsonConvert.Create('GetI: value is not an integer.');

	if (FValueType = jvtInteger) then
		Result := pint64(FValue)^;
end;

{ Returns value as double. If value is not double raises EJsonConvert. }
function TJson.GetF: double;
begin
	if (FValueType <> jvtFloat) then
		raise EJsonConvert.Create('GetF: value is not a float.');

	if (FValueType = jvtFloat) then
		Result := pdouble(FValue)^;
end;

{ Returns value as boolean. If value is not boolean raises EJsonConvert. }
function TJson.GetB: boolean;
begin
	if (FValueType <> jvtBool) then
		raise EJsonConvert.Create('GetB: value is not a boolean.');

	Result := pboolean(FValue)^;
end;

{ Returns value as array. If value is not array raises EJsonConvert. }
function TJson.GetA(const aIndex: integer): TJson;
begin
	if (FValueType <> jvtArray) then
		raise EJsonConvert.Create('GetA: value is not an array.');

	Result := TList<TJson>(FValue)[aIndex];
end;

{ Returns value as object. If value is not object raises EJsonConvert. }
function TJson.GetO(const aKey: string): TJson;
var
	path: string;
begin
	if (FValueType <> jvtObject) then
		raise EJsonConvert.Create('GetO: value is not an object.');

	if (TAVLTree<string, TJson>(FValue).Exists(aKey) = False) then
		raise EJsonItemNotFound.Create('Item not found.');

	Result := TAVLTree<string, TJson>(FValue).Items[aKey];
end;

{ Converts value of this Json to string. }
procedure TJson.SetToString(const aLength: integer);
begin
	Null;
	FValueType := jvtString;
	FValueSize := ((aLength * SizeOf(char)) + 1);
	FValue     := AllocMem(FValueSize);
end;

{ Converts value of this Json to integer. }
procedure TJson.SetToInteger;
begin
	if (FValueType = jvtInteger) then
		Exit;

	Null;
	FValueType := jvtInteger;
	FValueSize := SizeOf(int64);
	FValue     := GetMemory(FValueSize);
end;

{ Converts value of this Json to float. }
procedure TJson.SetToFloat;
begin
	if (FValueType = jvtFloat) then
		Exit;

	Null;
	FValueType := jvtFloat;
	FValueSize := SizeOf(double);
	FValue     := GetMemory(FValueSize);
end;

{ Converts value of this Json to bool. }
procedure TJson.SetToBool;
begin
	if (FValueType = jvtBool) then
		Exit;

	Null;
	FValueType := jvtBool;
	FValueSize := SizeOf(boolean);
	FValue     := GetMemory(FValueSize);
end;

{ Converts value of this Json to array. }
procedure TJson.SetToArray;
begin
	if (FValueType = jvtArray) then
		Exit;

	Null;
	FValueType           := jvtArray;
	FValueSize           := SizeOf(TList<TJson>);
	TList<TJson>(FValue) := TList<TJson>.Create(

		function: TJson
		begin
			Result := TJson.Create(Self);
		end,

		procedure(var aItem: TJson)
		begin
			aItem.Free;
		end,

		procedure(const aFromItem: TJson; var aToItem: TJson)
		begin
			aToItem.Assign(aFromItem);
		end,

		function(const aItemA, aItemB: TJson): integer
		begin
			if (aItemA.Name < aItemB.Name) then
				Result := - 1
			else if (aItemA.Name > aItemB.Name) then
				Result := + 1
			else
				Result := 0;
		end

	  );
end;

{ Converts value of this Json to object. }
procedure TJson.SetToObject;
begin
	if (FValueType = jvtObject) then
		Exit;

	Null;
	FValueType                      := jvtObject;
	FValueSize                      := SizeOf(TAVLTree<string, TJson>);
	TAVLTree<string, TJson>(FValue) := TAVLTree<string, TJson>.Create(

		function(const aKeyA, aKeyB: string): integer
		begin
			if (aKeyA < aKeyB) then
				Result := - 1
			else if (aKeyA > aKeyB) then
				Result := + 1
			else
				Result := 0;
		end,

		procedure(var aKey: string)
		begin
			aKey := '';
		end,

		procedure(var aVal: TJson)
		begin
			aVal.Free;
		end

	  );
end;

{ Converts value of this Json to string and sets its value. }
procedure TJson.SetS(const aValue: string);
begin
	SetToString(Length(aValue));
	Move(aValue[1], FValue^, FValueSize);
end;

{ Converts value of this Json to integer and sets its value. }
procedure TJson.SetI(const aValue: int64);
begin
	SetToInteger;
	PInt64(FValue)^ := aValue;
end;

{ Converts value of this Json to double and sets its value. }
procedure TJson.SetF(const aValue: double);
begin
	SetToFloat;
	pdouble(FValue)^ := aValue;
end;

{ Converts value of this Json to boolean and sets its value. }
procedure TJson.SetB(const aValue: boolean);
begin
	SetToBool;
	pboolean(FValue)^ := aValue;
end;

{ Converts value of this Json to array and sets its value. }
procedure TJson.SetA(const aIndex: integer; const aValue: TJson);
begin
	SetToArray;
	TList<TJson>(FValue)[aIndex].Assign(aValue);
end;

{ Converts value of this Json to object and sets its value. }
{ A complete path is created automatically if the target does not exist. }
procedure TJson.SetO(const aKey: string; const aValue: TJson);
begin
	SetToObject;
	TAVLTree<string, TJson>(FValue).Items[aKey].Assign(aValue);
end;

{ Renames this Json. }
procedure TJson.SetName(const aValue: string);
begin
	if (FOwner <> nil) then
		FOwner.Rename(FName, aValue);
	FName := aValue;
end;

{ Sets the Json to an object and adds a string value. }
procedure TJson.AddS(const aKey: string; const aVal: string);
var
	j: TJson;
begin
	SetToObject;
	j      := TJson.Create(Self);
	j.name := aKey;
	j.S    := aVal;
	TAVLTree<string, TJson>(FValue).Insert(aKey, j);
end;

{ Sets the Json to an object and adds a integer value. }
procedure TJson.AddI(const aKey: string; const aVal: integer);
var
	j: TJson;
begin
	SetToObject;
	j      := TJson.Create(Self);
	j.name := aKey;
	j.I    := aVal;
	TAVLTree<string, TJson>(FValue).Insert(aKey, j);
end;

{ Sets the Json to an object and adds a double value. }
procedure TJson.AddF(const aKey: string; const aVal: double);
var
	j: TJson;
begin
	SetToObject;
	j      := TJson.Create(Self);
	j.name := aKey;
	j.F    := aVal;
	TAVLTree<string, TJson>(FValue).Insert(aKey, j);
end;

{ Sets the Json to an object and adds a boolean value. }
procedure TJson.AddB(const aKey: string; const aVal: boolean);
var
	j: TJson;
begin
	SetToObject;
	j      := TJson.Create(Self);
	j.name := aKey;
	j.B    := aVal;
	TAVLTree<string, TJson>(FValue).Insert(aKey, j);
end;

{ Sets the Json to an object and adds a array value. }
procedure TJson.AddA(const aKey: string; const aVal: array of TJson);
var
	j: TJson;
	i: integer;
begin
	SetToObject;
	j     := TJson.Create(Self);
	for i := 0 to high(aVal) do
	begin
		j.A[i].Assign(aVal[i]);
		TAVLTree<string, TJson>(FValue).Insert(aKey, j);
	end;
end;

{ Sets the Json to an object and adds a object value. }
procedure TJson.AddO(const aKey: string; const aVal: TJson);
var
	j: TJson;
begin
	SetToObject;
	j := TJson.Create(Self);
	j.Assign(aVal);
	TAVLTree<string, TJson>(FValue).Insert(aKey, j);
end;

end.
