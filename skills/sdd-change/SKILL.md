---
name: sdd-change
description: Aplica uma mudança de escopo a um PRD já aprovado e propaga o efeito pelo pipeline — analisa o impacto em cada ID (RN, CA, UI, T, ADR, testes), mostra a tabela de impacto antes de editar, registra a revisão no PRD e na SPEC-UI (IDs novos continuam a numeração, alterados mantêm o número, revogados ficam riscados), ajusta o plano (tarefas pendentes editadas, concluídas nunca reabertas, uma fase nova para o que muda, tarefas que perderam o sentido marcadas Cancelado) e indica o que conferir no fim com o /sdd-trace. Use quando o usuário pedir "mudar o escopo", "o cliente pediu uma alteração", "acrescentar uma regra ao PRD aprovado", "tirar isso do escopo", "revisar o PRD" ou chamar /sdd-change. Para registrar só uma decisão de arquitetura, use sdd-adr; para corrigir um defeito, sdd-bug.
argument-hint: "[descrição da mudança, card ou caminho do PRD — opcional]"
allowed-tools: Read, Glob, Grep, Edit(docs/sdd/prds/**), Edit(docs/sdd/prototype/**), Edit(docs/sdd/plans/**)
---

# sdd-change — mudar um PRD aprovado sem perder o rastro

Entrada: $ARGUMENTS (se o seu ambiente não substituir essa variável, use a mensagem do usuário).

Mudar o escopo depois da aprovação é normal. O que não pode é a mudança entrar só no código, ou só no PRD: aí os IDs passam a mentir — o plano implementa uma regra que o PRD já não diz, o teste prova um cenário que mudou de sentido. Esta skill muda o que precisa mudar, **em todos os artefatos**, e deixa registrado o porquê.

Regras de ID que valem aqui (de `${CLAUDE_PLUGIN_ROOT}/templates/id-conventions.md`): número gasto não volta, nada é renumerado, regra e tela revogadas ficam riscadas no lugar, ADR muda pelo status.

## Passo 1 — Entender a mudança

1. Qual PRD? Com mais de um em `docs/sdd/prds/`, pergunte. Se ele ainda está `Rascunho` ou `Em revisão`, não precisa desta skill: edite com `sdd-prd`.
2. Card exportado? Normalize com `${CLAUDE_PLUGIN_ROOT}/templates/card-ingestion.md`.
3. Classifique cada parte da mudança:

| Tipo | Exemplo | Efeito nos IDs |
| --- | --- | --- |
| **Acrescenta** | uma regra ou cenário que não existia | IDs novos, continuando a numeração |
| **Altera** | uma regra muda de sentido (30 → 15 minutos) | mesmo ID, texto novo; quem já usava o ID precisa ser revisto |
| **Revoga** | algo sai do escopo | ID riscado, com o motivo; nunca apagado |
| **Corrige a redação** | erro de digitação, frase ambígua sem mudar o sentido | só o texto; sem efeito no plano |

Pergunte só o que a mudança não deixa claro, em blocos curtos, como no `sdd-prd`. Se ela é grande a ponto de reescrever o problema ou o objetivo do PRD, recomende um PRD novo (`PRD-XXX-tema-v2.md`, regra de `folder-conventions.md`) em vez de revisar.

## Passo 2 — Impacto, antes de editar qualquer coisa

Para cada ID tocado, siga a cadeia nos dois sentidos:

- `RN` → os `CA` que a provam → as telas (`UI`) que a mostram → as tarefas (`Implementa`/`Valida`) → os testes com o `CA-XX` no nome (`testing.ca_naming` do `config.yml`);
- ADRs citados pela regra ou pelas tarefas — se a mudança exige uma decisão nova ou contraria uma `Aceito`, **pare e indique o `/sdd-adr`** antes de seguir.

Mostre a tabela e espere a confirmação:

```markdown
| Mudança | ID | Tipo | Atinge | O que acontece |
| --- | --- | --- | --- | --- |
| Token expira em 15 min (era 30) | RN-02 | Altera | CA-03, UI-02.expirado, T-03 (Concluído), teste CA-03 | Nova tarefa T-09 ajusta o código e o teste |
| Login social sai do escopo | RN-07 | Revoga | CA-10, CA-11, T-06 (Pendente) | CA-10/11 revogados; T-06 vira Cancelado |
| Aviso por SMS | — | Acrescenta | — | RN-12, CA-18 novos; tarefa T-10 |
```

## Passo 3 — PRD

1. **Acrescenta:** RN e CA com os próximos números livres do PRD.
2. **Altera:** reescreva no lugar, mantendo o ID; se o sentido muda, o Gherkin do CA muda junto.
3. **Revoga:** risque como em "Revogando regras e telas" (`id-conventions.md`), com o motivo e, se houver, o ID que substitui.
4. Atualize a `**Data:**` do cabeçalho; o `**Status:**` continua `Aprovado` se o usuário aprovar a revisão agora, ou volta a `Em revisão` se ela precisa do aceite de outra pessoa.
5. Acrescente uma linha na seção **Revisões** (crie no fim do PRD, antes dos anexos, se ainda não existir):

```markdown
## Revisões

| Nº | Data | O que mudou | IDs | Motivo / origem |
| --- | --- | --- | --- | --- |
| 1 | 2026-10-12 | Token mais curto; login social fora do escopo; aviso por SMS | ~RN-02, ~CA-03, −RN-07, −CA-10, −CA-11, +RN-12, +CA-18 | Pedido do cliente (PROJ-140) |
```

Notação: `+` novo, `~` alterado, `−` revogado.

## Passo 4 — SPEC-UI (se houver)

Mesma lógica: telas e estados novos com os próximos números, alterados no lugar, removidos riscados; linhas na tabela de cobertura do PRD; uma linha na seção **Revisões** da SPEC-UI, com o mesmo número de revisão do PRD.

## Passo 5 — Plano

| Situação da tarefa atingida | O que fazer |
| --- | --- |
| `Pendente` e a mudança cabe nela | Edite `Implementa`/`Valida`/`Telas` e o critério no lugar; registre no histórico ("ajustada pela revisão 1 do PRD") |
| `Pendente` e perdeu o sentido (escopo revogado) | `**Status:** Cancelado` + linha no histórico com o motivo. O bloco fica, o número não volta |
| `Em andamento` | Pare e pergunte: terminar como estava e ajustar depois, ou ajustar agora |
| `Concluído` | **Nunca reabra.** Crie uma tarefa nova que ajusta o que foi entregue ("adaptar a T-03 à RN-02 revisada") |
| `Bloqueado` | Veja se a mudança resolve ou agrava o bloqueio; diga isso no histórico |

Tarefas novas vão para uma fase nova no fim — `### Fase N — Revisão 1 do PRD (2026-10-12)` —, com numeração contínua, `Depende de:` quando precisarem de algo já entregue, e as mesmas regras de tamanho e critério do `sdd-plan`. Se o plano estava `Concluído`, ele volta a `Em execução`.

## Passo 6 — Fechar

Mostre o diff de cada arquivo e peça confirmação antes de gravar (PRD, SPEC-UI e plano). Depois, na conversa:

- as tarefas novas e as canceladas;
- os testes que provavelmente mudam (os que carregam um `CA` alterado ou revogado) — quem mexe neles é o `/sdd-execute` das tarefas novas;
- o próximo passo: `/sdd-execute` na primeira tarefa elegível e, ao fim da fase, `/sdd-trace` para confirmar que nenhum elo quebrou.

## Não fazer

- Apagar uma regra, um cenário, uma tela ou uma tarefa. Revogar e cancelar deixam o rastro; apagar não.
- Reaproveitar o número de um ID revogado.
- Reabrir tarefa `Concluído` — o histórico dela é o registro do que foi entregue.
- Mudar o código ou os testes. Esta skill mexe nos documentos; o código muda pelas tarefas.
- Decidir sozinho uma questão de arquitetura que a mudança levanta — isso é `/sdd-adr`.
