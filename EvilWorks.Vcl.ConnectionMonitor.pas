unit EvilWorks.Vcl.ConnectionMonitor;

interface

uses
	Winapi.Windows,
    Winapi.Messages,
    Winapi.IpExport,
    Winapi.IpHlpApi,
    Winapi.IpTypes,
    Winapi.PsApi,
	System.SysUtils,
    System.Classes,
	EvilWorks.Api.Winsock2,
    EvilWorks.Api.IpHlpApi,
    EvilWorks.Api.TcpEStats,
	EvilWorks.System.SysUtils,
    EvilWorks.System.ProcessUtils;

type
	{ Exceptions }
	EConnectionMonitor = class(Exception);

	{ Forward declarations }
	TConnectionMonitor = class;
	TConnectionInfo    = class;

	{ TProtocol }
	TProtocol = (ptTCP, ptUDP);

	{ TDataRowType }
	TDataRowType  = (drtTCP4, drtTCP6, drtUDP4, drtUDP6);
	TDataRowTypes = set of TDataRowType;

	{ Events }
	TOnHostnameLookupDone = procedure(aMonitor: TConnectionMonitor; aConnection: TConnectionInfo) of object;

	{ TConnectionInfo }
	TConnectionInfo = class(TPersistent)
	private
		FOwner      : TConnectionMonitor;
		FDataRow    : pointer;
		FDataRowType: TDataRowType;
		FIndex      : integer;
	private
		function GetCompany: string;
		function GetConnectionCreationTime: TDateTime;
		function GetFileAttributes: DWORD;
		function GetFileDescription: string;
		function GetFileVersion: string;
		function GetLocalAddr: string;
		function GetLocalHostName: string;
		function GetLocalPort: string;
		function GetLocalPortName: string;
		function GetModuleFileName: string;
		function GetProcessCreationTime: TDateTime;
		function GetProcessID: DWORD;
		function GetProcessName: string;
		function GetProcessPath: string;
		function GetProcessServices: string;
		function GetProductName: string;
		function GetProtocol: TProtocol;
		function GetRemoteAddr: string;
		function GetRemoteHostName: string;
		function GetRemoteIPCountry: string;
		function GetRemotePort: string;
		function GetRemotePortName: string;
		function GetState: DWORD;
		function GetUserName: string;
		function GetWindowTitle: string;
	public
		constructor Create(aOwner: TConnectionMonitor);
		destructor Destroy; override;
	protected
		property DataRow: pointer read FDataRow write FDataRow;
	public
		property index: integer read FIndex;
	published
		property ProcessID             : DWORD read GetProcessID;
		property ProcessName           : string read GetProcessName;
		property ProcessPath           : string read GetProcessPath;
		property ProcessCreationTime   : TDateTime read GetProcessCreationTime;
		property UserName              : string read GetUserName;
		property ModuleFileName        : string read GetModuleFileName;
		property FileAttributes        : DWORD read GetFileAttributes;
		property FileVersion           : string read GetFileVersion;
		property FileDescription       : string read GetFileDescription;
		property ProductName           : string read GetProductName;
		property Company               : string read GetCompany;
		property WindowTitle           : string read GetWindowTitle;
		property ProcessServices       : string read GetProcessServices;
		property Protocol              : TProtocol read GetProtocol;
		property State                 : DWORD read GetState;
		property LocalAddr             : string read GetLocalAddr;
		property LocalPort             : string read GetLocalPort;
		property LocalHostName         : string read GetLocalHostName;
		property LocalPortName         : string read GetLocalPortName;
		property RemoteAddr            : string read GetRemoteAddr;
		property RemotePort            : string read GetRemotePort;
		property RemoteHostName        : string read GetRemoteHostName;
		property RemotePortName        : string read GetRemotePortName;
		property RemoteIPCountry       : string read GetRemoteIPCountry;
		property ConnectionCreationTime: TDateTime read GetConnectionCreationTime;
	end;

	{ TProcessInfo }
	TProcessInfo = class
	private
		FFileVersion        : string;
		FProcessServices    : string;
		FProductName        : string;
		FFileAttributes     : DWORD;
		FModuleFileName     : string;
		FProcessID          : DWORD;
		FCompany            : string;
		FProcessCreationTime: TDateTime;
		FFileDescription    : string;
		FProcessPath        : string;
		FProcessName        : string;
		FUserName           : string;
		FWindowTitle        : string;
	public
		property ProcessID          : DWORD read FProcessID;
		property ProcessName        : string read FProcessName;
		property ProcessPath        : string read FProcessPath;
		property ProcessCreationTime: TDateTime read FProcessCreationTime;
		property UserName           : string read FUserName;
		property ModuleFileName     : string read FModuleFileName;
		property FileAttributes     : DWORD read FFileAttributes;
		property FileVersion        : string read FFileVersion;
		property FileDescription    : string read FFileDescription;
		property ProductName        : string read FProductName;
		property Company            : string read FCompany;
		property WindowTitle        : string read FWindowTitle;
		property ProcessServices    : string read FProcessServices;
	end;

	{ THostName Item }
	THostNameCacheItem = class
	private
		FHostName: string;
		FIP      : string;
	public
		property IP      : string read FIP;
		property HostName: string read FHostName;
	end;

	{ TConnectionMonitor }
	TConnectionMonitor = class(TComponent)
	private
		FConnections               : array of TConnectionInfo;
		FConnectionCount           : integer;
		FProcessInfos              : array of TProcessInfo;
		FProcessInfoCount          : integer;
		FHostNameCacheItems        : array of THostNameCacheItem;
		FHostNameCacheItemCount    : integer;
		FWaitingHostNameLookups    : array of THostNameCacheItem;
		FWaitingHostNameLookupCount: integer;
		FMaxParallelHostnameLookups: integer;
		FDataRetrievalTypes        : TDataRowTypes;
		FOnHostnameLookupDone      : TOnHostnameLookupDone;
		function GetConnection(const aIndex: integer): TConnectionInfo;
		procedure SetMaxParalleHostnamelLookups(const Value: integer);
	protected
		FActiveHostnameLookups: integer;
		function HostNameLookup(aConnection: TConnectionInfo; const aRemote: boolean): string;
		procedure EventHostnameLookupDone(aConnection: TConnectionInfo);

		function AddConnection(const aDataRowType: TDataRowType): TConnectionInfo;
		procedure ClearConnectionTable;
		procedure ClearHostNameCache;

		procedure GetTCP4Table;
		procedure GetTCP6Table;
		procedure GetUDP4Table;
		procedure GetUDP6Table;
		procedure GetProcessTable;

		function GetCompany(const aProcessID: DWORD): string;
		function GetFileAttributes(const aProcessID: DWORD): DWORD;
		function GetFileDescription(const aProcessID: DWORD): string;
		function GetFileVersion(const aProcessID: DWORD): string;
		function GetModuleFileName(const aProcessID: DWORD): string;
		function GetProcessCreationTime(const aProcessID: DWORD): TDateTime;
		function GetProcessName(const aProcessID: DWORD): string;
		function GetProcessPath(const aProcessID: DWORD): string;
		function GetProcessServices(const aProcessID: DWORD): string;
		function GetProductName(const aProcessID: DWORD): string;
		function GetUserName(const aProcessID: DWORD): string;
		function GetWindowTitle(const aProcessID: DWORD): string;
	public
		constructor Create(aOwner: TComponent); override;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;
		procedure Refresh;
		property Connections[const aIndex: integer]: TConnectionInfo read GetConnection; default;
		property Count: integer read FConnectionCount;
	published
		property DataRetrievalTypes        : TDataRowTypes read FDataRetrievalTypes write FDataRetrievalTypes default [drtTCP4, drtTCP6, drtUDP4, drtUDP6];
		property MaxParallelHostnameLookups: integer read FMaxParallelHostnameLookups write SetMaxParalleHostnamelLookups default 10;
		property OnHostnameLookupDone      : TOnHostnameLookupDone read FOnHostnameLookupDone write FOnHostnameLookupDone;
	end;

