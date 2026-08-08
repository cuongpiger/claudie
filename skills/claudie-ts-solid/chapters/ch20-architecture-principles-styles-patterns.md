# Chapter 20: Architectural Principles, Styles & Patterns *(book ch. 49–55)*

## Core Idea
Architecture is **structure**; patterns and domain logic are **content**. Picking a style sets the floor plan; you fill it with domain logic. Six common principles anchor every style, four styles (structural, message-based, distributed, space-based) each host several patterns, and every pattern carries an explicit **cost ranking (1–5)** you weigh against your context.

## Part A — The Six Common Architectural Principles

- **1. Vertical Boundaries (Vertical Slicing)**: *build an end-to-end path for each feature* — UI/entrypoint → domain logic → infrastructure. **Each user story forms one slice.**
  - Problem it solves: "MakeOffer" logic scattered across `utils/`, `controllers/`, and `db/` — nobody can see the feature end-to-end.
  ```
  A[Frontend/UI: MakeOffer button] --> B[API/Controller: /offers/make]
  B --> C[Domain: OfferService.makeOffer(...)]
  C --> D[Infra: OfferRepo.save(...)]
  D --> E[Database]
  ```

- **2. Horizontal Boundaries (Layers)**: UI/Presentation, Application/Domain, Infrastructure.
  - Combined with vertical slicing you get **a grid**: each feature (vertical) spans each layer (horizontal). That grid *is* the architecture.

- **3. Contracts**: an interface describing **what** a module does, not **how**. The mechanism behind Dependency Inversion.
  ```typescript
  interface PaymentProcessor { processPayment(orderId: string): void; }
  class StripeProcessor implements PaymentProcessor { /* ... */ }

  class OrderService {
    constructor(private paymentProc: PaymentProcessor) {}   // free from details
    checkout(orderId: string) { this.paymentProc.processPayment(orderId); }
  }
  ```

- **4. Cross-Cutting Concerns**: tasks spanning multiple slices/layers that must not be duplicated — auth, logging, auditing, transaction management. Handle **globally or via wrappers** (middleware / aspect-oriented).
  ```typescript
  function authMiddleware(req, res, next) {
    if (!req.headers["auth"]) return res.status(401).json({ error: "Unauthorized" });
    next();
  }
  app.post("/offers", authMiddleware, logMiddleware, (req, res) => {
    // just the domain logic
  });
  ```

- **5. The Dependency Rule**: **inner (domain) layers never depend on outer (infrastructure) layers.** Domain depends on contracts; outer layers implement them.
  ```typescript
  interface OfferRepo { saveOffer(o: Offer): void; }        // domain contract
  class MongoOfferRepo implements OfferRepo { /* real Mongo */ }  // infrastructure
  class OfferService { constructor(private repo: OfferRepo) {} }  // inner layer
  ```

- **6. Conway's Law**: *"Organizations which design systems… are constrained to produce designs which are copies of the communication structures of these organizations."* — Melvin Conway.
  - Actionable form: if you have a Payments Team and a Shipping Team, your architecture needs matching module or service boundaries, or you get merge conflicts and coordination friction.

**Putting it together** — the result is a system that is: feature-focused (vertical), layered (horizontal), swappable (contracts), unified (cross-cutting handled once), domain-driven (dependency rule), and team-aligned (Conway).

## Part B — Reference Table: every pattern, cost, and when to use

**Cost ranking is 1–5 (higher = more complexity/overhead).** This is the single most decision-useful table in the book.

