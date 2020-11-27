//
// EvilLibrary by Vedran Vuk 2010-2012
//
// Name: 					EvilWorks.Web.TwitterTypes
// Description: 			Native implementation of Twitter data structures.
// File last change date:   December 14th. 2012
// File version: 			Dev 0.0.0
// Licence:                 Free.
//

unit EvilWorks.Web.TwitterTypes;

interface

uses
	System.Classes,
	System.SysUtils,
    System.Generics.Collections,
	Vcl.Graphics,
	EvilWorks.Generics.List,
	EvilWorks.Generics.AVLTree;

type
	{ Forward declarations }
	TTweet    = class;
	TUser     = class;
	TEntities = class;
	TPlace    = class;

	{ ============ }
	{ Helper types }
    { ============ }

	{ TIndices }
	TIndices = class(TPersistent)
	private
		FStarts: integer;
		FEnds  : integer;
	public
		procedure Assign(aSource: TPersistent); override;
	published
		property Starts: integer read FStarts write FStarts;
		property Ends  : integer read FEnds write FEnds;
	end;

    { ====== }
    { Tweets }
    { ====== }

	{ TContributor }
	TContributor = class(TPersistent)
	private
		FId        : int64;
		FIdStr     : string;
		FScreenName: string;
	public
		procedure Assign(aSource: TPersistent); override;
	published
		property Id        : int64 read FId write FId;
		property IdStr     : string read FIdStr write FIdStr;
		property ScreenName: string read FScreenName write FScreenName;
	end;

	{ TContributors }
	TContributors = TList<TContributor>;

	{ TCoordinate }
	TCoordinate = class(TPersistent)
	private
		FLongitude: double;
		FLattitude: double;
		FTyp      : string;
	public
		procedure Assign(aSource: TPersistent); override;
	published
		property Longitude: double read FLongitude write FLongitude;
		property Lattitude: double read FLattitude write FLattitude;
		property Typ      : string read FTyp write FTyp;
	end;

	{ TCurrentUserRetweet }
	TCurrentUserRetweet = class(TPersistent)
	private
		FIdStr: string;
		FId   : int64;
	public
		procedure Assign(aSource: TPersistent); override;
	published
		property Id   : int64 read FId write FId;
		property IdStr: string read FIdStr write FIdStr;
	end;

	{ TTweet }
	TTweet = class(TPersistent)
	private
		FContributors        : TContributors;
		FCoordinates         : TCoordinate;
		FCreatedAt           : TDateTime;
		FCurrentUserRetweet  : TCurrentUserRetweet;
		FEntities            : TEntities;
		FFavorited           : boolean;
		FId                  : int64;
		FIdStr               : string;
		FInReplyToScreenName : string;
		FInReplyToStatusId   : int64;
		FInReplyToStatusIdStr: string;
		FInReplyToUserId     : int64;
		FInReplyToUserIdStr  : string;
		FPossiblySensitive   : boolean;
		FRetweetCount        : integer;
		FRetweeted           : boolean;
		FSource              : string;
		FText                : string;
		FTruncated           : boolean;
		FWithheldCopyright   : boolean;
		FWithheldInCountries : string;
		FWithheldScope       : string;
		FUser                : TUser;
		procedure SetContributors(const Value: TContributors);
		procedure SetCoordinates(const Value: TCoordinate);
		procedure SetCurrentUserRetweet(const Value: TCurrentUserRetweet);
		procedure SetEntities(const Value: TEntities);
		procedure SetUser(const Value: TUser);
	public
		constructor Create;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;
	published
		property Contributors        : TContributors read FContributors write SetContributors;
		property Coordinates         : TCoordinate read FCoordinates write SetCoordinates;
		property CreatedAt           : TDateTime read FCreatedAt write FCreatedAt;
		property CurrentUserRetweet  : TCurrentUserRetweet read FCurrentUserRetweet write SetCurrentUserRetweet;
		property Entities            : TEntities read FEntities write SetEntities;
		property Favorited           : boolean read FFavorited write FFavorited;
		property Id                  : int64 read FId write FId;
		property IdStr               : string read FIdStr write FIdStr;
		property InReplyToScreenName : string read FInReplyToScreenName write FInReplyToScreenName;
		property InReplyToStatusId   : int64 read FInReplyToStatusId write FInReplyToStatusId;
		property InReplyToStatusIdStr: string read FInReplyToStatusIdStr write FInReplyToStatusIdStr;
		property InReplyToUserId     : int64 read FInReplyToUserId write FInReplyToUserId;
		property InReplyToUserIdStr  : string read FInReplyToUserIdStr write FInReplyToUserIdStr;
		property PossiblySensitive   : boolean read FPossiblySensitive write FPossiblySensitive;
		property RetweetCount        : integer read FRetweetCount write FRetweetCount;
		property Retweeted           : boolean read FRetweeted write FRetweeted;
		property Source              : string read FSource write FSource;
		property Text                : string read FText write FText;
		property Truncated           : boolean read FTruncated write FTruncated;
		property User                : TUser read FUser write SetUser;
		property WithheldCopyright   : boolean read FWithheldCopyright write FWithheldCopyright;
		property WithheldInCountries : string read FWithheldInCountries write FWithheldInCountries;
		property WithheldScope       : string read FWithheldScope write FWithheldScope;
	end;

    { TTweets }
	TTweets = class(TPersistent)
	private
		FItems: TList<TTweet>;
		procedure SetItems(const Value: TList<TTweet>);
	public
		constructor Create;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;
	published
		property Items: TList<TTweet> read FItems write SetItems;
	end;

    { ===== }
    { Users }
    { ===== }

    { TUser }
	TUser = class(TPersistent)
	private
		FUtcOffset                     : integer;
		FGeoEnabled                    : boolean;
		FFollowersCount                : integer;
		FName                          : string;
		FLocation                      : string;
		FListedCount                   : integer;
		FStatusesCount                 : integer;
		FFriendsCount                  : integer;
		FDefaultProfile                : boolean;
		FProfileImageUrlHttps          : string;
		FWithheldScope                 : string;
		FProfileBackgroundImageUrl     : string;
		FVerified                      : boolean;
		FProfileLinkColor              : TColor;
		FProfileBannerUrl              : string;
		FFollowing                     : boolean;
		FWithheldInCountries           : string;
		FProfileBackgroundColor        : TColor;
		FId                            : int64;
		FDefaultProfileImage           : boolean;
		FProfileSidebarBorderColor     : TColor;
		FStatus                        : TTweet;
		FProfileUseBackgroundImage     : boolean;
		FDescription                   : boolean;
		FProfileSidebarFillColor       : TColor;
		FProfileBackgroundTile         : boolean;
		FProfileBackgroundImageUrlHttps: string;
		FEntities                      : TEntities;
		FCreatedAt                     : TDateTime;
		FTimeZone                      : string;
		FShowAllInlineMedia            : boolean;
		FScreenName                    : string;
		FFavouritesCount               : integer;
		FProfileTextColor              : TColor;
		FUrl                           : string;
		FProfileImageUrl               : string;
		FIsTranslator                  : boolean;
		FProtectedAccount              : boolean;
		FIdStr                         : string;
		FContributorsEnabled           : boolean;
		FLang                          : string;
		FFollowRequestSent             : boolean;
		procedure SetStatus(const Value: TTweet);
		procedure SetEntities(const Value: TEntities);
	public
		constructor Create;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;
	published
		property ContributorsEnabled           : boolean read FContributorsEnabled write FContributorsEnabled;
		property CreatedAt                     : TDateTime read FCreatedAt write FCreatedAt;
		property DefaultProfile                : boolean read FDefaultProfile write FDefaultProfile;
		property DefaultProfileImage           : boolean read FDefaultProfileImage write FDefaultProfileImage;
		property Description                   : boolean read FDescription write FDescription;
		property Entities                      : TEntities read FEntities write SetEntities;
		property FavouritesCount               : integer read FFavouritesCount write FFavouritesCount;
		property FollowRequestSent             : boolean read FFollowRequestSent write FFollowRequestSent;
		property Following                     : boolean read FFollowing write FFollowing;
		property FollowersCount                : integer read FFollowersCount write FFollowersCount;
		property FriendsCount                  : integer read FFriendsCount write FFriendsCount;
		property GeoEnabled                    : boolean read FGeoEnabled write FGeoEnabled;
		property Id                            : int64 read FId write FId;
		property IdStr                         : string read FIdStr write FIdStr;
		property IsTranslator                  : boolean read FIsTranslator write FIsTranslator;
		property Lang                          : string read FLang write FLang;
		property ListedCount                   : integer read FListedCount write FListedCount;
		property Location                      : string read FLocation write FLocation;
		property name                          : string read FName write FName;
		property ProfileBackgroundColor        : TColor read FProfileBackgroundColor write FProfileBackgroundColor;
		property ProfileBackgroundImageUrl     : string read FProfileBackgroundImageUrl write FProfileBackgroundImageUrl;
		property ProfileBackgroundImageUrlHttps: string read FProfileBackgroundImageUrlHttps write FProfileBackgroundImageUrlHttps;
		property ProfileBackgroundTile         : boolean read FProfileBackgroundTile write FProfileBackgroundTile;
		property ProfileBannerUrl              : string read FProfileBannerUrl write FProfileBannerUrl;
		property ProfileImageUrl               : string read FProfileImageUrl write FProfileImageUrl;
		property ProfileImageUrlHttps          : string read FProfileImageUrlHttps write FProfileImageUrlHttps;
		property ProfileLinkColor              : TColor read FProfileLinkColor write FProfileLinkColor;
		property ProfileSidebarBorderColor     : TColor read FProfileSidebarBorderColor write FProfileSidebarBorderColor;
		property ProfileSidebarFillColor       : TColor read FProfileSidebarFillColor write FProfileSidebarFillColor;
		property ProfileTextColor              : TColor read FProfileTextColor write FProfileTextColor;
		property ProfileUseBackgroundImage     : boolean read FProfileUseBackgroundImage write FProfileUseBackgroundImage;
		property ProtectedAccount              : boolean read FProtectedAccount write FProtectedAccount;
		property ScreenName                    : string read FScreenName write FScreenName;
		property ShowAllInlineMedia            : boolean read FShowAllInlineMedia write FShowAllInlineMedia;
		property Status                        : TTweet read FStatus write SetStatus;
		property StatusesCount                 : integer read FStatusesCount write FStatusesCount;
		property TimeZone                      : string read FTimeZone write FTimeZone;
		property Url                           : string read FUrl write FUrl;
		property UtcOffset                     : integer read FUtcOffset write FUtcOffset;
		property Verified                      : boolean read FVerified write FVerified;
		property WithheldInCountries           : string read FWithheldInCountries write FWithheldInCountries;
		property WithheldScope                 : string read FWithheldScope write FWithheldScope;
	end;

    { ======== }
    { Entities }
    { ======== }

	{ THashTagItem }
	THashTagItem = class(TPersistent)
	private
		FText   : string;
		FIndices: TIndices;
		procedure SetIndices(const Value: TIndices);
	public
		constructor Create;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;
	published
		property Indices: TIndices read FIndices write SetIndices;
		property Text   : string read FText write FText;
	end;

	{ THashTagItems }
	THashTagItems = TList<THashTagItem>;

	{ TMediaSize }
	TMediaSize = class(TPersistent)
	public type

    	{ TMediaResizeType }
		TMediaResizeType = (
		  mrtCrop,
		  mrtFit
		  );

	private
		FW     : integer;
		FH     : integer;
		FResize: TMediaResizeType;
	public
		procedure Assign(aSource: TPersistent); override;
	published
		property W     : integer read FW write FW;
		property H     : integer read FH write FH;
		property Resize: TMediaResizeType read FResize write FResize;
	end;

    { TMediaSizes }
	TMediaSizes = class(TPersistent)
	private
		FLarge : TMediaSize;
		FMedium: TMediaSize;
		FThumb : TMediaSize;
		FSmall : TMediaSize;
		procedure SetLarge(const Value: TMediaSize);
		procedure SetMedium(const Value: TMediaSize);
		procedure SetSmall(const Value: TMediaSize);
		procedure SetThumb(const Value: TMediaSize);
	public
		constructor Create;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;
	published
		property Thumb : TMediaSize read FThumb write SetThumb;
		property Small : TMediaSize read FSmall write SetSmall;
		property Medium: TMediaSize read FMedium write SetMedium;
		property Large : TMediaSize read FLarge write SetLarge;
	end;

    { TMediaItem }
	TMediaItem = class(TPersistent)
	private
		FId               : int64;
		FDisplayUrl       : string;
		FExpandedUrl      : string;
		FIdStr            : string;
		FIndices          : TIndices;
		FMediaUrlHttps    : string;
		FMediaUrl         : string;
		FSizes            : TMediaSizes;
		FSourceStatusIdStr: string;
		FSourceStatusId   : int64;
		FTyp              : string;
		FUrl              : string;
		procedure SetIndices(const Value: TIndices);
		procedure SetSizes(const Value: TMediaSizes);
	public
		constructor Create;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;
	published
		property DisplayUrl       : string read FDisplayUrl write FDisplayUrl;
		property ExpandedUrl      : string read FExpandedUrl write FExpandedUrl;
		property Id               : int64 read FId write FId;
		property IdStr            : string read FIdStr write FIdStr;
		property Indices          : TIndices read FIndices write SetIndices;
		property MediaUrl         : string read FMediaUrl write FMediaUrl;
		property MediaUrlHttps    : string read FMediaUrlHttps write FMediaUrlHttps;
		property Sizes            : TMediaSizes read FSizes write SetSizes;
		property SourceStatusId   : int64 read FSourceStatusId write FSourceStatusId;
		property SourceStatusIdStr: string read FSourceStatusIdStr write FSourceStatusIdStr;
		property Typ              : string read FTyp write FTyp;
		property Url              : string read FUrl write FUrl;
	end;

    { TMediaItems }
	TMediaItems = Tlist<TMediaItem>;

    { TUrlItem }
	TUrlItem = class(TPersistent)
	private
		FIndices    : TIndices;
		FExtendedUrl: string;
		FDisplayUrl : string;
		FUrl        : string;
		procedure SetIndices(const Value: TIndices);
	public
		constructor Create;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;
	published
		property DisplayUrl : string read FDisplayUrl write FDisplayUrl;
		property ExtendedUrl: string read FExtendedUrl write FExtendedUrl;
		property Indices    : TIndices read FIndices write SetIndices;
		property Url        : string read FUrl write FUrl;
	end;

    { TUrlItems }
	TUrlItems = TList<TUrlItem>;

    { TUserMentionItem }
	TUserMentionItem = class(TPersistent)
	private
		FName      : string;
		FIndices   : TIndices;
		FScreenName: string;
		FIdStr     : string;
		FId        : int64;
		procedure SetIndices(const Value: TIndices);
	public
		constructor Create;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;
	published
		property Id        : int64 read FId write FId;
		property IdStr     : string read FIdStr write FIdStr;
		property Indices   : TIndices read FIndices write SetIndices;
		property name      : string read FName write FName;
		property ScreenName: string read FScreenName write FScreenName;
	end;

    { TUserMentionItems }
	TUserMentionItems = TList<TUserMentionItem>;

	{ TEntities }
	TEntities = class(TPersistent)
	private
		FHashTags    : THashTagItems;
		FMedia       : TMediaItems;
		FUrls        : TUrlItems;
		FUserMentions: TUserMentionItems;
		procedure SetHashTags(const Value: THashTagItems);
		procedure SetMedia(const Value: TMediaItems);
		procedure SetURLS(const Value: TUrlItems);
		procedure SetUserMentions(const Value: TUserMentionItems);
	public
		constructor Create;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;
	published
		property HashTags    : THashTagItems read FHashTags write SetHashTags;
		property Media       : TMediaItems read FMedia write SetMedia;
		property Urls        : TUrlItems read FUrls write SetURLS;
		property UserMentions: TUserMentionItems read FUserMentions write SetUserMentions;
	end;

    { ====== }
    { Places }
    { ====== }

    { TPlaceAttributes }
	TPlaceAttributes = TAVLTree<string, string>;

    { TPlace }
	TPlace = class(TPersistent)
	private
		FName       : string;
		FID         : string;
		FCountry    : string;
		FPlaceType  : string;
		FFullName   : string;
		FUrl        : string;
		FCountryCode: string;
		FAttributes : TPlaceAttributes;
	public
		constructor Create;
		destructor Destroy; override;
		procedure Assign(aSource: TPersistent); override;
	published
		property Attributes : TPlaceAttributes read FAttributes write FAttributes;
		property Country    : string read FCountry write FCountry;
		property CountryCode: string read FCountryCode write FCountryCode;
		property FullName   : string read FFullName write FFullName;
		property ID         : string read FID write FID;
		property name       : string read FName write FName;
		property PlaceType  : string read FPlaceType write FPlaceType;
		property Url        : string read FUrl write FUrl;
	end;

