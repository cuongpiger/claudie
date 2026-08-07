# Chapter 4: Structural Design Patterns

## Core Idea
Structural patterns compose objects and classes into larger structures while keeping
them flexible — they turn `has-a` and `is-a` relationships into something manageable,
extensible, and replaceable instead of a rigid inheritance tree.

## Frameworks Introduced

- **Adapter** — wrap an object so it satisfies an interface it wasn't built for.
  - When to use: a client expects interface A and you hold an object implementing B and
    can't (or won't) modify it; integrating legacy systems or third-party libraries;
    making two inherently incompatible classes interoperate while keeping strong typing.
  - How: `class XAdapter implements TargetInterface` holding a reference to the adaptee;
    each target method translates and delegates.
  - Analogy: a universal travel power adapter.

- **Decorator** — add behavior to an object at runtime by wrapping it in something with
  the same interface.
  - When to use: dynamic responsibility addition; avoiding class explosion from
    subclassing; extending behavior without modifying code (Open-Closed Principle);
    cross-cutting concerns (logging, transactions, caching); runtime-configurable behavior.
  - Four characteristics: runtime behavior extension, composition over inheritance,
    **recursive wrapping** (stackable), interface consistency.
  - How: an abstract `Decorator` implementing the component interface and holding a
    `protected readonly` component; concrete decorators call `super`/the wrapped method
    then apply their own transformation.

- **Façade** — one simplified interface in front of a complex subsystem.
  - When to use: simplifying a complex subsystem; defining an entry point per subsystem
    level; layering a system; decoupling clients from subsystem components.
  - Key discipline: expose the *minimal* methods and parameters. If the façade isn't
    simplifying and improving readability, it isn't earning its place.

- **Composite** — one interface for both leaves and containers so clients treat a tree
  uniformly.
  - When to use: representing hierarchical structures; letting clients ignore the
    difference between a single object and a composition; operations that must apply
    uniformly at any depth.
  - Canonical example: a filesystem — `Directory` contains `File`s and other
    `Directory`s, both implementing `FileSystemComponent`.

- **Proxy** — a surrogate object controlling access to a real one.
  - Five named variants by purpose: **virtual proxy** (lazy initialization),
    **protection proxy** (access control/RBAC), logging & auditing proxy, **smart
    proxy** (caching), validation proxy (input checks, centralized errors, retries).
  - Analogy: a secretary screening the director's calls.

- **Bridge** — split an abstraction from its implementation so both hierarchies extend
  independently.
  - When to use: separation of concerns between interface and implementation;
    both sides need independent extension; implementations must be swappable at runtime;
    multiple abstractions share implementations.
  - How: an abstract class holding a reference to an implementation interface — that
    reference *is* the bridge.
  - Analogy: a universal remote (abstraction) driving TVs, DVD players, sound systems
    (implementations).

- **Flyweight** — share expensive objects by splitting their state.
  - **Intrinsic state**: shared, unchanging, lives inside the flyweight.
  - **Extrinsic state**: unique per use, passed in as a method parameter.
  - When to use: very many similar objects; a shareable duplicated state; limited memory
    or GC pressure you want to keep low and predictable.
  - How: `Flyweight` interface + `ConcreteFlyweight(sharedState)` + a `FlyweightFactory`
    that caches by a key derived from the intrinsic state.

## Key Concepts

- **`has-a` relationship** — one object holds a reference to another (composition).
- **`is-a` relationship** — inheritance or type-based relationship.
- **Recursive wrapping** — stacking decorators so each layer wraps the previous one.
- **God object** — a class that knows or does too much; the failure state of a Façade.
- **Object pooling** — maintaining reusable instances that are borrowed and returned.
  Distinct from Flyweight: pooling reduces *creation/destruction* overhead; Flyweight
  reduces *memory* by sharing intrinsic state. They combine well.
