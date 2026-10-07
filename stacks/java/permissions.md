# Permissões — Java / Kotlin

Formato do Claude Code; o `sdd-setup` traduz para o Codex. Use somente o build tool do projeto (Maven **ou** Gradle) e sempre pelo wrapper.

```jsonc
{
  "permissions": {
    "allow": [
      "Bash(./mvnw compile *)",
      "Bash(./mvnw test *)",
      "Bash(./mvnw verify *)",
      "Bash(./mvnw spring-boot:run *)",
      "Bash(./gradlew build *)",
      "Bash(./gradlew test *)",
      "Bash(./gradlew check *)",
      "Bash(./gradlew bootRun *)",
      "Bash(./gradlew dependencies *)"
    ],
    "ask": [
      "Bash(./gradlew flywayMigrate *)",
      "Bash(./mvnw flyway:migrate *)",
      "Bash(./mvnw liquibase:update *)"
    ],
    "deny": [
      "Bash(./mvnw deploy *)",
      "Bash(./gradlew publish *)",
      "Bash(./gradlew flywayClean *)",
      "Bash(./mvnw flyway:clean *)",
      "Read(**/*.jks)",
      "Read(**/*.keystore)",
      "Read(**/application-prod.yml)",
      "Read(**/application-prod.properties)"
    ]
  }
}
```

## Notas

- `flywayClean` apaga o schema inteiro → bloqueado.
- Publicação de artefato (`deploy`, `publish`) → bloqueada; quem publica é o pipeline de CI.
- Dependências novas entram editando `pom.xml`/`build.gradle` — isso aparece no diff e é cobrado no review.
