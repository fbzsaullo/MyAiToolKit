# Método de estimativa do spike

Como chegar a uma **sugestão** de horas defensável. A sugestão é insumo para a decisão do usuário — por isso cada número precisa vir com a premissa que o sustenta, para que ele possa discordar de partes específicas em vez de aceitar ou rejeitar tudo.

## 1. Quebrar em partes

Uma parte boa tem tamanho parecido com uma tarefa do plano (30min a 4h). Partes maiores escondem incerteza; divida até que cada uma seja explicável em uma linha.

Toda quebra cobre estas categorias (as que se aplicarem):

| Categoria | Exemplos |
| --- | --- |
| Análise e alinhamento | esclarecer lacunas do card, ler código desconhecido, prova de conceito |
| Dados | migrations, models, backfill |
| Regras | serviços, validações, cálculos, estados |
| Exposição | rotas, controllers, API, autorização |
| Interface | telas, componentes, estados de erro |
| Integrações | APIs de terceiros, webhooks, filas |
| Testes | unidade, integração, sistema, concorrência |
| Operação | logs, métricas, feature flag |
| Overheads | code review, QA/homologação, deploy |

Os overheads vêm de `docs/sdd/config.yml` (`spike.overheads_pct`, padrão: review 10%, QA 15%, deploy 5% com mínimo de 0,5h). Se `spike.include_overheads` for `false`, liste-os à parte, sem somar.

## 2. Três pontos por parte

Para cada parte:

- **O (otimista):** tudo como esperado, sem surpresa.
- **M (provável):** o cenário mais comum, com os tropeços habituais.
- **P (pessimista):** os riscos conhecidos acontecem (não o fim do mundo).

**Esperado (PERT)** = (O + 4×M + P) / 6.

Fontes para os números, em ordem de preferência:
1. **O próprio código** — o que existe, o que falta, a qualidade da área. Uma tela parecida já pronta reduz muito o M.
2. **Histórico do projeto** — spikes anteriores em `docs/sdd/spikes/` com as horas que o usuário informou; tarefas concluídas no plano com `Estimativa`.
3. **Heurísticas da stack** — `stacks/<stack>/spike-heuristics.md`.
4. **Faixas genéricas** (abaixo), quando nada mais existir.

### Faixas genéricas (qualquer stack, em horas — O / M / P)

| Trabalho | O | M | P |
| --- | --- | --- | --- |
| Mudança pequena e isolada com teste | 0,5 | 1 | 2 |
| Estrutura de dados nova (tabela/entidade) | 0,5 | 1,5 | 3 |
| Regra de negócio nova com testes | 2 | 4 | 6 |
| Endpoint/rota nova com autorização e teste | 1 | 2 | 4 |
| Tela simples com estados | 2 | 3 | 5 |
| Integração com serviço externo | 4 | 8 | 16 |
| Bug sem reprodução clara | 2 | 6 | 16 |

## 3. Multiplicadores de contexto

Aplicados sobre M e P quando o sinal aparece. Sempre **nomeados** na tabela da sugestão:

| Sinal | Multiplicador |
| --- | --- |
| Área sem testes automatizados | ×1,3 a ×1,5 |
| Código legado/complexo na área | ×1,3 |
| Critérios de aceite vagos | ×1,2 + parte de alinhamento |
| Dependência de terceiro sem ambiente de teste | ×1,3 no P |
| Pessoa sem contexto do projeto (informado pelo usuário) | ×1,5 |
| Dados grandes de produção envolvidos | ×1,2 a ×1,5 |
| Versão de framework muito desatualizada na área | ×1,2 |

Não acumule multiplicadores sobre o mesmo motivo (legado e sem testes costumam andar juntos — escolha o maior e explique).

## 4. Total, faixa e dias

- **Total sugerido** = soma dos esperados + overheads.
- **Faixa** = soma dos O … soma dos P (com overheads proporcionais).
- **Dias** = total ÷ `spike.hours_per_day` (padrão 6). Arredonde para meio dia.

## 5. Confiança

| Nível | Quando |
| --- | --- |
| **Alta** | card claro, critérios de aceite completos, área do código conhecida e testada |
| **Média** | lacunas pequenas viraram premissas; alguma parte desconhecida |
| **Baixa** | lacunas grandes, área desconhecida, terceiro sem documentação, ou estimativa sem acesso ao código |

Confiança baixa → recomende um **spike técnico com timebox** (ex.: "4h para integrar com o sandbox do gateway") e reestimar depois. Também é válido sugerir **dividir o card** quando o total passar de ~5 dias: cards grandes demais costumam esconder escopo.

## 6. A decisão é do usuário

Depois de mostrar a sugestão, o usuário informa os valores dele. O arquivo grava **somente** esses valores (ou nenhum, se ele não informar). Se ele discordar muito da sugestão, pergunte o motivo e registre-o como premissa — essa informação melhora os próximos spikes.

## Erros comuns

- Estimar só a implementação e esquecer testes, review, QA e deploy.
- Um único número sem faixa: passa uma precisão que não existe.
- Esconder premissas: o usuário não consegue discordar do que não vê.
- Tratar a sugestão como compromisso — ela é ponto de partida para a decisão do usuário.
