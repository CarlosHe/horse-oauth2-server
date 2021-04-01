unit Controller.Ready;

interface

uses
  Horse;

type
  TReadyController = class
  private
    { private declarations }
  protected
    { protected declarations }
    class procedure GetReady(AReq: THorseRequest; ARes: THorseResponse; ANext: TNextProc);
  public
    { public declarations }
    class procedure &Register;
  end;

implementation

{ TReadyController }

class procedure TReadyController.GetReady(AReq: THorseRequest; ARes: THorseResponse; ANext: TNextProc);
begin
  ARes.Send('SERVER_IS_READY');
end;

class procedure TReadyController.Register;
begin
  THorse.Get('/ready', GetReady);
end;

end.
