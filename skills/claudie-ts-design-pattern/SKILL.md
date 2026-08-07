---
name: claudie-ts-design-pattern
description: "Knowledge base from \"TypeScript 5 Design Patterns and Best Practices\" by Theofanis Despoudis. Use when applying GoF design patterns in TypeScript, choosing between Singleton/Factory/Builder/Strategy/Observer/Proxy and their alternatives, working with advanced types (branded types, conditional types, mapped types, utility types), applying SOLID or DDD, writing functional or reactive (RxJS) TypeScript, or diagnosing TypeScript anti-patterns."
---

<!-- argument-hint: [pattern name, topic, or chapter number] -->

# TypeScript 5 Design Patterns and Best Practices
**Author**: Theofanis Despoudis | **Publisher**: Packt (2025) | **Chapters**: 11 | **Generated**: 2026-08-08

## How to Use This Skill

- **Without arguments** — load the core frameworks below for reference
- **With a topic** — ask about `Flyweight`, `branded types`, `SOLID`, `RxJS backpressure`;
  I find and read the relevant chapter
- **With a chapter** — ask for `ch04`; I load that chapter file
- **Browse** — ask "what chapters do you have?" for the full index

When you ask about a topic not covered below, I will read the relevant chapter file
before answering.

---

## Core Frameworks & Mental Models

### The central argument
TypeScript's **structural typing** is what makes classical design patterns practical in
the JS ecosystem — interfaces give real contracts instead of duck typing, and the
compiler enforces them through the refactors patterns require. Enable `strict` before
applying any pattern: **patterns without enforced contracts are just conventions.**

### Choosing a pattern

| Problem | Pattern |
|---|---|
| Exactly one shared instance per process | **Singleton** |
| One instance per distinct parameter set | **Parametric Singleton** |
| Copy an existing configured object graph | **Prototype** |
| >3 params, many optional, *multiple representations* | **Builder** |
| One product type, concrete class decided at runtime | **Factory Method** |
| A *family* of related products, swappable wholesale | **Abstract Factory** |
| Interfaces don't match | **Adapter** |
| Add behavior at runtime, stackable | **Decorator** |
| Too many subsystems for the client to call | **Façade** |
| Tree of leaves and containers treated uniformly | **Composite** |
| Control *access* to one object | **Proxy** |
| Two dimensions varying independently | **Bridge** |
| Too many near-identical objects in memory | **Flyweight** |
| Many algorithms, one chosen at runtime | **Strategy** |
| Request handled by one of several, in order | **Chain of Responsibility** |
| Need to queue / log / undo an action | **Command** |
| Many components must talk without knowing each other | **Mediator** |
| One change, many independent reactions | **Observer** |
| Traverse without exposing structure | **Iterator** |
| Undo/redo, checkpoints, snapshots | **Memento** |
| Behavior depends on internal state | **State** |
| Same algorithm, varying steps | **Template Method** |
| New operations over a *fixed* hierarchy | **Visitor** |

### Disambiguating the look-alikes
- **Adapter vs. Decorator vs. Proxy** — Adapter *translates* to a different interface;
  Decorator *adds behavior* through the same interface and stacks; Proxy *controls
  access* through the same interface, usually one per object.
- **Façade vs. Proxy** — Façade offers a *simpler, different* interface; Proxy has the
  *same* interface.
- **Strategy vs. State** — the caller picks a Strategy; the object's own internal
  condition drives State.
- **Mediator vs. Observer** — the mediator *knows* its components and routes; the
  Observer's publisher is *unaware* of its subscribers.
- **Chain vs. Decorator** — a Chain handler can **halt** the flow; a Decorator always
  continues.
- **Factory Method vs. Abstract Factory** — one product type vs. a consistent family.
  Factory Method is the specialization.
- **Flyweight vs. object pooling** — sharing one instance (memory) vs. recycling many
  (creation cost).

### When *not* to use a pattern
Use an `if` or lambda instead of Strategy for 2–3 simple variations. Use constructor
defaults instead of Builder without multiple representations. Use an enum instead of
State for a few trivial states. Skip Bridge with one implementation, Iterator over a
plain array, DDD on a simple domain, and Flyweight before the memory problem is
demonstrated. **Expect to refactor *into* Abstract Factory, never to start with it.**

