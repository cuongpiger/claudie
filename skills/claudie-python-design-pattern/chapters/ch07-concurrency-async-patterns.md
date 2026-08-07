# Chapter 7: Concurrency and Asynchronous Patterns

## Core Idea

Concurrency lets a program manage many operations at once; asynchronous programming lets it move on to other work while waiting for an operation to finish. Chef analogy: concurrency is cooking several dishes in parallel so all finish together; async is sending the order to the kitchen and serving other customers meanwhile.

These four patterns are the practical vocabulary: pool your threads instead of spawning them, split big work into independent worker units, hand back a placeholder instead of blocking, and treat streams of events as observable pipelines.

## Frameworks Introduced

- **Thread Pool**: Creating a thread per task is expensive — like hiring a new employee for every job then firing them. Keep a fixed pool of worker threads created once and reused; a thread that finishes a task returns to the pool instead of dying.
  - When to use: batch processing (many parallelizable tasks), load balancing (spread work evenly so no thread is overloaded), resource optimization (cap memory/CPU by capping thread count).
  - How: `concurrent.futures.ThreadPoolExecutor(max_workers=N)` as a context manager; `executor.submit(fn, arg)` per task. Four phases: initialization (pool creates workers), task submission (submit to pool, not a new thread), task execution (pool assigns to a free worker; queue if all busy), return to pool.
  - Real-world example: small restaurant with limited chefs (threads) and limited kitchen space (system resources) — orders queue until a chef frees up. Software: web servers handling client requests, database connection pools, task schedulers running cron jobs/backups.

- **Worker Model**: Divide a large task, or many tasks, into smaller manageable units processed in parallel. Workers can be threads in one app, separate processes on one machine, or different machines in a distributed system.
  - When to use: data transformation over a large dataset, task parallelism (independent tasks), distributed computing across multiple machines.
  - How: `multiprocessing.Process` + `multiprocessing.Queue`. Three components: **workers** (each processes a piece independently), **task queue** (central buffer decoupling submission from processing), **dispatcher** (optional — assigns tasks by availability, load, or priority).
  - Real-world example: delivery service where couriers (workers) pull packages (tasks) from a distribution center (task queue); courier count scales with demand. Software: map/reduce in big data, RabbitMQ/Kafka message consumers, image processing services.

- **Future and Promise**: A Future represents a value not yet known but eventually provided. An async function returns the Future immediately instead of blocking — that property is **non-blocking**. A Promise is the writable, controlling counterpart: the producer side that fulfills with a value or rejects with an error, which resolves the Future. Promises chain, so sequences of async operations stay concise.
  - When to use: data pipelines (each stage returns a Future so later stages don't block), task scheduling (Future tracks a task's state without blocking), complex database queries/transactions (return control to the UI immediately), file I/O offloaded to the background.
  - How (threads): `concurrent.futures.ThreadPoolExecutor` — `executor.submit()` returns a `Future`; `as_completed(futures)` iterates them in completion order; `future.result()` reads the value.
  - How (async): `asyncio` — `async def` coroutines, `await`, `asyncio.ensure_future()` to build Futures, `asyncio.gather()` to await many and collect results, `asyncio.run(main())` to drive the event loop.
  - Real-world example: ordering a custom dining table — the completion date and design sketch are the Future, the carpenter's work is the Promise moving toward fulfillment, delivery resolves it. Also: online order tracking numbers, food delivery ETAs, support ticket numbers.

