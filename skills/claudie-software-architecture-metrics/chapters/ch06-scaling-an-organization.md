# Chapter 6: Scaling an Organization — The Central Role of Software Architecture

**Author**: João Rosa

## Core Idea
Software architecture is a **sociotechnical** artifact that either enables or blocks organizational strategy; make it **intentional** by visualizing the flow of work (EventStorming), sharpening domain KPI definitions, and linking organizational KPIs → domain KPIs → engineering metrics in a **KPI Value Tree** — then change the architecture through metric-guided experiments.

## Frameworks Introduced

- **The KPI Value Tree** — the chapter's signature artifact. Three levels:
  1. **Organizational KPIs** — broad, measure company health. Usually financial (EBITDA, customer lifetime value), sometimes end-user-focused (monthly active users). **Lagging indicators**.
  2. **Domain KPIs** — narrower, per domain (e.g. "increase % of activated policies", "decrease time from quote request to policy activated/cancelled"). Also **lagging**.
  3. **Metrics** — can be lagging, but crucially also **leading indicators**: strong predictors that an intended action will produce the expected outcome (e.g. deployment frequency, change fail rate).
  - **When to use**: when you need to justify architectural work in business terms, or when teams don't understand the product direction.
  - **How**: build it from workshop output; it is **a snapshot in time** and must be maintained. Requires alignment across functions plus **senior-management buy-in** (because level 1 is organizational). **Clear ownership** and a process fitting the org's context and culture determine whether it lasts.
  - **Caveat**: it is an expensive exercise in time and commitment. In the story it started with one person only because a scale-up has short communication lines between senior management, architecture, and engineering.

- **Intentional (vs best-effort) architecture** — the diagnosis behind everything. If everyone is fulfilling requests "to the best of their abilities," architectural decisions are not intentional and the architecture will drift.
  - **How to become intentional**: visualize the flow of work and how software achieves goals; coordinate the organizational mission with its KPIs; then shape the architecture by balancing trade-offs.

- **Big Picture EventStorming** — "a flexible workshop format for collaborative exploration of complex business domains" (Brandolini / DDD community). The author's four-step sequence:
  1. Map the **business process as it currently stands** — flow and order of business events, with boundaries where the type of work changes or a process ends. Output: the flow plus **emergent domains and their boundaries** and pivotal domain events.
  2. **Map current software components** (microservices, monolith remains, anything between) onto the emergent domains. The mismatch between process and implementation becomes visible — and explains the drift.
  3. **Map component ownership**, which makes team **cognitive load** visible: owning components spread across the landscape requires knowledge from multiple domains.
  4. **Map the domain KPIs**, with domain experts articulating why each is relevant — surfacing knowledge that previously existed only implicitly.
  - **Why it works**: business-operations people come to understand the architecture and its constraints; software people come to understand business operations and how software enables them.

- **Process Modeling EventStorming** — the level-deeper follow-up on **one operational value stream** (in the story, "request travel insurance quote" in the Travel Insurance domain). Adds: detailed KPIs per step, **hotspots**, and every step in the stream.
  - **The question to ask at this depth**: **"Where does the company make money?"** It is critical to understand the business model when creating software; the architecture should facilitate value creation.
  - Expect **different people to have different definitions of the same KPI** — the workshop's real value is creating convergence and sharpening the definitions.

- **Domain decomposition — outcome → goals → metrics.** Decomposing a domain this way exposes its purpose and intentions.
  - **Rate-of-change rule**: **metrics change more often than goals.** Metrics sit closer to the software architecture; goals provide the guidance. Business forces act on both.

- **Metric-guided architectural experiments** — how the architecture actually changes. Frame explicit questions, run staged experiments with a hypothesis stated in terms of specific metrics, and let the metrics prove or disprove the direction.

