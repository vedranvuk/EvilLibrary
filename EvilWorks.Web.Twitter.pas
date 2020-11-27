//
// EvilLibrary by Vedran Vuk 2010-2012
//
// Name: 					EvilWorks.Web.Twitter
// Description: 			Twitter client.
// File last change date:   October 30th. 2012
// File version: 			Dev 0.0.0
// Licence:                 Free.
//

unit EvilWorks.Web.Twitter;

interface

uses
	Winapi.Windows,
	System.Classes,
	System.SysUtils,
	EvilWorks.Api.Winsock2,
	EvilWorks.Api.ZLib,
	EvilWorks.System.SysUtils,
	EvilWorks.System.StrUtils,
	EvilWorks.Web.AsyncSockets,
	EvilWorks.Web.HTTP,
	EvilWorks.Web.Base64,
	EvilWorks.Web.URI;

type
	{ Forward declarations. }
	TTwitterClient = class;

    { Events. }
	TOnResponse = procedure(aSender: TTwitterClient; const aResponse: string) of object;

    { TTwitterClient }
	TTwitterClient = class(TCustomHTTPClient)
	private
		FResponse  : TStringStream;
		FOnResponse: TOnResponse;
	protected
		procedure EventBodyAvailable(aData: TStream); override;
		procedure EventResponse(const aResponse: string);
	public
		constructor Create(aOwner: TComponent); override;
		destructor Destroy; override;
	published
		property AddressFamily;
		property Authorization;
		property BindHost;
		property BindPort;
		property ConnectTimeout;
		property ProxyChain;
		property RemoteHost;
		property RemotePort;
		property RequestHeaders;
		property SocketState;
		property SSL;
		property UserAgent;

		property OnConnected;
		property OnConnecting;
		property OnConnectTimeout;
		property OnDisconnected;
		property OnError;
		property OnLog;
		property OnProxyChainConnected;
		property OnProxyConnecting;
		property OnProxyConnected;
		property OnResolved;
		property OnResolving;
		property OnRequestHeaders;
		property OnResponseHeaders;

		property OnResponse: TOnResponse read FOnResponse write FOnResponse;
	end;

    { TTwitterClient }
	TTwitterRESTClient = class(TTwitterClient)
	public
		constructor Create(aOwner: TComponent); override;
	public

        { ======== }
        { Timeline }
        { ======== }

		procedure TimelineHomeTimeline(
		  const aCount: integer = 20;
		  const aSinceID: int64 = - 1;
		  const aMaxID: int64 = - 1;
		  const aTrimUser: boolean = False;
		  const aExcludeReplies: boolean = False;
		  const aContributorDetails: boolean = False;
		  const aIncludeEntities: boolean = True
		  );

        { ====== }
    	{ Tweets }
        { ====== }

		procedure TweetsStatusUpdate(
		  const aStatus: string;
		  const aInReplyToID: int64 = - 1;
		  const aLatitude: double = - 180;
		  const aLongitude: double = - 360;
		  const aPlaceID: string = '';
		  const aDisplayCoordinates: boolean = False;
		  const aTrimUser: boolean = False
		  );

        { ==== }
        { Help }
        { ==== }

		procedure HelpConfiguration;

        { =========== }
        { Unsupported }
        { =========== }

		procedure RelatedResults(
		  const aID: int64;
		  const aIncludeEntities: boolean = True;
		  const aIncludeUserEntities: boolean = True;
		  const aIncludeCards: boolean = True;
		  const aSendErrorCodes: boolean = True
		  );

		procedure StatusActivity(const aID: int64);

	end;

    { TTwitterStreamClient }
	TTwitterStreamClient = class(TTwitterClient)
	private
		FMessageSize: integer;
		FMessageMark: integer;
	protected
		procedure EventBodyAvailable(aData: TStream); override;
	public
		constructor Create(aOwner: TComponent); override;

		procedure StatusesFilter(
		  const aFollow: TStrings;   // List of user IDs, indicating the users to return statuses for.
		  const aTrack: TStrings;    // Keywords to track.
		  const aLocations: TStrings // Set of bounding boxes to track.
		  );

		procedure User(
		  const aInclFollowers: boolean = False;
		  const aInclReplies: boolean = False;
		  const aKeywords: TStrings = nil;
		  const aLocations: TStrings = nil
		  );

	end;

