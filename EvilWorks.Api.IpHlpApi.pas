unit EvilWorks.Api.IpHlpApi;

interface

uses
	WinApi.Windows,
    WinApi.Winsock2,
    WinApi.IpHlpApi,
    WinApi.IpRtrMib,
    WinApi.IpExport,
	System.SysUtils,
	EvilWorks.Api.TcpEStats;

const
	{ TCPIP_OWNING_MODULE_SIZE }
	TCPIP_OWNING_MODULE_SIZE = 16;
{$EXTERNALSYM TCPIP_OWNING_MODULE_SIZE}


type

	TMacAddr = array [0 .. MAXLEN_PHYSADDR - 1] of byte;
	PMacAddr = ^TMacAddr;

	{ MIB_TCP_STATE }
	MIB_TCP_STATE = (
	  MIB_TCP_STATE_CLOSED = 1,
	  MIB_TCP_STATE_LISTEN = 2,
	  MIB_TCP_STATE_SYN_SENT = 3,
	  MIB_TCP_STATE_SYN_RCVD = 4,
	  MIB_TCP_STATE_ESTAB = 5,
	  MIB_TCP_STATE_FIN_WAIT1 = 6,
	  MIB_TCP_STATE_FIN_WAIT2 = 7,
	  MIB_TCP_STATE_CLOSE_WAIT = 8,
	  MIB_TCP_STATE_CLOSING = 9,
	  MIB_TCP_STATE_LAST_ACK = 10,
	  MIB_TCP_STATE_TIME_WAIT = 11,
	  MIB_TCP_STATE_DELETE_TCB = 12
	  );
{$EXTERNALSYM MIB_TCP_STATE}
	{ TCP_TABLE_CLASS }
	TCP_TABLE_CLASS = (
	  TCP_TABLE_BASIC_LISTENER,
	  TCP_TABLE_BASIC_CONNECTIONS,
	  TCP_TABLE_BASIC_ALL,
	  TCP_TABLE_OWNER_PID_LISTENER,
	  TCP_TABLE_OWNER_PID_CONNECTIONS,
	  TCP_TABLE_OWNER_PID_ALL,
	  TCP_TABLE_OWNER_MODULE_LISTENER,
	  TCP_TABLE_OWNER_MODULE_CONNECTIONS,
	  TCP_TABLE_OWNER_MODULE_ALL
	  );
{$EXTERNALSYM TCP_TABLE_CLASS}
	TTcpTableClass   = TCP_TABLE_CLASS;
	PTCP_TABLE_CLASS = ^TCP_TABLE_CLASS;

	{ UDP_TABLE_CLASS }
	UDP_TABLE_CLASS = (
	  UDP_TABLE_BASIC,
	  UDP_TABLE_OWNER_PID,
	  UDP_TABLE_OWNER_MODULE
	  );
{$EXTERNALSYM UDP_TABLE_CLASS}
	TUdpTableClass    = UDP_TABLE_CLASS;
	PDUDP_TABLE_CLASS = ^UDP_TABLE_CLASS;

	{ MIB_TCPROW }
	MIB_TCPROW = record
		State: MIB_TCP_STATE;
		dwLocalAddr: DWORD;
		dwLocalPort: DWORD;
		dwRemoteAddr: DWORD;
		dwRemotePort: DWORD;
	end;
{$EXTERNALSYM PMIB_TCPROW}

	PMIB_TCPROW = ^MIB_TCPROW;
{$EXTERNALSYM MIB_TCPROW}
	TMibTcpRow = MIB_TCPROW;

	{ MIB_TCPTABLE }
	MIB_TCPTABLE = record
		dwNumEntries: DWORD;
		table: array [0 .. 0] of MIB_TCPROW;
	end;
{$EXTERNALSYM MIB_TCPTABLE}

	PMIB_TCPTABLE = ^MIB_TCPTABLE;
{$EXTERNALSYM MIB_TCPTABLE}
	TMibTcpTable = MIB_TCPTABLE;

	{ MIB_TCPROW_OWNER_PID }
	MIB_TCPROW_OWNER_PID = record
		dwState: DWORD;
		dwLocalAddr: DWORD;
		dwLocalPort: DWORD;
		dwRemoteAddr: DWORD;
		dwRemotePort: DWORD;
		dwOwningPid: DWORD;
	end;
{$EXTERNALSYM MIB_TCPROW_OWNER_PID}

	PMIB_TCPROW_OWNER_PID = ^MIB_TCPROW_OWNER_PID;
{$EXTERNALSYM MIB_TCPROW_OWNER_PID}
	TMibTcpRowOwnerPid = MIB_TCPROW_OWNER_PID;

	{ MIB_TCPTABLE_OWNER_PID }
	MIB_TCPTABLE_OWNER_PID = record
		dwNumEntries: DWORD;
		table: array [0 .. 0] of MIB_TCPROW_OWNER_PID;
	end;
{$EXTERNALSYM MIB_TCPTABLE_OWNER_PID}

	PMIB_TCPTABLE_OWNER_PID = ^MIB_TCPTABLE_OWNER_PID;
{$EXTERNALSYM MIB_TCPTABLE_OWNER_PID}
	TMibTcpTableOwnerPid = MIB_TCPTABLE_OWNER_PID;

	{ MIB_TCPROW_OWNER_MODULE }
	MIB_TCPROW_OWNER_MODULE = record
		dwState: DWORD;
		dwLocalAddr: DWORD;
		dwLocalPort: DWORD;
		dwRemoteAddr: DWORD;
		dwRemotePort: DWORD;
		dwOwningPid: DWORD;
		liCreateTimestamp: LARGE_INTEGER;
		OwningModuleInfo: array [0 .. TCPIP_OWNING_MODULE_SIZE - 1] of ULONGLONG;
	end;
{$EXTERNALSYM MIB_TCPROW_OWNER_MODULE}

	PMIB_TCPROW_OWNER_MODULE = ^MIB_TCPROW_OWNER_MODULE;
{$EXTERNALSYM MIB_TCPROW_OWNER_MODULE}
	TMibTcpRowOwnerModule = MIB_TCPROW_OWNER_MODULE;

	{ MIB_TCPTABLE_OWNER_MODULE }
	MIB_TCPTABLE_OWNER_MODULE = record
		dwNumEntries: DWORD;
		table: array [0 .. 0] of MIB_TCPROW_OWNER_MODULE;
	end;
{$EXTERNALSYM MIB_TCPTABLE_OWNER_MODULE}

	PMIB_TCPTABLE_OWNER_MODULE = ^MIB_TCPTABLE_OWNER_MODULE;
{$EXTERNALSYM MIB_TCPTABLE_OWNER_MODULE}
	TMibTcpTableOwnerModule = MIB_TCPTABLE_OWNER_MODULE;

	{ MIB_TCP6ROW }
	MIB_TCP6ROW = record
		State: MIB_TCP_STATE;
		LocalAddr: IN6_ADDR;
		dwLocalScopeId: DWORD;
		dwLocalPort: DWORD;
		RemoteAddr: IN6_ADDR;
		dwRemoteScopeId: DWORD;
		dwRemotePort: DWORD;
	end;
{$EXTERNALSYM MIB_TCP6ROW}

	PMIB_TCP6ROW = ^MIB_TCP6ROW;
{$EXTERNALSYM MIB_TCP6ROW}
	TMibTcp6Row = MIB_TCP6ROW;

	{ MIB_TCP6TABLE }
	MIB_TCP6TABLE = record
		dwNumEntries: DWORD;
		table: array [0 .. 0] of MIB_TCP6ROW;
	end;
{$EXTERNALSYM MIB_TCP6TABLE}

	PMIB_TCP6TABLE = ^MIB_TCP6TABLE;
{$EXTERNALSYM MIB_TCP6TABLE}
	TMibTcp6Table = MIB_TCP6TABLE;

	{ MIB_TCP6ROW_OWNER_PID }
	MIB_TCP6ROW_OWNER_PID = record
		ucLocalAddr: array [0 .. 15] of UCHAR;
		dwLocalScopeId: DWORD;
		dwLocalPort: DWORD;
		ucRemoteAddr: array [0 .. 15] of UCHAR;
		dwRemoteScopeId: DWORD;
		dwRemotePort: DWORD;
		dwState: DWORD;
		dwOwningPid: DWORD;
	end;
{$EXTERNALSYM MIB_TCP6ROW_OWNER_PID}

	PMIB_TCP6ROW_OWNER_PID = ^MIB_TCP6ROW_OWNER_PID;
{$EXTERNALSYM MIB_TCP6ROW_OWNER_PID}
	TMibTcp6RowOwnerPid = MIB_TCP6ROW_OWNER_PID;

	{ MIB_TCP6TABLE_OWNER_PID }
	MIB_TCP6TABLE_OWNER_PID = record
		dwNumEntries: DWORD;
		table: array [0 .. 0] of MIB_TCP6ROW_OWNER_PID;
	end;
{$EXTERNALSYM MIB_TCP6TABLE_OWNER_PID}

	PMIB_TCP6TABLE_OWNER_PID = ^MIB_TCP6TABLE_OWNER_PID;
{$EXTERNALSYM MIB_TCP6ROW_OWNER_PID}
	TMibTcp6TableOwnerPid = MIB_TCP6TABLE_OWNER_PID;

	{ MIB_TCP6ROW_OWNER_MODULE }
	MIB_TCP6ROW_OWNER_MODULE = record
		ucLocalAddr: array [0 .. 15] of UCHAR;
		dwLocalScopeId: DWORD;
		dwLocalPort: DWORD;
		ucRemoteAddr: array [0 .. 15] of UCHAR;
		dwRemoteScopeId: DWORD;
		dwRemotePort: DWORD;
		dwState: DWORD;
		dwOwningPid: DWORD;
		liCreateTimestamp: LARGE_INTEGER;
		OwningModuleInfo: array [0 .. TCPIP_OWNING_MODULE_SIZE - 1] of ULONGLONG;
	end;
{$EXTERNALSYM MIB_TCP6ROW_OWNER_MODULE}

	PMIB_TCP6ROW_OWNER_MODULE = ^MIB_TCP6ROW_OWNER_MODULE;
{$EXTERNALSYM MIB_TCP6ROW_OWNER_MODULE}
	TMibTcp6RowOwnerModule = MIB_TCP6ROW_OWNER_MODULE;

	{ MIB_TCP6TABLE_OWNER_MODULE }
	MIB_TCP6TABLE_OWNER_MODULE = record
		dwNumEntries: DWORD;
		table: array [0 .. 0] of MIB_TCP6ROW_OWNER_MODULE;
	end;
{$EXTERNALSYM MIB_TCP6TABLE_OWNER_MODULE}

	PMIB_TCP6TABLE_OWNER_MODULE = ^MIB_TCP6TABLE_OWNER_MODULE;
{$EXTERNALSYM MIB_TCP6TABLE_OWNER_MODULE}
	TMibTcp6TableOwnerModule = MIB_TCP6TABLE_OWNER_MODULE;

	{ MIB_UDPROW }
	MIB_UDPROW = record
		dwLocalAddr: DWORD;
		dwLocalPort: DWORD;
	end;
{$EXTERNALSYM MIB_UDPROW}

	TMibUdpRow  = MIB_UDPROW;
	PMIB_UDPROW = ^MIB_UDPROW;

	{ MIB_UDPTABLE }
	MIB_UDPTABLE = record
		dwNumEntries: DWORD;
		table: array [0 .. 0] of MIB_UDPROW;
	end;
{$EXTERNALSYM MIB_UDPTABLE}

	TMibUdpTable  = MIB_UDPTABLE;
	PMIB_UDPTABLE = ^MIB_UDPTABLE;

	{ MIB_UDPROW_OWNER_PID }
	MIB_UDPROW_OWNER_PID = record
		dwLocalAddr: DWORD;
		dwLocalPort: DWORD;
		dwOwningPid: DWORD;
	end;
{$EXTERNALSYM MIB_UDPROW_OWNER_PID}

	TMibUdpRowOwnerPid    = MIB_UDPROW_OWNER_PID;
	PMIB_UDPROW_OWNER_PID = ^MIB_UDPROW_OWNER_PID;

	{ MIB_UDPTABLE_OWNER_PID }
	MIB_UDPTABLE_OWNER_PID = record
		dwNumEntries: DWORD;
		table: array [0 .. 0] of MIB_UDPROW_OWNER_PID;
	end;
{$EXTERNALSYM MIB_UDPTABLE_OWNER_PID}

	TMibUdpTableOwnerPid    = MIB_UDPTABLE_OWNER_PID;
	PMIB_UDPTABLE_OWNER_PID = ^MIB_UDPTABLE_OWNER_PID;

	{ MIB_UDPROW_OWNER_MODULE }
	MIB_UDPROW_OWNER_MODULE = record
		dwLocalAddr: DWORD;
		dwLocalPort: DWORD;
		dwOwningPid: DWORD;
		liCreateTimestamp: LARGE_INTEGER;
		dwFlags: integer;
		OwningModuleInfo: array [0 .. TCPIP_OWNING_MODULE_SIZE - 1] of ULONGLONG;
	end;
{$EXTERNALSYM MIB_UDPROW_OWNER_MODULE}

	TMibUdpRowOwnerModule    = MIB_UDPROW_OWNER_MODULE;
	PMIB_UDPROW_OWNER_MODULE = ^MIB_UDPROW_OWNER_MODULE;

	{ MIB_UDPTABLE_OWNER_MODULE }
	MIB_UDPTABLE_OWNER_MODULE = record
		dwNumEntries: DWORD;
		table: array [0 .. 0] of MIB_UDPROW_OWNER_MODULE;
	end;
{$EXTERNALSYM MIB_UDPTABLE_OWNER_MODULE}

	TMibUdpTableOwnerModule    = MIB_UDPTABLE_OWNER_MODULE;
	PMIB_UDPTABLE_OWNER_MODULE = ^MIB_UDPTABLE_OWNER_MODULE;

	{ MIB_UDP6ROW }
	MIB_UDP6ROW = record
		dwLocalAddr: IN6_ADDR;
		dwLocalScopeId: DWORD;
		dwLocalPort: DWORD;
	end;
{$EXTERNALSYM MIB_UDP6ROW}

	TMibUdp6Row  = MIB_UDP6ROW;
	PMIB_UDP6ROW = ^MIB_UDP6ROW;

	{ MIB_UDP6TABLE }
	MIB_UDP6TABLE = record
		dwNumEntries: DWORD;
		table: array [0 .. 0] of MIB_UDP6ROW;
	end;
{$EXTERNALSYM MIB_UDP6TABLE}

	TMibUdp6Table  = MIB_UDP6TABLE;
	PMIB_UDP6TABLE = ^MIB_UDP6TABLE;

	{ MIB_UDPROW_OWNER_PID }
	MIB_UDP6ROW_OWNER_PID = record
		ucLocalAddr: array [0 .. 15] of UCHAR;
		dwLocalScopeId: DWORD;
		dwLocalPort: DWORD;
		dwOwningPid: DWORD;
	end;
{$EXTERNALSYM MIB_UDP6ROW_OWNER_PID}

	TMibUdp6RowOwnerPid    = MIB_UDP6ROW_OWNER_PID;
	PMIB_UDP6ROW_OWNER_PID = ^MIB_UDP6ROW_OWNER_PID;

	{ MIB_UDP6TABLE_OWNER_PID }
	MIB_UDP6TABLE_OWNER_PID = record
		dwNumEntries: DWORD;
		table: array [0 .. 0] of MIB_UDP6ROW_OWNER_PID;
	end;
{$EXTERNALSYM MIB_UDP6TABLE_OWNER_PID}

	TMibUdp6TableOwnerPid    = MIB_UDP6TABLE_OWNER_PID;
	PMIB_UDP6TABLE_OWNER_PID = ^MIB_UDP6TABLE_OWNER_PID;

	{ MIB_UDP6ROW_OWNER_MODULE }
	MIB_UDP6ROW_OWNER_MODULE = record
		ucLocalAddr: array [0 .. 15] of UCHAR;
		dwLocalScopeId: DWORD;
		dwLocalPort: DWORD;
		dwOwningPid: DWORD;
		liCreateTimestamp: LARGE_INTEGER;
		dwFlags: integer;
		OwningModuleInfo: array [0 .. TCPIP_OWNING_MODULE_SIZE - 1] of ULONGLONG;
	end;
{$EXTERNALSYM MIB_UDP6ROW_OWNER_MODULE}

	TMibUdp6RowOwnerModule    = MIB_UDP6ROW_OWNER_MODULE;
	PMIB_UDP6ROW_OWNER_MODULE = ^MIB_UDP6ROW_OWNER_MODULE;

	{ MIB_UDP6TABLE_OWNER_MODULE }
	MIB_UDP6TABLE_OWNER_MODULE = record
		dwNumEntries: DWORD;
		table: array [0 .. 0] of MIB_UDP6ROW_OWNER_MODULE;
	end;
{$EXTERNALSYM MIB_UDP6TABLE_OWNER_MODULE}

	TMibUdp6TableOwnerModule    = MIB_UDP6TABLE_OWNER_MODULE;
	PMIB_UDP6TABLE_OWNER_MODULE = ^MIB_UDP6TABLE_OWNER_MODULE;

	TGetPerTcpConnectionEStats = function(Row: PMIB_TCPROW; EstatsType: TCP_ESTATS_TYPE;
	  Rw: PUCHAR; RwVersion: ULONG; RwSize: ULONG; Ros: PUCHAR; RosVersion: ULONG;
	  RosSize: ULONG; Rod: PUCHAR; RodVersion: ULONG; RodSize: ULONG): ULONG; stdcall;
	TSetPerTcpConnectionEStats = function(Row: PMIB_TCPROW; EstatsType: TCP_ESTATS_TYPE;
	  Rw: PUCHAR; RwVersion: ULONG; RwSize: ULONG; Offset: ULONG): ULONG; stdcall;
	TGetPerTcp6ConnectionEStats = function(Row: PMIB_TCP6ROW; EstatsType: TCP_ESTATS_TYPE;
	  Rw: PUCHAR; RwVersion: ULONG; RwSize: ULONG; Ros: PUCHAR; RosVersion: ULONG;
	  RosSize: ULONG; Rod: PUCHAR; RodVersion: ULONG; RodSize: ULONG): ULONG; stdcall;
	TSetPerTcp6ConnectionEStats = function(Row: PMIB_TCP6ROW; EstatsType: TCP_ESTATS_TYPE;
	  Rw: PUCHAR; RwVersion: ULONG; RwSize: ULONG; Offset: ULONG): ULONG; stdcall;

