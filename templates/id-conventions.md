# Identificadores do MyAiToolKit

Todo artefato produzido pelo toolkit se conecta aos demais por meio de identificadores curtos. Este arquivo é o contrato desses identificadores: quem cria cada um, como ele é numerado e de que jeito deve ser citado. Qualquer skill que leia ou escreva artefatos (`sdd-architect`, `sdd-prd`, `sdd-prototype`, `sdd-plan`, `sdd-execute`, `sdd-review`, `sdd-trace`, `sdd-next`, `sdd-setup`, `spike`, `code-review`) segue o que está aqui.

## Catálogo

### Pipeline SDD

| Prefixo | O que identifica | Arquivo de origem | Quem consome |
|---------|------------------|-------------------|--------------|
| `ADR-XXX` | Uma decisão de arquitetura | `docs/sdd/architecture/adrs/ADR-XXX-*.md` (um arquivo por decisão) | PRD, plano (`Decisões base`), review |
| `RN-XX` | Uma regra de negócio | PRD, seção de regras | Gherkin do próprio PRD, plano (`Implementa`), review |
| `CA-XX` | Um critério de aceite, escrito como cenário Gherkin | PRD, seção de critérios | Plano (`Valida`), testes automatizados, review |
| `UI-XX` | Uma tela; com sufixo, um estado dela (`UI-03.vazio`) | SPEC-UI | Plano (`Telas`), review |
| `T-XX` | Uma tarefa executável | Plano | Outras tarefas (`Depende de`), histórico do plano, review |
| `R-XX` | Um apontamento de review SDD | `REVIEW-T-XX-*.md` | Rounds seguintes, plano (quando bloqueia) |

### Ferramentas fora do pipeline

| Prefixo | O que identifica | Arquivo de origem | Quem consome |
|---------|------------------|-------------------|--------------|
| `SPIKE-<CHAVE>` | Uma análise de esforço | `docs/sdd/spikes/SPIKE-<CHAVE>-*.md` | Plano (insumo opcional da `Estimativa`), o próprio card |
| `CR-XX` | Um apontamento de code review avulso | `docs/sdd/code-reviews/CR-*.md` | Conversa, comentários de PR |

`<CHAVE>` reaproveita a chave que o card já tem no board (`PROJ-123`, `GH-45`). Quando a demanda chega como texto solto, usa-se um sequencial de três dígitos: `SPIKE-001`, `SPIKE-002`.

## Como numerar

### Regras gerais

1. **Um contador por documento, sem reinício.** Se o plano tem fases, a fase 2 continua de onde a fase 1 parou (`T-08`, `T-09`…), nunca volta para `T-01`.
2. **Zero à esquerda.** Dois dígitos no mínimo (`RN-07`, `CA-12`) para que a ordenação alfabética coincida com a numérica. `ADR` é a exceção: usa três (`ADR-004`).
3. **Número gasto não volta.** Item removido continua ocupando o número, marcado como revogado. Reaproveitar um ID faz referências antigas apontarem para outra coisa sem ninguém perceber.
4. **Nada de renumerar.** Precisa reorganizar? Acrescente itens novos ao final. A ordem visual importa menos que a estabilidade das referências.

### Onde o ID é único

`ADR`, `RN`, `CA`, `UI` e `T` são únicos dentro do projeto (ou do par PRD/plano a que pertencem). `R` e `CR` não: cada relatório de review começa de novo em `01`, porque existe um relatório por tarefa, por round ou por branch. Por isso esses dois prefixos **sempre** levam o nome do relatório quando citados fora dele.

### Particularidades de cada prefixo

**`ADR-XXX`** — O nome do arquivo começa pelo ID (`ADR-004-fila-com-solid-queue.md`) e a citação usa exatamente esse prefixo. Uma proposta inicial costuma ter entre 5 e 12 decisões; muito além disso é sinal de que escolhas sem trade-off real estão virando ADR. O ciclo de vida está em "Status de um ADR".

**`RN-XX`** — Uma regra precisa poder ser verificada por teste. Quando provar uma regra exige vários cenários independentes, ela provavelmente esconde duas regras.

**`CA-XX`** — Vive no título do cenário Gherkin, entre colchetes: `Cenário [CA-04]: pedido acima do limite é recusado`. Os colchetes fazem parte do formato. A contagem é única no PRD inteiro, não por funcionalidade.

