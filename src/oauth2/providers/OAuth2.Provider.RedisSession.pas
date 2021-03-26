unit OAuth2.Provider.RedisSession;

interface

uses
  System.JSON;

type

  TOAuth2RedisSessionProvider = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class function NewSession: string;
    class procedure SetSession(AKey: string; AJSONObject: TJSONObject; const ASecsExpire: UInt64 = 86400);
    class function GetSession(AKey: string): TJSONObject;
    class procedure Forgot(AKey: string);
  end;

implementation

uses
  System.SysUtils,
  RedisConnection.Provider,
  Redis.Config,
  Redis.Commons,
  Redis.Values,
  GUIDGenerator.Provider;

const

  REDIS_SESSION_KEY = 'oauth2.session.%s';

  { TOAuth2RedisSessionProvider }

class function TOAuth2RedisSessionProvider.NewSession: string;
begin
  Result := TGUIDGeneratorProvider.New.SetWithoutBraces.Generate;
end;

class procedure TOAuth2RedisSessionProvider.Forgot(AKey: string);
var
  LRedis: IRedisClient;
begin
  LRedis := TRedisConnectionProvider.NewConnection;
  LRedis.Connect;
  LRedis.DEL([Format(REDIS_SESSION_KEY, [AKey])])
end;

class function TOAuth2RedisSessionProvider.GetSession(AKey: string): TJSONObject;
var
  LRedis: IRedisClient;
  LRedisString: TRedisString;
  LJSONObjectSession: TJSONObject;
begin
  LJSONObjectSession := nil;
  LRedis := TRedisConnectionProvider.NewConnection;
  try
    LRedis.Connect;
    LRedisString := LRedis.GET(Format(REDIS_SESSION_KEY, [AKey]));
    if not LRedisString.IsNull then
      LJSONObjectSession := TJSONObject(TJSONObject.ParseJSONValue(LRedisString.Value));
  finally
    Result := LJSONObjectSession;
  end;
end;

class procedure TOAuth2RedisSessionProvider.SetSession(AKey: string; AJSONObject: TJSONObject; const ASecsExpire: UInt64 = 86400);
var
  LRedis: IRedisClient;
begin
  LRedis := TRedisConnectionProvider.NewConnection;
  LRedis.Connect;
  LRedis.&SET(Format(REDIS_SESSION_KEY, [AKey]), AJSONObject.ToString, ASecsExpire);
end;

end.
