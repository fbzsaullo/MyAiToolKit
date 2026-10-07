# Diagramas C4 em Mermaid

Modelos prontos para copiar e adaptar. `flowchart` atende aos níveis 1, 2 e 3; `sequenceDiagram` explica fluxos; `stateDiagram-v2` mostra ciclos de vida. O nível 4 (código) quase nunca vale o esforço — quem quer ver classes abre o código.

O domínio usado nos exemplos é uma plataforma de cursos online, só para dar concretude.

## Nível 1 — Contexto

O sistema aparece como uma caixa fechada. Mostre quem o usa e com quem ele conversa — nada do que existe dentro dele.

```mermaid
flowchart TB
    Aluno[👤 Aluno]
    Instrutor[👤 Instrutor]

    Plataforma["🟦 Plataforma de Cursos<br/>(sistema em análise)"]

    Pagamento["Gateway de pagamento"]
    Video["Serviço de streaming de vídeo"]
    Email["Provedor de e-mail transacional"]

    Aluno -->|"assiste aulas e compra cursos"| Plataforma
    Instrutor -->|"publica conteúdo"| Plataforma
    Plataforma -->|"cobra assinaturas"| Pagamento
    Plataforma -->|"entrega vídeos"| Video
    Plataforma -->|"envia recibos e avisos"| Email

    style Plataforma fill:#1168bd,color:#fff
```

**Para ficar legível:**
- Pinte o sistema em análise com uma cor que o destaque
- Escreva na seta o que acontece (um verbo), não deixe a linha muda
- Pessoas em cima; sistemas externos dos lados ou embaixo
- Fique perto de 7 elementos — mais que isso satura

## Nível 2 — Containers

Abre a caixa e mostra o que é implantado separadamente: aplicação web, workers, banco, cache, filas.

```mermaid
flowchart TB
    Aluno[👤 Aluno]

    subgraph Plataforma["Plataforma de Cursos"]
        Web["Aplicação web<br/>Rails 8 + Hotwire"]
        Jobs["Workers<br/>Solid Queue"]
        DB[("Banco relacional<br/>PostgreSQL 16")]
        Cache[("Cache<br/>Solid Cache")]
        Storage[("Arquivos<br/>Active Storage + S3")]
    end

    Pagamento["Gateway de pagamento"]
    Email["Provedor de e-mail"]

    Aluno -->|"HTTPS"| Web
    Web --> DB
    Web -->|"fragmentos de página"| Cache
    Web -->|"anexos e certificados"| Storage
    Web -->|"enfileira trabalho"| Jobs
    Jobs --> DB
    Jobs -->|"webhooks e cobranças"| Pagamento
    Jobs -->|"envio assíncrono"| Email

    style Web fill:#1168bd,color:#fff
    style Jobs fill:#1168bd,color:#fff
```

**Para ficar legível:**
- Tecnologia e versão no rótulo, depois de `<br/>`
- Bancos, caches e filas como cilindro: `[(...)]`
- Protocolo ou formato na seta quando isso ajudar a decisão
- Sistemas externos fora do `subgraph`

## Nível 3 — Componentes

Lupa sobre **um** container. Só desenhe quando a organização interna influencia uma decisão — normalmente no container de domínio mais complexo.

O exemplo abaixo usa nomes de papéis (não de bibliotecas), para mostrar agrupamento lógico sem prescrever um estilo. A versão com classes reais de uma aplicação Rails está em `${CLAUDE_PLUGIN_ROOT}/stacks/rails/c4-component-example.md`.

