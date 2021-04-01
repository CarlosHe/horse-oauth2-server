unit Horse.HealthCheck.Database;

interface

uses
  Horse.HealthCheck;

type

  THorseHealthCheckDatabase = class(TInterfacedObject, IHorseHealthChecker)
  public
    { public declarations }
    function CheckHealth: THorseHealthCheckResult;
  end;

implementation

uses
  System.SysUtils,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  Connection.FireDAC.PoolManager;

const
  HEALTH_CHECKER_DESCRIPTION = 'database connection checker';

  { THorseHealthCheckDatabase }

function THorseHealthCheckDatabase.CheckHealth: THorseHealthCheckResult;
var
  LResult: THorseHealthCheckResult;
begin
  TFDConnectionPoolManager.DefaultManager.Connection(
    procedure(AConnection: TFDConnection)
    begin
      try
        AConnection.Connected := True;
        LResult := THorseHealthCheckResult.Create(
          THorseHealthStatus.Healthy,
          HEALTH_CHECKER_DESCRIPTION
          );
      except
        on E: Exception do
          LResult := THorseHealthCheckResult.Create(
            THorseHealthStatus.Unhealthy,
            HEALTH_CHECKER_DESCRIPTION,
            Exception.Create(E.Message)
            );
      end;
    end);
  Result := LResult;
end;

end.
