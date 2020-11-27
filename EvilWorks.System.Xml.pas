(*============================================================================================================

 EvilLibrary by Vedran Vuk 2010-2012

 Name: 					EvilWorks.Xml
 Description: 			Barebones Xml class. Don't expect it to follow standards. It parses XML, ok.
 File last change date: August 11th. 2012
 File version: 			0.0.1
 Licence:				Free as in beer.

 ===========================================================================================================*)

unit EvilWorks.System.Xml;

interface

uses
	System.Classes,
	System.SysUtils,
	EvilWorks.System.StrUtils;

const
	SAttributeNotFound       = 'Attribute "%s" not found.';
	SNodeNotFound            = 'Node "%s" not found.';
	SMalformedXml            = 'Malformed XML on line %d.';
	SCantHaveTextAndChildren = 'Node cannot have text and child nodes.';

type
	{ Exceptions }
	EXml               = class(Exception);
	EMalformedXml      = class(EXml);
	EAttributeNotFound = class(EXml);
	ENodeNotFound      = class(EXml);

	{ Forward declarations }
	TXmlAttribute  = class;
	TXmlAttributes = class;
	TXmlNode       = class;
	TXmlNodes      = class;
	TXml           = class;

	{ TXmlAttribute }
	TXmlAttribute = class(TPersistent)
	private
		FOwner: TXmlAttributes;

		FName : string;
		FValue: string;
		procedure SetName(const aValue: string);
		procedure SetValue(const aValue: string);
	public
		constructor Create(aOwner: TXmlAttributes); virtual;
		procedure Assign(aSource: TPersistent); override;

		property Owner: TXmlAttributes read FOwner;

		property name: string read FName write SetName;
		property Value: string read FValue write SetValue;
	end;

	{ TXmlAttributes }
	TXmlAttributes = class(TPersistent)
	private
		FOwner: TXmlNode;

		FList: TList;
		function GetCount: integer;
		function GetByIndex(const aIndex: integer): TXmlAttribute;
		function GetByName(const aName: string): TXmlAttribute;
		procedure SetByName(const aName: string; const aValue: TXmlAttribute);
		procedure SetByIndex(const aIndex: integer; const aValue: TXmlAttribute);
	protected
		function Add: TXmlAttribute; overload;
	public
		constructor Create(aOwner: TXmlNode); virtual;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;

		property Owner: TXmlNode read FOwner;

		procedure Add(const aName, aValue: string); overload;
		procedure Insert(const aName, aValue: string; const aIndex: integer);
		procedure Delete(const aName: string); overload;
		procedure Delete(const aIndex: integer); overload;
		procedure Clear;
		procedure Exchange(const aIndexA, aIndexB: integer);
		procedure Move(const aFromIdx, aToIdx: integer);
		function First: TXmlAttribute;
		function Last: TXmlAttribute;
		function Find(const aName: string): TXmlAttribute;
		function IndexOf(const aName: string): integer; overload;
		function IndexOf(aAttribute: TXmlAttribute): integer; overload;
		function AttributeExists(const aName: string): boolean;

		property Attributes[const aName: string]: TXmlAttribute read GetByName write SetByName;
		property Items[const aIndex: integer]: TXmlAttribute read GetByIndex write SetByIndex; default;
		property Count: integer read GetCount;
	end;

	{ TXmlNode }
	TXmlNode = class(TPersistent)
	private
		FOwner: TXmlNodes;

		FText      : string;
		FAttributes: TXmlAttributes;
		FName      : string;
		FNodes     : TXmlNodes;
		procedure SetText(const aValue: string);
		procedure SetAttributes(const aValue: TXmlAttributes);
		procedure SetName(const aValue: string);
		procedure SetNodes(const aValue: TXmlNodes);
	public
		constructor Create(aOwner: TXmlNodes); virtual;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;

		property Owner: TXmlNodes read FOwner;
	published
		property Attributes: TXmlAttributes read FAttributes write SetAttributes;
		property Nodes     : TXmlNodes read FNodes write SetNodes;
		property name      : string read FName write SetName;
		property Text      : string read FText write SetText;
	end;

	{ TXmlNodes }
	TXmlNodes = class(TPersistent)
	private
		FOwner: TXmlNode;

		FList: TList;
		function GetByIndex(const aIndex: integer): TXmlNode;
		function GetByName(const aName: string): TXmlNode;
		function GetCount: integer;
		procedure SetByIndex(const aIndex: integer; const aValue: TXmlNode);
		procedure SetByName(const aName: string; const aValue: TXmlNode);
	protected
		function Add: TXmlNode; overload;
	public
		constructor Create(aOwner: TXmlNode); virtual;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;

		property Owner: TXmlNode read FOwner;

		function Add(const aName: string; aText: string = CEmpty): TXmlNode; overload;
		function Insert(const aName, aText: string; const aIndex: integer): TXmlNode;
		procedure Delete(const aName: string); overload;
		procedure Delete(const aIndex: integer); overload;
		procedure Clear;
		procedure Exchange(const aIndexA, aIndexB: integer);
		procedure Move(const aFromIdx, aToIdx: integer);
		function First: TXmlNode;
		function Last: TXmlNode;
		function Find(const aName: string): TXmlNode;
		function IndexOf(const aName: string): integer; overload;
		function IndexOf(aNode: TXmlNode): integer; overload;
		function NodeExists(const aName: string): boolean;

		property Nodes[const aName: string]: TXmlNode read GetByName write SetByName;
		property Items[const aIndex: integer]: TXmlNode read GetByIndex write SetByIndex; default;
		property Count: integer read GetCount;
	end;

	{ TXmlHeader }
	TXmlHeader = class(TPersistent)
	private
		FAttributes: TXmlAttributes;
		procedure SetAttributes(const aValue: TXmlAttributes);
	public
		constructor Create; virtual;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;

		property Attributes: TXmlAttributes read FAttributes write SetAttributes;
	end;

	{ TXml }
	TXml = class(TPersistent)
	private
		FHeader      : TXmlHeader;
		FRoot        : TXmlNode;
		FIndentString: string;
		procedure SetRoot(const aValue: TXmlNode);
		procedure SetIndentString(const aValue: string);
		procedure SetHeader(const aValue: TXmlHeader);
	protected
		procedure Malformed(const aLine: integer);
		procedure Parse(aReader: TStreamReader);
		procedure Serialize(aWriter: TStreamWriter);
	public
		constructor Create; virtual;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;

		procedure Clear;

		procedure LoadFromFile(const aFileName: string);
		procedure LoadFromStream(aStream: TStream);
		procedure SaveToFile(const aFileName: string);
		procedure SaveToStream(aStream: TStream);

		property Header: TXmlHeader read FHeader write SetHeader;
		property Root: TXmlNode read FRoot write SetRoot;
		property IndentString: string read FIndentString write SetIndentString;
	end;

