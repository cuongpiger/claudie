# Chapter 1: Four Key Metrics Unleashed

**Author**: Andrew Harmel-Law

## Core Idea
The four key metrics from *Accelerate* (DORA) are architectural metrics, not just delivery metrics: when you make them visible to delivery teams, the teams themselves start demanding a testable, loosely coupled, observable architecture — letting the architect "take their hands off the tiller" and stop dictating.

## Frameworks Introduced

- **The Four Key Metrics (DORA)** — measured against one mental model: a pipeline from "developer pushes a change" to "change is serving users".
  - **Deployment frequency** — number of individual changes that exit the pipe over time.
  - **Lead time for changes** — time a *completed* code/config change takes to traverse the pipeline into production.
  - **Change failure rate** — proportion of changes exiting the pipe that cause a failure in the running service.
  - **Time to restore service** — time from failure occurring/being detected to service being restored for users.
  - **When to use**: as the entry point to any delivery-performance transformation, and as the conversation-starter that surfaces architectural problems.
  - **How**: pair 1+2 = *development throughput*; pair 3+4 = *service stability*. Track **all four together** — improving throughput while degrading stability is unbalanced improvement that never yields long-term value.
  - **Why it works**: the metrics are effectively non-gameable in combination. Gaming throughput (submitting fast-failing builds) or stability (delaying tickets) shows up in the other pair.

- **Refactoring Your Mental Model** — map the generic pipeline model onto your *actual* delivery process before instrumenting anything.
  - **When to use**: first step of every rollout, before writing a single collector.
  - **How**: pick your **scope** (all org software? one program? infra changes included?) and apply *the same scope to all four metrics*. If infra changes count toward lead time, infra-induced outages must count toward change failure rate.
  - Four pipeline shapes to recognize, in ascending measurement difficulty:
    1. **Single end-to-end pipeline** (monolith in a monorepo) — trivial, and rare in practice.
    2. **Multiple end-to-end pipelines**, one per artifact/repo — ideal for microservices; each is independently measurable. This is the shape independent deployability buys you.
    3. **Pipeline made of multiple subpipelines** (build+publish → deploy-to-test → CAB-gated deploy-to-prod) — the most commonly encountered; requires extra data collection to link change sets across stages.
    4. **Multistage fan-in** — per-repo first stages fanning into a shared path to production; hardest, because you must trace each aggregated deployment back to its originating repo to recover its start timestamp.

- **The Four Instrumentation Points** — four metrics require exactly four data captures.
  1. **Commit timestamp** — ideally when *any* developer change-set is considered complete and committed, anywhere. Pragmatic proxy: pipeline trigger on merge to `main`. Using the proxy is acceptable; know you are hiding branch wait time.
  2. **Deployment timestamp** — when the pipeline performing the final production deployment completes. (Add a manual approval gate at the end if you want post-deploy smoke testing inside the clock.)
  3. **Service-failure open timestamp** — creation of a "change failure" ticket.
  4. **Service-failure close timestamp** — ticket closed when *service is restored*, not when root cause is fixed. A rollback that puts you back online stops the clock.

- **Minimal Viable Dashboard (MVD)** — start with a wiki page, not a platform.
  - **How**: current value of each of the four metrics; the definitions and the time windows used; the historical raw data; flagged data sources so anyone can engage with them.
  - **Why it works**: it makes rollout possible in a day, and it establishes the transparency that produces the real benefit (team-driven improvement) before any automation exists.

## Key Concepts
- **Development throughput** — deployment frequency + lead time for changes, taken as a pair.
- **Service stability** — change failure rate + time to restore service, taken as a pair.
- **Failure in production** — anything that makes a service consumer unable, *or even disinclined*, to stay and complete their task. Cosmetic defects don't count; a "working" system so slow it causes uncharacteristic dropout does.
- **Highest environment** — the shared, closest-to-production environment all teams deliver into (SIT/pre-prod/staging), usable as a production stand-in when you cannot yet measure production. Treat testers and collaborating teams as your "users" and let them define failures.
- **Total time to run** — elapsed time between clock start (commit) and clock stop (production deploy) for an individual change.
- **DORA Elite–Low scale** — the performance bands from *Accelerate* / State of DevOps, used to colour-code each headline figure.

## Mental Models
- Think of the four key metrics as **a paradigm-change tool, not a report**. Meadows: "Paradigms are the sources of systems." You change the paradigm by making the anomalies of the old one visible, repeatedly, in public.
- Use metrics **to generate conversations**, not to dictate. The architect's leverage is the weekly discussion, not the dashboard.
- Treat **all four changes teams ask for** (release cadence → shift-left quality → cross-functional teams) as leading indicators: they all terminate in the same place — revealed architectural problems.
- Trade fidelity for momentum: **manual capture with honest definitions beats automated capture you never ship**.

