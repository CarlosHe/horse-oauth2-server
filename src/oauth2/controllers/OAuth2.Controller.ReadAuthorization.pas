unit OAuth2.Controller.ReadAuthorization;

interface

uses

  Horse;

type

  TOAuth2ReadAuthorizationController = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class procedure Read(AReq: THorseRequest; ARes: THorseResponse; ANext: TNextProc);
  end;

implementation

uses
  Horse.OAuth2.Singleton,
  OAuth2.Controller.RetrievesAuthRequestFromSession,
  OAuth2.RequestType.AuthorizationRequest,
  OAuth2.Entity.User,
  System.JSON,
  System.SysUtils,
  System.StrUtils;

{ TOAuth2ReadAuthorizationController }

class procedure TOAuth2ReadAuthorizationController.Read(AReq: THorseRequest; ARes: THorseResponse; ANext: TNextProc);
var
  LAuthRequest: TOAuth2AuthorizationRequest;
  LClientUris: TArray<string>;
  LUri: string;
  LSeparator: string;
  LState: string;
begin
  TOAuth2RetrievesAuthRequestFromSessionController.AssertValidAuthToken(AReq);
  LAuthRequest := TOAuth2RetrievesAuthRequestFromSessionController.GetAuthRequestFromSession(AReq);
  try
    if (AReq.ContentFields.ContainsKey('__confirm__')) and (AReq.ContentFields['__confirm__'] = '1') then
    begin
      LAuthRequest.SetUser(TOAuth2UserEntity.New(AReq.Session<TJSONObject>.GetValue<string>('sub')));
      LAuthRequest.SetAuthorizationApproved(True);
      THorseOAuth2.DefaultOAuth2AuthServer.CompleteAuthorizationRequest(LAuthRequest, ARes.RawWebResponse);
    end;
    if (AReq.ContentFields.ContainsKey('__cancel__')) and (AReq.ContentFields['__cancel__'] = '1') then
    begin
      LClientUris := LAuthRequest.GetClient.GetRedirectUri;
      LUri := LAuthRequest.GetRedirectUri;
      if IndexStr(LAuthRequest.GetRedirectUri, LClientUris) = -1 then
        LUri := LClientUris[0];
      LSeparator := '#';
      if LAuthRequest.GetGrantTypeId <> 'implicit' then
      begin
        if LUri.Contains('?') then
          LSeparator := '&'
        else
          LSeparator := '?'
      end;
      if AReq.ContentFields.ContainsKey('state')  then
        LState := AReq.ContentFields['state'];
      ARes.RawWebResponse.SendRedirect(LUri + LSeparator + 'error=access_denied&state=' + LState);
      ARes.RawWebResponse.SendResponse;
      raise EHorseCallbackInterrupted.Create;
    end;
  finally
    LAuthRequest.Free;
  end;
end;

end.
