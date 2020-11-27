unit EvilWorks.VCL.FindFiles platform;

interface

uses
	System.Classes,
    System.SysUtils,
    System.IOUtils;

type
	{ Forward declarations }
	TFindFiles = class;

	{ Events }
	TOnFileFound = procedure(aSender: TFindFiles; const aFileName: string) of object;

	{ TFindFiles }
	TFindFiles = class(TComponent)
	private
		FRootFolder    : string;
		FOnFileFound   : TOnFileFound;
		FOnFinished    : TNotifyEvent;
		FFileAttributes: TFileAttributes;
		procedure SetRootFolder(const Value: string);
		procedure SetFileAttributes(const Value: TFileAttributes);
	public
		constructor Create(aOwner: TComponent); override;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;
	published
		property RootFolder    : string read FRootFolder write SetRootFolder;
		property FileAttributes: TFileAttributes read FFileAttributes write SetFileAttributes;

		property OnFileFound: TOnFileFound read FOnFileFound write FOnFileFound;
		property OnFinished : TNotifyEvent read FOnFinished write FOnFinished;
	end;

implementation

{ TFindFiles }

constructor TFindFiles.Create(aOwner: TComponent);
begin
	inherited;

end;

destructor TFindFiles.Destroy;
begin

	inherited;
end;

procedure TFindFiles.Assign(aSource: TPersistent);
begin
	inherited;
	if (aSource is TFindFiles) then
	begin
		RootFolder  := TFindFiles(aSource).RootFolder;
		OnFileFound := TFindFiles(aSource).OnFileFound;
		OnFinished  := TFindFiles(aSource).OnFinished;
	end;
end;

procedure TFindFiles.SetFileAttributes(const Value: TFileAttributes);
begin
	FFileAttributes := Value;
end;

procedure TFindFiles.SetRootFolder(const Value: string);
begin
	FRootFolder := Value;
end;

end.