implementation

{ ============ }
{ Helper types }
{ ============ }

{ TIndices }

procedure TIndices.Assign(aSource: TPersistent);
begin
	if (aSource is TIndices) then
	begin
		Starts := TIndices(aSource).Starts;
		Ends   := TIndices(aSource).Ends;
	end;
end;

{ ====== }
{ Tweets }
{ ====== }

{ TContributor }

procedure TContributor.Assign(aSource: TPersistent);
begin
	if (aSource is TContributor) then
	begin
		Id         := TContributor(aSource).Id;
		IdStr      := TContributor(aSource).IdStr;
		ScreenName := TContributor(aSource).ScreenName;
	end;
end;

{ TCoordinate }

procedure TCoordinate.Assign(aSource: TPersistent);
begin
	if (aSource is TCoordinate) then
	begin
		Longitude := TCoordinate(aSource).Longitude;
		Lattitude := TCoordinate(aSource).Lattitude;
		Typ       := TCoordinate(aSource).Typ;
	end;
end;

{ TCurrentUserRetweet }

procedure TCurrentUserRetweet.Assign(aSource: TPersistent);
begin
	if (aSource is TCurrentUserRetweet) then
	begin
		Id    := TCurrentUserRetweet(aSource).Id;
		IdStr := TCurrentUserRetweet(aSource).IdStr;
	end;
