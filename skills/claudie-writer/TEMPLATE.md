# [Document Title] - Technical Design Document

**Owner:** @engineer
**Team:** `kyc`
**Status:** Draft / Shared on Teams / In-review

## Review Sign-Off

| Reviewer | Date | Approval | Notes |
|----------|------|----------|-------|
| @engineer | | Yes/No | |
| | | | |
| | | | |

---

## Context

[Short introduction — what is this system/feature and why does it exist?]

## Glossary

| Term | Definition |
|------|-----------|
| Term | Definition |

## Problem

List out all problems that need to be discussed/solved in the design.

1. First problem
2. Second problem

## Goal

What are you expecting to solve with this design?

- Goal 1
- Goal 2

## Out of Scope (Non-goals)

If there are related problems you have decided not to address with this design, list them here.

- Non-goal 1
- Non-goal 2

## Assumptions

What are you assuming will be true or in place to make your solution successful?

- Assumption 1
- Assumption 2

## Constraints / Limitations

List all the things this system is NOT intended to do or cannot do.

- Constraint 1
- Constraint 2

## Overview

Start by including a high-level diagram and decompose from there. Diagram (where possible) how your solution interacts with other subsystems and services, including sequence diagrams for complex interactions.

```
[High-level architecture diagram]
```

### Sequence Diagram

```
[Sequence diagram for key flows]
```

## Design Detail

### What are you going to deliver?

### Upstream and Downstream Dependencies

**Upstream (callers):**
-

**Downstream (dependencies):**
-

### How does it fit into the broader service?

### How will it scale?

### What are the limits of your solution?

### Fault Tolerance and Recovery

How will you ensure fault tolerance and quick recovery after failure?

### Future Evolution

How might your solution evolve to meet future requirements?

## Security Considerations

What are the security implications of your solution? If your solution is large enough in scope to warrant its own threat model, please add it here; otherwise describe how your solution impacts existing threat models.

## Operational Readiness Considerations

### Deployment

How will your chosen solution be deployed?

### Metrics and Alarms

What metrics and alarms will be key to monitoring the health of your solution?

### Limits Enforcement

How are your solution limits enforced?

### Throttling / Blacklisting

Will there be any throttling or blacklisting mechanisms in place?

### Data Recovery

Will there be any data recovery mechanisms in place?

### Noisy Neighbor (Multi-tenant)

If this is a multi-tenant solution, how are you dealing with noisy neighbor issues?

### Debugging

How will your solution be debugged when problems occur?

### Brown-out Recovery

How will your solution recover in case of a brown-out?

### Operational Tools

Are there any operational tools required for your solution?

## Rollout Plan

- **Phase 1:**
- **Phase 2:**
- **A/B tests:** Define any A/B tests planned as part of rollout
- **Data migration:** Describe any required data migration steps

## Test Plan

- How are you planning to test the service?
- How will you test the dependencies?
- Will you be creating mocks for dependencies or using a sandbox environment?
- How are you planning to run load and performance tests?

## Q&A

| Question / Concern | Answer / Resolution |
|--------------------|---------------------|
| | |

## Appendix

### References

- [Writing Technical Design Docs](https://medium.com/machine-words/writing-technical-design-docs-revisited-850d36570ec)
- [Stan Dev Design Docs](https://github.com/stan-dev/design-docs)
- [WePay Design Doc Template](https://github.com/wepay/design_doc_template)
