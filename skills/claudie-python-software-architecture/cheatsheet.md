# Cheatsheet — Percival & Gregory's Decision Rules

## The gate: should I use any of this at all?

| If… | Then… |
|---|---|
| The app is a CRUD wrapper around a DB and won't be more | **Use none of it.** "Go ahead and use Django, and save yourself a lot of bother." |
| Reads and writes act on the same conceptual objects | Skip CQRS. ORM + read methods on repositories is *just fine* |
| Domain complexity is rising | Cost-of-change curves cross — start paying the abstraction tax |
| You have exactly one adapter | Skip DI. Pass the UoW by hand |
| You're not sure | **Add patterns reactively**, when the pain appears — never on principle |

## Where does this code go?

```
Is it "how do I talk HTTP/Redis/CLI?"     → entrypoints/    (primary adapter)
Is it "how do I talk to Postgres/SMTP?"   → adapters/       (secondary adapter)
Is it "what steps does this use case take?" → service_layer/handlers.py
Is it "what is the business rule?"        → domain/model.py
Is it "what happened?"                    → domain/events.py   (past tense)
Is it "what should happen?"               → domain/commands.py (imperative)
Is it "how do I read this?"               → views.py
```

## Entity or value object?

| Test | Answer |
|---|---|
| Change an attribute — is it a *different thing*? | **Value object.** `@dataclass(frozen=True)` |
| Change an attribute — is it the *same thing*? | **Entity.** `__eq__` on the reference only |
| Litmus | `Name("Harry",…)` → `Name("Barry",…)` is a different name. A `Person` who changes name is the same person |

## Command or event?

| | Command | Event |
|---|---|---|
| Name | Imperative — `Allocate` | Past tense — `Allocated` |
| Handlers | Exactly **one** | **Many** |
| On exception | `log` + **`raise`** | `log` + **`continue`** |
| Aggregates modified | **One**, all-or-nothing | One per handler |
| Must succeed for the user's request? | **Yes** | No |
| Registry type | `Dict[Type, Callable]` | `Dict[Type, List[Callable]]` |

**Rule**: "When a user wants the system to do something → a **command**, modifying a single aggregate, succeeding or failing in totality. Any other bookkeeping, cleanup, and notification → an **event**."

## Which test level? (high gear vs low gear)

| Situation | Level | Why |
|---|---|---|
| New project, or a gnarly problem | **Domain tests** (low gear) | Max design feedback; overcome inertia |
| Adding a feature, fixing a bug | **Service-layer tests** (high gear) | Lower coupling, higher coverage |
| Proving the parts are glued together | **One E2E per feature** | Nothing else |
| All the unhappy paths | **One** E2E test total + many unit tests | Handle errors uniformly at the entrypoint |

**Threshold**: a healthy pyramid looked like **15 unit / 8 integration / 2 E2E**. If E2E is growing, you're building an ice-cream cone.
**Rule**: "Every line of code in a test is a blob of glue holding the system in a particular shape." Delete domain tests once the service layer covers the behavior.

## Choosing an abstraction — the four questions (Ch3)

1. Can I choose a familiar **Python data structure** to represent the messy system's state, and imagine a single function returning it?
2. Where's the **seam** — where can I draw a line and slide the abstraction in?
3. What **implicit concepts** can I make explicit?
4. What are the **dependencies**, and what is the **core business logic**?

**Tell**: *"If it's hard to fake, the abstraction is probably too complicated."*
**Tell**: if you can't describe a function without "then" or "and", you're violating the SRP.

## Sizing an aggregate

| Ask | Then |
|---|---|
| Do these two objects share an invariant? | If no → **must not** share a boundary (`DEADLY-SPOON` and `FLIMSY-DESK`) |
| Is the boundary as small as possible? | Smaller = better performance |
| Does it have a ubiquitous-language name? | If it's `GlobalSkuStock`, keep bikeshedding until it's `Product` |
| Are there bidirectional links? | 🚩 Your aggregates are wrong. Replace references with IDs |
| Does one use case update two aggregates atomically? | 🚩 Your consistency boundary is wrong |

