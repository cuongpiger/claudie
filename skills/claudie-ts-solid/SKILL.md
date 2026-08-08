---
name: claudie-ts-solid
description: "Knowledge base from \"SOLID: An Ontology of Software Design, Architecture and Testing with TypeScript\" by Khalil Stemmler (solidbook.io). Use when applying Stemmler's frameworks for SOLID principles, Responsibility-Driven Design, object stereotypes, clean code, naming, TypeScript error handling with Either, TDD, Domain-Driven Design, hexagonal architecture, or architectural style selection — and when reviewing TypeScript/Node design decisions, studying the book, or referencing its concepts."
---

<!-- argument-hint: [topic, framework name, or chapter number] -->

# SOLID: An Ontology of Software Design, Architecture and Testing with TypeScript
**Author**: Khalil Stemmler (solidbook.io) | **Words**: ~250,000 | **Book chapters**: 75, across 10 parts | **Skill chapters**: 22 | **Generated**: 2026-08-08

## How to Use This Skill

- **Without arguments** — load the core frameworks below for reference
- **With a topic** — ask about `connascence`, `object stereotypes`, `Either type`, `aggregate design`; I find and read the relevant chapter
- **With a chapter** — ask for `ch17` (SOLID) or `ch13` (RDD); I load that file
- **Browse** — ask "what chapters do you have?" for the full index

When you ask about a topic not covered below, I read the relevant chapter file before answering.

---

## Core Frameworks & Mental Models

### The goal, and the enemy
**The goal of software design**: *build products that serve the needs of the customer and of the users, and can be **cost-effectively changed by developers***. The enemy is **complexity** — anything that makes a system hard to **understand and modify**.

Separate **essential complexity** (the features, data, behaviour, and what must be shown — declarative, the floor) from **accidental complexity** (every design decision you make — imperative). Only the second is negotiable.

**Detect complexity by four symptoms** — and note the first two pull in *opposite* directions:
- **Ripple** — a simple change forces edits elsewhere → **under**-abstraction, tight coupling
- **Cognitive load** — too many elements to hold in your head → **over**-abstraction, too many layers
- **Poor discoverability** — can't find where to change it
- **Poor understandability** — found it, don't know how to change it

**Prefer strategic over tactical programming**: a **50/50 split** between code for the customer and code for maintainers. Justified by 40–80% of lifetime cost being maintenance. Tactical (brute force, 0% maintainability) is legitimate *only* for spikes and prototypes.

### SOLID — apply it at two levels
| | Class level | Architectural level |
|---|---|---|
| **SRP** | One reason to change | Each **bounded context** owns one responsibility |
| **OCP** | Add a class, don't edit one | Extend with new modules without rewriting |
| **LSP** | Subclasses honour the base contract | Subsystems stay substitutable behind a shared contract |
| **ISP** | Many small interfaces | Thin boundaries between teams and services |
| **DIP** | Depend on interfaces, inject concretes | Architecture depends on **ports**, not frameworks |

Stemmler's distinctive takes:
- **Resolve SRP arguments with object stereotypes**, not intuition. Ask *"how many stereotypes is this class playing?"*
- **OCP is an architecture test.** If adding a feature touches many files, fix the structure (vertical slices), not your discipline. *"It's about plopping in new slices of functionality."*
- **LSP is kept in the constructor**, not in documentation — push the invariant into the base class so subclasses *cannot* violate it.
- **Start with the interfaces.** *"If I'm building a repository, I always start by documenting what it should do."*
- **DIP is what makes `InMemoryUserRepo` possible** — it's the load-bearing principle for testability.

### Responsibility-Driven Design — the six object stereotypes
**Tests aren't design.** TDD delivers functional requirements; it won't produce expressive, minimal abstractions. RDD fills the gap: convert requirements into **responsibilities** (obligations to *do* or *know*), group them into **roles**, then design **collaborations**.

| Stereotype | Responsibility | Usual layer |
|---|---|---|
| **Information Holder** | Hold information (Value Object, Entity, DTO) | Domain |
| **Structurer** | Maintain relationships, protect invariants (Aggregate, cache) | Domain |
| **Service Provider** | Passive, specialized computation (Domain Service, utilities, cross-cutting) | Anywhere |
| **Coordinator** | Pass information so others can work | Application |
| **Controller** | Declaratively coordinate lower-level concerns — **identical to the Use Case pattern** | Application |
| **Interfacer** | Bridge neighborhoods (Gateway, Event Listener, Presenter) | Infrastructure |

