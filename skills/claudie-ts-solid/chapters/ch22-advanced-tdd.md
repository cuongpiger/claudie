# Chapter 22: Advanced TDD — Verification, Integration & Contract Tests, Legacy Code, Fixtures & Builders *(book ch. 71–75)*

## Core Idea
Every test is **Subject Verification**: draw an isolation boundary around the subject, then verify. There are exactly **three verification methods** (Result, State, Communication), and knowing which to reach for is most of the skill. **Contract tests** are what make mocking honest. **Builders** following the **Data Model Tree** are what make non-trivial test setup tractable.

---

## Part A — The Three Types of Verification

**Systems thinking** frames it: a system has a **Model/Process** (the logic under test), an **Input**, and an **Output**. Even complex systems are understandable if you focus on how data flows from input to output.

**Subject Verification** has two aspects you must master, regardless of whether you're testing a React component, a database connection, an external service adapter, or the whole app E2E:
1. **Isolation/Boundaries** — create clear boundaries around the subject.
2. **Verification** — confirm the subject behaves as expected.

| Method | Verifies | Use when | Example |
|---|---|---|---|
| **1. Result Verification** | Data in → data out. The subject is a **black box** | Pure functions, simple pipelines, E2E HTTP responses | `expect(isANumber(7)).toBeTruthy()` |
| **2. State Verification** | The subject's **internal state** after a sequence of actions | Objects encapsulating data + behavior: game engines, carts, DB-backed services. **The key here is *time*** | `game.move('upperLeft'); expect(game.getCurrentPlayerTurn()).toEqual('black')` |
| **3. Communication Verification** | Whether the subject **attempted** to interact with an external dependency, and how | **Indirect inputs & outputs** — DB, external API, message queue | `expect(mockUserRepo.saveUser.getCalls()).toEqual(0)` |

**Communication Verification** lets you check two things: **whether the call was made or not**, and **the arguments passed**. Example: for `makePayment` where everything is correct but you don't want to hit the real payment service, you verify that you at least *attempted* the call.

```typescript
// Result Verification + State Verification, together
const response = await request(app).get('/status');
expect(response.status).toBe(200);              // result verification
expect(response.body.message).toEqual('OK');
```

**Worked example — all three in one test:**
```typescript
let composition  = CompositionRoot.create('test');
let app          = composition.getApp();
let mockUserRepo = composition.getUserRepo();

it('should fail to create the user if they already exist', async () => {
  // Update the state of the world ahead of time (a fixture/builder)
  await new UserRepoBuilder(mockUserRepo)
    .withExistingUser(new UserBuilder().withEmail('john@example.com').build())
    .build();

  const response = await app.createUser('john@example.com');

  expect(response.isSuccess()).toBeFalsy();               // Result Verification
  expect(mockUserRepo.saveUser.getCalls()).toEqual(0);    // Communication Verification
});
```
Note the `CompositionRoot.create('test')` — the TestCompositionRoot technique from the design-patterns chapter, in production use.

---

## Part B — High Value Integration Tests & Contract Tests

**What is an integration test?** Not by negation ("not unit, not E2E") but by the **Core vs. Infrastructure** philosophy:

> **An integration test is a test that crosses architectural boundaries** — it does in fact involve **infrastructure code**.

Anything touching the network or the filesystem qualifies. Typically: your DB connection, and connections to external services (payments, queues, notifications).

**High Value Integration Test**: start from the service (application layer or the outer boundary of core code), draw the boundary around the service **and all infrastructure involved in executing the feature**. It's the same shape as a high-value unit test — except the infrastructure is real instead of mocked.

> *"Write tests. Not too many. Mostly integration."* — Guillermo Rauch

**Advantage**: **more confidence** than high-value unit tests, because they use **real infrastructure** — not the in-memory or SQLite stand-ins you use locally.

