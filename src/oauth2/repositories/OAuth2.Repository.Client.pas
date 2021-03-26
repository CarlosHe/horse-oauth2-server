unit OAuth2.Repository.Client;

interface

uses
  OAuth2.Repository.Client.Contract,
  OAuth2.Entity.Client.Contract,
  Data.DB;

type

  TOAuth2ClientRepository = class(TInterfacedObject, IOAuth2ClientRepository)
  private
    { private declarations }
  protected
    { protected declarations }
    function HandlesGrant(ARecord: TDataSet; AGrantType: string): Boolean;
    function VerifySecret(AClientSecret: string; AStoredHash: string): Boolean;
  public
    { public declarations }
    function GetClientEntity(AClientIdentifier: string): IOAuth2ClientEntity;
    function ValidateClient(AClientIdentifier: string; AClientSecret: string; AGrantType: string): Boolean;
    class function New: IOAuth2ClientRepository;
  end;

implementation

uses
  OAuth2.Entity.Client,
  OAuth2.Service.Client,
  System.StrUtils,
  System.SysUtils;

{ TOAuth2ClientRepository }

function TOAuth2ClientRepository.GetClientEntity(AClientIdentifier: string): IOAuth2ClientEntity;
var
  LRecord: TDataSet;
begin
  Result := nil;
  LRecord := TOAuth2ClientService.FindActive(AClientIdentifier);
  try
    if (LRecord <> nil) then
    begin
      Result := TOAuth2ClientEntity.New(
        LRecord.FieldByName('id').AsString.Trim(['{', '}']),
        LRecord.FieldByName('name').AsString,
        LRecord.FieldByName('redirect').AsString.Split([';']),
        not LRecord.FieldByName('secret').AsString.IsEmpty
        )
    end;
  finally
    LRecord.Free;
  end;
end;

function TOAuth2ClientRepository.HandlesGrant(ARecord: TDataSet; AGrantType: string): Boolean;
begin
  Result := True;
  case IndexStr(AGrantType, ['authorization_code', 'password', 'client_credentials']) of
    0:
      Result := not ARecord.FieldByName('password_client').AsBoolean;
    1:
      Result := ARecord.FieldByName('password_client').AsBoolean;
    2:
      Result := not ARecord.FieldByName('secret').AsString.IsEmpty;
  end;
end;

class function TOAuth2ClientRepository.New: IOAuth2ClientRepository;
begin
  Result := TOAuth2ClientRepository.Create;
end;

function TOAuth2ClientRepository.ValidateClient(AClientIdentifier, AClientSecret, AGrantType: string): Boolean;
var
  LRecord: TDataSet;
begin
  Result := False;
  LRecord := TOAuth2ClientService.FindActive(AClientIdentifier);
  try
    if ((LRecord <> nil) and (not LRecord.IsEmpty)) and (not HandlesGrant(LRecord, AGrantType)) then
    begin
      Result := False;
    end
    else if (LRecord <> nil) then
    begin
      Result := (LRecord.FieldByName('secret').AsString.IsEmpty) or (VerifySecret(AClientSecret, LRecord.FieldByName('secret').AsString));
    end;
  finally
    LRecord.Free;
  end;
end;

function TOAuth2ClientRepository.VerifySecret(AClientSecret, AStoredHash: string): Boolean;
begin
  Result := TOAuth2ClientService.VerifySecret(AClientSecret, AStoredHash);
end;

end.
