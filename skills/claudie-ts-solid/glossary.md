# Glossary — *SOLID: An Ontology of Software Design, Architecture and Testing with TypeScript*

**Absolute complexity** — Complexity inherent to an algorithm that can't be refactored away; the legitimate case for a comment (Ch 05)

**Accidental complexity** — Virtually any complexity that isn't essential; the implementation space, the imperative. Introduced the moment you start building (Ch 01)

**Acceptance Test** — A formalized description of a story's behavior; contractualizes success and failure scenarios. Customer writes, developer automates (Ch 09)

**Affordance** — What an object's physical attributes tell you that you can do with it. Code's affordances are documentation and reading (Ch 02)

**Aggregate** — A collection of entities bound by an aggregate root; the transaction boundary. Dispatches Domain Events (Ch 21). RDD stereotype: **Structurer** (Ch 13)

**Ambient types** — TypeScript declarations that let you safely use existing JavaScript libraries; a sliding effort/safety scale (Ch 06)

**Anti-pattern** — A well-known recurring "solution" that produces negative consequences. Unlike smells, can't be fixed by one refactoring — avoid from the start (Ch 15)

**Anti-affordance** — A property limiting what's possible (glass blocks passage). Unnoticed anti-affordances are how people walk into glass doors (Ch 02)

**Arrange-Act-Assert (AAA)** — Test structure; write it backwards (assert first) when stuck (Ch 12)

**BDD (Behavior-Driven Development)** — Dan North, 2006; "TDD done right." Tests focused on behavior, not implementation. Often described as DDD + TDD (Ch 09)

**Bill of Rights** — XP's customer and developer rights (Beck, Fowler, Martin) (Ch 08)

**Bloaters** — Code smell category: excessively large methods, classes, parameter lists (Ch 15)

**Bounded Context** — A **physical** boundary in DDD (contrast: subdomain = logical) (Ch 21)

**Characterization test** — A test written for existing code to capture its current behavior *after the fact*; for legacy code (Ch 22)

**Cohesion** — How strongly a module's internal parts relate. Aim high (Ch 19)

**Command Query Separation (CQS)** — A method is either a command (changes state) or a query (returns data), never both. Also a naming and feedback rule (Ch 18, Ch 02, Ch 04)

**Communication Verification** — Verifying that the subject *attempted* to interact with a dependency, and how (Ch 22)

**Composition Root** — The single place where dependencies are wired; Stemmler's preferred Singleton use. `TestCompositionRoot` builds a test version of the whole app (Ch 16)

**Concretion** — A literal object created with `new`. Opposite of an abstraction (Ch 01)

**Connascence** — Meilir Page-Jones: the degree and type of dependency where changing one element *forces* a change in another. Axes: strength, degree, **locality** (Ch 19)

**Contract** — An interface describing *what* a module does, not *how*; the mechanism behind DIP (Ch 20)

**Contract test** — Verifies all implementations of a port satisfy the same contract; the transitivity argument that licenses mocking (Ch 22)

**Controller (stereotype)** — RDD: a high-level, declarative object coordinating lower-level concerns. **Identical to the Use Case pattern** (Ch 13)

**Coordinator (stereotype)** — RDD: passes information to other objects so they can work (Ch 13)

**Core code** — Features and domain logic; knows nothing of databases, caches, or web servers. "The family jewels" (Ch 10)

**Couplers** — Code smell category: inappropriate intimacy between modules (Ch 15)

**Coupling** — Degree of interdependence between components. Aim low. Forms: subclass, temporal, dynamic (Ch 01, Ch 19)

**Cross-cutting concern** — Logic spanning multiple slices/layers that mustn't be duplicated: auth, logging, auditing, transactions (Ch 20)

**CRC Cards** — Class-Responsibility-Collaboration cards (Cunningham & Beck); a cheap design artifact (Ch 13)

**Data Model Tree** — The dependency-ordered relationships between database models; you must reconstruct it to set up test state (Ch 22)

**Degrees of freedom** — Triangulation metaphor: a `Car` has three (surge, sway, yaw); you aren't done until all are tested (Ch 12)

**Dependency Rule** — Inner (domain) layers never depend on outer (infrastructure) layers (Ch 20, Ch 21)

