# Chapter 13: Responsibility-Driven Design *(book ch. 32–34)*

## Core Idea
**Tests aren't design.** TDD reliably delivers *functional* requirements, but it won't produce clear, expressive, minimal abstractions or satisfy *non-functional* requirements on its own. Responsibility-Driven Design (RDD) fills that gap: convert requirements into **responsibilities**, group them into **roles**, then design how those roles **collaborate**. The six **object stereotypes** are the reusable vocabulary that makes this repeatable.

## Frameworks Introduced

- **Object Design = Analysis + Design + Programming** — *"Most developers think OO is just about programming, and that's a big mistake."*
  - **Analysis** — identify the requirements. Techniques: Event Storming, Event Modelling, Impact Mapping, Context Mapping, Design Stories, Use Case Diagrams, UI mockups (big picture); use-case pseudocode, BDD Given-When-Then, Example Mapping, UML sequence diagrams, rough sketches (detail).
  - **Design** — divide requirements into *neighborhoods of collaborating objects*, each with well-defined responsibilities. Output: **object candidates**. No production code yet.
  - **Programming** — translate roles/responsibilities/collaborations into classes and interfaces, inside a TDD loop.
  - Stemmler's fastest fix for OOP frustration: *"stop writing object-oriented code and learn object-oriented analysis and design first."*

- **Responsibility-Driven Design (RDD)** — Rebecca Wirfs-Brock, late 80s, modernized in *Object Design* (2002).
  - **Responsibility**: an obligation to **do** (a task/behavior) or **know** (some data).
  - **Role**: a collection of related responsibilities that can be used interchangeably.
  - **Collaboration**: an interaction between objects or roles. The one asking for help is the **client**; the one responding is the **collaborator**.
  - When to use: before writing the first test for any non-trivial feature.
  - Why it matters: RDD underpins DDD's tactical patterns, Clean/Hexagonal architecture, and most architectural patterns. **Design principles are a shortcut to RDD's philosophy.**

- **The Four Object Capabilities** — objects exist to:
  1. **Know information** (state)
  2. **Make decisions** (business rules, algorithms)
  3. **Advertise their services** (public methods)
  4. **Maintain connections to other objects** (composition, delegation)
  These four make abstraction, encapsulation, polymorphism, and inheritance possible.

- **Non-Functional Requirements, split two ways**:
  - **Execution qualities** — run-time/user-facing: usability, efficiency, correctness, reliability.
  - **Evaluation qualities** — make code easier to work with: maintainability, testability, flexibility.
  - Find NFRs *early* — new ones can force architectural change.

- **CRC Cards** (Ward Cunningham & Kent Beck) — the design artifact:
  - Top: **class** name. Left: **responsibilities**. Right: **collaborators**.
  - *"Not something you need to stay faithful to."* Use paper, markdown, a whiteboard, or the draw.io VS Code extension so designs can be checked into source control.

## The Six Object Stereotypes *(the highest-leverage framework in the chapter)*

| # | Stereotype | Stereotypical responsibility | Typical realizations | Usual layer |
|---|---|---|---|---|
| 1 | **Information Holder** | Hold information | Value Object, Entity, DTO | Domain |
| 2 | **Structurer** | Create and maintain relationships between objects; protect invariants | Aggregate, hash table, cache, connection pool | Domain |
| 3 | **Service Provider** | Sit passive, contain specialized computation | `DateUtil`/`TextUtil` (**stable**), **Domain Services** (*pure fabrication*), cross-cutting concerns (logging, security, tracing) | Anywhere — usually Rules/Processes |
| 4 | **Coordinator** | Pass information to other objects so they can do work | Orchestrators | Application |
| 5 | **Controller** | Higher-level, declarative object that coordinates lower-level concerns | **This is exactly the Use Case pattern** | Application |
| 6 | **Interfacer** | Bridge between object neighborhoods | Internal: facade/entry-point. External: **Gateway**. UI: **Event Listener** (in) / **Presenter** (out) | Infrastructure (ports & adapters) |

**Placement rules that fall out of this** (the shortcut to a candidate architecture):
- **Interfacers** are always in the infrastructure layer, as ports & adapters.
- **Controllers & Coordinators** are always application-oriented.
- **Information Holders** are almost always domain-oriented.
- **Service Providers** can go anywhere, but focus on *Rules* or *Processes*.

**Considerations**: an object *can* span stereotypes — a `Repository` that also caches is **Interfacer + Structurer**. Use "what stereotype is this most like?" to decide whether responsibilities are misplaced.

## Mental Models
- **"Objects come and go, filling in roles."** Like a restaurant manager who needs *a Server* — not Molly, Sam, or Frank specifically. Contractualize responsibilities into a **role** (interface/abstract class/type) and any object that fills it will do. **This is the foundation of effective polymorphism.**
- **The relationship is "played by," not "is a."** Borrowed from role-oriented programming.
- **Object models violate real-world physics.** *"We have a license to reinvent the world, because modeling the real world in our machinery is not our goal."* Model **only what is 100% necessary to meet the requirements** — modelling into oblivion is the classic trap.
- **"All models are wrong. Some are useful."** — Wirfs-Brock.
- **Collaborations "raise the IQ of the whole neighbourhood."**
- **Divergence & convergence**: there are infinite ways to make $1M; only a few ways to make $1M selling hotdogs. *Starting with a test constrains the design immediately* and sets a vector for success.
- **Design is about closing the gap.** You either **invent** objects or **integrate** them (libraries, frameworks, engines, CMSes). Choosing a drag-and-drop library *is* an RDD decision — you're integrating a role that carries responsibilities you need.

## Techniques

**Finding roles**: don't just "look for the nouns" — that only surfaces *domain* roles and misses the programmer-specific machinery. **Use the six stereotypes as a checklist instead.**