implementation

{ TXmlAttribute }

constructor TXmlAttribute.Create(aOwner: TXmlAttributes);
begin
	FOwner := aOwner;
end;

procedure TXmlAttribute.Assign(aSource: TPersistent);
begin
	if (aSource is TXmlAttribute) then
	begin
		name  := TXmlAttribute(aSource).name;
		Value := TXmlAttribute(aSource).Value;
	end;
end;

procedure TXmlAttribute.SetName(const aValue: string);
begin
	if (FName = aValue) then
		Exit;
	FName := aValue;
end;

procedure TXmlAttribute.SetValue(const aValue: string);
begin
	if (FValue = aValue) then
		Exit;
	FValue := aValue;
end;

{ TXmlAttributes }

constructor TXmlAttributes.Create(aOwner: TXmlNode);
begin
	FOwner := aOwner;

	FList := TList.Create;
end;

destructor TXmlAttributes.Destroy;
begin
	Clear;
	FList.Free;
	inherited;
end;

procedure TXmlAttributes.Assign(aSource: TPersistent);
var
	i: integer;
begin
	if (aSource is TXmlAttributes) then
	begin
		Self.Clear;
		for i := 0 to TXmlAttributes(aSource).Count - 1 do
			Self.Add.Assign(TXmlAttributes(aSource).Items[i]);
	end;
