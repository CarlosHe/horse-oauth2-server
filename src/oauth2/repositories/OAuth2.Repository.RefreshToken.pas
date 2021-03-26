unit OAuth2.Repository.RefreshToken;

interface

uses
  OAuth2.Repository.RefreshToken.Contract,
  OAuth2.Entity.RefreshToken.Contract;

type

  TOAuth2RefreshTokenRepository = class(TInterfacedObject, IOAuth2RefreshTokenRepository)
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    function GetNewRefreshToken: IOAuth2RefreshTokenEntity;
    procedure PersistNewRefreshToken(ARefreshTokenEntity: IOAuth2RefreshTokenEntity);
    procedure RevokeRefreshToken(ATokenId: string);
    function IsRefreshTokenRevoked(ATokenId: string): Boolean;
    class function New: IOAuth2RefreshTokenRepository;
  end;

implementation

uses
  OAuth2.Entity.RefreshToken,
  OAuth2.Service.RefreshToken;

{ TOAuth2RefreshTokenRepository }

function TOAuth2RefreshTokenRepository.GetNewRefreshToken: IOAuth2RefreshTokenEntity;
begin
  Result := TOAuth2RefreshTokenEntity.New;
end;

function TOAuth2RefreshTokenRepository.IsRefreshTokenRevoked(ATokenId: string): Boolean;
begin
  Result := TOAuth2RefreshTokenService.IsRefreshTokenRevoked(ATokenId);
end;

class function TOAuth2RefreshTokenRepository.New: IOAuth2RefreshTokenRepository;
begin
  Result := TOAuth2RefreshTokenRepository.Create;
end;

procedure TOAuth2RefreshTokenRepository.PersistNewRefreshToken(ARefreshTokenEntity: IOAuth2RefreshTokenEntity);
begin
  TOAuth2RefreshTokenService.Store(ARefreshTokenEntity);
end;

procedure TOAuth2RefreshTokenRepository.RevokeRefreshToken(ATokenId: string);
begin
  TOAuth2RefreshTokenService.RevokeRefreshToken(ATokenId);
end;

end.
