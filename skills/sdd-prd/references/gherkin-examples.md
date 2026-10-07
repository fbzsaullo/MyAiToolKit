# Cenários Gherkin de referência

Modelos para a seção de critérios de aceite do PRD. Cada exemplo mostra uma situação típica — caminho feliz com erros, disputa por recurso, tabela de exemplos, integração externa e regras por perfil — sempre com os IDs no lugar certo.

**Formato que vale para todos:**
- Palavras-chave no idioma do documento; em pt-BR: `Funcionalidade`, `Cenário`, `Esquema do Cenário`, `Dado`, `E`, `Quando`, `Então`, `Mas`, `Exemplos`
- `[CA-XX]` entre colchetes no título de **todo** cenário
- `(RN-XX)` no fim do passo que exercita aquela regra
- `(ADR-XXX)` no título do cenário quando o comportamento esperado vem de uma decisão de arquitetura

---

## 1 — Fluxo simples: sucesso e recusas

```gherkin
# language: pt
Funcionalidade: Agendamento de consulta pelo paciente
  Para não depender do telefone da recepção
  Como paciente cadastrado
  Quero marcar consultas pelo site

  Cenário [CA-01]: Paciente agenda em horário livre
    Dado que estou autenticado como paciente
    E a agenda da Dra. Ana tem o horário de 14:00 livre amanhã (RN-01)
    Quando escolho esse horário e confirmo
    Então a consulta fica registrada como "Confirmada"
    E recebo a confirmação por e-mail
    E o horário deixa de aparecer como livre para outros pacientes

  Cenário [CA-02]: Paciente tenta agendar com menos de 2 horas de antecedência
    Dado que são 13:10
    E a agenda da Dra. Ana tem o horário de 14:00 livre hoje
    Quando tento agendar esse horário
    Então o agendamento é recusado (RN-02)
    E vejo a mensagem "Agendamentos exigem 2 horas de antecedência"

  Cenário [CA-03]: Paciente com duas faltas no mês tenta agendar
    Dado que faltei a duas consultas neste mês sem avisar (RN-03)
    Quando tento agendar uma nova consulta
    Então o agendamento é recusado
    E sou orientado a falar com a recepção
```

---

## 2 — Dois usuários disputando o mesmo recurso

Cenários de concorrência costumam depender de uma decisão de arquitetura — por isso o ADR aparece no título.

```gherkin
# language: pt
Funcionalidade: Reserva do último horário disponível

  Cenário [CA-04]: Reserva confirmada quando o horário está livre
    Dado que a agenda da Dra. Ana tem apenas o horário das 16:00 livre (RN-01)
    Quando o paciente Bruno confirma esse horário
    Então a consulta de Bruno fica "Confirmada"
    E a agenda passa a não ter horários livres

  Cenário [CA-05]: Dois pacientes confirmam o mesmo horário ao mesmo tempo (ADR-002)
    Dado que a agenda da Dra. Ana tem apenas o horário das 16:00 livre (RN-04)
    E os pacientes Bruno e Carla confirmam esse horário no mesmo instante
    Quando o sistema processa as duas confirmações
    Então exatamente uma consulta é confirmada
    E a outra pessoa recebe "Este horário acabou de ser ocupado"
    E não existe nenhuma consulta duplicada no horário

  Cenário [CA-06]: Horário reservado e não confirmado é liberado
    Dado que Carla reservou o horário das 16:00 e não concluiu a confirmação
    E se passaram 10 minutos desde a reserva (RN-05)
    Quando outro paciente consulta a agenda
    Então o horário das 16:00 aparece como livre
```

---

## 3 — Mesma regra, várias combinações (Esquema do Cenário)

Quando o comportamento é igual e só os dados mudam, use uma tabela em vez de repetir cenários.