end;

function TXmlAttributes.Add: TXmlAttribute;
begin
	Result := TXmlAttribute.Create(Self);
	FList.Add(Result);
end;

procedure TXmlAttributes.Add(const aName, aValue: string);
begin
	Insert(aName, aValue, FList.Count);
end;

procedure TXmlAttributes.Insert(const aName, aValue: string; const aIndex: integer);
var
	attr: TXmlAttribute;
begin
	attr       := TXmlAttribute.Create(Self);
	attr.name  := aName;
	attr.Value := aValue;
	FList.Insert(aIndex, attr);
end;

procedure TXmlAttributes.Delete(const aName: string);
var
	i: integer;
begin
	i := IndexOf(aName);
	if (i = - 1) then
		raise EAttributeNotFound.CreateFmt(SAttributeNotFound, [aName]);

	TXmlAttribute(FList[i]).Free;
	FList.Delete(i);
end;

procedure TXmlAttributes.Delete(const aIndex: integer);
begin
	TXmlAttribute(FList[aIndex]).Free;
	FList.Delete(aIndex);
end;

procedure TXmlAttributes.Clear;
var
	i: integer;
begin
	for i := FList.Count - 1 downto 0 do
	begin
		TXmlAttribute(FList[i]).Free;
		FList.Delete(i);
	end;
end;

procedure TXmlAttributes.Exchange(const aIndexA, aIndexB: integer);
begin
	FList.Exchange(aIndexA, aIndexB);
end;

procedure TXmlAttributes.Move(const aFromIdx, aToIdx: integer);
begin
	FList.Move(aFromIdx, aToIdx);
end;

function TXmlAttributes.Find(const aName: string): TXmlAttribute;
var
	i: integer;
begin
	Result := nil;

	for i := 0 to FList.Count - 1 do
		if (SameText(TXmlAttribute(FList[i]).name, aName)) then
			Exit(TXmlAttribute(FList[i]));
end;

function TXmlAttributes.IndexOf(const aName: string): integer;
var
	i: integer;
begin
	Result := - 1;

	for i := 0 to FList.Count - 1 do
		if (SameText(TXmlAttribute(FList[i]).name, aName)) then
			Exit(i);
end;

function TXmlAttributes.AttributeExists(const aName: string): boolean;
begin
	Result := (IndexOf(aName) > - 1);
end;

function TXmlAttributes.IndexOf(aAttribute: TXmlAttribute): integer;
var
	i: integer;
begin
	Result := - 1;

	for i := 0 to FList.Count - 1 do
		if (TXmlAttribute(FList[i]) = aAttribute) then
			Exit(i);
end;

function TXmlAttributes.First: TXmlAttribute;
begin
	if (FList.Count = 0) then
		Exit(nil);

	Result := TXmlAttribute(FList[0]);
end;

function TXmlAttributes.Last: TXmlAttribute;
begin
	if (FList.Count = 0) then
		Exit(nil);

	Result := TXmlAttribute(FList[FList.Count - 1]);
end;

function TXmlAttributes.GetCount: integer;
begin
	Result := FList.Count;
end;

function TXmlAttributes.GetByIndex(const aIndex: integer): TXmlAttribute;
begin
	Result := TXmlAttribute(FList[aIndex]);
end;

function TXmlAttributes.GetByName(const aName: string): TXmlAttribute;
begin
	Result := Find(aName);
end;

procedure TXmlAttributes.SetByIndex(const aIndex: integer; const aValue: TXmlAttribute);
begin
	TXmlAttribute(FList[aIndex]).Assign(aValue);
end;

procedure TXmlAttributes.SetByName(const aName: string; const aValue: TXmlAttribute);
var
	attr: TXmlAttribute;
