# Modelo — `CLAUDE.md` da raiz

Gerado apenas quando Claude Code está entre as IAs do projeto (`project.ais` no `config.yml`).

O Claude Code lê o `CLAUDE.md`, não o `AGENTS.md`. Em vez de duplicar o conteúdo — o que garantiria divergência em poucas semanas — o `CLAUDE.md` **importa** o `AGENTS.md` com a sintaxe `@caminho` e acrescenta apenas o que é exclusivo do Claude Code.

Tamanho alvo: **10 a 30 linhas**. Se crescer, provavelmente há conteúdo que deveria estar no `AGENTS.md`.

> As quatro crases externas apenas delimitam o modelo.

---

````markdown
# [Nome do projeto]

<!-- myaitoolkit:start -->

@AGENTS.md

## Específico do Claude Code

- Permissões do projeto em `.claude/settings.json` (política do time, versionada). Ajustes pessoais vão em `.claude/settings.local.json`, que não é versionado.
- Skills do MyAiToolKit disponíveis pelo plugin: `/sdd-start`, `/sdd-next`, `/sdd-execute`, `/sdd-review`, `/sdd-trace`, `/sdd-setup`, `/spike` e `/my-ai-toolkit:code-review` (o nome com prefixo evita conflito com o `/code-review` nativo).
- Commits: as skills do MyAiToolKit não commitam; entregam a mensagem pronta no padrão do `AGENTS.md`. `git commit` e `git push` pedem confirmação.

<!-- myaitoolkit:end -->

<!-- Daqui para baixo o conteúdo é mantido pelo time; o /sdd-setup não altera. -->
````

---

## Regras

- **Nada do `AGENTS.md` se repete aqui.** Stack, comandos, convenções e restrições vivem lá.
- **Só o que é do Claude Code:** permissões, nomes dos comandos no Claude, preferências de fluxo que outras IAs não usam.
- **CLAUDE.md já existente e escrito à mão:** não sobrescreva. Ofereça (a) acrescentar a linha `@AGENTS.md` no topo, (b) mover para o `AGENTS.md` o que for comum a todas as IAs, mostrando o diff, ou (c) deixar como está e apenas gerar o `AGENTS.md`. A escolha é do usuário.
- **Módulos:** em uma pasta de módulo com `AGENTS.md` próprio, o `CLAUDE.md` do módulo também contém só `@AGENTS.md` (ver `module-template.md`).