implementation

{ TConnectionInfo }

constructor TConnectionInfo.Create(aOwner: TConnectionMonitor);
begin
	FOwner   := aOwner;
	FDataRow := nil;
	FIndex   := - 1;
end;

destructor TConnectionInfo.Destroy;
begin
	if (FDataRow <> nil) then
		FreeMem(FDataRow);
	inherited;
end;

function TConnectionInfo.GetCompany: string;
begin
	Result := FOwner.GetCompany(ProcessID);
end;

function TConnectionInfo.GetConnectionCreationTime: TDateTime;
begin
	Result := 0;
//    case FDataRowType of
//        drtTCP4:
//        Result := SystemTimeToDateTime(TSystemTime(PMIB_TCPROW_OWNER_MODULE(FDataRow)^.liCreateTimestamp));
//        drtTCP6:
//        Result := SystemTimeToDateTime(TSystemTime(PMIB_TCP6ROW_OWNER_MODULE(FDataRow)^.liCreateTimestamp));
//        drtUDP4:
//        Result := SystemTimeToDateTime(TSystemTime(PMIB_UDPROW_OWNER_MODULE(FDataRow)^.liCreateTimestamp));
//        drtUDP6:
//        Result := SystemTimeToDateTime(TSystemTime(PMIB_UDP6ROW_OWNER_MODULE(FDataRow)^.liCreateTimestamp));
//    end;
end;

