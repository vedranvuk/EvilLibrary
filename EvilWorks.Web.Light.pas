unit EvilWorks.Web.Light;

interface

uses
	EvilWorks.Api.Winsock2,
	EvilWorks.Api.OpenSSL;

type
	TLightRec = record
	private
		Result: integer;
		Socket: TSocket;
		SSL   : PSSL;
		CTX   : PSSL_CTX;
	public
		function ResultStr: string;
	end;

	TAddressFamily = (afUnspec, afIPv4, afIPv6);
	TProxyType     = (ptNone, ptHTTP, ptSocks4, ptSocks5);

procedure TcpOpen(
  var aRec: TLightRec;
  const aHost, aPort, aProxyHost, aProxyPort, aProxyUser, aProxyPass: string;
  const aProxyType: TProxyType = ptNone; const aIpv6: boolean = False
  );

implementation

uses
	EvilWorks.Web.URI;

procedure TcpOpen(
  var aRec: TLightRec;
  const aHost, aPort, aProxyHost, aProxyPort, aProxyUser, aProxyPass: string;
  const aProxyType: TProxyType = ptNone; const aIpv6: boolean = False
  );
begin

end;

{ TLightRec }

function TLightRec.ResultStr: string;
begin
	Result := GetWinsockErrorText(Self.Result);
end;

end.
