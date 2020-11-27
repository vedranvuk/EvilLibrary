//
// EvilLibrary by Vedran Vuk 2010-2012
//
// Name: 					EvilWorks.Api.Winsock2
// Description: 			Winsock2 header file, because embarcadero's is, naturally, incomplete.
// 						    Also some extra utilities, all self contained and lightweight.
// File last change date:   September 14th. 2012
// File version: 			Dev 0.0.0
// Licence:                 Free.
//

unit EvilWorks.Api.Winsock2;

interface

uses
	WinApi.Windows;

{$ALIGN OFF}


// Define the current Winsock version. To build an earlier Winsock version
// application redefine this value prior to including Winsock2.h
const
	WINSOCK_VERSION = $0202;
	WINSOCK2_DLL    = 'ws2_32.dll';

type
	u_char  = Byte;
	u_short = Word;
	u_int   = DWORD;
	u_long  = DWORD;

	// The new type to be used in all instances which refer to sockets.
	TSocket   = u_int;
	socklen_t = integer;

	WSAEVENT   = THandle;
	PWSAEVENT  = ^WSAEVENT;
	LPWSAEVENT = PWSAEVENT;

{$IFDEF UNICODE}
	PMBChar = PWideChar;
{$ELSE}
	PMBChar = PAnsiChar;
{$ENDIF}


const
	FD_SETSIZE = 64;

type
	PFDSet = ^TFDSet;

	TFDSet = packed record
		fd_count: u_int;
		fd_array: array [0 .. FD_SETSIZE - 1] of TSocket;
	end;

	PTimeVal = ^TTimeVal;

	TTimeVal = packed record
		tv_sec: Longint;
		tv_usec: Longint;
	end;

	timeval = TTimeVal;

const
	IOCPARM_MASK = $7F;
	IOC_VOID     = $20000000;
	IOC_OUT      = $40000000;
	IOC_IN       = $80000000;
	IOC_INOUT    = (IOC_IN or IOC_OUT);

	// get # bytes to read
	FIONREAD = IOC_OUT or (SizeOf(Longint) shl 16) or (Ord('f') shl 8) or 127;
	// set/clear non-blocking i/o
	FIONBIO = IOC_IN or (SizeOf(Longint) shl 16) or (Ord('f') shl 8) or 126;
	// set/clear async i/o
	FIOASYNC = IOC_IN or (SizeOf(Longint) shl 16) or (Ord('f') shl 8) or 125;

	// Socket I/O Controls

	// set high watermark
	SIOCSHIWAT = IOC_IN or (SizeOf(Longint) shl 16) or (Ord('s') shl 8);
	// get high watermark
	SIOCGHIWAT = IOC_OUT or (SizeOf(Longint) shl 16) or (Ord('s') shl 8) or 1;
	// set low watermark
	SIOCSLOWAT = IOC_IN or (SizeOf(Longint) shl 16) or (Ord('s') shl 8) or 2;
	// get low watermark
	SIOCGLOWAT = IOC_OUT or (SizeOf(Longint) shl 16) or (Ord('s') shl 8) or 3;
	// at oob mark?
	SIOCATMARK = IOC_OUT or (SizeOf(Longint) shl 16) or (Ord('s') shl 8) or 7;

	// Structures returned by network data base library, taken from the
	// BSD file netdb.h.  All addresses are supplied in host order, and
	// returned in network order (suitable for use in system calls).
type
	PHostEnt = ^THostEnt;

	THostEnt = packed record
		h_name: PAnsiChar;     // official name of host
		h_aliases: ^PAnsiChar; // alias list
		h_addrtype: Smallint;  // host address type
		h_length: Smallint;    // length of address
		case Byte of
			0:
			(h_addr_list: ^PAnsiChar); // list of addresses
			1:
			(h_addr: ^PAnsiChar); // address, for backward compat
	end;

	// It is assumed here that a network number
	// fits in 32 bits.
	PNetEnt = ^TNetEnt;

	TNetEnt = packed record
		n_name: PAnsiChar;     // official name of net
		n_aliases: ^PAnsiChar; // alias list
		n_addrtype: Smallint;  // net address type
		n_net: u_long;         // network #
	end;

	PServEnt = ^TServEnt;

	TServEnt = packed record
		s_name: PAnsiChar;     // official service name
		s_aliases: ^PAnsiChar; // alias list
		s_port: Smallint;      // protocol to use
		s_proto: PAnsiChar;    // port #
	end;

	PProtoEnt = ^TProtoEnt;

	TProtoEnt = packed record
		p_name: PAnsiChar;     // official protocol name
		p_aliases: ^PAnsiChar; // alias list
		p_proto: Smallint;     // protocol #
	end;

	// Constants and structures defined by the internet system,
	// Per RFC 790, September 1981, taken from the BSD file netinet/in.h.
const

	// Protocols
	IPPROTO_IP   = 0;  // dummy for IP
	IPPROTO_ICMP = 1;  // control message protocol
	IPPROTO_IGMP = 2;  // group management protocol
	IPPROTO_GGP  = 3;  // gateway^2 (deprecated)
	IPPROTO_TCP  = 6;  // TCP
	IPPROTO_PUP  = 12; // pup
	IPPROTO_UDP  = 17; // UDP - user datagram protocol
	IPPROTO_IDP  = 22; // xns idp
	IPPROTO_ND   = 77; // UNOFFICIAL net disk proto

	IPPROTO_RAW = 255; // raw IP packet
	IPPROTO_MAX = 256;

	// Port/socket numbers: network standard functions
	IPPORT_ECHO       = 7;
	IPPORT_DISCARD    = 9;
	IPPORT_SYSTAT     = 11;
	IPPORT_DAYTIME    = 13;
	IPPORT_NETSTAT    = 15;
	IPPORT_FTP        = 21;
	IPPORT_TELNET     = 23;
	IPPORT_SMTP       = 25;
	IPPORT_TIMESERVER = 37;
	IPPORT_NAMESERVER = 42;
	IPPORT_WHOIS      = 43;
	IPPORT_MTP        = 57;

	// Port/socket numbers: host specific functions
	IPPORT_TFTP    = 69;
	IPPORT_RJE     = 77;
	IPPORT_FINGER  = 79;
	IPPORT_TTYLINK = 87;
	IPPORT_SUPDUP  = 95;

	// UNIX TCP sockets
	IPPORT_EXECSERVER  = 512;
	IPPORT_LOGINSERVER = 513;
	IPPORT_CMDSERVER   = 514;
	IPPORT_EFSSERVER   = 520;

	// UNIX UDP sockets
	IPPORT_BIFFUDP     = 512;
	IPPORT_WHOSERVER   = 513;
	IPPORT_ROUTESERVER = 520;

	// Ports < IPPORT_RESERVED are reserved for  privileged processes (e.g. root).
	IPPORT_RESERVED = 1024;

	// Link numbers
	IMPLINK_IP        = 155;
	IMPLINK_LOWEXPER  = 156;
	IMPLINK_HIGHEXPER = 158;

	TF_DISCONNECT   = $01;
	TF_REUSE_SOCKET = $02;
	TF_WRITE_BEHIND = $04;

	// This is used instead of -1, since the TSocket type is unsigned.
	INVALID_SOCKET = TSocket(not (0));
	SOCKET_ERROR   = - 1;

	// The  following  may  be used in place of the address family, socket type, or
	// protocol  in  a  call  to WSASocket to indicate that the corresponding value
	// should  be taken from the supplied WSAPROTOCOL_INFO structure instead of the
	// parameter itself.
	FROM_PROTOCOL_INFO = - 1;

	// Types
	SOCK_STREAM    = 1; { stream socket }
	SOCK_DGRAM     = 2; { datagram socket }
	SOCK_RAW       = 3; { raw-protocol interface }
	SOCK_RDM       = 4; { reliably-delivered message }
	SOCK_SEQPACKET = 5; { sequenced packet stream }

	// Option flags per-socket.
	SO_DEBUG       = $0001; // turn on debugging info recording
	SO_ACCEPTCONN  = $0002; // socket has had listen()
	SO_REUSEADDR   = $0004; // allow local address reuse
	SO_KEEPALIVE   = $0008; // keep connections alive
	SO_DONTROUTE   = $0010; // just use interface addresses
	SO_BROADCAST   = $0020; // permit sending of broadcast msgs
	SO_USELOOPBACK = $0040; // bypass hardware when possible
	SO_LINGER      = $0080; // linger on close if data present
	SO_OOBINLINE   = $0100; // leave received OOB data in line

	SO_DONTLINGER       = not SO_LINGER;
	SO_EXCLUSIVEADDRUSE = not SO_REUSEADDR; // disallow local address reuse

	// Additional options.

	SO_SNDBUF   = $1001; // send buffer size
	SO_RCVBUF   = $1002; // receive buffer size
	SO_SNDLOWAT = $1003; // send low-water mark
	SO_RCVLOWAT = $1004; // receive low-water mark
	SO_SNDTIMEO = $1005; // send timeout
	SO_RCVTIMEO = $1006; // receive timeout
	SO_ERROR    = $1007; // get error status and clear
	SO_TYPE     = $1008; // get socket type

	// Options for connect and disconnect data and options.
	// Used only by non-TCP/IP transports such as DECNet, OSI TP4, etc.
	SO_CONNDATA    = $7000;
	SO_CONNOPT     = $7001;
	SO_DISCDATA    = $7002;
	SO_DISCOPT     = $7003;
	SO_CONNDATALEN = $7004;
	SO_CONNOPTLEN  = $7005;
	SO_DISCDATALEN = $7006;
	SO_DISCOPTLEN  = $7007;

	// Option for opening sockets for synchronous access.
	SO_OPENTYPE             = $7008;
	SO_SYNCHRONOUS_ALERT    = $10;
	SO_SYNCHRONOUS_NONALERT = $20;

	// Other NT-specific options.
	SO_MAXDG                  = $7009;
	SO_MAXPATHDG              = $700A;
	SO_UPDATE_ACCEPT_CONTEXT  = $700B;
	SO_UPDATE_CONNECT_CONTEXT = $7010;
	SO_CONNECT_TIME           = $700C;

	// TCP options.
	TCP_NODELAY   = $0001;
	TCP_BSDURGENT = $7000;

	// WinSock 2 extension -- new options
	SO_GROUP_ID       = $2001; // ID of a socket group
	SO_GROUP_PRIORITY = $2002; // the relative priority within a group
	SO_MAX_MSG_SIZE   = $2003; // maximum message size
	SO_Protocol_InfoA = $2004; // WSAPROTOCOL_INFOA structure
	SO_Protocol_InfoW = $2005; // WSAPROTOCOL_INFOW structure
{$IFDEF UNICODE}
	SO_Protocol_Info = SO_Protocol_InfoW;
{$ELSE}
	SO_Protocol_Info = SO_Protocol_InfoA;
{$ENDIF}
	PVD_CONFIG            = $3001; // configuration info for service provider
	SO_CONDITIONAL_ACCEPT = $3002; // enable true conditional accept:
	// connection is not ack-ed to the
	// other side until conditional
	// function returns CF_ACCEPT

// Address families.
	AF_UNSPEC    = 0;      // unspecified
	AF_UNIX      = 1;      // local to host (pipes, portals)
	AF_INET      = 2;      // Internet protocol Version 4: UDP, TCP, etc.
	AF_IMPLINK   = 3;      // arpanet imp addresses
	AF_PUP       = 4;      // pup protocols: e.g. BSP
	AF_CHAOS     = 5;      // mit CHAOS protocols
	AF_IPX       = 6;      // IPX and SPX
	AF_NS        = AF_IPX; // XEROX NS protocols
	AF_ISO       = 7;      // ISO protocols
	AF_OSI       = AF_ISO; // OSI is ISO
	AF_ECMA      = 8;      // european computer manufacturers
	AF_DATAKIT   = 9;      // datakit protocols
	AF_CCITT     = 10;     // CCITT protocols, X.25 etc
	AF_SNA       = 11;     // IBM SNA
	AF_DECnet    = 12;     // DECnet
	AF_DLI       = 13;     // Direct data link interface
	AF_LAT       = 14;     // LAT
	AF_HYLINK    = 15;     // NSC Hyperchannel
	AF_APPLETALK = 16;     // AppleTalk
	AF_NETBIOS   = 17;     // NetBios-style addresses
	AF_VOICEVIEW = 18;     // VoiceView
	AF_FIREFOX   = 19;     // FireFox
	AF_UNKNOWN1  = 20;     // Somebody is using this!
	AF_BAN       = 21;     // Banyan
	AF_ATM       = 22;     // Native ATM Services
	AF_INET6     = 23;     // Internet protocol Version 6
	AF_CLUSTER   = 24;     // Microsoft Wolfpack
	AF_12844     = 25;     // IEEE 1284.4 WG AF
	AF_IRDA      = 26;     // IrDA
	AF_NETDES    = 28;     // Network Designers OSI & gateway enabled protocols

	AF_MAX = 29;


	// Protocol families, same as address families for now.

	PF_UNSPEC    = AF_UNSPEC;
	PF_UNIX      = AF_UNIX;
	PF_INET      = AF_INET;
	PF_IMPLINK   = AF_IMPLINK;
	PF_PUP       = AF_PUP;
	PF_CHAOS     = AF_CHAOS;
	PF_NS        = AF_NS;
	PF_IPX       = AF_IPX;
	PF_ISO       = AF_ISO;
	PF_OSI       = AF_OSI;
	PF_ECMA      = AF_ECMA;
	PF_DATAKIT   = AF_DATAKIT;
	PF_CCITT     = AF_CCITT;
	PF_SNA       = AF_SNA;
	PF_DECnet    = AF_DECnet;
	PF_DLI       = AF_DLI;
	PF_LAT       = AF_LAT;
	PF_HYLINK    = AF_HYLINK;
	PF_APPLETALK = AF_APPLETALK;
	PF_VOICEVIEW = AF_VOICEVIEW;
	PF_FIREFOX   = AF_FIREFOX;
	PF_UNKNOWN1  = AF_UNKNOWN1;
	PF_BAN       = AF_BAN;
	PF_ATM       = AF_ATM;
	PF_INET6     = AF_INET6;

	PF_MAX = AF_MAX;

	WSAID_CONNECTEX: TGUID = (D1: $25A207B9; D2: $DDF3; D3: $4660; D4: ($8E, $E9, $76, $E5, $8C, $74, $06, $3E));

	WSAID_TRANSMITFILE: TGUID = (D1: $B5367DF0; D2: $CBAC; D3: $11CF; D4: ($95, $CA, $00, $80, $5F, $48, $A1, $92));

	//
	// Flags used in "hints" argument to getaddrinfo()
	// - AI_ADDRCONFIG is supported starting with Vista
	// - default is AI_ADDRCONFIG ON whether the flag is set or not
	// because the performance penalty in not having ADDRCONFIG in
	// the multi-protocol stack environment is severe;
	// this defaulting may be disabled by specifying the AI_ALL flag,
	// in that case AI_ADDRCONFIG must be EXPLICITLY specified to
	// enable ADDRCONFIG behavior
	//

	AI_PASSIVE     = $00000001; // Socket address will be used in bind() call
	AI_CANONNAME   = $00000002; // Return canonical name in first ai_canonname
	AI_NUMERICHOST = $00000004; // Nodename must be a numeric address string
	AI_NUMERICSERV = $00000008; // Servicename must be a numeric port number

	AI_ALL        = $00000100; // Query both IP6 and IP4 with AI_V4MAPPED
	AI_ADDRCONFIG = $00000400; // Resolution only if global address configured
	AI_V4MAPPED   = $00000800; // On v6 failure, query v4 and convert to V4MAPPED format

	AI_NON_AUTHORITATIVE      = $00004000; // LUP_NON_AUTHORITATIVE
	AI_SECURE                 = $00008000; // LUP_SECURE
	AI_RETURN_PREFERRED_NAMES = $00010000; // LUP_RETURN_PREFERRED_NAMES

	AI_FQDN       = $00020000; // Return the FQDN in ai_canonname
	AI_FILESERVER = $00040000; // Resolving fileserver name resolution

