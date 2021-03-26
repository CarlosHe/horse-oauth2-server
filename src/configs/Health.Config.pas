unit Health.Config;

interface

type

  THealthConfig = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class function Secret: string;
  end;

implementation

uses
  System.SysUtils;

{ THealthConfig }

class function THealthConfig.Secret: string;
begin
  Result := GetEnvironmentVariable('HEALTH_SECRET');
end;

end.
