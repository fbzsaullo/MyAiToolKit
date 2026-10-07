# Permissões dos agentes — princípios e regras comuns

Base para o `sdd-setup` gerar as permissões de cada IA. Aqui ficam a mecânica de cada ferramenta e as regras que valem para **qualquer** stack (segredos, git, Docker). As receitas de cada linguagem estão em `${CLAUDE_PLUGIN_ROOT}/stacks/<stack>/permissions.md`.

---

## Como decidir a lista de cada regra

| Pergunta | Lista |
| --- | --- |
| Só lê, ou faz algo local e reversível? | **liberar** (`allow`) |
| Muda algo fora da máquina, mas dá para desfazer? | **perguntar** (`ask` / `prompt`) |
| É irreversível, destrói dados ou expõe segredo? | **bloquear** (`deny` / `forbidden`) |

Três princípios por trás:

- **Menor privilégio.** Regra pelo prefixo exato do comando (`bin/rails test`), nunca a ferramenta inteira (`bin/rails`) e jamais tudo (`Bash`, `Bash(*)`).
- **Excesso de confirmação também é risco.** Uma lista de "perguntar" longa ensina o dev a aprovar sem ler — e aí a proteção some. Libere com generosidade o que é seguro, bloqueie com firmeza o que é perigoso e reserve a pergunta para o que realmente merece pausa.
- **O bloqueio é a camada que ninguém afrouxa.** No Claude Code, listas de todos os escopos se somam e `deny` sempre vence: um bloqueio no projeto protege o time inteiro, qualquer que seja a configuração pessoal de cada um.

E uma regra do toolkit: **nunca bloqueie `docs/`**. O agente lê PRDs, planos e ADRs o tempo todo.

---

## Claude Code — `.claude/settings.json`

### Onde cada configuração mora

| Arquivo | Alcance | Versionado | Uso |
| --- | --- | --- | --- |
| `.claude/settings.json` | projeto | **sim** | política do time — é o único que o setup escreve |
| `.claude/settings.local.json` | projeto, pessoal | não (no `.gitignore`) | ajustes da máquina de cada dev |
| `~/.claude/settings.json` | usuário | não | preferências pessoais para todos os projetos |

### Formato e precedência

```jsonc
{
  "permissions": {
    "allow": ["Bash(bin/rails test *)"],
    "ask":   ["Bash(bin/rails db:migrate *)"],
    "deny":  ["Read(**/.env)"]
  }
}
```

- Regra = `Ferramenta` ou `Ferramenta(especificador)`. `Bash` compara o comando inteiro, com `*` no lugar de qualquer trecho; `Read` e `Edit` usam caminhos no estilo `.gitignore`; `WebFetch` usa `domain:`.
- **Ordem de avaliação: `deny` → `ask` → `allow`.** A primeira lista com uma regra que case decide — especificidade não desempata.
- `deny` não tem exceção ("bloquear tudo menos X" não existe). Para isso, use `allow` específico.

### O espaço antes do `*` importa

É a causa mais comum de regra que não protege o que parece proteger:

- `Bash(git status *)` e `Bash(git status:*)` são equivalentes.
- **O espaço faz parte da regra.** `Bash(ls *)` casa `ls` e `ls -la`, mas **não** `lsof`. `Bash(ls*)`, sem espaço, casaria `lsof` também.
- Por isso `Bash(git push --force *)` **não** casa `git push --force-with-lease` (depois de `--force` vem `-`, não espaço).
- O `*` pode ficar no meio: `Bash(git push * --force)` casa `git push origin main --force`.
- Um `*` final precedido de espaço também casa o comando sozinho, desde que seja o único curinga da regra: `Bash(git push --force *)` pega `git push --force`.

**Consequência:** um bloqueio escrito como prefixo só cobre a ordem de argumentos que você escreveu. Flag no fim, forma curta e apelidos escapam. Para algo destrutivo, cubra as variantes (ver Git).

### Sombra entre listas

Como `ask` é avaliado antes de `allow`, uma regra **larga** em `ask` anula qualquer regra **estreita** em `allow` que case o mesmo comando — a liberada vira código morto.

Exemplo: `Bash(npx *)` em `ask` + `Bash(npx tsc *)` em `allow` → `npx tsc` continua perguntando.

Se um comando coberto por uma regra larga é frequente demais para tolerar a pergunta, a saída **não** é abrir exceção no `allow`: dê a ele um nome que a regra larga não alcance (script no `package.json`, alvo de `Makefile`, executável em `bin/`) e libere esse nome.

**Conferência obrigatória antes de gravar:** para cada regra do `allow`, procure no `ask` e no `deny` uma regra que case o mesmo comando. Encontrou? A do `allow` sai, ou a larga é reescrita.

---

## Codex — `.codex/config.toml` e `.codex/rules/`

O Codex separa duas coisas:

1. **Perfil de permissões** (`.codex/config.toml`): o que os comandos podem ler e escrever no sistema de arquivos e na rede (sandbox).
2. **Regras de comando** (`.codex/rules/*.rules`): quais comandos rodam direto, quais pedem aprovação e quais são proibidos.

A configuração do projeto só é carregada quando o projeto é **confiável** para o Codex. A sintaxe abaixo segue a documentação atual do Codex — confira na versão instalada (`codex --version`) e na documentação oficial se algo não for aceito, e registre o ajuste no `stack-report.md`.

### Perfil de permissões

```toml
# .codex/config.toml — gerado pelo /sdd-setup do MyAiToolKit
default_permissions = "myaitoolkit"

[permissions.myaitoolkit.filesystem]
":minimal" = "read"

[permissions.myaitoolkit.filesystem.":workspace_roots"]
"." = "write"
"**/.env" = "deny"
"**/.env.*" = "deny"
"**/*.pem" = "deny"
"**/*.key" = "deny"
"config/master.key" = "deny"
"config/credentials/*.key" = "deny"

[permissions.myaitoolkit.network]
enabled = true
```

Não misture perfis de permissão com a configuração antiga `sandbox_mode` — escolha um dos dois.

### Regras de comando

```python
# .codex/rules/myaitoolkit.rules — gerado pelo /sdd-setup do MyAiToolKit
# decision: "allow" (roda direto) | "prompt" (pede aprovação) | "forbidden" (bloqueia)

prefix_rule(pattern=["git", "status"], decision="allow")
prefix_rule(pattern=["git", "diff"], decision="allow")
prefix_rule(pattern=["git", "log"], decision="allow")
prefix_rule(pattern=["git", "commit"], decision="prompt")
prefix_rule(pattern=["git", "push"], decision="prompt")
prefix_rule(pattern=["git", "push", "--force"], decision="forbidden")
prefix_rule(pattern=["git", "push", "-f"], decision="forbidden")
prefix_rule(pattern=["git", "reset", "--hard"], decision="forbidden")
prefix_rule(pattern=["rm", "-rf"], decision="forbidden")
```

As regras do Codex casam por **sequência de palavras** a partir do início do comando — o mesmo cuidado com variantes vale aqui: `git push origin main --force` não começa com `["git", "push", "--force"]`. Cubra isso pela sandbox (que limita o estrago) e mantenha `git push` como `prompt`.

### Tradução entre as duas ferramentas

| Claude Code | Codex |
| --- | --- |
| `allow` | `decision="allow"` |
| `ask` | `decision="prompt"` |
| `deny` em comando | `decision="forbidden"` |
| `deny` em `Read(...)` de arquivo | `"caminho" = "deny"` no perfil de filesystem |

Os `permissions.md` de cada stack trazem a receita no formato do Claude; o setup traduz para o Codex com esta tabela.

---

## Bloqueio universal de segredos — entra em todo projeto

Arquivos que guardam segredo em texto puro. Valem para qualquer stack.

```jsonc
"deny": [
  // variáveis de ambiente
  "Read(**/.env)",
  "Read(**/.env.*)",

  // chaves e certificados
  "Read(**/*.pem)",
  "Read(**/*.key)",
  "Read(**/*.pfx)",
  "Read(**/*.p12)",
  "Read(**/id_rsa*)",
  "Read(**/id_ed25519*)",

  // nuvem e infraestrutura
  "Read(**/.aws/credentials)",
  "Read(**/.kube/config)",
  "Read(**/*.kubeconfig)",
  "Read(**/terraform.tfstate)",
  "Read(**/terraform.tfstate.*)",
  "Read(**/*.tfvars)",

  // tokens de registro de pacotes
  "Read(**/.npmrc)",
  "Read(**/.pypirc)",
  "Read(**/.gem/credentials)",
  "Read(**/.docker/config.json)",

  // comandos destrutivos
  "Bash(rm -rf *)",
  "Bash(git reset --hard *)"
]
```

- **`terraform.tfstate`** é esquecido com frequência e é dos piores: senhas de banco e chaves de API em texto puro.
- **`.npmrc`, `.pypirc`, `.gem/credentials`** guardam token de publicação. Ler é o primeiro passo para vazar.
- **`.env.example`** também cai em `.env.*`. Se o time quiser que o agente leia o exemplo, libere explicitamente com `Read(.env.example)` no `allow` **depois** de conferir que ele não contém valor real — e lembre que `deny` vence; nesse caso, troque o padrão `.env.*` por entradas nomeadas (`.env.local`, `.env.production`…).

Cada perfil de stack acrescenta os segredos próprios (em Rails: `config/master.key`, `config/credentials/*.key`).

---

## Git — vale para qualquer stack