function TConnectionInfo.GetFileAttributes: DWORD;
begin
	Result := FOwner.GetFileAttributes(ProcessID);
end;

function TConnectionInfo.GetFileDescription: string;
begin
	Result := FOwner.GetFileDescription(ProcessID);
end;

function TConnectionInfo.GetFileVersion: string;
begin
	Result := FOwner.GetFileVersion(ProcessID);
end;

function TConnectionInfo.GetLocalAddr: string;
begin
	case FDataRowType of
		drtTCP4:
//		Result := InAddr4ToStr(in_addr(PMIB_TCPROW_OWNER_MODULE(FDataRow)^.dwLocalAddr));
//		drtTCP6:
//		Result := InAddr6ToStr(in6_addr(PMIB_TCP6ROW_OWNER_MODULE(FDataRow)^.ucLocalAddr));
//		drtUDP4:
//		Result := InAddr4ToStr(in_addr(PMIB_UDPROW_OWNER_MODULE(FDataRow)^.dwLocalAddr));
//		drtUDP6:
//		Result := InAddr6ToStr(in6_addr(PMIB_UDP6ROW_OWNER_MODULE(FDataRow)^.ucLocalAddr));
	end;
end;

function TConnectionInfo.GetLocalHostName: string;
begin
	Result := FOwner.HostNameLookup(Self, False);
end;

function TConnectionInfo.GetLocalPort: string;
begin
	case FDataRowType of
		drtTCP4:
		Result := IntToStr(PMIB_TCPROW_OWNER_MODULE(FDataRow)^.dwLocalPort);
		drtTCP6:
		Result := IntToStr(PMIB_TCP6ROW_OWNER_MODULE(FDataRow)^.dwLocalPort);
		drtUDP4:
		Result := IntToStr(PMIB_UDPROW_OWNER_MODULE(FDataRow)^.dwLocalPort);
		drtUDP6:
		Result := IntToStr(PMIB_UDP6ROW_OWNER_MODULE(FDataRow)^.dwLocalPort);
	end;
end;

function TConnectionInfo.GetLocalPortName: string;
begin

end;

function TConnectionInfo.GetModuleFileName: string;
begin
	Result := FOwner.GetModuleFileName(ProcessID);
end;

function TConnectionInfo.GetProcessCreationTime: TDateTime;
begin
	Result := FOwner.GetProcessCreationTime(ProcessID);
end;

function TConnectionInfo.GetProcessID: DWORD;
begin
	case FDataRowType of
		drtTCP4:
		Result := PMIB_TCPROW_OWNER_MODULE(FDataRow)^.dwOwningPid;
		drtTCP6:
		Result := PMIB_TCP6ROW_OWNER_MODULE(FDataRow)^.dwOwningPid;
		drtUDP4:
		Result := PMIB_UDPROW_OWNER_MODULE(FDataRow)^.dwOwningPid;
		drtUDP6:
		Result := PMIB_UDP6ROW_OWNER_MODULE(FDataRow)^.dwOwningPid;
    	else
    	Result := 0;
	end;
