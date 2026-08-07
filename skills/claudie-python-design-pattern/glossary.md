# Glossary — Mastering Python Design Patterns

**Abstract base class (ABC)** — `abc`-module class whose `@abstractmethod` methods every concrete subclass must implement; a nominal contract enforced at instantiation (Ch 1, Ch 4).
**Abstract factory** — a logical group of factory methods producing a consistent family of related objects, swappable at runtime (Ch 3).
**Actor model** — concurrency via isolated actors that make local decisions, spawn actors, and exchange messages (Ch 7).
**Adaptee** — the object with the wrong interface that an adapter wraps (Ch 4).
**Adapter** — a translation layer making two incompatible interfaces work together, retrofitted without touching either side (Ch 4).
**Aggregate** — in event sourcing, the object or group representing one unit of business logic that records each change as an event (Ch 6).
**Backpressure** — signalling a producer to slow down until the consumer catches up (Ch 7).
**Bridge** — decouples an abstraction from its implementation up-front so both vary independently (Ch 4).
**Builder** — separates construction of a complex object from its representation so one procedure yields several representations (Ch 3).
**Cache-Aside** — application-owned caching: read from cache, on miss load from the store and populate; on write, invalidate the key (Ch 8).
**Caretaker** — the memento role that stores and retrieves previously created mementos (Ch 5).
**Chain of Responsibility** — passes a request along a chain of handlers, each choosing to handle or delegate to its successor (Ch 5).
**Circuit Breaker** — wraps a fragile call, trips after a failure threshold, and rejects subsequent calls without making them (Ch 9).
**Clean Architecture** — business logic encapsulated and separated from exposing interfaces, decoupled via dependency inversion (Ch 6).
**Closed (breaker state)** — calls execute normally and failures are counted (Ch 9).
**Collection pipeline** — computation organised as a sequence of operations, each consuming the previous one's collection (Ch 7).
**Command** — encapsulates an operation as an object holding all data and logic to run it, enabling deferral, queueing, and undo (Ch 5).
**Constructor injection** — declaring a dependency's shape (usually a `Protocol`) and accepting it as an `__init__` parameter (Ch 2, Ch 10).
**Coroutine** — a routine that can pause and resume so others run meanwhile; declared `async def`, driven with `await` (Ch 7).
**CQRS** — separating the read model from the write model (Ch 6).
**Cross-cutting concern** — a concern generic enough to apply across many parts of an app (logging, caching, auth); fits decorators, not OOP (Ch 4).
**Decorator (pattern)** — adds responsibilities to an object dynamically and transparently, without inheritance (Ch 4).
**Decorator injection** — a class-decorator factory that wires a dependency onto the class at decoration time (Ch 10).
**Dependency injection** — a component receives its collaborators from outside instead of creating them (Ch 1, Ch 2, Ch 10).
**Dependency Inversion Principle (DIP)** — high-level and low-level modules both depend on abstractions, not on each other (Ch 2).
**Descriptor** — the recommended Python mechanism for overriding attribute access via `__get__`/`__set__`/`__delete__` (Ch 4).
**Director** — the builder-only role that knows the step order and hands back the finished product on request (Ch 3).
**EAFP** — Easier to Ask for Forgiveness than Permission: act, then catch the specific exception; the favoured Pythonic style (Ch 11).
**Encapsulate What Varies** — isolate the parts most likely to change behind a stable operation, shielding the rest of the code (Ch 1).
**Event** — in event sourcing, an immutable record of type plus data, never changed once applied (Ch 6).
**Event-Driven Architecture (EDA)** — production, detection, consumption of, and reaction to events in real time (Ch 6).
**Event sourcing** — stores state changes as an immutable ordered event log; state is rebuilt by replay (Ch 6).
**Event store** — the collection of all events for an application (Ch 6).
**Extrinsic state** — per-object mutable data kept out of a flyweight and passed in by the client (Ch 4).
**Facade** — hides a complex subsystem behind one simplified entry point (Ch 4).
**Factory method** — a function returning a different object per input parameter, hiding the concrete class from the client (Ch 3).
**`fail_max`** — consecutive failures that trip a circuit breaker (Ch 9).
**Fault tolerance (FT)** — the property throttling, retry, and circuit breaking all serve (Ch 9).
**Favor Composition Over Inheritance** — build complex objects by combining simpler ones ("has-a") rather than subclassing (Ch 1, Ch 11).
**Flake8** — linter catching correctness smells a formatter cannot: `type()` comparisons, mutable defaults, protected access, wildcard imports (Ch 11).
**Flyweight** — shares intrinsic immutable data across many similar objects to cut memory, at the cost of object identity (Ch 4).
**`functools.lru_cache`** — the stdlib memoization decorator, managing entry size and lifetime automatically and thread-safely (Ch 8, Ch 11).
**Future** — a placeholder for a value not yet known; the read side consumers hold (Ch 7).
**GIL** — never named directly by the authors, but encoded in their guidance: threads for I/O, separate processes for real parallel computation (Ch 7).
**gRPC** — high-performance universal RPC framework using Protocol Buffers as its IDL; the chapter's microservice transport (Ch 6).
**Half-open (breaker state)** — after `reset_timeout`, one trial call decides: success closes the circuit, failure re-opens it (Ch 9).
**'has-a' relationship** — the composition relation between a containing class and the instances it holds (Ch 1).
**Implementor** — in bridge, the interface the abstraction delegates to through `_imp` (Ch 4).
**Interface Segregation Principle (ISP)** — never force a class to implement interfaces it does not use; prefer small specific ones (Ch 2).
**Internal DSL** — a limited-expressiveness language hosted in Python; the only kind the interpreter pattern applies to (Ch 5).
**Interpreter** — offers domain experts a simple internal DSL, assuming parsed data (an AST) already exists (Ch 5).
**Intrinsic state** — shared immutable data held inside a flyweight (Ch 4).
**Invariant vs. variant** — template's vocabulary: fix the part that never changes, parameterize the part that does (Ch 5).
**I/O-bound vs CPU-bound** — the workload split driving executor choice: `asyncio`/threads for I/O, processes for CPU (Ch 7).
**Iterator** — traverses a container element by element, decoupling algorithms from containers (Ch 5).
**Iterator protocol** — `__iter__()` plus `__next__()`, raising `StopIteration()` when exhausted; Python made it a language feature (Ch 5).
**Key function** — how a limiter buckets callers, e.g. `get_remote_address` for per-IP limits (Ch 9).
**Lazy initialization** — deferring creation of an expensive object until first use; instance-level or class/module-level (Ch 4).
**Lazy Loading** — defers loading a resource until needed; moves cost to first access rather than erasing it (Ch 8).
**LBYL** — Look Before You Leap: guard with an `if` before acting; cluttered and race-prone versus EAFP (Ch 11).
**Liskov Substitution Principle (LSP)** — substituting a subclass for its superclass must not change correctness or expected behavior (Ch 2).
**Loose Coupling** — minimize dependencies between parts; components interact through well-defined interfaces (Ch 1).
**`MagicMock`** — a `Mock` with magic methods configured, for fakes that must act as containers or context managers (Ch 10).
**Mediator** — objects communicate through a central hub rather than directly; skipped in Python in favour of `asyncio` (Ch 5).
**Memento** — snapshots an object's internal state for later restoration; roles are Memento, Originator, Caretaker (Ch 5).
**Memoization** — caching a function's results keyed on its arguments; paradigm-agnostic, unlike flyweight (Ch 4, Ch 8).
**Metaclass** — a class of a class, defining how a class behaves; the singleton hook lives in its `__call__()` (Ch 3).
**Microservices** — the app built as loosely coupled, independently deployable services communicating over well-defined APIs (Ch 6).
**Mock object** — a simulated collaborator giving isolation, behavior verification, and setup simplification (Ch 10).
**`mock_open()`** — a callable factory returning mocks preconfigured to behave like built-in `open()` (Ch 10).
**Mutable default argument** — `def f(x=[])`: evaluated once at definition time, so the default is shared state across calls (Ch 11).
**MVC** — splits an app into model (logic/state), view (representation), and controller (all model↔view glue) (Ch 6).
**MVT** — Django's MVC naming: controller = view, view = template (Ch 6).
**Mypy** — the static type checker used to verify `Protocol` conformance before running the code (Ch 1).
**`__new__`** — the hook the flyweight overrides to return a pooled object when one exists for the key (Ch 4).
**Non-blocking** — the property of returning a Future immediately instead of waiting for the value (Ch 7).
**Object pool** — reuses borrowed-and-returned objects via `_available`/`_in_use` lists instead of creating new ones (Ch 3).
**Observer** — publish-subscribe between one subject and a runtime-mutable list of subscribers notified on state change (Ch 1, Ch 5, Ch 7).
**Open (breaker state)** — all calls raise `CircuitBreakerError` immediately; the protected call is never made (Ch 9).
**Open-Closed Principle (OCP)** — entities are open for extension but closed for modification (Ch 2).
**Originator** — the memento role that gets and sets memento values (Ch 5).
**PEP 8** — the Python style guide covering indentation, line length, blank lines, import order, naming, comments, whitespace (Ch 11).
**Polymorphism** — treating objects of different classes through a common superclass interface (Ch 1).
**Program to Interfaces, Not Implementations** — code against a contract (ABC or Protocol) rather than a concrete class (Ch 1).
**Promise** — the writable producer side that fulfills with a value or rejects with an error, resolving a Future (Ch 7).
**Property technique** — `@property` / `@attr.setter`, Python's idiomatic conversion of attribute access into method calls (Ch 1).
**Protection proxy** — gates access to a sensitive object (Ch 4).
**Protocol** — a `typing.Protocol` subclass declaring required methods; any class with matching methods satisfies it implicitly (Ch 1, Ch 2, Ch 4).
**Protocol Buffers (protobuf)** — gRPC's efficient cross-language interface definition language, compiled with `protoc` (Ch 6).
**Prototype** — creates new objects by copying existing ones (`copy.deepcopy()`) when initialization costs more than copying (Ch 3).
**Proxy** — a surrogate implementing the subject's interface that performs an action before access reaches the real object (Ch 4).
**Reactive programming** — reacting to streams of events with composable operators instead of tangled callbacks (Ch 7).
**Reason to change** — the unit SRP measures, not line count; two reasons means two classes (Ch 2).
**Remote proxy** — a local stand-in for an object living in another address space (Ch 4).
**`reset_timeout`** — seconds a breaker stays open before allowing a trial call (Ch 9).
**Retry** — calls a failed external service again, immediately or after a wait, to absorb transient faults (Ch 9).
**RxPY** — the ReactiveX Python library (`reactivex`) providing `.pipe()` operators over observables (Ch 7).
**Serverless** — ship code and let the provider handle scaling and event-triggered execution; pay only for compute used (Ch 6).
**Single Responsibility Principle (SRP)** — a class has one job and one reason to change (Ch 2).
**Singleton** — restricts instantiation to one globally accessible object, preventing both re-instantiation and cloning (Ch 3).
**Smart (reference) proxy** — performs extra bookkeeping on access, such as reference counting or thread-safety checks (Ch 4).
**`spec` / `autospec`** — restricts a mock to the real object's attributes so drift and typos surface as failures (Ch 10).
**State** — behavior changes with an object's current state through a constrained graph of legal transitions (Ch 5).
**Strategy** — interchangeable algorithms producing the same result with different performance profiles, swapped transparently (Ch 5).
**Structural duck typing** — type compatibility from an object's methods rather than inheritance, checked statically (Ch 1).
**Stub** — a replacement that supplies indirect input only, without verifying interactions (Ch 10).
**Template** — keeps an algorithm's invariant structure in a template method and passes the variant steps in as callables (Ch 5).
**Thread** — the smallest unit of processing schedulable by the OS (Ch 7).
**Thread Pool** — reuses a fixed set of worker threads instead of creating one per task (Ch 7).
**Throttling** — caps the request rate per client in a time window, returning HTTP 429 past the limit (Ch 9).
**Transient fault** — a short-lived failure outside your control; the only failure class retry legitimately targets (Ch 9).
**TTL** — the cache expiry (`ex=60`) that bounds staleness even if invalidation is missed (Ch 8).
**`unittest.mock.patch`** — temporarily replaces a named target with a mock, as a context manager or decorator (Ch 10).
**Virtual proxy** — defers creation of a computationally expensive object until first needed (Ch 4).
**Visitor** — separates algorithms from the objects they operate on; skipped in Python in favour of first-class functions (Ch 5).
**Worker Model** — splits work into independent units processed in parallel by scalable threads, processes, or machines (Ch 7).
**Worker thread** — a thread dedicated to a task set, offloading work from the main thread to keep the app responsive (Ch 7).
**Write-through** — the alternative to cache-aside: push the new value into the cache at write time (Ch 8).
