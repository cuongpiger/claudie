# Troubleshooting Turborepo Caching

Nearly every Turborepo bug is a **caching correctness** problem: the hash includes too little (stale hits / cache poisoning) or the outputs are misdeclared (nothing restored). This guide covers diagnosis.

## How the hash is computed

Turborepo combines a **global hash** and a **package hash** per task:

**Global hash** changes with:
- Root and package `turbo.json`
- Root lockfile
- `globalDependencies` file contents
- `globalEnv` values
- Runtime-affecting flags

**Package hash** changes with:
- Package `turbo.json`
- Package lockfile / `package.json`
- Source files (scoped by `inputs`)
- `env` values for the task

If any component changes, the cache is invalidated (miss). If nothing changes, you get a hit and outputs are restored from `.turbo/cache` (local) or Remote Cache.

## Diagnostic tools

```bash
turbo run build --dry=json     # what would run + each task's hash, no execution
turbo run build --summarize    # writes .turbo/runs/*.json with full hash breakdown
turbo run build --force        # bypass cache reads (still writes); confirms output correctness
turbo run build --verbosity=2  # verbose cache decisions
```

**Finding an unexpected miss/hit:** run `--summarize` before and after the change, then diff the two summary JSON files. The differing (or missing) input in the `hashOfExternalDependencies` / `inputs` / `env` sections is your culprit.

## Symptom → diagnosis

### "Cache hit, but the output is wrong / stale"
The task depends on something not in its hash.
- Reads an env var? → add to `env` (or `globalEnv`).
- Reads `.env`? → add `.env*` to `inputs` or `globalDependencies` (Turborepo does not hash `.env` values on its own).
- Reads a file outside the package? → add via `$TURBO_ROOT$` glob or `globalDependencies`.
- Running in Loose Mode? → switch to Strict Mode so undeclared env can't silently leak in.

### "Never gets a cache hit"
Something in the hash changes every run.
- Generated file (timestamp, build id, `.next/cache`) included in `inputs` → exclude it.
- `outputs` accidentally overlapping `inputs` → the output churns the next hash.
- Absolute paths / machine-specific files tracked in git → narrow `inputs`.
- Lockfile churn → ensure the lockfile is committed and stable.

### "Files aren't restored after a cache hit"
`outputs` is missing or wrong.
- Declare exact globs: `["dist/**", ".next/**", "!.next/cache/**"]`.
- Remember globs are relative to the package, not the repo root.
- Empty/absent `outputs` caches only logs.

### "Cache poisoning: prod shipped preview config"
Loose Mode + undeclared env var. The build cache-hit against a run made with different env values.
- Keep the default **Strict Mode**.
- Declare every env var the build reads in `env`.
- Run `eslint-config-turbo` to find env vars used in code but absent from config.

### "Wrong build order / a dependency wasn't built"
Graph edge missing.
- App build needs libs built first → `"build": { "dependsOn": ["^build"] }`.
- Same-package prerequisite → list the task name without `^`.
- Don't `dependsOn` a `persistent` task — that errors.

## Remote Caching

```bash
npx turbo login     # authenticate (Vercel or self-hosted)
npx turbo link      # link the repo to a remote cache
```

- Remote cache shares artifacts across teammates and CI.
- In CI, ensure `TURBO_TOKEN` and `TURBO_TEAM` (or `--api`/`--token`) are set.
- Use `--remote-only` semantics via the `--cache` flag options to force remote behavior when debugging.
- Signature verification: set `remoteCache.signature: true` and `TURBO_REMOTE_CACHE_SIGNATURE_KEY` to authenticate artifacts.

## Git worktrees

Turborepo automatically shares the local cache across Git worktrees, so switching branches reuses prior work without extra config.

## Performance caveats

Caching is not universally faster. For extremely fast tasks, huge artifacts, or tasks with their own internal cache, the hashing/transfer overhead can exceed the savings — set `"cache": false` for those specific tasks and measure.
