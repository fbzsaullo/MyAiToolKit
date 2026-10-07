# Ingestão — como ler cada tipo de protótipo

Passo a passo para extrair a especificação de interface de um protótipo que já existe.

**Ordem sugerida:** views/HTML no repositório → imagens → Figma via MCP → export de ferramentas de protótipo.

**Regra para qualquer formato:** terminada a extração, diga **o que você não conseguiu ver** antes de fazer perguntas. Uma extração incompleta que não admite as lacunas produz uma SPEC-UI com aparência de completa — e esse é o pior resultado possível.

---

## Views no repositório (Rails) — a fonte mais rica

Quando o protótipo já é código Rails (ou as telas já existem parcialmente), o agente lê tudo direto.

| O que extrair | Onde procurar |
| --- | --- |
| Lista de telas e rotas | `config/routes.rb` (e `bin/rails routes` se for permitido rodar) + `app/views/<recurso>/` |
| Layout comum | `app/views/layouts/` |
| Campos e controles | `form_with`, `f.text_field`, `f.select`, `button_to`, `link_to` |
| Componentes reaproveitados | `app/components/` (ViewComponent), `app/views/components/` (Phlex), partials `_*.html.erb` renderizados em várias telas |
| Estados já implementados | Condicionais na view (`if @consultas.empty?`, `rescue`, `flash[:alert]`), `turbo_frame_tag` com `loading`, templates `*.turbo_stream.erb`, `render :new, status: :unprocessable_entity` |
| Comportamento dinâmico | Controllers Stimulus em `app/javascript/controllers/` (`data-controller`, `data-action`) |
| Tokens visuais | `tailwind.config.js` / `app/assets/tailwind/application.css`, variáveis CSS, `app/assets/stylesheets/` |
| Navegação | `link_to`, `redirect_to` nos controllers, `button_to`, menus no layout |

**Procedimento**
1. Leia as rotas primeiro — elas dão o inventário inteiro de uma vez.
2. Para cada rota de tela (`index`, `show`, `new`, `edit` e ações customizadas), abra a view e os partials que ela renderiza.
3. Anote campos, condicionais de estado e para onde cada ação leva.
4. Componentes ou partials usados por mais de uma tela vão para a seção de reutilizáveis.
5. Leia a configuração de tema para os tokens.

**Outros frontends no mesmo repositório** (React, Vue, Svelte em `app/javascript/` ou em pasta própria): mesma lógica — arquivo de rotas do router, componentes de página, renderização condicional (`{loading && …}`), arquivos de tema.

**Limitações a declarar**
- **Estado que ainda não existe no código.** Protótipo estático raramente trata erro. O estado provavelmente é necessário: derive do PRD e marque a origem como "Derivado do PRD".
- **O porquê das regras.** O código mostra que o campo é obrigatório, não o motivo. O vínculo com `RN-XX` vem da leitura do PRD.
- **Dados de exemplo.** Seeds e valores fixos na view não são regra de negócio.

---

## Imagens (PNG, JPG, prints)

Rendem mais do que se imagina: layout, hierarquia, campos, textos e estados visíveis.

| O que dá para extrair | Confiança |
| --- | --- |
| Layout e hierarquia | Alta |
| Campos, rótulos e botões | Alta |
| Textos visíveis | Alta |
| Navegação interna (menus, abas, trilhas) | Média |
| Cores | Aproximada — "verde escuro", nunca o código exato |
| Tipografia | Aproximada — com ou sem serifa, peso; não a família exata |
| Espaçamentos | Baixa — não tente medir pixel em imagem |

**Procedimento**
1. Uma imagem de cada vez, atribuindo `UI-XX` na ordem recebida.
2. Para cada uma: finalidade, campos, controles, textos e estado aparente.
3. Ao final, mostre a lista e **peça confirmação de nomes e ordem**.
4. Pergunte a navegação — imagem não carrega essa informação.

