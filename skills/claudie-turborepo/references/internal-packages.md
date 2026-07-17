# Internal Packages

Internal Packages are libraries whose source lives inside your workspace. You share code by depending on them like any npm package, using the workspace protocol.

## Declaring and consuming

In the consumer's `package.json`:

```json
{
  "dependencies": {
    "@repo/ui": "workspace:*"   // pnpm / bun
  }
}
```

npm and yarn use `"@repo/ui": "*"` instead of the `workspace:` protocol. Then import normally:

```ts
import { Button } from "@repo/ui/button";
```

- Use a namespace prefix (`@repo/`, `@acme/`) to avoid npm registry collisions.
- The package is discovered because its directory matches a workspace glob (`packages/*`).

## Three strategies

### 1. Just-in-Time Packages
Export TypeScript source directly; the consuming app's bundler compiles it.

```json
{
  "name": "@repo/ui",
  "exports": {
    "./button": "./src/button.tsx"
  }
}
```

- **Pros:** minimal config, no build step.
- **Cons:** Turborepo cannot cache a build (there is none); every consuming app recompiles it.
- **Use when:** apps use modern bundlers (Turbopack, webpack, Vite) and build times are acceptable.

### 2. Compiled Packages
The package compiles itself (e.g. `tsc`) and exports built JS + type declarations.

```json
{
  "name": "@repo/ui",
  "exports": {
    "./button": {
      "types": "./src/button.tsx",
      "default": "./dist/button.js"
    }
  },
  "scripts": { "build": "tsc" }
}
```

```json
// turbo.json — the build IS cacheable
{ "tasks": { "build": { "dependsOn": ["^build"], "outputs": ["dist/**"] } } }
```

- **Pros:** build output is cached by Turborepo; better optimization control.
- **Cons:** more configuration; a build step to maintain.
- **Use when:** you want cached, reusable build artifacts.

### 3. Publishable Packages
For distribution to the npm registry. Most stringent setup: full build, correct `exports`/`files`, and a versioning/release tool such as `changesets`.

- **Use when:** the package ships to npm, not just internal consumers.

## The `exports` field

Prefer explicit `exports` entrypoints over a barrel `index.ts` that re-exports everything — barrels force bundlers to load the whole package and hurt performance and tree-shaking.

```json
{
  "exports": {
    ".": "./src/index.ts",
    "./button": "./src/button.tsx",
    "./utils": "./src/utils.ts"
  }
}
```

## Choosing

| Question | Just-in-Time | Compiled | Publishable |
|----------|:---:|:---:|:---:|
| Build step to maintain? | No | Yes | Yes |
| Turborepo caches the build? | No | Yes | Yes |
| Consumed only inside the repo? | Yes | Yes | No (also npm) |
| Config overhead | Lowest | Medium | Highest |

Start Just-in-Time; move to Compiled when build times or repeated recompilation across apps become a problem; go Publishable only when you actually ship to npm.
