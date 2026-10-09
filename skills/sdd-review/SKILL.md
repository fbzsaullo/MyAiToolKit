---
name: sdd-review
description: Revisa a implementação de uma tarefa T-XX do plano SDD comparando o código com o plano, o PRD, os ADRs e a SPEC-UI, e gera o relatório REVIEW-T-XX com apontamentos R-XX classificados em Bloqueante, Importante ou Sugestão. Avalia aderência ao plano, rastreabilidade, aderência à especificação, testes, qualidade do código, segurança (com checklist por stack) e, quando há SPEC-UI, conformidade de interface. Um apontamento Bloqueante devolve a tarefa como Bloqueado no plano. Use quando o usuário pedir "review da T-XX", "revisar a tarefa", "validar a implementação contra o plano", "fechar a T-XX" ou trouxer um diff dizendo qual tarefa ele entrega. Fase 6 do pipeline SDD do MyAiToolKit. Quando aprova, entrega a mensagem de commit pronta no padrão do projeto (o kit nunca commita) e preenche no histórico do plano o hash dos commits já feitos. Com a revisão cruzada ligada (review.cross_check no config.yml, ou a palavra cruzada na chamada), um verificador independente confere os apontamentos graves antes do veredito. Para review avulso, sem plano SDD (código próprio ou de colegas, ligado ou não a um card), use a skill code-review.
argument-hint: "[T-XX e/ou branch, PR ou caminho do diff — opcional; cruzada ou simples para a revisão cruzada]"
allowed-tools: Read, Glob, Grep, Edit(docs/sdd/reviews/**), Edit(docs/sdd/plans/**)
---

# sdd-review — review da tarefa contra o pipeline

Entrada: $ARGUMENTS (se o seu ambiente não substituir essa variável, use a mensagem do usuário).

O review responde a uma pergunta objetiva: **a tarefa entregou o que prometeu?** Para isso, cruza o código com o que o pipeline já registrou — plano, PRD, ADRs e SPEC-UI — e produz apontamentos `R-XX` que fecham a cadeia `ADR → RN → CA → UI → T → R`.

## Postura

- **A stack vem do projeto.** Os critérios específicos saem do `docs/sdd/config.yml`, do `AGENTS.md`/`CLAUDE.md` e dos checklists do perfil da stack — não de opinião.
- **Franqueza.** Review que aprova tudo não serve para nada. Problema real é apontado, com evidência e sem rodeio.
- **Evidência sempre.** Cada `R-XX` cita arquivo e linha, ou uma ausência verificável ("não há teste com `CA-04` no nome").
- **Severidade calibrada.** `Bloqueante` impede o merge; `Importante` resolve-se agora ou na próxima tarefa; `Sugestão` é opcional.
- **Nada inventado.** Faltou PRD, plano ou contexto? A lacuna vai para o relatório e o review segue degradado.
- **Só o que exige julgamento.** Formatação é trabalho do linter.
- **Mesmo critério para código humano e de IA.** Nem mais rigor, nem mais tolerância.

## Passo 1 — Qual tarefa e qual diff

**Tarefa.** Se a entrada traz `T-XX`, use. Senão, procure o padrão `T-\d+`:
1. no nome da branch atual (`git branch --show-current`);
2. na última mensagem de commit (`git log -1 --pretty=%B`);
3. não achou: pergunte — "Qual tarefa do plano esta implementação entrega (ex.: T-04)?"

Um PR que entrega várias tarefas gera **um relatório por tarefa**, mais um resumo conjunto na conversa. Tarefa `Cancelado` não se revisa: se o diff traz código dela, aponte isso como divergência do plano.

**Rounds anteriores.** Procure `docs/sdd/reviews/REVIEW-T-XX-*.md`. Existindo, este é o round N+1 — siga "Segundo round em diante" abaixo. Isso faz parte do fluxo normal: revisar de novo sem olhar o round anterior perde justamente a informação que motivou o re-review.

**Diff**, em ordem de preferência:
1. caminho de um patch fornecido pelo usuário;
2. branch ou PR informado (`gh pr diff <n>` quando o `gh` estiver disponível);
3. alterações locais: `git diff <base>...HEAD`, com a branch base de `docs/sdd/config.yml` (`code_review.default_base_branch`) — confirme com o usuário se houver dúvida;
4. nada disso: pergunte como acessar o código (colar o diff, caminho, branch para comparar).

Diff vazio ou inacessível: não gere relatório.

## Passo 2 — Artefatos

Localize (convenções em `${CLAUDE_PLUGIN_ROOT}/templates/folder-conventions.md`):

- **Plano** — `docs/sdd/plans/PLAN-*.md` que contém a `T-XX`
- **PRD** — o do cabeçalho do plano (`**PRD:**`)
- **ADRs** — `docs/sdd/architecture/adrs/ADR-XXX-*.md` citados em `Decisões base:`
- **SPEC-UI** — `docs/sdd/prototype/SPEC-UI-XXX-*.md` (só em projeto com interface)
- **Contexto do agente** — `AGENTS.md` e/ou `CLAUDE.md` na raiz e no módulo afetado
- **Config** — `docs/sdd/config.yml`

Da tarefa, extraia: `Implementa`, `Valida`, `Decisões base`, `Telas`, `Arquivos/camadas`, `Critério de aceite`, `Testes a escrever`. Do PRD, o texto completo de cada `RN` e `CA` citado. De cada ADR, a decisão e o status (só `Aceito` é critério).

Artefato que não existe vira lacuna no relatório — nunca suposição.

**Projeto sem nenhum artefato SDD** (sem plano, sem PRD): este review não se aplica. Ofereça a skill `code-review`, que faz review avulso com branch base e card opcional, e sugira `/sdd-start` para os próximos trabalhos.

## Passo 3 — Stack e critérios

Siga a cascata de `${CLAUDE_PLUGIN_ROOT}/templates/stack-detection.md` (config → contexto do agente → arquitetura → inspeção do repositório → pergunta). Carregue, para cada stack tocada pelo diff:

- `${CLAUDE_PLUGIN_ROOT}/stacks/<stack>/review-checklist.md` (quando existir)
- `${CLAUDE_PLUGIN_ROOT}/stacks/<stack>/security-checklist.md` (quando existir; senão, a seção de segurança do `profile.md` ou do `_generic`)

Registre no início do relatório a stack, as versões e de onde vieram. Se nada identificar a stack e o usuário não responder, **pare** — review com convenções chutadas é pior que nenhum.

## Passo 4 — Avaliação

Perguntas-guia e severidades padrão de cada eixo em `references/review-checklist.md`. Os eixos 1 a 6 valem sempre; o 7 só quando há SPEC-UI e a tarefa tem `Telas:`.

1. **Aderência ao plano** — entregou exatamente o que a `T-XX` prometeu? Arquivos tocados batem com `Arquivos/camadas`? Os critérios de aceite estão atendidos? Tarefa marcada `Concluído` sem cumprir os critérios é Bloqueante.
2. **Rastreabilidade** — commits seguem o padrão de `git.commit` (`docs/sdd/config.yml`) e citam a `T-XX` quando o padrão prevê? Testes trazem o `CA-XX` no nome, no formato do projeto (`docs/sdd/config.yml` / perfil da stack)? Comentários citam `RN`/`ADR` onde a lógica não é óbvia?
3. **Aderência à especificação** — cada `RN` de `Implementa` está no código, do jeito que o PRD escreve? Cada `CA` de `Valida` tem teste que exercita o cenário? Cada ADR `Aceito` de `Decisões base` foi respeitado? Desvio silencioso, sem ADR novo, é Bloqueante.
4. **Testes** — os testes prometidos existem, cobrem bordas e passam? Há teste da decisão de arquitetura quando ela é central (ex.: concorrência)?
5. **Qualidade do código** — critérios universais (nomes coerentes, tratamento de erro do projeto, sem código morto, sem depuração esquecida, concorrência correta, sem dado pessoal em log) + convenções do projeto + `review-checklist.md` da stack.
6. **Segurança** — o `security-checklist.md` da stack aplicado **somente às linhas do diff**: entrada não confiável, injeção, autorização, exposição de dados, segredos, dependências novas. Não é modelagem de ameaças completa; é a verificação que todo PR merece.
7. **Interface** *(condicional)* — cada estado listado em `Telas:` foi implementado? Campos batem com a SPEC-UI? Componentes reutilizáveis foram usados, e não recriados? Avalie estrutura, estados e comportamento — **nunca estética**. Estado ausente é Bloqueante; divergência estrutural é Importante; detalhe visual não é apontamento.

Ferramentas da stack (linters, análise de segurança, testes) podem ser rodadas **somente com confirmação do usuário** e, de preferência, só sobre os arquivos do diff. O resultado entra como evidência.

## Passo 4b — Revisão cruzada (opcional)

Decida se roda: palavra `cruzada` ou `simples` na entrada; senão, `review.cross_check` do `docs/sdd/config.yml` (`never` quando ausente). Com `auto`, só roda se a avaliação produziu pelo menos um `Bloqueante`.

Rodando, siga `${CLAUDE_PLUGIN_ROOT}/templates/cross-check.md`:

1. separe os candidatos (`Bloqueante` e `Importante`, sem as ausências verificáveis por busca nem os alertas de ferramenta já confirmados), ainda sem número — `C-01`, `C-02`…;
2. delegue **uma** verificação a um agente novo, só de leitura (no Claude Code, o agente `my-ai-toolkit:review-verifier`; no Codex, um subagente), com o pedido da seção 4 do modelo — sem o seu raciocínio nem o caminho sugerido;
3. aplique as respostas pela tabela da seção 5: `Importante` refutado com contra-evidência conferida sai para "Candidatos descartados"; `Bloqueante` refutado, ou com sugestão de severidade menor, fica **em disputa**;
4. leve as disputas ao usuário numa pergunta só (seção 6) — a resposta "manter" já vale como a confirmação do Passo 6;
5. numere o que ficou (`R-01`…) e siga para o relatório.

Sem como abrir um agente independente: registre `Revisão cruzada: indisponível neste ambiente` e siga. Nunca faça a verificação no mesmo contexto fingindo ser outro agente. Não há segunda verificação nem réplica: as travas estão na seção 7 do modelo.

## Passo 5 — Relatório

Use `references/review-template.md` e salve em `docs/sdd/reviews/REVIEW-T-XX-AAAA-MM-DD.md` (se o projeto preferir comentar direto no PR sem versionar, pergunte).

**Recomendação final:**
- `Bloqueado` — pelo menos um Bloqueante
- `Aprovado com ressalvas` — só Importantes e/ou Sugestões
- `Aprovado` — nenhum apontamento (raro)

Com revisão cruzada, a recomendação é calculada sobre o que ficou depois da verificação; disputa ainda sem decisão conta como o apontamento original.

Na conversa, mostre: a recomendação, a contagem por severidade, o caminho do arquivo e os 1 a 3 apontamentos mais graves.

## Passo 6 — Devolver o resultado ao plano

O plano só "sabe" do review se ele for escrito lá. Com **pelo menos um Bloqueante**:

1. mude o `**Status:**` da `T-XX` para `Bloqueado`;
2. acrescente no histórico do plano a referência, ex.: `Bloqueado por R-01, R-03 (REVIEW-T-04-2026-10-09)`.

Peça confirmação antes de editar o plano (se o Bloqueante esteve em disputa, a resposta do Passo 4b já é essa confirmação), e avise se a tarefa estava `Concluído` — é exatamente a contradição entre estado declarado e estado verificado que o `sdd-trace` trata como grave.

Sem Bloqueante, **não mexa no estado da tarefa**. `Aprovado com ressalvas` não muda o status; Importantes que justificarem viram tarefa nova via `sdd-plan`. A única edição permitida no plano, nesse caso, é a coluna Commit do histórico (Passo 7).

## Passo 7 — Mensagem de commit e hash

O kit nunca commita (`${CLAUDE_PLUGIN_ROOT}/templates/commit-message.md`). Este passo fecha o ciclo da tarefa em texto.

**Aprovado ou Aprovado com ressalvas** — entregue a mensagem de commit da `T-XX`, montada como o template manda, no padrão de `git.commit` do `docs/sdd/config.yml`:
- tipo e escopo pelo efeito da tarefa;
- a `T-XX` onde `task_id` mandar;
- no corpo, quando ajuda, as `RN`/`ADR` que a tarefa atende.

Se o diff revisado trouxe coisas fora da tarefa, sugira separar em outro commit. Termine com uma linha: "Depois de commitar, o hash entra no histórico no próximo `/sdd-review` (de qualquer tarefa) — ou me diga o hash agora." Não abra um novo round só para isso.

**Bloqueado** — sem mensagem. Ela sai no round que aprovar.

Quando a tarefa aprovada fecha o trabalho da branch, sugira em uma linha o `/pr-description` para o texto do PR.

**Hash no histórico** — sempre que este passo rodar, procure as linhas do histórico com `Concluído` e a coluna Commit vazia (`—` ou em branco), inclusive de tarefas anteriores:
1. para cada uma, `git log --oneline --grep "T-XX"` (só leitura);
2. **um** commit encontrado: proponha preencher com o hash curto;
3. vários: liste e pergunte qual (o da entrega, normalmente o mais antigo);
4. nenhum: deixe vazio — o commit ainda não foi feito, ou a mensagem não cita a tarefa (diga isso).

Mostre as mudanças propostas na coluna e peça confirmação antes de editar o plano. Nunca invente um hash.

## Segundo round em diante

1. Conte os relatórios da tarefa: sem sufixo é o round 1; o novo é `-round2`, `-round3`…
2. Leia o mais recente e preencha "Round anterior" item a item: cada `R-XX` antigo como resolvido, persistente ou não verificável.
3. Salve como `REVIEW-T-XX-AAAA-MM-DD-roundN.md`. O relatório anterior não é editado — a sequência deles é o histórico de qualidade da tarefa.
4. Os apontamentos novos recomeçam em `R-01`. Fora do relatório, sempre qualificados: `R-01 (REVIEW-T-04-2026-10-09)`.
5. O Passo 7 vale em todo round: a mensagem de commit sai no round que aprovar.
6. Com revisão cruzada, só os candidatos novos do round são verificados. Na tabela "Round anterior", apontamento que esteve em disputa leva a decisão do usuário entre parênteses; candidatos descartados não são acompanhados.

## Não é papel deste review

- Comentar formatação
- Modelagem de ameaças completa (o eixo de segurança é a verificação do diff, não uma auditoria)
- Otimizar desempenho que não é qualidade prioritária no PRD ou na arquitetura
- Impor preferência pessoal que o projeto não declara
- Criticar código fora do diff
- Propor refatoração ampla — isso vira tarefa no plano
- Dizer que "está tudo perfeito" quando não está

## Comportamentos esperados

- Divergência entre plano e código que parece decisão consciente (refinamento durante a implementação): `Importante`, pedindo justificativa — não `Bloqueante`.
- Review que revela falha no próprio plano (a `RN-05` precisava de mais uma tarefa): diga isso explicitamente em "Notas ao processo".
- Padrão novo que o time adotou e não está documentado: registre em "Notas ao processo" e **sugira** `/sdd-setup refresh` para levá-lo ao `AGENTS.md`. Sugestão, nunca execução.
- Review em modo degradado por falta de `AGENTS.md`/`CLAUDE.md`: avise na conversa que `/sdd-setup` tornaria os próximos reviews completos.

## Material de apoio

- `references/review-template.md` — modelo do relatório
- `references/review-checklist.md` — perguntas e severidades por eixo
- `${CLAUDE_PLUGIN_ROOT}/templates/commit-message.md` — formato da mensagem de commit (Passo 7)
- `${CLAUDE_PLUGIN_ROOT}/templates/cross-check.md` — revisão cruzada (Passo 4b)
- `${CLAUDE_PLUGIN_ROOT}/templates/stack-detection.md` — como descobrir a stack
- `${CLAUDE_PLUGIN_ROOT}/stacks/rails/review-checklist.md` e `security-checklist.md` — checklists da stack de referência
- `${CLAUDE_PLUGIN_ROOT}/stacks/rails/pipeline-example.md` — exemplo completo; mostra um `R-XX` devolvendo a tarefa para `Bloqueado`
