unit Horse.HealthCheck.Redis;

interface

uses
  Horse.HealthCheck;

type

  THorseHealthCheckRedis = class(TInterfacedObject, IHorseHealthChecker)
  public
    { public declarations }
    function CheckHealth: THorseHealthCheckResult;
  end;

implementation

uses
  System.SysUtils,
  Redis.Commons,
  Connection.Redis;

const
  HEALTH_CHECKER_DESCRIPTION = 'redis connection checker';

  { THorseHealthCheckRedis }

function THorseHealthCheckRedis.CheckHealth: THorseHealthCheckResult;
var
  LRedis: IRedisClient;
begin
  LRedis := TRedisConnection.NewConnection;
  try
    LRedis.Connect;
    Result := THorseHealthCheckResult.Create(
      THorseHealthStatus.Healthy,
      HEALTH_CHECKER_DESCRIPTION
      );
  except
    on E: Exception do
      Result := THorseHealthCheckResult.Create(
        THorseHealthStatus.Unhealthy,
        HEALTH_CHECKER_DESCRIPTION,
        Exception.Create(E.Message)
        );
  end;

end;

end.
