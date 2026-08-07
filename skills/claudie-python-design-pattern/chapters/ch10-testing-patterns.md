# Chapter 10: Patterns for Testing

## Core Idea

Tests fail for the wrong reasons when the unit under test drags its dependencies along — file I/O, HTTP calls, databases, services that do not exist yet. Two patterns fix this from opposite ends. Mock Object replaces a dependency at test time from the outside. Dependency Injection removes the hardcoded dependency at design time so replacement needs no trickery at all. Use both: DI to make the seam, mocks or stubs to fill it.

## Frameworks Introduced

- **Mock Object**: Isolate the unit by substituting a simulated collaborator. Three features the authors name: **isolation** (predictable dependencies, no external side effects), **behavior verification** (assert that calls happened, with which arguments, in which order), **simplification** (skip expensive real-object setup).
  - When to use: unit testing against complex/unreliable/unavailable dependencies (mock an API returning canned responses so you can exercise error branches); integration testing where a collaborator is still under development or too costly to hit every run (a microservice not yet built); behavior verification (an MVC controller must call auth then logging before processing a request — assert the order).
  - How: `unittest.mock.patch(target)` temporarily swaps the target object for a mock, as a context manager or decorator. Its options: `new`, `spec`/`autospec` (restrict mock to the real object's attributes), `spec_set` (stricter), `side_effect` (conditional behavior or raising), `return_value` (fixed response), `wraps` (delegate to the original while overriding parts). `mock_open()` returns a Mock preconfigured to behave like built-in `open()`, simulating read/write. Patch builtins by full name: `patch("builtins.open", m_open)` — `builtins.open` is the full name of the `open()` built-in.
  - Why it works / failure mode: the object under test never learns it was faked, so internal behavior is testable without restructuring the class for tests. Failure mode: replace too much and you assert against your own mock instead of the code; a mock with no `spec` accepts calls the real object would reject, so the test passes while production breaks.
  - Real-world example: a flight simulator (practice real scenarios safely), a CPR dummy, a crash test dummy — all replicate the real thing in a controlled setting.

- **Dependency Injection**: Pass a class's dependencies in from outside instead of constructing them inside. Buys loose coupling, modularity, testability.
  - When to use: injecting DB connection objects into repositories/services so the engine or config swaps without touching component code (and mock connections drop in for tests without touching the live database); managing configuration across dev/test/prod environments by injecting settings, so modules decouple from their config source and tests can inject specific settings to probe robustness.
  - How: two mechanisms. **Constructor injection** — declare the dependency's shape with `typing.Protocol`, accept it as a `__init__` parameter, store it. **Decorator injection** — a class decorator factory `inject_sender(sender_cls)` sets `cls.sender = sender_cls()` and returns the class, so `@inject_sender(EmailSender)` wires the dependency without editing the class body.
  - Why it works / failure mode: the consumer never knows whether it holds a real or fake collaborator, so swapping is free. Decorator injection binds at class-decoration time, so a test that wants a different dependency must either reassign the attribute or declare a locally decorated class — a real constraint the authors work around explicitly.
  - Real-world example: appliances and power outlets (plug anything in, no permanent wiring); camera lenses swapped per environment without changing the camera; modular train systems where sleeper/diner/baggage cars attach per journey.

## Key Concepts

**Mock vs. stub.** Stubs also replace real implementations, but only to supply *indirect input* to the code under test. Mocks additionally *verify interactions*. That extra capability makes mocks more flexible across testing scenarios; it is also the only real distinction the authors draw.

**Patch target resolution.** `patch()` takes a `target` string naming the object to replace. Patch the name at the location that resolves it, not where it was defined — `"builtins.open"` when the code under test calls bare `open()`.

**`mock_open` is a factory.** `m_open = mock_open()` is itself callable and manufactures a fresh mock file handle each call. So `m_open.assert_called_once_with("dummy.log", "a")` checks the `open()` call, while `m_open().write.assert_called_once_with(...)` reaches through a handle to check the write.

**`spec`/`autospec` narrow the fake.** Constrain a mock to the real object's attributes so typos and vanished methods surface as failures.

## Mental Models

**Choosing mock vs. stub:** ask what the assertion is about. Asserting on *returned state* → stub is enough. Asserting that a *call occurred* (arguments, count, order) → mock. In the decorator DI example, the authors deliberately reach for stubs and hand-roll the verification with a `messages_sent` list — proof that a stub plus a recorded list covers many "was it called" cases without the mock library.

**DI as the thing that makes mocking unnecessary.** Patching is a workaround for a dependency you cannot reach. Inject it and the seam is a plain parameter — pass a fake, no `patch()`, no import-path archaeology. Reach for `patch()` when you cannot change the code (builtins, third-party internals); reach for DI when you can.

## Anti-patterns

- Patching where the object was defined instead of where the code under test looks it up.
- Mocking so much that the test exercises the mock's wiring, not the unit's logic.
- Unspecced mocks that happily accept calls the real collaborator would reject.
- Restructuring production classes purely to make them testable — inject instead; mocking `builtins.open` proves you can test internal behavior without altering class structure.
- Constructing dependencies inside `__init__` (`self.api = RealWeatherApiClient()`), which hardcodes the collaborator and forces patching later.

## Code Examples

```python
import unittest
from unittest.mock import mock_open, patch


class Logger:
    def __init__(self, filepath):
        self.filepath = filepath

    def log(self, message):
        with open(self.filepath, "a") as file:
            file.write(f"{message}\n")


class TestLogger(unittest.TestCase):
    def test_log(self):
        msg = "Hello, logging world!"
        m_open = mock_open()
        with patch("builtins.open", m_open):
            logger = Logger("dummy.log")
            logger.log(msg)
        m_open.assert_called_once_with("dummy.log", "a")
        m_open().write.assert_called_once_with(f"{msg}\n")


if __name__ == "__main__":
    unittest.main()
```

- **What it demonstrates**: `patch()` + `mock_open()` against `builtins.open` — file I/O isolated, no real file created, both the open call and the write verified.

```python
from typing import Protocol


class WeatherApiClient(Protocol):
    def fetch_weather(self, location):
        """Fetch weather data for a given location"""
        ...


class RealWeatherApiClient:
    def fetch_weather(self, location):
        return f"Real weather data for {location}"


class WeatherService:
    def __init__(self, weather_api: WeatherApiClient):
        self.weather_api = weather_api

    def get_weather(self, location):
        return self.weather_api.fetch_weather(location)


if __name__ == "__main__":
    ws = WeatherService(RealWeatherApiClient())
    print(ws.get_weather("Paris"))
```

- **What it demonstrates**: constructor injection typed by `Protocol` — `WeatherService` never names a concrete client.

```python
import unittest
from di_with_mock import WeatherService


class MockWeatherApiClient:
    def fetch_weather(self, location):
        return f"Mock weather data for {location}"


class TestWeatherService(unittest.TestCase):
    def test_get_weather(self):
        mock_api = MockWeatherApiClient()
        weather_service = WeatherService(mock_api)
        self.assertEqual(
            weather_service.get_weather("Anywhere"),
            "Mock weather data for Anywhere",
        )


if __name__ == "__main__":
    unittest.main()
```

- **What it demonstrates**: DI via mock object — no `patch()` needed, the fake goes in through the constructor.

```python
from typing import Protocol


class NotificationSender(Protocol):
    def send(self, message: str):
        """Send a notification with the given message"""
        ...


class EmailSender:
    def send(self, message: str):
        print(f"Sending Email: {message}")


class SMSSender:
    def send(self, message: str):
        print(f"Sending SMS: {message}")


def inject_sender(sender_cls):
    def decorator(cls):
        cls.sender = sender_cls()
        return cls

    return decorator


@inject_sender(EmailSender)
class NotificationService:
    sender: NotificationSender = None

    def notify(self, message):
        self.sender.send(message)


if __name__ == "__main__":
    service = NotificationService()
    service.notify("Hello, this is a test notification!")
```

- **What it demonstrates**: DI via decorator — swap `EmailSender` for `SMSSender` on the decorator line and the output changes; the class body never moves.

## Reference Tables

| Dimension | Mock | Stub |
| --- | --- | --- |
| Primary role | Simulate a collaborator **and** verify interactions | Supply indirect input to the code under test |
| Assertions | `assert_called_once_with`, call args, call order | On resulting state / values only |
| Verification built in | Yes, via the mock library | No — hand-roll it (e.g. a `messages_sent` list) |
| Flexibility | Higher; covers more testing scenarios | Narrower, but simpler and explicit |
| Typical source | `unittest.mock` | Small handwritten class implementing the Protocol |

| Tool | What it does | When to use |
| --- | --- | --- |
| `unittest.mock.Mock` | Generic auto-attribute fake recording all calls | Ad-hoc collaborator with no shape constraint |
| `unittest.mock.MagicMock` | `Mock` plus configured magic methods (`__len__`, `__iter__`, `__enter__`, …) | Fake must behave like a container or context manager |
| `unittest.mock.patch(target, ...)` | Temporarily replaces `target` with a mock; context manager or decorator | Dependency you cannot inject (builtins, module globals) |
| `patch(..., new=obj)` | Substitutes a specific replacement object | You built the fake yourself, e.g. `mock_open()` |
| `patch(..., spec=/autospec=)` | Restricts the mock to the real object's attributes | Guard against drift between fake and real API |
| `patch(..., spec_set=...)` | Stricter attribute specification | Forbid setting attributes the real object lacks |
| `patch(..., side_effect=...)` | Conditional behavior or raises an exception | Exercise error paths and per-call variation |
| `patch(..., return_value=...)` | Fixed response | Simple canned answer |
| `patch(..., wraps=...)` | Delegates to the original while overriding parts | Keep real behavior, observe or tweak one aspect |
| `unittest.mock.mock_open()` | Mock configured to act like `open()`; callable factory of file handles | Testing file reads/writes |

## Worked Example

**Decorator-based Dependency Injection, end to end.**

Start with the seam: `NotificationSender` is a `Protocol` with one method, `send(message)`. `EmailSender` and `SMSSender` implement it. `NotificationService` declares `sender: NotificationSender = None` as a *class attribute* and calls `self.sender.send(message)` in `.notify()` — it names no concrete sender.

The wiring is a decorator factory:

```python
def inject_sender(sender_cls):
    def decorator(cls):
        cls.sender = sender_cls()
        return cls

    return decorator
```

`inject_sender(EmailSender)` returns `decorator`; `decorator(NotificationService)` instantiates `EmailSender()`, assigns it to the class attribute, returns the class unchanged. Dependency management now lives outside the business logic — one line changes the channel.

Testing it: rather than mocks, use stubs that record calls.

```python
import unittest
from di_with_decorator import (
    NotificationSender,
    NotificationService,
    inject_sender,
)


class EmailSenderStub:
    def __init__(self):
        self.messages_sent = []

    def send(self, message: str):
        self.messages_sent.append(message)


class SMSSenderStub:
    def __init__(self):
        self.messages_sent = []

    def send(self, message: str):
        self.messages_sent.append(message)


class TestNotifService(unittest.TestCase):
    def test_notify_with_email(self):
        email_stub = EmailSenderStub()
        service = NotificationService()
        service.sender = email_stub
        service.notify("Test Email Message")
        self.assertIn(
            "Test Email Message",
            email_stub.messages_sent,
        )

    def test_notify_with_sms(self):
        sms_stub = SMSSenderStub()

        @inject_sender(SMSSenderStub)
        class CustomNotificationService:
            sender: NotificationSender = None

            def notify(self, message):
                self.sender.send(message)

        service = CustomNotificationService()
        service.sender = sms_stub
        service.notify("Test SMS Message")
        self.assertIn("Test SMS Message", sms_stub.messages_sent)


if __name__ == "__main__":
    unittest.main()
```

Reasoning: the first test overrides `service.sender` on the *instance*, shadowing the class attribute the decorator set — enough because `notify()` reads `self.sender`. The second test shows the decorator path itself: declare a class inside the test scope, decorate it with `@inject_sender(SMSSenderStub)`, then still assign `service.sender = sms_stub` to hold the exact instance being asserted on (the decorator built its own). Both assertions read the stub's `messages_sent` list — behavior verification without the mock library. Two tests, both pass.

## Key Takeaways

- Mock Object gives isolation, behavior verification, and simpler setup — pick it when the assertion is about a *call*.
- Stubs supply input only; add a recording list and they verify calls too, with less machinery.
- `patch("builtins.open", mock_open())` isolates file I/O with zero changes to the class under test.
- `mock_open()` is a callable factory: `m_open.assert_called_once_with(...)` checks the open, `m_open().write.assert_called_once_with(...)` checks the write.
- `spec`/`autospec`/`spec_set` keep fakes honest; `side_effect`/`return_value`/`wraps` shape their behavior.
- DI means dependencies arrive from outside — constructor for explicitness, class decorator to keep wiring out of business logic entirely.
- `typing.Protocol` documents the seam without inheritance, so real and fake implementations stay independent.
- The consumer must not be able to tell real from fake; when it can, the design leaked.

## Connects To

- **Ch 11 (Python anti-patterns)** — over-mocking and hidden dependency construction are testing-side instances of the pitfalls catalogued there.
- **Strategy / Adapter** — DI is Strategy's injection mechanism; `NotificationSender` implementations are interchangeable strategies.
- **Factory patterns** — `inject_sender(sender_cls)` is a minimal factory: it decides which concrete class to instantiate.
- **Ch 8 (concurrency) / Ch 9 (performance)** — injected dependencies let you swap in deterministic fakes for nondeterministic or expensive collaborators.
- **Dependency Inversion Principle** — both patterns push high-level code to depend on a `Protocol`, never a concrete class.
