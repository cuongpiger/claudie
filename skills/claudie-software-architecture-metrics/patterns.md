# Patterns & Techniques — Software Architecture Metrics

## Four Key Metrics Rollout (Ch 1)
**When to use**: starting any delivery-performance or architecture-modernization effort, especially when you want teams — not the architect — to drive improvement.
**How**: pick a scope and apply it identically to all four metrics → locate the four instrumentation points (commit timestamp, production-deploy timestamp, failure-ticket open, failure-ticket close) → publish a Minimal Viable Dashboard (wiki page: values, definitions, windows, raw history, data sources) → discuss weekly alongside spikes and ADRs → automate collection second.
**Trade-offs**: manual capture is honest but laborious; proxy trigger points (merge to `main`) hide branch wait time; the metrics only become architectural leverage if teams can self-serve their own pipelines' data.

## Fitness Function Definition (Ch 2, Ch 8)
**When to use**: any quality attribute you want held inside a range rather than measured once.
**How**: write one line containing the **target metric**, the **context** (environment, definitions, when to run), and the **failure condition**. Tag it with the six mandatory categories (breadth, trigger, location, metric type, automation, quality attribute). Build the architectural test **afterward** — it is not part of the definition. Then run it on every code change against an objective threshold.
**Trade-offs**: a definition without automation stays a metric; automation without a quality goal produces cheap tests that add no value. Manual fitness functions (a spreadsheet) are legitimate when automation isn't feasible.

## Fitness Function Testing Pyramid Balancing (Ch 2)
**When to use**: deciding which architectural tests to build next.
**How**: classify each candidate by breadth (atomic/holistic) × trigger (triggered/continual) → bottom = triggered atomic, middle = triggered holistic or continual atomic, top = continual holistic. Build a broad cheap base, deliberately few top-layer tests.
**Trade-offs**: unlike unit tests, *every* bottom-layer fitness function carries overhead — more is not better. Inverting the pyramid is legitimate in monitoring-heavy contexts.

## Architecture Review for Technical Debt (MMI) (Ch 4)
**When to use**: portfolio decisions about which systems to refactor, replace, or leave alone.
**How**: workshop with architects and developers — parse the source to capture the **actual** architecture → model the **target** on top of it → find simple refactorings (or conclude the code is better than the plan, or design a new target) → collect debts and candidate refactorings → review metrics for further debt. Score the criteria table, weight by principle, read the band: <4 consider replacing, 4–8 renew, >8 leave alone.
**Trade-offs**: several criteria are reviewer judgment, not measurement — so run reviews in pairs and discuss in a larger group for comparability. Cross-tool MMI comparison requires accounting for each tool's metric implementations.

## Private Build (Ch 5)
**When to use**: whenever automation and validation are owned by someone other than the development team, or trunk stability is poor.
**How**: in an environment you fully control, pull the latest mainline, build, and run API contract tests plus happy-path tests on globally important or changed functional areas — *before* pushing. Automate what repeats; keep the manual phase at smoke-test scope.
**Trade-offs**: costs check-in frequency and developer time, but far less than continuous trunk stabilization, QA round-trips, and ticket management. Not a complete validation, and not intended to be.

## Three-Metric Delivery Diagnosis (Ch 5)
**When to use**: diagnosing where a broken DevOps transition actually hurts.
**How**: track Time to Feedback (qualitative, indirect), Evitable Integration Issues per iteration (quantitative, indirect), Time Spent Restoring Trunk Stability per iteration (quantitative, **direct**). Read them as a *triple*, then apply the matching remedy from the interpretation table.
**Trade-offs**: Time to Feedback is qualitative and can be biased — cross-check it against the evitable-issue count before acting.

