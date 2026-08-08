# Chapter 19: The Least Principles, Coupling/Cohesion/Connascence & Simple Design *(book ch. 46–48)*

## Core Idea
Three layers of judgment: the **Least Principles** minimize friction (for readers, callers, and your own workflow); **Coupling, Cohesion & Connascence** — "the big three" — are the deep measures of *what kind* of dependency you actually have; and the **Four Elements of Simple Design** converge everything into four rules you can recall daily.

---

## Part A — The Least Principles

Why "Least"? Each minimizes the mental overhead, confusion, or friction that slows development — at the class level *and* at the workflow level. Least friction is what produces **flow**.

### Frameworks Introduced

- **Principle of Least Effort**: *Code should require minimal effort to understand, use, or maintain — clear, concise, direct, not verbose or needlessly abstract.*
  ```typescript
  // ❌ Needlessly complex
  class Calculator {
    sum(a: number, b: number): number {
      let result = 0;
      result = a + b;
      return result;
    }
  }
  // ✅ Direct
  class SimpleCalculator {
    sum(a: number, b: number): number { return a + b; }
  }
  ```

- **Principle of Least Astonishment (Surprise)**: *Behavior must match what the name and domain context suggest — no hidden side effects.*
  - Tells: `modal.close()` also navigates to another page. `repo.findUser()` also sends an email. **Astonishing.**
  ```typescript
  // ❌ Surprising hidden operation
  class Counter {
    private count = 0;
    increment(): number {
      this.count += 1;
      this.reset();       // 😱 secret reset
      return this.count;
    }
    private reset(): void { this.count = 0; }
  }
  // ✅ Predictable
  class PredictableCounter {
    private count = 0;
    increment(): number { return ++this.count; }
  }
  ```

- **Law of Demeter (Principle of Least Knowledge)**: *An object should only talk to its direct neighbours — never chain through nested structures.*
  - Prevents "train wrecks" like `car.engine.getPiston().oilItUp()`.
  ```typescript
  // ❌ Violating Demeter — reaching through Car into Engine
  class Driver {
    checkCarOilLevel(car: Car): number {
      return car.engine.getOilLevel();
    }
  }
  // ✅ Car exposes only what's needed
  class CarSafe {
    private engine: EngineSafe = new EngineSafe();
    getEngineOilLevel(): number { return this.engine.getOilLevel(); }
  }
  class DriverSafe {
    checkCarOilLevel(car: CarSafe): number { return car.getEngineOilLevel(); }
  }
  ```

- **Principle of Least Resistance**: *At the workflow level, remove friction so producing a feature is easy.* This is the **DX (developer experience)** principle.
  - Diagnostic questions: How fast can you spin up a new test or a new slice of domain logic? Are your patterns so complicated you can't "flow"?
  - Tells: adding a feature requires 5 steps (service + repo + test + interface + container binding); each new test needs 6 mocks.
  - Prevents **"psychic entropy"** — the mental overhead that paralyzes you because you don't know how to proceed.
  - Fix: fewer layers, a single domain folder, quick TDD path — features in minutes, not hours.

**Responsibility-first read**: each Least violation is usually a stereotype violation. A `Counter` is an *Information Holder* with a tiny bit of service logic — it has no business resetting itself.

---

## Part B — Coupling, Cohesion & Connascence ("The Big Three")

- **Coupling**: *the degree of interdependence between components.* Aim low — fewer direct/hardwired references.
- **Cohesion**: *how strongly a module's internal parts relate.* Aim high — each module handles one theme.
- **Connascence** (Meilir Page-Jones): *the degree and type of dependency where a change in one element **forces** a corresponding change in another to remain correct.*
  - Etymology: **con-** (together) + **-nascent** (born) — two elements "born together."
  - Why it beats coupling as a vocabulary: it says **how** elements rely on each other, and whether that's at compile-time or runtime.

