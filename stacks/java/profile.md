# Perfil de stack — Java / Kotlin

Segue o contrato de `stacks/README.md`. Cobre Spring Boot, Quarkus, Micronaut e projetos JVM em geral.

## 1. Sinais de detecção

| Sinal | Significa |
| --- | --- |
| `pom.xml` | Maven |
| `build.gradle` / `build.gradle.kts`, `settings.gradle(.kts)` | Gradle (Kotlin DSL quando `.kts`) |
| `mvnw` / `gradlew` | Wrapper — preferir sempre |
| `spring-boot-starter-*` | Spring Boot |
| `src/main/kotlin` | Kotlin |

## 2. Fontes de versão

| O quê | Onde |
| --- | --- |
| JDK | `maven.compiler.release`/`java.version` no `pom.xml`; `java { toolchain }` no Gradle; `.sdkmanrc`, `.tool-versions`, `Dockerfile` |
| Spring Boot e libs | `parent` / BOM no `pom.xml`; plugins e `libs.versions.toml` no Gradle |
| Wrapper | `.mvn/wrapper/maven-wrapper.properties`, `gradle/wrapper/gradle-wrapper.properties` |

## 3. Orientações por versão

- Use versões **LTS** do JDK em produção; confira o calendário do fornecedor da JDK (seção 10).
- Saltos importantes mudam o código: Spring Boot 3 exige Jakarta (`jakarta.*` no lugar de `javax.*`) e JDK 17+; JDKs recentes trazem *records*, *pattern matching* e *virtual threads*. Registre no `AGENTS.md` o que o projeto adota.

## 4. Comandos

Sempre pelo wrapper: `./mvnw test`, `./mvnw verify`, `./mvnw spring-boot:run`; `./gradlew build`, `./gradlew test`, `./gradlew bootRun`. Migrations: Flyway/Liquibase (`./gradlew flywayMigrate`, ou automáticas na subida do app — registre isso).

## 5. Testes

JUnit 5, AssertJ, Mockito, Spring Boot Test, Testcontainers.

**Convenção de nome para `CA-XX`:** use `@DisplayName` com o ID e um nome de método equivalente:

```java
@Test
@DisplayName("CA-05: dois pacientes disputam o último horário")
void ca05_doisPacientesDisputamOUltimoHorario() { /* ... */ }
```

Em Kotlin, nomes com crase aceitam o texto direto: ``fun `CA-05 dois pacientes disputam o último horário`()``. `grep`: `CA-?[0-9]{2}`.

## 6. Qualidade e segurança

Checkstyle, SpotBugs (+ Find Security Bugs), PMD, ktlint/detekt (Kotlin), OWASP Dependency-Check, Error Prone.

## 7. Convenções a observar no código

Camadas (controller/service/repository) ou hexagonal; DTOs × entidades; validação (Bean Validation); tratamento de erro (`@ControllerAdvice`); transações (`@Transactional` e onde é permitido); Spring Data × JPQL/SQL nativo; injeção por construtor.

## 8. Segredos

`*.jks`, `*.keystore`, `application-prod.yml`/`.properties` com valores reais, `.env*`.

## 9. Arquivos complementares

`permissions.md` ✅. Demais: material agnóstico e `_generic`.

## 10. Referências oficiais

- Suporte do Spring Boot: https://spring.io/projects/spring-boot#support
- Calendário do OpenJDK (Adoptium): https://adoptium.net/support/
