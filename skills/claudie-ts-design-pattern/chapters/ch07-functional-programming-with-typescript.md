# Chapter 7: Functional Programming with TypeScript

## Core Idea
Functional programming supplies *design concepts* (not patterns): purity, composition,
immutability, and referential transparency. These are the building blocks you combine to
build composable programs — and TypeScript adds static typing on top, with one hard
limit: **no Higher-Kinded Types**.

## Frameworks Introduced

- **Pure functions** — two required properties:
  1. **Deterministic output**: same arguments → same result, always.
  2. **No side effects**: nothing that touches the world outside the program (console,
     files, network, mutation of external state).
  - Mental frame: a pure function is a mathematical function — **domain** (arguments),
    **codomain** (return type), **range** (actual returned values).

- **IO actions** — the discipline for managing (not eliminating) side effects.
  - How: `interface IO<A> { (): A }` — wrap the effect in a thunk so the type signature
    *announces* impurity and the effect isn't executed until you call it.
  - Two benefits: side-effecting functions become visibly marked, and they can be
    composed and manipulated before any effect fires.

- **Function composition** — apply one function to the result of another: `f(g(x))`.
  - Utility: `compose(...fns)` using `reduceRight`, so the list reads bottom-to-top and
    output feeds into the next input.
  - **Rule of thumb: cap composition depth at 3–4 functions.** Beyond that, break it into
    chunks — deep nesting costs call-stack depth and memory, and TypeScript's inference
    starts needing explicit annotations.

- **Currying** — convert an n-argument function into a chain of one-argument functions,
  so it can participate in composition.

- **Immutability — four escalating levels**:
  1. `const` — prevents *reassignment* only; `array.push()` still mutates.
  2. `Readonly<T>` — property reassignment fails at compile time (shallow).
  3. `DeepReadonly<T>` — a recursive conditional/mapped type that freezes nested
     structures at the type level. Still bypassable with a cast.
  4. **Immutable.js** — genuinely immutable data structures, enforced *at runtime*, so
     even a cast can't mutate them.

- **Functional lenses** — a getter/setter pair packaged as a composable object.
  - `interface Lens<T, A> { get: (obj: T) => A; set: (obj: T) => (newValue: A) => T }`
  - Three helpers: `view(lens, obj)`, `set(lens, obj, value)`, and `over(lens, f, obj)`
    (get → transform → set in one step).
  - When to use: reading/updating deeply nested structures; maintaining immutability
    while updating; transforming or aggregating from nested data.
  - Analogy: an **Adapter** where the target is the object and the lens is the adaptee —
    but generic and composable.

- **The functional-structure ladder** — each level adds one capability:
  - **Functor** — has `map`: apply a function to a wrapped value, structure unchanged.
  - **Applicative** — adds `ap`: apply a *wrapped function* to a wrapped value.
  - **Semigroup** — has `concat`: an **associative** binary operation on a type.
  - **Monoid** — a Semigroup plus an **identity** element (`0` for sum, `1` for product,
    `""` for string concat).
  - **Traversable** — has `traverse`: apply a function to each element and collect the
    results (typically via `flatMap`).
  - **Monad** — a Functor plus `of` (unit) plus `flatMap` (flatten).

- **Monad laws** — three structural requirements plus three algebraic laws:
  - Structure: `map` (Functor law), `of` (Unit law), `flatMap` (Flatten law).
  - **Left identity**: `M.of(a).flatMap(f) === f(a)`
  - **Right identity**: `m.flatMap(M.of) === m`
  - **Associativity**: `m.flatMap(f).flatMap(g) === m.flatMap(x => f(x).flatMap(g))`

- **Three practical monads**:
  - **`Maybe`** — an optional value; eliminates repeated `null` checks.
  - **`Either<L, R>`** — error handling without exceptions; `left` = failure,
    `right` = success.
  - **`State<S, A>`** — a function `S -> (A, S)`; chain state-dependent computations
    where each step reads state, produces a result, and may return new state.

## Key Concepts

- **Declarative vs. imperative** — declarative states *what* (`filter().reduce()`);
  imperative states *how* (mutable accumulator in a `for` loop, order-sensitive).
- **Closure** — a function retaining access to its defining scope after that scope has
  returned.
- **Referential transparency** — you can replace any call with its value without changing
  the program's result. Another name for consistency and determinism.
