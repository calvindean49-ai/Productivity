# CLI agent orchestration centre + second brain — plan, draft 1

**Date:** 17 September 2026
**Status:** draft for back-and-forth. Nothing here is decided. Open questions are in §10; answer those and I redraft.
**Ground truth read for this draft:** `aether-os` at `a63590f` (ROUTE.md, NOW.md, ARCHITECTURE → *The Foreman*, QUEUE.md Phase 23, DECISIONS D-M14/M15/M33/M57, `src/foreman/`, `scripts/aether-run.sh`, `scripts/foreman-agent.ts`, `.claude/agents/*`), the `second-brain` repo (empty), and this repo (Lockdown).

---

## 0. What you asked for, in your words, restructured

1. **A front / an OS** that communicates with the Claude CLI, Codex, ChatGPT etc. and gets stuff done.
2. **Number 1 priority: a centre for CLI workflows** — Claude communicating with Codex etc., delegating among a team of spun-up CLI agents. The work itself may happen in the desktop app or a terminal; the OS must **show what is going on**.
3. The CLIs must be able to **set up workflows when prompted**, or understand how to.
4. It must also be a centre for **UI design and 3D game machinery**.
5. **Number 2: one context bank / second brain** that everything writes into, which the CLIs read from (and, per your first paragraph, edit). Not only for building things: the CLIs cooperate on personal projects — maths mastery, scheduling.
6. You have **Freebuff**, **Codex** and your plan subscriptions. Work must run **in the cloud and locally**, be **controlled from the OS**, and you can **see visually what workflow is happening**.
7. CLIs such as Claude Code must be **contactable through the OS**, set up a workflow, and **report everything back** to the OS for display.
8. **No API anywhere.** Everything runs on the subscriptions you already pay for (CLI logins), not on API keys.
9. Don't over-architect. Grounded in certainty of success.

---

## 1. Honest assessment first

**Rating of the idea as stated: 7/10.** The goal is right and the constraints (no API, subscriptions only, git-visible) are the *correct* constraints — they are what make it cheap and reliable. The two points off are for a real risk: **most of item 2 already exists**, and building "a front" from scratch would be building it twice.

**The finding that changes the plan:** `aether-os` already contains the orchestration centre. It is called the **Foreman** (built 12–14 Sep, `src/foreman/`, `server/foreman.ts`, `foreman.html`). Measured from the tree, not from memory:

| You asked for | Exists today in the Foreman | Gap |
|---|---|---|
| A console that contacts Claude Code and starts work | `npm run foreman:dispatch` starts `scripts/aether-run.sh <lane> 1 [unit]`, which runs `claude -p "/aether-run …" --permission-mode bypassPermissions`. Logged-in CLI, no API key (`env -u` strips the six `ANTHROPIC_*` routing vars). | First live run built nothing: expired `claude` login (D-M19). No one-command start (Q23.17). |
| Claude delegating to a team | The **main agent** (Q23.3, ◐): one Claude Code session takes a goal, `commission`s units with done-criteria, `request`s workers and reviews. It cannot build, rule, claim or close (nine refusals in `scripts/foreman-agent.ts`). Five review personas in `.claude/agents/` (builder, cold-reviewer, risk-assessor, architect, designer). | ◐ on two of its own ⛔s (Q23.13 classifier hole, Q23.14 token readable). |
| Codex / other CLIs in the team | **Decided 13 Sep (D-M33):** Codex, Gemini, Cursor's agent and Freebuff join **as reviewers first**, one shared slot, promoted to building only by you. Adapter interface exists (`src/foreman/adapters/types.ts`); Cursor and freebuff are `notWired`. | **Parked (Q23.9, D-M57):** none of the four CLIs is installed or signed in on any machine a worker has run on. The row forbids guessing a command line; it must come from the real `--help`. **This is the single biggest blocker and it is a 20-minute job on your Mac.** |
| Show what is going on | Console at `http://127.0.0.1:5174/foreman.html`: lanes, dispatch, work, ledger, review verdicts (`docs/reviews/<unit>-<pass>.md`), tree stamp. Runs and goals live in a local store, `.aether/foreman.sqlite` (tables `runs`, `goals`, `dispatcher`); the page polls `/api/foreman/dispatch` every 5 s and a run's log every 4 s. Dead workers detected at read time (Q23.6). | Console **cannot write** — no form to rule/commission/park/set a goal; POST only (Q23.12). No usage display (Q23.18). |
| Cloud + local | Local Mac lanes (`aether-run.sh`, capped per lane). Cloud lanes = five Claude Code Remote routines on a cron, toggled by the `lanes` skill. | Console observes cloud lanes, cannot steer them (Q23.19). |
| Everything reports back | Git is the bus: `CLAIMS.md`, `state/<lane>.md`, `docs/QUEUE.md`, `docs/reviews/`, `DECISIONS.md`; console reads them **out of `origin/main`** via `git show`. | Works. This is the pattern the second brain should copy. |
| UI design / 3D | `designer` agent, Higgsfield adapter, `threejs-devtools-mcp` and `unreal-mcp` in `.mcp.json`, `design-taste-frontend` / `image-to-code` skills. | Nothing needed for this plan. |
| Second brain | **Does not exist as a shared store.** `second-brain` repo is empty. Aether's knowledge lives in SQLite (`knowledge_objects`, `inbox_items`, conversations) which a CLI cannot read without the server. The five pillars are markdown, but they describe Aether, not you. | **The whole of item 5 is new work.** |

