# Chapter 9: Distributed Systems Patterns

## Core Idea

Distributed systems fail partially and unpredictably. Nodes talk over networks you don't own, to services other teams deploy. Three patterns cover the load-and-failure axis: **Throttling** protects a service from its callers, **Retry** absorbs transient faults, **Circuit Breaker** stops wasting resources on long-lasting failures. They are not alternatives — combine them and tune to your system's constraints.

Technical requirements for this chapter:

```
python -m pip install flask flask-limiter
python -m pip install pybreaker
```

## Frameworks Introduced

- **Throttling**: Control the rate of requests a user (or client service) can send to a service or API in a given time window, protecting service resources from overuse. Once the limit is reached, respond with HTTP **429** and a "too many requests" message.
  - When to use: when the system must continuously deliver service as expected; when you need to optimize cost of usage; when you need to handle bursts in activity. Also for **resource allocation** — fair distribution among multiple clients. Practical rules: N requests/day total (e.g. N=1000); N/day per IP address, country, or region; separate read/write limits for authenticated users.
  - How: pick a throttling type — **Rate-Limit**, **IP-level Limit** (e.g. whitelist), **Concurrent Connections Limit**. The chapter implements Rate-Limit with **Flask** + **Flask-Limiter**: a `Limiter` built from a key function (`get_remote_address`), the app object, `default_limits`, `storage_uri`, and `strategy="fixed-window"`. Per-route overrides via `@limiter.limit("2/minute")`. Other tooling: **django-throttle-requests** (Django rate-limiting middleware), Redis as a storage backend for multi-process deployments.
  - Why it works / failure mode: the limiter rejects cheaply before the expensive handler runs, so a surge costs 429s instead of a crash. Failure mode is misconfigured scope — `storage_uri="memory://"` is per-process, so counters diverge across workers; and a fixed window lets a client burst across the window boundary.
  - Real-world example: concert ticket sales capping tickets per user to stop the server crashing on a demand surge. Also highway traffic lights/speed limits, a water faucet, peak/off-peak electricity pricing, one-plate-at-a-time buffet lines.

- **Retry**: Cloud-native applications hit **transient faults** — mini-issues that look like bugs but come from outside your application (networking, external server/service performance). Users perceive malfunction or hangs. Answer: call the service again, immediately or after a wait.
  - When to use: to alleviate **identified transient failures** when communicating with an external component or service, due to network failure or server overload. Microservices communicating over the network — retry keeps a transient failure from failing the whole system. **Data synchronization** — retries cover temporary unavailability of one side.
  - How: a `retry(attempts)` decorator wrapping the fragile call in `try/except`, `time.sleep(1)` between attempts, returning a failure sentinel after exhausting attempts. Library option: the **Retrying** library (`https://github.com/rholder/retrying`); Go equivalent: **Pester**.
  - Why it works / failure mode: transient means the next attempt sees different conditions. Failure mode is retrying the wrong class of error — **not recommended for internal exceptions caused by errors in your own application logic**. Analyze the response from the external service: frequent busy faults signal a scaling problem on their side that retrying will not fix. Persistent errors across attempts (four DB errors in the example run) mean a permanent bug, not a blip.
  - Real-world example: redialing a friend after a busy line; retrying an ATM withdrawal after a network-congestion error.

