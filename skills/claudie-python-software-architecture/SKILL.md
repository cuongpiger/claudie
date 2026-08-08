---
name: claudie-python-software-architecture
description: "Knowledge base from \"Architecture Patterns with Python: Enabling Test-Driven Development, Domain-Driven Design, and Event-Driven Microservices\" by Harry Percival and Bob Gregory. Use when applying their patterns for domain modeling, repository, unit of work, service layer, aggregates, domain events, message bus, CQRS, dependency injection, and event-driven microservice integration in Python, studying the book, or referencing its concepts."
---

<!-- argument-hint: [topic, pattern name, or chapter number] -->

# Architecture Patterns with Python
**Authors**: Harry Percival & Bob Gregory (O'Reilly, 2020) | **Pages**: ~340 | **Chapters**: 13 + intro, epilogue, 5 appendices | **Generated**: 2026-08-08

## How to Use This Skill

- **Without arguments** — load the core patterns below for reference
- **With a topic** — ask about `repository`, `aggregates`, `CQRS`, `validation`; I find and read the relevant chapter
- **With a chapter** — ask for `ch07`; I load that specific chapter file
- **Browse** — ask "what chapters do you have?" for the full index

When you ask about a topic not covered below, I read the relevant chapter file before answering.

---

## Core Frameworks & Mental Models

### The organizing principle: Dependency Inversion
1. *High-level modules should not depend on low-level modules. Both should depend on abstractions.*
2. *Abstractions should not depend on details. Details should depend on abstractions.*

High-level modules are what the business cares about (allocations, trades, patients) and must change **fast**. Low-level modules (SMTP, Postgres, AMQP) change **slowly**. Put an abstraction between them so each moves at its own speed. Onion / hexagonal / ports-and-adapters / clean architecture are all names for this.

**The goal, stated once**: *"Have the complexity of your application grow more slowly than its size."* Judge every pattern by what a new requirement costs you — new *instances* of existing categories, or new categories?

### Every pattern has a price — always ask both questions
"Programmers know the benefits of everything and the trade-offs of nothing." (Rich Hickey) Each chapter asks *"What do we get for this? And what does it cost us?"*
**If your app is a CRUD wrapper around a database and won't be more, you don't need any of this. Use Django and save yourself a lot of bother.**

### The write-side stack (Part I)
- **Domain Model** — plain Python in the business's own jargon (*ubiquitous language*), zero framework/DB/IO dependencies. Model **behavior first**; let it drive storage. Starting from a database schema is the most common way designs go wrong.
- **Value object vs Entity** — value objects are defined by their data (`@dataclass(frozen=True)`, value equality); entities have long-lived identity (`__eq__` on `.reference` only). Litmus: change a letter in a `Name` and it's a *different name*; change a `Person`'s name and it's the *same person*.
- **Domain service as a function** — "Sometimes, it just isn't a thing." For every `FooManager`/`BarBuilder`/`BazFactory` there's a more readable `manage_foo()` waiting to happen.
- **Repository** — `add()` and `get()`, giving "the illusion of a collection of in-memory objects." **Invert the ORM dependency**: `orm.py` imports `model.py`, never the reverse (SQLAlchemy classical mapping). Keep `.commit()` out.
- **Service Layer** — one function per use case, always four steps: fetch from the repository → check the request against current state → call a domain service → persist. Introduce it *after* orchestration leaks into your controllers, never before (or you get an Anemic Domain).
- **Unit of Work** — a context manager abstracting *atomic operations*. **Explicit commit, implicit rollback**: `__exit__` always rolls back, so the only code path that changes the system is total success plus a deliberate `commit()`. Safe by default.
- **Aggregate** — a cluster of objects treated as a unit, with a root that is the *only* way in. Choosing aggregates is choosing consistency boundaries — a conceptual *and* a performance decision. **One aggregate = one repository.** Modify one aggregate per transaction.

### The read/write asymmetry
**Domain models are for writing.** Everything above exists to enforce rules when *changing* state and buys you nothing for reads. Reads are cacheable, can be stale, and scale horizontally; writes must be transactionally consistent. Stale reads are unavoidable anyway — *"as soon as we render the product page, the data is already stale."* Split `views.py` from your handlers even if you never go to full CQRS.

### The event-driven stack (Part II)
- **Domain Events** — listen for **"When X, then Y"** from domain experts; that sentence *is* the design. Events are past-tense dataclasses the model appends to `self.events`. Stop using exceptions for the same concept.
- **Message Bus** — "a dict that maps from events to their consumers… dumb infrastructure." Not Celery, and it gives you **no concurrency** — handlers run synchronously inside your request.
- **Commands vs Events** — a *command* is imperative-named, has one handler, modifies one aggregate, and **fails noisily**. An *event* is past-tense, has many handlers, and **fails independently** (logged, `continue`d). This split is how you choose what *must* succeed vs what can be tidied up later.
- **Events across services** — think in **verbs, not nouns**: a system for *ordering* and a system for *allocating*, not for orders and batches. Microservices are consistency boundaries too. Async messaging drops Connascence of Execution/Timing down to Connascence of **Name**.
- **CQRS** — a denormalized read model kept fresh by event handlers. *"Fancy CQRS is really a way of running our complex view logic whenever we write so that we can avoid running it when we read."*
- **DI + bootstrap script** — once you have more than one adapter, declare dependencies explicitly and inject them in one Composition Root that also does init and returns the configured bus.

### Testing philosophy
- **High gear / low gear**: domain tests give maximum design feedback but glue the design in place; service-layer tests give lower coupling and higher coverage. Default to high gear; drop to low gear for new projects and gnarly problems.
- *"Every line of code that we put in a test is like a blob of glue, holding the system in a particular shape."* Delete domain tests once the service layer covers the behavior.
- **Prefer fakes over mocks; prefer DI over `mock.patch`.** Patching makes code testable without making it *better* — it won't give you a `--dry-run` flag or let you run against FTP.
- Aim for **one E2E test per feature**, one E2E test for *all* unhappy paths, and the bulk of tests at the service layer.
- *"If it's hard to fake, the abstraction is probably too complicated."*

---

## Chapter Index

| # | Title | Key Frameworks |
|---|-------|----------------|
| [ch00](chapters/ch00-introduction-why-designs-go-wrong.md) | Introduction: Why Do Our Designs Go Wrong? | Big Ball of Mud, encapsulation/abstraction, layering, DIP |
| [ch01](chapters/ch01-domain-modeling.md) | Domain Modeling | Domain Model, Value Object, Entity, domain service, domain exceptions |
| [ch02](chapters/ch02-repository-pattern.md) | Repository Pattern | Repository, classical mapping, ports & adapters, `FakeRepository` |
| [ch03](chapters/ch03-coupling-and-abstractions.md) | On Coupling and Abstractions | Coupling/cohesion, FCIS, edge-to-edge testing, fakes vs mocks |
| [ch04](chapters/ch04-service-layer-and-flask-api.md) | Our First Use Case: Flask API and Service Layer | Service Layer, orchestration vs business logic, folder structure |
| [ch05](chapters/ch05-tdd-in-high-gear-and-low-gear.md) | TDD in High Gear and Low Gear | Test spectrum, high/low gear, rules of thumb for test types |
| [ch06](chapters/ch06-unit-of-work-pattern.md) | Unit of Work Pattern | UoW, context managers, explicit commit, "don't mock what you don't own" |
| [ch07](chapters/ch07-aggregates-and-consistency-boundaries.md) | Aggregates and Consistency Boundaries | Aggregate, invariants, bounded contexts, optimistic concurrency |
| [ch08](chapters/ch08-events-and-the-message-bus.md) | Events and the Message Bus | Domain Events, Message Bus, `.seen`, three publishing options |
| [ch09](chapters/ch09-going-to-town-on-the-message-bus.md) | Going to Town on the Message Bus | Everything is a handler, preparatory refactoring, events as interface |
| [ch10](chapters/ch10-commands-and-command-handler.md) | Commands and Command Handler | Commands vs events, error-handling asymmetry, retries with `tenacity` |
| [ch11](chapters/ch11-event-driven-microservices-integration.md) | Event-Driven Architecture: Integrating Microservices | Verbs not nouns, connascence, message broker, Redis pub/sub adapters |
| [ch12](chapters/ch12-cqrs.md) | Command-Query Responsibility Segregation (CQRS) | CQS, Post/Redirect/Get, read models, four view-model options |
| [ch13](chapters/ch13-dependency-injection-and-bootstrapping.md) | Dependency Injection (and Bootstrapping) | Explicit dependencies, Composition Root, adapter recipe |
| [ch14](chapters/ch14-epilogue-getting-there-from-here.md) | Epilogue: What Now? | Legacy migration, Strangler Fig, event interception, footguns |
| [ch15](chapters/ch15-appendices-structure-csv-django-validation.md) | Appendices A–E | Architecture table, project structure, CSV swap, Django, validation |

## Topic Index

- **Aggregate** → ch07, ch10, ch14
- **Anemic Domain** → ch04
- **Big Ball of Mud** → ch00, ch03, ch11, ch14
- **Bootstrap / Composition Root** → ch13
- **Bounded context** → ch07
- **Commands** → ch10, ch09, ch11
- **Connascence** → ch11
- **Consistency boundary** → ch07, ch10, ch11
- **CQRS / CQS** → ch12, ch14
- **Dependency Injection** → ch13, ch03
- **Dependency Inversion Principle** → ch00, ch02, ch04, ch06, ch13
- **Django** → ch15, ch14
- **Docker / project structure / config** → ch15
- **Domain events** → ch08, ch09, ch11
- **Domain model** → ch01, ch12
- **Entity vs Value Object** → ch01
- **Event-driven microservices** → ch11, ch14
- **FCIS (Functional Core, Imperative Shell)** → ch03
- **High gear / low gear** → ch05
- **Idempotency** → ch14, ch15
- **Invariants & constraints** → ch07
- **Legacy migration** → ch14
- **Message bus** → ch08, ch09, ch10, ch13
- **Mocks vs fakes** → ch03, ch06
- **Optimistic / pessimistic concurrency** → ch07
- **Ports and adapters** → ch02, ch04, ch13
- **Read models / views** → ch12, ch14
- **Repository** → ch02, ch07, ch12, ch15
- **Retries / error handling** → ch10, ch14
- **SELECT N+1** → ch12, ch14
- **Service layer** → ch04, ch05, ch14
- **SOLID / SRP** → ch00, ch08
- **Strangler Fig** → ch14
- **Testing strategy / test pyramid** → ch05, ch03, ch04
- **Tolerant Reader / Postel's Law** → ch15
- **Ubiquitous language** → ch01, ch14
- **Unit of Work** → ch06, ch09, ch15
- **Validation** → ch15, ch11

## Supporting Files

- [glossary.md](glossary.md) — every key term with a definition and chapter reference
- [patterns.md](patterns.md) — all patterns with when-to-use / how / trade-offs
- [cheatsheet.md](cheatsheet.md) — decision rules, smell tests, and thresholds

---

## Scope & Limits

This skill covers the book's content only. The example code is deliberately not production-hardened — the authors call it "a set of Lego blocks." Reliable messaging, idempotent handlers, event schema versioning, and message ordering are all acknowledged gaps you must solve yourself. For hands-on work in your codebase, combine with project-specific tools; for Python implementation idioms beyond architecture, see `claudie-python-expert`.
