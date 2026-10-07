# C4 nível 3 — componentes de uma aplicação Rails

Versão concreta do diagrama de componentes de `skills/sdd-architect/references/c4-mermaid-templates.md`, para a aplicação de agendamento de consultas.

É **um** jeito comum de organizar um Rails de porte médio — regra de negócio em objetos de serviço, autorização em policies, interface com Hotwire. Não é recomendação: uma aplicação Rails "clássica", com a regra nos models, é igualmente válida quando o domínio é simples. A escolha de organização é decisão do projeto, registrada em ADR.

```mermaid
flowchart TB
    subgraph App["Aplicação Rails 8"]
        subgraph Entrada["Entrada"]
            Rotas["config/routes.rb"]
            Controllers["Controllers<br/>ConsultasController, HorariosController"]
            Webhooks["Webhooks<br/>Convenio::WebhooksController"]
        end

        subgraph Interface["Interface (Hotwire)"]
            Views["Views ERB + Turbo Frames/Streams"]
            Componentes["ViewComponents<br/>SlotHorarioComponent"]
            Stimulus["Stimulus controllers"]
        end

        subgraph Regras["Regras de negócio"]
            Servicos["Objetos de serviço<br/>AgendarConsulta, CancelarConsulta"]
            Policies["Policies (Pundit)<br/>ConsultaPolicy"]
            Models["Models + validações<br/>Consulta, Horario, Paciente"]
        end

        subgraph Assincrono["Assíncrono"]
            Jobs["Jobs (Solid Queue)<br/>LembreteConsultaJob"]
            Mailers["Mailers<br/>ConsultaMailer"]
        end

        subgraph Integracoes["Integrações"]
            ClienteConvenio["Clientes de API<br/>Convenio::Cliente"]
        end
    end

    DB[("PostgreSQL<br/>dados + Solid Queue/Cache")]
    Convenio["API do convênio"]
    Email["Provedor de e-mail"]

    Rotas --> Controllers
    Controllers --> Policies
    Controllers --> Servicos
    Controllers --> Views
    Views --> Componentes
    Views --> Stimulus
    Webhooks --> Servicos
    Servicos --> Models
    Servicos -->|perform_later| Jobs
    Jobs --> Mailers
    Jobs --> ClienteConvenio
    Models --> DB
    Jobs --> DB
    ClienteConvenio --> Convenio
    Mailers --> Email

    style Regras fill:#fff3cd
    style Entrada fill:#e3f2fd
    style Interface fill:#e8f5e9
    style Integracoes fill:#f8d7da
```

## Leitura do diagrama

- **Controllers são finos:** autorizam (policy), chamam um serviço e escolhem a resposta. A regra fica em `Regras`.
- **Efeitos externos saem da requisição:** e-mails e chamadas ao convênio rodam em jobs, enfileirados depois do commit.
- **Integrações isoladas:** só `Convenio::Cliente` conhece a API externa; o resto do sistema usa a interface dele.
- **Um banco para tudo:** dados, filas (Solid Queue) e cache (Solid Cache) no PostgreSQL — coerente com o ADR que dispensou Redis.

## Variações comuns

| Situação | O que muda no diagrama |
| --- | --- |
| Domínio simples | Some o grupo de serviços; a regra fica nos models |
| Módulos com packwerk/engines | Cada pack vira um `subgraph` com sua API pública e setas só por ela |
| API-only | Some o grupo `Interface`; entram serializadores (Jbuilder/Alba) |
| Sidekiq em vez de Solid Queue | Jobs passam a depender de um Redis externo |
