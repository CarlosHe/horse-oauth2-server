unit OAuth2.Service.Scope;

interface

type

  TOAuth2ScopeService = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class function HasScope(AScope: string): Boolean;
    class function GetScopeDescription(AScope: string): string;
  end;

implementation

uses
  System.SysUtils,
  System.StrUtils;

var
  OAUTH2_SCOPES: array of string = ['*', 'public_profile'];

  OAUTH2_SCOPES_DESCRIPTIONS: array of string = ['Full access', 'Access your public profile'];

  { TOAuth2UserService }

class function TOAuth2ScopeService.GetScopeDescription(AScope: string): string;
begin
  if HasScope(AScope) then
  begin
    Result := OAUTH2_SCOPES[IndexStr(AScope, OAUTH2_SCOPES)];
    if Length(OAUTH2_SCOPES) <= Length(OAUTH2_SCOPES_DESCRIPTIONS) then
    begin
      Result := OAUTH2_SCOPES_DESCRIPTIONS[IndexStr(AScope, OAUTH2_SCOPES)];
    end;
  end;
end;

class function TOAuth2ScopeService.HasScope(AScope: string): Boolean;
begin
  Result := (AScope.Trim = '*') or (IndexStr(AScope, OAUTH2_SCOPES) > -1);
end;

end.
