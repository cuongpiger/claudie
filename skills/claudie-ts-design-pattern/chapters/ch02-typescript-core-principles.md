# Chapter 2: TypeScript Core Principles

## Core Idea
The advanced type system — utility types, `keyof`, conditional types with `infer`,
mapped types, and branded types — is the machinery you use to encode business rules at
the type level, so invalid states fail at compile time rather than in production.

## Frameworks Introduced

- **Branded (nominal) types**: simulate nominal typing inside TypeScript's structural
  system by intersecting a type with a unique marker.
  - When to use: when two types have identical structure but must not be
    interchangeable — `UserId` vs `OrderId`, validated vs unvalidated input, a
    `Point3d` intended for Euclidean math vs an arbitrary `{x,y,z}`.
  - How: `type NominalTyped<Type, Brand> = Type & { __type: Brand }`, then brand with a
    `unique symbol` (`typeof Symbol("Brand1")`) rather than a string literal.
  - Why the symbol matters: two string-branded types could still collide; unique symbols
    guarantee the compiler treats them as distinct even when both wrap `number`.

- **Conditional types + `infer`**: compute a type from a condition and extract type
  variables out of a structure.
  - When to use: modelling API responses that vary by shape, unwrapping container types,
    or writing your own utility types.
  - How: `A extends B ? C : D`; inside the `extends` clause, `infer E` names a position
    so you can return it. Recurse by referring to the alias itself.

- **Mapped types**: transform every property of an existing type by rule.
  - When to use: deriving variants (all-optional, all-readonly, relabelled) instead of
    hand-writing a parallel interface that will drift.
  - How: `{ [P in keyof T]: ... }`, with `?`/`readonly` modifiers, and `as` for key
    remapping via template literals.

- **Three ways to type a React component** — pick deliberately:
  1. `React.FC<Props>` — adds React-specific fields (`defaultProps`, `displayName`).
  2. `(props: Props) => JSX` — plain function signature, no React extras. Simplest.
  3. `React.FC<PropsWithChildren<Props>>` — when the component renders `children`.

- **Two error-modelling strategies** (the chapter presents them as a real choice):
  - **Custom error classes** extending `Error`, discriminated at the catch site with
    `instanceof`. Errors propagate automatically up the stack.
  - **Discriminated union results** (`{success: true, value} | {success: false, error}`).
    Type-safe and explicit, but errors must be threaded manually through every call —
    more verbose, more procedural, impossible to forget.

## Key Concepts

- **`Record<K, T>`** — object type with keys from `K` and values of `T`; structurally
  equivalent to an index signature.
- **`Partial<T>` / `Required<T>`** — all properties optional / all mandatory. **Both are
  shallow** — they do not recurse into nested objects.
- **`Pick<T, K>` / `Omit<T, K>`** — keep only / drop the named properties.
- **`keyof T`** — union of `T`'s property names as string literal types. Powers
  autocomplete on key-based APIs.
- **Structural vs nominal typing** — TypeScript compares *shape*; Java/Go compare
  *identity*. Branded types buy back the nominal behaviour where you need it.
- **Discriminated union** — union of object types sharing a literal-typed field the
  compiler can narrow on (`success: true | false`).
- **Bootstrapping (Nest.js)** — creating the app instance, configuring pipes, listening.
- **Graceful shutdown** — handling `SIGINT`/`SIGTERM` to clean up before `process.exit`.

## Mental Models

- **Think of utility types as the standard library of the type level.** Before writing a
  parallel interface by hand, ask whether `Pick`/`Omit`/`Partial`/`Record` derives it.
- **Use `keyof` whenever a string identifies a field.** It converts a stringly-typed API
  into an autocompleted, refactor-safe one.
- **Use a brand when structure isn't the whole truth.** If `string` is really "a string
  that has been validated," the type should say so.
- **Design servers to be stateless and restartable.** The author's rule: avoid global
  state and long-lived mutable structures, so a process can be killed and replaced at
  any moment without information loss. That's what makes scaling and process managers
  (PM2, nodemon) work.
