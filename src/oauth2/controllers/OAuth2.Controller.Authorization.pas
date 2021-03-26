unit OAuth2.Controller.Authorization;

interface

uses

  Horse,
  Web.HTTPApp,
  OAuth2.RequestType.AuthorizationRequest;

type

  TOAuth2AuthorizationController = class
  private
    { private declarations }
  protected
    { protected declarations }
    class procedure ApproveRequest(AAuthRequest: TOAuth2AuthorizationRequest; AUserId: string; AResponse: TWebResponse);
    class function ParseScopes(AAuthRequest: TOAuth2AuthorizationRequest): TArray<string>;
    class function ContainsScopesInArray(AScopesL: TArray<string>; AScopesR: TArray<string>): Boolean;
  public
    { public declarations }
    class procedure Authorize(AReq: THorseRequest; ARes: THorseResponse; ANext: TNextProc);
  end;

implementation

uses
  Horse.OAuth2.Singleton,
  System.Hash,
  System.IOUtils,
  System.StrUtils,
  System.SysUtils,
  System.Classes,
  System.JSON,
  Data.DB,
  OAuth2.Static.Auth,
  OAuth2.Provider.RedisSession,
  OAuth2.Service.Token,
  OAuth2.Service.Client,
  OAuth2.Service.Scope,
  OAuth2.Entity.User,
  OAuth2.Config.Server;

{ TOAuth2AuthorizationController }

class procedure TOAuth2AuthorizationController.ApproveRequest(AAuthRequest: TOAuth2AuthorizationRequest; AUserId: string; AResponse: TWebResponse);
begin
  AAuthRequest.SetUser(TOAuth2UserEntity.New(AUserId));
  AAuthRequest.SetAuthorizationApproved(True);
  THorseOAuth2.DefaultOAuth2AuthServer.CompleteAuthorizationRequest(AAuthRequest, AResponse)
end;

class procedure TOAuth2AuthorizationController.Authorize(AReq: THorseRequest; ARes: THorseResponse; ANext: TNextProc);
var
  LAuthRequest: TOAuth2AuthorizationRequest;
  LScopes: TArray<string>;
  LAuthToken: string;
  LSessionKey: string;
  LSessionValue: TJSONObject;
  LRecord: TDataSet;
  LHtmlAuth: string;
  LScopeFragment: string;
  LScopeItems: string;
  LScopeItem: string;
  I: Integer;
begin
  LAuthRequest := THorseOAuth2.DefaultOAuth2AuthServer.ValidateAuthorizationRequest(AReq.RawWebRequest);
  try

    LScopes := ParseScopes(LAuthRequest);

    LRecord := TOAuth2TokenService.FindValidToken(AReq.Session<TJSONObject>.GetValue<string>('sub'), LAuthRequest.GetClient.GetIdentifier);
    try
      if LRecord <> nil then
      begin
        while not LRecord.Eof do
        begin
          if (ContainsScopesInArray(LRecord.FieldByName('scopes').AsString.Split([' ']), LScopes)) or (TOAuth2ClientService.SkipsAuthorization) then
          begin
            ApproveRequest(LAuthRequest, AReq.Session<TJSONObject>.GetValue<string>('sub'), ARes.RawWebResponse);
            ARes.RawWebResponse.SendResponse;
            Exit;
          end;
          LRecord.Next;
        end;
      end;

      LAuthToken := THash.GetRandomString(16);

      LSessionKey := TOAuth2RedisSessionProvider.NewSession;
      LSessionValue := TJSONObject.Create;
      try
        LSessionValue.AddPair('auth_token', LAuthToken);
        LSessionValue.AddPair('auth_request', LAuthRequest.ToJSON);
        TOAuth2RedisSessionProvider.SetSession(LSessionKey, LSessionValue);
        ARes.RawWebResponse.SetCustomHeader('Set-Cookie', Format('horse_session=%s', [LSessionKey]));
        if Length(LAuthRequest.GetScopes) > 0 then
        begin
          LScopeFragment := OAUTH_HTML_AUTH_SCOPE_FRAGMENT;
          LScopeItems := '';
          for I := Low(LAuthRequest.GetScopes) to High(LAuthRequest.GetScopes) do
          begin
            LScopeItem := OAUTH_HTML_AUTH_SCOPE_ITEM.Replace('%SCOPE_DESCRIPTION%', TOAuth2ScopeService.GetScopeDescription(LAuthRequest.GetScopes[I].GetIdentifier));
            LScopeItems := LScopeItems + LScopeItem;
          end;
          LScopeFragment := LScopeFragment.Replace('%SCOPES_BOX%', LScopeItems);
        end;
        LHtmlAuth := OAUTH_HTML_AUTH;
        LHtmlAuth := LHtmlAuth.Replace('%STATE%', LAuthRequest.GetState);
        LHtmlAuth := LHtmlAuth.Replace('%APP_NAME%', LAuthRequest.GetClient.GetName);
        LHtmlAuth := LHtmlAuth.Replace('%AUTH_TOKEN%', LAuthToken);
        LHtmlAuth := LHtmlAuth.Replace('%SCOPES_FRAGMENT%', LScopeFragment);
        LHtmlAuth := LHtmlAuth.Replace('%APPLICATION_NAME%', TOAuth2ServerConfig.GetApplicationName);
        ARes.Send(LHtmlAuth).ContentType('text/html').Status(THTTPStatus.OK);
      finally
        LSessionValue.Free;
      end;
    finally
      LRecord.Free;
    end;
  finally
    LAuthRequest.Free;
  end;
end;

class function TOAuth2AuthorizationController.ContainsScopesInArray(AScopesL, AScopesR: TArray<string>): Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := Low(AScopesL) to High(AScopesL) do
  begin
    Result := IndexStr(AScopesL[I], AScopesR) > -1;
    if not Result then
      Break;
  end;
  for I := Low(AScopesR) to High(AScopesR) do
  begin
    Result := IndexStr(AScopesR[I], AScopesL) > -1;
    if not Result then
      Break;
  end;
end;

class function TOAuth2AuthorizationController.ParseScopes(AAuthRequest: TOAuth2AuthorizationRequest): TArray<string>;
var
  I: Integer;
begin
  Result := [];
  for I := Low(AAuthRequest.GetScopes) to High(AAuthRequest.GetScopes) do
    Result := Result + [AAuthRequest.GetScopes[I].GetIdentifier];
end;

end.
