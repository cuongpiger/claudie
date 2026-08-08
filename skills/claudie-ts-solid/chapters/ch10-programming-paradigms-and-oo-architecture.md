# Chapter 10: Programming Paradigms & an Object-Oriented Architecture *(book ch. 23–24)*

## Core Idea
Three paradigms, each defined by what it **restricts**. Structured programming gave us **sequence, selection, iteration**; object-oriented added **indirection** — the ability to safely swap dependencies without changing existing code. *"To this date, we have not identified any more comparable building blocks."* And the key architectural distinction that follows: **core code vs. infrastructure code**.

## Frameworks Introduced

- **The Four Building Blocks**: **sequence, selection, iteration** (from structured programming) + **indirection** (from OO). With all four, components become:

| Building block enables | SOLID principle |
|---|---|
| Packaged into cohesive vertical slices with a single responsibility | **SRP** |
| Strategically open for extension, closed for modification | **OCP** |
| Substitutable for other components implementing the same methods | **LSP** |
| Declaratively communicating intent with small, cohesive interfaces | **ISP** |
| Safely transferring control to other components without knowing their internals | **DIP** |

- **The three problems structured programming faced** — and OO's answers:

| Structured programming problem | Alan Kay's OO answer |
|---|---|
| **Shared mutable state (coupling)** | **Encapsulation** — state lives in the object it belongs to |
| **Cyclomatic complexity** | **Encapsulation + dynamic binding** — program against the abstraction, leave implementation for later. *"Instead of dealing with concrete classes here and now, we accomplish key tasks by describing **future** abstractions. This is the nature of architecture."* |
| **Unsafe polymorphism** | **Dynamic binding** — safe runtime adaptation |

- **OO as "a web of objects"** — Alan Kay, 1966–67, influenced by **cell biology** and the design of **Arpanet**. He envisioned individual **mini-computers**, each with isolated state (**encapsulation**), communicating via **message passing**, and easily **pluggable and interchangeable** (polymorphic).
  - Historical note: **Ivan Sutherland's Sketchpad (1963)** — the first program with a working GUI — already used "objects" and "occurrences" (instances).
  - **To Alan, OO was about *messaging*** — not about classes or hierarchies.

