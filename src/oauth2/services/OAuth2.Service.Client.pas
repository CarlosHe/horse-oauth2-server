unit OAuth2.Service.Client;

interface

uses

  System.JSON,
  Data.DB;

type

  TOAuth2ClientService = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class procedure Store(AUserId: string; AData: TJSONObject);
    class procedure Update(AUserId: string; AData: TJSONObject);
    class procedure SoftDelete(AClientId: string);
    class function Find(AId: string): TDataSet;
    class function FindActive(AId: string): TDataSet;
    class function FindForUser(AClientId: string; AUserId: string): TDataSet;
    class function ActiveForUser(AUserId: string): TDataSet;
    class function VerifySecret(AClientSecret, AStoredHash: string): Boolean;
    class function SkipsAuthorization: Boolean;
  end;

implementation

uses
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Stan.Async,
  FireDAC.DApt,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  Ragna,
  BCrypt,
  FireDAC.Connection.PoolManager,
  System.Hash,
  System.SysUtils;

{ TOAuth2ClientService }

class function TOAuth2ClientService.ActiveForUser(AUserId: string): TDataSet;
var
  LFDQueryClients: TFDQuery;
begin
  LFDQueryClients := TFDQuery.Create(nil);
  try
    TFDConnectionPoolManager.DefaultManager.Connection(
      procedure(AConnection: TFDConnection)
      begin
        try
          LFDQueryClients.Connection := AConnection;
          LFDQueryClients.SQL.Text :=
            'SELECT id, name, provider, redirect, password_client, created_at, updated_at' +
            ' FROM oauth_clients' +
            ' WHERE deleted_at IS NULL AND user_id = :puser_id AND (revoked IS NULL OR revoked = :prevoked)' +
            ' ORDER BY name ASC;';
          LFDQueryClients.ParamByName('puser_id').AsGUID :=
            StringToGUID(Format('{%s}', [AUserId.Trim(['{', '}'])]));
          LFDQueryClients.ParamByName('prevoked').AsBoolean := False;
          LFDQueryClients.OpenUp;
        except
          FreeAndNil(LFDQueryClients);
        end;
      end);
  finally
    Result := LFDQueryClients;
  end;
end;

class function TOAuth2ClientService.FindForUser(AClientId, AUserId: string): TDataSet;
var
  LFDQueryClients: TFDQuery;
begin
  LFDQueryClients := TFDQuery.Create(nil);
  try
    TFDConnectionPoolManager.DefaultManager.Connection(
      procedure(AConnection: TFDConnection)
      begin
        try
          LFDQueryClients.Connection := AConnection;
          LFDQueryClients.SQL.Text :=
            'SELECT id, name, provider, redirect, password_client, created_at, updated_at' +
            ' FROM oauth_clients' +
            ' WHERE deleted_at IS NULL AND id = :pid AND user_id = :puser_id AND (revoked IS NULL OR revoked = :prevoked)' +
            ' ORDER BY name ASC;';
          LFDQueryClients.ParamByName('pid').AsGUID := StringToGUID(Format('{%s}', [AClientId.Trim(['{', '}'])]));
          LFDQueryClients.ParamByName('puser_id').AsGUID := StringToGUID(Format('{%s}', [AUserId.Trim(['{', '}'])]));
          LFDQueryClients.ParamByName('prevoked').AsBoolean := False;
          LFDQueryClients.OpenUp;
        except
          FreeAndNil(LFDQueryClients);
        end;
      end);
  finally
    Result := LFDQueryClients;
  end;
end;

class function TOAuth2ClientService.Find(AId: string): TDataSet;
var
  LFDQueryClients: TFDQuery;
begin
  LFDQueryClients := TFDQuery.Create(nil);
  try
    TFDConnectionPoolManager.DefaultManager.Connection(
      procedure(AConnection: TFDConnection)
      begin
        try
          LFDQueryClients.Connection := AConnection;
          LFDQueryClients.SQL.Text :=
            'SELECT *' +
            ' FROM oauth_clients' +
            ' WHERE deleted_at IS NULL AND id = :pid;';
          LFDQueryClients.ParamByName('pid').AsGUID := StringToGUID(Format('{%s}', [AId.Trim(['{', '}'])]));
          LFDQueryClients.OpenUp;
        except
          FreeAndNil(LFDQueryClients);
        end;
      end);
  finally
    Result := LFDQueryClients;
  end;