### The Three Axes of Connascence
| Axis | Question | Rule of thumb |
|---|---|---|
| **Strength** | How hard is this dependency to find and refactor? | Stronger = more fragile |
| **Degree** | How many entities are involved? | Connascent with many = more fragile |
| **Locality** | How close are the entities in the code? | **Close code can tolerate strong connascence; distant code (microservices) needs weak connascence** |

The locality axis is the practical one: connascence of position inside one function is fine; the same across a service boundary is a liability.

### The Nine Types (weakest → strongest)

**Static (compile-time)** — cheaper, findable by tools:
1. **Connascence of Name** — components must agree on a name.
2. **Connascence of Type** — must share the same type.
3. **Connascence of Convention** — must follow the same naming/algorithmic convention.
4. **Connascence of Algorithm** — must follow the same exact algorithmic steps.
5. **Connascence of Position** — order of positional arguments matters.

**Dynamic (runtime)** — more dangerous, invisible to the compiler:
6. **Connascence of Execution Order** — must run in a certain sequence or it fails.
7. **Connascence of Timing** — must complete within timing constraints.
8. **Connascence of Value** — must share exact data (e.g. the same magic string).
9. **Connascence of Identity** — must refer to the same entity **instance**.

> **Not all connascence is bad.** Code needs *some* synergy. The goal is keeping it appropriate in strength, degree, and locality — especially avoiding *dynamic* forms across distant boundaries.

### Worked Examples

**Connascence of Name** — both sides hardcode the `firstName` property:
```typescript
class Person {
  firstName: string;
  constructor(name: string) { this.firstName = name; }
}

function greet(person: Person) {
  console.log(`Hello, ${person.firstName}`); // both rely on the exact property name
}
```
**Reduce it** by exposing a domain method (`person.getName()`) so external code stops depending on the property name — this is also Tell, Don't Ask.

**Connascence of Execution Order** — a runtime ordering dependency:
```typescript
class Car {
  private engineStarted = false;

  startEngine(): void { this.engineStarted = true; }

  drive(): void {
    if (!this.engineStarted) throw new Error("Engine not started");
    console.log("Driving...");
  }
}
```
Changing the requirement to "automatic engine start" forces changes to `drive()` **and every caller**. That's the connascence cost made visible.

**Coupling — the standard fix:**
```typescript
// ❌ High coupling — OrderProcessor constructs its own dependency
class OrderProcessor {
  paymentService = new PaymentService();
  processOrder(orderId: number) { this.paymentService.processPayment(orderId); }
}

// ✅ Low coupling — depend on an interface, inject the detail
interface PaymentProcessor { processPayment(orderId: number): void; }
class PayPalPaymentProcessor implements PaymentProcessor { /* ... */ }

class OrderProcessorDecoupled {
  constructor(private paymentProcessor: PaymentProcessor) {}
  processOrder(orderId: number): void { this.paymentProcessor.processPayment(orderId); }
}
```

**Cohesion — split the junk-drawer:**
```typescript
// ❌ Low cohesion
class Utilities {
  calculateTotal(items: number[]): number { return items.reduce((a, b) => a + b, 0); }
  formatDate(date: Date): string { return date.toISOString(); }
}
// ✅ High cohesion
class Order    { constructor(private items: number[]) {}
                 calculateTotal(): number { return this.items.reduce((a, b) => a + b, 0); } }
class DateUtils { formatDate(date: Date): string { return date.toISOString(); } }
```

### The Ongoing Tension: Emergent vs. Upfront Design
- **Upfront** would plan for multiple payment methods on day one. **Emergent** starts with one `PaymentService` and extracts the interface when a second appears.
- *Potential meets actual*: you can't foresee everything; new constraints push you to add or remove dependencies.
- **It's never done** — Stemmler calls it "a sort of never-ending game." Every feature reveals new connascence. Keep re-checking.

---

## Part C — The Four Elements of Simple Design

