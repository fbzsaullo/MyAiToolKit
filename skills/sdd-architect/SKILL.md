---
name: sdd-architect
description: Desenha ou revisa a arquitetura de um sistema e entrega uma proposta arquitetural com decisões justificadas (um arquivo de ADR por decisão), atributos de qualidade, restrições, trade-offs e diagramas C4 em Mermaid. Use quando o usuário pedir para "desenhar a arquitetura", "propor uma solução técnica", "escolher a stack", "como estruturar esse sistema", "revisar esta arquitetura", "qual arquitetura usar para…", ou quando descrever um sistema novo e quiser saber como construí-lo. Fase 1 do pipeline SDD do MyAiToolKit. Não fixa tecnologia, a menos que ela seja uma restrição declarada. Não produz estimativa de custo, prazo ou esforço, nem código.
argument-hint: "[descrição curta do sistema ou caminho de um briefing — opcional]"
allowed-tools: Read, Glob, Grep, Edit(docs/sdd/architecture/**)
---

# sdd-architect — proposta arquitetural

Entrada: $ARGUMENTS (se o seu ambiente não substituir essa variável, use a mensagem do usuário).

O objetivo desta skill é sair de uma demanda — sistema novo, evolução, integração, modernização — com uma **arquitetura decidida**: cada escolha feita, explicada e registrada de forma que outra pessoa (ou outro agente) consiga entender por que ela existe.

## O que orienta a skill

- **Decidir é escolher o que sacrificar.** Toda opção arquitetural melhora uma qualidade às custas de outra: mais isolamento custa mais operação, mais consistência custa disponibilidade, mais flexibilidade custa simplicidade. A proposta deixa esse preço visível.
- **A arquitetura serve ao negócio.** O critério de sucesso é atender ao que o negócio espera, dentro das restrições, garantindo as qualidades que importam — com o menor custo e risco que o contexto permite.
- **Decisão boa tem três partes:** foi tomada, tem motivo escrito e chegou a quem precisa saber. Faltando qualquer uma, ela não serve como guia.
- **Tecnologia é consequência, não ponto de partida.** A skill sugere a stack que melhor atende ao contexto. Se o cliente ou o time já impôs uma ("tem que ser Rails", "só AWS"), ela entra como **restrição** — e o documento diz isso com essas palavras.
- **Moda não é argumento.** Microsserviços, event sourcing, serverless ou hexagonal só aparecem quando o problema pede. "Todo mundo usa" nunca é justificativa.

## Visão geral do fluxo

1. **Entender** — conversa guiada para levantar objetivos, qualidades prioritárias, restrições e o cenário atual.
2. **Decidir** — classificar o problema, explicitar trade-offs e escolher estilo e tecnologias.
3. **Registrar** — gerar a proposta e um arquivo por decisão (ADR).

Leia as três fases antes de escrever qualquer coisa.

---

## Fase 1 — Entender

Pergunte em blocos, nunca tudo de uma vez. Comece pelo negócio e só depois desça para o técnico. Se o usuário já trouxe um briefing completo, vá direto aos blocos que ainda têm buracos.

A lógica da conversa é **eliminar possibilidades**: cada resposta deve tirar alternativas da mesa. Quanto menos coisa em aberto, mais firme a decisão.

### Bloco 1 — Por que o sistema existe

- Que problema ele resolve, para quem, e como esse problema é contornado hoje?
- Que resultado o negócio espera? (receita, economia, entrar num mercado, cumprir norma, lançar mais rápido)
- Quantos usuários, em ordem de grandeza? (dezenas, milhares, milhões)
- É produto, ferramenta interna, integração, white-label? Substitui algo existente?
- Qual o horizonte de vida? (prova de conceito, MVP em poucos meses, plataforma de longo prazo)

### Bloco 2 — Qualidades que vão pesar

Uma qualidade só é prioridade quando existe um problema real ligado a ela. Pergunte pelos sintomas, não pelo nome técnico:

- **Desempenho** — há uma meta de tempo de resposta ou de volume? Existem picos previsíveis (campanha, fechamento de mês)?
- **Escalabilidade** — a carga cresce devagar, rápido ou fica estável? Cresce em usuários, em dados ou nos dois?
- **Disponibilidade** — quanto custa uma hora fora do ar? Existe SLA? Dá para ter janela de manutenção?
- **Resiliência** — o sistema pode funcionar pela metade quando algo falha? Depende de serviços externos críticos?
- **Segurança** — trata dado sensível (financeiro, saúde, pessoal)? Há exigência regulatória (LGPD, PCI, BACEN)?
- **Manutenibilidade** — o time é estável? Quantas pessoas vão mexer? Com que frequência o sistema muda?
- **Observabilidade** — quem opera em produção? Que visibilidade essa pessoa precisa?

Fique com as **duas a quatro** que realmente vão decidir a arquitetura. As outras são registradas como "atendidas pelo padrão da plataforma".

### Bloco 3 — O que não se negocia

Restrição é dado de entrada, não variável a otimizar:

- **Tecnologia** — linguagem, framework, banco ou nuvem impostos? Por qual motivo?
- **Regulação** — LGPD, normas setoriais, dados obrigatoriamente no Brasil?
- **Dinheiro** — orçamento conhecido, teto de custo mensal, proibição de licenças pagas?
- **Pessoas** — tamanho e senioridade do time, o que ele já domina, distribuição geográfica
- **Prazo** — data de mercado, contratual ou legal?
- **Integrações** — sistemas legados com que é obrigatório conversar?
- **Infraestrutura** — nuvem específica, on-premise, híbrido?

### Bloco 4 — Ponto de partida técnico

- Já existe código? É legado a substituir, base a evoluir ou começo do zero?
- Que sistemas trocam dados com a solução, em que volume e de que tipo?
- Onde os dados vivem hoje e onde estão os gargalos?
- Que incidentes ou dores se repetem e precisam desaparecer com a nova arquitetura?

### Bloco 5 — O que está fora

Pergunte de forma explícita o que **não** é objetivo:

- Que capacidades o sistema não precisa ter? ("não será multi-tenant", "não funciona offline")
- Que cargas ele não precisa aguentar?
- Que tipo de extensão não vale preparar agora?

Sem isso, a arquitetura acaba resolvendo problemas que ninguém pediu.

### Hora de parar

Pare de perguntar quando conseguir justificar **cada** decisão sem supor nada. Se uma dúvida muda a resposta (100 ou 100 mil usuários?), pergunte. Se não muda, siga. Nunca deixe `[A DEFINIR]` no documento — lacuna volta como pergunta.

---

## Fase 2 — Decidir

Antes de escrever, organize o raciocínio (sem expor esse rascunho ao usuário):

### 2.1 Que tipo de problema é este?

Use a classificação de Cynefin para calibrar o tom:

- **Claro** — causa e efeito óbvios; a boa prática resolve. Raro em arquitetura.
- **Complicado** — causa e efeito conhecidos, várias soluções boas; o trabalho é escolher. Aqui a proposta pode ser firme.
- **Complexo** — só se entende agindo; muitas variáveis. É onde cai a maioria dos casos. A proposta deve prever MVP, métricas e pontos de revisão, sem falsa certeza.
- **Caótico** — não há relação causal visível (ex.: sistema distribuído em colapso). A primeira recomendação é estabilizar; evoluir vem depois.

### 2.2 Quais trade-offs estão em jogo?

Liste as tensões centrais e, para cada uma, o lado que o negócio prefere segundo a entrevista. Exemplos frequentes:

- reaproveitamento × acoplamento
- consistência × disponibilidade
- desempenho × resiliência
- velocidade de entrega × facilidade de manutenção
- segurança × disponibilidade
- operação simples × escala horizontal
- custo de infraestrutura × custo de desenvolvimento

Essas preferências são o principal insumo para escolher o estilo.

### 2.3 O domínio já sugere uma forma?

Alguns domínios combinam naturalmente com certos estilos:

| Formato do domínio | Estilo que costuma encaixar |
| --- | --- |
| Etapas sequenciais de transformação de dados | Pipes & Filters |
| Muita variação por cliente ou contexto | Microkernel / plugins |
| Áreas independentes, times separados, ritmos diferentes | Microsserviços |
| CRUD com regras moderadas, time pequeno, deploy único | Monolito (em camadas ou modular) — continua sendo a resposta certa com frequência |
| Reação a acontecimentos do mundo real | Orientado a eventos |
| Muita leitura, pouca escrita, tolerância a atraso na consistência | CQRS com modelos de leitura e cache |
| Muitas integrações heterogêneas | API Gateway + adaptadores |
| Necessidade de reconstituir todo o histórico | Event Sourcing |
| Carga intermitente e imprevisível | Serverless |

Havendo encaixe claro, aproveite. Não havendo, o estilo sai das qualidades prioritárias e das restrições.

### 2.4 Estilo e tecnologias

**Estilo:** justifique por (a) prioridade do negócio, (b) qualidades dominantes, (c) restrições e (d) capacidade do time de operar.

**Tecnologias:** com restrição declarada, respeite e registre como restrição. Sem restrição, escolha pelo contexto, pesando:

- maturidade (tecnologia da moda é dívida em potencial)
- domínio do time (a ferramenta ideal que ninguém sabe operar perde para a segunda melhor que todos conhecem)
- ecossistema (bibliotecas, suporte, mercado para contratar)
- custo total (licença, infraestrutura, aprendizado, manutenção)
- aderência às qualidades prioritárias

Uma stack "tradicional" é perfeitamente válida: se Rails + PostgreSQL atende, proponha Rails + PostgreSQL. O critério é resolver, não impressionar.

### 2.5 Que dívida está sendo contratada?

Toda arquitetura adia alguma coisa. Deixe claro:

- o que não está sendo feito agora e quando passará a ser necessário;
- quanto isso deve custar depois;
- em que cenário (volume, tamanho do time, regulação) a dívida vira problema.

Isso entra na proposta como "Dívidas técnicas conscientes".

---

## Fase 3 — Registrar

### Onde os arquivos ficam

- Proposta: `docs/sdd/architecture/proposta-arquitetural.md`
- Decisões: **um arquivo por ADR** em `docs/sdd/architecture/adrs/ADR-XXX-titulo-curto.md`, seguindo `references/adr-template.md`. Numeração de três dígitos, sem reúso (ver `${CLAUDE_PLUGIN_ROOT}/templates/id-conventions.md`).
- A proposta **não copia** o conteúdo dos ADRs: a seção de decisões é um índice com ID, título, status e link para o arquivo.
- ADRs nascem com `**Status:** Proposto`. Pergunte ao usuário se ele já quer marcá-los como `Aceito` ao aprovar a proposta.

Se o repositório já tiver uma convenção diferente para ADRs, pergunte antes de impor esta.

### Nível de detalhe do C4

O C4 tem quatro níveis; quanto menor o número, mais abstrato:

1. **Contexto** — o sistema como caixa fechada, com pessoas e sistemas ao redor
2. **Containers** — as peças implantáveis (aplicações, APIs, bancos, filas)
3. **Componentes** — a organização interna de um container
4. **Código** — classes e módulos; praticamente nunca compensa documentar, o código já é a fonte

Escolha pela complexidade da demanda e diga em uma frase por que escolheu:

| Situação | Níveis |
| --- | --- |
| PoC, sistema pequeno, time enxuto | 2, com uma frase de contexto |
| Caso comum | 1 + 2 |
| Vários containers críticos ou um container com muitos módulos | 1 + 2 + 3 (só dos containers relevantes) |
| Pedido explícito e justificado | 4 |

### Diagramas

Todos em Mermaid. Modelos em `references/c4-mermaid-templates.md`: `flowchart` para containers e componentes, `sequenceDiagram` para fluxos que ajudam a defender uma decisão, `stateDiagram` para ciclos de vida relevantes.

### Modelos e catálogos

Leia `references/proposal-template.md` antes de gerar a proposta. Os demais arquivos são consultados quando necessário:

- `references/adr-template.md` — modelo do arquivo de cada decisão
- `references/c4-mermaid-templates.md` — diagramas C4, sequência e estado, com erros comuns
- `references/quality-attributes.md` — catálogo de qualidades com perguntas, sinais de prioridade, padrões e trade-offs
- `references/architectural-styles.md` — estilos arquiteturais com forças, fraquezas e quando evitar
- `${CLAUDE_PLUGIN_ROOT}/stacks/rails/pipeline-example.md` — uma demanda percorrendo todas as fases em Rails; útil para ver como um ADR desta fase é citado no PRD, no plano e no review

### Como escrever

- **Afirme.** "Adotamos PostgreSQL", não "poderíamos usar PostgreSQL".
- **Justifique sempre**, ligando cada decisão a um objetivo, qualidade ou restrição.
- **Explique o jargão** na primeira vez em que aparecer; o sumário executivo precisa ser entendido por quem não é técnico.
- **Troque adjetivo por número.** "Aguenta 2 mil requisições por segundo" diz mais que "altamente escalável".
- **Registre o que ficou de fora** no apêndice — protege o escopo.
- **Seja franco sobre dívida.** Assumir o que foi adiado é sinal de maturidade, não de fraqueza.

---

## Antes de entregar

- [ ] Cada decisão tem motivo ligado a negócio, qualidade ou restrição — nunca a "boa prática" genérica
- [ ] As tecnologias refletem o contexto e o time, não a moda
- [ ] Imposições do cliente aparecem como **restrição**, não como decisão
- [ ] Cada decisão tem seu arquivo `ADR-XXX-*.md` e a proposta aponta para todos eles
- [ ] Os níveis de C4 combinam com a complexidade
- [ ] As dívidas conscientes estão escritas
- [ ] O sumário executivo é legível por alguém de negócio
- [ ] Nenhum custo, prazo ou esforço **criado pela proposta** — valores só aparecem quando são restrição informada, e ficam na seção de restrições
- [ ] Nenhum `[A DEFINIR]` restante

---

## Depois de entregar

**Sugira** — sem executar — preparar o contexto para agentes:

> A proposta definiu stack, restrições e convenções que o agente precisa ter à mão em toda sessão, e ninguém quer que ele releia o documento inteiro toda vez. Quando quiser, rode `/sdd-setup`: ele analisa o repositório, confere versões e gera o `AGENTS.md` (e o `CLAUDE.md`, se usar Claude Code) com o essencial, apontando para esta proposta para os detalhes.

Avise que comandos de build e teste só aparecem depois do primeiro scaffolding — antes disso não há o que detectar. Se o usuário não quiser, siga em frente; **nunca gere esses arquivos por conta própria**.

Próximo passo natural do pipeline: transformar a primeira funcionalidade em PRD com a skill `sdd-prd`.
