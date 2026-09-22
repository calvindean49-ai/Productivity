# Maths Mastery — External Research Review and Critique

**Written 22 September 2026. Companion to the Coaching Document, not a replacement for it.**

This file does three things: (A) says what should change this week, (B) sets out what the research actually
supports about training mathematical ability, organised under declarative / procedural / conditional,
(C) critiques the current plan against that research and against its own internal logic, and (D) gives
drop-in replacement text for the sections that should change.

Where this file contradicts the Coaching Document, the Coaching Document still wins until Calvin decides
otherwise. Contradictions are flagged explicitly in §F.

---

## §A Read this first — the six things that change

Ranked by how much they change outcomes, not by how interesting they are.

**A1. The plan is built on blocked practice. The strongest evidence in mathematics learning says
interleave.** Rohrer et al. (2020), a randomised controlled trial with 787 students across 54 classes:
blocked practice scored 38% on the delayed test, interleaved practice scored 61%, d ≈ 0.83. That is a very
large effect for an education RCT, and it is *specific to mathematics*, not imported from word lists.
The current weekly OS is blocked at every level: Monday olympiad topic, Tuesday the same topic, Wednesday
Layer 0 drill, Saturday geometry — and Phase 2 is explicitly "rotation of ~2 weeks each" per topic.
Two-week topic blocks are the practice structure the RCT says loses 23 percentage points.
**Fix: within every session, no two consecutive problems should use the same method.** The topic block can
stay as the *reading* unit; it must not be the *problem* unit. See §E2.
Caveat worth keeping honest: Rohrer's teachers all reported interleaved assignments took longer, so the
per-hour effect is smaller than d = 0.83 suggests. It is still the best-supported single change available.

**A2. The retest intervals in §4 are too short for the horizon.** Cepeda et al. (2008), 1,350 participants:
the optimal study gap is roughly 10–20% of the retention interval. For TMUA (about 15 weeks out) that is
**1.5–3 weeks**, not "~2 days, then ~1 week". For A-levels in June (about 36 weeks) it is 4–7 weeks.
A 2-day retest mostly measures recency. It will generate false "Reliable" ratings — which is exactly the
failure mode §4 was written to prevent.
**Fix: first retest at 10–14 days, second at 4–6 weeks.** See §E1.

**A3. Three hard external events have no scheduled preparation.**
- **SMC, Wed 7 Oct.** The 2025 BMO1 boundary was 104/125 on the SMC. Calvin has reached Senior Kangaroo
  once — that is the band *below* the BMO band. The whole of Phase 2 (five weeks, 11 Oct – 18 Nov) exists
  to serve BMO1, and BMO1 only happens if the SMC clears. The plan allocates zero hours to the SMC, and
  sits it in the middle of assessment week. **Check with school whether they can enter you for BMO1
  directly (UKMT has historically allowed schools to enter additional candidates for a fee).** If they
  can, the SMC stops being a gate and Phase 2 is safe. If they cannot, Phase 2 needs a written
  contingency: what those five weeks become if there is no BMO1.
- **Personal statement, 30 Nov.** §2 sets the deadline; §7 contains no slot for it. "Drafted in Phase 2
  evenings" collides with the olympiad blocks that occupy every Phase 2 evening.
- **Chemistry.** §3 names it as the subject most likely to erode quietly, on Year 12 evidence only, and
  then schedules ~30 min/day of retrieval shared between Physics *and* Chemistry — about 1.75 h/week each
  against 15–17 h/week for maths. If the Imperial offer is A\*A\*AA on four subjects, an A in Chemistry is
  load-bearing and no TMUA score compensates for missing it.

**A4. Saturday 10 October is a contaminated baseline.** Assessments Mon 5 – Fri 9, SMC on the Wed, then a
150-minute cold TMUA paper on the Saturday. The point of that paper is a clean read on timed precision.
It will instead measure fatigue. **Move it to the following weekend (17 Oct)** — Phase 2 starting a week
late costs almost nothing; a corrupted baseline costs the whole measurement.

**A5. The coaching mode in §10 should be conditional on evidence state, not uniform.** "Socratic by
default, no answers unless asked" is correct for topics where there is something to be Socratic *about*.
For material never opened (integrating factor) or never completed (3×3 inverses), the worked-example
effect says studying a full worked solution beats attempting the problem — and the expertise reversal
effect says that flips once competence exists. One uniform mode is wrong at both ends. See §E3.

**A6. The struggle floor is half of productive failure.** Sinha & Kapur (2021) reviewed 53 studies and 166
comparisons: problem-solving *before* instruction beats direct instruction on conceptual understanding and
transfer without costing procedural fluency — **but the mechanism requires the instruction phase to
follow.** Forty-five minutes of struggle followed by more Socratic questioning is not productive failure;
it is unproductive failure. §9's struggle floor must end with the canonical solution shown in full and
contrasted against what was attempted.

---

