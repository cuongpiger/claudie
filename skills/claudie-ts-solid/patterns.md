# Patterns & Techniques — Stemmler's *SOLID*

Concrete, repeatable techniques from the book. For *when to reach for which*, see [cheatsheet.md](cheatsheet.md).

---

## Private Constructor + Static Factory Method
**When to use**: any domain object with invariants — Entities, Value Objects, anything that must never exist in an invalid state.
**How**: make the constructor `private`; expose `static create(props)` that validates and returns the instance (or an `Either`).
**Trade-offs**: slightly more ceremony; in exchange, `new User(...)` becomes impossible and invariants are guaranteed at birth. *(Ch 06, Ch 16, Ch 21)*

## The Either Type
**When to use**: any use case with one happy path and several *expected* failure modes.
**How**: `type Either<S,F> = Success<S,F> | Failure<S,F>`, with `isSuccess()`/`isFailure()` returning **type predicates** (`this is Success<S,F>`). Model domain errors as **classes** implementing `DomainError` so message construction is encapsulated. Declare the use case's return type as an `Either` union of one success and all failures.
**Trade-offs**: more types to declare; in exchange every failure is discoverable from the signature and no `try/catch` or string-matching is needed. *(Ch 07)*

## Wrap Exceptions as ApplicationError
**When to use**: at every I/O boundary (DB, third-party API, filesystem).
**How**: wrap the call in `try/catch`; in the catch, `return failure(new DatabaseError(err))`. Add a generic `ApplicationError` to the use case's failure union.
**Trade-offs**: generalizing hides which infrastructure failed from the consumer — deliberate, for security. Keep the detail for your logs. *(Ch 07)*

## Composition Root (as Singleton)
**When to use**: you need exactly one instance of config, caches, and key services, and want to stop scattering `new Service()` calls.
**How**: a class with a private constructor and `static getInstance()`, exposing `readonly` wired dependencies.
**Trade-offs**: can become a God object; still a hidden global if misused; large apps may want a real DI container or multiple roots.
**The killer variant**: `CompositionRoot.create('test')` — a **TestCompositionRoot** that constructs an entire test version of the application. *(Ch 16, Ch 22)*

## Repository
**When to use**: whenever renaming a DB column would force edits in many controllers.
**How**: define the interface in the **domain** layer; implement it in infrastructure; inject at the composition root.
**Trade-offs**: an extra layer; in exchange LSP lets you swap `InMemoryUserRepo` → `PostgresUserRepo` → `MongoUserRepo` freely. *(Ch 16, Ch 21)*

## Builder (for test objects)
**When to use**: test setup for objects with many optional fields or deep relationships. Also the fix for any constructor with 7–8 parameters.
**How**: fluent chaining with a naming DSL — **`with`** for fields/values, **`from`/`and`** for relationships, **`build`** to construct. Build *backwards* from the target model, following the **Data Model Tree**.
```typescript
enrolmentResult = await studentEnrolmentBuilder
  .fromStudent(studentBuilder.withName('Johnny').withRandomEmail())
  .andClassroom(classroomBuilder.withClassName('Math'))
  .build();
```
**Trade-offs**: more files to maintain; overkill for 2–3 field objects. *(Ch 16, Ch 22)*

## Page Object
**When to use**: E2E tests that would otherwise reference HTML selectors.
**How**: a class exposing page-level operations (`mapPage.load()`); tests never touch the DOM directly. Same indirection reasoning as interfaces at class level and GraphQL at architectural level.
**Trade-offs**: an extra abstraction to maintain — but it's what stops UI changes from breaking every test. *(Ch 11)*

## Replace Conditional with Polymorphism
**When to use**: a `switch`/`if-else` on a type field controlling behavior.
**How**: abstract base class (or interface) + one subclass per case, each implementing the behavior.
**Trade-offs**: more classes. In exchange you satisfy OCP — adding a variant means adding a class, not editing a switch. *(Ch 15, Ch 17)*

## Consolidate Scattered Rules behind a Role Interface
**When to use**: **Shotgun Surgery** — the same conditional (role checks, permission checks) repeated across files.
**How**: define a role interface (`PermissionChecker`), one implementation per variant, and a single factory that resolves it. The one remaining `switch` lives in the factory — where creational decisions belong.
**Trade-offs**: a small class explosion; in exchange, a new role touches exactly two places. *(Ch 15)*

## Domain Events for Cross-Subdomain Side Effects
**When to use**: a controller is accumulating `if/else` for side effects that belong to *other* subdomains (referrals, notifications, billing).
**How**: the Aggregate dispatches a Domain Event; handlers in other subdomains subscribe. The originating subdomain never learns they exist.
**Trade-offs**: indirection makes flow harder to trace; requires dispatch infrastructure (e.g. from ORM hooks after transaction commit). *(Ch 21, Ch 18)*

## Value Objects (Wrap All Primitives)
**When to use**: any primitive carrying domain meaning — `Email`, `Password`, `Money`, `UserID`.
**How**: a class with validation in the constructor (or static factory) and domain behavior (`money.add(other)` rejecting currency mismatches).
**Trade-offs**: more types. In exchange the type signature enforces the rules, and `createUser("", "")` stops compiling. *(Ch 06, Ch 14, Ch 21)*

