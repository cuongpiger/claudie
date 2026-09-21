# Chapter 9: Presenting and Sharing Your Roadmap

## Core Idea
One of the chief functions of a product roadmap is to get everyone excited about the future — which means you have to tell the story, not hand over a document. Build one roadmap on a common foundation of vision, strategy, and themes, then layer on only the secondary and complementary components each audience actually needs.

## Frameworks Introduced

- **Modular Roadmap (one foundation, per-audience layers)**: Don't build a different roadmap per stakeholder group. Build the specifics each group wants *on top of* the common foundation of vision, strategy, and themes.
  - When to use: Any time more than one audience needs to see the roadmap — which is always.
  - How: In a slide deck, the first four slides are identical for every audience (vision → strategy → themes → timeframes). Then add **one additional slide per group** carrying that group's secondary components and complementary information. Keep the foundation and the audience layer as separate slides in the same document, so there's a clear, direct link from the overarching story to the details that group cares about.
  - Why it works: Preserves alignment (everyone sees the same why) while satisfying each group's planning needs. It turns the question from "should I share my roadmap?" into "which portions do I show to whom?"
  - Failure mode: Building genuinely separate, divergent roadmaps per audience — that defeats the entire point of aligning the organization around a common cause, and produces the Chef.io problem where one customer thinks they're getting feature X and another thinks feature Y.

- **Roadmap Presentation Prep Checklist (4 steps)**:
  1. **Identify your audience.** Peers? Executives? Have they seen the roadmap before? If so, what input have they already had?
  2. **Clarify your goals for the presentation.** Do you need input on an early draft? Alignment on a particular aspect? Or are you just informing people of what's coming?
  3. **Determine what your audience cares about.** What level of detail is necessary? Do you summarize to the high level only? Are you presenting a portfolio?
  4. **Assemble your components.** Pull vision, business objectives, themes, and timeframes together; then choose secondary and complementary components based on (1) and (3).
  - When to use: Before every roadmap presentation, without exception.

- **Presentation Sequence (why → near term → long term)**:
  1. Start with the **why**. Get everyone on board with the product vision before any details. Cover recent progress — what's been completed since last time. Include emotion: quotes or anecdotes from customers about how changes positively impacted them.
  2. Show the **near term** and clarify which critical needs justified the prioritization and how they tie to business objectives. Add stories from sales, support, and customer requests to humanize the product and give meaning beyond making a chart go up and to the right.
  3. Propose the **longer term**, continuing to reinforce alignment with company objectives.
  - Why it works: emotion + data + stories = win. A roadmap presented as a list of deliverables produces interrogation about dates; a roadmap presented as a story produces buy-in.

