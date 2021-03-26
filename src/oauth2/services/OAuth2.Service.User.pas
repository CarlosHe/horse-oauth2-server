unit OAuth2.Service.User;

interface

uses

  Data.DB;

type

  TOAuth2UserService = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class function FindAndValidateForPassport(AUsername: string; APassword: string): TDataSet;
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

{ TOAuth2UserService }

class function TOAuth2UserService.FindAndValidateForPassport(AUsername, APassword: string): TDataSet;
var
  FDQueryClients: TFDQuery;
begin
  Result := nil;
  FDQueryClients := TFDQuery.Create(nil);

  TFDConnectionPoolManager.DefaultManager.Connection(
    procedure(AConnection: TFDConnection)
    begin
      FDQueryClients.Connection := AConnection;
      FDQueryClients.SQL.Text := 'SELECT * FROM users WHERE deleted_at IS NULL AND username = :pusername;';
      FDQueryClients.ParamByName('pusername').AsString := AUsername;
      FDQueryClients.OpenUp;
    end);

  if (not FDQueryClients.IsEmpty) and (TBCrypt.CompareHash(APassword, FDQueryClients.FieldByName('password').AsString)) then
    Result := FDQueryClients
  else
    FDQueryClients.Free;
end;

end.
