# Modelo — descrição de Pull Request

Usado pela skill `pr-description` quando o repositório **não** tem um modelo de PR próprio (`.github/pull_request_template.md` e variações). Seções sem conteúdo saem — nada de "N/A" em sequência.

> Sobre as cercas: as quatro crases externas só delimitam o modelo. As cercas de três crases internas fazem parte da descrição.

---

````markdown
## O que muda

[2 a 4 linhas: o que o PR entrega e por quê, na língua de quem usa o sistema.
Ex.: "Dois pedidos para o mesmo horário não geram mais duas consultas: o segundo recebe 409.
Atende a RN-04 do PRD-003, que estava descumprida desde a T-03."]

## Rastreabilidade

- **Tarefas:** T-03 — [título] (`docs/sdd/plans/PLAN-003-*.md`)
- **Regras e cenários:** RN-04 · CA-05 (PRD-003)
- **Telas:** UI-02 (default, ocupado)
- **Decisões:** ADR-002 — [título]
- **Card / bug:** [PROJ-123 — link] · [BUG-PROJ-88]

## Mudanças por área

- **Dados:** [ex.: índice único em `consultas (medico_id, horario)`]
- **Regra:** [ex.: `AgendarConsulta` trata a violação do índice]
- **Interface:** [ex.: mensagem de horário ocupado]
- **Testes:** [ex.: request spec do CA-05; teste de concorrência]

## Como testar

1. [preparação — dados, seeds, variável de ambiente]
2. [ação — o que fazer na tela ou na API]
3. [o que observar]

```bash
[comando real de commands.test_single do config.yml, ex.: bundle exec rspec spec/requests/consultas_spec.rb]
```

## Cenários cobertos por teste

| Cenário | Teste |
| --- | --- |
| CA-05 — [título] | `spec/requests/consultas_spec.rb` — `it "CA-05: ..."` |

## Review

- **Review SDD:** [✅ Aprovado / ⚠️ Aprovado com ressalvas] — `REVIEW-T-03-AAAA-MM-DD.md`
- **Ressalvas em aberto:** [R-02 (REVIEW-T-03-AAAA-MM-DD) — vira tarefa T-07 · ou "nenhuma"]
- **Code review:** [veredito e Q1/Q2 em aberto, se houver `CR-*.md`]

## Riscos e implantação

- [ex.: migration com índice em tabela grande — `algorithm: :concurrently`]
- [ex.: variável nova `AGENDA_LOCK_TIMEOUT` (padrão 5s)]
- [ex.: rollback: reverter o deploy; a migration é reversível]

## Capturas de tela

[Só se o PR toca telas: uma por estado declarado — UI-02.default, UI-02.ocupado.]

## Fora do escopo

- [o que alguém poderia esperar ver aqui e não está — e onde vai ser tratado]
````

## Título

Fora do corpo, num bloco à parte: o mesmo formato do assunto de commit do projeto (`git.commit`), ex.: `feat(agenda): bloqueia horário já ocupado (T-03)`.
