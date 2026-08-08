# Glossary — Architecture Patterns with Python

**Adapter (secondary/driven/inward-facing)** — Concrete implementation of a port, going from our system out to the world: `SqlAlchemyRepository`, `EmailNotifications`, `redis_eventpublisher`. Lives in `adapters/`. (Ch2, Ch13, App A)

**Aggregate** — A cluster of associated objects treated as a unit for data changes; defines and enforces a consistency boundary. The only way to modify objects inside is to load the whole thing and call methods on the root. (Ch7)

**Aggregate root** — The entity that encapsulates access to an aggregate's members. `Product` is the root over `Batch`. (Ch7)

**Anemic Domain** — Anti-pattern where the domain model is reduced to data bags because all logic drifted into the service layer. (Ch4)

**Application service** — See *Service layer*. Handles requests from outside and orchestrates: get data → update the model → persist. Distinct from a *domain service*. (Ch4)

**Architecture tax** — Bob's term for attaching refactoring work to a feature project so it's an easier sell to the business. (Epilogue)

**At-least-once / at-most-once delivery** — The message-delivery guarantee you must consciously choose when moving to async messaging. (Ch11)

**Big Ball of Mud** — The anti-pattern where everything is coupled to everything, characterized by *sameness of function*. "The natural state of software in the same way that wilderness is the natural state of your garden." (Intro)

**Bootstrap script** — The Composition Root: declares default dependencies, runs one-time init, injects dependencies into handlers, returns the message bus. (Ch13)

**Bounded context** — Different models for the same word in different parts of a business. `Product(sku, batches)` in allocation vs `Product(sku, description, price, …)` in ecommerce. (Ch7)

**Classical mapping** — SQLAlchemy's `mapper()`-based style, defining schema separately from the model so the ORM depends on the model. Django has no equivalent. (Ch2, App D)

**Cohesion** — The good kind of togetherness: components that belong together and support each other. Want it *high* locally. (Ch3)

**Collaborators** — Objects that work together to achieve a goal (UoW and Repository). Clusters of them are called **object neighborhoods** in responsibility-driven design. (Ch6)

**Command** — A message capturing *intent*: imperative name, one recipient, fails noisily, modifies exactly one aggregate. `Allocate`, `CreateBatch`, `ChangeBatchQuantity`. (Ch10)

**Command Handler pattern** — The umbrella name for Events + Commands + Message Bus together. (Ch10)

**Composition Root** — The single place where an application's object graph is composed. Called "Pure DI" or "Vanilla DI" by Mark Seemann. (Ch13)

**Connascence** — A vocabulary for kinds of coupling. Want *strong connascence locally, weak connascence at a distance*. Of Execution and of Timing are strong; **of Name** is weak and is what event-driven integration buys you. (Ch11)

**Consistency boundary** — The set of objects an aggregate guarantees are mutually consistent. Also what a microservice should be. (Ch7, Ch11)

**Constraint** — A rule restricting the states a model can reach ("no double bookings"). (Ch7)

**Coupling** — Inability to change A without risking B. Good locally, poisonous globally; grows *superlinearly* in a ball of mud. (Ch3)

**CQRS (Command-Query Responsibility Segregation)** — CQS raised to architecture level: a separate read model, possibly a separate store, kept fresh by event handlers. (Ch12)

**CQS (Command-Query Separation)** — "Functions should either modify state or answer questions, but never both." (Ch12)

**CSV over SMTP** — Business processes run by emailing spreadsheets around. Low initial complexity, doesn't scale. (Ch7)

**Denormalized view model** — A read-optimized table with no foreign keys, e.g. `allocations_view(orderid, sku, batchref)`. (Ch12)

**Dependency Inversion Principle (DIP)** — (1) High-level modules should not depend on low-level modules; both should depend on abstractions. (2) Abstractions should not depend on details; details should depend on abstractions. The book's organizing principle. (Intro)

**Distributed ball of mud** — Microservices split by nouns, integrated by synchronous HTTP CRUD calls over anemic models. (Ch11)