**Design by Contract (DBC)** — Define preconditions, postconditions, and invariants; enforce with guard clauses, not comments (Ch 18)

**Dispensables** — Code smell category: dead code, unused parameters, redundant comments (Ch 15)

**Domain Event** — An object describing an event domain experts care about. "The best part of DDD" (Ch 21)

**Domain model** — A declarative, zero-dependency layer encapsulating a problem domain's business rules; the *solution space* (Ch 21)

**Domain Service** — Domain logic belonging to no single object. May not depend on repositories (Ch 21). RDD stereotype: **Service Provider** (pure fabrication)

**Double Loop TDD** — Acceptance test as outer loop; red-green-refactor as inner loop (Ch 12)

**Duck typing** — "If it looks like a duck…" Structural type compatibility, TypeScript's model (Ch 06)

**Either type** — `Either<S, F> = Success<S, F> | Failure<S, F>`; models one happy path and many sad paths as a typed union (Ch 07)

**Entity** — A domain object we care to uniquely identify; compared by identifier (Ch 21)

**Entropy** — Randomness/disorder; the default state of the world and of codebases (Ch 01)

**Errors** — **Expected** failure reasons in code we own; domain concepts. **Return** them (Ch 07)

**Essential complexity** — Complexity inherent to the system: the features, data, behaviour, and what must be presented. Declarative; the floor (Ch 01)

**Event Storming** — Collaborative domain-discovery: plot events → identify commands → identify aggregates → decompose to subdomains → use the ubiquitous language (Ch 08, Ch 21)

**Exceptions** — **Unexpected** failure reasons from code or context we don't own; accidental complexity. **Throw** them (Ch 07)

**Feature** — Synonym for **use case**; also a user story, command, or query (Ch 08)

**Feedforward / Feedback** — Norman's Seven Stages: plan/specify/perform are feedforward; perceive/interpret/compare are feedback. **Feedback leads to the conceptual model** (Ch 02)

**First-Class Collection** — A class wrapping an array with meaningful domain methods (Ch 14)

**Four Elements of Simple Design** — XP/Kent Beck: runs all tests · expresses intent · no duplication · minimal classes & methods (Ch 19)

**Four-Dimensional Lens** — Categorize any pattern by: object role · architectural layer · pattern category · architectural pattern (Ch 16)

**Golden Hammer** — Anti-pattern: always using the same tool regardless of fit (Ch 15)

**God object** — Anti-pattern: a class hoarding too many responsibilities (Ch 15, Ch 17)

**Hollywood Principle** — "Don't call us, we'll call you." Inversion of control; scales into event-driven architecture (Ch 18)

**Information Holder (stereotype)** — RDD: holds information; usually domain layer (Value Objects, Entities, DTOs) (Ch 13)

**Interfacer (stereotype)** — RDD: bridges object neighborhoods. External → **Gateway**; UI in → **Event Listener**; UI out → **Presenter** (Ch 13)

**INVEST** — Story principles: Independent, Negotiable, Valuable, Estimable, Small, Testable (Ch 08)

**Knowledge in the head / in the world** — Norman: must be learned vs. needs no learning. Prefer the world (Ch 02)

**Last Responsible Moment (LRM)** — Delay a decision until further postponement creates significant risk or cost (Ch 20)

**Law of Demeter** — Principle of Least Knowledge; "my object doesn't talk to strangers." Object Calisthenics Rule #5 (Ch 19, Ch 14)

**Leaky abstraction** — "All non-trivial abstractions eventually leak" (Ch 01)

**Least Astonishment** — Behavior must match what the name and context suggest; no hidden side effects (Ch 19)

**Least Resistance** — Workflow-level friction removal; the DX principle. Prevents "psychic entropy" (Ch 19)

**Mistakes vs. Slips** — Slip: right goal, wrong sequence (recoverable). Mistake: wrong goal or plan (Ch 02)

**Mockist TDD** — Outside-In / London style: start at the boundary, code inwards with mocks (Ch 12)

**Modular Monolith** — Subdomains as modules in one deployment. Start here, not with microservices (Ch 10, Ch 21)

**Newspaper Code Principle** — Front-load a file with the most important things (Ch 05)

**Nominal typing** — Type validity based on declared name and subtype relationship (Java). Not TypeScript's model (Ch 06)

