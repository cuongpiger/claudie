# Cheatsheet — Software Architecture Metrics

## Which technique for which situation

| Situation | Use | Ch |
|---|---|---|
| Don't know *what* to measure | GQM tree: goal → questions → metrics → data | 10 |
| Know the quality goal, need enforcement | Fitness function + automated threshold in CI | 2, 8 |
| Need to justify architecture work to the business | KPI Value Tree (org → domain → metrics) | 6 |
| Which of our 40 systems get investment? | MMI score, read the 4/8 bands | 4 |
| Is our delivery capability improving? | Four key metrics, all four together | 1 |
| Pipeline is owned by others and unstable | Private builds + the three-metric triple | 5 |
| Is this codebase decaying? | Relative Cyclicity + SDI + Maintainability Level trend | 9 |
| Have I done enough architecture work? | Measure quality attributes now and over time | 7 |
| Replacing a subsystem safely | Fidelity fitness function (Scientist pattern) | 8 |
| Architecture drifted from the business | Big Picture then Process Modeling EventStorming | 6 |

## Decision rules

- **If you can't measure an architecture characteristic, it's probably composite — decompose it** until you can. (Ch 8)
- **If a metric isn't run regularly against a threshold, it is evidence after the fact, not governance.** Metric + threshold + automation on every change = engineering. Any two is not enough. (Ch 8)
- **If the fix requires superhuman diligence from a human, automate it instead** — that's the argument for pipeline governance over review boards. (Ch 8)
- **If a thing is hard to test, that's a design report, not a testing inconvenience.** Optimize testability and deployability; every other quality stays cheap to add later. (Ch 3)
- **If you're improving one pair of the four key metrics while degrading the other, stop** — unbalanced improvement never yields long-term value. (Ch 1)
- **If people start saying "we're not achieving KPI X", the KPI has become a target.** If you need a target, call it a target — reserve "KPI"/"metric" for guides. (Ch 6)
- **If the trunk is regularly broken, don't trust any architectural measurement of that system.** Fix trunk stability first. (Ch 5)
- **If a legacy codebase floods you with violations, loosen the goals to something achievable, then tighten.** Morale is the constraint. (Ch 9)
- **If a cycle group exceeds ~5 elements, fix it now** — the cost of breaking it grows superlinearly, and past a few hundred elements there may be no natural break point. (Ch 9)
- **If PC fell but component count grew, that's not improvement.** `PC = CCD/n²`, so doubling components needs 4× CCD to hold PC flat. (Ch 9)
- **If ML is high but developers say maintainability is bad, check the package structure** — component-level ML is blind to package cycles. (Ch 9)
- **If the requirement is stated in "nines", replace it with failure scenarios.** Mode and timing of failure dominate impact; 5 nines is too close to 100% to be meaningful. (Ch 7)
- **If you're picking metrics because they're easy, you're picking the wrong ones** — measure what matters even when it's hard, and reserve sprint capacity to act on findings. (Ch 7)
- **If your questions all have metrics but none indicate failure, add negative metrics** — they keep you honest. (Ch 10)
- **If asking "where does this data come from?" is hard, you've found an architectural gap** — not a tooling problem. (Ch 10)
- **If a tool already computes the metric, don't write your own** — advanced metrics require a compiler front end. (Ch 9)
- **Never compare teams on these metrics.** Contexts, domains, skills, and technology differ; ranking teams on DORA is the canonical misuse. (Ch 6)

## Thresholds & defaults

