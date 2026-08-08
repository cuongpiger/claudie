# Chapter 10: Commands and Command Handler

## Core Idea
Split messages into two kinds. A **command** captures *intent* — one recipient, must succeed or fail noisily, modifies exactly one aggregate. An **event** captures a *fact* — broadcast to all listeners, allowed to fail independently. This split is what lets you deliberately choose which parts of a workflow *must* complete and which can be tidied up later.

## Frameworks Introduced

- **Commands vs Events** — the central distinction:

  | | **Event** | **Command** |
  |---|---|---|
  | Named | Past tense — "order allocated to stock", "shipment delayed" | Imperative mood — "allocate stock", "delay shipment" |
  | Error handling | **Fail independently** | **Fail noisily** |
  | Sent to | All listeners | One recipient |
  | Captures | Facts about things that happened | Intent — a wish for the system to do something |
  | Sender cares if it succeeded? | No — doesn't even know who's handling it | **Yes** — needs error information back |

- **Command Handler pattern**: the umbrella name for Events + Commands + Message Bus together.

- **The error-handling rule that falls out of the split**:
  > "When a user wants to make the system do something, we represent their request as a **command**. That command should modify **a single aggregate** and either succeed or fail in totality. Any other bookkeeping, cleanup, and notification we need to do can happen via an **event**. We don't require the event handlers to succeed in order for the command to be successful."

- **Two dispatch paths in the bus**:
  - `handle_event()` — iterates *multiple* handlers, catches and logs every exception, `continue`s. **Events cannot interrupt the flow.**
  - `handle_command()` — looks up *one* handler, logs the exception and `raise`s. **Commands fail fast and bubble up.**

- **Synchronous error recovery, two tiers**:
  1. **Log first, then act.** Every message handled writes a debug line naming the message and the handler. Because messages are dataclasses, the log line is a copy-pasteable Python repr — you can reproduce it in a unit test or replay it into the system.
  2. **Retry with exponential backoff** for transient failures — network hiccups, table deadlocks, brief downtime from deployments. *"If at first you don't succeed, retry the operation with an exponentially increasing back-off period."* Use `tenacity`.

## Key Concepts

- **Command** — `commands.Allocate`, `commands.CreateBatch`, `commands.ChangeBatchQuantity`. Dumb dataclasses, imperative names.
- **`Message = Union[commands.Command, events.Event]`** — the bus's input type.
- **`COMMAND_HANDLERS`** — `Dict[Type[Command], Callable]`. Note: **not** a list. One handler per command, by convention.
- **`EVENT_HANDLERS`** — `Dict[Type[Event], List[Callable]]`. Many handlers per event.
- **Transient failure** — the background level of breakage every system experiences; the target of retries.
- **Manual replay** — using the logged message repr to re-inject a message after fixing a bug.

## Mental Models

- **The conceptual wart this chapter fixes:** in Ch9, a POST to create a batch built a `BatchCreated` event — but the batch *hasn't been created yet*; that's why you called the API. `CreateBatch` is the honest name. *"`CreateBatch` is definitely a less confusing name than `BatchCreated`. We are being explicit about the intent of our users, and explicit is better than implicit, right?"*
- **Events spread knowledge about successful commands.** That's their job in the pipeline.
- **Ask: which part does the customer actually care about?** In the VIP example, only "create the order" must complete. That's the command. Everything else — updating history, sending congratulations — is an event handler and is allowed to fail.
- **Raise events *after* persisting, not before.** Raising before and committing everything together *sounds* safer, but then a slightly overloaded email server can stop you taking money for orders, and a bug in the `History` aggregate means you fail to charge a customer just because you can't recognize them as a VIP.
- **Aggregates + UoW already prevent the scary inconsistency.** You can't allocate three `DESIRABLE_BEANBAG`s and fail to decrement stock — the `Product` aggregate is the consistency boundary and the UoW makes the update atomic. *"By definition, we don't require two aggregates to be immediately consistent"*, so failing an event handler leaves the system eventually consistent, not broken.
- **Align transactional boundaries to the start and end of business processes.** Then handler names match the natural-language acceptance criteria, and "this concordance of names and structure helps us to reason about our systems as they grow larger and more complex."
- **Retries work *because* of UoW + Command Handler.** Each attempt starts from a consistent state and won't leave things half-finished. "Retrying operations that might fail is probably the single best way to improve the resilience of our software."

