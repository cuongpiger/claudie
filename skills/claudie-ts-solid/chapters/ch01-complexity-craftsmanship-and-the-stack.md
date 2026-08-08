# Chapter 01: Complexity, Craftsmanship & the Design Stack *(book ch. 1–3)*

## Core Idea
**The goal of software design** is *to build products that serve the needs of the customer, of the users, and can be cost-effectively changed by developers.* The enemy is **complexity** — anything that makes the system hard to **understand and modify**. Everything else in the book is a technique for keeping complexity at bay.

## Frameworks Introduced

- **The Three Goals of Software** (the frame the whole book returns to):
  1. Satisfy the needs of the **user**
  2. Satisfy the needs of the **customer**
  3. Do so in a way that the **developer** can continue to achieve goals #1 and #2

- **Essential vs. Accidental Complexity**:
  - **Essential complexity** — inherent to the system; you can't remove it. It is: the **features (use cases)**, the **data (state)** needed to fulfil them, the **behaviour (business logic and rules)** governing that data, and (ignoring cosmetics) **what must be presented to the user**. It's the **floor**, it's **declarative** — *what* we build, not *how*.
  - **Accidental complexity** — "virtually any other complexity that is not the essential complexity." Introduced the moment you start building. It's the **implementation space**, the **imperative**.
  - Some accidental complexity is avoidable (duplication, dead code, outdated comments). Some — **state** and **control** — is so foundational to OO that only a purely functional approach removes it, and that has its own tradeoffs. *"There are no silver bullets."* — Fred Brooks, 1987.

- **Causes of accidental complexity**: getting the requirements wrong · dependencies (tight coupling) · obscurity (low cohesion) · more developers · language and API capabilities · premature optimization.

- **The Four Symptoms of Complexity** — how to *detect* it:

  | Symptom | What it means | What it signals |
  |---|---|---|
  | **Ripple** | A simple change forces modifications in several other places | Tight coupling, lack of encapsulation, dependencies knowing too much |
  | **Cognitive load** | Too many elements must be held in your head at once | ⚠️ **Too much** abstraction/encapsulation — too many layers, global variables, inconsistent design, files organized by type instead of feature |
  | **Poor discoverability** | You can't find where to make the change | Identifying *where things are, what they are, and what you can do with them* |
  | **Poor understandability** | You found the code but don't know *how* to change it | Knowing how to perform the action, performing it, and **confirming you succeeded** |

  > **Ripple and cognitive load pull in opposite directions.** Ripple says you under-abstracted; cognitive load says you over-abstracted. Design is finding the point between them.

- **Tactical vs. Strategic Programming**:
  - **Tactical**: brute-force to a working solution, unconcerned with design implications. **0% focused on maintainability.** Legitimate for proofs of concept and exploratory programming — things you're confident won't be long-lived.
  - **Strategic**: a **50/50 split** between writing code for the **customer** and writing code for **maintainers**. Like seeding both sides of a marketplace — you can't succeed with only one.
  - The economic argument (Sun Microsystems): **40–80% of the lifetime cost of software goes to maintenance**, and **hardly any software is maintained for its whole life by the original author**.

- **The XP Values** (Kent Beck, formalized 1996 on a Chrysler project) — values dictate practice:
  - **Feedback** — *"Bad design is truly complexity of our own making."* Feedback loops force you to stop and look at what you just did, catching bad designs before they're unfixable. Code review is a feedback loop, but it is the **last line of defence**. Earlier loops: **pair programming, TDD, acceptance tests, unit tests**.
  - **Simplicity** — build the simplest possible thing that works and is understandable to developers.
  - **Communication**.

- **Software Craftsmanship** — *"Craftsmanship is professionalism in software development."* A **mindset**, not a certification or a seniority level. About taking **responsibility** for careers, clients, and community; **pride** in solutions; working with **pragmatism**.

- **The Software Craftsmanship Manifesto** (2006):
  > - Not only **working software**, but also **well-crafted software**
  > - Not only **responding to change**, but also **steadily adding value**
  > - Not only **individuals and interactions**, but also **a community of professionals**
  > - Not only **customer collaboration**, but also **productive partnerships**

