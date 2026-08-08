# Chapter 09: Acceptance Tests & BDD *(book ch. 22)*

## Core Idea
Acceptance Tests **contractualize** the success and failure scenarios of a story. The critical insight XP failed to communicate for years: **writing the tests and automating them are two entirely different tasks done by two entirely different roles** — the **customer writes them**, the **developer automates them**.

## Frameworks Introduced

- **What Acceptance Tests are for** — four jobs:
  1. Get the customer to **commit to and agree upon** the success criteria for a feature
  2. **Mitigate arguments** like *"you said the app was going to do X, Y, Z — we talked about this"*
  3. **Catch features when they regress**
  4. **Prove with certainty** that you've done what you agreed to do

- **The three-part structure of every scenario**: **Preconditions → Actions → Postconditions.**
  - Directly mirrors the "one happy path, multiple sad paths" shape: `CreateUser` passes with a valid email and password, and fails with `AccountAlreadyExists` or `InvalidEmailOrPassword`.

- **BDD (Behavior-Driven Development)** — Dan North, 2006, described as *"TDD done right."* A way to write tests (unit, integration, E2E — any kind) that focus on **behavior, not implementation details**.
  ```typescript
  // ❌ Not BDD — 'data' and 'arrays' are technical concerns, meaningless to the domain,
  //    and "Test save data into an array" isn't even a proper sentence
  describe('calendar', () => {
    test('save data into an array', () => { });
  });

  // ✅ BDD — speaks about observable behavior
  describe('calendar', () => {
    it('contains all of the days for the month', () => { });
  });
  ```
  > *Some people think of BDD as the amalgamation of **DDD + TDD**.*

- **Dan North's test-writing principles**:
  - **Test names should be sentences**
  - Prefer a **simple sentence format** to keep tests focused
  - **Expressive names help when tests fail**
  - **"Behavior" is a more useful word than "test"**
  - Prefer testing **behaviour** instead of the implementation
  - **Evolve a design by probing for the next important behavior**

- **The story → scenario pipeline**:
  ```
  As a    [X — person or role benefiting from the feature]
  I want  [Y — the feature]
  So that [Z — benefit or value of the feature]
  ```
  becomes
  ```
  Given some initial context (all the givens)
  When an event occurs
  Then ensure some outcomes
  ```
  *"This is always important to know, even if it's not written down. But writing it down does help to single in on the valuable work to be done."*

## The Three Formats — ranked

### Format #1: Single-line tests ❌ *(inadequate for acceptance tests)*
```typescript
describe('login', () => {
  it(`takes me to the dashboard page after I login`, () => { });
});
```
**Fine** for evolving a design with unit or integration tests. **Clumsy** for acceptance tests: *"Notice that this test doesn't say anything about the **Givens**? It is very easy to write bugs if we're not explicit about how we set up the state of the world and what the postconditions are."*

### Format #2: Given-When-Then style Jest tests 🟡 *(works, but awkward)*
```typescript
describe('Feature: Login', () => {
  describe("Scenario: Successful login", () => {
    describe("Given I've previously created an account", () => {
      describe("When I attempt to login", () => {
        test("I should login and see the dashboard page", () => { });
      });
    });
  });

  describe("Scenario: Account doesn't exist", () => { /* ... */ });
});
```
Genuinely expresses Given/When/Then — but **the formal specification is trapped inside Jest strings**, so the customer can't own it.

### Format #3: Given-When-Then feature tests ⭐ *(preferred)*
Use **`jest-cucumber`** (Ben Compton) so Jest tests **consume real Gherkin feature files** and validate them against the implementation. The spec becomes a first-class artifact the customer can read and own.

**The feature file** — lives in the use case folder:
```gherkin
# useCases/syncTasksToCalendar/SyncTasksToCalendar.feature
Feature: Sync Notion tasks to Google Calendar
  Scenario: Sync new tasks
    Given there are tasks in my tasks database
    And they don't exist in my calendar
    When I sync my tasks database to my calendar
    Then I should see them in my calendar
```

