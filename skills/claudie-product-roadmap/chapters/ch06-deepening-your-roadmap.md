# Chapter 6: Deepening Your Roadmap

## Core Idea
Layer five **secondary components** — features/solutions, stage of development, confidence, target customers, product areas — onto a theme-based roadmap so stakeholders answer their own questions. A little context means less time explaining the roadmap and more time executing it.

## Frameworks Introduced

- **The Five Secondary Components**: Features and solutions · Stage of development · Confidence · Target customers · Product areas.
  - When to use: on top of the primary components (product vision, business objectives, themes, timeframes, disclaimer) once the roadmap's skeleton exists. Secondary means the roadmap still works without them — but detail is what wins buy-in and alignment.
  - How: (1) Run the diagnostic question set for each component (below). (2) Add only the ones that answer questions your audience actually asks. (3) Apply them as tags, color codes, labels, or separate rows/swim lanes on themes and subthemes. (4) Experiment — different components matter at different points in the product life cycle.
  - Why it works: the added detail forces the team to think critically about each item and keep asking "why," which stress-tests the roadmap. Without it, stakeholders arrive at your door with laundry lists of questions and concerns.

- **Features as Subthemes**: When a solution must appear on the roadmap, add it *as a subtheme under its theme* — never side by side with themes, never replacing them.
  - When to use: for the three legitimate feature scenarios below.
  - How: keep the theme as the parent (the need), attach the feature as a subtheme (the likely answer). Subthemes can be need-based *or* solution-based; mixing both under one theme is normal and good.
  - Why it works: it preserves the *why*. A feature listed on its own loses the problem it exists to solve; a feature nested under a theme carries its justification with it.

- **The Three Legitimate Reasons a Feature Reaches the Roadmap**:
  1. **Probable solutions** — a likely solution is evident though not finally decided. Listing it does *not* remove the need for testing and validation, but gives exploration a starting point. (PT app: subthemes "Distribute invoices" and "Track status" with QuickBooks named as the probable solution.)
  2. **Infrastructure solutions** — defined and vetted internally by engineering, requiring less external validation. System-level needs turn into solutions fast. If you've validated the solution, be explicit: e.g., "Solr Proof of Concept."
  3. **Carryover solutions** — something from a previous roadmap or release plan that ran out of time or resources, carried into the next version as a subtheme. Teams cannot predict completion dates exactly, so carryover is normal.

- **Stage of Development Tagging**: Label each item with where it stands in your development process — discovery / market research / R&D → design / testing / prototyping → development / pre-production → alpha / beta / early access.
  - When to use: when items visibly pass through distinct stages and those stages span your roadmap's timeframes.
  - How: use your own organization's vocabulary. Spotify's PM tagged each item "think it," "ship it," or "tweak it." Bonus effect: status *differentiates themes from features* — "think it" means unsolved, therefore a theme; "ship it"/"tweak it" means a solution is chosen, therefore a feature.

- **Confidence Scoring**: Attach explicit certainty levels, because you should **never have 100% confidence in anything on your roadmap** — that would require predicting the future.
  - When to use: whenever timeframes are specific, items extend far enough out that you're reluctant to commit, or stakeholders treat anything written down as a promise.
  - How, three escalating options: (1) **Per column** — e.g., Now 75%, Next 50%, Later 25%. Predictive Index uses a decreasing gradient bar so certainty visibly drops with distance. (2) **Per item within a column threshold** — Now (70–95%): Theme 1: 95%, Theme 2: 85%, Theme 3: 80%, Theme 4: 70%. (3) **Confidence separation line** in the Now column — above the line the team is confident for the next release; below is aspirational. Hit it, bonus; miss it, carry over, no harm done.
  - Why it works: timeframe columns already imply confidence (strongest nearest, waning further out), but making it explicit converts an unspoken assumption into a negotiated expectation — which is what stops "it was on the roadmap" arguments.

- **Target Customer Tagging**: Tag or lane each theme by which customer type it serves.
  - When to use: multiple customer types with different needs (education: student, teacher, administrator, parent), or when the user differs from the buyer.
  - How: simple labels on each theme, or dedicated rows/swim lanes per user type for clearer separation. Cover every role or persona the product serves; the act of forcing a tag on each theme reveals whether you're focusing on the right customers at the right time.

- **Product Area Tagging**: Annotate items by area within the product — software: user interface, platform, administration, APIs; the garden hose: weather surface, exoskeleton, water channel, connectors.
  - When to use: when areas are distinct and easy to communicate, or carry separate business objectives.
  - How: color coding, text labels, or separate rows — same mechanics as target customers. Each area must get sufficient attention to come together into a fully functioning product.

## Key Concepts
- **Secondary components**: Optional roadmap detail (features, stage, confidence, customers, areas) that increases clarity, readability, and value without being required for the roadmap to work.
- **Probable solution**: A likely but not-yet-final solution listed on the roadmap as a starting point for exploration; still requires validation.
- **Carryover**: An item pushed from a previous roadmap or release plan into the next because time or resources ran out.
- **Stage of development**: The labeled step an item occupies in your process — and, incidentally, a signal of whether it is still a theme or already a feature.
- **Confidence**: The stated probability you will deliver an item within its timeframe; never 100%.
- **Confidence separation line**: A line in the Now column dividing committed work (above) from aspirational work (below).
- **Swim lane**: A roadmap row dedicated to one customer type or product area.
- **Information overload**: The failure mode of too many labels — the roadmap becomes difficult to read or tedious to interact with.

