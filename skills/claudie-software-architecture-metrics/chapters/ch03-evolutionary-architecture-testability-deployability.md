# Chapter 3: Evolutionary Architecture — Guiding Architecture with Testability and Deployability

**Author**: Dave Farley

> Short chapter (~5 pages), argument-driven rather than technique-driven. Its value is the *reduction*: instead of tracking many architectural qualities, optimize two — testability and deployability — and the rest follow.

## Core Idea
Testability and deployability are the only two architectural properties worth optimizing directly, because designing for them forces the five attributes of good design (modularity, cohesion, separation of concerns, abstraction, managed coupling) and thereby keeps every *other* architectural option (security, scalability, resilience) open until you actually know you need it.

## Frameworks Introduced

- **The Five Attributes of Sustainable Change** — the design properties that let you keep your options open:
  - **Modularity** — dividing systems into parts that can change without forcing change in other parts.
  - **Cohesion** — keeping parts of the code that change together close together in the code.
  - **Separation of concerns** — each part of the code and system focused on solving one problem.
  - **Abstraction / information hiding** — creating "seams" that let you consume behaviour without understanding how other parts work.
  - **Coupling** — the degree to which separate parts need to change together.
  - **When to use**: as the standing scorecard for any design decision.
  - **Why it works**: these are properties of *information*, not of software or any technology. They say nothing about what a system does, so they apply universally.

- **Testability as an architectural property, not a testing concern.**
  - **When to use**: whenever you'd otherwise rely on team skill/experience/motivation to produce quality.
  - **How**: derive the requirement from what a test physically needs — access to the relevant part, in a well-defined state, invoke a behaviour, capture the response. Then:
    - need to isolate the unit → forces **modularity**
    - need cheap setup → forces **cohesion** and **loose coupling**
    - need to control variables and limit complexity → forces **separation of concerns**
    - need tests that survive code change → forces **abstraction** and hidden implementation detail
  - **The key insight**: *the attributes of testable code are identical to the attributes of code that is easy to work on and change.* So use the tests to guide the design.
  - **Why it works**: designing for testability **amplifies developer talent**. Relying on skill, experience, and commitment alone produces the five attributes far less reliably.

- **Deployability as the systemic-scale counterpart** (continuous delivery).
  - **Deployment pipeline** = the definitive evaluation of releasability. If the pipeline passes, the software is *by definition* safe to release; everything determining releasability must be inside its scope.
  - **Scope rule**: pipeline scope is "from commit to releasable outcome". If you must test more broadly with other components *after* the pipeline ends, your pipeline does not determine releasability in any meaningful sense.
  - **Correct pipeline scope is always an independently deployable unit of software** — a single microservice or a whole enterprise system. Deployability is the only definitive scope of evaluation.
  - **Determinism requirement**: evaluate *exactly* the code that will reach production, and make its behaviour as deterministic as possible, so a given version yields the same result every run.

## Key Concepts
- **Architecture as a tourist map** — architectural descriptions should let you navigate the space without being precise about details that will change.
- **Software architecture is important and ephemeral** — it determines scalability/performance/resilience, yet how we judge those qualities is vague and subjective.
- **Complex adaptive system** — the real system includes developers, users, customers, and their environments and organizational contexts; hence design must be dynamic, almost organic.
- **Write-only development** — building code or systems and not testing them; never produces quality beyond trivial, throwaway code.
- **Essential vs accidental complexity** — the drive for testability (especially) pushes engineers to separate these more effectively.
- **Releasability** — the property a deployment pipeline exists to determine, definitively.

## Mental Models
- Use **testability as a design amplifier**: if a thing is hard to test, that is a design report, not a testing inconvenience.
- **Begin before you have the answers.** Complex systems never spring fully formed from their creators' minds; stop trying to foresee how the system will be used and evolve.
- **Judge "quality attributes" by business maturity, not aspiration.** Scalability work for a three-user system is wasted; general-purpose security for an intranet-only app is wasted. Both are overengineering for needs that may never arise.
- Think of testability and deployability as **the two options-preserving investments**: with a modular, abstracted, well-factored system, added security is easy to add later, and resilience can be pursued with chaos testing when it's actually needed.

## Worked Example
**Swapping a relational database for a graph database.** Suppose you learn your system would be more efficient on a graph DB than an RDBMS.

- If you separated core domain logic from the concern of persisting its results — good separation of concerns, better modularity and cohesion, decent abstraction — you can unplug the RDBMS-backed repository and drop in a GraphDB repository with relative ease.
- If core domain and persistence are conflated, it becomes very hard *even to think of* making the move.

The decision that made the later change cheap was made early, and it was not a database decision — it was a separation-of-concerns decision, of exactly the kind that designing for testability would have forced anyway.

## Anti-patterns
- **Overelaborate future-proofing** — hampering development to pre-solve needs that may never arise; the mirror-image failure of building nothing extensible.
- **Optimizing for scalability/resilience/security ahead of evidence** — the degree each matters is a function of the business and the system's maturity.
- **Manual testing as the strategy** — slow, inefficient, expensive, unreliable.
- **Write-only development** — no tests; step away from the keyboard.
- **A pipeline that doesn't determine releasability** — one whose successful completion still requires broader integration testing before release.
- **Pipeline scope smaller (or larger) than an independently deployable unit.**
- **Relying on skill, experience, and commitment to produce quality** — any of the three missing sinks the result; design-for-testability is the systemic answer.

## Key Takeaways
1. Optimize two properties — testability and deployability — and let the other architectural qualities stay open.
2. The attributes of testable code *are* the attributes of changeable code; that equivalence is the whole argument.
3. Let tests guide design. Testability treated as an architectural property amplifies design quality.
4. A deployment pipeline's scope must be an independently deployable unit, from commit to releasable outcome.
5. Evaluate exactly the code that ships, and push toward determinism so results are repeatable per version.
6. Software development is learning and discovery: begin without all the answers, then protect your ability to change.
7. An engineering-led, evolutionary approach lets you start sooner and adapt to the needs actually in front of you.

## Connects To
- **Ch 1** (Harmel-Law): the four key metrics are how you *measure* progress on deployability and, indirectly, testability.
- **Ch 2** (Weiss): quality attributes and architectural tests operationalize the five attributes; chaos testing appears in the top pyramid layer.
- **Ch 4** (Lilienthal): the MMI measures modularity, hierarchy, and pattern consistency — the structural half of the five attributes.
- **Ch 8** (Ford): "engineering-led approach" is Ford's thesis about moving from metrics to engineering practice.
- **Continuous Delivery** (Farley/Humble) — deployment pipelines and releasability.
