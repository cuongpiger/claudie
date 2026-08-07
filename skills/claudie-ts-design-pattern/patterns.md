# Patterns — Complete Catalog

All 23 techniques from the book, in the author's naming. Format: when to use, how,
trade-offs.

---

## Creational (Ch 3)

## Singleton
**When to use**: global config/state, controlled access to a shared external resource
(DB, filesystem, API endpoint), a cache layer, logging/error handling, thread or object
pools. Scope is **per process**.
**How**: private static `instance` + private constructor + public static `getInstance()`
that lazily creates and caches. Variants: module-resolution (`export default new X()`),
`@Singleton` class decorator, parametric (`Map` keyed by params).
**Trade-offs**: hard to mock and test in isolation; mutations are globally visible; lazy
init defers cost to first call, which is a bottleneck if init is expensive and the
resource is needed at startup. Prefer DI/IoC when loose coupling matters more.

## Prototype
**When to use**: you hold configured objects and want identical copies; `new` carries
real construction overhead; the object graph is complex/hierarchical.
**How**: a `Prototype` interface with `clone(): Prototype`; each concrete class
implements it using `lodash.cloneDeep`.
**Trade-offs**: callers must cast the result back to the concrete type; a `clone()` per
class is repetitive, and sharing it via a base class contradicts the pattern's purpose.
Never use `JSON.parse(JSON.stringify())` — it breaks on circular refs, `Date`, `RegExp`,
`Map`, `Set`.

## Builder
**When to use**: both criteria must hold — a common implementation-independent set of
steps, *and* multiple representations. Screening: >3 params? many optional with defaults?
all steps independent?
**How**: Product class + Builder interface (setters returning `this`, plus `build()`) +
concrete builders. `build()` returns and resets. GoF's optional **Director** consolidates
a known chain into one call.
**Trade-offs**: a builder class per variation duplicates code (mitigate with a generic
`Builder<T>` using `Partial<T>` + `keyof T`); can violate Open-Closed when new steps
appear; over-engineering for simple objects.

## Factory Method
**When to use**: creation logic is complex; the concrete type isn't known until runtime;
you want creation decoupled from usage; you need a central lifecycle control point.
**How**: Product interface + concrete products + Factory interface + concrete factories.
Instantiate factories once for the program's lifetime and pass them around. Pairs with DI
containers (Inversify.js, Nest.js).
**Trade-offs**: boilerplate; over-application is real. A `switch` on an enum is fine
during development but becomes a maintenance tax — refactor to separate factories once
the type list grows.

## Abstract Factory
**When to use**: you need *families* of related objects, clients must talk to factories
not concrete classes, and you want to interchange whole factories at runtime.
**How**: one interface with a `createX()` per product type; each concrete factory
produces a mutually compatible set.
**Trade-offs**: upfront complexity; premature abstraction is a named risk — expect to
*refactor into* this pattern, not start with it. Factory Method is its specialization
(single product type).

---

## Structural (Ch 4)

## Adapter
**When to use**: a client expects interface A and you hold an object implementing B and
can't modify it; legacy or third-party integration.
**How**: `class XAdapter implements Target` holding the adaptee; each method translates
and delegates.
**Trade-offs**: another class to maintain; complicates debugging; version drift as the
adaptee evolves; behavioral mismatch can be subtle. Reduce boilerplate with mapped types.

## Decorator
**When to use**: dynamic responsibility addition; avoiding subclass explosion; extending
behavior without modification (OCP); cross-cutting concerns; runtime-configurable behavior.
**How**: an abstract decorator implementing the component interface and holding a
`protected readonly` component. Modern form: a TS 5 class decorator returning
`class extends constructor`.
**Trade-offs**: interface changes ripple to every decorator; **order matters** when
decorators have side effects; each layer adds indirection; multiple stacked decorators
are hard to debug.

## Façade
**When to use**: simplifying a complex subsystem; defining an entry point per subsystem
level; layering; decoupling clients from components.
**How**: one class composing the subsystems, exposing minimal coordinated operations.
**Trade-offs**: becomes a God object under scope creep; limits clients to anticipated
uses; rigid when the underlying system evolves. **Build many small façades, one per use
case.**

