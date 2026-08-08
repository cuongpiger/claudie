# Chapter 13: Dependency Injection (and Bootstrapping)

## Core Idea
Once you have more than one adapter, passing dependencies around manually becomes painful. Declare dependencies **explicitly** in handler signatures, then inject them in one place — a **bootstrap script** (the Composition Root) — which also does app initialization and provides the single place to swap in fakes for tests.

## Frameworks Introduced

- **Explicit over implicit dependencies**: the standard Python way is to import a module and `mock.patch` it in tests. Trade that for a declared parameter.
  - ❌ `from allocation.adapters import email` … `email.send(...)` — hardcoded import, tied to `import email`; a trivial refactor to `from email import send_mail` breaks all your mocks.
  - ✅ `def send_out_of_stock_notification(event, send_mail: Callable)` — an explicit dependency on an **abstraction**, which is the DIP.
  - The real cost of the mock approach: "in real life, you'd end up having to call `mock.patch` for every single test that might cause an out-of-stock notification. If you've worked on codebases with lots of mocks used to prevent unwanted side effects, you'll know how annoying that mocky boilerplate gets."
  - It is a **trade-off**: explicit dependencies are "unnecessary, strictly speaking, and using them would make our application code marginally more complex. But in return, we'd get tests that are easier to write and manage."

- **Composition Root / bootstrap script** ("Pure DI" or "Vanilla DI", per Mark Seemann). Four jobs:
  1. Declare default dependencies but allow overrides.
  2. Do the "init" stuff needed to start the app (`orm.start_mappers()`, logging setup…).
  3. Inject all the dependencies into the handlers.
  4. Return the core object for the app — the message bus.

- **Three ways to do manual DI** — pick what your team likes:
  1. **Closures** — `def allocate_composed(cmd): return allocate(cmd, uow)`. (A named function gets you a nicer stack trace than a lambda.)
  2. **`functools.partial`** — `functools.partial(allocate, uow=uow)`. Differs from closures in that closures use **late binding of variables**, "a source of confusion if any of the dependencies are mutable."
  3. **Classes** — `__init__` declares the dependencies, `__call__` makes the instance callable. Familiar if you've written class-based descriptors or context managers that take arguments.