- **Tail call optimization** — restructuring recursion so the recursive call is the last
  operation. **TypeScript/JavaScript runtimes do not implement TCO** — large inputs still
  overflow the stack.
- **Functions as first-class citizens** — assignable to variables, passable as arguments,
  returnable from functions, storable in data structures. All four are prerequisites for
  higher-order functions.
- **Higher-Kinded Types (HKTs)** — types that operate on other types. TypeScript has no
  built-in support, which is why hand-rolled Applicative/Monad hierarchies hit inference
  errors and why `fp-ts` exists.
- **Arity** — the number of arguments a function takes; mismatched arity is what makes
  naive composition fail.

## Mental Models

- **Prefer declarative for functional code, imperative for state manipulation.** The
  author is explicit that imperative is *more* intuitive when you're genuinely
  manipulating state — the preference isn't absolute.
- **`IO<A>` is a label, not a cage.** It doesn't prevent effects; it makes them visible
  in the type signature and defers them until invocation.
- **Think of a lens as a scope over an object.** You create the scope once, then read and
  write through it compositionally, never touching the original.
- **A monad is composition glue.** Without `flatMap` and the associativity law, chaining
  fallible or effectful operations degenerates into nested `if (x !== null)`.
- **When TypeScript's inference gives up on a functional abstraction, reach for `fp-ts`
  rather than fighting it.** The missing feature is HKTs, and no amount of generics
  syntax works around it.

## Anti-patterns

- **`const` mistaken for immutability**: `const numbers = [1,2,3]; numbers.push(4)`
  succeeds. `const` binds the reference, not the contents.
- **`Readonly<T>` mistaken for deep immutability**: it's shallow, exactly like `Partial`
  and `Required` (Ch 2).
- **Escaping `DeepReadonly` with a cast**: `(dept.name as string) = "Billing"` compiles
  and mutates. Type-level immutability is advisory; only runtime-immutable structures
  (Immutable.js) are enforced.
- **Non-transparent sort**: `list.sort()` mutates the input, so calling it twice gives
  different results. Fix: `[...list].sort()`.
- **Relying on tail recursion for large inputs**: the code is *conceptually* correct but
  the runtime doesn't optimize it — it still overflows.
- **Unintended variable capture in closures**: closures inside loops capturing a variable
  that changes over time is the classic bug.
- **Deep composition chains**: past ~4 functions, expect inference failures and stack
  cost.
- **Immutability in performance-critical code**: every update allocates a new copy.
  The `ImmutablePerson.withAge()` pattern is fine for occasional updates and triggers
  excessive GC when updates are frequent.
- **Hand-rolling Applicatives/Monads in TypeScript**: `maybeNumber1.ap(maybeAdd.ap(...))`
  fails to typecheck because of missing HKTs. There is, in the author's words, "no easy
  solution" — use `fp-ts`.

## Code Examples

Imperative vs. declarative — the same computation:

```typescript
// Imperative: mutable accumulator, order-sensitive
let evenSum = 0
for (let i = 1; i <= 10; i++) {
  if (i % 2 === 0) evenSum += i
}

// Declarative: a pipeline of transformations
const numbers = Array.from({ length: 10 }, (_, i) => i + 1)
const sum = numbers.filter((n) => n % 2 === 0).reduce((acc, n) => acc + n, 0)  // 30
```

IO actions — making effects visible:

```typescript
interface IO<A> { (): A }

const getCurrentTime: IO<string> = () => new Date().toISOString()
const logMessage = (message: string): IO<void> => () => console.log(message)

logMessage("Hello, World!")()   // the trailing () is where the effect actually happens
```

Composition utility + currying:

```typescript
function compose<T>(...fns: Array<(arg: T) => T>) {
  return (x: T) => fns.reduceRight((acc, fn) => fn(acc), x)
}

function curry<T, U, V>(fn: (a: T, b: U) => V): (a: T) => (b: U) => V {
  return (a: T) => (b: U) => fn(a, b)
}

const curriedTruncate = curry(truncate)
const formatAndTruncate = compose(
  (s: string) => curriedTruncate(s)(7),
  removeSpaces,
  capitalizeFirstLetter,        // runs first — read bottom to top
)
```

Referential transparency — the fix is one spread:

```typescript
// NOT transparent: mutates the input
function sortList(list: number[]): number[] { return list.sort((a, b) => a - b) }

// Transparent: copies first
function pureSort(list: number[]): number[] { return [...list].sort((a, b) => a - b) }
```

