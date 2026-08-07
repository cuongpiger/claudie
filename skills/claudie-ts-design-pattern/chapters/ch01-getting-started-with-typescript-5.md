# Chapter 1: Getting Started with TypeScript 5

## Core Idea
TypeScript's static type system is what makes classical design patterns *practical* in
JavaScript's ecosystem — interfaces give you real contracts instead of duck typing, and
the compiler enforces them during the refactors that patterns inevitably require.

## Frameworks Introduced

- **Structural typing over duck typing**: TypeScript matches types by *shape*, not by
  declared name or nominal identity. An object satisfies a parameter type if it has the
  required members — no `implements` clause needed.
  - When to use: any time you'd otherwise write runtime property checks
    (`typeof x.send === "function"`) to guard a call.
  - How: type the parameter with an inline object type or interface describing only the
    members you actually call. The compiler then catches wrong-shape *and* wrong-order
    arguments at compile time.
  - Why it works: duck typing fails silently — swap two arguments and the guards just
    don't fire, producing no output and no error. Structural typing turns that into a
    compile error.

- **Incremental JS → TS migration**: convert a codebase file-by-file rather than
  big-bang.
  - When to use: any existing JavaScript codebase you've been asked to "rewrite in
    TypeScript."
  - How (the author's four strategies):
    1. **Divide and conquer** — pick one module (`auth.js`, `utils.js`) at a time.
    2. **Incremental file conversion** — rename `.js` → `.ts`; the resulting errors are
       your work list, and they mostly signal missing annotations.
    3. **Embrace `unknown` and `never`** — use `unknown` where you'd reach for `any`
       (it forces a narrowing check before use); use `never` to mark impossible cases.
    4. **`allowJs` as a bridge** — import `.js` files directly into a TS project to
       start immediately. Failure mode: `allowJs` skips type checking for those files,
       so it defers errors rather than removing them.

- **Type inference vs. explicit annotation** — a decision rule, not a style preference.
  - **Infer** for simple functions where context makes the type obvious, and for local
    variables in small scopes.
  - **Annotate explicitly** for complex signatures (many parameters, non-obvious return
    type) and for anything exported as a public API, where the type *is* documentation.

- **UML class diagrams** as the language for describing patterns independent of any
  implementation. The relationship vocabulary maps directly onto TypeScript code —
  see the Reference Tables below.

## Key Concepts

- **Statement vs. expression** — statements give orders (assignment, control flow) and
  produce no value; expressions evaluate to a value that statements consume.
- **`unknown`** — holds any value but permits no property access or assignment to
  another type until narrowed. The safe replacement for `any`.
- **`any`** — disables type checking entirely for that value. Minimize its use.
- **`never`** — the type of a function that never returns normally (throws or loops
  forever). Cannot be assigned a value.
- **Union type (`|`)** — value may be any one of the combined types.
- **Intersection type (`&`)** — value must satisfy *all* the combined types.
- **Union enums** — since TS 5, every enum is a union of its member literal types, so
  each member is a distinct type and out-of-range assignment is a compile error.
- **Tuple** — fixed-length array with a per-position type; use when the shape is known
  upfront. Use a plain array when size varies.
- **Abstract class** — cannot be instantiated; declares abstract methods subclasses
  must implement. The mechanism behind Template Method and most Factory hierarchies.
- **Type guard / type predicate (`value is T`)** — a function whose return type narrows
  its argument for the compiler inside the true branch.
- **`NoInfer<T>`** (TS 5.4) — blocks the compiler from using a position to infer `T`,
  so inference is driven only by the positions you intend.

## Mental Models

- **Think of an interface as a contract, a type alias as a calculator.** Reach for
  `interface` when defining the shape other code must satisfy; reach for `type` when
  composing, aliasing, or computing over existing types.
- **Think of `any` as a hole in the type system and `unknown` as a locked box.** Both
  accept anything; only `unknown` makes you prove what's inside before using it.
- **Use `strict` as the default and negotiate additions with your team.** The author is
  explicit: reach consensus with colleagues before enabling extra compiler flags, so
  the build doesn't become a source of confusion.
- **Refactor only behind tests.** Refactoring by definition must not change external
  behavior — tests are what let you assert that.

## Anti-patterns

- **Unioning logically unrelated types** (`type D = 'A' | 40`): technically legal, but
  every consumer now needs exhaustive checking and casting. Union types that don't share
  a domain make code harder to maintain, not safer.
- **Leaving `noImplicitAny` off**: `calculateArea(length, width)` with no annotations
  accepts `calculateArea("5", "2")` without complaint — and silently returns `NaN` for
  non-coercible strings.
- **Reaching for `any` during migration**: it compiles, but it removes exactly the
  safety you migrated for. Use `unknown` plus a type guard instead.
- **Over-relying on UML**: it captures static structure well and dynamic behavior
  poorly, and large diagrams become unmaintainable. Use it for a specific sub-system
  plus a short note on the architectural decision — not as living documentation of a
  whole system.

## Code Examples

Duck typing (JavaScript) — silently does nothing when arguments are swapped:

```javascript
function triggerNotification(emailClient, logger) {
  if (logger && typeof logger.log === "function") {
    logger.log("Sending email")
  }
  if (emailClient && typeof emailClient.send === "function") {
    emailClient.send("Message Sent")
  }
}
// swapped arguments → no error, no output
triggerNotification({ log: () => {} }, { send: (m) => console.log(m) })
```

Structural typing (TypeScript) — the same swap is now a compile error:

```typescript
function triggerNotification(
  emailClient: { send(message: string): void },
  logger: { log(message: string): void }
) {
  logger.log("Sending email")
  emailClient.send("Message Sent")
}
```

- **What it demonstrates**: the core argument of the book — patterns depend on
  contracts, and TypeScript gives you contracts the compiler enforces.

Type guard replacing an untyped JavaScript predicate:

```typescript
export const isObject = (value: unknown): value is object => {
  return typeof value === "object" && value !== null && !Array.isArray(value)
}
```

Method decorator, TS 5 signature (no `experimentalDecorators` needed for this form):

```typescript
function log(originalMethod: any, context: ClassMethodDecoratorContext) {
  function replacementMethod(this: any, ...args: any[]) {
    console.log(`Calling ${String(context.name)}`)
    return originalMethod.call(this, ...args)
  }
  return replacementMethod
}

class Calculator {
  @log
  add(x: number, y: number): number { return x + y }
}
```

- **What it demonstrates**: decorators wrap behavior around a method without touching
  the method body — the mechanism the book later reuses for Proxy and Decorator patterns.

## Reference Tables

UML relationship → TypeScript construct:

| UML relationship | Notation | Meaning | TypeScript form |
|---|---|---|---|
| Association | plain line | one class references another | constructor param / property holding the other class |
| Aggregation | line + hollow rhombus | part-whole; both survive independently | optional property, often with a default (`qb?: QueryBuilder`) |
| Composition | line + filled rhombus | parent controls child lifetime | private array/property created and owned by the parent |
| Inheritance | line + hollow arrow | subclass extends base | `class B extends A` |
| Implementation | interface above class name | class satisfies a contract | `class P implements Identifiable<string>` |

UML visibility markers:

| Symbol | Visibility | TypeScript |
|---|---|---|
| `+` | Public — anywhere | `public` (default) |
| `-` | Private — this class only | `private` |
| `#` | Protected — this class and subclasses | `protected` |
| `~` | Package — rarely used in modern OO | (no direct equivalent) |

Key `tsconfig.json` flags:

| Flag | Effect |
|---|---|
| `strict` | Umbrella for `noImplicitAny`, `strictNullChecks`, `strictFunctionTypes`, `strictBindCallApply` |
| `noImplicitAny` | Error when a type would be inferred as `any` |
| `strictNullChecks` | `null`/`undefined` must be handled explicitly before use |
| `module` | Emit format — `commonjs` for Node, `es2015`+/`esnext` for ESM |
| `target` | ECMAScript output version |
| `baseUrl` / `paths` | Non-relative import roots and aliases (`@components/*`) |
| `experimentalDecorators`, `emitDecoratorMetadata` | Required for legacy decorators, notably Inversify.js DI |
| `sourceMap` | Debug the original `.ts` in VSCode / devtools |
| `noUnusedLocals`, `noUnusedParameters` | Fail the build on dead locals/params |
| `allowJs` | Import `.js` files without compiler errors (no type checking) |

## Worked Example

**Refactoring a generic predicate parameter into a reusable type alias** — the
end-to-end flow the author walks through in VSCode:

Start with an inline function type in the signature:

```typescript
function find<T>(arr: T[], predicate: (item: T) => boolean) {
  for (let item of arr) {
    if (predicate(item)) { return item }
  }
  return undefined
}
```

1. Select the type expression `(item: T) => boolean`.
2. Right-click → **Refactor** → **Extract to type alias**.
3. Name it `Predicate`.

Result — the contract is now named, reusable, and appears in hover tooltips at every
call site:

```typescript
type Predicate<T> = (item: T) => boolean

function find<T>(arr: T[], predicate: Predicate<T>) {
  for (let item of arr) {
    if (predicate(item)) { return item }
  }
  return undefined
}
```

The same VSCode refactor menu also offers **Extract Method** (isolate a reusable block),
**Extract Variable** (name a repeated expression), and **Rename Symbol** (consistent
rename across the codebase). All three are the mechanical half of pattern adoption:
patterns are mostly named structures, and these actions are how you introduce the names.

## Key Takeaways

1. Prefer `interface` for object contracts; use `type` for unions, intersections, and
   aliasing. Contracts first, computation second.
2. Turn on `strict` (which implies `noImplicitAny` and `strictNullChecks`) before you
   start applying patterns — patterns without enforced contracts are just conventions.
3. Replace every runtime shape check you can with a structurally typed parameter; keep
   `unknown` + a `value is T` type guard for the boundaries you genuinely can't type.
4. Migrate JavaScript incrementally: one module at a time, `.js` → `.ts`, let the errors
   be the work list, and treat `allowJs` as a temporary bridge, not a destination.
5. Learn the five UML relationships (association, aggregation, composition, inheritance,
   implementation) — every pattern diagram in the rest of the book is built from them.
6. Refactor only with tests in place; TypeScript catches structural breakage, not
   behavioral regressions.

## Connects To

- **Ch 2**: advanced types and type inference — the deeper half of "Working with types."
- **Ch 3**: Singleton and Factory, validated with the Vitest setup introduced here.
- **Ch 5**: Strategy — the payoff of interfaces-as-parameters shown in this chapter.
- **Ch 9**: Domain-Driven Design as the discipline for turning business rules into the
  UML/class structure this chapter teaches you to draw.
- **Gang of Four**: the source vocabulary this book re-implements in modern TypeScript.
