# Chapter 9: Using Software Metrics to Ensure Maintainability

**Author**: Alexander von Zitzewitz

## Core Idea
Entropy — structural erosion — is the biggest enemy of any nontrivial system, and its end state is the big ball of mud; software metrics are the ideal tool to measure entropy, so wire **five or six** well-chosen metric rules into an automated **metrics-based feedback loop** and you will detect harmful trends while they're still cheap to fix.

## Frameworks Introduced

- **The metrics-based feedback loop** — define quantifiable goals measurable by a set of metrics → implement while continuously verifying you're meeting them → when you miss, improve the implementation until you're back inside the goal → continue.
  - **When to use**: every project. **Legacy adaptation**: standard goals weren't there when the system was built, so applying them yields a flood of violations that damages morale. **Start with a lenient set achievable with reasonable effort, then tighten the screws** once achieved. Only worthwhile if the legacy system is still valuable and under development — "improving metrics for a static codebase is pretty useless."

- **The "code cancer" model of cycle groups** — cycle groups start growing continuously once they reach a certain size, eating larger and larger chunks of the codebase.
  - **The counter-measure**: don't try to eliminate all cycles; **cap their size**. Set a threshold (say **5**) on "number of elements in the biggest source-file cycle group" so you get a warning at 6 — possibly a build break. At that size the fix is easy and quick.
  - **Pragmatic position**: small cycle groups within a single namespace/package do little harm *as long as you stop them growing into monster cycle groups*. But **component cycles should never span more than one namespace or package**, and for namespace/package cycle groups the author recommends a **zero-tolerance policy**.
  - **Why cycles are toxic**: they make it impossible to test sections of code in isolation; they make the code harder for new developers to understand (a randomly picked source file could depend on almost everything, directly or indirectly); and tight coupling makes it impossible to isolate and replace functionality without risky global changes — **modularization becomes impossible**.
  - **How to break them**: the **dependency inversion principle** (Robert C. Martin) — introduce an interface to invert a dependency in the cycle; **lift** the cyclic dependency into a higher-level class that depends on the cycle members and frees them from depending on each other; **demote** the cycle to a lower-level class that handles communication between the cyclic elements; or simply **move functionality between classes**. "There is no good excuse for letting code cancer grow out of control."

- **Verticalization** — the author's definition of good design: **horizontal layering plus vertical separation (siloing) of functional components**. Functional components sit in their own silos with **non-cyclic** dependencies and a clear hierarchy between silos — describable as vertical layering, or "microservices within a monolith."
  - **Why systems fail at it**: nobody forces you to organize code into silos, it's hard to do right, so boundaries blur, functionality that belongs in one silo spreads across several, cyclic dependencies between silos appear, and "maintainability goes down the drain at an ever-increasing rate."
  - **Dependency management is crucial for any architecture style.** If you choose microservices, treat inter-service dependencies as a **heavier-weight** form of dependency: interprocess communication has much higher latency than in-process calls and demands far more error handling (what if the target is unavailable, or the network fails?).