type
	// IPv4 Address
	SunB = packed record
		s_b1, s_b2, s_b3, s_b4: u_char;
	end;

	SunW = packed record
		s_w1, s_w2: u_short;
	end;

	in_addr = packed record
		case integer of
			0:
			(S_un_b: SunB);
			1:
			(S_un_w: SunW);
			2:
			(S_addr: u_long);
	end;

	TInAddr = in_addr;
	PInAddr = ^TInAddr;

	// IPv6 address

	in6_addr = packed record
		case integer of
			0:
			(Bytes: array [0 .. 15] of Byte);
			1:
			(Words: array [0 .. 7] of Word);
	end;

	TIn6Addr = in6_addr;
	PIn6Addr = ^TIn6Addr;

	in_addr6 = in6_addr;

	// Structure used by kernel to store most addresses.

	TSockAddrIn = packed record
		case integer of
			0:
			(sin_family: u_short;
			  sin_port: u_short;
			  sin_addr: TInAddr;
			  sin_zero: array [0 .. 7] of Char);
			1:
			(sa_family: u_short;
			  sa_data: array [0 .. 13] of Char)
	end;

	PSockAddrIn = ^TSockAddrIn;
	TSockAddr   = TSockAddrIn;
	PSockAddr   = ^TSockAddr;
	SOCKADDR    = TSockAddr;
	SOCKADDR_IN = TSockAddrIn;

	TSockAddrIn6 = packed record
		sin6_family: short;
		sin6_port: u_short;
		sin6_flowinfo: u_long;
		sin6_addr: in6_addr;
		sin6_scope_id: u_long;
	end;

	PSockAddrIn6 = ^TSockAddrIn6;
	SOCKADDR_IN6 = TSockAddrIn6;

	// Structure used by kernel to pass protocol information in raw sockets.
	PSockProto = ^TSockProto;

	TSockProto = packed record
		sp_family: u_short;
		sp_protocol: u_short;
	end;

	// Structure used for manipulating linger option.
	PLinger = ^TLinger;

	TLinger = packed record
		l_onoff: u_short;
		l_linger: u_short;
	end;

	PADDRINFOA  = ^ADDRINFOA;
	PPADDRINFOA = ^PADDRINFOA;

	ADDRINFOA = record
		ai_flags: integer;
		ai_family: integer;
		ai_socktype: integer;
		ai_protocol: integer;
		ai_addrlen: cardinal; // size_t
		AI_CANONNAME: PAnsiChar;
		ai_addr: PSockAddr;
		ai_next: PADDRINFOA;
	end;

	TAddrInfoA = ADDRINFOA;

	PADDRINFOW  = ^ADDRINFOW;
	PPADDRINFOW = ^PADDRINFOW;

	ADDRINFOW = record
		ai_flags: integer;
		ai_family: integer;
		ai_socktype: integer;
		ai_protocol: integer;
		ai_addrlen: cardinal; // size_t
		AI_CANONNAME: PWideChar;
		ai_addr: PSockAddr;
		ai_next: PADDRINFOW;
	end;

	TAddrInfoW = ADDRINFOW;

{$IFDEF UNICODE}
	addrinfo   = ADDRINFOW;
	TAddrInfo  = TAddrInfoW;
	PAddrInfo  = PADDRINFOW;
	PPAddrInfo = PPADDRINFOW;
{$ELSE}
	addrinfo   = ADDRINFOA;
	TAddrInfo  = TAddrInfoA;
	PAddrInfo  = PADDRINFOA;
	PPAddrInfo = PPADDRINFOA;
{$ENDIF}


const
	INADDR_ANY       = $00000000;
	INADDR_LOOPBACK  = $7F000001;
	INADDR_BROADCAST = $FFFFFFFF;
	INADDR_NONE      = $FFFFFFFF;

	ADDR_ANY = INADDR_ANY;

	SOL_SOCKET = $FFFF; // options for socket level

	MSG_OOB       = $1; // process out-of-band data
	MSG_PEEK      = $2; // peek at incoming message
	MSG_DONTROUTE = $4; // send without using routing tables
	MSG_WAITALL   = $8; // do not complete until packet is completely filled

	MSG_PARTIAL = $8000; // partial send or recv for message xport

	// WinSock 2 extension -- new flags for WSASend(), WSASendTo(), WSARecv() and WSARecvFrom()
	MSG_INTERRUPT = $10; // send/recv in the interrupt context
	MSG_MAXIOVLEN = 16;


	// Define constant based on rfc883, used by gethostbyxxxx() calls.

	MAXGETHOSTSTRUCT = 1024;

	// Maximum queue length specifiable by listen.
	SOMAXCONN = $7FFFFFFF;

	// WinSock 2 extension -- bit values and indices for FD_XXX network events
	FD_READ_BIT      = 0;
	FD_WRITE_BIT     = 1;
	FD_OOB_BIT       = 2;
	FD_ACCEPT_BIT    = 3;
	FD_CONNECT_BIT   = 4;
	FD_CLOSE_BIT     = 5;
	FD_QOS_BIT       = 6;
	FD_GROUP_QOS_BIT = 7;

	FD_MAX_EVENTS = 8;

	FD_READ      = (1 shl FD_READ_BIT);
	FD_WRITE     = (1 shl FD_WRITE_BIT);
	FD_OOB       = (1 shl FD_OOB_BIT);
	FD_ACCEPT    = (1 shl FD_ACCEPT_BIT);
	FD_CONNECT   = (1 shl FD_CONNECT_BIT);
	FD_CLOSE     = (1 shl FD_CLOSE_BIT);
	FD_QOS       = (1 shl FD_QOS_BIT);
	FD_GROUP_QOS = (1 shl FD_GROUP_QOS_BIT);

	FD_ALL_EVENTS = (1 shl FD_MAX_EVENTS) - 1;

	// All Windows Sockets error constants are biased by WSABASEERR from the "normal"

	WSABASEERR = 10000;

	// Windows Sockets definitions of regular Microsoft C error constants

	WSAEINTR  = WSABASEERR + 4;
	WSAEBADF  = WSABASEERR + 9;
	WSAEACCES = WSABASEERR + 13;
	WSAEFAULT = WSABASEERR + 14;
	WSAEINVAL = WSABASEERR + 22;
	WSAEMFILE = WSABASEERR + 24;

	// Windows Sockets definitions of regular Berkeley error constants

	WSAEWOULDBLOCK     = WSABASEERR + 35;
	WSAEINPROGRESS     = WSABASEERR + 36;
	WSAEALREADY        = WSABASEERR + 37;
	WSAENOTSOCK        = WSABASEERR + 38;
	WSAEDESTADDRREQ    = WSABASEERR + 39;
	WSAEMSGSIZE        = WSABASEERR + 40;
	WSAEPROTOTYPE      = WSABASEERR + 41;
	WSAENOPROTOOPT     = WSABASEERR + 42;
	WSAEPROTONOSUPPORT = WSABASEERR + 43;
	WSAESOCKTNOSUPPORT = WSABASEERR + 44;
	WSAEOPNOTSUPP      = WSABASEERR + 45;
	WSAEPFNOSUPPORT    = WSABASEERR + 46;
	WSAEAFNOSUPPORT    = WSABASEERR + 47;
	WSAEADDRINUSE      = WSABASEERR + 48;
	WSAEADDRNOTAVAIL   = WSABASEERR + 49;
	WSAENETDOWN        = WSABASEERR + 50;
	WSAENETUNREACH     = WSABASEERR + 51;
	WSAENETRESET       = WSABASEERR + 52;
	WSAECONNABORTED    = WSABASEERR + 53;
	WSAECONNRESET      = WSABASEERR + 54;
	WSAENOBUFS         = WSABASEERR + 55;
	WSAEISCONN         = WSABASEERR + 56;
	WSAENOTCONN        = WSABASEERR + 57;
	WSAESHUTDOWN       = WSABASEERR + 58;
	WSAETOOMANYREFS    = WSABASEERR + 59;
	WSAETIMEDOUT       = WSABASEERR + 60;
	WSAECONNREFUSED    = WSABASEERR + 61;
	WSAELOOP           = WSABASEERR + 62;
	WSAENAMETOOLONG    = WSABASEERR + 63;
	WSAEHOSTDOWN       = WSABASEERR + 64;
	WSAEHOSTUNREACH    = WSABASEERR + 65;
	WSAENOTEMPTY       = WSABASEERR + 66;
	WSAEPROCLIM        = WSABASEERR + 67;
	WSAEUSERS          = WSABASEERR + 68;
	WSAEDQUOT          = WSABASEERR + 69;
	WSAESTALE          = WSABASEERR + 70;
	WSAEREMOTE         = WSABASEERR + 71;

	// Extended Windows Sockets error constant definitions

	WSASYSNOTREADY         = WSABASEERR + 91;
	WSAVERNOTSUPPORTED     = WSABASEERR + 92;
	WSANOTINITIALISED      = WSABASEERR + 93;
	WSAEDISCON             = WSABASEERR + 101;
	WSAENOMORE             = WSABASEERR + 102;
	WSAECANCELLED          = WSABASEERR + 103;
	WSAEINVALIDPROCTABLE   = WSABASEERR + 104;
	WSAEINVALIDPROVIDER    = WSABASEERR + 105;
	WSAEPROVIDERFAILEDINIT = WSABASEERR + 106;
	WSASYSCALLFAILURE      = WSABASEERR + 107;
	WSASERVICE_NOT_FOUND   = WSABASEERR + 108;
	WSATYPE_NOT_FOUND      = WSABASEERR + 109;
	WSA_E_NO_MORE          = WSABASEERR + 110;
	WSA_E_CANCELLED        = WSABASEERR + 111;
	WSAEREFUSED            = WSABASEERR + 112;

	{ Error return codes from gethostbyname() and gethostbyaddr()
	  (when using the resolver). Note that these errors are
	 retrieved via WSAGetLastError() and must therefore follow
	 the rules for avoiding clashes with error numbers from
	 specific implementations or language run-time systems.
	 For this reason the codes are based at WSABASEERR+1001.
	 Note also that [WSA]NO_ADDRESS is defined only for
	 compatibility purposes. }

	// Authoritative Answer: Host not found
	WSAHOST_NOT_FOUND = WSABASEERR + 1001;
	HOST_NOT_FOUND    = WSAHOST_NOT_FOUND;

	// Non-Authoritative: Host not found, or SERVERFAIL
	WSATRY_AGAIN = WSABASEERR + 1002;
	TRY_AGAIN    = WSATRY_AGAIN;

	// Non recoverable errors, FORMERR, REFUSED, NOTIMP
	WSANO_RECOVERY = WSABASEERR + 1003;
	NO_RECOVERY    = WSANO_RECOVERY;

	// Valid name, no data record of requested type
	WSANO_DATA = WSABASEERR + 1004;
	NO_DATA    = WSANO_DATA;

	// no address, look for MX record
	WSANO_ADDRESS = WSANO_DATA;
	NO_ADDRESS    = WSANO_ADDRESS;

	// Define QOS related error return codes

	WSA_QOS_RECEIVERS         = WSABASEERR + 1005; // at least one Reserve has arrived
	WSA_QOS_SENDERS           = WSABASEERR + 1006; // at least one Path has arrived
	WSA_QOS_NO_SENDERS        = WSABASEERR + 1007; // there are no senders
	WSA_QOS_NO_RECEIVERS      = WSABASEERR + 1008; // there are no receivers
	WSA_QOS_REQUEST_CONFIRMED = WSABASEERR + 1009; // Reserve has been confirmed
	WSA_QOS_ADMISSION_FAILURE = WSABASEERR + 1010; // error due to lack of resources
	WSA_QOS_POLICY_FAILURE    = WSABASEERR + 1011; // rejected for administrative reasons - bad credentials
	WSA_QOS_BAD_STYLE         = WSABASEERR + 1012; // unknown or conflicting style
	WSA_QOS_BAD_OBJECT        = WSABASEERR + 1013;
	// problem with some part of the filterspec or providerspecific buffer in general
	WSA_QOS_TRAFFIC_CTRL_ERROR = WSABASEERR + 1014; // problem with some part of the flowspec
	WSA_QOS_GENERIC_ERROR      = WSABASEERR + 1015; // general error
	WSA_QOS_ESERVICETYPE       = WSABASEERR + 1016; // invalid service type in flowspec
	WSA_QOS_EFLOWSPEC          = WSABASEERR + 1017; // invalid flowspec
	WSA_QOS_EPROVSPECBUF       = WSABASEERR + 1018; // invalid provider specific buffer
	WSA_QOS_EFILTERSTYLE       = WSABASEERR + 1019; // invalid filter style
	WSA_QOS_EFILTERTYPE        = WSABASEERR + 1020; // invalid filter type
	WSA_QOS_EFILTERCOUNT       = WSABASEERR + 1021; // incorrect number of filters
	WSA_QOS_EOBJLENGTH         = WSABASEERR + 1022; // invalid object length
	WSA_QOS_EFLOWCOUNT         = WSABASEERR + 1023; // incorrect number of flows
	WSA_QOS_EUNKOWNPSOBJ       = WSABASEERR + 1024; // unknown object in provider specific buffer
	WSA_QOS_EPOLICYOBJ         = WSABASEERR + 1025; // invalid policy object in provider specific buffer
	WSA_QOS_EFLOWDESC          = WSABASEERR + 1026; // invalid flow descriptor in the list
	WSA_QOS_EPSFLOWSPEC        = WSABASEERR + 1027; // inconsistent flow spec in provider specific buffer
	WSA_QOS_EPSFILTERSPEC      = WSABASEERR + 1028; // invalid filter spec in provider specific buffer
	WSA_QOS_ESDMODEOBJ         = WSABASEERR + 1029; // invalid shape discard mode object in provider specific buffer
	WSA_QOS_ESHAPERATEOBJ      = WSABASEERR + 1030; // invalid shaping rate object in provider specific buffer
	WSA_QOS_RESERVED_PETYPE    = WSABASEERR + 1031; // reserved policy element in provider specific buffer

	{ WinSock 2 extension -- new error codes and type definition }
	WSA_IO_PENDING          = ERROR_IO_PENDING;
	WSA_IO_INCOMPLETE       = ERROR_IO_INCOMPLETE;
	WSA_INVALID_HANDLE      = ERROR_INVALID_HANDLE;
	WSA_INVALID_PARAMETER   = ERROR_INVALID_PARAMETER;
	WSA_NOT_ENOUGH_MEMORY   = ERROR_NOT_ENOUGH_MEMORY;
	WSA_OPERATION_ABORTED   = ERROR_OPERATION_ABORTED;
	WSA_INVALID_EVENT       = WSAEVENT(nil);
	WSA_MAXIMUM_WAIT_EVENTS = MAXIMUM_WAIT_OBJECTS;
	WSA_WAIT_FAILED         = $FFFFFFFF;
	WSA_WAIT_EVENT_0        = WAIT_OBJECT_0;
	WSA_WAIT_IO_COMPLETION  = WAIT_IO_COMPLETION;
	WSA_WAIT_TIMEOUT        = WAIT_TIMEOUT;
	WSA_INFINITE            = INFINITE;

	{ Windows Sockets errors redefined as regular Berkeley error constants.
	  These are commented out in Windows NT to avoid conflicts with errno.h.
	 Use the WSA constants instead. }

	EWOULDBLOCK     = WSAEWOULDBLOCK;
	EINPROGRESS     = WSAEINPROGRESS;
	EALREADY        = WSAEALREADY;
	ENOTSOCK        = WSAENOTSOCK;
	EDESTADDRREQ    = WSAEDESTADDRREQ;
	EMSGSIZE        = WSAEMSGSIZE;
	EPROTOTYPE      = WSAEPROTOTYPE;
	ENOPROTOOPT     = WSAENOPROTOOPT;
	EPROTONOSUPPORT = WSAEPROTONOSUPPORT;
	ESOCKTNOSUPPORT = WSAESOCKTNOSUPPORT;
	EOPNOTSUPP      = WSAEOPNOTSUPP;
	EPFNOSUPPORT    = WSAEPFNOSUPPORT;
	EAFNOSUPPORT    = WSAEAFNOSUPPORT;
	EADDRINUSE      = WSAEADDRINUSE;
	EADDRNOTAVAIL   = WSAEADDRNOTAVAIL;
	ENETDOWN        = WSAENETDOWN;
	ENETUNREACH     = WSAENETUNREACH;
	ENETRESET       = WSAENETRESET;
	ECONNABORTED    = WSAECONNABORTED;
	ECONNRESET      = WSAECONNRESET;
	ENOBUFS         = WSAENOBUFS;
	EISCONN         = WSAEISCONN;
	ENOTCONN        = WSAENOTCONN;
	ESHUTDOWN       = WSAESHUTDOWN;
	ETOOMANYREFS    = WSAETOOMANYREFS;
	ETIMEDOUT       = WSAETIMEDOUT;
	ECONNREFUSED    = WSAECONNREFUSED;
	ELOOP           = WSAELOOP;
	ENAMETOOLONG    = WSAENAMETOOLONG;
	EHOSTDOWN       = WSAEHOSTDOWN;
	EHOSTUNREACH    = WSAEHOSTUNREACH;
	ENOTEMPTY       = WSAENOTEMPTY;
	EPROCLIM        = WSAEPROCLIM;
	EUSERS          = WSAEUSERS;
	EDQUOT          = WSAEDQUOT;
	ESTALE          = WSAESTALE;
	EREMOTE         = WSAEREMOTE;

	WSADESCRIPTION_LEN = 256;
	WSASYS_STATUS_LEN  = 128;

