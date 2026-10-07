---
name: commit-message
description: Escreve a mensagem de commit das alterações atuais no padrão do projeto (Conventional Commits, ID da tarefa primeiro ou o padrão definido pelo usuário no /sdd-setup) e entrega em texto — nunca roda git commit, git add nem git push. Lê o diff preparado (staged) ou, sem ele, as alterações da árvore de trabalho; acha a tarefa T-XX quando há plano SDD; escolhe tipo e escopo pelo efeito da mudança; e sugere dividir em mais de um commit quando o diff mistura assuntos. Use quando o usuário pedir "mensagem de commit", "escreve o commit", "como fica o commit disso", "sugere um commit" ou chamar /commit-message (ou $commit-message), dentro ou fora do pipeline SDD.
argument-hint: "[T-XX | arquivos ou pastas | vazio = alterações atuais]"
allowed-tools: Read, Glob, Grep
---

# commit-message — a mensagem pronta, o commit com você

Entrada: $ARGUMENTS (se o seu ambiente não substituir essa variável, use a mensagem do usuário).

O MyAiToolKit não commita. Esta skill faz a parte que dá trabalho — ler o diff, entender o efeito, achar a tarefa, acertar o padrão — e entrega a mensagem em texto. Quem commita é o usuário.

As regras de formato (tipos, escopo, assunto, corpo, rodapé, onde a `T-XX` entra) estão em `${CLAUDE_PLUGIN_ROOT}/templates/commit-message.md`. **Leia antes de escrever.**

## Limites

- **Nunca** rode `git commit`, `git add`, `git reset`, `git commit --amend`, `git push` ou qualquer comando que altere o repositório. Só leitura: `git status`, `git diff`, `git log`, `git branch`.
- **Nunca invente uma `T-XX`.** Sem tarefa identificável, a mensagem sai sem ela, e você diz isso.
- Não grava arquivo. O padrão do projeto é do `/sdd-setup`; aqui ele só é lido.

## Passo 1 — Padrão do projeto

Leia `docs/sdd/config.yml` → `git.commit` e `project.language`.

Sem `git.commit`, pergunte uma vez, com as mesmas opções do setup — Conventional Commits, ID da tarefa primeiro, ou um padrão que o usuário escreve (no Claude Code, `AskUserQuestion`; em outros ambientes, opções numeradas). Use a resposta só nesta conversa e diga, em uma linha, que o `/sdd-setup` grava o padrão para as próximas vezes.

## Passo 2 — O que vai no commit

1. Com argumento de arquivos ou pastas, olhe só esse recorte.
2. Senão, `git diff --cached`: se há algo preparado (staged), **é isso** que vai no commit — descreva só isso.
3. Nada preparado: `git diff` + os arquivos novos de `git status --porcelain`. Avise que a mensagem descreve as alterações da árvore de trabalho e que é preciso adicioná-las antes de commitar.
4. Sem alteração nenhuma: diga que não há o que commitar e pare.

Diff muito grande (mais de ~1.500 linhas): leia por partes, começando pelos arquivos de código e testes. Arquivos gerados (lockfiles, `dist/`, snapshots) só contam pelo efeito ("atualiza dependências"), nunca linha a linha.

## Passo 3 — A tarefa (`T-XX`)

Procure, nesta ordem, e pare no primeiro que achar:

1. o argumento (`/commit-message T-03`);
2. o nome da branch (`git branch --show-current`);
3. o próprio diff: o plano (`docs/sdd/plans/*.md`) mudando o `**Status:**` de uma tarefa ou ganhando uma linha no histórico;
4. uma única tarefa `Em andamento` no plano.

Se encontrar mais de uma candidata, pergunte qual. Se o padrão não usa `T-XX` (`task_id: none`), pule este passo.

## Passo 4 — Escrever

Siga `templates/commit-message.md`:
- tipo pelo **efeito** da mudança, escopo pela área tocada;
- assunto curto no idioma do projeto;
- corpo só quando o porquê não é óbvio — com tarefa do plano, a regra (`RN-XX`) ou a decisão (`ADR-XXX`) que motivou ajuda quem lê o histórico;
- diff com assuntos independentes: sugira dividir, com uma mensagem e a lista de arquivos de cada grupo.

## Passo 5 — Entregar

No formato da seção 5 do template: o bloco com a mensagem e uma linha justificando o tipo. Se dividiu, um bloco por commit, na ordem sugerida. Termine sem executar nada.

## Relação com o pipeline

- Dentro do pipeline, a mensagem da tarefa já sai no fim do `/sdd-review` quando ela é aprovada. Esta skill serve para o resto: mudanças fora do plano, correções pequenas, ajustes depois do review, ou quando o usuário quer a mensagem antes.
- Depois do commit, o hash entra no histórico do plano pelo `/sdd-review` (ou à mão).
