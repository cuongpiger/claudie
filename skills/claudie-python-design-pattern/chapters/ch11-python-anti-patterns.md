# Chapter 11: Python Anti-Patterns

## Core Idea

Anti-patterns are practices that *work* but cost you later: they run, produce the
right output, and still leave code less readable, less correct under change, and
slower. This chapter is inverted relative to the rest of the book — instead of
patterns to reach for, it catalogs habits to remove, split into four categories:
**code style**, **correctness**, **maintainability**, and **performance**.
The framing rule: making it work is the floor, not the goal — code should work
*well* and stay easy to maintain.

## Frameworks Introduced

- **PEP 8** — the Python style guide (https://peps.python.org/pep-0008). Defines
  indentation, line length, blank lines, import ordering, naming, comments, and
  whitespace rules.
  - When to use: always, on every file you write or touch.
  - How: don't hand-enforce it. Run formatters — **Black**
    (https://black.readthedocs.io/en/stable/), **isort**
    (https://pycqa.github.io/isort/), and/or **Ruff**
    (https://docs.astral.sh/ruff/) — and wire them into the developer workflow
    via git commit hooks and/or the project's CI/CD pipeline.
- **Flake8** (plus IDEs: **Visual Studio Code**, **PyCharm**) — catches
  correctness and maintainability smells that a formatter cannot: `type()`
  comparisons, mutable default arguments, protected-member access, wildcard
  imports.
  - When to use: in the same commit-hook/CI stage as the formatters. Tooling
    finds them; you still need to know *why* each rule exists to fix it right.
- **EAFP** (Easier to Ask for Forgiveness than Permission) vs **LBYL** (Look
  Before You Leap) — the choosing rule: **favor EAFP where appropriate**. LBYL
  guards with an `if` check before acting and produces cluttered code plus a
  race window; EAFP acts and catches the specific exception, which is cleaner
  and more Pythonic.
- **`functools.lru_cache`** — the stdlib answer to hand-rolled caching. Provides
  an LRU cache that manages entry size and lifetime automatically, and is
  thread-safe.

## Key Concepts

- **Style violations are cheap to fix, so never argue about them.** Four spaces
  per indent level, never mix tabs and spaces. Max 79 characters per line. Two
  blank lines around top-level function and class definitions, one blank line
  around methods inside a class.
- **Import grouping order**: standard library, then related third-party, then
  local application/library imports — one import per line, groups separated by a
  blank line.
- **Naming**: `lower_case_with_underscores` for functions, variables, attributes
  and methods; `CapWords` for classes; `ALL_CAPS_WITH_UNDERSCORES` for constants.
- **Comments** are complete sentences with the first word capitalized. Block
  comments sit at the indentation level of the code they describe, each line
  starting with `#` + one space. Inline comments are used sparingly and separated
  from the statement by at least two spaces.
- **Extraneous whitespace** to avoid: immediately inside `()`/`[]`/`{}`,
  immediately before a comma/semicolon/colon, and more than one space around an
  assignment operator to align it with another line.
- **Subclass-awareness**: `isinstance()` respects the inheritance hierarchy;
  `type()` equality does not.
- **Default arguments are evaluated once**, at function-definition time — so a
  mutable default is shared state across every call.
- **Protected members (`_name`) are a contract**, not a lock. Nothing stops you
  reading them; the author's intent and future refactors are what break you.
- **Composition over inheritance** — the Chapter 1 principle applied as a fix for
  deep hierarchies.

## Anti-patterns

### Code style

- **Mixing tabs and spaces / wrong indent width** *(code style)*: inconsistent
  indentation is a readability and merge hazard.
  - Instead: four spaces per level, spaces only.
- **Long lines and missing blank lines** *(code style)*: dense code is harder to
  scan and review.
  - Instead: cap at 79 characters; two blank lines around top-level defs, one
    around methods.
- **Multiple imports per line / ungrouped imports** *(code style)*:
  `import os, sys` mixed with third-party and local imports hides where a name
  came from.
  - Instead: one import per line, grouped stdlib → third-party → local, blank
    line between groups. Let isort/Ruff do it.
- **camelCase functions, `snake_case` classes, lowercase constants** *(code
  style)*: breaks the reader's ability to infer a name's kind from its shape.
  - Instead: `calculate_sum`, `MyClass`, `MAX_VALUE`.
- **Sloppy comments (`#no space`, unclear inline notes)** *(code style)*: adds
  noise without adding information.
  - Instead: complete capitalized sentences; `# ` prefix; inline comments rare
    and two spaces off the statement.

### Correctness

- **Using `type()` to compare types** *(correctness)*: `type(obj) in (A, B)`
  ignores subclassing, so it silently fails for any subclass you or a caller adds
  later, and it forces you to enumerate every concrete class.
  - Instead: `isinstance(obj, Base)` — shorter, and subclass-aware by design.
- **Mutable default argument** *(correctness)*: `def f(mylist=[])` evaluates `[]`
  once at definition time, so the function *retains changes between calls* and
  accumulates state you never asked for.
  - Instead: default to `None`, then build the mutable value inside the function.
- **Accessing a protected member from outside a class** *(correctness)*:
  reading `obj._title` reaches past the interface the author intended. A later
  maintainer renaming or changing that attribute breaks your code with no
  warning.
  - Instead: refactor the access into a public method on the class (e.g.
    `presentation_line()`), or expose it with the `@property` decorator.

### Maintainability

- **Wildcard import (`from mymodule import *`)** *(maintainability)*: clutters
  the namespace, makes the origin of every imported name unknowable, and invites
  bugs from name collisions.
  - Instead: specific imports, or import the module itself and qualify uses.
- **LBYL instead of EAFP** *(maintainability)*: pre-checking with
  `if os.path.exists(filename):` yields cluttered code and duplicates a check the
  runtime already performs.
  - Instead: `try` the operation and catch the specific exception
    (`FileNotFoundError`). Same outcome, cleaner code.
- **Overusing inheritance / tight coupling** *(maintainability)*: a new class for
  every slight behavior variation produces deep hierarchies
  (`GrandParent → Parent → Child`), tightly coupling classes and making the code
  rigid and complex.
  - Instead: small, focused classes combined by composition — hold the
    collaborator as an attribute.
- **Global variables for sharing data between functions** *(maintainability)*:
  any part of the program can mutate global state unexpectedly, and concurrent
  threads can modify it simultaneously — so it doesn't scale.
  - Instead: pass data as function arguments, or encapsulate the state in a
    class. Improves modularity and testability.

### Performance

- **Not using `.join()` to concatenate strings in a loop** *(performance)*: `+`
  or `+=` inside a loop allocates a brand-new string object on every iteration.
  - Instead: `"".join(string_list)` — built for concatenating from a sequence or
    iterable.
- **Global variable as a cache** *(performance)*: a module-level `_cache = {}`
  looks quick but gives poor maintainability, data-consistency risk, and no
  cache life-cycle management (no eviction, no size bound, not thread-safe).
  - Instead: `@lru_cache(maxsize=...)` from `functools`, or a specialized caching
    library — automatic size/lifetime management, thread-safe, optimized data
    structures.

## Mental Models

- **Default arguments are class attributes of the function.** Evaluated once,
  bound forever. If it's mutable, it's shared.
- **`type()` asks "is it exactly this?", `isinstance()` asks "does it behave like
  this?"** You almost always want the second question.
- **Underscore prefix = "this may change without notice."** Touching it makes
  your code depend on someone else's internals.
- **EAFP treats exceptions as flow control, not as failures.** The `try` block
  states the intent; the `except` clause states the one thing that can go wrong.
- **A global variable is a function parameter you forgot to declare.** Making it
  explicit (argument or instance attribute) restores testability.

## Code Examples

```python
def manipulate(mylist=[]):
    mylist.append("test")
    return mylist


def better_manipulate(mylist=None):
    if not mylist:
        mylist = []
    mylist.append("test")
    return mylist
```

- **What it demonstrates**: BAD then GOOD for the mutable default argument — the
  `[]` default is created once and accumulates across calls; the `None` sentinel
  rebuilds a fresh list each call.

```python
from collections import UserList


class CustomListA(UserList):
    pass


class CustomListB(UserList):
    pass


def compare(obj):
    if type(obj) in (CustomListA, CustomListB):
        print("It's a custom list!")
    else:
        print("It's a something else!")


def better_compare(obj):
    if isinstance(obj, UserList):
        print("It's a custom list!")
    else:
        print("It's a something else!")
```

- **What it demonstrates**: BAD then GOOD for type comparison — both print
  `It's a custom list!`, but `isinstance()` is shorter and keeps working when new
  `UserList` subclasses appear. (`UserList` is also the recommended base when
  defining a custom list class.)

```python
def concatenate(string_list):
    result = ""
    for item in string_list:
        result += item
    return result


def better_concatenate(string_list):
    result = "".join(string_list)
    return result
```

- **What it demonstrates**: BAD then GOOD string concatenation — identical output
  (`AbcDefGhi`), but `+=` allocates a new string per iteration while `.join()`
  builds once.

```python
def test_open_file(filename):
    if os.path.exists(filename):
        with open(filename) as f:
            print(f.text)
    else:
        print("No file there")


def better_test_open_file(filename):
    try:
        with open(filename) as f:
            print(f.text)
    except FileNotFoundError:
        print("No file there")
```

- **What it demonstrates**: LBYL then EAFP — both print `No file there` for a
  missing file, but the `try`/`except` version is cleaner and has no
  check-then-act gap.

```python
# Global variable
counter = 0


def increment():
    global counter
    counter += 1


def reset():
    global counter
    counter = 0


class Counter:
    def __init__(self):
        self.counter = 0

    def increment(self):
        self.counter += 1

    def reset(self):
        self.counter = 0
```

- **What it demonstrates**: BAD then GOOD for shared state — the `global`
  statements versus state encapsulated in an instance, which is modular,
  testable, and safe to have several of.

## Reference Tables

| Anti-pattern | Category | Why it fails | Do this instead |
|---|---|---|---|
| Mixed tabs/spaces, wrong indent | Code style | Inconsistent, merge-hostile | 4 spaces per level, no tabs |
| Lines > 79 chars, missing blank lines | Code style | Hard to scan/review | 79-char cap; 2 blank lines top-level, 1 between methods |
| `import os, sys`, ungrouped imports | Code style | Origin of names unclear | One per line; stdlib → third-party → local, blank line between |
| `calculateSum`, `class my_class`, `maxValue` | Code style | Name shape no longer signals kind | `calculate_sum`, `MyClass`, `MAX_VALUE` |
| `#unspaced` / chatty inline comments | Code style | Noise without information | Capitalized sentences, `# ` prefix, inline used sparingly + 2 spaces |
| Extraneous whitespace in expressions | Code style | Visually noisy, aligns rot on edit | No space inside brackets, before `,;:`, or padding `=` |
| `type(obj) in (A, B)` | Correctness | Ignores subclasses; must enumerate every class | `isinstance(obj, Base)` |
| `def f(x=[])` / `def f(x={})` | Correctness | Default evaluated once; retains changes between calls | `def f(x=None)` then build inside |
| `obj._protected` from outside | Correctness | Not the intended interface; renames break callers silently | Public method, or `@property` wrapper |
| `from mymodule import *` | Maintainability | Namespace clutter, name collisions, unknown origins | Specific imports or import the module |
| LBYL (`if os.path.exists(...)`) | Maintainability | Cluttered; duplicates the runtime's own check | EAFP: `try` / `except FileNotFoundError` |
| Deep inheritance for behavior variants | Maintainability | Tight coupling, complexity, rigidity | Small focused classes + composition |
| `global` for sharing data | Maintainability | Unexpected mutation, unsafe under threads, untestable | Pass as arguments or encapsulate in a class |
| `result += item` in a loop | Performance | New string object every iteration | `"".join(string_list)` |
| Module-level dict as cache | Performance | No eviction/lifetime control, consistency risk, not thread-safe | `@lru_cache(maxsize=100)` or a caching library |

## Worked Example

**The mutable default argument trap**, end to end.

```python
def manipulate(mylist=[]):
    mylist.append("test")
    return mylist


def better_manipulate(mylist=None):
    if not mylist:
        mylist = []
    mylist.append("test")
    return mylist


if __name__ == "__main__":
    print("function manipulate()")
    print(manipulate())
    print(manipulate())
    print(manipulate())
    print("function better_manipulate()")
    print(better_manipulate())
    print(better_manipulate())
```

Running `python ch11/mutable_default_argument.py`:

```
function manipulate()
['test']
['test', 'test']
['test', 'test', 'test']
function better_manipulate()
['test']
['test']
```

The surprise: three identical calls to `manipulate()` return three *different*
lists-in-name-only — it is one list, growing. `"test"` accumulates because the
`[]` default was created once when the `def` executed, and `mylist` keeps its
previous value instead of being reset. `better_manipulate()` returns `['test']`
every time, which is what the signature implied all along.

The companion performance demo, `ch11/concatenate_strings_in_loop.py`, prints
`AbcDefGhi` from both `concatenate()` and `better_concatenate()` — same result,
but `+=` in the loop allocates a new string per item while `"".join()` does not.
The authors report no timing numbers here; the argument is allocation count.

## Key Takeaways

- Style violations: automate them away (Black, isort, Ruff) in commit hooks and
  CI; never spend review time on them.
- Correctness trio: `isinstance()` over `type()`, `None` over `[]`/`{}` as a
  default, public interface over `_protected` access.
- Prefer EAFP to LBYL where appropriate — it is the Pythonic default, not just a
  style preference.
- Composition beats a deep inheritance chain; explicit arguments or a class beat
  a `global`.
- `"".join()` for loop concatenation; `functools.lru_cache` instead of a global
  dict cache — the stdlib already solved both, with thread safety included.
- Flake8/VS Code/PyCharm will flag most of these, but know the reason behind each
  rule so the fix is right, not just silent.

## Connects To

- **Chapter 1, Foundational Design Principles** — the *Favor Composition over
  Inheritance* section is the direct fix for the tight-coupling anti-pattern; the
  *Techniques for achieving encapsulation* section covers the `@property`
  decorator that replaces protected-member access.
- **Chapter 1, Technical requirements** — same environment/tooling setup used for
  all `ch11/` example files.
- **Whole book** — closing note: Python favors simplicity; prefer techniques
  considered Pythonic and avoid these anti-patterns whichever pattern you pick.