end;

{ TTweet }

constructor TTweet.Create;
begin
	FContributors := TContributors.Create(

		function: TContributor
		begin
			Result := TContributor.Create;
		end,

		procedure(var aItem: TContributor)
		begin
			aItem.Free;
			aItem := nil;
		end,

		procedure(const aFromItem: TContributor; var aToItem: TContributor)
		begin
			aToItem.Assign(aFromItem);
		end,

		function(const aItemA, aItemB: TContributor): integer
		begin
			Result := 0;
		end

	  );

	FCoordinates        := TCoordinate.Create;
	FCurrentUserRetweet := TCurrentUserRetweet.Create;
	FEntities           := TEntities.Create;
	FUser               := TUser.Create;
end;

destructor TTweet.Destroy;
begin
	if (FUser <> nil) then
		FUser.Free;
	FEntities.Free;
	FCurrentUserRetweet.Free;
	FCoordinates.Free;
	FContributors.Free;
	inherited;
end;

procedure TTweet.Assign(aSource: TPersistent);
begin
	if (aSource is TTweet) then
	begin
		Contributors         := TTweet(aSource).Contributors;
		Coordinates          := TTweet(aSource).Coordinates;
		CreatedAt            := TTweet(aSource).CreatedAt;
		CurrentUserRetweet   := TTweet(aSource).CurrentUserRetweet;
		Entities             := TTweet(aSource).Entities;
		Favorited            := TTweet(aSource).Favorited;
		Id                   := TTweet(aSource).Id;
		IdStr                := TTweet(aSource).IdStr;
		InReplyToScreenName  := TTweet(aSource).InReplyToScreenName;
		InReplyToStatusId    := TTweet(aSource).InReplyToStatusId;
		InReplyToStatusIdStr := TTweet(aSource).InReplyToStatusIdStr;
		InReplyToUserId      := TTweet(aSource).InReplyToUserId;
		InReplyToUserIdStr   := TTweet(aSource).InReplyToUserIdStr;
		PossiblySensitive    := TTweet(aSource).PossiblySensitive;
		RetweetCount         := TTweet(aSource).RetweetCount;
		Retweeted            := TTweet(aSource).Retweeted;
		Source               := TTweet(aSource).Source;
		Text                 := TTweet(aSource).Text;
		Truncated            := TTweet(aSource).Truncated;
		User                 := TTweet(aSource).User;
		WithheldCopyright    := TTweet(aSource).WithheldCopyright;
		WithheldInCountries  := TTweet(aSource).WithheldInCountries;
		WithheldScope        := TTweet(aSource).WithheldScope;
	end;
