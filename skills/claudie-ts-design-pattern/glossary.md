# Glossary — TypeScript 5 Design Patterns and Best Practices

**Abstract Factory** — creational pattern providing an interface for creating *families*
of related objects; "a factory of factories" (Ch 3)

**Abstract operation** — a Template Method step declared abstract in the base class that
subclasses must implement (Ch 6)

**Adapter** — structural pattern wrapping an object so it satisfies an interface it
wasn't built for (Ch 4)

**Aggregation** — UML part-whole relationship where both parts survive independently;
hollow rhombus (Ch 1)

**Applicative** — functional structure adding `ap`: apply a *wrapped* function to a
wrapped value (Ch 7)

**Arity** — the number of arguments a function takes; mismatched arity breaks naive
composition (Ch 7)

**AST (Abstract Syntax Tree)** — the tree structure compilers and linters traverse with
the Visitor pattern (Ch 6)

**Backpressure** — a producer emitting faster than a consumer can process (Ch 8)

**Banana–monkey–jungle problem** — inheritance-driven dependency sprawl: using one class
drags in an entire hierarchy (Ch 10)

**`behaviorSubject`** — an Observable primitive holding and emitting current state; tRPC
uses it for connection status (Ch 8, Ch 11)

**Black-box reuse** — using a component through its interface alone, knowing nothing of
its internals; follows Liskov Substitution (Ch 10)

**Bounded context** — DDD's logical boundary around a sub-domain; in microservices, one
service per context (Ch 9)

**Branded type** — simulating nominal typing by intersecting a type with a unique symbol
marker (Ch 2)

**Bridge** — structural pattern splitting an abstraction from its implementation so both
extend independently (Ch 4)

**Builder** — creational pattern constructing complex objects step by step via a
chainable API (Ch 3)

**Chain of Responsibility** — behavioral pattern passing a request along handlers until
one processes it (Ch 5)

**Closure** — a function retaining access to its defining scope after that scope returned
(Ch 7)

**Cold Observable** — replays the full sequence for each new subscriber (Ch 8)

**Command** — behavioral pattern representing an action as an object, enabling queueing,
logging, and undo (Ch 5)

**Composite** — structural pattern giving leaves and containers one interface so clients
treat a tree uniformly (Ch 4)

**Composition (UML)** — parent controls child lifetime; filled rhombus (Ch 1)

**Concrete operation** — a Template Method step implemented directly in the base class
(Ch 6)

**Conditional type** — `A extends B ? C : D`; computes a type from a condition (Ch 2)

**`const` assertion (`as const`)** — narrows an object literal to its literal types (Ch 10)

**Currying** — converting an n-argument function into a chain of one-argument functions
(Ch 7)

**Decorator** — structural pattern adding behavior at runtime by wrapping an object with
the same interface; stackable (Ch 4)

**`DeepReadonly<T>`** — a recursive mapped type freezing nested structures; bypassable
with a cast (Ch 7)

**Declarative programming** — states *what* the program should do (`filter().reduce()`)
(Ch 7)

**Dependency Inversion Principle** — depend on injected abstractions, not concrete types
instantiated inside (Ch 9)

**Discriminated union** — a union of object types sharing a literal-typed field the
compiler narrows on (Ch 2)

**Domain event** — a DDD signal that something happened, dispatched for other parts to
react to (Ch 9)

**Double dispatch** — resolving a call on two runtime types at once; the mechanism behind
Visitor (Ch 6)

**Either monad** — error handling without exceptions; `left` = failure, `right` = success
(Ch 7)

**Entity** — a DDD object with unique identity, typically mutable, persisted (Ch 9)

**Extrinsic state** — the per-use state a Flyweight receives as a method parameter (Ch 4)

**Façade** — structural pattern presenting one simplified interface over a complex
subsystem (Ch 4)

**Factory Method** — creational pattern with an interface for creating one product type;
concrete factories choose the class (Ch 3)