## Key Concepts
- **Conway's Law** (Melvin Conway, "How Do Committees Invent?", *Datamation*, April 1968) — "organizations which design systems … are constrained to produce designs which are copies of the communication structures of these organizations." Architecture reflects **two dimensions**: the org structure (explicit, on the org chart) and **how people communicate within it** (implicit, and people are usually unaware of its effect).
- **Big ball of mud** (Foote & Yoder, 1999) — "a haphazardly structured, sprawling, sloppy, duct-tape and bailing wire, spaghetti code jungle."
- **Distributed big ball of mud** — the same, plus distribution over the network, adding complexity.
- **Accidental complexity** — complexity introduced as a dependency, poorly documented or untested code, or unstructured design; typically when a team struggles to cope with competing business forces. Ripple effects hit maintainability, operationability, and changeability (Brooks).
- **Cognitive load** (Skelton & Pais, *Team Topologies*) — "the limit on how much information they can hold in their brains at any given moment. The same happens for any one team by simply adding up all the team members' cognitive capacities."
- **Enticing knowledge** — the author's term for visualizing current processes and mapping constraints so collective knowledge in people's heads becomes visible. Most organizations have no detailed process diagrams — or have out-of-date ones.
- **Hotspots** — current challenges for people using the system; analyzing them reveals **waste**.
- **Waste** (Lean / Toyota Production System) — "the ideal conditions for making things are created when machines, facilities, and people work together to add value without generating any waste." Eight types of waste (Skhmot). Use Lean principles as **one lens** for generating intentionality when weighing architectural trade-offs — it can guide where you place architectural boundaries.
- **Goodhart's Law** — "when a measure becomes a target, it ceases to be a good measure."
- **Mean time to discover** — average time between an IT incident occurring and someone discovering it. Requires proper observability practices and tools.
- **Throughput** — baseline of a team's capability to deliver batches of work; Lean roots, adopted by DevOps for continuous improvement.
- **Employee Net Promoter Score** — employee happiness; drives higher retention.
- **Business forces** — technology, people, regulations, the market; they shift as a company scales and inevitably move the architecture.

## Mental Models
- **"Slower is faster."** Time invested in deeply understanding KPIs — and thus the environment the software must work in — pays off when you create the architecture. Don't take information for granted; ask the challenging questions.
- **Architecture is not static.** It is a continuous process: new artifacts change the landscape, the organization evolves, and what was valid in the past may not be valid now.
- **Architecture enables strategy; it is not a technical implementation *of* strategy.** Leaders need to see it that way.
- **Trends often matter more than the metric itself.** Rising mean time to discover suggests either growing architectural complexity from business forces, or rising cognitive load with a negative effect on engagement.
- **Combine metrics to locate problems**: mean time to discover **+** change fail rate → weak points in the architecture. Change fail rate **+** employee NPS → where managers need to support staff.
- **Clear boundaries make innovation possible** by respecting that some parts of the architecture benefit from stability while others benefit from experimentation.
- The next generation of architects needs to **facilitate workshops, understand group dynamics, and contribute to business strategy** — not just group patterns between technical components.

## Reference Tables

| Named metric | Nature | Use |
|---|---|---|
| Deployment frequency | Leading (velocity) | DORA; used as experiment success criterion in the story |
| Lead time | Leading (velocity) | DORA |
| Change fail rate | Leading (stability) | DORA; pairs with MTTD and eNPS |
| Mean time to restore | Leading (stability) | DORA |
| Mean time to discover | Trend indicator | Requires observability; proxy for whether people learn from the past |
| Throughput | Baseline | Team's capability to deliver batches of work |
| Employee Net Promoter Score | Social | Employee happiness → retention |
| EBITDA, customer lifetime value | Lagging, organizational | C-suite steering |
| Monthly active users (MAU) | Lagging, organizational | Growth steering via marketing, sales, contact centre, product features |

**KPI vs target — the discipline**: KPIs and metrics are **guides and enablers, not targets**; they are not meant to dictate behaviour. **Tell**: if people start saying "we are not achieving KPI X," the KPI is being used as a target. If you need a target, call it a target. Where an **SLA** exists (a contractual service level with financial consequences), targets are legitimate — learn from the SRE community and visualize how KPIs, metrics, and targets connect.

## Worked Example

### YourFinFreedom: monolith → distributed big ball of mud → intentional boundaries
A Belgian fintech scale-up leveraging PSD2 open-banking legislation, serving Belgium/Netherlands/Luxembourg and aiming at France, Germany, Italy. Simultaneous pressures: availability problems *caused by* success, need for more resilience, more financial-provider integrations, forecast scale-up, better features, faster delivery.