end;

function TConnectionInfo.GetProcessName: string;
begin
	Result := FOwner.GetProcessName(ProcessID);
end;

function TConnectionInfo.GetProcessPath: string;
begin
	Result := FOwner.GetProcessPath(ProcessID);
end;

function TConnectionInfo.GetProcessServices: string;
begin
	Result := FOwner.GetProcessServices(ProcessID);
end;

function TConnectionInfo.GetProductName: string;
begin
	Result := FOwner.GetProductName(ProcessID);
end;

function TConnectionInfo.GetProtocol: TProtocol;
begin
	case FDataRowType of
		drtTCP4, drtTCP6:
		Result := ptTCP;
		drtUDP4, drtUDP6:
		Result := ptUDP;
        else
        Result := ptTCP; // Compiler nagging.
	end;
end;

function TConnectionInfo.GetRemoteAddr: string;
begin
	case FDataRowType of
		drtTCP4:
//		Result := InAddr4ToStr(in_addr(PMIB_TCPROW_OWNER_MODULE(FDataRow)^.dwRemoteAddr));
//		drtTCP6:
//		Result := InAddr6ToStr(in6_addr(PMIB_TCP6ROW_OWNER_MODULE(FDataRow)^.ucRemoteAddr));
//		drtUDP4:
//		Result := EmptyStr;
//		drtUDP6:
//		Result := EmptyStr;
	end;
end;

function TConnectionInfo.GetRemoteHostName: string;
begin
	Result := FOwner.HostNameLookup(Self, True);

end;

function TConnectionInfo.GetRemoteIPCountry: string;
begin

end;

function TConnectionInfo.GetRemotePort: string;
begin
	case FDataRowType of
		drtTCP4:
		Result := IntToStr(PMIB_TCPROW_OWNER_MODULE(FDataRow)^.dwRemotePort);
		drtTCP6:
		Result := IntToStr(PMIB_TCP6ROW_OWNER_MODULE(FDataRow)^.dwRemotePort);
		drtUDP4:
		Result := EmptyStr;
		drtUDP6:
		Result := EmptyStr;
	end;
end;

function TConnectionInfo.GetRemotePortName: string;
begin

end;

function TConnectionInfo.GetState: DWORD;
begin
	case FDataRowType of
		drtTCP4:
		Result := PMIB_TCPROW_OWNER_MODULE(FDataRow)^.dwState;
		drtTCP6:
		Result := PMIB_TCP6ROW_OWNER_MODULE(FDataRow)^.dwState;
		drtUDP4:
		Result := 0;
		drtUDP6:
		Result := 0;
        else
        Result := 0; // Compiler nagging.
	end;
end;

function TConnectionInfo.GetUserName: string;
begin
	Result := FOwner.GetUserName(ProcessID);
end;

function TConnectionInfo.GetWindowTitle: string;
begin
	Result := FOwner.GetWindowTitle(ProcessID);
end;

{ TConnectionMonitor }

constructor TConnectionMonitor.Create(aOwner: TComponent);
begin
	inherited;
	FConnectionCount            := 0;
	FProcessInfoCount           := 0;
	FHostNameCacheItemCount     := 0;
	FWaitingHostNameLookupCount := 0;
	FActiveHostnameLookups      := 0;
	FMaxParallelHostnameLookups := 10;
	FDataRetrievalTypes         := [drtTCP4, drtTCP6, drtUDP4, drtUDP6];
end;

destructor TConnectionMonitor.Destroy;
begin
	ClearConnectionTable;
	ClearHostNameCache;
	inherited;
end;

function TConnectionMonitor.HostNameLookup(aConnection: TConnectionInfo; const aRemote: boolean): string;
var
	IP        : string;
	i         : integer;
