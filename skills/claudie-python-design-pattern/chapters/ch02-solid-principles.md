# Chapter 2: SOLID Principles

## Core Idea

SOLID — coined by Robert C. Martin — is five design principles that make software understandable, flexible, and maintainable. They extend the foundational principles of Chapter 1. In Python, four of the five are best expressed with `typing.Protocol` (structural typing) rather than inheritance: define small interfaces, let classes conform implicitly, and depend on the interface rather than the concrete class.

Nothing obliges you to follow them. Knowing them and thinking about your code with them in mind improves the code base over time.

## Frameworks Introduced

- **Single Responsibility Principle (SRP)**: A class should have only one reason to exist and be responsible for only one aspect of the functionality — one job, encapsulated in that class.
  - When to use: whenever a class both *computes/represents* something and *does I/O* with it (generate + save, parse + persist, model + render).
  - How: split into focused classes; the second class takes the first as a constructor argument (composition), not as a base class.
  - Why it works: each class has a single reason to change, so modifications don't cause unintended side effects elsewhere. Not about fewer lines of code.

- **Open-Closed Principle (OCP)**: Software entities (classes, modules) should be open for extension but closed for modification. Once defined and implemented, an entity should not be changed to add new functionality — extend it through inheritance or interfaces.
  - When to use: any dispatch function that grows an `if isinstance(...)` branch per new type.
  - How: define a `Protocol` for the operation, let each type implement it, and reduce the dispatcher to a single delegating call.
  - Why it works: modifying an entity risks breaking other code relying on it. Adding a type touches only new code, so existing tested behavior stays stable.

- **Liskov Substitution Principle (LSP)**: If a program uses objects of a superclass, substituting them with objects of a subclass must not change the correctness and expected behavior of the program.
  - When to use: every time you add a subclass that "can't do" something the parent promises.
  - How: raise the abstraction of the parent method until every subclass can honor it (`fly()` → `move()`), then specialize per subclass.
  - Failure mode: a subclass that overrides a method to do the opposite, do nothing, or raise — the caller written against the superclass silently breaks.

- **Interface Segregation Principle (ISP)**: A class should not be forced to implement interfaces it does not use. Prefer smaller, more specific interfaces over broad, general-purpose ones.
  - When to use: a "does-everything" base class where a specialized subtype only needs one method.
  - How: one `Protocol` per capability (`Printer`, `Scanner`, `Fax`); classes implement only what they need; functions type-hint the narrowest protocol they actually call.
  - Why it works: this is exactly where protocols are the natural answer — each interface exists to do one thing. Buys modularity, readability, fewer side effects, easier refactoring and testing.

- **Dependency Inversion Principle (DIP)**: High-level modules should not depend directly on low-level modules. Both should depend on abstractions or interfaces.
  - When to use: a high-level class instantiating a concrete collaborator inside `__init__`.
  - How: define a `Protocol` for the collaborator's role and inject an implementation through the constructor.
  - Why it works: it is the loose coupling principle from Chapter 1 applied to dependencies — high-level code stays isolated from low-level implementation details, so either side can change independently.

## Key Concepts

- **Reason to change** — the unit SRP measures, not line count. Two reasons to change = two classes.
- **`typing.Protocol` as the SOLID enabler** — structural typing means a class conforms by having the methods; no base class, no registration. `SimplePrinter` satisfies `Printer` without importing anything.
- **Ellipsis body (`...`)** — protocol methods declare shape only; no implementation.
- **Composition over inheritance for SRP** — `ReportSaver` holds a `Report`, it does not subclass it.
- **Type hints as the contract** — `def calculate_area(shape: Shape) -> float` and `def do_the_print(printer: Printer)` document exactly what the function requires.
- **Constructor injection** — `Notification(sender=email)` is the DIP mechanism in this chapter.

## Mental Models

- **Two verbs, two classes** — if you can describe the class as "generates X *and* saves X", it violates SRP.
- **`isinstance` chain = OCP alarm** — every new type forcing an edit to the same function means the entity is open for modification.
- **The Penguin test** — if a subclass has to lie about the parent's promise, the parent's method is named at the wrong abstraction level. Move up (`fly` → `move`) rather than override with a contradiction.
- **Fat interface, thin implementer** — a class implementing methods it will never call is an ISP violation waiting to break.
- **Point the arrow at the abstraction** — high-level and low-level both depend on the `Protocol`; neither depends on the other.

## Anti-patterns

- `Report` class that both `generate()`s content and `save_to_file()`s it (SRP).
- `calculate_area(shape)` doing `if isinstance(shape, Rectangle): ...` — every new shape edits this function (OCP).
- `class Penguin(Bird)` overriding `fly()` to `print("I can't fly")`; `make_bird_fly(penguin)` then behaves incorrectly (LSP) — the book ships this as `ch02/lsp_violation.py`.
- `AllInOnePrinter` as the only base, forcing `SimplePrinter` to carry `scan_document` and `fax_document` (ISP).
- `Notification.__init__` doing `self.email = Email()` — high-level module hardwired to a low-level class (DIP).

## Code Examples

```python
class Report:
    def __init__(self, content: str):
        self.content: str = content

    def generate(self):
        print(f"Report content: {self.content}")


class ReportSaver:
    def __init__(self, report: Report):
        self.report: Report = report

    def save_to_file(self, filename: str):
        with open(filename, "w") as file:
            file.write(self.report.content)
```

- **What it demonstrates**: SRP — generation and persistence split into two classes wired by composition (`ch02/srp.py`).

