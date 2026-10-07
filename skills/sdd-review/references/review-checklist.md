# Perguntas por eixo — review SDD

Para cada eixo, as perguntas que o revisor responde ao percorrer o diff e a severidade **sugerida** quando a resposta é "não". Só vira `R-XX` o que tem problema — pergunta atendida não precisa ser mencionada.

As severidades são ponto de partida. Subir ou descer é permitido, desde que o motivo esteja escrito no apontamento.

---

## Eixo 1 — Aderência ao plano

*A implementação faz o que a `T-XX` prometeu, nem mais nem menos?*

| Pergunta | Se "não" |
| --- | --- |
| Os arquivos tocados correspondem a `Arquivos/camadas` da tarefa? | Importante (escopo ampliado) / Bloqueante (escopo trocado) |
| Todos os `Critério de aceite (testável)` estão atendidos? | Bloqueante |
| Se a tarefa já está `Concluído` no plano, o código confirma isso? | Importante |
| O que foi feito combina com "O que fazer" da tarefa? | Sugestão (Importante se a diferença for grande) |

**Sinais de alerta**
- **Escopo maior:** o PR mexe em 12 arquivos e a tarefa lista 3. Pode ser uma refatoração oportuna ou escopo crescendo sem controle — peça justificativa.
- **Escopo menor:** menos arquivos que o previsto. A tarefa pode ter sido dividida, ou a entrega está incompleta sem que o plano saiba.
- **Critério de aceite ausente ou trivial:** é problema do plano, não do código — registre em "Notas ao processo".
- **Entrega maior que a tarefa:** outras tarefas foram feitas "de carona". Aponte.

**Não entra aqui:** detalhe de implementação (eixo 5), testes faltando (eixo 4), discordância com o PRD (é assunto do PRD, não do review).

---

## Eixo 2 — Rastreabilidade

*Os elos da cadeia continuam intactos?*

| Pergunta | Se "não" |
| --- | --- |
| Os commits seguem o padrão de `git.commit` do `config.yml` e citam a `T-XX` quando o padrão prevê? | Sugestão |
| A branch cita a `T-XX` (quando o projeto exige)? | Sugestão |
| Os testes de cenário trazem `CA-XX` no nome, no formato do projeto (`docs/sdd/config.yml`)? | Importante |
| Cada `CA-XX` de `Valida:` tem um teste? | Bloqueante |
| Pontos não óbvios citam `RN-XX` ou `ADR-XXX` em comentário? | Sugestão |

**Sinais de alerta**
- `Implementa: RN-05`, mas nada no código (nome, comentário, teste) remete à regra — aceitável se a regra é parte natural do fluxo; suspeito se é específica e sutil.
- `Valida: CA-04, CA-06`, mas só existe teste do CA-04 — Bloqueante.
- Testes com nome genérico (`"funciona"`, `"works correctly"`) — Importante.

---

## Eixo 3 — Aderência à especificação

*O código respeita o que PRD e ADRs determinaram?*

| Pergunta | Se "não" |
| --- | --- |
| Cada `RN-XX` de `Implementa:` está no código? | Bloqueante |
| O comportamento segue o texto **atual** da regra, e não a interpretação de quem implementou? | Bloqueante (diverge) / Importante (ambíguo) |
| Cada `CA-XX` de `Valida:` tem teste que realmente exercita o cenário? | Bloqueante — teste que verifica outra coisa é pior que teste ausente |
| Cada ADR `Aceito` de `Decisões base:` foi materializado? | Bloqueante |
| Existe desvio silencioso, sem ADR novo? | Bloqueante |
| Onde o PRD é ambíguo, o código escolheu algo razoável e registrou? | Importante (sem registro) |

**Sinais de alerta**
- **Faz mais do que a regra pede:** costuma ser aceitável, mas se a verificação extra muda o comportamento esperado por quem pediu, abra como Importante para confirmar.
- **Faz menos do que a regra pede:** Bloqueante — entrega valor errado.
- **Outro caminho que o do ADR:** ADR manda bloqueio de linha, código usa cache distribuído. Bloqueante até alinhar (ou o código volta, ou um ADR novo substitui o antigo).
- **Regra escondida:** o código recusa algo que nenhuma `RN` ou `CA` menciona. Pode ser validação técnica legítima ou regra de negócio clandestina — Importante.

**Casos especiais**
- Regra com duas leituras possíveis é defeito do PRD: nota ao processo.
- ADR genérico demais para ser verificado: nota ao processo pedindo um ADR mais específico.

---

## Eixo 4 — Testes

*Os testes existem, cobrem o que importa e passam?*

