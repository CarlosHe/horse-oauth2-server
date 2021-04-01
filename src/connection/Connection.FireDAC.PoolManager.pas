unit Connection.FireDAC.PoolManager;

interface

uses
  PoolManager,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Phys.PGDef,
  FireDAC.Phys.PG,
  System.SysUtils;

type

  TQueryCallback = reference to procedure(AQuery: TFDQuery);
  TConnectionCallback = reference to procedure(AConnection: TFDConnection);

  TFDConnectionPoolManager = class(TPoolManager<TFDConnection>)
  private
    { private declarations }
    class var FDefaultFDConnectionPoolManager: TFDConnectionPoolManager;
  protected
    { protected declarations }
    class procedure CreateDefaultInstance;
    class function GetDefaultFDConnectionPoolManager: TFDConnectionPoolManager; static;
  public
    { public declarations }
    procedure DoGetInstance(var AInstance: TFDConnection; var AInstanceOwner: Boolean); override;
    procedure ExecSQL(const ASQL: string = '');
    procedure Query(AQueryCallback: TQueryCallback);
    procedure Connection(AConnectionCallback: TConnectionCallback);
    class constructor Initialize;
    class destructor UnInitialize;
    class property DefaultManager: TFDConnectionPoolManager read GetDefaultFDConnectionPoolManager;
  end;

implementation

uses
  Config.Database,
  System.SyncObjs;

{ TFDConnectionPoolManager }

procedure TFDConnectionPoolManager.Connection(AConnectionCallback: TConnectionCallback);
var
  LItem: TPoolItem<TFDConnection>;
  LConnection: TFDConnection;
begin
  LItem := TFDConnectionPoolManager.DefaultManager.TryGetItem;
  LConnection := LItem.Acquire;
  try
    AConnectionCallback(LConnection);
  finally
    LItem.Release;
  end;
end;

class procedure TFDConnectionPoolManager.CreateDefaultInstance;
begin
  FDefaultFDConnectionPoolManager := TFDConnectionPoolManager.Create(True);
  FDefaultFDConnectionPoolManager.SetMaxIdleSeconds(60);
  FDefaultFDConnectionPoolManager.Start;
end;

procedure TFDConnectionPoolManager.DoGetInstance(var AInstance: TFDConnection; var AInstanceOwner: Boolean);
begin
  inherited;
  AInstanceOwner := True;
  AInstance := TFDConnection.Create(nil);
  try
    AInstance.DriverName := TDatabaseConfig.Driver;
    AInstance.Params.Add('CharacterSet=utf8');
    AInstance.Params.AddPair('Server', TDatabaseConfig.Host);
    AInstance.Params.AddPair('Port', TDatabaseConfig.Port.ToString);
    AInstance.Params.AddPair('GUIDEndian', 'Big');
    AInstance.FetchOptions.CursorKind := TFDCursorKind.ckDefault;
    AInstance.Params.Database := TDatabaseConfig.Database;
    AInstance.Params.UserName := TDatabaseConfig.User;
    AInstance.Params.Password := TDatabaseConfig.Password;
    AInstance.Connected := True;
  except
    FreeAndNil(AInstance);
    raise;
  end;
end;

procedure TFDConnectionPoolManager.ExecSQL(const ASQL: string);
var
  LItem: TPoolItem<TFDConnection>;
  LConnection: TFDConnection;
  LQuery: TFDQuery;
begin
  LItem := TFDConnectionPoolManager.DefaultManager.TryGetItem;
  LConnection := LItem.Acquire;
  try
    LQuery := TFDQuery.Create(nil);
    try
      LQuery.Connection := LConnection;
      LQuery.ExecSQL(ASQL);
    finally
      LQuery.Free;
    end;
  finally
    LItem.Release;
  end;
end;

class function TFDConnectionPoolManager.GetDefaultFDConnectionPoolManager: TFDConnectionPoolManager;
begin
  if (FDefaultFDConnectionPoolManager = nil) then
  begin
    CreateDefaultInstance;
  end;
  Result := FDefaultFDConnectionPoolManager;
end;

class constructor TFDConnectionPoolManager.Initialize;
begin
  CreateDefaultInstance;
end;

procedure TFDConnectionPoolManager.Query(AQueryCallback: TQueryCallback);
var
  LItem: TPoolItem<TFDConnection>;
  LConnection: TFDConnection;
  LQuery: TFDQuery;
begin
  LItem := TFDConnectionPoolManager.DefaultManager.TryGetItem;
  LConnection := LItem.Acquire;
  try
    LQuery := TFDQuery.Create(nil);
    try
      LQuery.Connection := LConnection;
      AQueryCallback(LQuery);
    finally
      LQuery.Free;
    end;
  finally
    LItem.Release;
  end;
end;

class destructor TFDConnectionPoolManager.UnInitialize;
begin
  if FDefaultFDConnectionPoolManager <> nil then
  begin
    FDefaultFDConnectionPoolManager.Free;
  end;
end;

end.
