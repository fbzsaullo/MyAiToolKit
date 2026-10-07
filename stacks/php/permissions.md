# Permissões — PHP

Formato do Claude Code; o `sdd-setup` traduz para o Codex.

```jsonc
{
  "permissions": {
    "allow": [
      "Bash(php artisan test *)",
      "Bash(php artisan route:list *)",
      "Bash(php artisan migrate:status *)",
      "Bash(./vendor/bin/phpunit *)",
      "Bash(./vendor/bin/pest *)",
      "Bash(./vendor/bin/pint *)",
      "Bash(./vendor/bin/phpstan *)",
      "Bash(./vendor/bin/psalm *)",
      "Bash(composer audit *)",
      "Bash(composer validate *)"
    ],
    "ask": [
      "Bash(composer require *)",
      "Bash(composer update *)",
      "Bash(composer install *)",
      "Bash(php artisan migrate *)",
      "Bash(php artisan db:seed *)",
      "Bash(php bin/console doctrine:migrations:migrate *)"
    ],
    "deny": [
      "Bash(php artisan migrate:fresh *)",
      "Bash(php artisan migrate:reset *)",
      "Bash(php artisan db:wipe *)",
      "Bash(php bin/console doctrine:database:drop *)",
      "Bash(php bin/console doctrine:schema:drop *)",
      "Read(**/auth.json)"
    ]
  }
}
```

## Notas

- **Sombra:** `Bash(php artisan migrate *)` (ask) **não** casa `migrate:status` nem `migrate:fresh` — depois de `migrate` vem `:`, não espaço. Por isso `migrate:status` fica liberado e `migrate:fresh` precisa de bloqueio próprio, como está acima.
- `tinker` não entra em nenhuma lista: é interativo.
- `migrate:fresh`, `migrate:reset`, `db:wipe` apagam tudo → bloqueados.