- **Observer in reactive programming**: The classic Observer (Chapter 5) works, but with many interdependent events it degrades into complicated, hard-to-maintain code. Reactive programming reacts to *streams* of events while keeping code clean.
  - When to use: collection pipelines (Martin Fowler — organize computation as a sequence of operations, each taking the previous one's collection as input), map/reduce or `group_by` over object sequences, and observables built from button events, requests, or Twitter feeds.
  - How: ReactiveX via RxPY — `pip install reactivex`. `rx.from_iterable()`, `rx.interval()`, `.pipe()` with `operators as ops`: `flat_map`, `filter`, `map`, `group_by`, `count`, then `.subscribe(callback)`.
  - Real-world example: airport flight information display — continuously streams arrivals, departures, delays, cancellations; travelers, airline staff, and airport services subscribe and react. Also: a spreadsheet reevaluating every dependent formula the moment one cell changes.

- **Other patterns (named, not implemented)**: **Actor model** (actors make local decisions, create more actors, send messages, decide how to respond to the next message), **Coroutines** (control passed cooperatively between routines without returning; built into Python via `asyncio`), **Message passing** (parallel computing, OOP, IPC — entities coordinate by passing messages), **Backpressure** (signal the producer to slow down until the consumer catches up, preventing overload).

## Key Concepts

- **Thread**: smallest unit of processing schedulable by the OS. Threads are tracks of execution running at the same time.
- **Worker thread**: a thread dedicated to a task or set of tasks, offloading work from the main thread to keep the app responsive.
- **Pool benefits**: reduced overhead (no create/destroy per task) and better resource management (capped thread count prevents resource exhaustion).
- **I/O-bound vs CPU-bound**: `asyncio` is *particularly useful for I/O-bound tasks* — web scraping, API calls, network requests, file I/O. Futures generally target I/O operations, network requests, and other time-consuming async tasks.
- **Thread vs process**: Thread Pool uses threads inside one application. Worker Model generalizes to separate processes (`multiprocessing.Process`) or even separate machines — that's what buys scalability and true parallelism.
- **Coroutine / async / await**: a coroutine can pause and resume, letting other coroutines run meanwhile. Declared `async def`; awaited from other coroutines with `await`. `asyncio.sleep()` is itself a coroutine — always `await` it.
- **Future vs Promise**: Future = read side, the placeholder consumers hold. Promise = write side, the producer that fulfills or rejects. Resolution flows Promise → Future, consumed via callbacks, polling, or blocking on the result.
- **GIL implication (as the authors frame it)**: the book does not name the GIL directly, but its guidance encodes it — threads for I/O and responsiveness, separate *processes* (`multiprocessing`) when you want real parallel computation.
- **Nondeterministic ordering**: in every example, results arrive out of submission order. "It is not predictable. This is generally the case with concurrency or asynchronous code." Never depend on completion order.

## Mental Models

Choosing the execution model:

1. **Waiting on I/O, and you can write async code end-to-end?** → `asyncio`. Cheapest per task, no thread overhead, scales to thousands of in-flight operations.
2. **Waiting on I/O, but the library is blocking (legacy DB driver, `requests`)?** → `ThreadPoolExecutor`. Threads are fine here because they're blocked, not computing.
3. **Burning CPU (transforms, image processing, map/reduce)?** → `multiprocessing.Process` + `Queue`, i.e. the Worker Model. Separate processes sidestep single-interpreter contention.
4. **Work exceeds one machine?** → Worker Model extended to distributed workers pulling from a broker (RabbitMQ, Kafka).

Two-axis view: **Thread Pool is about reuse** of a fixed number of threads; **Worker Model is about distribution** of tasks across scalable, flexible worker entities. Pool answers "how do I stop paying thread startup cost"; Worker Model answers "how do I add capacity."

Future/Promise is orthogonal — it's the *result-handling* layer over whichever executor you picked. Same `Future` vocabulary in both `concurrent.futures` and `asyncio`.

## Anti-patterns

- Creating a thread per task — the overhead the Thread Pool exists to remove.
- Unbounded thread creation — no `max_workers` cap means resource exhaustion.
- Blocking on results in submission order (`future1.result()`, then `future2.result()`) instead of `as_completed()` — you serialize what you paid to parallelize.
- Assuming output order matches submission order.
- Calling a coroutine without `await` (notably `asyncio.sleep()`) — nothing runs.
- Forgetting `asyncio.run(main())` — coroutines need an event loop.
- Skipping `p.join()` on worker processes — the program exits before workers finish.
- Chaining many interdependent event handlers with the classic Observer where a reactive pipeline belongs.
- Producing faster than consumers can absorb, with no backpressure signal.

## Code Examples

```python
from concurrent.futures import ThreadPoolExecutor
import time


def task(n):
    print(f"Executing task {n}")
    time.sleep(1)
    print(f"Task {n} completed")


with ThreadPoolExecutor(max_workers=5) as executor:
    for i in range(10):
        executor.submit(task, i)
```
- **What it demonstrates**: Thread Pool — 10 tasks, 5 reusable workers; finished threads pick up the next queued task.

```python
from multiprocessing import Process, Queue
import time


def worker(task_queue):
    while not task_queue.empty():
        task = task_queue.get()
        print(f"Worker {task} is processing")
        time.sleep(1)
        print(f"Worker {task} completed")


def main():
    task_queue = Queue()
    for i in range(10):
        task_queue.put(i)

    processes = [
        Process(target=worker, args=(task_queue,)) for _ in range(5)
    ]
    # Start the worker processes
    for p in processes:
        p.start()
    # Wait for all worker processes to finish
    for p in processes:
        p.join()

    print("All tasks completed.")
```
- **What it demonstrates**: Worker Model — 5 processes pulling from a shared `multiprocessing.Queue` until it drains.

```python
from concurrent.futures import ThreadPoolExecutor, as_completed


def square(x):
    return x * x


with ThreadPoolExecutor() as executor:
    future1 = executor.submit(square, 2)
    future2 = executor.submit(square, 3)
    future3 = executor.submit(square, 4)

    futures = [future1, future2, future3]
    for future in as_completed(futures):
        print(f"Result: {future.result()}")
```
- **What it demonstrates**: Future and Promise via `concurrent.futures` — `submit()` returns immediately; `as_completed()` yields Futures as they resolve (output: `16`, `4`, `9`).

```python
import asyncio


async def square(x):
    # Simulate some IO-bound operation
    await asyncio.sleep(1)
    return x * x


async def main():
    fut1 = asyncio.ensure_future(square(2))
    fut2 = asyncio.ensure_future(square(3))
    fut3 = asyncio.ensure_future(square(4))

    results = await asyncio.gather(fut1, fut2, fut3)
    for result in results:
        print(f"Result: {result}")


if __name__ == "__main__":
    asyncio.run(main())
```
- **What it demonstrates**: Future and Promise via `asyncio` — coroutines wrapped as Futures, awaited together with `gather()`, driven by `asyncio.run()`.

```python
from pathlib import Path
import reactivex as rx
from reactivex import operators as ops


def firstnames_from_db(path: Path):
    file = path.open()
    # collect and push stored people firstnames
    return rx.from_iterable(file).pipe(
        ops.flat_map(
            lambda content: rx.from_iterable(content.split(", "))
        ),
        ops.filter(lambda name: name != ""),
        ops.map(lambda name: name.split()[0]),
        ops.group_by(lambda firstname: firstname),
        ops.flat_map(
            lambda grp: grp.pipe(
                ops.count(),
                ops.map(lambda ct: (grp.key, ct)),
            )
        ),
    )


def main():
    db_path = Path(__file__).parent / Path("people.txt")
    # Emit data every 5 seconds
    rx.interval(5.0).pipe(
        ops.flat_map(lambda i: firstnames_from_db(db_path))
    ).subscribe(lambda val: print(str(val)))

    # Keep alive until user presses any key
    input("Starting... Press any key and ENTER, to quit\n")
```
- **What it demonstrates**: Observer in reactive programming — a re-polling Observable pipeline counting first-name occurrences, emitting `('Peter', 1)` style tuples every 5 seconds.

## Reference Tables

| Pattern | Intent | When to use | Python mechanism |
|---|---|---|---|
| Thread Pool | Reuse a bounded set of threads instead of creating one per task | Batch processing, load balancing, resource optimization | `concurrent.futures.ThreadPoolExecutor(max_workers=N)`, `.submit()` |
| Worker Model | Split work into independent units processed in parallel by scalable workers | Data transformation, task parallelism, distributed computing | `multiprocessing.Process`, `multiprocessing.Queue`, `.start()`/`.join()` |
| Future and Promise | Return a placeholder immediately; resolve it later without blocking | Data pipelines, task scheduling, async DB queries, file I/O | `executor.submit()` → `Future`, `as_completed()`, `future.result()`; or `asyncio.ensure_future()`, `asyncio.gather()`, `asyncio.run()` |
| Observer (reactive) | React to streams of events with composable operators | Collection pipelines, map/reduce and `group_by` over sequences, UI/feed events | RxPY (`reactivex`): `rx.from_iterable`, `rx.interval`, `.pipe()`, `ops.flat_map/filter/map/group_by/count`, `.subscribe()` |
| Actor model | Concurrent computation via isolated actors exchanging messages | Stateful concurrent entities | Third-party (not implemented in chapter) |
| Backpressure | Signal producers to slow down so consumers can catch up | Overload-prone stream systems | Reactive operators / bounded queues |

| Workload type | Choose | Why |
|---|---|---|
| I/O-bound, async-capable libraries (web scraping, API calls) | `asyncio` | Coroutines suspend on `await`; thousands in flight, no thread cost |
| I/O-bound, blocking libraries | `ThreadPoolExecutor` | Threads park on the blocking call; reuse avoids per-task overhead |
| CPU-bound (transforms, image processing) | `multiprocessing` / Worker Model | Separate processes give real parallel computation |
| Many independent tasks, elastic capacity needed | Worker Model + task queue | Add or remove workers with demand |
| Beyond one machine | Worker Model, distributed | Workers consume from RabbitMQ/Kafka across nodes |
| Continuous event streams | Observer (RxPY) | Composable pipeline instead of tangled callbacks |

## Worked Example

**Future and Promise with `asyncio`, end to end.**

Goal: square 2, 3, and 4 where each computation includes an I/O-bound wait, without paying 3 seconds of serial waiting.

1. **Model the task as a coroutine.** `async def square(x)` marks it suspendable. Inside, `await asyncio.sleep(1)` stands in for a network call or file read. `asyncio.sleep()` is itself a coroutine, so `await` is mandatory — dropping it produces a coroutine object that never runs.

2. **Initiate — get Futures, not values.** `asyncio.ensure_future(square(2))` schedules the coroutine on the event loop and hands back a Future immediately. Three calls, three Futures, all three already in flight. This is the Promise side starting work; `fut1` is the read-side placeholder.

3. **Execute concurrently.** Each `square` hits its `await` and yields control back to the loop, which starts the next. All three one-second sleeps overlap.

4. **Resolve.** `results = await asyncio.gather(fut1, fut2, fut3)` suspends `main()` until every Future resolves, then returns the results. Unlike `as_completed()`, `gather()` returns a list, so `main()` prints `4`, `9`, `16`.

5. **Drive the loop.** `asyncio.run(main())` inside `if __name__ == "__main__":` creates the event loop, runs `main()` to completion, and tears the loop down.

Total wall time ≈ 1 second, not 3. Swap `asyncio.sleep()` for real HTTP calls and the same shape scales to web scraping or fan-out API work — exactly the I/O-bound niche `asyncio` targets.

## Key Takeaways

- Thread Pool = **reuse**; Worker Model = **distribution**. Different problems, often combined.
- Cap your workers. An unbounded pool defeats the pattern's resource-management benefit.
- `submit()` returns a Future instantly — that non-blocking return is the entire point.
- `as_completed()` for streaming results as they land; `asyncio.gather()` for "wait for all, give me the list."
- Future = read side, Promise = write side. Same vocabulary in `concurrent.futures` and `asyncio`.
- `asyncio` is the I/O-bound tool; `multiprocessing` is the CPU-bound tool.
- Never assume completion order matches submission order.
- Reactive Observers turn many interdependent events into one readable pipeline; classic Observer doesn't scale to that.
- Actor model, coroutines, message passing, and backpressure exist with their own trade-offs — worth knowing by name.

## Connects To

- **Chapter 5 (Behavioral Patterns)**: reactive Observer is the classic Observer scaled to event streams; RxPY's `.pipe()` chain is Chain of Responsibility in operator form.
- **Chapter 6 (Architectural Patterns)**: Worker Model is how microservice/event-driven architectures actually consume from Kafka or RabbitMQ.
- **Chapter 8 (Performance Patterns)**: the direct sequel — concurrency buys throughput, performance patterns (caching, lazy evaluation) buy avoided work. Combine both.
- **Chapter 3 (Structural Patterns)**: a Future is a Proxy for a value that does not exist yet.
- **Chapter 2 (Creational Patterns)**: a thread pool is Object Pool applied to threads.
