# Reusable GitHub Actions Workflows

This repository contains a set of reusable workflows for GitHub Actions. These workflows are designed to automate various tasks such as deployments, PR checks, Azure object updates, and more across multiple repositories.

## How to Use

To use these workflows, reference them in your GitHub Actions workflow file using the `uses:` directive. This directive should include the path to the reusable workflow in this repository, `Andrews-McMeel-Universal/reusable_workflows/.github/workflows/`, followed by the specific workflow name.

## Workflow Examples

### Codeowners File Validation

This workflow checks the validity of the CODEOWNERS file in your repository.

```YAML
codeowners-validation:
  if: ${{ github.actor != 'dependabot[bot]' }}
  name: Codeowners File Validation
  uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/codeowners-validation.yaml@2
```

### Jira PR Linter

This workflow checks PRs for Jira ticket references and performs other compliance checks.

```YAML
jira-lint:
  if: ${{ github.actor != 'dependabot[bot]' && github.actor != 'amutechtest' && github.ref != 'refs/heads/development' && github.ref != 'refs/heads/main' }}
  name: Jira PR Linter
  uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/jira-lint.yaml@2
  with:
    fail-on-error: true
    skip-comments: false
  secrets:
    JIRA_TOKEN: ${{ secrets.JIRA_TOKEN }}
```

## Workflow Versioning

You can reference workflows by either a tag or a branch from this repository.

- To reference a specific release (for a static copy of the workflows at that point):

```YAML
Andrews-McMeel-Universal/reusable_workflows/.github/workflows/aks-deploy.yaml@2
```

- To reference a specific branch:

```YAML
Andrews-McMeel-Universal/reusable_workflows/.github/workflows/aks-deploy.yaml@DEVOPS-fix-aks-deploy-bug
```

## Integration of Reusable Workflows

After a pull request is merged into _main_, you can create a new release to use it as a reusable workflow. Follow the instructions in this guide to create a new release: [Creating a Release](https://amuniversal.atlassian.net/wiki/spaces/TD/pages/3452043300/Creating+a+new+GitHub+Release#Creating-a-release)

### Updating Major Release

After creating a new release, you can use the [Update Major Release Workflow](https://github.com/Andrews-McMeel-Universal/reusable_workflows/actions/workflows/update-major-release.yaml) to automatically update the major release tag for the repository.

1. Navigate to the [Update Major Release](https://github.com/Andrews-McMeel-Universal/reusable_workflows/actions/workflows/update-major-release.yaml) workflow.
1. Click "Run workflow" on the right-hand side of the page.
1. Specify the tag to create a major release for and what the major release will be.
1. Click "Run workflow"
