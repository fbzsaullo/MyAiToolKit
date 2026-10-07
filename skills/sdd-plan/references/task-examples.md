# Tarefas de referência — tamanho e preenchimento

Exemplos para calibrar como escrever tarefas no plano: o tamanho certo (nem gigante, nem picadinho), o preenchimento correto de `Implementa`, `Valida` e `Decisões base`, e o formato de cada tipo de tarefa.

Os exemplos usam nomes genéricos de camada e pseudocódigo, sem framework. A mesma série em Rails real (migrations, models, objetos de serviço, RSpec) está em `${CLAUDE_PLUGIN_ROOT}/stacks/rails/task-examples.md`.

O domínio é sempre o mesmo: **agendamento de consultas** numa clínica.

---

## A régua de tamanho

Uma tarefa boa vira **um commit ou um PR curto** e leva entre **30 minutos e 4 horas** — o teto único do toolkit, definido em `templates/id-conventions.md`. Passou disso, divida. Ficou abaixo de uns 10 minutos, é detalhe de outra tarefa.

Essa régua orienta o corte; ela não é escrita na tarefa. O plano registra `Complexidade` e, se o usuário quiser, a `Estimativa` que ele mesmo informar.

| Sinal de tarefa grande demais | O que fazer |
| --- | --- |
| Mais de 3 critérios de aceite | Dividir em duas |
| `Implementa:` com 4 ou mais regras | Provavelmente são duas tarefas juntas |
| A descrição precisa de "e também" / "além disso" | Tarefa dupla |
| Mais de 4h na sua cabeça | Dividir |
| Toca mais de 3 camadas | Tentar separar por camada — **exceto** no corte vertical deliberado (Exemplo 6), em que atravessar camadas é o objetivo e o corte é por comportamento |

| Sinal de tarefa pequena demais | O que fazer |
| --- | --- |
| Trivial, sem critério de aceite de verdade | Juntar com a anterior |
| "Criar a pasta X" | Faz parte da tarefa que cria o arquivo |
| "Renomear a variável Y" | Refatoração do momento, não tarefa de plano |

---

## Exemplo 1 — Estrutura (Fase 1)

Tarefas de estrutura em geral **não preenchem `Implementa` nem `Valida`**: elas preparam o terreno, não materializam regra.

```markdown
#### T-01 — Criar a entidade Consulta e sua persistência

- **Status:** Pendente
- **Complexidade:** Baixa
- **Estimativa:**
- **Depende de:** nenhuma
- **Implementa:** —
- **Valida:** —
- **Decisões base:** ADR-001 *(monolito modular, módulo Agenda)*
- **Arquivos/camadas:**
  - `persistencia/migracoes/criar-consultas` *(novo)*
  - `dominio/agenda/consulta` *(novo)*

**O que fazer:**
Criar a entidade `Consulta` com `id`, `medicoId`, `pacienteId`, `iniciaEm`,
`terminaEm` e `situacao` (pendente, confirmada, cancelada, realizada). Na
persistência: índice único em `(medicoId, iniciaEm)` e restrição
`terminaEm > iniciaEm`. Ainda sem comportamento — só a estrutura.

**Critério de aceite (testável):**
- [ ] Migração aplica e reverte sem erro
- [ ] Índice único e restrição de horário existem no banco

**Testes a escrever:**
- *Não se aplica* — estrutura pura. As regras ganham teste nas T-03 e T-04.

**Riscos / atenção:**
- Conferir no `AGENTS.md` se o projeto tem convenção de nome para tabelas de módulo.
```

---

## Exemplo 2 — Regra de negócio (Fase 2)

Tarefa de regra **sempre preenche `Implementa`** e quase sempre `Valida`.

