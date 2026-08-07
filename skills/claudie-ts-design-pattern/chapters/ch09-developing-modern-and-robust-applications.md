# Chapter 9: Developing Modern and Robust TypeScript Applications

## Core Idea
Patterns compound when combined deliberately, and they need governing principles — SOLID,
DDD, and MVC — to keep large applications organized. But none of these are laws: the
author is explicit that SOLID, DRY, and KISS cannot all be satisfied at once.

## Frameworks Introduced

- **Three tests before combining patterns**:
  1. **Purpose and fit** — does this combination address *your* specific problem?
  2. **Flexibility vs. complexity** — do the patterns complement each other, or compound?
  3. **Testability** — does the combination make unit tests easier or harder?

- **Domain-Driven Design (DDD)** — five building blocks:
  - **Bounded context** — a logical boundary around a sub-domain (shopping cart, payment
    processing, shipping). In microservices, **each service is a bounded context**.
  - **Ubiquitous/common language** — a shared vocabulary among developers, domain
    experts, and analysts. `Instrument` means one thing in financial trading and
    something else elsewhere. Practically: maintain a documentation site of terms.
  - **Entities** — domain objects with a **unique identity**, typically mutable, stored
    in a persistence layer, carrying `id`/`created_at`/`updated_at`. Managed via the
    **Repository pattern**; may serve as aggregate roots.
  - **Value objects** — no identity (no `id`), **immutable**, equal by attributes,
    **validate their own state on construction** (`Money`, `EmailField`, `AmountField`).
  - **Domain events** — something happened that other parts should react to. Implement
    with the Mediator or Observer patterns.

- **SOLID** (Robert C. Martin, *Design Principles and Design Patterns*, 2000):
  - **Single Responsibility** — a class should have only one reason to change. The
    failure state is a **God object**.
  - **Open-Closed** — entities should be open to extension, closed to modification.
    Replace type-branching with a mapping/configuration so extension is a data change.
  - **Liskov Substitution** — you should be able to pass a subclass wherever the parent
    is expected without changing program behavior. Also known as the *principle of least
    astonishment*. **Three ways to violate it**: returning an incompatible object,
    throwing an exception the parent doesn't, or introducing side effects the parent
    doesn't handle.
  - **Interface Segregation** — keep interfaces thin and small; derive new interfaces
    from existing ones rather than growing one fat interface.
  - **Dependency Inversion** — depend on abstractions passed in, not on concrete types
    instantiated inside. This is what makes mocking possible.

- **MVC** — three components under separation of concerns:
  - **Model** — the entity's data plus business logic (validation, integrity,
    retrieval). Associated with the **Domain layer**.
  - **View** — the presentation layer; handles user interaction. Typically React,
    Angular, or Vue components.
  - **Controller** — the glue; listens for input, calls model methods, propagates updates
    to the view. Associated with the **Application layer**.

## Key Concepts

- **`Mutable<T>`** — a mapped type using the `-readonly` modifier to strip readonly,
  recursively. The inverse of `DeepReadonly` from Ch 7.
- **`OptionalKeys<T>` / `RequiredKeys<T>`** — custom utilities that extract which keys of
  a type are optional vs. required, via `-?` plus a conditional on `Pick<T, K>`.
- **`FunctionPropertyNames<T>` / `FunctionProperties<T>`** — extract just the method names
  or method properties from a type.
- **Repository pattern** — an abstraction layer between domain logic and data access,
  offering a collection-like interface over domain objects.
- **DRY** — reduce repetition by extracting abstractions.
- **KISS** — favor simple over convoluted.
- **`ts-toolbelt`** — an open-source library of ready-made utility types worth reading
  for technique.

## Mental Models

- **Any pattern needing exactly one instance for the app's lifetime should be exported as
  a Singleton** — that's the author's general rule for Singleton combinations.
- **Open-Closed in practice means "make the change a data change."** `Record<AccountType,
  Voucher>` turns adding a new tier from an edit of `VoucherService` into an edit of a
  map. The shape resembles Factory Method or Strategy.
- **Liskov is about expectations, not signatures.** `NonEmptyStack` satisfies the `Bag`
  interface perfectly and still breaks every client, because `isEmpty()` never returns
  true.
- **SOLID is a toolbox, not a destination.** You cannot predict how requirements will
  change; applying every principle up front produces more classes, longer names, and
  sometimes worse cohesion. DRY and SOLID actively conflict — DRY can violate SOLID and
  SOLID can introduce duplication.
- **A value object with no `id` is deliberate.** There is no point giving a currency
  amount a unique identifier — equality *is* the attributes.

