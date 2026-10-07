# Modelo — arquivo de spike

Salvo pela skill `spike` em `docs/sdd/spikes/SPIKE-<CHAVE>-<tema>.md`. Contém **somente as horas informadas pelo usuário**; a sugestão da IA fica apenas na conversa.

> As quatro crases externas apenas delimitam o modelo.

---

````markdown
# SPIKE-<CHAVE>: [título do card]

- **Card:** [chave e link, ou "texto informado na conversa"]
- **Origem:** [jira-xml / github-issue / azure-devops / trello / texto / outro]
- **Data:** AAAA-MM-DD
- **Stack:** [ex.: Rails 8.0 / Ruby 3.3 — fonte: docs/sdd/config.yml]
- **Estimativa do usuário:** [ex.: 26h (~4,5 dias de 6h)] *(ou "não informada")*
- **Confiança:** [alta / média / baixa]

## 1. Entendimento

[2 a 4 linhas com o objetivo da atividade, em linguagem própria — não copie o card.]

**Critérios de aceite considerados**
- [critério]
- [critério]

## 2. Impacto no código

| Área | O que muda | Observação |
| --- | --- | --- |
| [ex.: `app/models/pedido.rb`] | [ex.: nova associação com parcelas] | [ex.: sem testes hoje] |
| [ex.: `app/views/checkout/`] | [ex.: novo passo de parcelamento] | [ex.: reaproveita o componente de resumo] |

## 3. Partes e horas

Horas **informadas pelo usuário**.

| # | Parte | Horas | Observação |
| --- | --- | --- | --- |
| 1 | [ex.: alinhamento das regras de juros] | [ex.: 1] | |
| 2 | [ex.: migration + model de parcelas] | [ex.: 1] | |
| 3 | [ex.: serviço de cálculo] | [ex.: 5] | usuário considera as 12 combinações trabalhosas |
| 4 | [ex.: integração com o gateway] | [ex.: 8] | |
| 5 | [ex.: tela de parcelas] | [ex.: 3] | |
| 6 | [ex.: testes de sistema] | [ex.: 2] | |
| — | Code review, QA e deploy | [ex.: 6] | |
| | **Total** | **[ex.: 26]** | |

*Se o usuário informou só o total, as linhas trazem "não informado" e o total fica na linha final.*

## 4. Premissas

> ⚠️ **Premissa:** [ex.: parcelamento não se aplica a assinaturas]
> ⚠️ **Premissa:** [ex.: sandbox do gateway disponível desde o primeiro dia]

## 5. Riscos

| Risco | Efeito se acontecer | Resposta |
| --- | --- | --- |
| [ex.: regra de juros acima de 6x muda] | [ex.: +4h no cálculo e nos testes] | [ex.: confirmar com o PO antes de começar] |

## 6. Lacunas do card

- [ ] [ex.: valor mínimo da parcela não definido] — perguntar a: [PO]

## 7. Próximos passos

- [ex.: confirmar as lacunas com o PO]
- [ex.: transformar em PRD com `sdd-prd` / planejar com `sdd-plan`]
- [ex.: spike técnico de 4h na integração, se a confiança precisar subir]

## Comentário para o card

```
Estimativa: [26h (~4,5 dias)] — confiança [média]
Inclui: [lista curta das partes]
Premissas: [principais]
Riscos: [principal, com o efeito em horas]
```
````