| Metric | Value | Ch |
|---|---|---|
| Biggest **component** cycle group | ≤ 5 elements | 9 |
| **Package/namespace** cycles | 0 — zero tolerance | 9 |
| Component cycles spanning namespaces | never | 9 |
| Maintainability Level | ≥ 75% (>90 = well designed; 20s = no architecture) | 9 |
| Relative Cyclicity | ≤ 4% components, 0% packages | 9 |
| Structural Debt Index | low 100s; goal ≈ 0 | 9 |
| Source file size | ~800 LoC (soft) | 9 |
| Statements per function/method | ≤ 100 | 9 |
| Cyclomatic Complexity | 15 (error rates climb above 24) | 9 |
| Max indentation level | 4 (soft) | 9 |
| Share of "complex" code | ≤ 10% of LoC | 9 |
| Number of metric-based rules | **5–6** — beyond that, diminishing returns | 9 |
| MMI weights | 45 / 30 / 25 (modularity / hierarchy / patterns) | 4 |
| MMI action bands | <4 replace · 4–8 renew · >8 leave alone | 4 |
| Four-key-metric windows | 31 days (freq, lead time, CFR); ~120 days (time to restore) | 1 |
| Prioritized quality attributes | ≤ 3 **plus maintainability** | 9 |
| GQM workshop size | 2–5 people, always incl. a developer | 10 |
| Scientist `try` sampling | 1% of requests; cut over after 24 clean hours | 8 |

**Propagation Cost by size**: `n < 500` → high values less concerning · `500 ≤ n < 5,000` → >20% concerning, >50% serious cycle problems · `n ≥ 5,000` → even 10% concerning.
**ACD is relative to n**: 100 is fine for 1,000 components, devastating for 100.

## Fitness function layer lookup

| Breadth × Trigger | Layer | Typical example |
|---|---|---|
| Holistic + continual | **Top** (few) | Production KPI corridor, chaos engineering |
| Holistic + triggered | **Middle** | Nightly integration suite on a test stage |
| Atomic + continual | **Middle** | Live transaction-duration monitoring |
| Atomic + triggered | **Bottom** (broad base) | Coverage, cyclomatic complexity, cycle checks |

## Measurement quadrant lookup

| | External | Internal |
|---|---|---|
| **Artifact** | Standards/GDPR compliance from design docs — earliest, weakest (judgment) | Complexity, coupling, schema size — cheap and accurate, needs code to exist |
| **Operational** | Response time, throughput, failures/month — captures user experience | Memory use, index-vs-data growth — predicts future problems |

## Tells & smells

- A change in one part breaks something **unrelated** → structural erosion. (Ch 9)
- Submodules couple more to *other* modules than to their siblings → modularity done badly. (Ch 4)
- Can't say what a unit's **single** task is, or its name is vague → unclear responsibilities. (Ch 4)
- One build unit holds 90%+ of the LoC → "Monolith and Satellites"; check criterion 1.1.3. (Ch 4)
- Release orchestration needed to ship one feature in one area → boundaries are misplaced. (Ch 6)
- Overlapping functionality across services → ownership can't be assigned. (Ch 6)
- A team owns components spanning unrelated domains → cognitive load, no single problem space. (Ch 6)
- Rising mean time to discover → growing complexity, or rising cognitive load. Pair with change fail rate to find weak points; pair change fail rate with employee NPS to find where staff need support. (Ch 6)
- Build broken and nobody on the team can debug or has permission to fix it → ownership shift. (Ch 5)
- API/contract tests written but never executed in the pipeline → immediately unmaintained. (Ch 5)
- QA reports "it's broken every time" → evitable integration issues; check the triple. (Ch 5)
- Impressive measurement infrastructure, few useful measurements → you optimized the mechanism. (Ch 7)
- Both jobs *and* the queue retrying → one failure became 50 API calls. (Ch 10)
- Telemetry only records under load → no signal exactly when you want early warning. (Ch 10)
- `Number of Authors(365) = 1` → knowledge monopoly. (Ch 9)
- Tall dark building in the software city → large, complex, frequently changed: refactor. (Ch 9)
- Executives asking for team rankings from DORA metrics → stop. (Ch 6)
- "We know this is bad, we'll fix it later" → the named mechanism of technical debt; encode it as a fitness function instead. (Ch 8)