begin

	if (aRemote) then
	begin
		case aConnection.FDataRowType of
			drtTCP4:
			IP := InAddr4ToStr(in_addr(PMIB_TCPROW_OWNER_MODULE(aConnection.FDataRow)^.dwRemoteAddr));
			drtTCP6:
			IP := InAddr6ToStr(in6_addr(PMIB_TCP6ROW_OWNER_MODULE(aConnection.FDataRow)^.ucRemoteAddr));
			drtUDP4:
			IP := EmptyStr;
			drtUDP6:
			IP := EmptyStr;
		end;
	end
	else
	begin
		case aConnection.FDataRowType of
			drtTCP4:
			IP := InAddr4ToStr(in_addr(PMIB_TCPROW_OWNER_MODULE(aConnection.FDataRow)^.dwLocalAddr));
			drtTCP6:
			IP := InAddr6ToStr(in6_addr(PMIB_TCP6ROW_OWNER_MODULE(aConnection.FDataRow)^.ucLocalAddr));
			drtUDP4:
			IP := InAddr4ToStr(in_addr(PMIB_UDPROW_OWNER_MODULE(aConnection.FDataRow)^.dwLocalAddr));
			drtUDP6:
			IP := InAddr6ToStr(in6_addr(PMIB_UDP6ROW_OWNER_MODULE(aConnection.FDataRow)^.ucLocalAddr));
		end;
	end;

	if (IP = EmptyStr) then
		Exit;

	for i := 0 to FHostNameCacheItemCount - 1 do
	begin
		if (SameText(FHostNameCacheItems[i].IP, IP)) then
		begin
			Result := FHostNameCacheItems[i].HostName;
			Exit;
		end;
	end;

	if (FActiveHostnameLookups >= FMaxParallelHostnameLookups) then
	begin
		Inc(FWaitingHostNameLookupCount);
		SetLength(FWaitingHostNameLookups, FWaitingHostNameLookupCount);
		FWaitingHostNameLookups[FWaitingHostNameLookupCount - 1] := THostNameCacheItem.Create;
		FWaitingHostNameLookups[FWaitingHostNameLookupCount - 1].FIP := IP;
	end
	else
	begin

	end;

//		if (aRemote) then
//		begin
//			case aConnection.FDataRowType of
//				drtTCP4:
//				Result := InAddr4RevLookup(in_addr(PMIB_TCPROW_OWNER_MODULE(FDataRow)^.dwRemoteAddr), False);
//				drtTCP6:
//				Result := InAddr6RevLookup(in6_addr(PMIB_TCP6ROW_OWNER_MODULE(FDataRow)^.ucRemoteAddr), False);
//				drtUDP4:
//				Result := EmptyStr;
//				drtUDP6:
//				Result := EmptyStr;
//			end;
//		end
//		else
//		begin
//			case aConnection.FDataRowType of
//				drtTCP4:
//				Result := InAddr4RevLookup(in_addr(PMIB_TCPROW_OWNER_MODULE(FDataRow)^.dwLocalAddr), False);
//				drtTCP6:
//				Result := InAddr6RevLookup(in6_addr(PMIB_TCP6ROW_OWNER_MODULE(FDataRow)^.ucLocalAddr), False);
//				drtUDP4:
//				Result := InAddr4RevLookup(in_addr(PMIB_UDPROW_OWNER_MODULE(FDataRow)^.dwLocalAddr), True);
//				drtUDP6:
//				Result := InAddr6RevLookup(in6_addr(PMIB_UDP6ROW_OWNER_MODULE(FDataRow)^.ucLocalAddr), True);
//			end;
//		end;

end;

procedure TConnectionMonitor.EventHostnameLookupDone(aConnection: TConnectionInfo);
begin
	if (Assigned(FOnHostnameLookupDone)) then
		FOnHostnameLookupDone(Self, aConnection);
end;

procedure TConnectionMonitor.Assign(aSource: TPersistent);
begin
	if (aSource is TConnectionMonitor) then
	begin
		DataRetrievalTypes := TConnectionMonitor(aSource).DataRetrievalTypes;
	end;
end;

procedure TConnectionMonitor.GetTCP4Table;
var
	connectionInfo: TConnectionInfo;
	ret           : DWORD;
	data          : pointer;
	ptr           : PMIB_TCPROW_OWNER_MODULE;
	datasize      : DWORD;
	c             : cardinal;
