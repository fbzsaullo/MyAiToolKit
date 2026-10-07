---
name: code-review
description: Code review avulso e configurável, para código próprio ou de colegas — pergunta contra qual branch comparar (detecta main/master/develop e sugere), pergunta se o review está ligado a uma história (aceitando o XML/JSON do card, a descrição em texto, o número da issue ou nenhuma), monta um roteiro de review sob medida a partir do docs/sdd/config.yml e dos checklists da stack (qualidade + segurança), verifica a cobertura dos critérios de aceite da história e entrega um relatório em que cada apontamento tem severidade (Bloqueante/Importante/Sugestão) e quadrante de urgência × importância (Q1 a Q4), além de comentários prontos para colar no PR. Use quando o usuário pedir "code review", "revisar meu código", "revisar a branch/PR do fulano", "review antes de abrir o PR" ou chamar /code-review (no Claude Code, /my-ai-toolkit:code-review se houver conflito com o comando nativo). Para revisar uma tarefa T-XX do plano SDD, use sdd-review.
argument-hint: "[branch, número do PR ou caminho de patch — opcional]"
allowed-tools: Read, Glob, Grep, Edit(docs/sdd/code-reviews/**)
---

# code-review — review sob medida, com história ou sem

Entrada: $ARGUMENTS (se o seu ambiente não substituir essa variável, use a mensagem do usuário).

Review de qualquer mudança, fora do fluxo do plano SDD: o seu código antes de abrir o PR, ou o código de um colega. A skill combina a configuração do projeto, os checklists da stack e — se houver — os critérios de aceite da história, e devolve apontamentos organizados por **o que fazer primeiro**.

Procedimento detalhado (o "roteiro" do review) em `references/review-procedure.md`.

## Passo 1 — Configuração

Leia `docs/sdd/config.yml`: stacks, versões, convenções de teste, `code_review.default_base_branch`, `code_review.tools` e `code_review.checklists`.

Sem `config.yml`: descubra a stack pela cascata de `${CLAUDE_PLUGIN_ROOT}/templates/stack-detection.md`, siga em **modo degradado** e sugira em uma linha:

> (Este projeto ainda não tem `docs/sdd/config.yml`. Rodar `/sdd-setup` deixa os próximos reviews calibrados — ferramentas, convenções e checklists certos.)

## Passo 2 — De quem é o código

Se a entrada não deixou claro, pergunte uma vez:

> O que vamos revisar?
>
> **A.** Meu trabalho na branch atual (`<branch atual>`)
> **B.** Outra branch (minha ou de um colega) — qual?
> **C.** Um Pull Request — número ou link
> **D.** Um patch/diff — caminho do arquivo ou colar aqui

O modo muda o tom do relatório: **próprio** (A, ou B/C/D quando o autor é o usuário) termina com checklist antes de abrir o PR; **de colega** termina com comentários prontos para colar, em tom construtivo.

Para B e C, a skill pode precisar de `git fetch` e `gh pr view/diff` — peça confirmação se o ambiente pedir. **Nunca** faça checkout que descarte alterações locais; prefira comparar referências remotas (`origin/<branch>`) sem trocar de branch.

## Passo 3 — Contra qual branch comparar

Detecte as candidatas (procedimento em `references/branch-detection.md`): a branch padrão do remoto (`origin/HEAD`), `main`, `master`, `develop`, `release/*` e a de `code_review.default_base_branch`. Depois **pergunte sempre**, já sugerindo a mais provável:

> Comparar com qual branch? Encontrei: **`main`** (padrão do remoto) · `develop` · `release/2026.10`. Sugiro `main`.

Com a resposta, monte o diff a partir do ponto em que as branches se separaram: `git diff <base>...<alvo>` (três pontos = desde o merge-base). Mostre o tamanho (arquivos, linhas, commits) antes de seguir. Diff vazio → avise e pare.

Diff muito grande (mais de ~1.500 linhas ou ~40 arquivos): avise que o review perde qualidade em diffs grandes e ofereça focar em pastas, commits ou tipos de arquivo.

## Passo 4 — Está ligado a uma história?

Pergunte:

> Esse código entrega alguma história/card?
>
> **A.** Sim — tenho o **XML/JSON** exportado do board (caminho do arquivo)
> **B.** Sim — vou **descrever em texto** (ou colar a descrição)
> **C.** Sim — é a **issue** número/link (GitHub)
> **D.** Não — review só do código

Para A, B e C, normalize com `${CLAUDE_PLUGIN_ROOT}/templates/card-ingestion.md` e extraia os **critérios de aceite**. Sem critérios explícitos no card, diga isso e pergunte se o usuário quer listar os principais — sem inventar.

Se a branch, os commits ou o card citarem `T-XX` e existir plano SDD, ofereça também `/sdd-review T-XX`, que cruza com PRD, ADRs e plano.

## Passo 5 — Montar o roteiro e revisar

Monte o roteiro **para este diff** (detalhes em `references/review-procedure.md`):

1. **Eixos universais:** correção, testes, qualidade, segurança — mais **aderência à história** quando houver card.
2. **Checklists da stack** de cada stack tocada pelo diff: `${CLAUDE_PLUGIN_ROOT}/stacks/<stack>/review-checklist.md` e `security-checklist.md` (ou o `_generic`).
3. **Convenções do projeto** do `AGENTS.md`/`CLAUDE.md` — elas ganham dos checklists em caso de conflito.
4. **Ferramentas** de `code_review.tools` (lint, análise de segurança, testes relacionados), **somente sobre os arquivos do diff** e **somente com confirmação** do usuário. Resultado entra como evidência; alerta de ferramenta é confirmado no código antes de virar apontamento.

Apresente o roteiro em poucas linhas antes de executar ("vou revisar 14 arquivos Ruby e 3 views com os checklists de Rails, verificar os 4 critérios do card PROJ-123 e, se você permitir, rodar rubocop e brakeman só nesses arquivos").

## Passo 6 — Classificar cada apontamento

Cada `CR-XX` recebe **duas** classificações (detalhes em `references/quadrants.md`):

**Severidade** — o impacto:
- `Bloqueante` — não deve ir para a branch base assim (bug, falha de segurança, critério de aceite não atendido, teste quebrado)
- `Importante` — precisa ser resolvido, agora ou em seguida
- `Sugestão` — melhoria opcional

**Quadrante** — o que fazer primeiro:

| | **Importante** | **Não importante** |
| --- | --- | --- |
| **Urgente** | **Q1 — Corrigir antes do merge** | **Q3 — Ajuste rápido agora** |
| **Não urgente** | **Q2 — Planejar (vira card/tarefa)** | **Q4 — Opcional / detalhe** |

- *Urgente* = precisa de ação antes deste merge (bloqueia o PR, quebra o CI, causa dano assim que entrar).
- *Importante* = afeta correção, segurança, dados, a história ou a manutenção de forma relevante.

Os dois eixos são independentes: um lint quebrando o CI é `Sugestão` em impacto mas urgente (Q3); uma dívida de desenho real é `Importante` mas pode esperar (Q2).

## Passo 7 — Relatório

Use `references/cr-template.md` e salve em `docs/sdd/code-reviews/CR-<branch>-AAAA-MM-DD.md` (barras viram hífen; mesmo dia → `-2`, `-3`). Se o usuário preferir não versionar, entregue só na conversa.

O relatório traz:
- matriz resumo Urgente × Importante com as contagens;
- apontamentos **agrupados por quadrante (Q1 → Q4)**, cada um com severidade, eixo, evidência (`arquivo:linha`) e sugestão;
- tabela de cobertura dos critérios de aceite (quando há história);
- resultado das ferramentas executadas;
- **modo colega:** comentários prontos para colar no PR, um por apontamento relevante, em tom respeitoso e específico;
- **modo próprio:** checklist do que fazer antes de abrir o PR.

**Veredito:**
- `⛔ Não pronto para merge` — há Q1
- `⚠️ Pronto com ajustes` — há Q3 (e/ou Q2 a registrar)
- `✅ Pronto` — só Q4 ou nada

Na conversa: veredito, a matriz de contagens, os itens de Q1 em destaque e o caminho do arquivo.

## Postura

- **Evidência sempre:** arquivo e linha, ou ausência verificável.
- **Só o diff:** código fora da mudança não é criticado (no máximo, uma nota se o diff piorar algo vizinho).
- **Sem formatação:** é trabalho do linter.
- **Mesmo rigor** para código próprio, de colega ou gerado por IA.
- **Construtivo com colegas:** aponte o problema e o caminho, sem julgamento pessoal; reconheça o que está bom.
- **Não altera código, não comenta no PR, não faz push.** O review gera relatório e comentários prontos; quem publica é o usuário.

## Material de apoio

- `references/review-procedure.md` — o roteiro completo
- `references/branch-detection.md` — detecção da branch base e montagem do diff
- `references/quadrants.md` — critérios de severidade e de quadrante, com exemplos
- `references/cr-template.md` — modelo do relatório
- `${CLAUDE_PLUGIN_ROOT}/templates/card-ingestion.md` — leitura de cards
- `${CLAUDE_PLUGIN_ROOT}/stacks/rails/review-checklist.md` e `security-checklist.md` — checklists de referência
