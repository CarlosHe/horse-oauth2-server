unit OAuth2.Repository.Scope;

interface

uses
  OAuth2.Entity.Client.Contract,
  OAuth2.Entity.Scope.Contract,
  OAuth2.Repository.Scope.Contract;

type

  TOAuth2ScopeRepository = class(TInterfacedObject, IOAuth2ScopeRepository)
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    function GetScopeEntityByIdentifier(AIdentifier: string): IOAuth2ScopeEntity;
    function FinalizeScopes(AScopes: TArray<IOAuth2ScopeEntity>; AGrantType: string; AClientEntity: IOAuth2ClientEntity; const AUserIdentifier: string = '')
      : TArray<IOAuth2ScopeEntity>;
    class function New: IOAuth2ScopeRepository;
  end;

implementation

uses
  OAuth2.Entity.Scope,
  OAuth2.Service.Scope,
  System.SysUtils,
  System.StrUtils;

{ TOAuth2ScopeRepository }

function TOAuth2ScopeRepository.FinalizeScopes(AScopes: TArray<IOAuth2ScopeEntity>; AGrantType: string; AClientEntity: IOAuth2ClientEntity;
  const AUserIdentifier: string): TArray<IOAuth2ScopeEntity>;
var
  I: Integer;
begin
  for I := Low(AScopes) to High(AScopes) do
    if TOAuth2ScopeService.HasScope(AScopes[I].GetIdentifier) then
      Result := Result + [AScopes[I]];
end;

function TOAuth2ScopeRepository.GetScopeEntityByIdentifier(AIdentifier: string): IOAuth2ScopeEntity;
begin
  if TOAuth2ScopeService.HasScope(AIdentifier) then
    Result := TOAuth2ScopeEntity.Create(AIdentifier);
end;

class function TOAuth2ScopeRepository.New: IOAuth2ScopeRepository;
begin
  Result := TOAuth2ScopeRepository.Create;
end;

end.