- **Dialect adapter** — Sequelize's mechanism for supporting MySQL/PostgreSQL/SQLite
  behind one API.

## Mental Models

- **Façade vs. Proxy**: a Façade provides a *different, simpler* interface to reduce
  complexity; a Proxy has the *same* interface and exists to control access.
- **Decorator vs. Proxy**: both wrap. Decorator *adds behavior* and is stackable —
  clients pile several on one object. Proxy *controls access*, usually one per object,
  and doesn't intend to add behavior.
- **Flyweight vs. object pooling**: sharing one instance across contexts vs. recycling
  many instances. Memory vs. instantiation cost.
- **Bridge is two hierarchies joined by one reference.** If you only have one
  implementation, you don't have a bridge — you have overhead.
- **Keep the composite model simple rather than fully general.** Over-generalizing the
  component interface is what causes method bloat and cycles.

## Anti-patterns

- **Adapter with `any`/`unknown` casts**: enable `strict` mode so casts are checked.
  Adapters that lie about types push the bug downstream.
- **Adapter version drift**: as the adaptee evolves, the adapter silently falls behind
  and produces subtly wrong behavior.
- **Decorator interface churn**: every method added to the component interface must be
  added to every decorator. Interface changes ripple across all of them.
- **Decorator ordering bugs**: when decorators have side effects, `Compress(Encrypt(x))`
  ≠ `Encrypt(Compress(x))`. Ordering is part of the contract.
- **Façade as God object / scope creep**: one façade accumulating every subsystem.
  Mitigation: build *multiple small façades for different use cases*, not one big one.
- **Composite method bloat**: forcing leaves to implement `add()`, `remove()`,
  `getChild()` just to satisfy the interface — leaving them to throw at runtime.
- **Composite cycles**: an un-guarded tree can loop back on itself, giving infinite
  traversal or stack overflow.
- **Proxy lifetime coupling**: tying the proxy's lifetime to the wrapped object causes
  leaks or premature destruction if not managed.
- **Bridge for a single implementation**: pure over-engineering — the example given is a
  logger that only ever writes to a file.
- **Mutable Flyweight intrinsic state**: changing one shared appearance changes every
  character using it. Mitigation: make intrinsic state **immutable**.
- **Premature Flyweight**: adds cache-lookup overhead and complexity before the memory
  problem is demonstrated.

## Code Examples

Adapter — bridging imperial and metric:

```typescript
interface MetricCalculator { getDistanceInMeters(): number }

class ImperialSystem {
  constructor(private distanceInFeet: number) {}
  getDistanceInFeet(): number { return this.distanceInFeet }
}

class ImperialToMetricAdapter implements MetricCalculator {
  constructor(private imperialSystem: ImperialSystem) {}

  getDistanceInMeters(): number {
    const feet = this.imperialSystem.getDistanceInFeet()
    if (typeof feet !== "number" || isNaN(feet)) {
      throw new Error("Invalid distance in feet provided")
    }
    return feet * 0.3048
  }
}

class Reporter {
  static reportDistance(calculator: MetricCalculator) {
    console.log(`The distance is ${calculator.getDistanceInMeters()} meters.`)
  }
}

Reporter.reportDistance(new ImperialToMetricAdapter(new ImperialSystem(10)))
```

Decorator — classic stackable form:

```typescript
interface FileReader { read(filePath: string): string }

class SimpleFileReader implements FileReader {
  read(filePath: string): string { return `Content of ${filePath}` }
}

abstract class FileReaderDecorator implements FileReader {
  constructor(protected readonly reader: FileReader) {}
  abstract read(filePath: string): string
}

class EncryptionDecorator extends FileReaderDecorator {
  read(filePath: string): string { return `Encrypted(${this.reader.read(filePath)})` }
}
class CompressionDecorator extends FileReaderDecorator {
  read(filePath: string): string { return `Compressed(${this.reader.read(filePath)})` }
}

let reader: FileReader = new SimpleFileReader()
reader = new CompressionDecorator(reader)
reader = new EncryptionDecorator(reader)   // order matters
```

