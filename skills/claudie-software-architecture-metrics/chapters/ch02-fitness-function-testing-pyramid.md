# Chapter 2: The Fitness Function Testing Pyramid — An Analogy for Architectural Tests and Metrics

**Author**: René Weiss

## Core Idea
A fitness function is your written **definition of "good"** for a system quality; classify your fitness functions into a pyramid (many cheap triggered-atomic at the base, few expensive continual-holistic at the top) so your portfolio of architectural tests balances cost, speed, and confidence — exactly as the functional testing pyramid does for functional tests.

## Frameworks Introduced

- **Fitness function** (Ford/Parsons/Kua) — "an objective function used to summarize how close a prospective design solution is to achieving the set aims."
  - **When to use**: any time you want a metric tailored to *your* system's quality goals rather than a generic tool default.
  - **How**: write one line containing (a) the **target metric**, (b) the **fitness function context** (environment, definitions, limitations, when to run), (c) the **failure condition**.
  - Automation is *recommended, not required*.

- **The fitness function concept map** — four interlinked artifacts, and the order they're created in:
  1. **Fitness function** — defines the target metric and the context.
  2. **Fitness function context** — environment, definitions, limitations influencing the test.
  3. **Target metric** — the discrete value you want.
  4. **Architectural test** — produces (and usually verifies the threshold of) the metric.
  - **Critical sequencing rule**: fitness function + context + target metric are defined **at design time, together**. The architectural test is built *afterward* and is **not** part of the definition. Engineering creativity (new tools, system changes) belongs in the test, not in the goal.