## Anti-patterns

- **Singleton + Façade grown too large**: centralizing too much complexity into one
  Singleton-Façade creates a bottleneck that hurts performance and scalability as the
  subsystem grows.
- **Singleton factories under DI**: a Singleton can't easily supply mocks or stubs, and
  the same instance is shared across tests — so isolating components requires modifying
  the Singleton or complex workarounds.
- **God objects**: the direct consequence of violating Single Responsibility. Adding
  `login()` and `sendEmail()` to a `User` model is the canonical example.
- **Over-splitting under SRP**: invoking 100 tiny services to run one business workflow
  isn't ideal either — consolidate behind a Façade.
- **Type-branching in a method (`if (user.isPremium()) ... if (user.isUltimate()) ...`)**:
  every new type forces edits in two places. Replace with a lookup map.
- **Fat interfaces**: every method added to `Collection<T>` must be implemented by every
  implementer. Marking properties optional with `?` hides the smell without fixing it.
- **Instantiating dependencies inside methods**
  (`const repo = UserRepositoryFactory.getInstance()`): creates a hard dependency,
  forces module-level mocking, and couples the classes' change cycles.
- **Complex recursive mapped types over large interfaces**: recursive type-checking
  slows TypeScript compile times measurably in projects with extensive type definitions.
- **DDD on a simple domain**: it needs significant time and resource investment, depends
  heavily on access to domain experts, and complicates development unnecessarily when the
  business logic isn't intricate.
- **Deep Composite + Iterator without caching**: consider caching or memoization for
  deeply nested structures to avoid re-traversing the same paths.

## Code Examples

Singleton + Façade — one instance, one simplified interface:

```typescript
class SystemFacade {
  private static instance: SystemFacade
  private constructor(private serviceA: ServiceA, private serviceB: ServiceB) {}

  static getInstance(serviceA: ServiceA, serviceB: ServiceB): SystemFacade {
    if (!SystemFacade.instance) {
      SystemFacade.instance = new SystemFacade(serviceA, serviceB)
    }
    return SystemFacade.instance
  }

  performComplexOperation(): void { /* coordinates A and B */ }
}
```

Iterator + Composite — uniform traversal of a tree:

```typescript
const root = new Composite("Root")
root.add(new Composite("Child1"))
root.add(new Composite("Child2"))

const iterator = root.createIterator()
while (iterator.hasNext()) {
  const component = iterator.next()
  if (component) console.log(component.getName())
}
```

Iterator + Visitor — operate on every element without touching element classes:

```typescript
const collection = new ElementCollection()
collection.add(new ElementA("Element A1"))
collection.add(new ElementB("Element B1"))

const visitor = new ConcreteVisitor()
const iterator = collection.createIterator()
while (iterator.hasNext()) {
  const element = iterator.next()
  if (element) element.accept(visitor)
}
```

Custom utility types:

```typescript
// Strip readonly, recursively — the inverse of DeepReadonly
type Mutable<T> = { -readonly [K in keyof T]: Mutable<T[K]> }

// Which keys are optional / required?
type OptionalKeys<T> = { [K in keyof T]-?: {} extends Pick<T, K> ? K : never }[keyof T]
type RequiredKeys<T> = { [K in keyof T]-?: {} extends Pick<T, K> ? never : K }[keyof T]

interface User { id: number; name: string; email?: string }
type UserOptionalKeys = OptionalKeys<User>   // "email"
type UserRequiredKeys = RequiredKeys<User>   // "id" | "name"

// Extract just the methods
type FunctionPropertyNames<T> = { [K in keyof T]: T[K] extends Function ? K : never }[keyof T]
type FunctionProperties<T>    = Pick<T, FunctionPropertyNames<T>>
```

Open-Closed — replace branching with a map:

```typescript
// BEFORE: every new tier edits VoucherService
class VoucherService {
  getVoucher(user: User): string {
    if (user.isPremium())  return "15% discount"
    if (user.isUltimate()) return "20% discount"
    return "10% discount"
  }
}

// AFTER: every new tier edits only the map
type Voucher = string
const userTypeToVoucherMap: Record<AccountType, Voucher> = {
  Normal:   "10% discount",
  Premium:  "15% discount",
  Ultimate: "20% discount",
}

class VoucherService {
  getVoucher(user: User): string {
    return userTypeToVoucherMap[user.getAccountType()]
  }
}
```

Liskov violation — satisfies the interface, breaks every client:

```typescript
interface Bag<T> {
  push(item: T): void
  pop(): T | undefined
  isEmpty(): boolean
}

class NonEmptyStack<T> implements Bag<T> {
  private tag: any = Symbol()
  constructor(private items: T[] = []) {
    if (this.items.length == 0) this.items.push(this.tag)   // always keeps one element
  }
  push(item: T) { this.items.push(item) }
  pop(): T | undefined {
    if (this.items.length === 1) {
      const item = this.items.pop()
      this.items.push(this.tag)   // side effect the parent never had
      return item
    }
    if (this.items.length > 1) return this.items.pop()
    return undefined
  }
  isEmpty(): boolean { return this.items.length === 0 }   // ALWAYS false
}
```

Interface Segregation — one fat interface split by capability:

```typescript
// BEFORE
interface Collection<T> {
  pushBack(item: T): void; popBack(): T
  pushFront(item: T): void; popFront(): T
  isEmpty(): boolean
  insertAt(item: T, index: number): void; deleteAt(index: number): T | undefined
}

// AFTER: implement only what your structure actually supports
interface Collection<T> { isEmpty(): boolean }
interface Array<T> extends Collection<T> {
  insertAt(item: T, index: number): void
  deleteAt(index: number): T | undefined
}
interface Stack<T> extends Collection<T> { pushFront(item: T): void; popFront(): T }
interface Queue<T> extends Collection<T> { pushBack(item: T): void;  popFront(): T }
```

Dependency Inversion — inject the abstraction, mock it in tests:

```typescript
class UserService {
  constructor(private userQuery: UserQuery = UserRepositoryFactory.getInstance()) {}
  findByEmail(email: string): User | undefined {
    return this.userQuery.findByEmail(email)
  }
}

class MockUserQuery implements UserQuery {
  private users: User[] = [
    { name: "Alice", email: "alice@example.com" },
    { name: "Bob",   email: "bob@example.com" },
  ]
  findByEmail(email: string): User | undefined {
    return this.users.find((u) => u.email === email)
  }
}

describe("UserService", () => {
  let userService: UserService
  beforeEach(() => {
    userService = new UserService(new MockUserQuery())   // no module mocking needed
  })
})
```

MVC — the three pieces wired together:

```typescript
class TodoController {
  constructor(private model: TodoList, private view: TodoView) {}

  addTodo(title: string): void {
    this.model.addTodo(title)       // mutate the model
    this.view.displayTodos()        // propagate to the view
  }

  promptAddTodo(): void { this.view.promptAddTodo() }
}

const todoList = new TodoList()
const todoView = new TodoView(todoList)
const todoController = new TodoController(todoList, todoView)
todoController.promptAddTodo()
```

## Reference Tables

Effective pattern combinations:

| Combination | Why | Watch out for |
|---|---|---|
| Singleton + Builder | one builder instance; `reset()` before each use | forgetting to reset leaks prior state |
| Singleton + Façade | one entry point, lazily initialized | becomes a bottleneck as the subsystem grows |
| Singleton + Factory / Abstract Factory | factories are stateless — no reason for many | can't easily mock under DI |
| Singleton + State | share one state instance across originators | shared mutable state across contexts |
| Iterator + Composite | traverse a tree of any depth uniformly | cache/memoize for deep structures |
| Iterator + Visitor | apply operations without touching element classes | Visitor's element-extensibility cost (Ch 6) |

SOLID at a glance:

| Principle | Rule | Failure state |
|---|---|---|
| Single Responsibility | one reason to change | God object |
| Open-Closed | extend, don't modify | edit N places per new variant |
| Liskov Substitution | subclass substitutable for parent | client assumptions broken |
| Interface Segregation | thin interfaces, derive to extend | implementers forced to stub methods |
| Dependency Inversion | depend on injected abstractions | untestable without module mocking |

Entity vs. Value Object:

| | Entity | Value Object |
|---|---|---|
| Identity | unique `id` | none |
| Mutability | typically mutable | immutable |
| Equality | by identity | by attributes |
| Lifecycle | create/modify/delete; persisted | constructed and validated, then fixed |
| Managed by | Repository pattern | plain construction |
| Examples | `Author`, `Course`, `Enrollment` | `Money`, `EmailField`, `AddressField` |

MVC responsibilities:

| Component | Owns | Layer | Useful patterns |
|---|---|---|---|
| Model | data + business logic, validation, integrity | Domain | Singleton, Factory Method, Builder |
| View | presentation, user interaction | Presentation | framework components (React/Angular/Vue) |
| Controller | input handling, coordination, propagation | Application | Mediator, Observer |

## Worked Example