end;

class function TOAuth2ClientService.FindActive(AId: string): TDataSet;
var
  FDQueryClients: TFDQuery;
begin
  Result := nil;
  FDQueryClients := Find(AId) as TFDQuery;
  if (FDQueryClients <> nil) and (not FDQueryClients.IsEmpty) and (not FDQueryClients.FieldByName('revoked').AsBoolean) then
    Result := FDQueryClients
  else
    FDQueryClients.Free;
end;

class function TOAuth2ClientService.SkipsAuthorization: Boolean;
begin
  Result := False;
end;

class procedure TOAuth2ClientService.SoftDelete(AClientId: string);
begin
  TFDConnectionPoolManager.DefaultManager.Connection(
    procedure(AConnection: TFDConnection)
    var
      FDQueryClients: TFDQuery;
    begin
      FDQueryClients := TFDQuery.Create(nil);
      try
        FDQueryClients.Connection := AConnection;
        FDQueryClients.SQL.Text :=
          'UPDATE oauth_clients SET deleted_at = now() WHERE id = :pid;';
        FDQueryClients.ParamByName('pid').AsString := AClientId;
        FDQueryClients.ExecSQL;
      finally
        FDQueryClients.Free;
      end;
    end);
end;

class procedure TOAuth2ClientService.Store(AUserId: string; AData: TJSONObject);
begin
  TFDConnectionPoolManager.DefaultManager.Connection(
    procedure(AConnection: TFDConnection)
    var
      FDQueryClients: TFDQuery;
      LPlainSecret: string;
    begin
      FDQueryClients := TFDQuery.Create(nil);
      try
        LPlainSecret := THash.GetRandomString(40);
        FDQueryClients.Connection := AConnection;
        FDQueryClients.SQL.Text := 'INSERT INTO oauth_clients (user_id, name, secret, redirect, provider, password_client)' +
          ' VALUES (:puser_id, :pname, :psecret, :predirect, :pprovider, :ppassword_client) RETURNING id;';
        FDQueryClients.ParamByName('puser_id').AsGUID := StringToGUID(Format('{%s}', [AUserId.Trim(['{', '}'])]));
        FDQueryClients.ParamByName('pname').AsString := AData.GetValue<string>('name');
        FDQueryClients.ParamByName('psecret').AsString := TBCrypt.GenerateHash(LPlainSecret, 10) ;
        FDQueryClients.ParamByName('predirect').AsString := AData.GetValue<string>('redirect');
        FDQueryClients.ParamByName('pprovider').AsString := AData.GetValue<string>('provider');
        FDQueryClients.ParamByName('ppassword_client').AsBoolean := AData.GetValue<Boolean>('password_client');
        FDQueryClients.OpenUp;
        AData.AddPair('id', FDQueryClients.FieldByName('id').AsString);
        AData.AddPair('plain_secret', LPlainSecret);
      finally
        FDQueryClients.Free;
      end;
    end);
end;

class procedure TOAuth2ClientService.Update(AUserId: string; AData: TJSONObject);
begin
  TFDConnectionPoolManager.DefaultManager.Connection(
    procedure(AConnection: TFDConnection)
    var
      FDQueryClients: TFDQuery;
    begin
      FDQueryClients := TFDQuery.Create(nil);
      try
        FDQueryClients.Connection := AConnection;
        FDQueryClients.SQL.Text := 'UPDATE oauth_clients SET name = :pname, redirect = :predirect WHERE id = :pid;';
        FDQueryClients.ParamByName('pid').AsGUID := StringToGUID(Format('{%s}', [AData.GetValue<string>('id').Trim(['{', '}'])]));
        FDQueryClients.ParamByName('pname').AsString := AData.GetValue<string>('name');
        FDQueryClients.ParamByName('predirect').AsString := AData.GetValue<string>('redirect');
        FDQueryClients.ExecSQL;
      finally
        FDQueryClients.Free;
      end;
    end);
end;

class function TOAuth2ClientService.VerifySecret(AClientSecret, AStoredHash: string): Boolean;
begin
  Result := TBCrypt.CompareHash(AClientSecret, AStoredHash);
end;

end.
