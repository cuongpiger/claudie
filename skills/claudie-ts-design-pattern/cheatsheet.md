# Cheatsheet — Decision Rules

The judgment calls, not the definitions. Keep this beside you while working.

---

## Do I need a pattern at all?

| If… | Then |
|---|---|
| 2–3 simple variations, unlikely to grow | `if` statement or a lambda — **not** Strategy |
| One representation, ≤3 params | constructor defaults or an object literal — **not** Builder |
| A few trivial states | an enum — **not** State |
| One implementation of an abstraction | a plain class — **not** Bridge |
| Plain array or read-only collection | `for...of` — **not** Iterator |
| Simple domain, no intricate business logic | skip DDD entirely |
| Memory problem not yet demonstrated | skip Flyweight (premature optimization) |
| Object hierarchy not yet obvious | skip Abstract Factory — **refactor into it later** |

**The author's own framing:** patterns aren't a silver bullet. Each must be re-evaluated
against what TypeScript already gives you for free.

---

## Disambiguating look-alikes

| Confusion | Deciding question |
|---|---|
| Adapter vs. Decorator vs. Proxy | Different interface → Adapter. Same interface, adds behavior, stackable → Decorator. Same interface, controls access, one per object → Proxy. |
| Façade vs. Proxy | Simpler *different* interface → Façade. *Same* interface → Proxy. |
| Strategy vs. State | Caller picks the algorithm → Strategy. Object's own condition drives behavior → State. |
| Mediator vs. Observer | Hub *knows* the components and routes → Mediator. Publisher is *unaware* of subscribers → Observer. |
| Mediator vs. Chain of Responsibility | Central hub knows everyone → Mediator. Linear pass-along until handled → Chain. |
| Chain vs. Decorator | Can **halt** the flow → Chain. Always continues → Decorator. |
| Command vs. Observer | Encapsulated *request* (undoable) → Command. State-change *notification* → Observer. |
| Factory Method vs. Abstract Factory | One product type → Factory Method. A consistent *family* → Abstract Factory. |
| Flyweight vs. object pooling | Sharing one instance across contexts (memory) → Flyweight. Recycling many instances (creation cost) → pooling. |
| Visitor vs. Composite | Behavioral, separates algorithm from structure → Visitor. Structural, uniform leaf/container → Composite. |

---

## Type-safety defaults

| Situation | Rule |
|---|---|
| Any new project | `strict: true` before applying patterns — patterns without enforced contracts are conventions |
| Defining an object's shape | `interface`. Use `type` only for unions, intersections, aliases |
| Tempted to write `any` | `unknown` + a `value is T` type guard |
| Tempted to write `Function` | `(arg: T) => R` or a generic callback interface |
| String identifies a field | `keyof T` — free autocomplete and rename safety |
| Two types share a shape but not a meaning | branded type with a **`unique symbol`** (a string brand can collide) |
| Literal map used for lookups | `as const` + `keyof typeof` — otherwise the return widens to `string` |
| One generic parameter constrains another | wrap the constrained one in `NoInfer<T>` (TS 5.4) |
| More than one generic parameter | name them `TKey`/`TValue`/`TData`/`TError`, never `T`/`K`/`U` |
| Default generic parameter | constrain it (`T extends Shape`), never leave it `{}` |

---

## Immutability — what each level actually prevents

| Mechanism | Reassign | Mutate | Nested | Survives cast |
|---|---|---|---|---|
| `const` | ✓ | ✗ | ✗ | n/a |
| `Readonly<T>` | ✓ | ✓ top level | ✗ | ✗ |
| `DeepReadonly<T>` | ✓ | ✓ | ✓ | ✗ |
| Immutable.js | ✓ | ✓ | ✓ | ✓ (runtime) |

**Same shallowness trap applies to `Partial<T>` and `Required<T>`** — neither recurses.

---

## Tells & smells