end;

procedure TTweet.SetContributors(const Value: TContributors);
begin
	FContributors.Assign(Value);
end;

procedure TTweet.SetCoordinates(const Value: TCoordinate);
begin
	FCoordinates.Assign(Value);
end;

procedure TTweet.SetCurrentUserRetweet(const Value: TCurrentUserRetweet);
begin
	FCurrentUserRetweet.Assign(Value);
end;

procedure TTweet.SetEntities(const Value: TEntities);
begin
	FEntities.Assign(Value);
end;

procedure TTweet.SetUser(const Value: TUser);
begin
	if (FUser = nil) then
		FUser := TUser.Create;
	FUser.Assign(Value);
end;

{ TTweets }

constructor TTweets.Create;
begin
	FItems := TList<TTweet>.Create(

		function: TTweet
		begin
			Result := TTweet.Create;
		end,

		procedure(var aItem: TTweet)
		begin
			aItem.Free;
			aItem := nil;
		end,

		procedure(const aFromItem: TTweet; var aToItem: TTweet)
		begin
			aToItem.Assign(aFromItem);
		end,

		function(const aItemA, aItemB: TTweet): integer
		begin
			Result := 0;
		end

	  );
end;

destructor TTweets.Destroy;
begin
	FItems.Free;
	inherited;
