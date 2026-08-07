# Chapter 8: Reactive and Asynchronous Programming

## Core Idea
Reactive programming is the asynchronous propagation of change: producers emit, consumers
react, and neither blocks on the other. Combined with functional composition (FRP), the
result is composable operator pipelines over data streams.

## Frameworks Introduced

- **The three "reactive" terms**, distinguished:
  - **Reactive programming** — the computing paradigm: responses are deferred and
    propagated later via callbacks, Promises, or Futures.
  - **Reactive systems** — the architectural principles from the **Reactive Manifesto**.
  - **Functional Reactive Programming (FRP)** — reactive programming plus functional
    composition and referential transparency, realized in practice as Observables.

- **The Reactive Manifesto's four properties**: **responsive** (timely), **resilient**
  (tolerant in mission-critical paths), **elastic** (scales with workload),
  **message-driven** (decoupled, loosely coupled communication).

- **Three change-propagation patterns**:
  - **Pull** — the consumer polls the producer. Simple, needs no architectural change,
    but costs extra code and wastes resources.
  - **Push** — the producer sends as soon as data is available. Lower communication
    overhead; the producer can offer replays and persisted messages. This is the Observer
    pattern (Ch 5) applied to streams.
  - **Pull-Push** (hybrid) — the producer writes to storage and pushes a *notification*
    containing a path/endpoint; the consumer then pulls the payload. Use when the
    producer can't send large payloads for security or performance reasons, or when the
    consumer has no direct knowledge of the producer.

- **Promise vs. Future** — three concrete differences:
  1. **Laziness**: a Future doesn't execute until you call `fork`/`run`; a Promise is
     eager and starts on creation.
  2. **Cancellation**: a Future's execution returns a cancel function; Promises have no
     built-in cancellation.
  3. **Execution context**: a Future stores the computation `(resolve, reject) => cancel`
     rather than executing it.

- **Observables** — a sequence that produces future values or events.
  - Lazy by default: nothing is emitted until at least one `subscribe()`.
  - `subscribe()` takes three callbacks: `next` (a value), `error`, `complete`.
  - An `Error` value in the stream triggers `error` but **does not close the observable**
    — the flow continues.

- **Cold vs. hot Observables**:
  - **Cold** — the producer replays the whole sequence per subscription, so late
    subscribers get the complete history.
  - **Hot** — the producer emits regardless of subscribers (a live broadcast); late
    subscribers see only values emitted after they joined. Created with `share()`.

- **Backpressure operators** — for when the producer outruns the consumer:
  - `buffer`/`bufferTime`/`bufferCount` — accumulate until the consumer is ready.
  - `throttle` — cap emissions over time (rapid input events).
  - `debounce` — emit only after a period of inactivity (search-as-you-type).

## Key Concepts

- **`pipe(op1, op2, op3)`** — chains operators; equivalent to `op1().op2().op3()` with
  the source value as the initial parameter. Each operator returns a new observable.
- **`of` / `from`** — create observables from a parameter list / from a collection or
  Promise.
- **`tap`** — the correct place for side effects inside a pipeline (logging, debugging),
  keeping `map`/`filter` pure.
- **`share()` vs. `shareReplay(n)`** — `share` multicasts; `shareReplay(n)` adds a replay
  buffer of size `n` so late subscribers receive the last `n` values.
- **RxJS schedulers** — control *when* a subscription starts and notifications are
  delivered. Four types: **null** (default, synchronous), **AsyncScheduler**
  (`setTimeout`), **QueueScheduler** (trampoline queue — runs after preceding tasks),
  **AsapScheduler** (`setTimeout(task, 0)`).
- **Marble testing** — `TestScheduler` with diagrams like `'---a---b---c|'` to assert
  emission *timing*, simulating time passage without real delays.

## Mental Models

- **Observables are the Observer pattern generalized.** The Observer pattern (Ch 5) is
  class-scoped: you add/remove observers and notify through methods. Observables manage
  *sequences* and add composable operators.
- **Reactive vs. functional programming**: FP is about functions, immutability, and
  purity; RP is about async data streams and change propagation. RP borrows FP's
  composition and purity to make propagation composable.
- **Reactive vs. OOP**: OOP is about how objects are created, hold state, and interact.
  RP is about how *data* moves through the system.
- **Put business logic in the operator chain, not in the consumer.** Store the
  transformations in the pipeline so subscribers receive only the data they need.
- **Prefer Push when the producer knows who cares; prefer Pull-Push when the payload is
  large or sensitive.**

## Anti-patterns

- **Losing the async, non-blocking property**: the chapter is explicit that if reactive
  code stops being asynchronous and non-blocking, you get performance degradation and
  potential **data loss** — the paradigm's added complexity buys nothing.
- **Pull with mismatched rates**: producer and consumer polling at different rates risks
  the producer generating more data than the consumer can process in time.