**`T-XX`** — Uma tarefa deve caber entre **30 minutos e 4 horas** de trabalho, o equivalente a um commit ou a um PR curto. Passou disso, divida; ficou abaixo de uns 10 minutos, junte com a vizinha. Mais de três critérios de aceite costuma indicar tarefa grande demais. Essa faixa é o único limite de tamanho do toolkit — o `sdd-plan` e os exemplos de tarefa usam ela como régua. Ela serve para **cortar** o trabalho, não para prever prazo: o plano guarda `Complexidade` (`Baixa` / `Média` / `Alta`) e, se o usuário quiser, uma `Estimativa` que ele mesmo informa (ver "Horas: quem decide é o usuário").

**`UI-XX`** — Contador único na SPEC-UI. O estado vem depois de um ponto (`UI-03.carregando`, `UI-03.erro`), o que permite à tarefa declarar `Telas: UI-03 (default, erro)` e ao review conferir estado por estado. Tela abandonada mantém o número, marcada como removida.

**`R-XX`** — Recomeça em `R-01` em cada `REVIEW-T-XX-*.md`, inclusive no segundo round da mesma tarefa. A ligação entre rounds é feita pela seção "Round anterior" do relatório, nunca pela coincidência de números. Fora do relatório, cite assim: `R-02 (REVIEW-T-06-2026-10-12)`; para vários do mesmo arquivo, `R-01, R-04 (REVIEW-T-06-2026-10-12)`. Escrever apenas "o R-02 da T-06" não basta — a T-06 pode ter mais de um round.

**`CR-XX`** — Segue a lógica do `R-XX`: recomeça a cada relatório do `/code-review` e, fora dele, é citado com o nome do arquivo: `CR-03 (CR-feature-carrinho-2026-10-06)`.

## Status de um ADR

O arquivo de cada ADR traz um campo `**Status:**` com um destes valores:

| Valor | Quando usar |
|-------|-------------|
| `Proposto` | A decisão foi escrita mas ainda não foi validada. |
| `Aceito` | Decisão em vigor; o código precisa respeitá-la. |
| `Substituído por ADR-XXX` | Uma decisão mais nova tomou o lugar desta. O arquivo fica, como registro. |
| `Descontinuado` | Deixou de fazer sentido e nada a substituiu. |

O review só cobra ADRs `Aceito`. Para o `sdd-trace`, uma tarefa apoiada em ADR que não está `Aceito` é um gap a ser reportado.

## Status de uma tarefa

O campo `**Status:**` dentro de cada bloco `#### T-XX` aceita quatro valores, e só eles. O idioma acompanha o `language` de `docs/sdd/config.yml` (padrão `pt-BR`) e não muda no meio de um plano:

| pt-BR | en | Quando usar |
|-------|----|-------------|
| `Pendente` | `Pending` | Valor inicial; ninguém começou. |
| `Em andamento` | `In progress` | Começou e ainda não terminou. |
| `Concluído` | `Done` | Critérios de aceite cumpridos e testes verdes. |
| `Bloqueado` | `Blocked` | Algo impede o avanço: dependência, decisão pendente ou apontamento Bloqueante de review. |

Caminho normal: `Pendente` → `Em andamento` → `Concluído`. Qualquer estado pode cair em `Bloqueado`; quando o impedimento é resolvido, a tarefa volta para onde estava.

Esses valores são lidos por máquina. `sdd-next` e `sdd-trace` procuram o texto exato; uma tarefa marcada como `Feita`, `OK` ou `✅` simplesmente não é encontrada. Como o plano é o único registro de execução, uma tarefa que ele não descreve corretamente deixa de existir para o restante do toolkit.

### Não confundir os "Status"

A palavra aparece em quatro contextos, com listas de valores diferentes — e alguns valores se repetem entre eles:

| Contexto | Localização | Valores aceitos |
|----------|-------------|-----------------|
| Documento | Cabeçalho do PRD, da SPEC-UI ou do plano | PRD e SPEC-UI: `Rascunho` / `Em revisão` / `Aprovado`. Plano: `Rascunho` / `Em execução` / `Concluído` |
| Tarefa | `**Status:**` dentro de `#### T-XX` | `Pendente` / `Em andamento` / `Concluído` / `Bloqueado` |
| Review | Recomendação final do relatório | `Aprovado` / `Aprovado com ressalvas` / `Bloqueado` |
| ADR | `**Status:**` no arquivo do ADR | `Proposto` / `Aceito` / `Substituído por ADR-XXX` / `Descontinuado` |

