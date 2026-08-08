# Chapter 9: Going to Town on the Message Bus

## Core Idea
Stop treating the message bus as an optional side channel. **Make it the main entrypoint to the service layer**: rename `services.py` → `handlers.py`, give every function the same signature `(event, uow)`, and let the API construct events instead of calling functions. The app becomes a message processor, and the complexity of new requirements stops translating into architectural complexity.

## Frameworks Introduced

- **Everything is an event handler**: there were two kinds of flow — API calls handled by service functions, and internal events handled by handlers. Collapse them. `services.allocate()` becomes the handler for `AllocationRequired`; `services.add_batch()` becomes the handler for `BatchCreated`. *"There is no conceptual difference between a brand-new allocation coming from the API and a reallocation that's internally triggered by a deallocation."*

- **Preparatory Refactoring** — "Make the change easy; then make the easy change."
  1. Refactor the service layer into event handlers (no behavior change).
  2. Write an E2E test that puts `BatchQuantityChanged` in and looks for `Allocated` out.
  3. Implement: a new handler that emits `AllocationRequired` events, handled by the *existing* allocation handler.

- **Events as the system's input interface** (superseding both domain objects and primitives):
  - Ch5 moved the service API from domain objects → primitives, to decouple clients from the model. This chapter moves primitives → **event classes**.
  - Why that isn't backsliding: the core domain model objects are still free to vary; you've coupled the external world to *event* classes instead, which are also part of the domain but **vary less often** — "a sensible artifact to couple on."
  - Payoff: invoking a use case means remembering one event class, not a particular combination of primitives. And event classes are a nice place to do input validation (Appendix E).
  - Caveat on **primitive obsession**: the OO rule "wrap primitives in value classes" is something many Pythonistas are skeptical of, and mindlessly applied it's "a recipe for unnecessary complexity." That's explicitly *not* what's happening here.

- **The bus owns the event queue**: `handle()` takes a UoW, maintains a queue, and after each handler pulls `uow.collect_new_events()` back onto it. This breaks the circular dependency between `unit_of_work` and `messagebus` — the UoW no longer imports the bus, it just *makes events available*.

- **Fake message bus for isolated handler tests** (optional): swap `publish_events()` on a `FakeUnitOfWorkWithFakeMessageBus` to record events instead of dispatching them, then assert on *emitted events* rather than downstream side effects. **"Start out with edge-to-edge testing, and resort to this only if necessary."**

## Key Concepts

- **Situated software** (Rich Hickey) — software that runs for extended periods managing a real-world process: warehouse-management systems, logistics schedulers, payroll. Hard to write because "unexpected things happen all the time in the real world of physical objects and unreliable humans."
- **`BatchQuantityChanged`** — the new input event: a batch reference plus a new quantity.
- **`AllocationRequired`** — the event emitted per deallocated line, fed back into the allocation handler.
- **`collect_new_events()`** — the UoW generator that yields events off `products.seen`, replacing `publish_events()`.
- **Event storming** — a facilitated practice for event-based requirements gathering and domain model elaboration.
- **Orchestration → choreography** — what this refactor completes.

## Mental Models

- **"Our ongoing objective with these architectural patterns is to try to have the complexity of our application grow more slowly than its size."** That single sentence is the justification for the entire book.
- **Measure a pattern by what a new requirement costs.** This chapter adds *change quantity → deallocate → new transaction → reallocate → publish external notification* — a genuinely complicated use case — and pays **zero architectural cost**. New events, new handlers, a new external adapter: all existing categories of thing, easy to explain to newcomers.
- **Handlers can be arbitrarily granular.** Multiple handlers per event; handlers may raise further events. That granularity is what lets you actually stick to the SRP.
- **Events translate well into business language.** From a DDD standpoint this is the real prize — look up event storming.
- **Watch the repository query smell.** Adding `get_by_batchref()` is fine because it returns a **single aggregate**. Methods like `get_most_popular_products` or `find_products_by_order_id` "would definitely trigger our spidey sense." Complex queries mean you want a different design (→ Ch12, CQRS).
- **Two units of work = two database transactions.** Splitting the workflow across UoWs opens you to integrity issues: the first transaction can commit while the second doesn't. Decide whether that's acceptable and whether you need to detect it.

## Code Examples

**Events become the input types:**

```python
# src/allocation/domain/events.py
@dataclass
class BatchCreated(Event):
    ref: str
    sku: str
    qty: int
    eta: Optional[date] = None


@dataclass
class AllocationRequired(Event):
    orderid: str
    sku: str
    qty: int


@dataclass
class BatchQuantityChanged(Event):
    ref: str
    qty: int
```

**All handlers get the same shape — `(event, uow)`:**