**Non-functional requirements** — **Execution qualities** (usability, efficiency, correctness, reliability) vs. **evaluation qualities** (maintainability, testability, flexibility) (Ch 13)

**Object Calisthenics** — Jeff Bay's nine constraints, applied during the refactor step (Ch 14)

**Object Stereotypes** — RDD's six roles: Information Holder, Structurer, Service Provider, Coordinator, Controller, Interfacer (Ch 13)

**Object-orientation abusers** — Code smell category: procedural code in OO clothing; `switch`-on-type (Ch 15)

**Opportunity Cost** — The benefit forgone by choosing one design path over another (Ch 20)

**Page Object** — Declarative indirection between E2E test specs and HTML; kills brittle selector-based tests (Ch 11)

**Primitive Obsession** — Passing raw strings/numbers that carry domain meaning. Fix: Value Objects (Ch 14)

**Programming by Wishful Thinking** — Write code as if the ideal methods already exist; let usage define the interface (Ch 18, Ch 12, Ch 22)

**Result Verification** — Black-box verification of data in → data out (Ch 22)

**Ripple** — Complexity symptom: a simple change forces modifications elsewhere. Signals under-abstraction (Ch 01)

**Rule of Three** — Only remove duplication on the third occurrence. "A little duplication is 10x better than a wrong abstraction" (Ch 12, Ch 18)

**Screaming Architecture** — The project structure should scream the domain, not the framework (Ch 03)

**Service Provider (stereotype)** — RDD: passive, specialized computation. Stable utilities, Domain Services (pure fabrications), cross-cutting concerns (Ch 13)

**Seven Stages of Action** — Norman: goal, plan, specify, perform, perceive, interpret, compare (Ch 02)

**Shotgun Surgery** — Change-preventer smell: one change requires edits across many files (Ch 15)

**Signifier** — Semiotics: the perceivable thing (signifier) producing mental content (signified). Cheap way to make affordances discoverable (Ch 02)

**Software Craftsmanship** — "Professionalism in software development." A mindset of responsibility, pride, and pragmatism (Ch 01)

**Spike** — Time-boxed research to produce a proper estimate under uncertainty (Ch 08)

**State Verification** — Verifying internal state after a sequence of actions; the key variable is *time* (Ch 22)

**Step-down Principle** — Maintain a consistent level of abstraction within a method; descend toward details (Ch 05)

**Strategic vs. Tactical programming** — Strategic: 50/50 split between customer and maintainer. Tactical: brute force, 0% maintainability — for spikes only (Ch 01)

**Structurer (stereotype)** — RDD: creates and maintains relationships; protects invariants (Ch 13)

**Structural typing** — Type compatibility determined by actual structure. TypeScript's model (Ch 06)

**Subdomain** — A **logical** boundary within the problem space. Types: **core**, **supporting**, **generic** (Ch 21)

**Subject Under Test (SUT)** — The specific object you're testing (Ch 11)

**Subject Verification** — The essential of testing: isolation/boundaries + verification (Ch 22)

**Tell, Don't Ask** — Tell the object to perform the task rather than extracting data to manipulate externally (Ch 18)

**Thin interface** — Ousterhout: choose the minimal public surface. Fowler's "Minimal Interface." A constraint on limited working memory (Ch 02)

**Transformation Priority Premise (TPP)** — Robert C. Martin: 12 ordered transformations constraining how you go from red to green (Ch 12)

**Triangulation** — Adding tests to sculpt a general solution; carving out degrees of freedom (Ch 12)

**Ubiquitous Language** — DDD: the shared language of domain concepts, embedded directly in code (Ch 21)

**Use Case** — The atomic unit of value; a command or query. Synonym for feature. Realized as the Use Case pattern (Ch 08)

**Value Object** — No identity; an attribute of an Entity; compared by structural equality (Ch 21)

**Vertical slice** — A feature cut end-to-end through every architectural layer (Ch 03, Ch 20)

**Walking Skeleton** — "Tracer Bullets" (*Pragmatic Programmer*): a thin end-to-end slice validating the whole architecture deploys and works (Ch 11, Ch 20)

**YAGNI** — You Aren't Gonna Need It. In DDD, YAGNI violations produce oversized aggregates (Ch 18)