Decorator — modern ECMAScript class decorator (same effect, no wrapper instances):

```typescript
function Encrypt() {
  return function <T extends { new (...args: any[]): FileReader }>(constructor: T) {
    return class extends constructor {
      read(filePath: string): string {
        return `Encrypted(${super.read(filePath)})`
      }
    }
  }
}

@Compress()
@Encrypt()
class SimpleFileReader implements FileReader {
  read(filePath: string): string { return `Content of ${filePath}` }
}
```

- **What it demonstrates**: TS 5 decorators apply to classes, methods, properties, and
  parameters — finer granularity than the classical OOP form, which is class-level only.

Proxy — virtual proxy with lazy initialization:

```typescript
export interface Store { save(data: string): void }

export class TextStore implements Store {
  save(data: string): void { console.log(`TextStore.save data=${data}`) }
}

export class ProxyTextStore implements Store {
  constructor(private textStore?: TextStore) {}

  save(data: string): void {
    if (!this.textStore) {
      console.log("Lazy init: textStore.")
      this.textStore = new TextStore()
    }
    this.textStore.save(data)
  }
}
```

Bridge — abstraction and implementation extend independently:

```typescript
interface WateringMechanism {
  water(amount: number): void
  checkWaterLevel(): number
  refill(amount: number): void
}

abstract class SmartPlantCare {
  constructor(
    protected mechanism: WateringMechanism,   // <- the bridge
    protected moistureThreshold: number,
  ) {}
  abstract waterPlant(currentMoisture: number): void
  abstract adjustWatering(weatherForecast: string): void
}

class TropicalPlantCare extends SmartPlantCare {
  constructor(mechanism: WateringMechanism) { super(mechanism, 60) }

  waterPlant(currentMoisture: number): void {
    if (currentMoisture < this.moistureThreshold) this.mechanism.water(100)
    else console.log("Tropical plant doesn't need watering")
  }
  adjustWatering(weatherForecast: string): void {
    if (weatherForecast.includes("humidity")) this.moistureThreshold += 10
    else if (weatherForecast.includes("dry")) this.moistureThreshold -= 10
  }
}
// Adding DripIrrigation touches nothing in SmartPlantCare.
```

Composite traversal over the DOM — the pattern in the platform itself:

```typescript
function traverse(node: Node, depth: number = 0): void {
  console.log(" ".repeat(depth) + node.nodeName)
  node.childNodes.forEach((child: Node) => traverse(child, depth + 1))
}
```

## Reference Tables

Picking a structural pattern:

| Problem | Pattern |
|---|---|
| Interfaces don't match | Adapter |
| Add behavior at runtime, stackable | Decorator |
| Too many subsystems to call | Façade |
| Tree of like-and-unlike parts | Composite |
| Control *access* to one object | Proxy |
| Two dimensions varying independently | Bridge |
| Too many near-identical objects in memory | Flyweight |

The three wrappers, disambiguated:

| | Same interface? | Intent | How many per object |
|---|---|---|---|
| Adapter | no (translates) | make incompatible things fit | one per incompatibility |
| Decorator | yes | add behavior | many, stacked |
| Proxy | yes | control access | usually one |

Proxy variants:

| Variant | Purpose |
|---|---|
| Virtual | defer creation of expensive objects (lazy init) |
| Protection | role-based access control on sensitive operations |
| Logging/auditing | audit trails, metrics, without touching business logic |
| Smart | caching expensive computations or remote data |
| Validation | input checks, centralized errors, retry mechanisms |

Real-world sightings:

