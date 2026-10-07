---
name: pr-description
description: Escreve o título e a descrição de um Pull Request a partir do diff da branch contra a base — o que muda e por quê, a rastreabilidade (T-XX, RN, CA, UI, ADR, card, BUG), como testar com os comandos reais do projeto, os cenários cobertos por teste, o resultado do review e os riscos de implantação — e entrega em texto, pronto para colar. Usa o modelo de PR do próprio repositório quando existe. Nunca abre, edita nem comenta PR, e nunca faz push. Use quando o usuário pedir "descrição do PR", "escreve o PR", "texto do pull request", "resumo para o PR" ou chamar /pr-description (ou $pr-description).
argument-hint: "[branch, número do PR ou T-XX — vazio = branch atual]"
allowed-tools: Read, Glob, Grep
---

# pr-description — o PR explicado, sem abrir o PR

Entrada: $ARGUMENTS (se o seu ambiente não substituir essa variável, use a mensagem do usuário).

Quem revisa um PR precisa saber, em um minuto, **o que** muda, **por que**, **como conferir** e **o que pode dar errado**. Num projeto com pipeline SDD, quase tudo isso já está escrito — no plano, no PRD, no review. Esta skill junta essas peças com o diff e entrega o texto. Abrir o PR é com o usuário.

## Limites

- **Nunca** rode `gh pr create`, `gh pr edit`, `gh pr comment`, `git push` ou qualquer comando que publique algo. Só leitura: `git`, `gh pr view`, `gh pr diff`.
- Nada inventado: comando de teste que não existe vira `TODO`; ID que não aparece nos artefatos não entra.
- Não grava arquivo. A descrição é entregue na conversa.

## Passo 1 — Alvo e base

1. **Alvo:** a branch atual, outra branch (sem checkout) ou um PR existente (`gh pr view <n> --json title,body,headRefName,baseRefName` e `gh pr diff <n>`). PR existente com descrição: pergunte se é para reescrever ou completar o que já está lá.
2. **Base:** siga `${CLAUDE_PLUGIN_ROOT}/skills/code-review/references/branch-detection.md` — candidatas a partir de `code_review.default_base_branch` do `docs/sdd/config.yml`, `origin/HEAD`, `main`/`master`, `develop`, `release/*`. **Pergunte sempre**, mostrando a sugestão.
3. **Diff:** a partir do merge-base (`git diff <base>...<alvo>`) e a lista de commits (`git log --oneline <base>..<alvo>`). Alterações não commitadas ficam fora do PR — avise se existirem.

## Passo 2 — Juntar o que já está escrito

Procure, sem perguntar o que dá para descobrir:

| Peça | Onde | Vira |
| --- | --- | --- |
| Tarefas `T-XX` | nome da branch, mensagens dos commits, plano com a tarefa recém-concluída | seção Rastreabilidade |
| Regras e cenários | `Implementa`/`Valida` das tarefas → PRD | o porquê; cenários cobertos |
| Telas e estados | `Telas:` das tarefas → SPEC-UI | lembrete de capturas de tela |
| Decisões | `Decisões base` das tarefas; ADRs novos ou alterados no diff | seção Rastreabilidade; riscos |
| Review SDD | `docs/sdd/reviews/REVIEW-T-XX-*.md` (o round mais recente) | recomendação e ressalvas em aberto |
| Code review | `docs/sdd/code-reviews/CR-<branch>-*.md` | veredito e Q1/Q2 em aberto |
| Card / bug | chave no nome da branch ou nos commits; `docs/sdd/bugs/BUG-*.md` | link do card; observado × corrigido |
| Testes | arquivos de teste no diff com `CA-XX` (ou `BUG-<CHAVE>`) no nome, no formato de `testing.ca_naming` | tabela de cenários cobertos |
| Comandos | `commands.*` do `config.yml` (`test`, `test_single`, `lint`, `migrate`…) | Como testar |
| Implantação | migrations, variáveis de ambiente novas, flags, dependências, jobs, mudanças de contrato no diff | Riscos e implantação |

Sem plano SDD nem `config.yml`, a descrição sai do diff e dos commits; diga isso numa linha e siga.

## Passo 3 — Modelo

1. **O repositório tem modelo de PR?** Procure `.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE.md`, `.github/PULL_REQUEST_TEMPLATE/*.md`, `docs/pull_request_template.md` e `pull_request_template.md` na raiz. Se existir, **ele manda**: preencha as seções dele, na ordem dele, encaixando o que juntou no Passo 2. Mais de um modelo: pergunte qual.
2. Sem modelo do repositório, use `references/pr-template.md`.

## Passo 4 — Escrever

- **Título:** curto e no padrão de `git.commit` do `config.yml` (o mesmo formato do assunto de commit, em `${CLAUDE_PLUGIN_ROOT}/templates/commit-message.md`). PR de uma tarefa: o título é o assunto do commit dela. Várias tarefas: o tema comum, com as `T-XX` no corpo.
- **Idioma:** `project.language`; IDs, comandos e caminhos não se traduzem.
- **Tamanho:** o que o revisor precisa, não o diff narrado. Diff grande: agrupe por área (dados, regra, interface, testes, configuração) com uma linha cada.
- **Como testar:** passos que alguém de fora consegue seguir — dados necessários, comandos reais, o que observar. Sem comando conhecido: `TODO`.
- **Pendências honestas:** ressalvas de review abertas, Q1/Q2 de code review ainda não resolvidos, `TODO`s do diff — entram, não somem.
- **Interface:** se o diff toca telas (`UI-XX`), deixe o lembrete de anexar capturas por estado (`UI-03.erro`), sem inventar imagem.

## Passo 5 — Entregar

Na conversa: o título num bloco, a descrição em outro (Markdown cru, pronto para colar) e, em uma linha, o que ficou como `TODO` ou pendência. Termine sem executar nada — quem abre o PR é o usuário.

## Relação com outras skills

- **`/sdd-review`** aprova a tarefa e entrega a mensagem de commit; quando a branch está pronta, `/pr-description` monta o texto do PR.
- **`/code-review`** em modo próprio lista "descrição do PR a escrever" no checklist antes do PR; esta skill é esse item.
- **`/commit-message`** escreve o commit; esta skill escreve o PR. Nenhuma das duas publica nada.
