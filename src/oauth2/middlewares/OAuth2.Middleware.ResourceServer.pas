unit OAuth2.Middleware.ResourceServer;

interface

uses

  Horse;

type

  TOAuth2MiddlewareResourceServer = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class procedure Invoke(AReq: THorseRequest; ARes: THorseResponse; ANext: TNextProc);
  end;

implementation

uses
  Horse.OAuth2.Singleton,
  OAuth2.Exception.ServerException,
  System.RegularExpressions,
  System.SysUtils,
  System.JSON,
  JOSE.Context,
  JOSE.Core.JWT;

{ TOAuth2MiddlewareResourceServer }

class procedure TOAuth2MiddlewareResourceServer.Invoke(AReq: THorseRequest; ARes: THorseResponse; ANext: TNextProc);
var
  LOAuth2ServerException: EOAuth2ServerException;
  LHeader: string;
  LJWT: string;
  LJWTContext: TJOSEContext;
begin
  try
    THorseOAuth2.DefaultOAuth2ResourceServer.ValidateAuthenticatedRequest(AReq.RawWebRequest);

    LHeader := AReq.RawWebRequest.Authorization;
    LJWT := TRegEx.Replace(LHeader, '^(?:\s+)?bearer\s', '', [TRegExOption.roIgnoreCase]);
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

  except
    on E: EHorseCallbackInterrupted do
      raise;
    on E: EOAuth2ServerException do
    begin
      E.GenerateHttpResponse(ARes.RawWebResponse);
      raise EHorseCallbackInterrupted.Create;
    end;
    on E: Exception do
    begin
      LOAuth2ServerException := EOAuth2ServerException.Create(E.Message, 0, 'unknown_error', 500, EmptyStr, EmptyStr);
      try
        LOAuth2ServerException.GenerateHttpResponse(ARes.RawWebResponse);
      finally
        LOAuth2ServerException.Free;
      end;
      raise EHorseCallbackInterrupted.Create;
    end;

  end;

end;

end.
