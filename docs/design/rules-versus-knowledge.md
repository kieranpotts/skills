# Rules versus knowledge

An agent skill is a set of rules or instructions for performing one step of a workflow. To maintain the [single responsibility principle](./single-responsibility.md), a skill should not drift into encoding knowledge, too.

A skill may instruct an agent to go and *extract* knowledge it needs — coding conventions, domain language, architectural constraints — from reference material that lives elsewhere. But the skill itself should not contain that knowledge. It says how to look something up and what to do with it, not what the answer is.

This separation is what makes a skill reusable across projects. A skill that specializes in defining a workflow step stays technology-agnostic and domain-agnostic, and can run unmodified against any codebase that supplies its own reference material on demand. A skill that hard-codes project-specific knowledge stops being portable the moment it leaves the project it was written for.

If a piece of bespoke knowledge genuinely belongs nowhere but a single repository, it belongs in a skill — or a reference document — that is local to that repository.