function GetExtendedTcpTable(
  pTcpTable: pointer; var dwSize: DWORD; bOrder: BOOL; ulAf: ULONG;
  TableClass: TCP_TABLE_CLASS; Reserved: ULONG): DWORD; stdcall;
{$EXTERNALSYM GetExtendedTcpTable}

function GetExtendedUdpTable(
  pUdpTable: pointer; var dwSize: DWORD; bOrder: BOOL; ulAf: ULONG;
  TableClass: UDP_TABLE_CLASS; Reserved: ULONG): DWORD; stdcall;
{$EXTERNALSYM GetExtendedUdpTable}

function GetPerTcpConnectionEStats(Row: PMIB_TCPROW; EstatsType: TCP_ESTATS_TYPE;
  Rw: PUCHAR; RwVersion: ULONG; RwSize: ULONG; Ros: PUCHAR; RosVersion: ULONG;
  RosSize: ULONG; Rod: PUCHAR; RodVersion: ULONG; RodSize: ULONG): ULONG; stdcall;
{$EXTERNALSYM GetPerTcpConnectionEStats}

function SetPerTcpConnectionEStats(Row: PMIB_TCPROW; EstatsType: TCP_ESTATS_TYPE;
  Rw: PUCHAR; RwVersion: ULONG; RwSize: ULONG; Offset: ULONG): ULONG; stdcall;
{$EXTERNALSYM SetPerTcpConnectionEStats}

