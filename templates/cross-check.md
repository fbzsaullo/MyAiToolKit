# Revisão cruzada — verificação independente dos apontamentos

Regras compartilhadas pelo `sdd-review` e pelo `code-review`. Quando ligada, a revisão cruzada entrega os apontamentos graves a um **segundo agente, independente**, que tenta derrubá-los lendo o código e os artefatos — sem ver o raciocínio de quem apontou. O que ele confirma fica; o que ele refuta com evidência sai; o que fica em dúvida volta para o usuário decidir.

Do round 2 em diante (só no `sdd-review`, que tem rounds), o mesmo verificador também **confere as correções**: os apontamentos do round anterior que o revisor marcou como `Resolvido` são entregues a ele, que diz se o problema ainda acontece (seção 7).

**Não é um debate.** Os agentes nunca conversam entre si: tudo passa pela skill que conduz o review, em passos fixos, com uma única verificação por review. A pesquisa sobre debate entre agentes mostra que rodadas de discussão livre raramente superam um único agente bem orientado e tendem a terminar em concordância vazia; o ganho de precisão vem da verificação independente de cada apontamento (fontes em `REFERENCES.md`, seção de revisão).

## 1. Quando roda

**Configuração** — `review.cross_check` em `docs/sdd/config.yml` (perguntado no `/sdd-setup`):

| Valor | Candidatos novos | Correções (round 2 em diante, `sdd-review`) |
| --- | --- | --- |
| `never` (padrão) | não verifica | não confere |
| `auto` | verifica quando o review produziu pelo menos um `Bloqueante` ou um `Q1` | confere as correções de **Bloqueantes** marcadas `Resolvido` — e isso, sozinho, já aciona a verificação |
| `always` | verifica os candidatos de todo review | confere as correções de `Bloqueantes` e `Importantes` marcadas `Resolvido` |

Sem a chave, vale `never`. Acionada a verificação por qualquer motivo, os candidatos novos seguem a seção 2 normalmente.

**Na chamada** — a palavra `cruzada` no argumento liga a verificação naquele review (como `always`); `simples` desliga. O `config.yml` não muda.

**Ambiente** — a verificação precisa de um agente novo, com contexto próprio:

- **Claude Code:** o agente do plugin `my-ai-toolkit:review-verifier` (`agents/review-verifier.md`) — só leitura, com limite de passos.
- **Codex:** um subagente pedido pela própria skill, com o pedido da seção 4 e a instrução de só ler.
- **Outra IA:** qualquer forma de abrir um agente com contexto limpo e ferramentas só de leitura.
- **Sem como abrir um agente independente:** a verificação **não acontece**. Escreva `Revisão cruzada: indisponível neste ambiente` no relatório, diga isso na conversa em uma linha e siga com o review normal. **Nunca simule** o verificador no mesmo contexto: um relatório que se diz verificado sem ter sido independente engana mais do que ajuda.

## 2. Candidatos novos

Depois da avaliação e da classificação, antes de escrever o relatório:

**Entram:** os apontamentos `Bloqueante` e `Importante`, e todo apontamento em `Q1` (no `code-review`).

**Ficam de fora:**

- `Sugestão` (a não ser que esteja em `Q1`);
- **ausência verificável por busca** — "não há teste com `CA-04` no nome", commit fora do padrão de `git.commit`: um grep já prova, e outro agente só repetiria a busca;
- **alerta de ferramenta já confirmado no código** — rubocop, brakeman, teste que falhou: a evidência já é objetiva.

Até aqui os apontamentos ainda **não têm número**: chame-os de `C-01`, `C-02`… Os `R-XX` / `CR-XX` definitivos são dados depois da verificação, para que um candidato descartado não gaste número.

**Limite de 20 itens por pedido**, somando candidatos novos e correções (seção 7). Passou disso, entram nesta ordem: correções de `Bloqueantes`, candidatos `Bloqueante`/`Q1`, o resto. O relatório diz o que ficou sem verificação.

## 3. O que o verificador recebe — e o que não recebe

Monte **um único pedido** com todos os itens.

**Recebe:**

