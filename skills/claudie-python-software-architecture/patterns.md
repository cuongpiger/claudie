# Patterns — Architecture Patterns with Python

Every pattern in the book, with when/how/trade-offs. Ordered as they arrive.

---

## Domain Model
**When to use**: The domain has non-trivial business rules — i.e. whenever the customer wouldn't just use a spreadsheet. Skip it for CRUD.
**How**: Talk to domain experts, ask for concrete examples for every rule, agree a glossary. Write unit tests whose *names are the rules*. Implement plain classes/functions using those exact nouns and verbs. No framework, DB, or I/O imports.
**Trade-offs**: Cost-of-change rises steeply with complexity for ActiveRecord/ORM and shallowly for a domain model — the lines cross. Below the crossover you're paying for nothing.

## Value Object
**When to use**: A business concept with data but no identity — an order line, a name, a sum of money.
**How**: `@dataclass(frozen=True)` (or `NamedTuple`/`namedtuple`/`attrs`). You get value equality and a safe `__hash__` for free. Complex behavior is fine — operators especially (`fiver + fiver == tenner`).
**Trade-offs**: Making everything a value object. If the thing survives changes to its own attributes, it's an entity.

## Entity
**When to use**: A domain object with a stable reference that outlives its data — `Batch`, `Person`, `Order`.
**How**: Implement `__eq__` comparing *only* the identity attribute; base `__hash__` on that same (ideally read-only) attribute, or set `__hash__ = None`.
**Trade-offs**: `retrieved == expected` now only proves the reference matched — repository tests must assert other attributes explicitly. **Never modify `__hash__` without also modifying `__eq__`.**

## Domain Service (as a function)
**When to use**: A business operation with no natural home in an entity or value object. "Sometimes, it just isn't a thing." — Evans.
**How**: A module-level function, not a `FooManager`. Python is multiparadigm; let the verbs be functions.
**Trade-offs**: Confusable with service-layer services. A *domain* service is a business concept; a *service-layer* service is an application use case. The service layer often calls the domain service.

## Repository
**When to use**: The domain is complex enough that you want to change business rules without thinking about migrations, and you want fast unit tests. **Not** for a CRUD wrapper.
**How**: `add(thing)` and `get(id)`, used *rigidly* for all data access in the domain and service layer. Invert the ORM dependency (SQLAlchemy classical mapping) so `orm.py` imports `model.py`, never the reverse. Keep `.commit()` out — that's the UoW's job. `delete` becomes a soft delete (`batch.cancel()`); `update` is the UoW's.
**Trade-offs**: **Pro** — simple interface, trivially fakeable, storage swappable, DB schema stays simple because you control the mapping. **Con** — the ORM already gives some decoupling; hand-maintained mappings are extra code; a "WTF factor" for Pythonistas who've never seen it.

## Ports and Adapters
**When to use**: Any time you want to swap an infrastructure detail.
**How**: The **port** is the interface (an ABC, a `Protocol`, or just the duck type). The **adapter** is the implementation. `AbstractRepository` is a port; `SqlAlchemyRepository` and `FakeRepository` are adapters. Keep ports in the same file as the adapters implementing them.
**Trade-offs**: ABCs are didactic; the authors admit deleting them from production because Python makes them too easy to ignore, leaving them unmaintained and misleading.

## Functional Core, Imperative Shell (FCIS)
**When to use**: Business logic tangled with I/O.
**How**: Three steps — shell gathers inputs, pure core computes a decision from plain data and returns plain data, shell applies outputs. Have the core emit *commands* as plain tuples: `('COPY', src, dst)`.
**Trade-offs**: You must make stateful components explicit and pass them around — DHH's "test-induced design damage."

## Edge-to-Edge Testing with Fakes and DI
**When to use**: Unit-testing an inner function feels like dodging the real code path, but E2E tests are too slow.
**How**: Make stateful dependencies explicit parameters (`reader`, `filesystem`); inject fakes in tests, real ones in production. Build spies from `list` subclasses so you can `assert filesystem == [("COPY", ...)]`.
**Trade-offs**: Prefer this over `mock.patch`: patching lets you unit test but does **not** let your code grow a `--dry-run` flag or run against FTP. Mock tests couple to implementation and get brittle.

## Service Layer
**When to use**: **After** you spot orchestration logic creeping into your controllers. Not before, or you get an Anemic Domain.
**How**: One function per use case, four steps every time: (1) fetch objects from the repository, (2) check the request against current state, (3) call a domain service, (4) persist. Type-hint the *port* (`repo: AbstractRepository`).
**Trade-offs**: **Pro** — a single home for use cases, HTTP separated from allocation, fast workflow tests. **Con** — another layer; if your app is *purely* web, controllers can be that home ("fat models, thin controllers").

