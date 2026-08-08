# Chapter 3: A Brief Interlude — On Coupling and Abstractions

## Core Idea
Coupling is fine *locally* (high cohesion) and poisonous *globally*. You reduce it by inserting a **simplifying abstraction** between subsystems — and the way you find that abstraction is to ask what familiar data structure could represent the messy system's state. Designing for testability *is* designing for extensibility.

## Frameworks Introduced

- **Coupling / cohesion distinction**: "When we're unable to change component A for fear of breaking component B, we say the components have become coupled."
  - **Local coupling is good**: it means components support each other like the gears of a watch — that's *high cohesion*.
  - **Global coupling is a nuisance**: it raises the risk and cost of change. In a Ball of Mud, coupling between non-cohesive elements grows **superlinearly** until you can no longer effectively change the system.
  - How to fix: insert a simpler abstraction so system A has *fewer kinds* of dependency on it. Now you can change the arrows on the right without changing the ones on the left.

- **Functional Core, Imperative Shell (FCIS)** — Gary Bernhardt's pattern.
  - When to use: whenever business logic is tangled with I/O.
  - How, in three steps: (1) *imperative shell* gathers inputs, (2) *functional core* computes a decision from plain data and returns plain data, (3) *imperative shell* applies the outputs.
  - Why it works: the core has no dependencies on external state, so testing it needs no filesystem, no DB, no network.

- **Separate "what we want to do" from "how to do it"**: have the core emit a list of *commands* as plain tuples — `("COPY", "sourcepath", "destpath")` — rather than performing the effect.
  - This is explicitly flagged as "a trick we'll employ on a grand scale later in the book" (→ Ch10, Commands).