## EventStorming for Architectural Intentionality (Ch 6)
**When to use**: architecture drifted from domain boundaries; teams don't understand product direction; cognitive load suspected.
**How**: **Big Picture** — map business events and boundaries → overlay current software components → overlay ownership (this reveals cognitive load) → overlay domain KPIs. Then **Process Modeling** on one operational value stream, adding step-level KPIs and hotspots, and answering "where does the company make money?"
**Trade-offs**: expensive in time and stakeholder commitment; not a one-time activity. Expect KPI definitions to conflict — converging them *is* the value.

## KPI Value Tree (Ch 6)
**When to use**: justifying architectural work in business terms, or connecting engineering metrics to strategy.
**How**: three levels — organizational KPIs (lagging: EBITDA, CLV, MAU) → domain KPIs (lagging) → metrics (leading and lagging; DORA metrics live here). Maintain it as business forces change and question each entry's usefulness.
**Trade-offs**: needs senior-management buy-in and clear ownership or it goes stale. KPIs must stay guides, not targets (Goodhart's Law) — if you need a target, call it a target.

## Metric-Guided Architectural Experiment (Ch 6)
**When to use**: changing boundaries in a system you can't afford to break.
**How**: state the questions, design a staged experiment (e.g. new self-contained service as a **proxy** for the old one, dual-writing to both), state a **hypothesis in specific metrics** (deployment frequency up, change fail rate down on the decoupled service), communicate the capacity cost up front, run, then cut over on the evidence.
**Trade-offs**: feature delivery drops during the experiment; ownership changes carry social as well as technical consequences and must be made explicit.

## Measurement Taxonomy Selection (Ch 7)
**When to use**: choosing what to measure at a given point in the lifecycle.
**How**: classify candidates as artifact/operational × external/internal. External artifact is earliest but weakest (judgment-based); internal artifact is cheap and accurate once code exists; external operational captures user experience; internal operational predicts future problems.
**Trade-offs**: each quadrant has a distinct earliest-available point and a distinct blind spot — over a project's life you use all four.

## Availability Modeling with MTTR / RPO / RTO (Ch 7)
**When to use**: availability requirements, especially when someone hands you a number of "nines".
**How**: design for, estimate, and test MTTR, RPO, and RTO during development; borrow MTBF data from other systems in your organization as a proxy; combine per-component figures deliberately into a macro view; replace "nines" requirements with **failure scenarios**.
**Trade-offs**: RPO and RTO trade against each other; real systems fail in many modes, so any single availability number hides the mode and timing that determine impact.

## Security by Risk-Weighted Proxy (Ch 7)
**When to use**: always — don't wait for an incident.
**How**: continuously run static code analysis, dynamic/penetration testing, and infrastructure scanning; exclude false positives; weight findings by likelihood × impact; aggregate into a trend.
**Trade-offs**: you're measuring the results of testing processes, not security itself; risk weighting needs expert judgment; you can't prove absence, so stopping is a judgment call from systematic data.

## Automated Governance in the Pipeline (Ch 8)
**When to use**: replacing code reviews and architecture review boards as the enforcement mechanism.
**How**: encode the rule as a test (ArchUnit for Java, NetArchTest for .NET, hand-rolled from logs or monitors elsewhere), wire it alongside unit/functional/UAT stages, break the build on violation. Reserve a **security slot** in every pipeline — including idle projects — so a zero-day can be swept organization-wide.
**Trade-offs**: manual governance delays the check and requires superhuman diligence; automated governance can be overused into an interlocking maze that merely frustrates teams. Treat fitness functions as a checklist of important-but-not-urgent principles.

## Hand-Rolled Fitness Function from Telemetry (Ch 8)
**When to use**: distributed architectures, where no framework can encode your topology's rules.
**How**: declare the allowed communication rules in code, import each service's logs for a window (or subscribe to monitors), parse call destinations, raise on violation.
**Trade-offs**: forensic logs give a retrospective batch check; real-time monitors give event-driven alerts but need more plumbing.

## Fidelity Fitness Function (Scientist pattern) (Ch 8)
**When to use**: replacing a subsystem where an unknown coupling point could cause catastrophic failure.
**How**: wrap old and new in `use` / `try`. `use` always executes and is always what the user receives. Configure the `try` sampling rate (GitHub used 1%). The framework randomizes execution order, compares results, swallows-but-records `try` exceptions, and publishes to a dashboard. Cut over on an evidence threshold — GitHub required 24 hours with no mismatches or slow cases, after 10M+ experiments over four days.
**Trade-offs**: doubles work for sampled requests; needs a comparable-results definition; errors are invisible to users but must still be triaged.

## Cycle-Size Capping (Ch 9)
**When to use**: from day one on new projects; as the "stop the bleeding" first move on legacy ones.
**How**: threshold the largest component cycle group at ≤5 (warn at 6, optionally break the build); zero tolerance for package/namespace cycles; never let a component cycle span namespaces. Break cycles by dependency inversion, lifting to a higher-level class, demoting to a lower-level class, or moving functionality.
**Trade-offs**: small intra-package cycles do little harm — the pragmatic goal is preventing growth, not purity. Once a group reaches hundreds of elements there may be no natural break point at all.

## Maintainability Level as a Canary (Ch 9)
**When to use**: nightly tracking of design health; comparing systems across an organization; rewrite-vs-refactor decisions.
**How**: collapse cycle groups into logical nodes → levelize → compute per-node contribution → sum (ML1) → apply the >5-node cycle penalty (ML2) → apply the sliding minimum for <100-component modules (ML3) → compute the package-cyclicity alternative (MLalt) → weighted average by component count over the larger modules (until 75% of components or ≥100-component modules are covered).
**Trade-offs**: experimental, and only Sonargraph computes it. Component-level ML alone can score in the high 90s while the package structure is a mess — always check both.

## Hotspot Refactoring from Version Control (Ch 9)
**When to use**: choosing refactoring targets with limited budget.
**How**: intersect high `Number of Changes(d)` / `Code Churn Rate(d)` with high complexity; check whether the hotspots are also bottleneck classes. Use a software-city visualization (footprint = LoC, height = complexity, shade = change frequency) — tall dark buildings are the targets. Use `Number of Authors(365) = 1` separately to find knowledge monopolies.
**Trade-offs**: the metric pairing is arbitrary and worth varying (height = incoming dependencies, shade = complexity) for different questions.

## GQM Tree (Ch 10)
**When to use**: measuring something you don't yet understand — technical debt, design maturity, whether the architecture meets its quality attributes.
**How**: goal (purpose, object, issue, point of view) → operational questions ("closer or further?") → metrics per question → data per metric. Prune: keep strong signals, prefer metrics answering multiple questions, include both positive and negative metrics, prioritize data that feeds many metrics cheaply. Then plan collection and act.
**Trade-offs**: the goal will be revised — start with an imperfect one. Deriving data requirements doubles as an architecture review and will surface missing instrumentation and unassigned responsibilities.

## GQM Workshop (Ch 10)
**When to use**: building consensus and shared ownership over what gets measured.
**How**: draft the goal beforehand; 2–5 participants (always including a developer, and someone who knows the architecture for system goals); write the goal visibly → gather questions → brainstorm metrics per question, linking each metric to every question it answers → sanity-check against the goal and refine it → identify data → prioritize with **one** technique (must-haves, big-bang-for-buck, dot voting, or value/effort) → reflect → record and share. Photograph the tree.
**Trade-offs**: messy by nature; needs a follow-up meeting for precise metric definitions and prioritization. Larger groups need breakouts.

## Operational Readiness Package (Ch 10)
**When to use**: turning GQM output into something that survives an incident at 3am.
**How**: alerts on each identified metric → a **runbook per metric** that references the metrics (for diagnosis and false-positive filtering) → diagnostic APIs and recovery tooling → an **ADR** for each structural decision (e.g. "jobs fail fast; the queue owns retries").
**Trade-offs**: real work that some of the team will question after the root cause is already fixed — its value only shows at the next incident.
