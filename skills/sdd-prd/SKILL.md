---
name: sdd-prd
description: Transforma uma demanda (ideia, conversa com cliente, card do board, funcionalidade pedida) em um PRD completo, com regras de negócio numeradas (RN-XX), critérios de aceite em Gherkin com IDs (CA-XX), hierarquia épico → funcionalidade → história e diagramas Mermaid. Use quando o usuário pedir para "escrever um PRD", "levantar requisitos", "especificar essa funcionalidade", "documentar a demanda", "detalhar essa história" ou quando trouxer uma demanda que precisa virar documento para o time implementar. Fase 2 do pipeline SDD do MyAiToolKit; os IDs RN/CA são consumidos pelo plano (sdd-plan) e pelo review (sdd-review). Não inclui estimativa, pontos ou complexidade.
argument-hint: "[descrição da demanda, caminho de um card ou de uma transcrição — opcional]"
allowed-tools: Read, Glob, Grep, Edit(docs/sdd/prds/**)
---

# sdd-prd — requisitos da funcionalidade

Entrada: $ARGUMENTS (se o seu ambiente não substituir essa variável, use a mensagem do usuário).

O PRD existe para que quem vai implementar **não precise adivinhar**. Ele é escrito para devs: preciso o suficiente para eliminar dúvida, enxuto o suficiente para ser lido inteiro. Responde a duas perguntas — **o que** será feito e **por que**. Quanto custa e quando fica pronto são assuntos de outro momento (o `/spike` e o planejamento do time).

## Como a skill trabalha

1. **Conversa** — reunir material até ser possível escrever todas as seções obrigatórias sem inventar nada.
2. **Documento** — gerar o PRD a partir de `references/prd-template.md`.

Se a demanda veio como card exportado (XML/JSON do Jira, issue do GitHub etc.), normalize antes com `${CLAUDE_PLUGIN_ROOT}/templates/card-ingestion.md` e use o card como ponto de partida da conversa — sem repetir perguntas que ele já responde.

## Fase 1 — Conversa

Pergunte em blocos, do porquê para o como. Nada de despejar a lista inteira.

### Bloco 1 — A dor

- Que problema isso resolve e quem sofre com ele hoje?
- Em qual produto, sistema ou módulo a mudança acontece?
- Como as pessoas lidam com isso hoje? Já existe algum processo ou tela parecida?
- O que acontece se a demanda não for feita?

### Bloco 2 — O resultado e os limites

- Quando estiver pronto, o que muda? (uma frase)
- Quais perfis de usuário são afetados?
- O que **entra** nesta entrega?
- O que **não entra**? (tão importante quanto o que entra)
- Há alguma demanda parecida que pode ser confundida com esta e precisa ficar explicitamente de fora?

### Bloco 3 — O comportamento

- Que regras o sistema precisa respeitar? (validações, limites, condições, exceções)
- Qual o caminho principal? E os desvios e erros?
- Quem pode ver e fazer o quê?
- Há exigência legal ou regulatória envolvida (LGPD, normas do setor)?

### Bloco 4 — Dados e integrações

- Algum sistema externo ou outro módulo participa?
- Que dados são lidos? Quais são gravados?
- Algum evento é publicado ou consumido?

### Bloco 5 — Aceite e riscos

- Como vamos saber que ficou pronto? (critérios em linguagem livre; depois viram Gherkin)
- Que riscos já se conhecem (técnicos, de negócio, de dependência)?
- Depende de outro time, fornecedor ou decisão ainda não tomada?

### Quando parar

Pare quando nenhuma seção obrigatória do modelo ficaria vazia ou genérica. Nem toda pergunta precisa de resposta — integração, por exemplo, pode simplesmente não existir.

Se o usuário pedir para gerar mesmo com lacunas, gere, mas marque cada suposição de forma visível:

> ⚠️ **Premissa:** [o que foi assumido e por quê]

Nunca use `[A DEFINIR]`.

## Fase 2 — Documento

Leia `references/prd-template.md` antes de escrever. Ele define todas as seções, quais são obrigatórias e em que ordem aparecem. Apoios:

- `references/gherkin-examples.md` — cenários de referência (caminho feliz, validação, regra violada, concorrência, integração, esquema com exemplos, permissão) e erros a evitar
- `${CLAUDE_PLUGIN_ROOT}/stacks/rails/pipeline-example.md` — uma demanda atravessando todas as fases; mostra como `RN-XX` e `CA-XX` deste PRD reaparecem em tela, tarefa e review

Salve em `docs/sdd/prds/PRD-XXX-tema.md` (numeração e nome em `${CLAUDE_PLUGIN_ROOT}/templates/folder-conventions.md`).

## Regras de escrita

- **Idioma** — segue o `language` de `docs/sdd/config.yml` (padrão `pt-BR`), inclusive títulos, regras e Gherkin. Termos técnicos consagrados (API, webhook, endpoint) podem ficar em inglês.
- **Gherkin no idioma do documento** — em pt-BR: `Funcionalidade`, `Cenário`, `Esquema do Cenário`, `Dado`, `Quando`, `Então`, `E`, `Mas`, `Exemplos`. Sem misturar com palavras-chave em inglês.
- **Mermaid** para fluxos, estados e visão técnica. Cada diagrama precisa caber numa tela; se crescer, divida.
- **Hierarquia sempre explícita** — épico → funcionalidade → história, mesmo quando tudo cabe numa funcionalidade só. Facilita cadastrar no board (Jira, GitHub Projects, Azure Boards).
- **IDs** — `RN-01`, `RN-02`… para regras; `CA-01`, `CA-02`… para cenários. São esses IDs que o plano cita (`Implementa: RN-03`, `Valida: CA-02`) e que os testes carregam no nome. Regras: `${CLAUDE_PLUGIN_ROOT}/templates/id-conventions.md`.
- **Ligação com a arquitetura** — se uma regra ou cenário existe por causa de uma decisão já registrada, cite o ADR entre parênteses: `RN-04: reserva expira em 15 minutos (ADR-003)`. Cite apenas ADRs que existem em `docs/sdd/architecture/adrs/`.

## Fica de fora do PRD

- Estimativas de qualquer tipo (horas, pontos, tamanhos de camiseta) e opinião sobre complexidade
- Detalhes de implementação que amarram o dev: biblioteca, nome de classe, padrão de código
- Prazos e cronograma

## Situações comuns

**Entrada é uma conversa ou transcrição** — extraia tudo o que der, identifique o que falta e pergunte só isso.

**Pedido de PRD "rápido"** — mantenha as seções obrigatórias e corte as opcionais. Regras de negócio e critérios de aceite nunca saem: são o motivo de o PRD existir.

**Revisar um PRD que já existe** — primeiro mostre o que falta em relação ao modelo; só reescreva depois de confirmar, principalmente se a mudança for estrutural. Se o PRD já está `Aprovado` e a mudança é de escopo, use o `sdd-change`: ele registra a revisão e leva a mudança para a SPEC-UI e o plano.

**Demanda grande demais** — proponha dividir em mais de um PRD (por funcionalidade ou por épico) e explique o critério da divisão.

## Ao entregar

Se o PRD tem interface (personas usando telas, fluxos de interação, cenários com ações em tela), **sugira** — sem executar — a fase de interface:

> Este PRD tem telas. Antes do plano, vale rodar `/sdd-prototype`: ele indexa um protótipo que você já tenha (ou gera um) e liga cada tela e estado às regras e cenários daqui. Assim o plano dimensiona melhor as tarefas de interface e o review consegue conferir se todos os estados foram implementados.

Sem interface (integração, job, API), siga direto para o plano com `sdd-plan`. A sugestão é opcional; ignorá-la não trava nada.