begin
	attr := Find(aName);
	if (attr = nil) then
		raise EAttributeNotFound.CreateFmt(SAttributeNotFound, [aName]);
	attr.Assign(aValue);
end;

{ TXmlNode }

constructor TXmlNode.Create(aOwner: TXmlNodes);
begin
	FOwner := aOwner;

	FAttributes := TXmlAttributes.Create(Self);
	FNodes      := TXmlNodes.Create(Self);
end;

destructor TXmlNode.Destroy;
begin
	FNodes.Free;
	FAttributes.Free;
	inherited;
end;

procedure TXmlNode.Assign(aSource: TPersistent);
begin
	if (aSource is TXmlNode) then
	begin
		name := TXmlNode(aSource).name;
		Text := TXmlNode(aSource).Text;
		Attributes.Assign(TXmlNode(aSource).Attributes);
		Nodes.Assign(TXmlNode(aSource).Nodes);
	end;
end;

procedure TXmlNode.SetAttributes(const aValue: TXmlAttributes);
begin
	FAttributes.Assign(aValue);
end;

procedure TXmlNode.SetName(const aValue: string);
begin
	if (FName = aValue) then
		Exit;
	FName := aValue;
end;

procedure TXmlNode.SetNodes(const aValue: TXmlNodes);
begin
	FNodes.Assign(aValue);
end;

procedure TXmlNode.SetText(const aValue: string);
begin
	if (FText = aValue) then
		Exit;
	FText := aValue;
end;

{ TXmlNodes }

constructor TXmlNodes.Create(aOwner: TXmlNode);
begin
	FOwner := aOwner;

	FList := TList.Create;
end;

destructor TXmlNodes.Destroy;
begin
	Clear;
	FList.Free;
	inherited;
end;

procedure TXmlNodes.Assign(aSource: TPersistent);
var
	i: integer;
begin
	if (aSource is TXmlNodes) then
	begin
		Self.Clear;
		for i := 0 to TXmlNodes(aSource).Count - 1 do
			Self.Add.Assign(TXmlNodes(aSource).Items[i]);
	end;
end;

function TXmlNodes.Add: TXmlNode;
begin
	Result := TXmlNode.Create(Self);
	FList.Add(Result);
end;

function TXmlNodes.Add(const aName: string; aText: string): TXmlNode;
begin
	Result := Insert(aName, aText, FList.Count);
end;

function TXmlNodes.Insert(const aName, aText: string; const aIndex: integer): TXmlNode;
begin
	Result      := TXmlNode.Create(Self);
	Result.name := aName;
	Result.Text := aText;
	FList.Insert(aIndex, Result);
end;

procedure TXmlNodes.Delete(const aName: string);
var
	i: integer;
begin
	i := IndexOf(aName);
	if (i = - 1) then
		raise ENodeNotFound.CreateFmt(SNodeNotFound, [aName]);

	TXmlNode(FList[i]).Free;
	FList.Delete(i);
end;

procedure TXmlNodes.Delete(const aIndex: integer);
begin
	TXmlNode(FList[aIndex]).Free;
	FList.Delete(aIndex);
end;

procedure TXmlNodes.Clear;
var
	i: integer;
begin
	for i := FList.Count - 1 downto 0 do
	begin
		TXmlNode(FList[i]).Free;
		FList.Delete(i);
	end;
end;

procedure TXmlNodes.Exchange(const aIndexA, aIndexB: integer);
begin
	FList.Exchange(aIndexA, aIndexB);
end;

procedure TXmlNodes.Move(const aFromIdx, aToIdx: integer);
begin
	FList.Move(aFromIdx, aToIdx);
end;

function TXmlNodes.Find(const aName: string): TXmlNode;
var
	i: integer;
begin
	Result := nil;

	for i := 0 to FList.Count - 1 do
		if (SameText(TXmlNode(FList[i]).name, aName)) then
			Exit(TXmlNode(FList[i]));
end;

function TXmlNodes.IndexOf(const aName: string): integer;
var
	i: integer;
