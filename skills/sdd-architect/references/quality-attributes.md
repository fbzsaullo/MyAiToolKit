# Qualidades que dirigem a arquitetura

Apoio para o Bloco 2 da entrevista do `sdd-architect` e para a seção 3 da proposta. Para cada qualidade: como perguntar sem jargão, quais sinais indicam que ela pesa de verdade, que soluções costumam atendê-la e qual preço elas cobram.

**Lembrete:** uma qualidade entra como prioridade quando existe um problema concreto por trás dela. Listar todas "para parecer completo" dilui a proposta. Escolha as 2 a 4 que de fato vão decidir alguma coisa.

---

## Desempenho

**Como perguntar**
- Alguma operação tem um tempo máximo aceitável? Qual?
- Existe um volume mínimo a sustentar (requisições, mensagens, transações por segundo)?
- Há picos conhecidos — campanhas, fechamento de mês, cargas em lote?
- Existe SLA de tempo de resposta por escrito?

**Quando pesa**
- "Se passar de X segundos o usuário desiste"
- Contrato B2B que fixa tempo de resposta
- Eventos com pico já previsto no calendário
- Reclamações recorrentes de lentidão em produção

**Respostas comuns**
- Cache de leitura (Redis, Solid Cache, cache em memória)
- Réplicas de leitura do banco
- Modelos de leitura dedicados (CQRS), views materializadas
- CDN para arquivos e respostas cacheáveis
- Tirar trabalho longo da requisição (jobs em background)
- Índices, particionamento e revisão de consultas (N+1 incluído)

**O que se paga**
- Consistência: cache e réplicas trazem dado levemente desatualizado
- Custo: cache distribuído é mais uma peça de infraestrutura
- Simplicidade: modelos de leitura separados duplicam o caminho de escrita

---

## Escalabilidade

**Como perguntar**
- A carga vai crescer devagar, rápido, ou fica parada?
- O crescimento é em usuários, em volume de dados ou nos dois?
- A projeção vem de dado concreto ou de expectativa?
- A carga se espalha ou se concentra em poucos clientes/recursos?

**Quando pesa**
- Plano de aquisição de usuários agressivo e financiado
- Produto sujeito a picos virais
- Multi-tenant em que um cliente pode crescer muito mais que os outros
- O volume atual já gera lentidão ou custo subindo

**Respostas comuns**
- Aplicação sem estado atrás de balanceador
- Filas para separar quem produz de quem consome
- Particionamento de dados por cliente ou região; sharding
- Escala automática (containers gerenciados, funções)
- Separar em serviços apenas as partes que crescem de forma desigual

**O que se paga**
- Operação: escalar horizontalmente exige orquestração e monitoramento
- Desenvolvimento: código sem estado e idempotente dá mais trabalho
- Consistência: dados particionados e caches distribuídos

**Armadilha:** "vamos de microsserviços para escalar" sem volume real. É pagar hoje uma conta que talvez nunca chegue.

---

## Disponibilidade

**Como perguntar**
- O que custa uma hora fora do ar — em dinheiro, reputação ou multa?
- Há SLA? Com quantos noves?
- Existe horário em que parar é aceitável?
- O uso é 24×7 ou concentrado em algum período?

**Quando pesa**
- SLA com multa por indisponibilidade
- Setor regulado (financeiro, saúde)
- Venda online em horário de pico
- Sistema interno sem o qual as pessoas param de trabalhar

**Respostas comuns**
- Múltiplas zonas ou regiões
- Health checks com reinício automático
- Circuit breaker e degradação elegante
- Banco replicado com failover automático
- Deploy blue-green ou canário
- Backup e plano de recuperação **testados** de tempos em tempos

**O que se paga**
- Custo: cada nove a mais custa bem mais que o anterior
- Consistência: failover pode perder as últimas escritas
- Operação: ambiente redundante exige time maduro

---

## Resiliência

**Como perguntar**
- Dá para continuar funcionando com uma parte fora do ar?
- Quais dependências externas são críticas?
- O que acontece hoje quando uma integração falha — perde-se pedido, acumula fila?
- Já houve queda em cadeia?

**Quando pesa**
- Muitas integrações com terceiros
- Histórico de falhas em cascata
- Serviços que dependem uns dos outros
- Exigência de seguir operando mesmo sem algumas funções

**Respostas comuns**
- Timeout explícito em toda chamada remota
- Retentativa com backoff exponencial (e limite)
- Circuit breaker
- Isolamento de recursos por dependência (bulkhead)
- Outbox para publicar eventos de forma confiável
- Saga para fluxos que atravessam vários serviços
- Escritas idempotentes

