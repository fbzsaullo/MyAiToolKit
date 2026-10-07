# Checklist de segurança — Ruby on Rails

Usado no eixo de **segurança** do `sdd-review` e do `code-review`. Aplique **somente às linhas do diff**. Não é auditoria completa: é a verificação mínima que toda mudança em Rails merece.

Severidade sugerida entre parênteses. Alerta de ferramenta só vira apontamento depois de confirmado no código.

## Injeção

- [ ] **SQL:** nenhuma interpolação de entrada em consulta — `where("nome = '#{params[:nome]}'")`, `order(params[:sort])`, `find_by_sql` montado com string, `pluck`/`select` com entrada. Use placeholders (`where("nome = ?", valor)`), hashes (`where(nome: valor)`) ou lista permitida para `order`. (Bloqueante)
- [ ] **`Arel.sql`/`sanitize_sql`** usados apenas sobre valores controlados pelo sistema. (Bloqueante se recebe entrada)
- [ ] **Comando de sistema:** nada de `system`, `` `...` ``, `%x()`, `exec`, `Open3` com entrada do usuário em string única; use a forma com argumentos separados e lista permitida. (Bloqueante)
- [ ] **Execução dinâmica:** `send`, `public_send`, `constantize`, `safe_constantize`, `instance_variable_get`, `eval` sobre entrada do usuário só com lista permitida explícita. (Bloqueante)
- [ ] **Caminho de arquivo:** `send_file`, `File.read`, `render file:` com parâmetro do usuário → risco de *path traversal*. (Bloqueante)
- [ ] **Desserialização:** `YAML.load`/`Marshal.load` em dado externo → usar `YAML.safe_load`/JSON. (Bloqueante)

## Saída e XSS

- [ ] Nada de `html_safe`, `raw` ou `<%==` sobre conteúdo vindo do usuário. (Bloqueante)
- [ ] `sanitize` com lista de tags permitida quando HTML do usuário é necessário. (Importante)
- [ ] `link_to` com URL do usuário: bloqueia `javascript:` (valide o esquema). (Importante)
- [ ] JSON embutido em view com `json_escape`/`to_json` seguro, sem montar `<script>` com interpolação. (Importante)

## Parâmetros e atribuição em massa

- [ ] `params.expect` (8.0+) ou `require(...).permit(...)` com lista **explícita**; nunca `permit!`. (Bloqueante)
- [ ] Campos sensíveis (`admin`, `role`, `user_id`, `account_id`, `price`, `status`) **não** vêm do formulário quando quem decide é o sistema. (Bloqueante)
- [ ] Atributos aninhados (`accepts_nested_attributes_for`) com escopo correto. (Importante)

## Autenticação e autorização

- [ ] Action nova exige autenticação (o `before_action` cobre a action? não há `skip_before_action` indevido?). (Bloqueante)
- [ ] **Autorização por registro:** o registro é buscado **pelo escopo do usuário** (`current_user.consultas.find(params[:id])`) ou passa por policy (`authorize @consulta`) — nunca `Consulta.find(params[:id])` sem verificação (IDOR). (Bloqueante)
- [ ] Pundit/Action Policy: `verify_authorized`/`verify_policy_scoped` não foi desligado na action nova; `policy_scope` em listagens. (Bloqueante)
- [ ] Senhas com `has_secure_password`/Devise; comparação de tokens com `ActiveSupport::SecurityUtils.secure_compare`; login com `authenticate_by` (7.1+). (Bloqueante)
- [ ] Tokens de uso único/expiráveis com `generates_token_for` ou equivalente — não IDs sequenciais. (Importante)
- [ ] Sessão renovada após login (`reset_session` / comportamento do gerador ou Devise). (Importante)

## CSRF, CORS e redirecionamento

- [ ] `protect_from_forgery` não desligado sem motivo; `skip_forgery_protection` só em endpoint de API com outra autenticação (token) ou webhook com verificação de assinatura. (Bloqueante)
- [ ] Webhook verifica assinatura do remetente antes de processar. (Bloqueante)
- [ ] `redirect_to params[:url]` / `redirect_back` com destino controlado (`allow_other_host: false`, lista de hosts). (Importante)
- [ ] CORS (`rack-cors`) sem `origins "*"` em endpoints autenticados. (Importante)

## Dados sensíveis e segredos

- [ ] Nenhum segredo, token ou senha no código; uso de `Rails.application.credentials` ou `ENV`. (Bloqueante)
- [ ] Campos pessoais novos (CPF, e-mail, telefone, dados de saúde) incluídos em `config.filter_parameters` e fora de logs/mensagens de erro. (Bloqueante)
- [ ] Dados muito sensíveis com `encrypts` (7.0+) quando o projeto adota essa prática. (Importante)
- [ ] Serialização de API (`as_json`, Jbuilder, serializers) expõe só os campos necessários — nada de `render json: @user` com o model inteiro. (Bloqueante se vaza campo sensível)
- [ ] Mensagens de erro para o usuário não expõem detalhes internos (stack trace, SQL). (Importante)

## Arquivos e uploads (Active Storage)

- [ ] Tipo e tamanho validados no servidor (não só no navegador). (Importante)
- [ ] Arquivo servido com autorização quando é privado (URLs assinadas/expiráveis, sem rota pública). (Bloqueante para dado pessoal)
- [ ] Nome de arquivo do usuário não usado como caminho no disco. (Bloqueante)

## Abuso e disponibilidade

- [ ] Ações sensíveis (login, recuperação de senha, envio de código, criação em massa) com limite de taxa (`rate_limit` do Rails 7.2+, Rack::Attack) quando o PRD/risco pede. (Importante)
- [ ] Regex com entrada do usuário sem risco de ReDoS (âncoras `\A`/`\z` em validação, não `^`/`$`). (Importante; Bloqueante se `^`/`$` permite bypass de validação)
- [ ] Consultas/paginação com limite máximo para não carregar tudo. (Importante)

## Dependências

- [ ] Gem nova é conhecida, mantida e necessária? Versão travada no `Gemfile.lock`? (Importante)
- [ ] `bundler-audit` (se o projeto usa) sem alerta novo. (conforme o alerta)

## Ferramentas (sempre com confirmação do usuário)

- `bin/brakeman --no-pager --only-files <arquivos do diff>` — confirme cada alerta no código antes de transformá-lo em apontamento; alerta de confiança baixa pode ser falso positivo.
- `bundle exec bundler-audit check --update` — quando o diff mexe no `Gemfile.lock`.

Referência: Guia de Segurança do Rails — https://guides.rubyonrails.org/security.html