- **The Maintainability Level (ML) metric** — the author's attempt at "the holy grail": condense coupling and cycle metrics into one number usable as a fitness function for good design. Built with a customer who supplied larger projects for testing; the values largely matched developers' own judgment of maintainability. Intended uses: track nightly as **a canary in a coal mine** (deteriorating values ⇒ time to refactor); compare the health of all systems in an organization; and decide **rewrite vs refactor**.
  - **Step 1 — levelize.** A dependency graph can only be properly levelized without cyclic dependencies between components, so first **collapse every cycle group into a single logical node**. In the worked example, F, G, H become node **FGH**, yielding three levels: the bottom level has only incoming dependencies, the top only outgoing.
  - **Step 2 — the maintainability intuition.** You want **as many components as possible to have no incoming dependencies**, because they can change without affecting anything else; and you want the remaining components to influence as few components as possible in the layers above.
  - **Step 3 — per-node contribution**:
    ```
    c_i = ( size(i) * (1 − inf(i) / numberOfComponentsInHigherLevels(i)) ) / n
    ```
    where `n` = total number of components, `size(i)` = number of components in the logical node (>1 only for nodes created from cycle groups), `inf(i)` = number of components influenced by the node.
  - **Step 4 — ML1**: `ML1 = 100 * Σ(i=1..k) c_i`, where `k` = number of logical nodes (`k < n` when cycles exist). Higher ML = better maintainability. **100% is unreachable** unless no component has incoming dependencies: top-level nodes contribute their maximum `c_i`, and lower-level contributions shrink the more they influence above. Cycle groups raise the influenced count for all members, so they push ML down.
  - **Step 5 — ML2 adds a cycle-group penalty**, because ML1 misses the negative influence when the cycle-group node sits on the topmost level:
    ```
    penalty(i) = 5 / size(i)   if size(i) > 5
               = 1             otherwise
    ML2 = 100 * Σ(i=1..k) c_i * penalty(i)
    ```
    A penalty of 1 means no penalty. A **100-node cycle group contributes only 5%** of its original contribution.
  - **Step 6 — ML3 adds a sliding minimum for small modules** (<100 components produced unfairly low values, because few components naturally raise relative coupling without hurting maintainability):
    ```
    ML3 = (100 − n) + (n/100) * ML2   if n < 100
        = ML2                          otherwise
    ```
    Justification: small systems are easier to maintain anyway. A 40-component system can never score below 60.
  - **Step 7 — MLalt for the package-structure blind spot.** A client Java project scored in the high 90s while its developers judged maintainability bad: the *component* structure was good and almost cycle-free, but **almost every package in the most critical module sat in a single cycle group** — the classic result of having no clear strategy for assigning classes to packages, which makes classes hard to find. So an alternative value is computed from **Relative Cyclicity over package/namespace dependencies (RC_p)**:
    ```
    MLalt = 100 * (1 − √(sumOfPackageCyclicity) / n_p)
    ```
  - **Step 8 — aggregate.** ML is computed **per module**, then combined as a **weighted average by component count** over the larger modules only: sort modules by decreasing size and keep adding until either **75% of all components** are included or the module has **at least 100 components**. Rationale: the action happens in the larger, more complex modules; small modules are easy to maintain and barely influence overall maintainability.
  - **Calibration**: well-designed systems score **over 90**; systems with no recognizable architecture (Apache Cassandra) score **in the 20s**.
  - **Tooling**: Sonargraph (including the free Sonargraph-Explorer) is currently the only tool computing this experimental metric. Inspired by **Decoupling Level (DL)** — research by Ran Mo, Yuangfang Cai, Rick Kazman, Lu Xiao, and Qiong Feng (Drexel / University of Hawaii) — which cannot be replicated because part of its algorithm is patented.

