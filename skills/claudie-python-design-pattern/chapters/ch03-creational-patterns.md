# Chapter 3: Creational Design Patterns

## Core Idea

Creational patterns deal with object creation. Their goal: provide better alternatives for situations where direct object creation — which in Python happens inside `__init__()` — is not convenient.

Reach for one when direct instantiation causes a concrete problem: creation code scattered across the codebase (untrackable), client coupled to a specific class, construction requiring multiple ordered steps, initialization too expensive to repeat, or a need for exactly one instance.

Python caveat that runs through the whole chapter: dynamic typing, first-class functions, default/keyword arguments, and built-in cloning already solve much of what these patterns solve in Java/C++. Apply the pattern when the problem is real, not by reflex.

## Frameworks Introduced

- **Factory method**: A client asks for an object without knowing where it comes from (which class generates it). Centralizes creation so objects are trackable, and decouples the code that creates an object from the code that uses it.
  - When to use: you can't track created objects because creation code sits in many places instead of one function; you want creation decoupled from usage so changes to the function need no changes in callers; you want to improve performance/memory by creating objects only when necessary (direct instantiation allocates fresh memory every time — `id(a) == id(b)` is `False`). Multiple factory methods is normal practice — each groups similar creations (DB connectors: MySQL/SQLite; shapes: circle/triangle).
  - How: one function taking a parameter that describes what you want, returning the right instance. Dispatch on that parameter (file extension → `JSONDataExtractor` / `XMLDataExtractor`), raise `ValueError` for unsupported input. No factory class needed — a plain function is enough in Python.
  - Real-world example: a plastic toy construction kit — same molding material, different molds produce different toys. In software: Django's `forms` module creating form fields (`CharField`, `EmailField`) customized by attributes like `max_length` and `required`.

- **Abstract factory**: A generalization of the factory method — a logical group of factory methods, each responsible for generating a different kind of object, together producing a family of related objects.
  - When to use: same benefits as factory method (trackable creation, decoupling, memory/performance), applied when you need a whole consistent family; when the active family must be swappable at runtime with no code changes.
  - How: one class per family exposing generically named creation methods (`make_character()`, `make_obstacle()`). A consumer class (`GameEnvironment`) accepts the factory as input and calls those methods. Swap the factory object, and the entire family swaps — the consumer is untouched.
  - Real-world example: car manufacturing — the same machinery stamps parts (doors, panels, hoods, fenders, mirrors) for different car models; the assembled model is configurable and easy to change at any time. In software: `factory_boy` and `model_bakery` creating Django model instances in tests.

- **Builder**: Separates the construction of a complex object from its representation, so the same construction procedure can produce several different representations. Use it when the object is composed of multiple parts assembled step by step, and is not complete until all parts are created.
  - When to use: an object with numerous possible configurations — typically a class with multiple constructors of varying parameter counts, which is confusing and error-prone; or when construction is more than setting initial values (parameter validation, setting up data structures, calls to external services).
  - How: a minimal end-product class (`Pizza`) that mostly holds defaults; one builder class per representation, each exposing the same step methods (`prepare_dough()`, `add_sauce()`, `add_topping()`, `bake()`) with its own details; a **director** (`Waiter`) whose `construct_pizza(builder)` runs the steps in the correct order and whose `pizza` property hands back the finished product when the client asks.
  - Real-world example: a fast-food restaurant — the same procedure prepares any burger and its packaging; classic vs cheeseburger differ in representation, not construction procedure. The cashier is the director, the crew member is the builder. In software: `django-query-builder`, building SQL queries dynamically from simple to very complex.