implementation

{ TTwitterClient }

constructor TTwitterClient.Create(aOwner: TComponent);
begin
	inherited;
	UserAgent := 'EvilTwitter/0.1';

	Authorization.AuthorizationType := hatOAuth1;
	Authorization.Enabled           := True;

	FResponse := TStringStream.Create;
end;

destructor TTwitterClient.Destroy;
begin
	FResponse.Free;
	inherited;
end;

procedure TTwitterClient.EventBodyAvailable(aData: TStream);
begin
	aData.Seek(0, soFromBeginning);
	EventResponse(TStringStream(aData).ReadString(aData.Size));
	FResponse.Clear;
end;

procedure TTwitterClient.EventResponse(const aResponse: string);
begin
	if (Assigned(FOnResponse)) then
		FOnResponse(Self, aResponse);
end;

{ TTwitterRESTClient }

constructor TTwitterRESTClient.Create(aOwner: TComponent);
begin
	inherited;
	Options := (Options + [hcoCombineChunks]);
end;

procedure TTwitterRESTClient.TimelineHomeTimeline(
  const aCount: integer; const aSinceID, aMaxID: int64;
  const aTrimUser, aExcludeReplies, aContributorDetails, aIncludeEntities: boolean);
const
	ResourceURI = 'https://api.twitter.com/1.1/statuses/home_timeline.json';
var
	t: TTokens;
	r: string;
begin
	r := ResourceURI;

	t.Clear;
	t.Add('count', TextFromInt(aCount));
	if (aSinceID > - 1) then
		t.Add('since_id', aSinceID);
	if (aMaxID > - 1) then
		t.Add('max_id', aMaxID);
	t.Add('trim_user', aTrimUser);
	t.Add('exclude_replies', aExcludeReplies);
	t.Add('contributor_details', aContributorDetails);
	t.Add('include_entities', aIncludeEntities);

	if (t.Empty = False) then
		r := r + '?' + t.AllTokens('&');

	Get(r, FResponse);
end;

procedure TTwitterRESTClient.TweetsStatusUpdate(
  const aStatus: string; const aInReplyToID: int64; const aLatitude, aLongitude: double;
  const aPlaceID: string; const aDisplayCoordinates, aTrimUser: boolean);
const
	ResourceURI = 'https://api.twitter.com/1.1/statuses/update.json';
var
	t: TTokens;
	r: string;
begin
	r := ResourceURI;

	t.Clear;
	if (aInReplyToID > - 1) then
		t.Add('in_reply_to_id', TextFromInt(aInReplyToID));
	if (aLatitude >= - 90) and (aLatitude <= 90) then
		t.Add('lat', TextFromFloat(aLatitude));
	if (aLongitude >= - 180) and (aLongitude <= 180) then
		t.Add('long', TextFromFloat(aLongitude));
	if (aPlaceID <> '') then
		t.Add('place_id', aPlaceID);
	if (aDisplayCoordinates) then
		t.Add('display_coordinates', TextFromBool(aDisplayCoordinates));
	if (aTrimUser) then
		t.Add('trim_user', TextFromBool(aTrimUser));

	if (t.Empty = False) then
		r := r + '?' + t.AllTokens('&');

	t.Clear;
	t.Add('status', aStatus);

	PostForm(r, t.AllTokens('&'), FResponse);
end;

procedure TTwitterRESTClient.HelpConfiguration;
const
	ResourceURI = 'https://api.twitter.com/1.1/help/configuration.json';
begin
	Get(ResourceURI, FResponse);
end;

procedure TTwitterRESTClient.RelatedResults(
  const aID: int64; const aIncludeEntities, aIncludeUserEntities, aIncludeCards, aSendErrorCodes: boolean);
const
	ResourceURI = 'https://api.twitter.com/1/related_results/show/';
