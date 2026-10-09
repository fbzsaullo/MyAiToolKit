---
name: sdd-setup
description: Analisa o repositório (uma ou várias linguagens, inclusive monorepo), lê as versões reais de cada stack, carrega o perfil da stack (Rails é a referência; há perfis para Node, Python, .NET, Go, Java e PHP e um genérico para o resto), formula recomendações conforme as versões e gera a configuração do projeto para os agentes — docs/sdd/config.yml, AGENTS.md (contexto canônico), CLAUDE.md, permissões do Claude Code (.claude/settings.json) e do Codex (.codex/), e o relatório docs/sdd/stack-report.md. Pergunta também o padrão das mensagens de commit (o kit nunca commita, só entrega a mensagem pronta em texto) e se a revisão cruzada dos reviews fica ligada (um verificador independente confere os apontamentos graves). Modos — completo, audit (somente leitura), module <nome>, permissions, refresh. Nunca sobrescreve conteúdo escrito por pessoas e sempre mostra o diff antes de gravar. Use apenas quando o usuário chamar /sdd-setup (ou $sdd-setup) ou pedir explicitamente para configurar o toolkit, gerar AGENTS.md/CLAUDE.md, analisar a stack ou configurar permissões.
argument-hint: "[audit | module <nome> | permissions | refresh — vazio = setup completo]"
disable-model-invocation: true
allowed-tools: Read, Glob, Grep
---

# sdd-setup — analisar a stack e configurar o projeto

Modo: $ARGUMENTS (se o seu ambiente não substituir essa variável, use a mensagem do usuário).

Esta skill é a ponte entre o repositório e os agentes. As outras skills do toolkit produzem documentos para pessoas; o setup produz o que **o agente precisa saber em toda sessão** — stack, versões, comandos reais, convenções, restrições, permissões — e o `docs/sdd/config.yml`, que as próprias skills (`code-review`, `spike`, `sdd-execute`, `sdd-review`…) leem para se calibrar.

O roteiro de análise está em `references/base-prompt.md`. **Leia-o antes de começar**: ele define como descobrir as stacks, ler versões, usar os perfis e formular recomendações para qualquer linguagem.

## Compromissos

- **Só roda quando pedido.** Nenhuma outra skill gera estes arquivos; elas apenas sugerem `/sdd-setup`.
- **Nunca destrói.** Conteúdo escrito por pessoas é preservado. Atualização só acontece dentro dos blocos `<!-- myaitoolkit:start -->` / `<!-- myaitoolkit:end -->`. Diff sempre antes de gravar.
- **Evidência, não suposição.** Versões vêm de lockfiles e arquivos de versão; comandos, de arquivos reais (`bin/`, `Rakefile`, `Makefile`, `package.json`…). O que não existe vira `TODO` explícito.
- **Raiz e módulo não se repetem.** Módulo nunca copia stack nem comandos globais.
- **Enxuto.** O `AGENTS.md` é lido em toda sessão: cada linha custa contexto. Detalhe longo fica num documento referenciado.
- **Multi-IA.** `AGENTS.md` é a fonte única (Codex, Cursor e outros o leem direto); o `CLAUDE.md` importa o `AGENTS.md` e acrescenta só o que é do Claude Code. Adicionar outra IA = seguir `${CLAUDE_PLUGIN_ROOT}/adapters/README.md`.
- **O kit nunca commita.** Nenhuma skill do MyAiToolKit roda `git commit`. Ao fim de um trabalho, a skill entrega a mensagem de commit pronta, em texto, no padrão que o usuário escolheu aqui. Quem commita, e quando, é o usuário.

## Modos

| Entrada | O que faz |
| --- | --- |
| *(vazio)* | Setup completo: análise + `config.yml` + `stack-report.md` + `AGENTS.md` + arquivos das IAs escolhidas + permissões |
| `audit` | Somente leitura: compara o que está documentado com o repositório e reporta divergências. Não grava nada |
| `module <nome>` | Contexto de um módulo específico (`AGENTS.md` do módulo + `CLAUDE.md` se houver Claude) |
| `permissions` | Só as permissões (Claude e/ou Codex) |
| `refresh` | Reanalisa versões, comandos e padrões novos registrados em reviews; atualiza o que já existe, dentro dos marcadores |

Sem argumento e com setup já existente, pergunte se a intenção é `refresh` ou refazer tudo.

## Fluxo

### 1. Analisar (roteiro em `references/base-prompt.md`)

