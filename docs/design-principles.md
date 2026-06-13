# Design principles

These are the design principles behind *this* collection of skills. They are deliberately stricter than the [generic best practices](./best-practices.md) for authoring agent skills, and they express the opinionated stance this repository takes. A skill in this collection MUST satisfy all of them.

The capitalized requirement keywords (MUST, MUST NOT, SHOULD, MAY, …) are used as defined in [IETF RFC 2119](https://www.ietf.org/rfc/rfc2119.txt).

## Portability

A skill MUST be portable: it MUST NOT reference any out-of-band material – anything outside its own directory.

Everything a skill needs to run MUST live within `skills/<name>/`: the `SKILL.md` itself, and any bundled `assets/`, `references/`, or `scripts/`. A skill MUST NOT link to a file elsewhere in the repository (a root `docs/` page, a shared reference, the project `AGENTS.md`), nor to another skill's directory. If the skill needs a piece of reference material, it carries its own copy under its own `references/`.

This is what lets a single skill be lifted out and installed on its own, into any project, and still work. The moment a skill depends on a file outside its directory, that file does not travel with it, and the skill breaks on install.

When bundling resources, namespace them so they remain unique if the skill is later installed alongside others – see [collision safety](../skills/create-skill/references/create-skill-collision-safety.md). Installers for Copilot and Cursor flatten every skill's `assets/`, `references/`, and `scripts/` into one shared directory, so an un-namespaced file is a silent-overwrite bug.

## Independence

A skill MUST be independent: it MUST NOT cross-reference another skill.

No `SKILL.md` links to, names as a dependency, or assumes the presence of another skill in the collection. A skill is a complete, self-contained unit. This is what gives the user the freedom to **delete any skill they don't want** without breaking the ones they keep, and to install a single skill without dragging in the rest.

Independence and portability are two sides of the same rule: portability forbids reaching *outside the directory*; independence forbids reaching *into a sibling skill* specifically.

## No hand-offs between skills

A skill MUST NOT hand off to another skill. It does its one job, reports its outcome, and stops.

A skill MUST NOT instruct the agent to invoke another skill next, name "the next step" as a specific skill, or chain itself to a successor. Sequencing skills into a workflow is **not a skill's decision** – it belongs to whatever orchestrates the skills: a human, an orchestrating agent, or a pipeline script. The skill exposes a clean output and a clear stopping point; the orchestrator decides what, if anything, runs next.

This follows from independence. A hand-off is a cross-reference with a direction, and it couples the skill to a workflow it should not assume. The same skill might be the last step in one workflow and the middle of another; baking in "next, run X" forecloses that.

A skill MAY describe *what kind of input it expects* and *what its output represents* in neutral terms – that is its contract, and it does not name another skill. It MUST NOT say "then run `plan`"; it MAY say "the output is an approved specification, ready for whatever consumes it."

## Single responsibility, and the duplication it avoids

A skill MUST have a single responsibility: it does one job and stops at the boundary of that job, leaving adjacent work to the caller. (See [best practices](./best-practices.md#single-responsibility) for the general principle.)

Single responsibility is what makes portability, independence, and no-hand-offs *achievable rather than painful*. When two skills find themselves needing the same shared content – the same checklist, the same format definition, the same convention – that is usually a signal that a responsibility has been drawn in the wrong place, not that the content should be shared between them.

Where shared content genuinely is unavoidable, **each skill carries its own copy**. Duplication is the accepted cost of independence and portability: a self-contained, deletable, individually-installable skill is worth more than a DRY one that cannot stand alone. But reach for duplication only after confirming the responsibility split is right – the better fix is almost always to draw the boundaries so the duplication is not needed in the first place.

This reverses the older "cross-reference instead of duplicate" guidance: a cross-reference breaks independence and portability, so it is not an acceptable way to avoid duplication here.

## Consequence for orchestration

Because skills neither reference nor hand off to one another, the *workflow* – the order in which skills run, the conditions under which one follows another, the human approval gates between phases – lives entirely outside the skills. It is the orchestrator's concern. A skill is a tool; the workflow is how the tools are wielded. Documenting a recommended workflow (for humans) is fine, and belongs in repository documentation – not inside any skill.

## Related

- [Best practices](./best-practices.md): Generic, universal guidance for authoring any agent skill – single responsibility, when a skill is worth adding, interactive vs. non-interactive execution.

- [Creating skills](./creating-skills.md): The authoring path (`create-skill`) and the contributor mechanics for this repository.

- [Collision safety](../skills/create-skill/references/create-skill-collision-safety.md): Namespacing bundled resources so a portable skill survives installation alongside others.
