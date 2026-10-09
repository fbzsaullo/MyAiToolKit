# Changelog

Todas as mudanças relevantes do MyAiToolKit. Formato inspirado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/); versionamento [SemVer](https://semver.org/lang/pt-BR/).

## [0.5.1] — 2026-10-09

Preparação para o diretório de plugins do Claude.

### Novo
- **Ícone da listagem** na pasta `.claude-plugin/`: o ícone MA/TK da marca, em PNG quadrado de 1024 px, branco sobre preto. O Claude Code não lê o arquivo; só o diretório usa.

### Convenções
- `.gitattributes`: imagens PNG marcadas como binárias, fora da regra de finais de linha LF.
- Conferido o que o validador do diretório apontou como leitura de credencial da máquina e como execução de pacote baixado: são exemplos de regras de permissão (`deny` de `.env`, `config/master.key`, `.aws/credentials`; `ask` de `npx` e `pnpm dlx`) que o `/sdd-setup` grava para **bloquear** ou **perguntar**. Nenhuma skill lê segredo nem roda script remoto; nada mudou nesses arquivos.

## [0.5.0] — 2026-10-09

O "Resolvido" do round 2 passa a ser conferido.

### Novo
- **Conferência das correções** no `/sdd-review`, do round 2 em diante, com a revisão cruzada ligada: os apontamentos do round anterior que o revisor marcou `Resolvido` vão para o mesmo verificador independente, sem a marcação nem o motivo dela, junto com o diff desde o round anterior. Ele responde `Resolvido`, `Persiste` ou `Inconclusivo`, sempre com `arquivo:linha`.
- **Assimetria invertida:** `Persiste` com evidência conferida **reabre** o apontamento como `R-XX` do round, com a severidade original; `Inconclusivo` numa correção de `Bloqueante` vira disputa e vai para o usuário (sem resposta, reabre).
- **Teste que não prova o cenário:** se o apontamento era a falta de um teste, o verificador confere se o teste novo exercita o cenário — existir com `CA-XX` no nome não basta.
- `auto` confere as correções de `Bloqueantes` (e isso, sozinho, aciona a verificação); `always` confere as de `Bloqueantes` e `Importantes`. Tudo no mesmo pedido único: parte A (candidatos novos) e parte B (correções), com limite de 20 itens.
- Relatório com o campo **`Commit revisado:`** — o próximo round usa o diff desde ele — e a coluna **Verificador** na tabela "Round anterior".

### Convenções
- `templates/cross-check.md`: seção 7 nova (correções); as travas viram a seção 8, com a trava 6 reescrita ("o que foi julgado não é julgado de novo; confere-se só a correção") e a trava 7 nova (reaberto espera o próximo round).

## [0.4.0] — 2026-10-09

Os reviews podem se questionar — sem virar debate.

### Novo
- **Revisão cruzada** no `/sdd-review` e no `/code-review`, opcional: um verificador independente, só de leitura, recebe os apontamentos `Bloqueante`, `Importante` e `Q1` (sem o raciocínio de quem apontou) e responde `Confirmado`, `Refutado` (com contra-evidência em `arquivo:linha`) ou `Inconclusivo`. `Importante` refutado sai do relatório; `Bloqueante` ou `Q1` refutado fica **em disputa** e vai para o usuário numa pergunta só. Uma verificação por review, sem réplica e sem segunda rodada. Regras em `templates/cross-check.md`.
- **Agente do plugin** `agents/review-verifier.md` (`my-ai-toolkit:review-verifier` no Claude Code): `Read`, `Grep` e `Glob`, `maxTurns: 12`. No Codex, a skill pede um subagente com o mesmo pedido. Sem suporte a subagentes, o review avisa "indisponível" e segue simples — nunca simula a verificação.
- **`/sdd-setup` pergunta** se a revisão cruzada fica desligada, automática (só com `Bloqueante`/`Q1`) ou sempre ligada, com o custo na pergunta. Chave `review.cross_check: never | auto | always` no `config.yml` (padrão `never`); na chamada, `cruzada` e `simples` sobrepõem o valor.
- Relatórios com o campo `Revisão cruzada:` e as seções "Verificação cruzada" e "Candidatos descartados".

### Convenções
- `adapters/README.md`: recurso opcional pode depender de uma capacidade do ambiente, desde que o pedido seja compartilhado entre as IAs e a skill siga no modo normal quando a capacidade faltar.
- `scripts/check.sh` valida o frontmatter dos agentes em `agents/`.
- `REFERENCES.md`: fontes da revisão cruzada e a escolha "verificação, não debate".

## [0.3.2] — 2026-10-09

### Corrigido
- `sdd-review`: a branch base do diff local vinha de `git.default_base_branch`, chave que não existe; agora vem de `code_review.default_base_branch`, a mesma do `/code-review`.
- Adaptador do Claude Code: o texto dizia que o `allowed-tools` limita a edição à pasta do artefato. Pela documentação, o campo **pré-aprova** as ferramentas listadas e não restringe as demais (e a liberação acaba na próxima mensagem do usuário). O README do adaptador agora explica o que de fato garante cada limite.
- `templates/id-conventions.md`: dizia "quatro valores" de status de tarefa; são cinco desde o `Cancelado`.

### Convenções
- **Numeração entre PRDs:** `RN`, `CA`, `UI` e `T` continuam a contagem do projeto inteiro — o PRD-002 começa depois do maior `RN`/`CA` do PRD-001, e o PLAN-002 depois da maior `T`. Seção nova "Mais de um PRD no projeto" em `id-conventions.md`; `sdd-prd`, `sdd-plan`, `sdd-prototype` e `sdd-bug` seguem a regra, e o `sdd-trace` aponta ID repetido entre documentos.

## [0.3.1] — 2026-10-07

### Novo
- **`/pr-description`** (`$pr-description` no Codex): escreve título e descrição do Pull Request a partir do diff contra a base (perguntada sempre, como no `/code-review`) — o que muda e por quê, rastreabilidade (`T-XX`, RN, CA, UI, ADR, card, BUG), como testar com os comandos do `config.yml`, cenários cobertos por teste, resultado do review SDD e do code review, riscos de implantação. Usa o modelo de PR do repositório quando existe; senão, `references/pr-template.md`. Entrega em texto: nunca abre, edita nem comenta PR, e nunca faz push.
- `sdd-review` e `code-review` sugerem o `/pr-description` quando o trabalho da branch está pronto.

### Corrigido
- README: a nota sobre o `/code-review` nativo e as chamadas no Codex tinha um trecho do início do arquivo colado no meio (introduzido na 0.2.0).

## [0.3.0] — 2026-10-07

O pipeline passa a lidar com o que acontece depois do plano: escopo que muda, defeito que aparece, decisão que surge no meio do caminho.

### Novo
- **`/sdd-change`**: muda o escopo de um PRD aprovado. Mostra o impacto em cada ID (RN, CA, UI, T, ADR, testes) antes de editar, registra a revisão no PRD e na SPEC-UI, e ajusta o plano — tarefas pendentes editadas, concluídas nunca reabertas, uma fase nova para o que muda e tarefas sem sentido marcadas `Cancelado`.
- **`/sdd-bug`**: do relato a **uma** tarefa de correção. Separa observado de esperado, acha o cenário descumprido (ou a lacuna no PRD), investiga a causa provável sem mexer no código e cria a tarefa com teste de regressão. Relatório em `docs/sdd/bugs/BUG-<CHAVE>-*.md`; bug sem PRD vai para `PLAN-000-correcoes.md`.
- **`/sdd-adr`**: registra uma decisão avulsa, substitui ou descontinua um ADR, mantém o índice da proposta e avisa quais tarefas se apoiam na decisão que mudou.
- `/sdd-start` ganha as opções **E** (defeito → `sdd-bug`) e **F** (mudança em PRD aprovado → `sdd-change`).

### Convenções
- Status de tarefa **`Cancelado`** (`Canceled`): para tarefa que perdeu o sentido; o bloco fica e o número não volta. Lido por `sdd-next`, `sdd-trace`, `sdd-execute` e `sdd-review`.
- **Tarefa estrutural**: `Implementa: estrutural — <motivo>` marca tarefa sem regra (projeto, infraestrutura, documentação); o `sdd-trace` deixa de apontá-la como "sem rastro".
- Seção **Revisões** no PRD (18) e na SPEC-UI (10), com notação `+` novo, `~` alterado, `−` revogado.
- ID `BUG-<CHAVE>` e pasta `docs/sdd/bugs/`.

### Pipeline
- O `/sdd-plan` confere, antes de entregar, se toda tela e todo estado da SPEC-UI aparecem em alguma tarefa — a mesma checagem que o `sdd-trace` faz no fim, só que quando corrigir é barato.
- O `/sdd-trace` aponta cenário coberto só por tarefa cancelada e revogação sem linha em Revisões, e tira da cobertura os IDs revogados.

## [0.2.0] — 2026-10-07

O kit nunca commita: ele entrega a mensagem pronta, no padrão que você escolheu.

### Novo
- **`/commit-message`** (`$commit-message` no Codex): escreve a mensagem de commit das alterações atuais — o que está preparado (staged) ou, sem isso, a árvore de trabalho — no padrão do projeto, acha a `T-XX` quando há plano e sugere dividir o commit quando o diff mistura assuntos. Só lê o repositório.
- `templates/commit-message.md`: regras compartilhadas de tipo, escopo, assunto, corpo, rodapé e posição da `T-XX`.

### Setup
- O `/sdd-setup` pergunta o **padrão das mensagens de commit**: Conventional Commits, ID da tarefa primeiro ou um padrão escrito pelo usuário. A escolha fica em `docs/sdd/config.yml` (`git.commit`) e numa linha do `AGENTS.md`; a opção que bate com o que o projeto já usa (commitlint, commitizen, hooks, histórico) vem recomendada.
- **O kit nunca commita.** A pergunta "`git commit` pelo agente: liberado ou com confirmação?" saiu: `git commit` fica sempre em `ask`. A chave `permissions.claude.git_commit` deixou de existir; o setup aponta configurações antigas com commit liberado.

### Pipeline
- A mensagem de commit da tarefa saiu do fim do `/sdd-execute` e passou para o fim do `/sdd-review`, entregue só quando a tarefa é aprovada — ninguém commita o que o review devolve como `Bloqueado`.
- O `/sdd-review` preenche a coluna Commit do histórico do plano a partir do `git log` (commits que citam a `T-XX`), com confirmação; o `/sdd-next` aponta o hash encontrado.
- `sdd-review` e `code-review` conferem se os commits seguem o padrão do projeto.

### Documentação
- Crédito ao [leanwork-sdd](https://github.com/leanwork/leanwork-sdd) (Leanwork Group, MIT) como base do pipeline SDD: seção "Origem e créditos" no README, seção própria no REFERENCES.md e aviso de copyright no LICENSE.

## [0.1.0] — 2026-10-06

Primeira versão.

### Pipeline SDD
- Skills `sdd-start`, `sdd-architect`, `sdd-prd`, `sdd-prototype`, `sdd-plan`, `sdd-execute`, `sdd-review`, `sdd-trace` e `sdd-next`.
- Rastreabilidade `ADR ↔ RN ↔ CA ↔ UI ↔ T ↔ R ↔ teste`, com convenções em `templates/id-conventions.md`.
- ADRs em arquivos próprios (`docs/sdd/architecture/adrs/ADR-XXX-*.md`) com status de ciclo de vida.
- Todos os artefatos em `docs/sdd/`.
- Campo opcional `Estimativa` nas tarefas: a IA sugere, **só o valor do usuário é gravado**.
- Eixo de **segurança** no review, com checklist por stack.
- Convenção de nome de teste para `CA-XX` definida por stack.
- `sdd-execute` e `sdd-setup` só rodam por chamada explícita.

### Setup multilinguagem
- `sdd-setup` com roteiro de análise comum, leitura de versões reais e recomendações por versão.
- Geração de `docs/sdd/config.yml`, `docs/sdd/stack-report.md`, `AGENTS.md` (canônico), `CLAUDE.md` (importa o `AGENTS.md`), `.claude/settings.json` e `.codex/` (config + regras).
- Perfis de stack: **Rails** (completo, referência), Node.js/TypeScript, Python, .NET, Go, Java/Kotlin, PHP e genérico.

### Ferramentas
- `spike`: análise de esforço a partir de texto ou card exportado (Jira, GitHub, Azure DevOps, Trello), com estimativa de três pontos e decisão do usuário.
- `code-review`: review avulso com escolha da branch base, história opcional (XML, texto ou issue), roteiro montado pela configuração e classificação por severidade e quadrante de urgência × importância.

### Multi-IA
- Plugin e marketplace do Claude Code.
- Adaptador do Codex com instaladores `install.sh` e `install.ps1`.
- Contrato para novos adaptadores em `adapters/README.md`.

### Qualidade
- `scripts/check.sh` e workflow de CI.
