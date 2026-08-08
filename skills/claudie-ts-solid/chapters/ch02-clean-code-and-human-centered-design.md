# Chapter 02: Clean Code & Human-Centered Design for Developers *(book ch. 4–5)*

## Core Idea
Clean code is code with **as little accidental complexity as possible** — minimal ripple, cognitive load, poor discoverability, and poor understandability. The chapter's real contribution is importing **Don Norman's *The Design of Everyday Things*** wholesale: your codebase is an *interface*, other developers are its *users*, and Norman's seven design principles apply directly.

## Frameworks Introduced

- **The Seven Stages of Action** (Don Norman) — the psychology of interacting with any object to accomplish a goal:
  1. **Goal** (form the goal) — 2. **Plan** (the action) — 3. **Specify** (an action sequence) — 4. **Perform** (the action sequence) — 5. **Perceive** (the state of the world) — 6. **Interpret** (the perception) — 7. **Compare** (the outcome with the goal)
  - **Stages 2–4 are *feedforward*** — clues leading you to act.
  - **Stages 5–7 are *feedback*** — and **feedback leads to true understanding: the conceptual model.**
  - Using a pen is muscle memory; adding a feature to a legacy codebase means spending noticeable time at *each* stage. **Naming the stage you're stuck at is how you diagnose the problem.**

- **Knowledge in the Head vs. Knowledge in the World**:
  - **In the head** — must be *learned* first.
  - **In the world** — easy to use and interpret, fast, and **doesn't have to be learned**. Best example: reminders (a sticky note on your path out the door). Why ATMs guide you step by step — imagine if withdrawing money required the tribal knowledge that changing a tire does.
  - Knowledge in the world is expressed through **affordances, signifiers, mappings, and physical constraints**.

- **Affordances** — *what the physical attributes of an object tell you that you can do with it.* A chair affords sitting; a light chair affords lifting; glass affords seeing through and has an **anti-affordance** blocking passage (which is how people walk into glass doors).
  - **In programming languages**: a JS developer reaches for `const visitors = {}` as a hash table; Java requires `Hashtable<String, String>` and classes. Different affordances → different reachable solutions.
  - **This is Stemmler's foundational argument for TypeScript**: the affordances for abstractions (interfaces, abstract classes) are *expressive and part of the language*, and we need abstraction for every design technique in the book.
  - **In design patterns**: Observer in Node.js is trivial (`EventEmitter`); Abstract Factory in plain JavaScript is nearly impossible — there's no `abstract` keyword.
  - **Code's affordances are documentation and reading.** High-level feedforward: repo docs (install, run, test, contribute, domain, architecture), folder structure and names, BDD-style tests. Lower level: formatting/style/file size, modular units, comments when necessary.

- **Signifiers** — from **semiotics**. A sign is a two-part relationship: the **signifier** (the physical thing you see/hear) and the **signified** (the mental content it produces). Signifiers are a **cheap way to enhance the discoverability of affordances**.
  - *Affordances signify which actions are possible; signifiers communicate **where** the action should take place and what the options are.*
  - **Intentional signifiers in software**: **design patterns** (seeing a `private constructor` + `static create` → "factory method"; or the name `StudentController`), **comments**, and **BDD-style tests** — "the most obvious, intentional clue for demonstrating what the code does."
  - **Accidental signifiers in software**: dead/commented-out code and stale `todo`s (signify work-in-progress); too many nested conditionals (signify a concentration of domain logic); thin controllers (signify logic lives elsewhere and the architecture is more than MVC); code smells and anti-patterns (signify issues to tend to).

