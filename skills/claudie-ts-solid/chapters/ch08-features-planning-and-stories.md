# Chapter 08: Features (Use Cases), Planning, Stories & Estimates *(book ch. 13–21)*

## Core Idea
**Feature = use case**, and the use case is the atomic unit of everything: what you discover, plan, estimate, test, and organize around. *"Use cases transform software development from being a creative, lofty, I'm-not-sure-when-I'm-quite-done kind of thing into a definite, formal, focused practice which can be mastered."*

## Frameworks Introduced

- **Feature = Use Case** — used interchangeably; *use case* is the more technically correct term (Alistair Cockburn, *Writing Effective Use Cases*, 2000). It may also appear as a user story, a **command** (`CreateUser`, `EditUser`), or a **query** (`GetUserById`).
  - The discipline this creates: **sniff use cases out of conversations with customers**, recognize when you're **writing pointless code not backed by a use case** (pure accidental complexity), and write use cases as **acceptance tests**.

- **The Anatomy of a Feature** — **Data + Behaviour + Namespace**. The **four types of data**:
  1. **Input data** — what is *necessary and sufficient* to execute the feature. For `upvotePost`, pass `postId` and `memberId` — **not** `Post` and `Member`. You need the objects for business logic, but you offload *retrieving* them (via the **Repository pattern**).
  2. **Dependencies** — other objects/functions with specific capabilities: fetching and persisting, checking existence, connecting to external services.
  3. **Output data** — the success result.
  4. **Output events** — what the feature emits.
  - *Inspired by Scott Wlaschin's input/output-first approach in* Domain Modeling Made Functional.

- **The Lifecycle of a Feature** — the shapes a feature takes from conversation to production:
  **Discovery → Planning → Estimation → Architecture → Acceptance tests → Design & implementation**
  - **Discovery**: scope roughly what the customer wants; learn the domain via **Event Storming/Modelling** with customers, domain experts, and developers in one room. Output: features (called **stories** at this stage) plus key problem areas. When uncertain about an estimate, **spike** it — time-boxed research to produce a proper estimate.

- **The Bill of Rights** (Fowler, Beck, Martin — *Planning Extreme Programming*):
  > *"When our fears are acknowledged and our rights are accepted, then we can be courageous."*

  **Customers have a right to**: know the plan, the timeline, and the cost · choose the stories yielding the most value each week · be informed of schedule changes **in time to reduce scope to hit the original date** · see current progress in a running system at any point, measured by **automated acceptance tests they specified** · **cancel at any time and be left with a useful working system** reflecting the investment to date · change their mind, swap functionality, and rearrange priorities without unreasonable cost.

  **Developers have a right to**: know what tasks need doing and their priority · **carry out technical practices that yield quality work, always, at all times** · ask for and receive help from peers, managers, and customers.

- **The Three Purposes of Planning**: **Prioritize** (do the most important stories first) · **Coordinate** (keep everyone synced) · **Recalibrate** (get back on track when you drift).

- **Two Stages of Planning**: the **initial plan** (inaccurate and flaky — no history to estimate from) and **continuous planning** (everything after).
  - **Scoping a project** uses four inputs: **Epics** (the big stories) · **Prices** (very rough estimates) · **Budgets** (how many people) · **Constraints** (is a domain expert reachable and available?). *Don't dedicate too much time to this* — the goal is to get the ball rolling and produce better estimates during continuous planning.
  - Then: negotiate the first release plan → execute it → **measure velocity**.

- **INVEST — story-writing principles**:

| Letter | Principle | Note |
|---|---|---|
| **I** | **Independent** | You *could* implement `Logout` before `Login`. **If acceptance tests assemble their own pre-conditions (the state of the world), all stories can be written independently.** Business-side dependencies are more real than technical ones |
| **N** | **Negotiable** | Everything up to (but not including) the acceptance test is negotiable — the story, the estimate. *"Just like an estimate isn't contractual, neither is a user story"* |
| **V** | **Valuable** | Must provide value |
| **E** | **Estimable** | |
| **S** | **Small** | Prefer short stories |
| **T** | **Testable** | |

- **Story Points (Fibonacci)** — the concrete estimation table:

| Points | Meaning |
|---|---|
| **1** | We know what to do, no dependencies, **< 2 hours** |
| **2** | We mostly know what to do, almost no dependencies, **~half a day** |
| **3** | We know some of what we need to do, some dependencies, **< 2 days** |
| **5** | We know very little, a fair amount of dependencies, **2–4 days** |
| **13** | We don't know what to do or even what the dependencies are, **> a week** |

  > **When torn between two values, it's generally safer to estimate up than down.**

- **Refactoring stories** — when a story is hard to estimate, it's one of four things:
  - Too small → **merge**
  - Too big → **split**
  - Contains both functional and non-functional requirements → **split**
  - Uncertainty → **spike**

- **Team estimation techniques**: **flying fingers**, **planning poker**. Plus ways to handle non-unanimous estimates.

- **Iteration size**: 1–3 weeks, **2 weeks is the sweet spot** for most teams. *Longer = more chance to get off track. Shorter = more replanning overhead at cycle boundaries.*

- **Plan stability**: *"Is the release plan stable? Heck no."* Four things change it: the customer changing requirements/priorities · developers learning something new about a story · velocity changing · stories added or removed. **Treat the release plan as a snapshot of what you're currently shooting for.**

## Interviewing the Domain Expert — the three rules

