# Chapter 4: Improve Your Architecture with the Modularity Maturity Index

**Author**: Dr. Carola Lilienthal

## Core Idea
The **Modularity Maturity Index (MMI)** scores a codebase 0–10 on how much design and architecture debt it carries, by measuring the three principles that match how the human brain handles complexity — modularity (45%), hierarchy (30%), and pattern consistency (25%) — so management and teams can decide, per system, whether to **refactor**, **replace**, or **leave alone**.

## Frameworks Introduced

- **The MMI (Modularity Maturity Index)** — a uniform 0–10 evaluation scheme derived from Lilienthal's doctoral thesis on architecture and cognitive science plus 300+ architectural assessments, designed so technical debt can be *compared across different systems*.
  - **When to use**: portfolio decisions ("which of our 40 applications need investment?") and to track a single legacy system's recovery over time.
  - **How**: score each criterion in the criteria table 0–10 using the threshold table; sum scores within a section; divide by the number of criteria in that section; weight by the principle's percentage; sum to a 0–10 MMI.
  - **Decision bands**:
    - **8–10** — low technical debt; system sits in the corridor of low, stable maintenance cost. Nothing to worry about.
    - **4–8** — significant debt accumulated. **Renewing is usually cheaper than replacing** — define and prioritize refactorings with the reviewer and schedule them into maintenance/expansion.
    - **< 4** — maintainable and extendable only with great effort (high, unpredictable maintenance costs). Weigh carefully whether refactoring is worth it or the system should be **replaced**.

- **The cognitive-science basis** — three brain mechanisms mapped to three architecture principles:
  | Brain mechanism | Architecture principle | MMI weight |
  |---|---|---|
  | Chunking | **Modularity** | 45% |
  | Building hierarchies | **Hierarchy** | 30% |
  | Building schemata | **Pattern consistency** | 25% |
  - **Why modularity dominates**: modularity is the *basis* for both hierarchy and pattern consistency — which is also why the index carries its name.
  - **Why it works**: architectures following these principles are perceived as uniform and understandable, so they can be maintained and extended quickly, with fewer errors, by *changing* development teams over a long life.