- **Constraints** — *limit the set of possible actions*. Four kinds: **physical** (a puzzle piece won't fit the wrong slot), **cultural** (elevator eye contact), **semantic** (helmets matter because we're fragile), **logical** (deduction from alibis).
  - **In software**: static type checking · Value Objects using the Factory Pattern to enforce creation rules · access modifiers · **language rules** (a `const` can't be redeclared; a `static` method is only reachable through its class) · **strictly-typed errors** that *force* you to deal with error states.
  - **Thin interfaces** (John Ousterhout, *A Philosophy of Software Design*; Fowler's **Minimal Interface**): when deciding public vs. private, **choose the minimal route.** *Humans have limited working memory — constrain what humans need to know in order to use the class effectively.*

- **Mapping** — *the relationship between two sets of things*, usually the layout of controls relative to what they control. The stove-top example: controls in the same spatial arrangement as burners are instantly understandable; a straight row is not.
  - **The mapping hierarchy** (best to worst):
    1. Mount controls **directly on** the items to be controlled
    2. Mount controls **as close to** the items to be controlled
    3. Mount controls in the **same spatial arrangement** as the items
  - Good mapping means **you construct a conceptual model faster.** Achieved through **grouping** and **proximity**.

- **Grouping** (place *related* controls together) and **Proximity** (place controls *close to* what they control):
  - **Grouping in software**: **cohesion** — group state and the operations against that state into one class. Also SRP and boundaries.
  - **Proximity in software**: **coupling** — components that change together should live near each other. **Anemic domain models are a proximity failure**: a `UserManager` doing `create`/`update`/`setPermissions` on `User` leaves `User` responsible for nothing, causing duplication and lost encapsulation.
  - **API design**: the **DOM API has good mapping** — methods live *on* the object they operate against:
    ```javascript
    // Great — the control is on the item to be controlled
    const node = document.querySelector('a').getAttribute('href');

    // Imagine having to do this instead (some Java APIs are like this)
    const nodeResult = document.querySelector('a');
    const node = document.createExecutableNode(nodeResult);
    node.getAttribute('href');
    ```
    This is also the **Law of Demeter** — *my object doesn't talk to strangers.*

- **Feedback** — *communicating the results of an action*. **Feedback is expected to be immediate.** Without it, users assume the thing is broken or slow and try again (bashing the elevator close button; double-purchasing on a slow checkout).
  - **Two kinds of error**:
    - **Slips** — the goal/plan **is correct** but the **sequence is off**. Recoverable: point the user to the right sequence.
    - **Mistakes** — the goal/plan is **not correct**. Bad: the user is going about their goal in an incorrect way.
  - **Feedback in software**: the **CQS principle** *is* a feedback contract — for a **command**, *no response* signals success and an error signals failure; for a **query**, *no response* signals failure or slowness and data signals success. Also: CLI progress output, loading spinners on submit, **autocomplete** (depicts the total set of possible actions), and **compile-time type checking** (shows immediately whether what you're doing is legal).

- **Conceptual Models** — the mental model a user builds of how the thing works. Built from feedback (stages 5–7).

## Worked Example — Grouping: state and behavior together

```typescript
class UserState {
  public name: string;
  public id: string;
  constructor(name: string, id: string) {
    this.name = name;
    this.id = id;
  }
}

class User {
  // State
  private state: UserState;
  constructor(state: UserState) {
    this.state = state;
  }

  // Behaviors — grouped with the state they operate on
  getName(): string {
    return this.state.name;
  }

  greet(): void {
    console.log(`Hello, I'm ${this.state.name}`);
  }
}
```
- **Why**: grouping state with the operations against it is *cohesion*, and cohesion is Norman's grouping principle applied to code. Splitting identifier, state, and behavior apart is legitimate for game engines (ECS, data-oriented design) for performance — but for business application software, keep them together.

## Testing your code for cleanliness — the three questions

Stemmler's practical cleanliness test. Hand the code to a developer and ask them to:
1. **"What does my code do?"** — tests *understandability*.
2. **"Find the code that needs to be changed."** — tests *discoverability*.
3. **"Change this code without introducing bugs."** — tests whether the design actually supports change.

If any of the three is hard, you have a human-centered design problem, not a taste problem.

## Structure vs. Developer Experience

The chapter's second axis: **structure** (rigor, layers, enforced boundaries) vs. **developer experience** (ease, speed, low ceremony). Illustrated by **Angular vs. React** and by **Object-Oriented vs. Functional programming**. Neither pole is correct; **balancing them is the design decision.** Developer experience isn't only for developer-tooling companies — *"APIs aren't just URLs,"* and DX matters for all companies.

## Anti-patterns
- **Anemic domain models** — a proximity/mapping failure; the control isn't on the thing it controls.
- **Fat public interfaces** — every extra public method spends the reader's limited working memory.
- **Silent commands** with no success/failure signal — violates the feedback expectation; users retry.
- **Leaving dead code and stale TODOs** — they're *accidental signifiers* telling readers something is in progress when it isn't.
- **APIs requiring a wrapper object to act on a returned value** — bad mapping; adds a whole layer of required knowledge.
- **Comments that describe *what* code is** instead of letting the code say it — generally discouraged.
- **Assuming your abstraction signifies what you intended** — "purple" means something slightly different in every brain; the same is true of your class names.

## Key Takeaways
1. **Your codebase is a user interface and developers are its users.** Every Norman principle transfers.
2. **Use the Seven Stages to diagnose confusion** — knowing whether someone is stuck at *specify* or at *interpret* tells you whether to fix naming or feedback.
3. **Prefer knowledge in the world** — structure, names, types, and tests that don't have to be learned first.
4. **Thin interfaces are a working-memory decision**, not an aesthetic one. Choose the minimal public surface.
5. **Types and explicit error handling are constraints** — they're how you reduce the surface area of what's possible.
6. **Put the control on the thing it controls** — that's mapping, cohesion, proximity, and the Law of Demeter all at once.
7. **Immediate feedback is non-negotiable** — compile-time checking and autocomplete are feedback mechanisms, and that's a large part of TypeScript's value.
8. **Test cleanliness with the three questions**, not with opinion.

## Connects To
- **Ch 01 (Complexity)** — the four symptoms; clean code is their absence.
- **Ch 06 (Types)** — types as constraints and feedback; the affordance argument for TypeScript.
- **Ch 07 (Errors)** — explicit error handling as a constraint; slips vs. mistakes.
- **Ch 04 (Naming)** — Naming Principle #2 is literally "knowledge in the world."
- **Ch 18 (CQS)** — CQS reframed as a feedback contract.
- **Ch 19 (Least Astonishment)** — Norman's conceptual model applied to method behavior.
- **Ch 03 (Organizing Things)** — proximity and grouping applied to folder structure.
- **Ch 16 (Design Patterns)** — patterns as intentional signifiers.

## References
- *The Design of Everyday Things* — Don Norman
- *A Philosophy of Software Design* — John Ousterhout (thin interfaces)
