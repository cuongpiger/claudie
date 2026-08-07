# Chapter 10: Anti-Patterns and Workarounds

## Core Idea
TypeScript is adaptive enough to accept idioms from Java, Go, and classical OOP — and
that's the trap. Prefer plain functions and types over classes, be precise instead of
permissive with types, and use the compiler's newest features rather than fighting it.

## Frameworks Introduced

- **The banana–monkey–jungle problem** — the canonical name for inheritance-driven
  dependency sprawl: to use a `Banana` you end up importing a `Jungle` containing a
  `Monkey` that exposes `getBanana()`.
  - Symptom: `new Jungle().getAnimalByType("Monkey").getBanana()`.
  - Fix: **favor composition over inheritance**. Make `Jungle` a *container/context* that
    holds animals and fruits, not a class coupled to specific animal behaviors.
  - Why composition wins: behaviors combine at runtime, dependencies shrink, and pieces
    swap without restructuring. Inheritance produces hierarchies where a change ripples
    across multiple parts of the codebase.

- **Black-box reuse** — using a component through its interface alone, knowing nothing of
  its internals.
  - How you get there: split multi-role classes into one class per single well-defined
    interface, then compose them through a class that depends only on those interfaces.
  - Why it matters: you can test and debug the component repeatedly in alternative
    scenarios, and it closely follows the **Liskov Substitution Principle**.

- **Interfaces over classes for models** — for plain data, use an `interface` plus
  factory functions, not a class.
  - Combine with `Readonly<T>` for immutability and `Partial<T>` for updates
    (`{ ...employee, ...updates }`).
  - Benefit: type checking with no class overhead, and immutability by construction.

- **`const` assertions** — `as const` narrows object literals to their literal types.
  - Without it, `colors[color]` returns `string`. With it, the return type is
    `"#FF0000" | "#00FF00" | "#0000FF"` — enabling stricter checking and IDE
    autocompletion.
  - Pairs with `keyof typeof colors` to derive the parameter type from the data.

- **`NoInfer<T>`** (TS 5.4) — mark a type parameter position as ineligible for inference.
  - Problem it solves: when `T` appears in two positions, both contribute to inference
    and `T` widens to their union — so an invalid argument silently typechecks.
  - Use it on the parameter that should be *constrained by* the other, not contribute to
    it.

## Key Concepts

- **God object** — a class that knows or does too much; violates SRP and breeds complexity.
- **POJO / JavaBean** — the Java convention (private fields, `get`/`set` prefixed
  accessors, public no-arg constructor, `Serializable`). Three of these four do not
  translate: TypeScript allows only one constructor, a no-arg constructor triggers
  uninitialized-property errors, and `Serializable` has no meaning.
- **Go-style error tuples** — `[T | null, Error | null]` with an explicit `err !== null`
  check at every call site. Explicit, but not idiomatic TypeScript.
- **Implicit vs. explicit typing** — `const arr = [1,2,3]` infers `number[]`;
  `let x;` (declare without assign) infers `any` and fails under `noImplicitAny`.
- **`unknown` as the safe `any`** — forces a type check before any operation.
- **Type widening in generics** — inference from multiple positions unions them together
  rather than constraining one by the other.

## Mental Models

- **Prefer composition; reach for inheritance only when the hierarchy is genuinely
  is-a.** Partial reuse via `extends` is the smell — it couples the whole chain.
- **Think of `any` as opting out of TypeScript.** `unknown` is the version that keeps the
  contract: you must prove the type before using it.
- **`Function` is `any` for callables.** It accepts every signature, so nothing about
  arguments or return types is checked.
- **If your TypeScript looks like Java, you're carrying overhead for nothing.**
  Getters/setters are usually unnecessary — for encapsulation, expose getters only and
  construct a *new* instance for updates.
- **If your TypeScript looks like Go, you're rejecting the language's error facilities.**
  Use exceptions with `try`/`catch`, and Promises/`async`-`await` for async control flow —
  they abstract error handling and propagation that Go forces you to thread manually.
- **Name generic parameters descriptively.** `TKey`/`TValue`/`TData`/`TError` beat
  `T`/`K`/`U` the moment there is more than one.

## Anti-patterns

- **Deep inheritance for partial reuse** (`CSV` → `ExcelToCSV` → `ExcelToPDF`): each
  subclass overrides one method and inherits the other, so every consumer must drag in
  the whole chain. Breaks SRP and couples all three classes.
- **`any` via untyped parameters**: `function processValue(value)` infers `any`;
  `processValue(123)` then throws `value.toUpperCase is not a function` at runtime.
- **The `Function` type**: `onEvent: Function` accepts `(a: string) => string`,
  `() => string`, and `() => number` equally — no argument or return-type checking at all.
- **POJOs/JavaBeans in TypeScript**: verbose `get`/`set` pairs, plus TypeScript won't
  allow the required no-arg constructor alongside a parameterized one.
- **`JSON.stringify` as a general serializer**: works for basic cases only — no
  polymorphism, no object identity, and it mishandles `Map`, `Set`, and `BigInt`. Write a
  custom object mapper or use a Factory Method.
