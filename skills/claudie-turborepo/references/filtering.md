# Filtering (`--filter` / `-F`) Reference

`--filter` selects which packages a `turbo run` targets. Filters are composable — repeat `--filter` to union multiple selectors.

## Selector matrix

| Goal | Syntax | Example |
|------|--------|---------|
| One package (by name) | `<name>` | `--filter=@acme/web` |
| Scope / glob names | `<glob>` | `--filter=@acme/*` |
| By directory | `{<dir-glob>}` | `--filter={./apps/*}` |
| Package **+ its dependencies** | `<name>...` | `--filter=web...` |
| Package **+ its dependents** | `...<name>` | `--filter=...ui` |
| Only dependencies (exclude self) | `<name>^...` | `--filter=web^...` |
| Only dependents (exclude self) | `...^<name>` | `--filter=...^ui` |
| Exclude a package | `!<name>` | `--filter=!docs` |
| Changed since a git ref | `[<ref>]` | `--filter=[HEAD^1]` |
| Changed in a commit range | `[<sha1>...<sha2>]` | `--filter=[main...HEAD]` |
| Directory changed since ref | `{<dir>}[<ref>]` | `--filter={./apps/*}[HEAD^1]` |

## Composition examples

```bash
# web plus everything web depends on
turbo build --filter=web...

# everything that depends on the ui package (rebuild consumers)
turbo build --filter=...ui

# packages under apps/ that changed since main, plus their dependencies
turbo build --filter={./apps/*}[main...HEAD]...

# all packages except docs
turbo build --filter=!docs

# union: web and its deps, AND anything depending on ui
turbo build --filter=web... --filter=...ui
```

## `--affected`

Shorthand for "packages changed on this branch":

```bash
turbo build --affected        # compares main...HEAD by default
```

Override the comparison base with env vars:

```bash
TURBO_SCM_BASE=develop TURBO_SCM_HEAD=HEAD turbo build --affected
```

Prefer `--affected` in CI to build/test only what changed. Use explicit `[git-range]` filters when you need a non-default base.

## Mental model

- `...` on the **right** of a name walks **down** into dependencies.
- `...` on the **left** of a name walks **up** into dependents.
- `^` excludes the matched package itself, keeping only the walked set.
- `{}` matches by directory; bare names match by `package.json` name.
- `[]` restricts to packages touched within a git range.