- **Circuit Breaker**: When a failure from an external component is likely to be **long-lasting**, retrying hurts responsiveness — you waste time and resources repeating a request that will fail. Wrap the fragile call or integration point in a circuit breaker object that monitors failures; once failures hit a threshold, the breaker **trips** and all subsequent calls return an error **without the protected call being made at all**.
  - When to use: when a component must be fault-tolerant to long-lasting failures communicating with an external component, service, or resource.
  - How: **pybreaker** (`https://pypi.org/project/pybreaker/`). Create `pybreaker.CircuitBreaker(fail_max=..., reset_timeout=...)` and apply it as a decorator on the flaky function. Trips raise `CircuitBreakerError`. (Implementation adapted from `https://github.com/veltra/pybreaker-playground`.)
  - Why it works / failure mode: failing fast frees threads, connections, and latency budget, and removes load from a struggling dependency so it can recover. After `reset_timeout` the breaker lets one call through: succeed and the circuit closes, fail and it opens again until another timeout elapses. Failure mode is a threshold set too low (normal noise trips it) or `reset_timeout` too short (probe traffic hammers a dependency that hasn't recovered).
  - Real-world example: e-commerce checkout — payment gateway down, breaker halts further payment attempts to prevent system overload. Rate-limited APIs — breaker stops additional requests once the limit is hit, avoiding penalties. Physical analogy: the breaker in a water or electricity distribution circuit.

## Key Concepts

- **Transient fault** — a short-lived failure outside your control (network, external service load). The only failure class retry legitimately targets.
- **Fault tolerance (FT)** — the property all three patterns serve; retries are one approach, circuit breaking another.
- **Rate limit window** — Flask-Limiter `strategy="fixed-window"`; limits expressed as strings, `"100 per day"`, `"10 per hour"`, `"2/minute"`.
- **Key function** — how the limiter buckets callers; `get_remote_address` buckets per client IP.
- **Storage backend** — `storage_uri="memory://"` for experiments; Redis for real multi-process deployments.
- **Circuit breaker states** — **closed** (calls pass, failures counted), **open** (calls rejected immediately with `CircuitBreakerError`), **half-open** (after `reset_timeout`, one trial call decides: success closes, failure re-opens).
- **`fail_max`** — consecutive failures that trip the breaker. **`reset_timeout`** — seconds open before a trial call is allowed.
- **Attempts vs. wait** — retry has two dials: attempt count and inter-attempt delay (fixed `time.sleep(1)` here; backoff/jitter is the standard extension this hand-rolled decorator omits).

## Mental Models

**Retry vs. Circuit Breaker — the duration test.** Retry assumes the fault is *transient*: try again and conditions differ. Circuit breaker assumes the fault is *durable*: trying again just burns your resources on a call that will fail. Ask how long the failure lasts. Milliseconds-to-seconds blip → retry. Dependency is down/overloaded → break the circuit.

**Why retry alone makes an outage worse.** A struggling service gets N× its normal traffic the moment every client starts retrying — the same clients that would have backed off now amplify load, and the failing service can never drain its backlog to recover. Retries also occupy your threads and connections while a request that will never succeed sits in `time.sleep`. The circuit breaker is the ceiling on retry: retry inside the breaker, and once failures cross `fail_max` stop generating load entirely until `reset_timeout` allows one polite probe.

**Layered defense, not competing choices.** Throttling protects you *from* callers (inbound). Retry and circuit breaker protect you *from* dependencies (outbound). These patterns "often work best when combined and tailored to fit the specific needs and constraints of your system."

**Frequent transient faults are a diagnosis, not a nuisance.** Constant busy faults = the accessed service has a scaling problem. Retry is masking, not fixing.

## Anti-patterns

- Retrying internal exceptions from your own application logic — the bug is deterministic; N attempts produce N identical failures.
- Retrying indefinitely, or with a fixed delay and no ceiling — turns a partial outage into a retry storm against a dependency that cannot recover.
- Using retry where the failure is long-lasting: "we might be wasting time and resources trying to repeat a request that's likely to fail."
- Using retry as a permanent workaround for a dependency's scaling problem instead of fixing the scaling problem.
- No throttling on an expensive endpoint — a demand surge crashes the server instead of receiving 429s.
- Shipping `storage_uri="memory://"` to a multi-worker production deployment; each process keeps its own counters, so real limits are workers × configured limit.

## Code Examples

```python
from flask import Flask
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

app = Flask(__name__)

limiter = Limiter(
    get_remote_address,
    app=app,
    default_limits=["100 per day", "10 per hour"],
    storage_uri="memory://",
    strategy="fixed-window",
)


@app.route("/limited")
def limited_api():
    return "Welcome to our API!"


@app.route("/more_limited")
@limiter.limit("2/minute")
def more_limited_api():
    return "Welcome to our expensive, thus very limited, API!"


if __name__ == "__main__":
    app.run(debug=True)
```
- **What it demonstrates**: Rate-Limit throttling with per-IP default limits plus a stricter per-route override; the 10th refresh of `/limited` and the 3rd of `/more_limited` inside a minute return **Too Many Requests**.

```python
import logging
import random
import time

logging.basicConfig(level=logging.DEBUG)


def retry(attempts):
    def decorator(func):
        def wrapper(*args, **kwargs):
            for _ in range(attempts):
                try:
                    logging.info("Retry happening")
                    return func(*args, **kwargs)
                except Exception as e:
                    time.sleep(1)
                    logging.debug(e)
            return "Failure after all attempts"

        return wrapper

    return decorator
```
- **What it demonstrates**: The Retry pattern as a reusable decorator — bounded attempt loop, exception swallowed and logged, fixed 1-second pause, explicit failure value once attempts are exhausted.

```python
@retry(attempts=3)
def connect_to_database():
    if random.randint(0, 1):
        raise Exception("Temporary Database Error")
    return "Connected to Database"


if __name__ == "__main__":
    for i in range(1, 6):
        logging.info(f"Connection attempt #{i}")
        print(f"--> {connect_to_database()}")
```
- **What it demonstrates**: Applying retry to a simulated flaky DB connection; the driver loop shows some attempts succeeding on the first try and others exhausting all three retries into `Failure after all attempts`.

```python
import pybreaker
from datetime import datetime
import random
from time import sleep

breaker = pybreaker.CircuitBreaker(fail_max=2, reset_timeout=5)


@breaker
def fragile_function():
    if not random.choice([True, False]):
        print(" / OK", end="")
    else:
        print(" / FAIL", end="")
        raise Exception("This is a sample Exception")


def main():
    while True:
        print(datetime.now().strftime("%Y-%m-%d %H:%M:%S"), end="")
        try:
            fragile_function()
        except Exception as e:
            print(" / {} {}".format(type(e), e), end="")
        finally:
            print("")
        sleep(1)
```
- **What it demonstrates**: The Circuit Breaker pattern via `pybreaker` — decorator-wrapped fragile call, trip after `fail_max` consecutive failures, immediate `CircuitBreakerError` while open, one trial call after `reset_timeout=5` seconds.

## Reference Tables

| Pattern | Intent | When to use | Mechanism / library |
|---|---|---|---|
| Throttling | Cap request rate to protect service resources | Continuous service delivery, cost control, burst handling, fair resource allocation | `Limiter` from **Flask-Limiter** (`get_remote_address`, `default_limits`, `strategy="fixed-window"`, `storage_uri`); **django-throttle-requests** for Django; returns HTTP 429 |
| Retry | Absorb transient faults from external components | Network failure, server overload, microservice calls, data synchronization | `retry(attempts)` decorator with `try/except` + `time.sleep`; **Retrying** library (Python), **Pester** (Go) |
| Circuit Breaker | Fail fast on long-lasting external failures | External component/service/resource likely down for a while | `pybreaker.CircuitBreaker(fail_max, reset_timeout)` as decorator; raises `CircuitBreakerError` |

| From state | Trigger | To state | Behavior while there |
|---|---|---|---|
| Closed | Consecutive failures reach `fail_max` | Open | Calls execute normally; failures counted |
| Open | `reset_timeout` seconds elapse | Half-open | All calls raise `CircuitBreakerError` immediately; protected call never made |
| Half-open | Trial call succeeds | Closed | One call allowed through as a probe |
| Half-open | Trial call fails | Open | Timer restarts; blocked until another timeout elapses |

| Throttling type | Basis |
|---|---|
| Rate-Limit | Requests per time window per key (IP, user, token) |
| IP-level Limit | Whitelist/blacklist of IP addresses, region, country |
| Concurrent Connections Limit | Simultaneous in-flight connections |

## Worked Example

**Circuit Breaker over a flaky function, end to end.**

`fragile_function()` fails roughly half the time — think an integration point degraded by its networking environment. Retry alone would sleep-and-repeat through every outage, holding resources hostage. Instead, wrap it.

```python
breaker = pybreaker.CircuitBreaker(fail_max=2, reset_timeout=5)


@breaker
def fragile_function():
    if not random.choice([True, False]):
        print(" / OK", end="")
    else:
        print(" / FAIL", end="")
        raise Exception("This is a sample Exception")
```

Reasoning through the runtime behavior of the `main()` loop (one call per second, timestamped):

1. **Closed.** Calls run. `pybreaker` counts consecutive failures; a success resets the count.
2. **Trip.** Two consecutive `Exception`s reach `fail_max=2` and the breaker opens.
3. **Open.** Every subsequent call fails *immediately* with `CircuitBreakerError` — "without any attempt to execute the intended operation." Latency drops to near zero and the dependency stops receiving load. `main()` catches it in the same broad `except Exception` and prints the type, which is how you can read state transitions straight from the output.
4. **Half-open probe.** After `reset_timeout=5` seconds the breaker allows the next call through.
5. **Resolve.** Probe succeeds → circuit closes, normal traffic resumes. Probe fails → circuit re-opens for another 5 seconds.

The two dials carry all the design intent: `fail_max` sets tolerance for noise (too low and normal flakiness trips you), `reset_timeout` sets recovery patience (too short and probes hammer a dependency still on the floor). Note the chapter's prose describes opening "after five consecutive failures" while the code sets `fail_max=2` — the code is authoritative; pick the threshold from your own error budget.

## Key Takeaways

- Throttling is inbound protection; retry and circuit breaker are outbound resilience. Different directions, same goal.
- Retry only transient, externally-caused faults. Never retry your own logic bugs.
- Bound retries. Unbounded or fixed-delay retry amplifies an outage into a storm.
- The circuit breaker's value is the *call not made* — open state costs nothing and gives the dependency room to recover.
- Half-open is the cheap, self-healing recovery test: one probe, no fleet-wide thundering herd.
- Frequent transient faults are a signal to fix the dependency's scaling, not to raise the retry count.
- Rate limits need the right key function, window strategy, and a shared storage backend (Redis) once you run more than one process.
- These are pieces of a larger puzzle — combine and tailor them; understand the principles so you can adapt them.

## Connects To

- **Other distributed systems patterns** named in this chapter: **CQRS** (separate read and write responsibilities for optimized data access and scalability), **Two-Phase Commit** (prepare then commit, for atomicity/consistency across participating resources), **Saga** (sequence of local transactions with compensating actions for partial failures), **Sidecar** (helper services deployed alongside primaries for monitoring, logging, security without modifying the main app), **Service Registry** (dynamic service registration and discovery), **Bulkhead** (partition resources so failures isolate instead of cascading — the natural companion to the circuit breaker).
- **Decorator pattern** (Ch. 5): both retry and `pybreaker` ship as decorators — cross-cutting resilience added without touching the wrapped function.
- **Proxy pattern**: the circuit breaker object is a protective proxy in front of an integration point.
- **Chapter 10, Testing patterns**: flaky external calls are exactly what you stub/mock; retry and breaker logic need deterministic tests.
- External catalog: Microsoft's cloud design patterns, Throttling entry — `https://learn.microsoft.com/en-us/azure/architecture/patterns/throttling`.
