# Layer 0 Diagnostic — Further Pure, Paper 1

**Cold. No notes. ~90 minutes.** Calculator allowed, but show every step — arithmetic slips at
boundary/scaling steps are a logged gap and the working is what gets marked.

**Before you start:** write the start time. Record the stop time. Keep every piece of rough work,
**including approaches you abandon** — the abandoned routes are the most informative thing in the packet.

**Before you mark:** for each question write your prediction — **SOLID / RUSTY / GAP** — *before* checking
anything. The mismatch between prediction and result is the metacognition reading and it is the
best-evidenced measurement in the whole system. Predictions written after the fact are worthless.

**If a topic has not been taught yet, write "NOT TAUGHT" and move on.** That is data, not failure — it
separates "gap" from "not yet covered", and those need completely different responses.

**Do not read §B until you have finished and marked.**

---

## §A The paper

Questions are interleaved — consecutive questions deliberately use different methods, and none tells you
which method to use. That is the point.

---

**1.** Let $z = 1 - i\sqrt{3}$.

Find $|z|$ and $\arg z$, and hence evaluate $z^6$.

---

**2.** $\mathbf{M} = \begin{pmatrix} 1 & 2 & 3 \\ 0 & 1 & 4 \\ 5 & 6 & 0 \end{pmatrix}$

Find $\mathbf{M}^{-1}$.

State clearly, before you begin, the condition that guarantees the inverse exists, and verify it holds.

---

**3.** The equation $x^3 - 5x^2 + 2x + 8 = 0$ has roots $\alpha, \beta, \gamma$.

Write down $\sum\alpha$, $\sum\alpha\beta$ and $\alpha\beta\gamma$, and hence find $\sum\alpha^2$.

---

**4.** Two lines are given by

$$\ell_1: \mathbf{r} = \begin{pmatrix}1\\0\\2\end{pmatrix} + \lambda\begin{pmatrix}2\\1\\-1\end{pmatrix}
\qquad
\ell_2: \mathbf{r} = \begin{pmatrix}0\\3\\1\end{pmatrix} + \mu\begin{pmatrix}1\\-1\\2\end{pmatrix}$$

Determine whether the lines are parallel, intersecting or skew, **justifying your classification**, and
find the shortest distance between them.

---

**5.** Prove by induction that $7^n + 2$ is divisible by 3 for all integers $n \geqslant 1$.

Before writing the inductive step, state **in words** exactly which statement you are assuming and exactly
which statement you are proving. Then write the proof.

---

**6.** Sketch the locus of points in the Argand diagram satisfying

$$|z - 3 + 2i| = |z - 1|$$

and find its Cartesian equation.

---

**7.** The plane $\Pi$ passes through $A(1, 2, -1)$, $B(2, 0, 3)$ and $C(0, 1, 1)$.

Find the perpendicular distance from $P(3, 3, 3)$ to $\Pi$.

---

**8.** Using the same cubic as question 3 — $x^3 - 5x^2 + 2x + 8 = 0$ with roots $\alpha, \beta, \gamma$ —
find a cubic equation whose roots are $\alpha^2, \beta^2, \gamma^2$.

Do this **without** finding $\alpha, \beta, \gamma$ themselves.

---

**9.** Use standard results to find $\displaystyle\sum_{r=1}^{n} r(r+1)$, simplifying fully.

---

**10.** $\mathbf{A} = \begin{pmatrix} 3 & 1 \\ 1 & 3 \end{pmatrix}$

Find the equations of all lines through the origin that are invariant under the transformation
represented by $\mathbf{A}$.

---

**11.** Use de Moivre's theorem to show that

$$\cos 5\theta = 16\cos^5\theta - 20\cos^3\theta + 5\cos\theta$$

---

**12.** Find $\displaystyle\sum_{r=1}^{n} \frac{1}{r(r+2)}$ in terms of $n$, simplifying fully.

State what the sum tends to as $n \to \infty$.

---

**13.** $\mathbf{B} = \begin{pmatrix} 4 & 3 \\ 5 & 4 \end{pmatrix}$

Find $\mathbf{B}^{-1}$.

Then, in one sentence each: what does it mean geometrically for a $2\times 2$ matrix to have determinant
zero, and what does a **negative** determinant tell you about the transformation?

---

**14. Method selection. Do not solve any of these.** For each, state in one line which method you would
use, **why that one rather than the obvious alternative**, and any condition that must hold first.

&nbsp;&nbsp;(a) Find the shortest distance from the point $(2,1,5)$ to the line
$\mathbf{r} = (1,0,0) + t(1,2,2)$.

&nbsp;&nbsp;(b) Evaluate $\displaystyle\sum_{r=1}^{20} \frac{1}{(2r-1)(2r+1)}$.

&nbsp;&nbsp;(c) Solve $\mathbf{M}\mathbf{x} = \mathbf{b}$ for a $3\times3$ matrix $\mathbf{M}$ and a single
given $\mathbf{b}$.

&nbsp;&nbsp;(d) Find $\alpha^3 + \beta^3 + \gamma^3$ for the roots of a given cubic.

---

**15.** Using your answer to question 10, find $\mathbf{A}^5$ **without** computing repeated matrix
products.

---

**16. Conditions and definitions.** One or two sentences each, from memory.

&nbsp;&nbsp;(a) State the condition for a $3\times3$ matrix to represent an invertible transformation, and
say what it means geometrically when it fails.