**Finding collaborations** (the hardest part of RDD):
- For a responsibility for **doing**: ask *"what role or object helps with this task?"*
- For a responsibility for **knowing**: ask *"what roles or objects need to know this information?"*
- Expect new responsibilities and roles to emerge as you do this — that's the process working.

## Worked Example — The house-bot, end to end

**1. Design Story** (always start here):
> The house-bot gradually learns the layout of the house. If you're in a room with him, you can say "house-bot" — he'll look at you and light up. Then you say "this is the kitchen"; he blinks and says "gotcha, this is the kitchen" and learns it. He can be told "go to the kitchen." He doesn't bump into walls while moving.

**2. Extract responsibilities** (doing **and** knowing):
- Knowing how to get to a certain room
- Turning left and right; moving backwards/forwards
- Taking pictures → `Picture` (*Information Holder*, guess) / `takePicture` (*Controller/Use Case*, guess)
- Composing a layout from pictures; creating a room layout; connecting rooms via halls
- Knowing when we've moved into another room; updating the house layout
- Listening for voice; detecting the "house-bot" wake command
- Blinking; playing back audio in response; playing back "I didn't understand"

**3. Divvy responsibilities into roles**:
`PathFinder`, `Path`, `CommandController`, `RoomLayout`, `Home`, `Blinker`, `Microphone`, `UseCase` (generic), `NameRoom` (use case), `ChangeRoom` (use case), `Wheels`, `Motor`

**4. Find collaborations** — ask "what role needs to know about `Path`?" → the `ChangeRoom` use case. Working through its pseudocode reveals it must also *coordinate* several objects to change rooms — and coordination is itself a new responsibility, one a **Use Case** typically owns.

> The list will grow. That's fine: *"we've started to become explicit about what's actually required. The low-level details emerge. Suddenly we're dealing with less obscurity."*

## Worked Example — Checkers, stereotype-mapped

Same process on a React + MobX + drag-and-drop checkers game. After brainstorming candidates, apply the stereotypes:

| Candidate | Stereotype | → Layer |
|---|---|---|
| `Game` | Controller / Coordinator | Application |
| `Board` | Structurer (organizes squares & pieces) | Domain |
| `Square` | Information Holder (location, occupancy) | Domain |
| `Piece` | Information Holder (+ minimal logic: "kinged?") | Domain |
| `MoveValidator` | Service Provider (rule-checking) | Domain (Rules) |
| `Logger` | Service Provider / Interfacer | Infra |
| `DragManager` | Interfacer (bridges React DnD ↔ domain) | Infrastructure |

**The payoff**: cross-referencing stereotypes against the stereotypical architecture *maps out the entire candidate architecture* — and shows at a glance where an object is mixing too many concerns.

Collaboration sketch:
```
+-------------+   (client)        +------------------+ (collaborator)
|   Game      |     movePiece()   |  MoveValidator   |
| (Controller)|    ----------->   | (Service)        |
+-------------+                   +------------------+
     |  calls
     v
+-------------+
|   Logger    |
+-------------+
```

NFRs declared up front for this project: **Testable** (game logic in isolation, no UI), **Maintainable** (easy to tweak rules), **Flexible** (may become networked multiplayer).

## Anti-patterns
- **Doing OOP without OOAD** — "like a kid building a treehouse with a bucket of nails."
- **Striving for realism in models** — modelling engines, carburetors, and ignition sparks when the requirements never asked. Harmful, not thorough.
- **"Look for the nouns"** as the only role-discovery technique — misses application and infrastructure machinery entirely.
- **Treating tests as a substitute for design** — TDD gives you working code and no duplication; it does *not* give you expressive, minimal, low-coupling abstractions.
- **Starting from code and working toward the problem** — the wrong direction; it takes longer.
- **Objects invented "out of thin air"** — RDD's core discipline: there's always a reason for an invention.

## Key Takeaways
1. **Convert requirements → responsibilities → roles → collaborations.** That's the whole method.
2. **Use the six stereotypes as your role-discovery checklist** — and as an instant map to the right architectural layer.
3. **Controller ≡ Use Case.** Same thing, different vocabulary.
4. **Design happens away from the editor** — CRC cards, whiteboards, markdown. Get it out of your head and onto paper.
5. **Model only what the requirements demand.** Realism is not the goal; usefulness is.
6. **Ask "what stereotype is this?"** whenever a class feels wrong — mixed stereotypes mean misplaced responsibilities.
7. **Integrating a library is a design decision**, not a shortcut around one — you're filling a role with someone else's object.
8. **Find NFRs early**, and split them into execution vs. evaluation qualities so you know what you're optimizing.

## Connects To
- **Ch 17 (SOLID)** — stereotypes are the practical test for SRP; roles are what LSP substitutes.
- **Ch 14 (Object Calisthenics)** — the mechanical rules for tightening RDD designs during refactoring.
- **Ch 15 (Code Smells)** — Strategy #2 for preventing smells is "object role stereotypes."
- **Ch 16 (Design Patterns)** — stereotypes are Level 1 of the pattern categorization hierarchy; the Four-Dimensional Lens starts here.
- **Ch 21 (DDD)** — Value Objects/Entities are Information Holders; Aggregates are Structurers; Domain Services are Service Providers (pure fabrications); Repositories are Interfacers.
- **Ch 12 (TDD)** — Mockist TDD requires thinking in roles, responsibilities, and collaborations.
- **Ch 08 (Features/Use Cases)** — the use-case-driven mindset RDD builds on.

## References
- *Object Design: Roles, Responsibilities, and Collaborations* — Rebecca Wirfs-Brock & Alan McKean
- *Growing Object-Oriented Software, Guided by Tests* — Freeman & Pryce