**So the honest shape of the plan is:** (a) unblock and finish the Foreman (four queue rows, one of which is you signing in to Codex); (b) create the second brain as a git repo of markdown that every CLI reads and writes; (c) make Aether show the Foreman's state read-only. Not a new "front".

**What I am uncertain about** (stated rather than guessed): what **Freebuff** is — I could not find it as a public CLI, and the aether-os tree only knows it as a binary name `freebuff` that has never been on PATH. See Q1 in §10.

---

## 2. Principles this plan holds to

1. **No API keys.** Every agent is a CLI logged into a subscription: `claude` (Max), `codex` (ChatGPT), `gemini` (Google). A tool that cannot be driven headless from a login is not in the team. (Aether's *product* chat still uses API keys on the VPS. That is separate and unchanged; it is not orchestration.)
2. **Git and markdown are the bus.** No message queue, no sockets between agents. An agent's instruction is a file it reads; its report is a file it commits. Every CLI can do that; the Foreman already reads that way. Anything visible in the OS is read *out of a commit*.
3. **One writer per file, append-only where two can collide** (`CLAIMS.md` pattern). This is what makes five concurrent workers safe without a server.
4. **Nothing duplicated.** No second queue, no second review format, no second conversation store. Extend the Foreman; don't build beside it.
5. **Each step is one session's work with a done-criterion a stranger can check.** That is the constitution's rule and it is also why this plan is "grounded in certainty": every step is small and measurable.

---

## 3. Target shape

```
                 ┌───────────────────────────────────────────┐
                 │  second-brain (git repo, markdown)         │
                 │  the ONE context bank                      │
                 │  AGENTS.md ← CLAUDE.md, GEMINI.md point here│
                 │  projects/  learning/maths/  schedule/     │
                 │  workflows/  inbox/  decisions/            │
                 └──────▲───────────────▲──────────────▲──────┘
          read + write  │               │              │ read (git show)
                        │               │              │
   ┌────────────┐  ┌────┴─────┐   ┌─────┴────┐   ┌─────┴───────────────────┐
   │ claude CLI │  │ codex CLI│   │gemini CLI│   │ Foreman (aether-os)      │
   │ local+cloud│  │ local    │   │ local    │   │ console + dispatcher     │
   └─────▲──────┘  └────▲─────┘   └────▲─────┘   │ starts workers, reads    │
         │              │              │         │ CLAIMS/QUEUE/reviews     │
         └──────────────┴──────────────┘         └──────▲───────────────────┘
                 started by dispatcher                  │ read-only
                 (one command line per tool,            │
                  measured from its --help)      ┌──────┴────────┐
                                                 │ Aether OS     │
                                                 │ "glance" panel│
                                                 └───────────────┘
```

- **Foreman** = the orchestration centre (item 2). Separate from Aether by your own 12 Sep decision.
- **second-brain** = the context bank (item 5). A repo, not a database, so a CLI reads it with `cat` and writes it with `git commit`.
- **Aether** = where you *see* it (item 7). Read-only view of the same files and the dispatcher's run store.

---

## 4. The second brain (context bank)

### 4.1 Why a git repo of markdown, not a database or Aether's SQLite

- Claude Code, Codex and Gemini CLI all read a project instruction file at the repo root (`CLAUDE.md`, `AGENTS.md`, `GEMINI.md`). Codex reads `AGENTS.md` natively. That is the "all CLIs share the same context" mechanism, with zero glue.
- Cloud sessions (Claude Code on the web, Codex cloud) start from a git checkout. A repo is the only store both a local and a cloud session can reach without an API.
- The Foreman already proves the reading pattern (`git show origin/main:<path>`, memoised per commit).
- Aether's SQLite cannot be read by a CLI without the server up, and writing it from an agent violates "never write the real database".

### 4.2 Proposed layout (small on purpose)

```
second-brain/
  AGENTS.md            ← the single instruction file. What this repo is, how to read it,
                          how to write to it, where a workflow lives. Canonical.
  CLAUDE.md            ← one line: "@AGENTS.md" (Claude Code imports it)
  GEMINI.md            ← same, for Gemini CLI
  INDEX.md             ← one screen: current projects, current focus, links. Rewritten in place.
  projects/<name>.md   ← one file per project: goal, state, next, links to repo/branch
  learning/maths/…     ← mastery map, what is proven vs practised, next probes
  schedule/            ← week plan, commitments, recurring routines (markdown tables)
  workflows/<name>.md  ← a workflow spec a CLI can execute (see 4.4)
  inbox/               ← raw captures, triaged into the above
  decisions/log.md     ← append-only, dated, same shape as aether-os DECISIONS.md but tiny
  runs/                ← what agents did: one short file per run (who, when, what changed)
```

### 4.3 Write rules (the whole "constitution" of this repo, kept to five lines)

1. `INDEX.md` and `projects/*` are **replaced in place**, never appended with dated layers (aether-os learned this the hard way at 3,459 lines).
2. `decisions/log.md`, `runs/*` and `inbox/*` are **append-only**.
3. Every agent commit message starts with the tool name and run id: `codex r-0142: …`.
4. An agent never deletes a file it did not create in the same run.
5. Aether reads this repo; it never writes it. (If you want Aether's inbox to flow here, that is a later, separate decision. Aether's own `pinned_memories` table is deliberately constrained so a model cannot write a mastery claim; the second brain must not become a way round that.)

### 4.4 "The CLIs can set up workflows when prompted"

A workflow is a markdown file under `workflows/` with a fixed shape — goal, trigger, steps, which tool does each step, done-criterion, where the output goes. `AGENTS.md` tells every CLI: *to set up a workflow, write one of these; to run one, follow it.* That is enough for a Claude Code or Codex session to author a workflow from a sentence you type, because the shape is in the file it already loaded. No engine needed for phase 1. The Foreman's main agent already does the "goal → units" split for code; the same session can write a `workflows/` file for non-code work.

### 4.5 What stays in Aether

Aether's knowledge graph, learning evidence and gates are untouched. The second brain is *about you and your projects*; Aether's SQLite is *evidence of learning*. They meet only at the read-only glance (§7) and, later, if you decide it, an inbox export.

---

## 5. The orchestration centre — finish the Foreman

In dependency order. Each is an existing or trivially-filed queue row.

| Step | Row | What | Your half |
|---|---|---|---|
| 5.1 | Q23.17 | `npm run foreman:up` / `down`; probe `claude` login before the dispatcher starts; one status strip. | none |
| 5.2 | Q23.12 | Console forms for rule / commission / park / **set a goal**. Today these are POST-only. This is what makes "contact Claude Code through the OS" true in the literal sense. | none |
| 5.3 | Q23.9 | **Codex adapter.** Install `codex` on the Mac, sign in with ChatGPT, save `codex exec --help` under `reports/q23-9/`, write the adapter against it in **read-only sandbox** (`codex exec --sandbox read-only …`), prove a planted write leaves a scratch tree byte-identical. Reviewer only, per D-M33. Gemini follows as its own commit (`gemini -p …`). | **install + sign in to Codex and Gemini** |
| 5.4 | Q23.19 | Console shows and switches the cloud lanes (through a session running the `lanes` skill). | none |
| 5.5 | Q23.18 | Usage strip: what each run's CLI output reported, never an estimate. | none |
| 5.6 | new | Point the Foreman at a **second repo**: `second-brain`. Today `readForeman` reads aether-os's own `docs/QUEUE.md`. Make the repo root a parameter so the same console can run a "personal" lane whose queue is `second-brain/workflows/`. | decision (Q5 in §10) |

**Cross-CLI delegation, concretely (item 2):** you type a goal in the console → main agent (Claude) commissions units into `docs/QUEUE.md` → dispatcher starts a `claude-local` worker on a unit → worker pushes → you (or the main agent) request a review → dispatcher starts `codex exec --sandbox read-only` on a scratch copy with the cold-reviewer brief → Codex writes `docs/reviews/<unit>-codex.md` → console shows it beside Claude's passes. Claude and Codex never talk to each other directly. They read and write the same files. That is the whole protocol, and every piece of it except the Codex command line exists today.

**Not in phase 1, on purpose:** ROUTE.md asks for a persisted run/step/artifact model for Aether's own assistant work. It is unbuilt, and the Foreman's `runs` + `goals` store plus the review files already give you visibility for orchestration. I would not build it for this.

**Codex building, not just reviewing,** is your promotion decision (D-M33 §f), taken after you have seen its review record. I would not pre-plan it.

---

## 6. Cloud and local

| | Claude Code | Codex | Gemini |
|---|---|---|---|
| Local headless | `claude -p` ✅ in use | `codex exec` (to measure) | `gemini -p` (to measure) |
| Cloud, plan-included | Claude Code Remote routines ✅ (five lanes on cron) | Codex cloud tasks exist on ChatGPT plans, started from the Codex app/web. **Whether they can be started from a script without an API is unmeasured.** | none known |
| Controlled from the console | local: yes; cloud: Q23.19 | local: after Q23.9 | local: after Q23.9 |

Recommendation: cloud = Claude only for now. Codex and Gemini local, as reviewers. Revisit Codex cloud once Q23.9 lands and you can measure what `codex` offers from a terminal.

---

## 7. Showing it in Aether ("see visually what workflow is happening")

Three options, in order of cost:

- **A. Link.** Aether's HUD gets a "Foreman" button that opens the console. Zero risk, ten minutes, and it honours your 12 Sep "separate from Aether" decision exactly.
- **B. Read-only glance panel (recommended).** A small Aether panel that renders the dispatcher's run view (running / ended / lost, per lane and tool) and the last five review verdicts. The data already exists behind `GET /api/foreman/dispatch` and `GET /api/foreman/reading`; the panel polls them the way the console does. No writes from Aether. The `verify:foreman` wall (product must not import `src/foreman/`) means Aether *fetches* from the Foreman server, never imports it; and the Foreman's token must not reach the product page, so this needs one read-only, token-less route on `127.0.0.1` or a proxy rule. That is the one real design point in this option.
- **C. Foreman inside Aether.** Reverses your 12 Sep decision. I would not.

Ask: do you want B (see Q3)?

---

## 8. Personal projects (maths mastery, scheduling) on the same rails

Phase 1 needs nothing special: a `claude` or `codex` session opened in `second-brain/` already has your maths map and schedule in context via `AGENTS.md`, and writes back to `learning/` and `schedule/`. Delegation for non-code work is a `workflows/` file plus, once 5.6 exists, the dispatcher running a "personal" lane. Scheduling stays in Aether's own calendar (your 13 Sep decision) — the second brain holds the *plan*, Aether holds the *commitments*. Whether that split is right is Q6.

---

## 9. First execution steps (in order; each one session or less)

1. **You:** on the Mac, `npm i -g @openai/codex && codex login` (ChatGPT), and install + sign in to Gemini CLI. Run `codex exec --help` and `gemini --help` and commit the output under `aether-os/reports/q23-9/`. **This unparks Q23.9 and is the only thing on the critical path that is yours.**
2. **Session:** create `second-brain` contents per §4.2 — `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `INDEX.md`, empty dirs with a `README` line each, one real `projects/aether-os.md` and one real `projects/lockdown.md` seeded from the two repos' READMEs. Done when: `claude -p "what am I working on"` run inside the repo answers from `INDEX.md`, and the same for `codex exec`.
3. **Session:** Q23.17 (`foreman:up`). Done when one command starts all three processes and refuses with the sign-in command when `claude` is logged out.
4. **Session:** Q23.9 Codex adapter, reviewer-only. Done criterion is already written in the row.
5. **Session:** Q23.12 console write forms, including *set a goal*. Done when you can type a goal in the browser and watch the main agent commission units and the dispatcher start a worker, with no curl.
6. **Session:** §7 option B glance panel in Aether.
7. **Then decide** (not before): Foreman on a second repo (5.6), Codex promotion to builder, Codex cloud.

Steps 2 and 3 are independent and can run in parallel lanes. Step 4 waits on step 1. Step 5 waits on nothing but is worth less than 4 (a goal you can type is not worth much until the team it dispatches to exists).

---

## 10. Open questions — answer these and I redraft

1. **What is Freebuff?** A CLI coding agent, a cloud service, something else? Does it have a headless command and a login? The aether-os tree only knows the binary name and has never seen it installed. If it has no terminal mode, it cannot be in the dispatcher's team under the no-API rule, and I would drop it from phase 1.
2. **"Where the CLIs read from only"** — did you mean the CLIs *only read* the second brain (something else writes it), or that it is *the only place* they read context from, and they also write back? Your first paragraph says "read from and edit to". I have assumed read **and** write with the rules in §4.3.
3. **Visibility:** is the Foreman console itself enough as "the OS shows what is going on", or do you want a read-only panel inside Aether (§7 option B)?
4. **Second brain home:** the empty `calvindean49-ai/second-brain` repo — use it, or do you want it inside aether-os? (I recommend the separate repo: it must be cloneable by a Codex session that should never see Aether's tokens.)
5. **Personal lane:** do you want the Foreman to dispatch non-code work (maths, scheduling) in phase 1, or is "a CLI session with the second brain loaded" enough to start? I recommend the latter; 5.6 is the first thing I would cut.
6. **Scheduling boundary:** keep commitments in Aether's calendar (13 Sep) and only the plan in the second brain, or move scheduling wholesale into the second brain?
7. **Mac availability:** the Foreman, local lanes, and Codex all run on the Mac. Roughly how many hours a day is it on and logged in? That decides how much should be pushed to cloud lanes.
8. **Priority between the two halves:** if you only get one this week, Foreman unblocked (steps 1, 3, 4) or second brain seeded (step 2)?

---

## 11. Persona pass (the aether-os review personas, applied to this plan)

- **cold-reviewer:** *Which claims are unsupported?* The Codex and Gemini command lines in §5.3/§6 are from public docs, not from a measured `--help` on your machine — the plan treats them as hypotheses, which is exactly what Q23.9's clause (a) demands. Codex cloud controllability is marked unmeasured. The claim "Codex reads `AGENTS.md` natively" is from its documentation and should be confirmed in step 2's done-criterion (it is).
- **risk-assessor:** *Any gate reached?* No. Nothing in this plan touches an evidence threshold, the automation rule or asset levels. The second brain is outside Aether's learning system by construction (§4.5). The one line to watch: Aether must never *write* the second brain from an automated path, or it becomes a second channel for self-report reaching the graph.
- **architect:** *Owning pillar?* Everything in §5 is ARCHITECTURE → *The Foreman*; §7 option B adds one Foreman route and one Aether panel, owned by ARCHITECTURE and WORLD respectively. The second brain has no pillar because it is not Aether — its `AGENTS.md` is its own single owner. This document should move to `aether-os/docs/proposals/` or the second-brain repo once you say which; it sits in the Lockdown repo only because that is this session's branch.
- **designer:** nothing visual to judge until §7 B; the glance panel inherits the HUD register.

## Council notes

- The draft and the challenge disagreed on *build a front* vs *finish the Foreman*; the challenge won on measurement (the table in §1). If you disagree with the 12 Sep "separate from Aether" decision, §7 changes and I need to know.
- Genuinely uncertain: Freebuff's nature, Codex cloud without an API, and how much of the Max allowance a Codex reviewer saves versus a second Claude pass (it spends ChatGPT quota instead, which is the point, but that quota is unmeasured).
- Assumption to check: that you want Codex as a *reviewer first* still holds (D-M33, four days old). If you now want it building from day one, step 4's done-criterion changes and the risk goes up.
