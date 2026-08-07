# Chapter 3: Creational Design Patterns

## Core Idea
Creational patterns separate *how an object is made* from *what the object is*, letting
you swap construction strategies at runtime without touching client code — and they
split object lifetime into two governable phases: creation and management/destruction.

## Frameworks Introduced

- **Singleton** — one instance, one global access point.
  - When to use: global config/state, controlled access to a shared external resource
    (DB connection, filesystem, API endpoint), a cache layer, logging/error handling,
    thread or object pools.
  - How: private static `instance` field + private constructor + public static
    `getInstance()` that lazily creates and caches.
  - Four key characteristics: global access point, instance caching, lazy
    initialization, unique instance per class.
  - Failure mode: lazy init defers cost to first call — a bottleneck if initialization
    is expensive and the resource is needed at startup.
  - Scope caveat: "one instance" means one *per process*. Spawning another process
    creates its own Singletons.

- **Prototype** — create new objects by cloning existing ones instead of calling `new`.
  - When to use: you already hold configured objects and want identical copies; `new`
    carries real construction overhead; the object graph is complex/hierarchical and
    you want the whole structure copied including nested objects.
  - How: a `Prototype` interface with a single `clone(): Prototype` method; each
    concrete class implements it.
  - Why it works: skips re-running construction logic and re-assigning shared properties.

- **Builder** — construct a complex object step by step through a chainable API.
  - When to use: both criteria must hold — (1) a common, implementation-independent set
    of steps produces the object, and (2) you need *multiple representations* of it.
    Without (2) it is over-engineering.
  - How: `Product` class + `Builder` interface (setters returning `this`, plus
    `build()`) + concrete builders. `build()` returns the product and resets the builder.
  - The GoF **Director** is an optional façade over the builder that consolidates a
    chain of steps into one call for a known product configuration.
  - Screening questions before adopting: does the object have more than three
    parameters? Are many optional with defaults? Are all steps independent? Any "no"
    means you probably don't need it yet.

- **Factory Method** — an interface for creating one product type; subclasses/concrete
  factories decide the concrete class.
  - When to use: creation logic is complex; the concrete type isn't known until runtime;
    you want creation decoupled from usage; you need a central point for lifecycle
    management.
  - Four components: Product interface, concrete products, Factory interface, concrete
    factories.
  - Practice: instantiate the factories once for the program's lifetime and pass them
    around — the creation logic then lives in exactly one place. Pairs naturally with
    DI containers (Inversify.js, Nest.js), which manage factory lifetime for you.

- **Abstract Factory** — "a factory of factories": one interface creating *families* of
  related products.
  - When to use: you need families of related/dependent objects (a UI toolkit's
    buttons + menus + scrollbars per platform); clients must talk to factories not
    concrete classes; you want to interchange whole factories at runtime; the created
    objects must be mutually compatible.
  - The fundamental trigger, in the author's words: **a runtime client that can
    interchange different Factory objects at runtime**, producing different
    representations or hierarchies.

- **Relationship between the two factories**: Factory Method creates objects of a
  *single* type; Abstract Factory creates *families*. Factory Method is a specialization
  of Abstract Factory.

## Key Concepts

- **Lazy initialization** — build the instance on first request, not at declaration.
- **Loose coupling** — components know each other only through interfaces, never
  implementation details.
- **Parametric Singleton** — cache multiple instances in a `Map` keyed by the
  constructor parameters, so `getInstance(param)` returns the same object per key. Works
  around the classic Singleton's inability to accept init parameters.
- **Module-resolution Singleton** — `export default new Service()`; Node caches modules
  by *resolved absolute path*, so every importer gets the same object.
- **Prototypical inheritance** — JavaScript's built-in mechanism (`Object.create`, the
  prototype chain). Conceptually similar to, but *not the same as*, the Prototype
  pattern: the pattern is about cloning instances, the language feature is about
  delegating property lookup.
- **Chainable API** — every setter returns `this`, enabling method chaining.

## Mental Models

- **Think of a Singleton as a global static object doing very specific, tightly
  interrelated work.** If you can't describe it that way, you probably want DI instead.
- **Treat `getInstance()` as a lease, not a constructor.** The caller asks for access,
  not for creation.
- **Reach for Builder only when a second representation already exists or is imminent.**
  One representation + optional params = constructor defaults or an object literal.
- **Prefer separate factory classes over a `switch` on an enum once the type list
  grows.** The switch is fine during development and becomes a maintenance tax as soon
  as you're editing both an enum and a `switch` for every new type.
- **Choose Abstract Factory when the *set* must stay consistent.** Its guarantee is that
  everything one concrete factory produces works together.

## Anti-patterns

- **Singleton as a global variable**: hard to mock, hard to test in isolation, and
  mutations from anywhere leak everywhere (`instance1.addData('item1')` is visible to
  `instance2` — by design, but surprising in tests).
