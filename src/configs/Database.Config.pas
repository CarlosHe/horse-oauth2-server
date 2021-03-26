unit Database.Config;

interface

uses
  System.SysUtils;

type

  TDatabaseConfig = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class function Driver: string;
    class function Host: string;
    class function Port: Word;
    class function Database: string;
    class function User: string;
    class function Password: string;
  end;

implementation

{ TDatabaseConfig }

class function TDatabaseConfig.Database: string;
begin
  Result := GetEnvironmentVariable('DB_DATABASE');
end;

class function TDatabaseConfig.Driver: string;
begin
  Result := GetEnvironmentVariable('DB_DRIVER');
end;

class function TDatabaseConfig.Host: string;
begin
  Result := GetEnvironmentVariable('DB_HOST');
end;

class function TDatabaseConfig.Password: string;
begin
  Result := GetEnvironmentVariable('DB_PASSWORD');
end;

class function TDatabaseConfig.Port: Word;
begin
  Result := StrToIntDef(GetEnvironmentVariable('DB_PORT'), 0);
end;

class function TDatabaseConfig.User: string;
begin
  Result := GetEnvironmentVariable('DB_USER');
end;

end.
