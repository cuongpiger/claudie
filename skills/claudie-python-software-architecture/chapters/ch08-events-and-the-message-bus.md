# Chapter 8: Events and the Message Bus

## Core Idea
It isn't the obvious features that make a mess of codebases — **it's the goop around the edge**: reporting, permissions, notifications, workflows touching a zillion objects. **Domain Events** separate side effects from use cases; a **Message Bus** routes them to handlers; and putting the **Unit of Work** in charge of publishing them keeps the service layer clean.

## Frameworks Introduced

- **Domain Events**: facts about things that have happened, recorded by the model in the language of the domain.
  - When to use: whenever a domain expert says **"When X, then Y"** — "when we try to allocate stock but there's none available, then we should send an email to the buying team." *"The magic words 'When X, then Y' often tell us about an event that we can make concrete in our system."*
  - How: `@dataclass` subclasses of a base `Event` class, in `domain/events.py`. An event is a kind of **value object** — pure data, no behavior.
  - Where they're raised: the aggregate appends to `self.events`.

- **Message Bus**: a publish-subscribe router. *"You can think of a message bus as a dict that maps from events to their consumers. It doesn't 'know' anything about the meaning of events; it's just a piece of dumb infrastructure for getting messages around the system."*
  - How: literally a `dict` of event type → list of handlers, plus a `handle()` loop.

- **Three options for publishing events** (all three used in production by the authors):
  1. **Service layer collects events from the model and passes them to the bus.** Simplest. `finally: messagebus.handle(product.events)`.
  2. **Service layer creates and raises its own events.** No `.events` on the model at all.
  3. **UoW collects events from aggregates and publishes on commit.** ← *the authors' favorite.* Most complex, may rely on ORM magic, but cleanest once set up.

- **`.seen` tracking on the repository**: for option 3 to work, the UoW must know which aggregates were touched. `AbstractRepository.__init__` creates `self.seen = set()`; `add()`/`get()` record into it and delegate to abstract `_add()`/`_get()`.

- **Single Responsibility Principle applied to workflows**: *"Rule of thumb: if you can't describe what your function does without using words like 'then' or 'and,' you might be violating the SRP."* The use case is `allocate`, not `allocate_and_send_mail_if_out_of_stock`. When you switch from email to SMS, `allocate()` should not change.

## Key Concepts

- **Event** — a fact about something that happened, named in domain language, implemented as a frozen-ish dataclass.
- **Raising an event** — the model recording a fact by appending to `self.events`.
- **Handler** — a function subscribed to an event type.
- **`HANDLERS`** — `Dict[Type[events.Event], List[Callable]]`.
- **Goop** — the authors' word for the mundane cross-cutting stuff (email, reporting, permissions) that ruins clean flows.
- **Eventual consistency** — how two transactionally-isolated aggregates (an order and a product) stay in sync: via events, not long-running multi-table transactions.
- **Orchestration → choreography** — tech reviewer Ed Jung's framing of the move from imperative to event-based flow control.
- **External events** — persisted to a centralized store so other containers/microservices can subscribe. The answer to "what if I need work off the main thread?"

## Mental Models

- **Listen for causal/temporal language from domain experts.** "When we try to allocate stock but there's none available, then we should send an email." That sentence *is* the design.
- **Don't use exceptions for control flow when you have events.** This chapter deliberately stops raising `OutOfStock` and appends an event instead — "if you're implementing domain events, don't raise exceptions to describe the same domain concept… it's confusing to have to reason about events and exceptions together."
- **This message bus is not Celery.** It has more in common with a Node.js app, a UI event loop, or an actor framework. It gives you **no concurrency** — only one handler runs at a time. The objective is to separate tasks conceptually and keep each UoW small, so the "recipe" for each use case lives in one place.
- **Events beat Celery as a distribution API.** Your API for distributing tasks becomes your *event classes* (or their JSON), which need not be Python. Celery's API is "function name plus arguments" — more restrictive, Python-only.
- **Events answer "what if I need to change multiple aggregates in one request?"** Ch7 said you may only modify one aggregate at a time. Events are how the second one finds out. When an order is canceled, find the products allocated to it and remove the allocations — eventually consistent, no cross-table lock.
- **Committing when nothing changed is safe and keeps the code uncluttered.** "We always commit unless something goes wrong."

## Code Examples

**Events as dataclasses:**

