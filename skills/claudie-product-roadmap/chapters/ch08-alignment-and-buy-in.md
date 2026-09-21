# Chapter 8: Achieving Alignment and Buy-in

## Core Idea
A roadmap only works if the people who fund it, execute it, and receive its output believe in it — so get alignment (shared understanding of goals and roles), not consensus. Achieve it through shuttle diplomacy (one-on-ones first), then a cross-functional meeting or co-creation workshop, optionally supported by software.

## Frameworks Introduced

- **Shuttle Diplomacy**: Meet with each stakeholder individually to reach decisions that require compromise and trade-offs, before ever putting them in a room together. Named after Kissinger shuttling between Middle East capitals after the October 1973 war.
  - When to use: Whenever you have multiple stakeholders with competing priorities, political agendas, or a history of not agreeing in group settings. Especially before any group roadmap meeting.
  - How:
    1. Come with a **draft** roadmap, not a blank page — entice them with something to react to and ask for input.
    2. Open by tying the conversation to goals and objectives, not features.
    3. Run the conversation with **GROW**: **G**oals (what are they trying to accomplish in the next X months?), **R**eality (what's on their plate now? what's recent?), **O**ptions (what do they think will help them achieve those goals? what options need revisiting?), **W**ay forward (which options actually serve the goals they named? what's top of their list and why?).
    4. Make sure every idea they raise lands on your scorecard/spreadsheet — visibly. They must feel heard and feel they contributed.
    5. Score the items they care about, with them, against the goals.
    6. Record the meeting in the Shuttle Diplomacy Canvas (below). Keep meetings short and informal; only discuss the issues that stakeholder cares about, ignore the rest of your list.
    7. Then convene the group to finalize — often in 90 minutes, because the hard conversations already happened.
  - Why it works: (a) One-on-one strips out office politics — nobody is performing for the CEO, the board, or their peers; (b) it creates a feedback loop revealing whether their thinking matches the org's goals and vision — if they keep pushing something that makes no sense against stated goals, that's a hint an unwritten goal exists that needs surfacing; (c) hidden agendas get revealed in private that never would in a group; (d) early input gives each stakeholder **authorship** — it stops being your plan and becomes our plan.
  - Failure mode: Time. It's N extra meetings, and people are meeting-allergic. Mitigate with short, informal, narrowly-scoped sessions. Also constrained by rapport (you'll click with some stakeholders more than others) and location (in-person beats any videoconference for building rapport).

- **Co-creation Workshop**: Bring all stakeholders together in a structured working session to finalize prioritization together — "let's figure this out," not "here's the plan."
  - When to use: After shuttle diplomacy, to finalize. Or skip the one-on-ones entirely and go straight here when you have few stakeholders and low political temperature. Run it quarterly in software (about the time it takes to ship something of substance).
  - How: Define clear outcomes before you schedule it (outcome = a finalized roadmap for the upcoming period). Then run the 90-minute agenda: Intro and rules (5) → Hopes and fears (10) → Vision and goals (10) → Back-plan (15) → Sizing and prioritizing (40) → Wrap-up (10).
  - Why it works: No single "decider" imposes a decision; every stakeholder had input into the final call, so they stay on board through execution.

- **Presenting Recommendations**: The formal alternative meeting mode — a team does heavy homework up front, then presents a proposal for sign-off from a steering committee, senior managers, or executives.
  - When to use: Larger, established, hierarchical organizations with a portfolio review or advisory cadence (e.g. quarterly).
  - How: Before the meeting, each team (1) gathers inputs from their stakeholders shuttle-diplomacy style ("what are priorities for sales? for clinical? what does security need?"), (2) does a **T-shirt sizing** exercise per proposed initiative to gauge resources, (3) assembles business cases answering: what's the story around these initiatives? how does it fit the vision, long-term strategy, near-term strategy? what about the competitive landscape and market timing? Then present the recommendation for sign-off.

- **GROW**: Four-part conversation structure for a stakeholder one-on-one — Goals, Reality, Options, Way forward. Keeps the meeting anchored to outcomes rather than feature requests.

- **$100 Test (with desirability/feasibility/viability split)**: Give each participant a fixed budget to "invest" across candidate themes. The variation: break each theme into desirability, feasibility, and viability, and let only the people responsible for each area invest in that category (Marketing/Sales/UX invest in desirability, Engineering in feasibility, Product in viability). Tally totals.
  - When to use: The sizing-and-prioritizing block of the workshop — to **narrow** a long list to a manageable set for discussion. Not to decide. Voting is a bad way to prioritize (see Ch7); it's a fine way to focus.

