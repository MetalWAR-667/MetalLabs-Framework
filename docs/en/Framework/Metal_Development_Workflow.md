# MetalLABS Development Workflow

**Status:** Living Document  
**Version:** 1.1  
**Language:** English (Canonical)

> *"Let's face it: architecture is the minimum amount of paperwork and mandatory discipline you need to keep your project maintainable, understandable, and—above all—to stop the next person who touches the code from showing up at your house with a baseball bat."*

---

## Objective

This document defines the standard development workflow used during the construction of **Lands of Folklore**.

The goal of this workflow is not to automate development, but to properly distribute responsibilities between the developer and the various AI tools—maintaining architectural control, reducing technical debt, and ensuring that all important decisions remain under human judgment.

This document describes a working process, not a technological dependency.

The workflow will be reviewed whenever practice shows that a phase can be simplified, corrected, or improved.

---

> *"Agents never execute an idea. They execute an approved decision."*

---

## Law 0

> **The workflow exists to serve the project. Never to replace the developer's judgment.**

Tools may change.  
Agents may change.  
The process must remain.

---

## Philosophy

Every change follows this general order:

```text
Think
    ↓
Design
    ↓
Audit the existing state
    ↓
Implement
    ↓
Audit the architecture
    ↓
Validate functionality
    ↓
Synchronize documentation
    ↓
Integrate
Implementation never precedes design.

Documentation never attempts to retrospectively justify a hastily built implementation.

Working code is not automatically correct code.

An implementation must work and must also respect the approved blueprint.

Team Roles
Agents are assigned by responsibility, not by brand or model.

The goal is to keep the workflow stable even as tools evolve or are replaced.

🕶️ Technical Director — Metal
Responsibilities:

Creatively find problems for the team to solve.

Translate complex concepts into understandable language before approval.

Maintain the overall vision for Lands of Folklore.

Design systems alongside the Architect.

Prioritize the roadmap.

Freeze and protect the scope of each Latido.

Make final decisions.

Accept, review, defer, or reject proposals.

Manually validate project behavior.

Act as the ultimate responsible party for code, commits, and documentation.

Authorize integration into the main branch.

Veto Authority:

Metal may halt or reject any proposal, even if work has already been invested.

Work invested does not create adoption rights.

Every rejected proposal must follow one of these paths:

text
Accept
→ enters the project

Request revision
→ returns to Design with specific feedback

Defer
→ moves to Future Seeds with a review trigger

Reject
→ briefly record the reason and close
📐 Architect — Lumen / GPT
Responsibilities:

Design conceptual architecture.

Review responsibilities between systems.

Define contracts between components.

Draft ADR proposals.

Cross-check proposals against the Chassis Laws and current architecture.

Detect conceptual inconsistencies.

Identify architectural risks.

Design the structural evolution of the Editor, Compiler, and Runtime.

Review technical decisions before they are finalized.

Not responsible for:

Keeping documentation synchronized with the actual code.

Periodically auditing the documentation tree.

Locating duplicate files.

Performing mechanical changes across multiple documents.

Implementing features on their own initiative.

Approving decisions on behalf of the Technical Director.

📦 Archivist — Jules Winnfield
Responsibilities:

Audit the docs/ folder.

Check documentation status before starting a new design phase.

Detect related documents.

Locate duplicates and contradictions.

Maintain indexes, tables of contents, and GitHub Wiki.

Synchronize cross-references.

Apply previously approved documentation changes.

Detect obsolete contracts and documentation debt.

Ensure ADR names, statuses, and numbering are consistent.

Prepare scoped documentation changes for review.

Intervention triggers:

The Archivist acts:

before starting a Foundation or major phase;

before creating an ADR;

when closing a phase;

when a decision affects multiple documents;

when reorganizing docs/;

when requested by the Technical Director.

A full documentation audit is not required before every minor Latido.

Not responsible for:

Designing architecture.

Making technical decisions.

Creating new conceptual models.

Modifying contracts without approval.

Converting provisional documentation into policy on their own initiative.

🔍 Auditor — Butch C. Claude
Responsibilities:

Cross-check hypotheses against existing source code in HEAD.

Find inconsistencies between documentation and code.

Audit implementations and technical decisions using real evidence.

Review responsibilities, coupling, and execution paths.

Identify architectural and performance risks.

Review diffs and Pull Requests before consolidation.

Distinguish between functional bugs and architectural deviations.

Evidence requirement:

Every relevant conclusion must include, where possible:

file;

class or function;

specific line or block;

observable behavior;

impact on the proposed blueprint.

If sufficient evidence does not exist, the claim must be marked as:

text
Hypothesis
and never as a confirmed conclusion.

Not responsible for:

Designing architecture from scratch.

Proactively maintaining documentation.

Implementing fixes without authorization.

Modifying the scope of a Latido.

🔧 Implementation Agent
The Implementer is an operational role.

It may be handled by different agents depending on the task.

Responsibilities:

Analyze existing code before modifying it.

Validate hypotheses with evidence.

Implement only the approved blueprint.

Detect real dependencies during implementation.

Report when the blueprint does not cover a situation encountered.

Keep the change scoped.

Review the diff before delivering the work.

Not responsible for:

Redefining architecture.

Expanding scope.

Introducing unsolicited improvements.

Silently resolving new decisions.

Approving their own implementation as correct.

🚚 Explorer — Jack Burton / Gemini
Responsibilities:

Technical research.

Brainstorming.

Exploring alternatives.

Gathering external references.

Consulting official documentation.

Comparing existing approaches.

Feeding the Future Seeds backlog.

Proposing questions that stress-test the design.

Not responsible for:

Validating final architecture.

Consolidating official documentation.

Turning a possibility into a decision.

Introducing future seeds into the current sprint.

Replacing the code audit.

🐺 The Junior — Winston W.
The utility agent, the team's Swiss Army knife.

Does not have a fixed responsibility, but a set of skills applied on demand.

Responsibilities:

Translation and localization: Adapt technical or explanatory texts between languages, preserving tone, intent, and context.

Organization and structuring: Take notes, drafts, or scattered ideas and turn them into coherent documents.

Formatting and presentation: Prepare documents in Markdown, organize tables, clean up formatting, etc.

Answering specific questions: Respond to concrete questions about syntax, tools, workflows, or concepts.

Context preparation: Help Metal prepare prompts, summaries, or documentation for other agents.

General support: Any task that does not clearly fit into Lumen, Jules, or Butch, but still needs to be done.

Not responsible for:

Making architectural decisions.

Auditing code (that's Butch's job).

Designing systems (that's Lumen's job).

Consolidating official documentation (that's Jules's job).

Standard Latido Workflow
1. Design
Metal and the Architect define:

objective;

scope;

responsibilities;

affected systems;

risks;

constraints;

out of scope;

success criteria;

stop criteria.

Output:

text
Implementation Plan
Until the blueprint is approved, implementation does not begin.

2. Pre-implementation Code Audit
Before modifying anything, the Implementer reviews the actual code.

They must answer:

Does this responsibility already exist?

Is there a partial implementation?

Is there duplication?

Which systems depend on the affected code?

Is there coupling that complicates the change?

Are there related signals, states, or caches?

Are there side effects?

Does the blueprint cover all real dependencies?

Is there legacy or frozen code that should be ignored?

Answers must provide concrete evidence:

text
File
Function or class
Line or observable behavior
Impact on the blueprint
If the analysis reveals an architectural decision not covered, the Latido returns to Design.

3. Implementation Preparation
Before modifying:

confirm the active branch;

sync with remote;

verify files match the current HEAD;

check working tree status;

review related contracts and ADRs;

avoid replacing entire files without reviewing the diff;

confirm the scope is still valid.

4. Implementation
The Implementer develops the change following the approved blueprint.

During this phase:

do not expand scope;

do not introduce unsolicited improvements;

do not shift responsibilities between systems;

do not create new abstractions without demonstrated need;

do not modify ADRs to justify the code;

do not hide new decisions inside the implementation.

If a new decision emerges:

text
Stop implementation
    ↓
Record finding
    ↓
Return to Design
5. Architectural Audit
Before functional validation, the Auditor reviews:

compliance with the blueprint;

separation of responsibilities;

ownership;

dependencies;

coupling;

contracts;

signals;

shared state;

dead code;

duplication;

out-of-scope modifications;

consistency with ADRs and Chassis Laws.

The goal is not to check if the function "seems to work."

The goal is to check if the code tells the same story as the blueprint.

Architectural Stop Criteria
If the audit detects an issue, it is classified by impact.

Critical Risk
Examples:

Violates a Chassis Law.

Introduces duplicate ownership.

Breaks stable identity.

Contaminates Editor with Runtime structures.

May corrupt persisted data.

Contradicts an accepted ADR.

Requires redesigning the main contract.

Action:

text
Stop
    ↓
Record the finding
    ↓
Return to Design
    ↓
Revise the blueprint or ADR
    ↓
Reimplement
The Latido cannot continue.

Medium Risk
The issue does not invalidate the overall model, but must be corrected before closing.

Action:

text
Controlled correction
The correction must record:

issue detected;

impact;

authorized change;

reason it does not alter the design;

evidence of resolution.

Low Risk
Does not prevent closing the Latido.

Recorded as technical debt, including:

location;

impact;

reason not to fix now;

review trigger;

likely future phase.

A debt without a review trigger is not considered properly documented.

6. Functional Validation
After passing the architectural audit, Metal manually verifies:

compilation;

execution;

expected behavior;

absence of regressions;

integration with the rest of the system;

Undo/Redo, where applicable;

persistence, where applicable;

user experience, where applicable.

An implementation can be functional and architecturally incorrect.

It can also be architecturally correct and functionally broken.

Both validations are mandatory.

7. Final Review
After fixing functional issues, a brief final check is performed.

Its purpose is to confirm that fixes have not introduced:

architectural shortcuts;

unplanned direct mutations;

new dependencies;

out-of-scope changes;

inconsistent documentation.

8. Git Integration
Every significant change follows this flow:

text
main
    ↓
New branch
    ↓
Implementation
    ↓
Commit
    ↓
Push
    ↓
Pull Request
    ↓
Review
    ↓
Squash & Merge
    ↓
Delete branch
The main branch must remain stable.

Each commit must represent a comprehensible, scoped change.

The Git history is part of the project's technical documentation.

9. Documentation Audit
Once the result is validated, the Archivist determines:

which documents must be updated;

which documents must be created;

which references have become obsolete;

which indexes must be updated;

if duplication exists;

if an ADR should be kept, revised, or replaced;

if the change should be recorded as debt or a future seed.

Documentation describes the final consolidated result.

Never an intermediate implementation state.

10. Closure by the Technical Director
Metal decides one of these outcomes:

text
Accept
Revise
Defer
Reject
Only an accepted outcome can be considered integrated and closed.

Latido Gate Checks
Every Latido must pass through these gates:

text
1. Approved blueprint
2. Pre-implementation code audit
3. Scoped implementation
4. Architectural audit
5. Controlled corrections
6. Functional validation
7. Final review
8. Documentation audit
9. Integration
10. Closure by the Technical Director
Principles
The blueprint rules
Implementation executes and validates the design.

Never the other way around.

Code is evidence
Decisions are grounded in the observable behavior of the project.

Not memory.

Not intuition.

Not outdated documentation.

A hypothesis is not a conclusion
When sufficient evidence does not exist, it must be explicitly stated.

Visible uncertainty is preferable to fabricated certainty.

Each tool contributes where it provides the most value
Not all AIs do the same job.

The goal is not for one tool to do everything.

The goal is for each to handle the responsibility where it provides the highest quality.

Separation between creation and certification
The agent that implements may review their own work.

But architectural certification must come from an independent review whenever the scope justifies it.

Responsibilities are explicit
Architectural decisions belong to the Technical Director.

Implementations belong to the code.

Audits belong to the process.

Documentation belongs to the project.

Git is part of the design
The commit history forms part of Lands of Folklore's technical record.

Each commit must clearly describe the change made.

Documentation does not blindly follow code
If an implementation contradicts the current documentation, first determine which one is wrong.

Existing code does not automatically make a decision correct.

Criteria for Closing a Latido
A Latido can only be considered closed when:

it meets the defined objective;

it respects the approved scope;

it has been cross-checked against the actual code;

it passes the architectural audit;

it passes functional validation;

it contains no open critical risks;

medium-risk corrections have been resolved;

low-risk debts are documented with a trigger;

it is properly integrated via Git;

documentation is synchronized;

Metal explicitly accepts the result.

Adaptability
This workflow does not depend on any specific AI.

If a tool is no longer used, only the agent assigned to a responsibility changes.

The process remains unchanged.

The names of the teammates are part of the current workshop.

The roles are part of the method.

Principle of Sovereignty
Agents do not replace the developer's judgment. Each brings a different perspective to the workshop. Architectural decisions belong to Lands of Folklore, not to the agent that proposed them.

Final Objective
Build a maintainable project.

Not develop faster.

Not write less code.

Not delegate important decisions.

The priority is to preserve:

a comprehensible architecture;

a clear technical history;

consistent documentation;

traceable decisions;

a reproducible process;

human control over design.

The workflow will have fulfilled its purpose as long as it allows Lands of Folklore to continue evolving for years without losing control of the chassis.

Principle of Authority
Agents always work under one of these states:

1. Research
The agent:

observes;

analyzes;

gathers evidence;

modifies nothing.

Output:

text
Report
2. Proposal
The agent:

proposes a solution;

identifies affected documents;

estimates risks;

waits for approval.

Output:

text
Action Plan
3. Approval
The Technical Director decides.

They may:

✔ Approve

✖ Reject

↺ Request changes

Only here does the state change.

4. Execution
The agent implements only what has been approved.

Does not expand scope.

Does not add improvements.

Does not interpret.

5. Review
The work returns to the Technical Director.

Only then can it be integrated.