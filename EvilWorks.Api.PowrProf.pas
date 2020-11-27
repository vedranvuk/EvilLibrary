unit EvilWorks.Api.PowrProf;

interface

uses
	WinApi.Windows;

type

{$EXTERNALSYM POWER_DATA_ACCESSOR}
	POWER_DATA_ACCESSOR = (
	  // Used by read/write and enumeration engines
	  ACCESS_AC_POWER_SETTING_INDEX = 0,
	  ACCESS_DC_POWER_SETTING_INDEX,
	  ACCESS_FRIENDLY_NAME,
	  ACCESS_DESCRIPTION,
	  ACCESS_POSSIBLE_POWER_SETTING,
	  ACCESS_POSSIBLE_POWER_SETTING_FRIENDLY_NAME,
	  ACCESS_POSSIBLE_POWER_SETTING_DESCRIPTION,
	  ACCESS_DEFAULT_AC_POWER_SETTING,
	  ACCESS_DEFAULT_DC_POWER_SETTING,
	  ACCESS_POSSIBLE_VALUE_MIN,
	  ACCESS_POSSIBLE_VALUE_MAX,
	  ACCESS_POSSIBLE_VALUE_INCREMENT,
	  ACCESS_POSSIBLE_VALUE_UNITS,
	  ACCESS_ICON_RESOURCE,
	  ACCESS_DEFAULT_SECURITY_DESCRIPTOR,
	  ACCESS_ATTRIBUTES,

	  // Used by enumeration engine.
	  ACCESS_SCHEME,
	  ACCESS_SUBGROUP,
	  ACCESS_INDIVIDUAL_SETTING,

	  // Used by access check
	  ACCESS_ACTIVE_SCHEME,
	  ACCESS_CREATE_SCHEME,

	  // Used by override ranges.
	  ACCESS_AC_POWER_SETTING_MAX,
	  ACCESS_DC_POWER_SETTING_MAX,
	  ACCESS_AC_POWER_SETTING_MIN,
	  ACCESS_DC_POWER_SETTING_MIN

	  );
	PPOWER_DATA_ACCESSOR = ^POWER_DATA_ACCESSOR;

const
	powrproflib = 'powrprof.dll';

{$EXTERNALSYM PowerEnumerate}
function PowerEnumerate(RootPowerKey: HKEY;
  SchemeGuid: PGUID;
  SubGroupOfPowerSettingsGuid: PGUID;
  AccessFlags: POWER_DATA_ACCESSOR;
  Index: ULONG;
  Buffer: PUCHAR;
  var BufferSize: DWORD
  ): DWORD; stdcall; external powrproflib name 'PowerEnumerate';

{$EXTERNALSYM PowerReadFriendlyName}
function PowerReadFriendlyName(RootPowerKey: HKEY;
  SchemeGuid: PGUID;
  SubGroupOfPowerSettingsGuid: PGUID;
  PowerSettingGuid: PGUID;
  Buffer: PUCHAR;
  var BufferSize: DWORD
  ): DWORD; stdcall; external powrproflib name 'PowerReadFriendlyName';

implementation

end.
