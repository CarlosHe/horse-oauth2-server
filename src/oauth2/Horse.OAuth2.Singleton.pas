unit Horse.OAuth2.Singleton;

interface

uses
  OAuth2.Repository.Client.Contract,
  OAuth2.Repository.AccessToken.Contract,
  OAuth2.Repository.Scope.Contract,
  OAuth2.Repository.AuthCode.Contract,
  OAuth2.Repository.RefreshToken.Contract,
  OAuth2.Repository.User.Contract,
  OAuth2.Grant.GrantType.Contract,
  OAuth2.AuthorizationServer,
  OAuth2.ResourceServer,
  OAuth2.CryptKey;

type

  THorseOAuth2 = class
  private
    class var FOAuth2AuthorizationServer: TOAuth2AuthorizationServer;
    class var FOAuth2ResourceServer: TOAuth2ResourceServer;
    class var FPrivateKey: TOAuth2CryptKey;
    class var FPublicKey: TOAuth2CryptKey;
    class var FOAuth2ClientRepository: IOAuth2ClientRepository;
    class var FOAuth2AccessTokenRepository: IOAuth2AccessTokenRepository;
    class var FOAuth2ScopeRepository: IOAuth2ScopeRepository;
    class var FOAuth2AuthCodeRepository: IOAuth2AuthCodeRepository;
    class var FOAuth2RefreshTokenRepository: IOAuth2RefreshTokenRepository;
    class var FOAuth2UserRepository: IOAuth2UserRepository;
    { private declarations }
  protected
    { protected declarations }
    class function MakeAuthCodeGrant: IOAuth2GrantTypeGrant;
    class function MakeRefreshTokenGrant: IOAuth2GrantTypeGrant;
    class function MakePasswordGrant: IOAuth2GrantTypeGrant;
    class function MakeClientCredentialsGrant: IOAuth2GrantTypeGrant;
    class function MakeImplicitGrant: IOAuth2GrantTypeGrant;
    class function GetDefaultOAuth2Server: TOAuth2AuthorizationServer; static;
    class function GetDefaultOAuth2ResourceServer: TOAuth2ResourceServer; static;
    class function GetDefaultPrivateKey: TOAuth2CryptKey; static;
    class function GetDefaultPublicKey: TOAuth2CryptKey; static;
    class function GetDefaultOAuth2ClientRepository: IOAuth2ClientRepository; static;
    class function GetDefaultOAuth2AccessTokenRepository: IOAuth2AccessTokenRepository; static;
    class function GetDefaultOAuth2ScopeRepository: IOAuth2ScopeRepository; static;
    class function GetDefaultOAuth2AuthCodeRepository: IOAuth2AuthCodeRepository; static;
    class function GetDefaultOAuth2RefreshTokenRepository: IOAuth2RefreshTokenRepository; static;
    class function GetDefaultOAuth2UserRepository: IOAuth2UserRepository; static;
  public
    { public declarations }

    class property DefaultOAuth2AuthServer: TOAuth2AuthorizationServer read GetDefaultOAuth2Server;
    class property DefaultOAuth2ResourceServer: TOAuth2ResourceServer read GetDefaultOAuth2ResourceServer;
    class property DefaultPrivateKey: TOAuth2CryptKey read GetDefaultPrivateKey;
    class property DefaultPublicKey: TOAuth2CryptKey read GetDefaultPublicKey;
    class property DefaultOAuth2ClientRepository: IOAuth2ClientRepository read GetDefaultOAuth2ClientRepository;
    class property DefaultOAuth2AccessTokenRepository: IOAuth2AccessTokenRepository read GetDefaultOAuth2AccessTokenRepository;
    class property DefaultOAuth2ScopeRepository: IOAuth2ScopeRepository read GetDefaultOAuth2ScopeRepository;
    class property DefaultOAuth2AuthCodeRepository: IOAuth2AuthCodeRepository read GetDefaultOAuth2AuthCodeRepository;
    class property DefaultOAuth2RefreshTokenRepository: IOAuth2RefreshTokenRepository read GetDefaultOAuth2RefreshTokenRepository;
    class destructor UnInitialize;
  end;

implementation

uses
  OAuth2.Grant.AuthCode,
  OAuth2.Grant.RefreshToken,
  OAuth2.Grant.Password,
  OAuth2.Grant.ClientCredentials,
  OAuth2.Grant.Implicit,
  OAuth2.Repository.Client,
  OAuth2.Repository.AccessToken,
  OAuth2.Repository.Scope,
  OAuth2.Repository.AuthCode,
  OAuth2.Repository.RefreshToken,
  OAuth2.Repository.User,
  System.Classes,
  System.SysUtils,
  OAuth2.Config.Keys,
  OAuth2.Config.TTL;

{ THorseOAuth2 }

class function THorseOAuth2.GetDefaultOAuth2AccessTokenRepository: IOAuth2AccessTokenRepository;
begin
  if FOAuth2AccessTokenRepository = nil then
    FOAuth2AccessTokenRepository := TOAuth2AccessTokenRepository.New;
  Result := FOAuth2AccessTokenRepository;
end;

class function THorseOAuth2.GetDefaultOAuth2AuthCodeRepository: IOAuth2AuthCodeRepository;
begin
  if FOAuth2AuthCodeRepository = nil then
    FOAuth2AuthCodeRepository := TOAuth2AuthCodeRepository.New;
  Result := FOAuth2AuthCodeRepository;
end;

class function THorseOAuth2.GetDefaultOAuth2ClientRepository: IOAuth2ClientRepository;
begin
  if FOAuth2ClientRepository = nil then
    FOAuth2ClientRepository := TOAuth2ClientRepository.New;
  Result := FOAuth2ClientRepository;
