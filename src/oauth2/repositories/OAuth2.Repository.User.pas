unit OAuth2.Repository.User;

interface

uses
  OAuth2.Repository.User.Contract,
  OAuth2.Entity.User.Contract,
  OAuth2.Entity.Client.Contract;

type

  TOAuth2UserRepository = class(TInterfacedObject, IOAuth2UserRepository)
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    function GetUserEntityByUserCredentials(AUsername: string; APassword: string; AGrantType: string; AClientEntity: IOAuth2ClientEntity): IOAuth2UserEntity;
    class function New: IOAuth2UserRepository;
  end;

implementation

uses
  Data.DB,
  System.SysUtils,
  OAuth2.Entity.User,
  OAuth2.Service.User;

{ TOAuth2UserRepository }

function TOAuth2UserRepository.GetUserEntityByUserCredentials(AUsername, APassword, AGrantType: string; AClientEntity: IOAuth2ClientEntity): IOAuth2UserEntity;
var
  LRecord: TDataSet;
begin
  Result := nil;
  LRecord := TOAuth2UserService.FindAndValidateForPassport(AUsername, APassword);
  try
    if LRecord <> nil then
      Result := TOAuth2UserEntity.New(LRecord.FieldByName('id').AsString.Trim(['{', '}']));
  finally
    LRecord.Free;
  end;
end;

class function TOAuth2UserRepository.New: IOAuth2UserRepository;
begin
  Result := TOAuth2UserRepository.Create;
end;

end.
