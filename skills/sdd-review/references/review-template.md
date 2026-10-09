# Modelo — Relatório de Review (SDD)

Preenchido pela skill `sdd-review`. Ordem das seções fixa. Arquivo: `docs/sdd/reviews/REVIEW-T-XX-AAAA-MM-DD.md` (rounds seguintes com `-roundN`).

> Sobre as cercas: as quatro crases externas apenas delimitam o modelo; as cercas de três crases internas fazem parte do relatório.

---

````markdown
# Review T-XX — [título da tarefa, igual ao do plano]

- **Plano:** `docs/sdd/plans/PLAN-XXX-tema.md`
- **PRD:** `docs/sdd/prds/PRD-XXX-tema.md`
- **ADRs considerados:** [ADR-XXX, ADR-YYY — ou "nenhum"]
- **SPEC-UI:** [caminho — ou "não se aplica"]
- **Revisor:** agente de IA (skill `sdd-review`)[ + verificador independente]
- **Revisão cruzada:** [desligada / pulada (modo automático: sem Bloqueante nem correção de Bloqueante a conferir) / feita — N verificados (C confirmados, D descartados, E em disputa, I inconclusivos)[ · M correções conferidas (A resolvidas, B reabertas, C em disputa)] / incompleta — motivo / indisponível neste ambiente]
- **Data:** AAAA-MM-DD
- **Commit revisado:** [hash curto do código revisado — ou "não se aplica" para patch avulso]
- **Round:** [1 / 2 / 3]
- **Recomendação:** [✅ Aprovado / ⚠️ Aprovado com ressalvas / ⛔ Bloqueado]

---

## Visão geral

[Um parágrafo: o que foi entregue, o que está bom e o que precisa ser resolvido antes do merge.]

**Apontamentos**

| Severidade | Qtde |
| --- | --- |
| Bloqueante | X |
| Importante | Y |
| Sugestão | Z |
| **Total** | **N** |

**O que a tarefa prometeu × o que entregou**

| Item | Prometido | Entregue | Situação |
| --- | --- | --- | --- |
| Regras (RN) | RN-02, RN-04 | RN-02, RN-04 | ✅ |
| Cenários (CA) | CA-01, CA-02, CA-05 | CA-01, CA-02 | ⚠️ CA-05 sem teste |
| Decisões (ADR) | ADR-002 | respeitada | ✅ |
| Critérios de aceite | 3 | 2 atendidos, 1 parcial | ⚠️ |
| Telas e estados (UI) | UI-02 (default, ocupado, antecedencia) | default, antecedencia | ⚠️ falta `.ocupado` |
| Testes prometidos | 4 | 3 | ⚠️ falta o do CA-05 |

---

## Contexto

### Stack

- [ex.: Ruby 3.3 / Rails 8.0]
- [ex.: PostgreSQL 16]
- [ex.: Hotwire + Tailwind]
- **Fonte:** [docs/sdd/config.yml / AGENTS.md / arquitetura / inspeção do repositório / usuário]

### Convenções aplicadas (do próprio projeto)

- [ex.: "regras de negócio em objetos de serviço em `app/services`" (AGENTS.md)]
- [ex.: "testes de cenário em `spec/requests` com `it \"CA-XX: ...\"`" (config.yml)]
- **Checklists da stack:** [ex.: `stacks/rails/review-checklist.md`, `stacks/rails/security-checklist.md`]

*Sem convenções documentadas no projeto, escreva:*

> ⚠️ O projeto não documenta convenções próprias (`AGENTS.md`/`CLAUDE.md` ausente ou incompleto). Foram aplicados apenas critérios universais e o checklist genérico da stack.

### Tamanho do diff

- **Arquivos alterados:** N
- **Linhas:** +AAA / −RRR
- **Commits:** N
- **Branch base comparada:** [ex.: `main`]

---

## Apontamentos

Numerados `R-01`, `R-02`… neste relatório. Cada um com eixo, severidade, evidência e sugestão.

### 🔴 Bloqueantes

Impedem o merge.

#### R-01 — [problema em poucas palavras]

- **Eixo:** [1 Plano / 2 Rastreabilidade / 3 Especificação / 4 Testes / 5 Qualidade / 6 Segurança / 7 Interface]
- **Ligado a:** [RN-XX, CA-XX, ADR-XXX, UI-XX — quando houver]
- **Onde:** `app/services/agendar_consulta.rb:31-44`
- **O que está errado:** [descrição objetiva; trecho de código se ajudar]

  ```ruby
  # trecho problemático
  ```

- **Por que bloqueia:** [viola a RN-XX / teste não passa / risco concreto em produção]
- **Caminho sugerido:** [uma correção defensável — não necessariamente a única]

### 🟡 Importantes

Resolver nesta tarefa ou adiar de forma explícita.

#### R-02 — [...]

[mesma estrutura]

### 🟢 Sugestões

Melhorias opcionais, a critério de quem implementou.

#### R-03 — [...]

[mesma estrutura, mais curta]

---

## Regras prometidas (Implementa)

### RN-04 — [texto da regra, como está no PRD]

- **Onde está no código:** [resumo objetivo]
- **Evidência:** `app/services/agendar_consulta.rb:20-38`
- **Situação:** ✅ implementada

### RN-07 — [texto da regra]

- **Onde está no código:** não encontrada / implementada de forma diferente
- **Situação:** ❌ ver R-01

---

## Cenários prometidos (Valida)

### CA-01 — [título do cenário, como está no PRD]