This is the highest-leverage tool in the book: it makes SRP decidable, maps candidates straight to architectural layers, and forms Level 1 of the pattern hierarchy.

**"Objects come and go, filling in roles."** Like a manager who needs *a Server* — not Molly or Frank specifically. **"Object models violate real-world physics"** — model only what the requirements demand; realism is a trap.

### Errors ≠ Exceptions
- **Errors** are **expected** failures in code **you own** — essential complexity, domain concepts. **Return** them.
- **Exceptions** are **unexpected** failures in code you **don't own** — accidental complexity. **Throw** them; wrap I/O in try/catch and convert to an `ApplicationError`.

Every feature has **one happy path and multiple sad paths**. Model them as `Either<Success, Failure1 | Failure2 | …>`, with domain errors as **classes** (so message construction is encapsulated). **Never** return bare `null`; **never** match on error message strings.

### Types are a design tool
Types **separate the contract from the implementation** — that separation is what makes SOLID, DI, plugin architectures, and ports & adapters possible at all. TypeScript is **structural**, not nominal: same shape = same type, so an empty marker class buys nothing. **Wrap primitives that carry domain rules** (`Email`, `Money`, `UserID`) with a private constructor + static `create()` — that's how you make illegal states unrepresentable.

### Human-centered design — your codebase is a UI
Norman's principles transfer directly: **affordances** (code's are documentation and reading), **signifiers** (design patterns, tests, and comments are *intentional*; dead code and nested conditionals are *accidental*), **constraints** (types, access modifiers, thin interfaces, explicit error handling), **mapping** (put the control on the thing it controls), **feedback** (compile-time checking and autocomplete *are* feedback).

**Test cleanliness with three questions**: What does my code do? · Find the code that needs changing · Change it without introducing bugs.

### Coupling, Cohesion & Connascence — the big three
**Connascence** (Page-Jones) beats "coupling" as vocabulary: it names *how* two elements depend on each other. Three axes — **strength**, **degree**, and **locality**. **Locality decides**: strong connascence inside one function is fine; the same across a service boundary is a liability. Prefer **static** (name, type, convention, algorithm, position) over **dynamic** (execution order, timing, value, identity).

**When overwhelmed, fall back to the Four Elements of Simple Design**: runs all tests · expresses intent · no duplication · minimal classes and methods.

### Architecture — structure vs. content
The **style** is the floor plan; **patterns and domain logic** are what you put in the rooms. Six common principles anchor every style: **vertical boundaries** (features as end-to-end slices) × **horizontal boundaries** (layers) = a grid · **contracts** · **cross-cutting concerns** handled once · **the Dependency Rule** (inner never depends on outer) · **Conway's Law**.

Every pattern carries an explicit **cost ranking 1–5**. Nothing above 3 is justified without a specific problem demanding it. **Prefer a well-structured modular monolith** until you have multiple autonomous teams; Stemmler's top three for distributed work are **Client-Server + Serverless + Cloud**, *not* microservices.

### Features (use cases) are the key
**Feature = use case** — the atomic unit of discovery, planning, estimation, folder structure, and tests. *"Use cases transform software development from a lofty I'm-not-sure-when-I'm-done thing into a definite, formal, focused practice which can be mastered."* Code not backed by a use case is, by definition, accidental complexity.

**Organize folders by feature, not by type.** Two places for any file: a feature folder, or `shared/`. Your architecture should **scream the domain**, not the framework.

### TDD — refactoring is where design happens
Red-green-refactor exists to create a safe moment for design work. **Rule of Three**: only remove duplication on the *third* occurrence — *"a little duplication is 10× better than a wrong abstraction."* **Write tests backwards** (assert → act → arrange) when stuck. Use the **Transformation Priority Premise** to choose the next red→green step instead of guessing. Mix **Classic** (inside-out) and **Mockist** (outside-in) TDD.

**Contract tests are what license you to mock**: if the fake passes the contract and production passes the contract, production works.

---

## Chapter Index

