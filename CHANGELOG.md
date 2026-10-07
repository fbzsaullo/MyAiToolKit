# Changelog

Todas as mudanças relevantes do MyAiToolKit. Formato inspirado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/); versionamento [SemVer](https://semver.org/lang/pt-BR/).

## [Não lançado]

### Setup
- O `/sdd-setup` pergunta o **padrão das mensagens de commit**: Conventional Commits, ID da tarefa primeiro ou um padrão escrito pelo usuário. A escolha fica em `docs/sdd/config.yml` (`git.commit`) e numa linha do `AGENTS.md`; a opção que bate com o que o projeto já usa (commitlint, commitizen, hooks, histórico) vem recomendada.
- **O kit nunca commita.** A pergunta "`git commit` pelo agente: liberado ou com confirmação?" saiu: `git commit` fica sempre em `ask`, e as skills entregam a mensagem pronta em texto. A chave `permissions.claude.git_commit` deixou de existir; o setup aponta configurações antigas com commit liberado.
- `sdd-execute` monta a mensagem no padrão escolhido; `sdd-review` e `code-review` conferem se os commits seguem o padrão.

### Documentação
- Crédito ao [leanwork-sdd](https://github.com/leanwork/leanwork-sdd) (Leanwork Group, MIT) como base do pipeline SDD: seção "Origem e créditos" no README, seção própria no REFERENCES.md e aviso de copyright no LICENSE.

## [0.1.0] — 2026-10-06

Primeira versão.

### Pipeline SDD
- Skills `sdd-start`, `sdd-architect`, `sdd-prd`, `sdd-prototype`, `sdd-plan`, `sdd-execute`, `sdd-review`, `sdd-trace` e `sdd-next`.
- Rastreabilidade `ADR ↔ RN ↔ CA ↔ UI ↔ T ↔ R ↔ teste`, com convenções em `templates/id-conventions.md`.
- ADRs em arquivos próprios (`docs/sdd/architecture/adrs/ADR-XXX-*.md`) com status de ciclo de vida.
- Todos os artefatos em `docs/sdd/`.
- Campo opcional `Estimativa` nas tarefas: a IA sugere, **só o valor do usuário é gravado**.
- Eixo de **segurança** no review, com checklist por stack.
- Convenção de nome de teste para `CA-XX` definida por stack.
- `sdd-execute` e `sdd-setup` só rodam por chamada explícita.

### Setup multilinguagem
- `sdd-setup` com roteiro de análise comum, leitura de versões reais e recomendações por versão.
- Geração de `docs/sdd/config.yml`, `docs/sdd/stack-report.md`, `AGENTS.md` (canônico), `CLAUDE.md` (importa o `AGENTS.md`), `.claude/settings.json` e `.codex/` (config + regras).
- Perfis de stack: **Rails** (completo, referência), Node.js/TypeScript, Python, .NET, Go, Java/Kotlin, PHP e genérico.

### Ferramentas
- `spike`: análise de esforço a partir de texto ou card exportado (Jira, GitHub, Azure DevOps, Trello), com estimativa de três pontos e decisão do usuário.
- `code-review`: review avulso com escolha da branch base, história opcional (XML, texto ou issue), roteiro montado pela configuração e classificação por severidade e quadrante de urgência × importância.

### Multi-IA
- Plugin e marketplace do Claude Code.
- Adaptador do Codex com instaladores `install.sh` e `install.ps1`.
- Contrato para novos adaptadores em `adapters/README.md`.

### Qualidade
- `scripts/check.sh` e workflow de CI.