- **Prototype**: Create new objects by copying existing ones instead of building from scratch. Use it when initializing an object is more expensive or complex than copying one.
  - When to use: an existing object must stay untouched while you need an exact copy with a few parts changed; duplicating an object populated from a database with references to other database-backed objects, where cloning by re-querying costs multiple queries.
  - How: in its simplest version just a `clone()` function taking an object and returning a copy — in Python, `copy.deepcopy()`. The fuller version adds a `Prototype` class with a `registry` dict plus `register()` / `unregister()`, and a `clone(identifier, **attrs)` that deep-copies the registered object then applies overrides via `setattr(obj, key, attrs[key])`. Verify with `id()` — clone address must differ from the original.
  - Real-world example: cloning a plant by taking a cutting — you don't grow from seed, you copy an existing plant. Many Python applications use it, but rarely name it "prototype" since cloning is built into the language.

- **Singleton**: Restricts instantiation of a class to one object — useful when you need one object to coordinate actions for the system. Requires mechanisms preventing both instantiation more than once and cloning.
  - When to use: you need exactly one object, or an object maintaining global state; controlling concurrent access to a shared resource (a class managing the database connection); a transversal service reachable from different parts of the application or by different users (the core class of a logging system).
  - How: a `SingletonType` metaclass holding an `_instances` dict and overriding `__call__()` to return the cached instance if present, otherwise build via `super().__call__()` and cache. The target class declares `class URLFetcher(metaclass=SingletonType)`. Test with `URLFetcher() is URLFetcher()` — `True` means singleton.
  - Real-world example: the captain of a ship — one person in charge, receiving the requests that need a decision. Also the office printer spooler, coordinating print jobs through a single point to avoid conflicts.

- **Object pool**: Reuse existing objects instead of creating new ones on demand. Use when initializing a new object is costly in system resources or time.
  - When to use: resource initialization is expensive or time-consuming in CPU cycles, memory, or network bandwidth. Example: bullet objects in a shooting game — creating a new bullet per shot is resource-intensive, so reuse a pool of them.
  - How: a pool class holding `_available` and `_in_use` lists. `acquire_car()` creates a new object only when `_available` is empty, then pops from `_available`, appends to `_in_use`, flags `in_use = True`, and returns it. `release_car(car)` clears the flag, removes from `_in_use`, and appends back to `_available`.
  - Real-world example: a car rental service — renting doesn't manufacture a new car, it hands one from the pool of available cars, which returns to the pool afterwards. Also a public swimming pool: water is treated and reused rather than refilled per swimmer.

## Key Concepts

- **Director**: the builder-only role that knows the step order. The client asks the director for the finished object; the director never knows the concrete representation.
- **Generic creation-method names**: `make_character()` / `make_obstacle()` rather than `make_frog()` — genericity is what makes the active abstract factory swappable at runtime.
- **Minimal end product**: with builder, the product class holds defaults and little else, since it is never instantiated directly. Exception: `prepare_dough()` lives on `Pizza`, both to show the product may carry some responsibility and to promote code reuse through composition.
- **Identity as the test**: `id()` and `is` are the chapter's verification tools — different addresses prove a real clone (prototype), same object proves a singleton.
- **`setattr(obj, attr, val)` idiom**: the Python way to absorb `**kwargs` into arbitrary instance attributes — used both to build `Website` objects and to override attributes on a clone.
- **`vars(obj)`**: returns the object's `__dict__` (data attributes and methods); handy for `__str__` and debugging. Not all objects have it — built-in types like lists and dicts do not.
- **Metaclass**: a class of a class, defining how a class behaves. The singleton hook lives in its `__call__()`.
- **Uniform interface ≠ uniform output**: `JSONDataExtractor` and `XMLDataExtractor` share an interface, but `parsed_data` returns a list in one case and a tree in the other. Different client code is still required — expecting one code path for all extractors is unrealistic without a common data mapping.

## Mental Models

- **Factory = one step, returns immediately. Builder = many steps, client asks the director for the result when it needs it.** That is the whole distinction.
- **Abstract factory = a family switch.** Choosing `FrogWorld` vs `WizardWorld` swaps hero *and* obstacle consistently; you can never end up with a wizard fighting a bug.
- **Prototype = cutting from a plant, not a seed.** Copy the expensive-to-grow thing, then tweak the copy.
- **Object pool = rental, not manufacture.** Objects are borrowed and returned, never destroyed.
- **Python's ladder before the pattern:** a plain function, then default/keyword arguments, then a module-level global — reach for a factory class, metaclass, or director only after those fail.

