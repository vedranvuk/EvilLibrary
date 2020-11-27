unit EvilWorks.Api.WinPCap;

// Translated from v1.4.2.11

interface

uses
	WinApi.Windows,
	EvilWorks.Api.Winsock2, // you can remove this and use WinApi.Winsock instead. Required for u_int, etc
	EvilWorks.Api.WinPCap.Bpf;

const
	SWinPcap = 'wpcap.dll';

	PCAP_SRC_IF_STRING = 'rpcap://';

	PCAP_VERSION_MAJOR = 2;
	PCAP_VERSION_MINOR = 4;

	PCAP_ERRBUF_SIZE = 256;
	PCAP_IF_LOOPBACK = $00000001; // interface is loopback

	//
	//  Error codes for the pcap API.
	//  These will all be negative, so you can check for the success or
	//  failure of a call that returns these codes by checking for a
	//  negative value.
	//

	PCAP_ERROR                = - 1; // generic error code
	PCAP_ERROR_BREAK          = - 2; // loop terminated by pcap_breakloop
	PCAP_ERROR_NOT_ACTIVATED  = - 3; // the capture needs to be activated
	PCAP_ERROR_ACTIVATED      = - 4; // the operation can't be performed on already activated captures
	PCAP_ERROR_NO_SUCH_DEVICE = - 5; // no such device exists
	PCAP_ERROR_RFMON_NOTSUP   = - 6; // this device doesn't support rfmon (monitor) mode
	PCAP_ERROR_NOT_RFMON      = - 7; // operation supported only in monitor mode
	PCAP_ERROR_PERM_DENIED    = - 8; // no permission to open the device
	PCAP_ERROR_IFACE_NOT_UP   = - 9; // interface isn't up

	//
	//  Warning codes for the pcap API.
	//  These will all be positive and non-zero, so they won't look like
	//  errors.
	//

	PCAP_WARNING                = 1; // generic warning code */
	PCAP_WARNING_PROMISC_NOTSUP = 2; // this device doesn't support promiscuous mode */

	MODE_CAPT = 0;
	MODE_STAT = 1;
	MODE_MON  = 2;

	PCAP_OPENFLAG_PROMISCUOUS = 1;