### Type-system defaults
- `interface` for object contracts; `type` for unions, intersections, and computation.
- Never `any` — use `unknown` plus a `value is T` type guard. Never `Function` — use an
  explicit signature or a generic callback interface.
- `keyof T` wherever a string names a field: free autocomplete and rename safety.
- **Branded types** (`Type & { __type: Brand }`) with a **`unique symbol`** when two
  types share a shape but not a meaning. String brands can collide.
- `as const` + `keyof typeof` on literal maps, or return types widen to `string`.
- `NoInfer<T>` (TS 5.4) when one parameter should *constrain* another rather than
  contribute to its inference.
- **`Partial`, `Required`, and `Readonly` are all shallow.** Only runtime-immutable
  structures (Immutable.js) survive a cast.

### SOLID — the rules and their failure states
- **Single Responsibility**: one reason to change → failure is a **God object**.
- **Open-Closed**: extend, don't modify. In practice, **turn variation into data** —
  a `Record<AccountType, Voucher>` lookup instead of branching on type.
- **Liskov Substitution**: violations *pass the type checker*. Watch for changed return
  types, new exceptions, and new side effects in subclasses.
- **Interface Segregation**: thin interfaces, derived to extend.
- **Dependency Inversion**: inject the abstraction with a default; pass a mock in tests.
  This is what makes unit testing possible at all.

**The meta-rule: SOLID, DRY, and KISS cannot all be satisfied at once.** SOLID can
introduce duplication; DRY can violate SOLID. You can't predict how requirements will
change — treat all three as tools chosen per situation, never a checklist.

### Functional TypeScript
A **pure function** is deterministic *and* side-effect free — both. Manage effects with
`IO<A>` (a thunk that makes impurity visible and deferred), not by banning them. Restore
referential transparency by copying before mutating (`[...list].sort()`). Cap composition
depth at **3–4 functions**. **TypeScript has no Higher-Kinded Types** — hand-rolled
Applicatives and Monads hit inference walls, so use `fp-ts` for anything past a simple
`Maybe`. **Do not rely on tail-call optimization; JS/TS runtimes don't implement it.**

### Reactive TypeScript
Observables generalize the Observer pattern with composable operators. They're **lazy** —
nothing emits until `subscribe()`, and an error in the stream doesn't close it. Know
whether yours is **cold** (replays history to late subscribers) or **hot** (`share()` —
late subscribers miss everything prior; use `shareReplay(n)` if that matters). Keep
transformations in `map`/`filter` and side effects in `tap`. Handle backpressure
explicitly — and **operator order determines what gets dropped**.

### Foreign idioms that don't translate
Don't write **Java** in TypeScript (POJOs, `get`/`set` pairs — TypeScript allows only one
constructor and `Serializable` is meaningless). Don't write **Go** in TypeScript
(`[value, error]` tuples — use `throw`/`try`/`catch` and `async`/`await`). Don't write
**classical OOP** inheritance chains for partial reuse — that's the *banana–monkey–jungle
problem*. Favor **composition**: one interface per role, composed through a class that
depends only on those interfaces (**black-box reuse**).

---

## Chapter Index

