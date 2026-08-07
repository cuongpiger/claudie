# Chapter 5: Behavioral Design Patterns for Object Communication

## Core Idea
These five patterns decouple the *sender* of a request from its *receiver* — by
introducing an intermediary object or abstracting the behavior itself — so objects
collaborate without knowing each other's internals.

## Frameworks Introduced

- **Strategy** — encapsulate a family of algorithms behind one interface, swappable at
  runtime.
  - When to use: multiple algorithm variants selected by runtime conditions (tax rules
    by marital status/income bracket); isolating algorithm internals from callers;
    replacing conditional complexity with polymorphism; user/admin-configurable behavior.
  - How: `Strategy` interface + concrete strategies + a `Context` class holding the
    current strategy and delegating to it. The context stays agnostic about which
    algorithm runs.
  - Failure mode: frequent switching instantiates a new strategy object each time —
    costly in a tight loop or high-frequency path, especially if switching has side
    effects.

- **Chain of Responsibility** — pass a request along independent handlers; each decides
  whether to handle it, transform it, or forward it.
  - When to use: multiple possible handlers and the right one isn't known a priori;
    decoupling sender from receivers; handlers that must be added/removed/reordered at
    runtime; naturally hierarchical handling (GUI events, logging levels).
  - How: an abstract `Handler` with `setNext(handler)` and an abstract `handle(request)`;
    each concrete handler either resolves or delegates to `this.nextHandler`.
  - Analogy: a complaint escalating front desk → supervisor → manager → CEO.

- **Command** — represent an action as an object.
  - Four benefits: separation of concerns, extensibility (new commands without touching
    existing code), queueing/logging/undo, parameterization.
  - When to use: decoupling sender from receiver; parameterizing objects with actions at
    runtime; **undo/redo**; queueing operations for later or ordered execution;
    composite commands (macros); transactional behavior with rollback.
  - Five roles: `Command` (interface), Concrete Commands (bind a receiver to an action),
    `Receiver` (knows *how*), `Invoker` (knows *when*), `Client` (wires them together).
  - Analogy: customer creates an order (command), waiter (invoker) takes it, chef
    (receiver) cooks it.

- **Mediator** — route all communication through a central coordinator.
  - Four characteristics: centralized communication, reduced dependencies, simplified
    interfaces, changes localized to the mediator.
  - When to use: reduce coupling by giving a set of objects one communication point;
    replace direct method calls between many objects with mediator-coordinated events.
  - Analogy: a solicitor with power of attorney acting between you and a government agency.

- **Observer** (aka **publish–subscribe**) — a subject notifies a dynamic list of
  subscribers when its state changes.
  - Two components: **Subject/publisher** (maintains subscriber list, posts events) and
    **Observer/subscriber** (has an update method called on change).
  - When to use: one-to-many communication where the publisher must not know its
    subscribers; triggering updates across an application without passing object
    references around.
  - Analogy: a newspaper subscription — subscribers join or leave at any time.

## Key Concepts

- **Context class (Strategy)** — holds the current strategy and delegates; conventionally
  the strategy field/type is prefixed `Strategy`.
- **Default handler (Chain of Responsibility)** — a terminal handler you must add,
  because nothing otherwise guarantees a request reaching the end gets processed.
- **Composite command / macro** — a command whose `execute()` runs several commands.
- **Reducer (Redux)** — `(state, action) => state`; the handler half of Command, where
  the action object is the command.
- **Cascading updates (Observer)** — one notification triggering another; the main
  source of hard-to-debug Observer behavior.

## Mental Models

- **Strategy vs. State (Ch 6)**: Strategy selects an *algorithm* from a family at runtime
  (sorting by user preference). State changes behavior based on an object's *internal
  state* (a media player behaving differently when playing/paused/stopped).
- **Mediator vs. Chain of Responsibility**: Chain passes a request along until someone
  handles it. Mediator centralizes communication so components interact *indirectly*
  and never know about each other.
- **Mediator vs. Observer**: the mediator *knows* the dependent structures and routes
  calls based on events. The Observer's publisher is *unaware* of its subscribers, and
  subscribers independently decide whether to react.
- **Command vs. Observer**: Command encapsulates a *request* as an object (enabling
  undo/redo). Observer notifies many listeners of a *state change*.
- **Chain of Responsibility vs. Decorator**: Decorator extends one object's behavior by
  wrapping, never interrupting the request flow. Chain lets handlers process
  sequentially and **halt** the flow when a condition is met.
- **Observer generalizes Chain of Responsibility.** You can build a chain out of
  Observables, but not the reverse — Observer supports dynamic subscription and operator
  composition.

## Anti-patterns

- **Strategy for two or three simple variations**: an `if` statement or a lambda is
  clearer. The pattern earns its classes when the algorithms are multiple and complex.
- **Strategy with shared state**: passing extra parameters or keeping state in the
  context tightens the coupling the pattern was meant to loosen.
- **Chain breakage**: a handler that neither resolves nor forwards — or throws an
  unhandled exception — silently drops the request.