function GetPerTcp6ConnectionEStats(Row: PMIB_TCP6ROW; EstatsType: TCP_ESTATS_TYPE;
  Rw: PUCHAR; RwVersion: ULONG; RwSize: ULONG; Ros: PUCHAR; RosVersion: ULONG;
  RosSize: ULONG; Rod: PUCHAR; RodVersion: ULONG; RodSize: ULONG): ULONG; stdcall;
{$EXTERNALSYM GetPerTcp6ConnectionEStats}

function SetPerTcp6ConnectionEStats(Row: PMIB_TCP6ROW; EstatsType: TCP_ESTATS_TYPE;
  Rw: PUCHAR; RwVersion: ULONG; RwSize: ULONG; Offset: ULONG): ULONG; stdcall;
{$EXTERNALSYM SetPerTcp6ConnectionEStats}

function MacAddr2Str(const aMacAddr: TMacAddr; aSize: integer): string;

implementation

const
	iphlpapilib = 'iphlpapi.dll';

var
	hIpHlpApi                  : THandle;
	_GetPerTcpConnectionEStats : TGetPerTcpConnectionEStats;
	_SetPerTcpConnectionEStats : TSetPerTcpConnectionEStats;
	_GetPerTcp6ConnectionEStats: TGetPerTcp6ConnectionEStats;
	_SetPerTcp6ConnectionEStats: TSetPerTcp6ConnectionEStats;