```jsonc
"allow": [
  "Bash(git status *)",
  "Bash(git diff *)",
  "Bash(git log *)",
  "Bash(git show *)",
  "Bash(git branch *)",
  "Bash(git fetch *)",
  "Bash(git merge-base *)",
  "Bash(git rev-parse *)",
  "Bash(git add *)",
  "Bash(git stash *)"
],
"ask": [
  "Bash(git commit *)",        // sempre ask: o kit não commita
  "Bash(git push *)",
  "Bash(git merge *)",
  "Bash(git rebase *)",
  "Bash(git checkout *)",
  "Bash(gh pr create *)",
  "Bash(gh pr merge *)"
],
"deny": [
  "Bash(git push --force *)",
  "Bash(git push -f *)",
  "Bash(git push * --force)",
  "Bash(git push * --force *)",
  "Bash(git push * -f)",
  "Bash(git push * -f *)",
  "Bash(git reset --hard *)",
  "Bash(git clean -fdx *)"
]
```

`git fetch`, `git merge-base` e `git rev-parse` ficam liberados porque o `/code-review` precisa deles para descobrir a branch base e montar o diff; nenhum altera o trabalho local.

**`git commit`:** sempre em `ask`. As skills do MyAiToolKit nunca commitam: entregam a mensagem pronta, em texto, no padrão de `git.commit` do `config.yml`. O `ask` cobre o caso de o usuário pedir um commit ao agente fora das skills: o pedido é dele, e a confirmação continua. Quem quiser liberar para si usa o `.claude/settings.local.json`, que não é versionado.

**Seis regras para bloquear force push**, por causa do espaço antes do `*`:

| Comando | Regra que bloqueia |
| --- | --- |
| `git push --force`, `git push --force origin main` | `git push --force *` |
| `git push -f origin main` | `git push -f *` |
| `git push origin main --force` | `git push * --force` |
| `git push origin --force main` | `git push * --force *` |
| `git push origin main -f` | `git push * -f` |
| `git push origin -f main` | `git push * -f *` |

**`--force-with-lease` continua possível, de propósito.** Ele não casa `git push --force *` (vem `-` depois de `--force`) e cai em `git push *`, que pergunta. Time que queira bloqueá-lo também acrescenta `Bash(git push --force-with-lease *)` ao `deny`.

**Brecha conhecida:** `git push origin +main` força o push pelo `+` do refspec e escapa das seis regras. `Bash(git push * +*)` cobre, ao custo de falsos positivos. O padrão do toolkit é não incluir; decisão do time.

---

## Docker e infraestrutura local

```jsonc
"allow": [
  "Bash(docker compose up *)",
  "Bash(docker compose stop *)",
  "Bash(docker compose start *)",
  "Bash(docker compose logs *)",
  "Bash(docker compose ps *)",
  "Bash(docker ps *)"
],
"ask": [
  "Bash(docker compose down *)",
  "Bash(docker build *)",
  "Bash(docker push *)",
  "Bash(kamal deploy *)"
],
"deny": [
  "Bash(docker system prune *)",
  "Bash(docker volume rm *)",
  "Bash(docker volume prune *)",
  "Bash(kubectl delete *)",
  "Bash(terraform apply *)",
  "Bash(terraform destroy *)"
]
```

**`docker compose down` pergunta.** Com `-v` (ou `--volumes`), ele apaga os volumes — banco de desenvolvimento, dados de seed. Sem a flag, só remove containers e redes. Para parar o ambiente no dia a dia, `stop`/`start` bastam e não tocam em nada persistente.

**Por que não bloquear só o `-v`?** A flag pode aparecer em qualquer posição (`down --remove-orphans -v`, `-f compose.yml down -v`, `--volumes`), e cobrir todas as variantes exigiria muitas regras — a que faltasse seria justamente a que passaria. Estreitar o que é liberado resolve com uma linha.

**`docker volume rm` / `prune` bloqueados:** caminho mais curto para a mesma perda. `docker system prune` cobre também a forma com `--volumes`, pelo prefixo.

**Brecha conhecida:** `docker compose up -V` recria os volumes anônimos. Volume nomeado não é afetado, por isso `up` fica liberado; projeto que guarda estado em volume anônimo deve mover `up` para `ask`.

**Terraform e deploy:** `terraform apply` mexe em infraestrutura real e custa dinheiro — bloqueado. Até `ask` é arriscado (a confirmação vira reflexo). Time que faz infraestrutura com agente deve mover para `ask` de forma consciente, nunca para `allow`. Deploy (`kamal deploy`, `cap deploy`) fica em `ask`.

---

## Antes de gravar

- [ ] Bloqueio universal + segredos da stack incluídos
- [ ] Comandos liberados são os **reais** do projeto (do `config.yml`), com o gerenciador certo
- [ ] Nenhuma regra do `allow` sombreada pelo `ask`/`deny`
- [ ] Escolhas do usuário aplicadas (migrations); `git commit` em `ask`
- [ ] Mescla não removeu nenhuma regra existente; divergências listadas no relatório
- [ ] `.claude/settings.local.json` no `.gitignore` (ou linha mostrada ao usuário)
- [ ] `docs/` não aparece em nenhum bloqueio
