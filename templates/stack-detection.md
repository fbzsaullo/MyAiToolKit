# Descobrindo a stack de um projeto

Toda skill que precisa saber "com que tecnologia estamos lidando" — `sdd-setup`, `sdd-review`, `code-review`, `spike`, `sdd-plan` — segue esta mesma cascata. A regra de ouro: **a stack vem do projeto, nunca de suposição**.

## A cascata

Pare no primeiro nível que responder com segurança. Os níveis seguintes servem para confirmar ou completar.

### 1. `docs/sdd/config.yml`

Gerado pelo `sdd-setup`. Quando existe, é a fonte mais direta: stacks, versões, caminhos (em monorepo), comandos de teste/lint/segurança, convenção de nome de teste e branch base.

```yaml
stacks:
  - name: rails
    path: .
    versions: { ruby: "3.3.5", rails: "8.0.1" }
    profile: stacks/rails/profile.md
```

Se o arquivo parecer desatualizado (ex.: `Gemfile.lock` aponta outra versão do Rails), use o que o repositório mostra **e** avise que vale rodar `/sdd-setup refresh`.

### 2. Contexto do agente — `AGENTS.md` / `CLAUDE.md`

Seções "Stack" e "Convenções". Times organizados declaram ali tecnologia, padrões de código e de teste. O que estiver declarado vira critério — mesmo que pareça haver jeito melhor.

### 3. Arquitetura

`docs/sdd/architecture/proposta-arquitetural.md` (restrições e diagrama de containers, onde a tecnologia aparece no rótulo) e os ADRs de stack em `docs/sdd/architecture/adrs/`.

### 4. Inspeção do repositório

Use os **sinais de detecção** de cada perfil em `${CLAUDE_PLUGIN_ROOT}/stacks/*/profile.md`. Resumo:

| Arquivo-pista | Stack | Perfil |
| --- | --- | --- |
| `Gemfile` + `config/application.rb` | Ruby on Rails | `stacks/rails/` |
| `Gemfile` sem Rails | Ruby | `stacks/_generic/` (+ partes de `rails/` que se aplicam) |
| `package.json` | Node.js / TypeScript (o framework vem das dependências) | `stacks/node/` |
| `pyproject.toml`, `requirements.txt`, `Pipfile` | Python | `stacks/python/` |
| `*.csproj`, `*.sln`, `global.json` | .NET | `stacks/dotnet/` |
| `go.mod` | Go | `stacks/go/` |
| `pom.xml`, `build.gradle(.kts)` | Java / Kotlin | `stacks/java/` |
| `composer.json` | PHP | `stacks/php/` |
| outros (`Cargo.toml`, `mix.exs`, `pubspec.yaml`…) | conforme o arquivo | `stacks/_generic/` |

Banco e infraestrutura: `config/database.yml`, `docker-compose.yml`/`compose.yaml`, gems/pacotes de driver (`pg`, `mysql2`, `sqlite3`, `redis`), pasta de migrations.

### 5. Pergunta

Só se nada acima funcionou:

> Não encontrei `docs/sdd/config.yml`, `AGENTS.md` nem proposta de arquitetura, e a inspeção do repositório não foi conclusiva. Qual é a stack principal (linguagem, framework e banco)?

Depois da resposta, sugira `/sdd-setup` para que a pergunta não se repita.

## Depois de descobrir

1. **Carregue o perfil** da stack (`stacks/<stack>/profile.md`) e, conforme a skill, os checklists (`review-checklist.md`, `security-checklist.md`, `test-conventions.md`, `spike-heuristics.md`) quando existirem.
2. **Sem perfil**, use `stacks/_generic/profile.md` e diga isso explicitamente no artefato gerado.
3. **Registre a fonte** no artefato: "Stack: Rails 8.0 / Ruby 3.3 — fonte: `docs/sdd/config.yml`".
4. **Convenções do projeto ganham das do perfil.** O perfil traz o comum da stack; o `AGENTS.md` traz a escolha do time. Em conflito, vale o projeto — e o artefato menciona o conflito.

## Casos que exigem cuidado

**Monorepo com várias stacks.** Descubra a stack **da pasta afetada**, não do repositório inteiro. Um diff que toca `apps/api/` (Rails) e `apps/web/` (React) é avaliado com os dois perfis, em seções separadas.

**Stack em migração.** Se a arquitetura declara "o novo" e "o legado", aplique critérios diferentes: código novo no padrão antigo dentro de área já migrada é problema; código novo no padrão novo dentro de área legada segue o plano de migração.

**Stack pouco comum.** Aplique os critérios universais do `_generic`, peça esclarecimento quando algo parecer estranho e declare a limitação. Não finja domínio de uma stack que o projeto não documentou.

**Sem `AGENTS.md`/`CLAUDE.md`.** Aplique o perfil da stack e os critérios universais, e escreva no artefato:

> ⚠️ Stack identificada por inspeção do repositório. O projeto não documenta convenções próprias — foram aplicados o perfil da stack e critérios universais. `/sdd-setup` gera esse contexto.