**The mistake.** Keisha (head of Product Engineering) decides microservices are the way to move faster, and scales from **3 to 10 teams**, each owning an area. Anna (senior engineer, new) concludes within months that the architecture doesn't fit the business need and may be costing market opportunities; she raises it, and Keisha talks her out of it.

**One year later** — a plethora of microservices plus monolith remains across 10 teams, and none of the promised speed or quality. Anna's list of day-to-day hurdles:
- Release orchestration between microservices is needed to ship one feature in one area.
- Functionality overlaps between microservices make ownership hard to assign.
- Constantly shifting departmental priorities produce a lot of abandoned work.
- Constant product issues have damaged morale.
- Team members don't understand the product direction or how to contribute to it.

Management admits they **never properly weighed the trade-offs**. Anna is offered a new **Solutions Architect** role — enabling teams' architectural efforts and acting as a steward of coherence across the technical landscape — and accepts on one condition: **full permission to interact with every part of the company** to understand their challenges.

**Seeking direction.** Talking outside her department, Anna finds the company has retuned its KPIs to its mission "Making financial services accessible to everyone, anywhere": the C-suite steers on **EBITDA** and **customer lifetime value**, plus a new **MAU** KPI that creates a feedback cycle from marketing, sales, and product features. Her question — "how is this connected to software architecture?" — is the chapter's pivot.

**The workshops.** Big Picture EventStorming (emergent domains → software components → ownership → domain KPIs) exposes the process/implementation mismatch and the source of cognitive load. Then Process Modeling EventStorming on the "request travel insurance quote" value stream, adding KPIs and hotspots, and answering where the money comes from: **a fee per activated travel insurance policy**, so the business wants to maximize activations while the customer wants a seamless process with the best price and coverage.

**The experiment.** The team examines the **central customer information microservice** — "not actually 'micro' at all" — which holds all customer information including financial services used, and whose architecture is entangled with travel insurance policies. Worse, it's owned by a *different* team, yet release orchestration depends on it. Three questions:
1. Can a self-contained service manage travel insurance policies?
2. What effort is required to move the Travel Insurance domain's dependencies off the central customer information service?
3. What effort is required to move travel insurance policy information out of it?

Experiment 1's design: create a self-contained travel insurance policy service acting as a **proxy** for the central service, **dual-writing** new quote requests to both, to prove the new service can reliably store the information. If all experiments succeed, the travel insurance policy service becomes the **single source of truth** for the domain.

**The hypothesis, stated in metrics**: creating the travel insurance policy service and moving the travel-insurance logic out will (1) **increase deployment frequency** and (2) **decrease change fail rate** — both *on the central customer information service* — and will redefine architectural boundaries in favour of the owning team's autonomy.

**Result**: experiments succeed and the metrics prove it. The old boundaries were misplaced; redefined, the domain's services **no longer need release orchestration**. Anna manages expectations up front — being explicit that the team's feature capacity will drop during the experiment — and Keisha backs her in communicating foreseeable consequences, intended outcome, and the tie to EU expansion. Stakeholders' appreciation of that honesty is what buys permission to repeat the approach in other domains.

**The KPI Value Tree evolves.** As the domain's KPIs improve, insurance analysts forecast needing to hire travel-insurance-quote staff linearly with market share — which would hit EBITDA. So the metric **"Decrease the time to find a match for the insurance quote request"** is replaced with **"Increase the first accepted travel insurance quote from the options provided by the insurance analyst"**, and the architecture gains a service that ingests customer information, queries insurance partners, and generates quote options — a **decision-support system** for analysts, replacing time spent browsing partner systems.

**Three patterns Anna finds across other domains**:
1. The software architecture is not aligned with domain boundaries.
2. The **domain boundaries themselves are incorrect**, causing accidental complexity — e.g. one central customer information service holding all financial domains must manage the differing behaviours of every financial domain model.
3. **Cognitive load is too high** where teams own components crossing domain boundaries or spanning different operational value streams — e.g. the team owning both Customer Onboarding *and* Billing, processes so distinctive and unrelated that the team couldn't focus on a single problem space.