### Structural style
| Pattern | Cost | Use when | Avoid when |
|---|---|---|---|
| **MVC** | 2–3 | CRUD apps with UI logic distinct from domain; medium/large projects | Small prototypes (raises cost to 3 if hand-rolled) |
| **MVP** | ~3 | UI frameworks without data binding; you want a **fully passive View** (easy to test); desktop/older mobile | Reactive/data-binding suits better; trivially small apps |
| **MVVM** | ~3 | Rich UI needing two-way binding or near-real-time updates; framework natively supports it (WPF, Angular, Vue) | Simple/small UIs — more pattern than needed |
| **Monolith** | ~2 | New projects, small teams, fast iteration, minimal devops, tight deadlines | ⚠️ Cost rises to **4–5 later** if you never structure it |
| **Layered** | ~3 | Typical business apps; classic recognizable layers; corporate/enterprise | Tiny projects — "too much ceremony" |
| **Hexagonal (Ports & Adapters)** | 3–4 | **Complex domain needing pure, testable logic**; you expect to swap infrastructure | Small/quick projects with no infra change expected |
| **Microkernel** | ~4 | A platform/framework needing plug-ins; stable core + highly variable rest (IDEs, heavily customized products); dynamic module loading | Simpler apps — overhead is high |

### Message-based style
| Pattern | Cost | Use when | Avoid when |
|---|---|---|---|
| **Event-Driven** | ~4 | Complex domain with multiple side-effects; avoid a single orchestrator; growth expected; high concurrency | Simple flows with a few steps — direct calls are simpler |
| **Publish-Subscribe** | 3–4 | Multiple components need the same events; new consumers expected later; large scale | Smaller systems. **3 if your team knows message brokers, 4 if not** |
| **Blackboard** | 4 | No single module can solve the problem (complex scheduling, tutoring, decision support); collaborative components; iteratively refined solutions | Anything simpler |
| **CQRS** | 3–4 | High read traffic + complex domain writes; specialized read views (analytics, front-end queries) differing from domain structure | Smaller apps — overkill. (4 if full-blown with separate DBs + event sourcing; 3 for moderate usage) |
| **Event Sourcing** | ~4 | **Audit-critical** systems (financial, trading, healthcare); complex state changes needing replay; async decoupling | Simpler apps — event store, ordering, and schema evolution are real work |

### Distributed style
| Pattern | Cost | Use when | Avoid when |
|---|---|---|---|
| **Client-Server** | 3 | Data-centric apps needing a central DB and unified business logic; centralized security; consistent UX | Offline-first scenarios |
| **Peer-to-Peer** | ~4 | Decentralized systems (file sharing, blockchain); a central server would bottleneck; equal-contribution nodes | Most business apps |
| **Microservices** | 4 | Many distinct business domains needing independent scaling/deploy; **multiple autonomous teams**; heterogeneous tech | Simpler projects — overhead is excessive; without operational maturity, a well-structured monolith is more practical |
| **Service-Oriented (SOA)** | 4 | Large enterprises with distinct departments; interoperability across platforms/standards; long-term evolution | Anything without ESB/governance investment |
| **Serverless** | 2–3 | Variable/unpredictable workloads; prototyping and startups; stateless event-triggered functions; rapid iteration | Consistent high load — can cost more than reserved infra |
| **Cloud Computing** | 3–4 | Variable traffic; global user base; rapid prototyping; leveraging managed services | Watch for vendor lock-in and unexpected charges |

### Space-based style
| Pattern | Cost | Use when | Avoid when |
|---|---|---|---|
| **Space-Based** (in-memory data grid) | 4 | Extreme concurrency bursts (flash sales, ticketing); real-time low-latency (trading, games) | Low-traffic apps; **strong consistency is non-negotiable** |

> **Stemmler's "Top Three" for distributed systems**: most teams starting out will work with **Client-Server + Serverless + Cloud Computing** — not microservices.

## Part C — Component & Structural Principles (packaging)

| Principle | What it says |
|---|---|
| **Reuse-Release Equivalence** | The unit of reuse is the unit of release |
| **Common Closure Principle (CCP)** | Classes that change together belong together |
| **Common Reuse Principle (CRP)** | Classes reused together belong together; don't force consumers to depend on what they don't use |
| **Stable Dependency Principle** | Depend in the direction of stability |
| **Volatile Components** | Isolate the parts that change often |

## Part D — Principles of Economics & Strategy

- **The Principle of Opportunity Cost**: *every design decision carries the benefit you forgo elsewhere.*
  - Helps with: prioritization ("good enough" now vs. fancy later), avoiding over-engineering, resource allocation.
  - Pitfalls: over-emphasis on speed cuts corners; under-investing in robustness costs later.

