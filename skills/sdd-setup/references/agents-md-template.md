# Modelo — `AGENTS.md` da raiz

O `AGENTS.md` é o contexto **canônico** do projeto para agentes de IA: Codex, Cursor e outras ferramentas o leem diretamente, e o `CLAUDE.md` gerado pelo setup apenas o importa. Uma fonte só evita que cada IA receba uma versão diferente das regras.

Tamanho alvo: **60 a 120 linhas**. Passou disso, mova o detalhe para um documento e aponte o caminho.

Os marcadores `<!-- myaitoolkit:start -->` e `<!-- myaitoolkit:end -->` delimitam o que o setup pode atualizar depois. Tudo fora deles pertence às pessoas e é preservado.

> As quatro crases externas apenas delimitam o modelo; as cercas de três crases internas fazem parte do arquivo.

---

````markdown
# [Nome do projeto]

<!-- myaitoolkit:start -->

## Resumo

[2 a 4 linhas: o que o sistema faz e para quem. Comprimido da proposta de arquitetura,
se existir. Alguém novo precisa entender o propósito em 15 segundos.]

## Stack

- **Linguagem e framework:** [ex.: Ruby 3.3.5 · Rails 8.0.1 (`load_defaults 8.0`)]
- **Banco:** [ex.: PostgreSQL 16]
- **Jobs / cache / filas:** [ex.: Solid Queue, Solid Cache]
- **Frontend:** [ex.: Hotwire (Turbo + Stimulus), importmap, Tailwind]
- **Testes:** [ex.: RSpec, factory_bot, Capybara]
- **Infra:** [só o que existe — ex.: Docker Compose local, deploy com Kamal]

Detalhes e recomendações de versão: `docs/sdd/stack-report.md`.

## Comandos

[Somente comandos que existem no repositório. O que faltar fica como TODO.]

```bash
bin/setup                      # preparar o ambiente
bin/dev                        # rodar local
bundle exec rspec              # testes
bundle exec rspec path/arquivo_spec.rb   # um arquivo
bin/rubocop                    # lint
bin/brakeman --no-pager        # análise de segurança
bin/rails db:migrate           # migrations (pede confirmação)
```

## Convenções

[Só decisões do projeto que o agente não adivinharia. Uma linha cada; ADR entre
parênteses quando a convenção vier de uma decisão registrada.]

- [ex.: Regras de negócio em objetos de serviço (`app/services`); controllers só orquestram (ADR-003)]
- [ex.: Autorização com Pundit em toda action; `verify_authorized` ligado no ApplicationController]
- [ex.: Sem callbacks com efeito colateral em models; efeitos via jobs (ADR-005)]
- [ex.: Testes de cenário do PRD com o ID: `it "CA-XX: ..."` em `spec/requests` ou `spec/system`]
- [ex.: Logs estruturados; nunca dado pessoal em log (`filter_parameters` cobre cpf, email, telefone)]
- [ex.: Nesta versão do Rails, use `normalizes` e `generates_token_for` em vez de callbacks e tokens manuais]

## Restrições

[O que é imposto de fora — não é escolha do time.]

- [ex.: Dados de pacientes permanecem no Brasil (LGPD + contrato)]
- [ex.: Integração com o sistema do convênio via API existente — contrato não pode mudar]

## Documentação do pipeline

- **Configuração do toolkit:** `docs/sdd/config.yml`
- **Arquitetura:** `docs/sdd/architecture/proposta-arquitetural.md`
- **Decisões (ADRs):** `docs/sdd/architecture/adrs/`
- **Requisitos (PRDs):** `docs/sdd/prds/` — regras `RN-XX`, cenários `CA-XX`
- **Interface (SPEC-UI):** `docs/sdd/prototype/` — telas `UI-XX`
- **Planos:** `docs/sdd/plans/` — tarefas `T-XX`
- **Reviews:** `docs/sdd/reviews/` — apontamentos `R-XX`

## Como trabalhar neste projeto

Este projeto usa o pipeline SDD do MyAiToolKit. Antes de implementar:

1. Procure o plano em `docs/sdd/plans/PLAN-XXX-*.md`.
2. Pegue a primeira tarefa `Status: Pendente` cujas dependências (`Depende de:`) estejam todas `Concluído`.
3. Leia a tarefa inteira, incluindo `Implementa:`, `Valida:`, `Decisões base:` e `Telas:`.
4. Abra o que ela referencia: `RN-XX` e `CA-XX` no PRD do cabeçalho do plano; `ADR-XXX` em `docs/sdd/architecture/adrs/`; `UI-XX` na SPEC-UI.
5. Respeite os pontos de validação humana do plano.
6. Escreva os testes com o `CA-XX` no nome, no formato acima.
7. Ao terminar, atualize o `Status:` da tarefa (`Pendente` → `Em andamento` → `Concluído`) e o histórico do plano. Tarefa concluída que continua `Pendente` some para quem retomar o trabalho.
8. Uma tarefa por vez, sempre seguida de review.

Com o MyAiToolKit instalado: `sdd-execute` executa uma tarefa, `sdd-review T-XX` revisa,
`code-review` faz review avulso e `spike` analisa o esforço de um card. Sem o toolkit,
os passos acima continuam valendo — eles não dependem de ferramenta.

<!-- myaitoolkit:end -->

<!-- Daqui para baixo o conteúdo é mantido pelo time; o /sdd-setup não altera. -->
````

---

## Como preencher

**Resumo.** Comprima, não copie. O sumário da proposta tem uma página; aqui cabem quatro linhas sobre *o que* o sistema faz.

**Stack.** Só o que existe hoje, com a versão real. Previsto e ainda não implementado fica de fora ou marcado: `Redis (previsto no ADR-007, ainda não implementado)`.

**Comandos.** A seção mais frágil. Tudo vem de arquivo real (`bin/`, scripts, CI). Em monorepo, agrupe por aplicação com comentário e diga de que pasta rodar. Sem comando para uma categoria, use `<!-- TODO: ... -->` em vez de inventar.

**Convenções.** O teste para incluir: *o agente erraria sem saber disso?* Entra: onde fica a regra de negócio, padrão de autorização, padrão de erro, formato de nome de teste, fronteiras entre módulos, idiomas específicos da versão. Não entra: "escreva testes", "use bons nomes", "siga SOLID".

**Restrições × convenções.** Convenção é escolha do time e pode mudar internamente; restrição vem de fora (cliente, lei, contrato). Separar ajuda o agente a saber o que é negociável.

**Documentação.** Só caminhos. Não descreva cada PRD — isso muda toda semana e vira link morto. Muitos PRDs? Aponte a pasta.

**Como trabalhar.** É quase igual em todo projeto que usa o pipeline, e é o que permite ao agente navegar os artefatos sozinho. Mantenha.
