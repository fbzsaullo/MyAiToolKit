# Roteiro de análise — qualquer linguagem

Este é o prompt-base do `sdd-setup`. Ele vale para **qualquer** stack: o que muda de uma linguagem para outra está nos perfis em `${CLAUDE_PLUGIN_ROOT}/stacks/<stack>/profile.md`. O roteiro diz *o que* investigar; o perfil diz *onde* e *como* naquela stack.

Siga as etapas na ordem. Cada uma alimenta a seguinte.

---

## Etapa 1 — Mapear o repositório

Objetivo: saber **quantas** aplicações/stacks existem e **onde** cada uma vive.

1. Liste a raiz e o primeiro nível de pastas. Procure sinais de monorepo: `apps/`, `packages/`, `services/`, `engines/`, `components/`, workspaces em `package.json`, `go.work`, vários `Gemfile`/`package.json`/`pyproject.toml` em pastas diferentes.
2. Para cada candidato, compare com os **sinais de detecção** de cada perfil (`stacks/*/profile.md`, seção 1). Use a tabela-resumo de `${CLAUDE_PLUGIN_ROOT}/templates/stack-detection.md`.
3. Distinga **stack principal** (a aplicação) de **stack auxiliar** (ferramentas de build, scripts, frontend embutido). Um Rails com `package.json` só para Tailwind/esbuild tem Node como auxiliar, não como segunda aplicação.
4. Anote a infraestrutura local: `docker-compose.yml`/`compose.yaml`, `.devcontainer/`, `Procfile`/`Procfile.dev`, `config/deploy.yml` (Kamal), `Dockerfile`, manifestos de Kubernetes, Terraform.
5. Anote o CI: `.github/workflows/`, `.gitlab-ci.yml`, `bitbucket-pipelines.yml`, `.circleci/` — os comandos que o CI roda são a melhor evidência de "como o time testa".

Resultado esperado (mantido na conversa):

```
Stacks encontradas
- rails     → .            (principal)  sinais: Gemfile, config/application.rb
- node      → .            (auxiliar)   sinais: package.json (tailwind, esbuild)
Infra local: compose.yaml (postgres 16, redis 7)
CI: .github/workflows/ci.yml (bin/rubocop, bin/brakeman, bin/rails test)
```

Stack sem perfil no toolkit → use `stacks/_generic/profile.md` e diga isso no relatório.

---

## Etapa 2 — Ler as versões reais

Objetivo: versões **do que está instalado/travado**, não do que alguém lembra.

Ordem de confiança (do mais para o menos confiável):

1. **Lockfile** — versão resolvida de fato (`Gemfile.lock`, `package-lock.json`/`pnpm-lock.yaml`/`yarn.lock`, `poetry.lock`/`uv.lock`, `composer.lock`, `go.sum`/`go.mod`, `packages.lock.json`).
2. **Arquivo de versão do runtime** — `.ruby-version`, `.tool-versions` (asdf/mise), `.node-version`/`.nvmrc`, `.python-version`, `global.json`, `go.mod` (`go 1.x`), `mise.toml`.
3. **Manifesto** — `Gemfile`, `package.json` (`engines`, faixas de dependências), `pyproject.toml` — dá a faixa permitida, não a versão exata.
4. **Configuração do framework** — ex.: `config.load_defaults 7.1` em Rails revela em que nível de padrões a aplicação está, que pode ser **diferente** da versão instalada.
5. **Imagem de container / CI** — `FROM ruby:3.3.5-slim`, `ruby-version:` no workflow.

Regras:
- Registre **de onde** veio cada versão (`rails 8.0.1 — Gemfile.lock`).
- Fontes que discordam são um achado: `.ruby-version` diz 3.2.2, `Dockerfile` usa 3.3.0 → reporte no `stack-report.md`.
- Sem nenhuma fonte, escreva "versão não identificada" — nunca chute.

O perfil da stack lista as fontes específicas e o que é relevante ler (seção 2 de cada `profile.md`).

---

## Etapa 3 — Carregar o perfil e extrair os fatos

Para cada stack, leia o `profile.md` correspondente e colete:

| Fato | Onde o perfil diz para procurar | Vai para |
| --- | --- | --- |
| Framework e bibliotecas centrais | dependências do manifesto | `config.yml` → `stacks[].libraries`; seção Stack do `AGENTS.md` |
| Banco e serviços | config de banco, drivers, compose | Stack |
| Comandos reais (build, rodar, testes, lint, segurança, migrations) | `bin/`, task runner, scripts, CI | `config.yml` → `commands`; seção Comandos |
| Framework de teste e organização | pastas e gems/pacotes de teste | `config.yml` → `testing` |
| Convenção de nome de teste para `CA-XX` | seção "Convenção de nome de teste" do perfil | `config.yml` → `testing.ca_naming` |
| Ferramentas de qualidade e segurança | dependências + CI | `config.yml` → `code_review.tools` |
| Organização do código | estrutura de pastas | seção Convenções |
| Convenções visíveis | padrões repetidos no código (ver lista no perfil) | seção Convenções |
| Arquivos com segredo | lista do perfil + bloqueio universal | permissões |

### Comandos: a regra de ouro

**Extrair, nunca inventar.** Um comando inexistente no `AGENTS.md` faz o agente falhar de forma confusa e desacredita o arquivo inteiro.

Precedência quando há mais de uma fonte (a primeira que existir vence):