```python
# src/allocation/service_layer/handlers.py   (was services.py)
def add_batch(event: events.BatchCreated, uow: unit_of_work.AbstractUnitOfWork):
    with uow:
        product = uow.products.get(sku=event.sku)
        ...


def allocate(event: events.AllocationRequired, uow: unit_of_work.AbstractUnitOfWork) -> str:
    line = OrderLine(event.orderid, event.sku, event.qty)
    ...


def send_out_of_stock_notification(
    event: events.OutOfStock, uow: unit_of_work.AbstractUnitOfWork,
):
    email.send('stock@made.com', f'Out of stock for {event.sku}')


def change_batch_quantity(
    event: events.BatchQuantityChanged, uow: unit_of_work.AbstractUnitOfWork
):
    with uow:
        product = uow.products.get_by_batchref(batchref=event.ref)
        product.change_batch_quantity(ref=event.ref, qty=event.qty)
        uow.commit()
```

**The bus drives a queue and passes the UoW down:**

```python
# src/allocation/service_layer/messagebus.py
def handle(event: events.Event, uow: unit_of_work.AbstractUnitOfWork):
    results = []
    queue = [event]
    while queue:
        event = queue.pop(0)
        for handler in HANDLERS[type(event)]:
            results.append(handler(event, uow=uow))
            queue.extend(uow.collect_new_events())
    return results


HANDLERS = {
    events.BatchCreated:        [handlers.add_batch],
    events.BatchQuantityChanged:[handlers.change_batch_quantity],
    events.AllocationRequired:  [handlers.allocate],
    events.OutOfStock:          [handlers.send_out_of_stock_notification],
}  # type: Dict[Type[events.Event], List[Callable]]
```
- **The `results` list is flagged as "a temporary ugly hack"** — the API wants the allocated batch reference back. "It's because we're mixing the read and write responsibilities in our system. We'll come back to fix this wart in Chapter 12."

**The UoW becomes passive:**

```python
class AbstractUnitOfWork(abc.ABC):
    def commit(self):
        self._commit()
        # publish_events() is gone

    def collect_new_events(self):
        for product in self.products.seen:
            while product.events:
                yield product.events.pop(0)
```

**The domain model grows the business rule and emits events:**

```python
class Product:
    def change_batch_quantity(self, ref: str, qty: int):
        batch = next(b for b in self.batches if b.reference == ref)
        batch._purchased_quantity = qty
        while batch.available_quantity < 0:
            line = batch.deallocate_one()
            self.events.append(
                events.AllocationRequired(line.orderid, line.sku, line.qty)
            )


class Batch:
    def deallocate_one(self) -> OrderLine:
        return self._allocations.pop()
```

**Flask constructs an event instead of calling a function:**

```python
@app.route("/allocate", methods=['POST'])
def allocate_endpoint():
    try:
        event = events.AllocationRequired(
            request.json['orderid'], request.json['sku'], request.json['qty'],
        )
        results = messagebus.handle(event, unit_of_work.SqlAlchemyUnitOfWork())
        batchref = results.pop(0)
    except InvalidSku as e:
        ...
```

## Reference Tables

| Whole app is a message bus: the trade-offs | |
|---|---|
| **Pros** | **Cons** |
| Handlers and services are the same thing — simpler | A message bus is "a slightly unpredictable way of doing things from a web point of view. You don't know in advance when things are going to end." |
| A nice data structure for inputs to the system | Duplication of fields and structure between model objects and events has a maintenance cost — adding a field to one usually means adding it to at least one other |

| API shape | Couples clients to | Introduced in |
|---|---|---|
| Domain objects — `allocate(line: OrderLine, ...)` | The domain model. Refactoring the model breaks callers | Ch4 |
| Primitives — `allocate(orderid, sku, qty, ...)` | Nothing, but you must remember the combination | Ch5 |
| **Events** — `handle(AllocationRequired(...), uow)` | **Event classes** — also domain, but they change less often | **Ch9** |

| Repository query | OK? |
|---|---|
| `get(sku)` → one aggregate | ✅ |
| `get_by_batchref(ref)` → one aggregate | ✅ "So long as our query is returning a single aggregate, we're not bending any rules" |
| `get_most_popular_products()` | 🚩 "would definitely trigger our spidey sense" |
| `find_products_by_order_id()` | 🚩 Consider a different design (Ch12) |

## Worked Example

**The real-world requirement, and the flow it produces.**

Things that happen in situated software:
- During a stock-take, three `SPRINGY-MATTRESS`es turn out to be water damaged by a leaky roof.
- A consignment of `RELIABLE-FORK`s is held in customs for weeks; three subsequently fail safety testing and are destroyed.
- A global shortage of sequins means the next batch of `SPARKLY-BOOKCASE` can't be manufactured.

Modeled as a rule: **`BatchQuantityChanged` → change the quantity → if the new quantity is below what's already allocated, deallocate those orders → each deallocation emits `AllocationRequired`.**

```
+----------+    /----\      +------------+       +--------------------+
| Batch    |--> |RULE| -->  | Deallocate | ----> | AllocationRequired |
| Quantity |    \----/      | Deallocate | ----> | AllocationRequired |
| Changed  |                | Deallocate | ----> | AllocationRequired |
+----------+                +------------+       +--------------------+
```

Sequence, spanning **two units of work**:
```
API -> MessageBus : BatchQuantityChanged event

group BatchQuantityChanged Handler + Unit of Work 1
    MessageBus -> Domain_Model : change batch quantity
    Domain_Model -> MessageBus : emit AllocationRequired event(s)
end

group AllocationRequired Handler + Unit of Work 2 (or more)
    MessageBus -> Domain_Model : allocate
end
```

