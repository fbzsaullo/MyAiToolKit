# Estados de tela — catálogo

O trecho que mais gera valor numa SPEC-UI. Protótipos mostram o caminho feliz; os bugs de interface quase sempre nascem nos estados que ninguém desenhou.

Todo estado recebe um ID com sufixo — `UI-03.erro`, `UI-03.vazio`, `UI-03.carregando` — para que a tarefa declare `Telas: UI-03 (default, erro)` e o review confira item por item.

---

## Estados que quase toda tela tem

Valem para qualquer tela que busca ou envia dados.

**`.default`** — dados presentes, tudo funcionando. O único que os protótipos sempre trazem.

**`.carregando`** — a requisição está em andamento.
Sem definição, cada dev resolve de um jeito e o produto fica com cinco indicadores diferentes (ou nenhum). Em listas, um esqueleto da estrutura costuma funcionar melhor que um spinner, porque o layout não "pula".
*Defina:* esqueleto ou spinner; a tela toda ou só a região que carrega (num Turbo Frame, por exemplo); controles bloqueados ou não.

**`.vazio`** — não há nada para mostrar. Não é erro: nada falhou.
É a primeira tela que um usuário novo vê e a mais esquecida. Bem feita, ensina e oferece o próximo passo; mal feita, parece defeito.
*Defina:* mensagem, imagem (se houver) e principalmente **a ação sugerida** ("Cadastrar o primeiro médico").
Separe dois casos que costumam ser misturados:
- **vazio de verdade** — o usuário ainda não criou nada; deve orientar;
- **vazio por filtro** — existem dados, o filtro é que não achou nada; deve oferecer limpar o filtro.

**`.erro`** — a requisição falhou.
*Defina:* mensagem compreensível (sem termos técnicos), se há "tentar de novo" e se a falha afeta a tela toda ou só uma área. "Algo deu errado" sem nenhuma ação é estado incompleto.

**`.semPermissao`** — o usuário entrou no sistema, mas não pode ver ou fazer aquilo.
*Obrigatório* quando o PRD tem permissões com mais de um perfil.
*Defina:* a tela inteira é bloqueada ou só alguns elementos somem ou ficam desabilitados? Ocultar e desabilitar comunicam coisas diferentes — desabilitar revela que a função existe.

---

## Mínimos por tipo de tela

### Lista

| Estado | Obrigatório? | Observação |
| --- | --- | --- |
| `.default` | Sim | — |
| `.carregando` | Sim | Esqueleto é melhor que spinner |
| `.vazio` | Sim | Distinto do vazio por filtro |
| `.vazioFiltro` | Se houver filtro | Oferece limpar filtro |
| `.erro` | Sim | Com "tentar de novo" |
| `.carregandoMais` | Se houver rolagem infinita | Não é o mesmo que o carregamento inicial |
| `.parcial` | Se houver paginação | Indica que existe mais além do exibido |

### Formulário

| Estado | Obrigatório? | Observação |
| --- | --- | --- |
| `.default` | Sim | Vazio ou pré-preenchido |
| `.validacao` | Sim | Mensagem junto a cada campo, não um alerta genérico (em Rails, os `errors` do model renderizados com status 422) |
| `.enviando` | Sim | Botão bloqueado e indicação de progresso — **evita envio em dobro** |
| `.sucesso` | Sim | Confirmação; definir se redireciona ou fica |
| `.erroEnvio` | Sim | Falha no servidor, diferente de validação. **Os dados digitados ficam na tela** |
| `.conflito` | Se houver edição concorrente | Outra pessoa alterou o mesmo registro (ex.: `lock_version`). Frequente e quase sempre esquecido |

**O erro mais comum de todos:** `.erroEnvio` apagando o que o usuário digitou. Escreva com todas as letras que os dados são preservados.

### Detalhe

