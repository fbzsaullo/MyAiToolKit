# Perfil de stack — Node.js / TypeScript

Segue o contrato de `stacks/README.md`. Cobre back-ends (Express, Fastify, NestJS, Hono), front-ends (React, Vue, Svelte, Angular) e full-stack (Next.js, Nuxt, Remix, SvelteKit).

## 1. Sinais de detecção

| Sinal | Significa |
| --- | --- |
| `package.json` na raiz ou numa subpasta | Projeto Node/JS |
| `tsconfig.json` | TypeScript |
| `workspaces` no `package.json`, `pnpm-workspace.yaml`, `turbo.json`, `nx.json` | Monorepo JS |
| dependências `next`, `nuxt`, `@remix-run/*`, `@sveltejs/kit` | Full-stack com framework |
| `express`, `fastify`, `@nestjs/core`, `hono` | Back-end |
| `react`, `vue`, `svelte`, `@angular/core` + `vite`/`webpack` | Front-end |
| `package.json` dentro de app Rails/Django/Laravel só com ferramentas de build | Node **auxiliar** — não é segunda aplicação |

## 2. Fontes de versão

| O quê | Onde |
| --- | --- |
| Node | `.node-version`, `.nvmrc`, `.tool-versions`, `package.json#engines`, `Dockerfile` |
| Gerenciador | lockfile: `package-lock.json` → npm, `pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn, `bun.lock`/`bun.lockb` → bun; `packageManager` no `package.json` |
| Framework e libs | versão resolvida no lockfile (não a faixa do `package.json`) |
| TypeScript | lockfile; `compilerOptions.strict` no `tsconfig.json` |

## 3. Orientações por versão

- **Node:** apenas versões LTS são recomendadas para produção. Confira o calendário oficial (seção 10) e reporte se a versão em uso está fora de manutenção. Versões recentes trazem `node --test` (test runner nativo), `fetch` nativo e `--env-file`; recomende quando o projeto usa dependências só para isso.
- **TypeScript:** `strict: false` é recomendação recorrente (ativar gradualmente).
- **Frameworks:** saltos de versão principal (ex.: Next.js com App Router, React com Server Components, Vue 2 → 3, Angular com standalone/signals) mudam a forma de escrever código — registre no `AGENTS.md` qual modelo o projeto usa para o agente não misturar.
- Sem certeza sobre o suporte de uma versão, aponte a página oficial.

## 4. Comandos

Fonte principal: `scripts` do `package.json`, executados **com o gerenciador do lockfile** (`pnpm test`, `yarn test`, `npm run test`). Categorias comuns: `build`, `dev`/`start`, `test`, `test:e2e`, `lint`, `typecheck`/`tsc`, `format`. Em monorepo, use os filtros do gerenciador (`pnpm --filter web test`) ou o task runner (`turbo run test`).

Armadilha: `npm run x` num projeto pnpm pode funcionar, mas quebra a convenção e gera regras de permissão que nunca casam.

## 5. Testes

Frameworks: Vitest, Jest, `node --test`, Mocha; Playwright/Cypress para ponta a ponta; Testing Library para componentes.

**Convenção de nome para `CA-XX`:**

```ts
describe("CA-05: dois pacientes disputam o último horário", () => {
  it("cria uma única consulta", async () => { /* ... */ });
});
// ou, com um único teste:
it("CA-05: dois pacientes disputam o último horário", async () => { /* ... */ });
```

`testing.ca_naming.pattern`: `it("CA-XX: <descrição>")` ou `describe("CA-XX: ...")`; `grep`: `CA-[0-9]{2}`.

## 6. Qualidade e segurança

ESLint (ou Biome), Prettier, `tsc --noEmit` para tipos, `npm audit`/`pnpm audit`, `eslint-plugin-security`. Recomendação de baixo esforço quando ausente: typecheck no CI e auditoria de dependências.

## 7. Convenções a observar no código

- organização: por camada (`controllers/`, `services/`) ou por funcionalidade (`features/x/`);
- validação de entrada (zod, class-validator, yup) e onde ela acontece;
- acesso a dados (Prisma, Drizzle, TypeORM, Knex, SQL direto);
- tratamento de erro (middleware central, `Result`, exceções);
- estado no front (React Query/TanStack, Redux, Zustand, Pinia, signals);
- componentes de servidor × cliente (Next/React);
- ESM × CommonJS.

## 8. Segredos

`.env*` (já no bloqueio universal), `.npmrc` com token, arquivos de chave de serviço (`*-service-account.json`, `firebase*.json` com chave privada).

## 9. Arquivos complementares

| Arquivo | Existe |
| --- | --- |
| `permissions.md` | ✅ |
| demais | ainda não — use o material agnóstico e o `_generic` |

## 10. Referências oficiais

- Calendário de versões do Node: https://nodejs.org/en/about/previous-releases
- TypeScript: https://www.typescriptlang.org/docs/
- OWASP Node.js Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Nodejs_Security_Cheat_Sheet.html
