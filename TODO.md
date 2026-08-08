# TODO

Open decisions arising from two conformance passes that reapplied
`create-skill`: the first to the 28 other skills in this collection, the
second to the 47 project-level skills under `.agents/skills/` in ten sibling
repositories. Each item spans several skills, so none could be settled by a
per-skill edit.

Part one below concerns this collection. Part two concerns `create-skill`
itself, and was surfaced by applying it downstream.

## Part one — this collection

All 29 skills here validate clean as they stand. These are judgment calls,
not defects.

## 1. Do skills commit their own work? — RESOLVED

Decision: the principle isn't quite "change-making commits, evaluation
doesn't" — `proof` edits prose but still doesn't commit, which that framing
can't explain. The rule now written into `AGENTS.md` is finer-grained: a
skill commits when its edit is itself a complete, commit-worthy unit of work
with its own type in `commit`'s vocabulary (`step`, `fix`, `refactor`,
`style`) — `code`, `fix`, `refactor`, `style` all qualify. A skill leaves
its edits uncommitted when it only polishes or verifies content that
another change already produced or will produce — `proof`, and by the same
logic `audit`, `review`, `test`, `validate`. `commit` is neither case: it
composes the message and changelog entry for another actor to file, and
MUST NOT stage or commit anything itself. A skill that does commit MUST
stop there — pushing, review, merging, and releasing stay out of scope.

The `<!-- TODO: Allow direct commits to dev? -->` marker is answered by the
same rule: a skill MUST NOT decide branch policy. It commits on whatever
branch is already checked out; whether that's a protected trunk is for the
repository's own conventions and the `branch` skill to have already
settled, not something a change-making skill gates on.

No skill needed editing — all six already behave per this rule. Only
`AGENTS.md` was missing the write-up.

## 2. How convention-agnostic should the Git and planning skills be? — RESOLVED

Decision: keep the genericized state. TS-9 names (`dev`, `test`, `ready`,
`step:`, `feature:`, `refactor:`, `fix:`, `maintenance:`) stay as discovered-
parameter defaults only, not hard-coded values, across `branch`, `merge`,
`release`, `plan`, `fix`, `code`. This matches the no-hard-coding rule
literally and preserves portability for repositories that diverge from TS-9.
No further changes needed — the six skills already reflect this.

## 3. Should evaluation skills persist their reports? — RESOLVED

Decision: made `test` and `validate` durable, mirroring `research`'s
pattern (an OPTIONAL report-store parameter, ephemeral when nothing
resolves it). Both skills gained:

- A `Report store — OPTIONAL` parameter, resolved the same way as their
  existing required store (specification, in both cases). Where nothing
  resolves it, the report returns to the caller as before — neither skill
  was made to prompt for it, matching each skill's existing interactivity
  stance (`test` may already ask about artifact locations; `validate` never
  prompts at all).

- `Write` added to `compatibility`.

- A success criterion: written to the resolved store, following that
  store's own conventions, when one resolves; returned in full otherwise.

- The "working tree unchanged" boundary criterion narrowed to name the
  report itself as the one permitted write.

- The final instruction step updated to resolve the store and write there
  before stopping.

Verified: both skills, and the full 29-skill collection, still validate
PASSED. `audit`, `probe`, `research`, `review` needed no change — they
already had this shape.

## 4. Naming a specific host CLI in `compatibility` — RESOLVED

Decision: genericized `review` and `specify` to match `triage`/`resolve`.
`review`'s `Bash (git diff, gh)` is now `Bash (git diff, review host CLI)`;
`specify`'s `Bash (git, gh)` is now `Bash (git, review host CLI)` — matching
`resolve`'s term, not `triage`'s "issue tracker CLI", since `specify` files
a proposal through a review/discussion vehicle (a PR), not an issue. Neither
skill named `gh` anywhere outside the front matter, so this was a clean
one-line change in each. Verified both skills, and the full collection,
still validate PASSED.

## Minor, unrelated to the above — RESOLVED

- The `decide` entries in `elaborate`, `research`, and `spike` are kept —
  each names a real, specific relationship, not a generic "see also".
  `research` and `spike` already linked back reciprocally from `decide`'s
  own README; `elaborate` didn't, which was the actual gap. Added the
  missing reciprocal entry to `decide/README.md`.

- `proof`'s README claimed running `style` first yields fewer conflicts,
  which `style`'s own README contradicted ("run them... in either order").
  Reworded `proof`'s entry to match `style`'s existing "either order, as
  separate changes" phrasing, since neither skill ever substantiated the
  ordering claim and the two skills touch disjoint aspects of a file
  (words vs. presentation) with no real interaction between them.

- `specify`'s `## Examples` section was deleted rather than repaired. It had a
  malformed code fence and illustrated store discovery rather than any output
  the skill produces. It is the only section removed outright during the
  pass, and it's a closed record now — nothing further to do.

