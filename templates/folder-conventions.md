# Onde cada artefato mora

Organização sugerida para os arquivos que o MyAiToolKit gera dentro do repositório de um projeto. Tudo o que o toolkit produz fica concentrado em `docs/sdd/`, separado da documentação que o projeto já tenha em `docs/`.

## Árvore de referência

```
meu-projeto/
├── AGENTS.md                              # contexto canônico para agentes (Codex, Cursor, outros)
├── CLAUDE.md                              # importa o AGENTS.md + notas só do Claude Code
├── .claude/
│   └── settings.json                      # permissões do Claude Code (política do time)
├── docs/
│   ├── (documentação própria do projeto, intocada)
│   └── sdd/
│       ├── config.yml                     # perfil do projeto gerado pelo sdd-setup
│       ├── stack-report.md                # análise de stack e versões do sdd-setup
│       ├── architecture/
│       │   ├── proposta-arquitetural.md
│       │   └── adrs/
│       │       ├── ADR-001-monolito-modular.md
│       │       └── ADR-002-fila-com-solid-queue.md
│       ├── prds/
│       │   ├── PRD-001-carrinho.md
│       │   └── PRD-002-pagamento-pix.md
│       ├── prototype/
│       │   ├── SPEC-UI-001-carrinho.md
│       │   └── assets/                    # HTML, imagens, exports do protótipo
│       ├── plans/
│       │   ├── PLAN-001-carrinho.md
│       │   └── PLAN-002-pagamento-pix.md
│       ├── reviews/
│       │   ├── REVIEW-T-04-2026-10-06.md
│       │   ├── REVIEW-T-04-2026-10-08-round2.md
│       │   └── REVIEW-T-05-2026-10-07.md
│       ├── traceability/
│       │   └── MATRIX-001-carrinho.md     # gerada pelo sdd-trace
│       ├── spikes/
│       │   └── SPIKE-PROJ-123-checkout-parcelado.md
│       └── code-reviews/
│           └── CR-feature-carrinho-2026-10-06.md
├── app/ (ou src/)
└── spec/ (ou test/)
```

## Regras por pasta

### `architecture/`

- **Uma proposta arquitetural por sistema** — `proposta-arquitetural.md`. Em sistemas grandes, uma por bounded context.
- **Uma decisão por arquivo** em `adrs/`: `ADR-XXX-titulo-curto.md`, três dígitos no número. A proposta não reproduz o conteúdo dos ADRs: ela lista cada um com título, status e link.
- ADR nunca é apagado. Quando perde a validade, muda o `**Status:**` (ver `id-conventions.md`).

### `prds/`

- **Um PRD por épico ou funcionalidade grande** — `PRD-XXX-tema.md`.
- O contador é do projeto inteiro e não reinicia com o tempo.
- Mudança de escopo grande pode gerar `-v2`; ajuste pequeno é feito no próprio arquivo, atualizando a data do cabeçalho.

### `prototype/`

- **Só existe para PRD com interface.** API, job ou integração não têm SPEC-UI, e isso é normal.
- Nome `SPEC-UI-XXX-tema.md`, com **o mesmo número do PRD** a que pertence.
- Material visual (HTML, imagens, código exportado de ferramentas de protótipo) vai em `prototype/assets/`; Figma e afins entram como link.
- Diferente do PRD, a SPEC-UI pode ser refeita do zero quando o protótipo muda — o PRD aprovado não é tocado.

### `plans/`

- **Um plano para cada PRD**, com o mesmo número: `PLAN-001` acompanha o `PRD-001`.
- O plano não é reescrito durante a execução; ele é **atualizado** (status das tarefas, histórico, estimativa informada pelo usuário).

### `reviews/`

- **Um relatório por tarefa revisada**: `REVIEW-T-XX-AAAA-MM-DD.md`.
- Revisões seguintes da mesma tarefa ganham sufixo: `-round2`, `-round3`. O relatório anterior não é editado.
- Com o tempo a pasta cresce; relatórios aprovados de tarefas antigas podem ir para `reviews/archive/`.
- Times que preferem tudo no PR podem colar o relatório como comentário em vez de versioná-lo. A escolha é do projeto, e convém registrá-la no `AGENTS.md`.

