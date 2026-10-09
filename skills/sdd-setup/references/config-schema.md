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

review:
  cross_check: never                 # never | auto | always — revisão cruzada no /sdd-review e no /code-review

spike:
  hours_per_day: 6                   # horas produtivas por dia (ajuste do time)
  include_overheads: true            # somar review, QA e deploy à sugestão
  overheads_pct: { code_review: 10, qa: 15, deploy: 5 }
  heuristics: stacks/rails/spike-heuristics.md

sdd:
  docs_root: docs/sdd
  task_status_language: pt-BR        # vocabulário de status das tarefas

git:
  commit:                            # o kit nunca commita: as skills entregam a mensagem pronta neste formato
    convention: conventional         # conventional | task-id | custom
    format: "<tipo>(<escopo>): <descrição> (T-XX)"
    types: [feat, fix, docs, chore, refactor, test, perf, build, ci, style]   # só em conventional
    task_id: subject                 # subject | footer | none — onde a T-XX aparece
    example: "feat(agenda): bloqueia horário já ocupado (T-03)"

permissions:
  claude:
    file: .claude/settings.json
    migrations: ask                  # ask | deny (git commit fica sempre em ask)
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
| `review.cross_check` | não (padrão `never`; perguntado no setup) | `sdd-review`, `code-review` |
| `spike.*` | não (valores padrão abaixo) | `spike`, `sdd-plan` (estimativa) |
| `sdd.docs_root` | não (padrão `docs/sdd`) | todas as skills do pipeline |
| `git.commit.*` | sim (perguntado no setup) | `commit-message` e `sdd-review` (mensagem entregue em texto), `sdd-review` e `code-review` (aderência dos commits) |
| `permissions.*` | não | `sdd-setup` |

Padrões quando ausentes: `spike.hours_per_day: 6`, `spike.include_overheads: true`, `spike.overheads_pct: { code_review: 10, qa: 15, deploy: 5 }`, `sdd.docs_root: docs/sdd`, `project.language: pt-BR`, `review.cross_check: never`. Sem `git.commit`, as skills usam `T-XX: <descrição>` e sugerem rodar o `/sdd-setup`.

### `git.commit` — padrão das mensagens

O kit **nunca commita**: estas chaves só definem o formato da mensagem que as skills entregam em texto. As regras de montagem (tipo, escopo, assunto, corpo, rodapé) estão em `templates/commit-message.md`.

| `convention` | `format` | `task_id` | `example` |
| --- | --- | --- | --- |
| `conventional` | `<tipo>(<escopo>): <descrição> (T-XX)` | `subject` | `feat(agenda): bloqueia horário já ocupado (T-03)` |
| `task-id` | `T-XX: <descrição>` | `subject` | `T-03: agenda consulta com bloqueio de horário` |
| `custom` | o texto que o usuário escreveu, com os marcadores dele | `subject`, `footer` (`Refs: T-XX`) ou `none` | exemplo confirmado com o usuário |

`types` só existe em `conventional`. Em `custom`, `example` é obrigatório: ele é a referência de quem lê o padrão.

### `review.cross_check` — revisão cruzada

| Valor | Efeito |
| --- | --- |
| `never` | Review como sempre foi (padrão) |
| `auto` | Um verificador independente confere os apontamentos só quando o review achou um `Bloqueante` ou um `Q1` |
| `always` | O verificador confere os `Bloqueante` e `Importante` de todo review |

Os valores são palavras, e não `on`/`off`, porque em YAML 1.1 `on` e `off` são lidos como booleanos. Na chamada, `cruzada` e `simples` sobrepõem o valor. Regras em `templates/cross-check.md`.

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