- **The Golden Rules for Better Software** — adopt on a new project and "your software will be better than 90% of all other projects of similar size and complexity." On an existing codebase, **first goal is to stop the bleeding** (make sure things aren't getting worse), then set monthly or quarterly goals to reduce violations by a few percentage points; over time it adds up.
  1. Have a **formal and enforceable architectural model** defining the parts of your software and the allowed dependencies between them.
  2. **Avoid circular dependencies on the namespace/package level.**
  3. **Limit circular dependency at the source-file/class level** — any cycle group with more than five elements has a good chance of turning into code cancer. Avoid even small ones if you can.
  4. **Avoid code duplication** (copy-and-paste programming) — a classical code smell. Rare edge case: duplicating code can break cycles that are otherwise hard to break.
  5. **Limit source-file size to 800 LoC** (soft threshold).
  6. **Limit maximum indentation to 4 and Modified Cyclomatic Complexity to 15** (soft thresholds).
  - Implement them **tool-based, verified automatically in the CI build**, and **across the organization** so all developers become familiar with them.

## Key Concepts
- **Entropy / structural erosion** — the drift toward a badly tangled, highly coupled codebase that has lost all architectural cohesion. **Typical symptom**: a change in one part breaks something in a completely unrelated part. **Second symptom**: many cyclic dependencies forming large cycle groups.
- **Cycle group** — a set of nodes (source files, namespaces, packages, …) mutually reachable through their dependencies.
- **Component** (Lakos) — in C/C++, a source file plus its associated header; in languages like Java, usually a single source file.
- **Depends Upon** — count of nodes reachable from a node, **plus one** (itself). In graph theory the reachable set is the node's **closure**.
- **Used From** — count of nodes with a direct or indirect connection *to* the node. `Σ Used From` always equals `Σ Depends Upon`, since each metric looks at one end of the same directed dependencies.
- **Fan Out** = `Depends Upon / n` per node; **Fan In** = `Used From / n`. **Average Fan In = Average Fan Out = Propagation Cost.**
- **CCD (Cumulative Component Dependency)** — sum of all `Depends Upon` values.
- **ACD (Average Component Dependency)** (John Lakos, *Large-Scale C++ Design*, 1996) — `CCD / n`. How many elements a randomly chosen element depends on, directly or indirectly, on average, including itself. Range: minimum **1** (no dependencies), maximum **n**.
- **PC (Propagation Cost)** (Baldwin, Rusnak & MacCormack, 2006) — `ACD / n`, equivalently `CCD / n²`. Normalizes ACD for cross-system comparison. **Key consequence**: if component count doubles, CCD must grow **4×** to hold PC constant — so in large systems (500+ components) PC usually *declines* as components grow even when coupling is very high. **A falling PC is not automatically good news.**
- **Cyclicity** — the **square** of the number of elements in a cycle group (a 5-element group has Cyclicity 25).
- **Relative Cyclicity** — `100 * √(sumOfCyclicity) / n`, computed per module and for the whole system.
- **SDI (Structural Debt Index)** — the author's metric, designed to be **roughly proportional to the work required to break a cycle group**, filling Relative Cyclicity's blind spot (it says nothing about how hard the cycles are to break). A graph algorithm finds a **minimal breakup set**; **parser dependencies** (individual usages — e.g. class A calling three methods of class B = three usages) act as **link weights** so the algorithm prefers cutting lower-weight links:
  ```
  SDI = 10 * numberOfLinksToCut + Σ weightOfLinksToCut
  ```
  The constant 10 exists because *someone must figure out how to break each link*; the weight term accounts for the extra effort per usage. Calculated per cycle group, then accumulated to module and system level. Sonargraph-Architect uses its components to **rank cycle groups by how easy they'd be to fix**. Use it *together with* Relative Cyclicity; **continuous growth is the symptom of code cancer developing**.
- **LoC** vs **Total Lines** — LoC counts lines containing actual code, skipping empty and comment lines; Total Lines counts everything. **Gotcha**: file-header copyright comments aren't commenting on code and should be excluded from comment-line counts.
- **Number of Statements** — size metric for functions/methods; also the standard **weight** for averaging complexity metrics, so that many small getters and setters don't dilute the complexity of long methods.
- **Cyclomatic Complexity** (Thomas McCabe, 1976) — number of distinct possible execution paths through a method, and therefore a **floor on the number of test cases needed for 100% coverage**. Shortcut computation: start at 1, add 1 per loop or conditional, add the number of cases for a switch. Well researched: **error rates increase quickly above 24.**
  - **Modified Cyclomatic Complexity** — adds only 1 per switch statement (switches inflate the metric without adding proportionate complexity).
  - **Extended Cyclomatic Complexity** — adds 1 per logical `&&` / `||`, since short-circuiting acts like an extra conditional.
  - **Average Cyclomatic Complexity** — aggregate to class/package/module as a weighted average.
- **Indentation debt** — maximum code indentation level in functions and methods; deeper = more complex. "Works surprisingly well for spotting complex code." Aggregate to class/file via weighted average by Number of Statements.
- **Change history metrics** (Adam Tornhill, *Your Code as a Crime Scene*) — the version-control system as a treasure trove: **Number of Changes(d)**, **Code Churn(d)** (lines added or removed in the last d days), **Code Churn Rate(d)** (`Code Churn(d) / lines in file` — a value of 2 for `Code Churn Rate(90)` means "this file was rewritten twice in the last 90 days"), and **Number of Authors(d)** (files with `Number of Authors(365) = 1` reveal **knowledge monopolies** — a risk if that person leaves).
- **Component Rank** — Google's PageRank applied to classes/source files, using outgoing dependencies instead of links. PageRank picks a random page, follows a random outgoing link with configurable probability (default 80%), stops and increments a counter, and repeats until per-page probabilities stabilize. **Use**: when you're new to a complex module, start reading the **highest-ranked classes** — many others reference them, so you'll need to understand them first.
- **LCOM4 (Lack of Cohesion of Methods, 4th version)** — detects single-responsibility-principle violations. Build a dependency graph between all methods (excluding constructors, overridden, and static methods) and all fields (excluding static fields); the metric value is the number of **connected components** with no connection between them. Ideal value is **1**; >1 means the class splits cleanly. **Caveat**: often fails when a class calls or accesses members of a superclass — it does not work well in class hierarchies. Works well for classes outside complex hierarchies.
- **Hard vs soft thresholds** — a hard threshold **breaks the build** when violated; a soft threshold only **issues a warning**. Size and complexity thresholds should mostly be soft, with justified exceptions — "just make sure that exceptions don't get out of hand."
- **Bottleneck class** — a class with many incoming *and* outgoing dependencies; frequently-changing complex hotspots often turn out to be these.
- **Architectural characteristics / "-ilities"** — the goals you want from your architecture (stability, scalability, maintainability, agility).

## Reference Tables

**Tools for gathering metrics**

| Tool | Capabilities |
|---|---|
| Understand | Commercial, many languages; mostly size and complexity metrics |
| NDepend | Commercial, .NET; mostly size and complexity metrics |
| Source Monitor | Free; C++, C, C#, VB.NET, Java, Delphi, VB6, HTML; **only** size and complexity metrics |
| SonarQube | Free for some languages, commercial version has more; mostly size and complexity metrics |
| Sonargraph-Explorer | Free for Java, C#, Python; **complete set** — coupling, cycles, size, complexity. Commercial **Sonargraph-Architect** adds change-history (Git) metrics and C/C++ |

All commercial tools offer free evaluations — try them and pick one. **The critical evaluation criterion: can it check metric thresholds in your automated build?** Writing your own tool is "almost always a bad idea if a tool is already available" — it costs more than buying one (especially long-term maintenance as languages gain features), and the advanced metrics here require a complete dependency model, i.e. implementing a compiler's parsing and dependency-resolution stages.

**Thresholds the author commits to**

| Metric | Recommended threshold | Note |
|---|---|---|
| Biggest **component** cycle group | **≤ 5** elements | Larger tolerable only with a good technical reason, or in code that's hardly ever changed |
| **Package/namespace** cycle groups | **0** — zero tolerance | Packages express architectural grouping and intent |
| Component cycles spanning namespaces | **Never** | |
| Maintainability Level | **≥ 75%** | Used as a fitness function |
| Relative Cyclicity (components) | **≤ 4%** | |
| Relative Cyclicity (packages/namespaces) | **0%** | |
| Structural Debt Index (components) | **low 100s** | Goal: as close to zero as possible |
| Source file size | **~800 LoC** (soft) | Above this, consider breaking the file up |
| Number of Statements per function/method | **100** | |
| Cyclomatic Complexity | **15** (safe side; research shows error rates climb above 24) | |
| Maximum indentation level | **4** (soft) | |
| Share of "complex" code | **≤ 10% of LoC** | "Complex" = avg indentation > 3, **or** avg complexity > 10, **or** size > 800 LoC. Sum those files' LoC over total LoC |
| Number of metric-based rules | **5–6** | "Any additional rules will result in diminishing returns" |

**Reading Propagation Cost by system size**

| System size | Interpretation |
|---|---|
| `n < 500` (small) | Higher PC values are **less concerning** |
| `500 ≤ n < 5,000` (midsized) | **> 20% concerning**; **> 50%** points to serious issues with large cycle groups |
| `n ≥ 5,000` (huge) | Even **10% is already quite concerning** |

**Always read PC together with ACD.** PC of 10% in a 5,000-component system means ACD = 500 — every change might affect an average of 500 components.
Similarly, ACD must be read against component count: **ACD of 100 is acceptable for 1,000 components, devastating for 100.**

## Worked Example

### Apache Cassandra as the case study in code cancer
- **v2** — one cycle group of about **450 Java files**.
- **v3** — that group grew to **more than 900 elements**.
- **v4** — **more than 1,300 elements**, and "the tumor even metastasized" with two new groups of **143** and **31** elements. About **75% of all elements** are now in large cycle groups.
- **At package level it's worse**: **102 of 113 Java packages** sit in a single big cycle group.
- The consequence, stated bluntly: "you could say that the developers minimized the architecture diagram of Cassandra to a single box labeled 'Cassandra'." Easy to read; reveals nothing about the inner structure.
- **The counter-example**: the **Spring framework** — well structured and architected, with a very limited number of small cycle groups.
- **The baseline claim**: in the author's long experience, **more than 80% of nontrivial systems over 100,000 LoC end up as big balls of mud.** Avoiding that fate alone puts you ahead of 80% of comparable systems — "low-hanging fruit."

### ACD / PC computed on a 6-node graph
Bottom nodes depend only on themselves → `Depends Upon = 1`. The right-middle component depends on the one beneath it → **2**. The left-middle depends on the right-middle, both bottom nodes, and itself → **4**. Both top-level components depend on everything in levels one and two plus themselves → **5** each.
`CCD = 18` → `ACD = 18/6 = 3` → `PC = 3/6 = 50%`. Meaning: every time you touch something, an average of 50% of all components could be affected. Devastating for a large system; **not useful for an example this small**.

### Relative Cyclicity — one big group vs many small ones
- **100 components, all in one 100-element cycle group**: `Cyclicity = 100² = 10,000`; `100 * √10,000 / 100 = 100%` — the worst possible value.
- **100 components in 50 cycle groups of 2**: each `Cyclicity = 2² = 4`, sum = 200; `100 * √200 / 100 = 14.14%` — far better, **even though every single component is still in a cycle**.
- **Lesson**: smaller is always better, because smaller cycle groups are much easier to break.

### SDI — why cycle size alone misleads
- **10 files in a simple ring** (1→2→3→…→10→1): Relative Cyclicity **100%**, but **cutting or inverting one dependency** fixes everything. With that link weighted 1, `SDI = 10*1 + 1 = 11`.
- **10 files, every file bidirectionally coupled to every other**: `(9+8+7+…+1) * 2 = 90` dependencies. Relative Cyclicity is **also 100%**, but you must break or invert **at least 45** dependencies.
- Two identical Relative Cyclicity readings, radically different remediation cost — which is exactly the gap SDI fills.

### ML computed on the 12-component example
Node A influences only E, I, and J (directly and indirectly). Node B influences everything in levels 2 and 3 except E and I — the FGH cycle group is what drags B down. So **A contributes more to maintainability than B**, having a lower probability of breaking something above it.
```
c_A = ( 1 * (1 − 3/8) ) / 12  ≈  0.052
```
Summing all `c_i`: **ML = 53/96 = 55%** with `k = 10` logical nodes and `n = 12` components. Fed through the ML3 sliding minimum, 55% becomes **94.6%** — "much more appropriate … if you consider the fact that small systems like this one do not create a high maintainability burden."

### The software city visualization (Apache Cassandra, Sonargraph-Architect)
A 3D encoding of several metrics at once:
- each **building** = a source file, **grouped by module and package/namespace**;
- **footprint area** ∝ file size in Lines of Code;
- **height** derived from the file's average complexity;
- **shade** determined by change frequency in the last 90 days.

**Reading rule: tall dark buildings are refactoring candidates.** In the Cassandra render, one darker building on the left isn't very tall but is the **third largest file by LoC**, and its darkness signals frequent change — it turned out to be `StorageManager`, obviously an important class for a non-SQL database. The pairing is arbitrary: height could be incoming dependencies while colour is complexity, which lets you do sophisticated analytics with very little effort.

### Building fitness functions out of these metrics
The author's own recommendation: **prioritize at most three architectural characteristics plus maintainability** — "there are very few use cases where maintainability is not important" — and measure each with an appropriate fitness function. Trade-offs are unavoidable: you cannot have all desirable characteristics without pushing complexity to unmanageable levels, and **some are mutually exclusive** — maximum performance and maximum security oppose each other, since security requires encryption and encryption burns CPU.
Concrete maintainability fitness function: **Maintainability Level ≥ 75%**, **Relative Cyclicity ≤ 4% for components and 0% for packages/namespaces**, **SDI in the low 100s** — checked in the CI build, breaking the build on violation.

### Tracking over time
Gather metrics **once a day in an automated build** and feed them into a tool that keeps history; render as trend charts (e.g. LoC growth over 90 days). Track **all your fitness functions plus some coupling and size metrics**. Trends let you react before things get bad — complementary to hard thresholds, not a replacement.
Tooling options: **SonarQube** (free for some languages, limited metric choice; the **Sonargraph SonarQube plug-in** adds more); **Jenkins + Sonargraph-Explorer** (free, good metrics, limited charts); **Sonargraph-Enterprise** (commercial team license, good metrics and flexible customizable charts); or roll your own, which "is not too hard as long as you have a good data source."

## Anti-patterns
- **Letting cycle groups grow** — past ~5 elements they compound into code cancer.
- **Package/namespace cycles** — worse than component cycles, because packages carry architectural intent.
- **Applying a full standard metric goal set to a legacy codebase at once** — the flood of violations damages morale.
- **Improving metrics on a static codebase** — pointless.
- **Picking the wrong metrics for your one or two rules** — "you might be harming it"; training developers to satisfy a metric yields **superficial improvements**.
- **Too many metric rules** — annoys developers, slows progress, adds no benefit. Sweet spot is 5–6.
- **Metric rules whose violations trigger no action** — useless without automation.
- **Writing your own metrics tool when one exists** — you end up implementing a compiler's front end.
- **Trusting component-level ML alone** — the high-90s project with a total mess of a package structure is the cautionary tale.
- **Reading a falling Propagation Cost as improvement** — it usually falls purely because the component count grew.
- **Using LCOM4 inside complex class hierarchies.**
- **Copy-and-paste programming.**
- **Treating inter-microservice dependencies as equivalent to in-process calls.**

## Key Takeaways
1. Cap cycle-group size rather than chasing zero cycles at component level — but hold **zero tolerance** for package/namespace cycles.
2. Every cycle *can* be broken: invert (dependency inversion principle), lift, demote, or move functionality.
3. Read coupling metrics as pairs and against system size: ACD with component count, PC with ACD, Relative Cyclicity with SDI.
4. SDI exists because remediation cost, not cycle size, is what you actually plan around.
5. Maintainability Level condenses coupling and cycles into one 0–100 canary — >90 for well-designed systems, 20s for architecture-free ones — but must be checked against the package structure too.
6. Weighted averages by Number of Statements keep getters and setters from hiding complex methods.
7. Mine version control for hotspots (change frequency, churn rate) and knowledge monopolies (`Number of Authors(365) = 1`); intersect hotspots with bottleneck classes for refactoring targets.
8. Adopt five or six rules, automate them in CI, apply them organization-wide, and gather metrics daily so trends surface early.
9. If you do only one thing: limit cyclic dependencies. That alone stops the worst side effects of structural erosion and makes stricter rules adoptable later.

## Connects To
- **Ch 4** (Lilienthal): MMI criteria 1.3.x and 2.2.x are precisely these size/complexity/cycle metrics; both chapters name Sonargraph and the same cycle-and-layer-violation diagnosis.
- **Ch 2** (Weiss): these are the canonical **bottom-layer, triggered-atomic** fitness functions; "-ilities" map to ISO 25010 maintainability subattributes.
- **Ch 8** (Ford): ArchUnit's cycle and layer checks are the executable form of golden rules 1–3; automation is what turns these metrics into engineering.
- **Ch 7** (Woods): these are **internal artifact measurements** — tangible, cheap, accurate, but only available once code exists.
- **John Lakos, *Large-Scale C++ Design*** (ACD/CCD); **Baldwin, Rusnak & MacCormack (2006)** (Propagation Cost); **Robert C. Martin, *Agile Software Development, Principles, Patterns, and Practices*** (dependency inversion); **Thomas McCabe (1976)** (cyclomatic complexity); **Adam Tornhill, *Your Code as a Crime Scene***; **Mo et al., "Decoupling Level"** (ICSE '16); **Foote & Yoder** (big ball of mud); **Building Evolutionary Architectures**.
