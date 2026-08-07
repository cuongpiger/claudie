# Chapter 1: Foundational Design Principles

## Core Idea
Four principles — Encapsulate What Varies, Favor Composition Over Inheritance, Program to Interfaces Not Implementations, and Loose Coupling — are the substrate every design pattern in this book is built from. Isolate change behind a boundary so a requirement shift touches one class, not the whole call graph.

## Frameworks Introduced

- **Encapsulate What Varies**: isolate the parts of your code most likely to change and encapsulate them, creating a protective barrier that shields the rest of the code from those elements.
  - When to use: a feature has several current or foreseeable variants (payment method, storage backend, export format), or an attribute needs validation/logging on access.
  - How: (1) name the axis of variation; (2) pull it into its own class or property; (3) expose a stable operation the rest of the system calls; (4) add new variants as new classes, not new `if` branches. Two techniques: **polymorphism** (each variant is a subclass overriding a common method) and **getters and setters**, with Python's **property technique** (`@property` / `@attribute_name.setter`) as the idiomatic form.
  - Why it works / failure mode: callers depend on the stable operation, never the variant. Fails when the encapsulated boundary leaks — callers branch on `isinstance` or reach past `radius` to `_radius`, and the barrier is gone.

- **Favor Composition Over Inheritance**: prefer composing objects from simpler parts to inheriting functionality from a base class; build complex objects by combining simpler ones.
  - When to use: the relationship is "has-a" rather than "is-a"; behavior must change at runtime; a subclass would inherit more than it needs.
  - How: instantiate the collaborator in `__init__` (`self.engine = Engine()`) or pass it in as a parameter. Python needs no explicit type declaration for this. Delegate: the outer class's method calls the inner object's method.
  - Why it works / failure mode: swapping a part means swapping one attribute, not rewriting a hierarchy. Benefits: flexibility (behavior changes at runtime), reusability, ease of maintenance (swap components without border effects). Failure mode: composing without injecting — hardcoding `Engine()` inside `__init__` gives composition but not loose coupling.

- **Program to Interfaces, Not Implementations**: an interface defines a contract for classes, specifying a set of methods that must be implemented; code against that contract rather than a concrete class.
  - When to use: more than one thing can fulfill a role (loggers, senders, parsers), or you need to mock a dependency in tests.
  - How: two techniques — **abstract base classes (ABCs)** via the `abc` module (`class X(ABC)` + `@abstractmethod`, subclass must implement) and **Protocols** via `typing` (Python 3.8+, structural duck typing, no inheritance required). Type-hint function parameters with the interface: `def log_message(logger: Logger, message: str)`.
  - Benefits: flexibility, maintainability, testability (interfaces are easy to mock).

- **Loose Coupling**: minimize dependencies between different parts of a program; components are independent and interact through well-defined interfaces.
  - When to use: any component that constructs its own collaborators, or that you cannot unit-test without real I/O.
  - How: two primary techniques — **dependency injection** (a component receives its dependencies from an external source rather than creating them) and the **observer pattern** (an object publishes state changes so others react without being tightly bound; covered in Ch 5).
  - Benefits: maintainability, extensibility, testability in isolation.

## Key Concepts
- **Polymorphism**: objects of different classes treated as objects of a common superclass, so a single interface represents different types.
- **Property technique**: Python's built-in conversion of attribute access into method calls via `@property` and `@attribute_name.setter`, giving encapsulation and validation without explicit getter/setter methods.
- **Abstract base class (ABC)**: a class from the `abc` module defining `@abstractmethod` methods that every concrete (non-abstract) subclass must implement — a nominal contract enforced at instantiation.
- **Protocol**: a `typing.Protocol` subclass declaring required methods; any class with matching methods satisfies it implicitly.
- **Structural duck typing**: type compatibility determined by an object's attributes/methods rather than its inheritance, and checked at compile time (unlike traditional runtime duck typing) so errors surface in the IDE.
- **'has-a' relationship**: the composition relation between a containing class and the classes whose instances it holds.
- **Dependency injection**: passing a component its collaborators from outside instead of letting it instantiate them.
- **Mypy**: the static type checker used to verify Protocol conformance (`mypy ch01/interfaces_bis.py`) before running the code.

