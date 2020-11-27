//
// EvilLibrary by Vedran Vuk 2010-2012
//
// Name: 					EvilWorks.DataStructures.AVLTree
// Description: 			An Generic AVL tree implementation.
//                          Largely a translation from C by Julienne Walker but implemented as a generic class
//                          with independant Key (Node key) and Val (Node data).
//                          http://eternallyconfuzzled.com/tuts/datastructures/jsw_tut_avl.aspx
// File last change date:   November 16th. 2012
// File version: 			Dev 0.0.0
// Licence:                 Free.
//

unit EvilWorks.Generics.AVLTree;

interface

uses
	System.SysUtils;

type
	{ Exceptions }
	EAVLTree             = class(Exception); // Base exception
	EAVLTreeItemNotFound = class(EAVLTree);  // Used in GetItem().

    { TAVLTree<TKey, TVal> }
    { A Generic balanced binary tree implementation. }
	TAVLTree<TKey, TVal> = class
	private const
		HEIGHT_LIMIT = 65536;
	public type
		TCompareFunc    = reference to function(const aKeyA, aKeyB: TKey): integer;
		TReleaseKeyProc = reference to procedure(var aKey: TKey);
		TReleaseValProc = reference to procedure(var aVal: TVal);
	private type

    	{ TAVLNode }
		PAVLNode = ^TAVLNode;

		TAVLNode = record
			Key: TKey;
			Val: TVal;
			Bal: integer;
			Lnk: array [boolean] of PAVLNode;
		end;

        { TTokensEnumerator }
		TAVLTreeEnumerator = class
		private
			FTree: TAVLTree<TKey, TVal>;
			FCurr: PAVLNode;
			FPath: array [0 .. HEIGHT_LIMIT] of PAVLNode;
			FTop : cardinal;
		public
			constructor Create(aTree: TAVLTree<TKey, TVal>);
			function GetCurrent: TVal; inline;
			function MoveNext: Boolean; inline;
			property Current: TVal read GetCurrent;
		end;

	private
		FRoot      : PAVLNode;
		FCount     : cardinal;
		FCompare   : TCompareFunc;
		FReleaseKey: TReleaseKeyProc;
		FReleaseVal: TReleaseValProc;
		function GetCount: integer;
		function GetItem(const aKey: TKey): TVal;
		procedure SetItem(const aKey: TKey; const aVal: TVal);
	protected
		procedure RotateSingle(var aRoot: PAVLNode; aDir: boolean);
		procedure RotateDouble(var aRoot: PAVLNode; aDir: boolean);
		procedure AdjustBalance(var aRoot: PAVLNode; aDir: boolean; aBalance: integer);
		procedure BalanceAfterInsert(var aRoot: PAVLNode; aDir: boolean);
		procedure BalanceAfterRemove(var aRoot: PAVLNode; aDir: boolean; var aDone: boolean);
		procedure RemoveNode(const aKey: TKey; const aFreeData: boolean; var aSaveKey: TKey; var aSaveVal: TVal);
		function Find(const aKey: TKey): PAVLNode;
	public
		constructor Create(const aCompare: TCompareFunc; const aReleaseKey: TReleaseKeyProc; const aReleaseVal: TReleaseValProc);
		destructor Destroy; override;
		procedure Assign(const aSource: TAVLTree<TKey, TVal>);

		function GetEnumerator: TAVLTreeEnumerator;

		procedure Insert(const aKey: TKey; const aVal: TVal);
		procedure Delete(const aKey: TKey);
		procedure ReKey(const aOldKey, aNewKey: TKey);
		procedure Clear;

		property Items[const aKey: TKey]: TVal read GetItem write SetItem; default;
		property Count: integer read GetCount;
		function Exists(const aKey: TKey): boolean;
	end;

implementation

{ ======================================= }
{ TAVLTree<TKey, TVal>.TAVLTreeEnumerator }
{ ======================================= }

{ Constructor. }
constructor TAVLTree<TKey, TVal>.TAVLTreeEnumerator.Create(aTree: TAVLTree<TKey, TVal>);
begin
	FTree := aTree;
	FCurr := nil;
	FTop  := 0;
end;

{ Gets curent item for the iterator. }
function TAVLTree<TKey, TVal>.TAVLTreeEnumerator.GetCurrent: TVal;
begin
	Result := FCurr^.Val;
end;

{ Advances to next item for the iterator. }
function TAVLTree<TKey, TVal>.TAVLTreeEnumerator.MoveNext: Boolean;
var
	last: PAVLNode;