## §B What the research supports, organised as asked

### B0. The frame itself holds up — with one correction

The Coaching Document's model — declarative, procedural and conditional knowledge developing *together*
rather than in sequence — is the mainstream position and is well supported. Rittle-Johnson and colleagues'
review of the mathematics evidence concludes the relation is **bidirectional and iterative**: conceptual
knowledge at pre-test predicts procedural skill at post-test, and procedural skill at pre-test predicts
conceptual knowledge at post-test. Each gain feeds the other. So the document's refusal to "learn the
concepts first, then practise" is right.

The correction: the declarative/procedural/conditional triad is standardly a **metacognitive** taxonomy
(knowing *what* strategies exist, *how* to run them, *when and why* to choose them), and the document uses
it as a taxonomy of mathematical knowledge. That mostly works, but it leaves out a fourth thing Schoenfeld
found mattered as much as any of them — **beliefs** — and beliefs appear nowhere in §1 or §5. See B4.

### B1. Declarative — the schema

**What it is here:** definitions, theorems, standard results, and above all the *connections* between them.
Not "facts" in the flashcard sense.

**What the evidence supports:**

- **Chunking is the mechanism of expertise.** Chase and Simon's chess work, and the template theory that
  refined it, found experts store thousands of domain-specific perceptual chunks that evolve into
  *templates* — core patterns with slots for variable detail. Masters reconstruct a real position after a
  few seconds' exposure; on randomised positions they are barely better than novices. The implication for
  maths: what separates a strong student from a mathematician is not more theorems, it is theorems
  organised into recognisable configurations. Schema reconstruction (the concept-map exercise in the
  baseline battery) is a reasonable *measure* of this. It is a weak *builder* of it.
- **Retrieval practice and spacing are the two highest-utility techniques overall** (Dunlosky et al.,
  2013 — both rated high utility; everything else, including self-explanation, elaborative interrogation
  and interleaving, rated moderate or low **on the evidence available in 2013**; interleaving's maths
  evidence has strengthened considerably since).
- **But retrieval practice is notably weaker in mathematics than elsewhere.** A 2025 meta-analytic review
  of spacing and retrieval practice for mathematics learning found the literature does not give conclusive
  evidence of a consistent retrieval-practice effect in maths. Three experiments on mathematical word
  problems found no retrieval-practice benefit on a delayed test. The general transfer effect of retrieval
  practice is around d = 0.4, moderated heavily by response congruency and by whether feedback is given —
  and studies on *problem solving specifically* are the ones least likely to show benefit.

**What this means for the plan:** the daily 30-minute retrieval slot is well spent on Physics and
Chemistry (declarative-heavy, where the effect is strong and reliable). It is a weaker bet for maths
problem-solving ability, and should not be counted as maths training. Maths retrieval should be narrow and
targeted: definitions, standard forms, validity conditions — the things that *are* declarative.

### B2. Procedural — execution

**What the evidence supports:**

- **Worked examples beat problem solving for novices** (the worked-example effect). A worked example gives
  the initial state, the goal, *and* the full solution path, which lets a novice build a schema instead of
  spending working memory on means-ends search.
- **This reverses with expertise** (the expertise reversal effect). For learners who already have the
  schema, studying worked examples is redundant and problem-solving is better. The transition is managed
  by **fading**: complete example → example with the last step removed → last two steps removed → full
  problem. Fading works because it frees enough capacity to attend to *why* each step happens.
- **Self-explanation** — explaining to yourself why each step is taken — reliably improves learning from
  worked examples, though Dunlosky rated it only moderate utility because it had not been well tested in
  real educational settings.
- **Error analysis works.** Studying *erroneous* examples — finding and diagnosing the broken step —
  outperformed straight problem solving on delayed post-tests. This is directly relevant: the Paper 2
  TMUA syllabus explicitly includes "locating the failing step in a supplied proof", and the plan treats
  that as a TMUA-specific skill rather than a general learning technique that happens to be assessed.
- **Interleaving is the big one for maths.** See A1.

### B3. Conditional — when and why

This is where the Coaching Document is right that most failures live, and it is right that this is where
experts separate from strong students. It is also the hardest to train, and the research here is more
cautionary than encouraging.

- **Blocked practice hides conditional failure completely.** If every problem on the page uses the same
  method, method selection is never exercised. This is precisely why the interleaving effect is so large:
  interleaved practice is the only common format that *forces* conditional knowledge. One reported effect
  for adaptive strategy use specifically was d = 1.09.
- **General problem-solving heuristics are the wrong grain size.** Schoenfeld's central finding: when
  people tried to teach Pólya's strategies, students did not learn to use them. A heuristic like "exploit
  an easier related problem" is not one strategy — it is at least a dozen sub-strategies for *identifying*
  which easier problem and *how* to exploit it. Pólya's descriptions are descriptive, not prescriptive.
  Strategies only become teachable when decomposed into **domain-specific tactics**.