## First-Class Collections
**When to use**: the same `.filter()`/`.map()` over a domain array appears in more than one place.
**How**: a class wrapping the array, exposing domain-named methods — `tasks.active()`, `orders.paidOnly()`, `players.activeUsers()`.
**Trade-offs**: one more class; in exchange collection logic is cohesive and duplication disappears. *(Ch 14)*

## Guard Clauses (Design by Contract)
**When to use**: any method with preconditions.
**How**: explicit `throw`s at the top of the method for each precondition; the success path flows unindented afterward. Eliminates `else`.
**Trade-offs**: none meaningful — this is strictly better than nested conditionals plus doc comments. *(Ch 18, Ch 14)*

## Introduce Parameter Object
**When to use**: long parameter lists, or **Data Clumps** (the same group of parameters travelling together).
**How**: define an interface (`OrderRequest`, `UserProps`) and pass one strictly-typed object.
**Trade-offs**: an extra type. Also solves the "blob parameter" naming smell. *(Ch 15, Ch 04)*

## Writing Tests Backwards (Assert → Act → Arrange)
**When to use**: you're stuck on how to express or verify a behavior.
**How**: write the **assert** first (turn the requirement into declarative code), then the **act** that makes it true, then the **arrange**. Read the finished test top-down.
**Trade-offs**: feels backwards at first. In exchange you avoid unnecessary abstractions, ceremony, and state. *(Ch 12)*

## Transformation Priority Premise
**When to use**: every red → green step.
**How**: pick the *simplest applicable* transformation from the ordered list (nil → constant → constant+ → scalar → statements → conditional → array → container → tail recursion → loop → recursion → function). Ask "can I do this with a scalar? No? What about a conditional?"
**Trade-offs**: slower than the obvious implementation; in exchange the design emerges rather than being guessed. Also usable in reverse when refactoring. *(Ch 12)*

## Triangulation
**When to use**: you've made a test pass with a constant or special case and need a general solution.
**How**: add another example. Think in **degrees of freedom** — enumerate the capabilities and don't stop until each is covered.
**Trade-offs**: more tests; that's the point. *(Ch 12)*

## Contract Tests (Outgoing/Incoming Adapter Tests)
**When to use**: you use mocks in unit tests and want a basis for believing production works.
**How**: one shared test suite run against **every** implementation of a port — the fake and the real one. Transitivity does the rest.
**Trade-offs**: needs real infrastructure to run; may cost money — run periodically if so. *(Ch 22)*

## Characterization Testing (legacy code)
**When to use**: inherited code with no tests, before any change.
**How**: write E2E tests capturing current behavior *after the fact*. Use the **4-Tier Acceptance Test Architecture**: Gherkin spec → executable spec (`jest-cucumber` + `supertest`) → test rig (builders, `resetDatabase()`) → system.
**Trade-offs**: locks in bugs along with behavior — that's acceptable; you're buying the ability to change safely. *(Ch 22)*

## Test Idempotency
**When to use**: any test that writes to a shared store.
**How**: **randomness** (`faker.lorem.word() + faker.datatype.uuid()`) or **reset & reconstruct** (`resetDatabase()` then rebuild).
**Trade-offs**: randomness is fast but makes failures less reproducible; reset is slower but deterministic. *(Ch 22)*

## Feature-Driven Folder Structure
**When to use**: any project past a single developer.
**How**: `src/modules/<domain>/useCases/<useCase>/` containing the UseCase, Errors, Controller, DTO, **and the test**. Everything else goes in `shared/`.
**Trade-offs**: fights framework conventions — tuck framework code into `shared/infrastructure/<framework>/`. *(Ch 03)*

## Documenting a Story with Pseudocode
**When to use**: after interviewing a domain expert, before writing code.
**How**: three artifacts — **Feature Summary** (namespace, input data, dependencies, success/failure outputs, trigger, side effects), **Domain Primitives** (types, constraints, state machines), and the **Use Case Algorithm** (steps then sub-steps).
**Trade-offs**: cheaper than UML, readable by the customer, and it surfaces edge cases Event Storming missed. *(Ch 08)*

## Given-When-Then Feature Tests
**When to use**: acceptance tests — the preferred format.
**How**: a `.feature` Gherkin file in the use case folder + `jest-cucumber` consuming it. Write acceptance tests as **coarse-grained unit tests** at the application layer.
**Trade-offs**: an extra file and library; in exchange the spec is a first-class artifact the customer can own. *(Ch 09)*

## Walking Skeleton
**When to use**: at the very start of a project, before feature work.
**How**: pick the **simplest testable** scenario; write a failing E2E test; build the bare minimum through every layer; deploy to a production-like environment. Minimize mocking.
**Trade-offs**: delivers no business value; can take a few days. In exchange it exposes deployment, CORS, and connection issues before the deadline, and leaves you a test rig. *(Ch 11, Ch 20)*

## Strong-Style Pairing
**When to use**: knowledge transfer when the navigator understands the whole feature.
**How**: "For an idea to go into the computer, it must pass through someone else's hands." The driver may only ask clarifying questions and may not challenge the *why* until the idea is fully expressed.
**Trade-offs**: requires real trust and TDD maturity. Ask for a small, temporary window of trust to start. *(Ch 11)*
