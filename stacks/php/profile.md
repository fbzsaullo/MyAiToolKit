# Perfil de stack — PHP

Segue o contrato de `stacks/README.md`. Cobre Laravel, Symfony e PHP em geral.

## 1. Sinais de detecção

| Sinal | Significa |
| --- | --- |
| `composer.json` | Projeto PHP |
| `artisan` + `laravel/framework` | Laravel |
| `bin/console` + `symfony/*` | Symfony |
| `wp-config.php` | WordPress → use `_generic` com cuidado redobrado |

## 2. Fontes de versão

| O quê | Onde |
| --- | --- |
| PHP | `require.php` no `composer.json`; `config.platform.php`; `.tool-versions`; `Dockerfile` |
| Framework e libs | `composer.lock` |

## 3. Orientações por versão

- Cada versão do PHP tem suporte ativo e de segurança definidos; confira a página oficial (seção 10) e reporte.
- Versões recentes trouxeram enums, `readonly`, propriedades promovidas no construtor e *match*; recomende quando o projeto ainda usa os padrões antigos no código novo.
- Laravel e Symfony têm calendários próprios (LTS no Symfony) — consulte.

## 4. Comandos

Laravel: `php artisan serve`, `php artisan test`, `php artisan migrate`, `./vendor/bin/pint`. Symfony: `symfony serve`/`php -S`, `php bin/console doctrine:migrations:migrate`, `./vendor/bin/phpunit`. Geral: `composer install`, scripts do `composer.json`, `./vendor/bin/phpstan`, `./vendor/bin/psalm`.

## 5. Testes

PHPUnit, Pest.

**Convenção de nome para `CA-XX`:**

```php
// Pest
it('CA-05: dois pacientes disputam o último horário', function () { /* ... */ });

// PHPUnit
/** @testdox CA-05: dois pacientes disputam o último horário */
public function test_ca_05_dois_pacientes_disputam_o_ultimo_horario(): void { /* ... */ }
```

`grep`: `CA-[0-9]{2}|ca_[0-9]{2}`.

## 6. Qualidade e segurança

PHPStan/Larastan, Psalm, Pint/PHP-CS-Fixer, `composer audit`, Enlightn (Laravel).

## 7. Convenções a observar no código

Laravel: Form Requests para validação, Policies/Gates, Actions/Services, Eloquent × Query Builder, Resources para API. Symfony: Voters, serviços autowired, Doctrine, Messenger. Em ambos: onde fica a regra de negócio e como os erros são tratados.

## 8. Segredos

`.env*` (Laravel/Symfony guardam tudo ali), `auth.json` do Composer, chaves em `storage/oauth-*.key` (Passport).

## 9. Arquivos complementares

`permissions.md` ✅. Demais: material agnóstico e `_generic`.

## 10. Referências oficiais

- Versões suportadas do PHP: https://www.php.net/supported-versions.php
- Laravel — política de suporte: https://laravel.com/docs/releases
- Symfony — versões: https://symfony.com/releases