- **The Principle of Last Responsible Moment (LRM)**: *delay a critical design decision until further postponement would create significant risk or cost.*
  - Helps with: informed decisions (less rework), flexibility, risk mitigation.
  - Pitfalls: **decision paralysis**, last-minute rushing, disrupted agile cycles.
  - In practice: defer the third-party API choice until you have concrete usage and performance data.

- **The Walking Skeleton**: *an extremely minimal but end-to-end implementation that stitches together every major architectural component* — UI → business logic → persistence — even with trivial functionality.
  - Helps with: early validation of the whole infrastructure, risk reduction, incremental development, and **establishing the automated E2E test rig** that grows with the system.
  - Pitfalls: **oversimplification** (masks issues that appear with complexity), **false sense of security**, misplaced focus away from domain logic.

## Worked Example — The Walking Skeleton in practice

For a new web application, the skeleton is a "ping" route that verifies:
1. A front-end page can load.
2. The page makes a simple API call (returning a `"hello"` message).
3. The backend successfully connects to a test database — data can be stored **and** retrieved.

This delivers **zero business value** — and that's the point. It proves the whole architecture can be deployed and can interoperate *before* you invest in features, and it leaves behind a working build-test-deploy pipeline.

**Why it matters economically**: it converts unknown integration risk (the most expensive kind of surprise) into a known quantity on day one — which is exactly the Opportunity Cost principle applied to risk.

## Anti-patterns
- **Domain code importing concrete infrastructure** (`new MongoDBConnection()` inside a service) — Dependency Rule violation; untestable without a real DB.
- **Duplicating auth/logging in every controller** — cross-cutting concern not extracted; guaranteed to be forgotten somewhere.
- **Organizing by technology instead of feature** (`utils/`, `controllers/`, `db/`) — vertical-boundary violation; you can never see a feature whole.
- **Microservices without operational maturity or multiple teams** — cost 4 with none of the benefits; a structured monolith is more practical.
- **An unstructured monolith** — starts at cost 2, silently becomes 4–5. The low starting cost is conditional on discipline.
- **Architecture that ignores team structure** — Conway's Law will win; you'll get the org's shape whether you designed it or not.
- **A walking skeleton kept too trivial for too long** — masks the integration issues it exists to expose.

## Key Takeaways
1. **Vertical slices × horizontal layers = a grid.** Every feature spans every layer; that's the architectural skeleton.
2. **Cost ranking is the decision tool** — nothing above cost 3 is justified without a specific problem demanding it.
3. **The Dependency Rule is the single most load-bearing principle** — it's what makes domain logic testable.
4. **Conway's Law is a design constraint, not trivia** — align module boundaries with team boundaries.
5. **Prefer a well-structured monolith** until you have multiple autonomous teams and real independent scaling needs.
6. **Client-Server + Serverless + Cloud** covers most teams' distributed needs. Microservices are not the default.
7. **Use LRM to defer irreversible choices** — but set a deadline so it doesn't become paralysis.
8. **Build the walking skeleton first.** It proves the architecture and gives you the test rig.
9. **Structure vs. content**: the style is the floor plan; design patterns and domain logic are what you put in the rooms.

## Connects To
- **Ch 17 (SOLID)** — the Dependency Rule is DIP at architectural scale; Contracts are ISP + DIP.
- **Ch 19 (Connascence)** — the *locality* axis is the technical argument for/against distributing a system.
- **Ch 16 (Design Patterns)** — architectural patterns are Level 4 of the pattern categorization hierarchy; each prescribes its own patterns.
- **Ch 13 (RDD)** — the stereotypical architecture (Domain/Application/Infrastructure) is the horizontal layering here.
- **Ch 21 (DDD & DDDForum)** — Hexagonal + Layered + CQRS + Modular Monolith applied to a real project.
- **Ch 03 (Organizing Things)** — feature-driven folder structure is vertical boundaries made concrete.
- **Ch 11 (The Walking Skeleton)** — book ch. 26 covers the technique in depth.
