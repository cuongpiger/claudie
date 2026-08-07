# Python Design Patterns — Decision Cheatsheet

## Picking a Pattern — Decision Tree

**Object creation is getting complicated**
- One step, pick a class by input → factory method (a plain function with `if/elif`; not a class)
- Must swap a whole *family* consistently (hero + obstacle) → abstract factory
- Many ordered steps / validation / external calls → builder + director
- Init costs more than copying, original must survive → prototype (`copy.deepcopy`)
- Init costs CPU/memory/bandwidth, objects are reusable → object pool
- One shared instance → **module-level global object**, not singleton
- Ladder first: plain function → default/keyword args → module global. Factory class/metaclass/director only after those fail.

**Two things won't talk**
- Interfaces incompatible, code already exists, can't change it → adapter
- You control the design up front, both sides must vary independently → bridge
- Many subsystem objects, want one simple entry point → facade
- Same interface, one object, add control (lazy/auth/remote/refcount) → proxy
- Same interface, one object, add responsibility → decorator

**Behavior changes at runtime**
- Client picks; all options give the *same result*, differ in performance; any order legal → **Strategy**
- Object's current state picks; different results per state; transitions constrained → **State**
- Handler unknown, several may react → Chain of Responsibility
- Audience plural and changes at runtime → Observer; single fixed call site → plain callback
- Need to store/queue/log/group/undo the call → Command; otherwise a function

## Look-Alike Patterns

| Pair | Key difference | Question that decides it |
|---|---|---|
| Strategy vs State | Strategy has no memory; State has legal transitions | Does swapping the delegate at random corrupt the object? Yes → State |
| Decorator vs Proxy vs Adapter | Decorator adds behavior; Proxy adds control; Adapter changes interface | What changed — interface, behavior, or access? |
| Bridge vs Adapter | Same shape, opposite timing | Did you have a choice when designing it? Yes → Bridge |
| Facade vs Proxy | Facade = many objects → one simple interface; Proxy = one object, same interface | How many objects behind it? |
| Factory vs Builder | One step vs many; builder has a director | Does the client ask for the result later? Yes → Builder |
| Mock vs Stub | Mock verifies calls; stub supplies input | Is the assertion about a call, or about state? |
| Retry vs Circuit Breaker | Transient vs durable fault | How long does the failure last? ms–s → retry; dependency down → break |
| Memoization vs Cache-Aside | In-process, dies with process vs cross-process, survives restart | Must it be shared or survive restart? Yes → cache-aside |

## Concurrency: Execution Model

| Workload | Choose | Why |
|---|---|---|
| I/O-bound, async libs available | `asyncio` | Thousands in flight, no thread cost |
| I/O-bound, blocking libs (`requests`, legacy DB) | `ThreadPoolExecutor(max_workers=N)` | Threads park, not compute; reuse kills startup cost |
| CPU-bound (transforms, images) | `multiprocessing` Worker Model | Real parallelism, sidesteps one-interpreter contention |
| Elastic capacity needed | Worker Model + task queue | Add/remove workers with demand |
| Beyond one machine | Distributed workers + RabbitMQ/Kafka | Broker-fed |
| Continuous event streams | Observer / RxPY | Composable pipeline, not tangled callbacks |

Pool = reuse. Worker Model = distribution. Future/Promise is orthogonal — result handling over whichever you picked. Always `as_completed()`, never `.result()` in submission order. Always cap `max_workers`. Always `p.join()`.

## Caching Decisions

| Question | If yes |
|---|---|
| Must survive restart / be shared across processes? | Cache-Aside (Redis), `ex=60` TTL |
| Same function, same args, many times, one process? | `lru_cache` |
| Value might never be needed? | Lazy loading (`@property` + `None` sentinel) |
| Data changes often, or entries must stay consistent as a set? | Don't cache-aside |
| Argument space large or user-controlled? | Bound `maxsize` (e.g. 128), never `None` |

Fix the algorithm first; cache after. Time the uncached path before building the cache. Cache-aside on write = **delete** the key, don't update it.

## Python-Specific Defaults

- **Protocol** when classes are third-party/pre-existing or you care what an object *does*; **ABC** when you own implementations and want runtime enforcement.
- Composition unless the relation is genuinely "is-a" and the subtype substitutes.
- Module-level global object over singleton metaclass.
- Functions over one-class-per-strategy — that's a Java transcription.
- Inject the dependency instead of `self.x = Concrete()` in `__init__`; DI removes the need to `patch()`. Use `patch()` only for what you can't change (builtins, third-party internals).
- `isinstance(obj, Base)` over `type(obj) in (...)` — subclass-aware.
- Default to `None`, never a mutable default argument.
- EAFP (`try` / `except FileNotFoundError`) over `if os.path.exists(...)`.
- `"".join(list)` over `+=` in a loop.
- `@functools.wraps` on every decorator, or `__name__`/`__doc__` are lost.
- Pass arguments or encapsulate in a class — no `global` for sharing, no module-level dict as cache.
- REST over gRPC when human readability or plain web integration is the actual need.
- Never `pickle` untrusted input (Memento).
- Production throttling: never `storage_uri="memory://"` — per-process counters mean real limit = workers × configured.

## Patterns to Avoid in Python

| Pattern | Why the authors object |
|---|---|
| Singleton | Metaclass machinery is opaque; a module global does it plainly |
| Factory method (as a class) | Dynamic typing + default/keyword args make separate factory classes over-engineering |
| Mediator, Visitor | Built-ins cover both goals more directly |
| Interpreter for an external DSL | Scoped to simple *internal* DSLs only |
| Adapter when you can fix the interface | Introduces hard-to-debug side effects; a last resort, not a default |
| Chain of Responsibility with one known handler | You buy indirection and nothing else |
| Builder for a single-constructor object | Pays off only with numerous configurations |
| Hand-rolled state `if/else` transitions | Duplicated at every call site; use a state machine |

## Smells → Pattern

| Symptom | Fix |
|---|---|
| `if isinstance(...)` / type-switch grows with every new type | Polymorphism, Strategy (OCP) |
| Class name joined by "and"; generates *and* saves | Split (SRP) |
| Subclass override contradicts or no-ops the parent promise | Move the method up the abstraction (`fly` → `move`) (LSP) |
| Subtype inherits `scan`/`fax` it never calls | Split the interface (ISP) |
| `self.x = Concrete()` inside `__init__` | Dependency injection (DIP) |
| Inline `fib_cache` dict per function | `@lru_cache` decorator |
| Public mutable attribute, no validation | `@property` |
| Very many identical expensive objects, identity irrelevant | Flyweight (and give up `id()` comparisons) |
| Retry storm; struggling service gets N× traffic | Circuit breaker wrapping the retry |
| Constant transient faults | Diagnosis: the dependency has a scaling problem — fix that |
| Producer outruns consumer | Backpressure / bounded queue |
| Test exercises the mock's wiring | Too much mocking — inject a stub |
| GUI not skinnable; new view needs model edits | MVC is wrong: smart model, thin controller, dumb view |
| Microservices with divergent deps | Containers |