### Two field stories from the author's own practice
- **Harbors and tax authorities.** A Big Picture EventStorming session included customer support staff *and* tax lawyers. When the support domain expert described how agents sometimes correct tax documents in the context of a vessel transaction, the tax lawyer flagged that this **conflicted with local law** — caught in a workshop, avoiding serious financial and legal consequences. The group then reflected on improving the support workflow and which KPIs would validate the improvement; the owning team used the insights to reprioritize its backlog while implementing new **Brexit** EU/UK interface rules.
- **Ecommerce restocking.** As technical team lead during a cloud migration, the team instrumented the API of the service choosing the best supplier and quantity for a restocking proposal. Call-success-rate metrics showed a relatively high number of failed calls; a composed metric relating failures to the product being restocked, plus digging by the business analyst, revealed those products were **end-of-life — no longer supplied but not yet retired from the system**. Adjusting the metrics to incorporate that dropped API errors to virtually zero and drastically improved end-to-end process time, with fewer products entering the restocking process at all.
- **Mobile banking apps and deployment frequency.** During a DevOps transformation, people wanted to apply **thresholds and rank teams by "performance"** on DORA metrics across an organization running everything from mainframes to serverless. Beyond the context objection: for mobile apps, frequent deployments trigger **update notifications that annoy customers and depress NPS**. The department instead invested in the *capability* to deploy any time and adopted a **three-ring deployment approach (alpha, beta, production)**, auto-deploying every change to alpha — the right answer for their context, reached by connecting KPIs and metrics holistically.

## Anti-patterns
- **Choosing an architectural style without weighing trade-offs** — and scaling team count to match the choice rather than the need.
- **Overriding a credible objection because you're keen on the plan** (Keisha with Anna, at the cost of a year).
- **Letting architecture mimic team structure and communication by default** — the passive form of Conway's Law.
- **Overengineering microservices past the point where the cognitive load of understanding a business transaction exceeds human capacity.**
- **Using KPIs and metrics as targets** — Goodhart's Law. Say "target" when you mean target.
- **Comparing teams' performance on these metrics** — counterproductive, because knowledge domains, skill levels, technology, and context all differ.
- **Applying DORA thresholds uniformly across radically different contexts.**
- **Copying another organization's metrics** — contexts differ; discovering your own is the investment that pays off.
- **Treating EventStorming as a one-time activity** — keeping people aligned requires constant effort.
- **Leaving ownership changes implicit** — architectural insight that shifts component ownership has technical *and* social trade-offs; be explicit or people lose focus, get frustrated, and leave.
- **Letting the KPI Value Tree go stale** — when business forces change, question the usefulness of every KPI and metric.

## Key Takeaways
1. Connect architecture to the mission through a three-level KPI Value Tree; if KPIs are poorly defined or misunderstood, the architecture will be at odds with them.
2. Make architecture intentional: visualize the flow of work first, then decide boundaries.
3. Big Picture EventStorming for emergent domains, component mapping, ownership and cognitive load; Process Modeling EventStorming for one value stream's KPIs and hotspots.
4. Expect KPI definitions to disagree across the room — converging them *is* the deliverable.
5. Ask "where does the company make money?" before touching boundaries.
6. Change the architecture via experiments with hypotheses stated in metrics (here: deployment frequency up, change fail rate down on the service being decoupled).
7. Metrics change faster than goals; trends and metric *combinations* carry more signal than single values.
8. Manage expectations explicitly — capacity dips, ownership shifts, and social consequences included.

## Connects To
- **Ch 1** (Harmel-Law): the four key metrics used here as the leading indicators in the KPI Value Tree's third level.
- **Ch 2 & Ch 8** (Weiss, Ford): "you can also implement metrics as fitness functions" — an architecture fitness function "provides an objective integrity assessment of some architectural characteristic(s)."
- **Ch 10** (Keeling): GQM is the systematic sibling of the outcome → goals → metrics decomposition used here.
- **Ch 5** (Ciceri): the same silo/ownership problem seen from the delivery-process side.
- **Conway (1968)**; **Foote & Yoder (1999)**; **Brooks, *The Mythical Man-Month***; **Skelton & Pais, *Team Topologies***; **Brandolini, EventStorming / "Discovering Bounded Contexts with EventStorming"**; **Baas-Schwegler & Rosa, *Visual Collaboration Tools***; **Accelerate** (Forsgren, Humble, Kim); **Toyota Production System / Lean**; **Goodhart's Law**; **SRE and SLAs**.
