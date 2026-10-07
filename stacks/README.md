# stacks/ — perfis por linguagem

As skills do MyAiToolKit não trazem tecnologia embutida: o que muda de uma linguagem para outra mora aqui, em **perfis de stack**. O `sdd-setup` usa o perfil para analisar o projeto; `code-review` e `sdd-review` usam os checklists; o `spike` usa as heurísticas de esforço; `sdd-execute` usa a convenção de nome de teste.

## Stacks disponíveis

| Pasta | Situação | O que tem |
| --- | --- | --- |
| `rails/` | **referência — completa** | perfil, permissões, checklists de review e de segurança, convenção de teste, heurísticas de spike e exemplos completos (pipeline, tarefas, C4) |
| `node/` | perfil | perfil + permissões |
| `python/` | perfil | perfil + permissões |
| `dotnet/` | perfil | perfil + permissões |
| `go/` | perfil | perfil + permissões |
| `java/` | perfil | perfil + permissões |
| `php/` | perfil | perfil + permissões |
| `_generic/` | fallback | perfil para qualquer stack sem pasta própria |

Rails é a stack de referência porque é a mais usada por quem mantém o projeto — e, por isso, é onde cada recurso do toolkit foi calibrado primeiro. As demais seguem o mesmo contrato e podem crescer até o nível do Rails.

## Contrato do `profile.md`

Todo perfil tem estas seções, nesta ordem e com estes títulos — o `sdd-setup` procura por eles:

1. **Sinais de detecção** — arquivos e conteúdos que identificam a stack; como distinguir variantes (ex.: Rails completo × API-only; Ruby sem Rails).
2. **Fontes de versão** — de onde ler cada versão, em ordem de confiança, e quais versões importam (runtime, framework, banco, ferramentas).
3. **Orientações por versão** — o que cada versão relevante traz ou exige, o que muda na forma de escrever código, e onde conferir o suporte oficial. **Sem datas inventadas**: quando não houver certeza, aponte a página oficial.
4. **Comandos** — onde extrair build, rodar, testes, lint, segurança, migrations; quais costumam existir; armadilhas.
5. **Testes** — frameworks, organização de pastas e a **convenção de nome de teste** para `CA-XX` (o padrão que vai para `testing.ca_naming` no `config.yml`).
6. **Qualidade e segurança** — ferramentas consagradas de lint, análise estática, auditoria de dependências.
7. **Convenções a observar no código** — padrões que, quando presentes, viram linhas da seção Convenções do `AGENTS.md`.
8. **Segredos** — arquivos próprios da stack que entram no bloqueio, além do universal.
9. **Arquivos complementares** — quais dos arquivos opcionais abaixo existem para a stack.
10. **Referências oficiais** — links para política de manutenção, guias de upgrade e documentação.

## Arquivos complementares

| Arquivo | Usado por | Conteúdo |
| --- | --- | --- |
| `permissions.md` | `sdd-setup` | Receita `allow` / `ask` / `deny` no formato do Claude Code (o setup traduz para o Codex) |
| `review-checklist.md` | `sdd-review`, `code-review` | Perguntas de qualidade específicas da stack, com severidade sugerida |
| `security-checklist.md` | `sdd-review`, `code-review` | Verificações de segurança da stack, aplicadas ao diff |
| `test-conventions.md` | `sdd-execute`, `sdd-review`, `sdd-trace` | Como o `CA-XX` aparece em cada framework de teste da stack |
| `spike-heuristics.md` | `spike`, `sdd-plan` | Faixas de esforço típicas por tipo de trabalho na stack |
| `pipeline-example.md` | todas as skills de fase | Uma demanda completa atravessando o pipeline, com código real |
| `task-examples.md` | `sdd-plan` | As tarefas de referência do planner com código real |
| `c4-component-example.md` | `sdd-architect` | Diagrama C4 nível 3 com componentes reais da stack |

Sem um arquivo complementar, a skill usa o equivalente genérico (`_generic/profile.md` ou o material agnóstico da própria skill) e avisa isso no artefato.

## Como adicionar uma stack

1. Crie `stacks/<nome>/profile.md` seguindo as dez seções acima. Use `rails/profile.md` como modelo de profundidade.
2. Crie `permissions.md` com a receita da stack, aplicando os princípios de `skills/sdd-setup/references/permission-principles.md` (inclusive a conferência de sombra entre listas).
3. Acrescente a linha da stack na tabela de detecção de `templates/stack-detection.md`.
4. Opcional, mas muito útil: `review-checklist.md`, `security-checklist.md`, `test-conventions.md` e `spike-heuristics.md`.
5. Para exemplos (`pipeline-example.md`, `task-examples.md`), mantenha o **mesmo domínio e os mesmos IDs** do exemplo Rails (agendamento de consultas, `RN-XX`, `CA-XX`, `T-XX`, `ADR-XXX`) — só o código muda. Assim dá para comparar stacks lado a lado.
6. Rode `scripts/check.sh` e atualize a tabela "Stacks disponíveis" acima e o `CHANGELOG.md`.

## Regras para quem escreve perfis

- **Versões e datas precisam de fonte.** Na dúvida, aponte a página oficial em vez de afirmar.
- **Comandos de exemplo são exemplos.** O setup só usa o que existir no repositório analisado; o perfil diz onde procurar.
- **Opinião não é convenção.** O perfil descreve o que é consagrado na comunidade; a escolha final é do projeto (o `AGENTS.md` ganha do perfil em caso de conflito).
