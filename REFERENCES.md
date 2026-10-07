# Referências

As skills do MyAiToolKit são escritas em tom prático: quase nunca citam autores. Isso ajuda quem usa e atrapalha quem quer estudar, avaliar ou discordar. Este arquivo reúne, fase por fase, **de onde vêm as ideias** usadas no toolkit, **onde ele se afasta delas de propósito** e **o que ainda falta**.

Como este é um projeto acadêmico, a regra aqui é simples: crédito a quem é de direito. Se alguma atribuição estiver errada ou incompleta, abra uma issue.

**Como as fontes são marcadas**

| Marca | Significa |
| --- | --- |
| **Uso direto** | A definição ou o vocabulário vêm da fonte, sem alteração relevante. |
| **Adaptação** | O conceito vem da fonte, mas o recorte, os limites ou a aplicação foram ajustados — e o ajuste está descrito. |
| **Heurística de prática** | Número ou regra de bolso sem fonte publicada conhecida; deve ser lido como opinião calibrável. |

---

## Base comum

### leanwork-sdd — base do pipeline

O pipeline SDD foi construído a partir do **[leanwork-sdd](https://github.com/leanwork/leanwork-sdd)** (Leanwork Group, licença MIT), que serviu de referência para a estrutura de fases e o modelo de rastreabilidade. Vêm de lá, entre outros:

- a sequência arquitetura → PRD → protótipo → plano → execução → review, com comandos de entrada (`start`), próximo passo (`next`) e auditoria de rastreabilidade (`trace`);
- a cadeia `ADR → RN → CA → UI → T → R` como grafo único, com o review como último elo;
- o cenário Gherkin ligado à regra e à decisão (`Cenário [CA-XX]: … (RN-XX)` / `(ADR-XXX)`);
- o protótipo como especificação rastreável (SPEC-UI com matriz `UI ↔ RN ↔ CA`, lacuna declarada e origem marcada de cada informação) e o sufixo de estado de tela (`UI-02.erro`);
- os eixos de aderência ao plano e de rastreabilidade no review;
- a classificação de permissões em `allow` / `ask` / `deny` e a divisão do contexto em raiz × módulo;
- a organização das referências por skill e vários limiares de calibragem (por exemplo, tarefas de 30min–4h).

**Adaptação.** Os textos foram reescritos em português e reorganizados; as partes acrescentadas por este projeto estão em [O que o MyAiToolKit acrescenta](#o-que-o-myaitoolkit-acrescenta). A literatura citada nas seções abaixo é, em boa parte, a mesma que o leanwork-sdd já documenta como fundamento.

### Spec-Driven Development

A ideia de especificar antes de implementar, com artefatos versionados que um agente de IA consome, aparece em ferramentas recentes:

- **[GitHub Spec Kit](https://github.com/github/spec-kit)** — fluxo especificar → planejar → quebrar em tarefas → implementar.
- **[Kiro](https://kiro.dev)** — requisitos, desenho e tarefas como arquivos separados.

**Adaptação.** O fluxo arquitetura → requisitos → interface (opcional) → plano → execução → review, com Gherkin no idioma do projeto e todas as fases ligadas por IDs, segue o desenho do leanwork-sdd.

A raiz mais antiga — requisito escrito antes do código, verificável e separado do desenho — está na **[ISO/IEC/IEEE 29148:2018](https://www.iso.org/standard/72089.html)** (sucessora da IEEE 830) e em **Michael Jackson**, *Problem Frames* (2001).

### Rastreabilidade

A cadeia `ADR → RN → CA → UI → T → R → teste` é uma **matriz de rastreabilidade de requisitos**:

- **ISO/IEC/IEEE 29148:2018** — rastreabilidade nos dois sentidos e registro da origem de cada requisito.
- **CMMI-DEV, área REQM** — rastreabilidade bidirecional entre requisitos e produtos de trabalho.
- Normas de setores regulados (aviônica, dispositivos médicos), onde a matriz é obrigatória.

**Adaptação.** As normas exigem rastrear, mas não definem prefixos, formato de ID nem a ligação com o review — essa convenção vem do leanwork-sdd. O MyAiToolKit acrescenta o elo `CA → teste` com convenção de nome por stack (`templates/id-conventions.md`).

**Mudança e análise de impacto.** A 29148 e o CMMI pedem que mudanças em requisitos sejam avaliadas pelo impacto antes de aceitas. O `sdd-change` faz isso seguindo a cadeia de IDs nos dois sentidos, e registra a revisão no próprio PRD (seção Revisões), em vez de num controle de mudanças à parte.

### Skills com carregamento sob demanda

`SKILL.md` curta e `references/` lidas só quando necessárias:

- **Jakob Nielsen** — [progressive disclosure](https://www.nngroup.com/articles/progressive-disclosure/), princípio de interface.
- **[Anthropic — Agent Skills](https://docs.claude.com/en/docs/claude-code/skills)** e **[OpenAI — Codex skills](https://developers.openai.com/codex/skills)** — o formato `SKILL.md` com descrição usada para seleção.

**Uso direto** do formato; **adaptação** do princípio de interface para economia de contexto do agente.

### Contexto e multi-IA

- **[AGENTS.md](https://agents.md)** — formato aberto de instruções para agentes, lido por várias ferramentas. **Uso direto**: é o contexto canônico gerado pelo `sdd-setup`.
- **[Claude Code — memória e imports](https://docs.claude.com/en/docs/claude-code/memory)** — a sintaxe `@arquivo` que permite ao `CLAUDE.md` importar o `AGENTS.md` em vez de duplicá-lo.
- **Docs as code** — documentação versionada junto do código; Anne Gentle, *Docs Like Code* (2017).
- Blocos delimitados por comentários (`<!-- start --> / <!-- end -->`) para atualização não destrutiva — convenção difundida em ferramentas de geração de README. **Adaptação.**

---

## `sdd-architect` — arquitetura

- **C4 Model** — **Simon Brown**, [c4model.com](https://c4model.com): os quatro níveis e a regra de não misturá-los. **Uso direto** dos níveis; a notação usa `flowchart` do Mermaid, não a notação C4 canônica. O diagrama de estados incluído nos modelos **não** faz parte do C4.
- **Architecture Decision Records** — **Michael Nygard**, ["Documenting Architecture Decisions"](https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions) (2011): contexto, decisão, status e consequências; **[MADR](https://adr.github.io/madr/)**: opções consideradas e consequências positivas/negativas/neutras; **Nat Pryce**, [adr-tools](https://github.com/npryce/adr-tools): um arquivo por decisão, numeração sequencial. **Uso direto** — e o toolkit segue a forma original de um arquivo por ADR, com status de ciclo de vida.
- **Estrutura da proposta** — ecoa o **[arc42](https://arc42.org)** (Starke e Hruschka), com recorte próprio: sem visão de implantação, com seções de dívida e riscos. **Adaptação.**
- **Cynefin** — **Dave Snowden e Mary Boone**, ["A Leader's Framework for Decision Making"](https://hbr.org/2007/11/a-leaders-framework-for-decision-making) (HBR, 2007). **Uso direto** de quatro domínios (o quinto, *disorder*, não é usado).
- **Atributos de qualidade** — o catálogo **não** reproduz a **[ISO/IEC 25010](https://www.iso.org/standard/78176.html)** nem o conjunto de **Bass, Clements e Kazman**, *Software Architecture in Practice*. Desempenho, disponibilidade, segurança e manutenibilidade existem nas duas referências; escalabilidade, resiliência e observabilidade são vocabulário de indústria promovido a atributo. **Adaptação declarada.** A regra "toda decisão aponta para uma qualidade ou restrição" vem da lógica do **ATAM** (SEI), sem o método completo.
- **Estilos arquiteturais** — camadas: Buschmann et al., *POSA* vol. 1 (1996) e Fowler, *PoEAA* (2002); monolito modular: Simon Brown e os *bounded contexts* de **Eric Evans**, *DDD* (2003); microsserviços: [Lewis e Fowler](https://martinfowler.com/articles/microservices.html) (2014) e Sam Newman, *Building Microservices*; pipes & filters: Garlan e Shaw (1994); orientado a eventos e integração: Hohpe e Woolf, *[Enterprise Integration Patterns](https://www.enterpriseintegrationpatterns.com)* (2003); CQRS: Greg Young, a partir do CQS de **Bertrand Meyer**; event sourcing: [Fowler](https://martinfowler.com/eaaDev/EventSourcing.html); microkernel: *POSA* vol. 1 e Mark Richards; serverless: [Roberts e Fowler](https://martinfowler.com/articles/serverless.html); REST: [Roy Fielding](https://ics.uci.edu/~fielding/pubs/dissertation/top.htm) (2000); gateway: [Chris Richardson](https://microservices.io). O limite "menos de ~15 pessoas" para evitar microsserviços é **heurística de prática**.
- **Padrões táticos citados** — circuit breaker, timeout, bulkhead: **Michael Nygard**, *Release It!*; saga: Garcia-Molina e Salem (1987) e Chris Richardson; outbox: Chris Richardson; backoff com *jitter*: [AWS Builders' Library](https://aws.amazon.com/builders-library/timeouts-retries-and-backoff-with-jitter/); serviços sem estado: *[The Twelve-Factor App](https://12factor.net)*; blue-green e canário: Humble e Farley, *Continuous Delivery* (2010); alertas por SLO: *[Google SRE Book](https://sre.google/sre-book/table-of-contents/)*; observabilidade: Cindy Sridharan e [OpenTelemetry](https://opentelemetry.io).
- **"Tecnologia sem graça"** — **Dan McKinley**, [Choose Boring Technology](https://mcfunley.com/choose-boring-technology) (2015).
- **Lei de Conway** — Melvin Conway (1968); ver divergências.

---

## `sdd-prd` — requisitos

- **BDD e Gherkin** — **Dan North**, [Introducing BDD](https://dannorth.net/introducing-bdd/) (2006); **Aslak Hellesøy e Matt Wynne**, Cucumber e *The Cucumber Book* (2012). As palavras-chave em português (`Funcionalidade`, `Cenário`, `Dado`, `Quando`, `Então`…) são a localização oficial do [gherkin-languages.json](https://github.com/cucumber/gherkin/blob/main/gherkin-languages.json). **Uso direto.**
- **Especificação por exemplos** — **Gojko Adzic**, *[Specification by Example](https://gojko.net/books/specification-by-example/)* (2011); tabelas do FIT de Ward Cunningham. Cenários declarativos ("`Dado` descreve estado") — comunidade Cucumber, Liz Keogh.
- **Linguagem do negócio nos cenários** — *Ubiquitous Language*, Eric Evans (2003).
- **Seções do PRD** — fora do escopo e pontos em aberto: [Joel Spolsky](https://www.joelonsoftware.com/2000/10/03/painless-functional-specifications-part-1-why-bother/) (2000); riscos, premissas e dependências: registro RAID e **PMBOK**; perfis de usuário: **Alan Cooper** (personas); fluxos principal e alternativos: casos de uso de **Ivar Jacobson** e **Alistair Cockburn**; regras numeradas: *Business Rules Manifesto* e IEEE 830 (regra clara e verificável); permissões: RBAC (NIST); estados: *Statecharts* de **David Harel** (1987). **Adaptação** — a composição não segue um modelo público único.
- **Hierarquia épico → funcionalidade → história** — prática comum de backlog (Scrum, boards ágeis); o "pequena o bastante" segue o **INVEST** de **Bill Wake** (2003).
- **Requisito diz o quê, não o como** — IEEE 830; David Parnas; Michael Jackson.
- **Entrevista guiada** — técnica catalogada na 29148 e no BABOK; evitar perguntas abertas e oferecer direções concretas segue **Rob Fitzpatrick**, *The Mom Test* (2013), e **Erika Hall**, *Just Enough Research* (2013).

---

## `sdd-prototype` — interface como especificação

- **Estados de tela** — **Scott Hurff**, [The UI Stack](https://www.scotthurff.com/posts/why-your-user-interface-is-awkward-youre-ignoring-the-ui-stack/) e *Designing Products People Love* (2015): ideal, vazio, erro, parcial e carregando. **Adaptação** — os estados universais do catálogo correspondem a esses cinco; os demais (sem permissão, vazio por filtro, estados por tipo de tela e estados derivados de regras) são extensões.
- Tela vazia que orienta — 37signals, *[Getting Real](https://basecamp.com/gettingreal)* (2006).
- Esqueleto em vez de spinner — **Luke Wroblewski**, *Avoid the Spinner* (2013); limites de tempo de resposta de **Jakob Nielsen**.
- Erro que preserva os dados e prevenção de erros — [heurísticas de Nielsen](https://www.nngroup.com/articles/ten-usability-heuristics/) #5 e #9; WCAG 3.3.4.
- Edição concorrente — problema da atualização perdida; Kung e Robinson (1981).
- Desfazer em vez de alerta — **Aza Raskin**, [Never Use a Warning When You Mean Undo](https://alistapart.com/article/neveruseawarning/) (2010).
- Valores de borda — **Glenford Myers**, *The Art of Software Testing* (1979); casos extremos — **Eric Meyer e Sara Wachter-Boettcher**, *Design for Real Life* (2016).
- **Protótipo derivado de casos de uso com rastreabilidade** — **Larry Constantine e Lucy Lockwood**, *Software for Use* (1999). É a ancoragem mais próxima do procedimento "cada recusa num cenário vira um estado de tela".
- Esboço × protótipo — **Bill Buxton**, *Sketching User Experiences* (2007); fidelidade — Rudd, Stern e Isensee (1996).
- **Design tokens** — Jina Anne (Salesforce) e o [W3C Design Tokens Community Group](https://www.w3.org/community/design-tokens/). Não duplicar valores: DRY, Hunt e Thomas, *The Pragmatic Programmer* (1999).
- **Inventário de componentes** — **Brad Frost**, [Interface Inventory](https://bradfrost.com/blog/post/interface-inventory/) (2013). (O toolkit faz inventário, não *Atomic Design*.)
- Acessibilidade — **[WCAG 2.2](https://www.w3.org/TR/WCAG22/)**; responsividade — Ethan Marcotte (2010); *mobile first* — Luke Wroblewski (2011); conteúdo real em vez de *lorem ipsum* — Kristina Halvorson.

---

## `sdd-plan` e `sdd-execute` — plano e execução

- Decomposição com dependências — *Work Breakdown Structure* (PMBOK).
- Critérios de conclusão por fase — *Definition of Done* (Scrum).
- **Teste de caracterização** — **Michael Feathers**, *Working Effectively with Legacy Code* (2004).
- **Expandir → migrar → contrair** — *Parallel Change*, [Martin Fowler](https://martinfowler.com/bliki/ParallelChange.html).
- **Corte vertical / esqueleto andante** — **Alistair Cockburn** (walking skeleton) e **Jeff Patton** (story mapping); ver divergências.
- Teste antes do código — **Kent Beck**, *Test-Driven Development by Example* (2002). O `sdd-bug` aplica a mesma ideia à correção: o teste que reproduz o defeito vem primeiro, falha, e depois fica como teste de regressão.
- Arrange-Act-Assert — Bill Wake (2001).
- Cardinalidade de métricas — orientação de nomes do [Prometheus](https://prometheus.io/docs/practices/naming/) e do OpenTelemetry.
- Feature flags — **Pete Hodgson**, [Feature Toggles](https://martinfowler.com/articles/feature-toggles.html) (2017).
- Os limites 30min–4h por tarefa, "mais de 3 critérios = grande demais" e "mais de 5 tarefas = diagrama" são **heurísticas de prática**.

---

## `sdd-review` e `code-review` — revisão

- **Revisão de código moderna** — [Google Engineering Practices](https://google.github.io/eng-practices/review/): não comentar o que o linter cobre, não exigir "do jeito que eu faria". Inspeção formal — **Michael Fagan** (IBM, 1976) e IEEE 1028.
- Rótulos de severidade em comentários — [Conventional Comments](https://conventionalcomments.org/).
- *Code smells* — Fowler e Beck, *Refactoring* (1999); *test smells* — **Gerard Meszaros**, *xUnit Test Patterns* (2007); dublês — [Fowler, Mocks Aren't Stubs](https://martinfowler.com/articles/mocksArentStubs.html).
- Dívida consciente × acidental — [Technical Debt Quadrant](https://martinfowler.com/bliki/TechnicalDebtQuadrant.html), Fowler (2009).
- **Matriz urgência × importância** (quadrantes Q1–Q4 do `code-review`) — a matriz de decisão atribuída a **Dwight D. Eisenhower** e popularizada por **Stephen Covey**, *Os 7 Hábitos das Pessoas Altamente Eficazes* (1989). **Adaptação**: urgência = precisa de ação antes deste merge; importância = impacto em correção, segurança, dados ou manutenção.
- **Eixo de segurança** — **[OWASP Top 10](https://owasp.org/Top10/)** e [CWE](https://cwe.mitre.org) (injeção, XSS, controle de acesso, exposição de dados); dados pessoais em log — LGPD art. 6º e [CWE-532](https://cwe.mitre.org/data/definitions/532.html). Em Rails: [Guia de Segurança do Rails](https://guides.rubyonrails.org/security.html), [OWASP Ruby on Rails Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Ruby_on_Rails_Cheat_Sheet.html) e [Brakeman](https://brakemanscanner.org). **Adaptação**: checklist aplicado só ao diff, explicitamente não é modelagem de ameaças.
- Diff a partir do ponto de separação (`base...alvo`) — [documentação do git diff](https://git-scm.com/docs/git-diff).

---

## `sdd-setup` — contexto e permissões

- **Menor privilégio e padrões seguros** — **[Saltzer e Schroeder](https://web.mit.edu/Saltzer/www/publications/protection/)** (1975); "aceitabilidade psicológica" (mesmo artigo) fundamenta não bloquear o que o pipeline precisa.
- **Fadiga de confirmação** — base experimental: Akhawe e Felt, *Alice in Warningland* (USENIX Security, 2013); Sunshine et al., *Crying Wolf* (2009).
- **Cadeia de suprimentos de dependências** — OWASP Top 10; [SLSA](https://slsa.dev); NIST SP 800-218.
- **Histórico compartilhado** — *Pro Git* (Chacon e Straub), regra de ouro do rebase e `--force-with-lease`.
- **Reversibilidade como critério** — decisões de "porta de mão dupla" × "mão única" (Jeff Bezos, carta aos acionistas de 2015) e *blast radius* (Google SRE).
- **Mecânica de permissões** — [Claude Code settings](https://docs.claude.com/en/docs/claude-code/settings) e documentação de permissões e regras do Codex.
- **Política de versões** — páginas oficiais de manutenção de cada stack (Rails, Ruby, Node, Python, .NET, Go, Java, PHP), citadas nos perfis em `stacks/`.
- **Mensagens de commit** — [Conventional Commits 1.0.0](https://www.conventionalcommits.org/pt-br/v1.0.0/) (tipos, escopo, `!` e `BREAKING CHANGE`); convenção de assunto curto e corpo com o porquê, de *Pro Git* (Chacon e Straub). **Adaptação**: a `T-XX` entra no assunto ou no rodapé `Refs:`, e o padrão é escolha do usuário no setup — Conventional Commits é a recomendação, não a imposição.

---

## `spike` — análise de esforço

- **Estimativa de três pontos e PERT** — técnica desenvolvida no programa Polaris da Marinha dos EUA; Malcolm, Roseboom, Clark e Fazar, *Application of a Technique for Research and Development Program Evaluation* (Operations Research, 1959). **Uso direto** da fórmula (O + 4M + P) / 6.
- **Estimativa de software** — **Steve McConnell**, *Software Estimation: Demystifying the Black Art* (2006): faixas em vez de número único, cone da incerteza, contar as atividades esquecidas.
- **Viés de otimismo** — Kahneman e Tversky, falácia do planejamento (1979) — motivo de mostrar o pessimista e as premissas.
- **Spike com timebox** — Kent Beck, *Extreme Programming Explained* (1999).
- **Separar estimativa de requisito** — o PRD e o plano não estimam por conta própria; a estimativa é decisão de quem vai executar. A ideia ecoa o debate *#NoEstimates* (Woody Zuill, Vasco Duarte), sem aboli-la: o toolkit apenas a coloca em uma ferramenta própria e deixa a decisão com o usuário.
- As faixas em `stacks/rails/spike-heuristics.md` e os multiplicadores de contexto são **heurísticas de prática**, feitas para serem recalibradas pelo histórico de cada time.

---

## Escolhas que divergem da literatura

Desvios conscientes. Quem adota o toolkit adota também estas escolhas.

### Corte por camada como padrão

O modelo de plano agrupa tarefas por camada técnica (dados → regras → exposição → interface → qualidade). Isso contraria o **walking skeleton** de [Alistair Cockburn](https://alistair.cockburn.us/walking-skeleton/) e o **story mapping** de [Jeff Patton](https://www.jpattonassociates.com/story-mapping/), que defendem entregar algo de ponta a ponta já na primeira fatia.

**Por que o padrão é por camada:** quando PRD e arquitetura já estão fechados antes do plano, o risco de descobrir requisitos tarde — o principal argumento do corte vertical — é menor, e o corte por camada facilita tarefas pequenas e revisáveis. **O custo:** o risco de integração continua existindo e fica concentrado no fim.

**Exceção:** quando a conversa do `sdd-plan` indica entrega incremental real ou risco concreto de integração, a parte afetada do plano usa corte vertical (seção "Corte horizontal ou vertical" do `sdd-plan`, Exemplo 6 de `task-examples.md`).

### Numeração plana de tarefas

`T-01`, `T-02`… em sequência, em vez da codificação hierárquica da WBS (`1.2.3`). Troca-se a estrutura embutida no ID por IDs curtos e estáveis para citar em commit, teste e review.

### ID no título do cenário, não em tag

`Cenário [CA-01]: ...` contraria o costume do Cucumber de usar **tags** (`@CA-01`), que o executor consegue filtrar. O ID no título não é filtrável e quebra se o título for reescrito sem cuidado. Escolhido por ser legível em qualquer ferramenta e por aparecer no relatório de testes. (Em RSpec, o metadado opcional `ca: "CA-01"` recupera a filtragem.)

### Lei de Conway usada como orientação

O artigo de Conway (1968) **descreve** que sistemas espelham a comunicação da organização. Usá-lo para **prescrever** a arquitetura é a "manobra inversa de Conway" (Skelton e Pais, *[Team Topologies](https://teamtopologies.com)*, 2019), e é nesse sentido que o catálogo de estilos o emprega.

### CAP como trade-off permanente

O "escolha 2 de 3" foi revisto pelo próprio **Eric Brewer** em *[CAP Twelve Years Later](https://www.infoq.com/articles/cap-twelve-years-later-how-the-rules-have-changed/)* (2012): o dilema vale durante partição; fora dela, a tensão é latência × consistência (modelo **PACELC**, Daniel Abadi). Os modelos usam o par consistência × disponibilidade por simplicidade.

### Busca textual não prova execução

Achar `CA-01` no nome de um teste prova que o cenário foi **citado** — não que o teste existe de verdade, roda e passa. Por isso o `sdd-review` verifica o conteúdo do teste e não só o nome.

### Estimativa existe, mas não é da IA

O pipeline SDD não estima por conta própria, mas o `spike` e o campo `Estimativa` do plano registram horas. A divergência em relação à IA "que estima sozinha" é intencional: a IA sugere com premissas, e somente o número informado pelo usuário é gravado.

---

## O que o MyAiToolKit acrescenta

Partes desenhadas para este projeto, além da base herdada do [leanwork-sdd](#leanwork-sdd--base-do-pipeline):

1. **Setup multilinguagem com perfis de stack** — um roteiro de análise comum (`base-prompt.md`) e perfis por linguagem com detecção, fontes de versão, orientações por versão, comandos, testes, segurança e permissões; Rails como perfil de referência.
2. **`config.yml` como contrato entre as skills** — os fatos do projeto (versões, comandos, convenção de teste, branch base, parâmetros de spike) num único arquivo que todas as skills leem.
3. **`AGENTS.md` como fonte única para várias IAs**, com `CLAUDE.md` apenas importando — e permissões geradas para Claude Code e Codex a partir da mesma receita.
4. **Adaptadores por IA** com contrato explícito (`adapters/README.md`) e instalador para o Codex.
5. **`spike`** — ingestão de cards de qualquer board, quebra em partes com três pontos e premissas visíveis, e a regra de que **só o número do usuário é gravado**.
6. **`code-review` avulso** — pergunta a branch base e a história, monta o roteiro a partir da configuração e classifica cada apontamento por severidade **e** por quadrante de urgência × importância.
7. **Eixo de segurança por stack** nos dois reviews.
8. **Convenção de nome de teste por stack** para o elo `CA → teste`.
9. **ADRs em arquivos próprios** (`docs/sdd/architecture/adrs/ADR-XXX-*.md`) com status de ciclo de vida, e campo opcional `Estimativa` nas tarefas do plano.
10. **O kit nunca commita nem abre PR** — padrão de mensagem escolhido no setup, `/commit-message` para qualquer diff, mensagem da tarefa entregue só quando o review aprova, hash preenchido no histórico a partir do `git log` e `/pr-description` montando o texto do PR com a rastreabilidade e os reviews.
11. **Gestão de mudança no pipeline** — `sdd-change` (impacto por ID, revisão registrada, tarefas canceladas em vez de apagadas), `sdd-bug` (bug como tarefa com teste de regressão ligado ao cenário descumprido) e `sdd-adr` (decisão avulsa com ciclo de vida), mais o status `Cancelado` e a marca `estrutural` nas tarefas.

---

## Lacunas conhecidas

| Lacuna | O que ajudaria |
| --- | --- |
| **Fitness functions** — Ford, Parsons e Kua, *Building Evolutionary Architectures* (2017) | Verificar fronteiras de módulo automaticamente (packwerk, dependency-cruiser, ArchUnit) em vez de só por review |
| **Ports & Adapters** — Alistair Cockburn (2005) | O termo "adaptadores" aparece, o padrão não é nomeado |
| **Strangler Fig** — Fowler (2004) | Migração gradual de legado é discutida sem o padrão |
| **Visão de implantação** (arc42 §7, C4 Deployment) | Decisões de infraestrutura sem diagrama de topologia |
| **Golden Signals / RED / USE** | Observabilidade sem método de métricas |
| **DORA** — [dora.dev](https://dora.dev) | Nada mede se o processo melhorou a entrega |
| **STRIDE / ASVS** | O eixo de segurança é checklist de diff, sem modelagem de ameaças |
| **RTO / RPO** | Recuperação de desastre citada sem as métricas que a definem |
| **eMAG e LBI (Lei 13.146/2015)** | Acessibilidade cita WCAG, não a norma brasileira |
| **Calibração de estimativas com histórico** | O `spike` poderia comparar estimativa informada × tempo real das tarefas concluídas |
| **Perfis completos para outras stacks** | Hoje só Rails tem checklists, heurísticas e exemplos próprios |

---

## Bibliografia

### Livros

| Autor | Obra | Ano |
| --- | --- | --- |
| Bass, Clements e Kazman | *Software Architecture in Practice* | 2021 (4ª ed.) |
| Kent Beck | *Extreme Programming Explained* / *Test-Driven Development by Example* | 1999 / 2002 |
| Beck e Fowler | *Refactoring* | 1999 |
| Beyer et al. | *Site Reliability Engineering* | 2016 |
| Fred Brooks | *The Mythical Man-Month* / *No Silver Bullet* | 1975 / 1987 |
| Buschmann et al. | *Pattern-Oriented Software Architecture*, vol. 1 | 1996 |
| Bill Buxton | *Sketching User Experiences* | 2007 |
| Chacon e Straub | *Pro Git* | 2014 |
| Alistair Cockburn | *Writing Effective Use Cases* | 2000 |
| Constantine e Lockwood | *Software for Use* | 1999 |
| Alan Cooper | *The Inmates Are Running the Asylum* | 1998 |
| Stephen Covey | *The 7 Habits of Highly Effective People* | 1989 |
| Eric Evans | *Domain-Driven Design* | 2003 |
| Michael Feathers | *Working Effectively with Legacy Code* | 2004 |
| Martin Fowler | *Patterns of Enterprise Application Architecture* | 2002 |
| Ford, Parsons e Kua | *Building Evolutionary Architectures* | 2017 |
| Gamma, Helm, Johnson e Vlissides | *Design Patterns* | 1994 |
| Erika Hall | *Just Enough Research* | 2013 |
| Hohpe e Woolf | *Enterprise Integration Patterns* | 2003 |
| Humble e Farley | *Continuous Delivery* | 2010 |
| Hunt e Thomas | *The Pragmatic Programmer* | 1999 |
| Scott Hurff | *Designing Products People Love* | 2015 |
| Michael Jackson | *Problem Frames* | 2001 |
| Steve McConnell | *Software Estimation: Demystifying the Black Art* | 2006 |
| Bertrand Meyer | *Object-Oriented Software Construction* | 1988 |
| Meyer e Wachter-Boettcher | *Design for Real Life* | 2016 |
| Gerard Meszaros | *xUnit Test Patterns* | 2007 |
| Glenford Myers | *The Art of Software Testing* | 1979 |
| Sam Newman | *Building Microservices* | 2015 |
| Michael Nygard | *Release It!* | 2007 / 2018 |
| Skelton e Pais | *Team Topologies* | 2019 |
| Cindy Sridharan | *Distributed Systems Observability* | 2018 |
| Wynne e Hellesøy | *The Cucumber Book* | 2012 |
| 37signals | *Getting Real* | 2006 |

### Artigos

- Akhawe e Felt — *Alice in Warningland* (USENIX Security, 2013)
- Eric Brewer — *CAP Twelve Years Later* (2012)
- Melvin Conway — *How Do Committees Invent?* (1968)
- Roy Fielding — *Architectural Styles and the Design of Network-based Software Architectures* (2000)
- Garcia-Molina e Salem — *Sagas* (SIGMOD, 1987)
- David Harel — *Statecharts: A Visual Formalism for Complex Systems* (1987)
- Kahneman e Tversky — *Intuitive Prediction: Biases and Corrective Procedures* (1979)
- Kung e Robinson — *On Optimistic Methods for Concurrency Control* (1981)
- Lewis e Fowler — *Microservices* (2014)
- Malcolm, Roseboom, Clark e Fazar — *Application of a Technique for R&D Program Evaluation* (Operations Research, 1959)
- Dan McKinley — *Choose Boring Technology* (2015)
- Dan North — *Introducing BDD* (2006)
- Michael Nygard — *Documenting Architecture Decisions* (2011)
- Saltzer e Schroeder — *The Protection of Information in Computer Systems* (1975)
- Snowden e Boone — *A Leader's Framework for Decision Making* (2007)
- Joel Spolsky — *Painless Functional Specifications* (2000)
- Sunshine et al. — *Crying Wolf* (USENIX Security, 2009)
- Bill Wake — *INVEST in Good Stories* (2003)

### Normas e sites

- ISO/IEC/IEEE 29148 · ISO/IEC 25010 · IEEE 830 · IEEE 1028 · CMMI-DEV · PMBOK
- [C4 Model](https://c4model.com) · [arc42](https://arc42.org) · [MADR](https://adr.github.io/madr/) · [adr-tools](https://github.com/npryce/adr-tools)
- [Gherkin](https://cucumber.io/docs/gherkin/reference/) · [Mermaid](https://mermaid.js.org)
- [WCAG 2.2](https://www.w3.org/TR/WCAG22/) · [Design Tokens CG](https://www.w3.org/community/design-tokens/)
- [OWASP Top 10](https://owasp.org/Top10/) · [OWASP Cheat Sheets](https://cheatsheetseries.owasp.org) · [CWE](https://cwe.mitre.org) · [SLSA](https://slsa.dev)
- [Google Engineering Practices](https://google.github.io/eng-practices/review/) · [Google SRE](https://sre.google/books/)
- [The Twelve-Factor App](https://12factor.net) · [microservices.io](https://microservices.io) · [DORA](https://dora.dev)
- [Conventional Comments](https://conventionalcomments.org/) · [Conventional Commits](https://www.conventionalcommits.org)
- [AGENTS.md](https://agents.md) · [Claude Code](https://docs.claude.com/en/docs/claude-code) · [Codex](https://developers.openai.com/codex)
- [GitHub Spec Kit](https://github.com/github/spec-kit) · [Kiro](https://kiro.dev)
- [Guia de Segurança do Rails](https://guides.rubyonrails.org/security.html) · [Brakeman](https://brakemanscanner.org)
- [LGPD — Lei 13.709/2018](https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm)