&nbsp;&nbsp;(b) Define what it means for two lines in three dimensions to be *skew*.

&nbsp;&nbsp;(c) In a proof by induction, what exactly is the base case doing? Why is the proof invalid
without it?

&nbsp;&nbsp;(d) State the validity condition for the general binomial expansion of $(1+x)^n$ when $n$ is
not a positive integer.

&nbsp;&nbsp;(e) What is an eigenvector, in words, without using the word "eigenvalue"?

&nbsp;&nbsp;(f) Give the conditions under which $\arg(z_1 z_2) = \arg z_1 + \arg z_2$ can fail.

---

**END OF PAPER.** Record the stop time. Write your SOLID / RUSTY / GAP predictions now, before reading on.

---
---

## §B What each question is testing — **do not read before marking**

Difficulty bands: **A** = anchor (expect to get these; they confirm the floor). **B** = discriminator
(this is where the A/A\* gap lives — unscaffolded, method not given). **C** = stretch (above A\* standard;
tells you about unfamiliar problem solving, not about your grade).

| Q | Band | Topic | The specific claim being tested | Attribute |
|---|---|---|---|---|
| 1 | A | Complex numbers | Modulus–argument form and de Moivre for a clean case | Fluency |
| 2 | **B** | **3×3 inverse — logged gap, never completed** | Can you carry out the full cofactor/adjugate route without losing a sign, and do you check the determinant *first*? | Fluency + conditional |
| 3 | A | Roots of polynomials | Vieta's relations recalled correctly; the $\sum\alpha^2 = (\sum\alpha)^2 - 2\sum\alpha\beta$ step | Fluency |
| 4 | **B** | **Skew lines — logged gap** | Do you *classify before computing*? Many students compute a distance without establishing the lines aren't parallel or intersecting. The justification is the marks. | Method selection |
| 5 | **B** | **Induction — logged gap (base case; assumed vs proved)** | The stated assumption. §3 records the assumed-vs-proved confusion directly; this question makes it visible before the algebra hides it. | Proof and rigour |
| 6 | A | Complex loci | Recognising equidistance ⇒ perpendicular bisector, rather than expanding blindly | Connections |
| 7 | **B** | **Point-to-plane distance — logged gap, unscaffolded** | Three chained steps (two direction vectors → normal → plane equation → distance) with no parts to guide you. Failure here could be any of four things — note which step broke. | Fluency + route choice |
| 8 | **C** | **Roots transformations — logged gap** | Squaring roots needs $\sum\alpha^2\beta^2 = (\sum\alpha\beta)^2 - 2\alpha\beta\gamma\sum\alpha$, which is not a substitution. If you tried $y = x^2$ and substituted, that is the finding. | Generalisation |
| 9 | A | Series | Standard results applied and factorised | Fluency |
| 10 | **B** | Invariant lines | Do you know invariant line through origin ⇔ eigenvector direction? Or did you set $y = mx$ and grind? Both work; only one shows the connection. | Connections |
| 11 | **C** | de Moivre ⇒ multiple-angle identity | Unscaffolded. Normally given as "expand $(\cos\theta + i\sin\theta)^5$, hence…". Without that line, can you find the route? | Unfamiliar problem solving |
| 12 | **B** | Method of differences | Spotting that partial fractions telescope, and handling the two leftover terms at each end correctly — the classic slip | Fluency + recognition |
| 13 | A | 2×2 inverse + interpretation | The inverse is the anchor; the two sentences are the real test — procedural fluency without geometric meaning is exactly the pattern §1 warns about | Conceptual understanding |
| 14 | **B** | **Pure conditional knowledge** | **The most informative five minutes on the paper.** §3 says most of your failures are conditional. This tests it with no execution to hide behind. | Method selection |
| 15 | **C** | Diagonalisation | Connecting Q10 to a power. Tests whether eigen-work is a procedure or a tool. | Connections |
| 16 | — | Declarative sweep | Cheap, fast, catches definition-level holes. §3 records ℚ/ℝ swapped and injective stated backwards — definitions are a known weak spot. | Conceptual understanding |

### How to read your results

- **Failed an anchor (1, 3, 6, 9, 13):** treat as urgent. These are below week-5 standard.
- **Failed a discriminator (2, 4, 5, 7, 10, 12, 14):** this is the A→A\* gap, and it is the actual target
  for the next eleven days.
- **Failed a stretch (8, 11, 15):** informative, not urgent. Do not let these set the revision priority.
- **Q14 answered vaguely:** the single most important signal on the paper. Vague method selection under no
  time pressure means it will be worse under time pressure.
- **Predicted SOLID but got it wrong:** the most valuable row in the whole exercise. Miscalibration is
  more dangerous than a gap, because you will not revise it.

### Known limits of this paper

- Built on OCR Core Pure content. **If you are on MEI, some notation differs** — the mathematics doesn't.
- It does not cover: hyperbolic functions, polar coordinates, Maclaurin series, differential equations, or
  any optional-paper content. If week 5 includes those, this paper does not measure them and a second
  short diagnostic is needed.
- It samples. One bad evening looks like a gap. Anything that reads as a gap here needs a retest at
  10–14 days before it counts as real (Coaching Document §4).
- These are custom questions, not official past-paper items. Per §4 they are good for *finding* gaps but
  do not by themselves prove a topic solid — confirm anything that looks fine against an OCR paper.
