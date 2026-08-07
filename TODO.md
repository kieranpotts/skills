# TODO

Open decisions arising from the conformance pass that reapplied `create-skill`
to all 28 other skills in this collection. Each item spans several skills, so
none could be settled by a per-skill edit. All 29 skills validate clean as
they stand — these are judgment calls, not defects.

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

## 2. How convention-agnostic should the Git and planning skills be?

The no-hard-coding rule in `AGENTS.md` says a skill MUST NOT hard-code the
location, name, or format of any artifact it touches. Applied literally, that
also strips out TS-9's vocabulary, which several skills previously named
outright:

- `branch`, `merge`, `release` — the trunk names `dev`, `test`, `ready` were
  softened into discovered parameters, with the TS-9 names kept only as noted
  defaults.

- `plan`, `fix`, `code` — the commit type prefixes `step:`, `feature:`,
  `refactor:`, `fix:`, `maintenance:` were genericized to describe the *role*
  each type plays, with the literals left visible only in worked examples.

The tension: TS-9 is a standard these repositories all follow, so naming its
vocabulary outright is arguably domain content rather than a hard-coded
artifact store. Portability costs concreteness here.

This is the change most likely to want reversing. It is localized to the
rules and parameters of those six skills.

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