## Composite
**When to use**: hierarchical structures; clients should ignore leaf-vs-container;
operations must apply uniformly at any depth.
**How**: one interface for leaf and container; the container holds a list of the
interface and recurses.
**Trade-offs**: method bloat (leaves forced to implement `add`/`remove`); deep hierarchies
cost traversal time; memory overhead with many small objects; cycles cause infinite loops.
Keep the interface small.

## Proxy
**When to use**: five variants — **virtual** (lazy init), **protection** (RBAC),
**logging/auditing**, **smart** (caching), **validation** (input checks, retries).
**How**: implement the same interface as the real subject and hold a reference to it.
**Trade-offs**: per-call indirection matters in real-time or high-frequency systems;
lifetime coupling risks leaks or premature destruction; error handling spans two objects;
hard to test with lazy loading or remote resources. Usually **one proxy per object**
(unlike Decorator).

## Bridge
**When to use**: an abstraction and its implementation must extend independently;
implementations swap at runtime; several abstractions share implementations.
**How**: an abstract class holding a reference to an implementation interface — that
reference *is* the bridge.
**Trade-offs**: pure overhead with a single implementation; over-engineering risk when a
simpler design suffices.

## Flyweight
**When to use**: very many similar objects; a shareable duplicated state; limited memory
or GC pressure you want predictable.
**How**: split **intrinsic** (shared, immutable, inside the flyweight) from **extrinsic**
(unique, passed as a method parameter); a `FlyweightFactory` caches by a key derived from
intrinsic state.
**Trade-offs**: cache-lookup overhead; mutating shared intrinsic state leaks into every
context (keep it immutable); premature optimization risk. Combines well with object
pooling — Flyweight saves memory, pooling saves creation cost.

---

## Behavioral: Communication (Ch 5)

## Strategy
**When to use**: multiple algorithm variants selected at runtime; isolating algorithm
internals; replacing conditional complexity with polymorphism; user-configurable behavior.
**How**: a Strategy interface, concrete strategies, and a Context holding the current one
and delegating.
**Trade-offs**: overkill for two or three simple variations (an `if` or lambda is
clearer); a class per strategy; frequent switching instantiates objects in hot paths;
shared state between context and strategies re-introduces coupling.

## Chain of Responsibility
**When to use**: multiple possible handlers, the right one unknown a priori; decoupling
sender from receivers; handlers reordered at runtime; naturally hierarchical handling.
**How**: an abstract `Handler` with `setNext()` and abstract `handle()`; each concrete
handler resolves or forwards.
**Trade-offs**: a handler that neither resolves nor forwards silently drops the request;
**always add a default terminal handler**; long chains accumulate latency; circular chains
loop forever; duplicate forwarding logic across handlers; hard to visualize at runtime.

## Command
**When to use**: decoupling sender from receiver; parameterizing objects with actions;
**undo/redo**; queueing operations; composite commands (macros); transactional rollback.
**How**: five roles — Command interface, concrete commands (bind receiver to action),
Receiver (knows *how*), Invoker (knows *when*), Client (wires them).
**Trade-offs**: indirection makes execution flow hard to trace; extra method calls;
proliferation of tiny command classes; commands can drift into tight coupling with
receivers, defeating the purpose.

## Mediator
**When to use**: reducing coupling by giving many objects one communication point;
replacing direct method calls with mediator-coordinated events.
**How**: a mediator interface with `triggerEvent(sender, message)`; components hold a
mediator reference and emit rather than call each other.
**Trade-offs**: **stack overflow** if an event routes back to its emitter; becomes a
monolithic God object violating SRP; a single point of failure and a testing bottleneck.

## Observer (publish–subscribe)
**When to use**: one-to-many communication where the publisher must not know its
subscribers; updates across an app without passing references.
**How**: a Subject managing a subscriber list with add/remove/notify; observers implement
a notify method.
**Trade-offs**: **memory leaks** from unremoved subscribers; O(n) notification blocks a
single-threaded runtime; cascading updates cause hard-to-debug behavior; overkill for
one-to-one relationships.

---

## Behavioral: State and Behavior (Ch 6)