function CheckStubsLoaded: boolean;
begin
	if (hIpHlpApi = 0) then
	begin
		hIpHlpApi := LoadLibrary(iphlpapilib);
		if (hIpHlpApi < 32) then
		begin
			hIpHlpApi := 0;
			Result    := False;
			Exit;
		end;
		@_GetPerTcpConnectionEStats  := GetProcAddress(hIpHlpApi, 'GetPerTcpConnectionEStats');
		@_SetPerTcpConnectionEStats  := GetProcAddress(hIpHlpApi, 'SetPerTcpConnectionEStats');
		@_GetPerTcp6ConnectionEStats := GetProcAddress(hIpHlpApi, 'GetPerTcp6ConnectionEStats');
		@_SetPerTcp6ConnectionEStats := GetProcAddress(hIpHlpApi, 'SetPerTcp6ConnectionEStats');
	end;
	Result := True;
end;

{ converts numerical MAC-address to ww-xx-yy-zz string }
function MacAddr2Str(const aMacAddr: TMacAddr; aSize: integer): string;
var
	i: integer;
begin
	if (aSize = 0) then
	begin
		Result := '00-00-00-00-00-00';
		Exit;
	end
	else
		Result := '';

	for i := 1 to aSize do
	begin
		Result := Result + IntToHex(aMacAddr[i], 2);
		if (i <> aSize) then
			Result := Result + '-';
	end;