| # | Title | Book ch. | Key Frameworks |
|---|-------|---|----------------|
| [ch01](chapters/ch01-complexity-craftsmanship-and-the-stack.md) | Complexity, Craftsmanship & the Design Stack | 1–3 | Essential vs. accidental complexity, four symptoms, tactical vs. strategic, XP values, the 9-step Stack |
| [ch02](chapters/ch02-clean-code-and-human-centered-design.md) | Clean Code & Human-Centered Design | 4–5 | Seven Stages of Action, knowledge in head/world, affordances, signifiers, constraints, mapping, feedback |
| [ch03](chapters/ch03-organizing-things-and-documentation.md) | Organizing Things & Documentation | 6–7 | Feature-driven structure, Screaming Architecture, 4 organization rules, 6 README questions |
| [ch04](chapters/ch04-naming-things.md) | Naming Things | 8 | The 7 naming principles, compression vs. context, ~35 concrete rules |
| [ch05](chapters/ch05-comments-formatting-and-style.md) | Comments, Formatting & Style | 9–10 | Code=what/how, comments=why; 3 readability truths, Newspaper Code, Step-down Principle |
| [ch06](chapters/ch06-typescript-type-system.md) | TypeScript's Type System | 11 | Static/dynamic × strong/weak, nominal vs. structural (duck) typing, wrapping primitives |
| [ch07](chapters/ch07-errors-and-exceptions.md) | Errors and Exceptions | 12 | Errors vs. exceptions, one happy path/many sad paths, the **Either type**, ApplicationError |
| [ch08](chapters/ch08-features-planning-and-stories.md) | Features, Planning, Stories & Estimates | 13–21 | Feature=use case, anatomy of a feature, Bill of Rights, INVEST, story points, pseudocode docs |
| [ch09](chapters/ch09-acceptance-tests-and-bdd.md) | Acceptance Tests & BDD | 22 | Customer writes/developer automates, Given-When-Then, the 3 formats, jest-cucumber |
| [ch10](chapters/ch10-programming-paradigms-and-oo-architecture.md) | Programming Paradigms & OO Architecture | 23–24 | Sequence/selection/iteration/indirection, web of objects, **core vs. infrastructure**, MVC's failure |
| [ch11](chapters/ch11-testing-strategies-walking-skeleton-pairing.md) | Testing Strategies, Walking Skeleton & Pairing | 25–27 | Test types, 5-part strategy, Walking Skeleton, Page Objects, strong-style pairing |
| [ch12](chapters/ch12-tdd-workflow-and-classic-tdd.md) | TDD Workflow & Classic TDD | 28–31 | Three Laws, Rule of Three, triangulation, tests backwards, **Transformation Priority Premise** |
| [ch13](chapters/ch13-responsibility-driven-design.md) | Responsibility-Driven Design | 32–34 | Analysis/design/programming, responsibilities→roles→collaborations, **six object stereotypes**, CRC cards |
| [ch14](chapters/ch14-object-calisthenics.md) | Object Calisthenics | 35 | The nine rules + concrete size thresholds |
| [ch15](chapters/ch15-code-smells-and-anti-patterns.md) | Code Smells & Anti-Patterns | 36 | 3-tier severity, 5 smell categories, smell→refactoring map, the 7 most common |
| [ch16](chapters/ch16-design-patterns.md) | Design Patterns & Pattern Awareness | 37–41 | Pattern Adoption Loop, Pattern Hooks, **Four-Dimensional Lens**, Composition Root, Stemmler's verdicts |
| [ch17](chapters/ch17-solid-principles.md) | **The SOLID Principles** | 42 | SRP, OCP, LSP, ISP, DIP — with TypeScript examples and architectural scaling |
| [ch18](chapters/ch18-structural-behavioural-creational-principles.md) | Structural, Behavioural & Creational Principles | 43–45 | 2 Meta-Questions, SoC, CQS, Tell Don't Ask, DBC, Hollywood, DRY/YAGNI/KISS, Wishful Thinking |
| [ch19](chapters/ch19-least-principles-connascence-simple-design.md) | Least Principles, Connascence & Simple Design | 46–48 | Least Effort/Astonishment/Knowledge/Resistance, **9 types of connascence**, Four Elements |
| [ch20](chapters/ch20-architecture-principles-styles-patterns.md) | Architectural Principles, Styles & Patterns | 49–55 | 6 common principles, **cost-ranked pattern tables**, component principles, LRM, Walking Skeleton |
| [ch21](chapters/ch21-domain-driven-design-and-dddforum.md) | Domain-Driven Design & DDDForum | 56–60, 70 | Ubiquitous Language, building blocks, subdomain types, **3 aggregate rules**, Domain Events |
| [ch22](chapters/ch22-advanced-tdd.md) | Advanced TDD | 71–75 | **3 verification types**, contract tests, characterization testing, idempotency, **builders & the Data Model Tree** |

## Topic Index

