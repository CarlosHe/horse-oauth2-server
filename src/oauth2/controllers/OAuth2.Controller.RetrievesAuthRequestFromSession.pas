unit OAuth2.Controller.RetrievesAuthRequestFromSession;

interface

uses
  Horse,
  OAuth2.RequestType.AuthorizationRequest;

type
  TOAuth2RetrievesAuthRequestFromSessionController = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class procedure AssertValidAuthToken(AReq: THorseRequest);
    class function GetAuthRequestFromSession(AReq: THorseRequest): TOAuth2AuthorizationRequest;
  end;

implementation

uses
  System.JSON,
  OAuth2.Entity.User,
  OAuth2.Provider.RedisSession,
  System.SysUtils;

class procedure TOAuth2RetrievesAuthRequestFromSessionController.AssertValidAuthToken(AReq: THorseRequest);
var
  LSessionKey: string;
  LSessionValue: TJSONObject;
begin
  AReq.Cookie.TryGetValue('horse_session', LSessionKey);
  LSessionValue := TOAuth2RedisSessionProvider.GetSession(LSessionKey);
  try
    if (LSessionValue = nil) then
    begin
      TOAuth2RedisSessionProvider.Forgot(LSessionKey);
      raise Exception.Create('The provided auth token for the request is different from the session auth token');
    end;
  finally
    LSessionValue.Free;
  end;
end;

class function TOAuth2RetrievesAuthRequestFromSessionController.GetAuthRequestFromSession(AReq: THorseRequest): TOAuth2AuthorizationRequest;
var
  LSessionKey: string;
  LSessionValue: TJSONObject;
  LJSONAuthRequest: TJSONObject;
begin
  AReq.Cookie.TryGetValue('horse_session', LSessionKey);
  LSessionValue := TOAuth2RedisSessionProvider.GetSession(LSessionKey);
  try
    if (LSessionValue = nil) or (not LSessionValue.TryGetValue<TJSONObject>('auth_request', LJSONAuthRequest)) then
    begin
      raise Exception.Create('Authorization request was not present in the session');
    end;
    Result := TOAuth2AuthorizationRequest.Create;
    Result.FromJSON(LJSONAuthRequest);

    Result.SetUser(TOAuth2UserEntity.New(AReq.Session<TJSONObject>.GetValue<string>('sub')));

    Result.SetAuthorizationApproved(true);
  finally
    LSessionValue.Free;
  end;
end;

end.