```python
import math
from typing import Protocol


class Shape(Protocol):
    def area(self) -> float: ...


class Rectangle:
    def __init__(self, width: float, height: float):
        self.width: float = width
        self.height: float = height

    def area(self) -> float:
        return self.width * self.height


class Circle:
    def __init__(self, radius: float):
        self.radius: float = radius

    def area(self) -> float:
        return math.pi * (self.radius**2)


def calculate_area(shape: Shape) -> float:
    return shape.area()
```

- **What it demonstrates**: OCP — a new shape is added without touching `calculate_area` (`ch02/ocp.py`).

```python
class Bird:
    def move(self):
        print("I'm moving")


class FlyingBird(Bird):
    def move(self):
        print("I'm flying")


class FlightlessBird(Bird):
    def move(self):
        print("I'm walking")


def make_bird_move(bird):
    bird.move()
```

- **What it demonstrates**: LSP — `FlyingBird` and `FlightlessBird` are both usable wherever `Bird` is; output is `I'm moving / I'm flying / I'm walking` (`ch02/lsp.py`).

```python
from typing import Protocol


class Printer(Protocol):
    def print_document(self): ...


class Scanner(Protocol):
    def scan_document(self): ...


class Fax(Protocol):
    def fax_document(self): ...


class SimplePrinter:
    def print_document(self):
        print("Simply Printing")


def do_the_print(printer: Printer):
    printer.print_document()
```

- **What it demonstrates**: ISP — one protocol per capability; `SimplePrinter` implements only `print_document` yet passes to `do_the_print` (`ch02/isp.py`).

```python
from typing import Protocol


class MessageSender(Protocol):
    def send(self, message: str): ...


class Email:
    def send(self, message: str):
        print(f"Sending email: {message}")


class Notification:
    def __init__(self, sender: MessageSender):
        self.sender = sender

    def send(self, message: str):
        self.sender.send(message)


if __name__ == "__main__":
    email = Email()
    notif = Notification(sender=email)
    notif.send(message="This is the message.")
```

- **What it demonstrates**: DIP — both `Notification` and `Email` depend on the `MessageSender` abstraction; the sender is injected (`ch02/dip.py`).

## Reference Tables

| Acronym | Full name | One-line rule | Smell that signals violation |
|---|---|---|---|
| SRP | Single Responsibility Principle | A class has one job and one reason to change. | Class name joined by "and"; a class that both builds data and writes it to disk. |
| OCP | Open-Closed Principle | Open for extension, closed for modification. | `if isinstance(...)` / type-switch that grows with every new type. |
| LSP | Liskov Substitution Principle | Subclass objects must be usable wherever superclass objects are, without changing correctness. | Override that contradicts, no-ops, or raises on the parent's promise (`Penguin.fly`). |
| ISP | Interface Segregation Principle | Don't force a class to implement methods it doesn't use. | Fat base class; a subtype inheriting `scan`/`fax` it will never call. |
| DIP | Dependency Inversion Principle | High-level and low-level modules both depend on abstractions. | `self.x = ConcreteThing()` inside a high-level class's `__init__`. |

## Worked Example

**OCP: shapes and `calculate_area`, end to end.**

Start with the naive version (hypothetical — deliberately not shipped as example code):

```python
class Rectangle:
    def __init__(self, width: float, height: float):
        self.width: float = width
        self.height: float = height


def calculate_area(shape) -> float:
    if isinstance(shape, Rectangle):
        return shape.width * shape.height
```

*Reasoning step 1* — adding a circle means editing `calculate_area`. You keep coming back to change that code, and every change means more testing to avoid bugs. The entity is open for modification.

*Step 2* — invert the direction of knowledge. Instead of the function knowing every shape, each shape knows its own area. Declare that contract as a protocol:

```python
class Shape(Protocol):
    def area(self) -> float: ...
```

*Step 3* — `Rectangle` and `Circle` conform structurally by implementing `area()`. Neither inherits `Shape`; no registration needed.

*Step 4* — the dispatcher collapses to one delegating line, permanently closed for modification:

```python
def calculate_area(shape: Shape) -> float:
    return shape.area()
```

*Step 5* — verify:

```python
if __name__ == "__main__":
    rect = Rectangle(12, 8)
    rect_area = calculate_area(rect)
    print(f"Rectangle area: {rect_area}")
    circ = Circle(6.5)
    circ_area = calculate_area(circ)
    print(f"Circle area: {circ_area:.2f}")
```

`python ch02/ocp.py` prints `Rectangle area: 96` and `Circle area: 132.73`. The win: a new shape type was added without modifying `calculate_area`.

## Key Takeaways

- Split on *reasons to change*, not on file size (SRP).
- Replace type-switching with polymorphism behind a protocol; growth becomes new files, not edits (OCP).
- Name parent methods at the abstraction level every subclass can honor (LSP).
- Many small protocols beat one fat interface; type-hint the narrowest one a function needs (ISP).
- Inject collaborators through the constructor, typed as a protocol (DIP).
- In Python, `typing.Protocol` is the workhorse for OCP, ISP, and DIP alike — structural conformance, no inheritance tax.

## Connects To

- **Chapter 1, Foundational Design Principles** — *program to interfaces, not implementations* (ABCs, protocols) underlies OCP/ISP/DIP; *loose coupling* is what DIP operationalizes.
- **Chapter 3 onward** — SOLID is the substrate the GoF-style design patterns are built on; patterns are recurring shapes these principles push you toward.
- Composition over inheritance: SRP's `ReportSaver`/`Report` and DIP's injected `MessageSender` are both composition solutions.
