unit OAuth2.Controller.AuthorizedAccessToken;

interface

uses
  Horse;

type

  TOAuth2AuthorizedAccessTokenController = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class procedure ForUser(AReq: THorseRequest; ARes: THorseResponse; ANext: TNextProc);
    class procedure Delete(AReq: THorseRequest; ARes: THorseResponse; ANext: TNextProc);
  end;

implementation

uses
  Ragna,
  Horse.OAuth2.Singleton,
  OAuth2.RequestType.AuthorizationRequest,
  OAuth2.Service.Token,
  Data.DB,
  System.JSON,
  System.SysUtils,
  FireDAC.Comp.Client;

{ TOAuth2AuthorizedAccessTokenController }

class procedure TOAuth2AuthorizedAccessTokenController.Delete(AReq: THorseRequest; ARes: THorseResponse; ANext: TNextProc);
var
  LRecord: TDataSet;
  LTokenId: string;
begin
  if (not AReq.Params.ContainsKey('token_id')) or (AReq.Params['token_id'].IsEmpty) then
  begin
    ARes.Send('Param "token_id" not found or is empty').Status(THTTPStatus.BadRequest);
    raise EHorseCallbackInterrupted.Create;
  end;

  LTokenId := AReq.Params['token_id'];

  LRecord := TOAuth2TokenService.FindForUser(LTokenId, AReq.Session<TJSONObject>.GetValue<string>('sub'));
  try
    if LRecord = nil then
      ARes.Send('').Status(THTTPStatus.NotFound)
    else
    begin
      TOAuth2TokenService.SoftDelete(LTokenId);
      ARes.Send('').Status(THTTPStatus.NoContent);
    end;
  finally
    LRecord.Free;
  end;
end;

class procedure TOAuth2AuthorizedAccessTokenController.ForUser(AReq: THorseRequest; ARes: THorseResponse; ANext: TNextProc);
var
  LRecord: TDataSet;
begin
  LRecord := TOAuth2TokenService.ForUser(AReq.Session<TJSONObject>.GetValue<string>('sub'));
  try
    if LRecord <> nil then
      ARes.Send<TJSONArray>(TFDQuery(LRecord).ToJSONArray)
    else
      ARes.Send<TJSONArray>(TJSONArray.Create);
  finally
    LRecord.Free;
  end;
end;

end.