## Iterator
**When to use**: complex structures (trees, graphs); multiple traversal orders; decoupling
clients from internals; parallel iteration; lazy evaluation.
**How**: `Iterator` (`hasNext`/`next`) + `Aggregate` (`createIterator`). Modern form:
implement `[Symbol.asyncIterator]()` for `for await...of`.
**Trade-offs**: unnecessary for plain arrays or read-only collections; more classes to
maintain.

## Memento
**When to use**: restorable snapshots including private state; state management behind an
abstraction; multi-level undo/redo; checkpoints in long-running processes.
**How**: Originator creates/consumes mementos; Memento is an immutable snapshot;
Caretaker holds history and **never inspects contents**.
**Trade-offs**: memory grows with history — cap it, compress, or store *edit operations*
instead of snapshots (the VS Code approach); frequent create/restore of complex state
costs real performance.

## State
**When to use**: behavior varies significantly by state; transitions are frequent or
complex; states share behavior with small variations; new states shouldn't touch the
Context.
**How**: Context holds a State reference and delegates; `changeState()` can guard illegal
transitions.
**Trade-offs**: overkill for a few trivial states (use an enum); class proliferation for
minor variations; hard to define genuinely meaningful states; incomplete transition
coverage produces surprises.

## Template Method
**When to use**: algorithmic variations over a fixed structure; reducing duplication
across near-identical implementations; framework hooks users customize.
**How**: an abstract base defining the skeleton method, plus concrete operations, abstract
operations, and optional hook operations.
**Trade-offs**: **deprecating a step after distribution breaks clients** — define as few
required/optional steps as possible.

## Visitor
**When to use**: traversing a composite hierarchy to collect state without type checks;
applying new operations to objects sharing an interface but with subclass-specific methods.
**How**: elements implement `accept(visitor)` passing `this` to the matching `visit*`
method. **Double dispatch** selects by visitor type *and* element type.
**Trade-offs**: adding a new element type forces edits to **every** visitor; wrong visit
method selection is a runtime bug; visitors see only public members. Take this trade only
when the element set is stable and operations keep growing.

---

## Functional Structures (Ch 7)

## Lens
**When to use**: reading/updating deeply nested structures; immutable updates; data
transformation from nested sources.
**How**: `Lens<T, A>` with `get: (obj: T) => A` and `set: (obj: T) => (v: A) => T`, plus
helpers `view`, `set`, `over`. Build with `lensProp<T, K extends keyof T>(key)`.
**Trade-offs**: allocation per update; another abstraction to learn. Replaces destructuring
pyramids in Redux-style reducers.

## The functional ladder
**Functor** (`map`) → **Applicative** (`ap`) → **Monad** (`map` + `of` + `flatMap`).
**Semigroup** (associative `concat`) → **Monoid** (adds `identity`).
**Traversable** (`traverse` — apply and collect).
**Trade-offs**: **TypeScript has no Higher-Kinded Types**, so hand-rolled Applicatives and
Monads hit inference walls. Use `fp-ts` for anything beyond a simple `Maybe`.

## Maybe / Either / State monads
**When to use**: `Maybe` for absent values, `Either<L,R>` for failures with reasons,
`State<S,A>` for threading state.
**How**: `flatMap` (not `map`) chains functions that themselves return the monad, keeping
the result flat and short-circuiting on failure.
**Trade-offs**: must obey left identity, right identity, and associativity to compose
reliably.

---

## Architectural (Ch 9)

## Repository
**When to use**: separating domain logic from data access.
**How**: a collection-like interface over domain objects, mediating between domain and
data-mapping layers.
**Trade-offs**: another layer; can hide query performance characteristics.

## MVC
**When to use**: medium-to-large applications needing separation of concerns.
**How**: Model (Domain layer — data + business logic), View (presentation), Controller
(Application layer — input handling and propagation).
**Trade-offs**: controller can become a coordination bottleneck. Enhance the Model with
Singleton/Factory Method/Builder; the Controller with Mediator/Observer.

## Domain events
**When to use**: decoupling reactions (welcome email, admin notification) from the action
that triggered them.
**How**: an event dispatcher with listeners; implement via Mediator or Observer.
**Trade-offs**: async handlers need retry logic; execution flow becomes indirect.
