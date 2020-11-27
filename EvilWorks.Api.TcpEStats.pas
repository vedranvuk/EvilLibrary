unit EvilWorks.Api.TcpEStats;

interface

uses
	WinApi.Windows;

type

	//
	// Please don't change the order of this enum. The order defined in this
	// enum needs to match the order in EstatsToTcpObjectMappingTable.
	//

	TCP_ESTATS_TYPE = (
	  TcpConnectionEstatsSynOpts,
	  TcpConnectionEstatsData,
	  TcpConnectionEstatsSndCong,
	  TcpConnectionEstatsPath,
	  TcpConnectionEstatsSendBuff,
	  TcpConnectionEstatsRec,
	  TcpConnectionEstatsObsRec,
	  TcpConnectionEstatsBandwidth,
	  TcpConnectionEstatsFineRtt,
	  TcpConnectionEstatsMaximum
	  );
	PTCP_ESTATS_TYPE = ^TCP_ESTATS_TYPE;

	//
	// TCP_BOOLEAN_OPTIONAL
	//
	// Define the states that a caller can specify when updating a boolean field.
	//

	TCP_BOOLEAN_OPTIONAL = (
	  TcpBoolOptDisabled = 0,
	  TcpBoolOptEnabled,
	  TcpBoolOptUnchanged = - 1
	  );
	PTCP_BOOLEAN_OPTIONAL = ^TCP_BOOLEAN_OPTIONAL;

	//
	// TCP_ESTATS_SYN_OPTS_ROS
	//
	// Define extended SYN-exchange information maintained for TCP connections.
	//

	TCP_ESTATS_SYN_OPTS_ROS_v0 = record
		ActiveOpen: BOOLEAN;
		MssRcvd: ULONG;
		MssSent: ULONG;
	end;
	PTCP_ESTATS_SYN_OPTS_ROS_v0 = ^TCP_ESTATS_SYN_OPTS_ROS_v0;

	//
	// TCP_SOFT_ERROR
	//
	// Enumerate the non-fatal errors recorded on each connection.
	//

	TCP_SOFT_ERROR = (
	  TcpErrorNone = 0,
	  TcpErrorBelowDataWindow,
	  TcpErrorAboveDataWindow,
	  TcpErrorBelowAckWindow,
	  TcpErrorAboveAckWindow,
	  TcpErrorBelowTsWindow,
	  TcpErrorAboveTsWindow,
	  TcpErrorDataChecksumError,
	  TcpErrorDataLengthError,
	  TcpErrorMaxSoftError
	  );
	PTCP_SOFT_ERROR = ^TCP_SOFT_ERROR;

	//
	// TCP_ESTATS_DATA_ROD
	//
	// Define extended data-transfer information for TCP connections.
	//

	TCP_ESTATS_DATA_ROD_v0 = record
		DataBytesOut: ULONG64;
		DataSegsOut: ULONG64;
		DataBytesIn: ULONG64;
		DataSegsIn: ULONG64;
		SegsOut: ULONG64;
		SegsIn: ULONG64;
		SoftErrors: ULONG;
		SoftErrorReason: ULONG;
		SndUna: ULONG;
		SndNxt: ULONG;
		SndMax: ULONG;
		ThruBytesAcked: ULONG64;
		RcvNext: ULONG;
		ThruBytesReceived: ULONG64;
	end;
	PTCP_ESTATS_DATA_ROD_v0 = ^TCP_ESTATS_DATA_ROD_v0;

	//
	// TCP_ESTATS_DATA_RW
	//
	// Define structure for enabling extended data-transfer information.
	//

	TCP_ESTATS_DATA_RW_v0 = record
		EnableCollection: BOOLEAN;
	end;
	PTCP_ESTATS_DATA_RW_v0 = ^TCP_ESTATS_DATA_RW_v0;

	//
	// TCP_ESTATS_SND_CONG_ROD
	//
	// Define extended sender-congestion information for TCP connections.
	//

	TCP_ESTATS_SND_CONG_ROD_v0 = record
		SndLimTransRwin: ULONG;
		SndLimTimeRwin: ULONG;
		SndLimBytesRwin: SIZE_T;
		SndLimTransCwnd: ULONG;
		SndLimTimeCwnd: ULONG;
		SndLimBytesCwnd: SIZE_T;
		SndLimTransSnd: ULONG;
		SndLimTimeSnd: ULONG;
		SndLimBytesSnd: SIZE_T;
		SlowStart: ULONG;
		CongAvoid: ULONG;
		OtherReductions: ULONG;
		CurCwnd: ULONG;
		MaxSsCwnd: ULONG;
		MaxCaCwnd: ULONG;
		CurSsthresh: ULONG;
		MaxSsthresh: ULONG;
		MinSsthresh: ULONG;
	end;
	PTCP_ESTATS_SND_CONG_ROD_v0 = ^TCP_ESTATS_SND_CONG_ROD_v0;

	//
	// TCP_ESTATS_SND_CONG_ROS
	//
	// Define static extended sender-congestion information for TCP connections.

	TCP_ESTATS_SND_CONG_ROS_v0 = record
		LimCwnd: ULONG;
	end;
	PTCP_ESTATS_SND_CONG_ROS_v0 = ^TCP_ESTATS_SND_CONG_ROS_v0;

	//
	// TCP_ESTATS_SND_CONG_RW
	//
	// Define structure for enabling extended sender-congestion information.
	//

	TCP_ESTATS_SND_CONG_RW = record
		EnableCollection: BOOLEAN;
	end;
	PTCP_ESTATS_SND_CONG_RW = ^TCP_ESTATS_SND_CONG_RW;

	//
	// TCP_ESTATS_PATH_ROD
	//
	// Define extended path-measurement information for TCP connections.
	//

	TCP_ESTATS_PATH_ROD_v0 = record
		FastRetran: ULONG;
		Timeouts: ULONG;
		SubsequentTimeouts: ULONG;
		CurTimeoutCount: ULONG;
		AbruptTimeouts: ULONG;
		PktsRetrans: ULONG;
		BytesRetrans: ULONG;
		DupAcksIn: ULONG;
		SacksRcvd: ULONG;
		SackBlocksRcvd: ULONG;
		CongSignals: ULONG;
		PreCongSumCwnd: ULONG;
		PreCongSumRtt: ULONG;
		PostCongSumRtt: ULONG;
		PostCongCountRtt: ULONG;
		EcnSignals: ULONG;
		EceRcvd: ULONG;
		SendStall: ULONG;
		QuenchRcvd: ULONG;
		RetranThresh: ULONG;
		SndDupAckEpisodes: ULONG;
		SumBytesReordered: ULONG;
		NonRecovDa: ULONG;
		NonRecovDaEpisodes: ULONG;
		AckAfterFr: ULONG;
		DsackDups: ULONG;
		SampleRtt: ULONG;
		SmoothedRtt: ULONG;
		RttVar: ULONG;
		MaxRtt: ULONG;
		MinRtt: ULONG;
		SumRtt: ULONG;
		CountRtt: ULONG;
		CurRto: ULONG;
		MaxRto: ULONG;
		MinRto: ULONG;
		CurMss: ULONG;
		MaxMss: ULONG;
		MinMss: ULONG;
		SpuriousRtoDetections: ULONG;

	end;
	PTCP_ESTATS_PATH_ROD_v0 = ^TCP_ESTATS_PATH_ROD_v0;

	//
	// TCP_ESTATS_PATH_ROS
	//
	// Define structure for enabling path-measurement information.
	//

	TCP_ESTATS_PATH_RW_v0 = record
		EnableCollection: BOOLEAN;
	end;
	PTCP_ESTATS_PATH_RW_v0 = ^TCP_ESTATS_PATH_RW_v0;

	//
	// TCP_ESTATS_SEND_BUFF_ROD
	//
	// Define extended output-queuing information for TCP connections.
	//

	TCP_ESTATS_SEND_BUFF_ROD_v0 = record
		CurRetxQueue: SIZE_T;
		MaxRetxQueue: SIZE_T;
		CurAppWQueue: SIZE_T;
		MaxAppWQueue: SIZE_T;
	end;
	PTCP_ESTATS_SEND_BUFF_ROD_v0 = ^TCP_ESTATS_SEND_BUFF_ROD_v0;

	//
	// TCP_ESTATS_SEND_BUFF_RW
	//
	// Define structure for enabling output-queuing information.
	//

	TCP_ESTATS_SEND_BUFF_RW_v0 = record
		EnableCollection: BOOLEAN;
	end;
	PTCP_ESTATS_SEND_BUFF_RW_v0 = ^TCP_ESTATS_SEND_BUFF_RW_v0;

	//
	// TCP_ESTATS_REC_ROD
	//
	// Define extended local-receiver information for TCP connections.
	//

	TCP_ESTATS_REC_ROD_v0 = record
		CurRwinSent: ULONG;
		MaxRwinSent: ULONG;
		MinRwinSent: ULONG;
		LimRwin: ULONG;
		DupAckEpisodes: ULONG;
		DupAcksOut: ULONG;
		CeRcvd: ULONG;
		EcnSent: ULONG;
		EcnNoncesRcvd: ULONG;
		CurReasmQueue: ULONG;
		MaxReasmQueue: ULONG;
		CurAppRQueue: SIZE_T;
		MaxAppRQueue: SIZE_T;
		WinScaleSent: UCHAR;
	end;
	PTCP_ESTATS_REC_ROD_v0 = ^TCP_ESTATS_REC_ROD_v0;

	//
	// TCP_ESTATS_REC_RW
	//
	// Define structure for enabling local-receiver information.
	//

	TCP_ESTATS_REC_RW_v0 = record
		EnableCollection: BOOLEAN;
	end;
	PTCP_ESTATS_REC_RW_v0 = ^TCP_ESTATS_REC_RW_v0;

	//
	// TCP_ESTATS_OBS_REC_ROD
	//
	// Define extended remote-receiver information for TCP connections.
	//

	TCP_ESTATS_OBS_REC_ROD_v0 = record
		CurRwinRcvd: ULONG;
		MaxRwinRcvd: ULONG;
		MinRwinRcvd: ULONG;
		WinScaleRcvd: UCHAR;
	end;
	PTCP_ESTATS_OBS_REC_ROD_v0 = ^TCP_ESTATS_OBS_REC_ROD_v0;

	//
	// TCP_ESTATS_OBS_REC_RW
	//
	// Define structure for enabling remote-receiver information.
	//

	TCP_ESTATS_OBS_REC_RW_v0 = record
		EnableCollection: BOOLEAN;
	end;
	PTCP_ESTATS_OBS_REC_RW_v0 = ^TCP_ESTATS_OBS_REC_RW_v0;

	//
	// TCP_ESTATS_BW_RW
	//
	// Define the structure for enabling bandwidth estimation for TCP connections.
	//

	TCP_ESTATS_BANDWIDTH_RW_v0 = record
		EnableCollectionOutbound: TCP_BOOLEAN_OPTIONAL;
		EnableCollectionInbound: TCP_BOOLEAN_OPTIONAL;
	end;
	PTCP_ESTATS_BANDWIDTH_RW_v0 = ^TCP_ESTATS_BANDWIDTH_RW_v0;

	//
	// TCP_ESTATS_BW_ROD
	//
	// Define bandwidth estimation statistics for TCP connections.
	//
	// Bandwidth and Instability metrics are expressed as bits per second.
	//

	TCP_ESTATS_BANDWIDTH_ROD_v0 = record
		OutboundBandwidth: ULONG64;
		InboundBandwidth: ULONG64;
		OutboundInstability: ULONG64;
		InboundInstability: ULONG64;
		OutboundBandwidthPeaked: BOOLEAN;
		InboundBandwidthPeaked: BOOLEAN;
	end;
	PTCP_ESTATS_BANDWIDTH_ROD_v0 = ^TCP_ESTATS_BANDWIDTH_ROD_v0;

	//
	// TCP_ESTATS_FINE_RTT_RW
	//
	// Define the structure for enabling fine-grained RTT estimation for TCP
	// connections.
	//

	TCP_ESTATS_FINE_RTT_RW_v0 = record
		EnableCollection: BOOLEAN;
	end;
	PTCP_ESTATS_FINE_RTT_RW_v0 = ^TCP_ESTATS_FINE_RTT_RW_v0;

	//
	// TCP_ESTATS_FINE_RTT_ROD
	//
	// Define fine-grained RTT estimation statistics for TCP connections.
	//

	TCP_ESTATS_FINE_RTT_ROD_v0 = record
		RttVar: ULONG;
		MaxRtt: ULONG;
		MinRtt: ULONG;
		SumRtt: ULONG;
	end;
	PTCP_ESTATS_FINE_RTT_ROD_v0 = ^TCP_ESTATS_FINE_RTT_ROD_v0;

implementation

end.
