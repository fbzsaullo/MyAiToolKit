---
name: sdd-execute
description: Executa UMA tarefa T-XX do plano SDD — carrega o contexto que a tarefa declara (RN, CA, ADR, UI), implementa somente o escopo dela, escreve os testes no formato do projeto, roda build/typecheck e testes, e atualiza o Status e o histórico no plano. Use apenas quando o usuário chamar /sdd-execute (ou $sdd-execute) ou pedir explicitamente para executar uma tarefa do plano.
argument-hint: "[T-XX — opcional; sem ela, pega a próxima tarefa livre]"
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Edit(docs/sdd/plans/**)
---

# sdd-execute — executar uma tarefa do plano

Tarefa: $ARGUMENTS (se o seu ambiente não substituir essa variável, use a mensagem do usuário).

Esta skill existe para que a implementação use **o mesmo contexto que o planejamento produziu**, em vez de o agente reconstruir a intenção a partir do título da tarefa. Uma execução = uma tarefa.

## Passo 1 — Achar o plano e a tarefa

1. Procure `docs/sdd/plans/PLAN-*.md`. Havendo mais de um, **pergunte qual** — não escolha pelo mais recente.
2. Com `T-XX` na entrada, use essa tarefa. Se ela não estiver `Pendente`, informe a situação atual e confirme antes de continuar.
3. Sem `T-XX`, pegue a primeira tarefa `Pendente` cujas dependências (`Depende de:`) estejam **todas** `Concluído`. Nenhuma elegível? Diga o que está travando e pare.

Leia o `**Status:**` de dentro do bloco `#### T-XX` — o do cabeçalho é do documento. Vocabulário em `${CLAUDE_PLUGIN_ROOT}/templates/id-conventions.md`.

## Passo 2 — Carregar o contexto declarado

Leia por inteiro o que a tarefa referencia. **Não deduza pelo título.**

- `Implementa:` → cada `RN-XX` no PRD
- `Valida:` → cada `Cenário [CA-XX]` no PRD
- `Decisões base:` → cada arquivo `docs/sdd/architecture/adrs/ADR-XXX-*.md` (confira se está `Aceito`; se não estiver, avise antes de seguir)
- `Telas:` → a tela e **cada estado** listado na SPEC-UI (em projeto sem interface o campo não existe, e isso não é lacuna)

ID referenciado que não existe no artefato: **pare e informe**. É uma falha de rastreabilidade — implementar mesmo assim gera código que ninguém consegue ligar a um requisito.

Leia também:
- `AGENTS.md` / `CLAUDE.md` da raiz e do módulo afetado — as convenções que o review vai cobrar;
- `docs/sdd/config.yml` — comandos de build/teste/lint e a **convenção de nome de teste** do projeto;
- o perfil da stack (`${CLAUDE_PLUGIN_ROOT}/stacks/<stack>/profile.md` e, em Rails, `test-conventions.md`).

## Passo 3 — Pontos de validação humana

Se a tarefa aparece em "Pontos de validação humana" do plano, peça confirmação **antes de escrever qualquer código** e espere a resposta.

## Passo 4 — Marcar o início

Mude o `**Status:**` para `Em andamento` antes de começar. Assim, se a sessão cair, o `sdd-next` mostra onde parou em vez de oferecer a tarefa como intocada.

## Passo 5 — Implementar

- Mexa apenas no que está em `Arquivos/camadas`. Precisa tocar outro arquivo? Explique o motivo ao usuário **antes** — escopo ampliado em silêncio vira apontamento no review.
- Respeite os ADRs de `Decisões base:` mesmo que outra abordagem pareça melhor. Se a decisão parecer errada, o caminho é um ADR novo via `sdd-architect`, não um desvio na implementação.

## Passo 6 — Testes

- Escreva os testes de `Testes a escrever:` **antes** do código de produção do ponto testado, quando for viável: ver o teste falhar primeiro confirma que ele testa a coisa certa.
- Nomeie os testes que provam cenários com o `CA-XX`, no formato do projeto (`docs/sdd/config.yml` / perfil da stack — ex.: `it "CA-05: ..."` em RSpec, `test "CA-05 ..."` em Minitest). É esse nome que fecha o elo `CA → teste` no `sdd-trace`.
- Rode primeiro o build/typecheck/carregamento da aplicação (em Rails, por exemplo, `bin/rails zeitwerk:check` quando fizer sentido) — erro de carregamento não é teste falhando, é implementação incompleta, e aparece mais rápido.
- Rode os testes usando os comandos do `config.yml`. Comandos não pré-autorizados pedem confirmação ao usuário — tudo bem.
- **Nunca marque como concluída uma tarefa com teste vermelho ou build quebrado.**

## Passo 7 — Fechar o estado

Critérios atendidos e testes verdes:

1. marque os checkboxes de `Critério de aceite (testável)`;
2. mude o `**Status:**` para `Concluído`;
3. acrescente uma linha no histórico do plano com a data (e o commit, se já existir).

**Não faça commit por conta própria.** Sugira uma mensagem citando a `T-XX` (ex.: `T-03: agenda consulta com bloqueio de horário`) e deixe a decisão com o usuário; o hash entra no histórico depois.

Não deu para concluir? Use `Bloqueado`, escreva o motivo na coluna de observação do histórico e pare. Tarefa parcial marcada como `Concluído` é exatamente a inconsistência que o `sdd-trace` procura — não crie uma.

Se o plano tem o campo `**Estimativa:**`, **não altere** o valor — ele pertence ao usuário.

## Passo 8 — Próximo passo

Sugira `/sdd-review T-XX`. **Não rode o review automaticamente** — quem implementou não é quem decide se passou.

## Não fazer

- **Mais de uma tarefa por execução.** Mesmo que a próxima pareça trivial, ela tem critérios e review próprios.
- **Regra de negócio fora das `RN` da tarefa.** Se a implementação exige uma decisão que o PRD não cobre, pare e aponte — quem muda é o PRD, não o código que adivinha.
- **`Concluído` com critério parcialmente atendido.** Use `Bloqueado` e registre.
- **Reescrever o plano durante a execução.** Tarefa mal dimensionada? Aponte e sugira revisar com `sdd-plan`. Executar algo diferente do planejado quebra o rastreio sem ninguém perceber.
- **Pular testes "porque a mudança é pequena".** O critério de pronto é o que está escrito na tarefa.

## Regra de ouro

O plano é a única fonte de verdade sobre o estado da execução, e esta skill é quem o atualiza enquanto o trabalho acontece. `sdd-next` e `sdd-trace` leem apenas o plano: um estado que ele não registra não existe. Plano desatualizado é pior do que não ter plano, porque faz as outras skills descreverem um projeto imaginário.