## Mental Models
- **Think of an encapsulation boundary as a blast wall.** Ask "what will the next requirement change?" and put that answer on the far side of the wall. Everything else stays untouched.
- **Use "is-a" vs "has-a" as the inheritance test.** A `Car` is not an `Engine`, it *has* an `Engine` — so compose. Reach for inheritance only when the subtype genuinely substitutes for the base type.
- **Think of Protocols as "what an object can do", ABCs as "what an object is".** Use ABCs when you own the implementations and want the contract enforced at runtime; use Protocols when you must accept third-party or pre-existing classes that cannot inherit from your base.
- **Use dependency injection when you can't name the collaborator at write time.** If the constructor says `Sender()`, the class chose; if it says `def __init__(self, sender)`, the caller chose — and the test can choose too.

## Anti-patterns
- **Branching on variant type inside core logic**: `if method == "credit_card": ... elif method == "paypal": ...` — every new payment method edits the core processing code, and the risk of a regression grows with each variant.
- **Deep inheritance hierarchies for feature reuse**: tempting in OOP, but produces tightly coupled code that is hard to maintain and extend; a base-class change ripples to every descendant.
- **Public mutable attributes with no validation**: exposing `radius` directly means a negative value is accepted, and later adding validation is a breaking API change. The property technique lets `circle.radius = 15` keep working while validation is added underneath.
- **Depending on a concrete class in a function signature**: typing a parameter as `ConsoleLogger` instead of `Logger` welds the function to one implementation and makes it unmockable.
- **A class instantiating its own dependencies**: `MessageService` doing `self.sender = EmailSender()` internally forces a code change to switch to SMS and blocks isolated testing.

## Code Examples

```python
class PaymentBase:
    def __init__(self, amount: int):
        self.amount: int = amount

    def process_payment(self):
        pass


class CreditCard(PaymentBase):
    def process_payment(self):
        msg = f"Credit card payment: {self.amount}"
        print(msg)


class PayPal(PaymentBase):
    def process_payment(self):
        msg = f"PayPal payment: {self.amount}"
        print(msg)


if __name__ == "__main__":
    payments = [CreditCard(100), PayPal(200)]
    for payment in payments:
        payment.process_payment()
```
- **What it demonstrates**: Encapsulate What Varies via polymorphism (`ch01/encapsulate.py`) — the varying payment logic lives in subclasses; the loop is written once against the superclass.

```python
class Circle:
    def __init__(self, radius: int):
        self._radius: int = radius

    @property
    def radius(self):
        return self._radius

    @radius.setter
    def radius(self, value: int):
        if value < 0:
            raise ValueError("Radius cannot be negative!")
        self._radius = value


if __name__ == "__main__":
    circle = Circle(10)
    print(f"Initial radius: {circle.radius}")
    circle.radius = 15
    print(f"New radius: {circle.radius}")
```
- **What it demonstrates**: the property technique (`ch01/encapsulate_bis.py`) — `_radius` is hidden behind the `radius` property; validation can evolve and the underlying attribute can change without breaking callers.

```python
class Engine:
    def start(self):
        print("Engine started")


class Car:
    def __init__(self):
        self.engine = Engine()

    def start(self):
        self.engine.start()
        print("Car started")


if __name__ == "__main__":
    my_car = Car()
    my_car.start()
```
- **What it demonstrates**: Favor Composition Over Inheritance (`ch01/composition.py`) — `self.engine = Engine()` makes `Car` a composite; the engine can be swapped without altering `Car`.

```python
from typing import Protocol


class Logger(Protocol):
    def log(self, message: str):
        ...


class ConsoleLogger:
    def log(self, message: str):
        print(f"Console: {message}")


class FileLogger:
    def log(self, message: str):
        with open("log.txt", "a") as f:
            f.write(f"File: {message}\n")


def log_message(logger: Logger, message: str):
    logger.log(message)


if __name__ == "__main__":
    log_message(ConsoleLogger(), "A console log.")
    log_message(FileLogger(), "A file log.")
```
- **What it demonstrates**: Program to Interfaces using Protocols (`ch01/interfaces_bis.py`) — `ConsoleLogger` and `FileLogger` inherit from nothing yet satisfy `Logger`; verify with `mypy ch01/interfaces_bis.py` → `Success: no issues found in 1 source file`. The ABC version (`ch01/interfaces.py`) is identical except `class Logger(ABC)` with `@abstractmethod` and both loggers subclassing `Logger`.