## Key Concepts

- **Alignment**: A concerted effort to help people understand the issues and what their respective roles are — asking questions and listening to feedback from internal and external stakeholders; people with differing opinions can still align on intentions.
- **Consensus**: A group reaching a mutually agreed decision in theory; in practice, hours of discussion producing a decision nobody can be held accountable for ("I didn't vote for that!").
- **Collaboration**: Individuals cooperating toward a common goal — they may not concur at every step, but they agree on the final outcome.
- **Silo**: What you create when you go off alone and produce the plan yourself; kills enthusiasm and momentum for a product.
- **Release schedule**: A dated list of products, features, and ship dates — what C. Todd's Excel file actually was, and explicitly *not* a roadmap.
- **Hopes and fears**: Opening exercise where each person writes hopes on one color of Post-it and fears on another, surfacing emotional aspirations and roadblocks that otherwise stay unsaid.
- **Back-plan**: Starting from the envisioned future outcome and working backward step by realistic step to the present, forcing teams to think through every necessary change.
- **Cover Story**: Gamestorming exercise where each participant draws a magazine/newspaper cover five years out, after the roadmap has been implemented — headline, image, subheadline, sidebars, quote.
- **T-shirt sizing**: Coarse resource estimate per initiative (S/M/L) used to gauge execution cost before proposing it.
- **Shuttle Diplomacy Canvas**: Your private tracking grid of each stakeholder's goals, reality, options, and way forward — a guide for you, not an artifact to share with the team.

## Mental Models

- **Use alignment when you're tempted to seek consensus.** You do not need consensus to get your roadmap in place, nor to update it. You need alignment and collaboration. Consensus manufactures deniability; alignment manufactures shared intent.
- **Think of the roadmap process as IKEA furniture** (named explicitly in Ch9): people value what they helped assemble. Early input converts "your plan" into "our plan," which is the real mechanism behind both shuttle diplomacy and co-creation.
- **Think of a stakeholder pushing an off-strategy item as a signal, not an obstacle.** If someone keeps pushing something that doesn't fit the stated goals, there is an unwritten goal you haven't heard yet. Dig for it.
- **Use one-on-ones when the politics are the problem.** The room isn't neutral — stronger voices belittle, everyone performs for the most senior person present. Remove the audience and the conversation becomes about what's best for the company.

## Reference Tables

### Shuttle Diplomacy Canvas

Track one column per stakeholder. Private to you.

| Row | What you capture | Joan, CEO | Mark, Sales | Jen, Engineering |
|---|---|---|---|---|
| **Goals** — desired outcomes for next 3 months, *why* they hold them, and what metrics they use | Objectives + motivation + metrics | 15% y/y profit growth; accountable to shareholders; % revenue increase and EBITDA | Hit $24MM revenue in Q1; revenue keeps the company alive; revenue, average deal size | Grow team to meet capacity, improve sprint velocity; needs to optimize team productivity |
| **Reality** — what's currently on their plate | Current load, recent events | Setting up the company for scale | Missed last quarter's target, scrambling to make up | Three teams with differing velocity; demands for faster multi-feature delivery |
| **Options** — what they think needs to be on the roadmap | Their raw asks | Platform stability; new features sales requested; better onboarding | Client ABC requested features, possible deal | Platform stability; bug fixes; sales feature request |
| **Way forward** — which of their priorities they agree on | Convergence points | Platform stability; better onboarding | Better onboarding | Platform stability |
| **Additional considerations** | Office politics, hidden agendas | — | — | — |

Read the Way forward row across columns: that's your alignment. Here, platform stability and better onboarding survive contact with all three stakeholders.

### $100 Test tally

| Theme | Desirability (Marketing, Sales, UX) | Feasibility (Engineering, Development) | Viability (Product managers) | Total |
|---|---|---|---|---|
| Theme A | $50 | $25 | $20 | $95 |
| Theme B | $25 | $75 | $60 | $160 |
| Theme C | $25 | $0 | $20 | $45 |

## Anti-patterns