### `traceability/`

- Matrizes geradas sob demanda pelo `sdd-trace`: `MATRIX-XXX-tema.md`, mesmo número do PRD/plano.
- São fotografias de um momento, não fonte de verdade. Mudou o PRD ou o plano, gere de novo.

### `spikes/`

- Uma análise por card: `SPIKE-<CHAVE>-tema.md` (a chave vem do board; sem chave, sequencial `SPIKE-001`).
- Guarda **apenas as horas que o usuário informou**. A sugestão da IA não é gravada.

### `code-reviews/`

- Um relatório por execução do `/code-review`: `CR-<branch>-AAAA-MM-DD.md` (barras da branch viram hífen: `feature/carrinho` → `feature-carrinho`).
- Revisar a mesma branch de novo no mesmo dia acrescenta `-2`, `-3`.

## Arquivos de contexto do agente

O `sdd-setup` gera e mantém esses arquivos; nenhuma outra skill escreve neles, no máximo sugere rodar o setup.

| Arquivo | Para quem | Conteúdo |
| --- | --- | --- |
| `AGENTS.md` | Qualquer agente (Codex, Cursor, Claude via import…) | Resumo, stack com versões, comandos, convenções, restrições, como navegar o `docs/sdd/` |
| `CLAUDE.md` | Claude Code | Linha `@AGENTS.md` + o que for específico do Claude |
| `.claude/settings.json` | Claude Code | Permissões `allow` / `ask` / `deny` calibradas pela stack |
| `docs/sdd/config.yml` | As próprias skills do toolkit | Stacks, versões, comandos, idioma, IAs em uso, branch base, parâmetros do spike |

Um `AGENTS.md` mínimo, antes do setup completo, já orienta o agente a seguir o pipeline:

```markdown
# Meu Projeto — guia para agentes

Este repositório usa o pipeline SDD do MyAiToolKit. Antes de mexer em código:

1. Procure o plano em `docs/sdd/plans/PLAN-XXX-*.md`.
2. Escolha a primeira tarefa com `Status: Pendente` cujas dependências (`Depende de:`) estejam todas `Concluído`.
3. Leia a tarefa inteira, em especial `Implementa:`, `Valida:`, `Decisões base:` e `Telas:`.
4. Abra o que ela referencia: regras e cenários no PRD (`docs/sdd/prds/`), decisões em `docs/sdd/architecture/adrs/`.
5. Respeite os pontos de validação humana marcados no plano.
6. Ao terminar, atualize o `Status:` da tarefa e o histórico do plano.
7. Uma tarefa por vez, sempre seguida de review.

Testes que provam cenários levam o `CA-XX` no nome (formato em `docs/sdd/config.yml`).
Com o toolkit instalado: `sdd-execute` executa uma tarefa e `sdd-review T-XX` revisa.
```

## Monorepo com vários sistemas

Cada sistema independente tem o seu próprio `docs/sdd/`:

```
monorepo/
├── apps/
│   ├── loja/
│   │   └── docs/sdd/ (config.yml, architecture/, prds/, plans/, …)
│   └── backoffice/
│       └── docs/sdd/ (config.yml, architecture/, prds/, plans/, …)
└── packages/
    └── compartilhado/
```

Os IDs valem só dentro do sistema: o `RN-01` da `loja` e o `RN-01` do `backoffice` não colidem. O `sdd-setup` detecta essa estrutura e pergunta se o projeto quer um `docs/sdd/` por sistema ou um único na raiz.

## O que fica fora de `docs/sdd/`

- **Arquivos-fonte de design** (Figma, Sketch, imagens soltas) → pasta `design/` ou link externo. A SPEC-UI é exceção porque é especificação rastreável, não arte.
- **Documentação gerada por build** (Swagger, YARD, RDoc) → não versionar aqui.
- **Atas e brainstorms** → ferramenta de notas do time; não fazem parte do pipeline.
- **README de bibliotecas internas** → junto do código da biblioteca.
