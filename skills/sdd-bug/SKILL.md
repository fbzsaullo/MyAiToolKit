---
name: sdd-bug
description: Fluxo curto do pipeline SDD para corrigir um defeito — recebe o relato (texto, card do Jira/GitHub, issue), separa o observado do esperado, descobre qual regra ou cenário do PRD o defeito descumpre (ou se falta especificação), investiga a causa provável no código sem alterá-lo, e transforma a correção em UMA tarefa T-XX de plano com teste de regressão, pronta para o /sdd-execute e o /sdd-review. Grava o relatório em docs/sdd/bugs/BUG-<CHAVE>-<tema>.md. Use quando o usuário pedir "corrigir um bug", "tem um defeito", "isso está quebrado", "investigar esse erro", "abrir uma correção" ou chamar /sdd-bug. Para mudança de escopo (o comportamento atual está certo, mas o pedido mudou), use sdd-change.
argument-hint: "[relato do defeito, caminho de um .xml/.json/.md, ou número/URL de issue — opcional]"
allowed-tools: Read, Glob, Grep, Edit(docs/sdd/bugs/**), Edit(docs/sdd/plans/**), Edit(docs/sdd/prds/**)
---

# sdd-bug — do relato à tarefa de correção

Entrada: $ARGUMENTS (se o seu ambiente não substituir essa variável, use a mensagem do usuário).

Bug não precisa de arquitetura, PRD novo nem plano inteiro. Precisa de quatro coisas: saber o que **deveria** acontecer, provar que **não** acontece (um teste que falha), corrigir e garantir que **não volta** (o mesmo teste, verde para sempre). Esta skill prepara isso e entrega uma tarefa pronta para o pipeline normal — `/sdd-execute` e `/sdd-review` não mudam.

## Bug ou mudança?

Antes de tudo: o comportamento atual **contraria o que foi combinado** (PRD, regra conhecida, contrato)? É bug. O comportamento atual **é o combinado**, mas agora querem outro? É mudança de escopo → `/sdd-change`. Na dúvida, mostre os dois caminhos e deixe o usuário escolher.

## Passo 1 — O relato

1. Card exportado? Normalize com `${CLAUDE_PLUGIN_ROOT}/templates/card-ingestion.md`.
2. Chave do bug: a do card (`BUG-PROJ-88`, `BUG-GH-45`) ou o próximo sequencial em `docs/sdd/bugs/` (`BUG-001`).
3. Separe e confirme, perguntando só o que faltar:
   - **Observado** — o que acontece, com mensagem de erro, log ou print, se houver;
   - **Esperado** — o que deveria acontecer, e **segundo quem** (PRD, regra de negócio, contrato de API, bom senso declarado pelo usuário);
   - **Como reproduzir** — passos, dados, ambiente, versão;
   - **Frequência** — sempre, às vezes, uma vez;
   - **Gravidade** — `Impede o uso` / `Contornável com esforço` / `Incômodo`. Se `Impede o uso` em produção, pergunte se há contenção imediata (desligar uma flag, reverter um deploy) e registre como recomendação, separada da correção.

## Passo 2 — Onde está o combinado

Procure em `docs/sdd/prds/` a regra e o cenário que cobrem o comportamento:

| Situação | O que significa | Consequência |
| --- | --- | --- |
| Um `CA` já descreve o certo | O código descumpre o combinado | A tarefa **valida esse CA**; o teste de regressão leva o `CA-XX` no nome. Se já existe teste com esse CA e ele passa, o teste estava incompleto — diga isso |
| Uma `RN` cobre, mas nenhum `CA` prova o caso | Lacuna de cenário | Proponha um `CA` novo (próximo número), registrado como revisão do PRD — mesmas regras do `sdd-change`, com o motivo `BUG-<CHAVE>` |
| Nada no PRD cobre | Lacuna de especificação | Proponha `RN` + `CA` novos, como acima. Se o usuário preferir não mexer no PRD, siga sem eles e registre a lacuna no relatório |
| Projeto sem PRD | Fora do pipeline de requisitos | O esperado declarado pelo usuário fica no relatório; o teste leva a chave do bug no nome (`it "BUG-PROJ-88: ..."`, no formato de `testing.ca_naming`) |

Mexer no PRD exige confirmação, com o diff da seção de regras e critérios e a linha na seção **Revisões**.

## Passo 3 — Causa provável

Leia o código do caminho reproduzido. **Não altere nada.** Liste:

- a hipótese principal, com evidência (`arquivo:linha`) e o raciocínio;
- hipóteses alternativas, se houver, e o que as descartaria;
- a confiança (`alta` / `média` / `baixa`) — com `baixa`, o primeiro passo da tarefa é confirmar a causa;
- outros pontos do código com o mesmo padrão (o defeito pode existir em mais de um lugar).

Use `git log` e `git blame` (só leitura) quando ajudarem a datar o defeito: um commit ou uma tarefa `T-XX` que o introduziu vale ser citado.

## Passo 4 — A tarefa

Uma tarefa só, no formato de `${CLAUDE_PLUGIN_ROOT}/skills/sdd-plan/references/plan-template.md`:

- **Onde:** no plano do PRD atingido, numa fase `### Fase N — Correções` (crie no fim se não existir); sem PRD, em `docs/sdd/plans/PLAN-000-correcoes.md`, um plano permanente só de correções (crie a partir do modelo, com cabeçalho mínimo, se não existir).
- **Numeração:** a próxima `T-XX` livre do projeto (a maior de todos os planos, mais um).
- **Implementa / Valida:** a `RN` e o `CA` do Passo 2. Sem PRD: `Implementa: estrutural — correção do BUG-<CHAVE>`.
- **Critério de aceite:** o teste de regressão **falha antes** da correção e passa depois; os testes existentes continuam verdes.
- **Testes a escrever:** o teste de regressão, com o nome definido no Passo 2.
- **Arquivos/camadas:** os do diagnóstico.
- Defeito grande demais para 30min–4h? Divida em tarefas (contenção, correção, limpeza) — a regra de tamanho do kit vale aqui também.

Mostre a tarefa e peça confirmação antes de gravar no plano.

## Passo 5 — O relatório

Grave `docs/sdd/bugs/BUG-<CHAVE>-<tema>.md` com `references/bug-template.md`, apontando para a tarefa criada. Ele guarda o que o plano não guarda: o relato, a reprodução e o diagnóstico.

## Passo 6 — Próximo passo

`/sdd-execute T-XX` — o execute começa pelo teste que reproduz o defeito. Depois, `/sdd-review T-XX`, que entrega a mensagem de commit (normalmente do tipo `fix`). O kit não commita.

## Não fazer

- Corrigir o código aqui. O diagnóstico aponta; a correção é do `/sdd-execute`, com teste primeiro.
- Tratar mudança de escopo como bug — isso esconde a decisão do PRD.
- Criar teste de regressão sem nome rastreável (`CA-XX` ou chave do bug).
- Inventar a causa: hipótese sem evidência é marcada como hipótese, com confiança baixa.
