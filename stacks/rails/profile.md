# Perfil de stack — Ruby on Rails

Stack de referência do MyAiToolKit. Segue o contrato de `stacks/README.md`.

---

## 1. Sinais de detecção

| Sinal | Significa |
| --- | --- |
| `Gemfile` com `gem "rails"` (ou `railties`) + `config/application.rb` | Aplicação Rails |
| `config.api_only = true` em `config/application.rb` | Rails **API-only** — sem views; a fase de interface normalmente não se aplica |
| `Gemfile` sem Rails, com `*.gemspec` | Gem/biblioteca Ruby → use `_generic` + as partes de teste e qualidade deste perfil |
| `Gemfile` sem Rails, com `config.ru` + Sinatra/Hanami/Roda | Ruby web sem Rails → `_generic` |
| `engines/*/` ou `components/*/` com `*.gemspec` | Engines internas → candidatas a módulos |
| `package.yml` na raiz e em subpastas (`packwerk`) | Modularização com packwerk → cada pack é um módulo |
| `config/importmap.rb` | Frontend com importmap |
| `package.json` com `esbuild`, `bun`, `vite_ruby`, `@hotwired/*`, `tailwindcss` | Node como **auxiliar** de build (não é segunda aplicação) |
| `app/javascript` com React/Vue em app separado (`frontend/`, `client/`) | Possível segunda stack principal → perfil `node` |

---

## 2. Fontes de versão

Em ordem de confiança:

| O quê | Onde | Observação |
| --- | --- | --- |
| Rails | `Gemfile.lock` → linha `rails (x.y.z)` | versão realmente instalada |
| Ruby | `.ruby-version`, `.tool-versions`, `mise.toml`; seção `RUBY VERSION` do `Gemfile.lock`; diretiva `ruby` no `Gemfile` | divergência entre fontes é achado |
| Nível de padrões | `config.load_defaults X.Y` em `config/application.rb` | pode estar **abaixo** da versão instalada |
| Banco | adapter em `config/database.yml`; gem (`pg`, `mysql2`, `trilogy`, `sqlite3`); imagem no `compose.yaml` | versão do servidor de produção raramente aparece no repo |
| Bundler | `BUNDLED WITH` no `Gemfile.lock` | — |
| Node (se auxiliar) | `.node-version`, `.nvmrc`, `package.json#engines` | — |
| Imagem/CI | `FROM ruby:x.y.z` no `Dockerfile`; `ruby-version` nos workflows | confirmação cruzada |

Bibliotecas que mudam a forma de escrever código e merecem entrar no `config.yml` (`libraries`): banco, jobs (`solid_queue`, `sidekiq`, `good_job`, `delayed_job`), cache (`solid_cache`, `redis`), frontend (`turbo-rails`, `stimulus-rails`, `importmap-rails`, `jsbundling-rails`, `cssbundling-rails`, `tailwindcss-rails`, `vite_ruby`, `view_component`, `phlex-rails`), autenticação (`devise`, `rodauth-rails`, gerador nativo do Rails 8), autorização (`pundit`, `action_policy`, `cancancan`), API (`jbuilder`, `alba`, `grape`), pagamentos e integrações relevantes.

---

## 3. Orientações por versão

O que cada versão traz e como isso muda o trabalho do agente. **Datas de fim de suporte não estão listadas de propósito**: confira sempre a política oficial de manutenção (links na seção 10) e registre no `stack-report.md` a situação na data da análise.

### Rails 6.1
- Zeitwerk é o carregador padrão (desde 6.0); o modo `classic` ainda existe e indica dívida de upgrade.
- Múltiplos bancos e `horizontal sharding` disponíveis.
- **Recomendação típica:** planejar upgrade — 6.1 já está fora da janela de suporte de segurança na política atual. Conferir.

### Rails 7.0
- Hotwire (Turbo + Stimulus) e importmap como padrão de frontend; `jsbundling`/`cssbundling` como alternativa.
- Somente Zeitwerk (o modo `classic` foi removido).
- Criptografia de atributos (`encrypts`) no Active Record.
- `load_async` para consultas em paralelo.
- **Agente:** usar `encrypts` para dados sensíveis em vez de criptografia manual; preferir Turbo Frames/Streams a JavaScript avulso quando o projeto usa Hotwire.

### Rails 7.1
- `Dockerfile` gerado por padrão em apps novos.
- `normalizes` (normalização de atributos), `generates_token_for` (tokens com expiração), `authenticate_by` (login resistente a timing attack).
- Chaves primárias compostas; `Rails.application.deprecators`.
- **Agente:** usar `normalizes` em vez de callbacks `before_validation` para limpar dados; `generates_token_for` em vez de tokens guardados em coluna.

