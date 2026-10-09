# Privacidade — MyAiToolKit

*Última atualização: 2026-10-09. [English summary below.](#english-summary)*

O MyAiToolKit é um plugin de skills (instruções em Markdown) e de um agente de verificação, executados pelo assistente de IA que você já usa — Claude Code ou Codex — **na sua máquina, dentro do seu projeto**. O plugin não tem servidor, conector, servidor MCP, telemetria nem analytics.

## O que o plugin lê

Só o que a tarefa pedida precisa, sempre no seu ambiente:

- arquivos do repositório do projeto e o histórico do git (mensagens de commit, diffs);
- documentos do pipeline em `docs/sdd/`;
- quando você pede: um Pull Request ou uma issue do **seu** repositório remoto (`gh pr view`, `gh pr diff`, `git fetch`), sempre com confirmação;
- cards e descrições que você entrega (XML, JSON ou texto), que podem trazer nomes de pessoas responsáveis.

## O que o plugin grava

Arquivos de texto **no seu repositório**, sempre mostrando o conteúdo ou o diff antes:

- relatórios e documentos em `docs/sdd/` (PRDs, planos, reviews, code reviews, spikes, bugs, matrizes);
- no `/sdd-setup`: `AGENTS.md`, `CLAUDE.md`, `.claude/settings.json`, `.codex/` e `docs/sdd/config.yml`.

Esses arquivos podem conter **dados pessoais** que já estão no seu projeto: o relatório do `/code-review` registra o nome de quem escreveu a branch ou o PR, e o de um card pode trazer o nome de responsáveis. Eles ficam onde você os versiona — o controle, o compartilhamento e a exclusão são seus.

## O que o plugin envia

**Nada** para o autor do kit nem para terceiros. O kit nunca commita, nunca faz push, nunca comenta em PR e não chama nenhum serviço externo. As únicas chamadas de rede são as leituras do seu próprio remoto listadas acima, feitas pelas suas ferramentas (`git`, `gh`) e com a sua confirmação.

## O assistente de IA

O conteúdo que as skills leem é processado pelo assistente que você usa (Claude Code, Codex ou outro), de acordo com os termos e a política de privacidade **desse serviço**. O MyAiToolKit não controla nem amplia esse tratamento.

## Retenção

O plugin não guarda nada fora do seu repositório. Não há conta, cadastro nem banco de dados do kit.

## Contato

Dúvidas ou problemas: [issues do repositório](https://github.com/fbzsaullo/MyAiToolKit/issues).

---

## English summary

MyAiToolKit is a plugin of skills (Markdown instructions) and one read-only verification agent, run by your AI assistant (Claude Code or Codex) **locally, inside your project**. It has no server, connector, MCP server, telemetry or analytics.

- **Reads:** your repository files and git history; `docs/sdd/`; on request and with confirmation, a pull request or issue from **your own** remote (`gh pr view`, `gh pr diff`, `git fetch`); cards you provide.
- **Writes:** text files **in your repository** (`docs/sdd/`, and `AGENTS.md`, `CLAUDE.md`, `.claude/settings.json`, `.codex/` during setup), always showing the content or diff first. Code-review reports record the name of the branch or PR author, and card content may include assignees' names; those files stay under your control.
- **Sends:** nothing to the kit's author or any third party. It never commits, pushes or comments on pull requests.
- **AI assistant:** content the skills read is processed by the assistant you use, under that service's own terms and privacy policy.
- **Retention:** nothing is kept outside your repository; there are no accounts or databases.
- **Contact:** [GitHub issues](https://github.com/fbzsaullo/MyAiToolKit/issues).
