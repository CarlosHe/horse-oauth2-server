unit OAuth2.Middleware.CookieToken;

interface

uses

  Horse;

type

  TOAuth2MiddlewareCookieToken = class
  private
    { private declarations }
  protected
    { protected declarations }
    class function GetNextUri(AReq: THorseRequest): string;
  public
    { public declarations }
    class procedure Invoke(AReq: THorseRequest; ARes: THorseResponse; ANext: TNextProc);
  end;

implementation

uses
  Horse.OAuth2.Singleton,
  JOSE.Core.JWT,
  JOSE.Core.Base,
  JOSE.Core.Builder,
  JOSE.Consumer,
  JOSE.Core.JWK,
  JOSE.Context,
  JOSE.Core.JWS,
  OAuth2.Exception.ServerException,
  OAuth2.Provider.RedisSession,
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.Hash,
  System.NetEncoding;

{ TOAuth2MiddlewareAuth }

class function TOAuth2MiddlewareCookieToken.GetNextUri(AReq: THorseRequest): string;
var
  LUri: string;
begin
  LUri := AReq.RawWebRequest.PathInfo;
  if not AReq.RawWebRequest.Query.IsEmpty then
    LUri := LUri + '?' + AReq.RawWebRequest.Query;
  LUri := TURLEncoding.URL.Encode(LUri);
  Result := Format('%s', [LUri]);
end;

class procedure TOAuth2MiddlewareCookieToken.Invoke(AReq: THorseRequest; ARes: THorseResponse; ANext: TNextProc);
var
  LJWT: string;
  LSigner: TJWS;
  LToken: TJWT;
  LJWK: TJWK;
  LValidations: IJOSEConsumer;
  LJWTContext: TJOSEContext;
  LValidationErro: string;
  LSessionKey: string;
  LSessionValue: TJSONObject;
  LRedirectUri: string;
  LAuthToken: string;
begin
  try
    if not AReq.Cookie.ContainsKey('horse_token') then
      raise EOAuth2ServerException.AccessDenied('Token not found');

    LJWT := AReq.Cookie.Items['horse_token'];

    try
      LJWTContext := TJOSEContext.Create(LJWT, TJWTClaims);
      try

        LValidations := TJOSEConsumerBuilder.NewConsumer
          .SetRequireJwtId
          .SetSkipVerificationKeyValidation
          .SetSkipSignatureVerification
          .SetSkipDefaultAudienceValidation
          .SetRequireExpirationTime
          .SetRequireIssuedAt
          .Build;
        try
          LValidations.ProcessContext(LJWTContext);
        except
          LValidationErro := 'the token has expired or the token id was not found';
        end;
      finally
        LJWTContext.Free;
      end;
    except
      LValidationErro := 'the token is in an invalid format';
    end;

    if not LValidationErro.IsEmpty then
      raise EOAuth2ServerException.AccessDenied(Format('The access token could not be verified because %s', [LValidationErro]));

    LToken := TJWT.Create;
    try
      LJWK := TJWK.Create(THorseOAuth2.DefaultPublicKey.GetKey);
      try
        LSigner := TJWS.Create(LToken);
        try
          LSigner.SkipKeyValidation := True;
          LSigner.SetKey(LJWK);
          LSigner.CompactToken := LJWT;
          LSigner.SetHeaderAlgorithm('RS256');
          try
            LSigner.VerifySignature;
          except

          end;
        finally
          LSigner.Free;
        end;
      finally
        LJWK.Free;
      end;

      if not LToken.Verified then
        raise EOAuth2ServerException.AccessDenied('Access token could not be verified');

      if THorseOAuth2.DefaultOAuth2AccessTokenRepository.IsAccessTokenRevoked(LToken.Claims.JWTId) then
        raise EOAuth2ServerException.AccessDenied('Access token has been revoked');

      LJWTContext := TJOSEContext.Create(LJWT, TJWTClaims);
      try
        AReq.Session(LJWTContext.GetClaims.Clone as TJSONObject);
        try
          ANext();
        finally
          AReq.Session<TJSONObject>.Free;
        end;
      finally
        LJWTContext.Free;
      end;

    finally
      LToken.Free;
    end;
  except
    LAuthToken := THash.GetRandomString(16);
    LSessionKey := TOAuth2RedisSessionProvider.NewSession;
    LRedirectUri := '/oauth2/login?next=' + GetNextUri(AReq);
    LSessionValue := TJSONObject.Create;
    try
      LSessionValue.AddPair('redirect_uri', LRedirectUri);
      LSessionValue.AddPair('auth_token', LAuthToken);
      TOAuth2RedisSessionProvider.SetSession(LSessionKey, LSessionValue);
      ARes.RawWebResponse.SetCustomHeader('Set-Cookie', Format('horse_session=%s', [LSessionKey]));
    finally
      LSessionValue.Free;
    end;
    ARes.RawWebResponse.SendRedirect(LRedirectUri);
    ARes.RawWebResponse.SendResponse;
    raise EHorseCallbackInterrupted.Create;
  end;
end;

end.