**Flyweight** — structural pattern sharing expensive objects by splitting intrinsic from
extrinsic state (Ch 4)

**`fp-ts`** — the library supplying functional abstractions TypeScript can't express
natively (no HKTs) (Ch 7)

**FRP (Functional Reactive Programming)** — reactive programming plus functional
composition and referential transparency (Ch 8)

**Functor** — functional structure with `map`: apply a function inside a context (Ch 7)

**Future** — a lazy, cancellable asynchronous computation; not native to TypeScript
(Ch 8)

**God object** — a class that knows or does too much; violates Single Responsibility
(Ch 9, Ch 10)

**`has-a` relationship** — one object holds a reference to another (composition) (Ch 4)

**Higher-Kinded Types (HKTs)** — types that operate on other types; **TypeScript has no
support**, which limits hand-rolled Applicatives and Monads (Ch 7)

**Hook operation** — an optional Template Method step with a default implementation
(Ch 6)

**Hot Observable** — emits regardless of subscribers; late subscribers miss earlier
values (Ch 8)

**Imperative programming** — states *how*, step by step, order-sensitively (Ch 7)

**Immutable.js** — library providing runtime-enforced immutable data structures (Ch 7)

**`infer`** — names a position inside a conditional type's `extends` clause so it can be
returned (Ch 2)

**Interface Segregation Principle** — keep interfaces thin; derive new ones rather than
growing one fat interface (Ch 9)

**Intrinsic state** — the shared, immutable state inside a Flyweight (Ch 4)

**IO action** — `interface IO<A> { (): A }`; wraps a side effect so it's visible in the
type and deferred (Ch 7)

**`is-a` relationship** — inheritance or type-based relationship (Ch 4)

**Iterator** — behavioral pattern traversing a collection without exposing its structure
(Ch 6)

**`keyof T`** — the union of `T`'s property names as string literal types (Ch 2)

**Lens** — a composable getter/setter pair for reading and immutably updating nested data
(Ch 7)

**Liskov Substitution Principle** — a subclass must be substitutable for its parent
without changing program behavior (Ch 9)

**Mapped type** — `{ [P in keyof T]: ... }`; transforms every property of a type by rule
(Ch 2)

**Marble testing** — asserting Observable *timing* with diagrams like `'---a---b---c|'`
via `TestScheduler` (Ch 8)

**`Maybe` monad** — represents an optional value; eliminates repeated `null` checks (Ch 7)

**Mediator** — behavioral pattern routing all communication through a central coordinator
(Ch 5)

**Memento** — behavioral pattern snapshotting and restoring state without breaking
encapsulation; three roles (Originator, Memento, Caretaker) (Ch 6)

**Monoid** — a Semigroup plus an identity element (Ch 7)

**Monad** — a Functor plus `of` and `flatMap`; obeys left identity, right identity, and
associativity (Ch 7)

**Monorepo** — multiple projects in one repository; easier sharing, unified versioning
(Ch 11)

**MVC** — Model (domain data + logic), View (presentation), Controller (glue) (Ch 9)

**`NoInfer<T>`** (TS 5.4) — marks a type-parameter position ineligible for inference,
preventing unwanted widening (Ch 1, Ch 10)

**`noImplicitAny`** — compiler flag erroring when a type would be inferred as `any` (Ch 1)

**Nominal typing** — types compared by name/identity (Java, Go); contrast structural (Ch 2)

**Object pooling** — recycling reusable instances to reduce creation cost; distinct from
Flyweight (Ch 4)

**Observable** — a sequence producing future values; the composable generalization of the
Observer pattern (Ch 8)

**Observer (publish–subscribe)** — behavioral pattern where a subject notifies a dynamic
subscriber list of state changes (Ch 5)

**`Omit<T, K>`** — a type with the named properties removed (Ch 2)

**Open-Closed Principle** — entities open to extension, closed to modification (Ch 9)

