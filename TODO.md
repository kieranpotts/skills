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

## 1. Do skills commit their own work?

The collection has no stated rule, so each skill answers from precedent, and
the precedents disagree:

| Skill      | Behavior                                            |
| ---------- | --------------------------------------------------- |
| `code`     | Commits; boundary stated as "stops at the commit".  |
| `fix`      | Commits, at instruction 9.                          |
| `refactor` | Commits. Previously also integrated and opened a PR.|
| `style`    | Commits, at instruction 5.                          |
| `proof`    | Stops before the commit.                            |
| `commit`   | Composes a message; will not stage or commit.       |

`AGENTS.md` cites proofreading as a skill that "edits prose but does not
commit the change", which supports the `proof` position but sits awkwardly
beside the four skills that do commit.

The working principle the pass converged on — change-making skills commit,
evaluation skills do not — is coherent, but it is written down nowhere.

`commit` is a further wrinkle: it writes the changelog file while refusing to
stage it, so it modifies the working tree but declines to record the change.

Decide the rule, then state it in `AGENTS.md` so skills stop inferring it.
Note that `commit` also carried a `<!-- TODO: Allow direct commits to dev? -->`
marker, removed during the pass; that question is part of this one.

## 2. How convention-agnostic should the Git and planning skills be? — RESOLVED

Decision: keep the genericized state. TS-9 names (`dev`, `test`, `ready`,
`step:`, `feature:`, `refactor:`, `fix:`, `maintenance:`) stay as discovered-
parameter defaults only, not hard-coded values, across `branch`, `merge`,
`release`, `plan`, `fix`, `code`. This matches the no-hard-coding rule
literally and preserves portability for repositories that diverge from TS-9.
No further changes needed — the six skills already reflect this.

## 3. Should evaluation skills persist their reports?

Reporting skills split two ways:

- Resolve an output store and write to it: `audit`, `probe`, `research`,
  `review`.

- Return the report to the caller and write nothing: `test`, `validate`.

Both behaviors predate the pass and were preserved. `test` and `validate`
therefore carry no `Write` in `compatibility`, which is what makes their
"working tree unchanged" boundary criterion coherent.

If verification and validation evidence is meant to be durable, both skills
need an output-store parameter and `Write`. That is a design change, not a
conformance fix, which is why it was left alone.

## 4. Naming a specific host CLI in `compatibility`

Two skills were deliberately genericized during the pass, and two were not:

| Skill     | `compatibility` parenthetical         |
| --------- | ------------------------------------- |
| `triage`  | `Bash (issue tracker CLI, ...)`       |
| `resolve` | `Bash (git, review host CLI, ...)`    |
| `review`  | `Bash (git diff, gh)`                 |
| `specify` | `Bash (git, gh)`                      |

Naming `gh` presumes GitHub in skills whose stores are supposed to be
discovered. Naming a generic CLI is vaguer but portable.

Pick one direction and apply it to all four. It is a one-line change per
skill.

## Minor, unrelated to the above

- Three READMEs gained a `decide` entry under `## Related skills` on the
  authoring agents' own initiative: `elaborate`, `research`, `spike`. Each is
  defensible individually; nobody decided it centrally.

- `proof`'s README asserts that running `style` first yields fewer conflicts.
  Neither skill documents that ordering.

- `specify`'s `## Examples` section was deleted rather than repaired. It had a
  malformed code fence and illustrated store discovery rather than any output
  the skill produces. It is the only section removed outright during the pass.

- `branch`'s examples previously used uppercase tracking IDs
  (`TS-504`, `PRODUCT-187`) that failed the skill's own lowercase-only
  validation regex. The examples were lowercased. If uppercase IDs are meant
  to be legal, the regex needs changing instead — and that likely affects
  `commit` too.

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

## 6. The validator's H1 check has three false-positive classes

`create-skill-validate.sh` derives the expected H1 from the `name` field by
replacing hyphens with spaces and sentence-casing. That is wrong for:

- Acronyms. `# APT` (bootstrap) and all six `# ... RFC` headings (rfc) are
  flagged; the validator wants `Apt` and `Draft rfc`.