## Repository query smell test

| Query | Verdict |
|---|---|
| `get(sku)` → one aggregate | ✅ |
| `get_by_batchref(ref)` → one aggregate | ✅ |
| `get_most_popular_products()` | 🚩 Spidey sense — you want a read model |
| `find_products_by_order_id()` | 🚩 Consider a different design (CQRS) |

## Optimistic vs pessimistic locking

| | Optimistic (`version_number`) | Pessimistic (`SELECT FOR UPDATE`) |
|---|---|---|
| Pattern | `read1, read2, write1, write2(fail)` | `read1, write1, read2, write2(succeed)` |
| You handle | **Retries** | **Deadlocks** |
| Config | `isolation_level="REPEATABLE READ"` | `.with_for_update()` |
| Cost under contention | Retries | Blocking |

## Commit style

**Always choose explicit commit + implicit rollback.** `__exit__` always rolls back; you call `commit()` by hand. Costs one line; buys **exactly one code path that changes the system**. Any exception or early exit lands in a safe state.

## Validation: which layer?

| Kind | Question | Where | Tool |
|---|---|---|---|
| **Syntax** | Is it well formed? | Message class, at the edge | `schema` + `from_json`, `ignore_extra_keys=True` |
| **Semantics** | Is it meaningful? | Service layer / bus | `ensure.product_exists(uow, event)` |
| **Pragmatics** | Can we comply here? | **Domain model** | Business rules |

**Rule**: validate *as little as possible* (Tolerant Reader — treat SKUs and IDs as opaque strings) but *as early as possible*. If a rule can be tested inside the domain model, it **should** be.

## Fakes vs mocks

**Default to fakes.** Reach for `mock.patch` only when you accept it improves nothing. Three reasons: patching makes code testable without making it better (it won't give you `--dry-run` or FTP support); mock tests verify *interactions* and get brittle; overuse buries the story in setup.
**Rule**: "Don't mock what you don't own." Wrap the messy third-party thing in your own thin abstraction, then fake that.

## Signals you need the next pattern

| Symptom | Pattern |
|---|---|
| Domain model importing `Column` / `models.Model` | Repository + classical mapping |
| Orchestration logic appearing in your controller | Service layer |
| `session` threaded through every signature | Unit of Work |
| Fear of locking a whole table | Aggregate + version numbers |
| A feature that needs "then" in its description | Domain events |
| `bus.handle(aggregate.events)` boilerplate everywhere | UoW publishes events (option 3) |
| Handlers named in the past tense for things not yet done | Commands |
| Nested `for` loops over ORM objects for a screen | Raw SQL → CQRS |
| A second adapter to pass around | Bootstrap script + DI |
| `mock.patch` in more than a handful of tests | Explicit dependencies |

## Legacy migration order (Epilogue)

1. **Name the problem** — hard to change? slow? buggy? Link the work to a feature project ("architecture tax").
2. **Service layer first.** Enumerate use cases; imperative names; each atomic. Worth it even over a messy Django ORM.
3. **Duplicate freely.** Copy → clean the copy → redirect callers → delete the mess. Better than a chain of use cases calling each other.
4. **Break the object graph** — direct references become IDs.
5. **Reads → SQL. Writes → one aggregate per transaction, joined by events.**
6. **Walking skeleton** in production early: a service that only logs its input.

## Footguns the book skipped

- Redis pub/sub is **not reliable messaging**. Use Event Store / Kafka / RabbitMQ for real.
- Two UoWs = two transactions. **You need monitoring and event-replay tooling.**
- **Handlers must be idempotent** if you're going to retry them. Use `SkipMessage`.
- **Event schemas change.** Document them (JSON schema + markdown) and share with consumers.
