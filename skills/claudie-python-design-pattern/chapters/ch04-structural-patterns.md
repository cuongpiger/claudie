# Chapter 4: Structural Design Patterns

## Core Idea

Structural patterns compose objects to produce new functionality. Creational patterns answer "how does this object get made?"; structural patterns answer "how do these objects fit together?" — wiring incompatible interfaces, layering behavior on without inheritance, hiding complexity behind one entry point, sharing memory across near-identical objects, and interposing a stand-in between client and target.

Six patterns, three jobs: make things fit (adapter, bridge), make things simpler or cheaper (facade, flyweight), make things do more (decorator, proxy).

## Frameworks Introduced

- **Adapter**: Two interfaces are incompatible and you cannot change either. Write a layer that translates. If the caller expects `function_a()` but you only have `function_b()`, the adapter converts `function_b()` to `function_a()`.
  - When to use: one side is *foreign* (no source access) or *old/legacy* (refactoring impractical). Applied after the fact, without touching either implementation. Caution — it can introduce side effects hard to debug.
  - How: a wrapper class holding the *adaptee* and exposing the expected method names; or a generic `Adapter` that injects an `adapted_methods` dict straight into `self.__dict__`.
  - Real-world example: EU-to-UK/USA plug adapter; USB adapters. In software: `zope.interface` (Zope Toolkit), used by Pyramid and Plone — the pre-ABC, pre-Protocol answer to interfaces in Python.

- **Decorator**: Add responsibilities to an object dynamically and transparently, without affecting other objects and without inheritance.
  - When to use: cross-cutting concerns — data validation, caching, logging, monitoring, debugging, business rules, encryption. Anything generic that applies across many parts of the app. Also GUI toolkits: borders, shadows, colors, scrolling on individual widgets.
  - How: Python's built-in decorator feature — a callable taking `func_in` and returning `func_out`, applied via the `@name` decoration line. Use `functools.wraps()` to preserve `__name__` and `__doc__`.
  - Real-world example: silencer on a gun, different camera lenses. In software: Django decorators restricting view access, controlling caching/compression per view, registering event subscribers, enforcing permissions.
  - **Precision point**: there is *no one-to-one relationship* between the decorator pattern and Python's `@decorator` syntax. Python decorators do far more than the pattern; implementing the decorator pattern is just one of their uses. The syntax is syntactic sugar — you can call the decorator manually instead.

- **Bridge**: Decouple an abstraction from its implementation so both vary independently. Unlike adapter, bridge is designed **up-front**, not retrofitted.
  - When to use: you want to share one implementation across multiple objects. Instead of writing several specialized classes each duplicating everything, define one abstraction that applies to all, plus a separate interface for the varying objects.
  - How: the abstraction class holds a reference (`_imp`) to an *Implementor* object satisfying an interface — declared with `typing.Protocol`. All abstraction methods delegate through `_imp`.
  - Real-world example: infoproducts in the digital economy — same information delivered as PDF, ebook, video series, course, newsletter. In software: device drivers (OS defines the interface, vendors implement it) and payment gateways (different implementations, consistent checkout).

- **Facade**: Hide internal complexity; expose only what the client needs through a simplified interface. An abstraction layer over an existing complex system.
  - When to use: give a complex system a single simple entry point; shield client code so internal changes require no client modifications; one facade per layer in a layered system, layers talking only through facades — promotes loose coupling.
  - How: one class whose `__init__()` constructs all the internal subsystem objects and whose methods (`start()`, plus thin wrappers) sequence them correctly.
  - Real-world example: calling a company and reaching customer service, who routes you; a car/motorcycle ignition key; booting a computer with one button. In software: `django-oscar-datacash` offers a facade class over its fine-grained DataCash gateway API; the **Requests** library is a facade over HTTP sockets and methods.

