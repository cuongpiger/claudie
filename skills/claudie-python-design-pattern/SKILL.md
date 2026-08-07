---
name: claudie-python-design-pattern
description: "Knowledge base from \"Mastering Python Design Patterns\" (3rd ed) by Kamon Ayeva & Sakis Kasampalis. Use when choosing or applying design patterns in Python — creational, structural, behavioral, architectural, concurrency, performance, distributed systems, and testing patterns — plus SOLID principles and Python anti-patterns."
---

<!-- argument-hint: [pattern name, topic, or chapter number] -->

# Mastering Python Design Patterns (3rd Edition)
**Authors**: Kamon Ayeva & Sakis Kasampalis | **Publisher**: Packt, May 2024 | **Pages**: ~264 | **Chapters**: 11 | **Generated**: 2026-08-08
**Target runtime**: Python 3.12 (3.11 in a few chapters) · code Black-formatted, PEP 8 compliant

## How to Use This Skill

- **Without arguments** — load the core principles and pattern-selection rules below
- **With a pattern name** — ask about `strategy`, `circuit breaker`, `flyweight`; I read the relevant chapter
- **With a problem** — describe the design problem; I use the selection rules to pick a pattern
- **With a chapter** — ask for `ch05`; I load that chapter file
- **Browse** — ask "what chapters do you have?"

When you ask about something not covered below, I read the relevant chapter file before answering.

---

## Core Frameworks & Mental Models

### The four foundational principles (Ch 1)

These come before any pattern. Most patterns are just a disciplined application of one of them.

- **Encapsulate What Varies** — isolate the parts most likely to change behind a stable interface, so a change ripples through one class instead of the whole program. Python mechanisms: polymorphism (subclasses overriding a method) and the `@property` technique (turn attribute access into a method call, adding validation without changing call sites).
- **Favor Composition Over Inheritance** — build objects by assembling simpler objects ("has-a") rather than extending a base class ("is-a"). Inheritance binds you to the parent's implementation forever; composition lets you swap a collaborator at runtime. Reach for inheritance only when the subtype genuinely substitutes for the base (see LSP).
- **Program to Interfaces, Not Implementations** — depend on the shape of a collaborator, not its concrete class. Python gives you two ways: `abc.ABC` + `@abstractmethod` (nominal, explicit, enforced at instantiation) and `typing.Protocol` (structural, duck-typed, no inheritance required). **Prefer `Protocol`** when you don't control the implementing classes or want zero coupling; use `ABC` when you want to share implementation and force explicit opt-in.
- **Loose Coupling** — minimize what one component must know about another. Techniques: dependency injection, message passing, event-driven communication. The test: can you replace a collaborator without editing the consumer?

### SOLID (Ch 2)

| | Principle | The rule | Violation smell |
|---|---|---|---|
| **S** | Single Responsibility | One class, one reason to change | The class name contains "And"; unrelated methods cluster |
| **O** | Open-Closed | Open for extension, closed for modification | Adding a case means editing an `if/elif` chain |
| **L** | Liskov Substitution | Subtypes must be usable wherever the base is | A subclass raises `NotImplementedError` or narrows accepted input |
| **I** | Interface Segregation | Many small interfaces beat one fat one | Implementers stub out methods they don't need |
| **D** | Dependency Inversion | Depend on abstractions, not concretions | High-level code imports a concrete driver/client directly |

### Choosing a pattern — the fast path

- **Object creation is getting complicated** → creational (Ch 3). Many similar products → *factory method*; families of related products → *abstract factory*; many optional construction steps → *builder*; copying an expensive existing object → *prototype*; expensive-to-create reusable resources → *object pool*.
- **Two things won't fit together** → structural (Ch 4). Incompatible interface → *adapter*; too many subsystems to call → *facade*; abstraction and implementation both vary → *bridge*; adding behavior per-object at runtime → *decorator*; too many similar objects in memory → *flyweight*; need to intercept access → *proxy*.
- **Behavior changes at runtime** → behavioral (Ch 5). Caller picks the algorithm → *Strategy*; the object's own state picks it, with legal transitions → *State*; many objects react to one change → *Observer*; a request must be queued/undone/logged → *Command*; a request may be handled by one of several handlers → *Chain of Responsibility*.
- **The system spans processes or machines** → Ch 6 (MVC, Microservices, Serverless, Event Sourcing) and Ch 9 (Throttling, Retry, Circuit Breaker).
- **It's too slow** → Ch 8 (Cache-Aside, Memoization, Lazy Loading) before reaching for concurrency.
- **It's blocked on I/O or CPU** → Ch 7 (Thread Pool, Worker Model, Future and Promise, reactive Observer).

### Look-alikes — the question that separates them

- **Strategy vs State**: who decides? Strategy — the *caller* picks, and the strategies don't know about each other. State — the *object* transitions itself along a legal transition graph.
- **Decorator vs Proxy**: why wrap? Decorator *adds behavior*. Proxy *controls access* (lazily create, protect, reach remotely, count references).
- **Adapter vs Bridge**: when? Adapter is retrofit — you're fixing an interface mismatch after the fact. Bridge is upfront — you split abstraction from implementation so both can vary.
- **Factory vs Builder**: shape of construction? Factory hands you a finished object in one call. Builder assembles it over several steps, often with a director.

### Python-specific cautions the authors make