| Pattern | In the wild |
|---|---|
| Adapter | Sequelize dialects (`dialect: 'mysql' \| 'postgres'`) |
| Decorator | Nest.js `@Controller('dogs')`, `@Get()` |
| Composite | The DOM tree |
| Proxy | Vue.js reactivity, MobX observables, ORM lazy loading, viewport image loading |
| Bridge | `Logger` (abstraction) over `Appender` (implementation) |
| Flyweight | Text editors sharing character+formatting objects |

## Worked Example

**Flyweight for a vehicle registry** — the full split of intrinsic from extrinsic state,
with an LRU-bounded factory:

```typescript
export interface Flyweight {
  perform(customization: { id: string }): void
}

export class ConcreteFlyweight implements Flyweight {
  // sharedState = INTRINSIC: brand, model, color — identical across many cars
  constructor(private sharedState: Object) {}

  public perform(customization: { id: string }): void {
    // customization = EXTRINSIC: plates + owner, unique per call
    console.log(
      `Shared (${JSON.stringify(this.sharedState)}) and unique (${customization.id}) state.`
    )
  }
}

import QuickLRU from "quick-lru"

export class FlyweightFactory {
  private cache = new QuickLRU({ maxSize: 1000 })

  public getFlyweight(sharedState: Object): Flyweight {
    const key = JSON.stringify(sharedState)
    if (!this.cache.has(key)) {
      console.log("FlyweightFactory: Can't find a flyweight, creating new one.")
      this.cache.set(key, new ConcreteFlyweight(sharedState))
    } else {
      console.log("FlyweightFactory: Reusing existing flyweight.")
    }
    return this.cache.get(key)!
  }
}

const factory = new FlyweightFactory()

function addCar(plates: string, owner: string, brand: string, model: string, color: string) {
  const flyweight = factory.getFlyweight({ brand, model, color })  // intrinsic → cache key
  flyweight.perform({ id: `${plates}_${owner}` })                  // extrinsic → parameter
}

addCar("CL234IR", "James Doe", "Chevrolet", "Camaro2018", "pink")  // creates
addCar("CL234IR", "James Doe", "BMW", "M5", "red")                 // creates
addCar("CL234IR", "James Doe", "BMW", "X1", "red")                 // creates (model differs)
```

The decision that makes or breaks this pattern is **which fields go on which side**.
Anything that varies per instance must be extrinsic, or the cache degenerates to one
entry per object and you've added a hash lookup for nothing. Anything shared must be
immutable, or a mutation leaks into every context sharing that flyweight.

## Key Takeaways

1. Adapter translates, Decorator adds, Proxy controls, Façade simplifies. Choose by
   intent, not by "it wraps something."
2. Use an abstract base decorator to hold the wrapped component and avoid duplicating the
   constructor across every concrete decorator.
3. TS 5 ECMAScript decorators give you the Decorator pattern without one wrapper class
   per behavior — at the cost of applying at class-definition time, not per instance.
4. Build many small façades, one per use case; a single growing façade becomes a God
   object.
5. Keep the Composite component interface small — resist adding `add`/`remove` to leaves
   just for symmetry, and guard against cycles.
6. Don't use Bridge until you have two dimensions that genuinely vary independently.
7. Flyweight: intrinsic state must be immutable and genuinely shared; extrinsic state
   goes through the method parameter. Combine with object pooling when creation cost
   also matters.
8. Every pattern here adds a layer of indirection — profile before assuming the overhead
   is negligible in real-time or data-intensive systems.

## Connects To

- **Ch 1**: UML composition/aggregation notation used in every diagram here.
- **Ch 2**: `Partial`/mapped types to cut adapter boilerplate; decorators require
  `experimentalDecorators` for the legacy form.
- **Ch 3**: `FlyweightFactory` is a Factory; the Proxy example lazily builds a Singleton.
- **Ch 6**: Visitor, the other tree-traversal pattern that pairs with Composite.
- **Ch 9**: the Open-Closed Principle that Decorator exists to satisfy.
- **Ch 11**: deeper analysis of these patterns in Nest.js, MobX, Vue, and Sequelize.
