# Revisão cruzada — verificação independente dos apontamentos

Regras compartilhadas pelo `sdd-review` e pelo `code-review`. Quando ligada, a revisão cruzada entrega os apontamentos graves a um **segundo agente, independente**, que tenta derrubá-los lendo o código e os artefatos — sem ver o raciocínio de quem apontou. O que ele confirma fica; o que ele refuta com evidência sai; o que fica em dúvida volta para o usuário decidir.

**Não é um debate.** Os agentes nunca conversam entre si: tudo passa pela skill que conduz o review, em passos fixos, com uma única verificação por review. A pesquisa sobre debate entre agentes mostra que rodadas de discussão livre raramente superam um único agente bem orientado e tendem a terminar em concordância vazia; o ganho de precisão vem da verificação independente de cada apontamento (fontes em `REFERENCES.md`, seção de revisão).

## 1. Quando roda

**Configuração** — `review.cross_check` em `docs/sdd/config.yml` (perguntado no `/sdd-setup`):

| Valor | Efeito |
| --- | --- |
| `never` (padrão) | Review como sempre foi |
| `auto` | Verifica só quando o review produziu pelo menos um `Bloqueante` ou um `Q1` — onde um falso positivo custa uma rodada inteira de correção |
| `always` | Verifica os candidatos de todo review |

Sem a chave, vale `never`.

**Na chamada** — a palavra `cruzada` no argumento liga a verificação naquele review (como `always`); `simples` desliga. O `config.yml` não muda.

**Ambiente** — a verificação precisa de um agente novo, com contexto próprio:

- **Claude Code:** o agente do plugin `my-ai-toolkit:review-verifier` (`agents/review-verifier.md`) — só leitura, com limite de passos.
- **Codex:** um subagente pedido pela própria skill, com o pedido da seção 4 e a instrução de só ler.
- **Outra IA:** qualquer forma de abrir um agente com contexto limpo e ferramentas só de leitura.
- **Sem como abrir um agente independente:** a verificação **não acontece**. Escreva `Revisão cruzada: indisponível neste ambiente` no relatório, diga isso na conversa em uma linha e siga com o review normal. **Nunca simule** o verificador no mesmo contexto: um relatório que se diz verificado sem ter sido independente engana mais do que ajuda.

## 2. Candidatos

Depois da avaliação e da classificação, antes de escrever o relatório:

**Entram:** os apontamentos `Bloqueante` e `Importante`, e todo apontamento em `Q1` (no `code-review`).

**Ficam de fora:**

- `Sugestão` (a não ser que esteja em `Q1`);
- **ausência verificável por busca** — "não há teste com `CA-04` no nome", commit fora do padrão de `git.commit`: um grep já prova, e outro agente só repetiria a busca;
- **alerta de ferramenta já confirmado no código** — rubocop, brakeman, teste que falhou: a evidência já é objetiva.

Até aqui os apontamentos ainda **não têm número**: chame-os de `C-01`, `C-02`… Os `R-XX` / `CR-XX` definitivos são dados depois da verificação, para que um candidato descartado não gaste número.

Mais de **20 candidatos**: verifique só os `Bloqueante` e os `Q1`, e registre no relatório que os demais não foram verificados.

## 3. O que o verificador recebe — e o que não recebe

Monte **um único pedido** com todos os candidatos.

**Recebe:**

- para cada candidato: o ID provisório, o enunciado do problema em uma ou duas frases, o local (`arquivo:linha`), a severidade proposta (e o quadrante, no `code-review`) e os IDs ligados (`RN`, `CA`, `ADR`, `UI`, critério do card);
- o **trecho do diff** de cada arquivo citado, sem comentário. Se o alvo do review não é a árvore de trabalho (branch de colega, PR, patch), inclua também o arquivo inteiro **na versão do alvo** (até ~400 linhas; acima disso, o hunk com ~40 linhas de contexto) — o verificador só lê arquivos do disco, que podem estar em outra versão;
- os **caminhos** dos artefatos: plano, PRD, ADRs, SPEC-UI, `AGENTS.md`, checklists da stack — ele lê o que precisar;
- no `code-review`, os critérios de aceite do card, como foram extraídos.

**Não recebe:** o raciocínio de quem apontou, o caminho sugerido, trechos de artefato escolhidos por quem apontou, nem o veredito provisório. Isso é o que torna a verificação independente.

## 4. O pedido

Use este texto, preenchendo as partes entre colchetes. É a fonte única: o agente do Claude Code e o subagente do Codex recebem exatamente isto.

````markdown
Você é o verificador independente de um review de código. Outro revisor levantou os candidatos abaixo. Sua tarefa é **tentar derrubar cada um**, lendo o código e os artefatos — não confirmar por educação.

Regras:
- Só leia. Não edite arquivos, não rode comandos que alterem nada, não abra outros agentes.
- Não procure problemas novos: julgue apenas os candidatos da lista.
- Para cada candidato, responda com uma destas três:
  - **Confirmado** — o problema acontece. Se a severidade proposta estiver errada, diga qual seria e por quê.
  - **Refutado** — o problema **não** acontece. Obrigatório: a contra-evidência em `arquivo:linha` (o código que impede o problema, o teste que cobre o caso, a cláusula do PRD/ADR que permite o comportamento).
  - **Inconclusivo** — não dá para confirmar nem refutar com o que está no repositório.
- "Não consegui reproduzir" ou "parece correto" **não** é refutação: é Inconclusivo.
- Seja breve: no máximo três linhas por candidato.