- **Edge-to-edge testing** (Bob's term): invoke the whole system through its real entrypoint, but fake the I/O at both edges.
  - When to use: when unit-testing an inner function feels like it's dodging the real code path, but E2E tests are too slow/unwieldy.
  - How: make the stateful dependencies explicit parameters (`reader`, `filesystem`), inject fakes in tests, inject real ones in production.
  - Cost: "we have to make our stateful components explicit and pass them around" — what DHH called *test-induced design damage*.

- **Spy objects built from `list`**: subclass `list`, have each method append a tuple. Lets you write `assert filesystem == [("COPY", ...)]` and `assert foo not in database`.

## Key Concepts

- **Coupling** — inability to change A without risking B.
- **Cohesion** — the good kind of togetherness; components that belong together and support each other.
- **Seam** — the place where you can carve out a boundary and slide an abstraction in.
- **Functional core** — pure logic over plain data, no side effects.
- **Imperative shell** — the thin I/O layer around the core.
- **Mock** — verifies *how* something gets used (`assert_called_once_with()`). London-school TDD.
- **Fake** — a working implementation designed for tests only; wouldn't work in real life (e.g. the in-memory repository). Lets you assert on *end state*. Classic-style TDD.
- **Spy** — records calls for later inspection; `FakeFileSystem(list)` is one. (`MagicMock` is, strictly, a spy.)
- **Test-induced design damage** — DHH's critique of making dependencies explicit purely to enable testing.

## Mental Models

- **"Given this *abstraction* of a filesystem, what *abstraction* of filesystem actions will happen?"** — replaces "Given this actual filesystem, when I run my function, check what actions happened." That reframing is the whole chapter.
- **Designing for testability really means designing for extensibility.** `mock.patch` lets you unit test; it does *not* let your code grow a `--dry-run` flag or run against an FTP server. Only an abstraction does that. If a test-driven change doesn't buy you a new capability, you probably reached for the wrong tool.
- **Think of mocking as a code smell, not a solution.** Three reasons: (1) patching improves testability without improving design; (2) mock tests verify *interactions*, coupling tests to implementation details and making them brittle; (3) overuse yields test suites so full of setup they fail to explain the code.
- **TDD is a design practice first and a testing practice second.** The tests are a record of your design choices — they explain the system to you when you come back after a long absence.
- **Start hacky, then refactor toward better design.** "Start with a solution to the smallest part of the problem, then iteratively make the solution richer and better designed." That's how the authors write code in the real world, and how the book is structured.
- **The book is firmly classicist.** Build tests around *state* in both setup and assertions; work at the highest level of abstraction possible rather than checking the behavior of intermediary collaborators.

## Code Examples

**Before — logic welded to I/O.** Untestable without `tempfile`, `shutil`, and real disk:

```python
def sync(source, dest):
    source_hashes = {}
    for folder, _, files in os.walk(source):
        for fn in files:
            source_hashes[hash_file(Path(folder) / fn)] = fn

    seen = set()
    for folder, _, files in os.walk(dest):
        for fn in files:
            dest_path = Path(folder) / fn
            dest_hash = hash_file(dest_path)
            seen.add(dest_hash)
            if dest_hash not in source_hashes:
                dest_path.remove()
            elif dest_hash in source_hashes and fn != source_hashes[dest_hash]:
                shutil.move(dest_path, Path(folder) / source_hashes[dest_hash])

    for src_hash, fn in source_hashes.items():
        if src_hash not in seen:
            shutil.copy(Path(source) / fn, Path(dest) / fn)
```
- **What it demonstrates**: it *looks* fine and has several bugs (the `shutil.move()` is wrong). You can't find them cheaply because every test needs `mkdtemp()`/`rmtree()` scaffolding.

**After — FCIS split into three:**

```python
# imperative shell — almost no logic, just gather → call core → apply
def sync(source, dest):
    source_hashes = read_paths_and_hashes(source)      # 1. gather inputs
    dest_hashes = read_paths_and_hashes(dest)

    actions = determine_actions(source_hashes, dest_hashes, source, dest)   # 2. core

    for action, *paths in actions:                     # 3. apply outputs
        if action == 'copy':
            shutil.copyfile(*paths)
        if action == 'move':
            shutil.move(*paths)
        if action == 'delete':
            os.remove(paths[0])


# pure I/O
def read_paths_and_hashes(root):
    hashes = {}
    for folder, _, files in os.walk(root):
        for fn in files:
            hashes[hash_file(Path(folder) / fn)] = fn
    return hashes


# pure business logic: plain data in, plain data out
def determine_actions(src_hashes, dst_hashes, src_folder, dst_folder):
    for sha, filename in src_hashes.items():
        if sha not in dst_hashes:
            yield 'copy', Path(src_folder) / filename, Path(dst_folder) / filename
        elif dst_hashes[sha] != filename:
            yield 'move', Path(dst_folder) / dst_hashes[sha], Path(dst_folder) / filename

    for sha, filename in dst_hashes.items():
        if sha not in src_hashes:
            yield 'delete', dst_folder / filename
```
- **What it demonstrates**: the core takes simple data structures and returns simple data structures. Everything interesting is now testable in microseconds.

**Edge-to-edge with explicit dependencies and a list-based spy:**

```python
def sync(reader, filesystem, source_root, dest_root):
    source_hashes = reader(source_root)
    dest_hashes = reader(dest_root)
    ...
    filesystem.copy(destpath, sourcepath)
    filesystem.move(olddestpath, newdestpath)
    filesystem.delete(dest_root / filename)


class FakeFileSystem(list):
    def copy(self, src, dest):
        self.append(('COPY', src, dest))

    def move(self, src, dest):
        self.append(('MOVE', src, dest))

    def delete(self, dest):
        self.append(('DELETE', dest))


def test_when_a_file_has_been_renamed_in_the_source():
    source = {"sha1": "renamed-file"}
    dest = {"sha1": "original-file"}
    filesystem = FakeFileSystem()
    reader = {"/source": source, "/dest": dest}

    sync(reader.pop, filesystem, "/source", "/dest")

    assert filesystem == [("MOVE", "/dest/original-file", "/dest/renamed-file")]
```
- **What it demonstrates**: no ABC required — Python's dynamic nature means duck typing is enough. The test exercises the *exact same function* production uses.

## Reference Tables

| | Mocks | Fakes |
|---|---|---|
| Verify | *How* something gets used | *End state* of the system |
| Typical API | `assert_called_once_with()` | A real (if simplified) working implementation |
| TDD school | London-school | Classic-style ← **this book** |
| Example | `unittest.mock.MagicMock` (really a spy) | `FakeRepository`, `FakeFileSystem` |
| Coupling to implementation | High — brittle tests | Low |

| Approach | Testable? | Extensible (`--dry-run`, FTP, S3)? |
|---|---|---|
| E2E tests with `tempfile` | Yes, slowly and painfully | No |
| `mock.patch` the I/O modules | Yes | **No** — this is the key argument |
| FCIS / injected abstractions | Yes, fast | Yes |

## Worked Example

**The directory-sync kata, end to end.** Three requirements:
1. File in source but not destination → copy it over.
2. File in source with a different name in destination → rename the destination file.
3. File in destination but not source → remove it.

Requirement 2 forces content hashing (`hashlib.sha1`), which drags in I/O — and that's the trap.

*The E2E test that shows the pain:*
```python
def test_when_a_file_has_been_renamed_in_the_source():
    try:
        source = tempfile.mkdtemp()
        dest = tempfile.mkdtemp()
        content = "I am a file that was renamed"
        source_path = Path(source) / 'source-filename'
        old_dest_path = Path(dest) / 'dest-filename'
        expected_dest_path = Path(dest) / 'source-filename'
        source_path.write_text(content)
        old_dest_path.write_text(content)

        sync(source, dest)

        assert old_dest_path.exists() is False
        assert expected_dest_path.read_text() == content
    finally:
        shutil.rmtree(source)
        shutil.rmtree(dest)
```
> "Wowsers, that's a lot of setup for two simple cases!"

*The diagnosis — name the three distinct responsibilities:*
1. Interrogate the filesystem (`os.walk` + hash each path). Same for source and destination.
2. Decide whether a file is new, renamed, or redundant.
3. Copy, move, or delete files to match the source.

*The abstractions chosen, one per seam:*
- For (1) and (2): a **dict of hash → path** represents filesystem state. `source_files = {'hash1': 'path1'}` vs `dest_files = {'hash1': 'pathX'}` — now it's just comparing two dicts.
- Between (2) and (3): a **list of command tuples**, `('COPY', src, dst)`.

*The same test, after:*
```python
def test_when_a_file_has_been_renamed_in_the_source():
    src_hashes = {'hash1': 'fn1'}
    dst_hashes = {'hash1': 'fn2'}
    actions = determine_actions(src_hashes, dst_hashes, Path('/src'), Path('/dst'))
    assert list(actions) == [('move', Path('/dst/fn2'), Path('/dst/fn1'))]
```
Four lines instead of eighteen, no `try/finally`, no disk. Now enumerating edge cases — and finding the `shutil.move()` bug — is cheap.

## Anti-patterns

- **`mock.patch` as a substitute for design.** It makes code testable without making it better.
- **Tests that assert on intermediary collaborators** rather than on state.
- **Over-mocked test suites** whose setup code hides the story you care about.
- **Abandoning E2E tests entirely.** "That doesn't mean we think you should never use E2E tests!" — aim for a decent test pyramid with the *minimum* number of E2E tests you need to feel confident.

## Key Takeaways

1. **Coupling is local-good, global-bad.** High cohesion inside a component; few, simple dependencies between components.
2. **The heuristic that finds abstractions: "Can I choose a familiar Python data structure to represent the state of the messy system, and imagine a single function that returns that state?"** A dict of hashes did the whole job here.
3. **Ask where the seam is.** Where can I draw a line between systems and slide the abstraction in?
4. **Ask what implicit concepts I can make explicit.** "The set of actions to take" was implicit in the original code; naming it unlocked everything.
5. **Ask what the dependencies are and what the core business logic is.** Then physically separate them.
6. **Prefer fakes over mocks**, and prefer explicit dependency injection over patching — even though it costs you passed-around parameters.
7. **You don't need an ABC to do dependency injection in Python.** ABCs are didactic; duck typing is sufficient.
8. **Practice makes less imperfect.** Finding the right abstraction is genuinely hard; the four questions above are the tools.

## Connects To
- **Ch 2**: `AbstractRepository`/`FakeRepository` are an instance of exactly this reasoning — "if it's hard to fake, the abstraction is too complicated."
- **Ch 4**: the Service Layer is where the FCIS split lands architecturally — domain model = functional core, service layer = edge-to-edge entrypoint.
- **Ch 5**: "On Deciding What Kind of Tests to Write" and the rules of thumb for the test pyramid.
- **Ch 8**: where the authors *do* use `mock.patch` for an email module — and admit it.
- **Ch 13**: where that patch is finally replaced with explicit, centralized dependency injection.
- **Ch 10**: command objects, the grown-up version of `('COPY', src, dst)` tuples.
- **External**: Gary Bernhardt, *Boundaries* (FCIS); Martin Fowler, *Mocks Aren't Stubs*; Brandon Rhodes, *Hoisting Your I/O*; Ed Jung, *Mocking and Patching Pitfalls*.
