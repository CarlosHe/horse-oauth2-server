unit OAuth2.Controller.Client;

interface

uses
  Horse;

type

  TOAuth2ClientController = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class procedure ForUser(AReq: THorseRequest; ARes: THorseResponse; ANext: TNextProc);
    class procedure Store(AReq: THorseRequest; ARes: THorseResponse; ANext: TNextProc);
    class procedure Update(AReq: THorseRequest; ARes: THorseResponse; ANext: TNextProc);
    class procedure Delete(AReq: THorseRequest; ARes: THorseResponse; ANext: TNextProc);
  end;

implementation

uses
  Ragna,
  System.JSON,
  System.SysUtils,
  FireDAC.Comp.Client,
  Data.DB,
  OAuth2.Service.Client,
  OAuth2.RequestType.AuthorizationRequest,
  Horse.OAuth2.Singleton;

{ TOAuth2ClientController }

class procedure TOAuth2ClientController.Delete(AReq: THorseRequest; ARes: THorseResponse; ANext: TNextProc);
var
  LRecord: TDataSet;
  LClientId: string;
begin
  if (not AReq.Params.ContainsKey('client_id')) or (AReq.Params['client_id'].IsEmpty) then
  begin
    ARes.Send('Param "client_id" not found or is empty').Status(THTTPStatus.BadRequest);
    raise EHorseCallbackInterrupted.Create;
  end;

  LClientId := Format('{%s}', [AReq.Params['client_id'].Trim(['{', '}'])]);

  LRecord := TOAuth2ClientService.FindForUser(LClientId, AReq.Session<TJSONObject>.GetValue<string>('sub'));
  try
    if LRecord = nil then
      ARes.Send('').Status(THTTPStatus.NotFound)
    else
    begin
      TOAuth2ClientService.SoftDelete(LClientId);
      ARes.Send('').Status(THTTPStatus.NoContent);
    end;
  finally
    LRecord.Free;
  end;
end;

class procedure TOAuth2ClientController.ForUser(AReq: THorseRequest; ARes: THorseResponse; ANext: TNextProc);
var
  LRecord: TDataSet;
begin
  LRecord := TOAuth2ClientService.ActiveForUser(AReq.Session<TJSONObject>.GetValue<string>('sub'));
  try
    if LRecord <> nil then
      ARes.Send<TJSONArray>(TFDQuery(LRecord).ToJSONArray)
    else
      ARes.Send<TJSONArray>(TJSONArray.Create);
  finally
    LRecord.Free;
  end;
end;

class procedure TOAuth2ClientController.Store(AReq: THorseRequest; ARes: THorseResponse; ANext: TNextProc);
var
  LJSONObjectBody: TJSONObject;
  LRedirectUri: string;
  LName: string;
begin
  LJSONObjectBody := AReq.Body<TJSONObject>;
  if LJSONObjectBody = nil then
  begin
    ARes.Send('Invalid body').Status(THTTPStatus.BadRequest);
    raise EHorseCallbackInterrupted.Create;
  end
  else if not LJSONObjectBody.TryGetValue<string>('redirect', LRedirectUri) then
  begin
    ARes.Send('Field "redirect" not found').Status(THTTPStatus.BadRequest);
    raise EHorseCallbackInterrupted.Create;
  end
  else if not LJSONObjectBody.TryGetValue<string>('name', LName) then
  begin
    ARes.Send('Field "name" not found').Status(THTTPStatus.BadRequest);
    raise EHorseCallbackInterrupted.Create;
  end
  else
  begin
    LJSONObjectBody.AddPair('provider', TJSONNull.Create);
    LJSONObjectBody.AddPair('password_client', TJSONBool.Create(False));
    TOAuth2ClientService.Store(AReq.Session<TJSONObject>.GetValue<string>('sub'), LJSONObjectBody);
    ARes.Send<TJSONObject>(LJSONObjectBody);
  end;
end;

class procedure TOAuth2ClientController.Update(AReq: THorseRequest; ARes: THorseResponse; ANext: TNextProc);
var
  LRecord: TDataSet;
  LJSONObjectBody: TJSONObject;
  LJSONObjectResBody: TJSONObject;
  LClientId: string;
  LRedirectUri: string;
  LName: string;
begin

  LJSONObjectBody := AReq.Body<TJSONObject>;
  if LJSONObjectBody = nil then
  begin
    ARes.Send('Invalid body').Status(THTTPStatus.BadRequest);
    raise EHorseCallbackInterrupted.Create;
  end
  else if (not AReq.Params.ContainsKey('client_id')) or (AReq.Params['client_id'].IsEmpty) then
  begin
    ARes.Send('Param "client_id" not found or is empty').Status(THTTPStatus.BadRequest);
    raise EHorseCallbackInterrupted.Create;
  end
  else if not LJSONObjectBody.TryGetValue<string>('redirect', LRedirectUri) then
  begin
    ARes.Send('Field "redirect" not found').Status(THTTPStatus.BadRequest);
    raise EHorseCallbackInterrupted.Create;
  end
  else if not LJSONObjectBody.TryGetValue<string>('name', LName) then
  begin
    ARes.Send('Field "name" not found').Status(THTTPStatus.BadRequest);
    raise EHorseCallbackInterrupted.Create;
  end
  else
  begin
    LClientId := Format('{%s}', [AReq.Params['client_id'].Trim(['{', '}'])]);
    LRecord := TOAuth2ClientService.FindForUser(LClientId, AReq.Session<TJSONObject>.GetValue<string>('sub'));
    try
      if LRecord = nil then
      begin
        ARes.Send('').Status(THTTPStatus.NotFound);
        raise EHorseCallbackInterrupted.Create;
      end
      else
      begin
        LJSONObjectResBody := TFDQuery(LRecord).ToJSONObject;
        LJSONObjectResBody.RemovePair('id').Free;
        LJSONObjectResBody.RemovePair('redirect').Free;
        LJSONObjectResBody. RemovePair('name').Free;
        LJSONObjectResBody.AddPair('id', LClientId);
        LJSONObjectResBody.AddPair('redirect', LRedirectUri);
        LJSONObjectResBody.AddPair('name', LName);
        TOAuth2ClientService.Update(AReq.Session<TJSONObject>.GetValue<string>('sub'), LJSONObjectResBody);
        ARes.Send<TJSONObject>(LJSONObjectResBody);
      end;
    finally
      LRecord.Free;
    end;
  end;
end;

end.
