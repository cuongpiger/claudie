# Chapter 11: Testing Strategies, The Walking Skeleton & Pair Programming *(book ch. 25–27)*

## Core Idea
The **core vs. infrastructure** distinction decides your testing strategy: *"a unit test is a test that tests the contract of a class or function that is **completely core code, never infrastructure code**."* Before any of that, you build a **walking skeleton** — a thin end-to-end slice proving the whole architecture deploys and works. **Pair programming** is the shortest feedback loop of all.

---

## Part A — Testing Strategies

### Test types

- **Unit** — Michael Feathers' definition by negation: it **doesn't** talk to a database or file system, **doesn't** communicate over the network, **doesn't** need to run at the same time as other tests, and **doesn't** require special setup.
  - Stemmler's simplification: **a unit test tests the contract of a class or function that is completely core code, never infrastructure code.**
  - **Note**: a unit test *can* span multiple classes. The object you care about is the **Subject Under Test (SUT)**.
- **Integration** — the contested one. Kent C. Dodds: *"confirms that several units of code work together in harmony"* — Stemmler finds this too close to a unit test. His definition: **crosses architectural boundaries into infrastructure**.
- **End-to-end** — the whole system, real infrastructure.
- **Acceptance** — a *scope-independent* category: an acceptance test can be written as a unit, integration, or E2E test.

### What needs testing — by concern

| Concern | What you actually verify |
|---|---|
| **Features (queries)** | That you can **see the data** · that the data is **correct** (created two posts → see both) · **security and scope** (do I have permission? does this user own it? how much can public users see?) |
| **Features (commands)** | **Fail when they should fail** (invalid email → `InvalidDetailsError`) · **succeed when they should** · **adhere to security rules** · **actually invoke the state-changing calls with the correct arguments** (does it attempt to send the email, bill the card?) |
| **Core code** | Pure logic — Value Objects, Entities, domain services |
| **Infrastructure** | Database, GraphQL/REST API, shared infrastructural components, external APIs/integrations |

### The five-part testing strategy for a decoupled application

1. **Unit test all domain layer code** — utilities, middleware, helpers, **Value Objects, Entities**, and other domain code. *"You should seldom need mocks (maybe stubs sparingly) because this code should be pure, cohesive, and loosely coupled."*
2. **Use case tests: acceptance test application layer features as unit tests** — the features themselves, exercised at the Use Case level.
3. **Integration test input adapters** — incoming boundary contracts.
4. **Integration test outgoing adapters** — outgoing boundary contracts.
5. **End-to-end test for queries and additional confidence.**

> **The diagnostic**: needing lots of mocks to unit test domain code means the domain code isn't pure — that's a design problem, not a testing problem.

---

## Part B — The Walking Skeleton

**Definition** (first called **Tracer Bullets** in *The Pragmatic Programmer*): *a thin slice of functionality that executes from end-to-end, threading all the way through each of the main architectural components.*

**What it validates**: that your choices of **packages, libraries, vendors, and tooling actually work** — and that you can **build, test, and deploy** that functionality in a **production-like environment**.

### Why end-to-end?
> *"But it worked on **my** machine!"*

Running tests against local infrastructure is a good start, but **the only way to prove the system works is to try it end-to-end**. That means **reducing mocking and stubbing as much as possible** — unless running the test costs money (e.g. a premium stock-market data API).

**Three benefits**:
1. Build out the initial **front-end testing architecture**
2. Build out the initial **back-end testing architecture**
3. **Most importantly — expose uncertainty early** by building, testing, and deploying early

**What it catches early**: CORS errors, database security settings on a production server, ORM connectivity. *"You do not want to be in a position right before the deadline where you're fumbling with database security settings so that your ORM can connect."*

### How to build one
- **Small steps.** Don't build the whole architecture in one go — *"there's just way too much to mentally account for"* (dependencies, layout decisions, database, seeders, migrations, dev environment). Slice it in your **Iteration Planning Meeting** for the initial sprint. **It's OK for this to take a few days**, especially with new technology.
- **Choose the simplest scenario.** For a StudySpots app with `ViewAllSpots`, `SubmitSpot`, `EditSpot`, `RateSpot`, `CreateAccount` — pick **`ViewAllSpots`**, *"solely because we can come up with a simple scenario to test it."* Seed a few spots in the database, verify they appear on screen. In a CQRS architecture that cuts through the **read** path.
- **Start with a failing end-to-end test**, then build the backend bare minimum.

### Worked Example — Page Objects for declarative E2E tests

**The problem**: developers write E2E tests that refer to page internals (HTML elements), so **changing the UI breaks the tests** — brittle tests prone to ripple.

**The solution**: *"just like interfaces at the class level, and just like GraphQL at the architectural level — add a layer of indirection between your test specifications and your HTML."* That's the **Page Object pattern**: declarative **expressions** instead of imperative **statements**.

```typescript
/// <reference types="cypress" />
import { And, Given, Then, When } from "cypress-cucumber-preprocessor/steps";
import { MapPage } from "../../pageObjects/mapPage/mapPage";

// Page object pattern
let mapPage = new MapPage();

/**
 * Scenario: View all study spots in Toronto by default
 */
Given(`I'm on the map page`, () => {
  mapPage.load();
});