| Pergunta | Se "não" |
| --- | --- |
| Todo item de `Testes a escrever:` foi criado? | Bloqueante |
| Cenários críticos têm teste de integração/requisição, não só unitário? | Importante |
| As bordas das regras estão cobertas (valor limite, entrada inválida, concorrência, tempo esgotado)? | Importante |
| A decisão de arquitetura central tem teste próprio (ex.: concorrência)? | Importante (Bloqueante se for o centro da tarefa) |
| Os testes passam? | Bloqueante |
| Algum teste depende de ordem de execução ou de estado externo? | Importante |
| Há dublês (mocks/stubs) escondendo justamente o que deveria ser testado? | Importante |
| A cobertura caiu abaixo do mínimo do projeto (se houver)? | Importante |

**Sinais de alerta (todos Bloqueantes, salvo indicação)**
- Asserção que não pode falhar (`expect(x).to eq(x)`).
- Teste desligado (`skip`, `xit`, `pending`) sem motivo escrito.
- Teste sem nenhuma asserção.
- "Teste de integração" que não toca banco nem serviço real — Importante.
- Só o caminho feliz, com cenários de erro do PRD sem teste — Importante a Bloqueante.

**Calibragem por tipo de tarefa**
- Estrutura (migration, model sem regra): teste pode não se aplicar — confira se a tarefa declarou isso.
- Regra de negócio: cobertura ampla.
- Interface: testes de componente/sistema nos fluxos críticos; nem todo CA precisa de teste de navegador.
- Observabilidade: testes leves (asserção sobre log ou métrica) bastam.

---

## Eixo 5 — Qualidade do código

*Critérios universais + convenções do projeto + `stacks/<stack>/review-checklist.md`.*

| Pergunta | Se "não" |
| --- | --- |
| Nomes seguem as convenções do projeto? | Importante (sistemático) / Sugestão (pontual) |
| Tratamento de erro segue o padrão do projeto? | Importante |
| Há código morto no diff (variável, método, comentário `TODO` sem dono)? | Sugestão a Importante |
| Há duplicação evidente? | Importante (se relevante) |
| Concorrência e código assíncrono estão corretos (sem condição de corrida óbvia, sem trabalho disparado e esquecido)? | Importante a Bloqueante |
| Restou saída de depuração (`puts`, `binding.irb`, `console.log`, `debugger`)? | Importante |
| Há números e textos mágicos sem nome? | Sugestão |
| Escritas são idempotentes onde deveriam (jobs, webhooks)? | Importante |
| Pontos críticos têm log estruturado? | Importante |
| Há acoplamento desnecessário entre camadas ou módulos? | Importante |
| Lógica não óbvia tem um comentário explicando o porquê? | Sugestão |

**Convenções do projeto viram critério.** Exemplos do que pode estar no `AGENTS.md` e passar a ser cobrado:
- "Regras ficam em objetos de serviço, controllers só orquestram" → regra no controller é Importante.
- "Erros de negócio retornam um objeto de resultado, nunca exceção" → exceção de negócio é Importante.
- "Consultas complexas ficam em scopes ou query objects" → SQL espalhado no controller é Importante.
- "Componentes de interface em ViewComponent" → partial novo com lógica é Importante.

**O que não fazer**
- Comentar formatação (é do linter).
- Cobrar preferência que o projeto não declara.
- Propor refatoração ampla dentro do review.
- Otimizar desempenho que não é qualidade prioritária.

**Ajustando a severidade**
- Sugestão → Importante: o problema se repete no diff ou está em código que servirá de modelo para outras tarefas.
- Importante → Bloqueante: há risco direto (perda de dado, vazamento, comportamento errado em produção).
- Bloqueante → Importante: o ponto está registrado como dívida consciente num ADR ou comentário, com justificativa defensável.

---

## Eixo 6 — Segurança

*O `security-checklist.md` da stack, aplicado **apenas às linhas do diff**.* Sem checklist para a stack, use a seção de segurança de `stacks/_generic/profile.md`.

| Pergunta | Se "não" |
| --- | --- |
| Toda entrada externa (parâmetros, headers, payload de webhook, arquivo enviado) é validada ou filtrada antes do uso? | Importante a Bloqueante |
| Consultas e comandos são montados sem interpolar entrada do usuário (SQL, shell, caminhos de arquivo)? | Bloqueante |
| Saída para HTML é escapada; nada de marcar como seguro um conteúdo vindo do usuário? | Bloqueante |
| Toda ação nova verifica autenticação **e** autorização (o usuário pode agir sobre *este* registro)? | Bloqueante |
| Dados pessoais e segredos ficam fora de logs, mensagens de erro e respostas da API? | Bloqueante |
| Não há segredo, token ou senha no código ou em arquivos versionados? | Bloqueante |
| Redirecionamentos e URLs montados com entrada do usuário são restritos a destinos permitidos? | Importante |
| Dependências novas são conhecidas, mantidas e sem vulnerabilidade conhecida? | Importante |
| Ações sensíveis (pagamento, troca de senha, exclusão) têm proteção contra repetição/abuso quando o PRD pede? | Importante |
| A ferramenta de análise da stack, se executada com permissão, não trouxe alerta novo? | conforme o alerta |