- `branch`'s lowercase-only regex is correct as-is; uppercase tracking IDs
  are not meant to be legal in a branch name. Made this explicit rather than
  implicit: instruction 2 now says outright to lowercase the identifier too
  (`TS-504` becomes `ts-504`), even where the tracker displays it uppercase,
  since Git branch names carry the same case-sensitivity hazards as any
  other path component. Checked `commit` for the same concern: it never
  embeds a free-text tracking ID, only numeric `#123` references in
  footers, so it was never actually affected.

Verified: all edited skills, and the full 29-skill collection, still
validate PASSED.

## Part two — `create-skill` itself

Reapplying `create-skill` to 47 project-level skills in ten sibling
repositories exposed gaps in the skill, its validator, and this collection's
`AGENTS.md`. Unlike part one, several of these are outright defects.

## 5. The `compatibility` vocabulary cannot express sub-agent fan-out — RESOLVED

Decision: added `Agent` to the permitted `compatibility` vocabulary in
`create-skill/SKILL.md` and its validator (`create-skill-validate.sh`), with
a rule reserving it for skills whose mechanism depends on fan-out (a named
instruction step and a governing rule, not incidental convenience). Where
`Agent` is declared, the skill's `README.md` MUST also explain why it fans
out, so installers see the cost up front. `gap-analysis` (in the `standards`
repository) can now re-declare `Agent` truthfully; that repository's own
skill still needs updating to pick this up.

## 6. The validator's H1 check has three false-positive classes — RESOLVED

Decision: downgraded the check from FAIL to WARN in `create-skill-validate.sh`.
The derivation (`name` field, hyphens→spaces, sentence-case) still runs and
still flags acronyms (`APT`), all-caps headings (`RFC`), and correctly
hyphenated compounds (`cross-references`) — but a mismatch no longer blocks
a clean run. A comment above the check now says explicitly that a WARN here
is not necessarily a defect. Verified: `create-skill` and all 29 skills in
this collection still validate PASSED.

The eight downstream skills carrying a residual FAIL will clear to WARN the
next time their repository reruns the validator; no edit is needed in those
repositories for this alone.

## 7. Project-level skills need a carve-out from "discover, don't assume" — RESOLVED

Decision: wrote the carve-out from the transient briefing into `AGENTS.md`'s
"discover, don't assume" rule and into `create-skill/SKILL.md`'s matching
rule, so it no longer has to be re-supplied per pass. The rule does not apply
to a project-level skill's own repository — such a skill exists to encode
that repository's concrete layout — but still binds in full for anything
outside it (a sibling repository, an issue tracker, a chat service) and for
global skills, which have no repository of their own to carve out.

This is closely related to part one's item 2 — the same tension, seen from
the other side, and resolved the same direction (keep the general rule as
literal as possible, name concrete vocabulary only where genericizing would
hollow the skill out).

## 8. The sibling-naming rule is harder downstream than here — RESOLVED

Decision: the rule stays absolute. It binds within a single project-level
family, not only across the global/project boundary. `AGENTS.md` and
`create-skill/SKILL.md` now say so explicitly, instead of leaving it to be
inferred from the independent-installability rationale, which didn't
obviously cover siblings that always ship together. `design`'s four
`SKILL.md` files (which named siblings by slash-path) still need re-editing
in that repository to match; the conformance pass already showed this
reads fine as lifecycle-stage references instead.

## 9. Nothing in `create-skill` governs the family index — RESOLVED

Decision: specified it. Added
`create-skill/references/create-skill-workflow-diagrams.md`, giving the emoji
legend (🤖 non-interactive, 🤖🧑 interactive, ⚙️ scripted) and the canonical
`classDef` block — reusing this collection's own root `README.md` diagrams
as the worked example. `SKILL.md` instruction 6 now points to it when
registering a skill in an index that includes a Mermaid workflow diagram,
and a new Rules bullet requires the diagram's node markers to stay in sync
with each skill's own README and its `classDef` styling to match the
reference. A collection still isn't required to keep an index, or a diagram
within one.

This fixes the `agentic`/`anthropic` drift and the `stroke-width`
inconsistency going forward, but doesn't retroactively fix the five
repositories already carrying it, or give `bookmarks`/`bootstrap` an index —
those are downstream follow-ups.

## 10. A recurring defect the validator could catch cheaply — RESOLVED

Decision: added `check_fence_languages` to `create-skill-validate.sh`,
checked against both `SKILL.md` and `README.md`. It FAILs any fenced code
block whose info string isn't in a known-language set (blank/plain-text
fences are unaffected). Verified it flags a synthetic ` ```gh ` block and
produces no false positives across all 29 skills in this collection.

The four downstream repositories (`audits`, `design` ×2, `rfc` ×2, and any
others not yet surveyed) still carry the actual ` ```gh ` instances and need
fixing directly — the validator only catches new instances and reruns of
`create-skill` against those skills, it doesn't retroactively fix files.

## 11. Non-interactive skills cannot satisfy a "confirm with the user" rule — RESOLVED

