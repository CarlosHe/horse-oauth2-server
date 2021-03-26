unit OAuth2.Controller.LoginProxy;

interface

uses

  Horse;

type

  TOAuth2LoginProxyController = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class procedure Page(AReq: THorseRequest; ARes: THorseResponse; ANext: TNextProc);
    class procedure Login(AReq: THorseRequest; ARes: THorseResponse; ANext: TNextProc);
  end;

implementation

uses
  System.SysUtils,
  Horse.OAuth2.Singleton,
  OAuth2.Static.Login,
  OAuth2.Provider.RedisSession,
  OAuth2.Config.LoginProxy,
  System.JSON,
  System.DateUtils,
  System.NetEncoding,
  System.Classes,
  System.Hash,
  OAuth2.Config.Server;

{ TOAuth2LoginProxyController }

class procedure TOAuth2LoginProxyController.Login(AReq: THorseRequest; ARes: THorseResponse; ANext: TNextProc);
var
  LSessionKey: string;
  LSessionValue: TJSONObject;
  LNormalizeRedirectUri: string;
  LJSONObjectContent: TJSONObject;
  LCookieStrings: TStringList;
begin
  AReq.Cookie.TryGetValue('horse_session', LSessionKey);
  LSessionValue := TOAuth2RedisSessionProvider.GetSession(LSessionKey);
  try
    if AReq.ContentFields.ContainsKey('next') then
      LNormalizeRedirectUri := TURLEncoding.URL.Decode(AReq.ContentFields['next']);

    if (AReq.ContentFields.ContainsKey('auth_token')) then
      if (LSessionValue.GetValue<string>('auth_token') <> AReq.ContentFields['auth_token']) or (LSessionValue = nil) then
        raise Exception.Create('The provided auth token for the request is different from the session auth token');

    AReq.RawWebRequest.ContentFields.AddPair('grant_type', 'password');
    AReq.RawWebRequest.ContentFields.AddPair('client_id', TOAuth2LoginProxyConfig.GetClientId);
    AReq.RawWebRequest.ContentFields.AddPair('client_secret', TOAuth2LoginProxyConfig.GetClientSecret);
    AReq.RawWebRequest.ContentFields.AddPair('redirect_uri', LNormalizeRedirectUri);
    AReq.RawWebRequest.ContentFields.AddPair('scope', '*');

    THorseOAuth2.DefaultOAuth2AuthServer.RespondToAccessTokenRequest(AReq.RawWebRequest, ARes.RawWebResponse);

    LJSONObjectContent := TJSONObject.ParseJSONValue(ARes.RawWebResponse.Content) as TJSONObject;
    try
      if LJSONObjectContent = nil then
        Exit;

      LCookieStrings := TStringList.Create;
      try
        ARes.RawWebResponse.SetCustomHeader('Set-Cookie', Format('horse_token=%s', [LJSONObjectContent.GetValue<string>('access_token')]));
      finally
        LCookieStrings.Free;
      end;
    finally
      LJSONObjectContent.Free;
    end;

    if not LNormalizeRedirectUri.IsEmpty then
    begin
      ARes.RawWebResponse.SendRedirect(LNormalizeRedirectUri);
      ARes.RawWebResponse.SendResponse;
    end;

  finally
    LSessionValue.Free;
    TOAuth2RedisSessionProvider.Forgot(LSessionKey);
  end;
end;

class procedure TOAuth2LoginProxyController.Page(AReq: THorseRequest; ARes: THorseResponse; ANext: TNextProc);
var
  LSessionKey: string;
  LSessionValue: TJSONObject;
  LCurrSessionValue: TJSONObject;
  LRedirectUri: string;
  LAuthToken: string;
  LHtmlLogin: string;
begin
  try
    AReq.Cookie.TryGetValue('horse_session', LSessionKey);
    LCurrSessionValue := TOAuth2RedisSessionProvider.GetSession(LSessionKey);
    try
      LAuthToken := THash.GetRandomString(16);
      LSessionKey := TOAuth2RedisSessionProvider.NewSession;
      if AReq.Query.ContainsKey('next') then
        LRedirectUri := AReq.Query['next'];
      LSessionValue := TJSONObject.Create;
      try
        LSessionValue.AddPair('redirect_uri', LRedirectUri);
        LSessionValue.AddPair('auth_token', LAuthToken);
        TOAuth2RedisSessionProvider.SetSession(LSessionKey, LSessionValue);
        ARes.RawWebResponse.SetCustomHeader('Set-Cookie', Format('horse_session=%s', [LSessionKey]));
      finally
        LSessionValue.Free;
      end;
      LHtmlLogin := OAUTH_HTML_LOGIN;
      LHtmlLogin := LHtmlLogin.Replace('%NEXT%', LRedirectUri);
      LHtmlLogin := LHtmlLogin.Replace('%AUTH_TOKEN%', LAuthToken);
      LHtmlLogin := LHtmlLogin.Replace('%APPLICATION_NAME%', TOAuth2ServerConfig.GetApplicationName);
      ARes.Send(LHtmlLogin).ContentType('text/html').Status(THTTPStatus.OK);
    finally
      LCurrSessionValue.Free;
    end;
  finally
    ANext();
  end;

end;

end.
