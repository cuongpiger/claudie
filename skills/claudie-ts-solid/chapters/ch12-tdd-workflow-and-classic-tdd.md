# Chapter 12: TDD Workflow, Classic TDD, Arrange-Act-Assert & the Transformation Priority Premise *(book ch. 28–31)*

## Core Idea
**Refactoring is where design happens** — the red-green-refactor loop exists to create a safe moment for design work. **TDD is mostly a design tool, not a verification tool.** The **Transformation Priority Premise** is the missing structured method for getting from red to green without relying on gut instinct.

---

## Part A — The TDD Workflow

### Red-Green-Refactor
- **Red** — write a failing test
- **Green** — write **just enough** code to pass it
- **Refactor** — criticize the design and refactor, keeping tests intact

> *"TDD gives us **immediate consequence detection** at each step."* If you have no idea how you'll make the test pass, you learn that right away.

### The Three Laws of TDD
1. **You are not allowed to write any production code unless it is to make a failing test pass.** (Writing tests *after* the code is much harder.)
2. **You are not allowed to write any more of a unit test than is sufficient to fail — and compilation failures are failures.**
3. **You are not allowed to write any more production code than is sufficient to pass the one failing unit test.** *"Once you make the failing test pass, **STOP**."*

**Law #2 in practice:**
```typescript
describe('elevator', () => {
  it('starts at ground floor', () => {
    let elevator = new Elevator();
    expect(elevator.getFloor()).toEqual(Elevator.Floors.Ground);
  });
});
```
This doesn't compile. The rule says: create the `Elevator` class, a `getFloor` method, and a `static Floors` enum — **and nothing more**. The test fails, the code compiles. You're in **red**.

### Other workflow rules
- **Have your tests running alongside you as you code.**
- **Commit after a passing test.**
- **Refactoring is something you do several times every hour, not something you wait until a few sprints later to do.**

### TDD Prerequisites
- A reasonable **testing strategy** thought out
- A **build-test-deploy test architecture**
- **Separate scripts** for acceptance/unit, integration, and E2E tests
- Ability to **seamlessly switch between environments**

### Why real-world TDD is so hard
- **As an industry, we struggle to agree on testing terminology.**
- **Many fail to recognize that TDD starts with architecture.**
- **Understanding what to test (and how) is hard.**
- **Frontend vs. backend differ fundamentally**: backend TDD is easier because you're often working with pure **core code** with no dependencies. On the frontend you code *within the confines of libraries and frameworks* — **there's less core code, fundamentally**.
  - **The frontend decision**: is it worth decoupling core from infrastructure, or should you test the majority via E2E? For **list-detail-view apps** where you fetch and present, *"you can validate correctness by observing and clicking."* For **drag-and-drop, games, heavy client-side logic** — things you can't verify by observing and clicking — you need the same rigor as a server-side hexagonal architecture.

### Classic vs. Mockist TDD

| | **Classic TDD** | **Mockist TDD** |
|---|---|---|
| Also called | **Inside-Out**, **Chicago style** | **Outside-In**, **London style** |
| Start from | The unit tests, building **outwards** | The **boundaries** (controller or use case), coding **inwards** |
| Fleshes out | Internal details of objects you know you need | **Mock objects** for infrastructural dependencies |
| Where taught | Part IV (TDD Basics) | Part X (Advanced TDD) |

> **Both are useful. Use a mixture of inside-out and outside-in to TDD your way through a feature.**

**Double Loop TDD**: the outer loop is the acceptance test; the inner loop is red-green-refactor. Then **fill confidence gaps with Integration and E2E tests** — *"for each Acceptance Test you've finished, ask how confident you feel about it working in production. **95% of the time, you should be lacking some confidence**"* — because the vertical slice relies on real infrastructure and third-party APIs.

---

## Part B — Classic TDD Techniques

### The Rule of Three
> **Only clean up duplication when you come across it three times.**

**Why wait?** *"It is way easier to invent the **wrong** abstraction than it is to invent the right one."* Cleaning up immediately is a form of **premature optimization**.

> **"A little bit of duplication is 10x better than an incorrect, complex, or wrong abstraction."**