## Unit of Work
**When to use**: Any use case touching more than one object, or where "this block succeeds or fails as a unit."
**How**: A context manager exposing repositories, `commit()`, `rollback()`. `__exit__` **always** rolls back (a no-op after commit); commit must be explicit. Inject the session factory so tests can swap Postgres for SQLite.
**Trade-offs**: **Pro** — atomicity is visible in the indentation, safe by default, a home for repositories, and later a hook for events. **Con** — your ORM already has this (SQLAlchemy's `Session` *is* a UoW); rollbacks, multithreading, and nested transactions need real thought.

## Aggregate
**When to use**: Your model has collections and it's getting hard to track who can modify what; you need concurrency without overselling.
**How**: Nominate a root entity that encapsulates access. Draw the boundary around the **smallest** set of objects that must be consistent with each other, and name it in the ubiquitous language. Enforce **one aggregate = one repository**.
**Trade-offs**: **Pro** — decides which classes are public, avoids ORM performance problems, makes invariants controllable. **Con** — a third domain-object concept to teach; "modify only one aggregate at a time" is a big mental shift; eventual consistency between aggregates gets complex.

## Optimistic Concurrency with Version Numbers
**When to use**: You can't lock a whole table, but must prevent lost updates on one aggregate.
**How**: `version_number` on the aggregate root, incremented on every state change. Set `isolation_level="REPEATABLE READ"`. The loser gets *"could not serialize access due to concurrent update"* — **retry the whole operation**.
**Trade-offs**: vs `SELECT FOR UPDATE` (pessimistic): optimistic fails and you retry; pessimistic waits and you worry about deadlocks. vs `SERIALIZABLE`: same effect, often severe performance cost. Version numbers also make an implicit concept explicit. The number itself doesn't matter — a random UUID would do.

## Domain Events
**When to use**: A domain expert says **"When X, then Y."**
**How**: `@dataclass` subclasses of a base `Event`, in `domain/events.py`. The aggregate appends to `self.events`. **Stop raising exceptions for the same domain concept.**
**Trade-offs**: **Pro** — separates responsibilities, decouples handlers from core logic, becomes shared vocabulary with stakeholders. **Con** — handlers run **synchronously** inside your request; no single place shows how a request is fulfilled; circular handler dependencies and infinite loops are possible.

## Message Bus (internal)
**When to use**: More than one thing must happen in response to a request.
**How**: A dict of message type → handler(s), plus a dispatch loop maintaining a queue. Give it the UoW; after each handler, `queue.extend(uow.collect_new_events())`.
**Trade-offs**: Gives you **no concurrency** — one handler at a time. It's not Celery; it's closer to a Node.js app or an actor framework. Its API for distributing work is your *event classes*, which need not be Python.

## Publishing Events — three options
1. **Service layer collects from the model and passes to the bus.** Simplest. `finally: messagebus.handle(product.events)`.
2. **Service layer raises its own events.** No `.events` on the model.
3. **UoW collects from `repo.seen` and publishes on commit.** ← the authors' choice. Most complex, may rely on ORM magic, cleanest once set up.
**Trade-offs**: Option 3 is "neat but also magic — it's not obvious when we call `commit` that we're also going to go and send email to people."

## Commands vs Events
**When to use**: Always, once you have a message bus.
**How**: Commands are imperative-named, sent to **one** handler, modify **one** aggregate, and **`raise`** on failure. Events are past-tense-named, sent to **many** handlers, and are logged and **`continue`**d on failure.
**Trade-offs**: **Pro** — clarifies what must succeed vs what can be tidied up later; `CreateBatch` beats `BatchCreated`. **Con** — the distinction is subtle (expect bikeshedding); you're expressly inviting failure, which needs better monitoring.

## Retry with Exponential Backoff
**When to use**: Transient failures — network hiccups, table deadlocks, deployment downtime.
**How**: `tenacity`'s `Retrying(stop=stop_after_attempt(3), wait=wait_exponential())` around the handler call; log and `continue` on `RetryError`.
**Trade-offs**: "Probably the single best way to improve the resilience of our software" — and safe *because* UoW + Command Handler mean each attempt starts from a consistent state. But at some point you must give up.

## Event-Driven Microservices Integration
**When to use**: Instead of synchronous HTTP between noun-named services.
**How**: Think in **verbs**, not nouns (a system for *ordering*, not for *orders*). Each service is a consistency boundary accepting commands and raising events. Thin adapters both ways: consumer deserializes JSON → builds a `Command` → calls the bus; publisher serializes a domain event to a channel.
**Trade-offs**: **Pro** — avoids the distributed ball of mud, services fail independently, changes stay local, drops Connascence of Execution/Timing to Connascence of **Name**. **Con** — information flows are harder to see, eventual consistency is a new concept, delivery guarantees need thought.

## CQS / Post-Redirect-Get
**When to use**: Any write endpoint currently returning data.
**How**: "Functions should either modify state or answer questions, but never both." POST returns `201`/`202` with a `Location` header; a separate GET reads the result.
**Trade-offs**: Fixes double-submits on refresh and broken bookmarks. Costs a round trip.

## CQRS
**When to use**: Your domain model is rich and read requirements are conceptually different from write requirements. **Not** for CRUD.
**How**: Put read-only projections in `views.py`. If needed, keep a denormalized read table (or Redis) updated by handlers on `Allocated`/`Deallocated`. Always have a rebuild path: query the write side, replay through the handler.
**Trade-offs (the four options)**:
| Option | Pros | Cons |
|---|---|---|
| Just use repositories | Simple, consistent | Performance issues with complex query patterns |
| Custom ORM queries | Reuses DB config and model definitions | Another query language with its own quirks |
| Hand-rolled SQL | Fine performance control, standard syntax | Schema changes hit your queries *and* your ORM definitions |
| Separate read store with events | Scales out; queries as simple as possible | Complex technique |

## Dependency Injection + Bootstrap (Composition Root)
**When to use**: Once you have more than one adapter.
**How**: Declare dependencies explicitly in handler signatures. A `bootstrap()` function declares defaults, runs init (`orm.start_mappers()`), injects deps into handlers (closures, `functools.partial`, classes, or `inspect.signature` matching), and returns a configured `MessageBus`. Entrypoints call `bootstrap.bootstrap()` and nothing else.
**Trade-offs**: Explicit deps are "unnecessary, strictly speaking, and marginally more complex — but in return, tests that are easier to write and manage." Closures use *late binding*; `partial` doesn't. Reach for a real DI framework (`Inject`, `Punq`, `dependencies`) only for chained dependencies.

## Building an Adapter "Properly" — the five-step recipe
1. Define your API using an **ABC**.
2. Implement **the real thing**.
3. Build a **fake** and use it for unit/service-layer/handler tests.
4. Find a **less fake** version for your Docker environment (e.g. MailHog for email).
5. **Test the less fake "real" thing.**
**Trade-offs**: Scale the ceremony — ABC for complex dependencies (multiple operations), a bare `Callable` for simple ones.

## Tolerant Reader / Postel's Law
**When to use**: Consuming messages from other systems, especially services you control.
**How**: Read only the fields you need; don't overspecify their internal structure; `ignore_extra_keys=True`. Treat SKUs, order numbers, and phone numbers as opaque strings.
**Trade-offs**: Right for event-based integration between your own services; a public internet-facing API may want to be more conservative. Resist sharing message definitions between systems.

## Three-Layer Validation
**When to use**: Always — pick the right layer.
**How**: **Syntax** (well-formedness) on the message class at the edge, via `schema` + `from_json`. **Semantics** (meaningfulness) in the service layer via an `ensure` module of preconditions. **Pragmatics** (can we comply in context) in the domain model.
**Trade-offs**: Validate *as little as possible* but *as early as possible*. Use the same UoW for preconditions as for the use case or you get concurrency bugs. If a rule can be tested in the domain model, test it there.

## SkipMessage (generic idempotency)
**When to use**: A message can't be processed but nothing is wrong — a duplicate, or something now out of date.
**How**: A precondition raises `SkipMessage(reason)`; the bus catches it and logs a warning.
**Trade-offs**: Keeps the "already handled" case out of every handler.

## Strangler Fig + Event Interception
**When to use**: Carving a service out of a legacy system you can't stop running.
**How**: (1) Raise events representing changes in the old system. (2) Build a second system that consumes them and builds its own domain model. (3) Replace the old system. Start with a **walking skeleton** — a deployment that only logs its input.
**Trade-offs**: Months of work, but incremental and reversible. See Sam Newman, *Monolith to Microservices*.

## Legacy Migration Recipe
**When to use**: You have a ball of mud and need a first step.
**How**: (1) Name the problem you're solving. (2) Enumerate use cases and give each an imperative name; build a service layer around them. (3) Break the object graph by replacing direct references with IDs. (4) Replace nested ORM loops with SQL for reads. (5) Change one aggregate per transaction for writes, joined by events.
**Trade-offs**: Duplication is fine during migration — "copy and paste it to a new place and then make that new code clean and tidy." Better than a long chain of use cases calling each other.
