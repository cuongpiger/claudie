# Appendices A–E: Summary Table, Project Structure, CSV Swap, Django, and Validation

## Core Idea
Five short appendices: a **one-table map of the whole architecture** (A), the **repo layout and Docker/config setup** that makes it runnable (B), a **proof that the abstractions work** by swapping the entire infrastructure for CSVs (C), the same patterns **in Django** and why it's harder (D), and a complete theory of **where validation belongs** — syntax at the edge, semantics at the handler, pragmatics in the domain (E).

## Frameworks Introduced

- **Appendix A — the architecture in one table.** Every component, its layer, and its job. See the Reference Table below; this is the single best "what did I just read?" artifact in the book.

- **Appendix B — project structure** built on four blocks:
  1. Source in a `src/` folder, pip-installable via a three-line `setup.py`.
  2. Docker config spinning up a local cluster that mirrors production as far as possible.
  3. Config via **environment variables** (12-factor), centralized in `config.py`, with defaults that let things run *outside* containers.
  4. A `Makefile` for the common commands.

- **Appendix C — the payoff demonstration.** Business asks for a CLI reading batches and orders from CSVs and writing allocations to a third CSV. Answer: write a `CsvRepository` and `CsvUnitOfWork`; reuse **all** the domain and service-layer logic unchanged.

- **Appendix D — Django** repository + UoW. Requires a manual translation layer (`update_from_domain` / `to_domain`) on the Django models, because Django has no equivalent of SQLAlchemy's classical mapper.

- **Appendix E — three kinds of validation** (borrowed from linguistics), each with its own home:

  | Kind | Question it answers | Example of a violation | **Where it belongs** |
  |---|---|---|---|
  | **Syntax** | Is the message *well formed*? | "Allocate three to" — no SKU, no order ID | **On the message class**, at the edge |
  | **Semantics** | Is the message *meaningful*? | `{"orderid": "superman", "sku": "zygote", "qty": -1}` — parses fine, is nonsense | **Service layer / message bus**, via `ensure.*` preconditions |
  | **Pragmatics** | Can we *comply* in this context? | "Allocate three million units of SCARCE-CLOCK to order 76543" — valid, but we don't have the stock | **The domain model** |

- **Tolerant Reader pattern / Postel's Law**: *"Be liberal in what you accept, and conservative in what you emit."* Extract only the fields you care about, do minimal validation on them, and pass `ignore_extra_keys=True`.

- **The `ensure` module** — contract-based programming for semantic preconditions, keeping the service layer flow clean and declarative.

- **`SkipMessage`** — an exception for messages that can't be processed but where *nothing is wrong*: duplicates, or messages now out of date. The bus logs a warning and moves on. This is how you implement idempotency generically.

## Key Concepts

- **Entrypoints / primary adapters** — translate external inputs into service-layer calls (web, event consumer).
- **Adapters / secondary adapters** — concrete implementations going from our system out to the world (repository, event publisher).
- **`PYTHONDONTWRITEBYTECODE=1`** — set it when mounting volumes, or you get "millions of root-owned files sprinkled all over your local filesystem, being all annoying to delete and causing weird Python compiler errors besides."
- **Docker build cache ordering** — install things in order of how frequently they change. "I can't tell you how much pain and frustration underlies this lesson."
- **Fat models** (Django) — push logic down into models. Works for simple apps but "runs into scalability problems of its own, particularly around managing interdependencies between apps."
- **`logic.py`** — the Django stepping stone: put one in every app from day one.
- **Well formed** — grammatically correct, in the linguistic sense.

## Mental Models