**Domain event** — A fact about something that happened, named in past tense, recorded by the model as a dataclass. (Ch8)

**Domain exception** — An exception named in the ubiquitous language: `OutOfStock`, not `ValueError`. (Ch1)

**Domain model** — The business layer: plain Python objects and functions in the business's own jargon, with no framework/DB/IO dependencies. "The mental map that business owners have of their businesses." (Ch1)

**Domain service** — Business logic with no natural home in a stateful entity or value object; usually a function. `allocate()` before it moved onto `Product`. (Ch1, Ch4)

**Edge-to-edge testing** — Bob's term: invoke the whole system through its real entrypoint, but fake the I/O at both edges. (Ch3)

**Entity** — A domain object with long-lived identity whose attributes vary over time. Identity equality on a stable reference. (Ch1)

**Entrypoint (primary/driving/outward-facing adapter)** — Translates external input into service-layer calls: `flask_app.py`, `redis_eventconsumer.py`. (Ch4, App A)

**Ensure pattern** — Contract-based preconditions (`ensure.product_exists(uow, event)`) that keep semantic validation out of the main service-layer flow. (App E, Epilogue)

**Event interception** — Raise events representing changes in the old system, build a new system that consumes them, then replace the old one. The mechanism behind a Strangler Fig migration. (Epilogue)

**Event storming** — A facilitated practice for event-based requirements gathering and domain model elaboration. See eventstorming.org, eventmodeling.org. (Ch9, Epilogue)

**Eventual consistency** — Two aggregates (or services) that are not required to be immediately consistent; reconciled via events. (Ch8, Ch11)

**External events** — Events persisted to a centralized store so other containers or microservices can subscribe. (Ch8, Ch11)

**Fake** — A working implementation designed only for tests; wouldn't work in real life. Lets you assert on *end state*. Associated with classic-style TDD. (Ch3)

**Fat models, thin controllers** — The cheap alternative to a service layer: push logic down out of controllers without adding a layer. (Ch4, App D)

**Flush** — SQLAlchemy persisting all tracked changes together. (Ch6)

**Functional Core, Imperative Shell (FCIS)** — Gary Bernhardt's pattern: shell gathers inputs → pure core computes a decision from plain data → shell applies outputs. (Ch3)

**Goop** — The authors' word for the mundane cross-cutting stuff (email, reporting, permissions) that ruins clean flows. "It's not the obvious features that make a mess of our codebases: it's the goop around the edge." (Ch8)

**Handler** — Receives a command or event and performs what needs to happen. Same thing as a service-layer function after Ch9. (Ch9, App A)

**High gear / low gear** — Bicycle metaphor for test level. *Low gear* = domain tests, for new projects and gnarly problems. *High gear* = service-layer tests, for everything else. (Ch5)

**Ice-cream cone model** — Bob's name for the inverted test pyramid: too many E2E tests, too few unit tests. (Ch4)

**Idempotency** — Calling a handler repeatedly with the same message doesn't repeat state changes. Prerequisite for safe retries. (Epilogue, App E)

**Invariant** — A condition that is always true when an operation finishes. May be temporarily bent mid-operation. (Ch7)

**Message broker** — Infrastructure that takes messages from publishers and delivers them to subscribers: Event Store, Kafka, RabbitMQ, Redis pub/sub. (Ch11)

**Message bus (internal)** — A dict mapping message types to handlers, plus a dispatch loop. "Dumb infrastructure for getting messages around the system." (Ch8)

**Mock** — Verifies *how* something gets used (`assert_called_once_with()`). Associated with London-school TDD. The book avoids them. (Ch3)

**Object neighborhood** — Responsibility-driven design's name for a cluster of collaborating objects. "Totally adorable." (Ch6)

**Onion architecture** — Model on the "inside," dependencies flowing inward. Same thing as hexagonal / ports-and-adapters / clean architecture; all reduce to the DIP. (Ch2)

**Optimistic concurrency control** — Assume conflicts are unlikely; let both transactions proceed and detect the clash (via `version_number` + `REPEATABLE READ`). Handle failure by retrying. (Ch7)

