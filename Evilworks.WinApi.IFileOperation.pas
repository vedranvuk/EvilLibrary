unit Evilworks.WinApi.IFileOperation;

interface

uses
  WinApi.ShellAPI, System.SysUtils;

function CopyFileIFileOperation(const srcFile, destFile: string): boolean;

implementation

uses ActiveX, ComObj, ShlObj;

function CopyFileIFileOperation(const srcFile, destFile: string): boolean;
// works on Windows >= Vista and 2008 server
var
  r: HRESULT;
  fileOp: IFileOperation;
  siSrcFile: IShellItem;
  siDestFolder: IShellItem;
  destFileFolder, destFileName: string;
begin
  result := false;

  destFileFolder := ExtractFileDir(destFile);
  destFileName := ExtractFileName(destFile);

  // init com
  r := CoInitializeEx(nil, COINIT_APARTMENTTHREADED or COINIT_DISABLE_OLE1DDE);
  if Succeeded(r) then
  begin
    // create IFileOperation interface
    r := CoCreateInstance(CLSID_FileOperation, nil, CLSCTX_ALL,
      IFileOperation, fileOp);
    if Succeeded(r) then
    begin
      // set operations flags
      r := fileOp.SetOperationFlags(FOF_NOCONFIRMATION OR FOFX_NOMINIMIZEBOX);
      if Succeeded(r) then
      begin
        // get source shell item
        r := SHCreateItemFromParsingName(PChar(srcFile), nil, IShellItem,
          siSrcFile);
        if Succeeded(r) then
        begin
          // get destination folder shell item
          r := SHCreateItemFromParsingName(PChar(destFileFolder), nil,
            IShellItem, siDestFolder);

          // add copy operation
          if Succeeded(r) then
            r := fileOp.CopyItem(siSrcFile, siDestFolder,
              PChar(destFileName), nil);
        end;

        // execute
        if Succeeded(r) then
          r := fileOp.PerformOperations;

        result := Succeeded(r);

        OleCheck(r);
      end;
    end;

    CoUninitialize;
  end;
end;

end.
