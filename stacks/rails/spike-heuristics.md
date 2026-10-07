# Heurísticas de esforço — Ruby on Rails

Faixas de referência para a **sugestão** de horas do `/spike` e do campo `Estimativa` do `sdd-plan`. São pontos de partida para a conversa, não verdade: a decisão final é sempre do usuário, e só o número dele é gravado.

As faixas consideram uma pessoa que já conhece o projeto, com testes incluídos, em uma aplicação Rails saudável. Use os multiplicadores do fim do arquivo para ajustar ao contexto real.

Formato: **otimista / provável / pessimista**, em horas.

## Banco e modelos

| Trabalho | O | M | P | Observações |
| --- | --- | --- | --- | --- |
| Migration simples (tabela nova ou coluna) + model com validações | 0,5 | 1 | 2 | inclui teste de model |
| Associação nova entre models existentes | 0,5 | 1,5 | 3 | cuidado com N+1 nas telas que a usam |
| Índice/restrição em tabela grande (concorrente, em etapas) | 1 | 3 | 6 | inclui verificar volume e janela |
| Backfill de dados (rake/job) | 2 | 4 | 10 | dobra se precisar rodar em produção com monitoramento |
| Renomear/remover coluna em uso (expandir → migrar → contrair) | 4 | 8 | 16 | várias tarefas; envolve deploys intermediários |

## Regras de negócio

| Trabalho | O | M | P | Observações |
| --- | --- | --- | --- | --- |
| Validação ou regra simples num model/serviço existente | 0,5 | 1 | 2 | — |
| Objeto de serviço novo com 2–4 regras e testes | 2 | 4 | 6 | — |
| Regra com concorrência (bloqueio, unicidade disputada) | 3 | 5 | 10 | teste de concorrência é a parte cara |
| Máquina de estados (5+ transições) | 3 | 6 | 12 | — |
| Cálculo com muitas combinações (preço, imposto, frete) | 2 | 5 | 10 | tabela de exemplos ajuda |

## Exposição (controllers e API)

| Trabalho | O | M | P | Observações |
| --- | --- | --- | --- | --- |
| Action REST nova com autorização + spec de requisição | 1 | 2 | 3 | — |
| CRUD completo (scaffold ajustado, com policy) | 3 | 5 | 8 | — |
| Endpoint de API JSON com serialização e versionamento | 2 | 3 | 6 | — |
| Webhook de terceiro com verificação de assinatura e idempotência | 3 | 5 | 10 | depende da documentação do terceiro |

## Interface (Hotwire)

| Trabalho | O | M | P | Observações |
| --- | --- | --- | --- | --- |
| Tela simples (lista ou formulário) com estados padrão | 2 | 3 | 5 | default, vazio, erro, validação |
| Formulário com Turbo (422, preservação de dados, mensagens) | 2 | 4 | 6 | — |
| Atualização em tempo real com Turbo Streams/broadcast | 2 | 4 | 8 | — |
| Stimulus controller novo com comportamento não trivial | 1 | 3 | 6 | — |
| Componente reutilizável (ViewComponent/partial) com estados | 1 | 2 | 4 | — |
| Teste de sistema de um fluxo crítico | 1 | 2 | 4 | instabilidade de navegador aumenta o P |

## Jobs e integrações

| Trabalho | O | M | P | Observações |
| --- | --- | --- | --- | --- |
| Job simples idempotente | 1 | 2 | 3 | — |
| Integração com API externa (cliente, erros, timeout, retentativa) | 4 | 8 | 16 | sem sandbox do terceiro, use o P |
| E-mail transacional (mailer + template + preview + teste) | 1 | 2 | 3 | — |
| Agendamento recorrente (Solid Queue recurring / cron) | 1 | 2 | 4 | — |

## Transversal

| Trabalho | O | M | P | Observações |
| --- | --- | --- | --- | --- |
| Feature flag em torno de uma funcionalidade | 1 | 2 | 3 | — |
| Logs estruturados e métricas de um fluxo | 1 | 2 | 4 | — |
| Ajustes de autorização em várias telas | 2 | 4 | 8 | — |
| Investigação de bug sem reprodução clara | 2 | 6 | 16 | sugerir spike com *timebox* |

## Atividades que costumam ser esquecidas

O `/spike` soma estas parcelas quando `spike.include_overheads` está ligado no `config.yml` (percentuais configuráveis):

- **Code review e ajustes** — padrão 10% do desenvolvimento
- **QA / homologação** — padrão 15%
- **Deploy e acompanhamento** — padrão 5% (mínimo de 0,5h)
- **Análise e alinhamento** quando o card tem lacunas — 0,5h a 2h, listado à parte

## Multiplicadores de contexto

Aplique ao valor provável (e ao pessimista) quando o sinal aparecer no projeto ou no card:

| Sinal | Multiplicador |
| --- | --- |
| Área sem testes (precisa de teste de caracterização antes) | ×1,3 a ×1,5 |
| Código legado com callbacks encadeados / "model gordo" na área | ×1,3 |
| `load_defaults` muito atrasado ou Rails fora de suporte na área tocada | ×1,2 |
| Card com critérios de aceite vagos | ×1,2 + parcela de análise |
| Dependência de outro time ou de terceiro sem ambiente de teste | ×1,3 no P |
| Pessoa sem contexto do projeto | ×1,5 |
| Dados de produção grandes envolvidos | ×1,2 a ×1,5 |

Explique **qual** multiplicador foi aplicado e por quê — o usuário precisa poder discordar de cada um.

## Cálculo sugerido

- Por tarefa: esperado = (O + 4×M + P) / 6 (PERT); mostre também O e P.
- Total: soma dos esperados + parcelas de overhead; faixa = soma dos O … soma dos P.
- Conversão em dias: total ÷ `spike.hours_per_day` do `config.yml` (padrão 6).
- Confiança: **alta** (card claro, área conhecida), **média** (lacunas pequenas), **baixa** (lacunas grandes, área desconhecida, terceiro envolvido). Confiança baixa → recomendar um spike técnico com timebox antes de comprometer o número.
