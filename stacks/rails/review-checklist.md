# Checklist de review — Ruby on Rails

Perguntas específicas de Rails para o eixo de **qualidade do código** do `sdd-review` e do `code-review`. Aplique só às linhas do diff. Convenções declaradas no `AGENTS.md` do projeto ganham deste checklist em caso de conflito.

Severidade sugerida entre parênteses; ajuste com justificativa.

## Active Record e banco

- [ ] **N+1:** listas que acessam associação dentro de loop usam `includes`/`preload`/`eager_load`? (Importante; Bloqueante em tela de alto tráfego)
- [ ] **Consulta em view ou helper:** a view dispara consulta que deveria vir pronta do controller? (Importante)
- [ ] **Lote grande:** iteração sobre muitos registros usa `find_each`/`in_batches` em vez de `.all.each`? (Importante)
- [ ] **Contagem:** `size`/`exists?` em vez de `count` em loop, `any?` em relação já carregada? (Sugestão)
- [ ] **Validação × restrição:** regra de unicidade/obrigatoriedade crítica tem **também** índice único ou `NOT NULL` no banco? Validação sozinha perde para concorrência. (Importante; Bloqueante se a RN depende disso)
- [ ] **Transação:** operações que precisam ser atômicas estão em `transaction`? Efeitos externos (e-mail, job, API) ficam **fora** da transação ou em `after_commit`? (Importante)
- [ ] **Bloqueio:** disputa por recurso usa `lock`/`with_lock` ou bloqueio otimista (`lock_version`) conforme o ADR? (conforme ADR — Bloqueante se divergir)
- [ ] **Callbacks:** callbacks com efeito colateral (enviar e-mail, chamar API) em model? Respeitam a convenção do projeto? (Importante)
- [ ] **`update_column(s)`/`update_all`/`delete_all`:** usados conscientemente (pulam validações e callbacks)? (Importante)
- [ ] **Enum:** valores explícitos (`enum :situacao, { pendente: 0, ... }`) para não depender da ordem? (Importante)

## Migrations

- [ ] Reversível (`change` com operações reversíveis, ou `up`/`down`)? (Importante)
- [ ] Índice para toda chave estrangeira nova e para colunas usadas em busca/unicidade? (Importante)
- [ ] Tabela grande: índice com `algorithm: :concurrently` + `disable_ddl_transaction!` (PostgreSQL)? Coluna com default em tabela grande avaliada? (Importante; Bloqueante em tabela muito grande)
- [ ] Remoção de coluna em duas etapas (`ignored_columns` antes, remoção depois)? (Importante)
- [ ] Migration sem lógica de negócio nem uso de models da aplicação (que podem mudar)? Backfill pesado em job/rake separado? (Importante)
- [ ] `schema.rb`/`structure.sql` atualizado junto? (Importante)

## Controllers e rotas

- [ ] Controller fino: regra de negócio no lugar que o projeto definiu (model, serviço)? (Importante)
- [ ] Parâmetros fortes com `params.expect` (8.0+) ou `require/permit` — nada de `permit!`? (Bloqueante para `permit!` com entrada do usuário)
- [ ] Respostas com status corretos (`:unprocessable_entity` em erro de validação para o Turbo re-renderizar, `:see_other` após `DELETE`/redirect com Turbo)? (Importante)
- [ ] Rotas REST (`resources`) em vez de rotas avulsas, quando o projeto segue REST? (Sugestão)
- [ ] `before_action` de autenticação/autorização cobrindo as actions novas (ver checklist de segurança)? (Bloqueante)

## Views, Hotwire e frontend

- [ ] Partial/componente existente reaproveitado em vez de duplicado? (Importante)
- [ ] Turbo Frames/Streams com `id`s estáveis (`dom_id`) e resposta coerente para requisições Turbo e não Turbo? (Importante)
- [ ] Formulário com erro devolve status 422 e mantém os dados digitados? (Bloqueante se a SPEC-UI pede)
- [ ] Stimulus: controller pequeno, `data-*-target`/`value` em vez de seletores frágeis? (Sugestão)
- [ ] Textos visíveis via I18n quando o projeto é internacionalizado? (Importante)
- [ ] Nenhuma lógica de negócio na view; *presenters*/helpers quando a view precisa formatar? (Importante)

## Jobs

- [ ] Job idempotente (rodar duas vezes não duplica efeito)? (Importante)
- [ ] Recebe IDs/GlobalID, não objetos inteiros serializados de forma frágil? (Importante)
- [ ] `retry_on`/`discard_on` coerentes com o tipo de erro? (Importante)
- [ ] Enfileirado após o commit (`after_commit`, ou `perform_later` fora da transação)? (Importante)
- [ ] Fila nomeada conforme a convenção do projeto? (Sugestão)

## Ruby em geral

- [ ] Sem `puts`, `pp`, `binding.irb`, `binding.pry`, `debugger` esquecidos? (Importante)
- [ ] `rescue` específico — nada de `rescue => e` engolindo tudo sem log? (Importante)
- [ ] Objetos de serviço com interface consistente com o projeto (`.call`, retorno de resultado)? (Importante)
- [ ] Constantes em vez de números/strings mágicos? (Sugestão)
- [ ] Métodos curtos, nomes que dizem o que fazem; sem *monkey patch* novo sem ADR? (Sugestão / Importante para monkey patch)
- [ ] Código carrega pelo Zeitwerk (nome do arquivo ↔ constante)? (Bloqueante se quebra o boot — `bin/rails zeitwerk:check`)

## Testes (complementa o eixo 4)

- [ ] Specs de requisição em vez de specs de controller para comportamento HTTP? (Sugestão)
- [ ] Factories mínimas (sem criar meio banco por teste); `build`/`build_stubbed` quando não precisa persistir? (Sugestão)
- [ ] Testes de sistema apenas nos fluxos críticos? (Sugestão)
- [ ] Sem `sleep` para esperar Turbo/JS — usar as esperas do Capybara? (Importante)
- [ ] Tempo controlado com `travel_to`/`freeze_time` em regras de prazo (ex.: antecedência de 2h)? (Importante)
- [ ] `CA-XX` no nome dos testes de cenário (`test-conventions.md`)? (Importante)

## Ferramentas (com confirmação do usuário, só nos arquivos do diff)

- `bin/rubocop <arquivos>` — alertas novos entram como evidência (sem repetir o que é só formatação).
- `bin/rails zeitwerk:check` — falha de carregamento é Bloqueante.
- Testes relacionados aos arquivos alterados (`spec/` correspondente).
