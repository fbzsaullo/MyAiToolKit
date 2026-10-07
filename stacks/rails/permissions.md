# Permissões — Ruby on Rails

Receita no formato do Claude Code. O `sdd-setup` soma isto ao bloqueio universal, às regras de git e (se houver) às de Docker de `skills/sdd-setup/references/permission-principles.md`, e traduz para o Codex pela tabela de lá.

**Ajuste ao projeto:** inclua só os comandos que existem (`bin/rubocop` existe? o projeto usa RSpec ou Minitest?). Regra para comando inexistente é ruído.

```jsonc
{
  "permissions": {
    "allow": [
      // testes
      "Bash(bundle exec rspec *)",
      "Bash(bin/rspec *)",
      "Bash(bin/rails test *)",
      "Bash(bin/ci *)",

      // qualidade e segurança (somente leitura do código)
      "Bash(bin/rubocop *)",
      "Bash(bundle exec rubocop *)",
      "Bash(bundle exec standardrb *)",
      "Bash(bin/brakeman *)",
      "Bash(bundle exec brakeman *)",
      "Bash(bundle exec bundler-audit *)",

      // inspeção que não altera nada
      "Bash(bin/rails routes *)",
      "Bash(bin/rails zeitwerk:check *)",
      "Bash(bin/rails db:migrate:status *)",
      "Bash(bin/rails about *)",
      "Bash(bundle list *)",
      "Bash(bundle check *)",

      // geradores (criam arquivos locais; revisáveis no diff)
      "Bash(bin/rails generate *)",
      "Bash(bin/rails g *)",

      // rodar local
      "Bash(bin/dev *)"
    ],
    "ask": [
      // dependências (cadeia de suprimentos)
      "Bash(bundle install *)",
      "Bash(bundle add *)",
      "Bash(bundle update *)",

      // banco — ver escolha "migrations" no setup (ask ou deny)
      "Bash(bin/rails db:migrate *)",
      "Bash(bin/rails db:rollback *)",
      "Bash(bin/rails db:prepare *)",
      "Bash(bin/rails db:seed *)",
      "Bash(bin/setup *)",

      // executa código arbitrário
      "Bash(bin/rails runner *)",

      // deploy
      "Bash(bin/kamal *)",
      "Bash(kamal *)"
    ],
    "deny": [
      // segredos do Rails
      "Read(config/master.key)",
      "Read(config/credentials/*.key)",
      "Read(**/config/master.key)",
      "Read(.kamal/secrets*)",
      "Bash(bin/rails credentials:show *)",
      "Bash(bin/rails credentials:edit *)",

      // destrói dados
      "Bash(bin/rails db:drop *)",
      "Bash(bin/rails db:reset *)",
      "Bash(bin/rails db:migrate:reset *)",
      "Bash(bin/rails db:schema:load *)",
      "Bash(bin/rails db:purge *)",
      "Bash(bin/rails db:truncate_all *)",
      "Bash(bin/rails db:system:change *)",

      // publicação
      "Bash(gem push *)",
      "Bash(bundle exec rake release *)"
    ]
  }
}
```

## Notas de calibragem

- **Testes, lint e Brakeman liberados:** só leem o código (o lint com `-a` altera arquivos, mas localmente e de forma revisável no diff).
- **Geradores liberados:** criam arquivos locais que aparecem no diff. Se o time preferir revisar antes, mova para `ask`.
- **`bundle install`/`add`/`update` perguntam:** instalar gem nova é vetor real de ataque de cadeia de suprimentos.
- **Migrations:** a escolha do setup decide — `ask` (padrão) ou `deny` (só manualmente). `db:migrate:status` é leitura e fica liberado; atenção: `Bash(bin/rails db:migrate *)` no `ask` **não** sombreia `db:migrate:status`, porque depois de `db:migrate` vem `:`, não espaço.
- **`bin/rails runner` pergunta:** executa qualquer código Ruby com o app carregado.
- **`bin/setup` pergunta:** costuma rodar `db:prepare` e pode reinstalar dependências.
- **`credentials:show`/`edit` bloqueados:** imprimem ou abrem os segredos decifrados — equivalem a ler a `master.key`.
- **`db:drop`, `db:reset`, `db:schema:load`, `db:purge`, `db:truncate_all` bloqueados:** apagam dados sem volta. Bloqueio, não pergunta: a confirmação vira reflexo.
- **Console (`bin/rails console`)** não entra em nenhuma lista: é interativo e o agente não deve depender dele. Sem regra, o Claude Code pergunta.
- **Projetos com `rake` direto** (`bundle exec rake db:migrate`) precisam das mesmas regras com o prefixo `bundle exec rake` — inclua se o projeto usa essa forma.

## Conferência de sombra

- `Bash(bin/rails db:migrate *)` (ask) × `Bash(bin/rails db:migrate:status *)` (allow) → **sem conflito** (o espaço depois de `db:migrate` não casa `:status`).
- Pelo mesmo motivo, `db:migrate *` **não** cobre `db:migrate:reset` (apaga e recria o banco) — por isso ele tem bloqueio próprio no `deny`. Ao acrescentar regras, lembre que cada tarefa `db:xxx:yyy` é um comando diferente para o casamento.
- `Bash(bin/rails generate *)` (allow) não conflita com nenhuma regra de `ask`/`deny`.
- Se o time colocar `Bash(bin/rails *)` em `ask`, **todas** as regras `bin/rails ...` do `allow` viram código morto — evite regras largas assim.