Contexto do review:
- Tipo: [sdd-review da T-XX | code-review da branch X contra Y]
- Artefatos para consultar: [caminhos]
- [Critérios de aceite do card, se houver]

Candidatos:
### C-01
- Problema: [enunciado]
- Local: [arquivo:linha]
- Severidade proposta: [Bloqueante | Importante] [· quadrante Qn]
- Ligado a: [RN-XX, CA-XX, ADR-XXX…]
- Trecho do diff:
  [hunk]

[demais candidatos]

Responda exatamente neste formato, um bloco por candidato:

C-01 · Confirmado | Refutado | Inconclusivo
Evidência: [arquivo:linha e uma frase]
Severidade: [mantém | sugere <outra> — motivo]
````

## 5. Aplicar a resposta

| Resposta | `Importante` (fora do Q1) | `Bloqueante` ou `Q1` |
| --- | --- | --- |
| **Confirmado** | Fica. Severidade sugerida diferente: pode mudar, com o motivo escrito no relatório | Fica. **Nunca é rebaixado sozinho** — sugestão de severidade menor vira disputa (seção 6) |
| **Refutado** | Sai para "Candidatos descartados", com a contra-evidência | **Em disputa** (seção 6): continua contando para o veredito até o usuário decidir |
| **Inconclusivo** | Fica como está, com nota | Fica como está, com nota |

**Conferir a contra-evidência.** Antes de descartar, abra o `arquivo:linha` citado pelo verificador e confira que o código está lá e diz o que ele afirma. Não está, ou não sustenta a refutação: trate como `Inconclusivo`. Essa conferência é de fato, não uma réplica — não reabra a discussão nem peça outra opinião.

**A assimetria é proposital.** No pipeline, um falso Bloqueante custa um round; um Bloqueante verdadeiro derrubado vira defeito em produção. Por isso o verificador pode tirar um `Importante` do relatório, mas um `Bloqueante` ou um `Q1` só sai com a decisão do usuário.

Depois de aplicar, numere os apontamentos que ficaram (`R-01`… / `CR-01`…) na ordem normal do relatório.

## 6. Disputas: uma pergunta só

Todas as disputas viram **uma única pergunta ao usuário**, antes de gravar o relatório — cada uma com as duas evidências lado a lado, em uma linha cada:

> **C-02 em disputa** — revisor: `app/controllers/pedidos_controller.rb:18` libera a action sem checar o dono do pedido · verificador: `app/controllers/application_controller.rb:6` aplica `before_action :authorize_owner!` a todas as actions.

| Skill | Opções por disputa |
| --- | --- |
| `sdd-review` | **Manter como Bloqueante** (a tarefa vai para `Bloqueado`) · Rebaixar para Importante · Descartar |
| `code-review` | **Manter no Q1** · Mover para Q2 · Descartar |

No `sdd-review`, a resposta "manter" vale também como a confirmação do Passo 6 para aquele apontamento — não pergunte duas vezes. Sem resposta, a disputa **fica como está** (o apontamento continua valendo): silêncio não descarta nada.

## 7. Travas

São elas que garantem que a verificação termina:

1. **Uma chamada ao verificador por review**, com todos os candidatos juntos. Nenhuma etapa se repete.
2. **Sem nova tentativa.** Resposta vazia, cortada ou fora do formato: os candidatos sem resposta válida valem `Inconclusivo`, e o relatório diz `incompleta`.
3. **Sem réplica.** Quem apontou não responde ao verificador; discordância vai para o usuário (seção 6).
4. **O verificador não cria apontamentos** — cada apontamento novo pediria outra verificação.
5. **O verificador não edita nem abre agentes.** No Claude Code, o agente do plugin só tem `Read`, `Grep` e `Glob`, e para em 12 passos (`maxTurns`).
6. **Rounds não se reverificam.** No `-round2`, a verificação vale só para os candidatos novos daquele round.

## 8. No relatório

**Cabeçalho** — campo `Revisão cruzada:` com um destes valores:

| Valor | Quando |
| --- | --- |
| `desligada` | `never`, ou `simples` na chamada |
| `pulada (modo automático: sem Bloqueante nem Q1)` | `auto` e nenhum candidato grave |
| `feita — N verificados (C confirmados, D descartados, E em disputa, I inconclusivos)` | verificação concluída |
| `incompleta — …` | resposta parcial ou fora do formato (seção 7, trava 2) |
| `indisponível neste ambiente` | sem como abrir um agente independente |

**Seções** — quando a verificação aconteceu, o relatório ganha "Verificação cruzada" (uma linha por candidato verificado: severidade antes → depois, resposta, evidência do verificador e decisão) e "Candidatos descartados" (o que saiu, sem número, com a contra-evidência). Os modelos `review-template.md` e `cr-template.md` mostram onde.

**Veredito** — calculado do que ficou, pelas regras normais de cada skill. Disputa ainda sem decisão conta como o apontamento original.

**Rounds seguintes (`sdd-review`)** — na tabela "Round anterior", um apontamento que esteve em disputa leva a decisão do usuário entre parênteses. Candidatos descartados não têm número e não são acompanhados.

## 9. Custo

Um review com verificação gasta, em média, **1,5 a 2 vezes** os tokens de um review simples: o verificador começa sem contexto e precisa ler código e artefatos. Por isso o padrão é `never`, o modo `auto` limita a verificação aos casos graves e a palavra `simples` desliga num review específico.