end;

procedure TTweets.Assign(aSource: TPersistent);
begin
	if (aSource is TTweets) then
	begin
		Items := TTweets(aSource).Items;
	end;
end;

procedure TTweets.SetItems(const Value: TList<TTweet>);
begin
	FItems.Assign(Value);
end;

{ ===== }
{ Users }
{ ===== }

{ TUser }

constructor TUser.Create;
begin
	FEntities := TEntities.Create;
end;

destructor TUser.Destroy;
begin
	if (FStatus <> nil) then
		FStatus.Free;
	FEntities.Free;
	inherited;
end;

procedure TUser.Assign(aSource: TPersistent);
begin
	if (aSource is TUser) then
	begin
		ContributorsEnabled            := TUser(aSource).ContributorsEnabled;
		CreatedAt                      := TUser(aSource).CreatedAt;
		DefaultProfile                 := TUser(aSource).DefaultProfile;
		DefaultProfileImage            := TUser(aSource).DefaultProfileImage;
		Description                    := TUser(aSource).Description;
		Entities                       := TUser(aSource).Entities;
		FavouritesCount                := TUser(aSource).FavouritesCount;
		FollowRequestSent              := TUser(aSource).FollowRequestSent;
		Following                      := TUser(aSource).Following;
		FollowersCount                 := TUser(aSource).FollowersCount;
		FriendsCount                   := TUser(aSource).FriendsCount;
		GeoEnabled                     := TUser(aSource).GeoEnabled;
		Id                             := TUser(aSource).Id;
		IdStr                          := TUser(aSource).IdStr;
		IsTranslator                   := TUser(aSource).IsTranslator;
		Lang                           := TUser(aSource).Lang;
		ListedCount                    := TUser(aSource).ListedCount;
		Location                       := TUser(aSource).Location;
		name                           := TUser(aSource).name;
		ProfileBackgroundColor         := TUser(aSource).ProfileBackgroundColor;
		ProfileBackgroundImageUrl      := TUser(aSource).ProfileBackgroundImageUrl;
		ProfileBackgroundImageUrlHttps := TUser(aSource).ProfileBackgroundImageUrlHttps;
		ProfileBackgroundTile          := TUser(aSource).ProfileBackgroundTile;
		ProfileBannerUrl               := TUser(aSource).ProfileBannerUrl;
		ProfileImageUrl                := TUser(aSource).ProfileImageUrl;
		ProfileImageUrlHttps           := TUser(aSource).ProfileImageUrlHttps;
		ProfileLinkColor               := TUser(aSource).ProfileLinkColor;
		ProfileSidebarBorderColor      := TUser(aSource).ProfileSidebarBorderColor;
		ProfileSidebarFillColor        := TUser(aSource).ProfileSidebarFillColor;
		ProfileTextColor               := TUser(aSource).ProfileTextColor;
		ProfileUseBackgroundImage      := TUser(aSource).ProfileUseBackgroundImage;
		ProtectedAccount               := TUser(aSource).ProtectedAccount;
		ScreenName                     := TUser(aSource).ScreenName;
		ShowAllInlineMedia             := TUser(aSource).ShowAllInlineMedia;
		Status                         := TUser(aSource).Status;
		StatusesCount                  := TUser(aSource).StatusesCount;
		TimeZone                       := TUser(aSource).TimeZone;
		Url                            := TUser(aSource).Url;
		UtcOffset                      := TUser(aSource).UtcOffset;
		Verified                       := TUser(aSource).Verified;
		WithheldInCountries            := TUser(aSource).WithheldInCountries;
		WithheldScope                  := TUser(aSource).WithheldScope;
	end;
