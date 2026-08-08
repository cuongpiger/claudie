# Chapter 16: Design Patterns — Creational, Structural, Behavioural & Pattern Awareness *(book ch. 37–41)*

> **Scope note**: for GoF pattern *mechanics* in TypeScript, see the sibling skill `claudie-ts-design-pattern`. This chapter captures what is **distinctive to Stemmler**: when to reach for a pattern at all, his opinionated verdicts on each one, the DDD-flavoured variants (Composition Root, private-constructor factory), and the Four-Dimensional Lens.

## Core Idea
Design patterns are **class-level** LEGO blocks — distinct from architectural patterns, which work at system scope. The common theme across all of them is **encapsulating what varies**. Because every pattern is itself a form of complexity, you should *discover which patterns you'll use at the same time you decide your architecture* — architecture is the structure, patterns are the content.

## Frameworks Introduced

- **The Pattern Adoption Loop** (Stemmler's 5-step process — use this instead of pattern-matching from memory):
  1. **Identify a recurring problem** — "I keep rewriting the same object-creation code."
  2. **Recall known patterns** — "That's a Builder or Factory scenario."
  3. **Prototype quickly** — implement it in one small slice.
  4. **Evaluate cost vs. benefit** — clearer code? less duplication?
  5. **Adopt or roll back** based on what you learned.

- **Pattern Hooks** — problem → pattern lookup table (see Reference Tables).

- **The Four-Dimensional Lens for Pattern Categorization** — the chapter's headline framework. Given *any* new pattern, library, or framework, ask four questions:
  1. **Stereotypical Object Role** — Information Holder, Structurer, Service Provider, Coordinator, Controller, or Interfacer?
  2. **Placement in the Stereotypical Architecture** — Infrastructure (Interfacing), Application (Coordination/Control/Collaboration), or Domain (Data/Rules/Processes/Relationships) layer?
  3. **Pattern Category** — structural, creational, or behavioural?
  4. **Architectural Pattern Context** — which style does it operate in (MVVM, Hexagonal, Pub-Sub…)?
  - When to use: every time a new library ships and you need to understand it in five minutes rather than five days.

- **The Categorization Hierarchy** (what the lens rests on):
  - **Level 1**: Six Object Stereotypes
  - **Level 2**: Stereotypical Architecture Context (which layer)
  - **Level 3**: Gang of Four context — Structural / Creational / Behavioural
  - **Level 4**: An Architectural Pattern's patterns

## Mental Models
- **Think of patterns as LEGO blocks**: each solves a small, well-known problem and connects to the others. Assembled into "object neighborhoods," they *become* your architecture.
- **Architecture picks your patterns for you.** Hexagonal, MVVM, MVC, and Pub-Sub each *prescribe* the patterns you must use to actualize them — so decide architecture and patterns together, up front.
- **Patterns "blow up in scale."** Many DDD/Hexagonal patterns are just classic structural or behavioural patterns at architectural size.
- **Code is like concrete** — once poured (especially with dependencies attached), it's hard to change. That's the argument for restraint.

## Worked Example — A pattern read through the Four-Dimensional Lens

**A Value Object** classifies as:
- **Creational** pattern — it typically uses a *factory method* + private constructor
- **Information Holder** — one of the six object stereotypes
- **Domain layer** — in the stereotypical architecture
- **Hexagonal Architecture** — the architectural pattern it belongs to

**A new state management library** you've never seen:
- **Role**: Information Holder + Interfacer — it stores state and bridges app ↔ UI
- **Layer**: Application layer — coordination and control of state
- **Category**: Behavioural — it leverages **Observer** to notify components
- **Architecture**: **MVVM** — the ViewModel synchronizes with the view

Four questions, and you now know its purpose, benefits, drawbacks, and how it interconnects — before reading the docs.

## Reference Tables

**Pattern Hooks — problem → pattern**

| Problem you're having | Reach for |
|---|---|
| Rename a DB column, now you must edit 10 controllers | **Repository** — encapsulate persistence |
| Test domain logic without real infrastructure | **Adapter / Ports & Adapters** — abstract I/O |
| Object with features toggled at runtime | **Decorator** — add responsibilities dynamically |
| Can't pick an algorithm until runtime | **Strategy** — interchangeable behaviors |
| Messy, repetitive test-object creation | **Factory** or **Builder** |
| Controller grown huge with if-else trees | **Strategy** or **Template Method** |

**Stemmler's verdicts — the opinionated part**

| Pattern | Verdict | Key note |
|---|---|---|
| **Singleton** | ⚠️ Use with care | Hidden dependency risk; can morph into a God object. Prefer DI. |
| **Factory** | ✅ Core in DDD | Private constructor + `create()` enforces invariants at birth |
| **Prototype** | 🔸 Rarely needed | "One I don't often use." Handy for test-data variants. Deep-vs-shallow copy gets tricky. |
| **Builder** | ⭐ Favourite | *Primary use case is test setup.* Smell: constructor with 7–8 params |
| **Adapter** | ⭐ Always | *"Every single time I interact with anything external or use some API, I'm always wrapping it in a class. Always."* |
| **Bridge** | ✅ Emerges naturally | Comes out of responsibility-first discovery of commands/events; also good for serialize/deserialize |
| **Decorator** | ⭐ "Incredibly powerful" | *The* clean answer to cross-cutting auth and logging without cluttering service methods |
| **Composite** | ✅ Very domain-driven | Mirrors aggregate design — talk to the root, not the parts |
| **Proxy** | ✅ Useful when recognized | Like Decorator/Adapter "but with more responsibility" |
| **Template Method** | ⭐ Loves it | Class-based React (`componentDidMount`, `render`) *is* Template Method — "a consistent skeleton that allows override for crucial steps" |
| **Mediator** | ❌ **Dislikes it** | *"I don't really like this pattern very much… domain objects shouldn't know about mediators."* Use Infra → Application Layer → domain objects instead |
| **Observer** | ⭐ "Constantly using" | With MobX you can build an entire frontend architecture on observables alone — no Redux needed |
| **Strategy** | ⭐ Classic | Auth strategies (Google/Facebook/Email) are the everyday example |
| **Iterator** | ✅ For non-trivial collections | Worth it when the thing you traverse isn't just a list |

## Code Examples

**The Composition Root as Singleton** — Stemmler's preferred way to use Singleton at all:
```typescript
// The single place to wire up & store critical app dependencies
class CompositionRoot {
  private static instance: CompositionRoot;

  public readonly logger: Logger;
  public readonly userRepo: UserRepo;
  public readonly config: Config;

  private constructor() {
    // Wire everything up once
    this.logger = new Logger();
    this.userRepo = new InMemoryUserRepo();
    this.config = { env: "production", version: "1.0.0" };
  }

  static getInstance(): CompositionRoot {
    if (!CompositionRoot.instance) {
      CompositionRoot.instance = new CompositionRoot();
    }
    return CompositionRoot.instance;
  }
}

const root = CompositionRoot.getInstance();
root.logger.log("App started");
```
- **Pros**: centralizes wiring ("one ring to rule them all"); avoids threading config through constructors.
- **Cons**: can become a God object; still a hidden global if misused; large apps may want a real DI container or multiple roots.
- **💡 Testing technique**: spin up a `CompositionRoot.create("test")` — a **TestCompositionRoot** that constructs an entire *test version of the application*. Stemmler calls this "super powerful."

**Private constructor + factory method** — enforce invariants at creation (the DDD staple):
```typescript
interface UserProps {
  email: string;
  role: "standard" | "admin";
}

class User {
  // Private, so `new User(...)` is impossible — no bypassing domain rules
  private constructor(private props: UserProps) {}

  static create(props: UserProps): User {
    if (!props.role) {
      props.role = "standard"; // default
    }
    if (!/\S+@\S+\.\S+/.test(props.email)) {
      throw new Error("Invalid email format");
    }
    return new User(props);
  }

  public promoteToAdmin() { this.props.role = "admin"; }
  public getEmail(): string { return this.props.email; }
  public getRole(): "standard" | "admin" { return this.props.role; }
}

// A dedicated factory hides creation steps and defaults
class UserFactory {
  static createStandardUser(email: string): User {
    return User.create({ email, role: "standard" });
  }
  static createAdminUser(email: string): User {
    return User.create({ email, role: "admin" });
  }
}
```
- **What it demonstrates**: the only path to a `User` is `User.create()`, so invariants are guaranteed. New user types get a method on `UserFactory` rather than scattered `new` calls.

## Anti-patterns
- **Showing off 6 patterns in a small feature** — confusion, not craftsmanship.
- **Abstract Factory / Bridge in a simple domain** — many classes, rarely beneficial.
- **Introducing a new pattern family mid-project** — creates inconsistency; devs no longer know the standard way to implement a feature.
- **Domain objects that know about a Mediator** — Stemmler's specific objection: "mediator" means nothing inside an `Order` aggregate.
- **Singleton reached for implicitly across many classes** — hidden dependency; makes tests need reset/reinit hooks.
- **Constructors with 7–8 parameters** — the Builder code smell.
- **Memorizing patterns before having the problem** — "You are here to solve problems. Learn patterns as a side-effect."

## Key Takeaways
1. **Choose patterns when you choose architecture** — the architectural pattern prescribes most of them anyway.
2. **Learn patterns as a side-effect of solving problems**, and introduce them during TDD's **Refactor** step.
3. **Name the pattern out loud** — "this is an Adapter" — it's half the value: a shared team mental model.
4. **Always wrap external APIs in a named class** (Adapter). No exceptions in Stemmler's practice.
5. **Builders are for tests first** — especially contract/repository tests in Hexagonal architectures.
6. **Private constructor + static `create()`** is the default way to build a domain entity.
7. **Use the Four-Dimensional Lens on every new library** — role, layer, category, architecture.
8. **Skip patterns entirely if the app is small.** Introduce them only at repeated pain points, duplication, or tricky test setups.

## Connects To
- **Ch 17 (SOLID)** — Strategy realizes OCP; Adapter realizes DIP; Decorator realizes OCP + SRP.
- **Ch 18 (Structural/Behavioural Principles)** — Strategy *is* Encapsulate What Varies; Observer *is* the Hollywood Principle.
- **Ch 13 (Responsibility Driven Design)** — the six object stereotypes are Level 1 of the categorization hierarchy.
- **Ch 20 (Architecture)** — where the higher levels of the hierarchy (Hexagonal, MVVM, CQRS) live.
- **Ch 21 (DDD & DDDForum)** — the Repository, Factory, and Domain Event patterns in full production form.
- **Ch 22 (Advanced TDD)** — Builders and fixtures for test object/database construction (book ch. 75).
- **`claudie-ts-design-pattern` skill** — full GoF mechanics and TypeScript implementations.
