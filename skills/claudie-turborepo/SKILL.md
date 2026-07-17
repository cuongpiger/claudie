---
name: claudie-turborepo
description: Use when working in a JavaScript/TypeScript monorepo that uses Turborepo (turbo.json present, `turbo run`, `create-turbo`) — developing tasks, debugging cache misses/cache poisoning, configuring dependsOn/outputs/inputs/env, filtering packages, setting up remote caching, structuring apps/packages workspaces, or reviewing turbo.json changes.
---

# Turborepo Expert

## Overview

Turborepo is a high-performance build orchestrator for JS/TS monorepos. It does two things well:

1. **Content-aware caching** — never run the same work twice. Each task run is hashed from its inputs; identical inputs restore outputs from cache in milliseconds.
2. **Task scheduling** — builds a task graph from `dependsOn` and runs independent work in parallel across cores.

Turborepo does **not** replace your package manager or bundler. It wraps the `scripts` already in your `package.json` files and schedules them. Works with npm, yarn, pnpm, and bun.

**Core mental model:** *Correct caching depends entirely on declaring the complete set of inputs (files + env vars) and outputs for every task.* Most Turborepo bugs are one of: undeclared outputs (nothing restored), undeclared inputs/env (stale cache hits / cache poisoning), or a missing `dependsOn` edge (wrong build order).

## When to Use

- Editing or reviewing a `turbo.json`
- A task shows a cache hit but produces stale/wrong output, or never hits cache
- Configuring build order across packages (`dependsOn`, `^build`)
- Filtering runs to specific packages or changed packages (`--filter`, `--affected`)
- Setting up or debugging Remote Caching in CI
- Structuring a new monorepo (`apps/`, `packages/`, workspace config)
- Deciding how a shared internal package should be consumed (source vs compiled)

**When NOT to use:** single-package projects with no cross-package tasks, or plain package-manager workspace questions with no `turbo`.

## First Step: Detect the Setup

Before advising, read the actual configuration — don't assume defaults.

```bash
cat turbo.json                            # task graph, global env/deps, ui/cache modes
cat package.json | grep -A5 workspaces    # npm/yarn/bun workspaces
cat pnpm-workspace.yaml 2>/dev/null        # pnpm workspaces
npx turbo --version                       # v1 vs v2 differ (see note below)
```

**v1 → v2 note:** In `turbo.json` the top-level key was `pipeline` in v1 and is `tasks` in v2. If you see `pipeline`, the repo is on v1 or was migrated incompletely.

## turbo.json Cheat Sheet

```json
{
  "$schema": "https://turborepo.dev/schema.json",
  "globalDependencies": ["tsconfig.json", ".env"],
  "globalEnv": ["NODE_ENV"],
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**", "!.next/cache/**"],
      "env": ["NEXT_PUBLIC_*"],
      "inputs": ["$TURBO_DEFAULT$", "!README.md"]
    },
    "test": { "dependsOn": ["build"], "outputs": ["coverage/**"] },
    "lint": { "dependsOn": ["^build"] },
    "dev": { "cache": false, "persistent": true }
  }
}
```

### The prefixes (memorize these)

| Syntax | Meaning |
|--------|---------|
| `"^build"` | Run `build` in this package's **dependencies** first (topological). Use for compile order. |
| `"build"` | Run `build` in the **same package** first. |
| `"utils#build"` | Depend on a **specific package's** task. |
| `"web#build": {}` | Override config for one package's task (key = `package#task`). |
| `"//#task"` | A task that runs in the **workspace root** package. |
| `env: ["API_*"]`, `["!SECRET"]` | Wildcard / negation for env var matching. |
| `"$TURBO_DEFAULT$"` | In `inputs`: keep default inputs, then add exclusions. |
| `"$TURBO_ROOT$"` | Make a glob relative to repo root, not the package. |

### Field quick reference