- **Singleton with untestable side effects**: if it makes real API calls, tests hit the
  network unless you bring in a mocking framework (Jest/Vitest).
- **`JSON.parse(JSON.stringify(obj))` as `deepClone`**: cannot handle circular
  references, and destroys `Date`, `RegExp`, `Map`, and `Set`. Use `lodash.cloneDeep`.
- **Prototype forcing type casts**: coding against the `Prototype` interface means
  `clone()` returns `Prototype`, so callers cast (`clonedPerson as Person`) to reach any
  real field — error-prone at scale.
- **`BasePrototype` + inheritance to share `clone()`**: contradicts the pattern's own
  purpose, which is to avoid inheritance when creating new objects.
- **Builder class proliferation**: a separate concrete builder per minor variation
  duplicates code. Mitigate with generics, composition + configuration objects, and
  validation hooks around each step.
- **Builder violating the Open-Closed Principle**: new steps or variations force edits
  to existing builder classes (see Ch 9 for OCP).
- **Factory boilerplate and misuse**: applying Factory Method indiscriminately
  over-engineers the codebase. Mitigate with decorators for auto-registration, or drop
  to a Builder / direct construction for simple objects.
- **Premature Abstract Factory**: the object hierarchy is rarely obvious upfront;
  expect to arrive at this pattern by refactoring, not by starting there.

## Code Examples

Classic Singleton — the three required elements:

```typescript
class UserService {
  private static instance: UserService
  private constructor() {}

  static getInstance(): UserService {
    if (!UserService.instance) {
      UserService.instance = new UserService()
    }
    return UserService.instance
  }

  getUsers(): string[] { return ["Alex", "John", "Sarah"] }
}

const userService = UserService.getInstance()
```

Parametric Singleton — one instance per key:

```typescript
export class ParametricSingleton {
  private static instances: Map<string, ParametricSingleton> = new Map()
  private constructor(private param: string) {}

  public getParam(): string { return this.param }

  static getInstance(param: string): ParametricSingleton {
    if (!ParametricSingleton.instances.has(param)) {
      ParametricSingleton.instances.set(param, new ParametricSingleton(param))
    }
    return ParametricSingleton.instances.get(param) as ParametricSingleton
  }
}

ParametricSingleton.getInstance("/v1/users")   // distinct
ParametricSingleton.getInstance("/v2/users")   // distinct
```

Decorator-based Singleton — removes the per-class boilerplate:

```typescript
function Singleton<T extends { new (...args: any[]): {} }>(constructor: T) {
  return class extends constructor {
    private static _instance: T | null = null
    constructor(...args: any[]) {
      super(...args)
      if (!(<any>this.constructor)._instance) {
        ;(<any>this.constructor)._instance = this
      }
      return (<any>this.constructor)._instance
    }
  } as unknown as T & { _instance: T }
}

@Singleton
class DecoratedSingleton {
  constructor() { console.log("DecoratedSingleton instance created") }
}
```

Prototype with a robust deep clone:

```typescript
import cloneDeep from "lodash.clonedeep"

interface AnimalPrototype { clone(): AnimalPrototype }

class Dog implements AnimalPrototype {
  constructor(private breed: string, private age: number) {}
  clone(): Dog { return cloneDeep(this) }
}

const dog: AnimalPrototype = new Dog("Boxer", 3)
const clonedDog = dog.clone() as Dog   // note the required cast
```

Generic Builder — one reusable builder instead of a class per product:

```typescript
interface Builder<T> { build(): T }

class GenericBuilder<T> implements Builder<T> {
  private obj: Partial<T> = {}

  public set<K extends keyof T>(key: K, value: T[K]): GenericBuilder<T> {
    this.obj[key] = value
    return this
  }

  public build(): T { return this.obj as T }
}
```

- **What it demonstrates**: `Partial<T>` + `keyof T` (Ch 2) collapse N hand-written
  builders into one type-safe generic. Trade-off: complex construction logic — adding
  or removing list items, conditional steps — doesn't fit this shape.

Factory Method with interchangeable factories:

```typescript
interface Vehicle { startEngine(): void; stopEngine(): void }
interface VehicleFactory { createVehicle(): Vehicle }

class CarFactory   implements VehicleFactory { createVehicle(): Vehicle { return new Car() } }
class TruckFactory implements VehicleFactory { createVehicle(): Vehicle { return new Truck() } }

const factories: VehicleFactory[] = [new CarFactory(), new TruckFactory(), new CarFactory()]
factories.forEach((factory) => {
  const vehicle = factory.createVehicle()
  vehicle.startEngine()
  vehicle.stopEngine()
})
```

Abstract Factory producing a consistent family:

```typescript
interface VehicleFactory {
  createCar(): Car
  createMotorcycle(): Motorcycle
}

class CompanyAFactory implements VehicleFactory {
  createCar(): Car { return new CompanyACar() }
  createMotorcycle(): Motorcycle { return new CompanyAMotorcycle() }
}

function produceVehicles(factory: VehicleFactory) {
  factory.createCar().drive()
  factory.createMotorcycle().ride()
}

produceVehicles(new CompanyAFactory())   // whole family swaps in one line
produceVehicles(new CompanyBFactory())
```

