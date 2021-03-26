unit Horse.OAuth2.Routers;

interface

type

  THorseOAuth2Routers = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class
      procedure Register;
  end;

implementation

uses
  Horse,
  OAuth2.Controller.Authorization,
  OAuth2.Controller.ReadAuthorization,
  OAuth2.Controller.AccessToken,
  OAuth2.Controller.AuthorizedAccessToken,
  OAuth2.Controller.Client,
  OAuth2.Controller.LoginProxy,
  OAuth2.Middleware.ServerException,
  OAuth2.Middleware.AuthorizationServer,
  OAuth2.Middleware.ResourceServer,
  OAuth2.Middleware.CookieToken,
  System.Hash;

{ THorseOAuth2Routers }

class procedure THorseOAuth2Routers.Register;
begin
  THorse
    .Use(TOAuth2MiddlewareServerException.Invoke)
    .Group.Prefix('/oauth2')
    .Post('/login', TOAuth2LoginProxyController.Login)
    .Get('/login', TOAuth2LoginProxyController.Page)
    .Get('/authorize', TOAuth2MiddlewareCookieToken.Invoke, TOAuth2AuthorizationController.Authorize)
    .Post('/read', TOAuth2MiddlewareCookieToken.Invoke, TOAuth2ReadAuthorizationController.Read)
    .Post('/token', TOAuth2AccessTokenController.IssueToken)
    .Get('/tokens', TOAuth2MiddlewareResourceServer.Invoke, TOAuth2AuthorizedAccessTokenController.ForUser)
    .Delete('/tokens/:token_id', TOAuth2MiddlewareResourceServer.Invoke, TOAuth2AuthorizedAccessTokenController.Delete)
    .Get('/clients', TOAuth2MiddlewareResourceServer.Invoke, TOAuth2ClientController.ForUser)
    .Post('/clients', TOAuth2MiddlewareResourceServer.Invoke, TOAuth2ClientController.Store)
    .Put('/clients/:client_id', TOAuth2MiddlewareResourceServer.Invoke, TOAuth2ClientController.Update)
    .Delete('/clients/:client_id', TOAuth2MiddlewareResourceServer.Invoke, TOAuth2ClientController.Delete);

end;

end.
