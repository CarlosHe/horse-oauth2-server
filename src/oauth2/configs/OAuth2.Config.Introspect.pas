unit OAuth2.Config.Introspect;

interface

type

  TOAuth2IntrospectConfig = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class function User: string;
    class function Password: string;
  end;

implementation

uses
  System.SysUtils;

{ TOAuth2IntrospectConfig }

class function TOAuth2IntrospectConfig.Password: string;
begin
  Result := GetEnvironmentVariable('INTROSPECT_PASSWORD');
  if Result.IsEmpty then
    Result := 'e084d100-f903-4940-8df4-10e05d45056d';
end;

class function TOAuth2IntrospectConfig.User: string;
begin
  Result := GetEnvironmentVariable('INTROSPECT_USER');
  if Result.IsEmpty then
    Result := 'introspect';
end;

end.