begin
	if (FCurr = nil) then
	begin
		FCurr := FTree.FRoot;
		FTop  := 0;

        // build a path to work with
		if (FCurr <> nil) then
		begin
			while (FCurr^.Lnk[False] <> nil) do
			begin
				FPath[FTop] := FCurr;
				Inc(FTop);
				FCurr := FCurr^.Lnk[False];
			end;
		end;
	end
	else
	begin
		if (FCurr^.Lnk[True] <> nil) then
		begin
        	// continue down this branch
			FPath[FTop] := FCurr;
			Inc(FTop);
			FCurr := FCurr^.Lnk[True];

			while (FCurr^.Lnk[not True] <> nil) do
			begin
				FPath[FTop] := FCurr;
				Inc(FTop);
				FCurr := FCurr^.Lnk[not True];
			end;
		end
		else
		begin
    		// move to the next branch
			repeat
				if (FTop = 0) then
				begin
					FCurr := nil;
					Break;
				end;

				last := FCurr;
				Dec(FTop);
				FCurr := FPath[FTop];
			until (last <> FCurr^.Lnk[True]);
		end;
	end;
	Result := (FCurr <> nil);
end;

{ ==================== }
{ TAVLTree<TKey, TVal> }
{ ==================== }

{ Constructor. aCompare compares two TVal items, aReleaseKey disposes of TKey, aReleaseVal of TVal. }
constructor TAVLTree<TKey, TVal>.Create(const aCompare: TCompareFunc; const aReleaseKey: TReleaseKeyProc; const aReleaseVal: TReleaseValProc);
begin
	FRoot       := nil;
	FCompare    := aCompare;
	FReleaseKey := aReleaseKey;
	FReleaseVal := aReleaseVal;
	FCount      := 0
end;

{ Destructor. }
destructor TAVLTree<TKey, TVal>.Destroy;
begin
	Clear;
	inherited;
end;

{ Assign from an instance of the same type. }
procedure TAVLTree<TKey, TVal>.Assign(const aSource: TAVLTree<TKey, TVal>);
begin

end;

{ Implements GetEnumerator for for in iterator. }
function TAVLTree<TKey, TVal>.GetEnumerator: TAVLTreeEnumerator;
begin
	Result := TAVLTreeEnumerator.Create(Self);
end;

{ Performs a single rotation. }
procedure TAVLTree<TKey, TVal>.RotateSingle(var aRoot: PAVLNode; aDir: boolean);
var
	save: PAVLNode;
begin
	save                 := aRoot^.Lnk[not aDir];
	aRoot^.Lnk[not aDir] := save^.Lnk[aDir];
	save^.Lnk[aDir]      := aRoot;
	aRoot                := save;
end;

{ Performs a double rotation. }
procedure TAVLTree<TKey, TVal>.RotateDouble(var aRoot: PAVLNode; aDir: boolean);
var
	save: PAVLNode;
begin
	save                            := aRoot^.Lnk[not aDir]^.Lnk[aDir];
	aRoot^.Lnk[not aDir]^.Lnk[aDir] := save^.Lnk[not aDir];
	save^.Lnk[not aDir]             := aRoot^.Lnk[not aDir];
	aRoot^.Lnk[not aDir]            := save;
	save                            := aRoot^.Lnk[not aDir];
	aRoot^.Lnk[not aDir]            := save^.Lnk[aDir];
	save^.Lnk[aDir]                 := aRoot;
	aRoot                           := save;
end;

{ Balances the tree height. }
procedure TAVLTree<TKey, TVal>.AdjustBalance(var aRoot: PAVLNode; aDir: boolean; aBalance: integer);
var
	n, nn: PAVLNode;
begin
	n  := aRoot^.Lnk[aDir];
	nn := n^.Lnk[not aDir];
	if (nn^.Bal = 0) then
	begin
		aRoot^.Bal := 0;
		n^.Bal     := 0;
	end
	else if (nn^.Bal = aBalance) then
	begin
		aRoot^.Bal := - aBalance;
		n^.Bal     := 0;
	end
	else
	begin
		aRoot^.Bal := 0;
		n^.Bal     := aBalance;
	end;
	nn^.Bal := 0;
end;

{ Balances the tree height after insertion. }
procedure TAVLTree<TKey, TVal>.BalanceAfterInsert(var aRoot: PAVLNode; aDir: boolean);
var
	n  : PAVLNode;
	bal: integer;
begin
	n := aRoot^.Lnk[aDir];
	if (not aDir) then
		bal := - 1
	else
		bal := + 1;
	if (n^.Bal = bal) then
	begin
		aRoot^.Bal := 0;
		n^.Bal     := 0;
		RotateSingle(aRoot, not aDir);
	end
	else
	begin
		AdjustBalance(aRoot, aDir, bal);
		RotateDouble(aRoot, not aDir);
	end;
end;