And(`location is disabled`, () => {
  // ...
});
```
- **What it demonstrates**: the test speaks in page-level operations, never in selectors. The Page Object is a **contract specifying how elements get added to the UI** — the same indirection principle as DIP, one layer up.

---

## Part C — Pair Programming

**Two roles**:
- **Driver** — actually codes. Hands on keyboard and mouse.
- **Navigator** — reviews the driver's work and thinks **strategically**. Asks: *"Are there any mistakes? Could we design this better? Will the solution require changes elsewhere? Could we make that more understandable?"*

### Three switching techniques

| Technique | How it works |
|---|---|
| **Using a clock** | Chess clock or pomodoro timer. When it expires, wrap up the thought and switch. **The simplest way to start.** |
| **Ping pong / popcorn** | Pairs alternate writing tests and making them pass: A writes a failing test → B implements it → B writes the next failing test → A implements → … |
| **Strong-style pairing** | *"For an idea to go into the computer, it needs to pass through someone else's hands"* — **Llewellyn Falco** |

**Strong-style rules** (requires high maturity and TDD experience):
- The driver may **only ask questions to understand what needs to be done**
- The driver **may not question *why*** until the idea is fully expressed — i.e. until the navigator says it's implemented and they're open to suggestions
- The driver tells the navigator when they're **ready for the next instruction**

*"Most effective when the navigator understands the entire picture of how to implement a feature."* The driver isn't concerned with learning the ideas until they're implementing them. **Sometimes all you have to do is ask for a small, temporary window of trust.**

### Output and cadence
- **For each passing test, make a commit.** When appropriate (finishing a feature), create a **pull request**.
- **How often?** No universal answer. Some companies pair ~95% of the time; some only mornings; some 3 of 5 days. Brad Pederson (Stats Perform): *"once people have become used to the practice over a two- or three-week span, the majority do prefer pairing."*

### Four considerations
1. **Power dynamics** — if you're the senior, it's mostly on you to make your partner comfortable. Be patient, encouraging, **stick to the timer**.
2. **Maturity** — keeping the conversation on track, following rules, being respectful. *"Leave ego at home."*
3. **Let the timer remind you** — **don't rely on your partner to say it's time to switch**; they may not feel comfortable asking.
4. **Allow time for individual work** — Sandro Mancuso notes pairing can be exhausting, and sometimes you want to explore a half-formed idea before you're ready to share it.

**What a good pair looks like** (Mike Tecson, Club Labs): they *"strike the right balance between communicating solutions, requesting feedback and driving forward with the task without becoming too chatty. They are socially aware… first and foremost engineers, but they also know how to pick up on social cues."* And they *"take initiative and strive to learn — they do not rely on their partner to drive solutions."*

## Anti-patterns
- **Calling a test that touches infrastructure a unit test** — it's an integration test by definition.
- **Heavy mocking to unit test domain code** — the domain code isn't pure enough.
- **E2E tests referencing HTML selectors directly** — brittle, ripple-prone. Use Page Objects.
- **Mocking away infrastructure in the walking skeleton** — defeats its only purpose.
- **Building the whole architecture in one go** — too much to hold in your head.
- **Deferring deployment until the end** — CORS, DB security, and ORM connectivity problems surface at the worst possible time.
- **Relying on your partner to call the role switch** — they often won't. Use the timer.
- **Pairing 100% of the time with no solo work** — it's genuinely exhausting.

## Key Takeaways
1. **Core vs. infrastructure is the line that defines every test type.**
2. **Test commands for four things**: correct failure, correct success, security, and *the right state-changing calls with the right arguments*.
3. **Acceptance tests belong at the use case (application layer) level, written as unit tests** — that's Stemmler's default.
4. **The walking skeleton's job is exposing uncertainty early**, not delivering value.
5. **Pick the simplest testable scenario** for the skeleton, not the most important feature.
6. **Page Objects are indirection for the UI** — the same reasoning as interfaces and DIP.
7. **Commit per passing test** when pairing.
8. **Use a timer** — it removes the social cost of asking to switch.
9. **Strong-style pairing needs trust**; ask for a temporary window of it.

## Connects To
- **Ch 22 (Advanced TDD)** — the three verification types, contract tests, builders and fixtures.
- **Ch 09 (Acceptance Tests)** — Given-When-Then and the Cypress/cucumber tooling used here.
- **Ch 10 (OO Architecture)** — core vs. infrastructure originates there.
- **Ch 20 (Architecture)** — the Walking Skeleton also appears as an economic/strategic principle.
- **Ch 12 (TDD Workflow)** — Double Loop TDD, and why TDD *starts with architecture*.
- **Ch 01 (Complexity)** — pair programming as the earliest feedback loop.
- **Ch 08 (Planning)** — iteration zero and walking the skeleton in release planning.

## References
- *The Pragmatic Programmer* — Tracer Bullets
- *Working Effectively with Legacy Code* — Michael Feathers (the unit test definition)
- *Growing Object-Oriented Software, Guided by Tests* — Freeman & Pryce (walking skeleton)
- Llewellyn Falco — *Llewellyn's Strong-Style Pairing*
- *Agile Technical Practices Distilled* — Marco Consolaro & Pedro M. Santos
