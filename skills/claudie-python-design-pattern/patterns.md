# Pattern Catalog — Mastering Python Design Patterns

## Creational (Ch 3)

### Factory Method
**When to use**: Creation code scattered; want creation decoupled from usage; create objects only when needed.
**How**: Plain function, `if/elif` dispatch on a descriptor param, `raise ValueError` on unsupported input. No factory class.
**Trade-offs**: Authors caution against it in Python — veterans call it over-engineered. Dynamic typing, first-class functions, and keyword args make direct instantiation simpler and more Pythonic. A statically-typed-language habit.

### Abstract Factory
**When to use**: Need a consistent family of related objects, swappable at runtime with no client change.
**How**: One class per family with generic `make_*()` methods; consumer takes the factory as a constructor arg.
**Trade-offs**: Inherits factory method's verbosity. Only pays off when the family is real and swapping is required.

### Builder
**When to use**: Numerous configurations (else many confusing constructors); construction needs ordered steps, validation, or external calls.
**How**: Minimal product class + one builder per representation sharing step methods + a **director** running steps in order.
**Trade-offs**: Over-engineering when one constructor call works. Vs factory: multi-step, has a director, client asks explicitly for the product.

### Prototype
**When to use**: Init costlier than copying; original must stay untouched; cloning DB-populated object graphs without re-querying.
**How**: `copy.deepcopy()`; fuller version adds a registry dict and `clone(id, **attrs)` applying overrides via `setattr()`.
**Trade-offs**: Rarely named in Python — cloning is built in. Deep copy expensive on large graphs.