| Field | Purpose |
|-------|---------|
| `dependsOn` | Task prerequisites (see prefixes). Defines the graph. |
| `outputs` | Globs to cache on success. **Omit → only logs cached, files NOT restored.** |
| `inputs` | Globs that affect the hash. Default = all git-tracked files. Always includes package.json, turbo.json, lockfile. |
| `env` | Env vars that affect this task's hash. Change → cache miss. |
| `passThroughEnv` | Env vars available at runtime but NOT in the hash. |
| `globalEnv` / `globalDependencies` | Env/files that affect **every** task's hash. |
| `globalPassThroughEnv` | Runtime env for all tasks, not hashed. |
| `cache` | `false` disables caching (use for `dev`, watchers). |
| `persistent` | `true` for long-running tasks (dev servers). Nothing may `dependsOn` it. |
| `interruptible` | Allow a persistent task to restart under `turbo watch`. |
| `with` | Sibling tasks to run alongside (e.g. app + its API in dev). |
| `outputLogs` | `full` \| `hash-only` \| `new-only` \| `errors-only` \| `none`. |

Full field-by-field reference: [references/turbo-json-reference.md](references/turbo-json-reference.md).

## Running & Filtering

```bash
turbo run build lint test          # run multiple tasks, respecting the graph
turbo build --filter=@acme/web     # one package
turbo build --filter=@acme/web...  # web AND everything it depends on
turbo build --filter=...@acme/ui   # ui AND everything that depends on it
turbo build --filter=./apps/*      # by directory
turbo build --affected             # only packages changed vs main...HEAD
turbo build --dry=json             # show what WOULD run (+ hashes), no execution
turbo run build --summarize        # write a run summary for hash debugging
turbo build --force                # ignore cache reads, re-run everything
turbo build --graph=graph.html     # visualize the task graph
```

Filter syntax (`...`, `!`, `{dir}`, `[git-range]`) is composable — full matrix: [references/filtering.md](references/filtering.md).

## Debugging Cache Problems (the #1 real-world task)

**Symptom → Cause → Fix:**

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| Cache hit but output is stale/wrong | Env var or file not declared as an input | Add it to `env` / `inputs` / `globalEnv` |
| Never gets a cache hit | An input changes every run (timestamp, generated file, absolute path) | Narrow `inputs`; exclude the churning file |
| Files not restored after a hit | `outputs` not declared or wrong glob | Declare exact output globs |
| Cache hit in prod ships preview config | **Cache poisoning** — Loose Mode + undeclared env | Use Strict Mode (default), declare all env vars |
| Two runs differ but you don't know why | — | `turbo run <task> --summarize` on each, diff the hash inputs |

**Workflow for a suspected bad hash:**
1. `turbo run build --dry=json` — confirm which tasks run and see their hash.
2. `turbo run build --summarize` — inspect the exact inputs/env that fed the hash.
3. Compare the two summaries (before/after the change) to find the differing input.
4. If an env var or file is missing from the hash, add it to `env`/`inputs`.

Deep guide: [references/troubleshooting.md](references/troubleshooting.md).

## Environment Variables (where correctness bugs hide)

- **Strict Mode is the default and correct choice** — only env vars you declare are visible to tasks. A task that reads an undeclared var from the process env fails loudly instead of building wrong. (This protection does NOT extend to values read from a `.env` file — see below — which is why stale builds still happen.)
- **The deciding question is "does this value change the build output?", not "is it a secret?"** If a secret gets baked into the output (`STRIPE_SECRET_KEY`, `DATABASE_URL` used at build time), it belongs in **`env`** even though it's a secret — otherwise you get stale/poisoned cache hits.
  - **`env`** — value affects this task's output (e.g. `build` reads `NEXT_PUBLIC_API_URL`, `STRIPE_SECRET_KEY`).
  - **`globalEnv`** — value affects all tasks (e.g. `NODE_ENV`).
  - **`passThroughEnv`** — needed at runtime but does NOT affect output, so it must NOT bust the cache. Only use this when you're sure the value doesn't change what's produced.
- Turborepo does **not** load `.env` files — your framework does, so Strict Mode can't see or guard those values. If a build value comes from `.env`, you MUST add `.env*` to `inputs` (or `globalDependencies`) so value changes invalidate the hash. A silent stale build almost always means either (a) a build-affecting var missing from `env`, or (b) a `.env` file missing from `inputs`.
- Framework prefixes (`NEXT_PUBLIC_*`, `VITE_*`) are auto-inferred, but declaring them explicitly is clearer and portable.
- Run `eslint-config-turbo` to catch env vars used in code but missing from config.

