# Roteiro do code review

O "script" que a skill monta para cada review. É montado **para o diff em questão**: os checklists das stacks tocadas, as convenções do projeto e os critérios da história (se houver).

## 1. Leitura de reconhecimento

Antes de apontar qualquer coisa:

1. Leia a lista de commits e as mensagens: o que o autor quis fazer?
2. Leia o diff por inteiro uma vez, sem anotar, para entender a forma da mudança.
3. Agrupe os arquivos por papel (dados, regra, entrada, interface, testes, configuração, gerados).
4. Identifique as stacks tocadas (um diff pode ter Ruby, ERB, JS e SQL) e carregue os checklists de cada uma.
5. Se houver história, tenha os critérios de aceite à vista.

## 2. Eixos

Percorra o diff eixo por eixo. Cada problema real vira um `CR-XX`; pergunta atendida não precisa ser mencionada.

### A — Aderência à história *(só com card)*

| Pergunta | Se "não" (severidade / quadrante típico) |
| --- | --- |
| Cada critério de aceite tem implementação no diff? | Bloqueante / Q1 |
| Cada critério tem um teste que o exercita? | Importante a Bloqueante / Q1 |
| O diff faz algo que a história não pede (escopo extra)? | Importante / Q2 — pedir justificativa |
| O comportamento bate com o texto do card, e não com uma interpretação livre? | Bloqueante (diverge) / Importante (ambíguo) |

Monte a **tabela de cobertura**: critério → onde está no código → teste → situação.

### B — Correção

- A lógica faz o que parece fazer? Teste mentalmente com valores de borda (zero, vazio, nulo, limite, fuso horário, concorrência).
- Erros são tratados no padrão do projeto? Algo engole exceção em silêncio?
- Mudanças de dados (migrations, backfill) são seguras e reversíveis?
- Efeitos colaterais (e-mail, job, chamada externa) acontecem uma vez só e no momento certo (após o commit)?

### C — Testes

- Há teste para o comportamento novo e para os erros principais?
- Os testes falhariam se o código estivesse errado (não são tautológicos)?
- Testes desligados, dependentes de ordem, com `sleep`, com dublês escondendo o que deveria ser testado?
- Os testes rodam? (Se o usuário permitir, rode só os relacionados ao diff.)

### D — Qualidade

- Checklist de qualidade da stack (`stacks/<stack>/review-checklist.md`).
- Convenções do `AGENTS.md`/`CLAUDE.md`.
- Duplicação, código morto, saída de depuração, nomes, acoplamento.

### E — Segurança

- Checklist de segurança da stack (`stacks/<stack>/security-checklist.md`), ou o universal de `stacks/_generic/profile.md`.
- Só sobre as linhas do diff; não é auditoria do sistema inteiro.

### F — Operação *(quando o diff toca algo de produção)*

- Logs úteis e sem dados pessoais nos pontos novos.
- Migrations e configuração que exigem cuidado no deploy (ordem, feature flag, variáveis de ambiente novas documentadas).

## 3. Ferramentas

De `code_review.tools` no `config.yml`, sempre:
- **com confirmação** do usuário;
- **só nos arquivos do diff** (`{files}` no comando), ou nos testes relacionados (`{spec_files}`);
- com o resultado tratado como **evidência**: alerta de ferramenta é confirmado no código antes de virar `CR-XX`; alerta de pura formatação não vira apontamento (no máximo, um item Q3 "rode o formatador").

Sem `config.yml`, sugira ferramentas pelo perfil da stack e pergunte se pode rodar.

## 4. Classificar

Para cada `CR-XX`: severidade + quadrante, conforme `quadrants.md`. Revise o conjunto no final:
- há Q1 demais? Reavalie — se tudo é urgente, nada é;
- algum Bloqueante fora do Q1? Escreva o porquê;
- todo Q2 tem sugestão de registro (card, tarefa, ADR)?

## 5. Escrever

- **Evidência:** `arquivo:linha` (ou intervalo), trecho curto quando ajuda.
- **Por quê:** a consequência concreta, não "é boa prática".
- **Caminho:** uma correção defensável (não precisa ser a única).
- **Tom:** objetivo; com colegas, cordial e específico — comente o código, não a pessoa.
- **Reconheça o que está bom** no resumo: ajuda o autor a saber o que manter.

### Comentários para colar (modo colega)

Um por apontamento de Q1, Q2 e Q3 (Q4 só se o usuário pedir), no formato:

```
**[Q1 · Bloqueante] Interpolação de parâmetro na consulta**
`app/models/pedido.rb:42` — `where("status = '#{params[:status]}'")` permite SQL injection.
Sugestão: `where(status: params[:status])` (ou um `enum` com lista permitida).
```

### Checklist antes do PR (modo próprio)

Lista curta e acionável: os Q1 e Q3 a resolver, os Q2 a registrar, os comandos a rodar (lint, testes) e a descrição do PR a escrever (citando a história e o que foi testado).

## 6. Não fazer

- Criticar código fora do diff.
- Repetir o que o linter já diz.
- Impor preferência pessoal que o projeto não declara.
- Propor reescrita ampla dentro do review (vira Q2 com sugestão de card).
- Alterar código, publicar comentários no PR ou fazer push.
