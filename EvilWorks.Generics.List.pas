//
// EvilLibrary by Vedran Vuk 2010-2012
//
// Name: 					EvilWorks.DataStructures.AVLTree
// Description: 			A Generic list implementation.
// File last change date:   November 17th. 2012
// File version: 			Dev 0.0.0
// Licence:                 Free.
//

unit EvilWorks.Generics.List;

interface

uses
	System.SysUtils;

type
	EList                 = class(Exception);
	EListIndexOutOfBounds = class(EList);

	{ TList<T> }
    { A Generic list. }
	TList<T> = class
	public type
		TCreateFunc  = reference to function: T;
		TDestroyProc = reference to procedure(var aItem: T);
		TAssignProc  = reference to procedure(const aFromItem: T; var aToItem: T);
		TCompareFunc = reference to function(const aItemA, aItemB: T): integer;
    private type

        { TListEnumerator }
        TListEnumerator = class
        private
            FIndex : integer;
            FList: TList<T>;
        public
            constructor Create(aList: TList<T>);
            function GetCurrent: T; inline;
            function MoveNext: Boolean; inline;
            property Current: T read GetCurrent;
        end;

	private
		FItems  : array of T;
		FCount  : integer;
		FSorted : boolean;
		FCreate : TCreateFunc;
		FCompare: TCompareFunc;
		FAssign : TAssignProc;
		FDestroy: TDestroyProc;
		function GetT(const aIndex: integer): T;
		procedure SetT(const aIndex: integer; const Value: T);
	protected
		procedure QuickSort(const aStart, aEnd: integer);
	public
		constructor Create(const aCreate: TCreateFunc; const aDestroy: TDestroyProc; const aAssign: TAssignProc; const aCompare: TCompareFunc);
		destructor Destroy; override;
		procedure Assign(const aSource: TList<T>);
		function GetEnumerator: TListEnumerator;

		function Add: T; overload;
		function Add(const aItem: T): T; overload;
		function AddSorted: T; overload;
		function AddSorted(const aItem: T): T; overload;
		function Insert(const aIndex: integer): T; overload;
		function Insert(const aIndex: integer; const aItem: T): T; overload;
		procedure Exchange(const aIndexA, aIndexB: integer);
		procedure Delete(const aIndex: integer);
		procedure Clear;

		procedure Sort;
		function IndexOf(const aVal: T): integer;

		property Items[const aIndex: integer]: T read GetT write SetT; default;
		property Count: integer read FCount;
		property Sorted: boolean read FSorted;
	end;

implementation

{ ======================== }
{ TList<T>.TListEnumerator }
{ ======================== }

{ Constructor. }
constructor TList<T>.TListEnumerator.Create(aList: TList<T>);
begin
	inherited Create;
	FIndex  := - 1;
	FList := aList;
end;

{ Gets curent item for the iterator. }
function TList<T>.TListEnumerator.GetCurrent: T;
begin
	Result := FList[FIndex];
end;

{ Advances to next item for the iterator. }
function TList<T>.TListEnumerator.MoveNext: Boolean;
begin
	Result := (FIndex < FList.Count - 1);
	if Result then
		Inc(FIndex);
end;

{ ======== }
{ TList<T> }
{ ======== }

{ Constructor. }
constructor TList<T>.Create(const aCreate: TCreateFunc; const aDestroy: TDestroyProc; const aAssign: TAssignProc; const aCompare: TCompareFunc);
begin
	FCount   := 0;
	FSorted  := False;
	FCreate  := aCreate;
	FDestroy := aDestroy;
	FAssign  := aAssign;
	FCompare := aCompare;
end;

{ Destructor. }
destructor TList<T>.Destroy;
begin
	Clear;
	inherited;
end;

{ Assign from an instance of the same type. }
procedure TList<T>.Assign(const aSource: TList<T>);
var
	i: integer;
	c: T;
begin
	Clear;
	for i := 0 to aSource.Count - 1 do
	begin
		c := Add;
		FAssign(aSource[i], c);
	end;
end;

{ Implements GetEnumerator. }
function TList<T>.GetEnumerator: TListEnumerator;
begin
	Result := TListEnumerator.Create(Self);
end;

{ Add a new item to the list. Uses aCreate function from constructor to create a new item. }
function TList<T>.Add: T;
begin
	Result := Add(FCreate);
end;

{ Add aItem to the list. }
function TList<T>.Add(const aItem: T): T;
begin
	Result := Insert(FCount, aItem);
end;

{ Add a new item to the list, sort if not already sorted. Adding is done using partitioning, fast. }
{ Uses aCreate function from constructor to create a new item. }
function TList<T>.AddSorted: T;
begin
	Result := AddSorted(FCreate);
end;

{ Add aItem to the list, sort if not already sorted. Adding is done using partitioning, fast. }
function TList<T>.AddSorted(const aItem: T): T;
var
	loIdx, hiIdx, i: integer;