`DeepReadonly` — recursive immutability at the type level:

```typescript
type DeepReadonly<T> =
  T extends (infer R)[]   ? ReadonlyArray<DeepReadonly<R>> :
  T extends Function      ? T :
  T extends object        ? { readonly [K in keyof T]: DeepReadonly<T[K]> } :
  T

const dept: DeepReadonly<Department> = { name: "Engineering", employees: [...] }
dept.name = "Sales"                             // Error
dept.employees.push({ id: 3, name: "Charlie" }) // Error
dept.employees[0].name = "Alicia"               // Error
;(dept.name as string) = "Billing"              // ...but this compiles and mutates
```

Immutable.js — enforcement that survives a cast:

```typescript
import { List, Map } from "immutable"

const list1 = List([1, 2, 3])
const list2 = list1.push(4)
console.log(list1.toArray())   // [1, 2, 3]  — original untouched
console.log(list2.toArray())   // [1, 2, 3, 4]

;(list1 as any).push(5)
console.log(list1.toArray())   // [1, 2, 3]  — still untouched at RUNTIME
```

Semigroup and Monoid:

```typescript
interface Semigroup<T> { concat(other: T): T }
interface Monoid<T> extends Semigroup<T> { identity(): T }

class Product implements Semigroup<Product>, Monoid<Product> {
  constructor(public value: number) {}
  concat(other: Product): Product { return new Product(this.value * other.value) }
  identity(): Product { return new Product(1) }   // 1 is neutral for multiplication
}

function concatAll<T extends Semigroup<T>>(xs: T[]): T {
  return xs.reduce((acc, x) => acc.concat(x))
}
```

`fp-ts` for the abstractions TypeScript can't express natively:

```typescript
import { pipe } from "fp-ts/function"
import * as O from "fp-ts/Option"
import * as A from "fp-ts/Array"
import * as N from "fp-ts/number"
import { sequenceT } from "fp-ts/Apply"

// Applicative — what the hand-rolled Maybe couldn't typecheck
const add = (a: number) => (b: number) => a + b
const result = pipe(
  sequenceT(O.option)(O.some(add), O.some(5), O.some(10)),
  O.map(([fn, a, b]) => fn(a)(b)),
)
console.log(O.getOrElse(() => 0)(result))     // 15

// Monoid fold
const sum = pipe([1, 2, 3, 4], A.foldMap(N.MonoidSum)((n) => n))   // 10

// Traversable — one None poisons the whole result
const traversed = pipe([O.some(1), O.some(2), O.none, O.some(4)],
                       A.traverse(O.Applicative)((n) => n))        // None
```

## Reference Tables

The functional-structure ladder:

| Structure | Required method | Adds |
|---|---|---|
| Functor | `map` | apply a function inside a context |
| Applicative | `ap` (+ `map`) | apply a *wrapped* function |
| Semigroup | `concat` | associative combination |
| Monoid | `concat` + `identity` | a neutral element |
| Traversable | `traverse` | apply-and-collect across a structure |
| Monad | `map` + `of` + `flatMap` | flatten nested contexts; sequencing |

Immutability enforcement levels:

| Mechanism | Prevents reassignment | Prevents mutation | Prevents nested mutation | Survives a cast |
|---|---|---|---|---|
| `const` | ✓ | ✗ | ✗ | n/a |
| `Readonly<T>` | ✓ | ✓ (top level) | ✗ | ✗ |
| `DeepReadonly<T>` | ✓ | ✓ | ✓ | ✗ |
| Immutable.js | ✓ | ✓ | ✓ | ✓ (runtime) |

Managing side effects — the author's comparison:

| Approach | Strengths | Limitations |
|---|---|---|
| IO actions | effects clearly marked; composable | complexity in managing actions |
| Dependency injection | decouples components; testable | added complexity; needs a DI framework |
| Observer pattern | loose coupling | memory leaks if unmanaged; hard-to-trace event chains |

Monad laws, at a glance:

| Law | Statement |
|---|---|
| Left identity | `M.of(a).flatMap(f) === f(a)` |
| Right identity | `m.flatMap(M.of) === m` |
| Associativity | `m.flatMap(f).flatMap(g) === m.flatMap(x => f(x).flatMap(g))` |

Which monad:

| Problem | Monad |
|---|---|
| Value may be absent | `Maybe` / `Option` |
| Operation may fail with a reason | `Either<L, R>` / `Result` |
| Threading state through a computation | `State<S, A>` |
| Marking and deferring a side effect | `IO<A>` |

## Worked Example

**The `Maybe` monad, motivated end to end** — the author builds up from the problem:

Step 1 — plain composition works fine for total functions:

```typescript
function add2(x: number): number { return x + 2 }
function mul3(x: number): number { return x * 3 }

mul3(add2(2))   // 12
add2(mul3(2))   // 8
```

Step 2 — partial functions break it. Every step must now guard:

```typescript
function safeDivide(x: number, y: number): number | null { return y !== 0 ? x / y : null }
function safeSquareRoot(x: number): number | null { return x >= 0 ? Math.sqrt(x) : null }

const result = safeDivide(16, 4)
if (result !== null) {
  const sqrtResult = safeSquareRoot(result)
  if (sqrtResult !== null) {
    console.log(sqrtResult)
  }
}
// ...and this nesting deepens with every additional step
```

Step 3 — put the null-ness inside a container that knows how to skip:

```typescript
class Maybe<T> {
  private constructor(private value: T | null) {}

  static just<T>(value: T): Maybe<T>  { return new Maybe(value) }
  static nothing<T>(): Maybe<T>       { return new Maybe<T>(null) }

  map<U>(fn: (value: T) => U): Maybe<U> {
    return this.value === null ? Maybe.nothing() : Maybe.just(fn(this.value))
  }

  flatMap<U>(fn: (value: T) => Maybe<U>): Maybe<U> {
    return this.value === null ? Maybe.nothing() : fn(this.value)
  }
}
```

Step 4 — rewrite the functions to return `Maybe<number>` instead of `number | null`:

```typescript
function safeDivide(x: number, y: number): Maybe<number> {
  return y !== 0 ? Maybe.just(x / y) : Maybe.nothing()
}
function safeSquareRoot(x: number): Maybe<number> {
  return x >= 0 ? Maybe.just(Math.sqrt(x)) : Maybe.nothing()
}
```

Step 5 — composition is a single line again, with failure short-circuiting:

```typescript
const result        = safeDivide(16, 4).flatMap(safeSquareRoot)  // Maybe { value: 2 }
const invalidResult = safeDivide(16, 0).flatMap(safeSquareRoot)  // Maybe { value: null }
```

**Why `flatMap` and not `map`.** `safeSquareRoot` already returns a `Maybe`, so `map`
would produce `Maybe<Maybe<number>>`. `flatMap` is precisely the "flatten" operation the
Monad laws require — it's what makes chaining fallible steps stay flat no matter how many
you add.

## Key Takeaways

1. A pure function is deterministic *and* effect-free — both properties, not either.
2. Use `IO<A>` to make effects visible and deferred; the paradigm manages side effects
   rather than banning them.
3. `const` ≠ immutable, `Readonly<T>` ≠ deep, `DeepReadonly<T>` ≠ cast-proof. Only
   runtime-immutable structures (Immutable.js) are actually enforced.
4. Restore referential transparency by copying before you sort/mutate: `[...list].sort()`.
5. Do not depend on tail-call optimization — JS/TS runtimes don't implement it.
6. Keep compositions to 3–4 functions; curry to make multi-argument functions composable.
7. Use lenses (`view`/`set`/`over`) for deep immutable updates — they replace the
   destructuring pyramids common in Redux reducers.
8. Climb the ladder deliberately: Functor → Applicative → Monad, Semigroup → Monoid.
   Each adds exactly one capability.
9. TypeScript has no Higher-Kinded Types. Hand-rolled Applicatives and Monads hit
   inference walls — use `fp-ts` for anything beyond a simple `Maybe`.

## Connects To

- **Ch 2**: conditional types, `infer`, and mapped types — the machinery behind
  `DeepReadonly`; discriminated-union results are the imperative ancestor of `Either`.
- **Ch 4**: Adapter — the mental model for what a lens does.
- **Ch 5**: the State monad resembles Chain of Responsibility, except each step returns
  *new* state rather than mutating.
- **Ch 6**: Memento — immutability makes snapshots cheap and safe.
- **Ch 8**: reactive programming, where these composition principles meet async streams.
- **Ch 10**: anti-patterns, including the misuse of these abstractions.