- **Flyweight**: Minimize memory and improve performance by sharing data between similar objects. A flyweight holds state-independent, immutable (**intrinsic**) data. State-dependent, mutable (**extrinsic**) data must not live in the flyweight — the client passes it in explicitly.
  - When to use: GoF's three requirements — (1) the app uses a large number of objects; (2) storing/rendering them is too expensive, and removing mutable state collapses many distinct objects into few shared ones; (3) **object identity is not important**, because sharing makes identity comparisons fail.
  - How: a class-level `pool` dict plus `__new__()`, which returns the pooled object if one exists for that key, otherwise creates, pools, and returns it. Mutable data is a parameter of `render()`.
  - Real-world example: a bookstore's "new and popular" shelf as a cache. In games: Counter-Strike soldiers share representation and behavior (jump, duck) but not weapons, health, location. In software: the Exaile music player reuses track objects identified by the same URL.
  - **Memoization vs. flyweight**: memoization is a general optimization caching computed results, paradigm-agnostic, applicable to functions and methods. Flyweight is OOP-specific and about sharing *object data*.

- **Proxy**: A surrogate object that performs an important action before access reaches the real object.
  - When to use: distributed systems where object location should be transparent; performance problems from eager creation of expensive objects; privilege checks on sensitive data (e.g. medical records); moving thread-safety burden off client code.
  - How: an object implementing the same interface (`ABC` or `Protocol`) as the real subject and holding a reference to it; or a **descriptor** class used as a decorator, overriding `__get__()`.
  - Real-world example: chip debit/credit card requiring physical card + PIN (protection proxy); a bank check giving access to an account (remote proxy). In software: Python's `weakref.proxy()` returns a smart proxy — weak references are the recommended way to add reference counting. ORMs in Django/Flask/FastAPI are remote proxies to a relational database anywhere, local or remote.

  Four variants:
  - **Virtual proxy**: lazy initialization — defers creation of a computationally expensive object until actually needed.
  - **Protection/protective proxy**: controls access to a sensitive object.
  - **Remote proxy**: local representation of an object that really lives in a different address space (network server).
  - **Smart (reference) proxy**: performs extra actions on access — reference counting, thread-safety checks.

## Key Concepts

- **Adaptee**: the object with the wrong interface that an adapter wraps.
- **Implementor**: in bridge, the interface the abstraction delegates to (`ResourceContentFetcher`).
- **Intrinsic vs. extrinsic state**: the flyweight split. Intrinsic = shared, immutable, in the flyweight. Extrinsic = per-object, mutable, passed by the client.
- **Descriptor**: the recommended Python mechanism for overriding attribute access — `__get__()`, `__set__()`, `__delete__()`. You override only the ones you need. `LazyProperty` overrides `__get__()` only, and uses `setattr()` to *replace itself with the computed value* — so the property is lazily loaded *and* settable only once.
- **Cross-cutting concern**: any part of an application generic enough to apply to many other parts. Doesn't fit the OOP paradigm well — decorators do.
- **Lazy initialization levels**: instance-level (each object gets its own copy) vs. class/module-level (all instances share one lazily-initialized property).
- **`Protocol` vs. `ABC`**: both used in this chapter for interfaces. `Protocol` for structural typing (bridge Implementor, `DBConnectionInterface`); `ABC` + `@abstractmethod` when you want to forbid direct instantiation and force overrides (facade `Server`, `RemoteServiceInterface`).

## Mental Models

**Adapter vs. decorator vs. proxy** — all three wrap one object, so tell them apart by *what changes*:

| | Interface | Behavior | Timing |
|---|---|---|---|
| Adapter | **Changes** — that's the point | Same | Retrofitted, after the fact |
| Decorator | Same | **Adds** responsibilities | Applied at decoration |
| Proxy | Same | Same (adds *control*: access, laziness, location, counting) | Designed with the subject |

Say it out loud: adapter makes a square peg fit a round hole. Decorator makes the peg *do more*. Proxy decides *whether, when, and how* you touch the peg at all.

**Bridge vs. adapter** — same shape, opposite intent and timing. Adapter is reactive: two unrelated classes already exist, make them work together. Bridge is proactive: designed up-front so abstraction and implementation can vary independently from day one. If you had a choice when you designed it, it's a bridge. If you didn't, it's an adapter.

**Facade vs. proxy** — facade simplifies *many* objects into one interface; proxy stands in front of *one* object with the *same* interface.