Decision: wrote the `garden` pattern into
`create-skill/references/create-skill-interactive.md` as a new section — a
non-interactive skill facing a confirmation requirement MUST NOT perform the
action outright, and recommends it instead, surfacing the recommendation in
its report. The uncommitted working tree stands in for the mid-flow prompt
it can't make. `SKILL.md`'s reference-list entry for that file now points
at the addition.

`garden`'s own family already implements this correctly and needs no
further change; the gap was only that `create-skill` didn't say so, leaving
each future pass to reinvent it.

## Downstream items, for the repositories themselves

Recorded here only so they are not lost. Each belongs to its own repository
and none is a `create-skill` concern.

| Repo | Item |
| ---- | ---- |
| `bookmarks` | `AGENTS.md` describes the skill as a flat `.agents/skills/add-bookmark.md` and cites a `.agents/skills/README.md` that has never existed. |
| `bootstrap` | The `is_agent_profile` carve-out was dropped, as `AGENTS.md` states the no-profile-branching rule absolutely and no step calls the predicate. Restore it in `AGENTS.md` if intended. |
| `audits` | `draft-audit`'s second commit uses `chore:` where `CONTRIBUTING.md` step 7 specifies `audit:`. |
| `plans` | `abandon-plan` runs `gh pr list --label A --label B`, which ANDs in `gh` and therefore matches nothing. Latent bug; needs two calls or `--search`. |
| `plans` | `draft-plan` hard-codes a `Plans` discussion category that no repository document mentions. |
| `risks` | The `draft-report`/`review-report`/`complete-report` names collide conceptually with `draft-audit` et al., since "report" names a genre rather than an artifact. Suggested: `*-threat-model`. |
| `risks` | `CONTRIBUTING.md` says "session report" where `AGENTS.md`, `INDEX.md`, and `TEMPLATE.md` say "workshop report". |
| `rfc` | `reject-rfc`, `complete-rfc`, and `supersede-rfc` push directly to `main`; none handles branch protection. |
| `design` | `reconcile-design` walks all eight views by default, which is expensive. Promoting its drift-area parameter to REQUIRED would change its remit. |
| `design` | All four `SKILL.md` files still name sibling skills by slash-path (item 8 is now resolved: rebind these as lifecycle-stage references instead). |
| `standards` | `gap-analysis` dropped its `Agent` declaration during the conformance pass because the value wasn't in the permitted set (item 5 is now resolved). Re-declare `Agent` in `compatibility` and add the required README explanation of why it fans out. |
| `audits`, `design`, `rfc` | Still carry the actual ` ```gh ` fenced blocks that item 10's new validator check now catches (1 instance in `audits`, 2 in `design`, 2 in `rfc`). Re-fence each as its real language (`graphql`, `sh`, etc.) and rerun the validator. |
| `rfc` | Its index diagram still draws every node `agentic` 🤖 despite its own skill READMEs stating some are interactive (item 9 is now resolved: sync the markers per the new reference). |
| `audits` | Its index diagram's `classDef anthropic` uses `stroke-width:2px` against the now-specified `1px` convention (item 9). |
| `bookmarks`, `bootstrap` | Have no skills index at all; their catalogues live in the repository `AGENTS.md`, which has gone stale. Item 9 specifies the index format if one is added, but doesn't require adding one. |
| `specs` | `supersede-spec` swaps `#released` → `#superseded` on a pull request closed at release, but `CONTRIBUTING.md` scopes lifecycle labels to open pull requests and lists none past `#released`. Either document the label or drop the swap. |
| `specs` | `CONTRIBUTING.md` permits an `EPIC` type and `epic/<slug>` branches, but `proposals/INDEX.md` only ever shows `Feature`. Confirm `Epic` belongs in the index. |
| `specs` | No documented path exists for abandoning a `DRAFT` proposal. `reject-spec` covers only `PROPOSED` onwards; the state machine implies a draft is simply dropped, but nothing says whether that should leave a trace. |
| `garden` | `water` and `fertilize` are the strongest merge candidates in the collection: both research a topic, extend one entry in place, cross-reference it, and recommend a maturity bump. The only distinction is the starting state — stub vs established — which has no bright line. |
| `garden` | `trim` and `cultivate` both edit one entry's prose. `cultivate` enforces the written style guide; `trim` makes judgment calls the guide is silent on. A "tidy this up" request could reasonably go either way. |
| `garden` | Three skills scan the whole garden ranking weak entries — `tend`, `fertilize` in unattended mode, and `forage`. Consider whether stub-ranking should live only in `tend`. |
| `garden` | `prune` and `graft` now delete files with no confirmation prompt, following from the family being uniformly non-interactive. Making these two interactive is defensible for destructive operations but would be the family's only split. |
| `garden` | The `harvest` digest has no defined home. The skill has always referred to "the most recent digest file", but nothing defines where digests live and none exist. It now falls back to printing to chat. |