- **Config should be functions, not constants.** "We use functions for getting the current config, rather than constants available at import time, because that allows client code to modify `os.environ` if it needs to."
- **Don't let `config.py` become a dumping ground.** Keep things immutable, modify only via environment variables, and if you use a bootstrap script, make it the only place (other than tests) that imports config.
- **A Makefile is code, so it goes stale less than documentation does.**
- **SKU format validation is a trap.** "Developers *love* to validate this kind of thing… This causes horrible problems down the line when some anarchist releases a product named `COMFY-CHAISE-LONGUE` or when a snafu at the supplier results in a shipment of `CHEAP-CARPET-2`. Really, as the allocation system, it's **none of our business** what the format of a SKU might be." Treat order numbers, phone numbers, and most strings as opaque.
- **Resist shared message-definition libraries between systems.** Sharing JSON Schema across services fails the robustness test — make it easy for each service to define the data it depends on instead.
- **Is Postel always right?** "Mentioning Postel can be quite triggering to some people. They will tell you that Postel is the precise reason that everything on the internet is broken and we can't have nice things. Ask Hynek about SSLv3 one day." The Tolerant Reader is right **for event-based integration between services you control**; a public internet-facing API may want to be more conservative.
- **Invalid data is a time bomb**: "the deeper it gets, the more damage it can do, and the fewer tools you have to respond to it."
- **When you receive an invalid message, there's usually little you can do but log and continue.** At MADE they count messages received vs. successfully processed / skipped / invalid, and alert on spikes in bad messages.
- **If a rule can be tested inside the domain model, it should be.** Don't drain business logic into precondition checks.
- **Django's strength is exactly the book's blind spot.** "The entire reason that Django is so great is that it's designed around the sweet spot of making it easy to build CRUD apps with minimal boilerplate. But the entire thrust of our book is about what to do when your app is no longer a simple CRUD app." The Django admin, "so awesome when you start out, becomes actively dangerous if the whole point of your app is to build a complex set of rules and modeling around the workflow of state changes. **The Django admin bypasses all of that.**"

## Reference Tables

**Appendix A — the whole architecture:**

| Layer | Component | Description |
|---|---|---|
| **Domain** | | *Defines the business logic.* |
| | Entity | A domain object whose attributes may change but that has a recognizable identity over time |
| | Value object | An immutable domain object whose attributes entirely define it; fungible with identical objects |
| | Aggregate | Cluster of associated objects treated as a unit for data changes. Defines and enforces a consistency boundary |
| | Event | Represents something that happened |
| | Command | Represents a job the system should perform |
| **Service Layer** | | *Defines the jobs the system should perform and orchestrates different components.* |
| | Handler | Receives a command or an event and performs what needs to happen |
| | Unit of Work | Abstraction around data integrity. Each UoW is an atomic update. Makes repositories available. Tracks new events on retrieved aggregates |
| | Message bus (internal) | Handles commands and events by routing them to the appropriate handler |
| **Adapters** (secondary) | | *Concrete implementations of an interface going from our system to the outside world (I/O).* |
| | Repository | Abstraction around persistent storage. **Each aggregate has its own repository** |
| | Event publisher | Pushes events onto the external message bus |
| **Entrypoints** (primary adapters) | | *Translate external inputs into calls into the service layer.* |
| | Web | Receives web requests, translates them into commands, passes them to the internal message bus |
| | Event consumer | Reads events from the external message bus, translates them into commands, passes them to the internal bus |
| N/A | External message bus (broker) | Infrastructure services use to intercommunicate via events |

**Appendix B — project tree:**

```
.
├── Dockerfile              # container config; minimize number of images
├── Makefile                # make build, make test — code, so it stays current
├── docker-compose.yml
├── requirements.txt
├── mypy.ini
├── src
│   ├── allocation
│   │   ├── config.py
│   │   ├── domain/         model.py, events.py, commands.py
│   │   ├── service_layer/  services.py → handlers.py, unit_of_work.py, messagebus.py
│   │   ├── adapters/       orm.py, repository.py, redis_eventpublisher.py, notifications.py
│   │   └── entrypoints/    flask_app.py, redis_eventconsumer.py
│   └── setup.py            # 3 lines; pip install -e
└── tests
    ├── conftest.py         # shared fixtures
    ├── pytest.ini
    ├── unit/               test_batches.py, test_allocate.py, test_handlers.py
    ├── integration/        test_orm.py, test_repository.py, test_uow.py, test_views.py
    └── e2e/                test_api.py, test_external_events.py
```

**Appendix D — should you do this in Django?**

