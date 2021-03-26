unit ServerPort.Config;

interface

type

  TServerPortConfig = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class function Port: Word;
  end;

implementation

uses
  System.SysUtils;

{ TServerPortConfig }

class function TServerPortConfig.Port: Word;
begin
  Result := StrToIntDef(GetEnvironmentVariable('PORT'), 9000);
end;

end.