## Reference Tables

| Metric | Raw data needed | Aggregation the author uses | Window |
|---|---|---|---|
| Deployment frequency | Count of *successful* deployments per day (include zero-days) | Mean deploys/day | last 31 days |
| Lead time for changes | Total time to run per individual change | Mean of individual lead times per day, then mean over window (never average an average) | last 31 days |
| Change failure rate | Count of *resolved* change-failure tickets ÷ count of deployments | Sum failures ÷ sum deployments over window | last 31 days |
| Time to restore service | Ticket open → close duration | Mean *or* median (mean is outlier-sensitive — sometimes that's what you want) | last 120 days |

Visualization pattern used for every metric: time-series **bar graph**, date on x-axis, plus (a) headline metric in a box with DORA-band colouring, (b) coplotted deploy count in light grey for context, (c) mean/95th/trend dotted lines, (d) supplementary stats (open failures, totals for the period).

## Worked Example
A PowerBI dashboard over Azure DevOps, built by hand:

- **Front page** — the four headline numbers plus the deployment-frequency and lead-time graphs, so anyone gets an accurate real-time picture in seconds. Graphs get promoted to the front page as team focus shifts.
- **Deployment frequency page** — bars = that day's deploy total; boxes show "average deployments per day" (the headline, green = DORA Elite), deploys so far today, and total deploys over the 31 days; dotted mean/95th/trend lines.
- **Lead time page** — bars = that day's mean lead time. Added after repeated questioning: the deploy count shadow-plotted in grey ("did we do a lot of deploys that day?") and a box highlighting the single longest lead time — which immediately exposed a blocked build. The team used the word "average" rather than "mean" to keep it approachable.
- **Change failure rate page** — bars are almost always 0 or 1 per day, which makes problem days unmistakable. Headline = failures as a percentage of deploys in the period; extra boxes for active failures and total deploys.
- **Time to restore page** — plotted over **120 days** rather than 31, because there are far fewer data points and improvement is only visible over a longer arc. Lead time coplotted for context. A box shows open change failures — not a DORA metric, but essential to know.

The dashboard was **iterated weekly**, alongside spikes and ADRs. Early discussions were "what does this metric mean?"; then "why is this number where it is?"; then "how do we improve it?" Self-service drill-down to each team's own pipelines was what made adoption stick.

## Anti-patterns
- **Inconsistent scope across the four metrics** — counting infra changes in lead time but excluding infra-caused outages from change failure rate.
- **Counting failed or time-triggered pipeline runs** — a build that dies at compile step adds a very fast "lead time" and skews the metric positively. Only count runs that deploy service updates to users; never count cron-triggered runs.
- **Reporting the latest single measurement** — lead time and deploy counts fluctuate wildly, especially with fan-in pipelines. Report the windowed aggregate.
- **Averaging an average** — introduces distortion; aggregate from raw daily totals.
- **Executive-first dashboards** — the primary audience is the delivery teams. Management should see rolled-up, read-only figures; if they want detail they should have to come to the teams. That is the desired behaviour, not a bug.
- **Hiding data, calculations, or definitions** — secrecy destroys the metrics' greatest strength. Publish raw data, calculations, and your exact definitions together.
- **Cherry-picking builds during manual capture** — if you estimate, publish your estimated accuracy.

## Key Takeaways
1. Instrument four points, not four metrics: commit time, deploy time, failure-open time, failure-close time. Everything else is arithmetic.
2. Fix your scope once and apply it identically to all four metrics.
3. Ship a Minimal Viable Dashboard (a wiki page) on day one; automate collection second.
4. Only count successful, user-affecting deployments.
5. Report windowed aggregates — 31 days for the throughput/failure-rate trio, ~120 days for time to restore.
6. "Failure" is a judgment call about user task completion; pick a definition you're comfortable defending and stick to it honestly.
7. The payoff is not the numbers — it's that teams start surfacing coupling, fuzzy domain boundaries, untestable modules, and unobservable microservices themselves.

## Connects To
- **Ch 3** (Farley): testability and deployability are the architectural qualities the four key metrics indirectly drive.
- **Ch 5** (Ciceri): private builds and time-to-feedback attack the same lead-time bottleneck from the local-environment side.
- **Ch 6** (Rosa): uses the four key metrics as the organizational-scaling instrument at YourFinFreedom.
- **Ch 8** (Ford): the four key metrics are metrics; fitness functions are the engineering step beyond them.
- **Accelerate / DORA State of DevOps** — source of the metrics and the Elite–Low bands.
- **Tools**: Four Keys (Google), Metrik (Thoughtworks), Azure DevOps extensions.