end;

procedure TUser.SetEntities(const Value: TEntities);
begin
	FEntities.Assign(Value);
end;

procedure TUser.SetStatus(const Value: TTweet);
begin
	if (FStatus = nil) then
		FStatus := TTweet.Create;
	FStatus.Assign(Value);
end;

{ ======== }
{ Entities }
{ ======== }

{ TMediaSize }

procedure TMediaSize.Assign(aSource: TPersistent);
begin
	if (aSource is TMediaSize) then
	begin
		W      := TMediaSize(aSource).W;
		H      := TMediaSize(aSource).H;
		Resize := TMediaSize(aSource).Resize;
	end;
end;

{ TMediaSizes }

constructor TMediaSizes.Create;
begin
	FThumb  := TMediaSize.Create;
	FSmall  := TMediaSize.Create;
	FMedium := TMediaSize.Create;
	FLarge  := TMediaSize.Create;
end;

destructor TMediaSizes.Destroy;
begin
	FLarge.Free;
	FMedium.Free;
	FSmall.Free;
	FThumb.Free;
	inherited;
end;

procedure TMediaSizes.Assign(aSource: TPersistent);
begin
	if (aSource is TMediaSizes) then
	begin
		Thumb  := TMediaSizes(aSource).Thumb;
		Small  := TMediaSizes(aSource).Small;
		Medium := TMediaSizes(aSource).Medium;
		Large  := TMediaSizes(aSource).Large;
	end;
