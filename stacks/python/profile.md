# Perfil de stack — Python

Segue o contrato de `stacks/README.md`. Cobre Django, FastAPI, Flask e projetos Python em geral.

## 1. Sinais de detecção

| Sinal | Significa |
| --- | --- |
| `pyproject.toml`, `requirements*.txt`, `Pipfile`, `setup.py`/`setup.cfg` | Projeto Python |
| `manage.py` + `settings.py` | Django |
| dependência `fastapi` (+ `uvicorn`) | FastAPI |
| dependência `flask` | Flask |
| `alembic.ini` | Migrations com Alembic (SQLAlchemy) |

Ferramenta de ambiente pelo arquivo: `uv.lock` → uv; `poetry.lock` ou `[tool.poetry]` → Poetry; `Pipfile.lock` → pipenv; `pdm.lock` → PDM; só `requirements.txt` → pip.

## 2. Fontes de versão

| O quê | Onde |
| --- | --- |
| Python | `.python-version`, `.tool-versions`, `requires-python` no `pyproject.toml`, `Dockerfile` |
| Framework e libs | lockfile (`uv.lock`, `poetry.lock`…) ou versões fixadas em `requirements.txt` |
| Django | lockfile; `DEFAULT_AUTO_FIELD` e `MIDDLEWARE` dão pistas da idade do projeto |

## 3. Orientações por versão

- **Python:** cada versão tem janela de suporte própria; confira a página oficial (seção 10) e reporte. Versões recentes trazem melhorias de desempenho e mensagens de erro; recomende atualização quando a versão estiver perto do fim de suporte.
- **Django:** prefira versões LTS em produção; consulte o calendário oficial. Saltos de versão mudam APIs assíncronas e padrões de configuração.
- **Tipagem:** projetos com `mypy`/`pyright` configurados devem manter anotações no código novo — registre no `AGENTS.md`.

## 4. Comandos

Use a ferramenta detectada: `uv run pytest`, `poetry run pytest`, `pipenv run pytest` ou `pytest` direto. Comuns:

| Para quê | Django | FastAPI/Flask |
| --- | --- | --- |
| Rodar | `python manage.py runserver` | `uvicorn app.main:app --reload` / `flask run` |
| Testes | `pytest` ou `python manage.py test` | `pytest` |
| Migrations | `python manage.py migrate` / `makemigrations` | `alembic upgrade head` |
| Lint/format | `ruff check`, `ruff format` (ou `black`, `flake8`) | idem |
| Tipos | `mypy`, `pyright` | idem |

## 5. Testes

pytest (mais comum), unittest/`manage.py test`, pytest-django, httpx/TestClient para APIs.

**Convenção de nome para `CA-XX`:** função de teste não aceita hífen, então use o ID no nome e, se quiser, na docstring:

```python
def test_ca_05_dois_pacientes_disputam_o_ultimo_horario():
    """CA-05: dois pacientes disputam o último horário."""
```

`testing.ca_naming.pattern`: `def test_ca_XX_<descricao>`; `grep`: `ca_[0-9]{2}|CA-[0-9]{2}` (busca sem diferenciar maiúsculas).

## 6. Qualidade e segurança

ruff (lint + format), black, mypy/pyright, bandit (segurança), pip-audit/safety (dependências), `python manage.py check --deploy` (Django).

## 7. Convenções a observar no código

- Django: apps por domínio, regra em models × services × managers, DRF serializers/viewsets, permissões;
- FastAPI: routers, dependências (`Depends`), Pydantic para validação, SQLAlchemy síncrono × assíncrono;
- padrão de configuração (django-environ, pydantic-settings);
- organização de testes e fixtures.

## 8. Segredos

`.env*`, `.pypirc`, `settings/production.py` com segredo literal (alertar), arquivos de chave de serviço.

## 9. Arquivos complementares

`permissions.md` ✅. Demais: material agnóstico e `_generic`.

## 10. Referências oficiais

- Ciclo de vida do Python: https://devguide.python.org/versions/
- Versões do Django: https://www.djangoproject.com/download/#supported-versions
- Checklist de deploy do Django: https://docs.djangoproject.com/en/stable/howto/deployment/checklist/