- **The "build an adapter properly" recipe** (the chapter's summary):
  1. Define your API using an **ABC**.
  2. Implement **the real thing**.
  3. Build a **fake** and use it for unit / service-layer / handler tests.
  4. Find a **less fake** version you can put into your Docker environment.
  5. **Test the less fake "real" thing.**
  6. Profit!

## Key Concepts

- **Composition Root** — the single place where an application's object graph is composed. Python devs aren't used to needing this: "We just pick our entrypoint and run code from top to bottom."
- **`inject_dependencies(handler, dependencies)`** — matches a handler's parameter names against a dependency dict via `inspect.signature`, returns a partial.
- **`MessageBus` as a class** — no longer a module; constructed with already-injected handler dicts.
- **MailHog** — a "real-ish" email server run in Docker for integration tests.
- **Dependency chains** — when your dependencies have their own dependencies. The signal that a real DI framework might earn its keep.
- **DI frameworks named**: `Inject` (used at MADE, "although it makes Pylint unhappy"), `Punq` (written by Bob), and the DRY-Python crew's `dependencies`.

## Mental Models

- **"Explicit is better than implicit." — The Zen of Python.** Declaring a dependency explicitly *is* the dependency inversion principle: rather than an implicit dependency on a specific detail, you have an explicit dependency on an abstraction.
- **Mocks tightly couple tests to implementation.** By choosing to monkeypatch `email.send_mail`, you're tied to writing `import email`.
- **Two tiers of dependency, two tiers of ceremony:**
  - **ABC** — the heavyweight option, for relatively complex dependencies (the UoW). Use when the API can't be captured as one function: read *and* write, GET *and* POST.
  - **Plain `Callable`** — perfectly fine for simple dependencies (`send_mail`, `publish`).
  - Real examples the authors inject at work: an S3 filesystem client, a key/value store client, a `requests` session object — "most of these will have more-complex APIs that you can't capture as a single function."
- **Harry vs. Bob on `inspect`:** Harry wrote `inject_dependencies()` as a first cut at manual DI, "and when he saw it, Bob accused him of overengineering and writing his own DI framework." Both the `inspect`-based and the fully-manual-lambda versions work fine *because this app only does DI in one place — the handler functions.*
- **`self.queue` is not thread-safe.** The bus instance is global in the Flask app context as written. "Just something to watch out for." (Also worth researching Flask app factories if you want in-process testing with the Flask Test Client.)

## Code Examples

**Manual DI, three flavors:**

```python
# 1. Closure — named function gets a nicer stack trace than a lambda
def bootstrap(...):
    uow = unit_of_work.SqlAlchemyUnitOfWork()

    def allocate_composed(cmd):
        return allocate(cmd, uow)

# 2. functools.partial — early binding
    allocate_composed = functools.partial(allocate, uow=uow)

# later at runtime, the UoW is already bound
allocate_composed(cmd)
```

```python
# 3. Classes
class AllocateHandler:
    def __init__(self, uow: unit_of_work.AbstractUnitOfWork):
        self.uow = uow                      # declare dependencies

    def __call__(self, cmd: commands.Allocate):   # produce a callable
        line = OrderLine(cmd.orderid, cmd.sku, cmd.qty)
        with self.uow:
            ...

allocate = AllocateHandler(unit_of_work.SqlAlchemyUnitOfWork())
allocate(cmd)
```

**The bootstrap script:**

```python
# src/allocation/bootstrap.py
def bootstrap(
    start_orm: bool = True,
    uow: unit_of_work.AbstractUnitOfWork = unit_of_work.SqlAlchemyUnitOfWork(),
    notifications: AbstractNotifications = EmailNotifications(),
    publish: Callable = redis_eventpublisher.publish,
) -> messagebus.MessageBus:
    if start_orm:
        orm.start_mappers()

    dependencies = {'uow': uow, 'notifications': notifications, 'publish': publish}

    injected_event_handlers = {
        event_type: [
            inject_dependencies(handler, dependencies)
            for handler in event_handlers
        ]
        for event_type, event_handlers in handlers.EVENT_HANDLERS.items()
    }
    injected_command_handlers = {
        command_type: inject_dependencies(handler, dependencies)
        for command_type, handler in handlers.COMMAND_HANDLERS.items()
    }

    return messagebus.MessageBus(
        uow=uow,
        event_handlers=injected_event_handlers,
        command_handlers=injected_command_handlers,
    )


def inject_dependencies(handler, dependencies):
    params = inspect.signature(handler).parameters       # inspect the handler's args
    deps = {
        name: dependency
        for name, dependency in dependencies.items()
        if name in params                                # match by name
    }
    return lambda message: handler(message, **deps)      # inject as kwargs
```
- **Note on defaults**: "It's nice to have them in a single place, but sometimes dependencies have some side effects at construction time, in which case you might prefer to default them to `None` instead."

**The "less magic" alternative Bob prefers** — one line per handler, no `inspect`:

```python
injected_event_handlers = {
    events.Allocated: [
        lambda e: handlers.publish_allocated_event(e, publish),
        lambda e: handlers.add_allocation_to_read_model(e, uow),
    ],
    events.Deallocated: [
        lambda e: handlers.remove_allocation_from_read_model(e, uow),
        lambda e: handlers.reallocate(e, uow),
    ],
    events.OutOfStock: [
        lambda e: handlers.send_out_of_stock_notification(e, notifications),
    ],
}
injected_command_handlers = {
    commands.Allocate:            lambda c: handlers.allocate(c, uow),
    commands.CreateBatch:         lambda c: handlers.add_batch(c, uow),
    commands.ChangeBatchQuantity: lambda c: handlers.change_batch_quantity(c, uow),
}
```
> "This is a perfectly viable solution, since it's only one line of code or so per handler you add, and thus not a massive maintenance burden even if you have dozens of handlers."

**The message bus becomes a class holding pre-injected handlers:**

```python
class MessageBus:
    def __init__(
        self,
        uow: unit_of_work.AbstractUnitOfWork,
        event_handlers: Dict[Type[events.Event], List[Callable]],
        command_handlers: Dict[Type[commands.Command], Callable],
    ):
        self.uow = uow
        self.event_handlers = event_handlers
        self.command_handlers = command_handlers

    def handle(self, message: Message):
        self.queue = [message]
        while self.queue:
            message = self.queue.pop(0)
            if isinstance(message, events.Event):
                self.handle_event(message)
            elif isinstance(message, commands.Command):
                self.handle_command(message)
            else:
                raise Exception(f'{message} was not an Event or Command')

    def handle_event(self, event: events.Event):
        for handler in self.event_handlers[type(event)]:
            try:
                logger.debug('handling event %s with handler %s', event, handler)
                handler(event)                       # ← single argument now
                self.queue.extend(self.uow.collect_new_events())
            except Exception:
                logger.exception('Exception handling event %s', event)
                continue

    def handle_command(self, command: commands.Command):
        logger.debug('handling command %s', command)
        try:
            handler = self.command_handlers[type(command)]
            handler(command)                          # ← single argument now
            self.queue.extend(self.uow.collect_new_events())
        except Exception:
            logger.exception('Exception handling command %s', command)
            raise
```
- **Key change**: handlers take *only* the message. All dependencies are already bound.

**Entrypoints get dramatically simpler:**

```python
# src/allocation/entrypoints/flask_app.py
-from allocation import views
+from allocation import bootstrap, views

 app = Flask(__name__)
-orm.start_mappers()
+bus = bootstrap.bootstrap()

 def add_batch():
     cmd = commands.CreateBatch(
         request.json['ref'], request.json['sku'], request.json['qty'], eta,
     )
-    uow = unit_of_work.SqlAlchemyUnitOfWork()
-    messagebus.handle(cmd, uow)
+    bus.handle(cmd)
     return 'OK', 201
```

## Reference Tables

| Dependency kind | Mechanism | Use when |
|---|---|---|
| Complex — multiple operations (read/write, GET/POST) | **ABC** + concrete + fake | UoW, notifications, S3 client, key/value store, `requests` session |
| Simple — one operation | Plain `Callable` | `send_mail`, `publish` |

| DI approach | Feels like | Watch out for |
|---|---|---|
| Closure (lambda or named fn) | Functional | **Late binding** of variables if deps are mutable; lambdas give worse stack traces |
| `functools.partial` | Functional | — |
| Class with `__init__` + `__call__` | OO | Requires rewriting every handler as a class |
| `inspect.signature` auto-wiring | Magic | Bob calls it "writing your own DI framework" |
| A real DI framework (`Inject`, `Punq`, `dependencies`) | Enterprise | Only worth it for **chained dependencies** or DI at multiple levels |

| Test level | `start_orm` | `uow` | `notifications` | `publish` |
|---|---|---|---|---|
| Unit / handler | `False` | `FakeUnitOfWork()` | `FakeNotifications()` | `lambda *args: None` |
| Integration (views) | `True` | `SqlAlchemyUnitOfWork(sqlite_session_factory)` | noop | noop |
| Integration (email) | `True` | `SqlAlchemyUnitOfWork(sqlite_session_factory)` | **`EmailNotifications()`** → MailHog | noop |
| Production | `True` | `SqlAlchemyUnitOfWork()` → Postgres | `EmailNotifications()` | `redis_eventpublisher.publish` |

## Worked Example

**Turning `send_mail` into a proper adapter, following the five-step recipe.**

*Step 1 & 2 — the ABC and the real implementation.* Imagine a generic notifications API: "Could be email, could be SMS, could be Slack posts one day."
```python
# src/allocation/adapters/notifications.py
class AbstractNotifications(abc.ABC):
    @abc.abstractmethod
    def send(self, destination, message):
        raise NotImplementedError


class EmailNotifications(AbstractNotifications):
    def __init__(self, smtp_host=DEFAULT_HOST, port=DEFAULT_PORT):
        self.server = smtplib.SMTP(smtp_host, port=port)
        self.server.noop()

    def send(self, destination, message):
        msg = f'Subject: allocation service notification\n{message}'
        self.server.sendmail(
            from_addr='allocations@example.com',
            to_addrs=[destination],
            msg=msg,
        )
```
Swap it in the bootstrap signature:
```diff
-    send_mail: Callable = email.send,
+    notifications: AbstractNotifications = EmailNotifications(),
```

*Step 3 — the fake, and the unit test:*
```python
class FakeNotifications(notifications.AbstractNotifications):
    def __init__(self):
        self.sent = defaultdict(list)  # type: Dict[str, List[str]]

    def send(self, destination, message):
        self.sent[destination].append(message)


def test_sends_email_on_out_of_stock_error(self):
    fake_notifs = FakeNotifications()
    bus = bootstrap.bootstrap(
        start_orm=False,
        uow=FakeUnitOfWork(),
        notifications=fake_notifs,
        publish=lambda *args: None,
    )

    bus.handle(commands.CreateBatch("b1", "POPULAR-CURTAINS", 9, None))
    bus.handle(commands.Allocate("o1", "POPULAR-CURTAINS", 10))

    assert fake_notifs.sent['stock@made.com'] == [
        f"Out of stock for POPULAR-CURTAINS",
    ]
```

*Steps 4 & 5 — the "less fake" real thing.* Add MailHog to `docker-compose.yml`:
```yaml
  mailhog:
    image: mailhog/mailhog
    ports:
      - "11025:1025"
      - "18025:8025"
```
And integration-test against it with the **real** `EmailNotifications`:
```python
@pytest.fixture
def bus(sqlite_session_factory):
    bus = bootstrap.bootstrap(
        start_orm=True,
        uow=unit_of_work.SqlAlchemyUnitOfWork(sqlite_session_factory),
        notifications=notifications.EmailNotifications(),
        publish=lambda *args: None,
    )
    yield bus
    clear_mappers()


def get_email_from_mailhog(sku):
    host, port = map(config.get_email_host_and_port().get, ['host', 'http_port'])
    all_emails = requests.get(f'http://{host}:{port}/api/v2/messages').json()
    return next(m for m in all_emails['items'] if sku in str(m))


def test_out_of_stock_email(bus):
    sku = random_sku()
    bus.handle(commands.CreateBatch('batch1', sku, 9, None))
    bus.handle(commands.Allocate('order1', sku, 10))

    email = get_email_from_mailhog(sku)
    assert email['Raw']['From'] == 'allocations@example.com'
    assert email['Raw']['To'] == ['stock@made.com']
    assert f'Out of stock for {sku}' in email['Raw']['Data']
```
> "Against all the odds, this actually worked, pretty much at the first go!"

Note the pattern in the fixtures: **the bus is used to do the test setup.** Same trick as Ch12's view tests — drive everything through the public entrypoint.

## Anti-patterns

- **`mock.patch` for every test that might trigger a side effect.** The boilerplate compounds and couples tests to import style.
- **Making the message bus responsible for passing dependencies to handlers** — an SRP violation, and duplicated cruft across Flask, Redis, and tests.
- **Reaching for a DI framework too early.** Only worth it for chained dependencies or DI at multiple levels.
- **Global bus instance + `self.queue` with threads.** Not thread-safe as written.

## Key Takeaways

1. **The pain threshold is "more than one adapter."** Until then, passing the UoW around by hand is fine — the book got through 12 chapters without DI.
2. **Explicit dependencies are the DIP applied to functions.** You depend on `send_mail: Callable`, not on `import email`.
3. **Put DI and all one-time initialization in a bootstrap script**, and have it return a ready-to-use message bus.
4. **The bootstrap script is also your test seam**: one place to override every adapter with a fake or a noop.
5. **Pick closures, partials, or classes by team taste** — but know that closures use late binding.
6. **Scale the ceremony to the dependency.** ABC for complex ones, bare `Callable` for simple ones.
7. **The adapter recipe is five steps**: ABC → real → fake → less-fake-in-Docker → test the less-fake thing.
8. **Use the bus for test setup** so tests stay decoupled from storage details.

## Connects To
- **Ch 3**: functional vs object-oriented dependency management, and the "why not just patch it out?" argument — the authors say to re-read it before this chapter.
- **Ch 8**: the `mock.patch` on the email module, promised there and finally removed here.
- **Ch 6**: the UoW's session factory — the book's first explicit dependency.
- **Ch 9 / Ch 10**: the module-level `messagebus`, now a configurable class.
- **Ch 12**: the bus-as-test-setup pattern reused in the bootstrap fixtures.
- **Epilogue**: applying all of this in the Real World™.
- **Mark Seemann**, *Dependency Injection in .NET* — "Pure DI" / "Vanilla DI" and the Composition Root.
