unit OAuth2.Service.RefreshToken;

interface

uses

  Data.DB,
  OAuth2.Entity.RefreshToken.Contract;

type

  TOAuth2RefreshTokenService = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class procedure Store(ARefreshToken: IOAuth2RefreshTokenEntity);
    class function IsRefreshTokenRevoked(ATokenId: string): Boolean;
    class procedure RevokeRefreshToken(ATokenId: string);
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
  Connection.FireDAC.PoolManager,
  System.SysUtils;

{ TOAuth2RefreshTokenService }

class function TOAuth2RefreshTokenService.IsRefreshTokenRevoked(ATokenId: string): Boolean;
var
  FDQueryClients: TFDQuery;
begin
  FDQueryClients := TFDQuery.Create(nil);
  try
    TFDConnectionPoolManager.DefaultManager.Connection(
      procedure(AConnection: TFDConnection)
      begin
        FDQueryClients.Connection := AConnection;
        FDQueryClients.SQL.Text := 'SELECT * FROM oauth_refresh_tokens WHERE deleted_at IS NULL AND revoked = :prevoked AND id = :pid;';
        FDQueryClients.ParamByName('pid').AsString := ATokenId;
        FDQueryClients.ParamByName('prevoked').AsBoolean := True;
        FDQueryClients.OpenUp;

      end);
    Result := not FDQueryClients.IsEmpty;
  finally
    FDQueryClients.Free;
  end;
end;

class procedure TOAuth2RefreshTokenService.RevokeRefreshToken(ATokenId: string);
begin
  TFDConnectionPoolManager.DefaultManager.Connection(
    procedure(AConnection: TFDConnection)
    var
      FDQueryClients: TFDQuery;
    begin
      FDQueryClients := TFDQuery.Create(nil);
      try
        FDQueryClients.Connection := AConnection;
        FDQueryClients.SQL.Text := 'UPDATE oauth_refresh_tokens SET revoked = :prevoked WHERE id = :pid;';
        FDQueryClients.ParamByName('pid').AsString := ATokenId;
        FDQueryClients.ParamByName('prevoked').AsBoolean := True;
        FDQueryClients.ExecSQL;
      finally
        FDQueryClients.Free;
      end;
    end);
end;

class procedure TOAuth2RefreshTokenService.Store(ARefreshToken: IOAuth2RefreshTokenEntity);
begin
  TFDConnectionPoolManager.DefaultManager.Connection(
    procedure(AConnection: TFDConnection)
    var
      FDQueryClients: TFDQuery;
    begin
      FDQueryClients := TFDQuery.Create(nil);
      try
        FDQueryClients.Connection := AConnection;
        FDQueryClients.SQL.Text := 'INSERT INTO oauth_refresh_tokens (id, access_token_id, revoked, expires_at)' +
          ' VALUES (:pid, :paccess_token_id, :prevoked, :pexpires_at) ON CONFLICT DO NOTHING;';
        FDQueryClients.ParamByName('pid').AsString := ARefreshToken.GetIdentifier;
        FDQueryClients.ParamByName('paccess_token_id').AsString := ARefreshToken.GetAccessToken.GetIdentifier;
        FDQueryClients.ParamByName('prevoked').AsBoolean := False;
        FDQueryClients.ParamByName('pexpires_at').AsDateTime := ARefreshToken.GetExpiryDateTime;
        FDQueryClients.ExecSQL;
      finally
        FDQueryClients.Free;
      end;
    end);
end;

end.