- **Go-style `[result, err]` tuples**: forces a null check after every call and makes
  error propagation through nested calls cumbersome.
- **Declaring without assigning** (`let x;`): infers `any` and fails under
  `noImplicitAny`. Declare the expected type.
- **Skipping `as const` on literal maps**: return types widen to `string`, losing
  autocomplete and narrowing.
- **Single-letter generics with multiple parameters**: `KeyValuePair<T, K>` and
  `ApiResponse<T, K>` say nothing about which is which.
- **Permissive default generics** (`type Config<T = {}, U = {}>`): `ctx` is inferred as
  `{}`, so `t.ctx.color` errors even though you assigned `{color: 'red'}`. Constrain with
  `T extends WithColor` instead.
- **Ignoring new TypeScript features**: not using `NoInfer` (5.4) means accepting silent
  type widening that would otherwise be a compile error.

## Code Examples

Inheritance sprawl — the problem:

```typescript
interface Reader { read(): string[] }
interface Writer { write(input: string[]): void }

class CSV implements Reader, Writer {
  constructor(private csvFilePath: string) {}
  read(): string[] { return ["data1", "data2"] }
  write(input: string[]): void { /* write CSV */ }
}

class ExcelToCSV extends CSV {                    // overrides read, inherits write
  constructor(csvFilePath: string, private excelFilePath: string) { super(csvFilePath) }
  read(): string[] { return ["excelData1", "excelData2"] }
}

class ExcelToPDF extends ExcelToCSV {             // overrides write, inherits read
  constructor(csvFilePath: string, excelFilePath: string, private pdfFilePath: string) {
    super(csvFilePath, excelFilePath)
  }
  write(input: string[]): void { /* write PDF */ }
}
// To use ExcelToPDF you now depend on ExcelToCSV AND CSV.
```

Composition — the fix (black-box reuse):

```typescript
class CSVReader   implements Reader { constructor(private csvFilePath: string) {}
                                      read(): string[] { return ["data1", "data2"] } }
class CSVWriter   implements Writer { write(input: string[]): void {} }
class ExcelReader implements Reader { constructor(private excelFilePath: string) {}
                                      read(): string[] { return ["excelData1"] } }
class PDFWriter   implements Writer { write(input: string[]): void {} }

class ReaderToWriters {
  constructor(private reader: Reader, private writers: Writer[]) {}
  perform() {
    const lines = this.reader.read()
    this.writers.forEach((writer) => writer.write(lines))
  }
}
// Any reader, any set of writers. No hardcoded dependency.
```

Interfaces + factory functions instead of a class:

```typescript
interface Employee {
  readonly id: string
  readonly name: string
  readonly department: string
}

function createEmployee(id: string, name: string, department: string): Employee {
  return { id, name, department }
}

function updateEmployee(employee: Employee, updates: Partial<Employee>): Employee {
  return { ...employee, ...updates }      // immutable update
}

const emp = createEmployee("1", "John Doe", "IT")
const updatedEmp = updateEmployee(emp, { department: "HR" })
```

Replacing `Function` with a generic callback type:

```typescript
// BEFORE — all three typecheck, none are actually checked
interface Callback { onEvent: Function }

// AFTER
interface Callback<T> { onEvent: (arg: T) => void }

const stringCallback: Callback<string> = { onEvent: (a) => console.log(a.toUpperCase()) }
const numberCallback: Callback<number> = { onEvent: (n) => console.log(n * 2) }

stringCallback.onEvent(5)   // Error: 'number' is not assignable to 'string'
```

Go-style errors vs. idiomatic TypeScript:

```typescript
// NOT idiomatic — Go's multiple-return pattern
function divideNumbers(a: number, b: number): [number | null, Error | null] {
  if (b === 0) return [null, new Error("Division by zero")]
  return [a / b, null]
}
const [result, err] = divideNumbers(10, 2)
if (err !== null) console.error("Error:", err.message)

// Idiomatic TypeScript
function divideNumbers(a: number, b: number): number {
  if (b === 0) throw new Error("Division by zero")
  return a / b
}
try {
  console.log("Result:", divideNumbers(10, 2))
} catch (error) {
  console.error("Error:", error.message)
}
```

`as const` for accurate literal return types:

```typescript
// BEFORE — getColor returns `string`
const colors = { red: "#FF0000", green: "#00FF00", blue: "#0000FF" }
function getColor(color: "red" | "green" | "blue") { return colors[color] }

// AFTER — returns "#FF0000" | "#00FF00" | "#0000FF"
const colors = { red: "#FF0000", green: "#00FF00", blue: "#0000FF" } as const
function getColor(color: keyof typeof colors) { return colors[color] }
```

Constraining default generics:

```typescript
// BEFORE — ctx infers as {}, so t.ctx.color is an error
type Config<T = {}, U = {}> = { ctx?: T; data?: U }
const t: Config = { ctx: { color: "red" }, data: {} }
// t.ctx.color  → Property 'color' does not exist on type '{}'

// AFTER — the constraint carries the shape
type WithColor = { color: string }
type Config<T extends WithColor, U = {}> = { ctx?: T; data?: U }

const t: Config<WithColor> = { ctx: { color: "red" }, data: {} }
if (t.ctx) t.ctx.color = "blue"
```