end;

procedure TMediaSizes.SetLarge(const Value: TMediaSize);
begin
	FLarge.Assign(Value);
end;

procedure TMediaSizes.SetMedium(const Value: TMediaSize);
begin
	FMedium.Assign(Value);
end;

procedure TMediaSizes.SetSmall(const Value: TMediaSize);
begin
	FSmall.Assign(Value);
end;

procedure TMediaSizes.SetThumb(const Value: TMediaSize);
begin
	FThumb.Assign(Value);
end;

{ TURL }

constructor TUrlItem.Create;
begin
	FIndices := TIndices.Create;
end;

destructor TUrlItem.Destroy;
begin
	FIndices.Free;
	inherited;
end;

procedure TUrlItem.Assign(aSource: TPersistent);
begin
	if (aSource is TUrlItem) then
	begin
		DisplayUrl  := TUrlItem(aSource).DisplayUrl;
		ExtendedUrl := TUrlItem(aSource).ExtendedUrl;
		Indices     := TUrlItem(aSource).Indices;
		Url         := TUrlItem(aSource).Url;
	end;
end;

procedure TUrlItem.SetIndices(const Value: TIndices);
begin
	FIndices.Assign(Value);
end;

{ TUserMention }

constructor TUserMentionItem.Create;
begin
	FIndices := TIndices.Create;
end;

destructor TUserMentionItem.Destroy;
begin
	FIndices.Free;
	inherited;
end;

procedure TUserMentionItem.Assign(aSource: TPersistent);
begin
	if (aSource is TUserMentionItem) then
	begin
		Id         := TUserMentionItem(aSource).Id;
		IdStr      := TUserMentionItem(aSource).IdStr;
		Indices    := TUserMentionItem(aSource).Indices;
		name       := TUserMentionItem(aSource).Name;
		ScreenName := TUserMentionItem(aSource).ScreenName;
	end;
end;

procedure TUserMentionItem.SetIndices(const Value: TIndices);
begin
	FIndices.Assign(Value);
end;

{ THashTag }

constructor THashTagItem.Create;
begin
	FIndices := TIndices.Create;
end;

destructor THashTagItem.Destroy;
begin
	FIndices.Free;
	inherited;
end;

procedure THashTagItem.Assign(aSource: TPersistent);
begin
	if (aSource is THashTagItem) then
	begin
		Indices := THashTagItem(aSOurce).Indices;
		Text    := THashTagItem(aSource).Text;
	end;
end;

procedure THashTagItem.SetIndices(const Value: TIndices);
begin
	FIndices.Assign(Value);
end;

{ TMediaItem }

constructor TMediaItem.Create;
begin
	FIndices := TIndices.Create;
	FSizes   := TMediaSizes.Create;
end;

destructor TMediaItem.Destroy;
begin
	FSizes.Free;
	FIndices.Free;
	inherited;
end;

procedure TMediaItem.Assign(aSource: TPersistent);
begin
	if (aSource is TMediaItem) then
	begin
		DisplayUrl        := TMediaItem(aSource).DisplayUrl;
		ExpandedUrl       := TMediaItem(aSource).ExpandedUrl;
		Id                := TMediaItem(aSource).Id;
		IdStr             := TMediaItem(aSource).IdStr;
		Indices           := TMediaItem(aSource).Indices;
		MediaUrl          := TMediaItem(aSource).MediaUrl;
		MediaUrlHttps     := TMediaItem(aSource).MediaUrlHttps;
		Sizes             := TMediaItem(aSource).Sizes;
		SourceStatusId    := TMediaItem(aSource).SourceStatusId;
		SourceStatusIdStr := TMediaItem(aSource).SourceStatusIdStr;
		Typ               := TMediaItem(aSource).Typ;
		Url               := TMediaItem(aSource).Url;
	end;
