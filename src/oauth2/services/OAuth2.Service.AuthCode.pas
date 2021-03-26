unit OAuth2.Service.AuthCode;

interface

uses

  Data.DB,
  OAuth2.Entity.AuthCode.Contract;

type

  TOAuth2AuthCodeService = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class procedure Store(AAuthCode: IOAuth2AuthCodeEntity);
    class function IsAuthCodeRevoked(ACodeId: string): Boolean;
    class procedure RevokeAuthCode(ACodeId: string);
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
  FireDAC.Connection.PoolManager,
  System.SysUtils;

{ TOAuth2AuthCodeService }

class function TOAuth2AuthCodeService.IsAuthCodeRevoked(ACodeId: string): Boolean;
var
  FDQueryClients: TFDQuery;
begin
  FDQueryClients := TFDQuery.Create(nil);
  try
    TFDConnectionPoolManager.DefaultManager.Connection(
      procedure(AConnection: TFDConnection)
      begin
        FDQueryClients.Connection := AConnection;
        FDQueryClients.SQL.Text := 'SELECT * FROM oauth_auth_codes WHERE deleted_at IS NULL AND (revoked IS NULL OR revoked = :prevoked) AND id = :pid;';
        FDQueryClients.ParamByName('pid').AsString := ACodeId;
        FDQueryClients.ParamByName('prevoked').AsBoolean := True;
        FDQueryClients.OpenUp;

      end);
    Result := not FDQueryClients.IsEmpty;
  finally
    FDQueryClients.Free;
  end;
end;

class procedure TOAuth2AuthCodeService.RevokeAuthCode(ACodeId: string);
begin
  TFDConnectionPoolManager.DefaultManager.Connection(
    procedure(AConnection: TFDConnection)
    var
      FDQueryClients: TFDQuery;
    begin
      FDQueryClients := TFDQuery.Create(nil);
      try
        FDQueryClients.Connection := AConnection;
        FDQueryClients.SQL.Text := 'UPDATE oauth_auth_codes SET revoked = :prevoked WHERE id = :pid;';
        FDQueryClients.ParamByName('pid').AsString := ACodeId;
        FDQueryClients.ParamByName('prevoked').AsBoolean := True;
        FDQueryClients.ExecSQL;
      finally
        FDQueryClients.Free;
      end;
    end);
end;

class procedure TOAuth2AuthCodeService.Store(AAuthCode: IOAuth2AuthCodeEntity);
var
  LScopes: TArray<string>;
  I: Integer;
begin

  LScopes := [];
  for I := Low(AAuthCode.GetScopes) to High(AAuthCode.GetScopes) do
    LScopes := LScopes + [AAuthCode.GetScopes[I].GetIdentifier];

  TFDConnectionPoolManager.DefaultManager.Connection(
    procedure(AConnection: TFDConnection)
    var
      FDQueryClients: TFDQuery;
    begin
      FDQueryClients := TFDQuery.Create(nil);
      try
        FDQueryClients.Connection := AConnection;
        FDQueryClients.SQL.Text := 'INSERT INTO oauth_auth_codes (id, user_id, client_id, scopes, revoked, expires_at)' +
          ' VALUES (:pid, :puser_id, :pclient_id, :pscopes, :prevoked, :pexpires_at) ON CONFLICT DO NOTHING;';
        FDQueryClients.ParamByName('pid').AsString := AAuthCode.GetIdentifier;
        FDQueryClients.ParamByName('puser_id').AsGUID := StringToGUID(Format('{%s}', [AAuthCode.GetUserIdentifier.Trim(['{', '}'])]));
        FDQueryClients.ParamByName('pclient_id').AsGUID := StringToGUID(Format('{%s}', [AAuthCode.GetClient.GetIdentifier.Trim(['{', '}'])]));
        FDQueryClients.ParamByName('pscopes').AsString := string.Join(' ', LScopes);
        FDQueryClients.ParamByName('prevoked').AsBoolean := False;
        FDQueryClients.ParamByName('pexpires_at').AsDateTime := AAuthCode.GetExpiryDateTime;
        FDQueryClients.ExecSQL;
      finally
        FDQueryClients.Free;
      end;
    end);
end;

end.
