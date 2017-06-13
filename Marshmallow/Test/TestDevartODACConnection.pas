unit TestDevartODACConnection;

interface

uses
  DB,
  Ora;

type
  // See TestSQLConnection for more info
  {$RTTI EXPLICIT
    METHODS([vcPrivate..vcPublished])
    PROPERTIES(DefaultPropertyRttiVisibility)
    FIELDS(DefaultFieldRttiVisibility)}
  TTestODACConnection = class(TOraSession)
    procedure RegisterClient(Client: TObject; Event: DB.TConnectChangeEvent = nil);  {$IFNDEF FPC}override;{$ENDIF} abstract;
    function GetConnected: Boolean; override; abstract;
    procedure SetConnected(Value: Boolean); override; abstract;
    procedure UnRegisterClient(Client: TObject); override; abstract;
  end;

implementation

end.
