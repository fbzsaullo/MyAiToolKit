# Perfil de stack — genérico (fallback)

Usado quando a stack do projeto não tem perfil próprio em `stacks/`. Segue o mesmo contrato dos demais (`stacks/README.md`), mas em vez de respostas prontas traz **perguntas e lugares onde procurar**. Toda análise feita com este perfil deve dizer isso no `stack-report.md`.

---

## 1. Sinais de detecção

Procure o manifesto da linguagem na raiz e nas subpastas:

| Arquivo | Ecossistema |
| --- | --- |
| `Cargo.toml` | Rust |
| `mix.exs` | Elixir |
| `pubspec.yaml` | Dart / Flutter |
| `Package.swift` | Swift |
| `build.sbt` | Scala |
| `deno.json` | Deno |
| `*.gemspec` sem Rails | Gem Ruby |
| `CMakeLists.txt`, `Makefile` sem outro manifesto | C/C++ |
| `stack.yaml`, `*.cabal` | Haskell |

Se nenhum manifesto existir, pergunte ao usuário qual é a stack.

## 2. Fontes de versão

Em ordem de confiança: lockfile → arquivo de versão do runtime (`.tool-versions`, `mise.toml`, arquivos `.<linguagem>-version`) → manifesto → imagem do `Dockerfile` → CI. Registre a origem de cada versão; sem fonte, "não identificada".

## 3. Orientações por versão

Sem conhecimento embutido da stack, limite-se a:
- apontar divergências de versão entre as fontes;
- recomendar conferir a política oficial de suporte da linguagem/framework (peça o link ao usuário ou procure na documentação oficial) — **não afirme datas**;
- sugerir criar um perfil para a stack (`stacks/README.md`).

## 4. Comandos

Use a precedência de `skills/sdd-setup/references/base-prompt.md`: executáveis do projeto/task runner (`Makefile`, `justfile`, `Taskfile.yml`, `scripts/`) → scripts do gerenciador de pacotes → o que o CI roda → README. Exemplos de nativos, **só com evidência no repositório**:

| Ecossistema | Build | Testes | Lint |
| --- | --- | --- | --- |
| Rust | `cargo build` | `cargo test` | `cargo clippy`, `cargo fmt --check` |
| Elixir | `mix compile` | `mix test` | `mix credo`, `mix format --check-formatted` |
| Dart/Flutter | `flutter build` | `flutter test` / `dart test` | `dart analyze` |
| Swift | `swift build` | `swift test` | `swiftlint` (se configurado) |

## 5. Testes

Identifique o framework pela pasta e pelas dependências de teste. **Convenção de nome para `CA-XX`** quando não houver perfil:

- se o framework aceita descrição livre (string): `"CA-05: <descrição>"`;
- se exige identificador (nome de função/método): `ca_05_<descricao>` ou `CA_05_<Descricao>`, conforme o padrão de nomes da linguagem.

Registre em `testing.ca_naming` o formato escolhido e o `grep` correspondente (`CA-[0-9]{2}` ou `CA_[0-9]{2}`).

## 6. Qualidade e segurança

Pergunte ou procure: linter oficial da linguagem, formatador, analisador estático, auditoria de dependências (ex.: `cargo audit`, `mix deps.audit`). Ausência de auditoria de dependências é recomendação de baixo esforço.

### Checklist de segurança universal (usado quando a stack não tem `security-checklist.md`)

Aplicado **somente às linhas do diff**:

- [ ] Entrada externa (parâmetros, headers, corpo, arquivos, mensagens de fila) validada antes do uso. (Importante a Bloqueante)
- [ ] Consultas ao banco parametrizadas — nada de concatenar entrada em SQL. (Bloqueante)
- [ ] Comandos de sistema sem entrada do usuário em string única; argumentos separados e lista permitida. (Bloqueante)
- [ ] Nada de execução/avaliação dinâmica (`eval`, reflexão, carregamento de classe por nome) sobre entrada do usuário. (Bloqueante)
- [ ] Caminhos de arquivo montados com entrada do usuário são normalizados e restritos a um diretório. (Bloqueante)
- [ ] Desserialização apenas de formatos seguros (JSON) para dados externos. (Bloqueante)
- [ ] Saída para HTML escapada; nada de marcar conteúdo do usuário como seguro. (Bloqueante)
- [ ] Toda operação nova verifica autenticação **e** autorização sobre o recurso específico (evitar IDOR). (Bloqueante)
- [ ] Dados pessoais e segredos fora de logs, mensagens de erro e respostas. (Bloqueante)
- [ ] Nenhum segredo no código ou em arquivo versionado. (Bloqueante)
- [ ] Redirecionamentos e URLs com entrada do usuário restritos a destinos permitidos. (Importante)
- [ ] Comparação de tokens/senhas em tempo constante; senhas com hash adequado (bcrypt/argon2). (Bloqueante)
- [ ] Dependências novas conhecidas, mantidas, sem vulnerabilidade conhecida. (Importante)
- [ ] Limite de taxa em ações sensíveis quando o risco pede. (Importante)

## 7. Convenções a observar no código

Procure padrões que se repetem e que o agente erraria sem saber:
- onde fica a regra de negócio e como as camadas se organizam;
- padrão de erros (exceções, valores de retorno, tipos de resultado);
- padrão de autenticação/autorização;
- como os testes são organizados e nomeados;
- regras de dependência entre módulos/pacotes.

Na dúvida, pergunte — convenção inventada é pior que convenção ausente.

## 8. Segredos

Além do bloqueio universal de `skills/sdd-setup/references/permission-principles.md`, pergunte ao usuário se a stack tem arquivos próprios de segredo (keystores, arquivos de credenciais de frameworks, configs de produção com senha).

## 9. Arquivos complementares

Nenhum. Permissões: aplique o bloqueio universal, git e Docker, e libere apenas os comandos de build/teste/lint **encontrados** no repositório, com a mesma lógica de baldes (`permission-principles.md`). Gerenciadores de pacote que instalam dependências vão para `ask`; publicação (`cargo publish`, `mix hex.publish`…) vai para `deny`.

## 10. Referências oficiais

- A documentação oficial da linguagem/framework — peça ao usuário ou localize pelo manifesto.
- Para contribuir com um perfil: `stacks/README.md`.
