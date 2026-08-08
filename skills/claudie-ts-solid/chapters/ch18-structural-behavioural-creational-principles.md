# Chapter 18: Structural, Behavioural & Creational Principles *(book ch. 43–45)*

## Core Idea
Beyond SOLID, Stemmler groups the remaining design principles by the question each answers: **Structural** = *where do abstractions go?* **Behavioural** = *how do objects interact?* **Creational** = *when do we introduce a new abstraction at all?* TDD and Object Calisthenics are the triggers that tell you *when*.

---

## Part A — Structural Principles (*where abstractions live*)

Structural principles serve two architectural essentials: **Vertical Slices** (features cut end-to-end) and **Horizontal Decoupling** (modules within a layer stay untangled).

### Frameworks Introduced

- **Separation of Concerns (SoC)**: *Each module/class should focus on one broad responsibility — never mixing data, UI, domain, and infrastructure logic in one place.*
  - **The 2 Meta-Questions** (Stemmler's practical test — this is the memorable part):
    1. **"What pattern is this?"** — Is it a domain entity, application service, controller, an RDD stereotype (Information Holder, Service Provider…), or a Gang of Four pattern (Adapter, Facade…)?
    2. **"Is it doing too much?"** — Check against Object Calisthenics (e.g. "no classes with >2 instance variables"). If it mixes stereotypes (Interfacer *and* Information Holder), split it.
  - Why it works: naming the pattern first gives you a *reason* to split, instead of an aesthetic opinion.

- **Composition Over Inheritance**: *Prefer combining behaviors in objects over forcing them into an inheritance chain.*
  - When to use: the moment you're about to write `class AnimatedDraggableComponent extends DraggableComponent extends Component`.
  - How: extract each behavior into its own small class; hold instances as private fields; delegate.

- **Encapsulate What Varies**: *Isolate the parts that differ between scenarios behind stable interfaces.*
  - When to use: payment, shipping, tax, chart rendering — anywhere variants multiply.
  - How: name the axis of variation, define one interface for it, one class per variant.

- **CQS (Command Query Separation)**: *A method is either a command (changes state) or a query (returns data) — never both.*
  - When to use: always; it is also a **naming rule** (see Ch 04, Naming Principle #2).
  - Failure mode it prevents: side-effect-laden "getters" that surprise callers.

- **Program to Interfaces, Not to Implementations**: *Depend on abstractions, not concrete classes.*
  - This is DIP's structural sibling — same arrow, stated as a coding habit.

### Code Examples

**SoC — split fetch from render:**
```typescript
// ❌ Violating SoC: combining fetch + render
class ProductPage {
  renderProductDetails(productId: number): void {
    const product = this.fetchProduct(productId);
    console.log(`Product: ${product.name} - $${product.price}`);
  }
  private fetchProduct(productId: number) {
    return { name: "Laptop", price: 1200 };
  }
}

// ✅ Proper SoC
class ProductService {
  fetchProduct(productId: number) {
    return { name: "Laptop", price: 1200 }; // real API call
  }
}
class ProductRenderer {
  renderProduct(product: { name: string; price: number }): void {
    console.log(`Product: ${product.name} - $${product.price}`);
  }
}

const service = new ProductService();
const renderer = new ProductRenderer();
renderer.renderProduct(service.fetchProduct(1));
```

**Composition over inheritance:**
```typescript
// ❌ Inheritance approach — rigid hierarchy
class Animal { move() { console.log("The animal moves"); } }
class Bird extends Animal { fly()  { console.log("The bird flies"); } }
class Fish extends Animal { swim() { console.log("The fish swims"); } }

// ✅ Composition approach — plug in behaviors
class Movement { move() { console.log("It moves"); } }
class Flying   { fly()  { console.log("It flies"); } }
class Swimming { swim() { console.log("It swims"); } }

class Bird {
  private mover = new Movement();
  private flyer = new Flying();
  performActions() { this.mover.move(); this.flyer.fly(); }
}
class Fish {
  private mover   = new Movement();
  private swimmer = new Swimming();
  performActions() { this.mover.move(); this.swimmer.swim(); }
}
```

**CQS:**
```typescript
// ❌ Combined — confusing
class User {
  private age = 0;
  setAgeAndGetAge(newAge: number): number { this.age = newAge; return this.age; }
}

// ✅ CQS
class CQSUser {
  private age = 0;
  setAge(newAge: number): void { this.age = newAge; }  // command
  getAge(): number { return this.age; }                 // query
}
```

---

## Part B — Behavioural Principles (*how objects interact*)

Every one ties back to a **responsibility-first** question: *which object is responsible — a Service? a Coordinator? a pure Information Holder?*

### Frameworks Introduced

- **Tell, Don't Ask**: *Instead of asking an object for data to manipulate externally, tell the object to perform the task itself.*
  - When to use: any time you see `x.getItems().push(...)` or `x.getList().filter(...)` outside the object.
  - How: move the operation onto the object and make the field `private`.
  - Why it works: domain invariants can only live where the data lives.

- **Design by Contract (DBC)**: *Define preconditions, postconditions, and invariants for each method; clients must respect them.*
  - When to use: domain entities and any public API with rules.
  - How: guard preconditions with explicit `throw`s at the top of the method; state the invariant the class always maintains.
  - Ties to human-centered design: readers see the conditions and know how to call the method **without guesswork**.

- **The Hollywood Principle ("Don't Call Us, We'll Call You")**: *A high-level coordinator sets up the control flow; lower-level modules register behavior that gets invoked when needed — inversion of control.*
  - When to use: plugin systems, event-driven designs, domain event handlers.
  - Scale-up: at architecture level this *becomes* event-driven architecture — the "coordinator" is your event bus or orchestrator.

### Code Examples

**Tell, Don't Ask:**
```typescript
// ❌ Manipulating data externally
class Order {
  items: { name: string; price: number }[] = [];
  getItems() { return this.items; }
}
const order = new Order();
order.items.push({ name: "Laptop", price: 1000 }); // no invariant can protect this

// ✅ Encapsulation via domain behavior
class ImprovedOrder {
  private items: { name: string; price: number }[] = [];

  addItem(name: string, price: number): void {
    this.items.push({ name, price });
  }

  calculateTotal(): number {
    return this.items.reduce((sum, item) => sum + item.price, 0);
  }
}

const improvedOrder = new ImprovedOrder();
improvedOrder.addItem("Laptop", 1000);
improvedOrder.addItem("Mouse", 50);
console.log(improvedOrder.calculateTotal()); // 1050
```

**Design by Contract:**
```typescript
class BankAccount {
  private balance: number = 0;

  deposit(amount: number): void {
    if (amount <= 0) throw new Error("Deposit must be > 0");   // precondition
    this.balance += amount;                                     // postcondition
  }

  withdraw(amount: number): void {
    if (amount <= 0) throw new Error("Withdrawal must be > 0");    // precondition
    if (amount > this.balance) throw new Error("Insufficient funds"); // precondition
    this.balance -= amount;
  }

  getBalance(): number {
    return this.balance; // invariant: balance >= 0, always
  }
}
```

### Worked Example — The Hollywood Principle with an EventBus

The registering object never calls the publisher; the bus calls **it**.

```typescript
class EventBus {
  private listeners: { [event: string]: Function[] } = {};

  on(event: string, listener: Function): void {
    if (!this.listeners[event]) this.listeners[event] = [];
    this.listeners[event].push(listener);
  }

  emit(event: string, data: any): void {
    this.listeners[event]?.forEach(listener => listener(data));
  }
}

class UserSubscriptions {
  constructor(private eventBus: EventBus) {
    // The bus calls 'onUserRegistered' — we never call the bus
    this.eventBus.on("userRegistered", this.onUserRegistered.bind(this));
  }

  onUserRegistered(event: UserRegisteredEvent): void {
    console.log(`Welcome, ${event.data.firstName}!`);
  }
}

class UserService {
  constructor(private eventBus: EventBus) {}

  registerUser(firstName: string, userEmail: string) {
    // ... handle creating the user ...
    this.eventBus.emit("userRegistered", new UserRegisteredEvent(user));
  }
}

const eventBus = new EventBus();
new UserSubscriptions(eventBus);
const userService = new UserService(eventBus);
userService.registerUser("Alice", "alice@gmail.com"); // "Welcome, Alice!"
```

**Read it responsibility-first**: the `EventBus` is a **Coordinator** stereotype. `UserService` doesn't know who cares about registration — that's the decoupling the principle buys. Scaled up, this is exactly how a Domain Event bus dispatches to `OrderPlacedEvent` handlers without the domain model knowing them.

---

## Part C — Creational Principles (*when to introduce an abstraction*)

Each one pairs with a **TDD / Object Calisthenics trigger** — the signal that tells you the moment has arrived.

### Frameworks Introduced

- **DRY / The Rule of Three**: *If the same logic appears in three places, refactor it into one.*
  - Trigger — **TDD**: you're rewriting the same test setup in multiple test files.
  - Trigger — **Calisthenics**: the same conditional or calculation in more than two places.
  - Note the pairing: DRY is *deliberately gated* by Rule of Three, so you don't abstract on the second occurrence.

- **YAGNI (You Aren't Gonna Need It)**: *Don't build functionality until a real requirement exists.*
  - Trigger — **TDD**: no test requires the method → you don't need it yet.
  - Trigger — **Calisthenics**: >2 instance variables, or public methods nothing calls.
  - **DDD tip**: YAGNI violations are how you end up with **big aggregates**. Extra properties on a write model slow loading — start from what you actually need (see Programming by Wishful Thinking).

- **KISS (Keep It Simple, Silly)**: *Avoid unnecessary cleverness or layering.*
  - Trigger — **TDD**: if your test setup is getting complicated, the production code is too clever.

- **Programming by Wishful Thinking**: *Write code as if the ideal methods/classes already exist; let usage define the interface, then implement.*
  - When to use: at the start of any use case — it's the client's-perspective API design move.
  - Trigger — **Calisthenics**: if the wished-for method ends up handling multiple concerns, split it (`reserveInventory()` + `chargePayment()` + `notify()`) or introduce a **Coordinator**.

### Code Examples

**DRY — one formula, three consumers:**
```typescript
// ❌ Same discount formula in three places, two different expressions
class CartController    { calculateDiscountedTotal(p: number) { return p * 0.8; } }
class OrderController   { applyDiscount(p: number)            { return p - (p * 0.2); } }
class CheckoutService   { finalizeCheckout(p: number)         { return p * 0.8; } }

// ✅ Centralize
function applyBlackFridayDiscount(price: number): number {
  return price * 0.8;
}
class CartControllerDRY  { getTotal(p: number)         { return applyBlackFridayDiscount(p); } }
class OrderControllerDRY { finalizeOrder(p: number)    { return applyBlackFridayDiscount(p); } }
class CheckoutServiceDRY { completeCheckout(p: number) { return applyBlackFridayDiscount(p); } }
```

**Programming by Wishful Thinking — write the usage first:**
```typescript
// 1. Start with the usage you WISH you had
function processOrder(orderId: number): void {
  const order = getOrder(orderId);  // wishful thinking
  order.process();                  // wishful thinking
}

// 2. Then define what you wished for
function getOrder(orderId: number): Order {
  return new Order(orderId);
}
class Order {
  constructor(private orderId: number) {}
  process(): void {
    console.log(`Processing order #${this.orderId}`);
  }
}
```

## Reference Table — principle → trigger

| Principle | Category | The trigger that says "now" |
|---|---|---|
| Separation of Concerns | Structural | Class answers "yes" to *"is it doing too much?"* |
| Composition Over Inheritance | Structural | About to add a third level of `extends` |
| Encapsulate What Varies | Structural | A second variant of the same behavior appears |
| CQS | Structural | A method both mutates and returns |
| Program to Interfaces | Structural | `new Concrete()` appears inside core logic |
| Tell, Don't Ask | Behavioural | `obj.getX().mutate()` outside the object |
| Design by Contract | Behavioural | A domain rule lives in a comment, not code |
| Hollywood Principle | Behavioural | Modules calling each other directly to coordinate |
| DRY / Rule of Three | Creational | **Third** occurrence of the same logic |
| YAGNI | Creational | No test demands the method |
| KISS | Creational | Test setup is getting complicated |
| Wishful Thinking | Creational | Starting a new use case |

## Anti-patterns
- **Abstracting on the second occurrence** — DRY without the Rule of Three creates the wrong abstraction.
- **Getters that return mutable internals** (`getItems()` returning the live array) — defeats Tell, Don't Ask *and* encapsulation.
- **Rules in comments instead of guard clauses** — Design by Contract violation; the rule isn't enforced.
- **Deep inheritance chains** (`Component → Draggable → AnimatedDraggable`) — use composition.
- **Speculative methods "we'll need later"** — YAGNI violation; in DDD this bloats aggregates and hurts load performance.
- **Clever one-liners** (the `Array.from({length: n}).reduce(...)` factorial) — KISS violation; simple recursion reads better.

## Key Takeaways
1. **Use the 2 Meta-Questions to decide any split**: *What pattern is this?* then *Is it doing too much?*
2. **Let TDD and Object Calisthenics tell you when to abstract** — that's the whole point of grouping these as "creational."
3. **Rule of Three is a brake on DRY**, not a synonym for it.
4. **Tell, Don't Ask is how invariants survive** — a public mutable collection has no invariants.
5. **Design by Contract means guard clauses**, not documentation.
6. **The Hollywood Principle scales into event-driven architecture** — same shape, bigger boxes.
7. **Start from the usage you wish existed**; the interface you get will be smaller than the one you'd have designed.

## Connects To
- **Ch 17 (SOLID)** — "Program to Interfaces" is DIP; "Encapsulate What Varies" is OCP's mechanism.
- **Ch 13 (Responsibility Driven Design)** — the stereotype vocabulary that makes SoC decidable.
- **Ch 14 (Object Calisthenics)** — the concrete rules cited as triggers throughout.
- **Ch 19 (Coupling, Cohesion & Connascence)** — what all of these are ultimately optimizing.
- **Ch 16 (Design Patterns)** — Strategy is Encapsulate What Varies; Observer is the Hollywood Principle.
- **Ch 20 (Architecture)** — CQS scales into CQRS; Hollywood scales into Event-Driven Architecture.