Regra de leitura: um `Status:` que aparece antes do primeiro `#### T-XX` de um plano é do documento, não de uma tarefa. Em texto corrido, diga qual deles está em jogo — "a tarefa está com `Status: Bloqueado`", "o review saiu com `Recomendação: Bloqueado`". Emojis (✅ ⚠️ ⛔) são bem-vindos em tabelas e no resumo do review, mas nunca dentro do campo de status da tarefa.

## Horas: quem decide é o usuário

Nenhuma skill grava estimativa por conta própria. Sempre que houver horas envolvidas — no `/spike` e no campo opcional `**Estimativa:**` de uma tarefa — o fluxo é:

1. **A IA sugere.** Mostra quanto cada parte deve levar e a soma, explicando de onde veio cada número.
2. **O usuário responde.** Informa o tempo que considera certo para cada parte, para o total, ou confirma a sugestão de forma explícita.
3. **O arquivo recebe só a resposta do usuário.** A sugestão da IA fica registrada apenas na conversa.

Sem resposta do usuário, o campo fica em branco. Silêncio não é aceite.

## Revogando regras e telas

Uma regra ou tela que deixou de valer não é apagada — é riscada e aponta para o que a substitui:

```markdown
### RN-06: ~~Cupom vale apenas na primeira compra~~ (revogada — ver RN-14)

[o texto original permanece abaixo, como histórico]
```

ADRs não são riscados: a revogação acontece pelo próprio campo de status (`Substituído por ADR-009`). Em ambos os casos o número continua reservado e quem seguir uma referência antiga encontra o motivo da mudança.

## Citando um ID em outro documento

### Formato

A referência vai entre parênteses, logo depois do trecho que ela justifica:

- Regra no PRD que nasce de uma decisão: `RN-02: reserva de estoque expira em 15 minutos (ADR-003)`
- Passo de cenário que exercita uma regra: `E o carrinho tem itens reservados (RN-02)`
- Estado de tela derivado de um cenário: `UI-04.reservaExpirada` (vem do `CA-06`, que prova a `RN-02`)
- Campos de uma tarefa no plano:
  - `Implementa: RN-02, RN-05` — regras que a tarefa coloca em código
  - `Valida: CA-06, CA-07` — cenários que passam a ficar verdes
  - `Decisões base: ADR-003` — decisão que a tarefa materializa
  - `Telas: UI-04 (default, reservaExpirada)` — telas e estados entregues

### A cadeia completa

Do mais abstrato ao mais concreto:

```
ADR-XXX  decisão de arquitetura
   ↓ motiva
RN-XX    regra de negócio
   ↓ é demonstrada por
CA-XX    cenário Gherkin
   ↓ aparece na interface como (opcional)
UI-XX    tela e seus estados
   ↓ é construída em
T-XX     tarefa
   ↓ é conferida por
R-XX     apontamentos do review
   ↓ é garantida por
teste    cujo nome contém "CA-XX"
```

O `sdd-trace` percorre essa cadeia nos dois sentidos e aponta onde ela se rompe.

## Nome de teste carrega o CA

O último elo da cadeia é o teste. A regra vale para qualquer linguagem:

> Todo teste que demonstra um cenário traz `CA-XX` no nome ou na descrição (ou `CA_XX` quando o framework só aceita identificadores), de modo que uma busca textual pelo ID encontre o teste.

Como isso fica em cada framework é definido pelo perfil da stack, na seção "Convenção de nome de teste":

| Stack | Onde está definido | Exemplo |
|-------|--------------------|---------|
| Rails + RSpec | `${CLAUDE_PLUGIN_ROOT}/stacks/rails/test-conventions.md` | `it "CA-06: reserva expira após 15 minutos" do` |
| Rails + Minitest | `${CLAUDE_PLUGIN_ROOT}/stacks/rails/test-conventions.md` | `test "CA-06 reserva expira após 15 minutos" do` |
| Demais stacks com perfil | `${CLAUDE_PLUGIN_ROOT}/stacks/<stack>/profile.md` | conforme o perfil |
| Stack sem perfil | `${CLAUDE_PLUGIN_ROOT}/stacks/_generic/profile.md` | `CA_06_reserva_expira_apos_15_minutos` |

```
// esboço independente de linguagem
teste "CA-06: reserva expira após 15 minutos":
    // preparar / executar / verificar

teste "CA-07: item volta ao estoque quando a reserva expira":
    // ...
```

O `sdd-setup` registra em `docs/sdd/config.yml` qual dessas formas o projeto adota. A partir daí, `sdd-execute` escreve os testes nesse formato e `sdd-review` e `sdd-trace` sabem o que procurar.