*"This will take discipline. You'll have to train your brain to handle some temporary messiness. But that's OK, because if we follow the TDD process, it'll get cleaned up when it needs to."*

### Triangulation
As you add tests, you **sculpt the design toward a general, robust solution**. *Agile Technical Practices* relates this to **degrees of freedom** from mechanics:

> In three-dimensional space there are **six degrees of freedom**: surge (forward/back), heave (up/down), sway (left/right), yaw, pitch, roll.
> **Cars have three** (surge, sway, yaw). **Planes have three** (pitch, roll, yaw). **Boats have all six.**

If you implement a `Car` class, **you aren't done until you've implemented all three degrees of freedom** — that's the necessary behavior. **By triangulating with more tests, you carve out the degrees of freedom (capabilities) of your design.**

Two ways to move the design forward:
1. **Move onto new behavior** — finish forward/back, then start left/right
2. **Add another example** — spend more time on forward/back, evolving what happens in edge cases

### Naming and writing tests
- Stick with **Format #1 (single-line tests)** for unit tests:
  ```typescript
  describe('guitar', () => {
    test('when I do something, then something happens', () => { });
  });
  ```
- **Note the missing `given`**: most beginner unit tests don't rely on state, so there's **no precondition**. Testing `add(a, b)` needs no `given`; testing that *a resumable chess game has all pieces in the right place* **does**.
- **Write tests based on behavior, not implementation.** Use **domain terminology** — if the domain is fishing, use fishing terms; for a calculator, use mathematics terms. Avoid technical names.
- **Prefer concrete examples over abstract statements.**
- **One example per test.**
- **Design happens during refactoring.**

---

## Part C — Arrange-Act-Assert & Writing Tests Backwards

### The three challenges you'll hit
1. **Not sure how to name the test** → **use concrete examples to guide test names**; remember **naming is a process**.
2. **Not sure how to express the behavior** → the **Transformation Priority Premise** gives you hints.
3. **Not sure how to verify it** → **write the test backwards**.

### Writing tests backwards *(the chapter's key technique)*

> *"Often, the hardest part about writing a test is figuring out **how we're going to verify that it will have worked**."*

Start from the **Assert** phase — decide first how you'll verify the test passes. *"I find this technique makes it easier to tap into your creativity — which I believe to be mostly unconscious. It informs your design in ways you never would have otherwise considered."*

**What you avoid**: inventing abstractions you don't need · being overly ceremonious · introducing unnecessary state.

This is **programming by wishful thinking** — expressing what you want declaratively. *"It sort of looks like English, but it's code — code that we know can **eventually** resolve to executable code."*

**Worked example — Tic Tac Toe, "should know that it's O's turn to go after X":**
```typescript
// 1. Assert — easy: just turn the requirement into declarative code
expect(game.getCurrentTurn()).toBe('O');

// 2. Act — what must happen for that to be true?
game.chooseMark({ row: 0, column: 0 });

// 3. Arrange — by default, X goes first, so...
const game = new Game();
```
Write it in **3 → 2 → 1** order; read it in **1 → 2 → 3** order.

**Keep it clean** — the AAA phases should be visible from structure; **comments are not necessary.**

---

## Part D — The Transformation Priority Premise (TPP)

**The problem it solves**: the "obvious implementation" step relies entirely on gut instinct. TPP **imposes constraints upon the Obvious Implementation**, explicitly defining what **preferred transformations** look like — and, more importantly, what **bad** ones look like.

> *"It's always going to be simpler to go from constants to scalars than from constants to conditionals or to recursion."*

**How you use it**: *"Can I do this with a scalar (argument)? No? Okay, what about applying a transformation to conditionals instead? Will that work? Ah yes, let's use that."*

> 💡 **Also works in reverse**: use TPP when refactoring to think about how to move your transformations **back down** to simpler ones.

### The TPP table — 12 transformations, simplest first

