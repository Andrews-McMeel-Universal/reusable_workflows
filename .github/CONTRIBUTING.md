# Contributing

## Branch Naming Convention

When creating a new branch, it should be associated with a Jira ticket. The branch name should follow this format: `jiraIssueType/AMUPRODUCT-1234/hyphenated-issue-summary`.

## Using Jira Smart Commits

In cases where creating a separate branch for each Jira ticket isn't practical, you can use [smart commits](https://confluence.atlassian.com/fisheye/using-smart-commits-960155400.html) to trigger our automation. Include the Jira issue key in each commit message like this: `[AMUPRODUCT-1234], [AMUPRODUCT-1235] Implemented the 4 required copy edits`.

## Pull Request Process

After committing your changes in a separate branch, you'll need to create a pull request (PR) on Github. When creating the PR, adhere to the provided PR template format and include a concise description of the technical details and related Jira tickets.

The PR title should ideally be the branch name. If multiple issues are addressed in a single branch, a brief, descriptive title is acceptable.

You don't need to specify reviewers or assignees. Our CODEOWNERS automation determines who will review your PR. Once an AMU software engineer reviews and approves your PR, and all checks pass, they will merge your PR into the staging and production branches.

> **NOTE:** Every PR triggers tests and automatic code formatting with Prettier.

> **NOTE:** A PR can't be merged until at least one reviewer with write access approves it and all tests pass. If a PR is updated with a new commit, previous reviews will be dismissed.