**Flyweight is a cache with an OOP shape** — and the price of admission is giving up `id()` comparisons.

## Anti-patterns

- Reaching for adapter when you *can* fix the interface — it introduces hard-to-debug side effects. Use with caution; it's a pragmatic last resort, not a default.
- Hand-rolling memoization inline per function — every new function drags along a new module-level `fib_cache` / `sum_cache` dict and extra branching. The module becomes unnecessarily complex. Decorate instead.
- Dropping `@functools.wraps(func)` from a decorator — the decorated function loses its `__name__` and `__doc__`.
- Putting mutable/extrinsic state inside a flyweight — it can't be shared, so the whole optimization collapses.
- Relying on object identity anywhere near flyweights — two objects of the same family *are* the same object.
- The protection-proxy security holes the authors flag explicitly: storing passwords in source code, storing them in clear text, using weak (MD5) or custom encryption. Also — nothing stops client code instantiating `SensitiveInfo` directly and bypassing the proxy entirely; use `abc` to forbid direct instantiation.

## Code Examples

```python
class Adapter:
    def __init__(self, obj, adapted_methods):
        self.obj = obj
        self.__dict__.update(adapted_methods)

    def __str__(self):
        return str(self.obj)
```
- **What it demonstrates**: generic adapter — `self.__dict__.update()` grafts renamed bound methods onto the wrapper, unifying many foreign interfaces into one.

```python
import functools


def memoize(func):
    cache = {}

    @functools.wraps(func)
    def memoizer(*args):
        if args not in cache:
            cache[args] = func(*args)
        return cache[args]

    return memoizer
```
- **What it demonstrates**: decorator pattern via Python's decorator feature — closure-held cache, `*args` for arbitrary signatures, `wraps` preserving metadata.

```python
class ResourceContentFetcher(Protocol):
    def fetch(self, path: str) -> str:
        ...


class ResourceContent:
    def __init__(self, imp: ResourceContentFetcher):
        self._imp = imp

    def get_content(self, path):
        return self._imp.fetch(path)
```
- **What it demonstrates**: bridge — abstraction holds `_imp`, a Protocol-typed Implementor; `URLFetcher` and `LocalFileFetcher` swap in freely.

```python
class Car:
    pool = dict()

    def __new__(cls, car_type):
        obj = cls.pool.get(car_type, None)
        if not obj:
            obj = object.__new__(cls)
            cls.pool[car_type] = obj
            obj.car_type = car_type
        return obj

    def render(self, color, x, y):
        type = self.car_type
        msg = f"render a {color} {type.name} car at ({x}, {y})"
        print(msg)
```
- **What it demonstrates**: flyweight — `__new__()` intercepts construction and returns a pooled instance; extrinsic `color`, `x`, `y` are arguments to `render()`, not attributes. 18 cars rendered, 3 created.

```python
class LazyProperty:
    def __init__(self, method):
        self.method = method
        self.method_name = method.__name__

    def __get__(self, obj, cls):
        if not obj:
            return None
        value = self.method(obj)
        setattr(obj, self.method_name, value)
        return value
```
- **What it demonstrates**: virtual proxy as a descriptor — `__get__()` computes once then `setattr()`s the value over the descriptor's own name, so subsequent access hits a plain attribute.

## Reference Tables

| Pattern | Intent | When to use | Python mechanism |
|---|---|---|---|
| Adapter | Make incompatible interfaces compatible | Foreign (no source) or legacy (impractical to refactor) code | Wrapper class delegating to adaptee; `self.__dict__.update(adapted_methods)` |
| Decorator | Add responsibilities dynamically and transparently | Cross-cutting concerns: caching, logging, validation, auth, encryption | `@decorator` syntax + `functools.wraps` |
| Bridge | Decouple abstraction from implementation up-front | Share one implementation across many objects; drivers, gateways, themes | `Protocol` Implementor held as `_imp`, delegation |
| Facade | Hide internal complexity behind a simple entry point | Complex subsystem; layered systems (one facade per layer) | One class constructing subsystem objects; `start()` + wrapper methods |
| Flyweight | Share intrinsic data to cut memory and improve speed | Very many expensive objects; identity irrelevant | Class-attribute `pool` dict + `__new__()`; extrinsic state as method args |
| Proxy | Interpose a surrogate before the real object | Laziness, security, remoting, reference counting | Same-interface class (`ABC`/`Protocol`) holding the subject; or a descriptor |