**The high-gear test, written entirely in events:**

```python
class TestChangeBatchQuantity:
    def test_changes_available_quantity(self):
        uow = FakeUnitOfWork()
        messagebus.handle(events.BatchCreated("batch1", "ADORABLE-SETTEE", 100, None), uow)
        [batch] = uow.products.get(sku="ADORABLE-SETTEE").batches
        assert batch.available_quantity == 100

        messagebus.handle(events.BatchQuantityChanged("batch1", 50), uow)

        assert batch.available_quantity == 50

    def test_reallocates_if_necessary(self):
        uow = FakeUnitOfWork()
        event_history = [
            events.BatchCreated("batch1", "INDIFFERENT-TABLE", 50, None),
            events.BatchCreated("batch2", "INDIFFERENT-TABLE", 50, date.today()),
            events.AllocationRequired("order1", "INDIFFERENT-TABLE", 20),
            events.AllocationRequired("order2", "INDIFFERENT-TABLE", 20),
        ]
        for e in event_history:
            messagebus.handle(e, uow)
        [batch1, batch2] = uow.products.get(sku="INDIFFERENT-TABLE").batches
        assert batch1.available_quantity == 10
        assert batch2.available_quantity == 50

        messagebus.handle(events.BatchQuantityChanged("batch1", 25), uow)

        # order1 or order2 will be deallocated, so we'll have 25 - 20
        assert batch1.available_quantity == 5
        # and 20 will be reallocated to the next batch
        assert batch2.available_quantity == 30
```
**Note the shape**: the whole test setup is a list of events replayed through the bus. That's what "events as the input interface" buys you.

**Isolated variant, when the chain gets too complex to reason about:**

```python
class FakeUnitOfWorkWithFakeMessageBus(FakeUnitOfWork):
    def __init__(self):
        super().__init__()
        self.events_published = []  # type: List[events.Event]

    def publish_events(self):
        for product in self.products.seen:
            while product.events:
                self.events_published.append(product.events.pop(0))


def test_reallocates_if_necessary_isolated():
    uow = FakeUnitOfWorkWithFakeMessageBus()
    # ...same setup...
    messagebus.handle(events.BatchQuantityChanged("batch1", 25), uow)

    # assert on new events emitted rather than downstream side-effects
    [reallocation_event] = uow.events_published
    assert isinstance(reallocation_event, events.AllocationRequired)
    assert reallocation_event.orderid in {'order1', 'order2'}
    assert reallocation_event.sku == 'INDIFFERENT-TABLE'
```
The authors admit `FakeUnitOfWorkWithFakeMessageBus` "is unnecessarily complicated and violates the SRP" and suggest a class-based bus instead:
```python
class AbstractMessageBus:
    HANDLERS: Dict[Type[events.Event], List[Callable]]

    def handle(self, event: events.Event):
        for handler in self.HANDLERS[type(event)]:
            handler(event)
```
(The module-level `messagebus.py` in this chapter is essentially the Singleton pattern. Ch13 uses a class-based bus.)

## Anti-patterns

- **Complex queries on repositories.** Return single aggregates; anything else is a signal.
- **Mixing read and write responsibilities** — the `results` return hack, fixed in Ch12.
- **Ignoring cross-UoW integrity.** Two transactions means one can succeed while the other fails.
- **Reaching for isolated handler tests first.** Edge-to-edge first; isolate only when the chain demands it.
- **Blind primitive-obsession avoidance.** Wrapping every primitive in a value class is over-engineering in Python; this refactor is justified by decoupling, not by dogma.

## Key Takeaways

1. **Events are the data structure for both inputs and internal messages.** One concept covers the API boundary and internal work packages.
2. **Handlers are how you react to events.** They call down to the model or out to external services, may be plural per event, and may raise further events.
3. **Refactor first, then add the feature.** "Make the change easy; then make the easy change."
4. **Give the message bus the queue and pass the UoW down** — it removes the circular dependency and makes event chaining explicit.
5. **Couple external clients to event classes, not to the domain model or to loose primitives.**
6. **Judge architecture by marginal cost.** A complicated new requirement should cost you new *instances* of existing categories, not new categories.
7. **Repository queries returning a single aggregate are fine; anything richer is a design smell.**

## Connects To
- **Ch 8**: domain events, the message bus, `.seen`, and the UoW's `publish_events()` — all evolved here.
- **Ch 10**: the commands-vs-events distinction, which the footnote here promises ("Some of these events sound more like commands!").
- **Ch 11**: where `BatchQuantityChanged` events actually come from — external message brokers.
- **Ch 12**: CQRS, fixing the read/write mixing that forced `handle()` to return results.
- **Ch 13**: dependency injection and a class-based message bus.
- **Ch 5**: "high gear" testing, applied here by writing handler tests purely in events.
- **Appendix E**: validation on event classes.
- **Event storming / DDD**: the requirements-gathering practice these events come from.
