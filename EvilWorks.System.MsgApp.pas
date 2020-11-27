unit EvilWorks.System.MsgApp;

interface

uses
	System.Classes;

type
	{ TMsgApp }
	TMsgApp = class
    private
    	procedure InitWindow;
        procedure FinWindow;
    public
    	constructor Create;
        destructor Destroy; override;
    end;

implementation

{ TMsgApp }

constructor TMsgApp.Create;
begin

end;

destructor TMsgApp.Destroy;
begin

  inherited;
end;

procedure TMsgApp.FinWindow;
begin

end;

procedure TMsgApp.InitWindow;
begin

end;

initialization

finalization

end.