**The test implementation:**
```typescript
// useCases/syncTasksToCalendar/SyncTasksToCalendar.spec.ts
import { defineFeature, loadFeature } from 'jest-cucumber';
import path from 'path';
import { SyncTasksToCalendar } from './SyncTasksToCalendar';
import { TasksDatabaseBuilder, TasksDatabaseSpy } from '../../testUtils/tasksDatabaseBuilder';
import { CalendarRepoBuilder } from '../../testUtils/calendarRepoBuilder';
import { FakeClock } from '../../testUtils/fakeClock';
import faker from 'faker';

const feature = loadFeature(path.join(__dirname, './SyncTasksToCalendar.feature'));
// defineFeature(feature, test => { given(...) / when(...) / then(...) })
```
- **Note the test utilities**: `TasksDatabaseBuilder`, `CalendarRepoBuilder`, `FakeClock`, `faker` — **builders and fixtures**, exactly the technique developed in ch. 22.
- **Note the assumption**: acceptance tests are written as **coarse-grained unit tests**.

## Worked Example — Notion → Google Calendar sync

**The story:**
> **As a** Notion user, **I wanted** to sync my tasks to my Google Calendar **so that** I could be notified when events take place and do all of my scheduling and task management from one place.

**The scenario:**
```gherkin
Feature: Sync Notion tasks to Google Calendar
  Scenario: Syncing new tasks
    Given there are tasks in my tasks database
    And they don't exist in my calendar
    When I sync my tasks database to my calendar
    Then I should see them in my calendar
```

The `And` clause is the important detail — it makes the second precondition explicit rather than assumed. That's precisely what Format #1 loses.

## Why acceptance testing was hard for 20 years

Four causes:
1. **Responsibilities** — XP said "the customer writes the tests" but never separated *writing* from *automating*.
2. **Tooling** — FitNesse, SpecFlow, Cucumber each introduced their own **formal language**. *"Many early-2000s developers found it hard to get customers to sit down and learn a new formal language."*
   > *"How would you feel if you took your car into the shop and had to read docs or take a class to place a work order? That's silly. Just bad UX."*
   **Customers want to describe the feature in their native language.**
3. **Failure to gain ubiquity** — the tools sat "like the least delicious bowl of chips at a party."
4. **The need for TDD best practices.**

## Tooling reference

| Tool | Use for |
|---|---|
| **Jest** | Default for unit + integration. Works well for acceptance tests written as **coarse-grained unit tests** (Stemmler's preferred approach). Add `ts-jest` for TypeScript |
| **jest-cucumber** | Given-When-Then support in Jest — consumes real `.feature` files |
| **Cypress.io** | E2E tests. Add `cypress-cucumber-preprocessor` for Gherkin |
| **React Testing Library** | Promotes focus on behavior instead of implementation details |

## Anti-patterns
- **Test names describing technical concerns** (`'save data into an array'`) — meaningless to the domain and not a sentence.
- **Single-line tests as acceptance tests** — no explicit Givens means bugs from unstated setup.
- **The specification living only in Jest strings** — the customer can't read, review, or own it.
- **Expecting the customer to learn a formal DSL** — bad UX; it's why 2000s-era acceptance tooling failed.
- **Developers writing the acceptance criteria themselves** — collapses the division of responsibilities the whole practice rests on.
- **Testing *how* behavior is realized** — acceptance tests care only about *what* should be realized.

## Key Takeaways
1. **Customer writes, developer automates.** The single most important distinction in the chapter.
2. **Acceptance tests are a contract** — that's what makes "you said it would do X" arguments go away.
3. **Prefer Format #3**: Gherkin `.feature` files consumed by `jest-cucumber`, colocated in the use case folder.
4. **Be explicit about the Givens** — unstated preconditions are where acceptance-test bugs live.
5. **Test names are sentences** describing behavior, not implementation.
6. **Write acceptance tests as coarse-grained unit tests** by default; go to E2E only when the strategy calls for it.
7. **BDD ≈ DDD + TDD** — domain language driving test design.

## Connects To
- **Ch 08 (Features & Stories)** — the story is the input; the acceptance test is where it stops being negotiable.
- **Ch 22 (Advanced TDD)** — the 4-Tier Acceptance Test Architecture, builders, fixtures, and idempotency that make these tests work.
- **Ch 11 (Testing Strategies)** — deciding at which scope to write acceptance tests.
- **Ch 07 (Errors)** — the failure scenarios you enumerate are the same union your `Either` returns.
- **Ch 03 (Organizing Things)** — feature files live in the use case folder alongside the code.
- **Ch 12 (TDD)** — Double Loop TDD wraps the unit loop inside the acceptance loop.

## References
- Dan North — *Introducing BDD* (2006)
- [jest-cucumber](https://github.com/bencompton/jest-cucumber) — Ben Compton
- Cypress.io · cypress-cucumber-preprocessor · React Testing Library
