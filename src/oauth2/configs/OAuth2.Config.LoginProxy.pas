unit OAuth2.Config.LoginProxy;

interface

type

  TOAuth2LoginProxyConfig = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class function GetClientId: string;
    class function GetClientSecret: string;
  end;

implementation

uses
  System.SysUtils;

{ TOAuth2LoginProxyConfig }

class function TOAuth2LoginProxyConfig.GetClientId: string;
begin
  Result := GetEnvironmentVariable('LOGIN_CLIENT_ID');
  if Result.IsEmpty then
    Result := '7318ec6c-8cdd-11eb-94ae-0242ac120002';
end;

class function TOAuth2LoginProxyConfig.GetClientSecret: string;
begin
  Result := GetEnvironmentVariable('LOGIN_CLIENT_SECRET');
  if Result.IsEmpty then
    Result := 'KLdcJbnqDeDJ3jkfHCpR*-URHNg8a4OlL4qCABDy';
end;

end.
