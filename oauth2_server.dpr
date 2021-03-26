program oauth2_server;

{$APPTYPE CONSOLE}

{$R *.res}


uses
  System.SysUtils,
  DataSet.Serialize.Config,
  Horse,
  Horse.Logger,
  Horse.Logger.Provider.Console,
  Horse.CORS,
  Horse.Jhonson,
  Horse.HealthCheck,
  Horse.HealthCheck.Ping in 'src\health-checkers\Horse.HealthCheck.Ping.pas',
  Ready.Controller in 'src\controllers\Ready.Controller.pas',
  Server.Consts in 'src\consts\Server.Consts.pas',
  OAuth2.Provider.RedisSession in 'src\oauth2\providers\OAuth2.Provider.RedisSession.pas',
  Redis.Connection in 'src\connection\Redis.Connection.pas',
  Database.Config in 'src\configs\Database.Config.pas',
  Redis.Config in 'src\configs\Redis.Config.pas',
  ServerPort.Config in 'src\configs\ServerPort.Config.pas',
  Horse.OAuth2.Singleton in 'src\oauth2\Horse.OAuth2.Singleton.pas',
  OAuth2.Repository.Client in 'src\oauth2\repositories\OAuth2.Repository.Client.pas',
  OAuth2.Repository.AccessToken in 'src\oauth2\repositories\OAuth2.Repository.AccessToken.pas',
  OAuth2.Repository.Scope in 'src\oauth2\repositories\OAuth2.Repository.Scope.pas',
  Horse.OAuth2.Routers in 'src\oauth2\Horse.OAuth2.Routers.pas',
  OAuth2.Controller.Client in 'src\oauth2\controllers\OAuth2.Controller.Client.pas',
  OAuth2.Controller.Authorization in 'src\oauth2\controllers\OAuth2.Controller.Authorization.pas',
  OAuth2.Controller.ReadAuthorization in 'src\oauth2\controllers\OAuth2.Controller.ReadAuthorization.pas',
  OAuth2.Controller.AccessToken in 'src\oauth2\controllers\OAuth2.Controller.AccessToken.pas',
  OAuth2.Controller.AuthorizedAccessToken in 'src\oauth2\controllers\OAuth2.Controller.AuthorizedAccessToken.pas',
  OAuth2.Repository.AuthCode in 'src\oauth2\repositories\OAuth2.Repository.AuthCode.pas',
  OAuth2.Repository.RefreshToken in 'src\oauth2\repositories\OAuth2.Repository.RefreshToken.pas',
  OAuth2.Middleware.ServerException in 'src\oauth2\middlewares\OAuth2.Middleware.ServerException.pas',
  OAuth2.Middleware.ResourceServer in 'src\oauth2\middlewares\OAuth2.Middleware.ResourceServer.pas',
  OAuth2.Middleware.AuthorizationServer in 'src\oauth2\middlewares\OAuth2.Middleware.AuthorizationServer.pas',
  OAuth2.Repository.User in 'src\oauth2\repositories\OAuth2.Repository.User.pas',
  OAuth2.Service.Client in 'src\oauth2\services\OAuth2.Service.Client.pas',
  FireDAC.Connection.PoolManager in 'src\connection\FireDAC.Connection.PoolManager.pas',
  OAuth2.Service.User in 'src\oauth2\services\OAuth2.Service.User.pas',
  OAuth2.Service.Scope in 'src\oauth2\services\OAuth2.Service.Scope.pas',
  OAuth2.Service.Token in 'src\oauth2\services\OAuth2.Service.Token.pas',
  OAuth2.Service.AuthCode in 'src\oauth2\services\OAuth2.Service.AuthCode.pas',
  OAuth2.Middleware.CookieToken in 'src\oauth2\middlewares\OAuth2.Middleware.CookieToken.pas',
  OAuth2.Service.RefreshToken in 'src\oauth2\services\OAuth2.Service.RefreshToken.pas',
  OAuth2.Config.Keys in 'src\oauth2\configs\OAuth2.Config.Keys.pas',
  OAuth2.Config.TTL in 'src\oauth2\configs\OAuth2.Config.TTL.pas',
  OAuth2.Controller.RetrievesAuthRequestFromSession in 'src\oauth2\controllers\OAuth2.Controller.RetrievesAuthRequestFromSession.pas',
  OAuth2.Controller.LoginProxy in 'src\oauth2\controllers\OAuth2.Controller.LoginProxy.pas',
  OAuth2.Static.Login in 'src\oauth2\statics\OAuth2.Static.Login.pas',
  OAuth2.Static.Auth in 'src\oauth2\statics\OAuth2.Static.Auth.pas',
  OAuth2.Config.Server in 'src\oauth2\configs\OAuth2.Config.Server.pas',
  OAuth2.Config.LoginProxy in 'src\oauth2\configs\OAuth2.Config.LoginProxy.pas',
  Horse.HealthCheck.Database in 'src\health-checkers\Horse.HealthCheck.Database.pas',
  Horse.HealthCheck.Redis in 'src\health-checkers\Horse.HealthCheck.Redis.pas';

begin
  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndLower;

  THorse.MaxConnections := 10000;
  THorse.ListenQueue := 200;

  THorseLoggerManager.RegisterProvider(
    THorseLoggerProviderConsole.New()
    );

  THorseHealthCheckManager
    .AddCheck<THorseHealthCheckDatabase>('database')
    .AddCheck<THorseHealthCheckRedis>('redis')
    .AddCheck<THorseHealthCheckPing>('ping');

  THorse
    .Use(THorseLoggerManager.HorseCallback)
    .Use(CORS)
    .Use(Jhonson)
    .Use('/healthcheck', [HorseHealthCheck]);

  TReadyController.Register;

  THorseOAuth2Routers.Register;

  THorse.Listen(TServerPortConfig.Port,
    procedure(AHorse: THorse)
    begin
      WriteLn(Format(sServerIsRunning, [THorse.Host, THorse.Port]));
    end);

end.