{ Balances the tree height after deletion. }
procedure TAVLTree<TKey, TVal>.BalanceAfterRemove(var aRoot: PAVLNode; aDir: boolean; var aDone: boolean);
var
	n  : PAVLNode;
	bal: integer;
begin
	n := aRoot^.Lnk[not aDir];
	if (not aDir) then
		bal := - 1
	else
		bal := + 1;
	if (n^.Bal = - bal) then
	begin
		aRoot^.Bal := 0;
		n^.Bal     := 0;
		RotateSingle(aRoot, aDir);
	end
	else if (n^.Bal = bal) then
	begin
		AdjustBalance(aRoot, not aDir, - bal);
		RotateDouble(aRoot, aDir);
	end
	else
	begin
		aRoot^.Bal := - bal;
		n^.Bal     := bal;
		RotateSingle(aRoot, aDir);
		aDone := True;
	end;
end;

{ Internal function for removing a node. if aFreeData frees node, Key and Val, }
{ otherwise returns Key in aSaveKey and Val in aSaveVal then removes the node. }
procedure TAVLTree<TKey, TVal>.RemoveNode(const aKey: TKey; const aFreeData: boolean; var aSaveKey: TKey; var aSaveVal: TVal);
var
	it  : PAVLNode;
	heir: PAVLNode;
	save: TVal;
	up  : array [0 .. HEIGHT_LIMIT] of PAVLNode;
	upd : array [0 .. HEIGHT_LIMIT - 1] of boolean;
	top : integer;
	done: boolean;
	dir : boolean;
begin
	top  := 0;
	done := boolean(0);
	if (FRoot <> nil) then
	begin
		it := FRoot;

        // Search down the tree and save path
		while (True) do
		begin
			if (it = nil) then
				Exit
			else if (FCompare(it^.Key, aKey) = 0) then
				Break;

            // Push direction and node onto stack
			upd[top] := (FCompare(it^.Key, aKey) < 0);
			up[top]  := it;
			it       := it^.Lnk[upd[top]];
			Inc(top);
		end;

        // Remove the node
		if (it^.Lnk[False] = nil) or (it^.Lnk[True] = nil) then
		begin
            // Which child is not nil?
			dir := (it^.Lnk[False] = nil);

            // Fix parent
			if (top <> 0) then
				up[top - 1]^.Lnk[upd[top - 1]] := it^.Lnk[dir]
			else
				FRoot := it^.Lnk[dir];

			if (aFreeData) then
			begin
				FReleaseKey(it^.Key);
				FReleaseVal(it^.Val);
			end
			else
			begin
				aSaveKey := it^.Key;
				aSaveVal := it^.Val;
			end;
			FreeMem(it);
		end
		else
		begin
        	// Find the inorder successor
			heir := it^.Lnk[True];

            // Save this path too
			upd[top] := True;
			up[top]  := it;
			Inc(top);

			while (heir^.Lnk[False] <> nil) do
			begin
				upd[top] := False;
				up[top]  := heir;
				Inc(top);
				heir := heir^.Lnk[False];
			end;

            // Swap data
			save      := it^.Val;
			it^.Val   := heir^.Val;
			heir^.Val := save;

            // Unlink successor and fix parent
			up[top - 1]^.Lnk[(up[top - 1] = it)] := heir^.Lnk[True];

			if (aFreeData) then
			begin
				FReleaseKey(it^.Key);
				FReleaseVal(it^.Val);
			end
			else
			begin
				aSaveKey := it^.Key;
				aSaveVal := it^.Val;
			end;
			FreeMem(heir);
		end;

        // Walk back up the search path
		Dec(top);
		while (top >= 0) and (not done) do
		begin
            // Update balance factors
			if (upd[top]) then
				up[top]^.Bal := up[top]^.Bal - 1
			else
				up[top]^.Bal := up[top]^.Bal + 1;

            // Terminate or rebalance as neccesary
			if (Abs(up[top]^.Bal) = 1) then
				Break
			else if (Abs(up[top]^.Bal) > 1) then
			begin
				BalanceAfterRemove(up[top], upd[top], done);

                // Fix parent
				if (top <> 0) then
					up[top - 1]^.Lnk[upd[top - 1]] := up[top]
				else
					FRoot := up[0];
			end;
			Dec(top);
		end;
		Dec(FCount);
	end;
end;

{ Searches for a node keyed with aKey. }
function TAVLTree<TKey, TVal>.Find(const aKey: TKey): PAVLNode;
var
	it : PAVLNode;
	cmp: integer;
begin
	it := FRoot;

	while (it <> nil) do
	begin
		cmp := FCompare(it^.Key, aKey);
		if (cmp = 0) then
			Break;
		it := it^.Lnk[cmp < 0];
	end;
	Result := it;
