# Modelo — Arquivo de ADR

Cada decisão arquitetural vira um arquivo em `docs/sdd/architecture/adrs/ADR-XXX-titulo-curto.md`. A proposta arquitetural só lista os ADRs; quem quiser entender uma decisão abre o arquivo dela. Ter um arquivo por decisão deixa o histórico do git legível: dá para ver quando cada escolha nasceu, mudou ou foi substituída.

> Sobre as cercas: as quatro crases externas só delimitam o modelo e não vão para o arquivo gerado.

---

````markdown
# ADR-XXX: [Decisão em forma de ação — ex.: Usar Solid Queue para jobs assíncronos]

- **Status:** Proposto
- **Data:** AAAA-MM-DD
- **Responsável:** [nome]
- **Proposta:** [../proposta-arquitetural.md](../proposta-arquitetural.md)

## Contexto

[O que obriga a decidir agora. Cite o problema concreto, a qualidade ou a restrição
envolvida e, se existir, um sintoma medido (fila acumulando, tempo de resposta, custo).
"Para escalar melhor" não é contexto; "relatórios de 40s travam a requisição" é.]

## Decisão

[Uma afirmação direta: "Usamos X, configurado assim, para o caso Y."
Nada de condicional e nada de narrar a comparação — ela vem a seguir.]

## Motivos

[Por que esta e não outra. Amarre a objetivos de negócio, qualidades prioritárias
ou restrições deste projeto. Quanto mais específico do contexto, mais útil o ADR
será para quem o ler daqui a um ano.]

## Opções descartadas

[As alternativas reais que foram avaliadas, cada uma com o motivo sincero da recusa.
É esta seção que impede alguém de reabrir a mesma discussão do zero.]

### [Opção A]
- **Em resumo:** [...]
- **Por que não:** [...]

### [Opção B]
- **Em resumo:** [...]
- **Por que não:** [...]

## Consequências

### O que melhora
- [o que a decisão facilita ou destrava]

### O que piora ou fica para depois
[Todo ganho tem custo. Escreva o custo.]
- **Dívida:** [descrição]
  - **Vira problema quando:** [gatilho]
  - **Como resolver:** [caminho em alto nível]

### O que muda sem ser ganho nem perda
- [ex.: migração de dados, treinamento, ajuste de pipeline]

## Para quem vai implementar

[Direção prática, não código: componentes afetados, ordem sugerida, feature flags.]

- Tarefas relacionadas: buscar `Decisões base: ADR-XXX` em `docs/sdd/plans/PLAN-*.md`
- Componentes afetados: [...]
- Exige migração: [sim/não — se sim, em uma frase]

## Referências

- [discussões, RFCs, artigos consultados]
- [PRDs impactados]
- [ADRs relacionados]
````

## Regras do arquivo

- **Número:** três dígitos (`ADR-007`), contador único no projeto, nunca reaproveitado.
- **Nome do arquivo:** `ADR-XXX-titulo-em-kebab-case.md`, com o trecho do título em até ~60 caracteres.
- **Status:** um dos valores definidos em `${CLAUDE_PLUGIN_ROOT}/templates/id-conventions.md` (`Proposto`, `Aceito`, `Substituído por ADR-XXX`, `Descontinuado`).
- **Substituição:** quando uma decisão nova toma o lugar desta, o arquivo antigo **permanece**. Muda apenas o status, e o ADR novo cita o antigo em "Contexto". Ninguém apaga o raciocínio anterior.
- **Datas:** sempre `AAAA-MM-DD`.
- **Atualizar o índice:** criar, aceitar ou substituir um ADR exige atualizar a tabela da seção 5 da proposta na mesma alteração.