end;

function GetExtendedTcpTable; external iphlpapilib name 'GetExtendedTcpTable';
function GetExtendedUdpTable; external iphlpapilib name 'GetExtendedUdpTable';

function GetPerTcpConnectionEStats(Row: PMIB_TCPROW; EstatsType: TCP_ESTATS_TYPE;
  Rw: PUCHAR; RwVersion: ULONG; RwSize: ULONG; Ros: PUCHAR; RosVersion: ULONG;
  RosSize: ULONG; Rod: PUCHAR; RodVersion: ULONG; RodSize: ULONG): ULONG;
begin
	if (CheckStubsLoaded) then
		Result := _GetPerTcpConnectionEStats(Row, EstatsType, Rw, RwVersion, RwSize, Ros,
		  RosVersion, RosSize, Rod, RodVersion, RodSize)
	else
		Result := 0;
end;

function SetPerTcpConnectionEStats(Row: PMIB_TCPROW; EstatsType: TCP_ESTATS_TYPE;
  Rw: PUCHAR; RwVersion: ULONG; RwSize: ULONG; Offset: ULONG): ULONG;
begin
	if (CheckStubsLoaded) then
		Result := _SetPerTcpConnectionEStats(Row, EstatsType, Rw, RwVersion, RwSize, Offset)
    else
    	Result := 0;
end;

function GetPerTcp6ConnectionEStats(Row: PMIB_TCP6ROW; EstatsType: TCP_ESTATS_TYPE;
  Rw: PUCHAR; RwVersion: ULONG; RwSize: ULONG; Ros: PUCHAR; RosVersion: ULONG;
  RosSize: ULONG; Rod: PUCHAR; RodVersion: ULONG; RodSize: ULONG): ULONG;
begin
	if (CheckStubsLoaded) then
		Result := _GetPerTcp6ConnectionEStats(Row, EstatsType, Rw, RwVersion, RwSize, Ros,
		  RosVersion, RosSize, Rod, RodVersion, RodSize)
	else
		Result := 0;
end;

function SetPerTcp6ConnectionEStats(Row: PMIB_TCP6ROW; EstatsType: TCP_ESTATS_TYPE;
  Rw: PUCHAR; RwVersion: ULONG; RwSize: ULONG; Offset: ULONG): ULONG;
begin
	if (CheckStubsLoaded) then
		Result := _SetPerTcp6ConnectionEStats(Row, EstatsType, Rw, RwVersion, RwSize, Offset)
    else
    	Result := 0;
end;

end.
