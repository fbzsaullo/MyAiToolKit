# MyAiToolKit

**Kit de ferramentas open-source para desenvolver software com agentes de IA** — Claude Code em primeiro lugar, com suporte a Codex e estrutura pronta para outras IAs.

> 🎓 **Projeto de faculdade.** O MyAiToolKit é um projeto acadêmico e open-source. Contribuições, críticas e sugestões são bem-vindas — veja [CONTRIBUTING.md](CONTRIBUTING.md).
>
> O pipeline SDD tem como base o [leanwork-sdd](https://github.com/leanwork/leanwork-sdd) (MIT) — veja [Origem e créditos](#origem-e-créditos).

O kit reúne três frentes:

1. **Pipeline SDD (Spec-Driven Development)** — da arquitetura ao review, com cada artefato ligado ao anterior por IDs rastreáveis.
2. **Setup multilinguagem** — analisa o repositório, lê as versões reais de cada stack e gera a configuração dos agentes (`AGENTS.md`, `CLAUDE.md`, permissões). Rails é a stack de referência.
3. **Ferramentas do dia a dia** — `/spike` para analisar o esforço de um card e `/code-review` para revisar código próprio ou de colegas.

---

## Comandos

### Pipeline SDD

| Comando | O que faz |
| --- | --- |
| `/sdd-start` | Começa uma demanda e descobre por qual fase entrar |
| `/sdd-architect` | Proposta de arquitetura com um arquivo de ADR por decisão e diagramas C4 |
| `/sdd-prd` | PRD com regras de negócio (`RN-XX`) e critérios de aceite em Gherkin (`CA-XX`) |
| `/sdd-prototype` | *(opcional)* SPEC-UI: telas (`UI-XX`) e estados, cruzados com o PRD |
| `/sdd-plan` | Plano com tarefas (`T-XX`) de 30min a 4h, critérios testáveis e estimativa opcional definida por você |
| `/sdd-execute` | Executa **uma** tarefa, com o contexto que ela declara, e atualiza o plano |
| `/sdd-review` | Revisa a tarefa contra plano, PRD, ADRs e SPEC-UI; apontamentos `R-XX` |
| `/sdd-trace` | Matriz de rastreabilidade `ADR ↔ RN ↔ CA ↔ UI ↔ T ↔ R ↔ teste` e os elos quebrados |
| `/sdd-next` | Mostra onde o projeto está e sugere o próximo passo |
| `/sdd-setup` | Analisa a stack e as versões e gera a configuração dos agentes |

### Ferramentas

| Comando | O que faz |
| --- | --- |
| `/spike` | Recebe um card (texto, XML do Jira, issue do GitHub…), quebra em partes, **sugere** horas com premissas e grava **as horas que você decidir** |
| `/code-review` | Pergunta a branch base e a história (XML do card, texto ou nenhuma), revisa com os checklists da stack e classifica cada apontamento por **severidade** e por **urgência × importância** |

> No Claude Code existe um `/code-review` nativo. Se os dois aparecerem, use `/my-ai-toolkit:code-review`. No Codex, as skills são chamadas com `$`: `$sdd-start`, `$spike`, `$code-review`…

---

## O pipeline

```
1. Arquitetura → 2. PRD → 3. Interface* → 4. Plano → 5. Execução ⇄ 6. Review
                                                   └── uma tarefa por ciclo ──┘

sdd-setup, sdd-next e sdd-trace acompanham o pipeline inteiro
* opcional — só para PRDs com telas
```

A execução é uma fase, não um intervalo entre fases: `/sdd-execute` pega uma tarefa por vez, carrega exatamente o contexto que o plano declarou e devolve o estado ao plano; `/sdd-review` valida e, se encontrar um bloqueio, também o devolve ao plano. O plano é o único lugar onde o estado da execução vive.

### Rastreabilidade de ponta a ponta

```
ADR-002   decisão: bloqueio de linha para disputa de horário
   ↓ motiva
RN-04     regra: um horário comporta uma única consulta
   ↓ é demonstrada por
CA-05     cenário: dois pacientes confirmam o último horário ao mesmo tempo
   ↓ aparece na tela como
UI-02.ocupado
   ↓ é construída em
T-03      tarefa: agendar consulta garantindo um paciente por horário
   ↓ é conferida por
R-01      apontamento do review (REVIEW-T-03-2026-10-09)
   ↓ é garantida por
it "CA-05: confirmações simultâneas criam uma única consulta"
```

Cada artefato declara seus vínculos por escrito, e o `/sdd-trace` percorre a cadeia nos dois sentidos para mostrar onde ela se rompe. As regras de numeração estão em [`templates/id-conventions.md`](templates/id-conventions.md) e um exemplo completo, em Rails, em [`stacks/rails/pipeline-example.md`](stacks/rails/pipeline-example.md).

---

## Setup multilinguagem

O `/sdd-setup` segue um **roteiro de análise comum** ([`base-prompt.md`](skills/sdd-setup/references/base-prompt.md)) e usa um **perfil por stack** para os detalhes:

1. descobre todas as stacks do repositório (inclusive monorepo);
2. lê as **versões reais** em lockfiles e arquivos de versão;
3. carrega o perfil da stack — ou o genérico, se não houver;
4. formula **recomendações conforme as versões** (recursos disponíveis e não usados, padrões atrasados, suporte, ferramentas ausentes);
5. pergunta, numa única rodada, o que a análise não respondeu (quais IAs, idioma, permissões) e o **padrão das mensagens de commit**: Conventional Commits, ID da tarefa primeiro ou um padrão que você escreve;
6. gera os arquivos, sempre mostrando o diff e sem sobrescrever o que foi escrito por pessoas.

| Stack | Perfil |
| --- | --- |
| **Ruby on Rails** | **completo** — referência: versões 6.1 → 8.x, permissões, checklists de review e de segurança, convenção de teste, heurísticas de spike e exemplos |
| Node.js / TypeScript, Python, .NET, Go, Java/Kotlin, PHP | perfil + permissões |
| Qualquer outra | perfil genérico |

**O que o setup gera no seu projeto:**

```
AGENTS.md                  contexto canônico (Codex, Cursor e outros leem direto)
CLAUDE.md                  importa o AGENTS.md + o que é só do Claude Code
.claude/settings.json      permissões do Claude Code
.codex/config.toml         permissões do Codex (sandbox)
.codex/rules/*.rules       comandos liberados/perguntados/proibidos no Codex
docs/sdd/
├── config.yml             fatos do projeto lidos por todas as skills
├── stack-report.md        análise de stack, versões e recomendações
├── architecture/          proposta + adrs/ADR-XXX-*.md
├── prds/ · prototype/ · plans/ · reviews/ · traceability/
├── spikes/                análises de esforço
└── code-reviews/          relatórios do /code-review
```

---

## `/spike` — quem decide as horas é você

1. Lê o card em qualquer formato ([`card-ingestion.md`](templates/card-ingestion.md)): XML do Jira, JSON/issue do GitHub, Azure DevOps, Trello ou texto.
2. Olha o código afetado e o `config.yml`.
3. Pergunta só o que muda o número; o resto vira premissa escrita.
4. Sugere horas por parte (otimista / provável / pessimista, PERT), com review, QA e deploy incluídos, faixa total e nível de confiança.
5. **Pergunta quanto tempo você acha que leva** — e grava **somente a sua resposta**.

## `/code-review` — o que resolver primeiro

Cada apontamento recebe severidade (Bloqueante / Importante / Sugestão) e um quadrante:

| | **Importante** | **Não importante** |
| --- | --- | --- |
| **Urgente** | **Q1 — corrigir antes do merge** | **Q3 — ajuste rápido agora** |
| **Não urgente** | **Q2 — planejar (vira card)** | **Q4 — opcional** |

O relatório vem agrupado de Q1 a Q4, com a cobertura dos critérios de aceite da história, o resultado das ferramentas da stack (rodadas só nos arquivos do diff e com sua permissão) e, quando o código é de um colega, comentários prontos para colar no PR.

---

## Instalação

### Claude Code

```bash
git clone <url-do-repositorio> MyAiToolKit
claude plugin marketplace add ./MyAiToolKit
claude plugin install my-ai-toolkit@my-ai-toolkit
```

Para desenvolver o próprio toolkit: `claude --plugin-dir ./MyAiToolKit` (vale só para a sessão). Detalhes em [`adapters/claude-code/`](adapters/claude-code/README.md).

### Codex

```bash
./MyAiToolKit/adapters/codex/install.sh --scope user          # Linux, macOS, Git Bash
./MyAiToolKit/adapters/codex/install.ps1 -Scope user          # Windows PowerShell
```

As skills vão para `~/.agents/skills/` (ou `.agents/skills/` do projeto, com `--scope repo`). Detalhes em [`adapters/codex/`](adapters/codex/README.md).

### Outras IAs

O conteúdo é escrito uma vez, no formato portátil de skills, e cada IA recebe um adaptador. Para adicionar uma nova, siga o contrato em [`adapters/README.md`](adapters/README.md).

---

## Estrutura do repositório

```
MyAiToolKit/
├── .claude-plugin/        manifesto do plugin e do marketplace (Claude Code)
├── skills/                uma pasta por comando (SKILL.md + references/)
│   ├── sdd-start/ sdd-next/ sdd-trace/ sdd-execute/
│   ├── sdd-architect/ sdd-prd/ sdd-prototype/ sdd-plan/ sdd-review/
│   ├── sdd-setup/         roteiro multilinguagem, modelos de AGENTS.md/CLAUDE.md, permissões
│   ├── spike/
│   └── code-review/
├── templates/             convenções compartilhadas: IDs, pastas, leitura de cards, detecção de stack
├── stacks/                perfis por linguagem (rails/ é o completo; _generic/ é o fallback)
├── adapters/              claude-code/, codex/ e o contrato para novas IAs
├── scripts/check.sh       verificações de consistência (rodam no CI)
├── REFERENCES.md          a literatura por trás de cada fase
├── CONTRIBUTING.md
├── CHANGELOG.md
└── LICENSE
```

Por que skills curtas com `references/`? A `SKILL.md` diz *como conduzir*; modelos e catálogos ficam em arquivos carregados só quando necessários. Menos contexto gasto, modelos versionados separadamente e reaproveitáveis fora do toolkit.

---

## Princípios

- **Uma fase por vez, com revisão.** Cada fase gera um artefato que alguém revisa antes da próxima começar.
- **A stack vem do projeto.** As skills não trazem tecnologia embutida; os perfis em `stacks/` e o `config.yml` dizem como cada projeto funciona.
- **Lacuna declarada vale mais que lacuna preenchida.** Nenhuma skill inventa para fechar uma tabela; tudo o que é deduzido aparece como premissa.
- **Nunca destrutivo.** Arquivos escritos por pessoas não são sobrescritos; o diff é sempre mostrado antes de gravar.
- **A IA sugere, você decide.** Estimativas, migrations e permissões sensíveis passam pela sua decisão.
- **O kit nunca commita.** Ao fim de cada tarefa, você recebe a mensagem de commit pronta, em texto, no padrão escolhido no setup; o commit é seu.
- **Português por padrão.** Skills e artefatos em PT-BR; o idioma dos artefatos pode mudar no `config.yml`.
- **Fontes na mesa.** [REFERENCES.md](REFERENCES.md) credita a literatura e registra onde o toolkit diverge dela de propósito.

---

## Origem e créditos

O pipeline SDD foi construído a partir do **[leanwork-sdd](https://github.com/leanwork/leanwork-sdd)** (Leanwork Group, licença MIT), que serviu de referência para a estrutura de fases e o modelo de rastreabilidade — a cadeia `ADR → RN → CA → UI → T → R`, o protótipo como especificação (SPEC-UI) e os eixos de review ligados ao plano. Os textos foram reescritos em português e reorganizados para este projeto.

As contribuições deste trabalho são:

- **Setup multilinguagem** — roteiro de análise comum e perfis de stack (Rails como referência, além de Node.js/TypeScript, Python, .NET, Go, Java/Kotlin, PHP e genérico), com leitura das versões reais e recomendações por versão.
- **`config.yml` como contrato entre as skills** — versões, comandos, convenção de teste, branch base e parâmetros de spike num único arquivo.
- **Multi-IA** — `AGENTS.md` como fonte única de contexto, `CLAUDE.md` apenas importando, permissões geradas para Claude Code e Codex, e adaptadores com contrato explícito.
- **`/spike`** — análise de esforço a partir de cards de qualquer board, com estimativa de três pontos em que só o número do usuário é gravado.
- **`/code-review`** — review avulso com escolha da branch base e classificação por severidade e por quadrante de urgência × importância.
- **Segurança e testes por stack** — eixo de segurança com checklist por stack nos reviews e convenção de nome de teste para o elo `CA → teste`.
- **ADRs em arquivos próprios** com status de ciclo de vida, e campo opcional `Estimativa` nas tarefas do plano.

O detalhamento das fontes, inclusive da literatura de engenharia de software, está em [REFERENCES.md](REFERENCES.md).

---

## Licença

[MIT](LICENSE). Inclui o aviso de copyright do leanwork-sdd, do qual o pipeline SDD deriva.
