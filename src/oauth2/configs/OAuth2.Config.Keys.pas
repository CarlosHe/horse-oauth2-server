unit OAuth2.Config.Keys;

interface

type

  TOAuth2KeysConfig = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class function GetPublicKey: string;
    class function GetPrivateKey: string;
    class function GetEncryptionKey: string;
  end;

implementation

uses
  System.SysUtils;

{ TOAuth2KeysConfig }

class function TOAuth2KeysConfig.GetEncryptionKey: string;
begin
  Result := GetEnvironmentVariable('ENCRYPTION_KEY');
  if Result.IsEmpty then
    Result := '84F19B3D613C4FEBB66F248C0B6EADA2';
end;

class function TOAuth2KeysConfig.GetPrivateKey: string;
begin
  Result := GetEnvironmentVariable('PUBLIC_KEY');
  if Result.IsEmpty then
    Result :=
      '-----BEGIN RSA PRIVATE KEY-----'#10 +
      'MIIEowIBAAKCAQEA3+fRbSnigY+ibVisHjAc/3nyv23y4kC4pCoyDWcX9jWqb3m0'#10 +
      '4L9SGZv3Fi9PTHNtMvox9ITeLDnAAxHe/hX7/ucoNu5fnCupesosOPOsE0oqshI6'#10 +
      '58hWNK+xMHcY/ObhTVFj9ycsN3H9GaDykB4Id8Kuw7iUuELDN6UVU/mHw+Cm41Nm'#10 +
      'xBNC4urMWbMcNNZ6VinQhQo+Th9uMDZhe9s4i6xuxWKeSWTLbSjJFndxUEQmiC+l'#10 +
      '2nL3wBYp7xby0pf5isG22OIgYmVNUBALiA4730vCT3nHn768eAzOmTs+wmXbDj8b'#10 +
      'HQwmGrYqxA5agQGcAxnU4xZIoLJtKmpd/8minwIDAQABAoIBAFMvMOM5mGlCD7pI'#10 +
      'I0nj3iIcEE+GbaIZIX/8HTRVhNV4AqX/tW96JOpWw2l+kht5FqzFvyF064XKvsdl'#10 +
      'ME99o22EO7CMxwCiSAjSa7OM8/UGrO4TT8ck6sIQM+gplyL+M94hyt3bs9W1h66p'#10 +
      '2PQp9ENqFLuqK7Z5N0XJEy9rmUDv15julC50ft2Q5uBqw+5XYaWzKJbgV8BNceob'#10 +
      'rW6esFIw1sWfwgEpmhLIL1f66saxEJoqYdoszcO0Gtt9Qpnc+Q5OxR5ihY7MBLtF'#10 +
      'TvrrQ7pMzefL+B0E0ixEeLRpcia9YQsebZ5RKj0k9MPhwHL6TnF6JJ3E+34pH3Yc'#10 +
      'd/GYDcECgYEA9lbIhG9bhqG/l9+uk0PGP9toTXxglWSdziWa8yS4PmezBESJv4xH'#10 +
      'TToBSFBoa6Y+WghARbrfvmvoysMi2FCebIHw8pjHjAAW4SuQLoWc8FZ3n0yWj7N/'#10 +
      'qSkHs6VjeGlT4A+TEfweTogcA2HH70sSKbd+x9TZJi5sWPB+S1zeQRkCgYEA6K/O'#10 +
      'KdESmzfgbFs2/93kiBAiImhqlsdiu2zVz404b+631tufC7rZKJwwRULxmGz1MZzL'#10 +
      '9qOQR9VFp1hyzIBhkaBOWre3nteg29pftU40lEbAc7ZISDA+ExZB6MT4DCkL16lt'#10 +
      'qFkWdpC30237gxdfg1SkSA/yQpY50ss6so6QYHcCgYEA1zdgvluv4gLkqeJx2hVn'#10 +
      'Whjtmmzk0QBz4kv2gSD+mv7sZvkeQ6xiCvV3c19Uq2A1r2DwDjvDCNGsM6Giisx8'#10 +
      'bJ5mDP0vsX/OfXEa6ZowT8WrgxBdpjSTfw3qvafsLKIQ9nuE6TyUmdXOa6H9FHJI'#10 +
      '7wtyh1HNWc9LN7T9EgiT4NkCgYAivq2wPNHkb5GJXI1343BOiOov7RuNbDRn/DZp'#10 +
      'CZNV03WMFbtICxyGHdxvWzGsKwjp4ZnrOD1BHK2L8X8i3kCzeBZ7IVe/1j7k1VTZ'#10 +
      'Q9ZCFdaC8MMWVG3Qd9Bbq53GYxKrn1cKflMGXVG1toSJ7KGMgMUPJaJtIvV7bnFT'#10 +
      'XEpevQKBgDcDQx/oZKj5rwuLFOQo7Ndzxns7MBD6rFRgIk6E/xJQjV4As/tgvC6A'#10 +
      'k/KGFIXwMpmNyxfvj53Dy+AA+JebTmlovKO/3a95P8uMOg5OxEqdmneULtVZ5JKG'#10 +
      'WUj0YZmFjTaRYUxcMba1qn4fOsv7fbk7VZ1lCSPWVjQ52XXB/sbN'#10 +
      '-----END RSA PRIVATE KEY-----'#10;
end;

class function TOAuth2KeysConfig.GetPublicKey: string;
begin
  Result := GetEnvironmentVariable('PRIVATE_KEY');
  if Result.IsEmpty then
    Result :=
      '-----BEGIN PUBLIC KEY-----'#10 +
      'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA3+fRbSnigY+ibVisHjAc'#10 +
      '/3nyv23y4kC4pCoyDWcX9jWqb3m04L9SGZv3Fi9PTHNtMvox9ITeLDnAAxHe/hX7'#10 +
      '/ucoNu5fnCupesosOPOsE0oqshI658hWNK+xMHcY/ObhTVFj9ycsN3H9GaDykB4I'#10 +
      'd8Kuw7iUuELDN6UVU/mHw+Cm41NmxBNC4urMWbMcNNZ6VinQhQo+Th9uMDZhe9s4'#10 +
      'i6xuxWKeSWTLbSjJFndxUEQmiC+l2nL3wBYp7xby0pf5isG22OIgYmVNUBALiA47'#10 +
      '30vCT3nHn768eAzOmTs+wmXbDj8bHQwmGrYqxA5agQGcAxnU4xZIoLJtKmpd/8mi'#10 +
      'nwIDAQAB'#10 +
      '-----END PUBLIC KEY-----'#10;
end;

end.
