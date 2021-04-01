unit Connection.Redis;

interface

uses
  System.SysUtils,
  Redis.Commons;

type
  TRedisConnection = class
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
  Config.Redis,
  Redis.Client,
  Redis.NetLib.INDY;

{ TRedisConnectionProvider }

class function TRedisConnection.NewConnection: IRedisClient;
begin
  Result := TRedisClient.Create(TRedisConfig.Host, TRedisConfig.Port);
end;

end.
