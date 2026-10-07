# Mensagem de commit — regras compartilhadas

Usado por `commit-message`, `sdd-review` (mensagem entregue quando a tarefa é aprovada) e `sdd-execute` (só para explicar onde a mensagem vem). O padrão do projeto fica em `docs/sdd/config.yml` → `git.commit` (estrutura em `skills/sdd-setup/references/config-schema.md`).

**O MyAiToolKit nunca commita.** Nenhuma skill roda `git commit`, `git add`, `git commit --amend` ou `git push`. A mensagem é entregue **em texto**, num bloco de código, e o usuário decide se e quando usar.

## 1. Qual padrão usar

| `git.commit.convention` | Formato |
| --- | --- |
| `conventional` | `<tipo>(<escopo>): <descrição>` + a `T-XX` onde `task_id` mandar |
| `task-id` | `T-XX: <descrição>` |
| `custom` | `format`, com `example` como referência do tom e da posição de cada parte |
| *(sem `git.commit`)* | dentro do plano, `T-XX: <descrição>`; fora dele, Conventional Commits sem `T-XX`. Avise que o `/sdd-setup` grava o padrão do projeto |

Posição da `T-XX` (`task_id`):
- `subject` — no fim do assunto, entre parênteses: `feat(agenda): bloqueia horário já ocupado (T-03)`. No `task-id`, ela abre o assunto.
- `footer` — rodapé `Refs: T-03`, depois de uma linha em branco.
- `none` — não entra.

Mudança fora do plano (sem `T-XX` identificável): a mensagem sai sem ela. **Nunca invente uma `T-XX`.**

## 2. Tipo (Conventional Commits)

Escolha pelo **efeito** da mudança, não pelos arquivos tocados:

| Tipo | Quando |
| --- | --- |
| `feat` | comportamento novo que alguém percebe (usuário, outra API, outro módulo) |
| `fix` | corrige um comportamento errado |
| `refactor` | muda a estrutura sem mudar o comportamento |
| `perf` | melhora desempenho sem mudar o comportamento |
| `test` | só testes |
| `docs` | só documentação (inclui `docs/sdd/`) |
| `build` | dependências, build, empacotamento |
| `ci` | pipelines de integração e deploy |
| `style` | formatação sem efeito em código (espaços, lint automático) |
| `chore` | manutenção que não cabe acima (configuração de ferramenta, scripts internos) |

Uma tarefa do plano costuma ser `feat` ou `fix`, e seus testes vão **no mesmo commit**, sem virar um `test` separado. Em `custom`, use os tipos que o padrão do usuário define (ex.: `bug` no lugar de `fix`).

**Escopo:** o módulo, domínio ou área tocada (`agenda`, `auth`, `api`), em minúsculas. Prefira os nomes de `stacks[].modules` do `config.yml` ou a pasta de domínio. Se a mudança atravessa várias áreas, omita o escopo: `feat: …`.

**Quebra de compatibilidade:** se a mudança quebra quem usa (API pública, contrato, migration irreversível), acrescente `!` depois do tipo/escopo (`feat(api)!: …`) e um rodapé `BREAKING CHANGE: <o que muda para quem usa>`.

## 3. Texto

- **Assunto:** até ~72 caracteres, sem ponto final, dizendo o que a mudança faz. Em pt-BR, verbo na 3ª pessoa do presente ("bloqueia", "adiciona", "corrige"); em en, imperativo ("block", "add", "fix"). O idioma segue `project.language`; tipos, escopos e IDs não se traduzem.
- **Corpo** (opcional, depois de uma linha em branco): o **porquê** e o que não é óbvio no diff — regra atendida, decisão tomada, efeito colateral. Não repita o diff linha a linha. Até ~72 caracteres por linha; tópicos com `-` funcionam bem.
- **Rodapé** (opcional): `Refs: T-XX`, `BREAKING CHANGE: …`, ou referências de card que o padrão do usuário pedir.
- Corpo só quando acrescenta algo: uma mudança pequena e clara fica só no assunto.

## 4. Um commit ou vários

Se o diff mistura mudanças independentes (ex.: a funcionalidade da tarefa + uma reformatação geral + um ajuste de CI), **sugira dividir**: uma mensagem por grupo, com os arquivos de cada um. É só sugestão, em texto — quem separa e commita é o usuário (ex.: com `git add -p`).

## 5. Formato da entrega

````markdown
**Mensagem de commit** (Conventional Commits — padrão do `config.yml`):

```text
feat(agenda): bloqueia horário já ocupado (T-03)

Dois pedidos para o mesmo horário: o segundo recebe 409 e a agenda
continua com uma consulta só (RN-04, ADR-002).
```

Tipo `feat`: a agenda passa a recusar um pedido que antes aceitava.
````

Depois do bloco, uma linha justificando o tipo. Nada de comando pronto para commitar no lugar do usuário: no máximo, lembre que dá para colar a mensagem no editor do `git commit`.
