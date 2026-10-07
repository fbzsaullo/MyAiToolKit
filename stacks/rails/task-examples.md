# Tarefas de referência — versão Rails

Os seis exemplos de `skills/sdd-plan/references/task-examples.md` aplicados a uma aplicação Rails 8 (PostgreSQL, Hotwire, RSpec, factory_bot). Mesmo domínio (agendamento de consultas), mesmos IDs e mesma régua de tamanho — muda só o concreto: arquivos reais, trechos de código e nomes de teste no formato `it "CA-XX: ..."`.

O guia de tamanho e a tabela de "quando um campo fica vazio" valem como estão no arquivo agnóstico; não são repetidos aqui.

---

## Exemplo 1 — Estrutura

```markdown
#### T-01 — Criar o model Consulta e a tabela consultas

- **Status:** Pendente
- **Complexidade:** Baixa
- **Estimativa:**
- **Depende de:** nenhuma
- **Implementa:** —
- **Valida:** —
- **Decisões base:** ADR-001 *(monolito modular; organização de pastas conforme o AGENTS.md)*
- **Arquivos/camadas:**
  - `db/migrate/20261005100000_create_consultas.rb` *(novo)*
  - `app/models/consulta.rb` *(novo)*
  - `spec/factories/consultas.rb` *(novo)*

**O que fazer:**
Tabela `consultas` com `paciente_id`, `horario_id` (FKs com índice), `situacao`
(integer, enum com valores explícitos) e timestamps. Model com `belongs_to`, enum e
scope `ativas` (pendente ou confirmada). Sem regra de agendamento ainda.

**Critério de aceite (testável):**
- [ ] `bin/rails db:migrate` e `db:rollback` funcionam
- [ ] `bin/rails zeitwerk:check` passa

**Testes a escrever:**
- *Não se aplica* — estrutura. As regras ganham teste na T-03.
```

```ruby
# db/migrate/20261005100000_create_consultas.rb
class CreateConsultas < ActiveRecord::Migration[8.0]
  def change
    create_table :consultas do |t|
      t.references :paciente, null: false, foreign_key: true
      t.references :horario, null: false, foreign_key: true
      t.integer :situacao, null: false, default: 0
      t.timestamps
    end
  end
end

# app/models/consulta.rb
class Consulta < ApplicationRecord
  belongs_to :paciente
  belongs_to :horario

  enum :situacao, { pendente: 0, confirmada: 1, cancelada: 2, realizada: 3 }

  scope :ativas, -> { where(situacao: %i[pendente confirmada]) }
end
```

---

## Exemplo 2 — Regra de negócio

```markdown
#### T-03 — Agendar consulta garantindo um paciente por horário

- **Status:** Pendente
- **Complexidade:** Alta
- **Estimativa:**
- **Depende de:** T-01, T-02
- **Implementa:** RN-02, RN-04
- **Valida:** CA-01, CA-02, CA-05
- **Decisões base:** ADR-002 *(bloqueio de linha)*
- **Arquivos/camadas:**
  - `app/services/agendar_consulta.rb` *(novo)*
  - `db/migrate/20261005120000_add_unique_index_to_consultas.rb` *(novo)*
  - `spec/services/agendar_consulta_spec.rb` *(novo)*

**O que fazer:**
Serviço com transação + `lock!` no horário, verificação de antecedência e de
horário livre, criação da consulta confirmada. Índice único parcial como segunda
barreira. Retorna objeto de resultado (convenção do projeto).

**Critério de aceite (testável):**
- [ ] CA-01 verde
- [ ] CA-02 verde: menos de 2h → erro `:antecedencia`
- [ ] CA-05 verde: 10 confirmações simultâneas → 1 consulta

**Testes a escrever:**
- *Serviço:* `it "CA-01: agenda em horário livre"`, `it "CA-02: recusa com menos de 2 horas"`
- *Concorrência:* `it "CA-05: confirmações simultâneas criam uma única consulta"`

**Riscos / atenção:**
- Validação humana antes da T-05: estratégia de bloqueio tem impacto operacional.
```

```ruby
# db/migrate/20261005120000_add_unique_index_to_consultas.rb
class AddUniqueIndexToConsultas < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :consultas, :horario_id,
              unique: true,
              where: "situacao IN (0, 1)", # pendente, confirmada
              name: "index_consultas_ativas_por_horario",
              algorithm: :concurrently
  end
end
```

```ruby
# spec/services/agendar_consulta_spec.rb
RSpec.describe AgendarConsulta do
  let(:paciente) { create(:paciente) }

  it "CA-01: agenda em horário livre" do
    horario = create(:horario, inicia_em: 1.day.from_now)

    resultado = described_class.call(paciente:, horario:)

    expect(resultado).to be_sucesso
    expect(resultado.consulta).to be_confirmada
  end

  it "CA-02: recusa com menos de 2 horas de antecedência" do
    freeze_time do
      horario = create(:horario, inicia_em: 90.minutes.from_now)

      resultado = described_class.call(paciente:, horario:)

      expect(resultado.erro).to eq(:antecedencia)
      expect(Consulta.count).to eq(0)
    end
  end
end
```

(O serviço completo e o teste de concorrência estão em `pipeline-example.md`.)

---

## Exemplo 3 — Exposição

