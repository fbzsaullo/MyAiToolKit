# Modelo — relatório de code review

Salvo pela skill `code-review` em `docs/sdd/code-reviews/CR-<branch>-AAAA-MM-DD.md`. Os apontamentos são agrupados por **quadrante** (Q1 → Q4), e cada um mostra também a **severidade**.

> As quatro crases externas apenas delimitam o modelo; as cercas de três crases internas fazem parte do relatório.

---

````markdown
# Code review — [branch ou PR]

- **Alvo:** [ex.: `origin/feature/parcelamento` · PR #128]
- **Base:** [ex.: `main`] (merge-base `a1b2c3d`)
- **Autor:** [nome] · **Modo:** [próprio / colega]
- **História:** [ex.: PROJ-123 — Checkout com pagamento parcelado (jira-xml)] *(ou "sem história")*
- **Stack:** [ex.: Rails 8.0 / Ruby 3.3 — fonte: docs/sdd/config.yml]
- **Tamanho:** [ex.: 12 commits · 18 arquivos · +642 −87]
- **Data:** AAAA-MM-DD
- **Veredito:** [⛔ Não pronto para merge / ⚠️ Pronto com ajustes / ✅ Pronto]

---

## Resumo

[Um parágrafo: o que a mudança faz, o que está bom, o que precisa mudar antes do merge.]

### Matriz urgência × importância

| | **Importante** | **Não importante** |
| --- | --- | --- |
| **Urgente** | **Q1 — Corrigir antes do merge:** 2 | **Q3 — Ajuste rápido agora:** 3 |
| **Não urgente** | **Q2 — Planejar:** 1 | **Q4 — Opcional:** 4 |

### Por severidade

| Bloqueante | Importante | Sugestão | Total |
| --- | --- | --- | --- |
| 2 | 2 | 6 | 10 |

---

## Roteiro aplicado

- **Eixos:** aderência à história, correção, testes, qualidade, segurança[, operação]
- **Checklists:** [ex.: `stacks/rails/review-checklist.md`, `stacks/rails/security-checklist.md`]
- **Convenções do projeto:** [ex.: AGENTS.md — serviços em `app/services`, Pundit em toda action]
- **Ferramentas executadas (com permissão):**

| Ferramenta | Escopo | Resultado |
| --- | --- | --- |
| rubocop | 14 arquivos do diff | 3 alertas (2 viraram CR-05; 1 só formatação) |
| brakeman | arquivos do diff | 1 alerta confirmado (CR-01) |
| rspec | 4 specs relacionadas | 1 falha (CR-02) |

*(Ferramentas não executadas: dizer por quê — não autorizado, não configurado.)*

---

## 🔴 Q1 — Corrigir antes do merge

#### CR-01 — [problema em poucas palavras]

- **Severidade:** Bloqueante · **Eixo:** Segurança
- **Onde:** `app/models/pedido.rb:42`
- **O que acontece:** [descrição objetiva; trecho se ajudar]

  ```ruby
  Pedido.where("status = '#{params[:status]}'")
  ```

- **Por que é Q1:** [efeito concreto assim que entrar]
- **Caminho sugerido:** [correção defensável]

#### CR-02 — [...]

[mesma estrutura]

## 🟠 Q2 — Planejar

#### CR-03 — [...]

- **Severidade:** Importante · **Eixo:** Qualidade
- **Onde:** [...]
- **O que acontece:** [...]
- **Por que pode esperar:** [...]
- **Registrar como:** [ex.: card "Mover regra de parcelamento para serviço" / tarefa no PLAN-004]

## 🟡 Q3 — Ajuste rápido agora

#### CR-04 — [...]

[estrutura curta: severidade, onde, o que fazer]

## ⚪ Q4 — Opcional

- **CR-07** (Sugestão) — `app/services/parcelamento.rb:18` — [sugestão em uma linha]
- **CR-08** (Sugestão) — [...]

---

## Cobertura da história *(omitir sem história)*

| Critério de aceite | Implementado em | Teste | Situação |
| --- | --- | --- | --- |
| Cliente escolhe de 1 a 12 parcelas | `app/views/checkout/_parcelas.html.erb` | `spec/system/checkout_spec.rb:30` | ✅ |
| Parcela mínima de R$ 20 | `app/services/parcelamento.rb:25` | — | ⚠️ sem teste (CR-02) |
| Juros a partir da 7ª parcela | não encontrado | — | ❌ ver o CR correspondente (sempre Q1) |

**Escopo fora da história:** [ex.: alteração no layout do carrinho não prevista no card — pedir justificativa (CR-06)]

---

## O que está bom

- [ex.: serviço de cálculo bem isolado e fácil de testar]
- [ex.: migration reversível e com índice]

---

## Comentários prontos para o PR *(modo colega)*

```
**[Q1 · Bloqueante] Interpolação de parâmetro na consulta**
`app/models/pedido.rb:42` — `where("status = '#{params[:status]}'")` abre espaço para SQL injection.
Sugestão: `where(status: params[:status])`, com o valor validado contra a lista de status.
```

```
**[Q3 · Sugestão] `binding.irb` esquecido**
`app/controllers/checkout_controller.rb:57` — remover antes do merge.
```

## Antes de abrir o PR *(modo próprio)*

- [ ] Resolver CR-01 e CR-02 (Q1)
- [ ] Ajustes rápidos: CR-04, CR-05 (Q3)
- [ ] Registrar CR-03 como card (Q2)
- [ ] Rodar `bin/rubocop` e `bundle exec rspec`
- [ ] Descrição do PR citando PROJ-123 e o que foi testado
````
