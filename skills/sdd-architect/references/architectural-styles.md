# Estilos arquiteturais — guia de escolha

Usado na Fase 2 do `sdd-architect` para fundamentar o estilo escolhido. Para cada estilo: em que cenário ele brilha, quando é má ideia, o que entrega, o que cobra e que tipo de domínio já "nasce" com o formato dele.

**Ponto de partida:** não existe estilo correto em abstrato. O certo é o que combina domínio, qualidades prioritárias, restrições e o que o time consegue operar. Tendência de mercado não entra na conta.

---

## Monolito em camadas

O padrão sensato para a maior parte dos sistemas — e frequentemente descartado sem motivo por quem quer parecer moderno. Uma aplicação Rails convencional é um exemplo direto.

| | |
| --- | --- |
| **Brilha quando** | Time de até ~10 pessoas; domínio conhecido; volume previsível que cabe em escala vertical; um deploy para tudo é aceitável; prioridade é entregar rápido |
| **Evite quando** | Vários times grandes precisam evoluir em paralelo; áreas com ritmos de release muito diferentes; volume já comprovado que exige escalar partes isoladas |
| **Entrega** | Fácil de entender, desenvolver e depurar; transação do banco resolve a maioria das questões de consistência; deploy e rollback simples; refatorar é mover código dentro do mesmo projeto |
| **Cobra** | Sem disciplina, o acoplamento cresce; escala vertical tem teto; camadas que vazam fazem uma mudança quebrar outra área |
| **Domínios que encaixam** | CRUD com regras moderadas, sistemas administrativos, ERPs verticais, e-commerce de porte médio |

---

## Monolito modular

O monolito com fronteiras explícitas: cada módulo expõe uma interface interna e esconde o resto. Em Rails: engines, `packwerk`, ou namespaces com regras de dependência verificadas no CI.

| | |
| --- | --- |
| **Brilha quando** | Condições do monolito, mas com crescimento previsto; vários contextos de negócio relativamente independentes; o time quer se preparar para separar no futuro sem pagar o custo operacional agora |
| **Entrega** | Disciplina de domínio forçada pelas fronteiras; extrair um serviço depois não exige reescrever tudo; deploy continua simples; casa bem com bounded contexts |
| **Cobra** | Exige mais rigor que o monolito comum; sem ferramenta que verifique as fronteiras, elas se dissolvem e o resultado é um monolito comum com outro nome |
| **Domínios que encaixam** | E-commerce com catálogo, pedidos, pagamentos e entrega; SaaS com funcionalidades grandes e independentes; sistemas internos com áreas de ritmos diferentes |

---

## Microsserviços

Resolve problemas reais de organização e escala, mas é escolhido demais por times pequenos atrás de modernidade.

| | |
| --- | --- |
| **Brilha quando** | Vários times autônomos (Lei de Conway); áreas com cadência de release muito diferente; necessidade comprovada de escalar partes isoladas; stacks diferentes com motivo real; maturidade para operar muitos deploys, rastreamento distribuído e transações distribuídas |
| **Evite quando** | Time com menos de ~15 pessoas; domínio ainda pouco entendido (as fronteiras sairão erradas); pouca maturidade de operação; "queremos escalar" sem volume |
| **Entrega** | Times evoluem em paralelo; escala só o que precisa; falha fica contida (com circuit breaker); liberdade de stack por serviço |
| **Cobra** | Operação muito mais complexa; transações viram sagas; consistência eventual em toda parte; latência entre serviços se acumula; mover responsabilidade entre serviços é caro |
| **Custos que não aparecem no slide** | Gateway, rastreamento distribuído, registro de contratos, service mesh, plataforma interna para os devs |
| **Domínios que encaixam** | Organizações grandes com vários times de produto; subdomínios com requisitos não funcionais muito diferentes; clientes com SLAs muito distintos |

---

## Pipes & Filters

Uma cadeia de etapas: cada uma recebe o resultado da anterior, transforma e passa adiante.

| | |
| --- | --- |
| **Brilha quando** | Processamento em sequência (ETL, mídia, linguagem natural); etapas independentes que podem ser desenvolvidas e testadas separadamente; etapas paralelizáveis; filtros reaproveitáveis entre cadeias |
| **Entrega** | Composição flexível; teste por etapa; paralelismo natural; cada etapa pode usar tecnologia diferente |
| **Cobra** | Overhead quando cada etapa é um processo; erros que atravessam etapas são difíceis de tratar; reconstituir o que aconteceu exige observabilidade extra |
| **Domínios que encaixam** | ETL e engenharia de dados; processamento linear de pedidos (validar → reservar → cobrar → expedir); CI/CD; conversão de vídeo, áudio e imagem |

---

## Orientado a eventos

Quem produz publica um fato; quem se interessa reage, no seu tempo.

