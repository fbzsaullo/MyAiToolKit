# Perfil de stack — .NET

Segue o contrato de `stacks/README.md`. Cobre ASP.NET Core, workers e bibliotecas em C#/F#.

## 1. Sinais de detecção

| Sinal | Significa |
| --- | --- |
| `*.sln`/`*.slnx`, `*.csproj`, `*.fsproj` | Projeto .NET |
| `Microsoft.NET.Sdk.Web` no `.csproj` | ASP.NET Core |
| `Microsoft.NET.Sdk.Worker` | Worker service |
| vários projetos (`*.Domain`, `*.Application`, `*.Infrastructure`, `*.Api`) | Arquitetura em camadas por projeto |
| `*.Tests.csproj` com xUnit/NUnit/MSTest | Projetos de teste |

## 2. Fontes de versão

| O quê | Onde |
| --- | --- |
| SDK | `global.json` |
| Framework alvo | `<TargetFramework>` em cada `.csproj` (ex.: `net8.0`) |
| Pacotes | `<PackageReference>`, `Directory.Packages.props` (gestão central), `packages.lock.json` |
| Configuração comum | `Directory.Build.props` (nullable, warnings como erro, versão da linguagem) |

## 3. Orientações por versão

- Versões **LTS** (pares) são as recomendadas para produção; as STS têm suporte mais curto. Confira a política oficial (seção 10) e reporte a situação do `TargetFramework`.
- `Nullable` desligado e `TreatWarningsAsErrors` ausente são recomendações frequentes.
- Projetos em .NET Framework (4.x) são legado: registre isso como restrição e evite APIs que só existem no .NET moderno.

## 4. Comandos

`dotnet build`, `dotnet test`, `dotnet run --project <caminho real>`, `dotnet format`, `dotnet watch`. Migrations com EF Core (só se houver `Microsoft.EntityFrameworkCore.Design`): `dotnet ef migrations add <Nome> --project <...> --startup-project <...>` — os caminhos precisam vir da estrutura real. Com vários projetos, aponte para a `.sln`.

## 5. Testes

xUnit, NUnit ou MSTest; FluentAssertions/Shouldly; Testcontainers ou `WebApplicationFactory` para integração.

**Convenção de nome para `CA-XX`:** nome de método não aceita hífen:

```csharp
[Fact]
public async Task CA_05_Dois_pacientes_disputam_o_ultimo_horario() { /* ... */ }
```

Opcional, para filtrar: `[Trait("CA", "CA-05")]`. `testing.ca_naming.pattern`: `CA_XX_<Descricao>`; `grep`: `CA_[0-9]{2}`.

## 6. Qualidade e segurança

Analisadores do SDK (`<AnalysisLevel>`), `dotnet format`, StyleCop/SonarAnalyzer, `dotnet list package --vulnerable`, Security Code Scan.

## 7. Convenções a observar no código

- divisão em projetos/camadas e regras de referência entre eles;
- mediador (MediatR ou chamadas diretas), validação (FluentValidation, DataAnnotations);
- padrão de erro (exceções de negócio × `Result`);
- acesso a dados (EF Core, Dapper) e se o `DbContext`/`IQueryable` pode sair da camada de infraestrutura;
- Minimal APIs × controllers;
- logging (Serilog, `ILogger`) e dados pessoais em log.

## 8. Segredos

`appsettings.Production.json` e `appsettings.*.Production.json` com valores reais, `secrets.json` (User Secrets), `*.pfx`/`*.p12` (já no bloqueio universal).

## 9. Arquivos complementares

`permissions.md` ✅. Demais: material agnóstico e `_generic`.

## 10. Referências oficiais

- Política de suporte do .NET: https://dotnet.microsoft.com/platform/support/policy/dotnet-core
- Segurança no ASP.NET Core: https://learn.microsoft.com/aspnet/core/security/