**O que se paga**
- Simplicidade: mais estados e caminhos para testar
- Desempenho: retentativas e timeouts somam latência
- Consistência: o sistema passa a conviver com consistência eventual

---

## Segurança

**Como perguntar**
- Há dados sensíveis (financeiros, saúde, pessoais, segredos comerciais)?
- Que normas se aplicam (LGPD, PCI DSS, SOC 2, normas do setor)?
- É preciso registrar quem viu ou alterou o quê, e quando?
- Quem é o atacante provável — externo, interno, cadeia de dependências?

**Quando pesa**
- Fintech, saúde, governo
- Cliente exigindo certificação
- Incidente de segurança anterior
- Dado sensível trafegando entre redes ou empresas

**Respostas comuns**
- Autenticação forte (OIDC, MFA)
- Autorização por políticas centralizadas (ex.: Pundit, Action Policy), não ifs espalhados
- Criptografia em trânsito e em repouso (incluindo criptografia de atributos)
- Cofre de segredos / credenciais criptografadas, nunca segredo no repositório
- Log de auditoria estruturado e imutável
- Menor privilégio em acessos e chaves
- Validação de entrada em todas as bordas, rate limiting
- Análise estática de segurança no CI (ex.: Brakeman em Rails)

**O que se paga**
- Disponibilidade: limites agressivos podem barrar usuário legítimo
- Experiência: MFA e reautenticação adicionam atrito
- Desempenho: criptografia consome processamento
- Custo: conformidade é custo recorrente

---

## Manutenibilidade

**Como perguntar**
- Com que frequência o sistema vai mudar?
- O time vai crescer? Muitas pessoas vão contribuir?
- Há rotatividade?
- Código antigo vai conviver com o novo?

**Quando pesa**
- Produto com entregas frequentes
- Time em crescimento rápido ou com muitos juniores
- Sistema que precisa durar anos
- Integração gradual com legado

**Respostas comuns**
- Fronteiras claras entre módulos (monolito modular, engines, packwerk)
- Testes automatizados em camadas (unidade, integração, sistema)
- Especificação executável (Gherkin, ADRs, este pipeline)
- Lint e formatação automáticos no CI
- Modelagem de domínio quando a regra de negócio é rica

**O que se paga**
- Velocidade inicial: estrutura cobra investimento antes de dar retorno
- Desempenho: camadas extras adicionam indireção
- Simplicidade: arquitetura elaborada demais para um CRUD vira peso morto

---

## Observabilidade

**Como perguntar**
- Quem cuida da produção? Há plantão?
- O que precisa ser acompanhado — tempo, erros, indicadores de negócio?
- Como um bug é investigado hoje?
- Há exigência de rastrear ações?

**Quando pesa**
- Sistema distribuído (serviços, filas, eventos)
- Operação contínua com plantão
- Norma que exige rastreabilidade
- Bugs que ninguém consegue reproduzir

**Respostas comuns**
- Logs estruturados (JSON) com identificador de requisição
- Rastreamento distribuído (OpenTelemetry)
- Métricas técnicas e de negócio
- Painéis organizados por fluxo de negócio, não só por serviço
- Alertas ligados a SLO, não a métricas soltas
- Rastreamento de erros (ex.: Sentry, Honeybadger)

**O que se paga**
- Custo: ferramentas cobram por volume
- Desempenho: instrumentação tem overhead
- Privacidade: logs capturam dado pessoal sem querer — filtrar parâmetros sensíveis

---

## Outras qualidades (só quando o briefing pedir)

- **Portabilidade** — rodar em mais de uma nuvem ou on-premise
- **Internacionalização** — idiomas, fusos, moedas
- **Acessibilidade** — WCAG, leitores de tela, navegação por teclado
- **Custo operacional** — gasto mensal mínimo como objetivo
- **Velocidade de lançamento** — chegar ao mercado acima de tudo
- **Testabilidade** — testar partes isoladamente
- **Reuso** — componentes que atendem várias aplicações

Cada uma traz seus próprios padrões e custos; entre na proposta apenas quando houver motivo explícito.

---

## Teste final

Toda decisão da proposta precisa estar ligada a **ao menos uma qualidade prioritária ou uma restrição**. Decisão que não se liga a nada é decisão gratuita — e decisão gratuita costuma ser excesso de engenharia.