begin
	Sort;

	if (FCount <> 0) then
	begin
		loIdx := 0;
		hiIdx := FCount;
		while (loIdx < hiIdx) do
		begin
			i := ((loIdx + hiIdx) shr 1);
			if (FCompare(aItem, FItems[i]) = - 1) then
				hiIdx := i
			else
				loIdx := i + 1;
		end;
		i := loIdx;
	end
	else
		i := 0;

	Insert(i, aItem);
    // Insert unmarks FSorted, but the insert index is found using
    // bisection and is 'sorted', so just re-mark as sorted.
	FSorted := True;
end;

{ Add a new item to the list at aIndex. Uses aCreate function from constructor to create a new item. }
{ If the list is sorted, Sorted state is broken and needs to be sorted again. }
function TList<T>.Insert(const aIndex: integer): T;
begin
	Result := Insert(FCount, FCreate);
end;

{ Add aItem to the list at aIndex. }
{ If the list was sorted, Sorted state is broken and needs to be sorted again. }
function TList<T>.Insert(const aIndex: integer; const aItem: T): T;
begin
	if (aIndex < 0) or (aIndex > FCount) then
		raise EArgumentOutOfRangeException.Create(Format('Index %d out of bounds %d.', [aIndex, FCount]));

	SetLength(FItems, FCount + 1);
	if (aIndex < FCount) then
		System.Move(FItems[aIndex], FItems[aIndex + 1], (FCount - aIndex) * SizeOf(T));
	FItems[aIndex] := aItem;
	Inc(FCount);
	FSorted := False;
end;

{ Exchange position of items at aIndexA and aIndexB. }
{ If the list was sorted, Sorted state is broken and needs to be sorted again. }
procedure TList<T>.Exchange(const aIndexA, aIndexB: integer);
var
	temp: T;
begin
	temp            := FItems[aIndexB];
	FItems[aIndexB] := FItems[aIndexA];
	FItems[aIndexA] := temp;
	FSorted         := False;
end;

{ Delete an item from the list at aIndex. Uses aDestroy from constructor to free the item. }
procedure TList<T>.Delete(const aIndex: integer);
begin
	if (aIndex < 0) or (aIndex > FCount) then
		raise EArgumentOutOfRangeException.Create(Format('Index %d out of bounds %d.', [aIndex, FCount]));

	FDestroy(FItems[aIndex]);
	Dec(FCount);
	if (aIndex < FCount) then
		System.Move(FItems[aIndex + 1], FItems[aIndex], (FCount - aIndex) * SizeOf(T));
end;

{ Clear the list. Uses aDestroy from constructor to free each item. }
procedure TList<T>.Clear;
var
	i: integer;
begin
	for i := 0 to FCount - 1 do
		FDestroy(FItems[i]);
	SetLength(FItems, 0);
	FCount := 0;
end;

{ Internal QuickSort function. Uses aCompare function from constructor to compare items when sorting. }
procedure TList<T>.QuickSort(const aStart, aEnd: integer);
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
			while (FCompare(FItems[i], FItems[p]) < 0) do
				Inc(i);
			while (FCompare(FItems[j], FItems[p]) > 0) do
				Dec(j);
			if (i <= j) then
			begin
				if (i <> j) then
					Exchange(i, j);
				if (p = i) then
					p := j
				else if (p = j) then
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

{ Sort the list. }
procedure TList<T>.Sort;
begin
	if (FSorted) then
		Exit;

	QuickSort(0, FCount - 1);
	FSorted := True;
end;

{ Find the index of aVal. }
function TList<T>.IndexOf(const aVal: T): integer;
var
	loIdx, hiIdx, cnt, i: integer;
begin
	Result := - 1;
	if (FSorted) then
	begin
		loIdx := 0;
		hiIdx := (FCount - 1);
		while (loIdx <= hiIdx) do
		begin
			cnt := ((loIdx + hiIdx) shr 1);
			i   := FCompare(FItems[cnt], aVal);
			if (i < 0) then
				loIdx := (cnt + 1)
			else
			begin
				hiIdx := (cnt - 1);
				if (i = 0) then
					Exit(loIdx);
			end;
		end;
	end
	else
	begin
		for i := 0 to FCount - 1 do
			if (FCompare(FItems[i], aVal) = 0) then
				Exit(i);
	end;
end;

{ Items getter. }
function TList<T>.GetT(const aIndex: integer): T;
begin
	if (aIndex < 0) or (aIndex >= FCount) then
		raise EListIndexOutOfBounds.Create(Format('Index %d out of bounds %d.', [aIndex, FCount]));

	Result := FItems[aIndex];
end;

{ Items setter. }
procedure TList<T>.SetT(const aIndex: integer; const Value: T);
begin
	if (aIndex < 0) or (aIndex >= FCount) then
		raise EListIndexOutOfBounds.Create(Format('Index %d out of bounds %d.', [aIndex, FCount]));

	FAssign(Value, FItems[aIndex]);
end;

end.
