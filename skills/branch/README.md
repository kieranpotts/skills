# `branch` skill

This skill defines branch naming conventions, and it explains how and when branches are cut from other ones.

Consistent branching rules are important for readability and maintainability of a code repository. They help developers understand the purpose and state of work-in-progress, and they make it easier to enforce constraints (eg. via branch protection rules) in reference repositories and automation pipelines.

The branching model described by this skill is trunk-based. There are multiple permanent trunks (`dev` → `test` → `ready`) plus short-lived `temp/*` and long-lived `epic/*` branches cut from `dev`.