- **Detail-by-Distance rule (Janna Bastow's chart)**: The further a person is from your core product development team, the less detail about features, functions, and dates you provide — and the less you share about brand-new product directions and internal infrastructure work.
  - When to use: Deciding what to reveal externally, by role.
  - Exception: Enterprise and component businesses where the customer is making a multi-year, multi-million-dollar commitment to you (see Bussgang and Analog Devices below) — there, detail is the price of the deal.

## Key Concepts

- **The IKEA Effect**: People love their IKEA furniture because they had a hand in putting it together — involving people across the organization in developing and refining the roadmap radically increases buy-in.
- **The Osborne Effect**: Pre-announcing future plans too early suppresses current sales as buyers wait for the next version; named for the Osborne 1, whose sales collapsed in 1983 after founder Adam Osborne pre-announced superior models, dealers canceled orders, the new models slipped, and the company went bankrupt.
- **Osborning**: The verb form — the act of killing your own current sales through premature announcement.
- **Secondary components**: The optional roadmap elements (features and solutions, stage of development, product areas, target customers, confidence) you add per audience.
- **Complementary information**: Data that is *not* formally part of a product roadmap but provides important context — platform considerations, project information, external drivers, financial information.
- **Confidence percentage**: A likelihood figure attached to items or timeframes, indicating how likely they are to be delivered in that timeframe (or at all) — the mechanism that keeps casual sales conversations from becoming promises.
- **Scalability (as a roadmap input)**: The volume of users you expect and when you expect them, stated explicitly so the team can balance between a fast prototype and an over-engineered system.
- **Technical debt / replatforming**: Work hidden entirely from the customer that may consume a large percentage of roadmap capacity; surface it as its own row, theme, or slide rather than leaving it invisible.
- **Product areas**: Parts of the product (admin UI, search, transactions) that development teams use as an organizing principle for their internal teams — shown as tags, colors, or swim lanes.
- **External drivers**: Regulatory changes, industry events, user conferences, competitor announcements — events you don't control that should inform roadmap timing.

## Mental Models

- **Think of the roadmap as a sales and communication tool, not a promise.** Janna Bastow's framing: put "we're going to have an initial version of this thing ready to use" on the roadmap. That lets the customer internally align around the idea that you gave them a date, without tying delivery of a specific thing to that date — and it frees you from having to build and specify the whole thing up front.
- **Use "what do they really want committed to?" when a customer demands a feature date.** Is it really a feature or a date? Or do they want to know you have skin in the game, that you're listening, that you'll tell them more when you know more? Serve the real need and they'll give you slack on the roadmap.
- **Treat executive detail-seeking as a trust signal.** Executives' interest in operational detail is inversely proportional to their trust in the team's ability to execute. If they're digging into the details, they think something is wrong.
- **Think of the commitment/flexibility trade as the customer's problem too.** The more specific deliverables you commit to, the less you can adjust when the winds change — and lack of flexibility is not in your customer's interest either. Say that out loud.

## Reference Tables

### Audience-tailoring matrix

| Audience | What they need from the roadmap | Secondary components to show | Complementary information to add | What to leave out |
|---|---|---|---|---|
| **Development team** (engineers, designers, testers, ops, technical support; in hard goods: design + manufacturing) | Concrete information to base project schedules, resource plans, technical architectures, and supply chains on. High-level themes are good context but not enough by themselves. | **Features and solutions** — a short list you believe will address the themes, concrete enough to ballpark effort and negotiate scope/timing. **Stage of development** — so they can plan resource allocation. **Product areas** — as tags, colors, or swim lanes, so they can map your roadmap to their team structure. | **Platform considerations**: scalability (expected volumes and when), technology and infrastructure (technical debt, refactoring, rearchitecture, replatforming — often its own row or slide). **Project information** (co-present with a project manager or engineering lead, *after* the primary components): schedule and resources, dependencies and risks, status. | Don't present the Gantt chart, burndowns, or velocity trackers *as* the roadmap. Don't dictate deadlines — you're asking what's feasible, not issuing commitments. Status is not part of the roadmap, though it informs it. |
| **Sales & Marketing** | What advantages the product will provide in terms of increased value, tied to critical dates on *their* calendar. They need to plan promotion, training, campaigns, and quotas. | **Stage of development** — including beta/early-access milestones, since marketing and sales care about a product once they can start talking about it. **Target customers** — when your solved problems will let you serve new segments ("Prosumer features," "Localized for China"). **Confidence percentages** — so a roadmap item doesn't become a promise in a sales call. **Features and solutions**, but sparingly. | **External drivers**: regulatory changes, industry events, user conferences, competitor announcements — mapped against roadmap timing. | Hard feature specificity. It's their job to talk to customers, so don't let them get ahead of your certainty. Use *likely*, *probable*, *tentative*, and liberal confidence percentages. |
| **Executives & Board** | The investments the company is making and the expected return on them. | Generally limit to the **high-level initial material**: vision, strategy, and problem-solving themes. | **Financial information**: market opportunity (target customer, or explicit revenue and profit targets — see the objectives-driven Contactually roadmap), profit and loss (rough revenues and a projected break-even timeframe). | Operational detail — unless asked. Keep all details on hand for the inquisitive board member, but don't lead with them. Business plan pro formas are not part of a roadmap. Better: preview the high-level material with them beforehand via shuttle diplomacy and collect concerns in advance. |
| **Customers** | Greatly simplified. Focus exclusively on the **value they should anticipate you will deliver** in the future. Enterprise implementation teams also need enough understanding of what's coming and when to prepare their organization — and they become advocates who smooth internal politics and purchasing for future releases. | Themes and rough timeframes only. Framed to avoid firm commitment. | A disclaimer and qualifiers. Development-cycle framing ("Considering" / "In development" / "Released") sets expectations honestly. | The details internal stakeholders need. Brand-new product directions that signal differentiating strategy. Internal infrastructure work. If you have more than one customer type, split the roadmap along those lines and show only what's relevant to the group in front of you. |

## Anti-patterns

- **Overpromising and Underdelivering**: The fear David Cancel names — "I'm going to disappoint you by giving you exactly what we thought six months ago was the best solution when it's not, or by changing course and having lied to you." The fix is not silence: as long as you're open and honest about priorities, customers are forgiving. Communicate direction and intent via themes without committing to deliverables that may not be achievable or may not even be the right solution.
- **The Osborne Effect**: Announcing future plans too early slows current sales because buyers wait for the next version. Most acute with hard goods that can't be upgraded by a software update, where pre-announcement makes the current product look obsolete.
- **Leaking differentiation to competitors**: There may be good reasons not to put everything on an external roadmap — particularly themes that signal a product direction that would further differentiate you. But if you're simply making existing product areas more robust, sharing may be fine or even necessary.
- **Maintaining multiple divergent roadmaps**: Defeats the alignment you spent Ch8 building. Use one foundation with per-audience layers instead.
- **Handing sales an over-specific roadmap**: Salespeople talk to customers daily and are eager to please. Anything specific will work its way into a sales conversation as a commitment. Always attach confidence.
- **The top-down "here's what we're going to build this year" roadmap**: Common in small, founder-led companies. As the company grows, executives become removed from the product team's details and challenges, so they overestimate what can be accomplished and by when.
- **Digging into operational detail as an executive**: Not an audience failure but a diagnostic — if the board is in the weeds, they've lost trust in the team's execution.
- **Presenting a Gantt chart or agile release plan as the roadmap**: Lines, arrows, connectors, burndowns, burnups, and velocity trackers do not form a good roadmap. Work back and forth between the roadmap and the release plan instead, to check assumptions and be realistic about dates.

## Worked Example

**Case Study: Chef.io's Roadmap Presentation**

*Dropping Like a Lead Balloon (2013).* CEO/founder Jesse Robbins presented a roadmap to the team framed as "here's what we're going to build this year," expecting them to execute the initiatives he'd laid out. As Chef.io grew — more staff defining, building, and shipping the product, plus shifting market conditions — the team couldn't match what the roadmap promised. Within a few years, product and engineering realized they would not hit those expectations and deadlines for the upcoming quarters. Customers were unhappy too: one thought they were getting feature X, another thought feature Y. Missed expectations and disappointment all round. Diagnosis: top-down roadmapping makes sense in theory (the founders set the vision, so they set the plan) but in practice now-executive CEOs, CTOs, and CPOs are removed from the product team's specific details and challenges, so they overestimate what can be done and by when. The roadmap has to account for the company's growth.

*Making Changes.* Product manager Julian Dunn convinced the team to revise both the internal and external roadmaps.

- **Internal**: Managed in ProdPad. Themes arranged on cards, each card related to a business objective, in a **Current → Near Term → Future** layout. Clicking a card reveals more detail, but the theme level is what the team works at. Example card: *Minimum Configuration Installation* — essentially asking "how can we make our products easier for the cloud?" — related to the objective of a more cloud-based product.
- **External**: The product team handed the ProdPad roadmap to product marketing, who pulled from it to create a slide artifact suitable for presenting to customers and partners:
  - **Slide 1** — introduction plus, more importantly, qualifiers and a disclaimer.
  - **Slide 2** — key metrics, recent progress, and definitions of three development cycles: "Considering," "In development," "Released."
  - **Slide 3** — content from the internal ProdPad roadmap, with "Near term" and "Future" horizons collapsed. Exposes the features under consideration without too much detail, framed to avoid firm commitment on delivering those feature sets.
  - Slides 4 and 5 cover "In development" and "Released."

The Slide 3 portion becomes a feedback instrument: if every customer reacts negatively to a roadmapped theme (or feature), the team reconsiders. The reframe that fixed the failure: a roadmap is not a promise or commitment for a set of features.

*Contrast — when detail is mandatory.* Jeff Bussgang at Open Market had to sell customers on a year-long C++ rearchitecture during which no features shipped. He took the architects' internal rewrite document and **reframed it to be customer-centric** — articulating how extensibility, APIs, and integration with existing systems would add value to the customer's business rather than just fixing Open Market's internal problem. That roadmap story bought a year of patience in a competitive market. Similarly, Sasha Dass at Analog Devices: "In our business, you better not show up to a customer meeting without a detailed roadmap" — because device makers plan specs, price points, and volumes years ahead and are betting millions on you delivering.

## Key Takeaways

1. Share internally for three reasons: **Inspiration** (get everyone excited about a future where customers are happy and the company succeeds), **Alignment** (the roadmap tells marketing what to announce, sales when they'll have something new, support when training updates, manufacturing when to retool), and the **IKEA Effect** (people who helped build it defend it).
2. Build one roadmap with a common foundation and per-audience layers. The question is never *whether* to share, only *which portions to whom*.
3. Match detail to distance from the core dev team — with the enterprise/component-manufacturer exception, where a detailed roadmap is the price of the customer's multi-year commitment.
4. Use themes plus confidence percentages as your commitment-management device. "We'll have an initial version ready" gives customers a date to plan around without tying you to a specific deliverable.
5. Prepare with the four-step checklist, then present why → recent progress → near term → long term, with emotion, data, and stories.
6. When a customer demands a feature commitment in public, acknowledge the need, explain that you don't want to limit the team's options by specifying an approach too early, and say when you *will* be able to commit. Then follow up one-on-one and offer to help manage their internal expectations.
7. Expect the roadmap to change for the better once you share it — it meshes with stakeholder needs, leverages serendipitous events, generates new ideas, and gets every group on the same page.

## Connects To

- **Ch 1**: A roadmap is not a project plan — why schedule, resources, dependencies, risks, and status are complementary, not core.
- **Ch 2**: Primary vs. secondary components, and the needs/expectations of each stakeholder group — the basis of the audience matrix.
- **Ch 3**: Identifying internal and external stakeholders — who's on your distribution list.
- **Ch 4**: Product vision (the *why* that opens every presentation) and expanding your addressable market as a growth lever.
- **Ch 5**: Themes — the unit that lets you communicate direction and intent without committing to deliverables.
- **Ch 6**: Stage of development, confidence percentages, and the fact that things change.
- **Ch 8**: Shuttle diplomacy — reused here to preview high-level material with executives and board members and collect concerns before the meeting; the IKEA Effect names why Ch8's co-creation works.
- **Ch 10**: Managing planned and unplanned change to the roadmap, and communicating it.
- **Osborne Computer Corporation (1983)**: The canonical cautionary tale of premature announcement.
