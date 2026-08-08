# Chapter 11: Event-Driven Architecture — Using Events to Integrate Microservices

## Core Idea
Splitting a system into **nouns** connected by synchronous HTTP calls produces a **distributed ball of mud**. Split into **verbs** instead, treat each microservice as a consistency boundary, and integrate with **asynchronous messages**: each service accepts commands from outside and raises events recording the result.

## Frameworks Introduced

- **Think in verbs, not nouns**: *"Our domain model is about modeling a business process. It's not a static data model about a thing; it's a model of a verb."*
  - ❌ a system for **orders** and a system for **batches**
  - ✅ a system for **ordering** and a system for **allocating**
  - Why it clarifies ownership: "When thinking about *ordering*, really we want to make sure that when we place an order, the order is placed. Everything else can happen **later**, so long as it happens."
  - Note the book's own system is named `Allocation` (a verb), not `Batches` (a noun).

- **Microservices are consistency boundaries, exactly like aggregates.** Between two services you accept eventual consistency, so you don't need synchronous calls. *"Segregating responsibilities is the same process we went through when designing our aggregates and commands."*

- **Connascence** — a richer vocabulary than "coupling" for describing inter-system relationships. Connascence isn't *bad*; some kinds are *stronger* than others. **Want: strong connascence locally, weak connascence at a distance.**

  | Type | Where it appears | Strength |
  |---|---|---|
  | **Connascence of Execution** | Distributed ball of mud — multiple components must know the correct *order* of work | Strong ❌ at a distance |
  | **Connascence of Timing** | Synchronous RPC chains — multiple things must happen one after another for the operation to work | Strong ❌ at a distance |
  | **Connascence of Name** | Event-driven integration — components need only agree on the *name* of an event and its field names | **Weak ✅** |

  "We can never completely avoid coupling, except by having our software not talk to any other software. What we want is to avoid **inappropriate** coupling." (See connascence.io.)

- **Message broker**: infrastructure that takes messages from publishers and delivers them to subscribers. The book uses **Redis pub/sub** for familiarity; MADE.com uses **Event Store**; **Kafka** and **RabbitMQ** are valid alternatives.

- **Two thin adapters, mirroring Flask**:
  - **Event consumer** (`entrypoints/redis_eventconsumer.py`) — inbound. Deserialize JSON → build a `Command` → `messagebus.handle()`. "Much as the Flask adapter does."
  - **Event publisher** (`adapters/redis_eventpublisher.py`) — outbound. Domain event → JSON → `r.publish(channel, ...)`.

## Key Concepts

- **Distributed ball of mud** — the microservices anti-pattern: a service per database table, HTTP APIs as CRUD interfaces to anemic models.
- **Temporal coupling** — "every part of the system has to work at the same time for any part of it to work." As the system grows, the probability that *some* part is degraded rises exponentially.
- **Temporal decoupling** — what async messaging buys you.
- **Internal vs external events** — some events come from outside; some get "upgraded" and published externally; **not all of them will**. Keep the distinction clear (critical if you get into event sourcing).
- **`Allocated`** — the new outbound event: `orderid`, `sku`, `qty`, `batchref`.
- **At-least-once vs at-most-once delivery** — a choice you must now make consciously.

## Mental Models

- **Follow the arrows to spot the mud.** To allocate stock: Orders → Batches → Warehouse. To handle warehouse damage: Warehouse → Batches → Orders. *"Multiply this by all the other workflows we need to provide, and you can see how services quickly get tangled up."*
- **A failure in a downstream service becomes a business decision upstream.** Network error after taking an order for three `MISBEGOTTEN-RUG`: place the order anyway and leave it unallocated, or refuse the order because allocation can't be guaranteed? Either way, "the failure state of our batches service has bubbled up and is affecting the reliability of our order service."
- **Degraded behavior becomes tractable:** "we can still take orders if the allocation system is having a bad day."
- **Changes become local.** "If we need to change the order of operations or to introduce new steps in the process, we can do that locally."
- **The honest cost, per Martin Fowler:** *"Event notification is nice because it implies a low level of coupling, and is pretty simple to set up. It can become problematic, however, if there really is a logical flow that runs over various event notifications… It can be hard to see such a flow as it's not explicit in any program text…. This can make it hard to debug and modify."*
- **Validate outbound events.** "Outbound events are one of the places it's important to apply validation" (Appendix E).