## Reference Tables

Choosing a creational pattern:

| Situation | Pattern |
|---|---|
| Exactly one shared instance per process | Singleton |
| One instance per distinct parameter set | Parametric Singleton |
| Copy an existing configured object graph | Prototype |
| >3 params, many optional, multiple representations | Builder |
| One product type, concrete class decided at runtime | Factory Method |
| A *family* of related products, swappable wholesale | Abstract Factory |

Singleton implementation variants:

| Variant | Mechanism | Trade-off |
|---|---|---|
| Classic | static field + private ctor + `getInstance()` | boilerplate per class |
| Module resolution | `export default new Service()` | control ceded to Node's module cache; breaks across duplicated `node_modules` paths |
| Decorator | `@Singleton` class decorator | least boilerplate; needs decorator support |
| Parametric | `Map<key, instance>` | you must design the key scheme |

Deep-clone options for Prototype:

| Approach | Circular refs | `Date`/`RegExp`/`Map`/`Set` |
|---|---|---|
| `JSON.parse(JSON.stringify(x))` | ✗ throws | ✗ destroyed |
| `lodash.cloneDeep(x)` | ✓ | ✓ |

Testing each pattern:

| Pattern | What to assert |
|---|---|
| Singleton | two `getInstance()` calls return the *same* reference (`toBe`) |
| Prototype | clone has correct state, a *different* reference, and is independently mutable |
| Builder | built object has the right properties; step order produces no unintended object; one suite per concrete builder |
| Factory Method | `create()` result matches expected type (`toBeInstanceOf`) |
| Abstract Factory | each concrete factory produces the correct product types |

## Worked Example

**A `Car` built with the classic Builder**, from product to chained construction:

```typescript
// 1. The product — many optional components
class Engine {}
class Transmission {}
class BodyStyle {}
class Wheels {}

class Car {
  constructor(
    public engine?: Engine,
    public transmission?: Transmission,
    public bodyStyle?: BodyStyle,
    public wheels?: Wheels,
  ) {}
}

// 2. The abstract steps — identical for every Car configuration
interface CarBuilder {
  setEngine(engine: Engine): CarBuilder
  setTransmission(transmission: Transmission): CarBuilder
  setBodyStyle(bodyStyle: BodyStyle): CarBuilder
  setWheels(wheels: Wheels): CarBuilder
  build(): Car
}

// 3. A concrete builder — chainable, resettable
class ConcreteCarBuilder implements CarBuilder {
  private car!: Car
  constructor() { this.reset() }
  reset() { this.car = new Car() }

  setEngine(engine: Engine) { this.car.engine = engine; return this }
  // ...remaining setters follow the same shape

  build(): Car {
    const result = this.car
    this.reset()          // ready for the next product
    return result
  }
}

// 4. Client code reads like a specification
const car = new ConcreteCarBuilder()
  .setEngine(new Engine())
  .setTransmission(new Transmission())
  .setBodyStyle(new BodyStyle())
  .setWheels(new Wheels())
  .build()
```

The same shape appears in the wild as Lodash's chain, where `value()` plays the role of
`build()`:

```javascript
const youngestUser = _.chain(users)
  .sortBy("age")
  .head()
  .value()          // <- unwraps, like build()
```

## Key Takeaways

1. Use Singleton only for genuinely single, tightly-scoped global concerns; prefer DI/IoC
   whenever loose coupling matters more than global access.
2. Singleton scope is per process — never rely on it for cross-process invariants.
3. Never deep-clone with `JSON.parse(JSON.stringify(...))` in a Prototype; reach for
   `lodash.cloneDeep`.
4. Builder earns its complexity only with multiple representations; otherwise use
   optional constructor params or an object literal.
5. A generic `Builder<T>` with `Partial<T>` and `keyof T` avoids one builder class per
   product — at the cost of complex, conditional construction logic.
6. Instantiate factories once and pass them around; that's what makes creation logic
   live in exactly one place.
7. Factory Method = one product type; Abstract Factory = a consistent family. Factory
   Method is the specialization.
8. Expect to *refactor into* Abstract Factory rather than start with it — premature
   abstraction here is a real, named risk.

## Connects To

- **Ch 2**: `Partial<T>`, `keyof T`, and `Map` underpin the generic Builder and the
  parametric Singleton; decorators enable the `@Singleton` variant.
- **Ch 4**: structural patterns, which arrange the objects these patterns create.
- **Ch 9**: the Open-Closed Principle, the specific SOLID rule Builder can violate.
- **Ch 11**: full analysis of pattern usage in open source (Nest.js adapters,
  Inversify.js, RxJS schedulers, Angular services, the TypeScript compiler API).
- **Gang of Four**: the Director role and the original creational catalog.