- **Chain without a default handler**: nothing guarantees the request is ever handled.
- **Circular chains**: an unmanaged `setNext` graph can loop forever.
- **Long chains in hot paths**: every request traverses every handler until one matches;
  latency accumulates.
- **Command class proliferation**: too many tiny, specific command classes. Also, letting
  commands become tightly coupled to their receivers removes the pattern's whole benefit.
- **Mediator stack overflow**: if handling `single_job_completed` calls back into the
  worker that emitted it, you get infinite recursion. Guard the event routing.
- **Monolithic mediator**: as more components route through it, the mediator accumulates
  responsibilities and violates the Single Responsibility Principle. Keep clear
  boundaries on what it owns.
- **Observer memory leaks**: subjects holding strong references to observers that are
  never unsubscribed keep them alive indefinitely. Cleanup on destroy is mandatory.
- **Observer performance**: notification is O(n); in a single-threaded runtime a
  long-running observer update blocks everything.

## Code Examples

Strategy — interchangeable sorting algorithms with a guarded context:

```typescript
interface SortStrategy {
  sort(data: number[]): number[]
}

class BubbleSort implements SortStrategy {
  sort(data: number[]): number[] { /* bubble sort */ return data }
}
class QuickSort implements SortStrategy {
  sort(data: number[]): number[] {
    if (data.length <= 1) return data
    /* quicksort */ return data
  }
}

class Sorter {
  constructor(private strategy: SortStrategy) {
    if (!strategy || typeof strategy.sort !== "function") {
      throw new Error("Invalid strategy provided")
    }
  }
  setStrategy(strategy: SortStrategy) { this.strategy = strategy }
  sort(data: number[]) { return this.strategy.sort(data) }
}

const sorter = new Sorter(new BubbleSort())
sorter.setStrategy(new QuickSort())   // behavior changes, client code doesn't
```

Chain of Responsibility — escalating support tickets by priority:

```typescript
abstract class SupportHandler {
  protected nextHandler?: SupportHandler
  setNext(handler: SupportHandler): SupportHandler {
    this.nextHandler = handler
    return handler
  }
  abstract handle(ticket: SupportTicket): void
}

class FrontDeskHandler extends SupportHandler {
  handle(ticket: SupportTicket): void {
    if (ticket.getPriority() <= 1) {
      ticket.setResolution("Resolved by Front Desk: General inquiry handled")
    } else if (this.nextHandler) {
      this.nextHandler.handle(ticket)     // escalate
    }
  }
}

class TechnicalSupportHandler extends SupportHandler {
  handle(ticket: SupportTicket): void {
    if (ticket.getPriority() <= 3) {
      ticket.setResolution("Resolved by Technical Support: Technical issue addressed")
    } else if (this.nextHandler) {
      this.nextHandler.handle(ticket)
    }
  }
}

const frontDesk = new FrontDeskHandler()
frontDesk.setNext(new TechnicalSupportHandler())
tickets.forEach((t) => frontDesk.handle(t))
```

Command — smart-home controller queueing actions:

```typescript
interface Command { execute(): void }

class Light {
  turnOn():  void { console.log("Light is turned on") }
  turnOff(): void { console.log("Light is turned off") }
}

class TurnOnLightCommand implements Command {
  constructor(private light: Light) {}        // Receiver bound to action
  execute(): void { this.light.turnOn() }
}
class TurnOffLightCommand implements Command {
  constructor(private light: Light) {}
  execute(): void { this.light.turnOff() }
}

class SmartHomeController {                   // Invoker
  private commands: Command[] = []
  addCommand(command: Command): void { this.commands.push(command) }
  executeCommands(): void {
    this.commands.forEach((command) => command.execute())
    this.commands = []
  }
}

const light = new Light()
const controller = new SmartHomeController()
controller.addCommand(new TurnOnLightCommand(light))
controller.addCommand(new TurnOffLightCommand(light))
controller.executeCommands()
```

- **What it demonstrates**: because commands are *objects*, the controller can queue,
  log, reorder, or (with an added `undo()`) reverse them — none of which is possible
  when the controller calls `light.turnOn()` directly.

Observer — subject with a dynamic subscriber list:

```typescript
interface Subscriber { notify(message?: any): void }

abstract class Subject {
  private subscribers: Subscriber[] = []
  public addSubscriber(s: Subscriber): void { this.subscribers.push(s) }
  public removeSubscriber(s: Subscriber): void {
    this.subscribers = this.subscribers.filter((x) => x !== s)
  }
  public notify(message?: any): void {
    this.subscribers.forEach((s) => s.notify(message))
  }
}

class ConcreteSubject extends Subject {
  private state: any
  setState(state: any) { this.state = state; this.notify(state) }
}

class ConcreteSubscriber implements Subscriber {
  private state: any
  public notify(message: any): void {
    this.state = message
    console.log(`Received update with state: ${this.state}`)
  }
}

const subject = new ConcreteSubject()
const a = new ConcreteSubscriber(), b = new ConcreteSubscriber()
subject.addSubscriber(a); subject.addSubscriber(b)
subject.setState(19)              // both notified
subject.removeSubscriber(b)       // <- forgetting this is the memory leak
subject.setState(21)              // only `a` notified
```

