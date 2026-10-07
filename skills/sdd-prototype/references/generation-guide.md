# Geração — quando ainda não existe protótipo

Como produzir um protótipo navegável a partir do PRD.

**Divisão de responsabilidades:** esta skill define **quais telas existem, que estados cada uma tem e o que aparece nelas**. A parte visual — tipografia, cores, espaçamento, composição — é passada para uma skill de frontend do ambiente.

---

## De onde tirar as respostas (antes de perguntar)

### 1. PRD — telas e estados

| Seção do PRD | O que ela revela |
| --- | --- |
| Quem usa (5) | Quantos perfis de interface existem; se há área administrativa à parte |
| Fluxos (7) | A sequência de telas; cada decisão no fluxo vira um desvio de navegação |
| Regras (8) | Validações, campos obrigatórios, controles desabilitados, mensagens |
| Critérios de aceite (9) | **Os estados.** Todo cenário de erro descreve um estado que precisa existir |
| Permissões (10) | Telas ou elementos que dependem do perfil; estado "sem permissão" |
| Estados da entidade (12) | Cada estado da entidade costuma ganhar uma representação visual |

Os cenários Gherkin são a fonte mais desperdiçada. "Paciente tenta agendar com menos de 2 horas → mensagem de antecedência" **já é** a especificação de um estado de tela. Percorrer todos os cenários entrega a lista de estados quase pronta.

### 2. Arquitetura e `docs/sdd/config.yml` — limites

- Tecnologia de frontend e biblioteca de componentes declaradas
- Renderização no servidor com Hotwire, SPA ou app mobile — muda o jeito de carregar e navegar
- Acessibilidade, idiomas, tema escuro
- Qualidade prioritária: se desempenho pesa, o protótipo evita padrões caros

### 3. Repositório — herdar, não reinventar

Procure antes de gerar:

- Tokens e tema (`tailwind.config.js`, `app/assets/tailwind/application.css`, variáveis CSS)
- Componentes prontos (`app/components/`, partials compartilhados, pasta `ui/`)
- Telas de funcionalidades anteriores e o layout principal

Se existem, siga-os. Um protótipo que destoa das telas atuais só gera retrabalho e discussão.

### 4. Perguntas — só o que sobrou

Com PRD e arquitetura bons, sobram duas ou três.

---

## Tipos de interface

Identificar o tipo cedo evita, por exemplo, entregar um painel corporativo quando o PRD descrevia um app para o público.

**Painel administrativo** — operadores internos, uso longo e diário, muito dado.
Menu lateral fixo; tabelas densas; ações em lote, filtros e ordenação; carregamento bem tratado em listas grandes; texto curto e neutro.

**Ferramenta de operação** — tarefa repetitiva, usuário treinado, rapidez acima de descoberta.
Fluxo linear ou em etapas; atalhos de teclado quando ajudam; pouco onboarding; confirmação apenas em ação destrutiva.

**Produto para o público / loja** — visitante casual, muitas vezes de primeira viagem, foco em conversão.
Pouca densidade e hierarquia forte; imagens em destaque; progresso visível em fluxos de compra; mensagens de erro gentis e com saída clara; linguagem acessível.

**Portal de autoatendimento** — cliente externo consultando os próprios dados, uso esporádico.
Navegação evidente; estado vazio que ensina o que fazer; nada de jargão interno.

**Site institucional** — conteúdo quase estático, objetivo de comunicar.
Tipografia organiza a página; poucos estados dinâmicos; formulários pontuais.

---

## Perguntas — seis temas

Pule o que as fontes já responderam e não faça mais que três temas de uma vez.

**Tipo de interface**
> Esse sistema está mais para painel administrativo, ferramenta de operação, produto para o público, portal de autoatendimento ou site institucional?

Pule quando perfis e fluxos do PRD já deixam claro.

**Dispositivo**
> O uso principal é no computador, no celular, só no celular ou nos dois por igual?

Pule quando a arquitetura define. "Responsivo" costuma ser resposta automática — confirme qual é o dispositivo **mais usado de fato**.

