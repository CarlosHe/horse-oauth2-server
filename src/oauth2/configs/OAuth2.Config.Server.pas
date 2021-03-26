unit OAuth2.Config.Server;

interface

type

  TOAuth2ServerConfig = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class function GetApplicationName: string;
  end;

implementation

uses
  System.SysUtils;

{ TOAuth2ServerConfig }

class function TOAuth2ServerConfig.GetApplicationName: string;
begin
  Result := GetEnvironmentVariable('APPLICATION_NAME');
  if Result.IsEmpty then
    Result := 'Horse';
end;

end.