| Pattern | Verdict for an existing Django app |
|---|---|
| **Repository + UoW** | "Quite a lot of work." Short-term payoff is **faster unit tests** — evaluate whether that's worth it. Long-term they decouple you from Django and the DB, so worth it **if you anticipate migrating away from either**. |
| **Service Layer** | Worth it "if you're seeing a lot of duplication in your `views.py`." Good way to think about use cases separately from web endpoints. |
| **Fat models / DDD in Django models** | Theoretically fine; migrations will slow you down but it "shouldn't be fatal." Works while the app isn't too complex and tests aren't too slow. **But** the Django community reports fat models hit scalability problems around interdependencies between apps. |
| **Stepping stones** | Put a `logic.py` in every Django app from day one. Start it working with Django model objects, decouple to plain Python later. Put all reads in one place for cheap CQRS benefits. Decouple your module hierarchy from the Django apps hierarchy — business concerns cut across them. |

## Worked Example

**Appendix C — swapping the entire infrastructure for CSVs.**

The naive attempt reuses the domain model but hardcodes the I/O:

```python
def main(folder):
    batches_path = Path(folder) / 'batches.csv'
    orders_path = Path(folder) / 'orders.csv'
    allocations_path = Path(folder) / 'allocations.csv'
    batches = load_batches(batches_path)

    with orders_path.open() as inf, allocations_path.open('w') as outf:
        reader, writer = csv.DictReader(inf), csv.writer(outf)
        writer.writerow(['orderid', 'sku', 'batchref'])
        for row in reader:
            line = model.OrderLine(row['orderid'], row['sku'], int(row['qty']))
            batchref = model.allocate(line, batches)
            writer.writerow([line.orderid, line.sku, batchref])
```
> "It's not looking too bad! And we're reusing our domain model objects and our domain service. **But it's not going to work.** Existing allocations need to also be part of our permanent CSV storage."

The second test — with pre-existing allocations in `allocations.csv` — forces the issue. Rather than hacking `load_batches`, implement the same two abstractions over CSVs:

```python
# src/allocation/service_layer/csv_uow.py
class CsvRepository(repository.AbstractRepository):
    def __init__(self, folder):
        self._batches_path = Path(folder) / 'batches.csv'
        self._allocations_path = Path(folder) / 'allocations.csv'
        self._batches = {}  # type: Dict[str, model.Batch]
        self._load()

    def get(self, reference):
        return self._batches.get(reference)

    def add(self, batch):
        self._batches[batch.reference] = batch

    def _load(self):
        with self._batches_path.open() as f:
            for row in csv.DictReader(f):
                eta = (datetime.strptime(row['eta'], '%Y-%m-%d').date()
                       if row['eta'] else None)
                self._batches[row['ref']] = model.Batch(
                    ref=row['ref'], sku=row['sku'], qty=int(row['qty']), eta=eta)

        if self._allocations_path.exists() is False:
            return

        with self._allocations_path.open() as f:
            for row in csv.DictReader(f):
                line = model.OrderLine(row['orderid'], row['sku'], int(row['qty']))
                self._batches[row['batchref']]._allocations.add(line)

    def list(self):
        return list(self._batches.values())


class CsvUnitOfWork(unit_of_work.AbstractUnitOfWork):
    def __init__(self, folder):
        self.batches = CsvRepository(folder)

    def commit(self):                     # commit = csv.writer
        with self.batches._allocations_path.open('w') as f:
            writer = csv.writer(f)
            writer.writerow(['orderid', 'sku', 'qty', 'batchref'])
            for batch in self.batches.list():
                for line in batch._allocations:
                    writer.writerow([line.orderid, line.sku, line.qty, batch.reference])

    def rollback(self):
        pass
```

**And the entire CLI collapses to nine lines, calling the *existing, unchanged* service layer:**

```python
def main(folder):
    orders_path = Path(folder) / 'orders.csv'
    uow = csv_uow.CsvUnitOfWork(folder)
    with orders_path.open() as f:
        for row in csv.DictReader(f):
            services.allocate(row['orderid'], row['sku'], int(row['qty']), uow)
```
> "Ta-da! *Now are y'all impressed or what?* — Much love, Bob and Harry"

**Appendix D — the Django translation layer, the price of no classical mapper:**