| Proxy variant | Distinguishing job | Example in chapter |
|---|---|---|
| Virtual | Lazy initialization — defer expensive creation to first use | `LazyProperty` descriptor loading `Test._resource` |
| Protection | Gate access to a sensitive object | `Info` guarding `SensitiveInfo.add()` behind a secret |
| Remote | Local stand-in for an object in another address space | `ProxyService` forwarding to `RemoteService` |
| Smart | Extra bookkeeping on access — ref counting, thread safety | `SmartProxy` counting refs, closing `DBConnection` at zero |

## Worked Example

**Adapter — adapting a legacy payment system** (`ch04/adapter/adapt_legacy.py`).

The situation: existing client code calls `make_payment()`. A new gateway exposes `execute_payment()`. You can change neither the client nor the gateway.

```python
class OldPaymentSystem:
    def __init__(self, currency):
        self.currency = currency

    def make_payment(self, amount):
        print(f"[OLD] Pay {amount} {self.currency}")


class NewPaymentGateway:
    def __init__(self, currency):
        self.currency = currency

    def execute_payment(self, amount):
        print(f"Execute payment of {amount} {self.currency}")


class PaymentAdapter:
    def __init__(self, system):
        self.system = system

    def make_payment(self, amount):
        self.system.execute_payment(amount)


def main():
    old_system = OldPaymentSystem("euro")
    print(old_system)
    new_system = NewPaymentGateway("euro")
    print(new_system)
    adapter = PaymentAdapter(new_system)
    adapter.make_payment(100)
```

Output:

```
<__main__.OldPaymentSystem object at 0x10ee58fd0>
<__main__.NewPaymentGateway object at 0x10ee58f70>
Execute payment of 100 euro
```

Reasoning, step by step:

1. Identify the **expected** interface — `make_payment(amount)`, dictated by the client, not by you.
2. Identify the **adaptee** — `NewPaymentGateway`, whose method is named differently.
3. Store the adaptee on the adapter (`self.system`), don't subclass it. Composition keeps the adaptee untouched and swappable.
4. Expose the *expected* method name on the adapter; inside it, call the adaptee's real method.
5. The client now holds a `PaymentAdapter` and calls `make_payment(100)` — same call site, new gateway underneath. Zero edits to either original class.

The unified-interface variant scales this: a generic `Adapter` plus an `adapted_methods` dict lets `Musician.play()` and `Dancer.dance()` both answer to `organize_event()`, while a compatible `Club` object passes through unwrapped.

## Key Takeaways

- Adapter is retrofitted and changes the interface; bridge is designed up-front and keeps abstraction and implementation varying independently.
- Python's `@decorator` feature is a superset of the decorator pattern, not the same thing — the pattern is one use of the feature.
- Decorators keep functions as clean as the naive version while delivering the memoized version's performance; that maintainability win is the real payoff, not just the milliseconds.
- Facade encapsulates complexity without removing functionality — the subsystem keeps everything, the client just doesn't see it.
- Flyweight's contract: split intrinsic from extrinsic, and accept that `id()` comparisons stop being meaningful.
- Proxy is one shape with four jobs. Name the job (lazy / guard / remote / count) before writing the class, and the implementation follows.
- Prefer `Protocol` for structural interfaces, `ABC` + `@abstractmethod` when you must forbid direct instantiation.

## Connects To

- **Chapter 3 (Creational patterns)**: flyweight's `__new__()` pool is object-creation control, the same lever singleton pulls. Proxy often fronts an object a factory built.
- **Chapter 5 (Behavioral patterns)**: next chapter — object interconnection and algorithms, where structure gives way to interaction.
- **Earlier chapters**: `@abstractmethod` and `@property` were already-used decorators; this chapter shows how to write your own.
- **Chapter 1**: technical requirements are unchanged.
