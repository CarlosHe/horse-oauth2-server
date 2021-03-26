unit Horse.HealthCheck.Ping;

interface

uses
  Horse.HealthCheck;

type

  THorseHealthCheckPing = class(TInterfacedObject, IHorseHealthChecker)
  public
    { public declarations }
    function CheckHealth: THorseHealthCheckResult;
  end;

implementation

{ THorseHealthCheckPing }

function THorseHealthCheckPing.CheckHealth: THorseHealthCheckResult;
begin
  Result := THorseHealthCheckResult.Create(
    THorseHealthStatus.Healthy,
    'ping-pong checker'
  );
end;

end.
