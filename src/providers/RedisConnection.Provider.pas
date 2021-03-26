unit RedisConnection.Provider;

interface

uses
  System.SysUtils,
  Redis.Commons;

type
  TRedisConnectionProvider = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class function NewConnection: IRedisClient;
  end;

implementation

uses
  Redis.Config,
  Redis.Client,
  Redis.NetLib.INDY;

{ TRedisConnectionProvider }

class function TRedisConnectionProvider.NewConnection: IRedisClient;
begin
  Result := TRedisClient.Create(TRedisConfig.Host, TRedisConfig.Port);
end;

end.
