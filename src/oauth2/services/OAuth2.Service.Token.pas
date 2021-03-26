unit OAuth2.Service.Token;

interface

uses

  Data.DB,
  OAuth2.Entity.AccessToken.Contract;

type

  TOAuth2TokenService = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class procedure Store(AAccessToken: IOAuth2AccessTokenEntity);
    class function IsAccessTokenRevoked(ATokenId: string): Boolean;
    class procedure SoftDelete(ATokenId: string);
    class procedure RevokeAccessToken(ATokenId: string);
    class function FindAndValidateForPassport(AUsername: string; APassword: string): TDataSet;
    class function FindValidToken(AUserId: string; AClientId: string): TDataSet;
    class function ForUser(AUserId: string): TDataSet;
    class function FindForUser(ATokenId: string; AUserId: string): TDataSet;
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
  System.SysUtils;

{ TOAuth2TokenService }

class function TOAuth2TokenService.FindAndValidateForPassport(AUsername, APassword: string): TDataSet;
var
  FDQueryClients: TFDQuery;
begin
  Result := nil;
  FDQueryClients := TFDQuery.Create(nil);

  TFDConnectionPoolManager.DefaultManager.Connection(
    procedure(AConnection: TFDConnection)
    begin
      FDQueryClients.Connection := AConnection;
      FDQueryClients.SQL.Text :=
        'SELECT * FROM users WHERE deleted_at IS NULL AND username = :pusername;';
      FDQueryClients.ParamByName('pusername').AsString := AUsername;
      FDQueryClients.OpenUp;
    end);

  if (not FDQueryClients.IsEmpty) and
    (TBCrypt.CompareHash(APassword, FDQueryClients.FieldByName('password')
    .AsString)) then
  begin
    Result := FDQueryClients;
  end;
end;

class function TOAuth2TokenService.FindForUser(ATokenId, AUserId: string): TDataSet;
var
  FDQueryToken: TFDQuery;
begin
  Result := nil;
  FDQueryToken := TFDQuery.Create(nil);
  TFDConnectionPoolManager.DefaultManager.Connection(
    procedure(AConnection: TFDConnection)
    begin
      FDQueryToken.Connection := AConnection;
      FDQueryToken.SQL.Text :=
        'SELECT *' +
        ' FROM oauth_access_tokens' +
        ' WHERE deleted_at IS NULL AND (revoked IS NULL OR revoked = :prevoked) AND id = :pid AND user_id = :puser_id;';
      FDQueryToken.ParamByName('prevoked').AsBoolean := False;
      FDQueryToken.ParamByName('pid').AsString := ATokenId;
      FDQueryToken.ParamByName('puser_id').AsGUID := StringToGUID(Format('{%s}', [AUserId.Trim(['{', '}'])]));
      FDQueryToken.OpenUp;
    end);
  if (not FDQueryToken.IsEmpty) then
    Result := FDQueryToken
  else
    FDQueryToken.Free;
end;

class function TOAuth2TokenService.FindValidToken(AUserId, AClientId: string): TDataSet;
var
  FDQueryToken: TFDQuery;
begin
  Result := nil;
  FDQueryToken := TFDQuery.Create(nil);
  TFDConnectionPoolManager.DefaultManager.Connection(
    procedure(AConnection: TFDConnection)
    begin
      FDQueryToken.Connection := AConnection;
      FDQueryToken.SQL.Text :=
        ' SELECT' +
        '   oauth_access_tokens.*' +
        ' FROM' +
        '   oauth_clients' +
        '   INNER JOIN oauth_access_tokens ON oauth_access_tokens.client_id = oauth_clients.id'
        +
        ' WHERE' +
        '   (oauth_access_tokens.revoked IS NULL OR oauth_access_tokens.revoked = :prevoked) AND'+
        '   oauth_access_tokens.user_id = :puser_id AND' +
        '   oauth_access_tokens.client_id = :pclient_id AND' +
        '   oauth_access_tokens.expires_at > now() AND' +
        '   oauth_clients.revoked = oauth_access_tokens.revoked AND' +
        '   oauth_access_tokens.deleted_at IS NULL AND' +
        '   oauth_clients.deleted_at IS NULL;';
      FDQueryToken.ParamByName('prevoked').AsBoolean := False;
      FDQueryToken.ParamByName('puser_id').AsGUID :=
        StringToGUID(Format('{%s}', [AUserId.Trim(['{', '}'])]));
      FDQueryToken.ParamByName('pclient_id').AsGUID :=
        StringToGUID(Format('{%s}', [AClientId.Trim(['{', '}'])]));
      FDQueryToken.OpenUp;
    end);

  if (not FDQueryToken.IsEmpty) then
    Result := FDQueryToken
  else
    FDQueryToken.Free;
end;

class function TOAuth2TokenService.ForUser(AUserId: string): TDataSet;
var
  FDQueryToken: TFDQuery;