| # | Title | Key Frameworks |
|---|-------|----------------|
| [ch01](chapters/ch01-getting-started-with-typescript-5.md) | Getting Started with TypeScript 5 | structural typing, JS→TS migration, UML class diagrams, tsconfig flags |
| [ch02](chapters/ch02-typescript-core-principles.md) | TypeScript Core Principles | utility types, `keyof`, branded types, conditional types + `infer`, mapped types |
| [ch03](chapters/ch03-creational-design-patterns.md) | Creational Design Patterns | Singleton, Prototype, Builder, Factory Method, Abstract Factory |
| [ch04](chapters/ch04-structural-design-patterns.md) | Structural Design Patterns | Adapter, Decorator, Façade, Composite, Proxy, Bridge, Flyweight |
| [ch05](chapters/ch05-behavioral-patterns-object-communication.md) | Behavioral Patterns for Object Communication | Strategy, Chain of Responsibility, Command, Mediator, Observer |
| [ch06](chapters/ch06-behavioral-patterns-state-and-behavior.md) | Behavioral Patterns for State and Behavior | Iterator, Memento, State, Template Method, Visitor |
| [ch07](chapters/ch07-functional-programming-with-typescript.md) | Functional Programming with TypeScript | purity, composition, immutability, lenses, Functor→Monad ladder |
| [ch08](chapters/ch08-reactive-and-asynchronous-programming.md) | Reactive and Asynchronous Programming | Pull/Push/Pull-Push, Promises vs. Futures, Observables, RxJS operators |
| [ch09](chapters/ch09-developing-modern-and-robust-applications.md) | Developing Modern and Robust Applications | combining patterns, custom utility types, DDD, SOLID, MVC |
| [ch10](chapters/ch10-anti-patterns-and-workarounds.md) | Anti-Patterns and Workarounds | class overuse, permissive types, foreign idioms, inference & generic gotchas |
| [ch11](chapters/ch11-design-patterns-in-open-source-architectures.md) | Design Patterns in Open Source Architectures | pattern-review method, Apollo Client, tRPC |

## Topic Index

- **Abstract Factory** → ch03, ch09, ch11
- **Adapter** → ch04, ch07, ch11
- **anti-patterns** → ch10 (also the Criticisms section of ch03–ch06)
- **applicatives / functors / monads** → ch07
- **backpressure** → ch08
- **branded types** → ch02
- **Bridge** → ch04
- **Builder** → ch03, ch09
- **Chain of Responsibility** → ch05, ch07
- **Command** → ch05
- **Composite** → ch04, ch09, ch11
- **conditional types / `infer`** → ch02, ch07
- **Decorator** → ch04, ch03 (`@Singleton`)
- **decorators (TS 5 syntax)** → ch01, ch03, ch04
- **Dependency Injection / Inversion** → ch03, ch09
- **DDD (bounded context, entities, value objects, domain events)** → ch09
- **error handling** → ch02, ch07 (`Either`), ch10 (Go idiom)
- **Façade** → ch04, ch09
- **Factory Method** → ch03, ch09, ch11
- **Flyweight** → ch04
- **`fp-ts`** → ch07
- **Future vs. Promise** → ch08
- **generics gotchas** → ch10
- **immutability** → ch07, ch09, ch10
- **Iterator** → ch06, ch08, ch09
- **`keyof`** → ch02, ch10
- **lenses** → ch07
- **Liskov Substitution** → ch09, ch10
- **mapped types** → ch02, ch09
- **Mediator** → ch05, ch09
- **Memento** → ch06, ch11
- **monorepo vs. multi-repo** → ch11
- **MVC** → ch09
- **`NoInfer`** → ch01, ch10
- **Observer / Observables** → ch05, ch06, ch08, ch11
- **Open-Closed Principle** → ch03, ch04, ch09
- **Prototype** → ch03
- **Proxy** → ch04, ch11
- **React (typing components, lifecycle)** → ch02, ch06
- **Repository pattern** → ch09
- **RxJS** → ch06, ch08
- **schedulers** → ch08
- **Singleton** → ch03, ch09
- **SOLID** → ch09, ch10
- **State** → ch05, ch06, ch09
- **Strategy** → ch05, ch06, ch11
- **structural vs. nominal typing** → ch01, ch02
- **Template Method** → ch06
- **testing patterns** → ch03–ch06 (per pattern), ch08 (marble testing)
- **tsconfig flags** → ch01, ch02
- **utility types (`Pick`/`Omit`/`Partial`/`Record`)** → ch02, ch09, ch10
- **Visitor** → ch06, ch09, ch11

## Supporting Files

- [glossary.md](glossary.md) — every key term with a definition and chapter reference
- [patterns.md](patterns.md) — all 23+ patterns: when to use, how, trade-offs
- [cheatsheet.md](cheatsheet.md) — decision rules, tells & smells, thresholds

---

## Scope & Limits

This skill covers the book's content only (TypeScript 5.x era, published January 2025).
For current TypeScript compiler behavior or library APIs, verify against the official
docs. For patterns applied to your specific codebase, combine with project-specific
context.
