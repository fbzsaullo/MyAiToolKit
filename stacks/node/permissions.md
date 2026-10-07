# Permissões — Node.js / TypeScript

Formato do Claude Code; o `sdd-setup` traduz para o Codex. Exemplo com **npm** — troque o prefixo pelo gerenciador do lockfile (`pnpm`, `yarn`, `bun`). Regra com o gerenciador errado nunca casa.

```jsonc
{
  "permissions": {
    "allow": [
      "Bash(npm run build *)",
      "Bash(npm run test *)",
      "Bash(npm test *)",
      "Bash(npm run lint *)",
      "Bash(npm run typecheck *)",
      "Bash(npm run dev *)",
      "Bash(npm ci *)",
      "Bash(npm ls *)",
      "Bash(npm audit *)"
    ],
    "ask": [
      "Bash(npm install *)",
      "Bash(npm i *)",
      "Bash(npm update *)",
      "Bash(npx *)",
      "Bash(npm run db:migrate *)"
    ],
    "deny": [
      "Bash(npm publish *)",
      "Read(**/.npmrc)",
      "Read(**/*-service-account*.json)"
    ]
  }
}
```

## Notas

- **Libere só os scripts que existem** no `package.json`.
- **`npx` pergunta sempre:** baixa e executa pacote arbitrário. Não crie exceções como `Bash(npx tsc *)` no `allow` — o `Bash(npx *)` do `ask` vence pela precedência e a exceção vira código morto. Para um `npx` frequente, crie um script (`"typecheck": "tsc --noEmit"`) e libere `npm run typecheck`.
- **`npm ci` liberado, `npm install` pergunta:** `ci` instala exatamente o lockfile; `install` pode trazer versões novas.
- **Migrations** (Prisma, Knex, TypeORM) seguem a escolha do setup (`ask` ou `deny`). Comandos destrutivos como `prisma migrate reset` e `prisma db push --force-reset` vão para `deny`.
- pnpm: `pnpm install`, `pnpm add`, `pnpm dlx` (equivalente ao `npx`) em `ask`; `pnpm publish` em `deny`.