## Reference Tables

Permissive types and their replacements:

| Anti-pattern | Problem | Replacement |
|---|---|---|
| `any` | opts out of type checking entirely | `unknown` + a type guard |
| untyped parameter | implicitly `any` | annotate; enable `noImplicitAny` |
| `Function` | any signature passes | `(arg: T) => R` or a generic callback interface |
| `let x;` | infers `any` | declare the expected type |
| object literal without `as const` | widens to `string` | `as const` + `keyof typeof` |
| `type C<T = {}>` | infers `{}`, blocks property access | `T extends SomeShape` |

Foreign idioms that don't translate:

| Origin | Idiom | Why it fails in TypeScript | Use instead |
|---|---|---|---|
| Java | POJO/JavaBean | only one constructor allowed; no-arg ctor leaves fields uninitialized; `Serializable` is meaningless | `interface` + factory functions |
| Java | `get`/`set` pairs | verbose; rarely needed | getters only; construct a new instance to "update" |
| Java | field serialization | `JSON.stringify` drops polymorphism, identity, `Map`/`Set`/`BigInt` | custom object mapper or Factory Method |
| Go | `[value, error]` tuples | null check at every call; awkward propagation | `throw` + `try`/`catch`; Promises + `async`/`await` |
| Classical OOP | deep inheritance for partial reuse | tight coupling across the chain; breaks SRP | composition + one interface per role |

Generic naming:

| Instead of | Write |
|---|---|
| `KeyValuePair<T, K>` | `KeyValuePair<TKey, TValue>` |
| `ApiResponse<T, K>` | `ApiResponse<TData, TError>` |

## Worked Example

**`NoInfer<T>` — catching a bug the type checker silently allows:**

Start with a generic `find` that looks correct:

```typescript
function find<T extends string>(heyStack: T[], needle: T): number {
  return heyStack.indexOf(needle)
}

console.log(find(["a", "b", "c"], "d"))   // compiles fine — and always returns -1
```

Hover over the call and TypeScript reports:

```typescript
function find<"a" | "b" | "c" | "d">(
  heyStack: ("a" | "b" | "c" | "d")[],
  needle:    "a" | "b" | "c" | "d",
): number
```

**Why.** `T` appears in *both* parameter positions, so both contribute to inference.
TypeScript widens `T` to the union of everything it saw — including `"d"` from the very
argument that should have been rejected. The call is self-justifying: passing an invalid
value expands the type until the value becomes valid.

**The fix.** Mark the second position as ineligible for inference, so `T` is determined
solely by the array:

```typescript
function find<T extends string>(heyStack: T[], needle: NoInfer<T>): number {
  return heyStack.indexOf(needle)
}

const invalidResult = find(["a", "b", "c"], "d")
// Argument of type '"d"' is not assignable to parameter of type '"a" | "b" | "c"'
```

`T` now infers as `"a" | "b" | "c"` from `heyStack` alone, and `needle` is *checked
against* it rather than contributing to it. This is the general shape: when one parameter
should constrain another, wrap the constrained one in `NoInfer`.

The broader lesson the chapter draws from this: **regularly review the codebase for
places newer TypeScript features would tighten checking**. `NoInfer` shipped in 5.4;
code written before it silently accepts bugs that a one-word change would catch.

## Key Takeaways

1. Favor composition over inheritance. Partial reuse through `extends` couples the whole
   chain and breaks SRP — split into one interface per role and compose.
2. Aim for black-box reuse: depend only on interfaces, so components can be swapped,
   tested, and debugged without knowing their internals.
3. For plain data models, use `interface` + factory functions with `Readonly`/`Partial`,
   not classes.
4. Never `any`. Use `unknown` and narrow. Never `Function`. Use an explicit signature or
   a generic callback interface.
5. Don't write Java in TypeScript (POJOs, `get`/`set` pairs) or Go in TypeScript
   (`[value, error]` tuples). Use exceptions, Promises, and `async`/`await`.
6. `JSON.stringify` is not a serializer for real domain objects — it loses polymorphism,
   identity, `Map`, `Set`, and `BigInt`.
7. Add `as const` to literal maps and derive parameter types with `keyof typeof` to keep
   return types narrow.
8. Name generic parameters descriptively (`TKey`, `TData`, `TError`) and constrain
   defaults with `extends` rather than leaving them as `{}`.
9. Use `NoInfer<T>` when one parameter should constrain another — otherwise inference
   widens `T` to include the very value you wanted rejected.

## Connects To

- **Ch 1**: `noImplicitAny`, `unknown` vs. `any`, type guards, and the first mention of
  `NoInfer`.
- **Ch 2**: `Readonly`, `Partial`, `keyof`, and generic constraints.
- **Ch 4**: composition-based structural patterns as the alternative to inheritance.
- **Ch 9**: SRP and the God object; Liskov Substitution, which black-box reuse follows.
- **Ch 11**: how tRPC and Apollo Client avoid these anti-patterns in production code.
- **refactoring.guru/refactoring/smells**: the recommended code-smell catalog.
