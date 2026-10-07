# Modelo — contexto de módulo

Para projetos divididos em módulos (engines, packs do packwerk, pastas por domínio, aplicações de um monorepo). O arquivo fica **dentro da pasta do módulo**: `AGENTS.md` com o conteúdo e, se o projeto usa Claude Code, um `CLAUDE.md` vizinho contendo apenas `@AGENTS.md`.

Tamanho alvo: **20 a 50 linhas**. Com menos de ~15 linhas úteis, o módulo provavelmente não precisa de contexto próprio — avise o usuário.

**Regra principal:** o módulo **nunca** repete stack nem comandos globais. O que está na raiz vale para todos; repetir aqui só cria versões divergentes.

> As quatro crases externas apenas delimitam o modelo.

---

````markdown
# Módulo: [nome]

<!-- myaitoolkit:start -->

## Responsabilidade

[1 a 2 linhas: o que o módulo faz e onde termina. Se não couber em duas linhas,
a fronteira provavelmente está mal definida.]

## Domínio

[Conceitos de negócio centrais — sem listar atributos; o código é a fonte da estrutura.]

- **[agregado/entidade principal]** — [papel em uma linha]
- **[entidade]** — [papel em uma linha]

## Fronteiras

**Pode depender de:**
- [ex.: `core` — tipos e erros comuns]
- [ex.: `agenda` — apenas pela API pública `Agenda::Horarios`]

**Não pode depender de:**
- [ex.: `faturamento` — integração só pelo job/evento `ConsultaRealizada`]
- [ex.: tabelas de outros módulos, diretamente]

## Convenções próprias

[**Somente** o que diverge da raiz. Se o módulo segue o padrão geral, remova a seção.]

- [ex.: relatórios usam SQL direto em query objects por desempenho (ADR-011)]
- [ex.: todos os jobs deste módulo são idempotentes — reprocessamento é esperado]

## Comandos próprios

[Somente o que vale só para este módulo. Se não houver, remova a seção.]

```bash
bundle exec rspec engines/faturamento/spec    # testes do módulo
```

## Decisões e requisitos que tocam o módulo

- **ADR-002** — [título curto] → `docs/sdd/architecture/adrs/ADR-002-*.md`
- **PRD-003** — [funcionalidade deste módulo] → `docs/sdd/prds/PRD-003-*.md`

<!-- myaitoolkit:end -->

<!-- Daqui para baixo o conteúdo é mantido pelo time; o /sdd-setup não altera. -->
````

---

## Como preencher

**Responsabilidade.** Se a descrição precisa de "e também" ou lista mais de dois propósitos, o módulo pode estar fazendo coisas demais. Registre como observação ao usuário — é assunto para o `sdd-architect`, não para o setup.

**Domínio.** Só conceito de negócio: `Fatura`, `ItemDeFatura`, `SituacaoFatura` entram; `FaturaRepository`, `FaturaSerializer` não.

**Fronteiras.** A seção mais valiosa: é aqui que o agente descobre que não pode simplesmente usar o model do módulo vizinho. Tire das decisões de modularização (proposta, ADRs, `package.yml` do packwerk). Se nada define as fronteiras, **pergunte** — uma fronteira inventada é pior que nenhuma. Se a integração é assíncrona, diga o nome do job ou evento.

**Convenções próprias.** Sem divergência, sem seção. Divergência sem ADR por trás é um achado — reporte ao usuário (pode ser dívida acidental).

**Decisões e requisitos.** Só o que afeta este módulo. Mais de ~8 ADRs aplicáveis sugere que ele é o núcleo do sistema — vale avaliar se a divisão está equilibrada.

## Quando recomendar não criar

- módulo trivial (CRUD sem regra, sem fronteira especial, sem convenção própria);
- módulo recém-criado, ainda sem código;
- módulo sendo extraído ou fundido (fronteira em movimento);
- projeto com um único módulo (a raiz já cobre).

Explique o motivo e deixe a decisão com o usuário.