```markdown
#### T-03 — Agendar consulta garantindo um paciente por horário

- **Status:** Pendente
- **Complexidade:** Alta
- **Estimativa:**
- **Depende de:** T-01, T-02
- **Implementa:** RN-02, RN-04
- **Valida:** CA-01, CA-05
- **Decisões base:** ADR-002 *(bloqueio de linha para disputa de horário)*
- **Arquivos/camadas:**
  - `aplicacao/agenda/agendar-consulta` *(novo)*
  - `aplicacao/agenda/resultado-agendamento` *(novo)*
  - `persistencia/agenda/repositorio-de-horarios` *(editado)*

**O que fazer:**
Caso de uso que: (1) abre transação; (2) lê o horário com bloqueio de escrita
(`buscarHorarioComBloqueio`); (3) verifica antecedência mínima de 2h e se o
horário segue livre; (4) cria a consulta como "confirmada"; (5) confirma a
transação. Violação de regra vira erro de negócio com mensagem própria; falha
técnica sobe para o tratamento global.

**Critério de aceite (testável):**
- [ ] CA-01 verde: agendamento em horário livre cria a consulta confirmada
- [ ] CA-05 verde: 50 confirmações simultâneas no mesmo horário → exatamente 1 sucesso
- [ ] Falha técnica (tempo esgotado no banco) não vira erro de negócio

**Testes a escrever:**
- *Unidade:* "CA-01: agenda em horário livre", "recusa com menos de 2h (RN-02)"
- *Integração:* "persiste a consulta em banco real"
- *Concorrência:* "CA-05: confirmações simultâneas geram uma única consulta"

**Riscos / atenção:**
- Bloqueio de linha tem custo sob carga — acompanhar espera por bloqueio (T-10).
- **Validação humana sugerida:** revisar com quem lidera tecnicamente antes da
  T-05 — a estratégia de bloqueio tem impacto operacional.
```

---

## Exemplo 3 — Exposição (Fase 3)

Tarefa de rota/endpoint **preenche `Valida`**, porque é ela que faz o cenário acontecer de ponta a ponta.

```markdown
#### T-05 — Expor a criação de consulta via POST /consultas

- **Status:** Pendente
- **Complexidade:** Média
- **Estimativa:**
- **Depende de:** T-03, T-04
- **Implementa:** —
- **Valida:** CA-01, CA-02, CA-05
- **Decisões base:** ADR-003 *(entrada HTTP fina, regra no caso de uso)*
- **Arquivos/camadas:**
  - `entrada/http/consultas` *(novo)*
  - `entrada/http/rotas` *(editado)*

**O que fazer:**
Rota que recebe médico e horário, obtém o paciente da sessão autenticada,
chama o caso de uso e traduz o resultado: sucesso → 201; regra violada → 422
com a mensagem de negócio; sem autenticação → 401; demais erros → tratamento global.

**Critério de aceite (testável):**
- [ ] Paciente autenticado agenda e recebe 201 (CA-01)
- [ ] Menos de 2h de antecedência → 422 com a mensagem correta (CA-02)
- [ ] Horário tomado → 422 com a mensagem correta (CA-05)
- [ ] Sem autenticação → 401

**Testes a escrever:**
- *Requisição:* "CA-01: POST /consultas cria e retorna 201", "CA-02: retorna 422 por antecedência",
  "retorna 401 sem sessão"

**Riscos / atenção:**
- Avaliar limite de requisições por paciente (scripts tentando reservar horários).
```

---

## Exemplo 4 — Qualidade e operação (Fase 5)

Logs, métricas e alertas em geral **não preenchem `Implementa` nem `Valida`** — não provam regra nem fecham cenário, mas sem eles não se vai para produção.

```markdown
#### T-10 — Instrumentar o agendamento com logs e métricas

- **Status:** Pendente
- **Complexidade:** Média
- **Estimativa:**
- **Depende de:** T-05
- **Implementa:** —
- **Valida:** —
- **Decisões base:** ADR-006 *(observabilidade com OpenTelemetry)*
- **Arquivos/camadas:**
  - `aplicacao/agenda/agendar-consulta` *(editado)*
  - `infra/telemetria/metricas-agenda` *(novo)*

**O que fazer:**
(1) log estruturado em cada tentativa com `medicoId`, `resultado`
(confirmada / antecedencia / ocupado) e identificador da requisição;
(2) contadores `agendamento_tentativas` e `agendamento_resultados{resultado}`;
(3) histograma do tempo de espera pelo bloqueio.

**Critério de aceite (testável):**
- [ ] Toda tentativa gera um log estruturado com identificador da requisição
- [ ] Métricas visíveis no ambiente local
- [ ] Nenhum dado pessoal (nome, CPF, telefone) nos logs

**Testes a escrever:**
- *Unidade (com logger falso):* "registra resultado correto", "não registra dado pessoal"

**Riscos / atenção:**
- `pacienteId` como rótulo de métrica explode a cardinalidade — use só no log.
```