- **Domain-general skills are largely unteachable.** Tricot and Sweller's argument: where a domain-general
  explanation and a domain-specific one both fit, the domain-specific one is usually correct, and
  domain-general capability is biologically primary — acquired without instruction, and therefore not
  improvable by it. Expert knowledge does not transfer across domains.

**The hard implication:** "developing the attributes of a mathematician" cannot be pursued as a set of
general capacities. Every attribute in §1 only exists as a large stock of domain-specific patterns plus the
conditions under which each applies. The route to "unfamiliar problem solving" is not exercises in
unfamiliar problem solving; it is a densely connected schema, exercised under conditions where the method
is not given. The Coaching Document half-knows this (§1: "transfer... appears when the schema is richly
connected and has been exercised on unfamiliar problems") and then organises §5 and §7 as if the attributes
were separately trainable faculties.

### B4. The fourth thing: control and beliefs

Schoenfeld's framework for problem-solving behaviour has four components, not three:

| Component | What it is |
|---|---|
| **Resources** | the body of facts and procedures at one's disposal (≈ declarative + procedural) |
| **Heuristics** | rules of thumb for making progress in difficult situations |
| **Control** | how efficiently the knowledge one has is actually deployed (≈ conditional, plus monitoring) |
| **Belief systems** | one's perspective on what mathematics *is* and how one works in it |

**Beliefs are absent from the Coaching Document entirely.** They are not a soft extra. Schoenfeld's
observational data showed students abandoning correct approaches because they held the belief that any
problem should be solvable in five minutes — a belief that wipes out resources the student demonstrably
possessed. For someone who has **never sat a BMO paper**, belief is plausibly the binding constraint on the
first attempt: the failure mode is not "cannot do olympiad geometry", it is "stops at eleven minutes
because nothing has worked and concludes the problem is beyond him".

The 45-minute struggle floor is, in effect, a beliefs intervention. It should be named as one, and belief
should be measured — the honest instrument is a log of *time-to-first-abandonment* on unfamiliar problems,
which is cheap to record and currently recorded nowhere.

Metacognitive calibration training — predicting performance, then comparing against the result, with
feedback — does have supporting evidence: judgment training improves both monitoring accuracy and
performance over and above repeated testing, and better-calibrated students perform better on assignments
and exams. The caveat is that general classroom metacognition training often fails to move calibration;
what works is item-specific judgements with feedback. **The Coaching Document's predict-SOLID/RUSTY/GAP-
then-mark protocol is item-specific judgement with feedback. It is the best-supported novel element in the
whole plan.** Keep it, and extend it beyond the baseline into routine work.

### B5. The uncomfortable meta-finding

Macnamara, Hambrick and Oswald's meta-analysis found deliberate practice explained 26% of performance
variance in games, 21% in music, 18% in sports — and **4% in education**. Education is the domain where
structured practice explains *least*. Ericsson disputed this; the dispute has not resolved in his favour.

Two readings, both worth holding:

1. The ceiling on what a better *plan* can buy is lower than the plan's detail implies. Returns to
   optimising the method are small relative to returns to doing the hours at all.
2. That number also reflects how badly "deliberate practice" is operationalised in education research —
   most of the studies it aggregates measure "time spent studying", which is not deliberate practice.

The defensible conclusion: a plan this elaborate is past the point of diminishing returns on planning. The
marginal hour is worth far more spent on Wednesday's Further Pure paper than on revising this framework
again.

---

## §C The attribute map, rebuilt

The §1 map is homemade and has overlaps (fluency / method selection / conditional knowledge are close to
the same thing; connections and generalisation overlap). Three established frameworks cover the same ground
with better provenance, and anchoring to them costs nothing:

- **Cuoco, Goldenberg & Mark (1996), "Habits of Mind"** — the canonical answer to "what are the attributes
  of a mathematician, stated as things a student can do". Their habits: students should be **pattern
  sniffers, experimenters, describers, tinkerers, inventors, visualizers, conjecturers and guessers**, with
  further habits of *looking for invariants*, *mixing experiment with deduction*, *building systematic
  explanation and proof*, *constructing and reasoning about algorithms*, and *reasoning by continuity*.
- **Mason, Burton & Stacey, *Thinking Mathematically*** — four processes in two pairs: **specialising and
  generalising**, **conjecturing and convincing**. Specialising is trying cases; generalising is moving
  from a few instances to a claim about a class; conjecturing is predicting; convincing is finding and
  communicating the reason. This is a smaller and more operational map than the ten-attribute table, and it
  maps directly onto proof work.
- **Schoenfeld's four components** — see B4.

**Recommended amendment to §1:** keep the ten-attribute table as the *reporting* structure (it is already
wired into §5 and §8), but add **beliefs/control** as an eleventh row, and add a "habit" column mapping each
attribute to the Cuoco or Mason process that names it. The value is not tidiness — it is that Cuoco and
Mason describe attributes as *things you do to a problem*, which makes them trainable. "Generalisation and
invention" is not a trainable instruction. "After every solved problem, weaken one hypothesis and see what
survives" is.

| Attribute (§1) | Named as a habit |
|---|---|
| Fluency | — (resources, Schoenfeld) |
| Conceptual understanding | describer; reasoning by continuity |
| Method selection | control (Schoenfeld); conditional knowledge |
| Proof and rigour | convincing (Mason); building systematic explanation and proof |
| Unfamiliar problem solving | tinkerer; experimenter; specialising (Mason) |
| Connections and representation | visualizer; translating between visual and verbal |
| Generalisation and invention | generalising (Mason); inventor; looking for invariants |
| Communication | describer (formal and informal) |
| Timed precision | — (exam artefact, not a mathematician's attribute — see D6) |
| Metacognition | control (Schoenfeld) |
| **Beliefs (new)** | **mixing experiment with deduction; tolerance for not knowing** |

---

## §D Critique of the current plan

Ratings out of 10, honestly.

### D1. The document itself — 4/10 as a use of this week

§10 says: *"Stop planning once the next task is clear. Resource-compiling, tooling talk, tracker design and
the OS project are the documented displacement pattern — name it and redirect."*

This is revision four in ten weeks (24 July, 15 Sept, 21 Sept, 22 Sept), the baseline has still not been
sat, and the next action requested was a further research-and-critique document. The document diagnosed the
pattern accurately and is now an instance of it.

This is worth saying plainly because the plan's own §0 says it: *"no baseline has been sat yet. Everything
below §0 is planned against a guess... Do not open a new planning discussion until it is — start the next
task."*

Producing this file was reasonable — there are findings in §A that genuinely change allocation, and A1 and
A3 would not have surfaced otherwise. But the honest rating of *commissioning* it before Wednesday's paper
is about 5/10. **Read §A, apply A4 and A3, and do not touch the rest until after 27 September.**

### D2. Evidence architecture (§4) — 8/10 in design, 3/10 in survivability

The four-state ladder, the assistance scale and the error taxonomy are genuinely good. The insistence that
nothing counts as solid on self-report is the single most valuable rule in the document.

The problem is arithmetic. §3 lists roughly twenty logged gaps. Each needs two spaced cold retests under
§4, each scheduled onto a calendar and marked against official solutions. That is ~40 retest events, on top
of the baseline battery, week-5 assessments, four A-levels and 15–17 h/week of primary work. Each log row
carries eight fields plus an assistance level plus primary and secondary error type plus an attribute
evidence line plus a retest date and result.

**Prediction, stated so it can be checked: the log will be maintained for about three weeks and then
degrade to sporadic entries.** That is the base rate for systems of this weight, and it is worse than a
lighter system, because the plan's entire epistemics rest on the log existing.

§8 says "lightweight by design". §4 and §8 together are not lightweight. Fix in §E1.

### D3. The weekly operating system (§7) — 5/10

- **Blocked at every level.** See A1. This is the most consequential weakness in the plan.
- **Budget not grounded.** "Plan against 15–17 home maths hours/week" is itself a guess, in a document
  whose central principle is that guesses are not evidence. There is no record of what the last three weeks
  actually contained. **If the true recent average is 9 hours, a 16-hour plan is fiction and every downstream
  allocation is wrong.** Measure one week before committing to the number.
- **No slack.** Weeks 3, 4 and 5 are all at capacity — diagnostics, then assessment prep, then assessments
  plus SMC — with a 150-minute timed paper on the far side. There is no recovery week anywhere before
  18 November. The 22:30 bedtime rule will be the thing that gives way, and §7 correctly identifies sleep
  as non-negotiable.
- **The degradation order is good** and is the sort of decision that should be made cold. Keep it.
- **No personal statement slot.** See A3.

### D4. Phase structure (§6) — 6/10

Phases 1, 3 and 4 are sound. Phase 2 is the weak one:

- Its deliverable (BMO1) is gated on an event it does not prepare for (A3).
- Five weeks split four ways between geometry, number theory, combinatorics and inequalities, starting from
  a base of never having sat a BMO paper, is roughly one week per area. That is not enough to build schema
  in any of them. **A defensible alternative: pick two areas, not four.** Geometry (correctly identified as
  weakest, longest runway) and number theory (which the §3 Layer 1 log shows is where the proof failures
  cluster — Bézout, Euclid's lemma, n⁵−n mod 3 and mod 5 all unresolved). Two areas at two-and-a-half weeks
  each, interleaved, beats four at one week.
- The document's own rule — "no new resources while suitable unused problems remain in the current source" —
  argues the same way.

### D5. TMUA strategy — 6/10

The analysis is right: at the top of the scale this is an error-rate problem, not a knowledge problem.
Two gaps follow from that and are not addressed:

- **There is no stated triage or guessing policy.** TMUA has no negative marking. That makes two rules
  free: never leave a blank, and have a pre-committed rule for when to abandon a question and come back
  (e.g. 90 seconds with no viable route → mark, guess, move). Forty questions in 150 minutes is 3.75
  minutes each; a triage policy is worth more marks than another practice paper.
- **Volume does not fix error rate.** Phase 3 allocates the daily micro-slot plus Monday, Tuesday, Friday
  and Saturday. For an error-rate problem, the intervention is a **checking protocol** applied to every
  answer (the §9 rule "re-derive every final numeric step by a second route" is exactly right and should be
  promoted from a write-up habit to a TMUA rule), plus error classification after every paper. Papers are
  a measuring instrument; they are not the training.
- **"Plan against a 7.5 floor" is mislabelled.** Imperial's accepted maths applicants averaged 7.6 in 2026,
  so 7.5 is *at* the mean, not a floor. A floor is the score below which the plan changes. Three bands are
  more useful than one number — see §F2.

### D6. The attribute framework (§1, §5) — 7/10

Strong for a self-built framework, and §5's honesty about what the baseline cannot measure is the best
writing in the document. Three criticisms:

- **Beliefs missing.** See B4.
- **"Timed precision" does not belong on a list of the attributes of a mathematician.** It is an artefact
  of the measuring instrument. Including it lets exam optimisation into the definition of the goal through
  the back door — which is precisely the tension §1 warns about. Keep training it; move it out of the
  attribute table into §2 with the other instrumental targets.
- **The "two sentences on why" probe is too weak to measure conceptual understanding.** Two sentences on a
  problem already answered correctly will mostly produce fluent restatement. Self-explanation's benefit
  depends heavily on explanation quality. A stronger probe, and one already in §9: *state the hypothesis
  that makes this method valid, then construct a case where dropping it breaks the result.* Boundary cases
  are much harder to fake than justifications.

### D7. Coaching protocol (§10) — 6/10

- Socratic-by-default is wrong for never-opened material (A5, §E3).
- The hint ladder is well designed and is essentially a fading schedule — which is the right mechanism.
- **The struggle floor is missing its second half** (A6). This is the most important single fix to how the
  coaching works.
- "One problem at a time, complete attempt before evaluation, 70% independent work" is correct and
  well-supported.
- Look-back questions are at Pólya's grain size, and Schoenfeld's finding is that this grain size does not
  transfer. "Does it generalise?" will produce shallow answers. Converting each into a *topic-specific*
  checklist is the fix — e.g. in geometry: drop the cyclic condition; drop convexity; replace an equality
  with an inequality; move a point to a limiting position. In number theory: weaken the modulus; replace a
  prime with a prime power; allow the exponent to vary.

### D8. What the plan gets right, and should not lose

Because a critique that only attacks is not useful:

- **The evidence-state ladder and the refusal of self-report.** Almost nobody does this. It is the reason
  §3's gap list is specific and useful rather than vibes.
- **Predict-then-mark calibration.** Best-supported novel element in the plan (B4).
- **The assistance scale.** Distinguishing cold from coached is what makes the rest of the data mean
  anything.
- **The error taxonomy, and the rule "do not disguise a condition failure as a careless reading error".**
  This is what surfaced the finding that most failures are conditional — which is the single most useful
  fact in the document.
- **The degradation order, decided cold.**
- **Sleep as non-negotiable.** Correct, and the first thing an ambitious plan sacrifices.
- **Naming the exam-versus-development tension rather than resolving it silently.**
- **The conjecture-book emptiness test** ("empty three weeks running = the programme has become exam
  prep"). That is a genuinely clever tripwire.

**Overall: 8/10 as a plan.** Top decile for a self-directed student. Its weaknesses are not of rigour but of
scheduling realism and one wrong bet on practice structure.

---

## §E Drop-in amendments

### E1. Replacement for the §4 evidence table and §8 log row

**Retest intervals** (replacing "~2 days, then ~1 week"):

| State | Evidence required |
|---|---|
| Unmeasured | No recent cold evidence |
| Building | Success only with instruction, scaffolding or immediate repetition |
| Reliable | Two cold successes at **10–14 days** and then **4–6 weeks**, including correct condition and method selection |
| Transferable | Reliable plus an unfamiliar transfer problem, an explanation, and a meaningful connection |

*(Rationale: optimal gap ≈ 10–20% of the retention interval. TMUA is ~15 weeks out; A-levels ~36.)*

**Replacement log row.** Every field must change a decision, or it goes:

```
date | source | topic | attribute | cold?(0-4) | outcome | error type + the exact failed step | next retest
```

Eight fields, one line. Dropped: secondary error type (record it in the failed-step text if it matters),
the separate attribute-evidence line (fold into the failed-step text), status (derivable from the retest
history). **The only field that must never be blank is `next retest`** — it is the only one that causes
anything to happen.

### E2. Replacement for the §7 weekly OS

Two structural changes, everything else as written.

**Change 1 — every session ends interleaved.** Whatever the session's topic, the last 20–25 minutes is a
mixed set: 6–8 problems drawn from *different* topics, arranged so no two consecutive problems use the same
method, with the method never stated. This is where conditional knowledge is actually built and where
method-selection errors become visible. Pull from the due-retest queue so it doubles as spaced review.

**Change 2 — Phase 2 runs two topics, not four, and alternates them.** Geometry and number theory.
Alternate days rather than two-week blocks:

| Slot | Phase 2 (amended) |
|---|---|
| Mon eve | Geometry — new material or worked examples + faded practice |
| Tue eve | Number theory — same |
| Wed eve | Layer 0 gap drill, cold, **interleaved across topics** |
| Thu eve | **Personal statement** until 30 Nov, then flex |
| Fri eve | TMUA drilling → OS build, day ends 22:30 |
| Sat | Long set (45-min struggle floor, **then the model solution**) · review hour · mixed set |
| Sun | TMUA Paper 2 logic · spaced review from the retest queue |

Combinatorics and inequalities move to Phase 6 or to the conjecture book. Two areas learned properly beat
four sampled.

### E3. Replacement for §10's coaching default

Coaching mode is chosen by the topic's §4 evidence state, not applied uniformly:

| Evidence state | Mode | Why |
|---|---|---|
| **Unmeasured / never opened** | Worked example in full, then faded practice: complete solution → last step removed → last two removed → full problem. Self-explanation prompt at each stage. | Worked-example effect. Socratic questioning on absent schema is means-ends search, which consumes working memory and builds nothing. |
| **Building** | Socratic, with the §10 hint ladder. Two failures on the same missing prerequisite → teach it directly. | Fading; expertise reversal beginning. |
| **Reliable** | Cold problems, no hints, unfamiliar framings. | Expertise reversal complete — examples are now redundant. |
| **Transferable** | Generalisation and invention: weaken hypotheses, build counterexamples, extend. | Only stage where §9's look-back questions will produce non-shallow answers. |

**And, added to §9's struggle floor:** after 45 minutes, the canonical solution is shown **in full**, then
contrasted step by step against what was attempted — specifically, which step of the model solution
corresponds to the point where the attempt broke. Withholding it converts productive failure into failure.

### E4. Additions to the measurement set

Three cheap instruments that measure things currently unmeasured:

- **Time-to-first-abandonment** on unfamiliar problems. One number per session. Proxy for beliefs (B4).
  Expect it to rise over Phase 2; if it does not, that is the finding.
- **Calibration gap**, carried beyond the baseline into all routine marking: predicted vs actual, one line.
  It is the best-evidenced element in the plan; restricting it to the battery week wastes it.
- **Actual hours**, recorded for one week before the 15–17 h figure is trusted (D3).

---

## §F Corrections and conflicts with the Coaching Document

### F1. Warwick's requirements — the §0 open item, provisionally resolved, and it matters

§2 currently states: *"A\*A\* Maths + FM plus: A in a third + test condition (STEP 2 / TMUA ~6.5), or A\* in
a third, or AA in third and fourth (per 2023 page — verify current cycle)."*

Multiple current secondary sources describe a materially different structure for 2027 entry:

- Typical offer **A\*A\* in Maths and Further Maths plus A in a third A-level**.
- **TMUA or STEP is required of essentially all applicants** (contextual-offer holders exempted) — the two
  are treated as interchangeable accepted routes, with STEP grade 2 the requirement for applicants who have
  *not* sat TMUA. It is an entry condition, not a way to reduce the offer.
- **The majority of offers in the most recent cycle went to applicants scoring TMUA 5.0 or above**, with
  some below 5.0 after holistic assessment.

If this is right, three things in the plan change:

1. **The "TMUA ~6.5" figure in §2 is too high for Warwick.** The relevant number is nearer 5.0.
2. **Imperial, not Warwick, is the binding TMUA constraint** — its accepted maths applicants averaged 7.6
   in 2026. The aspiration of 9 and the working target of ~7.5–8 are set by Imperial alone.
3. **The shape of the downside risk changes.** A 6.0 loses Imperial but probably does not lose Warwick.
   That is a materially less frightening failure mode than the current document implies, and it argues
   against expanding TMUA hours at the expense of A-level grades — because **A\*A\*A is required by both,
   and no TMUA score substitutes for a missed A\***.

**Critical caveat, stated plainly: `warwick.ac.uk` and `imperial.ac.uk` are both blocked by this
environment's network proxy, so none of the above comes from the official pages.** These are secondary
sources and could be out of date or wrong. Treat this as a sharpened version of the §0 open item, not a
closed one. **Verify on the official Warwick MMath/BSc 2027 course pages and Imperial's Mathematics course
page before changing any allocation.** That check takes ten minutes and is worth more than any other item
in this file.

### F2. Replacement wording for the TMUA target in §2

Replace *"aspiration as close to 9 as possible; plan against a 7.5 floor"* with three decision bands:

| Band | Consequence | What it triggers |
|---|---|---|
| **< 5.0** | Warwick at risk | Would require the STEP route to be live — decide by February |
| **5.0 – 7.0** | Warwick likely, Imperial unlikely | No change to plan; A-levels become everything |
| **≥ 7.5** | Both live | Target band |

A floor is a number below which the plan changes. 7.5 is a target, not a floor; the real floor is ~5.0.

### F3. Imperial's offer structure — a question worth asking

§2 records Imperial's offer as A\*A\*A (three A-levels) / **A\*A\*AA (four)**, and concludes Chemistry is
therefore part of the offer. Worth confirming directly with Imperial Admissions: **will they make a
three-subject offer to a four-subject candidate?** If yes, the four-A-level offer is strictly harder (four
grades to hit instead of three) and the answer changes how much Chemistry time is justified. If no,
Chemistry is load-bearing at grade A and the current ~1.75 h/week allocation is too thin.

### F4. Other factual notes

- **BMO1 access.** The 2025 SMC boundary for BMO1 was 104/125 (down from 110 in 2024). For BMO2, the 2025
  thresholds were 43/60 for Year 13. Forty-three of sixty is roughly four complete solutions out of six.
  §2's classification of BMO2 as "upside outcome, not a planning assumption" is correct and should not be
  softened.
- **iCanStudy.** No peer-reviewed evaluation of the programme exists. The common criticism is that it is
  strongest for declarative, conceptual subjects and weaker for procedural ones — which is the shape of
  maths. The underlying techniques it teaches (spacing, retrieval, elaboration, higher-order encoding) are
  well supported *individually*; the programme's specific packaging is not independently evidenced. 2–3
  h/week is a defensible bet on the declarative subjects (Physics, Chemistry) and a weaker one for maths.
  Worth noting: nothing in the maths plan currently depends on it.

---

## §G What could not be verified

Stated so it is not mistaken for research that was done:

- **Official Warwick and Imperial entry requirements** — both domains blocked by network egress. §F1 rests
  entirely on secondary sources. **This is the highest-value thing on the open-decisions list.**
- **Whether schools can enter candidates for BMO1 without the SMC boundary.** Believed possible for a fee,
  not confirmed for the current cycle. Ask the school directly — the answer determines whether Phase 2 is
  safe.
- **Cuoco et al.'s full habits list** — the source PDFs were blocked; the habits in §C are as reported in
  accessible secondary summaries and should be checked against the 1996 paper before being used as a
  framework.
- **Base-rate data on how many hours a TMUA 7.5+ typically takes.** No credible public data exists. Anyone
  who quotes a number for this is guessing.
- **Whether Calvin's 15–17 h/week figure is real.** Not measurable from here. Measure it.

---

## §H Sources

Evidence base, grouped.

**Practice structure**
- [Rohrer, Dedrick, Hartwig & Cheung (2020), A Randomized Controlled Trial of Interleaved Mathematics Practice](https://gwern.net/doc/psychology/spaced-repetition/2019-rohrer.pdf)
- [Rohrer et al., The benefit of interleaved mathematics practice is not limited to superficially similar kinds of problems](https://gwern.net/doc/psychology/spaced-repetition/2014-rohrer.pdf)
- [Cepeda, Vul, Rohrer, Wixted & Pashler (2008), Spacing Effects in Learning: A Temporal Ridgeline of Optimal Retention](https://laplab.ucsd.edu/articles/Cepeda%20et%20al%202008_psychsci.pdf)
- [Dunlosky et al. (2013), Improving Students' Learning With Effective Learning Techniques](https://iverson.cm.utexas.edu/courses/310M/Handouts/Dunlosky%20et%20al.%20-%202013%20-%20Improving%20Students%E2%80%99%20Learning%20With%20Effective%20Learni.pdf)
- [A Meta-analytic Review of the Effectiveness of Spacing and Retrieval Practice for Mathematics Learning (2025)](https://link.springer.com/article/10.1007/s10648-025-10035-1)
- [Retrieval practice may not benefit mathematical word-problem solving (Frontiers in Psychology, 2023)](https://www.frontiersin.org/journals/psychology/articles/10.3389/fpsyg.2023.1093653/full)

**Instruction design**
- [Worked-example effect (overview)](https://en.wikipedia.org/wiki/Worked-example_effect)
- [The expertise reversal effect (Kalyuga et al., summary PDF)](https://mrbartonmaths.com/resourcesnew/8.%20Research/Explicit%20Instruction/The%20Expertise%20Reversal%20Effect.pdf)
- [Kapur (2014), Productive Failure in Learning Math, *Cognitive Science*](https://onlinelibrary.wiley.com/doi/10.1111/cogs.12107)
- [Sinha & Kapur (2021), When Problem Solving Followed by Instruction Works](https://journals.sagepub.com/doi/10.3102/00346543211019105)
- [Teaching and learning mathematics through error analysis (Fields Mathematics Education Journal)](https://link.springer.com/article/10.1186/s40928-018-0009-y)

**Nature of mathematical expertise**
- [Schoenfeld, *Mathematical Problem Solving* — framework overview](https://www.instructionaldesign.org/theories/mathematical/)
- [Schoenfeld, ICME-12 lecture (on Pólya's grain-size problem)](https://www.mathunion.org/fileadmin/ICMI/Conferences/ICME/ICME12/www.icme12.org/upload/submission/1900_F.pdf)
- [Foster (2023), Problem solving in the mathematics curriculum: from domain-general strategies to domain-specific tactics](https://bera-journals.onlinelibrary.wiley.com/doi/10.1002/curj.213)
- [Tricot & Sweller (2014), Domain-Specific Knowledge and Why Teaching Generic Skills Does Not Work](https://mrbartonmaths.com/resourcesnew/8.%20Research/Problem%20Solving/Domain-Specific%20Knowledge.pdf)
- [Cuoco, Goldenberg & Mark (1996), Habits of Mind: An Organizing Principle for Mathematics Curricula](https://www.sciencedirect.com/science/article/abs/pii/S0732312396900231)
- [Mason, Burton & Stacey, *Thinking Mathematically*](https://www.mymathscloud.com/api/download/modules/11/Interview-Advice/Thinking%20Mathematically.pdf?id=apHfjK8WSr2JDG8FXMhFnw)
- [Gobet & Simon, Expert Chess Memory: Revisiting the Chunking Hypothesis](https://pubmed.ncbi.nlm.nih.gov/9709441/)

**Knowledge types and metacognition**
- [Rittle-Johnson, Schneider & Star (2015), Not a One-Way Street: Bidirectional Relations Between Procedural and Conceptual Knowledge of Mathematics](https://www.uni-trier.de/fileadmin/fb1/prof/PSY/PAE/Team/Schneider/Rittle-JohnsonEtAl2015.pdf)
- [Combined conceptualisations of metacognitive knowledge in mathematical problem-solving (2024)](https://www.tandfonline.com/doi/full/10.1080/2331186X.2024.2357901)
- [Enhanced monitoring accuracy and test performance: incremental effects of judgment training over repeated testing](https://www.sciencedirect.com/science/article/abs/pii/S0959475218308788)
- [Macnamara, Hambrick & Oswald (2014), Deliberate Practice and Performance: A Meta-Analysis](https://gwern.net/doc/psychology/2014-macnamara.pdf)

**Admissions and competitions**
- [UAT-UK TMUA Preparation Materials (official past papers)](https://esat-tmua.ac.uk/tmua-preparation-materials/)
- [Imperial College — TMUA](https://www.imperial.ac.uk/study/apply/undergraduate/process/admissions-tests/tmua/)
- [Warwick — Mathematics MMath](https://warwick.ac.uk/study/undergraduate/courses/mmath-mathematics/)
- [Warwick — Admissions Tests (TMUA)](https://warwick.ac.uk/study/undergraduate/applying/admissions-tests/)
- [TMUA scores and grade boundaries](https://dukesplus.com/guides/applying-to-university-in-the-uk/uk-university-admissions-tests/tmua-scores-grade-boundaries/)
- [UKMT — British Mathematical Olympiad Round 1](https://ukmt.org.uk/senior-challenges/british-maths-olympiad-round-1)
- [UKMT SMC 2025 boundaries](https://mathsaurus.com/2025/10/22/ukmt-senior-maths-challenge-2025-boundaries-announced/)
- [Evan Chen — olympiad training design](https://blog.evanchen.cc/2017/04/08/on-designing-olympiad-training/)

---

## §I Proposed replacement for §0's open-decisions list

- [ ] **Verify Warwick's 2027 offer and TMUA condition on the official course page** (§F1 — highest value)
- [ ] **Ask school: can they enter you for BMO1 without the SMC boundary?** (§A3 — gates all of Phase 2)
- [ ] **Move the baseline TMUA paper from Sat 10 Oct to Sat 17 Oct** (§A4)
- [ ] **Ask Imperial: three-subject offer for a four-subject candidate?** (§F3)
- [ ] Put the baseline week onto "Calendar"
- [ ] Record actual maths hours for one week before trusting the 15–17 figure (§D3)
- [ ] Decide: two olympiad topics or four (§D4)
- [ ] Find a slot for the personal statement before 30 Nov (§A3)
- [ ] Apply the 22:30 Friday finish to every Friday, or this one only
- [ ] Remove the duplicate Friday OS block on the main (non-"Calendar") calendar
- [ ] Confirm school mock dates
- [ ] Book January TMUA once booking opens 26 Oct
- [ ] Calvin's prediction, written down before results: which attribute is currently weakest?