| # | Transformation | Example |
|---|---|---|
| 1 | **`{}` → nil** | `return;` / `return null;` / `return '';` |
| 2 | **nil → constant** | `return 1;` |
| 3 | **constant → constant+** | `return 1 + 2;` / `return { value: 1 }` |
| 4 | **constant → scalar** | `function demo(arg) { return arg + 2; }` |
| 5 | **statement → statements** | **Unconditional** statements only — assignment and subroutine calls. `var temp = arg + 2; return someFunction(temp, arg);` |
| 6 | **unconditional → conditional** | `if/else`, `switch`, ternary. *Splitting code paths increases cyclomatic complexity — delay it as long as possible* |
| 7 | **scalar → array** | `var arr = [0,1,2,3,4,5,6]; return arr[index];` |
| 8 | **array → container** | A class or richer object does the selection: `page.getElement(index, elIndex)` |
| 9 | **statement → tail recursion** | `tailrecsum(x - 1, running_total + x)` — introduced **before** loops |
| 10 | **if → loop** | `for (let i = 0; i < arg; i++) { }` |
| 11 | **statement → recursion** | Original recursion: `return x + recsum(x - 1);` — the compiler must reach the bottom before evaluating |
| 12 | **expression → function** | Decomposition: `return Greeting.getGreeting(name);` |

**The notable ordering choice**: **tail recursion (#9) comes before loops (#10) and before original recursion (#11)** — tail recursion pushes a value forward through each call, making the original recursive call the last expression evaluated.

**Exercises the book uses**: Palindrome, Fizz Buzz, Nth Fibonacci, Stats calculator, Password validator, Recently Used List, Tennis.

## Anti-patterns
- **Writing tests after the code** — much harder, and it stops driving design.
- **Writing more production code than the failing test requires** — Law #3; stop when green.
- **Removing duplication on the second occurrence** — you'll invent the wrong abstraction.
- **Deferring refactoring to "a later sprint"** — refactoring happens several times an hour.
- **Jumping straight to conditionals or loops** from red to green — TPP says try scalars first.
- **Abstract/generic test names** — use concrete examples.
- **Technical test names** (`'save data into an array'`) — use domain terminology.
- **AAA comments in the test body** — the structure should be visible without them.
- **Assuming TDD alone produces good design** — it delivers functional requirements; design is the refactor step.

## Key Takeaways
1. **Refactoring is where design happens.** Red and green just create the safety to do it.
2. **The Three Laws are literal constraints** — write only enough test to fail, only enough code to pass.
3. **Rule of Three beats DRY-on-sight.** A little duplication is 10× better than a wrong abstraction.
4. **Triangulate to carve out degrees of freedom** — a `Car` isn't done until all three are tested.
5. **Write tests backwards from the assert** when you're stuck — it's the fastest route to a design you wouldn't have guessed.
6. **Use TPP to choose the next transformation**, and in reverse to simplify during refactoring.
7. **Delay conditionals as long as possible** — every branch is cyclomatic complexity.
8. **Mix Classic (inside-out) and Mockist (outside-in)** — neither alone covers a feature.
9. **Expect to lack confidence after acceptance tests pass** — that's what integration and E2E tests are for.
10. **On the frontend, decide deliberately**: decouple core from infrastructure, or accept E2E as your main strategy.

## Connects To
- **Ch 11 (Testing Strategies)** — the strategy TDD needs as a prerequisite.
- **Ch 09 (Acceptance Tests)** — the outer loop of Double Loop TDD.
- **Ch 22 (Advanced TDD)** — Mockist TDD, communication verification, contract tests, builders.
- **Ch 14 (Object Calisthenics)** — the refactor-step checklist.
- **Ch 15 (Code Smells)** — what to look for during refactor.
- **Ch 18 (Creational Principles)** — DRY/Rule of Three, and Programming by Wishful Thinking.
- **Ch 02 (Human-Centered Design)** — TPP is *constraints* applied to implementation choice.
- **Ch 13 (RDD)** — "tests aren't design"; RDD is what fills the gap.

## References
- *Test-Driven Development: By Example* — Kent Beck
- *The Transformation Priority Premise* — Robert C. Martin
- *Agile Technical Practices Distilled* — Consolaro & Santos (degrees of freedom)
- *Growing Object-Oriented Software, Guided by Tests* — Freeman & Pryce