var
	t: TTokens;
	r: string;
begin
	r := ResourceURI;

	t.Clear;
	if (aIncludeEntities) then
		t.Add('include_entities', 'true');
	if (aIncludeUserEntities) then
		t.Add('include_user_entities', 'true');
	if (aIncludeCards) then
		t.Add('include_cards', 'true');
	if (aSendErrorCodes) then
		t.Add('send_error_codes', 'true');

	if (t.Empty = False) then
		r := r + TextFromInt(aID) + '.json?' + t.AllTokens('&');

	Get(r, FResponse);
end;

procedure TTwitterRESTClient.StatusActivity(const aID: int64);
begin
	Get('https://api.twitter.com/i/statuses/' + TextFromInt(aID) + '/activity/summary.json', FResponse);
end;

{ TTwitterStreamClient }

constructor TTwitterStreamClient.Create(aOwner: TComponent);
begin
	inherited;
	Connection   := CKeepALive;
	FMessageSize := 0;
	FMessageMark := 0;
end;

procedure TTwitterStreamClient.EventBodyAvailable(aData: TStream);
var
	temp: string;
begin
	if (aData.Size < 2) then
		Exit;

    // Read in message size or Keep-alives.
	if (FMessageSize = 0) then
	begin
		aData.Seek(0, soFromBeginning);

    	// Optional Keep-alive linefeed between messages.
		if (TStringStream(aData).DataString = #13#10) then
		begin
			FResponse.Clear;
			Exit;
		end;

        // Get message size text.
		temp := TextFetchLine(TStringStream(aData).DataString);
		if (temp = '') then
			Exit; // If we are getting incomplete line, exit to buffer it.

        // Mark message start position in buffer.
		FMessageMark := (Length(temp) + 2);

        // Convert message size text to integer.
		FMessageSize := TextToInt(temp, - 1);
		if (FMessageSize = - 1) then
		begin
			HandleError( - 2, 'Error parsing length delimited message: Message size to integer failed.');
			Exit;
		end;
	end;

    // Check if we have complete message.
	aData.Seek(FMessageMark, soFromBeginning);
	if ((aData.Size - aData.Position) >= FMessageSize) then
	begin
		EventResponse(string(TStringStream(aData).ReadString(FMessageSize)));
		FMessageSize := 0;
		FMessageMark := 0;
		FResponse.Clear;
	end;
end;

procedure TTwitterStreamClient.StatusesFilter(const aFollow, aTrack, aLocations: TStrings);
const
	ResourceURI = 'https://stream.twitter.com/1.1/statuses/filter.json';
var
	t: TTokens;
begin
	aFollow.Delimiter    := ',';
	aTrack.Delimiter     := ',';
	aLocations.Delimiter := ',';

	t.Clear;
	if (aFollow.Count > 0) then
		t.Add('follow', aFollow.DelimitedText);
	if (aTrack.Count > 0) then
		t.Add('track', aTrack.DelimitedText);
	if (aLocations.Count > 0) then
		t.Add('locations', aLocations.DelimitedText);

	t.Add('delimited', 'length');

	PostForm(ResourceURI, t.AllTokens('&'), FResponse);
end;

procedure TTwitterStreamClient.User(
  const aInclFollowers, aInclReplies: boolean; const aKeywords, aLocations: TStrings);
const
	ResourceURI = 'https://userstream.twitter.com/1.1/user.json';
var
	t: TTokens;
begin
	t.Clear;
	if (aInclFollowers) then
		t.Add('with', 'followings')
	else
		t.Add('with', 'user');

	if (aInclReplies) then
		t.Add('replies', 'all');

	if (aKeywords <> nil) then
	begin
		aKeywords.Delimiter := ',';
		t.Add('track', aKeywords.DelimitedText);
	end;

	if (aLocations <> nil) then
	begin
		aKeywords.Delimiter := ',';
		t.Add('locations', aLocations.DelimitedText);
	end;

	Get(ResourceURI + '?delimited=length&' + t.AllTokens('&'), FResponse);
end;

end.