1. **Executáveis do projeto / task runner** — `bin/*` (Rails), `Makefile`, `justfile`, `Taskfile.yml`, `Rakefile` com tarefas próprias. Se o time criou, é a interface pretendida.
2. **Scripts do gerenciador de pacotes** — `package.json` `scripts`, `composer.json` `scripts`, `[tool.poetry.scripts]`/`[project.scripts]`.
3. **O que o CI executa** — evidência de que o comando funciona.
4. **Comando nativo do ecossistema** — só com evidência de que a estrutura é a padrão.
5. **README / CONTRIBUTING** — menos confiável (envelhece), mas melhor que chutar.

Use o **gerenciador certo** (lockfile `pnpm-lock.yaml` → `pnpm`, `uv.lock` → `uv`…). Em monorepo, informe o diretório de trabalho de cada comando. Sem comando para uma categoria, registre um TODO explícito:

```markdown
<!-- TODO: nenhum comando de teste encontrado (sem pasta de testes, sem script, nada no CI). Confirmar a estratégia de testes com o time. -->
```

### Validação opcional

Se o ambiente permitir, **com confirmação do usuário**, rode um comando rápido e inofensivo para validar (ex.: versão do runtime, lint de um arquivo). Nunca rode migrations, deploy, suíte completa demorada ou qualquer coisa destrutiva para "testar". Falha na validação vira observação no relatório — o comando pode estar certo e o ambiente, não configurado.

---

## Etapa 4 — Formular: como tirar o melhor proveito

É o que diferencia o setup de um simples inventário. Com as versões em mãos, use a seção "Orientações por versão" do perfil e produza recomendações **concretas e justificadas**:

1. **Recursos disponíveis e não usados** — a versão instalada já traz algo que o projeto resolve de outro jeito. *Ex.: Rails 8 tem Solid Queue, mas o projeto mantém Sidekiq + Redis só para dois jobs.* Recomende avaliar, não trocar por decreto.
2. **Padrões de configuração atrasados** — `load_defaults` (ou equivalente) abaixo da versão instalada. Explique o que a atualização muda e o risco.
3. **Suporte e fim de vida** — versão de runtime ou framework perto ou além do fim de suporte de segurança. Indique a data **apenas se tiver certeza**; caso contrário, recomende conferir a política oficial do projeto (link do perfil).
4. **Ferramentas de qualidade e segurança ausentes** — a stack tem padrão consagrado (lint, análise de segurança, auditoria de dependências) e o projeto não usa.
5. **Inconsistências** — versões divergentes entre fontes, comandos do README que não existem, CI testando outra versão.
6. **Como o agente deve trabalhar nesta versão** — APIs e idiomas corretos para a versão (ex.: em Rails 7.1+, `normalizes` e `generates_token_for`; em 8.0, o gerador de autenticação). Isso vai para a seção Convenções do `AGENTS.md` quando for algo que o agente erraria.

Cada recomendação tem: **o quê**, **por quê** (ligado à versão/evidência), **esforço relativo** (baixo/médio/alto — qualitativo) e **risco**. Nada de horas: estimativa é assunto do `/spike`, com decisão do usuário.

Recomendação é **sugestão** para o time. O setup não muda código, dependências nem configuração da aplicação.

---

## Etapa 5 — Ler o que o pipeline já sabe

Se existirem:

| Artefato | O que tirar |
| --- | --- |
| `docs/sdd/architecture/proposta-arquitetural.md` | Resumo (comprimido para 2–4 linhas), restrições, stack decidida, dívidas conscientes |
| `docs/sdd/architecture/adrs/*.md` com `Aceito` | Decisões que viram convenção obrigatória (citar o ADR entre parênteses) |
| `docs/sdd/prds/*.md` | Apenas nomes, para o índice — nunca conteúdo |
| `docs/sdd/plans/*.md` | Convenções que se repetem nas tarefas |
| `docs/sdd/reviews/*.md` | "Notas ao processo" → **padrões novos** a documentar |

Divergência entre o decidido (ADR) e o praticado (código) é achado do relatório — não escolha um lado em silêncio.

---

## Etapa 6 — Montar as saídas

1. `docs/sdd/config.yml` — fatos estruturados (`config-schema.md`). É lido pelas skills; precisa ser exato.
2. `docs/sdd/stack-report.md` — a análise para pessoas: stacks, versões e origens, recomendações, inconsistências, lacunas (`stack-report-template.md`).
3. `AGENTS.md` — o essencial para o agente em toda sessão (`agents-md-template.md`).
4. Arquivos de cada IA escolhida — `CLAUDE.md` e `.claude/settings.json` para Claude Code; `.codex/config.toml` e `.codex/rules/myaitoolkit.rules` para Codex (`permission-principles.md` + `stacks/<stack>/permissions.md`). Outras IAs: ver `${CLAUDE_PLUGIN_ROOT}/adapters/README.md`.

Antes de gravar, confira:

- [ ] Toda versão citada tem origem
- [ ] Todo comando citado existe no repositório (ou está marcado como TODO)
- [ ] Nenhum segredo copiado para os arquivos gerados
- [ ] `AGENTS.md` entre ~60 e ~120 linhas; detalhe longo foi para referência
- [ ] Nada do `AGENTS.md` está duplicado no `CLAUDE.md`
- [ ] Permissões: nenhuma regra do `allow` é anulada por uma do `ask`/`deny` (ver "Sombra entre listas" em `permission-principles.md`)
- [ ] Diff mostrado e aprovado

---

## Quando a stack não tem perfil

Use `stacks/_generic/profile.md` e aplique as mesmas seis etapas com mais perguntas ao usuário. No relatório, registre:

> Stack `<nome>` sem perfil no MyAiToolKit — análise feita com o perfil genérico. Comandos e convenções foram extraídos do repositório; recomendações por versão são limitadas.

E sugira, nas lacunas, criar um perfil seguindo `${CLAUDE_PLUGIN_ROOT}/stacks/README.md` — é a contribuição mais útil para o projeto open-source.