- **Teste:** `spec/requests/consultas_spec.rb` — `it "CA-01: agenda em horário livre"`
- **Cobre o cenário inteiro?** Sim — Dado/Quando/Então representados
- **Situação:** ✅

### CA-05 — [título]

- **Teste:** não encontrado
- **Situação:** ❌ ver R-02

---

## Telas prometidas (Telas) — omitir sem SPEC-UI

### UI-02 — [nome da tela, como está na SPEC-UI]

| Estado | Especificado | Implementado | Evidência |
| --- | --- | --- | --- |
| `.default` | Sim | ✅ | `app/views/consultas/new.html.erb:1-40` |
| `.antecedencia` | Sim | ✅ | `app/views/consultas/_antecedencia.html.erb` |
| `.ocupado` | Sim | ❌ | ver R-02 |

*Uma tabela por tela listada em `Telas:`.*

---

## Decisões de arquitetura

### ADR-002 — [título]

- **O que o ADR determina:** [resumo]
- **Como o código fez:** [arquivo:linha]
- **Conformidade:** ✅ usa `lock!` dentro da transação, como decidido

*Uma entrada por ADR de `Decisões base:`.*

---

## Segurança — resumo do eixo 6

| Verificação | Resultado |
| --- | --- |
| Entrada não confiável validada / parâmetros permitidos explicitamente | ✅ / ❌ R-XX |
| Consultas sem interpolação de entrada | ✅ / ❌ R-XX |
| Autorização no ponto de entrada | ✅ / ❌ R-XX |
| Dados pessoais fora de logs e respostas | ✅ / ❌ R-XX |
| Sem segredo no código | ✅ / ❌ R-XX |
| Ferramenta de análise da stack (se executada com permissão) | [ex.: brakeman — 0 alertas novos] |

---

## Verificação cruzada — omitir se desligada, pulada ou indisponível

Um verificador independente tentou derrubar cada apontamento grave, sem ver o raciocínio do revisor (`templates/cross-check.md`).

| Apontamento | Severidade (antes → depois) | Verificador | Evidência do verificador | Decisão |
| --- | --- | --- | --- | --- |
| R-01 | Bloqueante → Bloqueante | Confirmado | `app/services/agendar_consulta.rb:31` — sem lock na leitura | mantido |
| R-02 | Bloqueante → Bloqueante | Refutado | `app/controllers/application_controller.rb:6` — `before_action` | em disputa — decidido pelo usuário: manter |
| R-03 | Importante → Sugestão | Confirmado (severidade menor) | `app/models/consulta.rb:12` — valor nunca chega nulo | rebaixado: o banco já impede o nulo |
| R-04 | Importante → Importante | Inconclusivo | depende de configuração fora do repositório | mantido |

### Candidatos descartados

Refutados com contra-evidência conferida. Não receberam número.

| Candidato | Severidade proposta | Contra-evidência |
| --- | --- | --- |
| Falta teste do horário de verão | Importante | `spec/services/agendar_consulta_spec.rb:88` cobre o caso |

---

## Notas ao processo (não são apontamentos)

- **Plano a ajustar:** [ex.: a T-04 entregou mais do que listava; sugerir extrair tarefa]
- **PRD ambíguo:** [ex.: a RN-08 permite duas leituras]
- **Decisão sem ADR:** [o código tomou uma decisão de arquitetura não registrada]
- **Padrão novo:** [convenção que o time passou a seguir e não está no `AGENTS.md` — sugerir `/sdd-setup refresh`]
- **Contexto desatualizado:** [o `AGENTS.md` descreve algo que o código já não segue — sugerir `/sdd-setup audit`]

---

## Round anterior (a partir do round 2)

Comparado com `REVIEW-T-XX-AAAA-MM-DD.md` (commit revisado `a1b2c3d` → agora `e4f5a6b`). A numeração recomeçou neste relatório: os `R-XX` da tabela são do round anterior.

| Apontamento anterior | Situação | Verificador | Comentário |
| --- | --- | --- | --- |
| R-01 (round 1, Bloqueante) — SQL com parâmetro interpolado | ⚠️ Persiste (reaberto pelo verificador) | Persiste — `app/models/pedido.rb:12` ainda interpola `params[:ordem]` | ver R-01 deste round |
| R-02 (round 1, Importante) — faltava teste do CA-05 | ✅ Resolvido | Resolvido — `spec/requests/consultas_spec.rb:40` exercita o cenário inteiro | — |
| R-03 (round 1, Importante) — e-mail do paciente no log | ⚠️ Persiste | — (marcado Persiste: não vai ao verificador) | ver R-02 deste round |
| R-04 (round 1, Sugestão) — número mágico | ✅ Resolvido | — (Sugestão: não é conferida) | constante extraída |

*Coluna Verificador: só com revisão cruzada; nas demais situações, escreva o motivo de não haver conferência entre parênteses. Correção de Bloqueante com resposta `Inconclusivo` aparece como "em disputa — decidido pelo usuário: …".*

*Apontamento que esteve em disputa no round anterior: acrescente a decisão do usuário entre parênteses, ex.: "R-02 (round 1, em disputa — mantido pelo usuário)".*

---

## Fechamento

[Um ou dois parágrafos: reconheça o que está bom e seja claro sobre o que falta.]

**Próximos passos**

- [ex.: resolver R-01 e R-02 antes do merge]
- [ex.: decidir se R-03 entra agora ou vira tarefa]
- [ex.: registrar o padrão novo no `AGENTS.md`]
````