begin
	data     := nil;
	datasize := 0;
	ret      := GetExtendedTcpTable(data, datasize, False, AF_INET, TCP_TABLE_OWNER_MODULE_ALL, 0);
	if (ret = ERROR_INSUFFICIENT_BUFFER) then
	begin
		data := AllocMem(datasize);
		try
			ret := GetExtendedTcpTable(data, datasize, False, AF_INET, TCP_TABLE_OWNER_MODULE_ALL, 0);
			if (ret = NO_ERROR) then
			begin
				ptr := @PMIB_TCPTABLE_OWNER_MODULE(data)^.table;
				c   := 0;
				while (c < PMIB_TCPTABLE_OWNER_MODULE(data)^.dwNumEntries) do
				begin
					connectionInfo         := AddConnection(drtTCP4);
					connectionInfo.DataRow := AllocMem(SizeOf(ptr^));
					CopyMemory(connectionInfo.DataRow, ptr, SizeOf(ptr^));
					Inc(c);
					Inc(ptr);
				end;
			end
			else
			begin
				ClearConnectionTable;
				raise EConnectionMonitor.Create(Format('GetExtendedTcpTable failed when requesting connection table: (%d): %s', [ret, GetErrorText(ret)]));
			end;
		finally
			FreeMem(data);
		end;
	end
	else
	begin
		ClearConnectionTable;
		raise EConnectionMonitor.Create(Format('GetExtendedTcpTable failed when requesting needed buffer size: (%d): %s', [ret, GetErrorText(ret)]));
	end;
end;

procedure TConnectionMonitor.GetTCP6Table;
var
	connectionInfo: TConnectionInfo;
	ret           : DWORD;
	data          : pointer;
	ptr           : PMIB_TCP6ROW_OWNER_MODULE;
	datasize      : DWORD;
	c             : cardinal;
begin
	data     := nil;
	datasize := 0;
	ret      := GetExtendedTcpTable(data, datasize, False, AF_INET6, TCP_TABLE_OWNER_MODULE_ALL, 0);
	if (ret = ERROR_INSUFFICIENT_BUFFER) then
	begin
		data := AllocMem(datasize);
		try
			ret := GetExtendedTcpTable(data, datasize, False, AF_INET6, TCP_TABLE_OWNER_MODULE_ALL, 0);
			if (ret = NO_ERROR) then
			begin
				ptr := @PMIB_TCP6TABLE_OWNER_MODULE(data)^.table;
				c   := 0;
				while (c < PMIB_TCP6TABLE_OWNER_MODULE(data)^.dwNumEntries) do
				begin
					connectionInfo         := AddConnection(drtTCP6);
					connectionInfo.DataRow := AllocMem(SizeOf(ptr^));
					CopyMemory(connectionInfo.DataRow, ptr, SizeOf(ptr^));
					Inc(c);
					Inc(ptr);
				end;
			end
			else
			begin
				ClearConnectionTable;
				raise EConnectionMonitor.Create(Format('GetExtendedTcpTable failed requesting connection table: (%d): %s', [ret, GetErrorText(ret)]));
			end;
		finally
			FreeMem(data);
		end;
	end
	else
	begin
		ClearConnectionTable;
		raise EConnectionMonitor.Create(Format('GetExtendedTcpTable failed requesting needed buffer size: (%d): %s', [ret, GetErrorText(ret)]));
	end;
end;

procedure TConnectionMonitor.GetUDP4Table;
var
	connectionInfo: TConnectionInfo;
	ret           : DWORD;
	data          : pointer;
	ptr           : PMIB_UDPROW_OWNER_MODULE;
	datasize      : DWORD;
	c             : cardinal;