**Parametric Singleton** — caches multiple instances in a `Map` keyed by constructor
parameters (Ch 3)

**`Partial<T>`** — all properties optional; **shallow** (Ch 2)

**`Pick<T, K>`** — a type with only the named properties (Ch 2)

**`pipe`** — chains operators; `of(1).pipe(op1, op2)` ≡ `op1().op2()` (Ch 8)

**POJO / JavaBean** — the Java convention (private fields, get/set, no-arg constructor,
Serializable); does not translate to TypeScript (Ch 10)

**Prototype** — creational pattern creating objects by cloning existing ones (Ch 3)

**Proxy** — structural pattern controlling access to an object; variants: virtual,
protection, logging, smart, validation (Ch 4)

**Pull pattern** — the consumer polls the producer for changes (Ch 8)

**Pull-Push pattern** — the producer notifies with a path; the consumer fetches the
payload (Ch 8)

**Pure function** — deterministic output *and* no side effects (Ch 7)

**Push pattern** — the producer sends as soon as data is available (Ch 8)

**Reactive Manifesto** — the four properties of reactive systems: responsive, resilient,
elastic, message-driven (Ch 8)

**`Record<K, T>`** — object type with keys of `K` and values of `T` (Ch 2)

**Recursive wrapping** — stacking decorators so each wraps the previous (Ch 4)

**Referential transparency** — a call can be replaced with its value without changing the
result (Ch 7)

**Repository pattern** — an abstraction layer between domain logic and data access (Ch 9)

**`Required<T>`** — all properties mandatory; **shallow** (Ch 2)

**Scheduler (RxJS)** — controls when a subscription starts and notifications are
delivered; null / Async / Queue / Asap (Ch 8)

**Semigroup** — a type with an associative `concat` operation (Ch 7)

**`share()` / `shareReplay(n)`** — multicast an Observable / multicast with an n-value
replay buffer (Ch 8)

**Single Responsibility Principle** — a class should have only one reason to change (Ch 9)

**Singleton** — creational pattern guaranteeing one instance with a global access point;
scope is per process (Ch 3)

**SOLID** — Single Responsibility, Open-Closed, Liskov Substitution, Interface
Segregation, Dependency Inversion (Ch 9)

**State pattern** — behavioral pattern where an object's behavior changes with its
internal state (Ch 6)

**State monad** — `S -> (A, S)`; threads state through chained computations (Ch 7)

**Strategy** — behavioral pattern encapsulating interchangeable algorithms behind one
interface (Ch 5)

**Structural typing** — types compared by shape, not by name; TypeScript's model (Ch 1)

**Tail call optimization** — restructuring recursion so the recursive call is last;
**JS/TS runtimes do not implement it** (Ch 7)

**`tap`** — the RxJS operator for side effects inside a pipeline (Ch 8)

**Template Method** — behavioral pattern where a base class defines an algorithm skeleton
and subclasses fill in steps (Ch 6)

**`TestScheduler`** — RxJS utility for simulating time in tests (Ch 8)

**Traversable** — functional structure with `traverse`: apply a function to each element
and collect results (Ch 7)

**Type guard / type predicate** — `value is T`; narrows a type inside the true branch
(Ch 1)

**Ubiquitous language** — DDD's shared vocabulary among developers, domain experts, and
analysts (Ch 9)

**UML class diagram** — the notation used throughout the book to describe pattern
structure (Ch 1)

**Union enum** — since TS 5, every enum is a union of its member literal types (Ch 1)

**`unknown`** — accepts any value but permits no use until narrowed; the safe `any` (Ch 1)

**Value object** — a DDD object with no identity, immutable, equal by attributes,
self-validating (Ch 9)

**Virtual proxy** — a Proxy variant deferring creation of an expensive object (lazy
initialization) (Ch 4)

**Visitor** — behavioral pattern adding operations to a hierarchy without modifying it,
via double dispatch (Ch 6)