- para cada candidato novo: o ID provisório, o enunciado do problema em uma ou duas frases, o local (`arquivo:linha`), a severidade proposta (e o quadrante, no `code-review`) e os IDs ligados (`RN`, `CA`, `ADR`, `UI`, critério do card);
- o **trecho do diff** de cada arquivo citado, sem comentário. Se o alvo do review não é a árvore de trabalho (branch de colega, PR, patch), inclua também o arquivo inteiro **na versão do alvo** (até ~400 linhas; acima disso, o hunk com ~40 linhas de contexto) — o verificador só lê arquivos do disco, que podem estar em outra versão;
- para cada correção a conferir: o que a seção 7 lista;
- os **caminhos** dos artefatos: plano, PRD, ADRs, SPEC-UI, `AGENTS.md`, checklists da stack — ele lê o que precisar;
- no `code-review`, os critérios de aceite do card, como foram extraídos.

**Não recebe:** o raciocínio de quem apontou, o caminho sugerido, trechos de artefato escolhidos por quem apontou, o veredito provisório — nem, nas correções, a marcação `Resolvido` do revisor ou o motivo dela. Isso é o que torna a verificação independente.

## 4. O pedido

Use este texto, preenchendo as partes entre colchetes. A parte B só existe do round 2 em diante, com correções a conferir; sem candidatos novos, a parte A sai. É a fonte única: o agente do Claude Code e o subagente do Codex recebem exatamente isto.

````markdown
Você é o verificador independente de um review de código. Sua tarefa é **julgar cada item da lista lendo o código e os artefatos** — não concordar por educação com quem escreveu a lista.

Regras:
- Só leia. Não edite arquivos, não rode comandos que alterem nada, não abra outros agentes.
- Não procure problemas novos: julgue apenas os itens da lista.
- **Parte A — candidatos novos.** Outro revisor levantou estes problemas; tente derrubar cada um. Responda com uma destas três:
  - **Confirmado** — o problema acontece. Se a severidade proposta estiver errada, diga qual seria e por quê.
  - **Refutado** — o problema **não** acontece. Obrigatório: a contra-evidência em `arquivo:linha` (o código que impede o problema, o teste que cobre o caso, a cláusula do PRD/ADR que permite o comportamento).
  - **Inconclusivo** — não dá para confirmar nem refutar com o que está no repositório.
- **Parte B — correções a conferir.** Estes problemas foram apontados num review anterior. Diga se o problema **ainda acontece** no código atual:
  - **Resolvido** — não acontece mais. Obrigatório: `arquivo:linha` do que impede o problema agora. Se o problema era a falta de um teste, o teste precisa exercitar o cenário (preparar, agir e verificar o que o cenário pede); existir com o nome certo não basta.
  - **Persiste** — ainda acontece, no mesmo lugar ou em outro trecho do diff. Obrigatório: `arquivo:linha` de onde acontece.
  - **Inconclusivo** — não dá para afirmar nenhum dos dois.
- "Não consegui reproduzir", "parece correto" e "parece corrigido" **não** são respostas firmes: são Inconclusivo.
- Seja breve: no máximo três linhas por item.

Contexto do review:
- Tipo: [sdd-review da T-XX, round N | code-review da branch X contra Y]
- Artefatos para consultar: [caminhos]
- [Critérios de aceite do card, se houver]
- [Parte B: commit revisado no round anterior `<hash>` → agora `<hash>` — ou: "sem registro do commit anterior; as linhas podem ter mudado"]

Parte A — candidatos novos

### C-01
- Problema: [enunciado]
- Local: [arquivo:linha]
- Severidade proposta: [Bloqueante | Importante] [· quadrante Qn]
- Ligado a: [RN-XX, CA-XX, ADR-XXX…]
- Trecho do diff:
  [hunk]

[demais candidatos]

Parte B — correções a conferir

### P-01 (R-0X do round anterior)
- Problema: [o que estava errado, como no relatório anterior]
- Local no round anterior: [arquivo:linha]
- Por que importava: [consequência, como no relatório anterior]
- Severidade original: [Bloqueante | Importante]
- Ligado a: [RN-XX, CA-XX, ADR-XXX…]
- O que mudou nesses arquivos desde o round anterior:
  [diff]

[demais correções]

Responda exatamente neste formato, um bloco por item:

C-01 · Confirmado | Refutado | Inconclusivo
Evidência: [arquivo:linha e uma frase]
Severidade: [mantém | sugere <outra> — motivo]

P-01 · Resolvido | Persiste | Inconclusivo
Evidência: [arquivo:linha e uma frase]
````

## 5. Aplicar a resposta — candidatos novos