type
	// extra data types.
	pu_char  = ^u_char;
	ppu_char = ^pu_char;

	ppinteger = ^pinteger;

	//	pcap_t = pcap;
	Pcap    = pointer;
	ppcap   = ^Pcap;
	pcap_t  = Pcap;
	ppcap_t = ^pcap_t;

	//	pcap_dumper_t = pcap_dumper;
	pcap_dumper  = pointer;
	ppcap_dumper = ^pcap_dumper;

	pcap_dumper_t  = pcap_dumper;
	ppcap_dumper_t = ^pcap_dumper_t;

	//	pcap_if_t     = pcap_if;
	//	pcap_addr_t   = pcap_addr;

	//  The first record in the file contains saved values for some
	//  of the flags used in the printout phases of tcpdump.
	//  Many fields here are 32 bit ints so compilers won't insert unwanted
	//  padding; these files need to be interchangeable across architectures.
	//
	//  Do not change the layout of this structure, in any way (this includes
	//  changes that only affect the length of fields in this structure).
	//
	//  Also, do not change the interpretation of any of the members of this
	//  structure, in any way (this includes using values other than
	//  LINKTYPE_ values, as defined in "savefile.c", in the "linktype"
	//  field).
	//
	//  Instead:
	//
	//      introduce a new structure for the new format, if the layout
	//      of the structure changed;
	//
	//      send mail to "tcpdump-workers@lists.tcpdump.org", requesting
	//      a new magic number for your new capture file format, and, when
	//      you get the new magic number, put it in "savefile.c";
	//
	//      use that magic number for save files with the changed file
	//      header;
	//
	//      make the code in "savefile.c" capable of reading files with
	//      the old file header as well as files with the new file header
	//      (using the magic number to determine the header format).
	//
	//  Then supply the changes as a patch at
	//
	//      http://sourceforge.net/projects/libpcap/
	//
	//  so that future versions of libpcap and programs that use it (such as
	//  tcpdump) will be able to read your new capture file format.

	{ pcap_file_header }
	pcap_file_header = record
		magic: bpf_u_int32;
		version_major: u_short;
		version_minor: u_short;
		thiszone: bpf_int32;   // gmt to local correction
		sigfigs: bpf_u_int32;  // accuracy of timestamps
		snaplen: bpf_u_int32;  // max length saved portion of each pkt
		linktype: bpf_u_int32; // data link type (LINKTYPE_*)
	end;

	{ pcap_direction_t }
	pcap_direction_t = (
	  PCAP_D_INOUT = 0,
	  PCAP_D_IN,
	  PCAP_D_OUT
	  );

	//
	//  Generic per-packet information, as supplied by libpcap.
	//
	//  The time stamp can and should be a "struct timeval", regardless of
	//  whether your system supports 32-bit tv_sec in "struct timeval",
	//  64-bit tv_sec in "struct timeval", or both if it supports both 32-bit
	//  and 64-bit applications.  The on-disk format of savefiles uses 32-bit
	//  tv_sec (and tv_usec); this structure is irrelevant to that.  32-bit
	//  and 64-bit versions of libpcap, even if they're on the same platform,
	//  should supply the appropriate version of "struct timeval", even if
	//  that's not what the underlying packet capture mechanism supplies.
	//

	{ pcap_pkthdr }
	ppcap_pkthdr  = ^pcap_pkthdr;
	pppcap_pkthdr = ^ppcap_pkthdr;

	pcap_pkthdr = record
		ts: timeval;         // time stamp */
		caplen: bpf_u_int32; // length of portion present */
		len: bpf_u_int32;    // length this packet (off wire) */
	end;

	//
	//  As returned by the pcap_stats()
	//

	{ pcap_stat }
	ppcap_stat = ^pcap_stat;

	pcap_stat = record
		ps_recv: u_int;   // number of packets received
		ps_drop: u_int;   // number of packets dropped
		ps_ifdrop: u_int; // drops by interface XXX not yet supported
		{ #ifdef HAVE_REMOTE }
		ps_capt: u_int;    // number of packets that are received by the application; please get rid off the Win32 ifdef
		ps_sent: u_int;    // number of packets sent by the server on the network
		ps_netdrop: u_int; // number of packets lost on the network
		{ #endif HAVE_REMOTE }
	end;

	//
	//  As returned by the pcap_stats_ex()
	//

	{ pcap_stat_ex }
	ppcap_stat_ex = ^pcap_stat_ex;

	pcap_stat_ex = record
		rx_packets: u_long; // total packets received
		tx_packets: u_long; // total packets transmitted
		rx_bytes: u_long;   // total bytes received
		tx_bytes: u_long;   // total bytes transmitted
		rx_errors: u_long;  // bad packets received
		tx_errors: u_long;  // packet transmit problems
		rx_dropped: u_long; // no space in Rx buffers
		tx_dropped: u_long; // no space available for Tx
		multicast: u_long;  // multicast packets received
		collisions: u_long;

		// detailed rx_errors
		rx_length_errors: u_long;
		rx_over_errors: u_long;   // receiver ring buff overflow
		rx_crc_errors: u_long;    // recv'd pkt with crc error
		rx_frame_errors: u_long;  // recv'd frame alignment error
		rx_fifo_errors: u_long;   // recv'r fifo overrun
		rx_missed_errors: u_long; // recv'r missed packet

		// detailed tx_errors
		tx_aborted_errors: u_long;
		tx_carrier_errors: u_long;
		tx_fifo_errors: u_long;
		tx_heartbeat_errors: u_long;
		tx_window_errors: u_long;
	end;

	{ pcap_addr }
	ppcap_addr = ^pcap_addr;

	pcap_addr = record
		next: ppcap_addr;
		addr: psockaddr;      // address
		netmask: psockaddr;   // netmask for that address
		broadaddr: psockaddr; // broadcast address for that address
		dstaddr: psockaddr;   // P2P destination address for that address
	end;

	pcap_addr_t  = ppcap_addr;
	ppcap_addr_t = ^pcap_addr_t;

	ppcap_handler = ^pcap_handler;
	pcap_handler  = procedure(c: pu_char; h: ppcap_pkthdr; r: pu_char);

	//
	//  Item in a list of interfaces.
	//

	{ pcap_if }
	ppcap_if    = ^pcap_if;
	pppcap_if_t = ^ppcap_if_t;

	pcap_if = record
		next: ppcap_if;
		name: pansichar;        // name to hand to "pcap_open_live()
		description: pansichar; // textual description of interface, or NULL
		addresses: ppcap_addr;
		flags: bpf_u_int32; // PCAP_IF_ interface flags
	end;

	pcap_if_t  = pcap_if;
	ppcap_if_t = ^pcap_if_t;

	{ pcap_rmtauth }
	ppcap_rmtauth = ^pcap_rmtauth;

	pcap_rmtauth = record
		typ: integer;
		username: pansichar;
		password: pansichar;
	end;

function pcap_lookupdev(errbuff: pansichar): pansichar; cdecl; external SWinPcap name 'pcap_lookupdev';
function pcap_lookupnet(const device: pansichar; netp: bpf_u_int32; maskp: bpf_u_int32; errbuf: pansichar): integer; cdecl; external SWinPcap name 'pcap_lookupnet';

function pcap_create(const a: pansichar; b: pansichar): ppcap_t; cdecl; external SWinPcap name 'pcap_create';
function pcap_set_snaplen(p: ppcap_t; v: integer): integer; cdecl; external SWinPcap name 'pcap_set_snaplen';
function pcap_set_promisc(p: ppcap_t; v: integer): integer; cdecl; external SWinPcap name 'pcap_set_promisc';
function pcap_can_set_rfmon(p: ppcap_t): integer; cdecl; external SWinPcap name 'pcap_can_set_rfmon';
function pcap_set_rfmon(p: ppcap_t; v: integer): integer; cdecl; external SWinPcap name 'pcap_set_rfmon';
function pcap_set_timeout(p: ppcap_t; v: integer): integer; cdecl; external SWinPcap name 'pcap_set_timeout';
function pcap_set_buffer_size(p: ppcap_t; v: integer): integer; cdecl; external SWinPcap name 'pcap_set_buffer_size';
function pcap_activate(p: ppcap_t): integer; cdecl; external SWinPcap name 'pcap_activate';

function pcap_open_live(const device: pansichar; snaplen, promisc, to_ms: integer; ebuf: pansichar): ppcap_t; cdecl; external SWinPcap name 'pcap_open_live';
function pcap_open_dead(linktype, snaplen: integer): ppcap_t; cdecl; external SWinPcap name 'pcap_open_dead';
function pcap_open_offline(const fname: pansichar; errbuf: pansichar): ppcap_t; cdecl; external SWinPcap name 'pcap_open_offline';
function pcap_hopen_offline(p: intptr; c: pansichar): ppcap_t; cdecl; external SWinPcap name 'pcap_hopen_offline';

procedure pcap_close(p: ppcap_t); cdecl; external SWinPcap name 'pcap_close';
function pcap_loop(p: ppcap_t; cnt: integer; callback: pcap_handler; user: pu_char): integer; cdecl; external SWinPcap name 'pcap_loop';
function pcap_dispatch(p: ppcap_t; cnt: integer; callback: pcap_handler; user: pu_char): integer; cdecl; external SWinPcap name 'pcap_dispatch';
function pcap_next(p: ppcap_t; pkt_header: ppcap_pkthdr): pu_char; cdecl; external SWinPcap name 'pcap_next';

function pcap_next_ex(p: ppcap_t; pkt_header: pppcap_pkthdr; const pkt_data: ppu_char): integer; cdecl; external SWinPcap name 'pcap_next_ex';
procedure pcap_breakloop(p: ppcap_t); cdecl; external SWinPcap name 'pcap_breakloop';
function pcap_stats(p: ppcap_t; ps: ppcap_stat): integer; cdecl; external SWinPcap name 'pcap_stats';
function pcap_setfilter(p: ppcap_t; prg: pbpf_program): integer; cdecl; external SWinPcap name 'pcap_setfilter';
function pcap_setdirection(p: ppcap_t; dir: pcap_direction_t): integer; cdecl; external SWinPcap name 'pcap_setdirection';

function pcap_getnonblock(p: ppcap_t; errbuf: pansichar): integer; cdecl; external SWinPcap name 'pcap_getnonblock';
function pcap_setnonblock(p: ppcap_t; nonblock: integer; errbuf: pansichar): integer; cdecl; external SWinPcap name 'pcap_setnonblock';
function pcap_inject(p: ppcap_t; const data: pointer; size: size_t): integer; cdecl; external SWinPcap name 'pcap_inject';
function pcap_sendpacket(p: ppcap_t; const buf: pu_char; size: integer): integer; cdecl; external SWinPcap name 'pcap_sendpacket';

function pcap_statustostr(code: integer): pansichar; cdecl; external SWinPcap name 'pcap_statustostr';
function pcap_strerror(code: integer): pansichar; cdecl; external SWinPcap name 'pcap_strerror';
function pcap_geterr(p: ppcap_t): pansichar; cdecl; external SWinPcap name 'pcap_geterr';
procedure pcap_perror(p: ppcap_t; buff: pansichar); cdecl; external SWinPcap name 'pcap_perror';

function pcap_compile(p: ppcap_t; fp: pbpf_program; const str: pansichar; optimize: integer; netmask: bpf_u_int32): integer; cdecl; external SWinPcap name 'pcap_compile';
function pcap_compile_nopcap(snaplen_arg, linktype_arg: integer; progrm: pbpf_program; const buf: pansichar; optimize: integer; mask: bpf_u_int32): integer; cdecl;
  external SWinPcap name 'pcap_compile_nopcap';
procedure pcap_freecode(prg: pbpf_program); cdecl; external SWinPcap name 'pcap_freecode';

function pcap_offline_filter(fp: pbpf_program; const pkt_hdr: ppcap_pkthdr; const pkt_data: pu_char): integer; cdecl; external SWinPcap name 'pcap_offline_filter';

function pcap_datalink(p: ppcap): integer; cdecl; external SWinPcap name 'pcap_datalink';
function pcap_datalink_ext(p: ppcap): integer; cdecl; external SWinPcap name 'pcap_datalink_ext';
function pcap_list_datalinks(p: ppcap; i: ppinteger): integer; cdecl; external SWinPcap name 'pcap_list_datalinks';
function pcap_set_datalink(p: ppcap; i: integer): integer; cdecl; external SWinPcap name 'pcap_set_datalink';
function pcap_datalink_name_to_val(const name: pansichar): integer; cdecl; external SWinPcap name 'pcap_datalink_name_to_val';
function pcap_datalink_val_to_name(i: integer): pansichar; cdecl; external SWinPcap name 'pcap_datalink_val_to_name';
function pcap_datalink_val_to_description(i: integer): pansichar; cdecl; external SWinPcap name 'pcap_datalink_val_to_description';
procedure pcap_free_datalinks(i: integer); cdecl; external SWinPcap name 'pcap_free_datalinks';

function pcap_snapshot(p: ppcap): integer; cdecl; external SWinPcap name 'pcap_snapshot';
function pcap_is_swapped(p: ppcap): integer; cdecl; external SWinPcap name 'pcap_is_swapped';
function pcap_major_version(p: ppcap): integer; cdecl; external SWinPcap name 'pcap_major_version';
function pcap_minor_version(p: ppcap): integer; cdecl; external SWinPcap name 'pcap_minor_version';

// XXX
function pcap_file(p: ppcap): PHandle; cdecl; external SWinPcap name 'pcap_file';
function pcap_fileno(p: ppcap): integer; cdecl; external SWinPcap name 'pcap_fileno';

function pcap_dump_open(p: ppcap_t; const data: pansichar): pcap_dumper_t; cdecl; external SWinPcap name 'pcap_dump_open';
function pcap_dump_fopen(p: ppcap_t; fp: PHandle): pcap_dumper_t; cdecl; external SWinPcap name 'pcap_dump_fopen';
function pcap_dump_file(dmp: ppcap_dumper_t): PHandle; cdecl; external SWinPcap name 'pcap_dump_file';
function pcap_dump_ftell(dmp: ppcap_dumper_t): long; cdecl; external SWinPcap name 'pcap_dump_ftell';
function pcap_dump_flush(dmp: ppcap_dumper_t): integer; cdecl; external SWinPcap name 'pcap_dump_flush';
procedure pcap_dump_close(dmp: ppcap_dumper_t); cdecl; external SWinPcap name 'pcap_dump_close';
procedure pcap_dump(p: pu_char; const h: ppcap_pkthdr; const sp: pu_char); cdecl; external SWinPcap name 'pcap_dump';

function pcap_findalldevs(devs: pppcap_if_t; errbuf: pansichar): integer; cdecl; external SWinPcap name 'pcap_findalldevs';
function pcap_findalldevs_ex(source: pansichar; auth: ppcap_rmtauth; alldevs: pppcap_if_t; errbuff: pansichar): integer; cdecl; external SWinPcap name 'pcap_findalldevs_ex';
procedure pcap_freealldevs(devs: ppcap_if_t); cdecl; external SWinPcap name 'pcap_freealldevs';

function pcap_lib_version: pansichar; cdecl; external SWinPcap name 'pcap_lib_version';

// XXX this guy lives in the Bpf tree
function bpf_filter(const struct: pbpf_insn; const flt: pu_char; a, b: u_int): u_int; cdecl; external SWinPcap name 'bpf_filter';
function bpf_validate(const struct: pbpf_insn; i: integer): integer; cdecl; external SWinPcap name 'bpf_validate';
function bpf_image(const struct: pbpf_insn; a: integer): pansichar; cdecl; external SWinPcap name 'bpf_image';
procedure bpf_dump(const struct: pbpf_program; a: integer); cdecl; external SWinPcap name 'bpf_dump';

//
//  Win32 definitions
//
function pcap_setbuff(p: ppcap_t; dim: integer): integer; cdecl; external SWinPcap name 'pcap_setbuff';
function pcap_setmode(p: ppcap_t; mode: integer): integer; cdecl; external SWinPcap name 'pcap_setmode';
function pcap_setmintocopy(p: ppcap_t; size: integer): integer; cdecl; external SWinPcap name 'pcap_setmintocopy';

function pcap_open(const source: pansichar; snaplen, flags, read_timeout: integer; auth: ppcap_rmtauth; errbuf: pansichar): ppcap_t; cdecl; external SWinPcap name 'pcap_open';

//
//    Macros for the value returned by pcap_datalink_ext().
//
//    If LT_FCS_LENGTH_PRESENT(x) is true, the LT_FCS_LENGTH(x) macro
//    gives the FCS length of packets in the capture.
//
function LT_FCS_LENGTH_PRESENT(x: u_int): u_int;
function LT_FCS_LENGTH(x: u_int): u_int;
function LT_FCS_DATALINK_EXT(x: u_int): u_int;

implementation

function LT_FCS_LENGTH_PRESENT(x: u_int): u_int;
begin
	Result := (x and $04000000);
end;

function LT_FCS_LENGTH(x: u_int): u_int;
begin
	Result := ((x and $F0000000) shr 28);
end;

function LT_FCS_DATALINK_EXT(x: u_int): u_int;
begin
	Result := (((x and $F) shl 28) or $04000000);
end;

end.
