# Chapter 17: The SOLID Principles *(book ch. 42)*

## Core Idea
SOLID is five class-level design principles that reduce coupling and raise cohesion — and every one of them scales unchanged to the architectural level (bounded contexts, modules, ports & adapters). Stemmler's framing: SOLID exists so you can **add features by changing very little of the existing codebase**.

## Frameworks Introduced

- **Single Responsibility Principle (SRP)**: *A class (or module) should have one reason to change — a single responsibility.*
  - When to use: whenever a class mixes domain logic with presentation, logging, or persistence.
  - How: (1) name every reason the class might change; (2) if more than one, each reason belongs to a different **object stereotype** (Information Holder vs. Service Provider vs. Interfacer); (3) split along stereotype lines.
  - Why it works: Stemmler's shortcut — SRP is hard in the abstract but easy via **Object Stereotypes + Object Calisthenics**. If a class holds data *and* performs I/O, it's two stereotypes, therefore two classes.
  - Failure mode: the **God object** — cannot be tested or changed without breaking something unrelated.

- **Open-Closed Principle (OCP)**: *Classes or modules should be open for extension but closed for modification.*
  - When to use: when a new requirement tempts you to edit a stable `if/else` or `switch`.
  - How: extract the varying behavior behind an interface; add a **new** implementing class instead of editing the old one.
  - Stemmler's note: *his favourite principle.* Read it architecturally — "it's about plopping in new slices of functionality," which is only possible if your **workflow architecture** (feature-driven folders, vertical slices) affords it.

- **Liskov Substitution Principle (LSP)**: *Subtypes must be substitutable for their base types without unexpected side effects.*
  - When to use: any inheritance hierarchy, and every repository/gateway interface.
  - How: state the base type's contract (invariants, pre/post-conditions); enforce it **in the base class constructor** so subclasses cannot violate it.
  - Why it matters: LSP is what lets you swap `InMemoryUserRepo` for `PostgresUserRepo` or `MongoUserRepo` — "they all adhere to the contract that makes it work."
  - Failure mode: "duck-type mischief" — callers grow `if (x instanceof Weird)` special cases.

- **Interface Segregation Principle (ISP)**: *Don't force classes to implement methods they do not use. Split large interfaces into smaller, cohesive ones.*
  - When to use: any interface where an implementer throws `new Error("Not supported")`.
  - How: one interface per capability; a device that both prints and scans implements two interfaces.
  - Stemmler's practice: **"I always start with the interfaces."** Document what a repository *should do* first — cohesion is easy to get right up front and expensive to retrofit.

- **Dependency Inversion Principle (DIP)**: *High-level modules should depend on abstractions, not concrete classes.*
  - When to use: every boundary between core logic and infrastructure (DB, mail, payments, HTTP).
  - How: define the interface **in the core layer**, implement it in infrastructure, inject the implementation at the composition root.
  - Stemmler's note: "easily the principle that I use the most, even without thinking about it."

## Key Concepts
- **God object**: a class that handles domain logic, logging, and persistence at once — the canonical SRP violation.
- **Contract**: the invariants and pre/post-conditions a base type promises; LSP is about not breaking it.
- **Fat interface**: a "god" interface that forces partial or empty implementations.
- **Composition root**: the single place where concrete implementations are wired into abstractions.
- **Thin interface**: a small, cohesive interface — the ISP goal, and also a *constraint* in the human-centered-design sense.

## Mental Models
- **Think of OCP as "plopping in slices."** If adding a feature means editing five existing files, your architecture — not your discipline — is the problem.
- **Use stereotypes to resolve SRP arguments.** Instead of debating "is this one responsibility?", ask "how many object stereotypes is this class playing?"
- **Treat DIP as a direction-of-dependency rule, not a DI-container rule.** The abstraction belongs to the *consumer's* layer; that's what inverts the arrow.
- **LSP is the reason test doubles work.** If you can't substitute a fake, you have an LSP or DIP violation, not a testing problem.

## Code Examples

**SRP — separate the domain entity from the printer:**
```typescript
// Domain entity: handles domain logic only
class Order {
  private items: number[] = [];

  addItem(price: number): void {
    this.items.push(price);
  }

  calculateTotal(): number {
    return this.items.reduce((sum, p) => sum + p, 0);
  }
}

// Separate 'printing' / 'view' responsibility
class InvoicePrinter {
  printInvoice(order: Order): void {
    console.log(`Invoice total: ${order.calculateTotal()}`);
    // Potentially format PDF or console output
  }
}
```
- **What it demonstrates**: the entity keeps "items, discounts, total"; an Application Service or Printer owns rendering.

**OCP — extend shipping without editing existing classes:**
```typescript
interface IShippingMethod {
  calculateCost(orderValue: number): number;
}

class StandardShipping implements IShippingMethod {
  calculateCost(orderValue: number): number {
    return orderValue < 50 ? 5 : 0; // free over 50
  }
}

class ExpressShipping implements IShippingMethod {
  calculateCost(orderValue: number): number {
    return 15; // always $15 for express
  }
}

// Open to new shipping methods — never modified
function printShippingCost(method: IShippingMethod, orderValue: number) {
  console.log(`Shipping Cost: $${method.calculateCost(orderValue)}`);
}
```

**ISP — split the fat interface:**
```typescript
// ❌ Violating ISP
interface WarehouseDevice {
  printLabel(orderId: string): void;
  scanBarcode(): string;
  packageItem(orderId: string): void;
}

class BasicPrinter implements WarehouseDevice {
  printLabel(orderId: string): void { console.log("Printing label for", orderId); }
  scanBarcode(): string { throw new Error("Not supported"); }      // smell
  packageItem(orderId: string): void { throw new Error("Not supported"); } // smell
}

// ✅ Smaller, cohesive interfaces
interface LabelPrinter   { printLabel(orderId: string): void; }
interface BarcodeScanner { scanBarcode(): string; }
interface ItemPackager   { packageItem(orderId: string): void; }
```

