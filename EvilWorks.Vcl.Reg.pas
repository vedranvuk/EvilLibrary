unit EvilWorks.Vcl.Reg;

interface

uses
	System.Classes,
	DesignIntf,
	DesignEditors;

procedure Register;

implementation

uses
	EvilWorks.Vcl.BrowseDialog,
	EvilWorks.Vcl.ConnectionMonitor,
	EvilWorks.Vcl.ConsoleIO,
	EvilWorks.Vcl.GenericControl,
	EvilWorks.Vcl.FormSettings,
    EvilWorks.Vcl.Fullscreen,
    EvilWorks.Vcl.MarkupControl,
	EvilWorks.Vcl.Timers,
//	EvilWorks.Vcl.TextDisplay,
	EvilWorks.Vcl.TweetsControl,
	EvilWorks.Vcl.SplitPanel,
	EvilWorks.Web.AsyncSockets,
	EvilWorks.Web.HTTP,
	EvilWorks.Web.IRC,
	EvilWorks.Web.Twitter,

	EvilWorks.Design.HTTPHeadersEditor;

procedure Register;
begin
	RegisterComponents('EvilLibrary', [
	  TAsyncTCPClient,
	  TBrowseDialog,
	  TConnectionMonitor,
	  TConsoleIO,
	  TFormSettings,
      TFullscreen,
	  TGenericControl,
	  THTTPClient,
	  TIRCClient,
      TMarkupControl,
	  TNamedTimerList,
	  TSplitPanel,
//	  TTextDisplay,
	  TTweetsControl,
	  TTwitterRESTClient,
      TTwitterStreamClient
	  ]);

	RegisterPropertyEditor(TypeInfo(THTTPMessage), nil, '', THTTPHeadersProperty);

end;

end.
