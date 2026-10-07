#!/usr/bin/env bash
# Instala (ou remove) as skills do MyAiToolKit para o Codex.
#
#   install.sh --scope user|repo [--target DIR] [--uninstall] [--dry-run]
#
# As skills vao para <raiz>/.agents/skills/<nome>/ e o restante do toolkit para
# <raiz>/.agents/myaitoolkit-shared/. Toda ocorrencia de ${CLAUDE_PLUGIN_ROOT}
# nos .md copiados vira o caminho absoluto da pasta compartilhada.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

scope=""
target=""
uninstall=false
dry_run=false

usage() {
  sed -n '2,8p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

while [ $# -gt 0 ]; do
  case "$1" in
    --scope) scope="${2:-}"; shift 2 ;;
    --target) target="${2:-}"; shift 2 ;;
    --uninstall) uninstall=true; shift ;;
    --dry-run) dry_run=true; shift ;;
    -h|--help) usage 0 ;;
    *) echo "Opcao desconhecida: $1" >&2; usage 1 ;;
  esac
done

case "$scope" in
  user) root="$HOME" ;;
  repo) root="${target:-$PWD}" ;;
  *) echo "Informe --scope user ou --scope repo." >&2; usage 1 ;;
esac

if [ ! -d "$root" ]; then
  echo "Pasta de destino nao existe: $root" >&2
  exit 1
fi
root="$(cd "$root" && pwd)"

skills_dir="$root/.agents/skills"
shared_dir="$root/.agents/myaitoolkit-shared"
manifest="$shared_dir/.installed"

run() {
  if $dry_run; then
    echo "+ $*"
  else
    "$@"
  fi
}

# Skills registradas por uma instalacao anterior (uma por linha: "skill:<nome>").
previous_skills() {
  if [ -f "$manifest" ]; then
    sed -n 's/^skill://p' "$manifest"
  fi
}

remove_previous() {
  local name
  for name in $(previous_skills); do
    run rm -rf "$skills_dir/$name"
  done
  run rm -rf "$shared_dir"
}

if $uninstall; then
  if [ ! -f "$manifest" ]; then
    echo "Nenhuma instalacao do MyAiToolKit encontrada em $root/.agents."
    exit 0
  fi
  remove_previous
  echo "MyAiToolKit removido de $root/.agents."
  exit 0
fi

version="$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
  "$TOOLKIT_ROOT/.claude-plugin/plugin.json" | head -n 1)"

# Caminho que vai dentro dos .md. No Git Bash do Windows, usa a forma C:/... que o
# Codex nativo entende.
shared_ref="$shared_dir"
if command -v cygpath >/dev/null 2>&1; then
  shared_ref="$(cygpath -m "$shared_dir")"
fi
# Escapa os caracteres especiais do lado direito do sed (\, & e o separador |).
shared_ref_escaped="$(printf '%s' "$shared_ref" | sed -e 's/[\\&|]/\\&/g')"

replace_root_var() {
  local file="$1"
  if $dry_run; then
    return
  fi
  sed "s|\${CLAUDE_PLUGIN_ROOT}|$shared_ref_escaped|g" "$file" > "$file.tmp"
  mv "$file.tmp" "$file"
}

installed_previously="$(previous_skills)"
remove_previous

# 1. Pasta compartilhada: espelho do toolkit.
run mkdir -p "$shared_dir"
for item in skills templates stacks adapters REFERENCES.md LICENSE; do
  if [ -e "$TOOLKIT_ROOT/$item" ]; then
    run cp -R "$TOOLKIT_ROOT/$item" "$shared_dir/"
  fi
done

# 2. Skills no local que o Codex le.
run mkdir -p "$skills_dir"
installed=()
for skill_path in "$TOOLKIT_ROOT"/skills/*/; do
  name="$(basename "$skill_path")"
  if [ -e "$skills_dir/$name" ] && ! printf '%s\n' "$installed_previously" | grep -qx "$name"; then
    echo "AVISO: ja existe uma skill '$name' que nao e do MyAiToolKit em $skills_dir — mantida, nao sobrescrita." >&2
    continue
  fi
  run cp -R "$TOOLKIT_ROOT/skills/$name" "$skills_dir/$name"
  installed+=("$name")
done

# 3. Resolve ${CLAUDE_PLUGIN_ROOT} nos .md copiados.
if ! $dry_run; then
  while IFS= read -r -d '' file; do
    replace_root_var "$file"
  done < <(find "$shared_dir" -type f -name '*.md' -print0)
  for name in ${installed[@]+"${installed[@]}"}; do
    while IFS= read -r -d '' file; do
      replace_root_var "$file"
    done < <(find "$skills_dir/$name" -type f -name '*.md' -print0)
  done
fi

# 4. Manifesto da instalacao.
if ! $dry_run; then
  {
    echo "version:$version"
    echo "scope:$scope"
    echo "installed_at:$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    for name in ${installed[@]+"${installed[@]}"}; do
      echo "skill:$name"
    done
  } > "$manifest"
fi

echo "MyAiToolKit ${version:-?} instalado para o Codex em $root/.agents (${#installed[@]} skills)."
echo "Chame no Codex com \$sdd-start, \$sdd-setup, \$spike, \$code-review..."