begin
	data     := nil;
	datasize := 0;
	ret      := GetExtendedUdpTable(data, datasize, False, AF_INET, UDP_TABLE_OWNER_MODULE, 0);
	if (ret = ERROR_INSUFFICIENT_BUFFER) then
	begin
		data := AllocMem(datasize);
		try
			ret := GetExtendedUdpTable(data, datasize, False, AF_INET, UDP_TABLE_OWNER_MODULE, 0);
			if (ret = NO_ERROR) then
			begin
				ptr := @PMIB_UDPTABLE_OWNER_MODULE(data)^.table;
				c   := 0;
				while (c < PMIB_UDPTABLE_OWNER_MODULE(data)^.dwNumEntries) do
				begin
					connectionInfo         := AddConnection(drtUDP4);
					connectionInfo.DataRow := AllocMem(SizeOf(ptr^));
					CopyMemory(connectionInfo.DataRow, ptr, SizeOf(ptr^));
					Inc(c);
					Inc(ptr);
				end;
			end
			else
			begin
				ClearConnectionTable;
				raise EConnectionMonitor.Create(Format('GetExtendedUdpTable failed requesting connection table: (%d): %s', [ret, GetErrorText(ret)]));
			end;
		finally
			FreeMem(data);
		end;
	end
	else
	begin
		ClearConnectionTable;
		raise EConnectionMonitor.Create(Format('GetExtendedUdpTable failed requesting needed buffer size: (%d): %s', [ret, GetErrorText(ret)]));
	end;
end;

procedure TConnectionMonitor.GetUDP6Table;
var
	connectionInfo: TConnectionInfo;
	ret           : DWORD;
	data          : pointer;
	ptr           : PMIB_UDP6ROW_OWNER_MODULE;
	datasize      : DWORD;
	c             : cardinal;
begin
	data     := nil;
	datasize := 0;
	ret      := GetExtendedUdpTable(data, datasize, False, AF_INET6, UDP_TABLE_OWNER_MODULE, 0);
	if (ret = ERROR_INSUFFICIENT_BUFFER) then
	begin
		data := AllocMem(datasize);
		try
			ret := GetExtendedUdpTable(data, datasize, False, AF_INET6, UDP_TABLE_OWNER_MODULE, 0);
			if (ret = NO_ERROR) then
			begin
				ptr := @PMIB_UDP6TABLE_OWNER_MODULE(data)^.table;
				c   := 0;
				while (c < PMIB_UDP6TABLE_OWNER_MODULE(data)^.dwNumEntries) do
				begin
					connectionInfo         := AddConnection(drtUDP6);
					connectionInfo.DataRow := AllocMem(SizeOf(ptr^));
					CopyMemory(connectionInfo.DataRow, ptr, SizeOf(ptr^));
					Inc(c);
					Inc(ptr);
				end;
			end
			else
			begin
				ClearConnectionTable;
				raise EConnectionMonitor.Create(Format('GetExtendedUdpTable failed requesting connection table: (%d): %s', [ret, GetErrorText(ret)]));
			end;
		finally
			FreeMem(data);
		end;
	end
	else
	begin
		ClearConnectionTable;
		raise EConnectionMonitor.Create(Format('GetExtendedUdpTable failed requesting needed buffer size: (%d): %s', [ret, GetErrorText(ret)]));
	end;
end;

procedure TConnectionMonitor.GetProcessTable;
var
	ret         : integer;
	processTable: array [0 .. 1023] of DWORD;
	dataReturned: DWORD;
	i           : integer;
begin
	if (EnumProcesses(@processTable[0], SizeOf(processTable), dataReturned) = False) then
	begin
		ClearConnectionTable;
		ret := GetLastError;
		raise EConnectionMonitor.Create(Format('Error enumerating processes: (%d): %s.', [ret, GetErrorText(ret)]));
	end;

	FProcessInfoCount := (dataReturned div SizeOf(DWORD));
	if (FProcessInfoCount = 0) then
		raise EConnectionMonitor.Create('Error enumerating processes: Count of enumerated processes is 0.');

	SetLength(FProcessInfos, FProcessInfoCount);
	for i := 0 to FProcessInfoCount - 1 do
	begin
		FProcessInfos[i] := TProcessInfo.Create;
		try
			FProcessInfos[i].FProcessID   := processTable[i];
			FProcessInfos[i].FProcessName := GetPIDModuleName(processTable[i]);
		except
			on E: Exception do
				{ silent };
		end;
	end;

	{
	 property ProcessName
	 property ProcessPath
	 property ProcessCreationTime
	 property UserName
	 property ModuleFileName
	 property FileAttributes
	 property FileVersion
	 property FileDescription
	 property ProductName
	 property Company
	 property WindowTitle
	 property ProcessServices
	}