type
	PWSAData = ^TWSAData;

	TWSAData = packed record
		wVersion: Word;
		wHighVersion: Word;
		szDescription: array [0 .. WSADESCRIPTION_LEN] of AnsiChar;
		szSystemStatus: array [0 .. WSASYS_STATUS_LEN] of AnsiChar;
		iMaxSockets: Word;
		iMaxUdpDg: Word;
		lpVendorInfo: PAnsiChar;
	end;

	{ WSAOVERLAPPED = Record
	  Internal: LongInt;
	 InternalHigh: LongInt;
	 Offset: LongInt;
	 OffsetHigh: LongInt;
	 hEvent: WSAEVENT;
	 end; }
	WSAOVERLAPPED   = TOverlapped;
	TWSAOverlapped  = WSAOVERLAPPED;
	PWSAOverlapped  = ^WSAOVERLAPPED;
	LPWSAOVERLAPPED = PWSAOverlapped;

	{ WinSock 2 extension -- WSABUF and QOS struct, include qos.h }
	{ to pull in FLOWSPEC and related definitions }

	WSABUF = packed record
		len: u_long;  { the length of the buffer }
		buf: pointer; { the pointer to the buffer }
	end { WSABUF };

	PWSABUF  = ^WSABUF;
	LPWSABUF = PWSABUF;

	TServiceType = Longint;

	TFlowSpec = packed record
		TokenRate,               // In Bytes/sec
		TokenBucketSize,         // In Bytes
		PeakBandwidth,           // In Bytes/sec
		Latency,                 // In microseconds
		DelayVariation: Longint; // In microseconds
		ServiceType: TServiceType;
		MaxSduSize, MinimumPolicedSize: Longint; // In Bytes
	end;

	PFlowSpec = ^TFlowSpec;

	QOS = packed record
		SendingFlowspec: TFlowSpec;   { the flow spec for data sending }
		ReceivingFlowspec: TFlowSpec; { the flow spec for data receiving }
		ProviderSpecific: WSABUF;     { additional provider specific stuff }
	end;

	TQualityOfService = QOS;
	PQOS              = ^QOS;
	LPQOS             = PQOS;

const
	SERVICETYPE_NOTRAFFIC           = $00000000; // No data in this direction
	SERVICETYPE_BESTEFFORT          = $00000001; // Best Effort
	SERVICETYPE_CONTROLLEDLOAD      = $00000002; // Controlled Load
	SERVICETYPE_GUARANTEED          = $00000003; // Guaranteed
	SERVICETYPE_NETWORK_UNAVAILABLE = $00000004; // Used to notify change to user
	SERVICETYPE_GENERAL_INFORMATION = $00000005; // corresponds to "General Parameters" defined by IntServ
	SERVICETYPE_NOCHANGE            = $00000006;
	// used to indicate that the flow spec contains no change from any previous one
	// to turn on immediate traffic control, OR this flag with the ServiceType field in teh FLOWSPEC
	SERVICE_IMMEDIATE_TRAFFIC_CONTROL = $80000000;

	// WinSock 2 extension -- manifest constants for return values of the condition function
	CF_ACCEPT = $0000;
	CF_REJECT = $0001;
	CF_DEFER  = $0002;

	// WinSock 2 extension -- manifest constants for shutdown()
	SD_RECEIVE = $00;
	SD_SEND    = $01;
	SD_BOTH    = $02;

	// WinSock 2 extension -- data type and manifest constants for socket groups
	SG_UNCONSTRAINED_GROUP = $01;
	SG_CONSTRAINED_GROUP   = $02;

type
	GROUP = DWORD;

	// WinSock 2 extension -- data type for WSAEnumNetworkEvents()
	TWSANetworkEvents = record
		lNetworkEvents: Longint;
		iErrorCode: array [0 .. FD_MAX_EVENTS - 1] of integer;
	end;

	PWSANetworkEvents  = ^TWSANetworkEvents;
	LPWSANetworkEvents = PWSANetworkEvents;

	// WinSock 2 extension -- WSAPROTOCOL_INFO structure

{$IFNDEF ver130}

	TGUID = packed record
		D1: Longint;
		D2: Word;
		D3: Word;
		D4: array [0 .. 7] of Byte;
	end;

	PGUID = ^TGUID;
{$ENDIF}
	LPGUID = PGUID;

	// WinSock 2 extension -- WSAPROTOCOL_INFO manifest constants
const
	MAX_PROTOCOL_CHAIN = 7;
	BASE_PROTOCOL      = 1;
	LAYERED_PROTOCOL   = 0;
	WSAPROTOCOL_LEN    = 255;

type
	TWSAProtocolChain = record
		ChainLen: integer; // the length of the chain,
		// length = 0 means layered protocol,
		// length = 1 means base protocol,
		// length > 1 means protocol chain
		ChainEntries: array [0 .. MAX_PROTOCOL_CHAIN - 1] of Longint; // a list of dwCatalogEntryIds
	end;

type
	TWSAProtocol_InfoA = record
		dwServiceFlags1: Longint;
		dwServiceFlags2: Longint;
		dwServiceFlags3: Longint;
		dwServiceFlags4: Longint;
		dwProviderFlags: Longint;
		ProviderId: TGUID;
		dwCatalogEntryId: Longint;
		ProtocolChain: TWSAProtocolChain;
		iVersion: integer;
		iAddressFamily: integer;
		iMaxSockAddr: integer;
		iMinSockAddr: integer;
		iSocketType: integer;
		iProtocol: integer;
		iProtocolMaxOffset: integer;
		iNetworkByteOrder: integer;
		iSecurityScheme: integer;
		dwMessageSize: Longint;
		dwProviderReserved: Longint;
		szProtocol: array [0 .. WSAPROTOCOL_LEN + 1 - 1] of Char;
	end { TWSAProtocol_InfoA };

	PWSAProtocol_InfoA  = ^TWSAProtocol_InfoA;
	LPWSAProtocol_InfoA = PWSAProtocol_InfoA;

	TWSAProtocol_InfoW = record
		dwServiceFlags1: Longint;
		dwServiceFlags2: Longint;
		dwServiceFlags3: Longint;
		dwServiceFlags4: Longint;
		dwProviderFlags: Longint;
		ProviderId: TGUID;
		dwCatalogEntryId: Longint;
		ProtocolChain: TWSAProtocolChain;
		iVersion: integer;
		iAddressFamily: integer;
		iMaxSockAddr: integer;
		iMinSockAddr: integer;
		iSocketType: integer;
		iProtocol: integer;
		iProtocolMaxOffset: integer;
		iNetworkByteOrder: integer;
		iSecurityScheme: integer;
		dwMessageSize: Longint;
		dwProviderReserved: Longint;
		szProtocol: array [0 .. WSAPROTOCOL_LEN + 1 - 1] of WideChar;
	end { TWSAProtocol_InfoW };

	PWSAProtocol_InfoW  = ^TWSAProtocol_InfoW;
	LPWSAProtocol_InfoW = PWSAProtocol_InfoW;

{$IFDEF UNICODE}
	WSAProtocol_Info   = TWSAProtocol_InfoW;
	TWSAProtocol_Info  = TWSAProtocol_InfoW;
	PWSAProtocol_Info  = PWSAProtocol_InfoW;
	LPWSAProtocol_Info = PWSAProtocol_InfoW;
{$ELSE}
	WSAProtocol_Info   = TWSAProtocol_InfoA;
	TWSAProtocol_Info  = TWSAProtocol_InfoA;
	PWSAProtocol_Info  = PWSAProtocol_InfoA;
	LPWSAProtocol_Info = PWSAProtocol_InfoA;
{$ENDIF}


const
	// Flag bit definitions for dwProviderFlags
	PFL_MULTIPLE_PROTO_ENTRIES  = $00000001;
	PFL_RECOMMENDED_PROTO_ENTRY = $00000002;
	PFL_HIDDEN                  = $00000004;
	PFL_MATCHES_PROTOCOL_ZERO   = $00000008;

	// Flag bit definitions for dwServiceFlags1
	XP1_CONNECTIONLESS           = $00000001;
	XP1_GUARANTEED_DELIVERY      = $00000002;
	XP1_GUARANTEED_ORDER         = $00000004;
	XP1_MESSAGE_ORIENTED         = $00000008;
	XP1_PSEUDO_STREAM            = $00000010;
	XP1_GRACEFUL_CLOSE           = $00000020;
	XP1_EXPEDITED_DATA           = $00000040;
	XP1_CONNECT_DATA             = $00000080;
	XP1_DISCONNECT_DATA          = $00000100;
	XP1_SUPPORT_BROADCAST        = $00000200;
	XP1_SUPPORT_MULTIPOINT       = $00000400;
	XP1_MULTIPOINT_CONTROL_PLANE = $00000800;
	XP1_MULTIPOINT_DATA_PLANE    = $00001000;
	XP1_QOS_SUPPORTED            = $00002000;
	XP1_INTERRUPT                = $00004000;
	XP1_UNI_SEND                 = $00008000;
	XP1_UNI_RECV                 = $00010000;
	XP1_IFS_HANDLES              = $00020000;
	XP1_PARTIAL_MESSAGE          = $00040000;

	BIGENDIAN    = $0000;
	LITTLEENDIAN = $0001;

	SECURITY_PROTOCOL_NONE = $0000;

	// WinSock 2 extension -- manifest constants for WSAJoinLeaf()
	JL_SENDER_ONLY   = $01;
	JL_RECEIVER_ONLY = $02;
	JL_BOTH          = $04;

	// WinSock 2 extension -- manifest constants for WSASocket()
	WSA_FLAG_OVERLAPPED        = $01;
	WSA_FLAG_MULTIPOINT_C_ROOT = $02;
	WSA_FLAG_MULTIPOINT_C_LEAF = $04;
	WSA_FLAG_MULTIPOINT_D_ROOT = $08;
	WSA_FLAG_MULTIPOINT_D_LEAF = $10;

	// WinSock 2 extension -- manifest constants for WSAIoctl()
	IOC_UNIX     = $00000000;
	IOC_WS2      = $08000000;
	IOC_PROTOCOL = $10000000;
	IOC_VENDOR   = $18000000;

	SIO_ASSOCIATE_HANDLE               = 1 or IOC_WS2 or IOC_IN;
	SIO_ENABLE_CIRCULAR_QUEUEING       = 2 or IOC_WS2;
	SIO_FIND_ROUTE                     = 3 or IOC_WS2 or IOC_OUT;
	SIO_FLUSH                          = 4 or IOC_WS2;
	SIO_GET_BROADCAST_ADDRESS          = 5 or IOC_WS2 or IOC_OUT;
	SIO_GET_EXTENSION_FUNCTION_POINTER = 6 or IOC_WS2 or IOC_INOUT;
	SIO_GET_QOS                        = 7 or IOC_WS2 or IOC_INOUT;
	SIO_GET_GROUP_QOS                  = 8 or IOC_WS2 or IOC_INOUT;
	SIO_MULTIPOINT_LOOPBACK            = 9 or IOC_WS2 or IOC_IN;
	SIO_MULTICAST_SCOPE                = 10 or IOC_WS2 or IOC_IN;
	SIO_SET_QOS                        = 11 or IOC_WS2 or IOC_IN;
	SIO_SET_GROUP_QOS                  = 12 or IOC_WS2 or IOC_IN;
	SIO_TRANSLATE_HANDLE               = 13 or IOC_WS2 or IOC_INOUT;
	SIO_ROUTING_INTERFACE_QUERY        = 20 or IOC_WS2 or IOC_INOUT;
	SIO_ROUTING_INTERFACE_CHANGE       = 21 or IOC_WS2 or IOC_IN;
	SIO_ADDRESS_LIST_QUERY             = 22 or IOC_WS2 or IOC_OUT; // see below SOCKET_ADDRESS_LIST
	SIO_ADDRESS_LIST_CHANGE            = 23 or IOC_WS2;
	SIO_QUERY_TARGET_PNP_HANDLE        = 24 or IOC_WS2 or IOC_OUT;

	// WinSock 2 extension -- manifest constants for SIO_TRANSLATE_HANDLE ioctl
	TH_NETDEV = $00000001;
	TH_TAPI   = $00000002;