### Rails 7.2
- Exige Ruby 3.1+.
- Apps novos já vêm com **RuboCop (rubocop-rails-omakase)**, **Brakeman** e workflow de **CI no GitHub Actions**; opção de devcontainer.
- `allow_browser` para exigir navegadores modernos; arquivos de PWA.
- YJIT habilitado por padrão quando o Ruby suporta.
- **Recomendação típica:** projeto em 7.2 sem `bin/rubocop`/`bin/brakeman` pode adotá-los com baixo esforço.

### Rails 8.0
- Exige Ruby 3.2+.
- **Solid Queue, Solid Cache e Solid Cable** como padrão (jobs, cache e Action Cable no banco, sem Redis).
- **Propshaft** como pipeline de assets padrão (Sprockets segue disponível).
- **Kamal 2** + **Thruster** para deploy.
- **Gerador de autenticação** (`bin/rails generate authentication`).
- `params.expect` para parâmetros fortes mais seguros que `require(...).permit(...)`.
- **Recomendações típicas:** projeto em 8.x mantendo Redis só para poucos jobs → avaliar Solid Queue; controllers novos → usar `params.expect`.

### Rails 8.1
- Integração contínua local (`bin/ci` com `config/ci.rb`) em apps novos.
- Continuações de jobs (Active Job Continuations) para jobs longos retomáveis.
- Relato de eventos estruturados (`Rails.event`).
- **Agente:** se `bin/ci` existir, é o comando preferido para validar antes de concluir uma tarefa.

### `load_defaults` atrasado
Se `config.load_defaults` está abaixo da versão instalada, o app roda com comportamentos antigos. Recomende o caminho oficial: arquivo `config/initializers/new_framework_defaults_X_Y.rb`, ativando uma opção por vez com testes verdes, e só então subir o `load_defaults`.

### Ruby
- YJIT (3.2+ estável; 3.3 com melhorias de desempenho) — recomendar quando o projeto não habilita e o Ruby suporta.
- Cada versão de Ruby tem janela de manutenção própria — confira em ruby-lang.org (seção 10) e reporte a situação.

---

## 4. Comandos

Onde procurar, nesta ordem: `bin/*` → `Procfile.dev` → `Rakefile`/`lib/tasks` → workflows de CI → README.

| Para quê | Costuma existir | Observação |
| --- | --- | --- |
| Preparar ambiente | `bin/setup` | pode rodar `db:prepare` — é seguro em dev, mas pergunte antes |
| Rodar local | `bin/dev` (com `Procfile.dev`) ou `bin/rails server` | `bin/dev` sobe também o build de CSS/JS |
| Testes (RSpec) | `bundle exec rspec`, `bin/rspec` | arquivo: `bundle exec rspec spec/x_spec.rb:42` |
| Testes (Minitest) | `bin/rails test`, `bin/rails test:system` | arquivo: `bin/rails test test/models/x_test.rb:42` |
| CI local (8.1+) | `bin/ci` | preferir quando existir |
| Lint | `bin/rubocop`, `bundle exec rubocop`, `bundle exec standardrb` | `-a` corrige o seguro |
| Segurança | `bin/brakeman --no-pager` | `--only-files` restringe ao diff |
| Dependências | `bundle exec bundler-audit check --update`, `bundle exec ruby_audit` | só se a gem existir |
| Carregamento | `bin/rails zeitwerk:check` | rápido; detecta erro de nome/caminho |
| Migrations | `bin/rails db:migrate`, `db:rollback`, `db:migrate:status` | `migrate`/`rollback` alteram o banco → pedir confirmação |
| Console | `bin/rails console` | interativo — o agente não deve depender dele |
| Rotas | `bin/rails routes -g <termo>` | leitura |
| Infra local | `docker compose up -d` | só se houver compose |

**Armadilhas**
- `rails` sem `bin/` pode usar outra versão instalada globalmente — prefira `bin/rails`.
- `bin/setup` e `db:prepare` podem recriar o banco de dev; `db:reset`, `db:drop`, `db:schema:load` destroem dados.
- Em projetos com `spring`, comandos podem pegar código velho: `bin/spring stop` resolve.

---

## 5. Testes

**Como identificar**
- RSpec: pasta `spec/`, gem `rspec-rails`, `.rspec`, `spec/rails_helper.rb`.
- Minitest: pasta `test/`, `test/test_helper.rb`.
- Dados: `factory_bot_rails` (`spec/factories`) ou fixtures (`test/fixtures`).
- Sistema/navegador: `capybara` + `selenium-webdriver`/`cuprite`; pasta `spec/system` ou `test/system`.
- Requisições: `spec/requests` (preferível a `spec/controllers`, que é legado).

**Convenção de nome de teste para `CA-XX`** — detalhe em `test-conventions.md`:

| Framework | Formato | `testing.ca_naming.pattern` |
| --- | --- | --- |
| RSpec | `it "CA-05: dois pacientes disputam o último horário" do` | `it "CA-XX: <descrição>"` |
| RSpec (opcional) | metadado `ca: "CA-05"` no `it`/`describe` | `ca: "CA-XX"` |
| Minitest | `test "CA-05 dois pacientes disputam o último horário" do` | `test "CA-XX <descrição>"` |