### Singleton
**When to use**: One coordinating object; shared-resource access; transversal service (logging, DB connection).
**How**: `SingletonType` metaclass with `_instances` dict overriding `__call__()`; `class X(metaclass=SingletonType)`.
**Trade-offs**: Authors flag it as an **anti-pattern in the Python community** — metaclass is advanced, hard to explain, non-obvious on reading. Prefer a **module-level global object** (Rhodes' Global Object Pattern); modules are natural namespaces.

### Object Pool
**When to use**: Init costly in CPU, memory, or network bandwidth (game bullets, connections).
**How**: `_available`/`_in_use` lists; `acquire_*()` creates only when `_available` empty; `release_*()` returns it.
**Trade-offs**: Pointless for cheap objects. Undisciplined release leaks the pool.

## Structural (Ch 4)

### Adapter
**When to use**: Incompatible interfaces you cannot change — foreign (no source) or legacy (refactor impractical).
**How**: Wrapper holding the adaptee exposing expected names; or generic adapter injecting `adapted_methods` into `self.__dict__`.
**Trade-offs**: Introduces side effects hard to debug. Last resort — if you can fix the interface, fix it.

### Decorator
**When to use**: Cross-cutting concerns — validation, caching, logging, monitoring, auth, encryption.
**How**: Callable taking `func_in` returning `func_out`, applied with `@name`; `functools.wraps()` to keep `__name__`/`__doc__`.
**Trade-offs**: No one-to-one mapping between the pattern and Python's `@` syntax — the syntax does far more; the pattern is one use. Dropping `@wraps` loses metadata.

### Bridge
**When to use**: Share one implementation across many objects, designed **up-front** (unlike adapter, never retrofitted). Drivers, gateways, themes.
**How**: Abstraction holds `_imp` referencing an Implementor declared with `typing.Protocol`; all methods delegate.
**Trade-offs**: Indirection you must design before a second implementation exists. Wrong when only one ever will.

### Facade
**When to use**: One simple entry point to a complex subsystem; shield clients from internal change; one facade per layer.
**How**: One class whose `__init__()` builds the subsystem objects and whose `start()` plus wrappers sequence them.
**Trade-offs**: Becomes a god object if it grows past "simple entry point".

### Flyweight
**When to use**: GoF's three requirements — very many objects, storage/rendering too expensive, **identity irrelevant**.
**How**: Class-level `pool` dict + `__new__()` returning the pooled instance; mutable **extrinsic** state passed as method args.
**Trade-offs**: Collapses if mutable state leaks in. Identity comparisons break — same-family objects *are* one object. Distinct from memoization (caches results, any paradigm).

### Proxy
**When to use**: Lazy creation of expensive objects, privilege checks, transparent location, thread-safety off the client.
**How**: Same-interface class (`ABC`/`Protocol`) holding the subject, or a descriptor overriding `__get__()`. Four variants: **Virtual** (lazy init), **Protection** (gate sensitive access), **Remote** (stand-in for another address space), **Smart/reference** (ref counting, thread-safety bookkeeping).
**Trade-offs**: Protection proxies are bypassable — clients can instantiate the real subject; use `abc` to forbid it. Authors flag hardcoded/clear-text passwords and MD5 or custom crypto as real holes.

## Behavioral (Ch 5)

### Chain of Responsibility
**When to use**: Handler unknown in advance (approval tiers), or several may need to react.
**How**: `hasattr()`/`getattr()` dispatch on `f"handle_{event}"`, then `self.parent.handle(event)`, then `handle_default()`.
**Trade-offs**: Useless when one known element handles everything. Requests can fall off the end unhandled.

### Command
**When to use**: Undo/redo (killer feature), GUI actions, cut/copy/paste, transactions and logging, macros.
**How**: Class with `__init__()` capturing data + `execute()`; `undo()` where reversible, catch `AttributeError` where not; list + `reversed()`.
**Trade-offs**: One class per operation is heavy when nothing needs undo or queuing.

### Observer
**When to use**: Several objects must learn of a change and the audience varies at runtime — feeds, events, sockets.
**How**: Subject keeps `self.observers` + `add_observer()`/`remove_observer()`; loops calling each `update()`.
**Trade-offs**: With many interdependent events it degrades into an unmaintainable callback tangle — move to reactive streams (Ch 7).

### State
**When to use**: Anything modelable as a finite-state machine — process models, lexing, game entities, vending machines.
**How**: `state_machine` module — `@acts_as_state_machine`, `State(initial=True)`, `Event(from_states=, to_state=)`, `@before`/`@after`. Illegal moves raise `InvalidStateTransition`.
**Trade-offs**: Classic class-per-state is verbose in Python. Overkill for two states and a boolean.

### Interpreter
**When to use**: Give non-programmer domain experts a simple **internal** DSL; readability over performance.
**How**: Assumes parsing already happened. `pyparsing` grammar (`Word`, `Group`, `OneOrMore`, `Suppress`), `parseString()` → `ParseResults`.
**Trade-offs**: Simple languages and internal DSLs only. Need an external DSL? Yacc/Lex, Bison, or ANTLR.

### Strategy
**When to use**: Interchangeable algorithms switched at runtime transparently — same result, different performance profile.
**How**: A strategy is just a function passed as an argument; keep a `dict` of name → function.
**Trade-offs**: Class-per-strategy is dead weight in Python — first-class functions already do it.

### Memento
**When to use**: Undo/redo; OK/Cancel dialogs restoring on-load state.
**How**: `pickle.dumps(self.__dict__)` snapshots; `pickle.loads()` + `__dict__.clear()`/`update()` restores. No class per role.
**Trade-offs**: **`pickle` is not secure** — never unpickle untrusted data, it can execute arbitrary code. Snapshots grow with history.

### Iterator
**When to use**: Custom collections needing `for`/`next()` support with clean termination.
**How**: Iterator protocol — `__iter__()` and `__next__()`, `raise StopIteration()` when exhausted.
**Trade-offs**: Not a pattern in Python, a language feature. Built-in containers already implement it; don't hand-roll.

### Template
**When to use**: Structurally similar algorithms with a duplicated skeleton — pagination, framework hooks.
**How**: Template function keeps the **invariant** part, takes the **variant** step as a callable (`generate_banner(msg, style)`).
**Trade-offs**: Premature templating locks in a skeleton before you know the shape.

## Architectural (Ch 6)

### MVC (Model-View-Controller)
**When to use**: UI and logic evolve separately; parallel designer/developer work; adding views (terminal, GUI, PDF) cheaply.
**How**: Smart model (state, validation, data access, no UI dependency), thin controller (all model↔view traffic, no display, no rules), dumb view (display only, stores nothing).
**Trade-offs**: Drop the controller and you lose multiple views without touching the model. Frameworks rename the parts (Django MVT) — expect confusion.

### Microservices
**When to use**: Multiple client types, third-party API, messaging with other apps, or distinct functional areas needing independent scale and deploy.
**How**: gRPC (`grpcio`, `grpcio-tools`) with protobuf compiled by `protoc`; subclass generated `*Servicer`, serve via `grpc.server(ThreadPoolExecutor(...))`. Django/Flask/FastAPI; Lanarky for LLM services.
**Trade-offs**: Containers are mandatory, not optional — each service brings its own datastore and runtime. Ops cost is the price of independent deploy.

### Serverless
**When to use**: Event-driven work (image resize, PDF generation, backups); or one function per microservice.
**How**: AWS Lambda `lambda_handler(event, context)`. Test locally with LocalStack in Docker, deploy/invoke via `awslocal`.
**Trade-offs**: Pay only for compute consumed, but cede scaling and execution control to the provider.

### Event Sourcing
**When to use**: Complex state and transition rules — financial ledgers, inventory lifecycle, audit trails, undo/redo.
**How**: Event (immutable type+data), Aggregate (records changes), Event store. `eventsourcing`: subclass `Aggregate`, `@event("Name")` on mutators, `Application.save()`, read via `repository.get(id)`.
**Trade-offs**: State rebuilt by replay — reads cost more, log grows forever. Overkill where overwriting state is fine.

## Concurrency / Async (Ch 7)

### Thread Pool
**When to use**: Batch processing, load balancing, capping threads to cap memory/CPU. Best for I/O-bound work with **blocking** libraries.
**How**: `concurrent.futures.ThreadPoolExecutor(max_workers=N)` as context manager, `.submit(fn, arg)`.
**Trade-offs**: No real parallelism for CPU-bound work — use processes. Pool size is a knob you must actually tune.

### Worker Model
**When to use**: CPU-bound transforms, task parallelism, elastic capacity, work spanning machines.
**How**: `multiprocessing.Process` + `multiprocessing.Queue`. Workers, task queue (decouples submission from processing), optional dispatcher.
**Trade-offs**: Process overhead plus inter-process serialization. Worth it only when work per task exceeds that cost.

### Future and Promise
**When to use**: Data pipelines, task scheduling, async DB queries, background file I/O — anywhere blocking stalls the caller.
**How**: `executor.submit()` → `Future`, `as_completed()`, `future.result()`; or `asyncio.ensure_future()`, `gather()`, `run()`. Future = readable placeholder, Promise = writable producer side resolving it.
**Trade-offs**: `result()` blocks — call it too early and you threw away the non-blocking property.

### Observer in reactive programming
**When to use**: Continuous event streams and collection pipelines — map/reduce, `group_by`, UI/feed events.
**How**: RxPY (`reactivex`): `rx.from_iterable`, `rx.interval`, `.pipe()` with `ops.flat_map/filter/map/group_by/count`, `.subscribe(cb)`.
**Trade-offs**: New dependency and mental model; classic Observer suffices until events become interdependent.

## Performance (Ch 8)

### Cache-Aside
**When to use**: Read-heavy, rarely-updated data; cache must survive restarts or be shared across processes.
**How**: Fetch — return from cache; on miss read store, populate, return. Update — write store then **remove** the entry (invalidate, don't rewrite). `redis.StrictRedis`, `cache.set(key, val, ex=60)`.
**Trade-offs**: Per-key freshness, not set-level consistency — breaks when entries must stay consistent with each other. Staleness bounded by TTL.

### Memoization
**When to use**: Pure, expensive functions called repeatedly with identical args; recursive algorithms; single process.
**How**: `@functools.lru_cache(maxsize=None)`.
**Trade-offs**: `maxsize=None` is unbounded — memory grows with argument cardinality; bound it when the arg space is large or user-controlled. Args must be hashable; side effects or time-varying results cache stale forever.

### Lazy Loading
**When to use**: Expensive attribute or resource that may never be read; cutting initial load time; low-end devices.
**How**: `@property` over a `self._data = None` sentinel calling `load_data()` on first access; or `@lru_cache(maxsize=128)` on the entry point.
**Trade-offs**: Moves the latency spike, doesn't remove it. A legitimately-`None` result reloads every time; no invalidation path — loaded is frozen for the object's life.

## Distributed Systems (Ch 9)

### Throttling
**When to use**: Guarantee continuous service, control cost, absorb bursts, allocate resources fairly across clients.
**How**: Flask-Limiter `Limiter(get_remote_address, app, default_limits, storage_uri, strategy="fixed-window")`, `@limiter.limit("2/minute")`; returns HTTP **429**. django-throttle-requests for Django. Types: Rate-Limit, IP-level Limit, Concurrent Connections Limit.
**Trade-offs**: `storage_uri="memory://"` is per-process — counters diverge across workers; use Redis. Fixed windows let clients burst across the boundary.

### Retry
**When to use**: **Identified transient faults** with an external component — network blips, server overload, microservice calls, data sync.
**How**: `retry(attempts)` decorator wrapping the call in `try/except` with `time.sleep(1)` between attempts, failure sentinel after exhaustion. Or the Retrying library.
**Trade-offs**: **Not for internal exceptions from your own logic** — that's a bug, not a blip. Frequent busy faults mean their scaling problem, which retrying won't fix.

### Circuit Breaker
**When to use**: Failures likely **long-lasting**, where retrying wastes time on a call that will fail.
**How**: `pybreaker.CircuitBreaker(fail_max, reset_timeout)` as decorator; raises `CircuitBreakerError` without making the call. Closed →(fail_max)→ Open →(reset_timeout)→ Half-open; probe succeeds → Closed, fails → Open.
**Trade-offs**: Threshold too low and normal noise trips it; `reset_timeout` too short and probe traffic hammers a dependency that hasn't recovered.

## Testing (Ch 10)

### Mock Object
**When to use**: Unit testing against complex, unreliable, or unavailable dependencies; collaborator still unbuilt; verifying call order and arguments.
**How**: `unittest.mock.patch(target)` as context manager or decorator, with `spec`/`autospec`, `spec_set`, `side_effect`, `return_value`, `wraps`. `mock_open()` for file I/O; patch builtins by full name (`"builtins.open"`).
**Trade-offs**: Mock too much and you assert against your own mock. No `spec` means the mock accepts calls the real object rejects — test green, production broken. (Stub supplies input only; mock also verifies interactions.)

### Dependency Injection
**When to use**: Swapping DB connections or config per environment without touching component code; dropping fakes in for tests without touching live systems.
**How**: **Constructor injection** — declare the shape with `typing.Protocol`, accept and store in `__init__`. **Decorator injection** — `@inject_sender(EmailSender)` class-decorator factory setting `cls.sender`.
**Trade-offs**: Decorator injection binds at class-decoration time, so a test needing a different dependency must reassign the attribute or declare a locally decorated class.