begin
	Result := - 1;

	for i := 0 to FList.Count - 1 do
		if (SameText(TXmlNode(FList[i]).name, aName)) then
			Exit(i);
end;

function TXmlNodes.IndexOf(aNode: TXmlNode): integer;
var
	i: integer;
begin
	Result := - 1;

	for i := 0 to FList.Count - 1 do
		if (TXmlNode(FList[i]) = aNode) then
			Exit(i);
end;

function TXmlNodes.NodeExists(const aName: string): boolean;
begin
	Result := (IndexOf(aName) <> - 1);
end;

function TXmlNodes.First: TXmlNode;
begin
	if (FList.Count = 0) then
		Exit(nil);

	Result := TXmlNode(FList[0]);
end;

function TXmlNodes.Last: TXmlNode;
begin
	if (FList.Count = 0) then
		Exit(nil);

	Result := TXmlNode(FList[FList.Count - 1]);
end;

function TXmlNodes.GetCount: integer;
begin
	Result := FList.Count;
end;

function TXmlNodes.GetByIndex(const aIndex: integer): TXmlNode;
begin
	Result := TXmlNode(FList[aIndex]);
end;

function TXmlNodes.GetByName(const aName: string): TXmlNode;
begin
	Result := Find(aName);
end;

procedure TXmlNodes.SetByIndex(const aIndex: integer; const aValue: TXmlNode);
begin
	TXmlNode(FList[aIndex]).Assign(aValue);
end;

procedure TXmlNodes.SetByName(const aName: string; const aValue: TXmlNode);
var
	node: TXmlNode;
begin
	node := Find(aName);
	if (node = nil) then
		raise ENodeNotFound.CreateFmt(SNodeNotFound, [aName]);
	node.Assign(aValue);
end;

{ TXmlHeader }

constructor TXmlHeader.Create;
begin
	FAttributes := TXmlAttributes.Create(nil);
end;

destructor TXmlHeader.Destroy;
begin
	FAttributes.Free;
	inherited;
end;

procedure TXmlHeader.Assign(aSource: TPersistent);
begin
	if (aSource is TXmlHeader) then
	begin
		Attributes.Assign(TXmlHeader(aSource).Attributes);
	end;
end;

procedure TXmlHeader.SetAttributes(const aValue: TXmlAttributes);
begin
	FAttributes.Assign(aValue);
end;

{ TXml }

constructor TXml.Create;
begin
	FHeader       := TXmlHeader.Create;
	FRoot         := TXmlNode.Create(nil);
	FIndentString := #9;
end;

destructor TXml.Destroy;
begin
	FRoot.Free;
	FHeader.Free;
	inherited;
end;

procedure TXml.Assign(aSource: TPersistent);
begin
	if (aSource is TXml) then
	begin
		Header.Assign(TXml(aSource).Header);
		Root.Assign(TXml(aSource).Root);
		IndentString := TXml(aSource).IndentString;
	end;
end;

procedure TXml.Clear;
begin
	Root.Nodes.Clear;
	Root.Attributes.Clear;
	Root.name := '';
	Root.Text := '';
end;

procedure TXml.Malformed(const aLine: integer);
begin
	Clear;
	raise EMalformedXml.CreateFmt(SMalformedXml, [aLine]);
end;

procedure TXml.Parse(aReader: TStreamReader);
var
	lineIdx: integer;

	procedure ParseAttributes(const aText: string; aAttributes: TXmlAttributes);
	var
		tokens: TArray<string>;
		token : string;
		key   : string;
		Value : string;
	begin
		// Split into an array of attribute="value" tokens.
		tokens := TextSplit(aText, CSpace, CDoubleQuote, [soCSSep, soCSQot, soQuoted]);
		for token in tokens do
		begin
			// Skip Node name.
			if (TextPos(token, CEquals, True) = 0) then
				Continue;

			key   := Trim(TextFetchLeft(token, CEquals, True));
			Value := Trim(TextFetchRight(token, CEquals, True));
			if (key = EmptyStr) then
				Malformed(lineIdx);
			if (TextEnclosed(Value, CDoubleQuote, True) = False) then
				Malformed(lineIdx);
			aAttributes.Add(key, TextUnquote(Value));
		end;
	end;

