---
name: sdd-start
description: Ponto de entrada do pipeline SDD do MyAiToolKit para uma demanda nova — descobre em que fase a demanda está (sistema novo, funcionalidade num sistema existente, PRD pronto esperando plano) e encaminha para a skill certa (sdd-architect, sdd-prd ou sdd-plan), parando para revisão ao fim de cada fase. Use quando o usuário disser "começar o SDD", "iniciar o pipeline", "tenho uma demanda nova", "por onde começo" ou chamar /sdd-start.
argument-hint: "[descrição curta da demanda — opcional]"
allowed-tools: Read, Glob, Grep, Edit(docs/sdd/architecture/**), Edit(docs/sdd/prds/**), Edit(docs/sdd/prototype/**), Edit(docs/sdd/plans/**)
---

# sdd-start — começar uma demanda

Demanda: $ARGUMENTS (se o seu ambiente não substituir essa variável, use a mensagem do usuário).

O pipeline SDD do MyAiToolKit tem estas fases:

1. **Arquitetura** — `sdd-architect`: proposta e ADRs
2. **Requisitos** — `sdd-prd`: PRD com regras (`RN`) e cenários (`CA`)
3. **Interface** *(opcional, só com telas)* — `sdd-prototype`: SPEC-UI com telas e estados (`UI`)
4. **Plano** — `sdd-plan`: tarefas executáveis (`T`)
5. **Execução** — `sdd-execute`: uma tarefa por vez
6. **Review** — `sdd-review`: valida cada tarefa entregue (`R`)

Execução e review se alternam, tarefa a tarefa, até o plano terminar. Em paralelo, `sdd-setup` prepara o contexto dos agentes, e `sdd-next` e `sdd-trace` mostram onde o projeto está.

## Antes de tudo

1. Verifique se existe `docs/sdd/config.yml`. Se não existir **e** o repositório já tiver código, sugira em uma linha rodar `/sdd-setup` antes ou depois — sem bloquear.
2. Se a demanda veio como card (arquivo XML/JSON, issue do GitHub), normalize com `${CLAUDE_PLUGIN_ROOT}/templates/card-ingestion.md` e use o resultado como entrada da fase escolhida.

## Descobrir o ponto de partida

Pergunte **uma vez**, com opções claras:

> Esta demanda é:
>
> **A.** Um sistema novo — começar pela arquitetura (arquitetura → PRD → plano)
> **B.** Uma funcionalidade num sistema cuja arquitetura já existe — ir para o PRD (PRD → plano)
> **C.** Algo que já tem PRD e só falta o plano — ir para o plano
> **D.** Não sei — me ajuda a decidir
> **E.** Um defeito para corrigir — ir para o fluxo de bug
> **F.** Uma mudança num PRD já aprovado — revisar o escopo

Conforme a resposta:

- **A** — siga a skill `sdd-architect`. Ao fim da proposta, pergunte se quer emendar no PRD; se sim, siga `sdd-prd`.
- **B** — pergunte se há proposta de arquitetura ou ADRs para ler (em `docs/sdd/architecture/` ou outro caminho). Leia o que houver e siga `sdd-prd`.
- **C** — peça o caminho do PRD, leia e siga `sdd-plan`.
- **D** — faça duas ou três perguntas curtas (já existe código? há decisões de arquitetura registradas? há PRD?) e proponha o ponto de entrada.
- **E** — siga a skill `sdd-bug`.
- **F** — siga a skill `sdd-change`. Se a mudança é só uma decisão de arquitetura, siga `sdd-adr`.

Depois do PRD, se houver interface, ofereça `sdd-prototype` antes do plano — sem obrigar.

## Onde os artefatos ficam

Sugira esta estrutura em projetos novos (detalhes em `${CLAUDE_PLUGIN_ROOT}/templates/folder-conventions.md`):

```
docs/sdd/
├── config.yml
├── architecture/
│   ├── proposta-arquitetural.md
│   └── adrs/ADR-001-*.md
├── prds/PRD-001-*.md
├── prototype/SPEC-UI-001-*.md      # só PRDs com interface
├── plans/PLAN-001-*.md
└── reviews/REVIEW-T-04-AAAA-MM-DD.md
```

Se o projeto já usa outra organização, respeite-a e registre a diferença no `AGENTS.md` via `/sdd-setup`.

## Regra de ouro

**Uma fase por vez, com parada para revisão.** O pipeline funciona porque cada fase gera um artefato que alguém revisa antes da próxima começar. Ao terminar cada fase: pare, mostre o resultado e pergunte se pode seguir.