1. Descobrir **todas** as stacks do repositório (inclusive monorepo e frontends separados).
2. Ler as **versões reais** de cada uma.
3. Carregar `${CLAUDE_PLUGIN_ROOT}/stacks/<stack>/profile.md` de cada stack — ou `stacks/_generic/profile.md`.
4. Extrair comandos reais, ferramentas de teste, lint e segurança, convenções visíveis no código.
5. Ler os artefatos SDD, se existirem: arquitetura e ADRs (restrições, convenções obrigatórias), PRDs (só nomes, para o índice), planos, e as "Notas ao processo" dos reviews — a fonte mais valiosa de **padrões novos** ainda não documentados.
6. Formular recomendações conforme as versões (recursos disponíveis, versões perto do fim de suporte, ferramentas que a versão já traz e o projeto não usa).

### 2. Perguntar — uma única rodada

Junte numa só rodada o que a análise não resolveu. Se o ambiente tem uma ferramenta de pergunta com opções (no Claude Code, `AskUserQuestion`), use-a: cada pergunta com suas opções e a resposta livre ("Outro"). Sem ela, numere as opções no texto e aceite resposta livre.

> Antes de gravar, preciso de algumas escolhas:
>
> 1. **IAs usadas no projeto:** Claude Code, Codex, ambas, outra? *(define quais arquivos gero)*
> 2. **Idioma dos artefatos:** pt-BR (padrão) ou en?
> 3. **Padrão das mensagens de commit:** Conventional Commits, ID da tarefa primeiro, ou outro que você escreve? *(detalhes abaixo)*
> 4. **Migrations:** com confirmação a cada uma, ou bloqueadas (só manualmente)?
> 5. **Branch base para code review:** detectei `<main|master|develop>` — confirma?
> 6. **Revisão cruzada nos reviews:** desligada, automática ou sempre? *(custo e detalhes abaixo)*

Inclua só as perguntas que a análise não respondeu sozinha. As exceções são a 3 e a 6: cada uma é feita sempre que o `config.yml` ainda não tem a chave correspondente (`git.commit`, `review.cross_check`), mesmo que a análise tenha achado um padrão de commit (nesse caso, a opção correspondente vem marcada como recomendada). Em monorepo, acrescente: um `docs/sdd/` por sistema ou um único na raiz?

#### Padrão das mensagens de commit

O kit não commita (ver Compromissos), então a pergunta é só sobre **o formato da mensagem** que as skills vão entregar em texto. Ofereça sempre duas opções e a resposta livre:

