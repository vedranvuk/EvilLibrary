unit EvilWorks.Design.HTTPHeadersEditor;

{$R *.dfm}

interface

uses
	Winapi.Windows,
	Winapi.Messages,
	System.SysUtils,
	System.Variants,
	System.Classes,
	Vcl.Graphics,
	Vcl.Controls,
	Vcl.Forms,
	Vcl.Dialogs,
	Vcl.StdCtrls,
	Vcl.ComCtrls,
	Vcl.ExtCtrls,
	DesignEditors,
	DesignIntf,
	EvilWorks.Web.HTTP;

type
	{ }
	THTTPHeadersProperty = class(TClassProperty)
	public
		procedure Edit; override;
		function GetAttributes: TPropertyAttributes; override;
	end;

	{ }
	THTTPHeadersPropertyEditorForm = class(TForm)
		pnlFooter: TPanel;
		btnOK: TButton;
		btnCancel: TButton;
		bvlFooter: TBevel;
		lvHeaders: TListView;
		BtnClear: TButton;
		BtnDelete: TButton;
		BtnAdd: TButton;
		EdtValue: TEdit;
		EdtKey: TEdit;
		lblValue: TLabel;
		lblKey: TLabel;
		lblHeaders: TLabel;
		procedure FormCreate(Sender: TObject);
		procedure FormDestroy(Sender: TObject);
	private
		FHeaders: THTTPMessage;
	public
		procedure ReloadHeaders;
		property HTTPHeaders: THTTPMessage read FHeaders write FHeaders;
	end;

implementation

{ ==================== }
{ THTTPHeadersProperty }
{ ==================== }

{ }
procedure THTTPHeadersProperty.Edit;
var
	frm: THTTPHeadersPropertyEditorForm;
begin
	Application.CreateForm(THTTPHeadersPropertyEditorForm, frm);
	try
		frm.Caption := Self.GetName;
		frm.HTTPHeaders.Assign(THTTPMessage(GetOrdValue));
		frm.ReloadHeaders;
		if (frm.ShowModal = mrOk) then
		begin
			THTTPMessage(GetOrdValue).Assign(frm.HTTPHeaders);
			Modified;
		end;
	finally
		frm.Free;
	end;
end;

{ }
function THTTPHeadersProperty.GetAttributes: TPropertyAttributes;
begin
	Result := [paDialog, paMultiSelect, paAutoUpdate];
end;

{ ============================== }
{ THTTPHeadersPropertyEditorForm }
{ ============================== }

{ }
procedure THTTPHeadersPropertyEditorForm.FormCreate(Sender: TObject);
begin
	FHeaders := THTTPMessage.Create;
end;

{ }
procedure THTTPHeadersPropertyEditorForm.FormDestroy(Sender: TObject);
begin
	FHeaders.Free;
end;

{ }
procedure THTTPHeadersPropertyEditorForm.ReloadHeaders;
var
	i : integer;
	li: TListItem;
begin
	lvHeaders.Items.BeginUpdate;
	try
		lvHeaders.Clear;
		for i := 0 to HTTPHeaders.Count - 1 do
		begin
			li         := lvHeaders.Items.Add;
			li.Caption := HTTPHeaders[i].Key;
			li.SubItems.Add(HTTPHeaders[i].Val);
		end;
	finally
		lvHeaders.Items.EndUpdate;
	end;
end;

end.