end;

procedure TConnectionMonitor.Refresh;
begin
	ClearConnectionTable;

	if (drtTCP4 in DataRetrievalTypes) then
		GetTCP4Table;
	if (drtTCP6 in DataRetrievalTypes) then
		GetTCP6Table;
	if (drtUDP4 in DataRetrievalTypes) then
		GetUDP4Table;
	if (drtUDP6 in DataRetrievalTypes) then
		GetUDP6Table;
	if (DataRetrievalTypes <> []) then
		GetProcessTable;
end;

procedure TConnectionMonitor.SetMaxParalleHostnamelLookups(const Value: integer);
begin
	if (FMaxParallelHostnameLookups = Value) then
		Exit;
	FMaxParallelHostnameLookups := Value;
	if (FMaxParallelHostnameLookups < 0) then
		FMaxParallelHostnameLookups := 0;
end;

function TConnectionMonitor.AddConnection(const aDataRowType: TDataRowType): TConnectionInfo;
begin
	Inc(FConnectionCount);
	SetLength(FConnections, FConnectionCount);
	FConnections[FConnectionCount - 1]              := TConnectionInfo.Create(Self);
	FConnections[FConnectionCount - 1].FIndex       := (FConnectionCount - 1);
	FConnections[FConnectionCount - 1].FDataRowType := aDataRowType;
	Result                                          := FConnections[FConnectionCount - 1];
end;

procedure TConnectionMonitor.ClearConnectionTable;
var
	i: integer;
begin
	for i := 0 to FConnectionCount - 1 do
		FConnections[i].Free;
	SetLength(FConnections, 0);
	FConnectionCount := 0;

	for i := 0 to FProcessInfoCount - 1 do
		FProcessInfos[i].Free;
	SetLength(FProcessInfos, 0);
	FProcessInfoCount := 0;
end;

procedure TConnectionMonitor.ClearHostNameCache;
var
	i: integer;
begin
	for i := 0 to FHostNameCacheItemCount - 1 do
		FHostNameCacheItems[i].Free;
	SetLength(FHostNameCacheItems, 0);
	FHostNameCacheItemCount := 0;
end;

function TConnectionMonitor.GetProcessCreationTime(const aProcessID: DWORD): TDateTime;
begin
	Result := 0;
end;

function TConnectionMonitor.GetProcessName(const aProcessID: DWORD): string;
begin

end;

function TConnectionMonitor.GetProcessPath(const aProcessID: DWORD): string;
begin

end;

function TConnectionMonitor.GetProcessServices(const aProcessID: DWORD): string;
begin

end;

function TConnectionMonitor.GetUserName(const aProcessID: DWORD): string;
begin

end;

function TConnectionMonitor.GetWindowTitle(const aProcessID: DWORD): string;
begin

end;

function TConnectionMonitor.GetProductName(const aProcessID: DWORD): string;
begin

end;

function TConnectionMonitor.GetCompany(const aProcessID: DWORD): string;
begin

end;

function TConnectionMonitor.GetFileAttributes(const aProcessID: DWORD): DWORD;
begin
	Result := 0;
end;

function TConnectionMonitor.GetFileDescription(const aProcessID: DWORD): string;
begin

end;

function TConnectionMonitor.GetFileVersion(const aProcessID: DWORD): string;
begin

end;

function TConnectionMonitor.GetModuleFileName(const aProcessID: DWORD): string;
begin

end;

function TConnectionMonitor.GetConnection(const aIndex: integer): TConnectionInfo;
begin
	if (aIndex < 0) or (aIndex >= FConnectionCount) then
		raise Exception.Create(Format('TConnectionMonitor(%s).GetConnection index(%d) out of bounds(%d).', [name, aIndex, FConnectionCount]));

	Result := FConnections[aIndex];
end;

end.