- **Patterns are vocabulary before they are code.** Saying "Singleton" or "Factory"
  transmits a design decision in one word — that shared language is half their value.

## Anti-patterns

- **Assuming `Partial`/`Required` are deep**: nested objects keep their original
  optionality. You must apply the utility at each level explicitly.
- **Branding with non-unique markers**: two brands that aren't unique symbols can be
  mutually assignable, silently defeating the whole point.
- **Centralized error handling as the only layer**: a global Express error middleware
  (`res.status(500)`) is coarse-grained. It cannot produce specific status codes or
  useful debug detail — you still need `try/catch` inside handlers for that.
- **Relying on `SIGTERM` for cleanup**: `SIGINT` (Ctrl+C) is the softer signal that lets
  a process finish cleanup; `SIGTERM` is more forceful and may not give you the chance.
- **Treating patterns as a silver bullet**: apply them based on project context. The
  book's own framing is that each pattern must be re-evaluated in the light of what
  TypeScript already gives you for free.

## Code Examples

`keyof` turning a stringly-typed action into a checked one:

```typescript
interface SignupFormState { email: string; name: string }

interface ActionPayload<T> {
  key: keyof T          // => "email" | "name"
  value: string
}

type SignupFormAction = ActionPayload<SignupFormState>

const ok: SignupFormAction  = { key: "email", value: "a@b.com" }
const bad: SignupFormAction = { key: "username", value: "x" }
// Error: Type '"username"' is not assignable to type 'keyof SignupFormState'
```

Branded types with unique symbols:

```typescript
type NominalTyped<Type, Brand> = Type & { __type: Brand }

const Brand1 = Symbol("Brand1")
const Brand2 = Symbol("Brand2")

type TypeA = NominalTyped<number, typeof Brand1>
type TypeB = NominalTyped<number, typeof Brand2>

const a: TypeA = 10 as TypeA
const b: TypeB = 10 as TypeB
const c: TypeA = b   // Error: Type 'TypeB' is not assignable to type 'TypeA'
```

Conditional type with `infer`, and the recursive variant:

```typescript
interface Box<T> { value: T }

type UnpackBox<A> = A extends Box<infer E> ? E : A
type intStash = UnpackBox<{ value: 10 }>        // number

type DeepUnpack<T> = T extends Box<infer U> ? DeepUnpack<U> : T
type unpacked = DeepUnpack<Box<Box<Box<string>>>>  // string
```

- **What it demonstrates**: `infer` names a position inside a structure so the
  conditional can return it; self-reference makes the unwrapping recursive.

Mapped type with key remapping:

```typescript
interface Product { id: number; price: number }

type ProductDetails = {
  [P in keyof Product as `product ${P}`]: string
}
// { "product id": string; "product price": string }
```

Discriminated-union error handling:

```typescript
type SuccessResponse = { success: true;  value: number }
type ErrorResponse   = { success: false; error: string }

function divide(dividend: number, divisor: number): SuccessResponse | ErrorResponse {
  if (divisor === 0) return { success: false, error: "Cannot divide by zero." }
  return { success: true, value: dividend / divisor }
}

const result = divide(10, 0)
if (result.success) console.log(result.value)   // narrowed to SuccessResponse
else                console.error(result.error) // narrowed to ErrorResponse
```

## Reference Tables

Core utility types:

| Utility | Creates | Example |
|---|---|---|
| `Partial<T>` | all properties optional (shallow) | `Partial<{name: string; age: number}>` |
| `Required<T>` | all properties mandatory (shallow) | `Required<{name?: string}>` |
| `Pick<T, K>` | only the properties `K` | `Pick<User, 'name'>` |
| `Omit<T, K>` | everything except `K` | `Omit<User, 'password'>` |
| `Record<K, T>` | keys of type `K`, values of type `T` | `Record<'free'\|'used', number>` |
| `NonNullable<T>` | `T` minus `null`/`undefined` | `T extends null\|undefined ? never : T` |