end;

{ Inserts a new node keyed with aey with value aVal. }
procedure TAVLTree<TKey, TVal>.Insert(const aKey: TKey; const aVal: TVal);
var
	head      : TAVLNode;
	s, t, p, q: PAVLNode;
	dir       : boolean;
begin
	if (FRoot = nil) then
	begin
		FRoot := AllocMem(SizeOf(TAVLNode));
		if (FRoot = nil) then
			Exit;
		FRoot^.Key := aKey;
		FRoot^.Val := aVal;
	end
	else
	begin
    	// If node of aKey exists, update its Val and exit.
		s := Find(aKey);
		if (s <> nil) then
		begin
			s^.Val := aVal;
			Exit;
		end;

        // Set up false root to ease maintenance
		FillChar(head, SizeOf(head), 0);
		t            := @head;
		t^.Lnk[True] := FRoot;

        // Search down the tree, saving rebalance points
		s := t.Lnk[True];
		p := t.Lnk[True];
		while (True) do
		begin
			dir := (FCompare(p^.Key, aKey) < 0);
			q   := p^.Lnk[dir];

			if (q = nil) then
				Break;

			if (q^.Bal <> 0) then
			begin
				t := p;
				s := q;
			end;

			p := q;
		end;

		q           := AllocMem(SizeOf(TAVLNode));
		q^.Key      := aKey;
		q^.Val      := aVal;
		p^.Lnk[dir] := q;

		if (q = nil) then
			Exit;

        // Update balance factors
		p := s;
		while (p <> q) do
		begin
			dir := (FCompare(p^.Key, aKey) < 0);

			if (not dir) then
				p^.Bal := p^.Bal - 1
			else
				p^.Bal := p^.Bal + 1;

			p := p^.Lnk[dir];
		end;

		q := s; // Save rebalance point for parent fix

        // Rebalance if necessary
		if (Abs(s^.Bal) > 1) then
		begin
			dir := (FCompare(s^.Key, aKey) < 0);
			BalanceAfterInsert(s, dir);
		end;

        // Fix parent
		if (q = head.Lnk[True]) then
			FRoot := s
		else
			t^.Lnk[(q = t^.Lnk[True])] := s;
	end;
	Inc(FCount);
end;

{ Deletes a node keyed with aKey. }
procedure TAVLTree<TKey, TVal>.Delete(const aKey: TKey);
var
	tempKey: TKey;
	tempVal: TVal;
begin
	RemoveNode(aKey, True, tempKey, tempVal);
end;

{ Changes the Key of a node. }
procedure TAVLTree<TKey, TVal>.ReKey(const aOldKey, aNewKey: TKey);
var
	tempKey: TKey;
	tempVal: TVal;
begin
	RemoveNode(aOldKey, False, tempKey, tempVal);
	FReleaseKey(tempKey);
	Insert(aNewKey, tempVal);
end;

{ Clears the tree. Disposition methods called for every node. }
procedure TAVLTree<TKey, TVal>.Clear;
var
	it  : PAVLNode;
	save: PAVLNode;
begin
	it := FRoot;

    // Destruction by rotation
	while (it <> nil) do
	begin
		if (it^.Lnk[False] = nil) then
		begin
            // Remove node
			save := it^.Lnk[True];
			FReleaseKey(it^.Key);
			FReleaseVal(it^.Val);
			FreeMem(it);
		end
		else
		begin
            // Rotate right
			save            := it^.Lnk[False];
			it^.Lnk[False]  := save^.Lnk[True];
			save^.Lnk[True] := it;
		end;
		it := save;
	end;
	FRoot  := nil;
	FCount := 0;
end;

{ Checks if a node keyed with aKey exists. }
function TAVLTree<TKey, TVal>.Exists(const aKey: TKey): boolean;
begin
	Result := (Find(aKey) <> nil);
end;

{ Returns the count of tree nodes. }
function TAVLTree<TKey, TVal>.GetCount: integer;
begin
	Result := integer(FCount);
end;

{ Item getter. If not found raises EAVLTreeItemNotFound. }
function TAVLTree<TKey, TVal>.GetItem(const aKey: TKey): TVal;
var
	node: PAVLNode;
begin
	node := Find(aKey);
	if (node = nil) then
		raise EAVLTreeItemNotFound.Create('Item not found.');

	Result := node^.Val;
end;

{ Item setter. If not found inserts new item. }
procedure TAVLTree<TKey, TVal>.SetItem(const aKey: TKey; const aVal: TVal);
var
	node: PAVLNode;
begin
	node := Find(aKey);
	if (node <> nil) then
		node^.Val := aVal
	else
		Insert(aKey, aVal);
end;

end.