## Code Examples

**Inbound adapter — Redis consumer, structurally identical to the Flask endpoint:**

```python
# src/allocation/entrypoints/redis_eventconsumer.py
r = redis.Redis(**config.get_redis_host_and_port())


def main():
    orm.start_mappers()
    pubsub = r.pubsub(ignore_subscribe_messages=True)
    pubsub.subscribe('change_batch_quantity')

    for m in pubsub.listen():
        handle_change_batch_quantity(m)


def handle_change_batch_quantity(m):
    logging.debug('handling %s', m)
    data = json.loads(m['data'])
    cmd = commands.ChangeBatchQuantity(ref=data['batchref'], qty=data['qty'])
    messagebus.handle(cmd, uow=unit_of_work.SqlAlchemyUnitOfWork())
```
- **What it demonstrates**: an entrypoint's whole job is deserialize → build a Command → hand to the service layer. Note it builds a **command** (imperative), not an event.

**Outbound adapter — Redis publisher:**

```python
# src/allocation/adapters/redis_eventpublisher.py
r = redis.Redis(**config.get_redis_host_and_port())


def publish(channel, event: events.Event):
    logging.debug('publishing: channel=%s, event=%s', channel, event)
    r.publish(channel, json.dumps(asdict(event)))
```
- The channel is hardcoded here, but "you could also store a mapping between event classes/names and the appropriate channel."

**The new outbound event, raised by the model:**

```python
# src/allocation/domain/events.py
@dataclass
class Allocated(Event):
    orderid: str
    sku: str
    qty: int
    batchref: str


# src/allocation/domain/model.py
class Product:
    def allocate(self, line: OrderLine) -> str:
        ...
            batch.allocate(line)
            self.version_number += 1
            self.events.append(events.Allocated(
                orderid=line.orderid, sku=line.sku, qty=line.qty,
                batchref=batch.reference,
            ))
            return batch.reference
```

**Wiring — one handler, one line:**

```python
HANDLERS = {
    events.Allocated: [handlers.publish_allocated_event],
    events.OutOfStock: [handlers.send_out_of_stock_notification],
}  # type: Dict[Type[events.Event], List[Callable]]


def publish_allocated_event(event: events.Allocated, uow: unit_of_work.AbstractUnitOfWork):
    redis_eventpublisher.publish('line_allocated', event)
```

## Reference Tables

| Event-based microservices integration: the trade-offs | |
|---|---|
| **Pros** | **Cons** |
| Avoids the distributed big ball of mud | The overall flows of information are **harder to see** |
| Services are decoupled — easier to change individual services and add new ones | Eventual consistency is a new concept to deal with |
| Things fail independently, so degraded behavior is manageable | Message reliability and **at-least-once vs at-most-once** delivery need thinking through |

| Integration style | Connascence | Failure mode |
|---|---|---|
| Synchronous HTTP between noun-services | Execution + Timing (strong) | Cascades; every service must be up |
| Async events via broker | **Name** (weak) | Isolated; eventual consistency |

## Worked Example

**The noun-based design, and exactly where it breaks.**

Naive split by nouns: `Orders`, `Batches`, `Warehouse`, `CRM` — "a microservice per database table… HTTP APIs as CRUD interfaces to anemic models. This is the most common initial way for people to approach service-oriented design."

*Happy path:*
```
Customer -> Orders   : Add product to basket
Orders   -> Batches  : Reserve stock
Customer -> Orders   : Place order
Orders   -> Batches  : Confirm reservation
Batches  -> Warehouse: Dispatch goods
Orders   -> CRM      : Update customer record   (3rd order → VIP)
```
Each step is a command: `ReserveStock`, `ConfirmReservation`, `DispatchGoods`, `MakeCustomerVIP`. *"This works fine for systems that are very simple."*