Node.js vs. browser environment:

| Aspect | Node.js (backend) | Browser (frontend) |
|---|---|---|
| File structure | each file is a module | files bundled into one, loaded via `<script>` |
| Modules | CommonJS or ES modules | ES modules, IIFEs |
| Context | server; filesystem + network access | browser; DOM access |
| APIs | `fs`, `http`, … | DOM APIs, events |
| Performance | optimized for concurrent requests | single-threaded; offload via Web Workers |

Server runtimes:

| Runtime | TypeScript | Server entry |
|---|---|---|
| Node.js | transpile first (`tsc`) | `http.createServer(...).listen(8080)` |
| Deno | native, no build step | `Deno.serve({port}, handler)` (`--allow-net`) |
| Bun | native, no build step | `Bun.serve({port, fetch})` |

Express.js vs. Nest.js:

| | Express.js | Nest.js |
|---|---|---|
| Style | minimalist, flexible | structured, opinionated (Angular-inspired) |
| Organization | routes + middleware | modules, controllers, providers |
| DI | none built in | first-class dependency injection |
| Choose when | you want customization and few conventions | you want enforced structure at scale |

## Worked Example

**Graceful shutdown of a long-lived Node server**, end to end — the pattern that makes a
server safely restartable:

```typescript
import * as http from "http"

const shutdownHandler = () => {
  console.log("Received shutdown signal, gracefully exiting...")
  // flush logs, close DB pools, drain in-flight requests here
  process.exit(0)   // 0 = successful termination
}

http
  .createServer((req: http.IncomingMessage, res: http.ServerResponse) => {
    res.write("Hello World!")
    res.end()
  })
  .listen(8080)

process.on("SIGINT",  shutdownHandler)
process.on("SIGTERM", shutdownHandler)
```

Driving it from the OS:

```console
$ lsof -i 8080
COMMAND   PID   USER            FD  TYPE  ...  NAME
node    10416   theo.despoudis  22u IPv6  ...  TCP *:http-alt (LISTEN)

$ kill -INT 10416
# in the server's terminal:
Received shutdown signal, gracefully exiting...
```

`lsof -i <port>` finds the PID; `kill -INT <PID>` sends `SIGINT`, which triggers the
handler. Pair this with a process manager (PM2, nodemon) that restarts on crash, and
with stateless service design so a restart costs nothing.

## Key Takeaways

1. Derive types with `Pick`/`Omit`/`Partial`/`Required`/`Record` instead of duplicating
   interfaces — but remember `Partial`/`Required` are shallow.
2. Use `keyof T` for any API where a string names a field; you get autocomplete and
   rename-safety for free.
3. Reach for branded types with `unique symbol` when structural equality would let two
   semantically different values be swapped.
4. `A extends B ? C : D` plus `infer` is how you compute types; recursion is legal and is
   the standard way to unwrap nested containers.
5. Choose error strategy deliberately: exception classes propagate automatically;
   discriminated-union results force every caller to handle failure but add verbosity.
6. A global error middleware handles the 500 case only — keep `try/catch` in handlers
   for specific status codes and debug detail.
7. Build server processes stateless and shutdown-aware (`SIGINT`/`SIGTERM`), so process
   managers and horizontal scaling actually work.

## Connects To

- **Ch 1**: basic types, `strict`, and structural typing — this chapter is their
  advanced continuation.
- **Ch 3**: Factory Method, which the DOM itself uses to create the right node type per tag.
- **Ch 6**: Visitor, used to traverse the DOM tree.
- **Ch 7**: functional programming — discriminated-union results are the imperative
  ancestor of `Either`/`Option`.
- **Ch 8**: reactive programming — the chapter argues patterns are the foundation you
  need before Observables make sense.
- **Gang of Four (1994)**: the origin of the pattern catalog this book modernizes.