begin
  Result := nil;
  FDQueryToken := TFDQuery.Create(nil);
  TFDConnectionPoolManager.DefaultManager.Connection(
    procedure(AConnection: TFDConnection)
    begin
      FDQueryToken.Connection := AConnection;
      FDQueryToken.SQL.Text :=
        'SELECT id, client_id, scopes, revoked, expires_at, created_at, updated_at'+
        ' FROM oauth_access_tokens'+
        ' WHERE deleted_at IS NULL AND (revoked IS NULL OR revoked = :prevoked) AND user_id = :puser_id;';
      FDQueryToken.ParamByName('prevoked').AsBoolean := False;
      FDQueryToken.ParamByName('puser_id').AsGUID := StringToGUID(Format('{%s}', [AUserId.Trim(['{', '}'])]));
      FDQueryToken.OpenUp;
    end);
  if (not FDQueryToken.IsEmpty) then
    Result := FDQueryToken
  else
    FDQueryToken.Free;
end;

class function TOAuth2TokenService.IsAccessTokenRevoked(ATokenId: string): Boolean;
var
  FDQueryClients: TFDQuery;
begin
  FDQueryClients := TFDQuery.Create(nil);
  try
    TFDConnectionPoolManager.DefaultManager.Connection(
      procedure(AConnection: TFDConnection)
      begin
        FDQueryClients.Connection := AConnection;
        FDQueryClients.SQL.Text :=
          'SELECT *'+
          ' FROM oauth_access_tokens'+
          ' WHERE deleted_at IS NULL AND (revoked IS NULL OR revoked = :prevoked) AND id = :pid;';
        FDQueryClients.ParamByName('pid').AsString := ATokenId;
        FDQueryClients.ParamByName('prevoked').AsBoolean := True;
        FDQueryClients.OpenUp;

      end);
    Result := not FDQueryClients.IsEmpty;
  finally
    FDQueryClients.Free;
  end;
end;

class procedure TOAuth2TokenService.RevokeAccessToken(ATokenId: string);
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
          'UPDATE oauth_access_tokens SET revoked = :prevoked WHERE id = :pid;';
        FDQueryClients.ParamByName('pid').AsString := ATokenId;
        FDQueryClients.ParamByName('prevoked').AsBoolean := True;
        FDQueryClients.ExecSQL;
      finally
        FDQueryClients.Free;
      end;
    end);
end;

class procedure TOAuth2TokenService.SoftDelete(ATokenId: string);
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
          'UPDATE oauth_access_tokens SET deleted_at = now() WHERE id = :pid;';
        FDQueryClients.ParamByName('pid').AsString := ATokenId;
        FDQueryClients.ExecSQL;
      finally
        FDQueryClients.Free;
      end;
    end);
end;

class procedure TOAuth2TokenService.Store(AAccessToken: IOAuth2AccessTokenEntity);
var
  LScopes: TArray<string>;
  I: Integer;
begin

  LScopes := [];
  for I := Low(AAccessToken.GetScopes) to High(AAccessToken.GetScopes) do
    LScopes := LScopes + [AAccessToken.GetScopes[I].GetIdentifier];

  TFDConnectionPoolManager.DefaultManager.Connection(
    procedure(AConnection: TFDConnection)
    var
      FDQueryClients: TFDQuery;
    begin
      FDQueryClients := TFDQuery.Create(nil);
      try
        FDQueryClients.Connection := AConnection;
        FDQueryClients.SQL.Text :=
          'INSERT INTO oauth_access_tokens (id, user_id, client_id, scopes, revoked, expires_at)' +
          ' VALUES (:pid, :puser_id, :pclient_id, :pscopes, :prevoked, :pexpires_at) ON CONFLICT DO NOTHING;';
        FDQueryClients.ParamByName('pid').AsString :=
          AAccessToken.GetIdentifier;
        if not AAccessToken.GetUserIdentifier.IsEmpty then
          FDQueryClients.ParamByName('puser_id').AsGUID :=
            StringToGUID(Format('{%s}',
            [AAccessToken.GetUserIdentifier.Trim(['{', '}'])]))
        else
        begin
          FDQueryClients.ParamByName('puser_id').DataType := ftGuid;
          FDQueryClients.ParamByName('puser_id').Clear;
        end;
        FDQueryClients.ParamByName('pclient_id').AsGUID :=
          StringToGUID(Format('{%s}',
          [AAccessToken.GetClient.GetIdentifier.Trim(['{', '}'])]));
        FDQueryClients.ParamByName('pscopes').AsString :=
          string.Join(' ', LScopes);
        FDQueryClients.ParamByName('prevoked').AsBoolean := False;
        FDQueryClients.ParamByName('pexpires_at').AsDateTime :=
          AAccessToken.GetExpiryDateTime;
        FDQueryClients.ExecSQL;
      finally
        FDQueryClients.Free;
      end;
    end);
end;

end.
