# Chapter 10: Measure the Unknown with the Goal-Question-Metric Approach

**Author**: Michael Keeling

## Core Idea
To measure something well you must first understand **why** you're measuring it — so work top-down from a goal, to the questions that would tell you whether you're closer or further from it, to the metrics that answer those questions, to the data that computes them. GQM's real power is on the problems you *don't yet understand*, and the act of tracing metrics back to data reliably exposes gaps in the architecture itself.

## Frameworks Introduced

- **The GQM approach** (Victor Basili & David Weiss, 1984) — an analysis technique for measuring and evaluating tough software problems. Easy to learn, straightforward to apply, usable alone or as a collaborative workshop. It "provides just enough structure to nudge teams toward better outcomes" — it doesn't remove the need for creativity and analytical thinking.
  - **When to use**: technical-debt questions, whether the implemented architecture satisfies key quality attributes, team design maturity — the "gnarly" problems where the alternative is a biased, unreliable gut feeling.
  - **The name almost says it all — three steps**: identify a goal → enumerate questions to evaluate the goal → define metrics that answer the questions. **Plus the step the name omits**: decide how to collect the data.
  - **Why it works**: teams that understand the *why* behind a metric are more likely to **use and trust** it to guide future decisions. GQM "transforms goals from mushy statements about our desires into quantifiable and verifiable models."

