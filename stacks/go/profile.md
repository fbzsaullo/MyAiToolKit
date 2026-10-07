# Perfil de stack — Go

Segue o contrato de `stacks/README.md`.

## 1. Sinais de detecção

| Sinal | Significa |
| --- | --- |
| `go.mod` | Módulo Go |
| `go.work` | Workspace com vários módulos |
| `cmd/<nome>/main.go` | Executáveis do projeto |
| `internal/` | Pacotes privados ao módulo |

## 2. Fontes de versão

| O quê | Onde |
| --- | --- |
| Go | diretiva `go 1.x` e `toolchain` no `go.mod`; `.tool-versions`; `Dockerfile` |
| Dependências | `go.mod` (versões exigidas) + `go.sum` |

## 3. Orientações por versão

- O Go mantém as duas versões mais recentes; confira a política oficial (seção 10).
- Versões recentes trouxeram genéricos, `log/slog` (logs estruturados), roteamento com métodos e curingas no `net/http`, e iteradores (`range` sobre funções). Recomende quando o projeto usa dependências só para isso.

## 4. Comandos

`go build ./...`, `go test ./...` (`-race` quando concorrência é central), `go run ./cmd/<nome>` (caminho real), `go vet ./...`, `gofmt`/`goimports`, `golangci-lint run` (só com `.golangci.yml`). Muitos projetos usam `Makefile` — ele tem precedência.

## 5. Testes

Pacote `testing`, testes em tabela, `testify` opcional, `httptest`.

**Convenção de nome para `CA-XX`:** função sem hífen; em testes de tabela, o ID vai no nome do caso:

```go
func TestCA05_DoisPacientesDisputamOUltimoHorario(t *testing.T) { /* ... */ }

// ou em tabela
{name: "CA-05: dois pacientes disputam o último horário", ...}
```

`testing.ca_naming.pattern`: `TestCAXX_<Descricao>` ou caso `"CA-XX: ..."`; `grep`: `CA-?[0-9]{2}`.

## 6. Qualidade e segurança

`go vet`, golangci-lint, staticcheck, `govulncheck` (vulnerabilidades com análise de alcance), gosec.

## 7. Convenções a observar no código

Estrutura de pacotes (`cmd/`, `internal/`, por domínio), tratamento de erro (`errors.Is/As`, erros sentinela, *wrapping* com `%w`), uso de `context.Context`, injeção de dependências por interfaces pequenas, acesso a dados (`database/sql`, sqlc, GORM).

## 8. Segredos

`.env*` e chaves já no bloqueio universal; arquivos de config com credenciais (ex.: `config/*.yaml` de produção) — perguntar ao usuário.

## 9. Arquivos complementares

`permissions.md` ✅. Demais: material agnóstico e `_generic`.

## 10. Referências oficiais

- Política de versões: https://go.dev/doc/devel/release
- govulncheck: https://go.dev/doc/security/vuln/
