---
name: claudie-software-architecture-metrics
description: "Knowledge base from \"Software Architecture Metrics: Case Studies to Improve the Quality of Your Architecture\" (O'Reilly, 2022) by Christian Ciceri, Dave Farley, Neal Ford, Andrew Harmel-Law, Michael Keeling, Carola Lilienthal, João Rosa, Alexander von Zitzewitz, René Weiss, and Eóin Woods. Use when choosing or designing architecture metrics, applying the four key DORA metrics, writing fitness functions, scoring technical debt with the Modularity Maturity Index, measuring coupling/cycles/complexity/maintainability, running GQM or EventStorming workshops, connecting KPIs to architecture, or studying and referencing the book."
---

<!-- argument-hint: [topic, metric name, framework name, or chapter number] -->

# Software Architecture Metrics
**Authors**: Christian Ciceri, Dave Farley, Neal Ford, Andrew Harmel-Law, Michael Keeling, Carola Lilienthal, João Rosa, Alexander von Zitzewitz, René Weiss, Eóin Woods (O'Reilly, 2022) | **Pages**: 217 | **Chapters**: 10, one per author | **Generated**: 2026-08-08

## How to Use This Skill

- **Without arguments** — load the core frameworks below for reference
- **With a topic** — ask about `fitness functions`, `technical debt`, `cyclic dependencies`, `availability`, `GQM`; I find and read the relevant chapter
- **With a chapter** — ask for `ch09`; I load that chapter file
- **Browse** — ask "what chapters do you have?" for the full index

When you ask about a topic not covered below, I read the relevant chapter file before answering.

---

## Core Frameworks & Mental Models

### The through-line of the whole book
**A metric is only a measure. It becomes engineering when it is applied regularly and automatically against an objective threshold.** (Ch 8) Every chapter is a variation on this: choose metrics from goals rather than from tooling, wire them into the build or the dashboard, and act on them.

### The Four Key Metrics (DORA) — Ch 1
- **Deployment frequency** + **lead time for changes** = *development throughput*
- **Change failure rate** + **time to restore service** = *service stability*

Track **all four together** — improving one pair while degrading the other is unbalanced improvement that never pays off. Instrument **four points**, not four metrics: commit timestamp, production-deploy timestamp, failure-ticket open, failure-ticket close. Fix one **scope** and apply it identically to all four. Ship a **Minimal Viable Dashboard** (a wiki page: values, definitions, windows, raw history, data sources) on day one; automate second. Report windowed aggregates — 31 days for the first three, ~120 days for time to restore. The payoff is not the numbers: it's that teams start surfacing coupling, fuzzy domain boundaries, untestable modules, and unobservable services themselves.

### Fitness functions — Ch 2, Ch 7, Ch 8
**"Any mechanism that provides objective evaluation criteria for architecture characteristic(s)."** A fitness function is your written **definition of "good"**: one line containing the **target metric**, the **context** (environment, definitions, when to run), and the **failure condition**. Define metric + context + target **at design time**; build the architectural test **afterward** — the test is engineering, not part of the definition.

Classify each one on six mandatory dimensions: **breadth of feedback** (atomic/holistic), **execution trigger** (triggered/continual), **execution location**, **metric type**, **automation**, and **quality attribute** (ISO 25010). Layer in the **Fitness Function Testing Pyramid** using just the first two: broad cheap base of triggered-atomic, deliberately **few** continual-holistic at the top. Unlike unit tests, every bottom-layer function carries overhead — more is not better.

A fitness function is **not** a measurement mechanism; it *consumes* measurements (Ch 7). If you can't measure a characteristic objectively, it is probably **composite** (like *reliability*) — decompose it until you can (Ch 8).

### Testability and deployability as the two levers — Ch 3
The attributes of testable code — **modularity, cohesion, separation of concerns, abstraction, managed coupling** — are *identical* to the attributes of changeable code. So designing for testability **amplifies developer talent** instead of relying on skill, experience, and motivation. At systemic scale, the **deployment pipeline defines releasability**: if you must test more broadly after it passes, it doesn't determine releasability at all. Its scope is always **an independently deployable unit**. Optimize these two and every other quality (security, scalability, resilience) stays cheap to add later — pre-optimizing them is overengineering for needs that may never arise.

### Modularity Maturity Index — Ch 4
A 0–10 technical-debt score built on the three brain mechanisms for handling complexity: **modularity 45% + hierarchy 30% + pattern consistency 25%**. Read it as a decision: **<4 consider replacing · 4–8 renew (usually cheaper than replacing) · >8 leave alone.** Distinguish **implementation debt** (code smells; tool-findable; pay down in daily work, no extra budget) from **design and architecture debt** (needs a target-vs-actual architecture review workshop). Maintenance pushes debt up, architecture improvement pulls it down; deny the team that alternation and **architecture erosion** is inevitable — the tell is *less functionality delivered per unit of time*.

### Coupling, cycles, and maintainability — Ch 9
**Entropy is the enemy; cycle groups are its measurable form.** Past a certain size they self-amplify ("code cancer") — Apache Cassandra went 450 → 900 → 1,300 elements across three major versions, with 102 of 113 packages in one group. So **cap cycle size** rather than chasing purity: ≤5 elements for components, **zero tolerance** for package/namespace cycles, never spanning namespaces. Every cycle can be broken — dependency inversion, lifting, demoting, or moving functionality.

Read metrics in pairs: **ACD** with component count, **PC** (`= CCD/n²`) with ACD, **Relative Cyclicity** with **SDI** (which alone estimates *remediation effort*). Adopt **5–6 rules**, not more, and verify them in CI.

### Measurement in the architecture cycle — Ch 7
Measurements → prioritization → architectural decisions → system change → more measurements. Classify every measurement **artifact/operational × external/internal**; each quadrant has a distinct earliest-available point and blind spot. Five approaches: runtime telemetry (**logs, traces, metrics**), software analysis, design analysis, estimates/models, fitness functions. **Start small, measure something that matters, act on it visibly, start early, make it visible, make it continuous** — and periodically switch measurements off.

### Connecting metrics to the organization — Ch 6
Architecture is **sociotechnical**. Make it **intentional**: visualize the flow of work (**Big Picture EventStorming** → emergent domains → components → ownership → domain KPIs; then **Process Modeling EventStorming** on one value stream, asking *"where does the company make money?"*). Link it in a **KPI Value Tree**: organizational KPIs (lagging) → domain KPIs (lagging) → metrics (leading). Change the architecture via **experiments whose hypotheses are stated in metrics**. **Metrics change faster than goals; trends and metric combinations carry more signal than single values.** KPIs are guides, not targets (Goodhart's Law) — and never rank teams on them.

### GQM — Ch 10
**To measure something well you must understand why you're measuring it.** Goal (purpose, object, issue, point of view) → operational questions ("closer or further?") → metrics → data, with **traceability from any leaf back to the root**. Prune for strong signals and reuse; include **both positive and negative metrics**. The hidden benefit: asking *"where does this data come from?"* reliably exposes gaps in the architecture. "A metric by itself can only tell you something is wrong. It can't tell you what to do about it."

### Surviving a broken transition — Ch 5
When "DevOps" has become a ticket-driven automation team (**ownership shift**), you can't fix broken builds and can't trust the pipeline as validation authority. Move validation to the **private build** — an integration build in an environment you control, *before* changes hit the mainline; manual is acceptable temporarily. Diagnose with the triple: **Time to Feedback** (qualitative, indirect), **Evitable Integration Issues per iteration** (quantitative, indirect), **Time Spent Restoring Trunk Stability per iteration** (quantitative, **direct**).

---

## Chapter Index

| # | Title | Author | Key Frameworks |
|---|-------|--------|----------------|
| [ch01](chapters/ch01-four-key-metrics-unleashed.md) | Four Key Metrics Unleashed | Andrew Harmel-Law | Four key metrics, four instrumentation points, mental-model refactoring, Minimal Viable Dashboard |
| [ch02](chapters/ch02-fitness-function-testing-pyramid.md) | The Fitness Function Testing Pyramid | René Weiss | Fitness function definition, 6+4 categories, the pyramid, 7-step development process, ISO 25010 |
| [ch03](chapters/ch03-evolutionary-architecture-testability-deployability.md) | Evolutionary Architecture: Testability and Deployability | Dave Farley | Five attributes of sustainable change, testability as design amplifier, deployment pipeline scope |
| [ch04](chapters/ch04-modularity-maturity-index.md) | Improve Your Architecture with the MMI | Carola Lilienthal | MMI (45/30/25), technical-debt corridor, architecture review workshop, full scoring tables |
| [ch05](chapters/ch05-private-builds-and-metrics.md) | Private Builds and Metrics | Christian Ciceri | Ownership shift, private build, three process metrics, interpretation matrix |
| [ch06](chapters/ch06-scaling-an-organization.md) | Scaling an Organization | João Rosa | KPI Value Tree, EventStorming (Big Picture + Process Modeling), metric-guided experiments, Conway's Law |
| [ch07](chapters/ch07-role-of-measurement.md) | The Role of Measurement in Software Architecture | Eóin Woods | Measurement taxonomy, five approaches, performance/scalability/availability/security measurement, pitfalls |
| [ch08](chapters/ch08-metrics-to-engineering.md) | Progressing from Metrics to Engineering | Neal Ford | Architecture fitness function, automation as governance, ArchUnit, Scientist, checklist framing |
| [ch09](chapters/ch09-metrics-for-maintainability.md) | Using Software Metrics to Ensure Maintainability | Alexander von Zitzewitz | ACD/PC, Relative Cyclicity, SDI, Maintainability Level, complexity metrics, golden rules |
| [ch10](chapters/ch10-goal-question-metric.md) | Measure the Unknown with GQM | Michael Keeling | GQM tree, pruning and prioritization, GQM workshop, operational readiness package |

## Topic Index

- **ACD / CCD / Propagation Cost** → ch09
- **ArchUnit / NetArchTest** → ch08
- **Architecture erosion / structural erosion** → ch04, ch09
- **Availability, MTBF, MTTR, RPO, RTO, "nines"** → ch07
- **Big ball of mud (and distributed)** → ch06, ch09
- **Change failure rate** → ch01, ch06
- **Chaos engineering** → ch02, ch03
- **Cognitive load** → ch06
- **Complexity (cyclomatic, indentation, size)** → ch09
- **Continuous integration / delivery** → ch03, ch05, ch08
- **Conway's Law** → ch06
- **Coupling** → ch03, ch04, ch08, ch09
- **Cyclic dependencies / cycle groups** → ch04, ch08, ch09
- **Deployability / deployment pipeline** → ch03, ch08
- **DevOps culture, ownership shift** → ch05
- **DORA / four key metrics** → ch01, ch06
- **EventStorming** → ch06
- **Fidelity fitness function / Scientist** → ch08
- **Fitness functions** → ch02, ch06, ch07, ch08, ch09
- **GQM (Goal-Question-Metric)** → ch10
- **Governance automation, zero-day sweep** → ch08
- **ISO 25010 / FURPS quality attributes** → ch02
- **KPI Value Tree, leading vs lagging** → ch06
- **LCOM4, Component Rank** → ch09
- **Lead time for changes** → ch01, ch06
- **Maintainability Level (ML)** → ch09
- **Measurement taxonomy (artifact/operational, external/internal)** → ch07
- **Metrics-based feedback loop** → ch09
- **MMI (Modularity Maturity Index)** → ch04
- **Modularity, cohesion, separation of concerns, abstraction** → ch03, ch04
- **Observability (logs, traces, metrics)** → ch07
- **Pattern consistency** → ch04
- **Performance and scalability measurement** → ch07
- **Private builds, trunk stability** → ch05
- **Runbooks, ADRs, diagnostic APIs** → ch10
- **Security measurement** → ch07, ch08
- **SDI (Structural Debt Index), Relative Cyclicity** → ch09
- **Team Topologies / sociotechnical architecture** → ch06
- **Technical debt** → ch04, ch08, ch09
- **Testability** → ch03
- **Testing pyramid (functional and fitness function)** → ch02
- **Time to restore service** → ch01, ch07
- **Verticalization** → ch09
- **Version-control / change-history metrics** → ch09

## Supporting Files

- [glossary.md](glossary.md) — every significant term with its definition and chapter
- [patterns.md](patterns.md) — all 22 techniques with when-to-use, how, and trade-offs
- [cheatsheet.md](cheatsheet.md) — decision rules, thresholds, lookup tables, tells and smells

---

## Scope & Limits

This skill covers the book's content only. It is a **multi-author collection**: the chapters sometimes disagree in emphasis (e.g. Ch 9 wants 5–6 hard rules in CI; Ch 7 warns against measuring too much), and those tensions are preserved rather than smoothed over. Tool availability and version details reflect early 2022 — verify current tool support before recommending. For applying these metrics to a specific codebase, combine with project-specific analysis tools and language-specific skills.
