# Contribuindo com o MyAiToolKit

Obrigado pelo interesse! O MyAiToolKit é um projeto de faculdade e open-source, e cresce com contribuições de quem usa.

## Formas de contribuir

- **Perfil de stack** — a contribuição mais valiosa. Siga o contrato em [`stacks/README.md`](stacks/README.md). Começar por `profile.md` + `permissions.md` já ajuda muito; checklists, heurísticas de spike e exemplos vêm depois.
- **Adaptador para outra IA** — siga [`adapters/README.md`](adapters/README.md).
- **Melhorias nas skills** — fluxos, perguntas, modelos.
- **Correções em [REFERENCES.md](REFERENCES.md)** — atribuição errada ou faltando.
- **Relatos de uso** — issues contando onde uma skill errou, perguntou demais ou de menos.

## Regras para escrever skills

1. **Uma pasta por skill** em `skills/<nome>/`, com `SKILL.md`. O `name` do frontmatter é igual ao nome da pasta.
2. **`description` diz quando usar e quando não usar** — é por ela que as IAs escolhem a skill.
3. **SKILL.md curta**, conduzindo o fluxo; modelos e catálogos vão em `references/`.
4. **Portabilidade** (ver `adapters/README.md`): arquivos compartilhados como `${CLAUDE_PLUGIN_ROOT}/...`, `$ARGUMENTS` com o aviso de fallback, nada que dependa de ferramenta exclusiva de uma IA no fluxo principal (recursos opcionais podem depender de uma capacidade do ambiente, nas condições de `adapters/README.md`, regra 4).
5. **Português (PT-BR)** nos textos. Termos técnicos consagrados podem ficar em inglês.
6. **Modelos dentro de cerca de quatro crases** (````` ````markdown `````) quando contiverem blocos de código — senão a primeira cerca interna fecha o modelo.
7. **Nada inventado:** exemplos de comandos, versões e datas precisam de fonte ou devem apontar para a documentação oficial.

## Antes de abrir o PR

```bash
bash scripts/check.sh
```

O script confere frontmatter das skills e dos agentes do plugin (`agents/`), caminhos `${CLAUDE_PLUGIN_ROOT}/...`, links relativos e cercas de modelos. O CI roda o mesmo script.

Teste a mudança de verdade:

- **Claude Code:** `claude --plugin-dir .` e chame a skill alterada.
- **Codex:** `./adapters/codex/install.sh --scope repo --target <pasta-de-teste>` e chame com `$nome-da-skill`.

Atualize o [CHANGELOG.md](CHANGELOG.md) na seção "Não lançado".

## Versionamento

[SemVer](https://semver.org/lang/pt-BR/): **patch** para correções de texto e de regras, **minor** para skills, perfis ou adaptadores novos, **major** para mudanças incompatíveis nos artefatos gerados (IDs, campos do plano, estrutura de `docs/sdd/`, chaves do `config.yml`). A versão fica em `.claude-plugin/plugin.json` e `.claude-plugin/marketplace.json`.

## Conduta

Seja respeitoso, objetivo e generoso com quem está começando — é um projeto acadêmico, e aprender faz parte.
