unit OAuth2.Config.TTL;

interface

type

  TOAuth2TTLConfig = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class function GetAccessTokenTTL: Int64;
    class function GetRefreshTokenTTL: Int64;
    class function GetAuthCodeTTL: Int64;
  end;

implementation

uses
  System.SysUtils;

{ TOAuth2TTLConfig }

class function TOAuth2TTLConfig.GetAccessTokenTTL: Int64;
begin
  Result := StrToInt64Def(GetEnvironmentVariable('ACCESS_TOKEN_TTL'), 1296000);
end;

class function TOAuth2TTLConfig.GetAuthCodeTTL: Int64;
begin
  Result := StrToInt64Def(GetEnvironmentVariable('AUTH_CODE_TTL'), 25920000);
end;

class function TOAuth2TTLConfig.GetRefreshTokenTTL: Int64;
begin
  Result := StrToInt64Def(GetEnvironmentVariable('REFRESH_TOKEN_TTL'), 2592000);
end;

end.
