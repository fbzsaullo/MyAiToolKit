# Adaptadores — levando o MyAiToolKit para cada IA

O conteúdo do toolkit é escrito **uma vez**, em formato portátil, e cada IA recebe esse conteúdo por um adaptador. Hoje existem dois:

| IA | Pasta | Como instala | Situação |
| --- | --- | --- | --- |
| Claude Code | `claude-code/` | o repositório **é** o plugin e o marketplace | foco principal |
| Codex | `codex/` | script copia as skills para `.agents/skills/` | suportado |

## O formato portátil

Tudo o que o toolkit faz está em **skills** no padrão `SKILL.md` (pasta por skill, frontmatter YAML + instruções em markdown + `references/` carregadas sob demanda). Esse formato é lido nativamente pelo Claude Code e pelo Codex, e vem sendo adotado por outras ferramentas.

Regras que mantêm as skills portáteis:

1. **Frontmatter mínimo comum:** `name` (igual ao nome da pasta) e `description` (quando usar e quando não usar). Campos extras do Claude Code — `allowed-tools`, `argument-hint`, `disable-model-invocation` — são ignorados por quem não os conhece.
2. **Argumentos:** o texto usa `$ARGUMENTS` com o aviso "se o seu ambiente não substituir essa variável, use a mensagem do usuário". O Claude Code substitui; os demais usam a mensagem.
3. **Arquivos compartilhados** (`templates/`, `stacks/`, outros) são citados como `${CLAUDE_PLUGIN_ROOT}/<caminho>`. O Claude Code resolve a variável; os demais adaptadores **reescrevem** a variável para o caminho absoluto da instalação.
4. **Nada de ferramenta exclusiva no fluxo principal.** Instruções falam em "leia o arquivo", "rode o comando (com confirmação)", não em nomes de ferramentas de uma IA específica.
   **Exceção — recursos opcionais.** Um recurso desligado por padrão pode depender de uma capacidade do ambiente (a revisão cruzada precisa abrir um agente independente) desde que: (a) o texto descreva a capacidade e cite o jeito de cada IA entre parênteses; (b) o que o agente recebe esteja num arquivo compartilhado, igual para todas as IAs (`templates/cross-check.md`); (c) sem a capacidade, a skill avise e siga no modo normal — **nunca simule**.
5. **Contexto do projeto em `AGENTS.md`.** O `sdd-setup` gera o `AGENTS.md` como fonte única; cada IA recebe um arquivo próprio só quando precisa (o `CLAUDE.md` apenas importa o `AGENTS.md`).

## Contrato de um adaptador

Para suportar uma IA nova, crie `adapters/<ia>/` com um `README.md` respondendo:

| Pergunta | Exemplo (Codex) |
| --- | --- |
| **Onde as skills ficam?** | `.agents/skills/<nome>/SKILL.md` (projeto) ou `~/.agents/skills/` (usuário) |
| **Como o usuário chama uma skill?** | `$sdd-start`, ou pelo seletor de skills; também por descrição |
| **Onde ficam os arquivos compartilhados?** | `.agents/myaitoolkit-shared/` |
| **O que acontece com `${CLAUDE_PLUGIN_ROOT}`?** | o instalador troca pelo caminho absoluto da pasta compartilhada |
| **Qual arquivo de contexto a IA lê?** | `AGENTS.md` (nativo) |
| **Como a IA abre um agente independente?** (revisão cruzada) | subagente pedido pela skill, só de leitura; herda a sandbox da sessão |
| **Como são as permissões?** | `.codex/config.toml` (perfil de sandbox) + `.codex/rules/*.rules` |
| **Como instalar, atualizar e remover?** | `install.sh` / `install.ps1` com `--scope`, reexecução idempotente e `--uninstall` |

E entregue:

1. **Instalador** idempotente (bash e PowerShell), com remoção.
2. **Tradução de permissões**, se a IA tiver um formato próprio: acrescente uma seção em `skills/sdd-setup/references/permission-principles.md` e a tabela de tradução a partir do formato do Claude Code.
3. **Arquivo de contexto**, se a IA não ler `AGENTS.md`: um modelo em `skills/sdd-setup/references/<ia>-context-template.md` que **importe ou aponte** para o `AGENTS.md`, sem duplicá-lo.
4. **Opção na pergunta de IAs do `sdd-setup`** e o valor correspondente em `project.ais` (`config-schema.md`).
5. **Linha nova** na tabela do início deste arquivo e no `README.md` principal.
6. Rode `scripts/check.sh`.

## Exemplos de próximos adaptadores

- **Cursor:** lê `AGENTS.md`; regras de projeto em `.cursor/rules/`. Um adaptador poderia gerar uma regra que aponta para as skills instaladas.
- **Gemini CLI:** lê `GEMINI.md`; o setup geraria um `GEMINI.md` que referencia o `AGENTS.md`.
- **GitHub Copilot:** lê `.github/copilot-instructions.md` e `AGENTS.md`.

Antes de implementar, confira a documentação atual de cada ferramenta — formatos de configuração mudam com frequência.
