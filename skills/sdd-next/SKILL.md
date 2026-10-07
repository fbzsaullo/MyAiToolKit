---
name: sdd-next
description: Olha os artefatos do pipeline SDD do projeto (arquitetura, ADRs, PRDs, SPEC-UI, planos, reviews, contexto do agente) e diz em que ponto o projeto está e qual é a próxima ação — priorizando bloqueios, depois reviews pendentes, depois execução e por fim novas fases. Use quando o usuário perguntar "o que eu faço agora?", "onde paramos?", "qual o próximo passo?", "status do pipeline" ou chamar /sdd-next. Só sugere; não executa nada sem confirmação.
allowed-tools: Read, Glob, Grep
---

# sdd-next — qual é o próximo passo

Descobre onde o projeto está no pipeline SDD do MyAiToolKit e sugere **uma** próxima ação.

## 1. Encontrar os artefatos

Procure primeiro nos caminhos padrão e, se não achar, na raiz e em `docs/`:

- Configuração: `docs/sdd/config.yml`
- Arquitetura: `docs/sdd/architecture/proposta-arquitetural.md` e `docs/sdd/architecture/adrs/ADR-*.md`
- PRDs: `docs/sdd/prds/PRD-*.md`
- SPEC-UI: `docs/sdd/prototype/SPEC-UI-*.md` (opcional — só em PRD com interface)
- Planos: `docs/sdd/plans/PLAN-*.md`
- Reviews: `docs/sdd/reviews/REVIEW-*.md`
- Contexto do agente: `AGENTS.md`, `CLAUDE.md` (raiz e módulos), `.claude/settings.json`

## 2. Avaliar cada um

- **Arquitetura** — há ADRs? Quantos `Aceito` × `Proposto`? Diagramas C4? Restou `[A DEFINIR]` ou `⚠️ Premissa`?
- **PRD** — tem `RN` e `CA`? Qual o status do documento (`Rascunho` / `Em revisão` / `Aprovado`)?
- **SPEC-UI** — existe para os PRDs com interface? Lacunas da seção 8 ainda abertas? *(Ausência só importa quando o PRD tem telas.)*
- **Plano** — quantas tarefas? Quantas `Concluído`, `Em andamento`, `Bloqueado`, `Cancelado`? Canceladas não entram na conta do que falta.
- **Reviews** — quantos? Quantos com recomendação `Bloqueado`? Há tarefa `Concluído` sem review?
- **Contexto do agente** — existe `docs/sdd/config.yml`? `AGENTS.md`/`CLAUDE.md` com stack, comandos e convenções? Há `<!-- TODO -->` pendente? Módulo novo sem contexto? Projeto com código e sem `.claude/settings.json` (quando usa Claude Code)?

## 3. Resumir numa tabela curta

```
| Artefato                 | Situação            | Próximo passo natural            |
|--------------------------|---------------------|----------------------------------|
| Arquitetura (5 ADRs)     | 4 aceitos, 1 proposto | Decidir ADR-005                |
| PRD-001 Agendamento      | Aprovado            | —                                |
| PLAN-001 Agendamento     | 5/11 concluídas     | Executar T-06                    |
| Reviews                  | 3 ok, 1 bloqueado   | Resolver R-02 (REVIEW-T-04-2026-10-09) |
| Contexto do agente       | sem config.yml      | /sdd-setup                       |
```

## 4. Sugerir UMA ação

Em ordem de prioridade — pare na primeira que se aplicar. Não apresente um cardápio de opções.

**1. Destravar**
- Review com recomendação `Bloqueado` e sem round seguinte: "A T-04 tem review bloqueado — R-01, R-03 (REVIEW-T-04-2026-10-09). Quer olhar os pontos para corrigir?" Sempre cite `R-XX` com o nome do relatório.
- Tarefa `Bloqueado` no plano: diga o que a bloqueia e como destravar.

**2. Validar o que foi entregue**
- Tarefa `Concluído` sem review: "A T-04 e a T-05 estão concluídas mas sem review. Quer rodar `/sdd-review T-04` antes de seguir?"

**3. Continuar a execução**
- Tarefa `Em andamento`: é trabalho interrompido e vem antes de qualquer outra. "A T-06 ficou em andamento na última sessão. Retomar com `/sdd-execute T-06`?"
- Próxima tarefa `Pendente` cujas dependências estão todas `Concluído`: "A próxima tarefa livre do PLAN-001 é a T-07. Executar com `/sdd-execute T-07`?"

**4. Avançar o pipeline**
- PRD **com interface**, aprovado, sem SPEC-UI e sem plano: "O PRD-001 tem telas e ainda não tem especificação de interface. Quer rodar `/sdd-prototype` antes, ou ir direto para o plano com `sdd-plan`?" — ofereça os dois caminhos, nunca bloqueie.
- PRD aprovado sem plano: "Vamos montar o plano do PRD-001 com `sdd-plan`?"
- Arquitetura sem PRD: "A arquitetura está pronta. Qual funcionalidade vira o primeiro PRD? Posso seguir com `sdd-prd`."
- Nada encontrado: "Não achei artefatos do pipeline. Quer começar com `/sdd-start`?"

**Sugestão paralela — contexto do agente.** Quando couber, acrescente **uma linha** junto da sugestão principal, sem substituí-la:
- sem `docs/sdd/config.yml` ou sem `AGENTS.md`: "(Aproveitando: `/sdd-setup` analisaria a stack e deixaria os próximos reviews mais completos.)"
- `TODO` pendente no contexto: "(O `AGENTS.md` tem comandos marcados como TODO — agora que há código, `/sdd-setup refresh` resolve.)"
- módulo novo sem contexto: "(Apareceu o módulo `X` — `/sdd-setup module X`, se fizer sentido.)"
- reviews citando padrão novo: "(Os últimos reviews registraram um padrão ainda não documentado — `/sdd-setup refresh` captura.)"
- código sem permissões do Claude Code: "(Não há `.claude/settings.json` — `/sdd-setup permissions` gera um calibrado pela stack.)"

São convites de uma linha: não repita se o usuário ignorar e nunca gere os arquivos por conta própria.

## 5. Antes de sugerir, aponte inconsistências

- PRD cita ADR que não existe em `adrs/`
- Plano cita CA que não está no PRD
- Tarefa `Concluído` sem commit no histórico — confira com `git log --oneline --grep "T-XX"`: achou, mostre o hash e diga que o próximo `/sdd-review` preenche; não achou, a tarefa ainda não foi commitada (`/commit-message T-XX` dá a mensagem)
- **Tarefa `Concluído` com review `Bloqueado` em aberto** — contradição grave
- **Status da tarefa diferente do histórico do plano**
- **Status com grafia fora do vocabulário** — a tarefa fica invisível; mostre a grafia encontrada
- **Tarefa apoiada em ADR que não está `Aceito`**

## Não fazer

- Rodar qualquer skill sem confirmação — esta skill sugere, não executa.
- Listar todos os arquivos do projeto; só os do pipeline.
- Inventar status: sem informação clara, diga "situação indeterminada".
- Pular review de tarefa concluída — review faz parte do pipeline.
- Cobrar SPEC-UI de PRD sem interface.
- Criar ou editar `AGENTS.md`, `CLAUDE.md` ou `config.yml` — apenas sugerir `/sdd-setup`.
