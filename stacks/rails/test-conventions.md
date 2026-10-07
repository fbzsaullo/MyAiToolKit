# Convenção de testes — Ruby on Rails

Como o `CA-XX` aparece nos testes de uma aplicação Rails, para que `sdd-execute` escreva, `sdd-review` cobre e `sdd-trace` encontre. A regra geral está em `templates/id-conventions.md`: o ID do cenário precisa estar no nome do teste, de forma localizável por busca textual.

## RSpec

**Formato padrão** — o ID abre a descrição do exemplo:

```ruby
# spec/requests/consultas_spec.rb
RSpec.describe "Consultas", type: :request do
  describe "POST /consultas" do
    it "CA-01: agenda consulta em horário livre" do
      # ...
    end

    it "CA-02: recusa agendamento com menos de 2 horas de antecedência" do
      # ...
    end
  end
end
```

**Metadado opcional** — útil para rodar só os testes de um cenário (`bundle exec rspec --tag ca:CA-05`):

```ruby
it "CA-05: dois pacientes disputam o último horário", ca: "CA-05" do
  # ...
end
```

O metadado **complementa** o ID na descrição, não o substitui: a descrição é o que aparece no relatório do RSpec e o que o `sdd-trace` procura primeiro.

**Cenário que vira vários exemplos** (um `Esquema do Cenário` com tabela): agrupe num `describe`/`context` com o ID e deixe os exemplos internos livres:

```ruby
describe "CA-07: valor cobrado conforme o plano" do
  [
    ["Particular", "Clínico geral", 250.0],
    ["Convênio Ouro", "Cardiologia", 50.0]
  ].each do |plano, especialidade, valor|
    it "cobra #{valor} para #{plano} em #{especialidade}" do
      # ...
    end
  end
end
```

## Minitest

```ruby
# test/integration/consultas_test.rb
class ConsultasTest < ActionDispatch::IntegrationTest
  test "CA-01 agenda consulta em horário livre" do
    # ...
  end
end
```

O Minitest transforma o texto em nome de método (`test_CA-01_agenda...`); a busca por `CA-01` continua funcionando.

## Onde cada cenário costuma ser provado

| Tipo de cenário | RSpec | Minitest |
| --- | --- | --- |
| Regra isolada (validação, cálculo) | `spec/models`, `spec/services` | `test/models`, `test/services` |
| Fluxo ponta a ponta sem tela | `spec/requests` | `test/integration` |
| Fluxo com tela (crítico) | `spec/system` | `test/system` |
| Job | `spec/jobs` | `test/jobs` |
| Concorrência | `spec/requests` ou `spec/services` com threads | idem em `test/` |

Teste de concorrência em Rails: desligue a transação automática naquele exemplo (`self.use_transactional_tests = false` no Minitest; em RSpec, `uses_transaction` ou configuração equivalente do projeto) para que as threads enxerguem os mesmos dados, e limpe os dados ao final.

## O que o `config.yml` registra

```yaml
testing:
  framework: rspec
  paths: [spec]
  ca_naming:
    pattern: 'it "CA-XX: <descrição>"'
    grep: 'CA-[0-9]{2}'
```

## O que o review cobra

- Teste de cenário sem o `CA-XX` no nome → **Importante** (eixo 2).
- `CA-XX` de `Valida:` sem nenhum teste com o ID → **Bloqueante** (eixo 2/3).
- ID no nome, mas o teste não exercita o cenário (Dado/Quando/Então) → **Bloqueante** (eixo 3).