- **Building the plan alone and emailing it out**: The Excel-spreadsheet-as-attachment move creates a silo and triggers fire alarms across teams. Any artifact that doesn't match others' expectations produces heated conversations, not alignment.
- **Confusing a release schedule with a roadmap**: Dates and features bring an illusion of certainty; they don't communicate why, so stakeholders have nothing to align *on*.
- **Chasing consensus**: Produces hours of discussion, a decision nobody owns, and a stakeholder who — once they dislike the outcome — becomes a barrier to implementation.
- **Going straight to the big group meeting when politics run hot**: Attendees perform for each other, stronger voices intimidate weaker ones, and the political machinations ruin your alignment attempt.
- **Relying solely on software for buy-in**: No team the authors spoke with got alignment from a tool alone. Tools (JIRA, Roadmunk, ProdPad, Aha!, ProductPlan, Slack, Trello, Asana) track and communicate; face-to-face achieves alignment.
- **Reopening settled decisions without new information**: Kills execution momentum. Don't reconsider decisions unless there is significant new information.
- **Running a workshop without predefined outcomes**: It becomes another unnecessary meeting. Know the outcome (a finalized roadmap for the period) before you book the room.
- **Using a vote to decide priorities**: Fine for narrowing to a discussable list; wrong as the decision mechanism.

## Worked Example

**Co-creation Workshop, 90 minutes**

| Block | Time | What happens |
|---|---|---|
| Intro and rules | 5 min | State the outcome: a finalized roadmap for next quarter. |
| Hopes and fears | 10 min | Each person writes hopes on one Post-it color, fears on another, one per note. Cluster. Check them against the established business objectives — surfaces visions and roadblocks that would otherwise stay unsaid. |
| Vision and goals | 10 min | MadLibs: *"A world where the [target customer] no longer suffers from the [identified problem] because of [product differentiator] they [benefit]."* Pare down to *"To [benefit realized] by [product differentiator]."* Compare responses. Alternative: Cover Story — draw the magazine cover five years out, with headline, image, subheadline, sidebars, and a quote. |
| Back-plan | 15 min | Start from the Cover Story future and step backward to today, each step realistic. Example: vision = "solo business travelers have a satisfying time dining with strangers while traveling." First step back = "they can search for a desirable local restaurant in an unfamiliar area." Continue until you reach the present. |
| Sizing and prioritizing | 40 min | Run the $100 test, split by desirability/feasibility/viability with each function investing only in its own category. Tally (Theme B wins at $160). Use the result to narrow to a discussable shortlist, then decide together. |
| Wrap-up | 10 min | Confirm the decisions; agree not to reopen them absent significant new information. |

## Key Takeaways

1. Seek alignment and collaboration; explicitly do not seek consensus — you don't need it to create or update a roadmap.
2. Run shuttle diplomacy *before* any group meeting: bring a draft, use GROW, put every stakeholder's idea visibly on your scorecard, record it in the canvas.
3. Read the canvas across columns — the items that show up in multiple stakeholders' "way forward" rows are your alignment, and the hardest conversations are already done before the group convenes.
4. Choose your meeting mode by culture: Presenting Recommendations for hierarchical orgs with steering committees; Co-creation Workshop for teams that will build together. Both need (a) a culture of constructive disagreement and (b) general agreement on overall strategy.
5. Skip the one-on-ones only when stakeholders are few and political agendas are low — then go straight to the workshop.
6. Give stakeholders authorship early, while the roadmap is still a work in progress. That's what converts "your plan" into "our plan."
7. Use software to track and communicate, never to replace face-to-face alignment. And once decided, don't relitigate without significant new information.

## Connects To

- **Ch 3**: Identifying and mapping internal and external stakeholders — the input list for shuttle diplomacy.
- **Ch 4**: Guiding principles, product vision, and business objectives — the goals you anchor every GROW conversation and workshop to.
- **Ch 5**: Themes — what you're aligning on, rather than features or dates.
- **Ch 6**: Stage of development and confidence — context that shapes what's realistic to commit to.
- **Ch 7**: Prioritization — shuttle diplomacy and the workshop "polish off" the prioritization exercise started here; also the source of the authors' objection to voting as a decision mechanism.
- **Ch 9**: Presenting and sharing the now-aligned roadmap; the IKEA Effect names the mechanism this chapter relies on.
- **Kissinger's shuttle diplomacy (1973–1979)**: The historical origin — acting as neutral intermediary, cutting through emotionally charged interactions, seeking incremental improvement rather than full-blown resolution.
- **Gamestorming (Gray, Brown, Macanufo)**: Source of the Cover Story and $100 Test exercises.
