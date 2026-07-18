# 🧪 MetalLab IAS Framework
## The Chaos Budget — v0.0777
*An experimental framework for controlled creative mutation in AI agents*

> *"Innovation without discipline turns into chaos. Discipline without experimentation turns into stagnation. The Chaos Budget exists somewhere in between."*

---

### Law 0 — MetalLab exists to serve Lands of Folklore, never to replace it.
> *"MetalLab is a laboratory for learning, research, and experimentation. Its mission is to improve the processes, tools, and knowledge applicable to Lands of Folklore and future projects. The laboratory must never become an end in itself or displace the development of the main project."*

A serious laboratory that does not take itself too seriously.

Three agents enter. Only one leaves with an approved pull request.

Before anyone jumps to conclusions, a clarification:  
This is not intended to prove which AI is better.  
It aims to test what happens when different AIs work under the exact same rules, with the same change budget, and the same review criteria.

If these models disappear tomorrow and new ones emerge, the experiment should remain valid.  
**Models are replaceable. The process should not be.**

If Gemini, Claude, Codex, or Jules disappear in three years, and four entirely different agents appear, the protocol should work exactly the same way.  
If that happens, the framework will have proven that it is abstracted from the technology provider.

---

## 📖 1. Executive Summary

The Chaos Budget is an experimental software engineering framework designed to investigate whether different AI agents can detect, propose, and implement valuable, unexpected, and technically sound improvements when working within a strictly constrained environment.

The testbed will be **The METAL_IAS — Absurdly Oversized Installer**, a small, functional, deliberately oversized, and sufficiently expendable project to allow for experiments without endangering critical development.

The goal is not to find out which AI writes more code.  
Nor is it to prove that an agent can replace the developer.  
The goal is to study:

- What each agent considers valuable.
- How it selects problems.
- How much context it requires.
- How it responds to strict constraints.
- The quality of its implementation.
- How much human labor is required to verify it.
- Which types of tasks each model is most efficient at.
- When a fast model is sufficient and when it is worth using an advanced one.

The ultimate purpose is not pure automation.  
It is controlled emergence and the construction of an AI-assisted workflow that is useful, verifiable, and sustainable.

---

## 🎯 2. The True Objective of the Experiment

This experiment does not aim to discover which AI agent is "the best."  
It is not about Jules.  
It is not about DeepSeek.  
Nor Codex.  
Nor Gemini.  
Nor Claude.

The true object of study is **the Chaos Budget**.  
That is, the workflow framework that defines how different agents can collaborate within an engineering process where creativity is permitted, but the scope remains strictly controlled.

The proof that the framework makes sense is very simple: if all current models were to disappear tomorrow and be replaced by entirely different ones, the experiment would still be valid. It would be enough to replace the current agents with new ones and apply the exact same rules.

If the conclusions remain useful regardless of the model's name, it means that the value of the experiment does not lie in comparing a specific technology, but in designing a reproducible process for collaborating with artificial intelligence agents.

**Models will change. The framework will remain.** And that is precisely the true objective of MetalLab.

---

## 🎯 3. Core Hypothesis

A software project can safely reserve a small **Chaos Budget** where different agents explore unconventional ideas without compromising:

- Stability.
- Architecture.
- Scope.
- Maintainability.
- Long-term vision.
- The main branch of the project.

Creativity becomes an experiment. Architecture remains deterministic. Innovation becomes probabilistic.

---

## ⚠️ 4. Prior Hypotheses and Limitations

Expectations regarding Jules, Gemini, Codex, or Claude represent only prior hypotheses based on past experiences. They do not constitute results or conclusions.

These predictions must be kept unmodified before starting the experiment in order to later compare which behaviors were unexpected and which judgments were conditioned by previous experiences.

### 4.1 Context Limitation
Initial tests can be performed without providing the agent with the full context of the project:
- ADRs.
- Architectural contracts.
- Historical decisions.
- Design philosophy.
- Exhaustive technical documentation.

Therefore, a poor result should not automatically be attributed to a limitation of the model. It may stem from a lack of context, poor problem division, or ambiguity in the mission.

### 4.2 Prior Observation
All models tested so far have shown that they can work surprisingly efficiently when they receive:
- Sufficient context.
- A problem broken down into small, coherent pulses.
- Missions with a limited and well-defined scope.

For this reason, MetalLab does not intend to answer *"Which is the best AI?"*, but rather to observe how the behavior of each changes when they share the same conditions.

---

## 🛡️ 5. Fundamental Rules

### 5.1 The Gold Rule
Every experiment must be completely disposable.
If deleting the experimental branch harms the project, the isolation has failed, and the experiment is invalidated.

### 5.2 The Protected Core — Immutable DNA
The following elements define the project's identity and **cannot be modified**:
- Main entry point (`main.py`).
- Documented architecture.
- Public API contracts.
- Project philosophy.
- Coding standards.
- Stable installation flow.

Agents can read, analyze, and criticize them in their report, but they cannot modify them just because they felt particularly inspired one night.

### 5.3 Maximum Mutation Budget
Each cycle allows at most:

| Resource | Limit |
|---------|--------|
| New feature | 1 |
| Modified source files | 2 |
| New resources or data files | 1 |
| Architectural changes | 0 |
| Broken tests | 0 |
| Creative excuses | 0 |

The budget is a maximum limit, not a mandatory goal. An eight-line solution can be better than a three-hundred-line one.

### 5.4 Survival Rules
Any of the following conditions implies the automatic rejection of the mutation:
- Syntax or compilation error.
- Broken automated tests.
- Unjustified reduction in coverage.
- Violation of architectural contracts.
- Significant performance regression.
- Hidden side effects.

### 5.5 Legitimate Option of Inaction
The agent may conclude that no modification is worth consuming the Chaos Budget. In that case, it must explain what alternatives it evaluated, why it discarded them, and what it learned about the current system.

Modifying nothing can demonstrate system understanding, restraint, maturity, and prioritization capacity.

---

## 🏗️ 6. Experimental Design

All agents start from the same frozen point: **`chaos-base-001`**. The agents do not communicate with each other and are unaware of their competitors' proposals.

### 6.1 Phase A — Free Mutation
All agents receive the complete repository, the Chaos Budget, the laboratory rules, and **no guidance** on which module they should touch.

- **Experimental question:** What does each model see when it observes the project without anyone telling it what to look for?
- **What is evaluated:** Initiative, problem selection, global understanding, restraint capacity, and the capacity to refrain from acting.

### 6.2 Phase B — Directed Mission
All agents receive the same file or subsystem, the same task, the same constraints, and the same clean base commit.

- **Experimental question:** How does each model solve the same technical problem when they all start from exactly the same point?