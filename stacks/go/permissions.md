# Permissões — Go

Formato do Claude Code; o `sdd-setup` traduz para o Codex.

```jsonc
{
  "permissions": {
    "allow": [
      "Bash(go build *)",
      "Bash(go test *)",
      "Bash(go run *)",
      "Bash(go vet *)",
      "Bash(gofmt *)",
      "Bash(go fmt *)",
      "Bash(go list *)",
      "Bash(golangci-lint run *)",
      "Bash(govulncheck *)",
      "Bash(make test *)",
      "Bash(make lint *)"
    ],
    "ask": [
      "Bash(go get *)",
      "Bash(go install *)",
      "Bash(go mod tidy *)",
      "Bash(migrate *)"
    ],
    "deny": []
  }
}
```

## Notas

- `go run` liberado porque executa o código do próprio projeto; se o projeto tem `cmd/` que mexe em dados reais (ferramentas administrativas), mova para `ask`.
- `go get`/`go install` perguntam: trazem código de fora.
- Alvos de `Makefile` só entram se existirem — e cuidado com alvos como `make deploy` ou `make migrate`, que vão para `ask`.
