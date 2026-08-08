# Cheatsheet — Stemmler's design judgment

Decision rules, thresholds, and tells. One printed page to keep beside you.

---

## Decision rules — the core if/then logic

| When… | Do… | Because |
|---|---|---|
| Adding a feature touches many existing files | Fix the **structure** (vertical slices), not your discipline | That's an **OCP** failure at architecture level |
| An implementation throws `new Error("Not supported")` | Split the interface | **ISP** — the interface is fat |
| A subclass could violate the base contract | Enforce the invariant **in the base constructor** | LSP is kept by construction, not documentation |
| Core logic contains `new ConcreteThing()` | Define the interface in the core, inject the concrete | **DIP** — otherwise it's unmockable and vendor-locked |
| You can't decide if a class has one responsibility | Ask **"how many object stereotypes is it?"** | 3+ (or "I don't know") → refactor |
| You see duplication for the **second** time | **Leave it** | "A little duplication is 10× better than a wrong abstraction" |
| You see duplication for the **third** time | Refactor it | Rule of Three |
| You're about to write a comment | **Refactor first**; comment only if it can't be simplified | Code says *what/how*; comments say *why* |
| A name is getting very long | Look for the **conditionals it encodes** and split into methods | Long names are a design smell |
| You can't name a class | You probably haven't found the right **construct** | `Validator` was really a Value Object |
| A primitive carries a domain rule | Wrap it in a **Value Object** | Makes illegal states unrepresentable |
| An operation is expected to fail | **Return** a typed error (`Either`) | Errors ≠ exceptions |
| A dependency you don't own might fail | **Throw**/wrap in try-catch, convert to `ApplicationError` | Exceptions are accidental complexity |
| The consumer must fix something to proceed | **Throw immediately** — fail fast | No recovery path exists |
| You're stuck writing a test | Write it **backwards**: assert → act → arrange | Deciding verification first unlocks the design |
| You're stuck going red → green | Walk the **TPP** ladder from the simplest transformation | Constraint beats intuition |
| Test setup needs 6 mocks | You have a **coupling** problem, not a testing problem | Least Resistance |
| You must flip between feature folders to do one feature | Suspect **coupling** between features | Folder boundaries surface it |
| You mock infrastructure in unit tests | Add a **contract test** for every implementation | Transitivity is what licenses the mock |
| Inheriting untested legacy code | **Characterize** before you change | Lock in behavior first |

---

## Errors vs. Exceptions — the fork

```
Is the failure EXPECTED and in code we OWN?
├── YES → it's an ERROR
│         → model as a class implementing DomainError
│         → RETURN it in the Either failure union
│         → the consumer switches on error.constructor
└── NO  → it's an EXCEPTION (code/context we don't own)
          → wrap the I/O in try/catch
          → convert to an ApplicationError you own
          → generalize it at the API boundary (log the detail, hide it from consumers)
```
**Never**: return bare `null` · match on error message strings · `console.log` and throw.

---

## Thresholds & defaults

| Thing | Value |
|---|---|
| Method length | **5–10 lines max** |
| Method arguments | **2 max** |
| Class length | **50–100 lines**, 1–2 responsibilities |
| Instance variables per class | **2 max** (Calisthenics #8) |
| Files per package | **10–15 max** |
| Typical file size (Uncle Bob's data) | **200–500 lines** |
| Levels of indentation per method | **1** |
| Duplication before refactoring | **3 occurrences** |
| Iteration length | **2 weeks** (range 1–3) |
| Domain expert interview | **15–30 min**, rarely > 1 hour |
| Story point > 13 | **Split it** |
| Core subdomain effort | **~20% of value, ~5% of code, ~80% of effort** |
| Confidence after acceptance tests pass | **~95% of the time you should still lack some** → add integration/E2E |
| Constructor params before reaching for a Builder | **7–8** |
| Calisthenics rules per TDD iteration | **2–3**, not all nine |

---

## Story point table (Fibonacci)

| Pts | Confidence | Duration |
|---|---|---|
| 1 | Know exactly what to do, no dependencies | < 2 hours |
| 2 | Mostly know, almost no dependencies | ~half a day |
| 3 | Know some of it, some dependencies | < 2 days |
| 5 | Know very little, fair dependencies | 2–4 days |
| 13 | Don't know what to do *or* the dependencies | > a week → **split or spike** |

**Torn between two values? Estimate up.** · Can't estimate at all? → **merge**, **split**, or **spike**.

---

## Architecture cost ranking (1–5) — pick the cheapest that solves your problem

| Cost | Patterns |
|---|---|
| **2** | Monolith*, MVC |
| **2–3** | Serverless |
| **3** | MVP, MVVM, Layered, Client-Server |
| **3–4** | Hexagonal, Pub-Sub, CQRS, Cloud Computing |
| **4** | Microkernel, Event-Driven, Blackboard, Event Sourcing, P2P, **Microservices**, SOA, Space-Based |

\* *Monolith starts at 2 and silently becomes 4–5 if you never structure it.*

**Rules**: nothing above cost 3 without a specific problem demanding it · **prefer a well-structured modular monolith** until you have multiple autonomous teams · Stemmler's "top three" for distributed work: **Client-Server + Serverless + Cloud**, *not* microservices.

---

## Tells & smells — fast recognition

| If you see… | You're probably in… |
|---|---|
| A simple change forcing edits elsewhere | **Ripple** → under-abstraction, tight coupling |
| Too many layers/classes to hold in your head | **Cognitive load** → over-abstraction |
| `throw new Error("Not supported")` | ISP violation |
| `(obj as any)._privateField` | Inappropriate intimacy (coupler) |
| `switch` on a type field | OO-abuser smell + OCP violation |
| The same role check in many files | **Shotgun surgery** |
| `Manager`, `Processor`, `Helper`, `Utils` in a name | Missing construct / low cohesion |
| A method that mutates *and* returns | CQS violation |
| `a.getB().getC().do()` | Law of Demeter / Calisthenics #5 |
| A method doing something its name doesn't say | **Least Astonishment** violation |
| 5 steps to add a new feature | **Least Resistance** violation — fix the architecture |
| Getters + setters for every field | Anemic model; Tell-Don't-Ask violation |
| A `UserManager` doing everything to `User` | Anemic domain model (a *proximity* failure) |
| Test setup getting complicated | The production code is too clever (**KISS**) |
| No test demands a method | **YAGNI** violation — delete it |
| Execution-order dependency across services | Worst connascence: **dynamic + distant** |

---

## Connascence — is this dependency acceptable?

**Static** (compile-time, findable): Name → Type → Convention → Algorithm → Position
**Dynamic** (runtime, invisible): Execution Order → Timing → Value → Identity

**Rule**: strength × degree × **distance** = risk. Strong connascence *inside one function* is fine; the same across a service boundary is a liability. **Prefer static over dynamic always.**

---

## Which test, and where

| Testing… | Write a… |
|---|---|
| Value Objects, Entities, domain services | **Unit test** (seldom need mocks — if you do, the code isn't pure) |
| A feature / use case | **Acceptance test as a coarse-grained unit test** at the application layer |
| Input adapters (controllers, routes) | **Integration test** |
| Output adapters (repos, gateways) | **Integration test** + **contract test** |
| Queries, plus general confidence | **E2E** |
| Legacy code with no tests | **E2E characterization test** |

**Verification method**: pure I/O → **Result** · state accumulated over time → **State** · "did it try to call X?" → **Communication**.

---

## The daily fallback — Four Elements of Simple Design

When everything else is too much to recall:
1. **Runs all the tests**
2. **Expresses intent**
3. **No duplication**
4. **Minimal classes & methods**