## Mental Models
- **Use secondary components as pre-answered stakeholder questions.** Every label you add is a conversation you don't have to have twice.
- **Think of "why" as a tax on every item.** The point of the extra detail isn't decoration — it's that filling it in forces the team to keep asking why at every juncture and stress-test each item.
- **Use status labels as a theme/feature detector.** If an item can be labeled "shipped" or "tweaked," a solution was chosen — it's a feature. If it's still "think it," it's a theme.
- **Think of detail as a dial, not a switch (Strive for Balance).** Too much information makes the roadmap unreadable; too little leaves holes that cause confusion and a loss of stakeholder confidence. A *selection* of these components is the balance point — experiment to find yours.

## Reference Tables

### Diagnostic questions per secondary component

| Component | Ask yourself |
|---|---|
| **Features** | Do we have enough understanding of the need and possible solutions to feel confident in a particular solution? · Do we have validated solutions from previous release plans that didn't get completed and need carryover? · Do we have validated infrastructure needs? · Do we have mandates from decision-making stakeholders that must be addressed? · What is the likelihood this solution will be changed, postponed, or dropped from the schedule (i.e., what is your confidence)? |
| **Stage of Development** | Do your themes or features go through distinct stages of development? · If so, do those stages take longer than the timeframes in your roadmap? · Is this level of detail helpful in managing expectations with your stakeholders? (Consider whether confidence may be sufficient instead.) |
| **Confidence** | Does your roadmap include specific timeframes — months, quarters, or years? · Does your roadmap show themes or features far enough into the future that you find yourself reluctant to commit to those items? · How regularly does your development team hit dates projected months in advance? · Do your stakeholders tend to assume that if it's written down, it is a promise? · Have you already included stage-of-development information that might provide enough insight into confidence? |
| **Target Customers** | Do you have distinct customer types with different needs? · Is it important to achieve balance in addressing the needs of each? · Conversely, are there one or two customer types that are more important? · Will clarifying the customer type be helpful in guiding stakeholder conversations? |
| **Product Areas** | Does your product have distinct areas or components that are easy to communicate? · Do you have separate business objectives for individual product areas? · Is it important to show that work is being done to improve all areas (or specific areas that need attention most)? · Will clearly marking product areas be helpful in guiding stakeholder conversations? |

### Confidence by column (worked pattern)

| Column | Column threshold | Per-item example |
|---|---|---|
| Now | 70–95% | Theme 1: 95% · Theme 2: 85% · Theme 3: 80% · Theme 4: 70% |
| Next | ~50% | — |
| Later | ~25% | — |

## Anti-patterns
- **Features chosen on instinct or stakeholder demand**: The common misstep that leads to building the wrong things and sending the product off-course.
- **Listing features and themes side by side**: Solutions must never replace or sit level with themes — nest them as subthemes so the problem they solve stays visible.
- **Publishing feature-level detail too early**: Names like "Pause Button" leave no room for discovery or experimentation and describe no problem, job, or user value. Early in the process, when specifics are uncertain, problems/needs/JTBD framings are sufficient.
- **Implying 100% confidence**: No roadmap item deserves it. Unmarked items read as promises.
- **Information overload**: Stacking every label on every item makes the roadmap tedious to read. Pick what your stakeholders care most about.
- **Too little detail**: The opposite failure — a roadmap full of holes that erodes confidence and generates stakeholder interrogations.

## Worked Example

**Buffer's feature-level roadmap (Trello, public).** Buffer publishes revenue, salaries, diversity — and its product roadmap. Like Slack, it uses Trello, but the individual items are highly specific as to the deliverable planned: "Pause Button," "Allow multiple admins for Business customers." These leave little room for discovery or experimentation and describe neither the problem to be solved, the job to be done, nor the value to the user. Buffer pushes transparency further, letting customers comment and vote on individual features, and soliciting feature requests that can likewise be viewed, commented on, and voted on.

The authors' verdict: many product people are rightfully wary of sharing this level of detail with customers — as are they. Early in the process, when specifics are not certain, framing the effort as a problem, need, or job to be done is usually sufficient. Contrast with the correct placement (PT app, Figure 6-1): one theme, three subthemes — the first two need-based, the third naming PayPal as a probable solution. Same specificity, but the need stays on top.

## Key Takeaways
1. Add secondary components to buy execution time — each label is a stakeholder question answered in advance.
2. Let features onto the roadmap only for the three reasons: probable, infrastructure, or carryover — and always as subthemes.
3. Run the component's diagnostic question set before adding it; if the answers are "no," leave it off.
4. State confidence explicitly — by column, per item within a column threshold, or with a separation line in Now — and never claim 100%.
5. Use stage-of-development labels ("think it / ship it / tweak it") as both status and an automatic theme-vs-feature classifier; consider whether confidence alone would suffice instead.
6. Tag target customers and product areas when you must balance distinct audiences or ensure every area of the product gets attention.
7. Strive for balance and experiment: too much detail is unreadable, too little erodes confidence, and the right mix varies by team, product, ecosystem, and life-cycle stage.

## Connects To
- **Ch 2 (Roadmap components)**: Defines primary vs. secondary components; this chapter builds out the secondary set.
- **Ch 3 (Personas / roles)**: Supplies the roles and personas you tag themes with under target customers.
- **Ch 5 (Themes)**: Establishes themes and subthemes; this chapter defines exactly when and how a solution may join them.
- **Ch 7 (Prioritization)**: The next step — ordering the now-detailed items.
- **Ch 9 (Stakeholder communication)**: Guidance on which mix of components each audience needs and who cares most about what.
- **Jobs-to-be-Done**: The alternative framing recommended over premature feature detail in public roadmaps.
- **Kanban/status workflows**: Stage-of-development tagging is the roadmap-level analogue of a workflow column.