```markdown
#### T-05 — Expor o agendamento em POST /horarios/:horario_id/consultas

- **Status:** Pendente
- **Complexidade:** Média
- **Estimativa:**
- **Depende de:** T-03, T-04
- **Implementa:** —
- **Valida:** CA-01, CA-02, CA-05
- **Decisões base:** ADR-003 *(controllers finos)*
- **Arquivos/camadas:**
  - `config/routes.rb` *(editado)*
  - `app/controllers/consultas_controller.rb` *(novo)*
  - `app/policies/consulta_policy.rb` *(novo)*
  - `spec/requests/consultas_spec.rb` *(novo)*

**Critério de aceite (testável):**
- [ ] Paciente autenticado agenda → redireciona com 303 para "Minhas consultas" (CA-01)
- [ ] Menos de 2h → re-renderiza com 422 e mensagem (CA-02)
- [ ] Horário ocupado → re-renderiza com 422 e mensagem (CA-05)
- [ ] Sem sessão → redireciona para o login

**Testes a escrever:**
- *Requisição:* `it "CA-01: cria a consulta e redireciona"`, `it "CA-02: responde 422 por antecedência"`,
  `it "CA-05: responde 422 quando o horário foi ocupado"`, `it "exige autenticação"`
```

```ruby
# app/controllers/consultas_controller.rb
class ConsultasController < ApplicationController
  before_action :set_horario

  def new
    authorize Consulta
  end

  def create
    authorize Consulta
    resultado = AgendarConsulta.call(paciente: Current.user.paciente, horario: @horario)

    if resultado.sucesso?
      redirect_to consultas_path, notice: t(".confirmada"), status: :see_other
    else
      flash.now[:alert] = t(".#{resultado.erro}")
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_horario
    @horario = Horario.publicados.find(params.expect(:horario_id))
  end
end
```

---

## Exemplo 4 — Qualidade e operação

```markdown
#### T-10 — Instrumentar o agendamento com logs e métricas

- **Status:** Pendente
- **Complexidade:** Média
- **Estimativa:**
- **Depende de:** T-05
- **Implementa:** —
- **Valida:** —
- **Decisões base:** ADR-006 *(observabilidade com eventos estruturados)*
- **Arquivos/camadas:**
  - `app/services/agendar_consulta.rb` *(editado)*
  - `config/initializers/filter_parameter_logging.rb` *(editado)*

**Critério de aceite (testável):**
- [ ] Cada tentativa gera evento com `medico_id`, `resultado` e `request_id`
- [ ] Nenhum dado pessoal (nome, CPF, telefone) em log — `filter_parameters` atualizado

**Testes a escrever:**
- *Serviço:* `it "registra o resultado do agendamento"`, `it "não registra dado pessoal"`

**Riscos / atenção:**
- `paciente_id` não vira rótulo de métrica (cardinalidade); fica só no evento.
```

```ruby
# trecho em app/services/agendar_consulta.rb (Rails 8.1+: Rails.event)
Rails.event.notify("agendamento.tentativa",
                   medico_id: @horario.medico_id,
                   resultado: resultado.erro || :confirmada)
```

---

## Exemplo 5 — Tarefa nascida de um ADR

```markdown
#### T-12 — Colocar o agendamento online atrás de feature flag

- **Status:** Pendente
- **Complexidade:** Média
- **Estimativa:**
- **Depende de:** T-05
- **Implementa:** —
- **Valida:** —
- **Decisões base:** ADR-005 *(liberação gradual por clínica)*
- **Arquivos/camadas:**
  - `app/controllers/consultas_controller.rb` *(editado)*
  - `app/views/horarios/index.html.erb` *(editado)*
  - `AGENTS.md` *(editado — como ligar/desligar)*

**Critério de aceite (testável):**
- [ ] Flag desligada: rota responde 404 e o botão "Agendar" não aparece
- [ ] Flag ligada para a clínica piloto: comportamento normal

**Testes a escrever:**
- *Requisição:* `it "responde 404 com a flag desligada"`, `it "agenda com a flag ligada"`

**Riscos / atenção:**
- Validação humana antes do deploy: flag desligada em produção.
```

```ruby
# com Flipper (exemplo; use a ferramenta de flags do projeto)
before_action -> { raise ActionController::RoutingError, "Not Found" unless Flipper.enabled?(:agendamento_online, Current.clinica) }
```

---

## Exemplo 6 — Corte vertical

```markdown
#### T-01 — Fatia: paciente agenda em horário livre (caminho feliz)

- **Status:** Pendente
- **Complexidade:** Alta
- **Estimativa:**
- **Depende de:** nenhuma
- **Implementa:** RN-01
- **Valida:** CA-01
- **Decisões base:** ADR-003; ADR-002 fica para a próxima fatia
- **Arquivos/camadas:**
  - `db/migrate/20261005100000_create_consultas.rb` *(novo)*
  - `app/models/consulta.rb` *(novo)*
  - `app/services/agendar_consulta.rb` *(novo — sem bloqueio ainda)*
  - `app/controllers/consultas_controller.rb` *(novo)*
  - `spec/requests/consultas_spec.rb` *(novo)*

**Critério de aceite (testável):**
- [ ] CA-01 verde: POST em horário livre cria a consulta e redireciona

**Testes a escrever:**
- *Requisição:* `it "CA-01: agenda em horário livre"`

**Riscos / atenção:**
- Antecedência (RN-02) e disputa de horário (CA-05, com ADR-002) são as próximas fatias.
- Este corte gera mais tarefas que o horizontal; o ganho é ver funcionando cedo.
```