type

	// Manifest constants and type definitions related to name resolution and
	// registration (RNR) API
	TBLOB = packed record
		cbSize: u_long;
		pBlobData: PBYTE;
	end;

	PBLOB = ^TBLOB;

	// Service Install Flags

const
	SERVICE_MULTIPLE = $00000001;

	// & Name Spaces
	NS_ALL = 0;

	NS_SAP         = 1;
	NS_NDS         = 2;
	NS_PEER_BROWSE = 3;

	NS_TCPIP_LOCAL = 10;
	NS_TCPIP_HOSTS = 11;
	NS_DNS         = 12;
	NS_NETBT       = 13;
	NS_WINS        = 14;

	NS_NBP = 20;

	NS_MS   = 30;
	NS_STDA = 31;
	NS_NTDS = 32;

	NS_X500    = 40;
	NS_NIS     = 41;
	NS_NISPLUS = 42;

	NS_WRQ = 50;

	NS_NETDES = 60;

	{ Resolution flags for WSAGetAddressByName().
	  Note these are also used by the 1.1 API GetAddressByName, so leave them around. }
	RES_UNUSED_1    = $00000001;
	RES_FLUSH_CACHE = $00000002;
	RES_SERVICE     = $00000004;

	{ Well known value names for Service Types }
	SERVICE_TYPE_VALUE_IPXPORTA            = 'IpxSocket';
	SERVICE_TYPE_VALUE_IPXPORTW: PWideChar = 'IpxSocket';

{$IFDEF UNICODE}
	SERVICE_TYPE_VALUE_SAPID: PWideChar    = 'SapId';
	SERVICE_TYPE_VALUE_TCPPORT: PWideChar  = 'TcpPort';
	SERVICE_TYPE_VALUE_UDPPORT: PWideChar  = 'UdpPort';
	SERVICE_TYPE_VALUE_OBJECTID: PWideChar = 'ObjectId';
{$ELSE}
	SERVICE_TYPE_VALUE_SAPID: PAnsiChar    = 'SapId';
	SERVICE_TYPE_VALUE_TCPPORT: PAnsiChar  = 'TcpPort';
	SERVICE_TYPE_VALUE_UDPPORT: PAnsiChar  = 'UdpPort';
	SERVICE_TYPE_VALUE_OBJECTID: PAnsiChar = 'ObjectId';
{$ENDIF}

	// SockAddr Information
type
	SOCKET_ADDRESS = packed record
		lpSockaddr: PSockAddr;
		iSockaddrLength: integer;
	end;

	PSOCKET_ADDRESS = ^SOCKET_ADDRESS;

	// CSAddr Information
	CSADDR_INFO = packed record
		LocalAddr, RemoteAddr: SOCKET_ADDRESS;
		iSocketType, iProtocol: Longint;
	end;

	PCSADDR_INFO  = ^CSADDR_INFO;
	LPCSADDR_INFO = ^CSADDR_INFO;


	//
	// Portable socket structure (RFC 2553).
	//

	//
	// Desired design of maximum size and alignment.
	// These are implementation specific.
	//

const
	_SS_MAXSIZE = 128; // Maximum size.
{$EXTERNALSYM _SS_MAXSIZE}
	_SS_ALIGNSIZE = SizeOf(Int64); // Desired alignment.
{$EXTERNALSYM _SS_ALIGNSIZE}

	//
	// Definitions used for sockaddr_storage structure paddings design.
	//

	_SS_PAD1SIZE = _SS_ALIGNSIZE - SizeOf(short);
{$EXTERNALSYM _SS_PAD1SIZE}
	_SS_PAD2SIZE = _SS_MAXSIZE - (SizeOf(short) + _SS_PAD1SIZE + _SS_ALIGNSIZE);
{$EXTERNALSYM _SS_PAD2SIZE}


type
	sockaddr_storage = record
		ss_family: short; // Address family.
		__ss_pad1: array [0 .. _SS_PAD1SIZE - 1] of AnsiChar; // 6 byte pad, this is to make
		// implementation specific pad up to
		// alignment field that follows explicit
		// in the data structure.
		__ss_align: Int64; // Field to force desired structure.
		__ss_pad2: array [0 .. _SS_PAD2SIZE - 1] of AnsiChar; // 112 byte pad to achieve desired size;
		// _SS_MAXSIZE value minus size of
		// ss_family, __ss_pad1, and
		// __ss_align fields is 112.
	end;
{$EXTERNALSYM sockaddr_storage}

	TSockAddrStorage = sockaddr_storage;
	PSockAddrStorage = ^sockaddr_storage;

	// Address list returned via WSAIoctl( SIO_ADDRESS_LIST_QUERY )
	SOCKET_ADDRESS_LIST = packed record
		iAddressCount: integer;
		Address: array [0 .. 0] of SOCKET_ADDRESS;
	end;

	LPSOCKET_ADDRESS_LIST = ^SOCKET_ADDRESS_LIST;

	// Address Family/Protocol Tuples
	AFProtocols = record
		iAddressFamily: integer;
		iProtocol: integer;
	end;

	TAFProtocols = AFProtocols;
	PAFProtocols = ^TAFProtocols;


	// Client Query API Typedefs

	// The comparators
	TWSAEComparator = (COMP_EQUAL { = 0 } , COMP_NOTLESS);

	TWSAVersion = record
		dwVersion: DWORD;
		ecHow: TWSAEComparator;
	end;

	PWSAVersion = ^TWSAVersion;

	TWSAQuerySetA = packed record
		dwSize: DWORD;
		lpszServiceInstanceName: PAnsiChar;
		lpServiceClassId: PGUID;
		lpVersion: PWSAVersion;
		lpszComment: PAnsiChar;
		dwNameSpace: DWORD;
		lpNSProviderId: PGUID;
		lpszContext: PAnsiChar;
		dwNumberOfProtocols: DWORD;
		lpafpProtocols: PAFProtocols;
		lpszQueryString: PAnsiChar;
		dwNumberOfCsAddrs: DWORD;
		lpcsaBuffer: PCSADDR_INFO;
		dwOutputFlags: DWORD;
		lpBlob: PBLOB;
	end;

	PWSAQuerySetA  = ^TWSAQuerySetA;
	LPWSAQuerySetA = PWSAQuerySetA;

	TWSAQuerySetW = packed record
		dwSize: DWORD;
		lpszServiceInstanceName: PWideChar;
		lpServiceClassId: PGUID;
		lpVersion: PWSAVersion;
		lpszComment: PWideChar;
		dwNameSpace: DWORD;
		lpNSProviderId: PGUID;
		lpszContext: PWideChar;
		dwNumberOfProtocols: DWORD;
		lpafpProtocols: PAFProtocols;
		lpszQueryString: PWideChar;
		dwNumberOfCsAddrs: DWORD;
		lpcsaBuffer: PCSADDR_INFO;
		dwOutputFlags: DWORD;
		lpBlob: PBLOB;
	end;

	PWSAQuerySetW  = ^TWSAQuerySetW;
	LPWSAQuerySetW = PWSAQuerySetW;

{$IFDEF UNICODE}
	TWSAQuerySet  = TWSAQuerySetA;
	PWSAQuerySet  = PWSAQuerySetW;
	LPWSAQuerySet = PWSAQuerySetW;
{$ELSE}
	TWSAQuerySet  = TWSAQuerySetA;
	PWSAQuerySet  = PWSAQuerySetA;
	LPWSAQuerySet = PWSAQuerySetA;
{$ENDIF}


const
	LUP_DEEP                = $0001;
	LUP_CONTAINERS          = $0002;
	LUP_NOCONTAINERS        = $0004;
	LUP_NEAREST             = $0008;
	LUP_RETURN_NAME         = $0010;
	LUP_RETURN_TYPE         = $0020;
	LUP_RETURN_VERSION      = $0040;
	LUP_RETURN_COMMENT      = $0080;
	LUP_RETURN_ADDR         = $0100;
	LUP_RETURN_BLOB         = $0200;
	LUP_RETURN_ALIASES      = $0400;
	LUP_RETURN_QUERY_STRING = $0800;
	LUP_RETURN_ALL          = $0FF0;
	LUP_RES_SERVICE         = $8000;

	LUP_FLUSHCACHE    = $1000;
	LUP_FLUSHPREVIOUS = $2000;

	// Return flags
	RESULT_IS_ALIAS = $0001;

type
	// Service Address Registration and Deregistration Data Types.
	TWSAeSetServiceOp = (RNRSERVICE_REGISTER { =0 } , RNRSERVICE_DEREGISTER, RNRSERVICE_DELETE);

	{ Service Installation/Removal Data Types. }
	TWSANSClassInfoA = packed record
		lpszName: PAnsiChar;
		dwNameSpace: DWORD;
		dwValueType: DWORD;
		dwValueSize: DWORD;
		lpValue: pointer;
	end;

	PWSANSClassInfoA = ^TWSANSClassInfoA;

	TWSANSClassInfoW = packed record
		lpszName: PWideChar;
		dwNameSpace: DWORD;
		dwValueType: DWORD;
		dwValueSize: DWORD;
		lpValue: pointer;
	end { TWSANSClassInfoW };

	PWSANSClassInfoW = ^TWSANSClassInfoW;