**Outbox pattern** — Mentioned as the fix for cross-transaction reliability in event publishing. (Epilogue)

**Persistence ignorance** — The domain model knows nothing about how data is loaded or persisted. (Ch2)

**Pessimistic concurrency control** — Assume conflicts will happen; lock to prevent them (`SELECT FOR UPDATE` / `.with_for_update()`). (Ch7)

**Port** — The interface between your application and what you're abstracting. In Python: an ABC, a `Protocol`, or just the duck type your adapters conform to. (Ch2)

**Post/Redirect/Get** — The web pattern that separates the write phase from the read phase; a simple instance of CQS. (Ch12)

**Postel's Law / robustness principle** — "Be liberal in what you accept, and conservative in what you emit." (App E)

**Pragmatics** — Validation of whether we can *comply* in context ("allocate three million SCARCE-CLOCK"). Belongs in the domain model. (App E)

**Preparatory Refactoring** — "Make the change easy; then make the easy change." (Ch9)

**Primitive obsession** — The OO anti-pattern of putting primitives in public APIs. Applied mindlessly in Python, "a recipe for unnecessary complexity." (Ch9)

**Read model / view model** — A read-optimized projection of data, updated by event handlers on write. (Ch12)

**Repository** — An abstraction over persistent storage that gives "the illusion of a collection of in-memory objects." `add()` and `get()`. **One aggregate = one repository.** (Ch2, Ch7)

**Responsibility-driven design** — Wirfs-Brock & McKean's tradition of thinking in *roles and responsibilities* rather than data or algorithms. (Intro)

**Seam** — The place where you can draw a line between systems and slide an abstraction in. (Ch3)

**SELECT N+1** — The classic ORM performance trap: one query for IDs, then one per object. (Ch12)

**Semantics** — Validation of whether a message is *meaningful* (`{"orderid": "superman", "qty": -1}`). Belongs at the handler / message bus. (App E)

**Service layer** — Defines the jobs the system should perform and orchestrates components. One function per use case, following four steps: fetch → check → call domain → persist. (Ch4)

**Situated software** — Rich Hickey's term for software that runs for extended periods managing a real-world process: warehouse management, logistics schedulers, payroll. (Ch9)

**`.seen`** — The set on `AbstractRepository` tracking which aggregates were loaded, so the UoW can collect their events. (Ch8)

**`SkipMessage`** — Exception for messages that can't be processed but where nothing is wrong (duplicates, stale messages). Logged and skipped by the bus. (App E)

**Spy** — Records calls for later inspection; `FakeFileSystem(list)` is one. `MagicMock` is really a spy. (Ch3)

**Strangler Fig pattern** — Build a new system around the edges of an old one while keeping it running; gradually intercept and replace functionality until the old system does nothing. (Epilogue)

**Syntax** — Validation of whether a message is *well formed*. Belongs on the message class, at the edge. (App E)

**Temporal coupling** — "Every part of the system has to work at the same time for any part of it to work." (Ch11)

**Test-induced design damage** — DHH's critique of making dependencies explicit purely to enable testing. (Ch3)

**Tolerant Reader** — Extract only the fields you care about and do minimal validation on them (`ignore_extra_keys=True`). Martin Fowler's pattern. (App E)

**Ubiquitous language** — The business jargon, used verbatim as class, method, variable, test, and exception names. (Ch1)

**Unit of Work (UoW, "you-wow")** — An abstraction over atomic operations. A context manager giving a stable snapshot, all-or-nothing persistence, and access to repositories. Safe by default: explicit commit, implicit rollback. (Ch6)

**Value object** — An immutable domain object uniquely identified by the data it holds. Value equality. `@dataclass(frozen=True)`. (Ch1)

**View builder / view fetcher** — Split for read-heavy systems with complex read logic: the fetcher reads data returning tuples/dicts, the builder filters and maps them (and is easy to unit test). (Epilogue)

**Walking skeleton** — A first production deployment that only logs its input, forcing every infrastructure question into the open. "The 'Hello World' of event-driven architecture." (Epilogue)