- **Polling as a default**: it works without architectural change but costs code volume
  and unnecessary resource consumption.
- **Side effects inside `map`**: move them to `tap`, which exists for exactly this.
- **Assuming a hot observable replays**: a late subscriber to a `share()`d stream
  silently misses everything emitted before it joined. Use `shareReplay(n)` if that
  matters.
- **Ignoring backpressure**: high-frequency events (scroll, typing) without
  throttle/debounce/buffer produce unresponsive interfaces and wasted network calls.
- **Testing time-based Observables with real delays**: slow and flaky. Use
  `TestScheduler`.

## Code Examples

Polling — the Pull pattern with timeout and abort support:

```typescript
export interface AsyncRequest<T> { success: boolean; data?: T }

export async function asyncPoll<T>(
  fn: () => PromiseLike<AsyncRequest<T>>,
  pollInterval = 5000,
  pollTimeout = 30000,
  abortSignal?: AbortSignal,
): Promise<T> {
  if (abortSignal?.aborted) throw new Error("Polling aborted")
  const endTime = new Date().getTime() + pollTimeout

  const condition = (resolve: (value: T) => void, reject: (reason?: any) => void): void => {
    if (abortSignal?.aborted) { reject(new Error("Polling aborted")); return }
    Promise.resolve(fn())
      .then((result) => {
        const now = new Date().getTime()
        if (result.success) {
          if (result.data === undefined) {
            reject(new Error("Successful response must include data")); return
          }
          resolve(result.data)
        } else if (now < endTime) {
          setTimeout(condition, pollInterval, resolve, reject)
        } else {
          reject(new Error("Reached timeout. Exiting"))
        }
      })
      .catch(reject)
  }

  return new Promise(condition)
}
```

Push — the Observer pattern over an RxJS `Subject`:

```typescript
import { Subject } from "rxjs"

class Producer {
  private subject = new Subject<number>()
  sendData(data: number) { this.subject.next(data) }
  subscribe(callback: (data: number) => void) { this.subject.subscribe(callback) }
}

const producer = new Producer()
producer.subscribe((data) => console.log("Subscriber 1 received:", data))
producer.subscribe((data) => console.log("Subscriber 2 received:", data))
producer.sendData(42)
```

Pull-Push — the consumer pulls through an async generator:

```typescript
class Consumer {
  constructor(private collector: Collector) {}

  async *pullDataStream() {
    while (await this.collector.hasMoreData()) {
      const data = await this.collector.pullData()
      for (const item of data) yield item
      await new Promise((resolve) => setTimeout(resolve, 1000))
    }
  }
}

for await (const item of consumer.pullDataStream()) console.log("Received:", item)
```

Creating Observables from several sources:

```typescript
import { Observable, of, from } from "rxjs"

of(1, 2, 3, 4, 5)                 // from a parameter list
of({ id: 1, data: "value" })
from([1, 2, 3, 4, 5])             // from a collection
from(Promise.resolve("data"))     // from a Promise

const randomValues = new Observable<number>((subscriber) => {
  subscriber.next(1)
  subscriber.next(2)
  setInterval(() => subscriber.next(Math.random() * 100), 1000)
})
```

Subscribing with all three callbacks:

```typescript
const origin = from([1, 2, 3, 4, new Error("Error")])

origin.subscribe({
  next:     (v: any) => console.log("Value accepted: ", v),
  error:    (e)      => console.log("Error accepted: ", e),   // does NOT close the stream
  complete: ()       => console.log("Finished"),
})
```

Composable operators — note `tap` for side effects:

```typescript
import { of, from, interval } from "rxjs"
import { filter, take, map, tap } from "rxjs/operators"

interval(1000).pipe(
  take(5),
  map((v: number) => v * v),
  tap((v) => console.log(`Squared value: ${v}`)),   // side effect isolated here
).subscribe()
// 0, 1, 4, 9, 16

of(1, 2, 3, 4, 5, 6, 7, 8, 9, 10).pipe(
  filter((v: number) => v % 3 === 0),
).subscribe()
// 3, 6, 9
```

Marble testing with `TestScheduler`:

```typescript
import { TestScheduler } from "rxjs/testing"

const testScheduler = new TestScheduler((actual, expected) => {
  expect(actual).toEqual(expected)
})

testScheduler.run(({ cold, expectObservable }) => {
  const source$ = cold("---a---b---c|")
  expectObservable(source$).toBe("---a---b---c|")
})
```

## Reference Tables

Change-propagation patterns:

| Pattern | Who initiates | Best for | Cost |
|---|---|---|---|
| Pull | consumer polls | simple cases, no architecture change | code volume, wasted resources, rate mismatch |
| Push | producer sends | notifications, live feeds, WebSockets, IoT | producer must track consumers |
| Pull-Push | producer notifies, consumer fetches | large or sensitive payloads; consumer unaware of producer | extra storage/collector hop |