| Resposta | `Importante` (fora do Q1) | `Bloqueante` ou `Q1` |
| --- | --- | --- |
| **Confirmado** | Fica. Severidade sugerida diferente: pode mudar, com o motivo escrito no relatório | Fica. **Nunca é rebaixado sozinho** — sugestão de severidade menor vira disputa (seção 6) |
| **Refutado** | Sai para "Candidatos descartados", com a contra-evidência | **Em disputa** (seção 6): continua contando para o veredito até o usuário decidir |
| **Inconclusivo** | Fica como está, com nota | Fica como está, com nota |

**Conferir a contra-evidência.** Antes de descartar, abra o `arquivo:linha` citado pelo verificador e confira que o código está lá e diz o que ele afirma. Não está, ou não sustenta a refutação: trate como `Inconclusivo`. Essa conferência é de fato, não uma réplica — não reabra a discussão nem peça outra opinião.

**A assimetria é proposital.** No pipeline, um falso Bloqueante custa um round; um Bloqueante verdadeiro derrubado vira defeito em produção. Por isso o verificador pode tirar um `Importante` do relatório, mas um `Bloqueante` ou um `Q1` só sai com a decisão do usuário.

Depois de aplicar, numere os apontamentos que ficaram (`R-01`… / `CR-01`…) na ordem normal do relatório.

## 6. Disputas: uma pergunta só

Todas as disputas — de candidatos novos e de correções (seção 7) — viram **uma única pergunta ao usuário**, antes de gravar o relatório, cada uma com as duas evidências lado a lado, em uma linha cada:

> **C-02 em disputa** — revisor: `app/controllers/pedidos_controller.rb:18` libera a action sem checar o dono do pedido · verificador: `app/controllers/application_controller.rb:6` aplica `before_action :authorize_owner!` a todas as actions.

| Skill | Opções por disputa |
| --- | --- |
| `sdd-review` — candidato novo | **Manter como Bloqueante** (a tarefa vai para `Bloqueado`) · Rebaixar para Importante · Descartar |
| `sdd-review` — correção | Considerar resolvido · **Reabrir como Bloqueante** (a tarefa vai para `Bloqueado`) |
| `code-review` | **Manter no Q1** · Mover para Q2 · Descartar |

No `sdd-review`, as respostas que bloqueiam ("manter", "reabrir") valem também como a confirmação do Passo 6 para aquele apontamento — não pergunte duas vezes. **Sem resposta, vale o lado que bloqueia**: o candidato continua valendo e a correção é reaberta. Silêncio não descarta nem fecha nada.

## 7. Round 2 em diante: conferir as correções

Só no `sdd-review`. Ao preencher a tabela "Round anterior", o revisor marca cada apontamento antigo como `Resolvido`, `Persiste` ou `Não verificável`. Quem julga a correção é o mesmo agente que vai aprovar a tarefa — e o erro mais caro do pipeline é um Bloqueante dado como resolvido sem estar. Por isso, com a revisão cruzada ligada, o verificador confere o "Resolvido".

**O que entra:**

| No round anterior | Marcado agora | Conferido? |
| --- | --- | --- |
| `Bloqueante` (inclusive o que esteve em disputa e o usuário manteve) | `Resolvido` | sim, em `auto` e `always` |
| `Importante` | `Resolvido` | só em `always` |
| qualquer um | `Persiste` | não — o lado que bloqueia já foi escolhido |
| qualquer um | `Não verificável` | não — continua sendo decisão do usuário |
| `Sugestão` | qualquer marcação | não |
| candidato descartado | — | não — não tem número nem é acompanhado |

Diferente dos candidatos novos (seção 2), **ausências entram**: se o problema era a falta de um teste, uma busca prova que agora existe um teste com `CA-XX` no nome, mas não que ele exercita o cenário. É isso que o verificador confere.

**O que o verificador recebe, por correção** (`P-01`, `P-02`…): do relatório anterior, o problema, o local, "o que está errado" e "por que bloqueia" — **sem o caminho sugerido**, porque a correção pode ter seguido outro caminho e o que importa é se o problema sumiu; o `git diff <commit revisado no round anterior>..HEAD` dos arquivos citados (relatório anterior sem `Commit revisado`: o diff inteiro contra a base, com o aviso de que as linhas podem ter mudado); e os mesmos caminhos de artefato dos candidatos novos.

