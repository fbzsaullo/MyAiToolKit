---
name: sdd-plan
description: Quebra um PRD aprovado em um plano de execução incremental, com tarefas T-XX pequenas (30min–4h), critérios de aceite testáveis, dependências, testes a escrever, complexidade e pontos de validação humana. Cada tarefa declara o que implementa (RN-XX), o que valida (CA-XX), em que decisões se apoia (ADR-XXX) e, se houver interface, quais telas e estados entrega (UI-XX). Opcionalmente registra uma estimativa por tarefa — sugerida pela IA, mas decidida e informada pelo usuário. Use quando o usuário pedir para "criar o plano", "quebrar o PRD em tarefas", "planejar a implementação", "decompor a funcionalidade" ou "fazer o planning técnico". Fase 4 do pipeline SDD do MyAiToolKit; o plano é o que o sdd-execute consome. Não inclui datas, cronograma nem alocação de pessoas.
argument-hint: "[caminho do PRD — opcional]"
allowed-tools: Read, Glob, Grep, Edit(docs/sdd/plans/**)
---

# sdd-plan — plano de execução

Entrada: $ARGUMENTS (se o seu ambiente não substituir essa variável, use a mensagem do usuário).

O plano é o roteiro de quem vai implementar — gente do time ou um agente de IA. Cada tarefa precisa ser pequena o bastante para virar um commit, ter critério de aceite verificável e dizer quais testes escrever. A pergunta que o plano responde é: **o que fazer, em que ordem e como saber que terminou**. Datas, cronograma e quem pega cada tarefa ficam com a gestão do time.

## Como a skill trabalha

1. **Conversa** — conferir se o PRD dá base suficiente para decidir ordem, dependências e testes. O que faltar, perguntar.
2. **Plano** — gerar o documento a partir de `references/plan-template.md`.
3. **Estimativa (opcional)** — se o usuário quiser, sugerir horas por tarefa e registrar **apenas** o que ele decidir.

## Fase 1 — Conversa

O PRD já resolveu o quê e o porquê. Aqui a questão é como quebrar com segurança. Leia o PRD inteiro, `docs/sdd/config.yml`, o `AGENTS.md`/`CLAUDE.md` e a arquitetura antes de perguntar — só pergunte o que nenhum deles responde.

### Bloco 1 — Terreno técnico

- Stack e versões (normalmente já estão em `docs/sdd/config.yml`)
- Como o código está organizado: monolito convencional, módulos (engines, packwerk), serviços separados?
- A funcionalidade nasce do zero ou entra em código existente?
- Convenções da casa que mudam a ordem das tarefas (ex.: sempre começar pela migration, ou pelo contrato da API)

### Bloco 2 — Como vai para produção

- Uma entrega só ou várias? Precisa de feature flag ou lançamento escondido?
- Alguma parte pode ir para produção sozinha?
- Há dependência externa que pode atrasar uma parte (API de parceiro, design, decisão de negócio)?

### Bloco 3 — Testes

- Framework e convenções de teste (RSpec ou Minitest, factories ou fixtures, testes de sistema) — o `config.yml` costuma responder
- Cobertura mínima exigida? Algo dispensa teste?
- Há ambiente de homologação?
- Quem dá o aceite final (PO, QA, cliente, o próprio dev)?
- **Onde testar:** em que ponto a funcionalidade deve ser verificada? Prefira o ponto mais externo possível (requisição, job, objeto de serviço público) e um que já seja usado em funcionalidades parecidas. Quanto menos pontos diferentes, mais os testes resistem a refatorações internas.

### Bloco 4 — Riscos

- Há código frágil ou sem teste no caminho?
- Alguma decisão de arquitetura ainda aberta que pode mudar a quebra? Se sim, sugira resolver antes com `sdd-architect` (que também registra um ADR isolado em `docs/sdd/architecture/adrs/`).
- Vai mexer em dados de produção que exigem migração ou backfill?

### Quando parar

Quando nenhuma tarefa depender de uma decisão que ainda não foi tomada. Se o usuário pedir para gerar mesmo assim, gere e registre cada suposição na seção de premissas, citando-a nas tarefas afetadas:

> ⚠️ **Premissa:** [o que foi assumido]

## Fase 2 — Plano

Leia `references/plan-template.md` antes de escrever. Salve em `docs/sdd/plans/PLAN-XXX-tema.md`, com **o mesmo número do PRD**.

### Corte horizontal ou vertical

O padrão é cortar por camada técnica (base → regras → exposição → interface → qualidade). O motivo e o custo dessa escolha estão em `${CLAUDE_PLUGIN_ROOT}/REFERENCES.md`, seção "Corte por camada como padrão" — leia antes de desviar.

Mude para corte vertical **apenas na parte do plano afetada** quando a conversa mostrou que:

- partes **precisam** ir para produção separadas, ou a entrega é de fato incremental (Bloco 2); ou
- existe risco concreto de integração — dependência externa instável, contrato entre times nunca testado na prática (Bloco 4).

No corte vertical, cada `T-XX` atravessa as camadas necessárias para fechar **um** `CA-XX` de ponta a ponta: primeiro o caminho feliz, depois erros e casos de borda. Formato no Exemplo 6 de `references/task-examples.md`.

Avise o usuário de duas coisas ao propor:

1. O corte vertical gera **mais** tarefas, não menos — o teto de 4h obriga a separar por comportamento. O ganho é ver funcionando cedo e reduzir surpresas de integração.
2. Uma tarefa vertical toca várias camadas numa execução só. Por isso o alerta "mexe em mais de 3 camadas → dividir" de `task-examples.md` não vale para ela (a exceção está registrada lá).

Sem esses gatilhos, fique no corte por camada — ele é o padrão, não uma alternativa equivalente.

### Material de apoio

- `references/task-examples.md` — tarefas de referência (estrutura, regra, exposição, observabilidade, feature flag, corte vertical) em pseudocódigo, com o preenchimento correto dos campos de rastreio e um guia de tamanho
- `${CLAUDE_PLUGIN_ROOT}/stacks/rails/task-examples.md` — os mesmos exemplos em Rails real
- `${CLAUDE_PLUGIN_ROOT}/stacks/rails/pipeline-example.md` — demanda completa; mostra de onde vêm `Implementa`, `Valida`, `Decisões base` e `Telas`

## Fase 3 — Estimativa (opcional)

Só acontece se o usuário quiser. Pergunte uma vez, ao terminar o plano: "Quer registrar uma estimativa por tarefa?"

Se sim:

1. Se existir um spike do mesmo card em `docs/sdd/spikes/`, use-o como referência.
2. **Sugira** um valor para cada tarefa e a soma, com a premissa de cada número. Use `${CLAUDE_PLUGIN_ROOT}/stacks/<stack>/spike-heuristics.md` quando houver. Mostre em tabela:

   | Tarefa | Sugestão | Premissa |
   | --- | --- | --- |
   | T-01 | 1h | migration simples, sem backfill |
   | T-02 | 3h | regra com 3 cenários e concorrência |
   | **Total** | **4h** | |

3. **Peça o valor do usuário** — por tarefa, só o total, ou um "aceito a sugestão" explícito.
4. **Grave somente o que o usuário informou** no campo `**Estimativa:**` de cada tarefa. Se ele deu só o total, grave o total no cabeçalho do plano e deixe os campos das tarefas vazios.
5. Se ele não responder, os campos ficam vazios. Silêncio não é aceite.

A sugestão da IA nunca vai para o arquivo. Regra completa em `${CLAUDE_PLUGIN_ROOT}/templates/id-conventions.md`, "Horas: quem decide é o usuário".

## Regras de escrita

- **Idioma** — o `language` de `docs/sdd/config.yml` (padrão `pt-BR`). Termos técnicos consagrados (migration, job, endpoint, controller) podem ficar em inglês.
- **Numeração** — `T-01` … `T-NN`, contínua no plano inteiro; não reinicia por fase. Um plano novo no mesmo projeto continua da maior `T` de todos os planos (inclusive o `PLAN-000-correcoes.md`).
- **Status** — o campo `**Status:**` de cada tarefa aceita somente `Pendente`, `Em andamento`, `Concluído`, `Bloqueado` ou `Cancelado`, escritos por extenso e sem emoji. Toda tarefa nasce `Pendente`; `Cancelado` só entra quando o escopo muda (`sdd-change`).
- **Tarefa estrutural** — tarefa que não coloca regra em código (projeto, infraestrutura, documentação) escreve `**Implementa:** estrutural — <motivo>` e, de preferência, cita o ADR em `Decisões base`. Campo vazio, sem `estrutural`, é tarefa sem rastro. `sdd-next` e `sdd-trace` leem esse texto literalmente.
- **Checkbox** — `- [ ]` / `- [x]` em critérios de aceite, testes transversais, prontidão e pontos em aberto. **Nunca** no status: duas representações do mesmo estado acabam se contradizendo.
- **Tamanho** — tudo dentro do teto de **30min a 4h** (regra de `T-XX` em `templates/id-conventions.md`):
  - *pequena* (um commit, ~30min–2h): mudança isolada com teste óbvio — "criar o model Consulta com validações";
  - *média* (PR curto, 2h–4h): partes acopladas que não faz sentido separar — "objeto de serviço + validações + testes do agendamento";
  - *acima de 4h*: divida, sempre.
  A faixa serve para cortar, não para prever prazo — não vai escrita na tarefa (o campo `Estimativa` é outra coisa, e só o usuário preenche).
- **Complexidade** — `Baixa`, `Média` ou `Alta`, pelo risco e pelo desconhecido, não pelo tamanho. Tarefa pequena em código legado frágil pode ser `Alta`; CRUD médio pode ser `Baixa`.
- **Mermaid** no mapa de dependências quando houver mais de 5 tarefas; abaixo disso, lista em texto.
- **Interface** — com SPEC-UI, leia `docs/sdd/prototype/SPEC-UI-XXX-*.md` antes de decompor a fase de interface: a lista de telas dimensiona as tarefas e a seção de componentes repetidos evita duplicação. Tarefas de interface preenchem `Telas: UI-02 (default, ocupado)`. Sem SPEC-UI, omita o campo e use os fluxos do PRD.
- **Rastreio** — `Implementa:` lista as `RN-XX` que a tarefa coloca em código; `Valida:` lista os `CA-XX` que ficam verdes; `Decisões base:` lista os `ADR-XXX` que ela materializa (somente ADRs `Aceito`). É isso que permite responder "mudou a RN-05: que tarefas e testes são afetados?".
- **Testes** — os nomes seguem a convenção do perfil da stack registrada em `docs/sdd/config.yml` (ex.: `it "CA-03: ..."` em RSpec).

## Fica de fora do plano

- **Datas e prazos** — o plano trata de ordem e dependência.
- **Nomes de pessoas** — quem pega cada tarefa é decisão do dia a dia do time.
- **Horas sugeridas pela IA** — somente o valor informado pelo usuário, no campo `Estimativa`.
- **Código pronto** — nomes de arquivos e classes sugeridos, sim; implementação, não.
- **Decisões de arquitetura novas** — o plano consome decisões, não cria. Surgindo uma, pare, registre em "Pontos em aberto" com `bloqueia: T-XX` e sugira `sdd-architect`.
- **Repetição do PRD** — cite `RN-XX`, não copie a regra.

## Situações comuns

**Usuário cola o PRD** — leia inteiro antes de perguntar; pergunte só o que ele não responde.

**Não existe PRD** — sugira `sdd-prd` antes. Planejar sem PRD faz os requisitos aparecerem durante a implementação, que é o momento mais caro. Se o usuário insistir, registre nas premissas que o plano nasceu sem PRD.

**Funcionalidade pequena (1–3 tarefas)** — mantenha o modelo, comprimido: fases e mapa viram opcionais; critérios de aceite e testes por tarefa continuam obrigatórios.

**Atualizar um plano existente** — leia o plano atual, identifique o que já foi concluído e mostre a diferença proposta antes de reescrever. Nunca apague o histórico sem confirmação. Se a atualização nasce de uma mudança no PRD aprovado, o caminho é o `sdd-change`, que ajusta PRD, SPEC-UI e plano juntos.

**Tarefa grande demais** — divida antes de gravar. Sinais: mais de 3 critérios de aceite, critério que precisa de mais de 2 testes, descrição que pede "e também", mais de 4h na sua cabeça. Lista completa em `references/task-examples.md`.

**Código legado sem teste** — proponha antes uma tarefa de caracterização (testes que registram o comportamento atual), para que a mudança não quebre nada em silêncio.

**Refatoração de grande alcance** (renomear coluna usada em muitas consultas, mudar assinatura usada por vários chamadores) — não faça uma tarefa gigante. Use **expandir → migrar → contrair**:
1. *expandir* — a forma nova passa a existir ao lado da antiga; nada quebra;
2. *migrar* — os chamadores mudam em lotes (por módulo ou pasta), uma tarefa por lote, todas com `Depende de:` a expansão;
3. *contrair* — a forma antiga é removida, com `Depende de:` todos os lotes.
Cada tarefa deixa o CI verde sozinha, ao custo de mais tarefas.

**Plano para agente de IA** — seja ainda mais explícito em critérios de aceite e pontos de validação humana. O agente não tem o "isso está estranho, melhor perguntar"; precisa que a parada esteja escrita.

**Marcar andamento** — pedidos como "marca a T-04 como concluída" alteram só o necessário e acrescentam uma linha no histórico (com commit, se houver). A execução normal é responsabilidade do `sdd-execute`.

## Ao entregar

Antes de gravar, com SPEC-UI, confira a cobertura de interface — é o mesmo teste que o `sdd-trace` faz no fim, só que agora, quando corrigir é barato:

- toda tela `UI-XX` aparece em `Telas:` de alguma tarefa;
- todo estado `UI-XX.estado` da SPEC-UI aparece entre os parênteses de alguma tarefa (`Telas: UI-03 (default, erro)`). Tela citada sem estados não cobre os estados;
- o que ficar de fora entra numa tarefa ou é justificado nas premissas do plano.

Mostre o número de tarefas por fase, os pontos de validação humana e a primeira tarefa elegível. Sugira o próximo passo: `/sdd-execute` (ou `$sdd-execute` no Codex) para executar a primeira tarefa.