## Code Examples

**Commands replacing the misnamed events:**

```python
# src/allocation/domain/commands.py
class Command:
    pass


@dataclass
class Allocate(Command):            # replaces events.AllocationRequired
    orderid: str
    sku: str
    qty: int


@dataclass
class CreateBatch(Command):         # replaces events.BatchCreated
    ref: str
    sku: str
    qty: int
    eta: Optional[date] = None


@dataclass
class ChangeBatchQuantity(Command): # replaces events.BatchQuantityChanged
    ref: str
    qty: int
```

**The bus dispatches the two kinds differently:**

```python
# src/allocation/service_layer/messagebus.py
Message = Union[commands.Command, events.Event]


def handle(message: Message, uow: unit_of_work.AbstractUnitOfWork):
    results = []
    queue = [message]
    while queue:
        message = queue.pop(0)
        if isinstance(message, events.Event):
            handle_event(message, queue, uow)
        elif isinstance(message, commands.Command):
            cmd_result = handle_command(message, queue, uow)
            results.append(cmd_result)
        else:
            raise Exception(f'{message} was not an Event or Command')
    return results


def handle_event(event, queue, uow):
    for handler in EVENT_HANDLERS[type(event)]:      # many handlers
        try:
            logger.debug('handling event %s with handler %s', event, handler)
            handler(event, uow=uow)
            queue.extend(uow.collect_new_events())
        except Exception:
            logger.exception('Exception handling event %s', event)
            continue                                 # never interrupt the flow


def handle_command(command, queue, uow):
    logger.debug('handling command %s', command)
    try:
        handler = COMMAND_HANDLERS[type(command)]    # exactly one handler
        result = handler(command, uow=uow)
        queue.extend(uow.collect_new_events())
        return result
    except Exception:
        logger.exception('Exception handling command %s', command)
        raise                                        # fail fast, bubble up


EVENT_HANDLERS = {
    events.OutOfStock: [handlers.send_out_of_stock_notification],
}  # type: Dict[Type[events.Event], List[Callable]]

COMMAND_HANDLERS = {
    commands.Allocate:            handlers.allocate,
    commands.CreateBatch:         handlers.add_batch,
    commands.ChangeBatchQuantity: handlers.change_batch_quantity,
}  # type: Dict[Type[commands.Command], Callable]
```
- **What it demonstrates**: the asymmetry is the whole point — `List[Callable]` vs bare `Callable`, `continue` vs `raise`. (`return result` is still the temporary hack from Ch9, fixed in Ch12.)

**Retries with tenacity:**

```python
from tenacity import Retrying, RetryError, stop_after_attempt, wait_exponential


def handle_event(event, queue, uow):
    for handler in EVENT_HANDLERS[type(event)]:
        try:
            for attempt in Retrying(stop=stop_after_attempt(3), wait=wait_exponential()):
                with attempt:
                    logger.debug('handling event %s with handler %s', event, handler)
                    handler(event, uow=uow)
                    queue.extend(uow.collect_new_events())
        except RetryError as retry_failure:
            logger.error(
                'Failed to handle event %s times, giving up!',
                retry_failure.last_attempt.attempt_number,
            )
            continue
```

## Reference Tables

| Splitting commands and events: the trade-offs | |
|---|---|
| **Pros** | **Cons** |
| Treating them differently clarifies which things **have** to succeed and which can be tidied up later | The semantic differences are subtle — **expect bikeshedding arguments** |
| `CreateBatch` is a much less confusing name than `BatchCreated`; explicit beats implicit | You're **expressly inviting failure** — choosing smaller, isolated failures over big ones. Harder to reason about; **requires better monitoring** |

| Concern | Command | Event |
|---|---|---|
| Handlers registered | Exactly one | One or more |
| Exception behavior | Log + `raise` | Log + `continue` |
| Aggregates modified | **One** | One (each handler) |
| Must succeed for the user's request to succeed? | Yes | No |
| Retry strategy | Caller/API decides | `tenacity` inside the bus |

## Worked Example

**The VIP customer — why event handlers must be allowed to fail.**

