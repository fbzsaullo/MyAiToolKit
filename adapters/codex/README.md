# Adaptador — Codex

O Codex lê skills no mesmo formato `SKILL.md`, procurando em `.agents/skills/` (do diretório atual até a raiz do repositório) e em `~/.agents/skills/` (usuário). O instalador deste adaptador copia as skills para lá e resolve os caminhos compartilhados.

## O que o instalador faz

1. Copia o toolkit (skills, `templates/`, `stacks/`, `adapters/`, `REFERENCES.md`) para `<raiz>/.agents/myaitoolkit-shared/`.
2. Copia cada skill para `<raiz>/.agents/skills/<nome>/`.
3. Troca `${CLAUDE_PLUGIN_ROOT}` pelo caminho absoluto de `myaitoolkit-shared` em todos os `.md` copiados.
4. Grava `<raiz>/.agents/myaitoolkit-shared/.installed` com a versão e a lista de skills — usado para atualizar e remover sem tocar em skills de outras origens.

`<raiz>` depende do escopo:

| Escopo | `<raiz>` | Quando usar |
| --- | --- | --- |
| `user` | `~` (sua pasta pessoal) | disponível em todos os projetos |
| `repo` | a pasta do projeto (padrão: diretório atual, ou `--target`) | versionar o toolkit junto com o projeto do time |

## Uso

Bash (Linux, macOS, Git Bash no Windows):

```bash
./adapters/codex/install.sh --scope user
./adapters/codex/install.sh --scope repo --target ../meu-projeto
./adapters/codex/install.sh --scope user --uninstall
./adapters/codex/install.sh --scope repo --dry-run      # mostra o que faria
```

PowerShell (Windows):

```powershell
./adapters/codex/install.ps1 -Scope user
./adapters/codex/install.ps1 -Scope repo -Target ..\meu-projeto
./adapters/codex/install.ps1 -Scope user -Uninstall
```

Rodar de novo atualiza a instalação (substitui as skills do toolkit e mantém as demais).

## Como chamar no Codex

Pelo nome com `$`: `$sdd-start`, `$sdd-plan`, `$sdd-execute`, `$sdd-review`, `$sdd-setup`, `$spike`, `$code-review` etc. O Codex também escolhe uma skill sozinho quando o pedido casa com a descrição dela.

Observações:
- O Codex ignora `allowed-tools`, `argument-hint` e `disable-model-invocation`. As skills `sdd-execute` e `sdd-setup` dizem no próprio texto que só devem rodar a pedido explícito.
- `$ARGUMENTS` não é substituído: as skills usam a sua mensagem como entrada.
- O comando nativo `/review` do Codex continua existindo; o review do toolkit é o `$code-review`.
- **Revisão cruzada** (`review.cross_check` ou a palavra `cruzada`): o `$sdd-review` e o `$code-review` pedem ao Codex um subagente só de leitura e lhe entregam o pedido de `templates/cross-check.md`. O subagente herda a sandbox da sessão. A pasta `agents/` do toolkit é do Claude Code e não é instalada. Se a sua versão do Codex não abrir subagentes, o review avisa "indisponível neste ambiente" e segue simples — confira `codex --version` e a documentação de subagentes do Codex.

## Contexto e permissões

- **Contexto:** o Codex lê `AGENTS.md` nativamente. O `$sdd-setup` gera esse arquivo.
- **Permissões:** com Codex entre as IAs do projeto, o `$sdd-setup` gera `.codex/config.toml` (perfil de permissões de arquivos e rede) e `.codex/rules/myaitoolkit.rules` (comandos liberados, com aprovação ou proibidos). A configuração de projeto só é carregada quando o projeto é confiável para o Codex. Detalhes e sintaxe em `skills/sdd-setup/references/permission-principles.md`.

## Se algo não funcionar

O Codex evolui rápido. Se uma skill não aparecer ou uma regra não for aceita:
1. confira a versão (`codex --version`) e a documentação oficial de skills e de permissões;
2. verifique se a pasta `.agents/skills/<nome>/SKILL.md` existe e se o `name` do frontmatter é igual ao nome da pasta;
3. abra uma issue no repositório com a versão do Codex e o erro.