- **The Two Values for Doing OO Properly** — *"So many developers get OO wrong because they're implementing practices without understanding the principles or the underlying values."* **Values → principles → practices.**

  **Value #1: Messaging.** Ask yourself:
  - Can I **declaratively express the behavior/communication** I want between objects (even if they don't exist yet)?
  - Can I use **tests to guide the design and validity** of my messages/methods?
  - Can I tell if my class is **overly coupled**?
  - Can I use **design patterns** to express common communication patterns?

  **Value #2: Encapsulation (and the right amount thereof).** Ask yourself:
  - Can I tell if my class is **cohesive**?
  - Is this class too big? Should I break it up? How?
  - Should all these instance variables really be in this class?
  - Are the methods **expressive**?

- **Design principles are paradigm-agnostic.** Immutability isn't exclusive to FP; encapsulation and polymorphism aren't exclusive to OO. *"We are still dealing with sequence, selection, iteration, and indirection, regardless of the paradigm."*

- **Choosing a paradigm** — the factors: the **skill level of your team** · **familiarity with the paradigms and their conceptual models** · **the language's support** for the paradigm you want.
  - **Stemmler's honest position**: *"I believe that functional programming is the **cleanest** way to codify the essential and avoid accidental complexity. However, object-oriented programming is still the most popular way to develop software, and it's most likely you'll find yourself on teams of other object-oriented developers."*
  - **His recommendation**: **master OO, learn how to apply functional programming principles to it, and learn FP on your own time.**
  - Uncle Bob's summary: structured programming taught us to **restrict direct transfer of control**; OO gave us **discipline over indirect transfer of control**; FP imposes **discipline over assignment**.

## The Five Steps to Deciding on an Architecture

> *"Architecture is about the stuff that's hard to change if we get it wrong early on."*

1. **Use the requirements.** *"The requirements are the biggest clues as to what you need."* Worried about pre-optimization? **Remember YAGNI** and let requirements dictate what's necessary.
   - **Functional requirements** ("the system shall do *something*") — testable, same input yields same output. They **identify the external services, APIs, and dependencies** you'll need.
   - **Non-functional requirements** — they hint at the correct **architectural patterns and tools**.
2. **Consult design principles.**
3. **Consult architectural principles.**
4. **Consult architectural patterns.**
5. **Draw it out on a whiteboard.**

## The Core vs. Infrastructure Distinction *(the chapter's key idea)*

| | **Core code** | **Infrastructure code** |
|---|---|---|
| What it is | Features and domain logic | What connects core code to the real world |
| What it knows | **Nothing** of databases, caches, or web servers | DB adapters, system clocks, web servers, external tech |
| Value | **"The family jewels"** — the most valuable code | Makes it "buzz and whirr for real" |
| Where it comes from | Learning the domain (ch. 16) | Technology choices |
| Testability | **Unit testable, fast** | **You can't unit test infrastructure** |

## What's Wrong With MVC

**The problem is the *model*.** *"The testing options are limited."*

It's not uncommon to find controllers containing **validation logic, business rules, event handling, response parsing and formulating, web server logic, and persistence code all in the same place**.

> **Trivial implementations of MVC promote a mixture of core code and infrastructure code.**

Because the model "does a *lot* of stuff," teams organize it **arbitrarily** — inventing `Manager`/`Service`/`Helper` classes with no principle behind them. That's the gap DDD and layered architecture fill.

**Transaction Scripts vs. Domain Models** — the two ways requests get handled in an OO architecture, and the fork every backend feature reaches.

**Dependency inversion & the Dependency Rule** are what keep core decoupled from infrastructure — that's *why* we decouple: so core code stays fast to test and free to change.

## Deployment: the Modular Monolith

> *"Should we start with microservices? **No.** … Start with a well-organized **Modular Monolith** until it reaches the critical mass and the socio-technical opportunity at which it makes sense to break into separate teams and deployments."*

Apply the organizing principles: **package subdomains into modules, which contain use cases, packaged by feature.**

## Code Example — how inheritance goes wrong

The classic `Animal`–`Cat`–`Dog` example, which *"sent us down a path of creating a generally incorrect conceptual model for OO"*:

```typescript
class Animal {
  private name: string;
  public setName(name: string): void { this.name = name; }
  public printName(): void { console.log("My name is: " + this.name); }
}

class Cat extends Animal {
  public meow(): void { console.log("Meow"); }
}
```
- **What's wrong**: it teaches OO as **taxonomy and hierarchy** rather than **messaging between encapsulated objects**. *"Just because the tool lets you do something doesn't mean it's right."* **Over-use of inheritance is the most common way developers mess up OO.**
- **The fix**: *"Leave the hierarchy idea behind. Focus on that web of objects."*

## Anti-patterns
- **Inheritance as the primary reuse mechanism** — the #1 way OO designs go wrong.
- **Teaching/learning OO through Animal-Cat-Dog** — builds the wrong conceptual model.
- **Trivial MVC on a complex domain** — mixes core and infrastructure, making the model untestable.
- **Arbitrary `Manager`/`Service` classes** in the model layer — a symptom of having no organizing principle.
- **Applying SOLID as practices without understanding the values** — you'll follow rules without knowing when they don't apply.
- **Starting with microservices** — start with a modular monolith.
- **Believing a technique belongs to a paradigm** — immutability, encapsulation, and polymorphism are all achievable in either.

## Key Takeaways
1. **Indirection is OO's real contribution** — swapping dependencies safely, without editing existing code.
2. **OO is about messaging**, per Alan Kay — objects as mini-computers passing messages, not a class taxonomy.
3. **Values → principles → practices.** Start at values (messaging, encapsulation) and the SOLID principles become intuitive rather than memorized.
4. **Core code knows nothing about infrastructure.** That single rule is what makes fast tests and swappable technology possible.
5. **MVC's failure mode is the model** — it invites core and infrastructure to mix.
6. **Requirements drive architecture**: functional requirements → components and dependencies; non-functional requirements → patterns and tools.
7. **Master OO, apply FP principles to it, learn FP separately.** The pragmatic path.
8. **Modular monolith first.** Split when the *socio-technical* situation demands it, not before.

## Connects To
- **Ch 17 (SOLID)** — each principle is mapped here to a building block of the paradigm.
- **Ch 20 (Architecture)** — the Dependency Rule, layered/hexagonal styles, and the modular monolith in depth.
- **Ch 21 (DDD)** — the domain model is the answer to "what goes in the model?"
- **Ch 13 (RDD)** — "a web of objects" is exactly RDD's object neighbourhoods.
- **Ch 11 (Testing Strategies)** — core vs. infrastructure determines which test type covers what.
- **Ch 08 (Features)** — the pseudocode captures essential complexity; the paradigm codifies it.
- **Ch 18 (Composition Over Inheritance)** — the antidote to the inheritance trap.
