unit OAuth2.Middleware.AuthorizationServer;

interface

uses

  Horse;

type

  TOAuth2MiddlewareAuthorizationServer = class
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
  System.SysUtils;

{ TOAuth2MiddlewareAuthorizationServer }

class procedure TOAuth2MiddlewareAuthorizationServer.Invoke(AReq: THorseRequest; ARes: THorseResponse; ANext: TNextProc);
var
  LOAuth2ServerException: EOAuth2ServerException;
begin
  try
    THorseOAuth2.DefaultOAuth2AuthServer.RespondToAccessTokenRequest(AReq.RawWebRequest, ARes.RawWebResponse);
    ANext();
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