## Reference Tables

| Principle | Primary technique(s) | Reach for it when |
|---|---|---|
| Encapsulate What Varies | Polymorphism; getters and setters; the property technique | A behavior has variants, or attribute access needs validation/side effects |
| Favor Composition Over Inheritance | 'has-a' — instantiate or accept collaborators in `__init__` | The relation is has-a, or behavior must change at runtime |
| Program to Interfaces, Not Implementations | ABCs (`abc`); Protocols (`typing`) | Multiple implementations fill one role; tests need mocks |
| Loose Coupling | Dependency injection; observer pattern (Ch 5) | A component creates its own dependencies or can't be tested alone |

| Interface technique | Mechanism | Enforcement | Use when |
|---|---|---|---|
| ABC | Subclass `ABC`, mark `@abstractmethod` | Runtime — concrete subclass must implement | You own the implementations; want the contract explicit and enforced |
| Protocol | Structural duck typing, no inheritance | Static — mypy / IDE, not enforced at runtime | Classes are third-party or pre-existing; you care what an object *does*, not what it *is* |

## Worked Example
**A message service, decoupled by dependency injection** (`ch01/loose_coupling.py`).

```python
class MessageService:
    def __init__(self, sender):
        self.sender = sender

    def send_message(self, message: str):
        self.sender.send(message)


class EmailSender:
    def send(self, message: str):
        print(f"Sending email: {message}")


class SMSSender:
    def send(self, message: str):
        print(f"Sending SMS: {message}")


if __name__ == "__main__":
    email_service = MessageService(EmailSender())
    email_service.send_message("Hello via Email")
    sms_service = MessageService(SMSSender())
    sms_service.send_message("Hello via SMS")
```

Output:
```
Sending email: Hello via Email
Sending SMS: Hello via SMS
```

The reasoning step: `MessageService` never names `EmailSender` or `SMSSender`. It is initialized by passing a sender object that has a `send` method, and `send_message` just delegates. The choice of transport moves to the call site, so switching mechanisms — or substituting a fake sender in a test — requires no change to `MessageService`. Three principles stack here: composition (`MessageService` *has-a* sender), programming to an implied interface (anything with `send`), and loose coupling via injection.

## Key Takeaways
1. Before writing a class, name what will vary and give it its own class or property — that is the whole of Encapsulate What Varies.
2. Replace variant `if`/`elif` chains with subclasses overriding a common method; the caller loop then never changes.
3. Use `@property` / `@x.setter` instead of hand-written `get_x`/`set_x` — same encapsulation and validation, more aligned with Python's design philosophy.
4. Default to composition ("has-a", set in `__init__`); reserve inheritance for genuine "is-a" substitution.
5. Type-hint parameters with the interface (`logger: Logger`), never with a concrete class — that single habit buys flexibility, maintainability, and testability.
6. Pick ABCs when you want the contract enforced at runtime over classes you own; pick Protocols when you need structural duck typing across classes that can't inherit from you. Run `mypy` to make Protocol conformance a real check.
7. Never let a class construct its own collaborators — inject them, and the class becomes swappable and testable for free.

## Connects To
- **Ch 2 (SOLID principles)**: the next layer up. Encapsulate What Varies plus Program to Interfaces are the mechanics behind the Open/Closed and Dependency Inversion principles.
- **Ch 5 (Behavioral Design Patterns)**: the observer pattern, the second named loose-coupling technique, is developed there; the strategy pattern is the direct pattern-form of the polymorphic encapsulation shown here.
- **Creational patterns (Factory, Builder)**: they encapsulate what varies in object *construction*, complementing the behavioral encapsulation of this chapter.
- **Unit testing / mocking**: interfaces and dependency injection are precisely what make a component testable in isolation — inject a fake `sender` or `logger`.
- **Mypy / static typing**: Protocols shift duck typing from a runtime gamble to a compile-time check surfaced in the IDE.