| Estado | Obrigatório? | Observação |
| --- | --- | --- |
| `.default` | Sim | — |
| `.carregando` | Sim | — |
| `.naoEncontrado` | Sim | ID inexistente ou registro removido — não é o mesmo que erro |
| `.erro` | Sim | Falha ao carregar |
| `.semPermissao` | Se houver permissões | — |

### Fluxo em etapas (cadastro longo, checkout)

| Estado | Obrigatório? | Observação |
| --- | --- | --- |
| `.etapaN` | Sim | Um por etapa |
| `.processando` | Sim | Entre etapas, quando o servidor valida |
| `.erroEtapa` | Sim | Falha numa etapa — volta ou fica? |
| `.retomada` | Se fizer sentido | O usuário volta outro dia: o progresso é recuperado? |
| `.expirado` | Se houver prazo | Reserva vencida, sessão encerrada |

### Ação que não tem volta (excluir, cancelar, estornar)

| Estado | Obrigatório? | Observação |
| --- | --- | --- |
| `.confirmacao` | Sim | Pergunta antes de executar |
| `.processando` | Sim | Botão bloqueado |
| `.sucesso` | Sim | Retorno ao usuário; existe desfazer? |
| `.erro` | Sim | Falhou — o estado anterior foi mantido? |

---

## Estados que nascem das regras de negócio

Além dos genéricos, cada `RN-XX` que **impede** uma ação tende a gerar um estado próprio. No domínio de agendamento:

| Regra | Estado |
| --- | --- |
| RN-02: antecedência mínima de 2 horas | `UI-02.antecedencia` |
| RN-04: um horário só pode ter uma consulta | `UI-02.ocupado` |
| RN-03: bloqueio após duas faltas no mês | `UI-01.bloqueadoPorFaltas` |

**Como encontrar todos:** percorra os cenários Gherkin do PRD. Todo `Cenário [CA-XX]` cujo `Então` fala em recusa, bloqueio ou mensagem de erro corresponde a um estado de tela.

Esse cruzamento é a principal razão de existir da fase de interface: sem ele, os cenários de erro do PRD não ganham representação e viram improviso na hora de implementar.

---

## Os que mais faltam

Confira rapidamente em cada tela:

- [ ] **Vazio por filtro** tratado como vazio de verdade
- [ ] **Erro de envio** apagando o formulário
- [ ] **Edição simultânea** por duas pessoas
- [ ] **Sessão expirada** no meio de um fluxo longo
- [ ] **Elemento sem permissão** que deveria sumir ou ficar desabilitado
- [ ] **Mudança enquanto a página está aberta** (horário ocupado por outra pessoa; Turbo Streams ajudam aqui)
- [ ] **Texto comprido demais** quebrando o layout
- [ ] **Zero e negativo** em campos numéricos
- [ ] **Sem conexão** — quando o PRD fala de uso em campo ou no celular

Nem todo estado vale para toda tela. O que importa é **passar pela lista e decidir conscientemente** — é isso que diferencia especificação de interface de uma coleção de telas bonitas.

---

## Como fica na SPEC-UI

```markdown
**Estados**

| Estado | ID | Quando acontece | O que aparece | Origem |
| --- | --- | --- | --- | --- |
| Padrão | `UI-02.default` | Horário livre, paciente apto | Resumo da consulta + botão confirmar | Protótipo |
| Enviando | `UI-02.enviando` | Confirmação em andamento | Botão bloqueado com indicador | Protótipo |
| Antecedência | `UI-02.antecedencia` | Menos de 2h para o horário (RN-02) | Aviso + volta para a agenda | Derivado do CA-02 |
| Ocupado | `UI-02.ocupado` | Outra pessoa confirmou antes (RN-04) | Aviso + próximos horários livres | Derivado do CA-05 |
| Falha no envio | `UI-02.erroEnvio` | Erro no servidor | Aviso com "tentar de novo". **Dados mantidos** | Derivado do PRD |
```

A coluna **Origem** não é enfeite: estado "derivado" não passou por design nem por aprovação de quem pediu, e quem implementa precisa saber disso antes de começar.