```python
# src/allocation/domain/events.py
from dataclasses import dataclass


class Event:
    pass


@dataclass
class OutOfStock(Event):
    sku: str
```
- **What it demonstrates**: a parent class for common attributes and for message-bus type hints; `dataclasses` are as good for events as they were for value objects.

**The aggregate raises the event instead of sending mail or raising an exception:**

```python
class Product:
    def __init__(self, sku: str, batches: List[Batch], version_number: int = 0):
        self.sku = sku
        self.batches = batches
        self.version_number = version_number
        self.events = []  # type: List[events.Event]

    def allocate(self, line: OrderLine) -> str:
        try:
            # ...
        except StopIteration:
            self.events.append(events.OutOfStock(line.sku))
            # raise OutOfStock(f'Out of stock for sku {line.sku}')   <- deleted
            return None
```

**The message bus, in full:**

```python
# src/allocation/service_layer/messagebus.py
def handle(event: events.Event):
    for handler in HANDLERS[type(event)]:
        handler(event)


def send_out_of_stock_notification(event: events.OutOfStock):
    email.send_mail(
        'stock@made.com',
        f'Out of stock for {event.sku}',
    )


HANDLERS = {
    events.OutOfStock: [send_out_of_stock_notification],
}  # type: Dict[Type[events.Event], List[Callable]]
```

**Option 3 — UoW publishes, repository tracks:**

```python
class AbstractUnitOfWork(abc.ABC):
    def commit(self):
        self._commit()
        self.publish_events()

    def publish_events(self):
        for product in self.products.seen:
            while product.events:
                event = product.events.pop(0)
                messagebus.handle(event)

    @abc.abstractmethod
    def _commit(self):
        raise NotImplementedError


class AbstractRepository(abc.ABC):
    def __init__(self):
        self.seen = set()  # type: Set[model.Product]

    def add(self, product: model.Product):
        self._add(product)
        self.seen.add(product)

    def get(self, sku) -> model.Product:
        product = self._get(sku)
        if product:
            self.seen.add(product)
        return product

    @abc.abstractmethod
    def _add(self, product): raise NotImplementedError

    @abc.abstractmethod
    def _get(self, sku): raise NotImplementedError
```

**And the payoff — the service layer, totally free of event-handling concerns:**

```python
def allocate(orderid, sku, qty, uow: unit_of_work.AbstractUnitOfWork) -> str:
    line = OrderLine(orderid, sku, qty)
    with uow:
        product = uow.products.get(sku=line.sku)
        if product is None:
            raise InvalidSku(f'Invalid sku {line.sku}')
        batchref = product.allocate(line)
        uow.commit()
        return batchref
```
Identical to Ch7's version — the email feature was added with **zero changes** to the use case.

## Reference Tables

| Domain events: the trade-offs | |
|---|---|
| **Pros** | **Cons** |
| A message bus separates responsibilities cleanly when one request triggers multiple actions | The bus is another thing to wrap your head around; UoW-raises-events is neat **but magic** — it isn't obvious that `commit` also sends email |
| Handlers are decoupled from core application logic, easy to change later | Hidden event handling runs **synchronously**: your service function doesn't finish until every handler does. Watch for endpoint latency |
| Domain events model the real world and become part of your business language with stakeholders | Split across a chain of handlers, there's **no single place** to see how a request is fulfilled |
| | You open yourself to circular dependencies between handlers, and infinite loops |

| Publishing option | Where events originate | Complexity | Verdict |
|---|---|---|---|
| **1** | Model raises; service layer calls `bus.handle(product.events)` after commit | Low | Simplest way to start |
| **2** | Service layer creates and raises events directly | Low | Used in production; logic about *when* to raise belongs closer to the model though |
| **3** | Model raises; **UoW** publishes on commit via `repo.seen` | High | **Chosen.** Cleanest and easiest to use once set up |

## Worked Example

**Four homes for one email, and why three are wrong.**

*Home 1 — the Flask endpoint:*
```python
@app.route("/allocate", methods=['POST'])
def allocate_endpoint():
    line = model.OrderLine(request.json['orderid'], request.json['sku'], request.json['qty'])
    try:
        uow = unit_of_work.SqlAlchemyUnitOfWork()
        batchref = services.allocate(line, uow)
    except (model.OutOfStock, services.InvalidSku) as e:
        send_mail('out of stock', 'stock_admin@made.com', f'{line.orderid} - {line.sku}')
        return jsonify({'message': str(e)}), 400
    return jsonify({'batchref': batchref}), 201
```
> "Sending email isn't the job of our HTTP layer, and we'd like to be able to unit test this new feature."

