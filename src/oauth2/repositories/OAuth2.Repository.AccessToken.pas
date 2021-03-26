unit OAuth2.Repository.AccessToken;

interface

uses
  OAuth2.Repository.AccessToken.Contract,
  OAuth2.Entity.Client.Contract,
  OAuth2.Entity.AccessToken.Contract,
  OAuth2.Entity.Scope.Contract;

type

  TOAuth2AccessTokenRepository = class(TInterfacedObject, IOAuth2AccessTokenRepository)
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    function GetNewToken(AClientEntity: IOAuth2ClientEntity; AScopes: TArray<IOAuth2ScopeEntity>; const AUserIdentifier: string = ''): IOAuth2AccessTokenEntity;
    procedure PersistNewAccessToken(AAccessTokenEntity: IOAuth2AccessTokenEntity);
    procedure RevokeAccessToken(ATokenId: string);
    function IsAccessTokenRevoked(ATokenId: string): Boolean;
    class function New: IOAuth2AccessTokenRepository;
  end;

implementation

uses
  OAuth2.Entity.AccessToken,
  OAuth2.Service.Token;

{ TOAuth2AccessTokenRepository }

function TOAuth2AccessTokenRepository.GetNewToken(AClientEntity: IOAuth2ClientEntity; AScopes: TArray<IOAuth2ScopeEntity>; const AUserIdentifier: string): IOAuth2AccessTokenEntity;
var
  I: Integer;
begin
  Result := TOAuth2AccessTokenEntity.New;
  Result.SetClient(AClientEntity);
  Result.SetUserIdentifier(AUserIdentifier);
  for I := Low(AScopes) to High(AScopes) do
    Result.AddScope(AScopes[I]);
end;

function TOAuth2AccessTokenRepository.IsAccessTokenRevoked(ATokenId: string): Boolean;
begin
  Result := TOAuth2TokenService.IsAccessTokenRevoked(ATokenId);
end;

class function TOAuth2AccessTokenRepository.New: IOAuth2AccessTokenRepository;
begin
  Result := TOAuth2AccessTokenRepository.Create;
end;

procedure TOAuth2AccessTokenRepository.PersistNewAccessToken(AAccessTokenEntity: IOAuth2AccessTokenEntity);
begin
  TOAuth2TokenService.Store(AAccessTokenEntity);
end;

procedure TOAuth2AccessTokenRepository.RevokeAccessToken(ATokenId: string);
begin
  TOAuth2TokenService.RevokeAccessToken(ATokenId);
end;

end.