**A cohesive interface (Stemmler's own example):**
```typescript
interface UserRepo {
  save(user: User): Promise<void>;
  getByUserId(userId: number): Promise<User | UserNotFound>;
  getByEmail(email: string): Promise<User | UserNotFound>;
}
```

## Worked Example — LSP: fixing `DiscountPolicy`

**The violation.** A base `DiscountPolicy` implies "returns a non-negative discount." A subclass breaks it:

```typescript
class DiscountPolicy {
  getDiscount(orderValue: number): number {
    return 0; // No discount by default
  }
}

class RegularDiscountPolicy extends DiscountPolicy {
  getDiscount(orderValue: number): number {
    return orderValue > 100 ? 10 : 0; // $10 off if over 100
  }
}

// ❌ Violating LSP — a negative "discount" increases the cost
class WeirdDiscountPolicy extends DiscountPolicy {
  getDiscount(orderValue: number): number {
    return -5;
  }
}
```

Callers now need `if (discount < 0)` guards everywhere — the contract leaked into every consumer.

**The fix — push the invariant into the base class constructor** so no subclass *can* violate it:

```typescript
class DiscountPolicy {
  constructor(private discount: number) {
    if (discount < 0) {
      throw new Error("Discount value must be positive");
    }
  }

  getDiscount(orderValue: number): number {
    return this.discount;
  }
}

class RegularDiscountPolicy extends DiscountPolicy {
  constructor() { super(10); } // $10 off
  getDiscount(orderValue: number): number {
    return orderValue > 100 ? super.getDiscount(orderValue) : 0;
  }
}

class SpecialDiscountPolicy extends DiscountPolicy {
  constructor() { super(5); } // $5 off
  getDiscount(orderValue: number): number {
    return super.getDiscount(orderValue);
  }
}
```

**The lesson**: LSP is not fixed by documenting the contract — it's fixed by making the contract **unbreakable at construction time**.

**DIP applied to the same domain:**
```typescript
// ❌ Core logic welded to a vendor
class OrderConfirmationSender {
  private emailService = new SendGridEmailService(); // hard dependency
  confirmOrder(customerEmail: string) {
    this.emailService.sendEmail(customerEmail, "Order Confirmed", "Thanks!");
  }
}

// ✅ Depend on the abstraction; inject the detail
interface EmailService {
  sendEmail(to: string, subject: string, body: string): void;
}

class SESMailService implements EmailService { /* AWS SES */ }
class Mailjet        implements EmailService { /* Mailjet */ }

class OrdersService {
  constructor(private emailService: EmailService) {}
  confirmOrder(customerEmail: string) {
    this.emailService.sendEmail(customerEmail, "Order Confirmed", "Thanks!");
  }
}

// Usage — swap the detail without touching the core
new OrdersService(new SESMailService()).confirmOrder("alice@example.com");
new OrdersService(new Mailjet()).confirmOrder("alice@example.com");
```

## Reference Table — SOLID at two levels

| Principle | Class level | Architectural level |
|---|---|---|
| **SRP** | One reason to change per class | Each **bounded context** owns one responsibility |
| **OCP** | Add a class, don't edit one | Extend with new subdomains/modules without rewriting |
| **LSP** | Subclasses honour the base contract | Subsystems/microservices stay substitutable behind a shared contract |
| **ISP** | Many small interfaces | Thin, cohesive boundaries between teams and services |
| **DIP** | Depend on interfaces, inject concretes | Architecture depends on **ports**, not frameworks or databases |

## Anti-patterns
- **God object** — domain logic + logging + DB access in one class. Violates SRP; untestable.
- **`throw new Error("Not supported")` in an implementation** — a tell that the interface is fat (ISP violation).
- **Editing a `switch`/`if-else` for every new variant** — OCP violation; extract a strategy interface.
- **Subclass that narrows or contradicts the base contract** — LSP violation; callers grow `instanceof` checks.
- **`new ConcreteThing()` inside core logic** — DIP violation; the core is now unmockable and vendor-locked.
- **Reflexive SOLID application** — Stemmler applies these *after* recognizing a real problem, not preemptively (see the "be wary of overuse" warning in the design-patterns chapter).

## Key Takeaways
1. **Start with the interface.** Stemmler designs the repository contract before the implementation — cohesion is cheap up front, expensive later.
2. **Enforce contracts in constructors, not comments.** That's how LSP is actually kept.
3. **OCP is an architecture test.** If adding a feature touches many existing files, fix the structure (vertical slices), not the discipline.
4. **DIP is the load-bearing principle** for testability — it's what makes `InMemoryUserRepo` possible.
5. **Resolve SRP disputes with object stereotypes**, not intuition about "one thing."
6. **Every principle re-reads at the architecture level** — SRP→bounded contexts, DIP→ports & adapters.

## Connects To
- **Ch 13 (Responsibility Driven Design)** — object stereotypes are the practical tool for judging SRP.
- **Ch 14 (Object Calisthenics)** — the mechanical rules that make SRP-compliant classes emerge.
- **Ch 18 (Structural Principles)** — "Program to Interfaces, Not Implementations" is DIP's sibling; Composition Over Inheritance sidesteps most LSP problems.
- **Ch 19 (Coupling, Cohesion & Connascence)** — the deeper measure of what SOLID is optimizing.
- **Ch 20 (Architectural Principles)** — The Dependency Rule is DIP scaled to layers; Hexagonal ports are DIP made structural.
- **Ch 16 (Design Patterns)** — Strategy realizes OCP, Adapter realizes DIP, Decorator realizes OCP+SRP.