**Limitações a declarar sempre**
- Para onde cada ação leva
- Estados que não foram capturados (se só veio o estado padrão, erro, vazio e carregando não existem no material)
- Valores exatos de cor e fonte
- Comportamento dinâmico (hover, validação ao digitar, rolagem infinita)
- Conteúdo cortado em prints de telas longas

**Dica para o usuário** (sem insistir): se o protótipo tem prints dos estados de erro e vazio, vale enviá-los — é o material que mais falta e o que mais gera retrabalho.

---

## Figma via MCP

Exige o MCP do Figma conectado. Sem ele, o link **não serve**: o conteúdo é um canvas atrás de login, não HTML legível.

| O que extrair | Onde |
| --- | --- |
| Lista de telas | Frames de nível mais alto |
| Estados | Variantes ou nomes de frame (`Agenda / vazio`, `Agenda / erro`) |
| Componentes | Biblioteca e instâncias |
| Tokens | Estilos publicados (cor, texto, efeito) — valores exatos |
| Hierarquia | Árvore de camadas |
| Navegação | Conexões do protótipo interativo, se configurado |

**Procedimento**
1. Frames de topo → inventário.
2. Variantes → estados.
3. Estilos publicados → tokens.
4. Conexões do protótipo interativo → navegação.
5. Pergunte o que a organização do arquivo não deixa claro.

**Limitações a declarar**
- Arquivo bagunçado (sem nomes consistentes): pergunte o que é tela, rascunho ou variante, em vez de adivinhar.
- Validações e regras condicionais não ficam no Figma.
- Telas antigas e exploratórias convivem com as atuais: confirme o que entra.

**Sem o MCP**, ofereça alternativas:

> Não tenho acesso direto ao Figma neste ambiente. Dá para exportar as telas em PNG e anexar aqui, ou colar o código do Dev Mode das telas principais — o primeiro é mais rápido, o segundo traz os valores exatos.

---

## Ferramentas que geram protótipo com IA

Ferramentas que geram telas a partir de texto normalmente oferecem exportar o código para um repositório.

**Caminho preferido: código exportado.** Com o código clonado localmente, a ingestão é igual à de "views no repositório" — o melhor cenário. Sugira:

> Se o protótipo pode ser exportado para o GitHub, me passe o caminho da pasta clonada. A extração fica muito mais precisa do que pelo link de visualização, e o código fica versionado como referência para a implementação.

**Caminho alternativo: link publicado.** Costuma ser uma SPA: o HTML inicial é quase vazio e o conteúdo surge via JavaScript, então um fetch simples traz pouco. Com ferramenta de navegação no ambiente, dá para navegar e ler o DOM renderizado; sem ela, declare a limitação e peça export ou prints.

**Cuidados próprios desse tipo de protótipo**
- Muitos dados fictícios — não são requisito.
- Telas que ninguém pediu — cruze com o PRD antes de aceitar como escopo.
- Quase sempre só o caminho feliz — os estados de erro precisam vir do PRD.

---

## Modo misto — protótipo incompleto

Situação mais frequente: as telas principais existem, os estados de erro e as telas administrativas não.

1. Faça a ingestão de tudo o que existe, com o guia do formato.
2. Cruze com o PRD para descobrir o que falta.
3. **Mostre as lacunas antes de gerar qualquer coisa.**
4. Para cada lacuna, o usuário decide: gerar, ajustar o PRD ou deixar fora do escopo.
5. O que for gerado entra com origem "Gerado" — nunca misturado com "Protótipo".

A distinção importa porque uma tela gerada não passou por design nem por aprovação de quem pediu.

---

## Antes de encerrar a ingestão

- [ ] Toda tela do material tem `UI-XX`
- [ ] Nomes e ordem confirmados pelo usuário
- [ ] Navegação mapeada (perguntada quando não dava para extrair)
- [ ] Estados de cada tela listados, com origem
- [ ] Componentes repetidos identificados
- [ ] Tokens extraídos, com "aproximado" onde couber
- [ ] Lacunas escritas, nenhuma preenchida por suposição
- [ ] Cruzamento com o PRD feito nos dois sentidos