end;

procedure TMediaItem.SetIndices(const Value: TIndices);
begin
	FIndices.Assign(Value);
end;

procedure TMediaItem.SetSizes(const Value: TMediaSizes);
begin
	FSizes.Assign(Value);
end;

{ TEntities }

constructor TEntities.Create;
begin
	FHashTags := THashTagItems.Create(

		function: THashTagItem
		begin
			Result := THashTagItem.Create;
		end,

		procedure(var aItem: THashTagItem)
		begin
			aItem.Free;
			aItem := nil;
		end,

		procedure(const aFromItem: THashTagItem; var aToItem: THashTagItem)
		begin
			aToItem.Assign(aFromItem);
		end,

		function(const aItemA, aItemB: THashTagItem): integer
		begin
			Result := 0;
		end

	  );

	FMedia := TMediaItems.Create(

		function: TMediaItem
		begin
			Result := TMediaItem.Create;
		end,

		procedure(var aItem: TMediaItem)
		begin
			aItem.Free;
			aItem := nil;
		end,

		procedure(const aFromItem: TMediaItem; var aToItem: TMediaItem)
		begin
			aToItem.Assign(aFromItem);
		end,

		function(const aItemA, aItemB: TMediaItem): integer
		begin
			Result := 0;
		end

	  );

	FUrls := TUrlItems.Create(

		function: TUrlItem
		begin
			Result := TUrlItem.Create;
		end,

		procedure(var aItem: TUrlItem)
		begin
			aItem.Free;
			aItem := nil;
		end,

		procedure(const aFromItem: TUrlItem; var aToItem: TUrlItem)
		begin
			aToItem.Assign(aFromItem);
		end,

		function(const aItemA, aItemB: TUrlItem): integer
		begin
			Result := 0;
		end

	  );

	FUserMentions := TUserMentionItems.Create(

		function: TUserMentionItem
		begin
			Result := TUserMentionItem.Create;
		end,

		procedure(var aItem: TUserMentionItem)
		begin
			aItem.Free;
			aItem := nil;
		end,

		procedure(const aFromItem: TUserMentionItem; var aToItem: TUserMentionItem)
		begin
			aToItem.Assign(aFromItem);
		end,

		function(const aItemA, aItemB: TUserMentionItem): integer
		begin
			Result := 0;
		end

	  );
end;

destructor TEntities.Destroy;
begin
	FUserMentions.Free;
	FUrls.Free;
	FMedia.Free;
	FHashTags.Free;
	inherited;
end;

procedure TEntities.Assign(aSource: TPersistent);
begin
	if (aSource is TEntities) then
	begin
		HashTags     := TEntities(aSource).HashTags;
		Media        := TEntities(aSource).Media;
		Urls         := TEntities(aSource).Urls;
		UserMentions := TEntities(aSource).UserMentions;
	end;
end;

procedure TEntities.SetHashTags(const Value: THashTagItems);
begin
	FHashTags.Assign(Value);
end;

procedure TEntities.SetMedia(const Value: TMediaItems);
begin
	FMedia.Assign(Value);
end;

procedure TEntities.SetURLS(const Value: TUrlItems);
begin
	FUrls.Assign(Value);
end;

procedure TEntities.SetUserMentions(const Value: TUserMentionItems);
begin
	FUserMentions.Assign(Value);
end;

{ TPlace }

constructor TPlace.Create;
begin
	FAttributes := TPlaceAttributes.Create(

		function(const aKeyA, aKeyB: string): integer
		begin
			if (aKeyA < aKeyB) then
				Result := - 1
			else if (aKeyA > aKeyB) then
				Result := 1
			else
				Result := 0;
		end,

		procedure(var aKey: string)
		begin
			aKey := '';
		end,

		procedure(var aVal: string)
		begin
			aVal := '';
		end

	  );
end;

destructor TPlace.Destroy;
begin
    FAttributes.Free;
	inherited;
end;

procedure TPlace.Assign(aSource: TPersistent);
begin
	if (aSource is TPlace) then
	begin

		Country     := TPlace(aSource).Country;
		CountryCode := TPlace(aSource).CountryCode;
		FullName    := TPlace(aSource).FullName;
		ID          := TPlace(aSource).ID;
		name        := TPlace(aSource).name;
		PlaceType   := TPlace(aSource).PlaceType;
		Url         := TPlace(aSource).Url;
	end;
end;

end.