---

## Exemplo 5 — Tarefa que existe por causa de uma decisão

Quando a tarefa nasce para materializar um ADR, `Decisões base` carrega o ADR e `Implementa` pode ficar vazio.

```markdown
#### T-12 — Colocar o agendamento online atrás de feature flag

- **Status:** Pendente
- **Complexidade:** Média
- **Estimativa:**
- **Depende de:** T-05
- **Implementa:** —
- **Valida:** —
- **Decisões base:** ADR-005 *(liberação gradual por clínica)*
- **Arquivos/camadas:**
  - `entrada/http/consultas` *(editado)*
  - `interface/agenda` *(editado)*
  - `configuracao/flags` *(editado)*

**O que fazer:**
Proteger a rota e o botão "Agendar online" com a flag `agendamento_online`:
desligada por padrão, ligada para as clínicas do grupo piloto. Explicar no
`AGENTS.md` como ligar e desligar.

**Critério de aceite (testável):**
- [ ] Flag desligada: rota responde 404 e o botão não aparece
- [ ] Flag ligada: comportamento normal
- [ ] Grupo piloto recebe a funcionalidade

**Testes a escrever:**
- *Requisição:* "404 com flag desligada", "201 com flag ligada"

**Riscos / atenção:**
- Validação humana antes do deploy: confirmar a flag desligada em produção.
```

---

## Exemplo 6 — Corte vertical deliberado

Exceção ao corte por camada dos exemplos anteriores. Só vale quando a conversa (Bloco 2 ou 4 do `SKILL.md`) mostrou entrega incremental real ou risco concreto de integração — ver "Corte horizontal ou vertical".

A tarefa atravessa as camadas de propósito, mas o comportamento coberto é estreito (só o caminho feliz de um `CA-XX`), para continuar dentro das 4h. O corte aqui é por cenário.

```markdown
#### T-01 — Fatia: paciente agenda em horário livre (caminho feliz)

- **Status:** Pendente
- **Complexidade:** Alta
- **Estimativa:**
- **Depende de:** nenhuma
- **Implementa:** RN-01
- **Valida:** CA-01
- **Decisões base:** ADR-003 *(entrada HTTP fina)*; ADR-002 fica para a próxima fatia
- **Arquivos/camadas:**
  - `persistencia/migracoes/criar-consultas` *(novo)*
  - `dominio/agenda/consulta` *(novo)*
  - `aplicacao/agenda/agendar-consulta` *(novo)*
  - `entrada/http/consultas` *(novo)*

**O que fazer:**
O mínimo que atravessa as quatro camadas para o caminho feliz: entidade e
persistência, caso de uso que cria a consulta (ainda sem bloqueio — a disputa
de horário é o CA-05, próxima fatia) e a rota. Objetivo: algo demonstrável
de ponta a ponta o quanto antes, não a funcionalidade inteira.

**Critério de aceite (testável):**
- [ ] CA-01 verde: POST /consultas em horário livre retorna 201 e cria a consulta

**Testes a escrever:**
- *Requisição:* "CA-01: agenda em horário livre"

**Riscos / atenção:**
- Antecedência (RN-02) e disputa de horário (CA-05) ficam para as próximas fatias.
- Este corte gera **mais tarefas** que o horizontal equivalente (compare com as
  T-01, T-03 e T-05 acima): o ganho é ver funcionando cedo, não fazer menos.
```

---

## Quando um campo fica vazio

| Tipo de tarefa | `Implementa` | `Valida` | `Decisões base` |
| --- | --- | --- | --- |
| Estrutura (entidade, migration) | vazio | vazio | pode citar ADR de estrutura |
| Regra de negócio | obrigatório | provável | provável |
| Exposição (rota, endpoint) | vazio (a regra está no caso de uso) | provável | pode citar |
| Interface (componente, tela) | vazio | possível | possível |
| Observabilidade | vazio | vazio | provável |
| Testes transversais | vazio | vários CAs | vazio |
| Migração de dados | vazio | vazio | possível |

**Regra prática:** tarefa sem nenhum dos três campos merece a pergunta "ela precisa mesmo existir?". Tarefa sem rastreio costuma ser candidata a corte ou a fusão com outra.
