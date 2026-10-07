# Adaptador — Claude Code

No Claude Code, o próprio repositório é o plugin (`.claude-plugin/plugin.json`) e também o marketplace (`.claude-plugin/marketplace.json`). Não há passo de conversão: as skills em `skills/` são carregadas como estão, e `${CLAUDE_PLUGIN_ROOT}` é resolvido pelo Claude Code.

## Instalação

**Uso normal (persistente):**

```bash
git clone <url-do-repositorio> MyAiToolKit
claude plugin marketplace add ./MyAiToolKit
claude plugin install my-ai-toolkit@my-ai-toolkit
```

O `install` usa `plugin@marketplace`: o plugin se chama `my-ai-toolkit` e o marketplace também. Para atualizar depois de um `git pull`:

```bash
claude plugin marketplace update my-ai-toolkit
```

**Desenvolvendo o próprio toolkit:**

```bash
claude --plugin-dir ./MyAiToolKit
```

Carrega o plugin direto da pasta, sem instalar — ideal para editar uma skill e testar na hora. Vale só para aquela sessão.

Depois de instalar, rode `/plugin` dentro do Claude Code para conferir que as skills foram carregadas.

## Como chamar

Cada skill vira um comando com o nome dela:

| Comando | Também disponível como |
| --- | --- |
| `/sdd-start`, `/sdd-next`, `/sdd-trace` | `/my-ai-toolkit:sdd-start` etc. |
| `/sdd-architect`, `/sdd-prd`, `/sdd-prototype`, `/sdd-plan` | idem |
| `/sdd-execute`, `/sdd-review` | idem |
| `/sdd-setup` | idem |
| `/spike` | `/my-ai-toolkit:spike` |
| `/my-ai-toolkit:code-review` | `/code-review` quando não houver conflito |

O Claude Code tem um `/code-review` nativo. Quando os dois existem, use o nome com prefixo (`/my-ai-toolkit:code-review`) para chamar o do toolkit.

## Invocação automática

As skills de fase (`sdd-architect`, `sdd-prd`, `sdd-prototype`, `sdd-plan`, `sdd-review`) e as de consulta (`sdd-next`, `sdd-trace`, `spike`, `code-review`) podem ser carregadas pelo modelo quando o pedido casa com a descrição. Duas são travadas com `disable-model-invocation: true` e só rodam quando você chama:

- **`sdd-execute`** — escreve código e altera o plano;
- **`sdd-setup`** — escreve `AGENTS.md`, `CLAUDE.md`, permissões e configuração.

## Permissões pré-aprovadas

Cada skill declara `allowed-tools` com leitura (`Read`, `Glob`, `Grep`) e edição **apenas** da pasta do artefato que ela produz (ex.: `Edit(docs/sdd/prds/**)` no `sdd-prd`). Comandos de shell **não** são pré-aprovados em nenhuma skill: rodar testes, git ou ferramentas pede confirmação, a menos que o `.claude/settings.json` do projeto (gerado pelo `sdd-setup`) os libere.

## Contexto do projeto

O `sdd-setup` gera `AGENTS.md` (conteúdo) e `CLAUDE.md` com `@AGENTS.md` (importação) — o Claude Code lê o `CLAUDE.md` e, por ele, o `AGENTS.md`.