{$IFDEF UNICODE}
	WSANSClassInfo   = TWSANSClassInfoW;
	TWSANSClassInfo  = TWSANSClassInfoW;
	PWSANSClassInfo  = PWSANSClassInfoW;
	LPWSANSClassInfo = PWSANSClassInfoW;
{$ELSE}
	WSANSClassInfo   = TWSANSClassInfoA;
	TWSANSClassInfo  = TWSANSClassInfoA;
	PWSANSClassInfo  = PWSANSClassInfoA;
	LPWSANSClassInfo = PWSANSClassInfoA;
{$ENDIF // UNICODE}

	TWSAServiceClassInfoA = packed record
		lpServiceClassId: PGUID;
		lpszServiceClassName: PAnsiChar;
		dwCount: DWORD;
		lpClassInfos: PWSANSClassInfoA;
	end;

	PWSAServiceClassInfoA  = ^TWSAServiceClassInfoA;
	LPWSAServiceClassInfoA = PWSAServiceClassInfoA;

	TWSAServiceClassInfoW = packed record
		lpServiceClassId: PGUID;
		lpszServiceClassName: PWideChar;
		dwCount: DWORD;
		lpClassInfos: PWSANSClassInfoW;
	end;

	PWSAServiceClassInfoW  = ^TWSAServiceClassInfoW;
	LPWSAServiceClassInfoW = PWSAServiceClassInfoW;

{$IFDEF UNICODE}
	WSAServiceClassInfo   = TWSAServiceClassInfoW;
	TWSAServiceClassInfo  = TWSAServiceClassInfoW;
	PWSAServiceClassInfo  = PWSAServiceClassInfoW;
	LPWSAServiceClassInfo = PWSAServiceClassInfoW;
{$ELSE}
	WSAServiceClassInfo   = TWSAServiceClassInfoA;
	TWSAServiceClassInfo  = TWSAServiceClassInfoA;
	PWSAServiceClassInfo  = PWSAServiceClassInfoA;
	LPWSAServiceClassInfo = PWSAServiceClassInfoA;
{$ENDIF}

	TWSANameSpace_InfoA = packed record
		NSProviderId: TGUID;
		dwNameSpace: DWORD;
		fActive: DWORD { Bool };
		dwVersion: DWORD;
		lpszIdentifier: PAnsiChar;
	end;

	PWSANameSpace_InfoA  = ^TWSANameSpace_InfoA;
	LPWSANameSpace_InfoA = PWSANameSpace_InfoA;

	TWSANameSpace_InfoW = packed record
		NSProviderId: TGUID;
		dwNameSpace: DWORD;
		fActive: DWORD { Bool };
		dwVersion: DWORD;
		lpszIdentifier: PWideChar;
	end { TWSANameSpace_InfoW };

	PWSANameSpace_InfoW  = ^TWSANameSpace_InfoW;
	LPWSANameSpace_InfoW = PWSANameSpace_InfoW;

{$IFDEF UNICODE}
	WSANameSpace_Info   = TWSANameSpace_InfoW;
	TWSANameSpace_Info  = TWSANameSpace_InfoW;
	PWSANameSpace_Info  = PWSANameSpace_InfoW;
	LPWSANameSpace_Info = PWSANameSpace_InfoW;
{$ELSE}
	WSANameSpace_Info   = TWSANameSpace_InfoA;
	TWSANameSpace_Info  = TWSANameSpace_InfoA;
	PWSANameSpace_Info  = PWSANameSpace_InfoA;
	LPWSANameSpace_Info = PWSANameSpace_InfoA;
{$ENDIF}


{ WinSock 2 extensions -- data types for the condition function in }
{ WSAAccept() and overlapped I/O completion routine. }
type
	LPCONDITIONPROC = function(lpCallerId: LPWSABUF; lpCallerData: LPWSABUF; lpSQOS, lpGQOS: LPQOS; lpCalleeId, lpCalleeData: LPWSABUF; g: GROUP;
	  dwCallbackData: DWORD): integer; stdcall;

	LPWSAOVERLAPPED_COMPLETION_ROUTINE = procedure(const dwError, cbTransferred: DWORD; const lpOverlapped: LPWSAOVERLAPPED; const dwFlags: DWORD); stdcall;

	LPFN_CONNECTEX = function(s: TSocket; const SOCKADDR: PSockAddr; namelen: integer; lpSendBuffer: pointer; dwSendDataLength: DWORD; lpdwBytesSent: PDWORD;
	  lpOverlapped: POverlapped): BOOL; stdcall;

	LPFN_ACCEPTEX = function(sListenSocket, sAcceptSocket: TSocket; lpOutputBuffer: LPVOID;
	  dwReceiveDataLength, dwLocalAddressLength, dwRemoteAddressLength: DWORD; var lpdwBytesReceived: DWORD; lpOverlapped: POverlapped): BOOL; stdcall;

	LPFN_TRANSMITFILE = function(hSocket: TSocket; hFile: THandle; nNumberOfBytesToWrite: DWORD; nNumberOfBytesPerSend: DWORD; lpOverlapped: POverlapped;
	  lpTransmitBuffers: pointer; dwFlags: DWORD): BOOL; stdcall;

	LPFN_GETACCEPTEXSOCKADDRS = procedure(lpOutputBuffer: LPVOID; dwReceiveDataLength, dwLocalAddressLength, dwRemoteAddressLength: DWORD;
	  var LocalSockaddr: PSockAddr; var LocalSockaddrLength: integer; var RemoteSockaddr: PSockAddr; var RemoteSockaddrLength: integer); stdcall;

const

	// Flags for getnameinfo()

	NI_NOFQDN      = $01; // Only return nodename portion for local hosts
	NI_NUMERICHOST = $02; // Return numeric form of the host's address
	NI_NAMEREQD    = $04; // Error if the host's name not in DNS
	NI_NUMERICSERV = $08; // Return numeric form of the service (port #)
	NI_DGRAM       = $10; // Service is a datagram service

	NI_MAXHOST = 1025; // Max size of a fully-qualified domain name
	NI_MAXSERV = 32;   // Max size of a service name

function accept(const s: TSocket; var addr: TSockAddr; var addrlen: integer): TSocket; stdcall;
function bind(const s: TSocket; const addr: PSockAddr; const namelen: integer): integer; stdcall;
function closesocket(const s: TSocket): integer; stdcall;
function connect(const s: TSocket; const name: PSockAddr; namelen: integer): integer; stdcall;
function ioctlsocket(const s: TSocket; const cmd: DWORD; var arg: u_long): integer; stdcall;
function getpeername(const s: TSocket; var name: TSockAddr; var namelen: integer): integer; stdcall;
function getsockname(const s: TSocket; var name: TSockAddr; var namelen: integer): integer; stdcall;
function getsockopt(const s: TSocket; const level, optname: integer; optval: PAnsiChar; var optlen: integer): integer; stdcall;
function htonl(hostlong: u_long): u_long; stdcall;
function htons(hostshort: u_short): u_short; stdcall;
function inet_addr(cp: PAnsiChar): u_long; stdcall;
function inet_ntoa(inaddr: TInAddr): PAnsiChar; stdcall;
function listen(s: TSocket; backlog: integer): integer; stdcall;
function ntohl(netlong: u_long): u_long; stdcall;
function ntohs(netshort: u_short): u_short; stdcall;
function recv(s: TSocket; out buf; len, flags: integer): integer; stdcall;
function recvfrom(s: TSocket; var buf; len, flags: integer; var from: TSockAddr; var fromlen: integer): integer; stdcall;
function select(nfds: integer; readfds, writefds, exceptfds: PFDSet; timeout: PTimeVal): integer; stdcall;
function send(s: TSocket; const buf; len, flags: integer): integer; stdcall;
function sendto(s: TSocket; var buf; len, flags: integer; var addrto: TSockAddr; tolen: integer): integer; stdcall;
function setsockopt(s: TSocket; level, optname: integer; optval: PAnsiChar; optlen: integer): integer; stdcall;
function shutdown(s: TSocket; how: integer): integer; stdcall;
function socket(const af, struct, protocol: integer): TSocket; stdcall;
function gethostbyaddr(addr: pointer; len, struct: integer): PHostEnt; stdcall;
function gethostbyname(name: PAnsiChar): PHostEnt; stdcall;
function gethostname(name: PAnsiChar; len: integer): integer; stdcall;
function getservbyport(port: integer; proto: PAnsiChar): PServEnt; stdcall;
function getservbyname(const name, proto: PAnsiChar): PServEnt; stdcall;
function getprotobynumber(const proto: integer): PProtoEnt; stdcall;
function getprotobyname(const name: PAnsiChar): PProtoEnt; stdcall;
function GetAddrInfo(const nodename, servname: PChar; const hints: PAddrInfo; res: PPAddrInfo): integer; stdcall;
procedure FreeAddrInfo(ai: PAddrInfo); stdcall;
function WSAStartup(wVersionRequired: Word; var WSData: TWSAData): integer; stdcall;
function WSACleanup: integer; stdcall;
procedure WSASetLastError(iError: integer); stdcall;
function WSAGetLastError: integer; stdcall;
function WSAIsBlocking: BOOL; stdcall;
function WSAUnhookBlockingHook: integer; stdcall;
function WSASetBlockingHook(lpBlockFunc: TFarProc): TFarProc; stdcall;
function WSACancelBlockingCall: integer; stdcall;
function WSAAsyncGetServByName(HWindow: HWND; wMsg: u_int; name, proto, buf: PAnsiChar; buflen: integer): THandle; stdcall;
function WSAAsyncGetServByPort(HWindow: HWND; wMsg, port: u_int; proto, buf: PAnsiChar; buflen: integer): THandle; stdcall;
function WSAAsyncGetProtoByName(HWindow: HWND; wMsg: u_int; name, buf: PAnsiChar; buflen: integer): THandle; stdcall;
function WSAAsyncGetProtoByNumber(HWindow: HWND; wMsg: u_int; number: integer; buf: PAnsiChar; buflen: integer): THandle; stdcall;
function WSAAsyncGetHostByName(HWindow: HWND; wMsg: u_int; name, buf: PAnsiChar; buflen: integer): THandle; stdcall;
function WSAAsyncGetHostByAddr(HWindow: HWND; wMsg: u_int; addr: PAnsiChar; len, struct: integer; buf: PAnsiChar; buflen: integer): THandle; stdcall;
function WSACancelAsyncRequest(hAsyncTaskHandle: THandle): integer; stdcall;
function WSAAsyncSelect(s: TSocket; HWindow: HWND; wMsg: u_int; lEvent: Longint): integer; stdcall;
function __WSAFDIsSet(s: TSocket; var FDSet: TFDSet): BOOL; stdcall;

{ WinSock 2 API new function prototypes }
function WSAAccept(s: TSocket; addr: TSockAddr; addrlen: PInteger; lpfnCondition: LPCONDITIONPROC; dwCallbackData: DWORD): TSocket; stdcall;
function WSACloseEvent(hEvent: WSAEVENT): WordBool; stdcall;
function WSAConnect(s: TSocket; const name: PSockAddr; namelen: integer; lpCallerData, lpCalleeData: LPWSABUF; lpSQOS, lpGQOS: LPQOS): integer; stdcall;
function WSACreateEvent: WSAEVENT; stdcall;

function WSADuplicateSocketA(s: TSocket; dwProcessId: DWORD; lpProtocolInfo: LPWSAProtocol_InfoA): integer; stdcall;
function WSADuplicateSocketW(s: TSocket; dwProcessId: DWORD; lpProtocolInfo: LPWSAProtocol_InfoW): integer; stdcall;
function WSADuplicateSocket(s: TSocket; dwProcessId: DWORD; lpProtocolInfo: LPWSAProtocol_Info): integer; stdcall;

function WSAEnumNetworkEvents(const s: TSocket; const hEventObject: WSAEVENT; lpNetworkEvents: LPWSANetworkEvents): integer; stdcall;
function WSAEnumProtocolsA(lpiProtocols: PInteger; lpProtocolBuffer: LPWSAProtocol_InfoA; var lpdwBufferLength: DWORD): integer; stdcall;
function WSAEnumProtocolsW(lpiProtocols: PInteger; lpProtocolBuffer: LPWSAProtocol_InfoW; var lpdwBufferLength: DWORD): integer; stdcall;
function WSAEnumProtocols(lpiProtocols: PInteger; lpProtocolBuffer: LPWSAProtocol_Info; var lpdwBufferLength: DWORD): integer; stdcall;

function WSAEventSelect(s: TSocket; hEventObject: WSAEVENT; lNetworkEvents: Longint): integer; stdcall;

function WSAGetOverlappedResult(s: TSocket; lpOverlapped: LPWSAOVERLAPPED; lpcbTransfer: LPDWORD; fWait: BOOL; var lpdwFlags: DWORD): WordBool; stdcall;

function WSAGetQosByName(s: TSocket; lpQOSName: LPWSABUF; LPQOS: LPQOS): WordBool; stdcall;

function WSAhtonl(s: TSocket; hostlong: u_long; var lpnetlong: DWORD): integer; stdcall;
function WSAhtons(s: TSocket; hostshort: u_short; var lpnetshort: Word): integer; stdcall;

function WSAIoctl(s: TSocket; dwIoControlCode: DWORD; lpvInBuffer: pointer; cbInBuffer: DWORD; lpvOutBuffer: pointer; cbOutBuffer: DWORD;
  lpcbBytesReturned: LPDWORD; lpOverlapped: LPWSAOVERLAPPED; lpCompletionRoutine: LPWSAOVERLAPPED_COMPLETION_ROUTINE): integer; stdcall;

function WSAJoinLeaf(s: TSocket; name: PSockAddr; namelen: integer; lpCallerData, lpCalleeData: LPWSABUF; lpSQOS, lpGQOS: LPQOS; dwFlags: DWORD)
  : TSocket; stdcall;

function WSANtohl(s: TSocket; netlong: u_long; var lphostlong: DWORD): integer; stdcall;
function WSANtohs(s: TSocket; netshort: u_short; var lphostshort: Word): integer; stdcall;

function WSARecv(s: TSocket; lpBuffers: LPWSABUF; dwBufferCount: DWORD; var lpNumberOfBytesRecvd: DWORD; var lpFlags: DWORD; lpOverlapped: LPWSAOVERLAPPED;
  lpCompletionRoutine: LPWSAOVERLAPPED_COMPLETION_ROUTINE): integer; stdcall;
function WSARecvDisconnect(s: TSocket; lpInboundDisconnectData: LPWSABUF): integer; stdcall;
function WSARecvFrom(s: TSocket; lpBuffers: LPWSABUF; dwBufferCount: DWORD; var lpNumberOfBytesRecvd: DWORD; var lpFlags: DWORD; lpFrom: PSockAddr;
  lpFromlen: PInteger; lpOverlapped: LPWSAOVERLAPPED; lpCompletionRoutine: LPWSAOVERLAPPED_COMPLETION_ROUTINE): integer; stdcall;

function WSAResetEvent(hEvent: WSAEVENT): WordBool; stdcall;

function WSASend(s: TSocket; lpBuffers: LPWSABUF; dwBufferCount: DWORD; var lpNumberOfBytesSent: DWORD; dwFlags: DWORD; lpOverlapped: LPWSAOVERLAPPED;
  lpCompletionRoutine: LPWSAOVERLAPPED_COMPLETION_ROUTINE): integer; stdcall;
function WSASendDisconnect(s: TSocket; lpOutboundDisconnectData: LPWSABUF): integer; stdcall;
function WSASendTo(s: TSocket; lpBuffers: LPWSABUF; dwBufferCount: DWORD; var lpNumberOfBytesSent: DWORD; dwFlags: DWORD; lpTo: PSockAddr; iTolen: integer;
  lpOverlapped: LPWSAOVERLAPPED; lpCompletionRoutine: LPWSAOVERLAPPED_COMPLETION_ROUTINE): integer; stdcall;

function WSASetEvent(hEvent: WSAEVENT): WordBool; stdcall;

function WSASocketA(af, iType, protocol: integer; lpProtocolInfo: LPWSAProtocol_InfoA; g: GROUP; dwFlags: DWORD): TSocket; stdcall;
function WSASocketW(af, iType, protocol: integer; lpProtocolInfo: LPWSAProtocol_InfoW; g: GROUP; dwFlags: DWORD): TSocket; stdcall;
function WSASocket(af, iType, protocol: integer; lpProtocolInfo: LPWSAProtocol_Info; g: GROUP; dwFlags: DWORD): TSocket; stdcall;

function WSAWaitForMultipleEvents(cEvents: DWORD; lphEvents: PWSAEVENT; fWaitAll: LongBool; dwTimeout: DWORD; fAlertable: LongBool): DWORD; stdcall;

function WSAAddressToStringA(lpsaAddress: PSockAddr; const dwAddressLength: DWORD; const lpProtocolInfo: LPWSAProtocol_InfoA; const lpszAddressString: PAnsiChar;
  var lpdwAddressStringLength: DWORD): integer; stdcall;
function WSAAddressToStringW(lpsaAddress: PSockAddr; const dwAddressLength: DWORD; const lpProtocolInfo: LPWSAProtocol_InfoW;
  const lpszAddressString: PWideChar; var lpdwAddressStringLength: DWORD): integer; stdcall;
function WSAAddressToString(lpsaAddress: PSockAddr; const dwAddressLength: DWORD; const lpProtocolInfo: LPWSAProtocol_Info; const lpszAddressString: PMBChar;
  var lpdwAddressStringLength: DWORD): integer; stdcall;

function WSAStringToAddressA(const AddressString: PAnsiChar; const AddressFamily: integer; const lpProtocolInfo: LPWSAProtocol_InfoA; var lpAddress: TSockAddr;
  var lpAddressLength: integer): integer; stdcall;
function WSAStringToAddressW(const AddressString: PWideChar; const AddressFamily: integer; const lpProtocolInfo: LPWSAProtocol_InfoA; var lpAddress: TSockAddr;
  var lpAddressLength: integer): integer; stdcall;
function WSAStringToAddress(const AddressString: PMBChar; const AddressFamily: integer; const lpProtocolInfo: LPWSAProtocol_Info; var lpAddress: TSockAddr;
  var lpAddressLength: integer): integer; stdcall;

{ Registration and Name Resolution API functions }
function WSALookupServiceBeginA(var qsRestrictions: TWSAQuerySetA; const dwControlFlags: DWORD; var hLookup: THandle): integer; stdcall;
function WSALookupServiceBeginW(var qsRestrictions: TWSAQuerySetW; const dwControlFlags: DWORD; var hLookup: THandle): integer; stdcall;
function WSALookupServiceBegin(var qsRestrictions: TWSAQuerySet; const dwControlFlags: DWORD; var hLookup: THandle): integer; stdcall;

function WSALookupServiceNextA(const hLookup: THandle; const dwControlFlags: DWORD; var dwBufferLength: DWORD; lpqsResults: PWSAQuerySetA): integer; stdcall;
function WSALookupServiceNextW(const hLookup: THandle; const dwControlFlags: DWORD; var dwBufferLength: DWORD; lpqsResults: PWSAQuerySetW): integer; stdcall;
function WSALookupServiceNext(const hLookup: THandle; const dwControlFlags: DWORD; var dwBufferLength: DWORD; lpqsResults: PWSAQuerySet): integer; stdcall;

function WSALookupServiceEnd(const hLookup: THandle): integer; stdcall;

function WSAInstallServiceClassA(const lpServiceClassInfo: LPWSAServiceClassInfoA): integer; stdcall;
function WSAInstallServiceClassW(const lpServiceClassInfo: LPWSAServiceClassInfoW): integer; stdcall;
function WSAInstallServiceClass(const lpServiceClassInfo: LPWSAServiceClassInfo): integer; stdcall;

function WSARemoveServiceClass(const lpServiceClassId: PGUID): integer; stdcall;

function WSAGetServiceClassInfoA(const lpProviderId: PGUID; const lpServiceClassId: PGUID; var lpdwBufSize: DWORD; lpServiceClassInfo: LPWSAServiceClassInfoA)
  : integer; stdcall;
function WSAGetServiceClassInfoW(const lpProviderId: PGUID; const lpServiceClassId: PGUID; var lpdwBufSize: DWORD; lpServiceClassInfo: LPWSAServiceClassInfoW)
  : integer; stdcall;
function WSAGetServiceClassInfo(const lpProviderId: PGUID; const lpServiceClassId: PGUID; var lpdwBufSize: DWORD; lpServiceClassInfo: LPWSAServiceClassInfo)
  : integer; stdcall;

function WSAEnumNameSpaceProvidersA(var lpdwBufferLength: DWORD; const lpnspBuffer: LPWSANameSpace_InfoA): integer; stdcall;
function WSAEnumNameSpaceProvidersW(var lpdwBufferLength: DWORD; const lpnspBuffer: LPWSANameSpace_InfoW): integer; stdcall;
function WSAEnumNameSpaceProviders(var lpdwBufferLength: DWORD; const lpnspBuffer: LPWSANameSpace_Info): integer; stdcall;

function WSAGetServiceClassNameByClassIdA(const lpServiceClassId: PGUID; lpszServiceClassName: PAnsiChar; var lpdwBufferLength: DWORD): integer; stdcall;
function WSAGetServiceClassNameByClassIdW(const lpServiceClassId: PGUID; lpszServiceClassName: PWideChar; var lpdwBufferLength: DWORD): integer; stdcall;
function WSAGetServiceClassNameByClassId(const lpServiceClassId: PGUID; lpszServiceClassName: PMBChar; var lpdwBufferLength: DWORD): integer; stdcall;

function WSASetServiceA(const lpqsRegInfo: LPWSAQuerySetA; const essoperation: TWSAeSetServiceOp; const dwControlFlags: DWORD): integer; stdcall;
function WSASetServiceW(const lpqsRegInfo: LPWSAQuerySetW; const essoperation: TWSAeSetServiceOp; const dwControlFlags: DWORD): integer; stdcall;
function WSASetService(const lpqsRegInfo: LPWSAQuerySet; const essoperation: TWSAeSetServiceOp; const dwControlFlags: DWORD): integer; stdcall;

function WSAProviderConfigChange(var lpNotificationHandle: THandle; lpOverlapped: LPWSAOVERLAPPED; lpCompletionRoutine: LPWSAOVERLAPPED_COMPLETION_ROUTINE)
  : integer; stdcall;

function getnameinfo(const pAddr: pointer; addrlen: socklen_t; host: PAnsiChar; hostlen: DWORD; serv: PAnsiChar; servlen: DWORD; flags: integer): integer; stdcall;
function GetNameInfoW(const pAddr: pointer; addrlen: socklen_t; host: PWideChar; hostlen: DWORD; serv: PWideChar; servlen: DWORD; flags: integer): integer; stdcall;

{ Macros }
function WSAMakeSyncReply(buflen, Error: Word): Longint;
function WSAMakeSelectReply(Event, Error: Word): Longint;
function WSAGetAsyncBuflen(aParam: Longint): Word;
function WSAGetAsyncError(aParam: Longint): Word;
function WSAGetSelectEvent(aParam: Longint): Word;
function WSAGetSelectError(aParam: Longint): Word;

procedure FD_CLR(socket: TSocket; var FDSet: TFDSet);
function FD_ISSET(socket: TSocket; var FDSet: TFDSet): Boolean;
procedure FD_SET(socket: TSocket; var FDSet: TFDSet);
procedure FD_ZERO(var FDSet: TFDSet);

{ Extension functions }

var
	ConnectEx: LPFN_CONNECTEX;

function LoadConnectEx(const aSocket: TSocket): integer;

{ ============================================================ }
{ ======================= Custom Types ======================= }
{ ============================================================ }

const
	{ Socks version }
	SOCKSVER4 = $04;
	SOCKSVER5 = $05;

	{ Socks commands }
	SOCKSCMD_TCPCONNECT = $01; // RFC 1928
	SOCKSCMD_TCPBIND    = $02; // RFC 1928
	SOCKSCMD_UDPASSOC   = $03; // RFC 1928
	SOCKSCMD_RESOLVE    = $F0; // Tor extension
	SOCKSCMD_RESOLVEPTR = $F1; // Tor extension

	{ Socks5 authentication methods }
	SOCKS5AUTH_NOAUTH   = 0;
	SOCKS5AUTH_GSSAPI   = 1;
	SOCKS5AUTH_USERPASS = 2;

	{ Socks address types }
	SOCKSADDRTYP_IPV4       = $01;
	SOCKSADDRTYP_DOMAINNAME = $03;
	SOCKSADDRTYP_IPV6       = $04;

type
	{ TIPProtocol }
	{ IP protocol in an enum form. }
	TIPProtocol = (
	  ptIP = IPPROTO_IP,
	  ptICMP = IPPROTO_ICMP,
	  ptIGMP = IPPROTO_IGMP,
	  ptGGP = IPPROTO_GGP,
	  ptTCP = IPPROTO_TCP,
	  ptPUP = IPPROTO_PUP,
	  ptUDP = IPPROTO_UDP,
	  ptIDP = IPPROTO_IDP,
	  ptND = IPPROTO_ND,
	  ptRAW = IPPROTO_RAW
	  );

    { TSocketType }
    { Socket type in an enum form. }
	TSocketType = (
	  stStream = SOCK_STREAM,
	  stDGram = SOCK_DGRAM,
	  stRaw = SOCK_RAW,
	  stRDM = SOCK_RDM,
	  stSeqpacket = SOCK_SEQPACKET
	  );

	{ TAddressFamily }
	{ IP address family in an enum form. }
	TAddressFamily   = (afUnspec = AF_UNSPEC, afIPv4 = AF_INET, afIPv6 = AF_INET6);
	TAddressFamilies = set of TAddressFamily;

	{ TProxyType }
	{ Proxy protocol type/version. }
	TProxyType  = (ptNone, ptHTTP, ptSocks4, ptSocks5);
	TProxyTypes = set of TProxyType;

	{ TTCPState }
	{ Indicates the state of a TCP connection. }
	TTCPState = (
	  tsClosed, tsListening, tsSynSent, tsSynReceived, tsEstablished, tsFinWait1, tsFinWait2, tsCloseWait,
	  tsClosing, tsLastAck, tsTimeWait, tsDeleteTCB
	  );

{ ============================================================ }
{ ==================== Helper functions ====================== }
{ ============================================================ }

function InitWinsock: Boolean;
procedure FinWinsock;

{ Error functions }
function GetWinsockErrorText(const aError: integer): string;
function GetLastWinsockErrorText: string;

{ Quick utils for testing, mostly. }
function CreateTcpSock(const aAf: TAddressFamily = afIPv4): TSocket;
function CreateUdpSock(const aAf: TAddressFamily = afIPv4): TSocket;
function CreateRawSock(const aAf: TAddressFamily = afIPv4): TSocket;

function ConnectTCPSock(const aSock: TSocket; const aAddrPool: PAddrInfo): Boolean;
function ConnectTCPSockNonBlocking(const aSock: TSocket; const aAddrPool: PAddrInfo): Boolean;

function MakeTcpConnection(const aHost, aPort: string; const aAf: TAddressFamily = afIPv4): TSocket;
function MakeTcpConnectionSocks5(const aHost, aPort, aProxyHost, aProxyPort, aProxyUser, aProxyPass: string; const aAf: TAddressFamily = afIPv4): TSocket;

function SendStrTcp(const aSock: TSocket; const aString: string): integer;
function RecvStrTcp(const aSock: TSocket; var aString: string): integer;
function RecvStrTcpNonBlocking(const aSock: TSocket; var aString: string): integer;

procedure DeleteSock(var aSock: TSocket);

{ Resolving utils }
function GetAddrPool(
  const aHost, aPort: string;
  var aAddrInfo: PAddrInfo;
  const aAf: TAddressFamily = afIPv4;
  const aSockType: TSocketType = stStream;
  const aProtocol: TIPProtocol = ptTCP;
  const aFlags: integer = 0
  ): integer;
procedure FreeAddrPool(var aAddrInfo: PAddrInfo);

{ Proxy handshakes }
function GetSocks4ErrorText(const aErr: integer): string;
function GetSocks5ErrorText(const aErr: integer): string;

function NegotiateProxy(const aSocket: TSocket; const aHost, aPort, aUser: string): integer;
function NegotiateSocks4(const aSocket: TSocket; const aHost, aPort, aUser, aPass: string): integer;
function NegotiateSocks5(const aSocket: TSocket; const aHost, aPort, aUser, aPass: string): integer;

{ Address conversion }
function SockAddrToStr(const aSockAddr: PSockAddr; const aAddrLen: integer; var aOutString: string): Boolean; overload;
function SockAddrToStr(const aSockAddr: PSockAddr; const aAddrLen: integer): string; overload;
function ServToPortNum(const aServName: string; var aPort: Word): Boolean;

function InAddr4ToStr(const aAddr: in_addr): string;
function InAddr6ToStr(const aAddr: in6_addr; const aAbbreviate: boolean = True): string;
function InAddr4RevLookup(const aAddr: in_addr; const aDGram: boolean = False): string;
function InAddr6RevLookup(const aAddr: in6_addr; const aDGram: boolean = False): string;

{ String conversion }
function ProxyTypeToString(const aProxyType: TProxyType): string;
function ProxyTypeToScheme(const aProxyType: TProxyType): string;

{ ============================================================ }
{ ====================== Helper types ======================== }
{ ============================================================ }

type

	{ GetAddrPoolAsync }
    { Resolves an address asynchronously by using GetAddrInfo in a thread. }
    { If you use more of these be sure to set IsMultiThreaded RTL var to true. }

    { TGetAddrPoolAsyncData events. }
	TOnResolved = reference to procedure(const aAddrPool: PAddrInfo; const aError: integer);

	{ GetAddrPoolAsync data }
	TGetAddrPoolAsyncData = record
	private
		ThreadHandle: THandle;
		class function GetAddrPoolAsyncThread(aParam: pointer): DWORD; stdcall; static;
	public
		host         : string;
		port         : string;
		AddressFamily: TAddressFamily;
		SocketType   : TSocketType;
		Flags        : integer;
		OnResolved   : TOnResolved;
		procedure Initialize;
		procedure Abort;
		function Running: boolean;
	end;

	PGetAddrPoolAsyncData = ^TGetAddrPoolAsyncData;

procedure GetAddrPoolAsync(var aData: TGetAddrPoolAsyncData);

implementation

uses
	EvilWorks.System.StrUtils;

function LoadConnectEx(const aSocket: TSocket): integer;
var
	guidConnectEx: System.TGUID;
	Bytes        : DWORD;
begin
	guidConnectEx := WSAID_CONNECTEX;
	Result        := WSAIoctl(aSocket, SIO_GET_EXTENSION_FUNCTION_POINTER, @guidConnectEx, SizeOf(guidConnectEx),
	  @@ConnectEx, SizeOf(@ConnectEx), @Bytes, nil, nil
	  );
end;

function accept; external WINSOCK2_DLL name 'accept';
function bind; external WINSOCK2_DLL name 'bind';
function closesocket; external WINSOCK2_DLL name 'closesocket';
function connect; external WINSOCK2_DLL name 'connect';
function ioctlsocket; external WINSOCK2_DLL name 'ioctlsocket';
function getpeername; external WINSOCK2_DLL name 'getpeername';
function getsockname; external WINSOCK2_DLL name 'getsockname';
function getsockopt; external WINSOCK2_DLL name 'getsockopt';
function htonl; external WINSOCK2_DLL name 'htonl';
function htons; external WINSOCK2_DLL name 'htons';
function inet_addr; external WINSOCK2_DLL name 'inet_addr';
function inet_ntoa; external WINSOCK2_DLL name 'inet_ntoa';
function listen; external WINSOCK2_DLL name 'listen';
function ntohl; external WINSOCK2_DLL name 'ntohl';
function ntohs; external WINSOCK2_DLL name 'ntohs';
function recv; external WINSOCK2_DLL name 'recv';
function recvfrom; external WINSOCK2_DLL name 'recvfrom';
function select; external WINSOCK2_DLL name 'select';
function send; external WINSOCK2_DLL name 'send';
function sendto; external WINSOCK2_DLL name 'sendto';
function setsockopt; external WINSOCK2_DLL name 'setsockopt';
function shutdown; external WINSOCK2_DLL name 'shutdown';
function socket; external WINSOCK2_DLL name 'socket';
function gethostbyaddr; external WINSOCK2_DLL name 'gethostbyaddr';
function gethostbyname; external WINSOCK2_DLL name 'gethostbyname';
function gethostname; external WINSOCK2_DLL name 'gethostname';
function getservbyport; external WINSOCK2_DLL name 'getservbyport';
function getservbyname; external WINSOCK2_DLL name 'getservbyname';
function getprotobynumber; external WINSOCK2_DLL name 'getprotobynumber';
function getprotobyname; external WINSOCK2_DLL name 'getprotobyname';
function WSAStartup; external WINSOCK2_DLL name 'WSAStartup';
function WSACleanup; external WINSOCK2_DLL name 'WSACleanup';
procedure WSASetLastError; external WINSOCK2_DLL name 'WSASetLastError';
function WSAGetLastError; external WINSOCK2_DLL name 'WSAGetLastError';
function WSAIsBlocking; external WINSOCK2_DLL name 'WSAIsBlocking';
function WSAUnhookBlockingHook; external WINSOCK2_DLL name 'WSAUnhookBlockingHook';
function WSASetBlockingHook; external WINSOCK2_DLL name 'WSASetBlockingHook';
function WSACancelBlockingCall; external WINSOCK2_DLL name 'WSACancelBlockingCall';
function WSAAsyncGetServByName; external WINSOCK2_DLL name 'WSAAsyncGetServByName';
function WSAAsyncGetServByPort; external WINSOCK2_DLL name 'WSAAsyncGetServByPort';
function WSAAsyncGetProtoByName; external WINSOCK2_DLL name 'WSAAsyncGetProtoByName';
function WSAAsyncGetProtoByNumber; external WINSOCK2_DLL name 'WSAAsyncGetProtoByNumber';
function WSAAsyncGetHostByName; external WINSOCK2_DLL name 'WSAAsyncGetHostByName';
function WSAAsyncGetHostByAddr; external WINSOCK2_DLL name 'WSAAsyncGetHostByAddr';
function WSACancelAsyncRequest; external WINSOCK2_DLL name 'WSACancelAsyncRequest';
function WSAAsyncSelect; external WINSOCK2_DLL name 'WSAAsyncSelect';
function __WSAFDIsSet; external WINSOCK2_DLL name '__WSAFDIsSet';

{ WinSock 2 API new function prototypes }
function WSAAccept; external WINSOCK2_DLL name 'WSAAccept';
function WSACloseEvent; external WINSOCK2_DLL name 'WSACloseEvent';
function WSAConnect; external WINSOCK2_DLL name 'WSAConnect';
function WSACreateEvent; external WINSOCK2_DLL name 'WSACreateEvent';
function WSADuplicateSocketA; external WINSOCK2_DLL name 'WSADuplicateSocketA';
function WSADuplicateSocketW; external WINSOCK2_DLL name 'WSADuplicateSocketW';
function WSAEnumNetworkEvents; external WINSOCK2_DLL name 'WSAEnumNetworkEvents';
function WSAEnumProtocolsA; external WINSOCK2_DLL name 'WSAEnumProtocolsA';
function WSAEnumProtocolsW; external WINSOCK2_DLL name 'WSAEnumProtocolsW';
function WSAEventSelect; external WINSOCK2_DLL name 'WSAEventSelect';
function WSAGetOverlappedResult; external WINSOCK2_DLL name 'WSAGetOverlappedResult';
function WSAGetQosByName; external WINSOCK2_DLL name 'WSAGetQosByName';
function WSAhtonl; external WINSOCK2_DLL name 'WSAhtonl';
function WSAhtons; external WINSOCK2_DLL name 'WSAhtons';
function WSAIoctl; external WINSOCK2_DLL name 'WSAIoctl';
function WSAJoinLeaf; external WINSOCK2_DLL name 'WSAJoinLeaf';
function WSANtohl; external WINSOCK2_DLL name 'WSANtohl';
function WSANtohs; external WINSOCK2_DLL name 'WSANtohs';
function WSARecv; external WINSOCK2_DLL name 'WSARecv';
function WSARecvDisconnect; external WINSOCK2_DLL name 'WSARecvDisconnect';
function WSARecvFrom; external WINSOCK2_DLL name 'WSARecvFrom';
function WSAResetEvent; external WINSOCK2_DLL name 'WSAResetEvent';
function WSASend; external WINSOCK2_DLL name 'WSASend';
function WSASendDisconnect; external WINSOCK2_DLL name 'WSASendDisconnect';
function WSASendTo; external WINSOCK2_DLL name 'WSASendTo';
function WSASetEvent; external WINSOCK2_DLL name 'WSASetEvent';
function WSASocketA; external WINSOCK2_DLL name 'WSASocketA';
function WSASocketW; external WINSOCK2_DLL name 'WSASocketW';
function WSAWaitForMultipleEvents; external WINSOCK2_DLL name 'WSAWaitForMultipleEvents';
function WSAAddressToStringA; external WINSOCK2_DLL name 'WSAAddressToStringA';
function WSAAddressToStringW; external WINSOCK2_DLL name 'WSAAddressToStringW';
function WSAStringToAddressA; external WINSOCK2_DLL name 'WSAStringToAddressA';
function WSAStringToAddressW; external WINSOCK2_DLL name 'WSAStringToAddressW';

{ Registration and Name Resolution API functions }
function WSALookupServiceBeginA; external WINSOCK2_DLL name 'WSALookupServiceBeginA';
function WSALookupServiceBeginW; external WINSOCK2_DLL name 'WSALookupServiceBeginW';
function WSALookupServiceNextA; external WINSOCK2_DLL name 'WSALookupServiceNextA';
function WSALookupServiceNextW; external WINSOCK2_DLL name 'WSALookupServiceNextW';
function WSALookupServiceEnd; external WINSOCK2_DLL name 'WSALookupServiceEnd';
function WSAInstallServiceClassA; external WINSOCK2_DLL name 'WSAInstallServiceClassA';
function WSAInstallServiceClassW; external WINSOCK2_DLL name 'WSAInstallServiceClassW';
function WSARemoveServiceClass; external WINSOCK2_DLL name 'WSARemoveServiceClass';
function WSAGetServiceClassInfoA; external WINSOCK2_DLL name 'WSAGetServiceClassInfoA';
function WSAGetServiceClassInfoW; external WINSOCK2_DLL name 'WSAGetServiceClassInfoW';
function WSAEnumNameSpaceProvidersA; external WINSOCK2_DLL name 'WSAEnumNameSpaceProvidersA';
function WSAEnumNameSpaceProvidersW; external WINSOCK2_DLL name 'WSAEnumNameSpaceProvidersW';
function WSAGetServiceClassNameByClassIdA; external WINSOCK2_DLL name 'WSAGetServiceClassNameByClassIdA';
function WSAGetServiceClassNameByClassIdW; external WINSOCK2_DLL name 'WSAGetServiceClassNameByClassIdW';
function WSASetServiceA; external WINSOCK2_DLL name 'WSASetServiceA';
function WSASetServiceW; external WINSOCK2_DLL name 'WSASetServiceW';
function WSAProviderConfigChange; external WINSOCK2_DLL name 'WSAProviderConfigChange';
function getnameinfo; external WINSOCK2_DLL name 'getnameinfo';
function GetNameInfoW; external WINSOCK2_DLL name 'GetNameInfoW';

{$IFDEF UNICODE}
function WSADuplicateSocket; external WINSOCK2_DLL name 'WSADuplicateSocketW';
function WSAEnumProtocols; external WINSOCK2_DLL name 'WSAEnumProtocolsW';
function WSASocket; external WINSOCK2_DLL name 'WSASocketW';
function WSAAddressToString; external WINSOCK2_DLL name 'WSAAddressToStringW';
function WSAStringToAddress; external WINSOCK2_DLL name 'WSAStringToAddressW';
function WSALookupServiceBegin; external WINSOCK2_DLL name 'WSALookupServiceBeginW';
function WSALookupServiceNext; external WINSOCK2_DLL name 'WSALookupServiceNextW';
function WSAInstallServiceClass; external WINSOCK2_DLL name 'WSAInstallServiceClassW';
function WSAGetServiceClassInfo; external WINSOCK2_DLL name 'WSAGetServiceClassInfoW';
function WSAEnumNameSpaceProviders; external WINSOCK2_DLL name 'WSAEnumNameSpaceProvidersW';
function WSAGetServiceClassNameByClassId; external WINSOCK2_DLL name 'WSAGetServiceClassNameByClassIdW';
function WSASetService; external WINSOCK2_DLL name 'WSASetServiceW';
function GetAddrInfo; external WINSOCK2_DLL name 'GetAddrInfoW';
procedure FreeAddrInfo; external WINSOCK2_DLL name 'FreeAddrInfoW';
{$ELSE}
function WSADuplicateSocket; external WINSOCK2_DLL name 'WSADuplicateSocketA';
function WSAEnumProtocols; external WINSOCK2_DLL name 'WSAEnumProtocolsA';
function WSASocket; external WINSOCK2_DLL name 'WSASocketA';
function WSAAddressToString; external WINSOCK2_DLL name 'WSAAddressToStringA';
function WSAStringToAddress; external WINSOCK2_DLL name 'WSAStringToAddressA';
function WSALookupServiceBegin; external WINSOCK2_DLL name 'WSALookupServiceBeginA';
function WSALookupServiceNext; external WINSOCK2_DLL name 'WSALookupServiceNextA';
function WSAInstallServiceClass; external WINSOCK2_DLL name 'WSAInstallServiceClassA';
function WSAGetServiceClassInfo; external WINSOCK2_DLL name 'WSAGetServiceClassInfoA';
function WSAEnumNameSpaceProviders; external WINSOCK2_DLL name 'WSAEnumNameSpaceProvidersA';
function WSAGetServiceClassNameByClassId; external WINSOCK2_DLL name 'WSAGetServiceClassNameByClassIdA';
function WSASetService; external WINSOCK2_DLL name 'WSASetServiceA';
function GetAddrInfo; external WINSOCK2_DLL name 'GetAddrInfoA';
procedure FreeAddrInfo; external WINSOCK2_DLL name 'FreeAddrInfoA';
{$ENDIF}


function WSAMakeSyncReply;
begin
	WSAMakeSyncReply := MakeLong(buflen, Error);
end;

function WSAMakeSelectReply;
begin
	WSAMakeSelectReply := MakeLong(Event, Error);
end;

function WSAGetAsyncBuflen(aParam: Longint): Word;
begin
	WSAGetAsyncBuflen := Word(aParam);
end;

function WSAGetAsyncError(aParam: Longint): Word;
begin
	WSAGetAsyncError := HIWORD(aParam);
end;

function WSAGetSelectEvent(aParam: Longint): Word;
begin
	Result := Word(aParam);
end;

function WSAGetSelectError(aParam: Longint): Word;
begin
	WSAGetSelectError := HIWORD(aParam);
end;

procedure FD_CLR(socket: TSocket; var FDSet: TFDSet);
var
	i: DWORD;
begin
	i := 0;
	while i < FDSet.fd_count do
	begin
		if FDSet.fd_array[i] = socket then
		begin
			while i < FDSet.fd_count - 1 do
			begin
				FDSet.fd_array[i] := FDSet.fd_array[i + 1];
				Inc(i);
			end;
			Dec(FDSet.fd_count);
			Break;
		end;
		Inc(i);
	end;
end;

function FD_ISSET(socket: TSocket; var FDSet: TFDSet): Boolean;
begin
	Result := __WSAFDIsSet(socket, FDSet);
end;

procedure FD_SET(socket: TSocket; var FDSet: TFDSet);
begin
	if FDSet.fd_count < FD_SETSIZE then
	begin
		FDSet.fd_array[FDSet.fd_count] := socket;
		Inc(FDSet.fd_count);
	end;
end;

procedure FD_ZERO(var FDSet: TFDSet);
begin
	FDSet.fd_count := 0;
end;

{ Initializes Winsock to version 2.2 }
function InitWinsock: Boolean;
var
	ret: integer;
	wsd: TWSAData;
begin
	ZeroMemory(@wsd, SizeOf(wsd));
	ret := WSAStartup($0202, wsd);
	if (ret = 0) then
		Result := True
	else
		Result := False;
end;

{ Finalizes Winsock. }
procedure FinWinsock;
begin
	WSACleanup;
end;

{ Returns text description of a winsock error. }
function GetWinsockErrorText(const aError: integer): string;
var
	buffer: array [0 .. 255] of Char;
	flags : DWORD;
begin
	FillChar(buffer, 256, #0);
	flags := FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_IGNORE_INSERTS or FORMAT_MESSAGE_ARGUMENT_ARRAY;
	FormatMessage(flags, nil, aError, 0, buffer, SizeOf(buffer), nil);
	Result := buffer;
end;

{ Returns last winsock error description. }
function GetLastWinsockErrorText: string;
begin
	Result := GetWinsockErrorText(WSAGetLastError);
end;

{ Creates a TCP socket. }
function CreateTcpSock(const aAf: TAddressFamily): TSocket;
begin
	Result := socket(integer(aAf), SOCK_STREAM, IPPROTO_TCP);
end;

{ Creates a UDP socket. }
function CreateUdpSock(const aAf: TAddressFamily): TSocket;
begin
	Result := socket(integer(aAf), SOCK_DGRAM, IPPROTO_UDP);
end;

{ Creates a RAW socket. }
function CreateRawSock(const aAf: TAddressFamily = afIPv4): TSocket;
begin
	Result := socket(integer(aAf), SOCK_RAW, IPPROTO_RAW);
end;

{ Tries to connect a TCP socket to an address in aAddrPool. True on success, False if not. }
function ConnectTCPSock(const aSock: TSocket; const aAddrPool: PAddrInfo): Boolean;
var
	curr: PAddrInfo;
begin
	Result := True;

	curr := aAddrPool;
	while (curr <> nil) do
	begin
		if (connect(aSock, curr^.ai_addr, curr^.ai_addrlen) <> 0) then
			curr := curr^.ai_next
		else
			Break;

		if (curr = nil) then
			Exit(False);
	end;
end;

{ Same as ConnectTCPSock but it treats WSAEWOULDBLOCK error as success. Use it for non-blocking sockets. }
function ConnectTCPSockNonBlocking(const aSock: TSocket; const aAddrPool: PAddrInfo): Boolean;
var
	curr: PAddrInfo;
begin
	Result := True;

	curr := aAddrPool;
	while (curr <> nil) do
	begin
		if (connect(aSock, curr^.ai_addr, curr^.ai_addrlen) <> 0) then
		begin
			if (WSAGetLastError = WSAEWOULDBLOCK) then
				Break;
			curr := curr^.ai_next;
		end
		else
			Break;

		if (curr = nil) then
			Exit(False);
	end;
end;

{ Returns a socket connected to aHost:aPort, SOCKET_ERROR if something failed. Call WSAGetLastError if so. }
function MakeTcpConnection(const aHost, aPort: string; const aAf: TAddressFamily): TSocket;
label Error;
var
	addr: PAddrInfo;
begin
	Result := CreateTcpSock(aAf);
	if (Result = INVALID_SOCKET) then
		Exit;

	if (GetAddrPool(aHost, aPort, addr, aAf) <> 0) then
		goto Error;

	if (ConnectTCPSock(Result, addr) = False) then
		goto Error;

	Exit;

Error:
	FreeAddrPool(addr);
	closesocket(Result);
end;

{ Same as MakeTcpConnection but over Socks5 proxy. }
function MakeTcpConnectionSocks5(const aHost, aPort, aProxyHost, aProxyPort, aProxyUser, aProxyPass: string; const aAf: TAddressFamily): TSocket;
begin
	Result := MakeTcpConnection(aProxyHost, aProxyPort, aAf);
	if (Result = INVALID_SOCKET) then
		Exit;

	if (NegotiateSocks5(Result, aHost, aPort, aProxyUser, aProxyPass) = SOCKET_ERROR) then
	begin
		DeleteSock(Result);
		Result := INVALID_SOCKET;
	end;
end;

{ Sends a string over a TCP socket. }
function SendStrTcp(const aSock: TSocket; const aString: string): integer;
var
	buffer: rawbytestring;
begin
	buffer := UTF8Encode(aString);
	Result := send(aSock, buffer[1], Length(buffer), 0);
end;

{ Receives a string over a TCP socket. Result -2 on rtl error, -1 on winsock, 0 on close, >0 = bytes received. }
function RecvStrTcp(const aSock: TSocket; var aString: string): integer;
var
	buf    : pointer;
	bufsize: u_long;
	optlen : integer;
begin
	aString := '';

	if (ioctlsocket(aSock, FIONREAD, bufsize) <> 0) then
		Exit(SOCKET_ERROR);

	if (bufsize = 0) then
	begin
		optlen := SizeOf(bufsize);
		if (getsockopt(aSock, SOL_SOCKET, SO_RCVBUF, @integer(bufsize), optlen) <> 0) then
			Exit(SOCKET_ERROR);
	end;

	buf := AllocMem(bufsize);
	if (buf = nil) then
		Exit( - 2);

	Result := recv(aSock, buf^, bufsize, 0);
	if (Result > 0) then
		aString := string(PAnsiChar(buf));

	FreeMemory(buf);
end;

{ Same as RecvStrTcp, but will immediately return empty aString and 0 if no data available. }
function RecvStrTcpNonBlocking(const aSock: TSocket; var aString: string): integer;
var
	buf    : pointer;
	bufsize: u_long;
begin
	aString := '';

	if (ioctlsocket(aSock, FIONREAD, bufsize) <> 0) then
		Exit(SOCKET_ERROR);

	if (bufsize = 0) then
		Exit(SOCKET_ERROR);

	buf := AllocMem(bufsize);
	if (buf = nil) then
		Exit( - 2);

	Result := recv(aSock, buf^, bufsize, 0);
	if (Result > 0) then
		aString := string(PAnsiChar(buf));

	FreeMemory(buf);
end;

{ closes and deletes a socket if its value is not INVALID_SOCKET. }
procedure DeleteSock(var aSock: TSocket);
begin
	if (aSock = INVALID_SOCKET) then
		Exit;
	closesocket(aSock);
	aSock := INVALID_SOCKET;
end;

{ Resolves aHost:aPort to an address pool in aAddrInfo. Returns 0 on success, Winsock Error otherwise. }
function GetAddrPool(
  const aHost, aPort: string; var aAddrInfo: PAddrInfo; const aAf: TAddressFamily;
  const aSockType: TSocketType; const aProtocol: TIPProtocol; const aFlags: integer
  ): integer;
var
	hints: TAddrInfo;
begin
	ZeroMemory(@hints, SizeOf(hints));
	hints.ai_family   := integer(aAf);
	hints.ai_socktype := integer(aSockType);
	hints.ai_protocol := integer(aProtocol);
	hints.ai_flags    := aFlags;

	Result := GetAddrInfo(PChar(aHost), PChar(aPort), @hints, @aAddrInfo);
end;

{ Frees PAddrInfo. }
procedure FreeAddrPool(var aAddrInfo: PAddrInfo);
begin
	if (aAddrInfo = nil) then
		Exit;
	FreeAddrInfo(aAddrInfo);
	aAddrInfo := nil;
end;

{ Returns a text description of a Socks4 handshake error. }
function GetSocks4ErrorText(const aErr: integer): string;
begin
	case aErr of
		$5A:
		Result := 'Request granted.';
		$5B:
		Result := 'Request rejected or failed.';
		$5C:
		Result := 'Request failed because client is not running identd (or unreachable).';
		$5D:
		Result := 'Request failed because client ident could not confirm user ID in request.';
		else
		Result := 'Unknown error.';
	end;
end;

{ Returns a text description of a Socks5 handshake error. }
function GetSocks5ErrorText(const aErr: integer): string;
begin
	case aErr of
		0:
		Result := 'Connected OK.';
		1:
		Result := 'General failure.';
		2:
		Result := 'Connection not allowed by ruleset.';
		3:
		Result := 'Network unreachable.';
		4:
		Result := 'Host unreachable.';
		5:
		Result := 'Connection refused by destination host.';
		6:
		Result := 'TTL expired.';
		7:
		Result := 'Command not supported / protocol error.';
		8:
		Result := 'Address type not supported.';
		else
		Result := 'Unknown error.';
	end;
end;

{ Negotiates a client connection with a HTTP proxy ON A BLOCKING SOCKET! }
{ aUser is optional, if HTTP proxy requests is for auth. }
{ Returns 0 on success, SOCKET_ERROR on winsock error, or a >0 value for Proxy error. }
{ Supports NoAuth and User Auth. }
function NegotiateProxy(const aSocket: TSocket; const aHost, aPort, aUser: string): integer;
begin
	Result := 0;
end;

{ Negotiates a client connection with a socks4 proxy ON A BLOCKING SOCKET! }
{ aUser, apass are optional, if Socks4 server requests them for an User/Pass auth. }
{ Returns 0 on success, SOCKET_ERROR on winsock error, or a >0 value for Socks4 error. }
{ Supports NoAuth and User/Pass. }
function NegotiateSocks4(const aSocket: TSocket; const aHost, aPort, aUser, aPass: string): integer;
begin
	Result := 0;
end;

{ Negotiates a client connection with a socks5 proxy ON A BLOCKING SOCKET! }
{ aUser, aPass are optional, if Socks5 server requests them for an User/Pass auth. }
{ Returns 0 on success, SOCKET_ERROR on winsock error, or a >0 value for Socks5 error. }
{ Supports NoAuth and User/Pass. }
function NegotiateSocks5(const aSocket: TSocket; const aHost, aPort, aUser, aPass: string): integer;

	function IsError(const aErr: integer): Boolean;
	begin
		if (aErr <= 0) or (aErr = SOCKET_ERROR) then
			Result := True
		else
			Result := False;
	end;

var
	Buff : array of Byte;
	host : ansistring;
	port : Word;
	uname: ansistring;
	pword: ansistring;
begin
	// Send auth methods.
	SetLength(Buff, 4);
	Buff[0] := $05; // Socks version, must be $05.
	Buff[1] := $02; // Num of methods supported.
	Buff[2] := $00; // Method 1 - No auth.
	Buff[3] := $02; // Method 2 - Username/Password.
	Result  := send(aSocket, Buff[0], Length(Buff), 0);
	if IsError(Result) then
		Exit(SOCKET_ERROR);

    // Recieve selected Auth method.
	SetLength(Buff, 2);
	ZeroMemory(@Buff[0], 2);
	Result := recv(aSocket, Buff[0], Length(Buff), MSG_WAITALL);
	if IsError(Result) then
		Exit(SOCKET_ERROR);

    // Check reply version.
	if (Buff[0] <> $05) then // Socks version, must be $05.
		Exit(1);

    // Do User/Pass auth.
	if (Buff[1] = 2) then
	begin
    	// Send Username/Password
		uname := ansistring(aUser);
		pword := ansistring(aPass);

		SetLength(Buff, 3 + Length(uname) + Length(pword));
		Buff[0] := $01; // Sending user:pass auth.

        // Put username
		Buff[1] := Length(uname);
		if (Buff[1] > 0) then
			CopyMemory(@Buff[2], @uname[1], Length(uname));

        // Put password
		Buff[2 + Length(uname) + 1] := Length(pword);
		if (Buff[2 + Length(uname) + 1] > 0) then
			CopyMemory(@Buff[2 + Length(uname) + 1], @pword[1], Length(pword));

        // Send Username:Password auth.
		Result := send(aSocket, Buff[0], Length(Buff), 0);
		if (IsError(Result)) then
			Exit(SOCKET_ERROR);

        // Get auth response.
		SetLength(Buff, 2);
		ZeroMemory(@Buff[0], 2);
		Result := recv(aSocket, Buff[0], Length(Buff), MSG_WAITALL);
		if IsError(Result) then
			Exit(SOCKET_ERROR);
	end
	else if (Buff[1] <> 0) then // Some unsupported auth method requested.
		Exit(1);

    // Send connect request.
	host := ansistring(aHost);
	ServToPortNum(aPort, port);
	SetLength(Buff, 7 + Length(host));
	Buff[0] := $05;                                      // Socks version.
	Buff[1] := $01;                                      // Establish TCP connection.
	Buff[2] := $00;                                      // Reserved.
	Buff[3] := $03;                                      // Destination type: Domain name.
	Buff[4] := Length(host);                             // Length of hostname
	CopyMemory(@Buff[5], PAnsiChar(host), Buff[4]);      // Hostname
	CopyMemory(@Buff[5 + Buff[4]], @port, SizeOf(port)); // Port

	Result := send(aSocket, Buff[0], Length(Buff), 0);
	if IsError(Result) then
		Exit(SOCKET_ERROR);

    // Recieve connect response.
	SetLength(Buff, 260);
	FillChar(Buff[0], 260, 0);
	Result := recv(aSocket, Buff[0], 260, 0);
	if IsError(Result) then
		Exit(SOCKET_ERROR);

    // Check for final "OK!".
	if (Buff[1] <> $00) then
		Exit(1);
end;

{ Returns an IP string from PSockAddr in standard dotted format: byte.byte.byte.byte:word (ip:port). }
{ Supports IPv6 addresses as well, uses Winsock functions to convert data. }
function SockAddrToStr(const aSockAddr: PSockAddr; const aAddrLen: integer; var aOutString: string): Boolean;
var
	buffer    : array [0 .. 255] of Char;
	buffersize: cardinal;
begin
	if (aSockAddr = nil) or (aAddrLen = 0) then
		Exit(False);

	buffersize := 256;
	ZeroMemory(@buffer[0], buffersize);
	if (WSAAddressToString(aSockAddr, aAddrLen, nil, buffer, buffersize) = 0) then
	begin
		SetString(aOutString, PChar(@buffer[0]), buffersize);
		Result := True;
	end
	else
	begin
		aOutString := '';
		Result     := False;
	end;
end;

{ Returns an IP string from PSockAddr in standard dotted format: byte.byte.byte.byte:word (ip:port). }
function SockAddrToStr(const aSockAddr: PSockAddr; const aAddrLen: integer): string; overload;
var
	s: string;
begin
	Result := '';
	if (SockAddrToStr(aSockAddr, aAddrLen, s)) then
		Result := s;
end;

{ Returns port number for a service name in net byte order. i.e. "http -> 80" }
function ServToPortNum(const aServName: string; var aPort: Word): Boolean;
var
	sent: PServEnt;
	code: integer;
begin
	Result := False;

	sent := getservbyname(PAnsiChar(ansistring(aServName)), PAnsiChar('tcp'));
	if (sent = nil) then
	begin
		Val(aServName, aPort, code);
		if (code <> 0) then
			Exit;
		aPort := htons(aPort);
	end
	else
		aPort := sent^.s_port;

	Result := True;
end;

{ Converts in_addr to text representation. ~10x faster than inet_ntoa. }
function InAddr4ToStr(const aAddr: in_addr): string;
type
	TIP4Bytes = array [0 .. 3] of byte;
var
	s: shortstring;
begin
	Str(TIP4Bytes(aAddr)[0], s);
	Result := string(s);
	Str(TIP4Bytes(aAddr)[1], s);
	Result := Result + '.' + string(s);
	Str(TIP4Bytes(aAddr)[2], s);
	Result := Result + '.' + string(s);
	Str(TIP4Bytes(aAddr)[3], s);
	Result := Result + '.' + string(s);
end;

{ Converts in6_addr to text representation. If aAbbreviate collapses leading and consecutive zeros. }
function InAddr6ToStr(const aAddr: in6_addr; const aAbbreviate: boolean = True): string;
var
	i: integer;
begin
	Result := '';

	if (aAbbreviate) then
	begin
		for i := 0 to 7 do
		begin
			if (aAddr.Words[i] <> 0) then
			begin
				if (aAddr.Bytes[i * 2] <> 0) then
				begin
					Result := Result + TextIntToHex(aAddr.Bytes[i * 2], 1);
					Result := Result + TextIntToHex(aAddr.Bytes[i * 2 + 1], 2);
				end
				else
					Result := Result + TextIntToHex(aAddr.Bytes[i * 2 + 1], 1);
			end;

			if not (TextEnds(Result, '::')) then
				if (i <> 7) then
					Result := Result + ':';
		end;
		Exit;
	end;

	for i := 0 to 15 do
	begin
		Result := Result + TextIntToHex(aAddr.Bytes[i], 2);
		if (i <> 15) and (Odd(i)) then
			Result := Result + ':';
	end;
end;

{ Performs a reverse lookup on a ipv4 address. On failure result will be empty. }
function InAddr4RevLookup(const aAddr: in_addr; const aDGram: boolean = False): string;
var
	addr    : sockaddr_in;
	hostName: array [0 .. NI_MAXHOST - 1] of ansichar;
	servName: array [0 .. NI_MAXSERV - 1] of ansichar;
	flags   : integer;
begin
	Result := CEmpty;

	if (aDGram) then
		flags := NI_NAMEREQD or NI_DGRAM or NI_NUMERICHOST
	else
		flags := NI_NAMEREQD or NI_NUMERICHOST;

	ZeroMemory(@addr, SizeOf(addr));
	ZeroMemory(@hostName[0], Length(hostName));
	ZeroMemory(@servName[0], Length(servName));

	addr.sin_family      := AF_INET;
	addr.sin_addr.S_addr := aAddr.S_addr;
	addr.sin_port        := 0;

	if (getnameinfo(@addr, SizeOf(addr), hostName, Length(hostName), servName, Length(servName), flags) = 0) then
		Result := string(hostName);
end;

{ Performs a reverse lookup on a ipv6 address. On failure result will be empty. }
function InAddr6RevLookup(const aAddr: in6_addr; const aDGram: boolean = False): string;
var
	addr    : sockaddr_in6;
	hostName: array [0 .. NI_MAXHOST - 1] of ansichar;
	servName: array [0 .. NI_MAXSERV - 1] of ansichar;
	flags   : integer;
begin
	Result := CEmpty;

	if (aDGram) then
		flags := NI_NAMEREQD or NI_DGRAM or NI_NUMERICHOST
	else
		flags := NI_NAMEREQD or NI_NUMERICHOST;

	ZeroMemory(@addr, SizeOf(addr));
	ZeroMemory(@hostName[0], Length(hostName));
	ZeroMemory(@servName[0], Length(servName));

	addr.sin6_family := AF_INET6;
	addr.sin6_addr   := aAddr;
	addr.sin6_port   := 0;

	if (getnameinfo(@addr, SizeOf(addr), hostName, Length(hostName), servName, Length(servName), flags) = 0) then
		Result := string(hostName);
end;

{ TProxyType to string. }
function ProxyTypeToString(const aProxyType: TProxyType): string;
begin
	case aProxyType of
		ptNone:
		Result := '<none>';
		ptHTTP:
		Result := 'HTTP';
		ptSocks4:
		Result := 'Socks4';
		ptSocks5:
		Result := 'Socks5';
	end;
end;

{ TProxyType to URI scheme. }
function ProxyTypeToScheme(const aProxyType: TProxyType): string;
begin
	case aProxyType of
		ptNone:
		Result := '<none>';
		ptHTTP:
		Result := 'http://';
		ptSocks4:
		Result := 'socks4://';
		ptSocks5:
		Result := 'socks5://';
	end;
end;

{ ===================== }
{ TGetAddrPoolAsyncData }
{ ===================== }

{ GetAddrPoolAsync thread procedure. }
class function TGetAddrPoolAsyncData.GetAddrPoolAsyncThread(aParam: pointer): DWORD;
var
	data: PGetAddrPoolAsyncData;
	addr: PAddrInfo;
	ret : integer;
begin
	Result := 0;

	data               := PGetAddrPoolAsyncData(aParam);
	ret                := GetAddrPool(data^.host, data^.port, addr, data^.AddressFamily, data^.SocketType);
	data^.ThreadHandle := 0;
	if (Assigned(data^.OnResolved)) then
		data^.OnResolved(addr, ret);
end;

{ Constructor. Use this as constructor. }
procedure TGetAddrPoolAsyncData.Initialize;
begin
	host          := '';
	port          := '';
	AddressFamily := afUnspec;
	SocketType    := stStream;
	OnResolved    := nil;
	ThreadHandle  := 0;
end;

{ Aborts the thread if its running. }
procedure TGetAddrPoolAsyncData.Abort;
begin
	if (ThreadHandle <> 0) then
	begin
		TerminateThread(ThreadHandle, 0);
		ThreadHandle := 0;
	end;
	Initialize;
end;

{ Tells if the resolve thread for this data is still running. }
function TGetAddrPoolAsyncData.Running: boolean;
begin
	Result := (ThreadHandle <> 0);
end;

{ Calls GetAddrInfo in a thread. }
procedure GetAddrPoolAsync(var aData: TGetAddrPoolAsyncData);
var
	ThreadHandle: THandle;
	threadID    : cardinal;
begin
	threadID     := 0;
	ThreadHandle := CreateThread(nil, 0, @aData.GetAddrPoolAsyncThread, @aData, CREATE_SUSPENDED, threadID);
	if (ThreadHandle <> 0) then
	begin
		aData.ThreadHandle := ThreadHandle;
		ResumeThread(ThreadHandle);
	end;
end;

end.