**`Money` as a value object** — the complete pattern, with every value-object property
visible:

```typescript
class Money {
  private readonly amount: number       // immutable
  private readonly currency: string

  constructor(amount: number, currency: string) {
    this.amount = amount
    this.currency = currency
    this.validate()                     // validates its own state on construction
  }

  private validate(): void {
    if (this.amount < 0) {
      throw new Error("Amount cannot be negative")
    }
    if (this.currency.length !== 3) {
      throw new Error("Currency must be a 3-letter ISO code")
    }
  }

  private ensureSameCurrency(other: Money): void {
    if (this.currency !== other.currency) {
      throw new Error("Cannot perform operations on different currencies")
    }
  }

  public equals(other: Money): boolean {           // equality BY ATTRIBUTES, not identity
    return this.amount === other.amount && this.currency === other.currency
  }

  public add(other: Money): Money {                // operations RETURN NEW instances
    this.ensureSameCurrency(other)
    return new Money(this.amount + other.amount, this.currency)
  }

  public subtract(other: Money): Money {
    this.ensureSameCurrency(other)
    const resultAmount = this.amount - other.amount
    if (resultAmount < 0) throw new Error("Resulting amount cannot be negative")
    return new Money(resultAmount, this.currency)
  }
}
```

Four things make this a value object rather than an entity:

1. **No `id`.** Two 5-EUR amounts *are* the same thing — a unique identifier would be
   meaningless.
2. **`readonly` fields.** Every operation returns a new `Money`; nothing mutates.
3. **Self-validation in the constructor.** An invalid `Money` cannot exist. Callers never
   have to check.
4. **Business invariants live inside** — `ensureSameCurrency` means "you cannot add EUR
   to USD" is enforced by the type, not by every caller remembering to check.

**Domain events** for the reactive half of the same architecture:

```typescript
const dispatcher = new EventDispatcher()
const userService = new UserService(dispatcher)

async function sendWelcomeEmail(event: UserRegisteredEvent) {
  const maxRetries = 3
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      await sendEmail(event.email)
      return
    } catch (error) {
      console.error(`Attempt ${attempt} failed for ${event.email}:`, error)
      if (attempt === maxRetries) {
        console.error(`Failed to send welcome email after ${maxRetries} attempts.`)
      }
    }
  }
}

dispatcher.addListener(sendWelcomeEmail)
dispatcher.addListener(notifyAdminOfNewUser)

userService.registerUser("user123", "user@example.com")   // fires both handlers
```

`UserService` knows nothing about email or admin notification — that's the decoupling
domain events buy, implemented with the Observer/Mediator machinery from Ch 5.

## Key Takeaways

1. Before combining patterns, run the three tests: fit, complexity-vs-flexibility, and
   testability. A combination that makes tests harder is the wrong combination.
2. Export as a Singleton anything that must exist exactly once for the app's lifetime —
   but expect a mocking problem under DI.
3. Satisfy Open-Closed by turning variation into data (`Record<K, V>` lookups) rather than
   branching on type.
4. Liskov violations pass the type checker. Watch for changed return types, new
   exceptions, and new side effects in subclasses.
5. Dependency Inversion is what makes unit testing possible — inject the abstraction with
   a default, and pass a mock in tests.
6. Use value objects (immutable, self-validating, no `id`) for domain concepts where
   equality is attribute-based; use entities for anything with a persisted identity.
7. Domain events (via Mediator/Observer) decouple business logic without hiding it.
8. DDD costs real time and needs domain-expert access — apply it to intricate domains,
   not simple ones.
9. SOLID, DRY, and KISS cannot be satisfied simultaneously. Treat them as tools chosen
   per situation, not a checklist.

## Connects To

- **Ch 2**: `Pick`, `Omit`, mapped types, and the `-readonly`/`-?` modifiers behind these
  custom utilities.
- **Ch 3**: Singleton, Builder, Factory Method, Abstract Factory — the combination
  partners.
- **Ch 4**: Façade (the Singleton partner), Composite (the Iterator partner).
- **Ch 5**: Mediator and Observer — how domain events are implemented.
- **Ch 6**: Iterator, Visitor, State — the other combination partners.
- **Ch 7**: `DeepReadonly` (the inverse of `Mutable`); immutability as a value-object
  requirement.
- **Ch 10**: anti-patterns — where over-applying these principles goes wrong.
- **Robert C. Martin, *Design Principles and Design Patterns* (2000)**: the source of
  SOLID. **Vaughn Vernon, *Implementing Domain-Driven Design***: the DDD reference.
