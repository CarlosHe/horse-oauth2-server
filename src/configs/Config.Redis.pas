unit Config.Redis;

interface

type
  TRedisConfig = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class function Host: string;
    class function Port: Integer;
  end;

implementation

uses
  System.SysUtils;

{ TRedisConfig }

class function TRedisConfig.Host: string;
begin
  Result := GetEnvironmentVariable('REDIS_HOST');
end;

class function TRedisConfig.Port: Integer;
begin
  Result := StrToIntDef(GetEnvironmentVariable('REDIS_PORT'), 6379);
end;

end.