- **Two kinds of technical debt found in an architecture review** (Cunningham's definition: debt arises from consciously or unconsciously wrong/suboptimal technical decisions, creating later work that makes maintenance and expansion more expensive):
  - **Implementation debt** — code smells (long methods, empty catch blocks). Largely tool-detectable. Every team should resolve this **gradually in daily work, without extra budget**.
  - **Design and architecture debt** — inconsistent, complex class/package/subsystem/layer/module structure and dependencies that don't match the planned architecture. **Cannot be found by counting and measuring**; requires an architecture review.
  - Explicitly **not** technical debt in this framing: missing documentation, poor test coverage, poor usability, inadequate hardware.

- **The technical-debt corridor model** — a system starts inside a corridor of low, stable maintenance cost. Maintenance and change push debt **up**; architecture improvement pulls it **down**. A permanent alternation of the two keeps the system inside the corridor. Deny the team continuous debt reduction and **architecture erosion** sets in: changes get more expensive, consequential errors harder to understand, and — the telling detail — *less and less functionality is delivered per unit of time*.
  - Two exits from the dilemma: **refactoring** (arduous, step-by-step back into the corridor) or **replacing**.
  - Systems that never had a capable team accumulate debt from day one: they "grew up under poor conditions."

- **The architecture review workshop (target-vs-actual)** — how the non-measurable MMI criteria get determined. Run by a reviewer *with* the architects and developers:
  1. **Parse the source code** with an analysis tool to record the **actual architecture**.
  2. **Model the target architecture** on top of the actual so the two can be compared.
  3. Technical debts become visible; reviewer and team look for **simple refactorings** to move actual toward target — *or* conclude the code's solution is better than the original plan, *or* that neither is best and a new target image must be designed.
  4. **Collect technical debts and candidate refactorings.**
  5. **Review metrics** (large classes, too-strong coupling, cycles, …) to find further debt.
  - Practice notes: reviews are always done **in pairs**, then discussed in a larger group of reviewers, for maximum comparability. Start from the team's own list of known debts — most teams can enumerate it instantly.

## Key Concepts
- **Modularity** (Parnas, 1972) — a module should contain **only one design decision** (encapsulation), and the data structure for that decision should be encapsulated in the module locality.
- **Cohesion through coupling** — a unit's subunits should have high cohesion with each other and low coupling outward. Tell: if a module's submodules couple more strongly to *other* modules than to their "sisters and brothers," modularity is done badly. Coupling is measurable; cohesion is not.
- **Schema** — an abstraction summarizing typical properties of similar things; why design patterns work cognitively, and why they must be **findable in the source code and used consistently**.
- **Target architecture** — the plan, on paper or in the architect's/developer's head.
- **Actual architecture** — what the source code really implements. As a rule they differ.
- **Architecture erosion** — the process of leaving the low-cost corridor permanently.
- **Cycles** — class cycles, package cycles, module cycles, and upward relationships between layers. Created by *use* and *inherit* relations, which (unlike *contain-being*) need not be hierarchical.

## Reference Tables

**MMI criteria and how each is determined**

| Category (weight) | Subcategory (weight) | Criteria | Determined by |
|---|---|---|---|
| **1. Modularity (45%)** | 1.1 Domain and technical modularization (25%) | 1.1.1 Allocation of source code to domain modules, % of total | Architecture analysis tools |
| | | 1.1.2 Allocation of source code to technical layers, % of total | Architecture analysis tools |
| | | 1.1.3 Size relationships of domain modules [(LoC max/LoC min)/number] | Metrics tools |
| | | 1.1.4 Size relationships of technical layers [(LoC max/LoC min)/number] | Metrics tools |
| | | 1.1.5 Domain modules, technical layers, packages, classes have clear responsibilities | Reviewers |
| | | 1.1.6 Mapping of technical layers and domain modules through packages/namespaces or projects | Reviewers |
| | 1.2 Internal interfaces (10%) | 1.2.1 Domain or technical modules have interfaces (% violations) | Architecture analysis tools |
| | | 1.2.2 Mapping of internal interfaces through packages/namespaces or projects | Reviewers |
| | 1.3 Proportions (10%) | 1.3.1 % of source code in large classes | Metrics tools |
| | | 1.3.2 % of source code in large methods | Metrics tools |
| | | 1.3.3 % of classes in large packages | Metrics tools |
| | | 1.3.4 % of methods with high cyclomatic complexity | Metrics tools |
| **2. Hierarchy (30%)** | 2.1 Technical and domain layering (15%) | 2.1.1 Architecture violations in technical layering (%) | Architecture analysis tools |
| | | 2.1.2 Architecture violations in layering of domain modules (%) | Architecture analysis tools |
| | 2.2 Class and package cycles (15%) | 2.2.1 Classes in cycles (%) | Metrics tools |
| | | 2.2.2 Packages in cycles (%) | Metrics tools |
| | | 2.2.3 Number of classes per cycle | Metrics tools |
| | | 2.2.4 Number of packages per cycle | Metrics tools |
| **3. Pattern consistency (25%)** | — | 3.1 Allocation of source code to the pattern, % of total | Architecture analysis tools |
| | | 3.2 Relationships of the patterns are cycle-free (% violations) | Architecture analysis tools |
| | | 3.3 Explicit mapping of patterns (class names, inheritance, annotations) | Reviewers |
| | | 3.4 Separation of domain and technical source code (DDD, Quasar, Hexagonal) | Reviewers |

**Scoring thresholds (0 = worst, 10 = best)**

| Sect. | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1.1.1 | ≤54% | >54% | >58% | >62% | >66% | >70% | >74% | >78% | >82% | >86% | >90% |
| 1.1.2 | ≤75% | >75% | >77.5% | >80% | >82.5% | >85% | >87.5% | >90% | >92.5% | >95% | >97.5% |
| 1.1.3 | ≥7.5 | <7.5 | <5 | <3.5 | <2.5 | <2 | <1.5 | <1.1 | <0.85 | <0.65 | <0.5 |
| 1.1.4 | ≥16.5 | <16.5 | <11 | <7.5 | <5 | <3.5 | <2.5 | <2 | <1.5 | <1.1 | <0.85 |
| 1.1.5 | No | | | | | partial | | | | | Yes, all |
| 1.1.6 | No | | | | | partial | | | | | Yes |
| 1.2.1 | ≥6.5% | <6.5% | <4% | <2.5% | <1.5% | <1% | <0.65% | <0.4% | <0.25% | <0.15% | <0.1% |
| 1.2.2 | No | | | | | partial | | | | | Yes |
| 1.3.1 | ≥23% | <23% | <18% | <13.5% | <10.5% | <8% | <6% | <4.75% | <3.5% | <2.75% | <2% |
| 1.3.2 | ≥23% | <23% | <18% | <13.5% | <10.5% | <8% | <6% | <4.75% | <3.5% | <2.75% | <2% |
| 1.3.3 | ≥23% | <23% | <18% | <13.5% | <10.5% | <8% | <6% | <4.75% | <3.5% | <2.75% | <2% |
| 1.3.4 | ≥3.6% | <3.6% | <2.6% | <1.9% | <1.4% | <1% | <0.75% | <0.5% | <0.4% | <0.3% | <0.2% |
| 2.1.1 | ≥6.5% | <6.5% | <4% | <2.5% | <1.5% | <1% | <0.65% | <0.4% | <0.25% | <0.15% | <0.1% |
| 2.1.2 | ≥14% | <14% | <9.6% | <6.5% | <4.5% | <3.2% | <2.25% | <1.5% | <1.1% | <0.75% | <0.5% |
| 2.2.1 | ≥25% | <25% | <22.5% | <20% | <17.5% | <15% | <12.5% | <10% | <7.5% | <5% | <2.5% |
| 2.2.2 | ≥50% | <50% | <45% | <40% | <35% | <30% | <25% | <20% | <15% | <10% | <5% |
| 2.2.3 | ≥106 | <106 | <82 | <62 | <48 | <37 | <29 | <22 | <17 | <13 | <10 |
| 2.2.4 | ≥37 | <37 | <30 | <24 | <19 | <15 | <12 | <10 | <8 | <6 | <5 |
| 3.1 | ≤54.5% | >54.5% | >59% | >63.5% | >68% | >72.5% | >77% | >81.5% | >86% | >90.5% | >95% |
| 3.2 | ≥7.5% | <7.5% | <5% | <3.5% | <2.5% | <2% | <1.5% | <1.1% | <0.85% | <0.65% | <0.5% |
| 3.3 | No | | | | | partial | | | | | Yes |
| 3.4 | No | | | | | partial | | | | | Yes |

**Tools named for target-vs-actual analysis**: Lattix, Sotograph/SotoArc, Sonargraph, Structure101, TeamScale.

## Worked Example

**Extreme proportions — the "Monolith and eight Satellites".** A team stated their nine build units reflected the planned modules of the system. The size pie chart told a different story: **one build unit held 950,860 LOC; the other eight together held 84,808 LOC.** The dependency view showed the Monolith using all eight "Satellite X" units. Verdict: modularity is not well-balanced — and criterion 1.1.3 (LoC max/LoC min per module count) makes this *measurable*, not a matter of opinion.

**A cycle of 242 classes.** In a system of 479 classes total, a single cycle contained **242 classes spread over 18 directories**, all needing each other directly or indirectly — over half the codebase. The cycle had a strong concentration in the centre with few satellites, meaning **there is no natural break point**: only a large redesign would resolve it. The lesson: prevent large cycles rather than plan to break them. Most systems, fortunately, have smaller, less concentrated cycles that a few refactorings can dissolve.

**Layer cycles in an 80,000-LOC system.** Four technical layers — App, Services, Entities, Util — stacked and used mainly top-down as intended, but some **back references** had crept in, creating cycles between layers and hence architecture violations. Those violations were caused by just **16 classes** and were easy to resolve. Same lesson, opposite outcome: the earlier you find them, the cheaper they are.

**Pattern consistency read from a dependency diagram.** A team recorded their design patterns as layers in an analysis tool, then had the source code partitioned into those patterns. Reading the arcs: **left-of-axis arcs go downward** (with the pattern layering), **right-of-axis arcs go upward** (against it). This system was judged good because it showed mostly left-side arcs and very few right-side ones — design patterns naturally form hierarchical structures, so upward arcs are the violation signal. Examining patterns in the source is described as usually the most exciting part of a review, because it reveals *the level at which the team is really working* — pattern classes are typically scattered across packages and only become analyzable once modelled this way.

**Portfolio view.** 18 systems assessed over 5 years, plotted as MMI (0–10, y-axis) against assessment date (x-axis) with point size = LOC. This is the artifact that turns per-system scores into a management conversation.

## Anti-patterns
- **Focusing development on quick feature implementation rather than architecture quality** — the named root cause of two decades of legacy systems.
- **Not allowing the team to continuously reduce technical debt** — makes architecture erosion inevitable.
- **Deliberately accepting target-vs-actual deviation under time pressure** with refactoring "postponed indefinitely."
- **Relying on IDEs for architectural insight** — development environments give local views of the code being edited, never an overview, so deviations occur unnoticed.
- **Program units that combine arbitrary, unrelated elements** — the brain gains nothing from a unit that isn't a coherent, meaningful whole.
- **Vague unit names** — if you can't answer "what is this unit's task?" with *one* task, responsibilities are unclear. Not measurable, but a reliable clue.
- **Comparing MMI scores across tools without checking metric implementations** — for comparability you must account for how each tool implements each metric.

## Key Takeaways
1. MMI = 45% modularity + 30% hierarchy + 25% pattern consistency, scored 0–10.
2. Read the score as a decision: <4 consider replacing, 4–8 renew (usually cheaper than replacing), >8 leave it alone.
3. Implementation debt is tool-findable and should be paid down in daily work with no extra budget; design/architecture debt needs a review.
4. Cycles and layer violations are precisely measurable at every level — measure them and kill them early, while they're still 16 classes rather than 242.
5. Coupling is measurable, cohesion is not; balance of unit sizes is measurable, clarity of responsibility is not. The MMI deliberately mixes tool metrics, tool-assisted analysis, and reviewer judgment.
6. Pattern consistency only counts if patterns are explicitly mappable in the source (names, inheritance, annotations) and their relationships are cycle-free.
7. Run reviews as workshops with the team, in reviewer pairs, and start from the debts the team already knows about.

## Connects To
- **Ch 9** (von Zitzewitz): supplies the individual coupling/size/complexity metrics (ACD, cyclomatic complexity, cycle counts) that MMI criteria 1.3.x and 2.2.x rely on, plus the "toxicity of cyclic dependencies" argument.
- **Ch 3** (Farley): modularity, cohesion, separation of concerns, abstraction, coupling — MMI measures the structural consequences of exactly those attributes.
- **Ch 2** (Weiss): ISO 25010 lists modularity, modifiability, and analyzability as maintainability subattributes; MMI criteria make good bottom-layer atomic fitness functions.
- **Ch 7** (Woods): MMI is a *software analysis* / *design analysis* measurement approach.
- **Ward Cunningham (OOPSLA '92)** — origin of "technical debt". **David Parnas (1972)** — modularity. **Lilienthal, *Sustainable Software Architecture*** — the full cognitive-science treatment.
- **DDD, Quasar, Hexagonal architecture** — the named approaches for separating domain from technical code (criterion 3.4).