*Home 2 — the domain model:*
```python
        except StopIteration:
            email.send_mail('stock@made.com', f'Out of stock for {line.sku}')
            raise OutOfStock(f'Out of stock for sku {line.sku}')
```
> "But that's even worse! We don't want our model to have any dependencies on infrastructure concerns like `email.send_mail`."

*Home 3 — the service layer:*
```python
        try:
            batchref = product.allocate(line)
            uow.commit()
            return batchref
        except model.OutOfStock:
            email.send_mail('stock@made.com', f'Out of stock for {line.sku}')
            raise
```
> "Catching an exception and reraising it? It could be worse, but it's definitely making us unhappy. Why is it so hard to find a suitable home for this code?"

*The diagnosis:* an SRP violation. `allocate` would have to become `allocate_and_send_mail_if_out_of_stock`. Each class should have only one reason to change — switching to SMS must not touch `allocate()`.

*Home 4 — nowhere.* The model records a fact; a handler somewhere else decides what to do about it. The test that drives it:

```python
def test_records_out_of_stock_event_if_cannot_allocate():
    batch = Batch('batch1', 'SMALL-FORK', 10, eta=today)
    product = Product(sku="SMALL-FORK", batches=[batch])
    product.allocate(OrderLine('order1', 'SMALL-FORK', 10))

    allocation = product.allocate(OrderLine('order2', 'SMALL-FORK', 1))

    assert product.events[-1] == events.OutOfStock(sku="SMALL-FORK")
    assert allocation is None
```

**On the `_add()`/`_commit()` ugliness** — tech reviewer Hynek called it "super-gross," and the authors agree the listings are examples, not perfection. The composition-over-inheritance alternative:

```python
class TrackingRepository:
    seen: Set[model.Product]

    def __init__(self, repo: AbstractRepository):
        self.seen = set()  # type: Set[model.Product]
        self._repo = repo

    def add(self, product: model.Product):
        self._repo.add(product)
        self.seen.add(product)

    def get(self, sku) -> model.Product:
        product = self._repo.get(sku)
        if product:
            self.seen.add(product)
        return product
```
Wrapping lets you call the real `.add()`/`.get()` and drop the underscorey methods. Switching all the ABCs to `typing.Protocol` is a good way to force yourself away from inheritance.

**On fake-maintenance burden:** "There's no doubt that it is work, but in our experience it's not a lot of work. Once your project is up and running, the interface for your repository and UoW abstractions really don't change much."

## Anti-patterns

- **Dumping cross-cutting features into web controllers.** "As a one-off hack, this might be OK… but it's easy to see how we can quickly end up in a mess."
- **Infrastructure imports in the domain model.** `email.send_mail` in `Product.allocate()` is worse than putting it in the controller.
- **Functions whose name needs "and"/"then."** An SRP smell.
- **Using exceptions for control flow** alongside events for the same domain concept.
- **Circular handler dependencies / infinite loops** — an acknowledged risk of the pattern.
- **Assuming the bus gives you async.** It doesn't. Handlers run synchronously inside your request.

## Key Takeaways

1. **Events help enforce the SRP** by separating primary use cases from secondary ones.
2. **Events are also how aggregates communicate**, so you never need long-running transactions locking multiple tables.
3. **A message bus is a dict from events to consumers** — dumb infrastructure, deliberately.
4. **Name events in domain language and treat them as part of the domain model.** They become vocabulary you share with stakeholders.
5. **Start with Option 1 if you're new to this**; graduate to Option 3 (UoW publishes) when the `bus.handle(aggregate.events)` boilerplate gets annoying.
6. **Accept the magic knowingly.** `uow.commit()` sending email is convenient and non-obvious; document it.
7. **The pattern's real cost is legibility**: with the workflow split across handlers, no single place shows how a request is fulfilled.

## Connects To
- **Ch 7**: aggregates and the "what if I need to change multiple aggregates?" question this chapter answers with eventual consistency.
- **Ch 6**: the UoW, extended with `publish_events()` and `_commit()`.
- **Ch 2**: the Repository, extended with `.seen`.
- **Ch 9**: the message bus promoted to the *main* entrypoint of the app, with a more complex workflow.
- **Ch 10**: error handling — "what happens if one of the handlers fails?"
- **Ch 11**: external events, and Table 11-1 on internal vs external events.
- **Ch 13**: dependency injection, which finally removes the `mock.patch` on the email module.
- **SOLID / SRP**: the S, applied to workflow orchestration.