## Anti-patterns

**Should you use the singleton pattern?** In the Python programmer community, singleton is considered an **anti-pattern**. Even though the `URLFetcher` implementation works, two problems stand out on re-reading it: the techniques used are rather advanced and not easy to explain to a beginner; and reading `SingletonType` does not make it immediately obvious that it provides a metaclass for a singleton — only the name suggests it.

The verdict: prefer a **module-level global object**. Python modules act as natural namespaces holding variables, functions, and classes, which makes them ideal for organizing and sharing global resources. Brandon Rhodes' **Global Object Pattern** (https://python-patterns.guide/python/module-globals/) achieves the same result without complex instantiation processes or forcing a class to have only one instance.

**Should you use the factory method pattern?** The main critique veteran Python developers express is that it is over-engineered or unnecessarily complex for many use cases. Python's dynamic typing and first-class functions usually allow simpler solutions; you can create objects directly where you need them without separate factory classes or functions, which is more readable and more Pythonic — *simple is better than complex*. Default and keyword arguments also make constructors easy to extend in a backward-compatible way, reducing the need for separate factory methods. The pattern is well established in statically typed languages such as Java or C++, but is often too cumbersome or verbose for Python.

Other traps:
- Assuming a shared interface means shared client code (the JSON/XML `parsed_data` mismatch).
- Building a builder for an object that a single constructor call already handles — the builder pays off only with numerous configurations or genuinely complex construction.
- Adding a builder subclass per variant without weighing inheritance against composition.

## Code Examples

```python
def extract_factory(filepath: Path):
    ext = filepath.name.split(".")[-1]
    if ext == "json":
        return JSONDataExtractor(filepath)
    elif ext == "xml":
        return XMLDataExtractor(filepath)
    else:
        raise ValueError("Cannot extract data")
```
- **What it demonstrates**: the factory method — one function, dispatch on an input parameter, unsupported input raises.

```python
class FrogWorld:
    def __init__(self, name):
        print(self)
        self.player_name = name

    def __str__(self):
        return "\n\n\t------ Frog World -------"

    def make_character(self):
        return Frog(self.player_name)

    def make_obstacle(self):
        return Bug()


class GameEnvironment:
    def __init__(self, factory):
        self.hero = factory.make_character()
        self.obstacle = factory.make_obstacle()

    def play(self):
        self.hero.interact_with(self.obstacle)
```
- **What it demonstrates**: the abstract factory — generic creation methods grouped per family, and a consumer that depends only on the factory interface.

```python
class Waiter:
    def __init__(self):
        self.builder = None

    def construct_pizza(self, builder):
        self.builder = builder
        steps = (
            builder.prepare_dough,
            builder.add_sauce,
            builder.add_topping,
            builder.bake,
        )
        [step() for step in steps]

    @property
    def pizza(self):
        return self.builder.pizza
```
- **What it demonstrates**: the builder's director — step order lives here, representation lives in the builder, product handed over on request.

```python
class Prototype:
    def __init__(self):
        self.registry = {}

    def register(self, identifier: int, obj: object):
        self.registry[identifier] = obj

    def unregister(self, identifier: int):
        del self.registry[identifier]

    def clone(self, identifier: int, **attrs) -> object:
        found = self.registry.get(identifier)
        if not found:
            raise ValueError(f"Incorrect object identifier: {identifier}")
        obj = copy.deepcopy(found)
        for key in attrs:
            setattr(obj, key, attrs[key])
        return obj
```
- **What it demonstrates**: the prototype — `copy.deepcopy()` plus `setattr()` overrides, with a registry tracking clonable originals.

```python
class SingletonType(type):
    _instances = {}

    def __call__(cls, *args, **kwargs):
        if cls not in cls._instances:
            obj = super(SingletonType, cls).__call__(*args, **kwargs)
            cls._instances[cls] = obj
        return cls._instances[cls]


class URLFetcher(metaclass=SingletonType):
    def __init__(self):
        self.urls = []
```
- **What it demonstrates**: the singleton via metaclass — and why the authors call it un-Pythonic: nothing here reads as "one instance" without the name.