## Reference Tables

Picking a communication pattern:

| Problem | Pattern |
|---|---|
| Many algorithms, one chosen at runtime | Strategy |
| Request may be handled by one of several, in order | Chain of Responsibility |
| Need to queue / log / undo an action | Command |
| Many components must talk without knowing each other | Mediator |
| One change, many independent reactions | Observer |

Disambiguating the look-alikes:

| Pair | Key distinction |
|---|---|
| Strategy vs. State | algorithm chosen by caller vs. behavior driven by internal state |
| Mediator vs. Chain | central hub knows everyone vs. linear pass-along |
| Mediator vs. Observer | mediator knows subscribers vs. publisher does not |
| Chain vs. Decorator | can halt the flow vs. always continues |
| Command vs. Observer | encapsulated request vs. state-change notification |

Real-world sightings:

| Pattern | In the wild |
|---|---|
| Strategy | Passport.js / `nuxt-auth` OAuth provider strategies |
| Chain of Responsibility | Express.js middleware (`app.use`, `router.handle(req, res, done)`) |
| Command | Redux actions + reducers |
| Mediator | chatroom message routing; UI widgets updating a shared counter |
| Observer | RxJS Observables (see Ch 8) |

What to test per pattern:

| Pattern | Assert |
|---|---|
| Strategy | each strategy computes correctly; `setStrategy` swaps behavior; mock the context |
| Chain | each handler resolves its own range; unhandled requests forward (mock the next handler) |
| Command | each command calls the right receiver method (mock receivers); invoker queue management |
| Mediator | an event from A triggers the right method on B, in the right order; components do emit to the mediator |
| Observer | no leaked references after unsubscribe; `unsubscribe` actually stops delivery; each observer's reaction logic |

## Worked Example

**Mediator coordinating two workers** — and the one-line change that turns it into a
stack overflow:

```typescript
interface WorkerMediator {
  triggerEvent(sender: Workhorse, message: string): void
}

abstract class Workhorse {
  protected mediator?: WorkerMediator
  setMediator(m: WorkerMediator) { this.mediator = m }
  abstract performWork(): void
}

class BatchWorker extends Workhorse {
  public performWork(): void {
    console.log("Performing batch work")
    this.mediator?.triggerEvent(this, "batch_job_completed")
  }
  public finalize(): void {
    console.log("Performing final work in BatchWorker")
    this.mediator?.triggerEvent(this, "final_job_completed")
  }
}

class SingleTaskWorker extends Workhorse {
  public performWork(): void {
    console.log("Performing work in SingleTaskWorker")
    this.mediator?.triggerEvent(this, "single_job_completed")
  }
}

class WorkerCenter implements WorkerMediator {
  constructor(private workerA: BatchWorker, private workerB: SingleTaskWorker) {
    workerA.setMediator(this)
    workerB.setMediator(this)
  }

  triggerEvent(sender: Workhorse, message: string): void {
    if (message.startsWith("batch_job_completed")) {
      this.workerB.performWork()      // batch finished → kick off the single task
    }
    if (message.startsWith("single_job_completed")) {
      this.workerA.finalize()         // single task finished → finalize the batch
    }
  }
}

const workerA = new BatchWorker()
const workerB = new SingleTaskWorker()
const mediator = new WorkerCenter(workerA, workerB)
workerA.performWork()   // start of the whole event chain
```

**The failure mode.** Replace the second branch with:

```typescript
if (message.startsWith("single_job_completed")) {
  this.workerB.performWork()   // ← stack overflow
}
```

`workerB.performWork()` emits `single_job_completed`, which re-enters `triggerEvent`,
which calls `workerB.performWork()` again — unbounded recursion. Because the mediator is
the only place routing lives, this is easy to introduce and invisible from the worker
classes. Route events *forward* through the graph, never back to the emitter, and treat
the mediator's routing table as the thing under test.

## Key Takeaways

1. Reach for Strategy when you have several *complex* interchangeable algorithms — not
   for two branches an `if` would cover.
2. Always terminate a Chain of Responsibility with a default handler; without one,
   unhandled requests fail silently.
3. Design Chain handlers to be modular and independently testable, log the request flow,
   and profile long chains — debuggability is the pattern's weak point.
4. Command's real payoff is that actions become data: queueable, loggable, undoable,
   composable into macros.
5. Keep the mediator's responsibilities narrow, and make sure event routing never sends
   an event back to its emitter.
6. Observer requires disciplined unsubscription — every subject holding observers is a
   potential leak.
7. Choose by intent using the disambiguation table above; several of these patterns look
   structurally identical and differ only in what they mean.

## Connects To

- **Ch 4**: Decorator (contrast with Chain of Responsibility) and Proxy.
- **Ch 6**: State (contrast with Strategy), Visitor, Iterator, Memento, Template Method.
- **Ch 8**: RxJS Observables — the reactive generalization of Observer.
- **Ch 9**: the Single Responsibility Principle a bloated mediator violates.
- **Ch 11**: pattern usage across Express, Redux, Passport, and RxJS in real codebases.
