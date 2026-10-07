# Modelo — `docs/sdd/stack-report.md`

Relatório para pessoas: o que o setup encontrou, de onde tirou cada informação e o que recomenda. É regenerado a cada `refresh` (o anterior fica no histórico do git), então pode ser mais detalhado que o `AGENTS.md`.

> As quatro crases externas apenas delimitam o modelo.

---

````markdown
# Relatório de stack — [nome do projeto]

- **Gerado em:** AAAA-MM-DD, pelo `/sdd-setup` [modo]
- **Repositório:** [monorepo? quantas aplicações?]

## 1. O que foi encontrado

| Stack | Papel | Pasta | Perfil usado |
| --- | --- | --- | --- |
| Ruby on Rails | principal | `.` | `stacks/rails/profile.md` |
| Node.js | auxiliar (build de CSS) | `.` | `stacks/node/profile.md` |

### Versões

| Item | Versão | Origem | Observação |
| --- | --- | --- | --- |
| Ruby | 3.3.5 | `.ruby-version` | `Dockerfile` usa 3.3.5 ✅ |
| Rails | 8.0.1 | `Gemfile.lock` | — |
| Padrões do Rails (`load_defaults`) | 7.1 | `config/application.rb` | ⚠️ abaixo da versão instalada (ver R1) |
| PostgreSQL | 16 | `compose.yaml` | produção não verificável pelo repositório |
| Node | 22.11.0 | `.node-version` | — |

### Bibliotecas que moldam o código

- [ex.: Hotwire (Turbo + Stimulus) com importmap]
- [ex.: Solid Queue para jobs; Sidekiq ainda presente no Gemfile (ver R2)]
- [ex.: Pundit para autorização]

### Comandos confirmados

| Para quê | Comando | Evidência |
| --- | --- | --- |
| Rodar local | `bin/dev` | `bin/dev` + `Procfile.dev` |
| Testes | `bundle exec rspec` | `spec/`, CI |
| Lint | `bin/rubocop` | `bin/rubocop`, CI |
| Segurança | `bin/brakeman` | `bin/brakeman`, CI |

### Infraestrutura e CI

- [ex.: `compose.yaml` com postgres 16 e redis 7]
- [ex.: deploy com Kamal (`config/deploy.yml`)]
- [ex.: GitHub Actions roda rubocop, brakeman e rspec]

## 2. Recomendações

Ordenadas por relevância. Esforço e risco são qualitativos — horas, quando necessárias, vêm do `/spike`.

### R1 — [título — ex.: Atualizar `load_defaults` para 8.0]

- **Por quê:** [evidência e versão — ex.: Rails 8.0.1 instalado, padrões ainda em 7.1]
- **O que muda:** [ex.: novos padrões de segurança e de comportamento do Active Record]
- **Esforço:** [baixo / médio / alto]
- **Risco:** [baixo / médio / alto — e onde]
- **Como fazer:** [ex.: usar `new_framework_defaults_8_0.rb` e ativar uma opção por vez]

### R2 — [...]

[mesma estrutura]

## 3. Inconsistências

- [ex.: README manda `rails s`, mas o projeto usa `bin/dev` com Procfile]
- [ex.: CI testa Ruby 3.2, `.ruby-version` diz 3.3]

## 4. Lacunas

- [ex.: nenhum comando de auditoria de dependências — sugerido `bundler-audit`]
- [ex.: banco de produção não identificável pelo repositório]

## 5. O que foi gerado

| Arquivo | Ação |
| --- | --- |
| `docs/sdd/config.yml` | criado |
| `AGENTS.md` | criado |
| `CLAUDE.md` | criado (importa o AGENTS.md) |
| `.claude/settings.json` | mesclado — 9 regras adicionadas, 1 divergência mantida |
| `.codex/config.toml`, `.codex/rules/myaitoolkit.rules` | criados |
````
