# Changelog

Todas as mudanças relevantes do MyAiToolKit. Formato inspirado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/); versionamento [SemVer](https://semver.org/lang/pt-BR/).

## [Não lançado]

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