## Structuring a Monorepo

```
my-turbo/
├── apps/            # deployable apps/services
│   └── web/package.json
├── packages/        # shared libs, config, tooling
│   └── ui/package.json
├── turbo.json
├── package.json     # root: turbo devDep, workspaces (npm/yarn/bun)
└── pnpm-workspace.yaml   # pnpm only
```

- Name internal packages with a namespace: `@repo/ui`, `@acme/config` — avoids npm collisions.
- Declare cross-package deps with workspace protocol: `"@repo/ui": "workspace:*"` (pnpm/bun) or `"*"` (npm/yarn).
- Prefer the `exports` field over barrel/index re-export files (barrels hurt bundler performance).
- Scaffold new repos with `npx create-turbo@latest` rather than hand-assembling.

### Internal package strategies

| Strategy | Exports | Turbo caches build? | When |
|----------|---------|:---:|------|
| Just-in-Time | TS source (`./src/button.tsx`) | No (no build task) | Modern bundler consumes it; minimal config |
| Compiled | compiled JS + types via `tsc` | **Yes** | Want cached, optimized builds |
| Publishable | full dist + `changesets` | Yes | Shipping to npm registry |

Details: [references/internal-packages.md](references/internal-packages.md).

## Reviewing turbo.json Changes

When reviewing a PR that touches `turbo.json`, check in order:

1. **Outputs complete?** Every task that writes files declares them in `outputs`. Missing outputs = broken cache restoration downstream.
2. **Inputs/env complete?** Anything the task reads that isn't git-tracked source (env vars, `.env`, generated files) is declared. This is where cache-poisoning bugs enter.
3. **Graph correct?** `build` depends on `^build`; `test`/`lint` depend on `build` only if they need built artifacts. No `dependsOn` on a `persistent` task.
4. **`cache: false` justified?** Only for `dev`/watch/deploy tasks, not to "fix" a caching bug that should be fixed by declaring inputs.
5. **Env placement by effect, not secrecy.** A value goes in `env`/`globalEnv` if it changes the output (even a secret like `STRIPE_SECRET_KEY`); it goes in `passThroughEnv` only if it's needed at runtime but doesn't affect output. Flag build-affecting vars that are missing entirely.
6. **Strict Mode preserved** — no accidental switch to Loose Mode / `--env-mode=loose`.

## Common Mistakes

- **Empty/missing `outputs`** → task "caches" but no files come back; next task fails on missing `dist/`.
- **Forgetting `.env` in `inputs`** → build cache-hits with a stale environment.
- **`dependsOn: ["build"]` when you meant `["^build"]`** → depends on the same package instead of dependencies; wrong order.
- **Something `dependsOn` a `persistent: true` task** → Turborepo errors; persistent tasks can't be dependencies.
- **Using `cache: false` to paper over a stale-cache bug** → hides the real missing-input problem.
- **Overly broad `inputs`** (e.g. including build output or `node_modules`) → cache never hits.
- **`--parallel` for correctness** → deprecated and ignores the graph; use `--concurrency` or `persistent`.

## Quick Reference

```toon
checklist[10]{area,rule}:
  outputs,Declare every generated file glob or cache restores nothing
  inputs,Add .env and generated files or hashes go stale
  env,affects output → env (even secrets); runtime-only no-output-effect → passThroughEnv
  dependsOn,^build for dependency order; build for same-package order
  persistent,Set true for dev servers; nothing may depend on them
  strict-mode,Keep the default; Loose Mode risks cache poisoning
  filter,pkg... = with deps; ...pkg = with dependents; --affected = changed only
  debugging,--dry=json to preview; --summarize to diff hash inputs
  cache-false,Only for dev/watch/deploy never to hide input bugs
  structure,apps/ for deployables packages/ for shared use workspace:* deps
```

## References

- [turbo-json-reference.md](references/turbo-json-reference.md) — every configuration field
- [filtering.md](references/filtering.md) — full `--filter` syntax matrix
- [troubleshooting.md](references/troubleshooting.md) — cache-miss & cache-poisoning diagnosis
- [internal-packages.md](references/internal-packages.md) — sharing code between packages
- Official docs: https://turborepo.dev/docs