var
	lineStr     : string;
	lineElements: TArray<string>;
	lineElement : string;
	tempInt     : integer;
	tempStr     : string;
	currNode    : TXmlNode;
	tempNode    : TXmlNode;

	headerExpected  : boolean;
	nodeTextExpected: boolean;
	inComment       : boolean;
	inText          : boolean;
begin
	Clear;
	lineIdx  := 0;
	currNode := FRoot;

	headerExpected   := True;
	nodeTextExpected := False;
	inComment        := False;
	inText           := False;

	while (aReader.EndOfStream = False) do
	begin
		lineStr := Trim(aReader.ReadLine);
		Inc(lineIdx);

		// Check for multi line comment end, and remove it from lineStr.
		if (inComment) then
		begin
			tempInt := TextPos(lineStr, '-->', True);
			if (tempInt <> 0) then
			begin
				lineStr   := TextCopy(lineStr, tempInt + 3, MaxInt);
				inComment := False;
				if (lineStr = CEmpty) then
					Continue;
			end
			else
				Continue;
		end;

		// If there are multiple tags/texts/comments on a lineStr, split it.
		lineElements := TextSplitMarkup(lineStr);
		for lineElement in lineElements do
		begin
			if (TextEnclosed(lineElement, '<', '>', True)) then
			begin
				tempStr := TextUnEnclose(lineElement, '<', '>', True);

				// Check if its a header.
				if (TextEnclosed(tempStr, '?xml', '?')) then
				begin
					if (headerExpected = False) then
						Malformed(lineIdx);

					if (inText) then
						Malformed(lineIdx);

					ParseAttributes(TextUnEnclose(tempStr, '?xml', '?'), FHeader.Attributes);
					headerExpected := False;
				end

				// Check if its a comment.
				else if (TextEnclosed(tempStr, '!--', '--')) then
				begin
					{ Skip, we wont load comments. }
					Continue;
				end

				// Check if its self ending tag.
				else if (TextEnds(tempStr, '/', True)) then
				begin
					tempNode := currNode.Nodes.Add(TextFetchLeft(tempStr, CSpace, True), CEmpty);
					if (tempNode.name = CEmpty) then
						Malformed(lineIdx);
					if (inText) then
						Malformed(lineIdx);
					ParseAttributes(TextUnEnclose(tempStr, '', '/', True), tempNode.Attributes);
				end

				// Closing tag
				else if (TextBegins(tempStr, '/', True)) then
				begin
					if (currNode <> FRoot) then
						currNode := currNode.Owner.Owner;
					if (currNode = nil) then
						Malformed(lineIdx);
					inText           := False;
					nodeTextExpected := False;
				end

				// Should be an opening tag.
				else
				begin
					if (inText) then
						Malformed(lineIdx);

					if (TextPos(tempStr, CSpace, True) <> 0) then
					begin
						if (currNode = FRoot) and (currNode.name = EmptyStr) then
						begin
							FRoot.name := TextFetchLeft(tempStr, CSpace, True);
							if (FRoot.name = EmptyStr) then
								Malformed(lineIdx);
							ParseAttributes(tempStr, FRoot.Attributes);
						end
						else
						begin
							currNode := currNode.Nodes.Add(TextFetchLeft(tempStr, CSpace, True), CEmpty);
							if (currNode.name = CEmpty) then
								Malformed(lineIdx);
							ParseAttributes(tempStr, currNode.Attributes);
						end;
					end
					else
					begin
						if (currNode = FRoot) and (currNode.name = EmptyStr) then
						begin
							FRoot.name := tempStr;
							if (FRoot.name = EmptyStr) then
								Malformed(lineIdx);
						end
						else
						begin
							currNode := currNode.Nodes.Add(tempStr, CEmpty);
							if (currNode.name = CEmpty) then
								Malformed(lineIdx);
						end;
					end;

					nodeTextExpected := True;
				end;
			end
			else
			begin
				// Check for start of multi line comment.
				if (TextBegins(lineElement, '<!--', True)) then
				begin
					inComment := True;
				end
				// Should be node text content.
				else if (inComment = False) then
				begin
					if (nodeTextExpected = False) then
						Malformed(lineIdx);

					inText := True;

					currNode.Text := currNode.Text + CCrLf + lineElement;
				end
				else
					Malformed(lineIdx);
			end;
		end;

	end;