`testing.ca_naming.grep`: `CA-[0-9]{2}`.

**Onde cada tipo de cenário costuma ser provado**
- Regra pura → spec de model/serviço.
- Cenário ponta a ponta sem interface → spec de requisição.
- Cenário com tela → spec de sistema (só os críticos; o resto em requisição).
- Concorrência → teste com threads e `ActiveRecord::Base.connection_pool` adequado, ou teste de integração no banco real (sem `use_transactional_fixtures` naquele teste).

---

## 6. Qualidade e segurança

| Ferramenta | Para quê | Sinal no projeto |
| --- | --- | --- |
| RuboCop (+ `rubocop-rails`, `rubocop-rspec`, `rubocop-rails-omakase`) | estilo e problemas comuns | `.rubocop.yml`, `bin/rubocop` |
| Standard (`standardrb`) | alternativa sem configuração | `.standard.yml` |
| Brakeman | análise estática de segurança | `bin/brakeman`, gem `brakeman` |
| bundler-audit / ruby_audit | dependências com vulnerabilidade | gems no grupo de dev |
| strong_migrations | migrations perigosas em produção | gem `strong_migrations` |
| Bullet / Prosopite | N+1 em desenvolvimento/teste | gem `bullet`/`prosopite` |
| SimpleCov | cobertura | `spec/spec_helper.rb` com `SimpleCov.start` |
| erb_lint / herb | lint de views | `.erb-lint.yml` |

Recomendação de ausência (para o `stack-report.md`): Brakeman e auditoria de dependências são baratos e de alto valor; `strong_migrations` vale em bancos grandes.

Checklists usados no review: `review-checklist.md` e `security-checklist.md`.

---

## 7. Convenções a observar no código

Quando presentes, viram linhas da seção Convenções do `AGENTS.md`:

- **Onde fica a regra de negócio:** objetos de serviço (`app/services`), interactors, *form objects*, concerns, ou "models gordos". Descubra pelo que já existe e registre.
- **Autorização:** Pundit (`app/policies`, `authorize`), Action Policy, CanCanCan — e se há `verify_authorized`/`after_action` garantindo o uso.
- **Autenticação:** Devise, gerador nativo do Rails 8 (`app/models/session.rb`, `Authentication` concern), Rodauth.
- **Controllers:** REST puro (só as 7 actions) ou actions customizadas; uso de `params.expect` (8.0+) ou `require/permit`.
- **Callbacks:** permitidos ou evitados em models (frequente decisão de time).
- **Consultas:** scopes, *query objects* (`app/queries`), SQL direto.
- **Views:** ERB com partials, ViewComponent (`app/components`), Phlex; uso de Turbo Frames/Streams; Stimulus controllers.
- **Jobs:** idempotência, filas nomeadas, `retry_on`/`discard_on`.
- **API:** serializadores (Jbuilder, Alba, ActiveModel::Serializers), versionamento (`/api/v1`).
- **Modularização:** engines ou packwerk e suas regras de dependência.
- **Logs:** `config.filter_parameters` cobrindo dados pessoais; logs estruturados (`lograge`, `rails_semantic_logger`).
- **Testes:** RSpec × Minitest, factories × fixtures, onde ficam os testes de cenário.

---

## 8. Segredos

Além do bloqueio universal (`permission-principles.md`):

- `config/master.key` — decifra `config/credentials.yml.enc`. **Nunca** ler.
- `config/credentials/*.key` — chaves por ambiente.
- `.kamal/secrets` — segredos de deploy (pode conter valores ou comandos que os buscam).
- `config/database.yml` com senha literal (em vez de `ENV`) → alertar o usuário.
- `storage/` e `log/` podem conter dados de usuários — não precisam de bloqueio, mas não devem ir para o contexto.

---

## 9. Arquivos complementares

| Arquivo | Existe |
| --- | --- |
| `permissions.md` | ✅ |
| `review-checklist.md` | ✅ |
| `security-checklist.md` | ✅ |
| `test-conventions.md` | ✅ |
| `spike-heuristics.md` | ✅ |
| `pipeline-example.md` | ✅ |
| `task-examples.md` | ✅ |
| `c4-component-example.md` | ✅ |

---

## 10. Referências oficiais

- Política de manutenção do Rails: https://rubyonrails.org/maintenance
- Guia de upgrade: https://guides.rubyonrails.org/upgrading_ruby_on_rails.html
- Notas de versão: https://guides.rubyonrails.org (seção "Release Notes")
- Versões e manutenção do Ruby: https://www.ruby-lang.org/en/downloads/branches/
- Guia de segurança do Rails: https://guides.rubyonrails.org/security.html
- Brakeman: https://brakemanscanner.org
