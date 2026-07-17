# turbo.json Configuration Reference

Full reference for `turbo.json` fields. Applies to Turborepo v2 (top-level key `tasks`; v1 used `pipeline`).

## Top-level fields

| Field | Type | Purpose |
|-------|------|---------|
| `$schema` | string | JSON schema URL for editor autocomplete: `https://turborepo.dev/schema.json`. |
| `tasks` | object | Task definitions. Each key is a task name matched against `package.json` scripts. (v1: `pipeline`.) |
| `globalDependencies` | string[] | File globs included in **every** task's hash. Changing any invalidates all caches (e.g. `tsconfig.json`, `.env`). |
| `globalEnv` | string[] | Env vars included in every task's hash. |
| `globalPassThroughEnv` | string[] | Env vars available to all tasks at runtime in Strict Mode; NOT hashed. |
| `ui` | string | `"tui"` (interactive terminal UI) or `"stream"` (sequential logs). |
| `remoteCache` | object | Remote cache config: `enabled`, `signature`, `apiUrl`, `timeout`, etc. |
| `daemon` | boolean | Deprecated; no longer affects `turbo run`. |
| `envMode` | string | `"strict"` (default) or `"loose"`. Loose exposes all process env to tasks (risk of cache poisoning). |
| `cacheDir` | string | Local cache directory, default `.turbo/cache`. |

## Per-task fields (inside `tasks.<name>`)

### `dependsOn: string[]`
Declares prerequisites and builds the task graph.

- `"^build"` — run `build` in this package's **dependencies** first (topological/transitive).
- `"build"` — run `build` in the **same package** first.
- `"pkg#task"` — depend on a specific package's task.
- Package-specific override: use key `"web#build"` with its own config block.

```json
{
  "tasks": {
    "build": { "dependsOn": ["^build"] },
    "test":  { "dependsOn": ["build"] },
    "deploy": { "dependsOn": ["build", "test", "lint"] },
    "web#build": { "dependsOn": ["ui#build"] }
  }
}
```

### `outputs: string[]`
File globs (relative to the package) cached on successful completion.
- **Omitting or `[]` caches only logs** — generated files are NOT restored.
- Negation excludes: `["!.next/cache/**"]`.

```json
{ "outputs": ["dist/**", ".next/**", "!.next/cache/**", "storybook-static/**"] }
```

### `inputs: string[]`
File globs that determine whether the package changed (affect the hash).
- Default: all git-tracked files in the package.
- Always implicitly includes `package.json`, `turbo.json`, and the lockfile.
- `"$TURBO_DEFAULT$"` keeps defaults and lets you add exclusions.
- `"$TURBO_ROOT$"` makes a glob relative to the repo root instead of the package.

```json
{ "inputs": ["$TURBO_DEFAULT$", "!**/*.test.ts", "$TURBO_ROOT$/config/shared.json"] }
```

### `env: string[]`
Env vars that affect this task's hash. Supports wildcards and negation.

```json
{ "env": ["DATABASE_URL", "NEXT_PUBLIC_*", "!NEXT_PUBLIC_ANALYTICS_ID"] }
```

### `passThroughEnv: string[]`
Env vars made available to the task at runtime in Strict Mode, but NOT part of the hash. Use for runtime-only values/secrets that shouldn't invalidate the cache.

### `cache: boolean` (default `true`)
Set `false` to skip caching entirely (dev servers, watchers, deploy tasks).

### `persistent: boolean` (default `false`)
Marks a long-running task (dev server). **No task may `dependsOn` a persistent task.** Persistent tasks are interactive by default.

### `interactive: boolean`
Enables stdin in the terminal UI. Only meaningful with `persistent: true` (where it defaults to `true`).

### `interruptible: boolean` (default `false`)
Allows a persistent task to be restarted by `turbo watch`.

### `with: string[]`
Sibling tasks to run concurrently alongside this task (e.g. run an app dev server together with its backing API dev server).

```json
{ "tasks": { "dev": { "persistent": true, "with": ["api#dev"] } } }
```

### `outputLogs: string`
Log verbosity: `full` | `hash-only` | `new-only` | `errors-only` | `none`.

## Package Configurations (per-package turbo.json)

A package can have its own `turbo.json` that extends the root:

```json
{
  "extends": ["//"],
  "tasks": {
    "build": { "outputs": ["custom-dist/**"] }
  }
}
```

- `extends: ["//"]` inherits from the root config.
- `"$TURBO_EXTENDS$"` in an array **appends** to the inherited array instead of replacing it.

## Special tokens summary

| Token | Where | Effect |
|-------|-------|--------|
| `^` | `dependsOn` | Topological — run in dependencies first. |
| `#` | `dependsOn` / task key | Target/override a specific `package#task`. |
| `//` | task key | Root-package task; also the `extends` target. |
| `$TURBO_DEFAULT$` | `inputs` | Preserve default inputs before adding exclusions. |
| `$TURBO_ROOT$` | globs | Anchor glob to repo root. |
| `$TURBO_EXTENDS$` | package config arrays | Append to inherited array. |
| `*` / `!` | `env`, globs | Wildcard match / negation. |