```gherkin
# language: pt
Funcionalidade: Valor da consulta por convênio

  Esquema do Cenário [CA-07]: Valor cobrado conforme o plano do paciente
    Dado que o paciente tem o plano "<plano>"
    E a consulta é de "<especialidade>"
    Quando a consulta é confirmada
    Então o valor cobrado do paciente é R$ <valor> (RN-06)

    Exemplos:
      | plano        | especialidade  | valor  |
      | Particular   | Clínico geral  | 250.00 |
      | Particular   | Cardiologia    | 400.00 |
      | Convênio Ouro| Clínico geral  | 0.00   |
      | Convênio Ouro| Cardiologia    | 50.00  |
```

---

## 4 — Integração com sistema de terceiros

```gherkin
# language: pt
Funcionalidade: Verificação de elegibilidade no convênio

  Cenário [CA-08]: Convênio confirma elegibilidade
    Dado que o paciente informou a carteirinha "0099887766"
    E o serviço do convênio está respondendo (RN-07)
    Quando o paciente confirma a consulta
    Então a elegibilidade é registrada como "Aprovada"
    E a consulta segue para confirmação

  Cenário [CA-09]: Serviço do convênio indisponível
    Dado que o paciente informou a carteirinha "0099887766"
    E o serviço do convênio responde com erro 503
    Quando o paciente confirma a consulta
    Então a consulta fica "Aguardando elegibilidade"
    E uma nova verificação é agendada para 15 minutos depois (RN-08)
    E a falha é registrada no log com o identificador da requisição
    Mas após 3 tentativas sem sucesso a recepção é avisada (RN-09)
```

---

## 5 — Resultado diferente por perfil de acesso

```gherkin
# language: pt
Funcionalidade: Cancelamento de consulta

  Cenário [CA-10]: Recepcionista cancela consulta com motivo
    Dado que estou autenticada como recepcionista
    E existe a consulta #812 "Confirmada"
    Quando cancelo a consulta informando o motivo "Médica de licença"
    Então a consulta passa para "Cancelada pela clínica"
    E o paciente é avisado por e-mail e mensagem
    E o horário volta a ficar livre (RN-10)

  Cenário [CA-11]: Paciente cancela com menos de 24 horas
    Dado que estou autenticado como paciente
    E minha consulta é amanhã às 09:00 e agora são 15:00
    Quando tento cancelar pelo site
    Então o cancelamento é recusado (RN-11)
    E vejo o telefone da recepção para cancelamentos tardios

  Cenário [CA-12]: Recepcionista tenta cancelar consulta já realizada
    Dado que estou autenticada como recepcionista
    E a consulta #640 está "Realizada"
    Quando tento cancelá-la
    Então a operação é bloqueada (RN-12)
    E sou orientada a abrir um pedido de estorno com o financeiro
```

---

## Erros frequentes

- ❌ **Cenário sem `[CA-XX]`** — o plano não consegue citar e a rastreabilidade quebra.
- ❌ **Cenário descrevendo cliques** — "clico no botão azul" é teste de interface, não regra de negócio. Descreva o comportamento.
- ❌ **Um cenário provando tudo** — vários `Então` sobre assuntos diferentes. Separe, ou assuma que ele prova várias regras e cite todas.
- ❌ **Código no meio do texto** — "Dado que `appointment.status = 1`" é implementação, não negócio.
- ❌ **Cenário que depende de outro** — "continuando o CA-04…". Cada cenário precisa rodar sozinho.
- ❌ **Título vago** — "paciente agenda com sucesso" não diz o que diferencia este cenário dos outros.

## O que funciona

- ✅ **Uma regra principal por cenário** — quando o teste quebrar, fica óbvio qual regra foi violada.
- ✅ **`Dado` descreve estado**, não ação: "Dado que existe a consulta", não "Dado que eu crio a consulta".
- ✅ **Um `Quando` por cenário**, com uma ação só.
- ✅ **`Então` verificável** — "a consulta fica Confirmada" pode ser checado; "o sistema funciona" não.
- ✅ **`(RN-XX)` nos passos que provam regras** e **`(ADR-XXX)` no título** quando o comportamento depende de arquitetura (concorrência, consistência, falhas).
- ✅ **Cobertura mínima:** caminho feliz, uma ou duas variações relevantes e os erros mais prováveis.