*Then a second workflow arrives.* Stock arrives water-damaged in transit. Can't sell water-damaged sofas — throw them away, request more from partners, update the stock model, possibly reallocate a customer's order. **Where does this logic go?** The Warehouse system knows the stock is damaged, so maybe it owns the process:
```
Warehouse worker -> Warehouse: Report stock damage
Warehouse -> Batches : Decrease available stock
Batches   -> Batches : Reallocate orders
Batches   -> Orders  : Update order status
Orders    -> CRM     : Update order history
```
> "This sort of works too, but now our dependency graph is a mess. To allocate stock, the Orders service drives the Batches system, which drives Warehouse; but in order to handle problems at the warehouse, our Warehouse system drives Batches, which drives Orders."

**The event-driven replacement.** `BatchQuantityChanged` arrives from Redis; `Allocated` goes back out to Redis:
```
Redis -> MessageBus : BatchQuantityChanged event

group ChangeBatchQuantity Handler + Unit of Work 1
    MessageBus -> Domain_Model : change batch quantity
    Domain_Model -> MessageBus : emit Allocate command(s)
end

group Allocate Handler + Unit of Work 2 (or more)
    MessageBus -> Domain_Model : allocate
    Domain_Model -> MessageBus : emit Allocated event(s)
end

MessageBus -> Redis : publish to line_allocated channel
```

**The E2E test that drives it — in through one channel, out through another:**

```python
def test_change_batch_quantity_leading_to_reallocation():
    # start with two batches and an order allocated to one of them
    orderid, sku = random_orderid(), random_sku()
    earlier_batch, later_batch = random_batchref('old'), random_batchref('newer')
    api_client.post_to_add_batch(earlier_batch, sku, qty=10, eta='2011-01-02')
    api_client.post_to_add_batch(later_batch, sku, qty=10, eta='2011-01-02')
    response = api_client.post_to_allocate(orderid, sku, 10)
    assert response.json()['batchref'] == earlier_batch

    subscription = redis_client.subscribe_to('line_allocated')

    # change quantity on allocated batch so it's less than our order
    redis_client.publish_message('change_batch_quantity', {
        'batchref': earlier_batch, 'qty': 5
    })

    # wait until we see a message saying the order has been reallocated
    messages = []
    for attempt in Retrying(stop=stop_after_delay(3), reraise=True):
        with attempt:
            message = subscription.get_message(timeout=1)
            if message:
                messages.append(message)
                print(messages)
            data = json.loads(messages[-1]['data'])
            assert data['orderid'] == orderid
            assert data['batchref'] == later_batch
```
**Why the retry loop:** the system under test is asynchronous, so (a) the `line_allocated` message may take time to arrive, and (b) **it won't be the only message on that channel**. `tenacity` again.

## Anti-patterns

- **Splitting a system into nouns** and naming services after data tables.
- **CRUD HTTP APIs over anemic models** as the integration strategy.
- **Synchronous RPC chains between services** — Connascence of Execution and Timing at a distance.
- **Publishing every internal event externally.** Keep the internal/external distinction deliberate.
- **Glossing over broker semantics.** "Concerns like message ordering, failure handling, and idempotency all need to be thought through."

## Key Takeaways

1. **Name your services after verbs (processes), not nouns (things).** It immediately clarifies which service owns which responsibility.
2. **Treat each microservice as a consistency boundary**, exactly as you treat an aggregate. Between services, accept eventual consistency.
3. **Each service accepts commands from outside and raises events recording the result.** Other services subscribe to those events to trigger the next step.
4. **Connascence of Name is the goal at a distance** — agreement on an event name and its field names, nothing more.
5. **Entrypoints stay thin regardless of transport.** A Redis consumer and a Flask endpoint do the same job: deserialize, build a command, call the bus.
6. **You buy independent failure and local changeability; you pay in visibility.** No program text shows the end-to-end flow anymore.
7. **Validate outbound events** — they're your public contract.

## Connects To
- **Ch 9**: where `BatchQuantityChanged` events came from — answered here: an external Redis channel.
- **Ch 10**: commands vs events, applied across service boundaries; the consumer builds a `ChangeBatchQuantity` *command*.
- **Ch 7**: aggregates as consistency boundaries — the same reasoning, one level up.
- **Ch 4**: Flask as a thin adapter; the Redis consumer is its twin.
- **Appendix E**: validating outbound events.
- **Epilogue ("Footguns")**: message reliability, ordering, idempotency, and eventual-consistency pitfalls.
- **connascence.io**; **Martin Fowler, "What do you mean by 'Event-Driven'"**.