**Origin**: eXtreme Programming; popularized by **Kent Beck**, with Ward Cunningham and the XP community. They endured because they're memorable when everything else is too much to recall.

1. **Runs All the Tests** — correctness first. No matter how clean, failing code is wrong code. Encourages test-first, which stops over-building.
2. **Expresses Intent** — name things after real domain concepts. `hasDiscount()` beats `checkFlag()` or `evalCond()`. **Naming is design**, and it evolves as domain understanding deepens.
3. **No Duplication** — unify repeated logic. *Each refactoring to remove duplication typically spawns or improves an abstraction.*
4. **Minimal Classes & Methods** — only what the domain or tests demand. Avoids "factory-of-a-factory-of-a-service."

```typescript
// Expresses Intent — domain language, not cryptic conditions
class Order {
  constructor(private items: number[]) {}
  calculateTotal(): number { return this.items.reduce((a, b) => a + b, 0); }
  hasDiscount(): boolean   { return this.calculateTotal() > 100; }
}
```

```typescript
// ❌ Over-engineered — Minimal Classes violation
class OrderFactory        { createOrder(items: number[]): Order { return new Order(items); } }
class OrderServiceFactory { createOrderService(): OrderService  { return new OrderService(new OrderFactory()); } }

// ✅ Minimal
class Order        { constructor(private items: number[]) {} }
class OrderService { createOrder(items: number[]): Order { return new Order(items); } }
```

> **The convergence point of the whole book's principles section.** After SOLID, structural/behavioural/creational, and coupling/cohesion/connascence — XP practitioners converge on these four as the daily checklist. "Minimal" is not about skipping necessary structure; it's about not adding more than the domain or tests demand.

## Anti-patterns
- **Train-wreck call chains** (`a.b().c().d()`) — Law of Demeter violation; also raises connascence of name across distance.
- **Methods with secret side effects** — Least Astonishment violation; erodes trust in the whole API.
- **Ceremony to add a feature** (5 files + container binding) — Least Resistance violation; this is an *architecture* bug, not a discipline bug.
- **Dynamic connascence across service boundaries** — execution-order or timing dependencies between microservices are the most brittle thing you can build.
- **`Utilities` / `Helpers` classes** — the canonical low-cohesion smell.
- **Factory-of-a-factory** — Minimal Classes violation.
- **Trying to eliminate all coupling/connascence** — impossible; code must do something. Manage strength, degree, and locality instead.

## Key Takeaways
1. **Locality is the deciding axis** — strong connascence is acceptable when the two elements sit next to each other, and dangerous when they're far apart.
2. **Static connascence beats dynamic** — prefer failures the compiler can catch over failures that need the right runtime sequence.
3. **Least Resistance is an architecture metric.** If new features are painful, simplify the architecture rather than pushing developers harder.
4. **Least Astonishment is a naming contract** — the method must do what its name says and nothing more.
5. **Connascence gives you the vocabulary coupling lacks** — "high coupling" tells you there's a problem; "connascence of execution order across services" tells you *which* problem.
6. **When overwhelmed, fall back to the Four Elements.** Passes tests → expresses intent → no duplication → minimal elements.
7. **Design is never finished** — each new feature reveals connascence you didn't plan for. That's expected, not failure.

## Connects To
- **Ch 17 (SOLID)** — coupling/cohesion is what SOLID optimizes; connascence explains *why* each principle helps.
- **Ch 18 (Structural/Behavioural Principles)** — Tell, Don't Ask is the fix for connascence of name; Program to Interfaces lowers coupling.
- **Ch 14 (Object Calisthenics)** — "One Dot per Line" *is* the Law of Demeter, mechanized.
- **Ch 02 (Human-Centered Design)** — Least Astonishment is the *conceptual model* principle applied to code.
- **Ch 20 (Architecture)** — locality of connascence is the argument for/against distributed architectures.
- **Ch 12 (TDD)** — "Runs All the Tests" and the refactor step are where design actually happens.
