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

## Agentes do plugin

A pasta `agents/` traz os subagentes que o plugin registra. Hoje há um:

| Agente | Nome no Claude Code | Para quê |
| --- | --- | --- |
| `agents/review-verifier.md` | `my-ai-toolkit:review-verifier` | Verificador da revisão cruzada do `/sdd-review` e do `/code-review` (`templates/cross-check.md`) |

Ele só tem `Read`, `Grep` e `Glob` (não edita, não roda comandos, não abre outros agentes), usa o mesmo modelo da sessão (`model: inherit`) e para em 12 passos (`maxTurns`). Só é chamado quando a revisão cruzada está ligada — `review.cross_check` no `config.yml` ou a palavra `cruzada` na chamada. Confira com `/agents` depois de instalar.

Agentes de plugin ignoram `permissionMode`, `hooks` e `mcpServers` (documentação de subagentes do Claude Code); o verificador não precisa de nenhum deles.

## Permissões pré-aprovadas

Cada skill declara `allowed-tools` com leitura (`Read`, `Glob`, `Grep`) e edição da pasta do artefato que ela produz (ex.: `Edit(docs/sdd/prds/**)` no `sdd-prd`). Comandos de shell **não** são pré-aprovados em nenhuma skill: rodar testes, git ou ferramentas pede confirmação, a menos que o `.claude/settings.json` do projeto (gerado pelo `sdd-setup`) os libere.

**`allowed-tools` pré-aprova; não restringe.** Pela documentação do Claude Code, o campo libera as ferramentas listadas sem pedir confirmação, mas todas as outras continuam disponíveis, sujeitas às permissões do projeto. A liberação também acaba na próxima mensagem do usuário: numa skill que pergunta algo no meio do fluxo, o que vem depois da resposta volta a seguir as permissões normais. Na prática:

- uma edição fora da pasta do artefato **não é impedida** pelo frontmatter — ela pede confirmação. Quem garante que as skills só escrevem onde devem é o texto de cada skill, e quem garante que o agente não commita é a regra `ask` de `git commit` que o `sdd-setup` grava no `.claude/settings.json`;
- para tirar uma ferramenta de uso de verdade, o Claude Code oferece o campo `disallowed-tools` e as regras `deny` das permissões. O toolkit ainda não usa nenhum dos dois nas skills.

## Contexto do projeto

O `sdd-setup` gera `AGENTS.md` (conteúdo) e `CLAUDE.md` com `@AGENTS.md` (importação) — o Claude Code lê o `CLAUDE.md` e, por ele, o `AGENTS.md`.
