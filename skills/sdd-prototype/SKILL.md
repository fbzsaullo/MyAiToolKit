---
name: sdd-prototype
description: Especifica a interface de um PRD na SPEC-UI — inventário de telas (UI-XX), estados de cada tela (UI-XX.estado) e o cruzamento de cada tela com as regras (RN-XX) e cenários (CA-XX) do PRD. Indexa um protótipo existente (views no repositório, HTML exportado, imagens, Figma via MCP, export de ferramentas de protótipo) ou gera um quando não houver. Use quando o usuário pedir para "especificar as telas", "documentar o protótipo", "criar um protótipo", "mapear as telas contra o PRD", "gerar a SPEC-UI" ou "ler o Figma", ou quando aceitar a sugestão de especificar a interface antes do plano. Fase 3 do pipeline SDD do MyAiToolKit, opcional — PRD sem interface (API, job, integração, biblioteca) pula a fase. Não faz design visual — delega tipografia, cores e composição a skills de frontend do ambiente. Nunca inventa tela ou estado que não veio do protótipo nem do PRD.
argument-hint: "[caminho do PRD e/ou do protótipo — opcional]"
allowed-tools: Read, Glob, Grep, Edit(docs/sdd/prototype/**)
---

# sdd-prototype — especificação de interface

Entrada: $ARGUMENTS (se o seu ambiente não substituir essa variável, use a mensagem do usuário).

A SPEC-UI responde a uma pergunta que o PRD não responde: **como cada regra aparece na tela**. Ela fica entre o PRD (o quê e por quê) e o plano (o que fazer, em que ordem). O que dá valor a ela não é a beleza do protótipo, e sim o vínculo explícito entre cada tela, cada estado e as regras e cenários que eles materializam — é isso que permite ao plano dimensionar o trabalho de interface e ao review conferir se nada ficou faltando.

## Compromissos

- **O protótipo existente manda.** Se há protótipo, ele é a fonte; gerar é plano B.
- **Nada inventado.** Tela ou estado sem origem no protótipo ou no PRD vira lacuna escrita, não suposição.
- **Origem sempre visível.** Cada tela e estado diz se foi extraído do protótipo, derivado do PRD ou gerado agora. Estado derivado não passou por design — quem implementa precisa saber.
- **Estrutura, não estética.** A skill decide quais telas e estados existem. Tipografia, paleta e composição ficam com skills de frontend do ambiente; sem nenhuma disponível, gera um wireframe funcional e diz isso.
- **Opcional de verdade.** Ausência de SPEC-UI nunca trava o pipeline.

## Passo 0 — A fase faz sentido?

Indícios de que **não** há interface a especificar:

- a arquitetura não tem container de frontend (só API, worker, job, CLI ou biblioteca);
- o PRD não tem seção de perfis de usuário nem fluxos de interação;
- os cenários falam apenas de comportamento de sistema (jobs, integrações, eventos), sem pessoa usando tela.

Nesse caso, avise e encerre, sem insistir:

> Este PRD não descreve telas — os cenários são de processamento e integração. A especificação de interface não se aplica; dá para seguir direto para o plano com `sdd-plan`.

Se só parte do PRD tem interface, especifique essa parte e registre o que ficou de fora e por quê.

## Passo 1 — Qual PRD

Se o caminho não veio na entrada, procure em `docs/sdd/prds/`. Havendo mais de um, pergunte. A SPEC-UI é **por PRD**: o mesmo projeto pode ter funcionalidades com e sem tela.

## Passo 2 — Qual modo

Pergunte uma vez:

> Como vamos tratar a interface?
>
> **A.** Já existe protótipo — indexar e cruzar com o PRD *(ingestão)*
> **B.** Não existe protótipo — gerar um *(geração)*
> **C.** Existe parte — indexar o que há e gerar o resto *(misto)*

O modo C é o mais comum na prática: as telas principais foram desenhadas, os estados de erro e as telas de administração não.

## Passo 3a — Ingestão

Procedimento por formato em `references/ingestion-guide.md`. Ordem sugerida: views/HTML no repositório → imagens → Figma via MCP → export de ferramentas de protótipo.

| Formato | O que sai sozinho | O que vai precisar perguntar |
| --- | --- | --- |
| Views no repositório (ERB, ViewComponent, Phlex, React, Vue) | Muito: rotas, partials/componentes, campos, condicionais de estado | Estados não implementados; intenção de negócio |
| HTML exportado / ferramentas de protótipo que geram código | Muito, como no caso anterior | Idem |
| Imagens | Médio: layout, campos, hierarquia, cores aproximadas | Navegação, estados que não aparecem, valores exatos |
| Figma via MCP | Muito: frames, camadas, componentes, tokens | Fluxo entre telas, comportamento dinâmico |

**Antes de perguntar qualquer coisa, diga onde você está cego.** Exemplo:

> Encontrei 5 telas nas imagens. Elas não me mostram:
> - para onde cada botão leva;
> - como ficam carregamento e erro;
> - os valores exatos das cores (vejo um verde escuro, mas não o código).
>
> Posso perguntar sobre isso, ou você prefere enviar mais material?

## Passo 3b — Geração

Detalhes em `references/generation-guide.md`. Fontes, da mais forte para a mais fraca:

1. **PRD** — perfis, fluxos, regras, cenários e permissões definem quais telas e estados existem;
2. **Arquitetura e `docs/sdd/config.yml`** — tecnologia de frontend (Hotwire, SPA, mobile), biblioteca de componentes obrigatória, acessibilidade, i18n;
3. **Repositório** — tokens, tema, layout e componentes já existentes: o protótipo **herda**, não reinventa;
4. **Perguntas** — só para o que as três fontes não responderam.

Com PRD e arquitetura bem feitos, normalmente sobram duas ou três perguntas. Identidade visual nunca é pergunta aberta ("que cores você quer?"): se há marca, peça referência; se há design system no repositório, siga-o; se não há nada, ofereça duas ou três direções concretas para escolher.

O visual é delegado: monte um briefing (arquétipo, telas, estados, tokens, restrições) e passe para a skill de frontend disponível. Sem uma, produza HTML simples focado em estrutura e estados e marque a fidelidade como wireframe.

## Passo 4 — Cruzar com o PRD

É o centro da fase. Para cada `UI-XX`:

- quais `RN-XX` se manifestam nela, e de que forma (validação, botão desabilitado, mensagem, regra de exibição);
- quais `CA-XX` acontecem nela — todo cenário precisa acontecer em algum lugar;
- quais estados ela precisa ter para comportar esses cenários (catálogo em `references/screen-states.md`).

Depois, percorra o caminho inverso — é aí que aparecem os problemas:

| Achado | O que significa | O que fazer |
| --- | --- | --- |
| `CA-XX` sem tela | Cenário sem lugar para acontecer | Apontar: pode ser cenário de backend (ok) ou tela faltando |
| `RN-XX` visível que não aparece | Regra que o usuário deveria perceber e não percebe | Apontar: tela provavelmente incompleta |
| Tela sem `RN` nem `CA` | Algo que o PRD não pediu | Apontar: escopo extra ou PRD incompleto |
| Cenário de erro sem estado | Falha prevista sem tela correspondente | Apontar: é a origem mais comum de bug de interface |

**Nunca crie a tela que falta só para a tabela ficar completa.** Registre a lacuna e deixe a decisão com o usuário: gerar a tela, ajustar o PRD ou aceitar fora do escopo.

## Passo 5 — Gravar

Use `references/spec-ui-template.md` e salve em `docs/sdd/prototype/SPEC-UI-XXX-tema.md`, com **o mesmo número do PRD**. Material visual vai em `docs/sdd/prototype/assets/`.

## IDs

`UI-XX` segue `${CLAUDE_PLUGIN_ROOT}/templates/id-conventions.md`: contador do projeto (a segunda SPEC-UI continua da maior `UI` da primeira), dois dígitos, sem reúso (tela removida fica marcada). Estados com sufixo: `UI-03.vazio`, `UI-03.erro`, `UI-03.carregando` — é assim que o plano e o review apontam um estado específico.

## Como as outras fases usam a SPEC-UI

- **`sdd-plan`** — tarefas de interface ganham o campo `Telas: UI-XX (estados)`; a lista de componentes reutilizáveis evita tarefas duplicadas.
- **`sdd-review`** — confere se cada estado declarado foi implementado e se os campos batem. Avalia estrutura, estados e comportamento, nunca estética.
- **`sdd-trace`** — `UI-XX` entra na cadeia `ADR → RN → CA → UI → T → R`.

## O que não vai na SPEC-UI

- Código de componente (é trabalho das tarefas)
- Regra de negócio reescrita — cite o `RN-XX`
- Medidas em pixel e escalas (moram no protótipo e no design system)
- Textos longos definitivos — rótulos e mensagens curtas, sim
- Telas hipotéticas ("talvez um relatório…")

## Quando sugerir esta skill

Outras skills apenas sugerem; esta só roda por pedido direto ou aceite:

| Momento | Quem sugere |
| --- | --- |
| PRD com interface pronto e sem SPEC-UI | `sdd-prd` ao terminar; `sdd-next` |
| Plano prestes a nascer para PRD com telas | `sdd-plan` |
| Review encontrou tela sem especificação | `sdd-review` |

Pulando a fase, o pipeline segue normalmente — as tarefas apenas não terão o campo `Telas:`.

## Ao final, informe

- Telas especificadas (`UI-01`…`UI-NN`) e a origem de cada uma
- Cobertura: quantas `RN-XX` e `CA-XX` do PRD aparecem em alguma tela
- Lacunas que precisam de decisão antes do plano
- Componentes reutilizáveis encontrados
- Próximo passo: `sdd-plan`, agora com `Telas:` disponível nas tarefas de interface

## Material de apoio

- `references/spec-ui-template.md` — modelo do documento
- `references/ingestion-guide.md` — extração por formato
- `references/generation-guide.md` — arquétipos, perguntas e delegação do visual
- `references/screen-states.md` — catálogo de estados e quais são obrigatórios
- `${CLAUDE_PLUGIN_ROOT}/stacks/rails/pipeline-example.md` — exemplo completo em Rails; mostra um `CA-XX` virando `UI-XX.estado` e sendo cobrado no plano e no review