```python
class CarPool:
    def __init__(self):
        self._available = []
        self._in_use = []

    def acquire_car(self) -> Car:
        if len(self._available) == 0:
            new_car = Car("BMW", "M3")
            self._available.append(new_car)
        car = self._available.pop()
        self._in_use.append(car)
        car.in_use = True
        return car

    def release_car(self, car: Car) -> None:
        car.in_use = False
        self._in_use.remove(car)
        self._available.append(car)
```
- **What it demonstrates**: the object pool — lazy creation only on exhaustion, acquire/release cycling between two lists.

## Reference Tables

| Pattern | Intent | When to use | Python mechanism used |
|---|---|---|---|
| Factory method | Return a different object per input parameter, hiding the class from the client | Creation code scattered; want to decouple creation from usage; create objects only when necessary | A plain function with `if/elif` dispatch, `raise ValueError` on unsupported input |
| Abstract factory | Group factory methods to build a family of related objects | Need a consistent family; must swap the active family at runtime with no code change | A class per family with generic `make_*()` methods; consumer takes the factory as a constructor argument |
| Builder | Separate construction of a complex object from its representation | Numerous possible configurations; construction needs ordered steps, validation, or external calls | Minimal product class + one builder class per representation + a director running the step tuple |
| Prototype | Create new objects by copying existing ones | Initialization costlier than copying; original must stay untouched; DB-populated object graphs | `copy.deepcopy()`, `setattr()` for overrides, a registry dict, `id()` to verify |
| Singleton | Restrict instantiation to one object, globally accessible | One coordinating object; shared resource access; transversal service like logging | `SingletonType` metaclass with `_instances` dict and `__call__()` — but prefer a module-level global |
| Object pool | Reuse objects rather than create new ones | Initialization costly in CPU, memory, or network bandwidth | `_available` / `_in_use` lists with `acquire_*()` / `release_*()` methods |

**Builder vs factory:**

| | Factory | Builder |
|---|---|---|
| Steps to create | Single step | Multiple steps |
| Director | None | Almost always uses one |
| When the client gets the object | Returned immediately | Client explicitly asks the director for the final object when it needs it |

## Worked Example

**The pizza-ordering application** — the chapter's end-to-end builder walkthrough. It is a good fit because pizza preparation has a mandatory order: dough before sauce, sauce before topping, both before baking. Baking time also varies by dough thickness and topping — a per-representation detail.

Constants and product first:

```python
import time
from enum import Enum

PizzaProgress = Enum("PizzaProgress", "queued preparation baking ready")
PizzaDough = Enum("PizzaDough", "thin thick")
PizzaSauce = Enum("PizzaSauce", "tomato creme_fraiche")
PizzaTopping = Enum(
    "PizzaTopping",
    "mozzarella double_mozzarella bacon ham mushrooms red_onion oregano",
)
# Delay in seconds
STEP_DELAY = 3


class Pizza:
    def __init__(self, name):
        self.name = name
        self.dough = None
        self.sauce = None
        self.topping = []

    def __str__(self):
        return self.name

    def prepare_dough(self, dough):
        self.dough = dough
        print(f"preparing the {self.dough.name} dough of your {self}...")
        time.sleep(STEP_DELAY)
        print(f"done with the {self.dough.name} dough")
```

`Pizza` is deliberately minimal — it is never instantiated directly by the client, only by a builder. `prepare_dough()` sits here anyway for two reasons: to show that a minimal product may still carry some responsibility, and to promote code reuse through composition (both builders delegate to it).

Two builders, same step names, different details:

```python
class MargaritaBuilder:
    def __init__(self):
        self.pizza = Pizza("margarita")
        self.progress = PizzaProgress.queued
        self.baking_time = 5

    def prepare_dough(self):
        self.progress = PizzaProgress.preparation
        self.pizza.prepare_dough(PizzaDough.thin)
    ...


class CreamyBaconBuilder:
    def __init__(self):
        self.pizza = Pizza("creamy bacon")
        self.progress = PizzaProgress.queued
        self.baking_time = 7

    def prepare_dough(self):
        self.progress = PizzaProgress.preparation
        self.pizza.prepare_dough(PizzaDough.thick)
    ...
```

Margarita: thin dough, double mozzarella and oregano, 5 seconds. Creamy bacon: thick dough, crème fraîche, mozzarella/bacon/ham/mushrooms/red onion/oregano, 7 seconds. Every pizza-specific detail is confined to its builder.

The director owns the order (see `Waiter` in Code Examples above) — `construct_pizza(builder)` runs `prepare_dough`, `add_sauce`, `add_topping`, `bake` as a tuple of bound methods executed in sequence. Because the builder is chosen at runtime, adding a pizza style needs no change to `Waiter`.

Selection and assembly:

```python
def validate_style(builders):
    try:
        input_msg = "What pizza would you like, [m]argarita or [c]reamy bacon? "
        pizza_style = input(input_msg)
        builder = builders[pizza_style]()
        valid_input = True
    except KeyError:
        error_msg = "Sorry, only margarita (key m) and creamy bacon (key c) are available"
        print(error_msg)
        return (False, None)
    return (True, builder)


def main():
    builders = dict(m=MargaritaBuilder, c=CreamyBaconBuilder)
    valid_input = False
    while not valid_input:
        valid_input, builder = validate_style(builders)
    print()
    waiter = Waiter()
    waiter.construct_pizza(builder)
    pizza = waiter.pizza
    print()
    print(f"Enjoy your {pizza}!")
```

Note the shape: `builders` maps a key to a *class*, `builders[pizza_style]()` instantiates it, `KeyError` becomes a friendly message plus a retry loop. The client never calls a step method — it hands the builder to the waiter, then collects `waiter.pizza` whenever it wants it. That deferred handover is precisely what separates builder from factory.

Extending to a Hawaiian pizza is left as an exercise, with an explicit instruction: weigh inheritance against composition before choosing.

## Key Takeaways

- Reach for a creational pattern when direct `__init__()` creation causes a specific pain — untrackable creation, coupling, ordered construction, expensive initialization, or a single-instance requirement.
- Factory method centralizes creation; abstract factory generalizes it to families of related objects that swap together at runtime.
- Builder is the multi-step, director-driven cousin of factory. Product stays minimal; each builder owns one representation; the director owns the order.
- Prototype is nearly free in Python — `copy.deepcopy()` plus `setattr()` overrides — because cloning is a built-in language feature.
- Singleton works but is considered an anti-pattern in the Python community: the metaclass is advanced and non-obvious. Use a module-level global object (Global Object Pattern) instead.
- Object pool trades memory for initialization cost: create only when the pool is empty, return objects on release.
- A shared interface does not guarantee uniform client code — `parsed_data` returning a list vs a tree still forces different handling.
- The Pythonic default is the simplest thing that works. Both the factory-method and singleton sections end with the authors showing the pattern, then showing the simpler code they would actually write.

## Connects To

- **Chapter 1, Foundational Design Principles**: composition over inheritance is invoked directly — twice, for `Pizza.prepare_dough()` reuse and for the Hawaiian-pizza extension exercise.
- **Gang of Four taxonomy**: creational is the first of three categories (creational, structural, behavioral); a design pattern names, motivates, and explains a general design addressing a recurring problem, describing problem, solution, applicability, and consequences.
- **Chapter 4, Structural Design Patterns**: the next step, with object creation now covered.
- **Prototype ↔ object pool**: both avoid the cost of fresh initialization — prototype by copying, object pool by recycling.
- **Singleton ↔ object pool**: both target resource management and consistent state across the application.
- **Factory method → abstract factory → builder**: an escalation in construction complexity — one call, one family, one ordered procedure.