**Three disadvantages** (benefits still outweigh):
1. **Slower.** But: Stemmler's anecdote — weeks of high-value unit tests against SQLite, then switching to real MySQL and *nothing worked* due to faulty configuration. Integration testing catches that immediately.
2. **You might spend money.** Options: use a sandbox account; create a "test instance"; incur the cost but run integration tests **periodically**; leave it out.
3. **You must set up/manage infrastructure.** For a frontend developer, **the entire backend is infrastructural**. Options: host the backend as test infrastructure somewhere, or containerize the whole backend with Docker and run it locally.

### Contract tests — the transitivity argument *(the key idea)*

The skeptic's question: *"If we're using mocks to mock out infrastructure, how can we know things will work in production?"*

> *"Honestly, if you mock out your infrastructure, you have **no right** to believe things will go well in production."*

The fix uses mathematical **transitivity** — *if a = b and b = c, then a = c*:
- You have a **High Value Unit Test** using a **mock** database, **and**
- You have a **contract test** verifying that **all implementations** of the database contract work (the mock one **and** the production one),
- **Therefore** the production version should work too.

Two forms:
- **Outgoing Adapter Test (contract)** — verifies every implementation of an outgoing port satisfies the same contract.
- **Incoming Adapter Test (contract)** — the same idea on the inbound side.

Both are available to you *because* Hexagonal Architecture decoupled you from the core.

---

## Part C — Legacy Code: E2E Characterization Testing

**Characterization test**: *a test written for existing code to capture and express its current behavior — **after the fact***. You're documenting the existing "character" of the system. Without them, any modification could silently break crucial functionality.

**Approach legacy code with high value tests first** — usually **E2E**, which simulate real user interactions and give the most confidence.

### The 4-Tier Acceptance Test Architecture

Think of the testing rig as a layered cake:

1. **Acceptance Test Specification** — the user story in plain language (Gherkin):
   ```gherkin
   Feature: Submit an Assignment
       As a student
       I want to submit an assignment
       So that I can get a grade

       Scenario: Successfully submit an assignment
           Given I was assigned an assignment
           When I submit the assignment
           Then it should be marked as submitted

       Scenario: Fail to submit an assignment twice
           Given I have already submitted an assignment
           When I try to submit it again
           Then I should see an error message
   ```
2. **Executable Specification** — translates the criteria into executable code, typically **`jest-cucumber`** + `supertest` + fixture builders.
3. **(Driver / test rig layer)** — resets, builders, fixtures.
4. **(System under test)** — the real app.

---

## Part D — Idempotency Techniques

Tests must be re-runnable. Stemmler frames setup in terms of **direct inputs & outputs** vs. **indirect inputs & outputs** — where *indirect inputs = fixtures = **the state of the world***.

| Technique | How | When |
|---|---|---|
| **#1 Randomness** | Generate unique data per run — `faker.lorem.word() + faker.datatype.uuid()`. "If your hash is large enough, you shouldn't have to worry about test collisions." | Cheap, fast; good when you only need uniqueness |
| **#2 Resetting & reconstructing** | `resetDatabase()` then rebuild the required state | When you need a known, clean world |

```typescript
given("I want to create a class room", () => {
  const uniqueName = faker.lorem.word() + faker.datatype.uuid();
  requestBody = { name: uniqueName };
});
```

---

## Part E — Fixtures & Builders *(the highest-leverage technique here)*

### The Data Model Tree

Your app is a web of objects. For test setup there's a **second** tree: the **Data Model Tree** — the relationships between all data models in your database, forming a tree **in their sequence of creation**.

**Worked example — what `gradeAssignment` requires.** Ask: *"what is the state of the data models at this point?"*
1. The **classroom** and **the student** must exist
2. Link them with a **student enrolment** record
3. Create an **assignment** for the classroom (depends on the classroom existing)
4. Assign it to the student → a **studentAssignment** record
5. The student submits → an **assignmentSubmission** record
6. **Only then** can `gradeAssignment` run → a **grade** record

