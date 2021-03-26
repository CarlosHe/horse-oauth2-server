unit OAuth2.Controller.AccessToken;

interface

uses

  Horse;

type

  TOAuth2AccessTokenController = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class procedure IssueToken(AReq: THorseRequest; ARes: THorseResponse; ANext: TNextProc);
  end;

implementation

uses
  Horse.OAuth2.Singleton;

{ TOAuth2AccessTokenController }

class procedure TOAuth2AccessTokenController.IssueToken(AReq: THorseRequest; ARes: THorseResponse; ANext: TNextProc);
begin
  THorseOAuth2.DefaultOAuth2AuthServer.RespondToAccessTokenRequest(AReq.RawWebRequest, ARes.RawWebResponse)
end;

end.