```mermaid
flowchart TB
    subgraph App["Aplicação web"]
        Entrada["Pontos de entrada<br/>(HTTP, webhooks)"]

        subgraph Aplicacao["Casos de uso"]
            Comandos["Operações de escrita"]
            Consultas["Operações de leitura"]
            Validacao["Validação de entrada"]
        end

        subgraph Dominio["Domínio"]
            Entidades["Entidades e regras"]
            Politicas["Políticas de negócio"]
        end

        subgraph Infra["Infraestrutura"]
            Persistencia["Persistência"]
            Adaptadores["Adaptadores de serviços externos"]
            Publicador["Publicação de jobs/eventos"]
        end
    end

    DB[("Banco")]
    Fila[("Fila")]
    Externo["Gateway de pagamento"]

    Entrada --> Comandos
    Entrada --> Consultas
    Comandos --> Validacao
    Comandos --> Entidades
    Comandos --> Persistencia
    Comandos --> Publicador
    Entidades --> Politicas
    Consultas --> Persistencia
    Persistencia --> DB
    Publicador --> Fila
    Adaptadores --> Externo

    style Dominio fill:#fff3cd
    style Aplicacao fill:#e3f2fd
    style Infra fill:#f8d7da
```

**Para ficar legível:**
- Use `subgraph` para agrupar (camadas, módulos, bounded contexts)
- Uma cor por grupo ajuda o olho
- Nada de classes individuais — isso já seria nível 4
- Esse agrupamento é ilustração, não recomendação: separar em camadas tem custo e só compensa em certos contextos (ver `architectural-styles.md`)

## Sequência — fluxos que precisam de explicação

Para um a três fluxos em que o desenho de containers não basta. Fluxo CRUD previsível não precisa.

```mermaid
sequenceDiagram
    actor A as Aluno
    participant W as App Rails
    participant P as Gateway
    participant DB as Banco
    participant Q as Fila
    participant J as Job
    participant M as E-mail

    A->>W: Confirma assinatura
    activate W
    W->>P: Cria cobrança
    P-->>W: ✅ cobrança aprovada (id)
    W->>DB: BEGIN
    W->>DB: cria matrícula (ativa)
    W->>DB: registra pagamento
    W->>DB: COMMIT
    W->>Q: enfileira EnviarBoasVindas
    W-->>A: Redireciona para o curso
    deactivate W

    Note over Q,J: daqui em diante, fora da requisição

    Q->>J: EnviarBoasVindas
    J->>M: e-mail de boas-vindas
    J->>DB: marca matrícula como notificada
```

**Para ficar legível:**
- `activate`/`deactivate` mostram o trecho síncrono
- `Note` marca a passagem para o assíncrono
- Respostas com seta tracejada (`-->>`)
- Mais de 7 participantes atrapalha a leitura

## Estados — ciclo de vida de uma entidade

Útil quando boa parte da arquitetura existe para controlar as transições de uma entidade (matrícula, pedido, contrato, chamado).

```mermaid
stateDiagram-v2
    [*] --> Pendente
    Pendente --> Ativa: pagamento_aprovado
    Pendente --> Cancelada: pagamento_recusado
    Pendente --> Cancelada: expirou_48h
    Ativa --> Suspensa: falha_na_renovacao
    Suspensa --> Ativa: pagamento_regularizado
    Suspensa --> Cancelada: 15_dias_sem_pagamento
    Ativa --> Concluida: curso_finalizado
    Concluida --> [*]
    Cancelada --> [*]

    note right of Suspensa
        Prazo de tolerância
        configurável por plano
    end note
```

## Erros que tiram o valor do diagrama

- ❌ **Excesso de caixas** — passou de ~15 elementos num mesmo nível, divida em diagramas ou suba um nível.
- ❌ **Níveis misturados** — containers e componentes no mesmo desenho confundem o leitor.
- ❌ **Setas sem rótulo** — toda seta deve dizer o que passa por ela (requisição, evento, dado).
- ❌ **Tecnologia no contexto** — o nível 1 é caixa fechada; tecnologia aparece a partir do nível 2.
- ❌ **Desenho sem pergunta** — se o leitor não tira nenhuma conclusão arquitetural dele, o diagrama não precisa estar na proposta.