> **Data models rely on each other and you must compose state in an explicit sequence based on dependencies. That's a characteristic of Composition.** You must **reconstruct the tree** — and you build the *builders* in reverse, starting from the target model.

### The Builder DSL — `build`, `from`/`and`, `with`

Stemmler's naming convention, and the reason the tests read like English:
- **`with`** expresses **fields/values**
- **`from`** and **`and`** express **relationships**
- **`build`** constructs it all

**The target-first read**: *"an enrolment **comes from** a student **with** a name **with** an email, **and from** a classroom **with** a name."*

```typescript
let enrolmentResult;

beforeAll(async () => {
  await resetDatabase();
});

given("There is an existing student enrolled to a class", async () => {
  enrolmentResult = await studentEnrolmentBuilder
    .fromStudent(studentBuilder.withName('Johnny').withRandomEmail())
    .andClassroom(classroomBuilder.withClassName('Math'))
    .build();
});
```

**How it's written**: focus on the **end result** — the `enrolment` — and *assume it will work*. This is **Programming by Wishful Thinking / Tell, Don't Ask** applied to test setup. Then implement the builders to fill in the failing test.

**A builder that manipulates the database:**
```typescript
// This could also be your Prisma data model type (which is a better design)
type StudentProps = {
  name: string;
  email: string;
};

class StudentBuilder {
  private props: StudentProps = { name: '', email: '' };

  withName(name: string) {
    this.props.name = name;
    return this;                          // chaining
  }

  withRandomEmail() {
    this.props.email = faker.internet.email();
    return this;
  }

  async build() {
    const student = await prisma.student.create({ data: this.props });
    return student;
  }
}
```

## Anti-patterns
- **Mocking infrastructure without contract tests** — you have no basis for believing production works.
- **Testing only through State Verification** when the interesting behavior is a *call that shouldn't happen* — that needs Communication Verification.
- **Developing against SQLite and deploying to MySQL with no integration test** — the configuration will differ and you'll find out in production.
- **Hand-rolled inline test setup for deep data trees** — unreadable and duplicated. Use builders.
- **Non-idempotent tests** — no reset, no randomness; they pass once and fail on re-run.
- **Refactoring legacy code before characterizing it** — you have no way to know you preserved behavior.
- **Treating a frontend's backend as "not infrastructure"** — to the frontend, the entire backend is infrastructure.

## Key Takeaways
1. **Pick the verification method deliberately**: Result for pure I/O, State when *time* and accumulated state matter, Communication for indirect inputs/outputs.
2. **An integration test crosses architectural boundaries.** That's the definition — not "not unit, not E2E."
3. **Contract tests are what license you to mock.** Transitivity: mock passes contract + production passes contract ⇒ production works.
4. **Characterize before you change legacy code.** Lock in current behavior first.
5. **Learn your Data Model Tree** — test setup difficulty is a composition problem, not a testing problem.
6. **Builders use `with` for values, `from`/`and` for relationships, `build` to construct** — write the usage you wish existed, then implement it.
7. **Randomness or reset** — every test must be re-runnable.
8. **Run expensive integration tests periodically** if they cost money; don't drop them entirely.

## Connects To
- **Ch 16 (Design Patterns)** — Builder ("my primary use case is simplifying test setup"), and the TestCompositionRoot Singleton.
- **Ch 18 (Programming by Wishful Thinking)** — how builder APIs get designed.
- **Ch 20 (Architecture)** — Hexagonal is what makes outgoing/incoming adapter contract tests possible.
- **Ch 11 (Testing Strategies)** — book ch. 25 covers which test type covers which concern.
- **Ch 12 (TDD Workflow)** — Classic vs. Mockist TDD; Communication Verification is the Mockist tool.
- **Ch 09 (Acceptance Tests)** — Given-When-Then and jest-cucumber originate there.
- **Ch 21 (DDD)** — repositories are the contract most worth contract-testing.