- Hyphenated compounds. `fix-cross-references` is flagged; the validator
  wants `# Fix cross references`, but "cross-references" is a correctly
  hyphenated English compound that the skill's own prose uses throughout.

- Proper nouns, by the same logic, though no current skill trips this.

Eight of the 47 downstream skills carry a residual FAIL for this reason
alone, and every one of them is correct as written. This is the only check
in the validator that a conforming skill cannot satisfy.

Until it is fixed, a clean run is not achievable across the collection, which
erodes the validator's value as a gate. Options: relax the check to a WARN,
compare case-insensitively, or let the front matter carry an explicit
`title` that the check honors when present.

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

## 9. Nothing in `create-skill` governs the family index

Most downstream repositories keep a `.agents/skills/README.md` cataloguing
their skills, usually with a Mermaid workflow diagram. `create-skill`
describes the per-skill `README.md` and says nothing about this index.

The consequence showed up immediately: in five repositories the index diagram
drew every node as `agentic` 🤖 while the skills are interactive and their
own READMEs now say so. Four agents corrected the index to `anthropic` 🤖🧑;
the `rfc` agent left it, reading its remit to edit the index as covering
prose only. Both readings were reasonable, because there is no rule.

Two smaller drifts in the same file: `audits`' index uses
`stroke-width:2px` in its `classDef anthropic` where the `create-skill`
template uses `1px`, and `bookmarks` and `bootstrap` have no index at all —
their skill catalogues live in the repository `AGENTS.md`, where they have
gone stale.

`create-skill` should either specify the index or state explicitly that it is
out of scope.

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

## 11. Non-interactive skills cannot satisfy a "confirm with the user" rule

`create-skill` treats interactivity as a per-skill mode, stated in the
`## Parameters` preamble. It says nothing about what a non-interactive skill
should do when the repository it operates on has a rule requiring user
confirmation.

The `garden` repository hit this squarely. Its `AGENTS.md` requires explicit
user confirmation before promoting or demoting an entry's maturity emoji, but
the skills that would do so are non-interactive. The pass resolved it by
making the family `MUST NOT` change the emoji and `SHOULD` recommend one,
pushing the decision to the human reading the report — a reasonable answer,
but invented on the spot.

The general pattern is worth stating in `create-skill`: a non-interactive
skill facing a confirmation requirement recommends rather than acts, and
surfaces the recommendation in its report. The uncommitted working tree is
the review gate.

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
| `specs` | `supersede-spec` swaps `#released` → `#superseded` on a pull request closed at release, but `CONTRIBUTING.md` scopes lifecycle labels to open pull requests and lists none past `#released`. Either document the label or drop the swap. |
| `specs` | `CONTRIBUTING.md` permits an `EPIC` type and `epic/<slug>` branches, but `proposals/INDEX.md` only ever shows `Feature`. Confirm `Epic` belongs in the index. |
| `specs` | No documented path exists for abandoning a `DRAFT` proposal. `reject-spec` covers only `PROPOSED` onwards; the state machine implies a draft is simply dropped, but nothing says whether that should leave a trace. |
| `garden` | `water` and `fertilize` are the strongest merge candidates in the collection: both research a topic, extend one entry in place, cross-reference it, and recommend a maturity bump. The only distinction is the starting state — stub vs established — which has no bright line. |
| `garden` | `trim` and `cultivate` both edit one entry's prose. `cultivate` enforces the written style guide; `trim` makes judgment calls the guide is silent on. A "tidy this up" request could reasonably go either way. |
| `garden` | Three skills scan the whole garden ranking weak entries — `tend`, `fertilize` in unattended mode, and `forage`. Consider whether stub-ranking should live only in `tend`. |
| `garden` | `prune` and `graft` now delete files with no confirmation prompt, following from the family being uniformly non-interactive. Making these two interactive is defensible for destructive operations but would be the family's only split. |
| `garden` | The `harvest` digest has no defined home. The skill has always referred to "the most recent digest file", but nothing defines where digests live and none exist. It now falls back to printing to chat. |
