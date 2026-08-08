# Chapter 7: The Role of Measurement in Software Architecture

**Author**: Eóin Woods

## Core Idea
Continuous architecture leaves you with one hard question — *have I done enough architecture work, on the right things?* Measurement is the answer: measure quality attributes at a point in time to see where you are, measure them over time to see where you're headed, and use both to prioritize architectural attention rationally instead of by instinct or method.

## Frameworks Introduced

- **The measurement–architecture cycle** — measurements (from the delivery pipeline and every deployed environment) → inform work and prioritization → architectural decisions → system changes → more measurements reveal whether the decisions worked → repeat. Extraction must be **continuous and frequent**.

- **The 2×2 measurement taxonomy** — classify every measurement on two axes: **artifact vs operational** and **external vs internal**. Classify as you go, to understand each one's value *and* limitations.

  | | **External** (visible to / affecting people outside the delivery & ops teams) | **Internal** (visible to / affecting the delivery & ops teams) |
  |---|---|---|
  | **Artifact** (from documents, code, designs) | Compliance with a standard or guidelines via design documentation. **Weakest type** — judgment-based — but the **earliest available**, as design ideas emerge. Good for building stakeholder confidence (e.g. GDPR compliance, alignment with a best-practice standard) | Code complexity, module coupling, number of DB schema elements. **Tangible, accurate, quick, inexpensive.** Good indicators of maintainability and extensibility. Downside: the artifact (usually code) must exist first |
  | **Operational** (from the running system) | Response time, throughput, time to recover from failure, failures per month — the classical quality-attribute measures. Requires an operational system, but **captures what users experience** | Memory usage, DB index growth vs data growth. Requires an operational system; provides an internal reality check and is **often useful for predicting future problems** |

  Different types are relevant at different lifecycle points — over time you use them all.