| | |
| --- | --- |
| **Brilha quando** | O sistema reage a acontecimentos do mundo (sensores, mudanças de estado de negócio); vários interessados no mesmo fato; produtor e consumidor precisam ser independentes; registrar o que aconteceu é exigido |
| **Entrega** | Baixo acoplamento no tempo e na estrutura; novos consumidores sem mexer no produtor; resiliência via fila; histórico como efeito colateral |
| **Cobra** | Fluxo ponta a ponta difícil de seguir sem rastreamento; consistência eventual; depuração em produção mais trabalhosa; evolução do formato dos eventos é dor permanente |
| **Domínios que encaixam** | IoT; pedido confirmado que dispara e-mail, nota fiscal, antifraude e logística; integração entre muitos sistemas internos |

---

## CQRS

Modelos separados para escrever e para ler. Combina com eventos e com event sourcing, mas não depende deles.

| | |
| --- | --- |
| **Brilha quando** | Leitura muito maior que escrita; leituras pedem formatos otimizados (busca, agregações, desnormalização); escrita com regra rica e leitura simples; consumidores diferentes querem formatos diferentes |
| **Evite quando** | CRUD simples; leitura e escrita equilibradas; time sem experiência com consistência eventual |
| **Entrega** | Cada leitura com o formato ideal; escala de leitura independente; escrita com domínio rico, leitura com estruturas simples; encaixa com cache, índice de busca e réplicas |
| **Cobra** | Dois modelos para manter; atraso entre escrever e ler; mais difícil descobrir qual modelo de leitura está defasado; a sincronização precisa ser confiável |
| **Domínios que encaixam** | Catálogo muito buscado (índice de busca como modelo de leitura); painéis analíticos sobre dados transacionais; buscas complexas |

---

## Event Sourcing

A verdade é a lista de eventos; o estado atual é calculado a partir dela.

| | |
| --- | --- |
| **Brilha quando** | Auditoria completa é obrigatória (financeiro, saúde, jurídico); consultar o estado em qualquer momento do passado tem valor; a própria história é parte do produto; várias leituras diferentes da mesma realidade |
| **Evite quando** | CRUD comum; time sem experiência no padrão; histórico sem valor real |
| **Entrega** | Auditoria perfeita; reconstrução do estado em qualquer ponto; novos modelos de leitura reprocessando eventos |
| **Cobra** | Complexidade alta; versionar eventos antigos é problema eterno; armazenamento cresce; consultar o estado atual sem projeção é caro |
| **Domínios que encaixam** | Lançamentos financeiros; fluxos de aprovação; trilhas de auditoria regulatória |

---

## Microkernel (plugins)

Um núcleo pequeno e estável, com extensões que mudam o comportamento.

| | |
| --- | --- |
| **Brilha quando** | Muita personalização por cliente; white-label com diferenças de função; ferramenta que terceiros estendem; ligar e desligar funções por tenant |
| **Entrega** | Núcleo estável e extensões evoluindo à parte; personalização sem fork; possibilidade de ecossistema de terceiros |
| **Cobra** | O contrato do plugin é difícil de mudar; depurar interação entre plugins é complicado; muitos plugins ativos podem pesar |
| **Domínios que encaixam** | ERPs com personalização por cliente; IDEs; CMSs; SaaS B2B com clientes muito diferentes |

---

## Serverless (funções sob demanda)

Código executado quando chamado, com escala gerida pelo provedor.

| | |
| --- | --- |
| **Brilha quando** | Carga irregular e imprevisível; média baixa com picos raros; cola entre serviços; eventos esparsos (webhooks, uploads); custo zero em ociosidade importa |
| **Evite quando** | Carga constante e previsível (sai mais caro que servidor); latência crítica (partida a frio); execuções longas; necessidade de controlar o runtime |
| **Entrega** | Sem servidor para cuidar; escala automática; paga pelo uso; ótimo em fluxos por evento |
| **Cobra** | Partida a frio; dependência do provedor; depuração local difícil; limite de tempo de execução; custo pode disparar com desenho ruim |
| **Domínios que encaixam** | Webhooks; processamento de upload; rotinas agendadas; integrações leves; back-ends de baixo volume |

---

## API Gateway + adaptadores

Uma porta de entrada padronizada e um adaptador por integração externa.

| | |
| --- | --- |
| **Brilha quando** | Muitos parceiros heterogêneos; versionamento de API precisa ser consistente; consumidores querem formatos ou versões diferentes; integrações B2B |
| **Entrega** | Padrão HTTP conhecido por todos; gateway concentra autenticação, limites, log e versão; adaptadores isolam o núcleo das mudanças dos parceiros |
| **Cobra** | Mais um salto de rede; gateway vira gargalo se não escalar; bastante configuração |
| **Domínios que encaixam** | Back-ends multicanal (web, app, parceiros); APIs públicas B2B; Backend-for-Frontend |

---

## Desempate

Quando dois estilos parecem servir igualmente, fique com o que:

1. é **mais simples** e ainda atende às qualidades prioritárias;
2. o time **já consegue operar** sem contratação ou treinamento pesado;
3. **prende menos** a um fornecedor, dadas as restrições;
4. deixa o caminho **aberto para evoluir** se a hipótese se mostrar errada.

Tecnologia "sem graça" costuma ser a melhor decisão: um monolito Rails, PostgreSQL e uma fila simples resolvem a grande maioria dos problemas que arquiteturas distribuídas prometem resolver, com uma fração do custo de operação.
