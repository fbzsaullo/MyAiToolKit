# Permissões — Python

Formato do Claude Code; o `sdd-setup` traduz para o Codex. Ajuste o prefixo à ferramenta detectada (`uv run`, `poetry run`, `pipenv run`).

```jsonc
{
  "permissions": {
    "allow": [
      "Bash(pytest *)",
      "Bash(python -m pytest *)",
      "Bash(uv run pytest *)",
      "Bash(poetry run pytest *)",
      "Bash(ruff check *)",
      "Bash(ruff format *)",
      "Bash(black *)",
      "Bash(mypy *)",
      "Bash(pyright *)",
      "Bash(bandit *)",
      "Bash(pip-audit *)",
      "Bash(python manage.py check *)",
      "Bash(python manage.py showmigrations *)",
      "Bash(python manage.py test *)"
    ],
    "ask": [
      "Bash(pip install *)",
      "Bash(uv add *)",
      "Bash(uv sync *)",
      "Bash(poetry add *)",
      "Bash(poetry install *)",
      "Bash(python manage.py migrate *)",
      "Bash(python manage.py makemigrations *)",
      "Bash(alembic upgrade *)",
      "Bash(alembic downgrade *)"
    ],
    "deny": [
      "Bash(twine upload *)",
      "Bash(uv publish *)",
      "Bash(poetry publish *)",
      "Read(**/.pypirc)",
      "Bash(python manage.py flush *)",
      "Bash(python manage.py reset_db *)"
    ]
  }
}
```

## Notas

- `python manage.py shell` e `dbshell` não entram em nenhuma lista: são interativos (sem regra, o Claude pergunta).
- `flush`/`reset_db` apagam dados → `deny`.
- Migrations seguem a escolha do setup (`ask` ou `deny`).
- Conferência de sombra: nenhuma regra larga como `Bash(python *)` em `ask` — ela anularia todas as liberações `python manage.py ...`.