end;

procedure TXml.Serialize(aWriter: TStreamWriter);
var
	indentDepth: integer;

	function GetIndentString: string;
	var
		i: integer;
	begin
		Result     := '';
		for i      := 0 to indentDepth - 1 do
			Result := Result + FIndentString;
	end;

	function GetAttributesText(aAttributes: TXmlAttributes): string;
	var
		i: integer;
	begin
		Result := '';
		for i  := 0 to aAttributes.Count - 1 do
		begin
			Result := Result + aAttributes[i].name + '="' + aAttributes[i].Value + '"';
			if (i <> aAttributes.Count - 1) then
				Result := Result + ' ';
		end;
	end;

	procedure WriteNode(aNode: TXmlNode);
	var
		str       : string;
		i         : integer;
		needsClose: boolean;
	begin
		needsClose := False;

		if (aNode.Attributes.Count > 0) then
			str := GetIndentString + '<' + aNode.name + ' ' + GetAttributesText(aNode.Attributes)
		else
			str := GetIndentString + '<' + aNode.name;

		if (aNode.Text = EmptyStr) and (aNode.Nodes.Count = 0) then
			str := str + ' />'
		else if (aNode.Text <> EmptyStr) then
		begin
			str := str + '>' + aNode.Text + '</' + aNode.name + '>';
			if (aNode.Nodes.Count > 0) then
				raise EXml.Create(SCantHaveTextAndChildren);
		end
		else
			str := str + '>';

		aWriter.WriteLine(str);

		if (aNode.Nodes.Count > 0) then
		begin
			needsClose := True;
			Inc(indentDepth);
			for i := 0 to aNode.Nodes.Count - 1 do
				WriteNode(aNode.Nodes[i]);
			Dec(indentDepth);
		end;

		if (needsClose) then
			aWriter.WriteLine(GetIndentString + '</' + aNode.name + '>');
	end;

begin
	indentDepth := 0;
	aWriter.WriteLine('<?xml ' + GetAttributesText(FHeader.Attributes) + ' ?>');

	WriteNode(FRoot);
end;

procedure TXml.LoadFromFile(const aFileName: string);
var
	str: TFileStream;
begin
	str := TFileStream.Create(aFileName, fmOpenRead or fmShareDenyWrite);
	try
		LoadFromStream(str);
	finally
		str.Free;
	end;
end;

procedure TXml.LoadFromStream(aStream: TStream);
var
	reader: TStreamReader;
begin
	reader := TStreamReader.Create(aStream);
	try
		Parse(reader);
	finally
		reader.Free;
	end;
end;

procedure TXml.SaveToFile(const aFileName: string);
var
	str: TFileStream;
begin
	str := TFileStream.Create(aFileName, fmOpenWrite or fmCreate or fmShareDenyWrite);
	try
		SaveToStream(str);
	finally
		str.Free;
	end;
end;

procedure TXml.SaveToStream(aStream: TStream);
var
	writer: TStreamWriter;
begin
	writer := TStreamWriter.Create(aStream);
	try
		Serialize(writer);
	finally
		writer.Free;
	end;
end;

procedure TXml.SetHeader(const aValue: TXmlHeader);
begin
	FHeader.Assign(aValue);
end;

procedure TXml.SetIndentString(const aValue: string);
begin
	if (FIndentString = aValue) then
		Exit;
	FIndentString := aValue;
end;

procedure TXml.SetRoot(const aValue: TXmlNode);
begin
	FRoot.Assign(aValue);
end;

end.