**Fidelidade**
> Você quer um wireframe (estrutura, campos e estados, sem acabamento visual) ou algo próximo do visual final?

**Pergunte sempre.** Wireframe valida fluxo rápido; alta fidelidade vira referência de implementação.

**Identidade visual** — três caminhos:
- **Há marca:** peça uma referência concreta (site, manual, arquivos) e extraia dela. Não pergunte cores.
- **Há design system no repositório:** detecte e siga, sem perguntar.
- **Não há nada:** jamais pergunte "que cores você quer?" — a resposta costuma ser vaga e o resultado genérico. Ofereça direções nomeadas:

> Como não há identidade definida, sugiro três caminhos:
>
> **A. Sóbrio e compacto** — cinzas frios, fonte enxuta, bordas discretas. Combina com ferramenta de uso intenso.
> **B. Leve e arejado** — bastante espaço, fonte maior, uma cor de destaque. Combina com produto para o público.
> **C. Institucional** — azul de alto contraste, visual conservador. Combina com cliente corporativo tradicional.

**Densidade e tom**
> Muita informação por tela, estilo sistema de gestão, ou mais espaçada, estilo app? E os textos, formais ou descontraídos?

Pule quando o tipo de interface já responde.

**Restrições**
> Há exigência de acessibilidade, tema escuro, vários idiomas ou alguma biblioteca de componentes obrigatória?

Pule quando a arquitetura já lista.

---

## Passando o visual adiante

A skill monta um briefing e entrega para quem cuida do visual.

```
Tipo de interface: [painel | operação | público | portal | institucional]
Dispositivo principal: [computador | celular | só celular | ambos]
Fidelidade: [wireframe | alta]
Tecnologia: [da arquitetura/config — ex.: Rails + Hotwire + Tailwind]
Biblioteca obrigatória: [se houver]
Tokens existentes: [arquivo do repositório, se houver]
Direção visual: [A/B/C escolhida ou marca do cliente]
Densidade: [alta | média | baixa]
Tom dos textos: [formal | neutro | descontraído]
Restrições: [acessibilidade, tema escuro, idiomas]

Telas:
- UI-01 [nome] — [para que serve] — estados: default, vazio, carregando, erro
- UI-02 [nome] — [para que serve] — estados: default, ocupado, antecedencia
[...]

Componentes repetidos:
- [componente] — em UI-01 e UI-04 — estados: [...]
```

**Com skill de frontend disponível:** entregue o briefing e não reescreva as escolhas visuais dela — o papel desta skill termina na estrutura.

**Sem skill de frontend:** gere HTML simples, focado em estrutura e estados, e escreva no cabeçalho:

> **Fidelidade:** wireframe. Nenhuma skill de design visual estava disponível — o protótipo cobre estrutura, campos e estados, sem acabamento final.

Um wireframe correto é mais útil que uma alta fidelidade mal feita.

---

## O que entra e o que não entra no protótipo

**Sempre**
- uma tela para cada `UI-XX`;
- **todos** os estados previstos, não só o caminho feliz — erro e vazio são justamente o que costuma faltar e o que mais vira bug;
- navegação funcionando entre as telas, quando o formato permitir;
- dados de exemplo plausíveis e coerentes com o domínio.

**Nunca**
- tela que o PRD não pediu — se parece faltar uma, aponte como lacuna;
- regra de negócio nova — o protótipo materializa `RN-XX` existentes;
- dados enganosos (valores absurdos, "lorem ipsum" onde o texto importa).

---

## Antes de encerrar a geração

- [ ] Todo `CA-XX` acontece em alguma tela ou está declarado como cenário de backend
- [ ] Toda `RN-XX` visível aparece em alguma tela
- [ ] Cada tela tem os estados mínimos do seu tipo (`screen-states.md`)
- [ ] Componentes repetidos estão listados como reutilizáveis
- [ ] Tokens usados estão na seção 2 da SPEC-UI
- [ ] Nenhuma tela sem respaldo no PRD
- [ ] Fidelidade declarada com honestidade no cabeçalho
