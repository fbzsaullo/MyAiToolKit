# `docs/sdd/config.yml` — estrutura

Arquivo de fatos do projeto, gerado pelo `sdd-setup` e lido pelas skills do toolkit. Escrito para máquina primeiro: chaves estáveis, valores exatos, nada de prosa. O que é análise e opinião vai para o `stack-report.md`.

Regras:
- Valor desconhecido = `null` (nunca um chute).
- Toda versão tem uma origem em `source`.
- Comandos aqui precisam existir no repositório.
- O setup só reescreve as chaves que ele mesmo gerencia; chaves extras adicionadas pelo time são preservadas.

## Exemplo completo (Rails)

```yaml
# Gerado pelo /sdd-setup do MyAiToolKit. Edite à vontade; o setup preserva chaves desconhecidas.
version: 1
generated_at: 2026-10-06

project:
  name: clinica-agenda
  language: pt-BR            # idioma dos artefatos: pt-BR | en
  ais: [claude-code, codex]  # IAs em uso; define quais arquivos o setup mantém
  monorepo: false

stacks:
  - name: rails                      # nome do perfil em stacks/
    role: primary                    # primary | auxiliary
    path: .
    profile: stacks/rails/profile.md
    versions:
      ruby:  { value: "3.3.5", source: ".ruby-version" }
      rails: { value: "8.0.1", source: "Gemfile.lock" }
      load_defaults: { value: "8.0", source: "config/application.rb" }
    libraries:                       # só o que muda a forma de escrever código
      database: { value: "postgresql 16", source: "compose.yaml" }
      jobs: solid_queue
      cache: solid_cache
      frontend: hotwire (turbo + stimulus), importmap, tailwindcss
      auth: rails authentication generator
      authorization: pundit
    modules: []                      # engines/packs detectados, ex.: [{ name: billing, path: engines/billing }]
  - name: node
    role: auxiliary
    path: .
    profile: stacks/node/profile.md
    versions:
      node: { value: "22.11.0", source: ".node-version" }
    purpose: build de CSS (tailwind)

commands:                            # sempre a partir de `path` da stack; null quando não existe
  setup: bin/setup
  run: bin/dev
  build: null
  test: bundle exec rspec
  test_single: bundle exec rspec {file}
  system_test: bundle exec rspec spec/system
  lint: bin/rubocop
  lint_fix: bin/rubocop -a
  security: bin/brakeman --no-pager
  dependency_audit: bundle exec bundler-audit check --update
  migrate: bin/rails db:migrate
  load_check: bin/rails zeitwerk:check
  infra_up: docker compose up -d

testing:
  framework: rspec                   # rspec | minitest | jest | pytest | …
  paths: [spec]
  factories: factory_bot             # factory_bot | fixtures | …
  system_tests: capybara + selenium (headless chrome)
  ca_naming:                         # como um teste carrega o CA-XX (ver stacks/<stack>/test-conventions.md)
    pattern: 'it "CA-XX: <descrição>"'
    grep: 'CA-[0-9]{2}'

code_review:
  default_base_branch: main          # detectado; o /code-review sempre pergunta mesmo assim
  candidate_branches: [main, develop]
  tools:                             # ferramentas que o /code-review pode rodar (sempre com confirmação)
    - { name: rubocop, command: "bin/rubocop {files}", scope: changed_files }
    - { name: brakeman, command: "bin/brakeman --no-pager --only-files {files}", scope: changed_files }
    - { name: rspec, command: "bundle exec rspec {spec_files}", scope: related_specs }
  checklists:
    - stacks/rails/review-checklist.md
    - stacks/rails/security-checklist.md

spike:
  hours_per_day: 6                   # horas produtivas por dia (ajuste do time)
  include_overheads: true            # somar review, QA e deploy à sugestão
  overheads_pct: { code_review: 10, qa: 15, deploy: 5 }
  heuristics: stacks/rails/spike-heuristics.md

sdd:
  docs_root: docs/sdd
  task_status_language: pt-BR        # vocabulário de status das tarefas

permissions:
  claude:
    file: .claude/settings.json
    git_commit: ask                  # allow | ask
    migrations: ask                  # ask | deny
  codex:
    config: .codex/config.toml
    rules: .codex/rules/myaitoolkit.rules
```

## Chaves

| Chave | Obrigatória | Quem lê |
| --- | --- | --- |
| `project.language` | sim | todas as skills que escrevem artefatos |
| `project.ais` | sim | `sdd-setup` (quais arquivos manter) |
| `stacks[]` | sim (pode ser vazio em repo sem código) | todas |
| `stacks[].versions.*.source` | sim para cada versão | `sdd-setup` (audit), leitores humanos |
| `commands.*` | não (`null` quando não existe) | `sdd-execute`, `code-review`, `sdd-review` |
| `testing.ca_naming` | sim quando há testes | `sdd-execute`, `sdd-review`, `sdd-trace` |
| `code_review.*` | sim | `code-review`, `sdd-review` |
| `spike.*` | não (valores padrão abaixo) | `spike`, `sdd-plan` (estimativa) |
| `sdd.docs_root` | não (padrão `docs/sdd`) | todas as skills do pipeline |
| `permissions.*` | não | `sdd-setup` |

Padrões quando ausentes: `spike.hours_per_day: 6`, `spike.include_overheads: true`, `spike.overheads_pct: { code_review: 10, qa: 15, deploy: 5 }`, `sdd.docs_root: docs/sdd`, `project.language: pt-BR`.

## Monorepo

Cada stack declara seu `path`, e os comandos podem ser agrupados por stack:

```yaml
stacks:
  - { name: rails, role: primary, path: apps/api, profile: stacks/rails/profile.md, versions: { … } }
  - { name: node,  role: primary, path: apps/web, profile: stacks/node/profile.md,  versions: { … } }

commands:
  apps/api:
    test: bundle exec rspec
    lint: bin/rubocop
  apps/web:
    test: pnpm test
    lint: pnpm lint
```

Se o projeto optar por um `docs/sdd/` por sistema, cada um tem o seu `config.yml` com `path: .` relativo ao sistema.