**Limites do eixo**
- Não é auditoria completa nem modelagem de ameaças — é a verificação mínima que todo diff merece.
- Não invente ameaça sem relação com o código alterado.
- Alerta de ferramenta precisa ser confirmado no código antes de virar apontamento (falso positivo existe).

---

## Eixo 7 — Interface *(somente com SPEC-UI e campo `Telas:`)*

Sem SPEC-UI ou sem `Telas:` na tarefa, pule o eixo — nada de apontamento de interface sem especificação.

| Pergunta | Se "não" |
| --- | --- |
| Todo estado listado em `Telas:` foi implementado? | Bloqueante |
| Campos e controles batem com a SPEC-UI? | Importante |
| Componentes marcados como reutilizáveis foram usados, e não recriados? | Importante |
| O erro de envio do formulário mantém os dados digitados (quando especificado)? | Bloqueante |
| O vazio por filtro é diferente do vazio inicial (quando especificado)? | Importante |
| Restrições de interface (acessibilidade, tema escuro, idiomas) foram respeitadas? | Importante a Bloqueante |
| A tela faz algo que a SPEC-UI não prevê? | Importante — pedir justificativa (pode ser lacuna da especificação) |

**O limite:** estrutura, estados e comportamento. **Não** viram apontamento: cor, espaçamento, tamanho de fonte, composição, "ficaria mais bonito se…". Se a implementação claramente ignorou o protótipo, registre **um** apontamento Importante sobre o padrão, não um por detalhe.

**Sinais de alerta**
- Só o estado padrão existe, embora `Telas:` liste três — Bloqueante.
- O estado existe no código mas nenhuma condição o exibe — Importante.
- Componente reutilizável copiado em outra tela — Importante.
- Estado "derivado do PRD" implementado ao pé da letra sem validação de design — não é apontamento, mas vale nota sugerindo validar.

---

## Notas ao processo

Não são `R-XX`; vão para a seção própria do relatório:

- **Plano a ajustar** — a tarefa estava mal dimensionada ou faltam tarefas
- **PRD ambíguo** — a redação de uma regra ou cenário permitiu duas leituras
- **Decisão sem ADR** — o código tomou uma decisão de arquitetura não registrada
- **Padrão novo** — convenção que o time passou a seguir sem documentar
- **SPEC-UI incompleta** — a implementação precisou de um estado que a especificação não previa

---

## Severidade de bolso

| Situação | Bloqueante | Importante | Sugestão |
| --- | --- | --- | --- |
| Critério de aceite não atendido | ✓ | | |
| Teste prometido ausente (CA da tarefa) | ✓ | | |
| ADR aceito desrespeitado sem ADR novo | ✓ | | |
| RN não implementada | ✓ | | |
| Interpolação de entrada em SQL/shell | ✓ | | |
| Ação sem verificação de autorização | ✓ | | |
| Dado pessoal em log | ✓ | | |
| Segredo no código | ✓ | | |
| Teste desligado sem motivo / sem asserção | ✓ | | |
| Estado de tela especificado e ausente | ✓ | | |
| Formulário que perde dados no erro | ✓ | | |
| Escopo ampliado sem justificativa | | ✓ | |
| Borda de regra sem teste | | ✓ | |
| Convenção do projeto violada de forma sistemática | | ✓ | |
| Concorrência suspeita | | ✓ | |
| Tratamento de erro inconsistente | | ✓ | |
| Saída de depuração esquecida | | ✓ | |
| Nome de teste fora da convenção de CA | | ✓ | |
| Componente reutilizável recriado | | ✓ | |
| Campo diferente da SPEC-UI | | ✓ | |
| Dependência nova sem avaliação | | ✓ | |
| Código morto | | ✓ | ✓ |
| Número mágico | | | ✓ |
| Nome que poderia ser melhor | | | ✓ |
| Comentário faltando em lógica complexa | | | ✓ |
| Commit fora do padrão ou sem a T-XX | | | ✓ |
| Detalhe visual | | | — não é apontamento |
