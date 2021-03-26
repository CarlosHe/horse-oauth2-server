unit OAuth2.Repository.AuthCode;

interface

uses
  OAuth2.Repository.AuthCode.Contract,
  OAuth2.Entity.AuthCode.Contract;

type

  TOAuth2AuthCodeRepository = class(TInterfacedObject, IOAuth2AuthCodeRepository)
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    function GetNewAuthCode: IOAuth2AuthCodeEntity;
    procedure PersistNewAuthCode(AAuthCodeEntity: IOAuth2AuthCodeEntity);
    procedure RevokeAuthCode(ACodeId: string);
    function IsAuthCodeRevoked(ACodeId: string): Boolean;
    class function New: IOAuth2AuthCodeRepository;
  end;

implementation

uses
  System.SysUtils,
  OAuth2.Entity.AuthCode,
  OAuth2.Service.AuthCode;

{ TOAuth2AuthCodeRepository }

function TOAuth2AuthCodeRepository.GetNewAuthCode: IOAuth2AuthCodeEntity;
begin
  Result := TOAuth2AuthCodeEntity.Create(EmptyStr);
end;

function TOAuth2AuthCodeRepository.IsAuthCodeRevoked(ACodeId: string): Boolean;
begin
  Result := TOAuth2AuthCodeService.IsAuthCodeRevoked(ACodeId);
end;

class function TOAuth2AuthCodeRepository.New: IOAuth2AuthCodeRepository;
begin
  Result := TOAuth2AuthCodeRepository.Create;
end;

procedure TOAuth2AuthCodeRepository.PersistNewAuthCode(AAuthCodeEntity: IOAuth2AuthCodeEntity);
begin
  TOAuth2AuthCodeService.Store(AAuthCodeEntity);
end;

procedure TOAuth2AuthCodeRepository.RevokeAuthCode(ACodeId: string);
begin
  TOAuth2AuthCodeService.RevokeAuthCode(ACodeId);
end;

end.