```python
# src/djangoproject/alloc/models.py — ORM depends on model, not the reverse
from allocation.domain import model as domain_model


class Batch(models.Model):
    reference = models.CharField(max_length=255)
    sku = models.CharField(max_length=255)
    qty = models.IntegerField()
    eta = models.DateField(blank=True, null=True)

    @staticmethod
    def update_from_domain(batch: domain_model.Batch):
        try:
            b = Batch.objects.get(reference=batch.reference)
        except Batch.DoesNotExist:               # entities need explicit try/except upsert
            b = Batch(reference=batch.reference)  # (get_or_create works for value objects)
        b.sku = batch.sku
        b.qty = batch._purchased_quantity
        b.eta = batch.eta
        b.save()
        b.allocation_set.set(
            Allocation.from_domain(l, b) for l in batch._allocations
        )

    def to_domain(self) -> domain_model.Batch:
        b = domain_model.Batch(
            ref=self.reference, sku=self.sku, qty=self.qty, eta=self.eta)
        b._allocations = set(a.line.to_domain() for a in self.allocation_set.all())
        return b


# src/allocation/service_layer/unit_of_work.py
class DjangoUnitOfWork(AbstractUnitOfWork):
    def __enter__(self):
        self.batches = repository.DjangoRepository()
        transaction.set_autocommit(False)     # stop Django auto-committing each op
        return super().__enter__()

    def __exit__(self, *args):
        super().__exit__(*args)
        transaction.set_autocommit(True)

    def commit(self):
        for batch in self.batches.seen:       # must manually push touched objects back
            self.batches.update(batch)        # (SQLAlchemy instruments the instances; Django doesn't)
        transaction.commit()

    def rollback(self):
        transaction.rollback()
```
Tests need `@pytest.mark.django_db(transaction=True)` (via `pytest-django`) to exercise custom transaction/rollback behavior. **The service layer didn't change at all**, and `views.py` ends up "almost identical to the old `flask_app.py`."

**Appendix E — validation, all three layers.**

*Syntax, declared on the message class:*
```python
from schema import And, Schema, Use

@dataclass
class Allocate(Command):
    _schema = Schema({
        'orderid': int,
        'sku': str,
        'qty': And(Use(int), lambda n: n > 0),
    }, ignore_extra_keys=True)          # ← Tolerant Reader

    orderid: str
    sku: str
    qty: int

    @classmethod
    def from_json(cls, data):
        data = json.loads(data)
        return cls(**cls._schema.validate(data))
```
Repetitive (fields declared twice), so a factory unifies them — at the cost of losing dataclass types:
```python
def command(name, **fields):
    schema = Schema(And(Use(json.loads), fields), ignore_extra_keys=True)
    cls = make_dataclass(name, fields.keys())
    cls.from_json = lambda s: cls(**schema.validate(s))
    return cls

quantity = And(Use(int), lambda x: x > 0)      # reusable parsers keep it DRY

Allocate = command(orderid=int, sku=str, qty=quantity)
AddStock = command(sku=str, qty=quantity)
```

*The bus becomes the cross-cutting validation point:*
```python
class MessageBus:
    def handle_message(self, name: str, body: str):
        try:
            message_type = next(mt for mt in EVENT_HANDLERS if mt.__name__ == name)
            message = message_type.from_json(body)
            self.handle([message])
        except StopIteration:
            raise KeyError(f"Unknown message name {name}")
        except ValidationError as e:
            logging.error(f'invalid message of type {name}\n{body}\n{e}')
            raise e
```
So each entrypoint only decides **how to report** the failure:
```python
# Flask: bubble it up as a 400
@app.route("/change_quantity", methods=['POST'])
def change_batch_quantity():
    try:
        bus.handle_message('ChangeBatchQuantity', request.body)
    except ValidationError as e:
        return bad_request(e)
    except exceptions.InvalidSku as e:
        return jsonify({'message': str(e)}), 400


# Redis: log and skip
def handle_change_batch_quantity(m, bus: messagebus.MessageBus):
    try:
        bus.handle_message('ChangeBatchQuantity', m)
    except ValidationError:
        print('Skipping invalid message')
    except exceptions.InvalidSku as e:
        print(f'Unable to change stock for missing sku {e}')
```