- **Architectural test vs functional test** — a functional test asks "can I create a customer?"; an architectural test asks "can I create 10 customers *and* hit a quality goal?" (e.g. produce a duration metric and assert it's under 10 ms). Use the terms *architectural test* / *architectural verification* deliberately to keep the distinction visible.

- **Fitness function categories (dimensions)** — a catalog to pick from when defining a fitness function; also a gap-finder that shows which quality areas you haven't covered. Six mandatory, four optional.

- **The Fitness Function Testing Pyramid** — layer assignment driven by just **two** of the categories: **breadth of feedback** (atomic vs holistic) × **execution trigger** (triggered vs continual). Ford/Parsons/Kua call these two a natural "mash-up".
  - **Top layer** — *holistic + continual*. Closest to real-world use; hardest and costliest to build; more prone to nondeterminism; root cause hardest to isolate. Keep only a few genuinely good ones. Includes production KPI corridors and chaos engineering.
  - **Middle layer** — *triggered holistic* **or** *continual atomic*. Integration-test builds against a test stage; or live monitoring of a single value (transaction duration, browser load time).
  - **Bottom layer** — *triggered atomic*. Cheap, fast, usually already in CI/CD: coverage, cyclomatic complexity, simple performance tests. Build a **broad base** here.
  - **Where the analogy breaks**: nobody caps unit-test count, but you *should* cap bottom-layer fitness functions — every one carries overhead. More is not better.
  - Inverting the pyramid (mostly continual-holistic) is legitimate in some contexts; so is having no top or middle layer at all.

- **The 7-step development process** (fold into Scrum-style iterations):
  1. Work with key stakeholders to identify the most important **quality attributes**, set architectural goals, and document them.
  2. Draft fitness functions and target metrics into a **shared list or backlog**, tagging the categories you already anticipate.
  3. Prioritize and select the ones that are important, helpful, and **feasible to test right now** — checking uncovered dimensions and pyramid balance. First time round, start with something simple from the bottom.
  4. Finalize the unfinished definitions among your selections, keeping the full categorization and pyramid layer.
  5. Develop an automated test that produces the metric (and ideally asserts the threshold directly).
  6. **Visualize** the results on a dashboard for the team and relevant stakeholders.
  7. **Iterate regularly** — decommission unreliable or low-value tests; tighten metrics as the system improves, loosen them when goals shift.

## Key Concepts
- **Target metric** — the discrete value a fitness function aims at.
- **Fitness function context** — environment, definitions, and limitations that make the metric meaningful and testable.
- **Atomic** — verifies a partial/limited aspect; passing says nothing about whole-system behaviour.
- **Holistic** — verifies that a large part of the system performs as intended for end users; harder to build and maintain.
- **Continual** — evaluated continuously, independent of development activity (usually production monitoring).
- **Triggered** — run by a CI workflow, developer action, or schedule (e.g. nightly).
- **Static fitness function** — target metric is a fixed value (coverage > 90%).
- **Dynamic fitness function** — target metric is a *range in relation to another value* (response time 50–100 ms for 10 000–100 000 concurrent users). Harder to automate, but tracks reality better.
- **Temporary vs permanent** — mark a fitness function temporary when its validity is bounded by design (e.g. supporting a long refactoring); "permanent" means no planned end date, not forever.
- **Quality attribute requirements / quality goals** — one of the three drivers of architecture (with functional requirements and constraints); define *how well* things must work.

## Reference Tables

**Mandatory categories**

| Category | Possible values |
|---|---|
| Breadth of feedback | Atomic or holistic |
| Test execution trigger | Triggered or continual |
| Execution location | CI/CD, test environment, production system, … |
| Metric type | True/false, discrete value, time series/historical values |
| Automation | Automated or manual |
| Quality attribute | ISO 25010: functional suitability, performance efficiency, compatibility, usability, reliability, security, maintainability, portability |

**Optional categories**

| Category | Possible values |
|---|---|
| Temporary or permanent | Temporary or permanent |
| Static or dynamic | Static or dynamic |
| Target audience | Yours to specify (developers, product owners, ops…) |
| Applicability | Yours to specify (JavaScript frontends only; service A vs service B) |

**ISO/IEC 25010 quality attributes → subattributes** (the catalog the chapter uses)

| Attribute | Subattributes |
|---|---|
| Functional suitability | completeness, correctness, appropriateness |
| Performance efficiency | time-behavior, resource utilization, capacity |
| Compatibility | coexistence, interoperability |
| Usability | appropriateness recognizability, learnability, operability, user error protection, UI aesthetics, accessibility |
| Reliability | maturity, availability, fault tolerance, recoverability |
| Security | confidentiality, integrity, nonrepudiation, accountability, authenticity |
| Maintainability | modularity, reusability, analyzability, modifiability, testability |
| Portability | adaptability, installability, replaceability |

*(FURPS — functionality, usability, reliability, performance, supportability — is the named alternative catalog.)*

**Pyramid layer decision**

| Breadth × Trigger | Layer |
|---|---|
| Holistic + continual | Top |
| Holistic + triggered | Middle |
| Atomic + continual | Middle |
| Atomic + triggered | Bottom |

## Worked Example

Five fitness functions, written in the author's one-line form, with full categorization:

**Bottom layer — coverage**
```
Unit Test Coverage > 0.9;
Execute on each CI Build; Fail when below target coverage
```
```
Integration Test Coverage > 0.5;
Execute on each nightly integration test build;
Fail when below target coverage
```
→ atomic · triggered · CI/CD · specific value (>90%) · automated · **maintainability** · static.
Rationale for the quality attribute: good coverage is treated as an *indicator* that the system can be adapted and changed more easily.

**Middle layer — resilience to third-party latency**
```
Integration test errors = 0% (when network latency is 10s for third-party API call);
Execute on each nightly integration test build; Fail when integration test fails
```
→ atomic *or* holistic (depends on how central that third party is to your use cases) · triggered · CI/CD **and** test environment · metric type 0/1 · automated · **reliability** · static.

Extended with a second metric so it also proves the fallback mechanism performs:
```
Integration test errors = 0% (when network latency is 10s for third-party API call);
Execute on each nightly integration test build; Fail when integration test fails;
Fail when test execution duration is > 10 minutes (standard execution time,
without network latency is below 5 minutes)
```
→ two metric types (0/1 plus a discrete duration) · **reliability + performance efficiency**. The threshold is deliberately *double* the no-latency baseline.

**Top layer — production revenue corridor (online shop)**
```
Measure revenue per minute throughout the day. Fail when revenue per minute,
based on current time, is out of the corridor provided by the following table:
```
| Time frame of day | Min revenue (per min) |
|---|---|
| 01:00–05:00 | €200 |
| 05:01–07:00 | €400 |
| 07:01–09:00 | €600 |
| 09:01–11:30 | €900 |
| 11:31–13:30 | €1100 |
| 13:31–17:30 | €950 |
| 17:31–19:30 | €1500 |
| 19:31–21:00 | €750 |
| 21:01–00:59 | €300 |

→ **holistic** · **continual** · production · discrete value · automated · *multiple* attributes (reliability, performance efficiency, usability, …) · **dynamic**. A deviation flags an underlying technical problem, possibly introduced by the last deployment.

**Top layer — zero-downtime rolling deploy (online shop reliability)**
```
Deploy the new release to our production system (at night, 01:00 AM).
While the release is rolled out, constantly perform the regression test set
containing the 5 main end user use cases (login, put item to cart,
remove item from cart, view cart, checkout). The system performs all actions
and responds within 100ms. Fail when test case fails;
Fail when system doesn't perform actions and respond < 100ms
```
→ holistic · **triggered** (nightly) · production · two metric types (discrete latency + 0/1 availability) · automated · reliability + performance efficiency · static.

Note the author's own caveat: real categorizations are frequently **not black-and-white**, and that's fine — the categories exist to be a checklist and a gap-finder, not a taxonomy to win arguments.

## Anti-patterns
- **Automating tests because they're easy rather than because they serve a quality goal** — the author has "often seen" this add little or no value. Goals first.
- **Trying to identify all fitness functions up front** — as impossible as knowing all requirements up front. Start small, learn from implementation, extend.
- **Testing arbitrarily** — loses focus on the qualities that matter (performance, security, modifiability).
- **Maximizing bottom-layer fitness functions** — unlike unit tests, each one carries real overhead.
- **Baking the test implementation into the fitness function definition** — the definition is the goal; the test is the engineering.
- **Keeping unreliable or obsolete fitness functions alive** — decommission them in step 7.

## Key Takeaways
1. Write the fitness function, its context, and its target metric at design time; build the architectural test after.
2. The fitness function is your definition of "good" — one line: metric, context, failure condition.
3. Use the six mandatory categories as a checklist for every fitness function, and as a map of which quality attributes you've left uncovered.
4. Layer assignment needs only two dimensions: atomic-vs-holistic × triggered-vs-continual.
5. Broad cheap base, deliberately few top-layer tests; the pyramid shape is the default, not a law.
6. Start from stakeholder-aligned quality goals (ISO 25010 or FURPS as the catalog), never from available tooling.
7. Metrics are the objective: unbiased measures that keep a team focused on aligned goals.

## Connects To
- **Ch 8** (Ford): the path *from* metrics *to* fitness functions and automation — the natural next step.
- **Ch 7** (Woods): fitness functions listed as one of five measurement approaches; quality-attribute-driven measurement.
- **Ch 9** (von Zitzewitz): supplies concrete bottom-layer atomic metrics (coupling, cyclomatic complexity) and their thresholds.
- **Ch 10** (Keeling): GQM is the complementary technique for *discovering* which metrics to write fitness functions for.
- **Building Evolutionary Architectures** (Ford, Parsons, Kua) — origin of fitness functions and most categories.
- **Martin Fowler, "TestPyramid"**; **ISO/IEC 25010**; **Bass/Clements/Kazman, *Software Architecture in Practice***.
