# Modelo — Relatório de bug

Arquivo em `docs/sdd/bugs/BUG-<CHAVE>-<tema>.md`, gerado pelo `sdd-bug`. Curto: o plano guarda a execução; este arquivo guarda o relato e o diagnóstico.

> Sobre as cercas: as quatro crases externas só delimitam o modelo e não vão para o arquivo gerado.

---

````markdown
# BUG-<CHAVE>: [o defeito em uma frase — ex.: link de recuperação aceito depois de expirar]

- **Card de origem:** [chave ou link, se houver]
- **Data:** AAAA-MM-DD
- **Gravidade:** [Impede o uso / Contornável com esforço / Incômodo]
- **Frequência:** [sempre / às vezes / uma vez]
- **Tarefa de correção:** [T-XX em `docs/sdd/plans/PLAN-XXX-*.md`]

## Observado

[O que acontece. Mensagem de erro, trecho de log ou descrição do print.]

## Esperado

[O que deveria acontecer e segundo quem: `RN-XX` / `CA-XX` do PRD-XXX, contrato, ou "declarado pelo usuário" quando não há PRD.]

## Como reproduzir

1. [passo]
2. [passo]

- **Ambiente:** [produção, homologação, local; versão ou commit]
- **Dados:** [o que é preciso existir para reproduzir]

## Onde está o combinado

[Uma das situações: CA existente descumprido / RN sem cenário para o caso / lacuna no PRD / projeto sem PRD.
Se o PRD foi revisado, cite a revisão e os IDs: "Revisão 2 do PRD-007: +CA-19".]

## Causa provável

- **Hipótese principal:** [explicação] — `arquivo:linha`
- **Confiança:** [alta / média / baixa]
- **Alternativas:** [outras hipóteses e o que as descartaria — ou "nenhuma"]
- **Mesmo padrão em:** [outros pontos do código — ou "nenhum encontrado"]
- **Origem:** [commit ou T-XX que introduziu, se identificado]

## Teste de regressão

`[nome do teste no formato do projeto — ex.: it "CA-03: link expirado é recusado"]` — falha antes da correção e passa depois.

## Contenção

[Só com gravidade "Impede o uso": medida imediata recomendada (flag, rollback) — ou "não se aplica".]
````