| If you see… | You're probably in… |
|---|---|
| `typeof x.send === "function"` guards | duck typing that should be a structurally typed parameter |
| A subclass overriding one method and inheriting another | the banana–monkey–jungle problem → composition |
| `if (user.isPremium()) ... if (user.isUltimate())` | an Open-Closed violation → `Record<K, V>` lookup |
| `login()` and `sendEmail()` on a `User` model | a God object → split into services |
| Interface growing past ~5 methods | Interface Segregation violation → split by capability |
| `new SomeFactory()` inside a method body | Dependency Inversion violation → inject it |
| `isEmpty()` that can never return true | a Liskov violation the type checker won't catch |
| `JSON.parse(JSON.stringify(x))` | a broken deep clone → `lodash.cloneDeep` |
| `[result, err]` tuples | Go idiom → `throw` + `try`/`catch` |
| `getName()`/`setName()` pairs | Java idiom → getters only, construct new for updates |
| One façade importing everything | God object → many small façades |
| `console.log` inside `map` | impure pipeline → move it to `tap` |
| A subject with no matching `removeSubscriber` | an Observer memory leak |
| A mediator branch calling back into its emitter | imminent stack overflow |

---

## Thresholds & defaults

| Rule | Value |
|---|---|
| Function composition depth | **3–4 max** — beyond that, inference fails and stack cost grows |
| Chain of Responsibility | always add a **default terminal handler** |
| Template Method | as **few** required/optional steps as possible (you can't deprecate them) |
| Singleton scope | **per process** — a new process gets its own |
| Flyweight intrinsic state | must be **immutable** |
| Memento history | must be **bounded**; prefer storing edit operations over full snapshots |
| Observer notification | **O(n)**, and blocking in a single-threaded runtime |
| Tail recursion | **do not rely on it** — JS/TS runtimes don't implement TCO |

---

## Async & reactive decisions

| Need | Choose |
|---|---|
| Consumer must ask for updates | Pull (polling) — simple, but wastes resources |
| Producer knows who cares | Push (Observer / RxJS `Subject`) |
| Payload too large or sensitive to push | Pull-Push (notify with a path, consumer fetches) |
| Lazy start + cancellation | Future (`Fluture`) — Promises are eager and uncancellable |
| Value may be absent | `Maybe` / `Option` |
| Failure needs a reason | `Either<L, R>` |
| Threading state through steps | `State<S, A>` |
| Late subscribers need history | cold Observable, or `shareReplay(n)` |
| Multicast without history | `share()` |
| High-frequency source | `throttle` → then `bufferTime` → then `map`. **Order matters** — buffering first throttles whole batches |
| Search-as-you-type | `debounce` |
| Testing time-based Observables | `TestScheduler` + marble diagrams, never real timers |

---

## Error handling

| Approach | Pick when |
|---|---|
| Custom `Error` subclasses + `instanceof` | you want automatic propagation up the stack |
| Discriminated union results | you want every caller forced to handle failure (verbose but unmissable) |
| Global Express middleware | the generic 500 case **only** — keep `try/catch` in handlers for specific codes and debug detail |
| `Either` monad | you're already composing functionally |

---

## Entity or value object?

| | Entity | Value object |
|---|---|---|
| Has an `id` | yes | **no** |
| Mutable | typically | **never** |
| Equality | by identity | by attributes |
| Validates itself | not necessarily | **on construction** |
| Managed by | Repository | plain construction |

If a unique identifier would be *meaningless* (two 5-EUR amounts are the same thing),
it's a value object.

---

## Reading an unfamiliar codebase for patterns

1. Docs → ADRs → API reference → CONTRIBUTING/README/wiki
2. Folder structure and **file naming** (`CarFactory.ts` announces the pattern)
3. Scan for the easy ones: Factory Method, Singleton, Builder, Adapter, Decorator,
   Façade, Observer, Strategy, Command
4. Imports: do classes accept **interfaces**? Is there a DI container?
5. **Mocks in tests mark the real abstraction boundaries**

Pick **one entry-point file**, not the whole repo.

---

## The meta-rule

**SOLID, DRY, and KISS cannot all be satisfied at once.** SOLID can introduce duplication;
DRY can violate SOLID; both can lose to KISS. You can't predict how requirements will
change, so treat all three as tools chosen per situation — never as a checklist to
complete.
