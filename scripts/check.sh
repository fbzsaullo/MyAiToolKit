#!/usr/bin/env bash
# Verificacoes de consistencia do MyAiToolKit. Roda localmente e no CI.
#
#   bash scripts/check.sh
#
# Sai com codigo 1 se encontrar qualquer problema.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1

errors=0
fail() {
  echo "ERRO: $*" >&2
  errors=$((errors + 1))
}

markdown_files() {
  find . -type f -name '*.md' -not -path './.git/*' -not -path './node_modules/*' -not -path './.agents/*' | sort
}

# Imprime "numero_da_linha<TAB>linha" das linhas FORA de blocos de codigo cercados.
# Segue a regra do CommonMark: a cerca de fechamento usa o mesmo caractere e pelo
# menos o mesmo numero de crases da abertura. Ao fim, avisa cerca nao fechada.
outside_fences() {
  awk '
    {
      line = $0
      if (match(line, /^ {0,3}`{3,}/)) {
        run = substr(line, RSTART, RLENGTH)
        gsub(/ /, "", run)
        n = length(run)
        rest = substr(line, RSTART + RLENGTH)
        if (open == 0) { open = n; next }
        if (n >= open && rest ~ /^[ \t]*$/) { open = 0; next }
        next
      }
      if (open == 0) print NR "\t" line
    }
    END { if (open > 0) print "UNCLOSED_FENCE\t" open > "/dev/stderr" }
  ' "$1"
}

echo "== 1. Skills: frontmatter =="
for dir in skills/*/; do
  name="$(basename "$dir")"
  file="$dir/SKILL.md"
  if [ ! -f "$file" ]; then
    fail "$dir sem SKILL.md"
    continue
  fi
  if [ "$(head -n 1 "$file")" != "---" ]; then
    fail "$file: frontmatter precisa comecar na primeira linha com ---"
    continue
  fi
  frontmatter="$(awk 'NR == 1 { next } /^---$/ { exit } { print }' "$file")"
  fm_name="$(printf '%s\n' "$frontmatter" | sed -n 's/^name:[[:space:]]*//p' | head -n 1)"
  if [ "$fm_name" != "$name" ]; then
    fail "$file: name '$fm_name' diferente da pasta '$name'"
  fi
  if ! printf '%s\n' "$frontmatter" | grep -q '^description:[[:space:]]*[^[:space:]]'; then
    fail "$file: description ausente ou vazia"
  fi
  # Em YAML, ": " ou " #" dentro de um valor sem aspas quebra o parse do frontmatter.
  while IFS= read -r line; do
    key="${line%%:*}"
    value="${line#*: }"
    case "$value" in \"*|\'*) continue ;; esac
    if printf '%s' "$value" | grep -q ': \| #'; then
      fail "$file: valor de '$key' tem ': ' ou ' #' sem aspas (YAML invalido)"
    fi
  done <<< "$frontmatter"
done

echo "== 1b. Agentes do plugin: frontmatter =="
for file in agents/*.md; do
  [ -e "$file" ] || continue
  name="$(basename "$file" .md)"
  if [ "$(head -n 1 "$file")" != "---" ]; then
    fail "$file: frontmatter precisa comecar na primeira linha com ---"
    continue
  fi
  frontmatter="$(awk 'NR == 1 { next } /^---$/ { exit } { print }' "$file")"
  fm_name="$(printf '%s\n' "$frontmatter" | sed -n 's/^name:[[:space:]]*//p' | head -n 1)"
  if [ "$fm_name" != "$name" ]; then
    fail "$file: name '$fm_name' diferente do nome do arquivo '$name'"
  fi
  for key in description tools; do
    if ! printf '%s\n' "$frontmatter" | grep -q "^$key:[[:space:]]*[^[:space:]]"; then
      fail "$file: $key ausente ou vazio (agente do plugin precisa declarar as ferramentas)"
    fi
  done
  while IFS= read -r line; do
    key="${line%%:*}"
    value="${line#*: }"
    case "$value" in \"*|\'*) continue ;; esac
    if printf '%s' "$value" | grep -q ': \| #'; then
      fail "$file: valor de '$key' tem ': ' ou ' #' sem aspas (YAML invalido)"
    fi
  done <<< "$frontmatter"
done

echo "== 2. Referencias \${CLAUDE_PLUGIN_ROOT}/... =="
while IFS= read -r file; do
  grep -o '\${CLAUDE_PLUGIN_ROOT}/[A-Za-z0-9_./<>*-]*' "$file" 2>/dev/null | sort -u | while IFS= read -r ref; do
    path="${ref#\$\{CLAUDE_PLUGIN_ROOT\}/}"
    path="${path%.}"
    path="${path%/}"
    # Caminhos com marcador de exemplo (<stack>, *, XXX) nao sao verificaveis.
    case "$path" in
      *'<'*|*'*'*|*XXX*|'') continue ;;
    esac
    if [ ! -e "$path" ]; then
      echo "ERRO: $file: referencia inexistente \${CLAUDE_PLUGIN_ROOT}/$path" >&2
      echo x >> "$ROOT/.check-errors.tmp"
    fi
  done
done < <(markdown_files)

echo "== 3. Links relativos e cercas de codigo =="
while IFS= read -r file; do
  dir="$(dirname "$file")"
  content="$(outside_fences "$file" 2>"$ROOT/.check-fence.tmp")"
  if grep -q UNCLOSED_FENCE "$ROOT/.check-fence.tmp"; then
    fail "$file: bloco de codigo aberto e nunca fechado (cerca de modelo quebrada?)"
  fi
  printf '%s\n' "$content" | grep -o '\]([^)#[:space:]][^)[:space:]]*)' | sed 's/^](//; s/)$//' | sort -u | while IFS= read -r link; do
    case "$link" in
      http://*|https://*|mailto:*) continue ;;
    esac
    target="${link%%#*}"
    [ -z "$target" ] && continue
    if [ ! -e "$dir/$target" ]; then
      echo "ERRO: $file: link relativo quebrado ($link)" >&2
      echo x >> "$ROOT/.check-errors.tmp"
    fi
  done
done < <(markdown_files)
rm -f "$ROOT/.check-fence.tmp"

echo "== 4. Manifestos =="
plugin_version="$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' .claude-plugin/plugin.json | head -n 1)"
market_version="$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' .claude-plugin/marketplace.json | head -n 1)"
if [ -z "$plugin_version" ] || [ "$plugin_version" != "$market_version" ]; then
  fail "versao do plugin.json ($plugin_version) diferente do marketplace.json ($market_version)"
fi
if ! grep -q "## \[$plugin_version\]" CHANGELOG.md; then
  fail "CHANGELOG.md sem a secao da versao $plugin_version"
fi
# Valida JSON com o primeiro interpretador que realmente funcionar (no Windows, `python3`
# pode ser so o atalho da Microsoft Store).
if python3 -c 'pass' >/dev/null 2>&1; then
  for json in .claude-plugin/plugin.json .claude-plugin/marketplace.json; do
    PYTHONUTF8=1 python3 -m json.tool "$json" >/dev/null 2>&1 || fail "$json nao e JSON valido"
  done
elif node -e '' >/dev/null 2>&1; then
  for json in .claude-plugin/plugin.json .claude-plugin/marketplace.json; do
    node -e 'JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"))' "$json" >/dev/null 2>&1 \
      || fail "$json nao e JSON valido"
  done
else
  echo "(sem python3/node funcional: validacao de JSON pulada)"
fi

echo "== 5. Scripts =="
bash -n adapters/codex/install.sh || fail "adapters/codex/install.sh com erro de sintaxe"
bash -n scripts/check.sh || fail "scripts/check.sh com erro de sintaxe"

if [ -f "$ROOT/.check-errors.tmp" ]; then
  errors=$((errors + $(wc -l < "$ROOT/.check-errors.tmp")))
  rm -f "$ROOT/.check-errors.tmp"
fi

echo
if [ "$errors" -gt 0 ]; then
  echo "Falhou: $errors problema(s)."
  exit 1
fi
echo "Tudo certo."
