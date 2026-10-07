# Branch base e diff

Como descobrir contra o que comparar e como montar o diff sem mexer no trabalho local do usuário.

## 1. Candidatas

Rode (são comandos de leitura):

```bash
git rev-parse --abbrev-ref HEAD                      # branch atual
git symbolic-ref --short refs/remotes/origin/HEAD    # padrão do remoto, ex.: origin/main
git branch -a --list main master develop 'release/*' 'origin/main' 'origin/master' 'origin/develop' 'origin/release/*'
```

Se `origin/HEAD` não existir (clone antigo ou remoto sem HEAD), `git remote show origin` mostra a linha `HEAD branch:` — mas acessa a rede; peça confirmação.

Monte a lista de candidatas, sem repetição, nesta ordem de sugestão:

1. `code_review.default_base_branch` do `docs/sdd/config.yml` (escolha registrada do time)
2. padrão do remoto (`origin/HEAD`)
3. `main` / `master` (a que existir)
4. `develop`
5. `release/*` mais recente

**Pergunte sempre**, mesmo com uma só candidata — times usam fluxos diferentes (Git Flow compara com `develop`; hotfix compara com `main`/`release`). Mostre a sugestão e as alternativas encontradas. Se o usuário responder uma branch que não existe localmente, procure em `origin/`.

## 2. Atualizar referências (opcional)

A base local pode estar atrasada. Ofereça:

> Quer que eu atualize as referências do remoto (`git fetch origin`) antes de comparar? Não altera seus arquivos.

Com `fetch`, compare com `origin/<base>`; sem ele, avise que a comparação usa a cópia local.

## 3. O alvo

| Modo | Alvo |
| --- | --- |
| Branch atual | `HEAD` — e avise se há alterações **não commitadas** (`git status --porcelain`): elas ficam fora de `base...HEAD`. Pergunte se devem entrar (`git diff <base>` sem os três pontos inclui a área de trabalho) |
| Outra branch | `origin/<branch>` (após `fetch`) ou a branch local — **sem checkout** |
| Pull Request (GitHub) | `gh pr view <n> --json headRefName,baseRefName,title,body,author,commits,files` para os metadados; `gh pr diff <n>` para o diff. A base do PR é sugerida como resposta da pergunta do passo 1 |
| Patch | ler o arquivo informado |

Nunca troque de branch nem faça `stash`/`checkout` por conta própria: o usuário pode ter trabalho em andamento.

## 4. Montar o diff

```bash
git merge-base <base> <alvo>                 # ponto de separação
git diff --stat <base>...<alvo>              # tamanho
git diff <base>...<alvo>                     # conteúdo (três pontos = desde o merge-base)
git log --oneline <base>..<alvo>             # commits do trabalho
```

Os **três pontos** importam: `base...alvo` mostra só o que o alvo trouxe desde que se separou da base, ignorando o que entrou na base depois. Dois pontos (`base..alvo`) no `git diff` compararia as pontas e misturaria mudanças alheias.

Para ler um arquivo como está no alvo sem checkout: `git show <alvo>:<caminho>`.

## 5. Antes de revisar

Mostre ao usuário:

```
Comparando origin/feature/parcelamento com main (merge-base a1b2c3d)
12 commits · 18 arquivos · +642 −87
```

- Diff vazio → nada a revisar; confira se a base está certa.
- Diff gigante (> ~1.500 linhas ou ~40 arquivos) → ofereça recortar por pasta, por commit ou por tipo de arquivo.
- Arquivos gerados (lockfiles, `schema.rb`, builds, snapshots) → revise só a coerência (ex.: `schema.rb` bate com as migrations), não linha a linha.

## 6. Registrar a escolha

Se o usuário escolher uma base diferente de `code_review.default_base_branch` repetidas vezes, sugira atualizar o `config.yml` via `/sdd-setup refresh` — sem editar por conta própria.