Acceptance criteria, from a different, imaginary project:
> **Given** a customer with two orders in their history,
> **When** the customer places a third order,
> **Then** they should be flagged as a VIP.
>
> **When** a customer first becomes a VIP,
> **Then** we should send them an email to congratulate them.

The code maps one-to-one onto those clauses:

```python
class History:  # Aggregate
    def __init__(self, customer_id: int):
        self.orders = set()          # Set[HistoryEntry]
        self.customer_id = customer_id

    def record_order(self, order_id: str, order_amount: int):
        entry = HistoryEntry(order_id, order_amount)
        if entry in self.orders:
            return
        self.orders.add(entry)
        if len(self.orders) == 3:
            self.events.append(CustomerBecameVIP(self.customer_id))


def create_order_from_basket(uow, cmd: CreateOrder):        # ← COMMAND handler
    with uow:
        order = Order.from_basket(cmd.customer_id, cmd.basket_items)
        uow.orders.add(order)
        uow.commit()                 # raises OrderCreated


def update_customer_history(uow, event: OrderCreated):      # ← EVENT handler
    with uow:
        history = uow.order_history.get(event.customer_id)
        history.record_order(event.order_id, event.order_amount)
        uow.commit()                 # raises CustomerBecameVIP


def congratulate_vip_customer(uow, event: CustomerBecameVIP):  # ← EVENT handler
    with uow:
        customer = uow.customers.get(event.customer_id)
        email.send(customer.email_address, f'Congratulations {customer.first_name}!')
```

**The argument, in two questions:**
- *What happens if the email server is slightly overloaded?* If all the work had to complete in one transaction, **a busy email server would stop you taking money for orders.**
- *What happens if there's a bug in the `History` aggregate?* **Should you fail to take a customer's money just because you can't recognize them as a VIP?**

Only `create_order_from_basket` *has* to complete. That's the only part the customer cares about, and the part business stakeholders should prioritize. Separating the concerns makes things fail in isolation, which **improves the overall reliability of the system.**

**What the logs give you.** Every handled message writes:
```
Handling event CustomerBecameVIP(customer_id=12345)
with handler <function congratulate_vip_customer at 0x10ebc9a60>
```
Because messages are dataclasses, `CustomerBecameVIP(customer_id=12345)` is a neatly printed summary you can **copy and paste into a Python shell to re-create the object** — then reproduce the bug in a unit test, or replay the message once it's fixed.

## Anti-patterns

- **Naming a request in the past tense.** `BatchCreated` for a batch that doesn't exist yet is a lie about intent.
- **Registering multiple handlers for a command.** Breaks the "one recipient, fail noisily" contract.
- **Letting an event handler's failure abort the command.** That's the coupling this whole chapter exists to remove.
- **Raising events before persisting** and committing everything together — couples business-critical work to best-effort work.
- **A command that modifies more than one aggregate.** It can no longer "succeed or fail in totality."
- **Relying on retries forever.** "At some point, regardless of `tenacity`, we'll have to give up trying to process the message. Building reliable systems with distributed messages is hard."

## Key Takeaways

1. **Name commands imperatively, events in past tense.** The naming *is* the design decision.
2. **One command → one handler → one aggregate → all-or-nothing.**
3. **Events fail independently and are logged, not raised.** Many handlers, none of them blocking.
4. **Aggregates and the UoW already prevent true inconsistency**; event failure leaves you eventually consistent, not corrupt.
5. **Align transaction boundaries with business processes** so handler names match acceptance criteria.
6. **Log every message with its handler**, using dataclasses so the log doubles as a replay script.
7. **Retry transient failures with exponential backoff** — the single best resilience investment, made safe by UoW + Command Handler.
8. **You are trading one big failure for many small ones.** That's a real trade: it demands better monitoring.

## Connects To
- **Ch 9**: where every input became an event — the "conceptual wart" this chapter corrects.
- **Ch 7**: aggregates as consistency boundaries, which is *why* a command may only touch one.
- **Ch 6**: the UoW, which makes each retry attempt start from a consistent state.
- **Ch 8**: `OutOfStock` and `send_out_of_stock_notification` — the surviving event/handler pair.
- **Ch 11**: events as an integration pattern between services, and "Footguns."
- **Ch 12**: fixing the `return result` hack via CQRS.
- **Epilogue**: pointers to further reading on reliable distributed messaging.
- **`tenacity`**: the Python retry library used here.