**Aplicar a resposta — a assimetria se inverte.** Aqui o erro perigoso é dar como fechado o que continua aberto; o lado conservador é **reabrir**.

| Resposta | Correção de `Bloqueante` | Correção de `Importante` |
| --- | --- | --- |
| **Resolvido** | Continua `Resolvido`, com a evidência do verificador na tabela | Continua `Resolvido` |
| **Persiste** (evidência conferida) | **Reaberto**: vira um `R-XX` deste round, com a severidade original, e a tabela registra `⚠️ Persiste (reaberto pelo verificador)` | Reaberto da mesma forma |
| **Persiste** (evidência não confere) | Vale como `Inconclusivo` | Vale como `Inconclusivo` |
| **Inconclusivo** | **Em disputa** — vai para o usuário (seção 6) | Continua `Resolvido`, com nota |

Reabrir não precisa de pergunta: só mantém o bloqueio que já existia. A evidência do verificador é conferida no `arquivo:linha` antes, como na seção 5. O apontamento reaberto entra no relatório como qualquer `R-XX` deste round, com "Onde" na evidência do verificador e a origem escrita: `persiste de R-02 (REVIEW-T-04-2026-10-09)`. Ele entra **depois** da verificação — não volta para a parte A.

## 8. Travas

São elas que garantem que a verificação termina:

1. **Uma chamada ao verificador por review**, com todos os itens juntos (parte A e parte B). Nenhuma etapa se repete.
2. **Sem nova tentativa.** Resposta vazia, cortada ou fora do formato: os itens sem resposta válida valem `Inconclusivo`, e o relatório diz `incompleta`.
3. **Sem réplica.** Quem apontou não responde ao verificador; discordância vai para o usuário (seção 6).
4. **O verificador não cria apontamentos.** `Persiste` aponta um problema que já existia, não um novo.
5. **O verificador não edita nem abre agentes.** No Claude Code, o agente do plugin só tem `Read`, `Grep` e `Glob`, e para em 12 passos (`maxTurns`).
6. **O que foi julgado não é julgado de novo.** Um candidato verificado num round, ou uma disputa que o usuário já decidiu, não volta a ser discutido; no round seguinte, confere-se só a **correção** (seção 7).
7. **Reaberto espera o próximo round.** Um apontamento reaberto vira `R-XX` deste round e só é conferido de novo no round seguinte — no máximo uma conferência por item, por round.

## 9. No relatório

**Cabeçalho** — `Commit revisado:` com o hash curto do código revisado (`git rev-parse --short HEAD`, ou o último commit do PR/branch; patch avulso: `não se aplica`) — é ele que permite ao próximo round ver só o que mudou. E o campo `Revisão cruzada:` com um destes valores:

| Valor | Quando |
| --- | --- |
| `desligada` | `never`, ou `simples` na chamada |
| `pulada (modo automático: sem Bloqueante nem Q1)` | `auto` e nada grave a verificar; no round 2 em diante, também sem correção de Bloqueante a conferir |
| `feita — N verificados (C confirmados, D descartados, E em disputa, I inconclusivos)` | verificação concluída; do round 2 em diante, acrescente `· M correções conferidas (A resolvidas, B reabertas, C em disputa)` |
| `incompleta — …` | resposta parcial ou fora do formato (seção 8, trava 2) |
| `indisponível neste ambiente` | sem como abrir um agente independente |

**Seções** — quando a verificação aconteceu, o relatório ganha "Verificação cruzada" (uma linha por candidato verificado: severidade antes → depois, resposta, evidência do verificador e decisão) e "Candidatos descartados" (o que saiu, sem número, com a contra-evidência). As correções conferidas aparecem na própria tabela "Round anterior", na coluna **Verificador**. Os modelos `review-template.md` e `cr-template.md` mostram onde.

**Veredito** — calculado do que ficou, pelas regras normais de cada skill. Disputa ainda sem decisão conta pelo lado que bloqueia; apontamento reaberto conta como qualquer `R-XX` do round.

## 10. Custo

Um review com verificação gasta, em média, **1,5 a 2 vezes** os tokens de um review simples: o verificador começa sem contexto e precisa ler código e artefatos. Conferir correções no mesmo pedido acrescenta pouco — o verificador já está lendo os mesmos arquivos. Por isso o padrão é `never`, o modo `auto` limita a verificação aos casos graves e a palavra `simples` desliga num review específico.