- **The Craftsmanship Principles** (actionable):
  1. **Care about what you do** — enjoying the work increases the likelihood of doing it well.
  2. **Use Agile technical best practices** — TDD, refactoring, pair programming, simple design.
  3. **Always be improving yourself.**
  4. **Know your industry** — know *why* we do what we do.
  5. **Learn the domain** — when you know the domain, code becomes a **metaphor** for real life (DDD's Ubiquitous Language).
  6. **Ruthless simplicity** — build precisely what's needed to make the feature work. No more.

## The Software Design & Architecture Stack — the 9-step roadmap

Modelled on the **OSI Model**: each layer builds on the previous one. This is the book's table of contents as a mental model.

| Step | Layer | Goal |
|---|---|---|
| 1 | **Clean Code** | Consistency, meaningful names over comments, proper spacing, all tests run, pure functions, don't pass null |
| 2 | **Programming Paradigms** | Structured, object-oriented, functional |
| 3 | **OOP & Domain Modeling** | True object-oriented practice |
| 4 | **Design Principles** | Balance coupling and cohesion — SOLID, DRY, Composition over Inheritance, Encapsulate What Varies, Program to Abstractions, Hollywood Principle |
| 5 | **Design Patterns** | Creational, structural, behavioural — class-level solutions |
| 6 | **Architectural Principles** | System-level rules |
| 7 | **Architectural Styles** | Structural, message-based, distributed |
| 8 | **Architecture Patterns** | MVC, Hexagonal, CQRS, Event-Driven… |
| 9 | **Enterprise Patterns** | DDD tactical patterns |

**Why the stack matters**: you can take a topic like **Value Objects** from DDD and follow it *all the way down* through architectural patterns, styles, design patterns, to clean code — and from there into psychology, design thinking, and mental images. Top-down and bottom-up understanding of the same thing.

## Mental Models
- **Entropy is the default.** Rooms get messy, dishes pile up. *"When you exert the least amount of energy, the world tends towards complexity."* **If a system is too complex for us to understand, we can't maintain it.**
- **Complexity is incremental.** Even with best efforts, adding features increases potential complexity — more code means more to understand, more ways to break, more to account for.
- **A dependency is a component needed for another component to work.** Concrete dependencies (`new`) prevent isolated testing.
- **All non-trivial abstractions eventually leak.** Expect it from React, Angular, ORMs, and your own designs.

## Code Example — coupling that prevents testing

```typescript
class UserService {
  constructor(
    private db: MySqlConnection,   // concretion
    private logger: Logger         // concretion
  ) {}

  createUser() { /* ... */ }
}
```
- **What it demonstrates**: there is **no way to test `UserService` in isolation**. A real `MySqlConnection` makes tests slow; a noisy `Logger` makes them unreadable. That inability *is* tight coupling.
- **Concretion**: a literal object created with `new`. The alternative is an **abstraction** (interface, abstract class, type).

## Reference — Forms of coupling

| Form | Definition | Example |
|---|---|---|
| **Subclass coupling** | Child connected to parent | `SomeClass extends BaseClass` |
| **Temporal coupling** | Two actions bundled because they happen at the same time | `CreateUserAndSendEmail()` |
| **Dynamic coupling** | The order of execution matters | Must call `a()` before `b()` |

## Anti-patterns
- **Applying the tactical approach to long-lived projects** — you'll ship once, then nobody (including you) can change it.
- **Organizing files by infrastructure/type rather than feature** — named as a direct cause of cognitive load.
- **Treating code review as your feedback loop** — it's the *last* line of defence, far too late for structural feedback.
- **Over-abstracting to avoid ripple** — you trade ripple for cognitive load. Both are complexity.
- **Constructing concrete dependencies inside a class** — untestable in isolation, by definition.
- **Assuming there's a silver bullet** — every paradigm has tradeoffs.

## Key Takeaways
1. **Complexity = hard to understand and modify.** That's the whole definition, and the whole enemy.
2. **Separate essential from accidental complexity** — the first is the requirements, the second is your design decisions. Only the second is negotiable.
3. **Use the four symptoms as a diagnostic**: ripple, cognitive load, poor discoverability, poor understandability.
4. **Strategic programming is a 50/50 investment** — half for the customer, half for maintainers. Justified by 40–80% of lifetime cost being maintenance.
5. **Tactical is legitimate for spikes and prototypes** — just be honest about which mode you're in.
6. **Move feedback earlier**: pair programming and TDD beat code review, which beats production.
7. **The stack gives you top-down and bottom-up understanding** of any single concept.
8. **Craftsmanship is a mindset of responsibility, pride, and pragmatism** — not a title.

## Connects To
- **Ch 19 (Coupling, Cohesion & Connascence)** — the deep treatment of what's introduced here.
- **Ch 02 (Human-Centered Design)** — discoverability and understandability get their full framework there.
- **Ch 17 (SOLID)** / **Ch 18 (Principles)** — step 4 of the stack.
- **Ch 16 (Design Patterns)** — step 5.
- **Ch 20 (Architecture)** — steps 6–8.
- **Ch 21 (DDD)** — step 9.
- **Ch 12 (TDD)** — the earliest practical feedback loop.

## References
- *A Philosophy of Software Design* — John Ousterhout (tactical vs. strategic)
- *No Silver Bullet* — Fred Brooks (1987)
- *Extreme Programming Explained* — Kent Beck
- *Clean Agile: Back to Basics* — Robert C. Martin (2019)
- The Stack & The Map — khalilstemmler.com