end;

class function THorseOAuth2.GetDefaultOAuth2RefreshTokenRepository: IOAuth2RefreshTokenRepository;
begin
  if FOAuth2RefreshTokenRepository = nil then
    FOAuth2RefreshTokenRepository := TOAuth2RefreshTokenRepository.New;
  Result := FOAuth2RefreshTokenRepository;
end;

class function THorseOAuth2.GetDefaultOAuth2ResourceServer: TOAuth2ResourceServer;
begin
  if FOAuth2ResourceServer = nil then
  begin
    FOAuth2ResourceServer := TOAuth2ResourceServer.Create(
      GetDefaultOAuth2AccessTokenRepository,
      GetDefaultPublicKey
      );
  end;
  Result := FOAuth2ResourceServer;
end;

class function THorseOAuth2.GetDefaultOAuth2ScopeRepository: IOAuth2ScopeRepository;
begin
  if FOAuth2ScopeRepository = nil then
    FOAuth2ScopeRepository := TOAuth2ScopeRepository.New;
  Result := FOAuth2ScopeRepository;
end;

class function THorseOAuth2.GetDefaultOAuth2Server: TOAuth2AuthorizationServer;
begin
  if FOAuth2AuthorizationServer = nil then
  begin
    FOAuth2AuthorizationServer := TOAuth2AuthorizationServer.Create(
      GetDefaultOAuth2ClientRepository,
      GetDefaultOAuth2AccessTokenRepository,
      GetDefaultOAuth2ScopeRepository,
      GetDefaultPrivateKey,
      TOAuth2KeysConfig.GetEncryptionKey
      );
    FOAuth2AuthorizationServer.EnableGrantType(MakeAuthCodeGrant, TOAuth2TTLConfig.GetAccessTokenTTL);
    FOAuth2AuthorizationServer.EnableGrantType(MakeRefreshTokenGrant, TOAuth2TTLConfig.GetAccessTokenTTL);
    FOAuth2AuthorizationServer.EnableGrantType(MakePasswordGrant, TOAuth2TTLConfig.GetAccessTokenTTL);
    FOAuth2AuthorizationServer.EnableGrantType(MakeClientCredentialsGrant, TOAuth2TTLConfig.GetAccessTokenTTL);
    FOAuth2AuthorizationServer.EnableGrantType(MakeImplicitGrant, TOAuth2TTLConfig.GetAccessTokenTTL);
  end;
  Result := FOAuth2AuthorizationServer;
end;

class function THorseOAuth2.GetDefaultOAuth2UserRepository: IOAuth2UserRepository;
begin
  if FOAuth2UserRepository = nil then
    FOAuth2UserRepository := TOAuth2UserRepository.New;
  Result := FOAuth2UserRepository;
end;

class function THorseOAuth2.GetDefaultPrivateKey: TOAuth2CryptKey;
begin
  if FPrivateKey = nil then
  begin
    FPrivateKey := TOAuth2CryptKey.New(TOAuth2KeysConfig.GetPrivateKey, EmptyStr, False);
  end;
  Result := FPrivateKey;
end;

class function THorseOAuth2.GetDefaultPublicKey: TOAuth2CryptKey;
begin
  if FPublicKey = nil then
  begin
    FPublicKey := TOAuth2CryptKey.New(TOAuth2KeysConfig.GetPublicKey, EmptyStr, False);
  end;
  Result := FPublicKey;
end;

class function THorseOAuth2.MakeAuthCodeGrant: IOAuth2GrantTypeGrant;
begin
  Result := TOAuth2AuthCodeGrant.New(GetDefaultOAuth2AuthCodeRepository, GetDefaultOAuth2RefreshTokenRepository, TOAuth2TTLConfig.GetAuthCodeTTL);
  Result.SetRefreshTokenTTL(TOAuth2TTLConfig.GetRefreshTokenTTL);
end;

class function THorseOAuth2.MakeClientCredentialsGrant: IOAuth2GrantTypeGrant;
begin
  Result := TOAuth2ClientCredentialsGrant.New;
end;

class function THorseOAuth2.MakeImplicitGrant: IOAuth2GrantTypeGrant;
begin
  Result := TOAuth2ImplicitGrant.New(TOAuth2TTLConfig.GetAccessTokenTTL);
end;

class function THorseOAuth2.MakePasswordGrant: IOAuth2GrantTypeGrant;
begin
  Result := TOAuth2PasswordGrant.New(GetDefaultOAuth2UserRepository, GetDefaultOAuth2RefreshTokenRepository);
  Result.SetRefreshTokenTTL(TOAuth2TTLConfig.GetRefreshTokenTTL);
end;

class function THorseOAuth2.MakeRefreshTokenGrant: IOAuth2GrantTypeGrant;
begin
  Result := TOAuth2RefreshTokenGrant.New(GetDefaultOAuth2RefreshTokenRepository);
  Result.SetRefreshTokenTTL(TOAuth2TTLConfig.GetRefreshTokenTTL);
end;

class destructor THorseOAuth2.UnInitialize;
begin
  if Assigned(FPrivateKey) then
    FreeAndNil(FPrivateKey);
  if Assigned(FPublicKey) then
    FreeAndNil(FPublicKey);
  if Assigned(FOAuth2ResourceServer) then
    FreeAndNil(FOAuth2ResourceServer);
  if Assigned(FOAuth2AuthorizationServer) then
    FreeAndNil(FOAuth2AuthorizationServer);
end;

end.