*Semantics, via preconditions:*
```python
# src/allocation/ensure.py
class MessageUnprocessable(Exception):
    def __init__(self, message):
        self.message = message


class ProductNotFound(MessageUnprocessable):
    """Raised when we act on a product that doesn't exist in our database."""
    def __init__(self, message):
        super().__init__(message)
        self.sku = message.sku


def product_exists(event, uow):
    product = uow.products.get(event.sku)
    if product is None:
        raise ProductNotFound(event)


# services.py — main flow stays clean and declarative
def allocate(event, uow):
    line = model.OrderLine(event.orderid, event.sku, event.qty)
    with uow:
        ensure.product_exists(uow, event)      # ← same UoW, or you get concurrency bugs
        product = uow.products.get(line.sku)
        product.allocate(line)
        uow.commit()
```

*Idempotency, generically:*
```python
class SkipMessage(Exception):
    """Raised when a message can't be processed, but there's no incorrect behavior.
    For example, we might receive the same message multiple times, or a message
    that is now out of date."""
    def __init__(self, reason):
        self.reason = reason


def batch_is_new(self, event, uow):
    batch = uow.batches.get(event.batchid)
    if batch is not None:
        raise SkipMessage(f"Batch with id {event.batchid} already exists")


class MessageBus:
    def handle_message(self, message):
        try:
            ...
        except SkipMessage as e:
            logging.warn(f"Skipping message {message.id} because {e.reason}")
```

## Anti-patterns

- **Validating the internal structure of identifiers** — SKU formats, order numbers, phone numbers. Treat them as opaque strings.
- **Sharing message-definition libraries or JSON Schema between systems.** Fails the robustness test.
- **Defensive coding inside the domain model.** Validate at the edge so handlers only ever see valid messages.
- **Putting all your business logic into precondition checks.** If a rule can be tested in the domain model, test it there.
- **Using a different UoW for preconditions than for the use case.** Opens you to "irritating concurrency bugs."
- **Splitting Docker images per application role** (Web API vs pub/sub client). "Usually ends up being more trouble than it's worth; the cost in terms of complexity and longer rebuild/CI times is too high."
- **The Django admin on a complex-workflow app.** It bypasses every rule you modeled.
- **`config.py` as a dumping ground** of vaguely-config-related stuff imported everywhere.

## Key Takeaways

1. **Appendix A's table is the book's map.** Domain / Service Layer / Adapters / Entrypoints, with one line per component.
2. **`src/` + `setup.py` + `pip install -e`** makes imports painless; keep tests in a sibling tree split by type.
3. **Config as functions reading env vars, with local-machine defaults**, so code runs both inside and outside containers.
4. **Order Dockerfile steps by rate of change** to maximize build-cache reuse.
5. **Appendix C is the proof**: a completely different I/O model (CLI + CSVs) cost two new classes and zero changes to the domain or service layer.
6. **Django can do this, but pays a translation-layer tax** because it has no classical mapper — and its greatest strengths assume a CRUD app.
7. **Separate syntax / semantics / pragmatics and put each in its own layer.** "Once you've validated the syntax and semantics of your commands at the edges of your system, the domain is the place for the rest of your validation. Validation of pragmatics is often a core part of your business rules."
8. **Validate as little as possible** (Tolerant Reader), but **validate as early as possible** (at the edge).
9. **Invest in validation helpers.** "It's worth investing time to make boring code easy to maintain."

## Connects To
- **Ch 2 / Ch 6**: Repository and UoW — Appendix C swaps their implementations wholesale; Appendix D reimplements them on Django.
- **Ch 4**: the folder structure introduced there, expanded in Appendix B.
- **Ch 8**: "the message bus is a great place to put cross-cutting concerns" — validation is the example.
- **Ch 9 / Ch 10**: event and command classes, which Appendix E turns into the validation boundary.
- **Ch 11**: outbound events, where the "conservative in what you emit" half of Postel's law applies.
- **Ch 12**: `Product` bounded-context modeling vs. read models; Appendix D's advice to centralize reads.
- **Epilogue**: the `ensure` pattern referenced in the "layering an overgrown system" recipe; Django advice continues there.
- **Martin Fowler, "Tolerant Reader"**; **12-factor manifesto**; **`schema`**, `environ-config`, `pytest-django`, `Invoke`, DRY-Python `mappers`.