- **Acceptance tests / BDD / Given-When-Then** → ch09, ch22, ch08
- **Affordances, signifiers, constraints** → ch02
- **Aggregates** → ch21, ch13
- **Anti-patterns** → ch15
- **Architecture (styles, patterns, cost)** → ch20, ch10
- **Arrange-Act-Assert** → ch12
- **Builders / fixtures / test data** → ch22, ch16
- **Clean code** → ch02, ch04, ch05
- **CQS / CQRS** → ch18, ch20, ch02, ch04
- **Code smells** → ch15, ch14
- **Cohesion** → ch19, ch02
- **Comments** → ch05
- **Composition Root** → ch16, ch22
- **Composition over inheritance** → ch18, ch10
- **Connascence** → ch19
- **Contract tests** → ch22
- **Conway's Law** → ch20
- **Core vs. infrastructure code** → ch10, ch11
- **Coupling** → ch19, ch01
- **Complexity (essential/accidental)** → ch01
- **Dependency Inversion / Dependency Rule** → ch17, ch20, ch21
- **Design by Contract** → ch18
- **Design patterns (GoF)** → ch16
- **Domain-Driven Design** → ch21, ch08
- **Domain Events** → ch21, ch18
- **Either type / functional error handling** → ch07
- **Entities & Value Objects** → ch21, ch06, ch14
- **Errors & exceptions** → ch07
- **Estimates & story points** → ch08
- **Event Storming** → ch08, ch21
- **Feature-driven folder structure** → ch03, ch20
- **Formatting & style / ESLint / Prettier** → ch05
- **Hexagonal architecture / ports & adapters** → ch20, ch22, ch21
- **Hollywood Principle** → ch18
- **Human-centered design** → ch02
- **Integration tests** → ch22, ch11
- **INVEST** → ch08
- **Law of Demeter** → ch19, ch14, ch02
- **Legacy code / characterization testing** → ch22
- **Liskov Substitution Principle** → ch17
- **Microservices vs. monolith** → ch20, ch10
- **Naming** → ch04
- **Object Calisthenics** → ch14
- **Object stereotypes** → ch13, ch16, ch15
- **Open-Closed Principle** → ch17
- **Pair programming** → ch11
- **Page Objects** → ch11
- **Paradigms (structured/OO/functional)** → ch10
- **Pattern awareness / Four-Dimensional Lens** → ch16
- **Planning & release planning** → ch08
- **Primitive Obsession** → ch14, ch06
- **Programming by Wishful Thinking** → ch18, ch12, ch22
- **Repository pattern** → ch16, ch21
- **Responsibility-Driven Design** → ch13
- **Rule of Three** → ch12, ch18
- **Screaming Architecture** → ch03
- **Separation of Concerns** → ch18
- **Simple Design (4 elements)** → ch19
- **Single Responsibility Principle** → ch17, ch13
- **SOLID** → ch17
- **Software Craftsmanship** → ch01
- **Story writing** → ch08
- **Subdomains & Bounded Contexts** → ch21
- **TDD (workflow, laws, Classic/Mockist)** → ch12, ch22, ch11
- **Tell, Don't Ask** → ch18
- **Testing strategies** → ch11, ch22
- **Thin interfaces** → ch02, ch17
- **Transformation Priority Premise** → ch12
- **Triangulation** → ch12
- **Types / TypeScript type system** → ch06
- **Ubiquitous Language** → ch21, ch04
- **Use cases / features** → ch08, ch03, ch13
- **Verification (result/state/communication)** → ch22
- **Vertical slices** → ch03, ch20
- **Walking Skeleton** → ch11, ch20
- **YAGNI / KISS / DRY** → ch18, ch12

## Supporting Files

- [glossary.md](glossary.md) — ~110 key terms with definitions and chapter references
- [patterns.md](patterns.md) — every concrete technique with when-to-use / how / trade-offs
- [cheatsheet.md](cheatsheet.md) — decision rules, thresholds, cost rankings, tells & smells

---

## Scope & Limits

This skill covers the book's content only. **Part VI (Design Patterns, ch16)** deliberately defers GoF *mechanics* to the sibling `claudie-ts-design-pattern` skill and keeps only what's distinctive to Stemmler — his verdicts on each pattern, the DDD variants, and the Four-Dimensional Lens.

Code examples were reconstructed from a text extraction that shattered TypeScript formatting; they are faithful in substance but were re-typeset, so treat them as illustrative rather than as literal quotations. For hands-on implementation in your codebase, combine with project-specific tooling.