- **Singleton**: the authors treat it as largely an anti-pattern in Python. A module-level object already gives you one shared instance — reach for that (Brandon Rhodes' "Global Object Pattern") before a metaclass, which they consider too advanced and non-obvious for the benefit.
- **Factory method**: often over-engineered in Python. First-class functions, dynamic typing, and `**kwargs` do the same job with far less ceremony.
- **Mediator / Visitor**: the authors flag both as rarely worth it in Python.
- The **decorator pattern** and Python's `@decorator` syntax are not the same thing. The syntax is a superset — it implements the pattern, but also much else.

### Structuring the code itself (Ch 11)

Non-negotiables: never a mutable default argument; `isinstance()` not `type()` for type comparison; `str.join()` not `+=` in a loop; `functools.lru_cache` not a module-level dict for caching; explicit imports not `from x import *`; EAFP (`try/except`) over LBYL (`if` pre-checks) as the Python idiom. Format with Black, lint per PEP 8.

---

## Chapter Index

| # | Title | Key Patterns / Frameworks |
|---|-------|---------------------------|
| [ch01](chapters/ch01-foundational-design-principles.md) | Foundational Design Principles | Encapsulate What Varies, Favor Composition Over Inheritance, Program to Interfaces, Loose Coupling |
| [ch02](chapters/ch02-solid-principles.md) | SOLID Principles | SRP, OCP, LSP, ISP, DIP |
| [ch03](chapters/ch03-creational-patterns.md) | Creational Design Patterns | factory method, abstract factory, builder, prototype, singleton, object pool |
| [ch04](chapters/ch04-structural-patterns.md) | Structural Design Patterns | adapter, decorator, bridge, facade, flyweight, proxy |
| [ch05](chapters/ch05-behavioral-patterns.md) | Behavioral Design Patterns | Chain of Responsibility, Command, Observer, State, Interpreter, Strategy, Memento, Iterator, Template |
| [ch06](chapters/ch06-architectural-patterns.md) | Architectural Design Patterns | MVC, Microservices (gRPC, Lanarky), Serverless (LocalStack), Event Sourcing |
| [ch07](chapters/ch07-concurrency-async-patterns.md) | Concurrency and Asynchronous Patterns | Thread Pool, Worker Model, Future and Promise, Observer in reactive programming (RxPY) |
| [ch08](chapters/ch08-performance-patterns.md) | Performance Patterns | Cache-Aside (Redis), Memoization (`lru_cache`), Lazy Loading |
| [ch09](chapters/ch09-distributed-systems-patterns.md) | Distributed Systems Patterns | Throttling, Retry, Circuit Breaker (`pybreaker`) |
| [ch10](chapters/ch10-testing-patterns.md) | Patterns for Testing | Mock Object (`unittest.mock`), Dependency Injection |
| [ch11](chapters/ch11-python-anti-patterns.md) | Python Anti-Patterns | PEP 8 / Black, EAFP vs LBYL, correctness & performance anti-patterns |

## Topic Index

- **abstract factory** → ch03
- **ABC / abstract base class** → ch01, ch02
- **adapter** → ch04
- **anti-patterns** → ch11
- **asyncio** → ch07
- **bridge** → ch04
- **builder** → ch03
- **cache-aside** → ch08
- **Chain of Responsibility** → ch05
- **circuit breaker** → ch09
- **Command** → ch05
- **composition over inheritance** → ch01
- **concurrent.futures** → ch07
- **decorator (pattern)** → ch04
- **dependency injection** → ch01, ch10
- **Dependency Inversion / DIP** → ch02
- **descriptor** → ch04
- **EAFP / LBYL** → ch11
- **encapsulation** → ch01
- **Event Sourcing** → ch06
- **facade** → ch04
- **factory method** → ch03
- **flyweight** → ch04
- **Future and Promise** → ch07
- **GIL** → ch07
- **Interface Segregation / ISP** → ch02
- **Interpreter** → ch05
- **Iterator** → ch05
- **lazy loading** → ch08
- **Liskov Substitution / LSP** → ch02
- **lru_cache / functools** → ch08, ch11
- **Memento** → ch05
- **memoization** → ch08
- **microservices** → ch06
- **mock object** → ch10
- **multiprocessing** → ch07
- **mutable default argument** → ch11
- **MVC** → ch06
- **object pool** → ch03
- **Observer** → ch05, ch07
- **Open-Closed / OCP** → ch02
- **PEP 8 / Black** → ch11
- **Program to Interfaces** → ch01
- **property / @property** → ch01, ch04, ch08
- **Protocol (typing)** → ch01, ch10
- **prototype** → ch03
- **proxy** → ch04
- **reactive programming / RxPY** → ch07
- **retry** → ch09
- **serverless** → ch06
- **Single Responsibility / SRP** → ch02
- **singleton** → ch03
- **SOLID** → ch02
- **State** → ch05
- **Strategy** → ch05
- **Template** → ch05
- **thread pool** → ch07
- **throttling** → ch09
- **unittest.mock / patch** → ch10
- **Worker Model** → ch07

## Supporting Files

- [glossary.md](glossary.md) — all key terms with definitions
- [patterns.md](patterns.md) — the full pattern catalog: when to use, how, trade-offs
- [cheatsheet.md](cheatsheet.md) — decision trees, look-alike disambiguation, Python defaults

---

## Scope & Limits

Covers this book only (3rd ed, 2024, Python 3.12). Pattern names and the authors' cautions are preserved verbatim; code examples are reproduced as printed (Black-formatted). Library versions cited in the book — Redis 6.2.6, LocalStack 3.4.0, MyPy 1.10.0, Lanarky 0.8.6 — are as of mid-2024; verify current APIs before use. For patterns outside this book (e.g. full DDD, CQRS in depth) or for applying these to a specific codebase, combine with project tooling.