- **Five measurement approaches**:
  1. **Runtime measurement of applications and infrastructure** — via **logs** (sequences of timestamped event records showing what happened in a component over time), **traces** (collections of directly related events recording an end-to-end cross-component scenario, e.g. request handling), and **metrics** (direct numerical measurements of characteristics over a period, e.g. VM CPU usage, image-store size) — Sridharan, *Distributed Systems Observability*. **Infrastructure** telemetry is usually easy (cloud platforms provide all three); **application** telemetry needs work (implement it or reuse an APM tool) but is **context specific**, which is what lets you measure what stakeholders actually care about — business metrics like revenue generated, not just technical ones.
  2. **Software analysis** — "the code doesn't lie." Static analysis is highly developed, but **limited to common programming mistakes and structural characteristics**, so it mostly informs maintainability and extensibility. For security it works as a **proxy** (count of vulnerabilities found).
  3. **Design analysis** — because code analysis is retrospective, capture *some* aspects of the design before implementation to get **predictive** measurements (standards compliance, likely scalability). **Not** old-fashioned detailed design documents (out of date the moment they're finished) — a **minimal but accurate representation**.
  4. **Estimates and models** — build mathematical models (usually a spreadsheet) from your own prior experience, measurements of similar systems, and published benchmarks, capturing the relationships between operational parameters (database size, request volume, request types, server count, memory) and the resulting quality-attribute values. Limits: works best for numerically expressible qualities (scalability, performance), poor for security; hard and expensive to keep a model both simple enough to understand and reliable; and the predictive power can't be validated until the system exists — at which point you can just measure it.
  5. **Fitness functions** (Ford, Parsons, Kua) — **not a measurement mechanism** but a mechanism for *using* measurements to keep quality attributes within an acceptable range. A fitness function defines the acceptable value(s) for one or more quality attributes **plus how to check** the system exhibits them. Ideally automated; **manual ones (a spreadsheet calculation) can still be valuable**. Example: if all requests of a type must complete within 100 ms, run an automated fitness function in production that monitors request times and alerts when they slip.

- **Six "getting started" rules**:
  1. **Start small** — measuring everything easily measurable *looks* like progress but costs a lot and yields few useful measurements. Pick a few things that enable action.
  2. **Measure something that matters** — the easy place to start is what's easy to measure; the *right* place is what will have real impact on your work.
  3. **Act on what you measure** — visibly use the insight to drive action, e.g. choosing which quality attribute to work on next.
  4. **Start early** — a range of measurement types lets you begin far earlier than production.
  5. **Make measurement visible** — report regularly and surface outputs in the project environment, so people with influence understand what's measured and what effect it's having. It may inspire others.
  6. **Make measurement continuous** — integrate it into the delivery cadence so people building each part are thinking about what measurements would help and how to build the mechanisms in.

## Key Concepts
- **Performance** — how quickly the system processes a specified piece of workload. Measured as **latency** (time to complete one piece of work) and **throughput** (instances completed in a set time); the two should be inversely proportional. Two determinants: **how much work must be done** and **how efficiently it can be done** (e.g. whether DB access uses an index).
- **Scalability** — how the system's workload capacity varies in response to available resources (CPU, memory, storage, network). Ideally **linear** (+50% resources → +50% workload); rarely achieved. Multifaceted: request-processing capacity, batch throughput, data storage capacity, and **organizational (people and process) capacity**.
- **Performance ≠ scalability** — but performance degradation is usually the **first indicator** of a scalability problem.
- **Availability** — the proportion of a specified period the system's services were usable; affected by both planned (maintenance) and unplanned (failures) unavailability.
- **MTBF (mean time between failures)** — how often the system fails (reliability).
- **MTTR (mean time to recover)** — how long recovery takes. John Allspaw (2010): **time to recover is often more important than how often incidents occur.** Its advantage: you can design for it, estimate it, and test it *while building*, whereas MTBF can only be estimated after many failures.
- **RPO (recovery point objective)** — how much data you're prepared to lose, in time or transactions ("10 minutes of updates", "100 transactions").
- **RTO (recovery time objective)** — how long you're prepared to wait for data to be available after a failure. **RPO and RTO are usually inversely related**: accept an RPO of infinity and RTO approaches zero; make every byte valuable and RTO grows. RTO affects MTTR but differs from it — a system may restore service on partial data, giving RTO > MTTR.
- **Security proxy measurements** — static code analysis (potential vulnerabilities in code), **dynamic analysis** (automated and manual penetration testing against test or operational deployments), and **infrastructure scanning**. Weight by risk (likelihood × impact) and aggregate. This measures *the results of testing processes* rather than actual security — but proxies are the best available way to judge whether security is getting better or worse.

## Reference Tables

**Common problems, by quality**

| Quality | Problem | Detail |
|---|---|---|
| Performance | Testing vs reality | Hard to make a test environment behave like production — realistic stored data, workload patterns, identical resources and configuration. If you don't know how representative it is, you don't know how useful the numbers are |
| | Models vs reality | Predictive power is even harder to know. **Test as early as possible to calibrate and validate**; be cautious about over-reliance |
| | Generating workload | High-fidelity, repeatable, useful workload generation is itself complex — especially where particular request/batch patterns must meet particular data patterns |
| | Intermittent phenomena | Distributed systems produce hard-to-reproduce effects. Tempting to ignore; instead **seize them as learning opportunities** — they may need architectural attention |
| | Missing logging | Many apps are built without logging for performance measurement; plan it early to avoid large retrospective work |
| | Overwhelming logging | Massive (often superfluous) logging produces data too voluminous to turn into reliable measurements. Needs a clear strategy and a configurable mechanism |
| Scalability | Unpredictable bottlenecks | Very common in complex distributed systems; until found and addressed they undermine the validity of your scalability numbers. Do as much **exploratory testing** as possible |
| | Unpredictable nonlinear behaviour | Added resources yield far less added workload than expected; measurements lose value unless you know where this happens. Design to avoid it, and explore to find it |
| | Combining resources | Most workloads need a *mix* (scaling a DB needs memory plus CPU plus disk I/O). Build combined measurements, e.g. CPU **and** memory required for web-request processing |
| Availability | Measuring MTBF | Only estimable via reliability models (weak for software failures) or from real failures — the thing you're avoiding. Practical fix: **borrow failure data from other systems you have access to, probably in your own organization**, as a proxy until you have your own |
| | Varying failure modes | MTTR/RPO are conceptually simple for one atomic component; real systems fail creatively. You need a *set* of MTTR/MTBF/RPO/RTO measurements and a deliberate way to combine them into a macro view |
| | **The tyranny of "the nines"** | 99.99% ("4 nines") ≈ 1 minute/week down; 99.999% ≈ 1 second/day — so close to 100% as to be fairly meaningless. It also ignores **failure mode and timing**, which dominate real impact. **Be wary of requirements stated in nines**; use **failure scenarios** to understand the business need instead |
| Security | Environment consistency | Configure test and operational environments as identically as possible, or results diverge |
| | Security identities | Don't reuse the same users/certificates across environments — and accept that this breaks the consistency you just asked for |
| | False positives | Static scanners produce many; **exclude them from measurements** or the picture looks worse than reality |
| | Adjusting for risk | Weighting by likelihood and impact is genuinely hard; consult experts, and expect judgment to improve with experience |
| | Knowing when to stop | You can't prove the absence of insecurity. Apply **expert judgment based on good data from a systematic, consistent approach** |

**How to measure each quality**

| Quality | Key measurement | Method |
|---|---|---|
| Performance | Response time | Synthetic workload (e.g. **Gatling** for APIs and web) in test or production, or built-in logging for retrospective analysis. **Never a single measurement** — characterize the *distribution* by mean, median, and standard deviation, then compare to the requirement and let the magnitude of the gap decide whether it needs architectural attention. Note the **cost trade-off**: performance can often be bought with more memory/faster CPU/faster storage |
| Scalability | Workload processed at an acceptable performance level, for a given resource level | E.g. requests processed in 5 s with mean response 0.5 s and 95th percentile under 2 s; then **increase resources in steps (~20%)**, re-measure throughput, and use the ratios to characterize scalability. Also measure storage required to meet requirements (indexing for performance, retention for regulation) and its cost — and **the number of people required to support the system at a given workload** (business-ops staff for exceptions, sysops staff for routine tasks) |
| Availability | MTBF, MTTR, RPO, RTO | Model and test MTTR/RPO/RTO during development; estimate MTBF roughly; combine into an availability estimate; refine with real measurements after incidents |
| Security | Count of incidents (lagging) plus weighted proxy metrics | Static analysis, dynamic/penetration testing, infrastructure scanning; risk-weighted and aggregated. **Don't wait for an incident to assess security** |

## Worked Example

**Civis — a citizen engagement platform** for a local government body serving 120,000 people: one unified digital interface for information, requests to departments, and service applications. Deep unknowns — which services will be popular, and how many users will engage — so the approach must be exploratory and incremental. Stack: Java services in containers on a public cloud, a managed relational database, an API gateway, plus web, Android, and iOS clients.

Measurements introduced, **in order**, each with its taxonomy classification and its purpose:

1. **Database size model** — *internal artifact, estimate*. A simple spreadsheet estimating table count, expected rows per significant table, and storage needed under different usage scenarios. Motivated by cost, performance, *and* flexibility. Purpose: decide whether the database design needs optimizing **at this stage**. Kept deliberately, for reuse later.
2. **Code complexity via static analysis** — *internal artifact*. Wired into the delivery pipeline and wrapped in a fitness function — at this stage "just a simple Python script to break the build if the complexity gets too high," called from a pipeline action. Purpose: signal when to spend time refactoring or rethinking architectural structure.
3. **Static security analysis** — *internal artifact*. An aggregated "vulnerabilities" metric stored on every pipeline run, so the **trend** of vulnerabilities introduced as code changes is visible. Acts as a proxy for security awareness and points at code areas needing attention. **Deliberately no automated fitness function yet** — the metric is expected to be unstable for a while. (Penetration testing is explicitly "not yet".)
4. **Response time metric** — *external operational*. A set of response-time measurements wrapped into a performance metric with automated tests runnable in CI; trends monitored; wrapped in an automated fitness function that alerts when it falls outside acceptable bounds. Purpose: trigger a system-level performance review. The same tests will be reused in the operational environment.
5. **Recovery time tests** — *internal and external operational*. Used to estimate how long recovery from different failures takes, and thus expected availability. Backed by **a spreadsheet model acting as a manual fitness function**. Purpose: signal when to review or redesign the recovery approach.
6. **Production usage, DB size, and per-table item counts** — *internal operational*. Started the moment code hit production; trends plotted and **compared against the original estimation spreadsheet** from step 1. Purpose: predict database growth and locate storage optimization work.
7. **Real availability from actual incidents** — *external operational*. Times between failures and recovery times recorded manually, real availability calculated and **reported in near-real time to stakeholders including area residents**. Purpose: address availability proactively, before it becomes a crisis.

Measurements continue to be **added and in some cases removed** as development proceeds — the point of the whole exercise being to know whether the system meets its quality-attribute requirements, whether the architecture is effective, and where attention has the greatest impact.

## Anti-patterns
- **Focusing on mechanisms rather than measurements** — measurement infrastructure is absorbing to build; you end up with impressive plumbing and few useful measurements. Start with the simplest mechanisms and add complexity only once the work delivers value.
- **Choosing measurements because they're easy** — code size, response times. Fine for early quick wins, but impact requires measuring what's most important *even when it's difficult*.
- **Focusing on technical over business measurements** — recovery time of a database is easier than revenue per hour, but a purely technical program never earns business stakeholders' understanding or value. Consider all stakeholder viewpoints.
- **Not taking action** — measuring, prioritizing, then doing nothing because there's always a crisis. Fix: reserve **a percentage of each sprint** for optimization or acting on measurement findings.
- **Prioritizing accuracy over usefulness** — there's a point past which more accuracy won't change any decision. Watch for it.
- **Measuring too much** — cheap platform capability lets the program become "a monster that generates huge amounts of data — and dozens of measurements of limited value." **Periodically review and switch measurements off.**
- **Deferring measurement until production**, even on iterative teams — the historical default this chapter exists to break.
- **Producing detailed design documents for design analysis** — out of date as soon as they're complete.
- **Accepting availability requirements stated in nines.**

## Key Takeaways
1. Measuring quality attributes is one of the few ways to know whether architecture work is effective — and it's how you decide where to spend the next hour.
2. Classify every measurement as artifact/operational × external/internal; each quadrant has a distinct earliest-available point and a distinct blind spot.
3. Fitness functions consume measurements, they don't produce them — you still need one of the five approaches underneath.
4. Design MTTR, RPO, and RTO in and test them; treat MTBF as borrowed or estimated until you've earned real data.
5. Security can only be measured by risk-weighted proxies — so measure them continually rather than waiting for an incident.
6. Characterize performance as a distribution, and derive scalability from stepped resource increases, not single data points.
7. Measurement forces you to make quality attributes measurable and requirements specific — and sometimes reveals where that isn't possible. That specificity is itself a benefit to stakeholder communication.
8. Start small, on something that matters, act on it visibly, and keep pruning.

## Connects To
- **Ch 2** (Weiss): fitness functions, their categories, and the quality-attribute catalog — this chapter supplies the measurement mechanisms underneath them.
- **Ch 8** (Ford): fitness functions and automation as the engineering step.
- **Ch 4** (Lilienthal) and **Ch 9** (von Zitzewitz): concrete internal-artifact measurements — coupling, complexity, structural erosion.
- **Ch 1** (Harmel-Law): time to restore service is the external-operational counterpart of MTTR.
- **Continuous Delivery** (Humble & Farley); **RCDA** (Poort & van Vliet); **Continuous Architecture in Practice** (Erder, Pureur, Woods); **Distributed Systems Observability** (Sridharan); **Building Evolutionary Architectures** (Ford, Parsons, Kua); **John Allspaw, "MTTR Is More Important Than MTBF"** (2010).