Promise vs. Future:

| | Promise | Future |
|---|---|---|
| Execution | eager — starts on creation | lazy — starts on `fork`/`run` |
| Cancellation | none built in | `fork` returns a cancel function |
| Native in TS | yes | no — hand-roll or use `Fluture` |

Promise combinators:

| Method | Resolves when |
|---|---|
| `Promise.all` | all resolve; rejects on first rejection |
| `Promise.race` | first settles (resolve *or* reject) |
| `Promise.allSettled` | all settle; returns `{status, value/reason}` per entry (needs `"es2020"` in `tsconfig` `lib`) |

Cold vs. hot Observables:

| | Cold | Hot |
|---|---|---|
| Emission starts | per subscription | independent of subscribers |
| Late subscriber gets | full history | only values after joining |
| Created with | `of`, `from`, `new Observable` | `.pipe(share())` |
| Replay for late subscribers | inherent | `shareReplay(n)` |

RxJS schedulers:

| Scheduler | Executes |
|---|---|
| `null` (default) | synchronously |
| `AsyncScheduler` | via `setTimeout` |
| `QueueScheduler` | on a trampoline queue, after preceding tasks |
| `AsapScheduler` | via `setTimeout(task, 0)` |

Backpressure operators:

| Operator | Effect | Typical use |
|---|---|---|
| `buffer` / `bufferTime` / `bufferCount` | accumulate then release | batching messages |
| `throttle` / `throttleTime` | cap emission rate | scroll, rapid input |
| `debounce` / `debounceTime` | emit after quiet period | search-as-you-type |

## Worked Example

**A live chat over WebSocket with backpressure control** — the chapter's end-to-end RxJS
application:

```typescript
import { webSocket } from "rxjs/webSocket"
import { throttleTime, bufferTime, map, tap } from "rxjs/operators"
import { Observable } from "rxjs"

const chatSocket = webSocket<string>("ws://localhost:8080/chat")

const messageStream$: Observable<string> = chatSocket.pipe(
  tap((message) => console.log("New message received:", message)), // observe, don't mutate
  throttleTime(100),        // cap burst rate from a chatty room
  bufferTime(1000),         // batch a second's worth of messages
  map((messages) => messages.join("\n")),  // one UI update per batch
)

messageStream$.subscribe({
  next: (bufferedMessages) => {
    console.log("Buffered messages:", bufferedMessages)
    updateChatUI(bufferedMessages)
  },
  error: (error) => console.error("WebSocket error:", error),
})

function updateChatUI(messages: string) {
  console.log("Updating chat UI with:", messages)
}
```

**Why this ordering matters.** `throttleTime(100)` first drops the flood down to at most
ten messages per second; `bufferTime(1000)` then groups whatever survived into one array
per second; `map` collapses that array into a single string. The result is **one DOM
update per second** instead of one per message — which is precisely the backpressure
problem the operators exist to solve. Move `bufferTime` before `throttleTime` and you
throttle *arrays* instead of messages, silently dropping whole batches.

Note also that `tap` carries the logging. Putting `console.log` inside `map` would make
the transformation impure and break the FRP property the pipeline depends on.

## Key Takeaways

1. Reactive programming's benefits (efficiency, decoupling, simpler async code) evaporate
   if the async, non-blocking property is broken — that's when you get degradation and
   data loss.
2. Choose Pull for simple cases, Push when the producer knows its consumers, and
   Pull-Push when the payload is too large or sensitive to push directly.
3. Futures give you laziness and cancellation that Promises don't. TypeScript has no
   native Future — hand-roll it or use `Fluture`.
4. Observables are lazy: nothing happens until `subscribe()`. An error in the stream
   fires the `error` callback without closing the observable.
5. Know whether your observable is cold or hot — it determines whether late subscribers
   see history. `share()` makes it hot; `shareReplay(n)` gives late subscribers a buffer.
6. Keep pipelines pure: transformations in `map`/`filter`, side effects in `tap`.
7. Handle backpressure explicitly with buffer/throttle/debounce for high-frequency
   sources; operator *order* determines what actually gets dropped.
8. Test observable pipelines end to end with `TestScheduler` and marble diagrams rather
   than real timers.

## Connects To

- **Ch 5**: the Observer pattern — Observables are its composable generalization; the
  Push pattern is the Observer pattern applied to streams.
- **Ch 6**: the Iterator pattern — RxJS Observables build on ES6 iterators.
- **Ch 7**: FRP is reactive programming plus functional composition, purity, and
  referential transparency.
- **Ch 9**: building modern, robust applications where these streams live.
- **Reactive Manifesto**: <https://www.reactivemanifesto.org/> — the source of the
  responsive/resilient/elastic/message-driven vocabulary.
