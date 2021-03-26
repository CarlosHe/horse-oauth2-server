unit GUIDGenerator.Provider;

interface

type

  IGUIDGeneratorProvider = interface
    ['{B018A540-719B-4088-AF9C-B427C157A1AC}']
    function SetWithoutBraces(const ABraces: Boolean = True): IGUIDGeneratorProvider;
    function SetWithoutHyphen(const AHyphen: Boolean = True): IGUIDGeneratorProvider;
    function SetUppercase(const AUppercase: Boolean = True): IGUIDGeneratorProvider;
    function Generate: string;
  end;

  TGUIDGeneratorProvider = class(TInterfacedObject, IGUIDGeneratorProvider)
  private
    { private declarations }
    FWithoutBraces: Boolean;
    FWithoutHyphen: Boolean;
    FUppercase: Boolean;
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create;
    class function New: IGUIDGeneratorProvider;
    function SetWithoutBraces(const AWithoutBraces: Boolean = True): IGUIDGeneratorProvider;
    function SetWithoutHyphen(const AWithoutHyphen: Boolean = True): IGUIDGeneratorProvider;
    function SetUppercase(const AUppercase: Boolean = True): IGUIDGeneratorProvider;
    function Generate: string;
  end;

implementation

uses
  System.SysUtils;

{ TGUIDGeneratorProvider }

constructor TGUIDGeneratorProvider.Create;
begin
  FWithoutBraces := False;
  FWithoutHyphen := False;
  FUppercase := False;
end;

function TGUIDGeneratorProvider.Generate: string;
var
  LGUID: TGUID;
  LHResult: HResult;
begin
  LHResult := CreateGUID(LGUID);
  Result := EmptyStr;
  if LHResult = S_OK then
    Result := LGUID.ToString;
  if FWithoutBraces then
    Result := Result.Replace('{', '').Replace('}', '');
  if FWithoutHyphen then
    Result := Result.Replace('-', '');
  if FUppercase then
    Result := Result.ToUpper;
end;

class function TGUIDGeneratorProvider.New: IGUIDGeneratorProvider;
begin
  Result := TGUIDGeneratorProvider.Create;
end;

function TGUIDGeneratorProvider.SetUppercase(const AUppercase: Boolean): IGUIDGeneratorProvider;
begin
  Result := Self;
  FUppercase := AUppercase;
end;

function TGUIDGeneratorProvider.SetWithoutBraces(const AWithoutBraces: Boolean): IGUIDGeneratorProvider;
begin
  Result := Self;
  FWithoutBraces := AWithoutBraces;
end;

function TGUIDGeneratorProvider.SetWithoutHyphen(const AWithoutHyphen: Boolean = True): IGUIDGeneratorProvider;
begin
  Result := Self;
  FWithoutHyphen := AWithoutHyphen;
end;

end.