- **The GQM tree** — a hierarchy: **goal at the root** → branches to **questions** → branches again to **metrics** → **leaves are the data** used to compute the metrics.
  - **The property that matters is traceability**: you can trace any leaf (data being collected) back to the root (why you're collecting it at all).

- **Writing the goal** — an ideal goal statement describes four things: the **purpose**, the **object to be measured**, the **issue/topic of interest**, and the **point of view** from which you're considering it.
  - The goal can target anything: elements of the architecture, development processes, technical experiments, design artifacts, even teams and organizations. **Defining the object aligns what is measured with why.**
  - **Providing the goal up front is essential** — it establishes conceptual direction by focusing attention on a particular set of measures.
  - **The goal is often revised throughout the analysis** as understanding improves. **Even an imperfect goal statement that captures only the essence is useful.**

- **Asking the questions** — questions should be **operationally focused** and let you evaluate progress against the goal: *are you getting closer or further away?*
  - "Great questions can illuminate problems and potential next steps for fixing those problems. Asking good questions requires a curious mind. You must be willing to **temporarily let go of what is practical** and ask the questions that need to be asked, even if you are unsure how to answer them now."

- **Defining the metrics** — metrics can be **simple rubrics, Boolean values, statistical inferences, or equations of varying complexity**. Every metric you plan to use eventually needs a clear and precise definition. Each metric links to **at least one** question; one metric may answer several questions, and one question may need several metrics.

- **Pruning and prioritizing the tree** — "It's not enough to simply know how you *could* measure the goal. You must also plan for how you *will*." In practice not all metrics give a strong signal, and some are impractical or costly.
  1. Identify **key metrics that provide the strongest signals** first.
  2. Look for metrics that **answer multiple questions**.
  3. Where a question has multiple metrics, ask carefully whether all are necessary.
  4. **Include both positive and negative metrics** — ones that indicate success *and* ones that indicate failing — **to keep you honest**.
  5. Extend the tree down to **data**, so you can see where each piece of data is used. **The more metrics a piece of data helps compute, the more valuable that data is.**
  6. **Top priority = data that feeds high-value metrics and is inexpensive to collect.**
  - Then create a concrete plan (recording/collecting data, computing metrics, building dashboards), share it with the team and stakeholders, and act. **Depending on the goal, it may not be necessary to compute all metrics or answer all questions.**

- **Data sources by what you're measuring**:
  | What you're measuring | Where the data comes from |
  |---|---|
  | The running system | Instrument your code to record it |
  | Development processes or methods | Surveys, or harvested from task databases |
  | Code | Source-code repositories, or static-analysis tools |
  | Short, quick experiments | Often easiest and cheapest to **collect manually for a few days** |

- **The GQM workshop** — a structured collaborative format whose goal is **consensus and shared ownership** over the metrics and data. By the end, all participants should understand **why** particular metrics are necessary and **how** they will be calculated.
  - **Benefits**: stakeholder participation creates stronger buy-in and can lead to more thorough analysis; the workshop also demonstrates structured analysis to the group, and participants who enjoy it tend to apply GQM elsewhere.
  - **Participants**: technical *and* nontechnical. A business-process goal needs a subject-matter expert; a product-launch goal needs product management, marketing, design, and sales. **At least one software developer must always participate.** Best in groups of **two to five**; larger groups need breakout sessions.
  - **Preparation**: create a **draft goal statement before** the workshop — knowing the goal also tells you whether the right people are invited. Materials: on-site, a large whiteboard and markers (sticky notes optional, for brainstorming). Remote: a virtual whiteboard (e.g. Miro) preferred, or any shared editable document (Google Docs, Dropbox Paper); plain screensharing works "in a pinch" but makes stakeholder participation harder.
  - **Outcomes**: a goal phrase accepted by all stakeholders; a list of questions characterizing the goal; a prioritized list of metrics with references to the questions they answer; metric definitions (formal or informal); and a list of the data needed.
  - **The nine steps**:
    1. Introduce the workshop and share ground rules (including how to treat each other).
    2. **Write the goal statement where everyone can see it** — on a physical whiteboard, leave plenty of space for questions and metrics.
    3. Invite questions: *"What questions would you need to answer to know whether we've met this goal?"* Gather until time runs out or the group stalls.
    4. Pick a question and brainstorm metrics for it. **Draw a line from each metric to every question it can answer.** Encourage creativity; don't worry yet about computation or data.
    5. **Once every question has at least one metric, go back to the goal and sanity-check**: do these metrics evaluate this goal? Does the goal need rephrasing? Are there new goals to consider? Refine if necessary.
    6. Identify the data needed per metric; define metrics more precisely if needed.
    7. **Prioritize** — pick *one* technique: "must-have" metrics, "big bang for the buck" metrics answering more than one question, dot voting, or sorting by value/effort.
    8. Open the floor: any surprises? consensus on the most important metrics? any metrics that look problematic or costly?
    9. **After** the workshop, record and share the outcomes; prepare a report of the findings if needed.
  - **Facilitation hints**: one question per sticky note, then have a participant read them aloud, **cluster and de-duplicate** before moving on. If the group stalls on metrics, say *"Let's not worry yet about how we'll get the data — once we know what metrics we need, we can figure out how to compute them."* Look for chances to reuse metrics or data. For system-focused questions, **someone who knows the architecture must be present**, because the architecture determines the cost of data collection. **And take a picture of the GQM tree** — the quickest way to share the essence of the analysis.

## Key Concepts
- **Goal** — a simple statement of something you want to understand and measure.
- **Question** — operational, progress-evaluating, and allowed to be impractical to answer at first.
- **Metric** — anything from a rubric to an equation, precisely defined before use.
- **Data** — the leaves; valued by how many metrics it feeds and how cheap it is to collect.
- **Positive and negative metrics** — success indicators paired with failure indicators.
- **Key metric** — strong signal, ideally answering more than one question.

## Mental Models
- **"A metric by itself can only tell you something is wrong. It can't tell you what to do about it."** (the author's first team leader) — GQM supplies the context that makes a metric decipherable.
- **It's easy to find good metrics for things you understand deeply**; the most useful metrics measure things you don't yet fully understand — which are also the hardest to measure. That's the territory GQM is for.
- **Metric definition is a design activity.** Asking what data a metric needs is how you discover that your architecture can't produce it.
- Expect the process to be **messy**: questions and metrics "churned and evolved" as understanding deepened. Half an hour of iterating in a shared document was enough in the case study.

## Reference Tables

**Example goals focused on software architecture concerns** (note how each names an object *and* a point of view):
- Improve system availability **from the users' point of view**.
- Decrease the development time for new microservices **from the product managers' viewpoint**.
- Reduce technical debt in the architecture **from the perspective of software developers**.
- Reduce the number of bugs being released into production.
- Detect more problems in production before our users do.
- Improve the machine learning model's accuracy **from the users' viewpoint**.
- Make better design decisions in the architecture **from the development team's perspective**.

**Example questions for "improve system availability from the users' point of view"**:
- What is our current availability?
- Which components or services have the best availability? The worst?
- Which components or services go down the most?
- Why do components or services become unavailable?
- How long is a typical outage?
- When do outages happen?

## Worked Example

### The team that learned to see the future

**System context.** The system depends on third-party services for some data operations, several of which impose **API rate limits**. **Queues** ensure data is eventually processed and manage request volume. The critical dependency, the **"Foo Service"**, imposes an API request limit set in a licensing agreement: exceed it and requests are rejected with "rate limit exceeded" until the calculated rate falls back below the threshold. **Both hourly and daily limits** apply, plus limits on request size and total compute load.

Asynchronous work queues also drive workflows and other analysis; **when a queue grows too large, internal users are negatively impacted**. The queues are deliberately resilient — retrying certain kinds of failures — so that after a temporary disruption the system eventually reaches a correct, consistent state as long as queues and workers stay up. **Self-correction matters especially for the Foo Service, because its limits are easy to exceed but reset quickly.**

**Incident #1 — too many requests to the Foo Service.** In the small hours of a Monday, the Foo Service began rejecting requests. Because its rate limit is **a shared budget for the whole system**, multiple components were hit simultaneously. Within hours, job time-in-queue had increased dramatically and users felt it.

Root cause: every weekend a large batch of data is uploaded to the Foo Service so it's ready for internal users on Monday. **A storage-solution failure combined with a bug in the batch operation** made the batch **aggressively retry** API requests until the rate limit was exceeded. Stopping the runaway batch let the system slowly recover; once storage was repaired, the batch finished.

**The postmortem question that led to GQM.** Fixing the batch bug was the obvious action item. But the team asked: *could we have found out about the Foo Service problem sooner? Could we see a potential incident approaching and fix it before users are affected?*

**The goal**: *discover problems involving the Foo Service earlier and mitigate or resolve them before those problems negatively affect users.* Ideally, "users should think the engineering team is made up of omnipotent magicians who can see the future." The team then brainstormed in a shared document, **iterating and riffing for about half an hour**:

| Question | Metrics |
|---|---|
| What is the current Foo Service API usage? | API usage as reported by the Foo Service |
| How close are we to exceeding the Foo Service rate limit? | Remaining API calls (total quota available − reported usage); % API quota remaining for all components (reported usage / total quota); % API quota remaining **for each component** (component-tracked usage / component-assigned quota) |
| Is the Foo Service having a problem, or are *we* having a problem connecting to it? | Heartbeat is successful (**Boolean, with an error tolerance to deal with blips**); synthetic traffic is synced to the Foo Service as expected (Boolean); % timeout requests over a 15-minute window; % authentication-error requests over a 15-minute window |
| Are jobs working as expected? | Count of total requests; count of normal, error, and timeout responses; % error responses over a 15-minute window |
| Are we keeping up with the request load? | Job queue depth (count of pending and in-progress jobs); average queue depth over time; average, **p99, p95** job processing time; average job throughput (jobs / time) |

**Three architectural flaws exposed by asking "where does the data come from?"**
1. **Data was only recorded when the system was under load.** No traffic → no requests to the Foo Service → no way to know whether it was working. No harm would result if the Foo Service died while nobody needed it, but the team wanted the *option* to warn users ahead of time — and to anticipate downstream failures that *were* under their control.
2. **Responsibility for handling failures and retries was not clearly assigned** in the architecture.
3. **Teammates were unsure how to respond to problems.**

**The fixes, one per flaw:**
1. **A new heartbeat component** to check Foo Service availability. Fortunately the Foo Service offers a **metering API** so customers can check current usage and confirm accessibility — extra information that also made **managing the overall API budget** easier.
2. **Failure handling reassigned from the jobs to the work queue.** The old open-ended design had let some jobs retry failed Foo Service requests themselves, which *exacerbated* the incident: self-recovering jobs ran longer, inevitably failed, re-entered the queue, and increased congestion — so total requests to the Foo Service ballooned. **In the worst cases a job made 5 failed attempts and was retried 10 times before permanently failing: 50 API requests for one job.** The decision — **jobs should fail fast** — was captured in an **architecture decision record (ADR)**.
3. **Alerts** on every identified metric, plus **a runbook per metric** so everyone knows what to do. **Each runbook references the metrics**, to make diagnosis easier and eliminate false positives. They also built tools and added **diagnostic APIs** to assist recovery.

Some team members questioned whether all this was necessary, since the root cause was already fixed.

**Incident #2 — seeing the future.** Nine months later, in the small hours of a Friday, a Foo Service developer deployed a configuration change that took the Foo Service **completely down for 14 hours**. This time:
- An alert fired **within 10 minutes** of the Foo Service becoming globally unavailable.
- The **diagnostic APIs** let the team quickly confirm the problem was in the Foo Service and outside their control.
- They disabled a few alarms and watched the metrics to verify job failures were being retried with **exponential backoff, as described in the ADR**. Everything worked as planned.
- **Shortly after the workday began — before a single user noticed — they emailed internal users** about the issue.
- When the Foo Service returned, the system **self-corrected as designed**, and the team watched the metrics normalize over the next few hours.

**"What would have been a critical, priority-zero issue nine months before was now a barely noteworthy event."**

**Reflection.** The metrics became a permanent part of operational visibility and incident response. And crucially: *thinking specifically about metrics and the data required to compute them exposed gaps in the architecture* — a missing component, and an unassigned retry responsibility. Many postmortems expose weaknesses in operational visibility and response strategy; **GQM not only highlights them but shows the path toward a better system.**

### A workshop example
A colocated GQM workshop whose goal was **identifying analytics to flag records for fraud investigation**. The chapter is candid that the resulting tree "at this stage was fairly messy." Afterward the **facilitator prepared a written summary precisely defining the metrics**, and **stakeholders prioritized them in a follow-up meeting**. In this case, data collection and metric computation turned out to be **key system requirements feeding directly into the architecture design and project scope**.

## Anti-patterns
- **Guessing from gut feelings** on big questions — biased and unreliable.
- **Skipping the goal**, or starting from metrics you already collect — without the *why*, teams neither use nor trust the numbers.
- **Waiting for a perfect goal statement** — even an essence-capturing one is useful, and the goal gets revised anyway.
- **Filtering questions by feasibility while brainstorming** — you must temporarily let go of what's practical.
- **Failing to prune** — some metrics give weak signals or cost too much; an unpruned tree isn't a plan.
- **Only positive metrics** — you need failure indicators to stay honest.
- **Treating "how do we measure it?" as a separate, later problem** — the data question is where architectural gaps surface.
- **Instrumenting only the loaded path** — no traffic then means no signal at all.
- **Leaving retry responsibility unassigned** — jobs and queues both retrying multiplies load exactly when you can least afford it (50 requests for one job).
- **Alerts without runbooks** — the team won't know how to respond, and false positives won't get filtered.
- **Running a system-focused workshop with nobody who knows the architecture** — you can't assess data-collection cost.
- **Using multiple prioritization techniques** — you only need one.

## Key Takeaways
1. Goal → questions → metrics → data, and every leaf must trace back to the root.
2. Write the goal with purpose, object, issue, and point of view; expect to revise it after the metrics exist.
3. Questions must be operational: *closer or further from the goal?*
4. Prioritize metrics by signal strength and reuse; prioritize data by how many metrics it feeds and how cheap it is.
5. Pair success metrics with failure metrics.
6. Deriving the data requirement is an architecture review in disguise — missing instrumentation and unassigned responsibilities surface here.
7. Ship the outputs as alerts **plus** runbooks **plus** diagnostic APIs, and record structural decisions as ADRs.
8. Run it as a 2–5 person workshop with a pre-drafted goal, one prioritization technique, and a photo of the tree.

## Connects To
- **Ch 6** (Rosa): the outcome → goals → metrics domain decomposition and the KPI Value Tree are the organizational cousins of the GQM tree; EventStorming plays the same "align stakeholders in a workshop" role.
- **Ch 7** (Woods): "measure something that matters" and "start small" are GQM's pruning rules restated; this chapter supplies the technique for choosing *what*.
- **Ch 2** (Weiss): GQM discovers which metrics deserve fitness functions; step 1 of Weiss's process (align quality goals with stakeholders) is a GQM goal statement.
- **Ch 1** (Harmel-Law): time to restore service and change failure rate are the DORA counterparts of this team's queue-depth and error-rate metrics.
- **Basili & Weiss, "A Methodology for Collecting Valid Software Engineering Data"** (IEEE TSE, Nov 1984); **Keeling, *Design It! From Programmer to Software Architect*** (Pragmatic Bookshelf, 2017); **ADRs**; **Miro / Google Docs / Dropbox Paper** for remote workshops.
