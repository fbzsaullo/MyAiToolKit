# Severidade e quadrante — como classificar

Cada apontamento `CR-XX` tem duas classificações independentes:

- **Severidade** responde *quanto isso importa* (impacto).
- **Quadrante** responde *quando agir* (urgência × importância), inspirado na matriz de Eisenhower.

Juntas, dizem ao autor o que fazer agora, o que planejar e o que pode ficar para quando houver tempo.

## Severidade

| Severidade | Significa | Exemplos |
| --- | --- | --- |
| **Bloqueante** | Não deve entrar na branch base assim | bug de lógica, falha de segurança, critério de aceite não atendido, teste quebrado, migration irreversível em tabela grande, dado pessoal em log |
| **Importante** | Precisa ser resolvido, agora ou logo em seguida | N+1 em tela usada, teste faltando para uma borda relevante, tratamento de erro inconsistente, duplicação significativa, convenção do projeto violada |
| **Sugestão** | Melhoria opcional | nome melhorável, extração de método, comentário útil, número mágico |

## Os dois eixos do quadrante

**Urgente?** Precisa de ação **antes deste merge**:
- impede o merge (CI falhando, conflito, regra do repositório);
- causa dano **assim que entrar** (bug visível, falha de segurança explorável, dado corrompido);
- é barato de corrigir agora e caro depois (ex.: nome de coluna numa migration ainda não aplicada).

**Importante?** Afeta de forma relevante:
- correção do comportamento ou a história/critérios de aceite;
- segurança e dados;
- manutenção futura (desenho, acoplamento, testes).

## Os quatro quadrantes

| Quadrante | Urgente | Importante | Ação | Exemplos |
| --- | --- | --- | --- | --- |
| **Q1 — Corrigir antes do merge** | sim | sim | resolver neste PR | SQL com interpolação de parâmetro; critério de aceite não atendido; ação sem autorização; teste do cenário principal ausente |
| **Q2 — Planejar** | não | sim | registrar como card/tarefa (ou resolver agora, se for barato) | regra de negócio no controller que deveria estar num serviço; ausência de índice que só pesa com volume futuro; refatoração de área frágil |
| **Q3 — Ajuste rápido agora** | sim | não | corrigir neste PR, em minutos | `binding.irb` esquecido; lint quebrando o CI; texto com erro de digitação visível ao usuário; arquivo de debug commitado |
| **Q4 — Opcional** | não | não | a critério do autor | nome que poderia ser melhor; pequena simplificação; preferência de estilo do projeto não obrigatória |

## Como severidade e quadrante costumam se combinar

| | Q1 | Q2 | Q3 | Q4 |
| --- | --- | --- | --- | --- |
| **Bloqueante** | quase sempre | raro (bloqueante que pode esperar? reavalie) | — | — |
| **Importante** | quando o efeito chega com o merge | dívida real sem efeito imediato | — | — |
| **Sugestão** | — | — | quando o CI ou o usuário final é afetado já | o caso comum |

São tendências, não regras. Quando a combinação fugir delas, escreva o motivo no apontamento.

## Regras de bolso

- **Na dúvida entre Q1 e Q2, pergunte:** "se isso entrar hoje, alguém (usuário, CI, dado, segurança) sofre amanhã?" Se sim, Q1.
- **Na dúvida entre Q3 e Q4:** "isso atrapalha o merge ou é visível para alguém?" Se sim, Q3.
- **Q2 não é lixeira.** Todo Q2 sai do review com uma sugestão concreta de registro (card, tarefa no plano, ADR).
- **Critério de aceite da história não atendido é Q1 + Bloqueante**, sempre.
- **Segurança com caminho de exploração no diff é Q1 + Bloqueante.** Endurecimento sem exploração direta costuma ser Q2 + Importante.
- **Não infle o Q1:** se tudo é urgente, nada é. Um review com 15 itens em Q1 provavelmente classificou mal.

## Veredito a partir dos quadrantes

| Situação | Veredito |
| --- | --- |
| Pelo menos um Q1 | `⛔ Não pronto para merge` |
| Nenhum Q1, algum Q3 | `⚠️ Pronto com ajustes` |
| Só Q2 e/ou Q4 | `✅ Pronto` — com Q2 registrados para depois |
| Nada | `✅ Pronto` |
