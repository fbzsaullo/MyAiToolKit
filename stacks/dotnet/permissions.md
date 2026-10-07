# Permissões — .NET

Formato do Claude Code; o `sdd-setup` traduz para o Codex.

```jsonc
{
  "permissions": {
    "allow": [
      "Bash(dotnet build *)",
      "Bash(dotnet test *)",
      "Bash(dotnet run *)",
      "Bash(dotnet restore *)",
      "Bash(dotnet format *)",
      "Bash(dotnet list package *)",
      "Bash(dotnet ef migrations list *)",
      "Bash(dotnet ef migrations script *)"
    ],
    "ask": [
      "Bash(dotnet add package *)",
      "Bash(dotnet ef migrations add *)",
      "Bash(dotnet ef migrations remove *)",
      "Bash(dotnet ef database update *)"
    ],
    "deny": [
      "Read(**/appsettings.Production.json)",
      "Read(**/appsettings.*.Production.json)",
      "Read(**/secrets.json)",
      "Bash(dotnet ef database drop *)",
      "Bash(dotnet nuget push *)"
    ]
  }
}
```

## Notas

- `migrations list` e `script` só leem → liberados. `add`, `remove` e `database update` alteram estado → perguntam (ou ficam bloqueados, conforme a escolha de migrations no setup).
- `database drop` é irreversível → bloqueado.
- `dotnet add package` pergunta: instalar pacote é vetor de cadeia de suprimentos.
- `secrets.json` (User Secrets) fica fora do repositório, mas é lido pela aplicação e guarda segredos reais.
