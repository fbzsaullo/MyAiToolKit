---
name: sdd-adr
description: Registra uma decisão de arquitetura avulsa sem rodar a fase de arquitetura inteira — escreve um ADR novo (próximo número livre, um arquivo por decisão, status Proposto até o usuário aceitar), substitui um ADR existente (o novo diz o que substitui; o antigo passa a "Substituído por ADR-XXX") ou descontinua um ADR, mantendo o índice da proposta arquitetural em dia e avisando quais tarefas do plano se apoiam na decisão que mudou. Use quando o usuário pedir "registrar uma decisão", "criar um ADR", "trocar a decisão do ADR-004", "essa decisão não vale mais", "documentar por que escolhemos X" ou chamar /sdd-adr. Para desenhar ou revisar a arquitetura de um sistema, use sdd-architect.
argument-hint: "[decisão a registrar, ou substituir|descontinuar ADR-XXX — opcional]"
allowed-tools: Read, Glob, Grep, Edit(docs/sdd/architecture/**)
---

# sdd-adr — uma decisão, um arquivo

Entrada: $ARGUMENTS (se o seu ambiente não substituir essa variável, use a mensagem do usuário).

Nem toda decisão nasce na fase de arquitetura. Uma biblioteca nova, uma troca de estratégia de cache, uma restrição que apareceu no meio do projeto: tudo isso merece um ADR, e nenhum desses casos justifica refazer a proposta inteira. Esta skill escreve **uma** decisão no mesmo formato do `sdd-architect`, para que plano, review e trace a enxerguem igual.

Modelo do arquivo: `${CLAUDE_PLUGIN_ROOT}/skills/sdd-architect/references/adr-template.md`. Ciclo de vida e status: "Status de um ADR" em `${CLAUDE_PLUGIN_ROOT}/templates/id-conventions.md`.

## Modos

| Entrada | O que faz |
| --- | --- |
| *(uma decisão nova)* | ADR novo |
| `substituir ADR-XXX` | ADR novo que toma o lugar do `ADR-XXX` |
| `descontinuar ADR-XXX` | O `ADR-XXX` deixa de valer e nada o substitui |

Sem modo claro na entrada, pergunte.

## Passo 1 — Vale um ADR?

Vale quando a decisão tem **trade-off real** (havia pelo menos duas opções defensáveis), é **difícil de desfazer** ou **muda como o código é escrito** daqui para a frente. Escolha óbvia, sem alternativa, ou detalhe que muda toda semana não vira ADR — diga isso e sugira registrar em Convenções do `AGENTS.md` (`/sdd-setup refresh`), se for o caso.

## Passo 2 — Conversa curta

Pergunte só o que faltar, num bloco:

1. **Contexto** — o que obriga a decidir agora? (o problema concreto, a qualidade ou a restrição; um sintoma medido, se houver)
2. **Opções** — quais foram consideradas? Pelo menos duas reais, com o motivo de cada recusa.
3. **Decisão** — o que foi escolhido, numa frase direta.
4. **Consequências** — o que melhora, o que piora (a dívida e quando ela vira problema).

Leia antes a proposta arquitetural e os ADRs existentes: a decisão nova não pode contradizer um ADR `Aceito` sem substituí-lo. Se contradiz, mude o modo para `substituir` e confirme com o usuário.

## Passo 3 — Escrever

- **Número:** o próximo livre em `docs/sdd/architecture/adrs/` (três dígitos). Números de ADRs substituídos ou descontinuados continuam ocupados.
- **Arquivo:** `ADR-XXX-titulo-curto.md`, título em forma de ação.
- **Status:** `Proposto`. Só vira `Aceito` quando o usuário aceitar explicitamente — pergunte no fim; silêncio não é aceite.
- **Substituir:** no ADR novo, uma linha `- **Substitui:** ADR-YYY` no cabeçalho e, no contexto, o que mudou desde a decisão antiga. No antigo, **só** o status muda para `Substituído por ADR-XXX` — o resto do texto fica, como registro.
- **Descontinuar:** no ADR, o status muda para `Descontinuado` e uma seção curta "Por que deixou de valer" vai para o fim. Nenhum arquivo é apagado.
- **Índice:** se existe `docs/sdd/architecture/proposta-arquitetural.md`, acrescente a linha do ADR novo na tabela de decisões e atualize o status do substituído. A proposta lista; não reproduz o ADR.

Mostre o conteúdo e o diff do índice e peça confirmação antes de gravar.

## Passo 4 — Efeito no plano

Procure em `docs/sdd/plans/` as tarefas com o ADR antigo em `Decisões base` (substituído ou descontinuado):

- `Pendente` ou `Em andamento` — avise: elas se apoiam numa decisão que não vale mais. O ajuste do plano é do `/sdd-change` (ou do `sdd-plan`); esta skill não edita o plano;
- `Concluído` — o código pode precisar mudar: sugira uma tarefa de adequação via `/sdd-change`.

ADR novo que ainda nenhuma tarefa cita aparece no `/sdd-trace` como "ADR que ninguém cita" até alguma tarefa se apoiar nele — avise, para não parecer erro.

## Não fazer

- Apagar ou reescrever o texto de um ADR antigo. Só o status muda.
- Gravar `Aceito` sem o aceite explícito do usuário.
- Reaproveitar o número de um ADR substituído ou descontinuado.
- Registrar preferência sem alternativa como se fosse decisão.