| Opção | Formato | Exemplo |
| --- | --- | --- |
| **Conventional Commits** | `<tipo>(<escopo>): <descrição> (T-XX)`, com os tipos `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `perf`, `build`, `ci` e `style` | `feat(agenda): bloqueia horário já ocupado (T-03)` |
| **ID da tarefa primeiro** | `T-XX: <descrição>` | `T-03: agenda consulta com bloqueio de horário` |
| **Outro** | o usuário escreve o padrão — ex.: `bug(agenda): …`, `[PROJ-123] …`, gitmoji | — |

- **Recomendação:** marque como recomendada a opção que bate com o que o projeto já usa (evidências em "Convenção de commit", na Etapa 3 do `base-prompt.md`). Sem evidência, recomende Conventional Commits.
- **"Outro":** monte um exemplo no padrão escrito e confirme antes de gravar ("Ficaria assim: `bug(agenda): bloqueia horário já ocupado (T-03)` — certo?"). Se o padrão não tem lugar para a `T-XX`, pergunte onde ela entra: no fim do assunto, no rodapé (`Refs: T-XX`) ou em lugar nenhum.
- **Idioma:** a descrição segue `project.language`; tipos, escopos e IDs não se traduzem.
- **Onde fica:** `docs/sdd/config.yml` → `git.commit` (lido por `commit-message`, `sdd-review` e `code-review`; regras de formato em `${CLAUDE_PLUGIN_ROOT}/templates/commit-message.md`) e uma linha em Convenções do `AGENTS.md`, para que qualquer IA siga o mesmo padrão.

#### Revisão cruzada nos reviews

Pergunta sobre o `/sdd-review` e o `/code-review`: depois de avaliar, eles podem entregar os apontamentos graves a um **segundo agente, independente**, que tenta derrubá-los lendo o código — sem ver o raciocínio de quem apontou. Apontamento refutado com evidência sai do relatório; `Bloqueante` ou `Q1` refutado nunca sai sozinho: vira uma pergunta ao usuário. Os agentes não conversam entre si e há uma única verificação por review. Regras completas em `${CLAUDE_PLUGIN_ROOT}/templates/cross-check.md`.

Ofereça três opções e a resposta livre:

| Opção | Valor gravado | Efeito |
| --- | --- | --- |
| **Desligada** (recomendada) | `never` | Review como sempre foi |
| **Automática** | `auto` | Verifica só quando o review achou um `Bloqueante` ou um `Q1` |
| **Sempre** | `always` | Verifica os `Bloqueante` e `Importante` de todo review |
| **Outro** | — | O usuário descreve; converta para um dos três valores e confirme antes de gravar |

- **Diga o custo na própria pergunta:** um review com verificação gasta cerca de 1,5 a 2 vezes os tokens de um review simples.
- **Diga que dá para mudar a cada chamada:** `/sdd-review T-04 cruzada` liga naquele review; `simples` desliga.
- **Ambiente:** a verificação precisa que a IA abra um agente novo (no Claude Code, o agente do plugin `review-verifier`; no Codex, um subagente). Sem isso, o review avisa "indisponível" e segue simples — a escolha continua valendo para quando houver suporte.
- **Onde fica:** `docs/sdd/config.yml` → `review.cross_check`.

### 3. Detectar divergências (quando já existe configuração)

Compare o que está documentado com o que a análise encontrou e mostre **antes** de propor mudanças:

| Divergência | Exemplo | Peso |
| --- | --- | --- |
| Versão desatualizada | `AGENTS.md` diz Rails 7.1, `Gemfile.lock` tem 8.0.1 | Alta — o agente vai usar API errada |
| Comando quebrado | documentado `bin/rails test`, mas o projeto usa RSpec | Alta |
| Convenção contrariada por ADR novo | `AGENTS.md` permite callbacks, ADR-009 proibiu | Alta |
| Segredo sem bloqueio | apareceu `config/master.key` ou `.env` sem regra de deny | **Alta** |
| Stack nova sem cobertura | entrou um frontend em `web/` sem perfil nem permissões | Média |
| Link morto | índice aponta para PRD que não existe | Média |
| Padrão novo não documentado | três reviews citam o mesmo padrão | Média |
| Padrão de commit ausente ou contrariado | `config.yml` sem `git.commit`, ou os commits recentes seguem outro formato | Média — pergunte (passo 2) |
| Revisão cruzada não configurada | `config.yml` sem `review.cross_check` (setup anterior à 0.4.0) | Baixa — pergunte (passo 2, pergunta 6) |
| Commit liberado ao agente | configuração antiga com `permissions.claude.git_commit: allow` ou `Bash(git commit *)` em `allow` | Média — o kit não commita mais; proponha `ask` e deixe a decisão com o time |
| Módulo novo sem contexto | engine criada depois do último setup | Baixa |
| Permissão para comando que sumiu | `allow` com script removido | Baixa |

No modo `audit`, esta tabela é o resultado final — nada é gravado.

### 4. Gerar ou mesclar

Arquivos e modelos:

| Arquivo | Quando | Modelo |
| --- | --- | --- |
| `docs/sdd/config.yml` | sempre | `references/config-schema.md` |
| `docs/sdd/stack-report.md` | setup completo e `refresh` | `references/stack-report-template.md` |
| `AGENTS.md` (raiz) | sempre | `references/agents-md-template.md` |
| `CLAUDE.md` (raiz) | se Claude Code estiver entre as IAs | `references/claude-md-template.md` |
| `AGENTS.md` / `CLAUDE.md` de módulo | modo `module` | `references/module-template.md` |
| `.claude/settings.json` | Claude Code + modo completo ou `permissions` | `references/permission-principles.md` + `stacks/<stack>/permissions.md` |
| `.codex/config.toml` e `.codex/rules/myaitoolkit.rules` | Codex + modo completo ou `permissions` | idem, seção Codex |

**Arquivo novo:** mostre o conteúdo proposto e peça confirmação.

**Arquivo existente:**
1. dentro dos marcadores `myaitoolkit:start/end` — pode atualizar;
2. fora deles — é das pessoas: nunca alterar nem remover;
3. arquivo **sem marcadores** (escrito à mão antes do setup): **não sobrescrever**. Ofereça: (a) mostrar o diff sugerido para a pessoa aplicar, (b) colocar marcadores em volta das seções que ela indicar, ou (c) acrescentar uma seção nova no fim. A escolha é dela;
4. sempre mostrar o diff, mesmo em mudança pequena.

Mantenha a ordem canônica de seções (Resumo, Stack, Comandos, Convenções, Restrições, Documentação, Como trabalhar). Se o arquivo existente tem outra ordem escrita por uma pessoa, a ordem dela prevalece.

**Permissões existentes:** mesclar por comparação de listas — manter tudo o que já existe, acrescentar só o que falta, **nunca remover** regra do usuário. Regra em balde diferente do sugerido (ex.: `git push` em `allow`) não é alterada: aponte no relatório e deixe a decisão com o time.

**`.gitignore`:** confirme que `.claude/settings.local.json` está ignorado. Se não estiver, mostre a linha para o usuário adicionar — sem editar por conta própria.

**Repositório sem código:** não há stack para detectar. Gere o `config.yml` com o que foi informado, o `AGENTS.md` com as seções do pipeline e, nas permissões, apenas o bloqueio universal de segredos e as regras de git. Avise que vale rodar `/sdd-setup refresh` depois do primeiro scaffolding — é o momento mais importante do setup.

### 5. Relatar

- arquivos criados, atualizados e intocados;
- stacks e versões encontradas, com a origem de cada versão;
- recomendações principais do `stack-report.md` (até 5);
- padrão de commit escolhido, com um exemplo de mensagem;
- revisão cruzada escolhida (`never`, `auto` ou `always`);
- divergências encontradas e o que foi feito com cada uma;
- lacunas deixadas como `TODO` e o motivo;
- módulos detectados que não receberam contexto (e por quê);
- regras de permissão adicionadas por balde, e divergências mantidas.

## Contexto de módulo

Projetos modulares (engines, packwerk, pastas por domínio, apps de monorepo) podem ganhar contexto por módulo — **sempre por escolha do usuário**:

- detecte os módulos e liste; o usuário escolhe quais;
- nunca gere para todos de uma vez;
- módulo que ficaria com menos de ~15 linhas úteis: recomende **não** criar;
- módulo nunca repete stack nem comandos globais — só responsabilidade, domínio, fronteiras, convenções que **divergem** da raiz e comandos exclusivos.

Divisão entre raiz e módulo:

| Seção | Raiz | Módulo |
| --- | --- | --- |
| Resumo | O produto em 2–4 linhas | A responsabilidade do módulo em 1–2 linhas |
| Stack | Completa, com versões | Nunca — vem da raiz |
| Comandos | Globais | Só os exclusivos do módulo |
| Convenções | Do projeto | Só as que divergem |
| Restrições | Do projeto | Fronteiras: do que pode e não pode depender |
| Documentação | Índice do `docs/sdd/` | ADRs e PRDs que tocam o módulo |
| Domínio | — | Entidades e agregados principais |

## O que nunca vai para o contexto do agente

- Conteúdo copiado dos artefatos (aponte o caminho; não duplique regras, ADRs ou critérios)
- Histórico e changelog (é papel do git e do plano)
- Conselho genérico ("escreva código limpo") — o agente já sabe
- Detalhe que muda toda semana
- **Credenciais, tokens, connection strings — nunca.** Se encontrar algum num arquivo existente, alerte o usuário em vez de propagar
- Afrouxamento do bloqueio de segredos a pedido sem explicar o risco específico (ex.: `config/master.key` decifra todas as credenciais do Rails)

## Quem sugere esta skill (e quando)

| Momento | Quem sugere |
| --- | --- |
| Proposta de arquitetura concluída | `sdd-architect` |
| Review sem contexto do agente ou com padrão novo | `sdd-review` |
| Code review sem `config.yml` | `code-review` |
| Spike sem `config.yml` | `spike` |
| Projeto com artefatos SDD e sem contexto, módulo novo, código sem permissões | `sdd-next` |
| Primeiro scaffolding concluído | `sdd-next` |

Sempre convite, nunca etapa obrigatória.

## Material de apoio

- `references/base-prompt.md` — **roteiro de análise multilinguagem** (leitura obrigatória)
- `references/config-schema.md` — estrutura do `docs/sdd/config.yml`
- `references/stack-report-template.md` — relatório de stack e versões
- `references/agents-md-template.md` — `AGENTS.md` da raiz
- `references/claude-md-template.md` — `CLAUDE.md` que importa o `AGENTS.md`
- `references/module-template.md` — contexto de módulo
- `references/permission-principles.md` — mecânica de permissões do Claude Code e do Codex, bloqueio universal, git e Docker
- `${CLAUDE_PLUGIN_ROOT}/stacks/README.md` — contrato dos perfis de stack
- `${CLAUDE_PLUGIN_ROOT}/stacks/rails/profile.md` — perfil de referência
- `${CLAUDE_PLUGIN_ROOT}/templates/stack-detection.md` — cascata de detecção usada pelas demais skills
- `${CLAUDE_PLUGIN_ROOT}/templates/cross-check.md` — revisão cruzada (pergunta 6)