*"But domain experts are busy!"* — Yes, but **stories are such small slices that interviews take 15–30 minutes, rarely more than an hour.** Prefer face-to-face or video.

1. **Listen and ask questions more than you speak** — the domain expert's point of view is what ultimately goes into production.
2. **Avoid jumping to technical conclusions** — don't start database-first, API-first, or class-first. That **corrupts the domain with unnecessary technical details**. DDD is *persistence ignorant, technology ignorant,* and *paradigm ignorant*.
3. **Avoid technical language** — *"Domain experts don't know what floats or observables are."* Speak the ubiquitous language.

> Note the term for whoever writes the ticket: the **requirements jockey** (project manager, engineering manager, or another customer representative). Even with a well-written ticket, **you still interview**.

## Worked Example — Documenting with pseudocode

Instead of UML and formal use-case diagrams (*"expensive, hard to change, understand, and work with"*), use **pseudocode** — a lightweight text format learned from **Scott Wlaschin**. It's understandable to the customer *and* forces you to surface nuances your Event Storming session missed.

**Three artifacts**: a **Feature Summary**, **Domain Primitives**, and the **Use Case Algorithm**.

```
# Feature summary
Feature: <Name of feature>
    Namespace:
        Subdomain: <Name of subdomain>
    Data:
        Input data:
            <All input data>
        Dependencies:
            <All dependent operations or services>
        Output (events and results):
            Success:
                <Success event>
            Failure:
                <All failure results>
    Behavior:
        Triggered by:
            <Triggering event or the role of the actor who triggers it>
        Side-effects:
            <...>
```

**The three documentation steps**:
1. **Get a high-level understanding of the entire workflow** — input and output data; success states, failure states, and dependencies; **probe edge cases with hypothetical scenarios**.
2. **Document the domain primitives (data types)** — constraints, variants, and state machines.
3. **Document the steps** — the **use case algorithm** at the highest level of abstraction, then sub-steps.

Notice the shape: `Success` / `Failure` maps directly onto the **one happy path, multiple sad paths** model from the errors chapter, and the failure list becomes your `Either` union.

## Other frameworks in this part

- **Customers** (ch. 15): the customer *makes business decisions*, is a *domain expert*, *must be available for questions*, is *responsible for the success or failure of the project*, and is **often an entire team**. There's a distinction between **driving** and **steering**.
- **Learning the Domain** (ch. 16): **Event Storming** in five steps — plot domain events → sort chronologically → push events to the edges → identify **commands** → identify **aggregates** (optional) → decompose to **subdomains** with **context maps** → use the **ubiquitous language** everywhere.
- **Story formats**: the **command/query format**, and *"As a [role], I want [feature], so that [value]."* Non-functional requirements get their own story format.
- **Release planning**: order stories, pick iteration size, plan for regular rebuilds and bugs, **walk the skeleton**, run an **iteration zero** (zero-functionality iteration) or a **pizza party / mob programming iteration**.
- **Iteration planning**: understand the story → list the tasks (including technical tasks) → **sign up for tasks** → track the iteration plan.

## Anti-patterns
- **Writing code not backed by a use case** — by definition, accidental complexity.
- **Passing whole domain objects as use case input** — pass IDs and let the Repository fetch; keeps the use case cohesive.
- **Treating estimates or user stories as contracts** — they're negotiable by design.
- **Running an acceptance test *through* other stories** to set up state — that's what makes stories look dependent; assemble pre-conditions directly.
- **Jumping to database-first / API-first design in a domain interview** — corrupts the domain model.
- **Using technical language with domain experts.**
- **Skipping the interview because the ticket looks detailed** — the requirements jockey isn't the domain expert.
- **Long iterations** — more room to drift off track.
- **Estimating down when uncertain** — estimate up.

## Key Takeaways
1. **The use case is the unit of everything** — discovery, planning, estimation, folder structure, tests.
2. **Input data should be necessary and sufficient** — IDs in, repository fetches, domain objects used inside.
3. **INVEST's "Independent" is achievable** if your acceptance tests build their own world.
4. **Use the Fibonacci table literally** — the point values map to concrete confidence and duration; estimate up when torn.
5. **Merge, split, or spike** any story you can't estimate.
6. **Interviews are 15–30 minutes** — the "experts are too busy" objection dissolves when stories are small.
7. **Document with pseudocode, not UML** — customer-readable and it surfaces edge cases.
8. **The release plan is a snapshot**, and everyone must accept that.
9. **The Bill of Rights is a working agreement** — especially the developer right to *carry out quality technical practices at all times*.

## Connects To
- **Ch 03 (Organizing Things)** — features are vertical slices and the basis of folder structure.
- **Ch 09 (Acceptance Tests)** — where the use case becomes an executable Given-When-Then spec.
- **Ch 07 (Errors)** — "one happy path, multiple sad paths" is the feature's output shape.
- **Ch 21 (DDD)** — Event Storming, subdomains, ubiquitous language, and the Use Case pattern in code.
- **Ch 11 (The Walking Skeleton)** — how release planning starts.
- **Ch 13 (RDD)** — the Controller stereotype *is* the Use Case pattern.
- **Ch 01 (Complexity)** — the features are the essential complexity.

## References
- *Writing Effective Use Cases* — Alistair Cockburn (2000)
- *Domain Modeling Made Functional* — Scott Wlaschin
- *Planning Extreme Programming* — Beck & Fowler
- *User Stories Applied* — Mike Cohn
