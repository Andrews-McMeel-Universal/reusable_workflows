# Reusable Workflows

Reusable workflows can be called from other GitHub Actions workflows within repositories to perform a variety of tasks.

We use them to automate deployments, PR-related checks, update objects in Azure, and more.

---

## Getting Started

To call a reusable workflow, you need to use the `uses:` option contains the path to the reusable workflow repo, `Andrews-McMeel-Universal/reusable_workflows/.github/workflows/` along with the workflow name.

```YAML Example
codeowners-validation:
  if: ${{ github.actor != 'dependabot[bot]' }}
  name: Codeowners File Validation
  uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/codeowners-validation.yaml@2
```

If the workflow requires any inputs to be passed in, make sure to include those under either the `with:` and `secrets:` sections.

```YAML Example
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

When referencing workflows, you can specify either a tag or a branch from this repository.

For example, to specify a release to get a static copy of the workflows at that point:

```YAML Example
Andrews-McMeel-Universal/reusable_workflows/.github/workflows/aks-deploy.yaml@2
```

To specify a branch:

```YAML Example
Andrews-McMeel-Universal/reusable_workflows/.github/workflows/aks-deploy.yaml@DEVOPS-fix-aks-deploy-bug
```

> NOTE: You can call multiple reusable workflows within a single workflow file.

---

## Development and Testing

```bash
git clone https://github.com/Andrews-McMeel-Universal/reusable_workflows.git
```

We primarily test workflows with the [reusable_workflows-test](https://github.com/Andrews-McMeel-Universal/reusable_workflows-test) repository. You can test and link the respective workflow tests with PRs by doing the following:

1. Create a branch in the `reusable_workflows` repository
1. Create a branch that matches the name of the branch in the `reusable_workflows` repository in the `reusable_workflows-test` repository.
1. Create or update the workflow in the `reusable_workflows-test` repository to reference the branch name.
1. Push your changes to the branch and trigger (through whatever workflow triggers you have set up) the workflow's GitHub action.
1. Click on the workflow's GitHub action tab on the left side of the "Actions" page.
1. Click the ellipsis button at the top right of the workflow's GitHub action page and click "Create status badge"
1. Specify the branch you've set up in the repository and copy the markdown URL.
1. Once you've successfully run the workflow, paste the markdown URL in the reusable_workflows PR for merging in the workflow changes. The end result should look something like this PR: https://github.com/Andrews-McMeel-Universal/reusable_workflows/pull/18

---

## New Releases

This repository is using the `update-major-release.yaml` to automatically create major release tags based off the most latest/stable version.

To run this workflow:

1. Go to this repository's [Update Major Release](https://github.com/Andrews-McMeel-Universal/reusable_workflows/actions/workflows/update-major-release.yaml) workflow
1. Press "Click workflow" on the right-hand side of the page.
1. Specify the tag to create a major release for and what the major release will be.
1. Click "Run workflow"

---

## Available workflows

Depending on the app, you will want to use a combination of different workflows. For example, for a Kubernetes-based application, you would want to use the `aks-deploy.yaml` to deploy the application to the Azure Kubernetes Service cluster along with a few PR checking workflows like, `codeowners-validation.yaml`, `pr-labels.yaml`, and `lint-and-format.yaml`.

To get an idea of what workflows a specific application might need, you can reference the template repository that is closely related to the app. For example, for a Kubernetes-based Ruby on Rails application, you can reference [k8sapp_ruby_template](https://github.com/Andrews-McMeel-Universal/k8sapp_ruby_template)

---

## Deployment Workflows

### Azure Kubernetes Service Deploy

**Workflow file: [aks-deploy.yaml](https://github.com/Andrews-McMeel-Universal/reusable_workflows/blob/main/.github/workflows/aks-deploy.yaml)**

- AKS deployment workflow.
  - Checks the code out
  - Parses the charts.yaml and values.yaml in the application's helm charts for information about the application
  - Reads the specified Azure KeyVaults for secrets and build arguments for the application
  - Creates public DNS records for the application
  - Creates any K8s secrets or Configmaps specified for the application
  - Builds docker image for the application
  - Pushes the docker image to Azure's container repository
  - Bakes the application's helm charts
  - Deploys the application to Azure Kubernetes
  - Upon a successful deployment, the workflow records the deployment information in Azure Storage Tables for use by subsequent workflows.

```YAML Example
jobs:
  deploy:
    name: AKS Deployment
    uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/aks-deploy.yaml@2
    with:
      environment: development
      environmentIngress: true|false # If set to true, the environment name will be prepended to the application hostname.
    secrets:
      azureClusterName: ${{ secrets.AKS_CLUSTER_NAME }}
      azureCredentials: ${{ secrets.AZURE_CREDENTIALS }}
      registryHostName: ${{ secrets.REGISTRY_HOSTNAME }}
      registryUserName: ${{ secrets.REGISTRY_USERNAME }}
      registryPassword: ${{ secrets.REGISTRY_PASSWORD }}
      storageAccountKey: ${{ secrets.STORAGEACCOUNT_KEY }}
```

### WordPress Site Deploy

**Workflow file: [wpe-deploy.yaml](https://github.com/Andrews-McMeel-Universal/reusable_workflows/blob/main/.github/workflows/wpe-deploy.yaml)**

- Deploys the WordPress site to WPEngine

```YAML Example
jobs:
  deploy:
    name: WP Engine Deployment
    uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/wpe-deploy.yaml@2
    with:
      WPE_ENV_NAME: appnamedev
      SOURCE_PATH: "wp-content/themes/appname"
      PUBLISH_PATH: "wp-content/themes/appname"
      environment: development
    secrets:
      WPENGINE_ED25514: ${{ secrets.WPENGINE_ED25514 }}
```

### Update Boley DNS

**Workflow file: [update-addns.yaml](https://github.com/Andrews-McMeel-Universal/reusable_workflows/blob/main/.github/workflows/update-addns.yaml)**

- Updates internal Active Directory DNS.
- Reads the Azure Storage Table for application information and then updates Active Directory DNS.

> NOTE: This workflow runs on a self hosted runner.

```YAML Example
jobs:
  update-boley-dns:
    name: Update Boley DNS
    uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/update-addns.yaml@2
    with:
      environment: staging
    secrets:
      domainController: ${{ secrets.BOLEY_DC }}
      storageAccountKey: ${{ secrets.STORAGEACCOUNT_KEY }}
```

### Update Azure API Management

**Workflow file: [update-azureapimanagement.yaml](https://github.com/Andrews-McMeel-Universal/reusable_workflows/blob/main/.github/workflows/update-azureapimanagement.yaml)**

- Updates Azure API Management.
  - Reads the Azure Storage Table for application information and then updates Azure API Management with the swagger.json Open API Spec.

```YAML Example
jobs:
  update-azure-api-management:
    name: Update Azure API Management
    uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/update-azureapimanagement.yaml@2
    with:
      environment: development  # This is required
      apiId: gocomics-user-info-service-api  # Defaults to "[REPOSITORY_NAME]-api"
      apiServiceName: amudevelopmentapi101  # Defaults to the resource with a "environment" tag matching the environment input set above.
      apiServiceResourceGroup: AMU_DEV_RG  # Defaults to the resource with a "environment" tag matching the environment input set above.
    secrets:
      azurePassword: ${{ secrets.AMU_DEPLOY_PASSWORD }}  # Only set if the API service is in the fdickinson tenant
      azureSubscription: ${{ secrets.AMU_PAY_AS_YOU_GO_SUBSCRIPTION_ID }}  # Only set if the API service is in the fdickinson tenant
      azureCredentials: ${{ secrets.AZURE_CREDENTIALS }}  # Only set if the API service is NOT in the fdickinson tenant
      storageAccountKey: ${{ secrets.STORAGEACCOUNT_KEY }}
```

### B2C Build and Deploy

**Workflow file: [b2c-build-and-deploy.yaml](https://github.com/Andrews-McMeel-Universal/reusable_workflows/blob/main/.github/workflows/b2c-build-and-deploy.yaml)**

- Builds the B2C assets
- Uploads the B2C assets

```YAML Example
jobs:
  b2c-build-and-deploy:
    uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/b2c-build-and-deploy.yaml@2
    with:
      environment: development
      azureB2CProductName: appname
      azureB2CDomain: developmentamub2c.onmicrosoft.com
    secrets:
      azureCredentials: ${{ secrets.AZURE_CREDENTIALS }}
      storageAccountKey: ${{ secrets.STORAGEACCOUNT_KEY }}
      azureB2CClientId: ${{ secrets.B2C_CLIENT_ID }}
      azureB2CClientSecret: ${{ secrets.B2C_CLIENT_SECRET }}
```

### Purge CDN

**Workflow file: [purge-cdn.yaml](https://github.com/Andrews-McMeel-Universal/reusable_workflows/blob/main/.github/workflows/purge-cdn.yaml)**

- Purges the Azure CDN cache for a specific CDN endpoint

```YAML Example
jobs:
  purge-cdn:
    name: Purge CDN
    uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/purge-cdn.yaml@2
    with:
      environment: staging  # This is required
      cdnResourceGroup: AMU_Games_RG  # Defaults to the resource with a "environment" tag matching the environment input set above.
      cdnProfile: production-games  # Defaults to the resource with a "environment" tag matching the environment input set above.
      cdnEndpoint: appname-game  # Defaults to the resource with a "repository-name" tag matching the GitHub repository name.
    secrets:
      azureCredentials: ${{ secrets.AZURE_CREDENTIALS }}
```

### Azure Function Deploy

**Workflow file: [azfunction-deploy.yaml](https://github.com/Andrews-McMeel-Universal/reusable_workflows/blob/main/.github/workflows/azfunction-deploy.yaml)**

- Deploys an Azure Function App

```YAML Example
jobs:
  build-and-deploy:
    name: Build and Deploy
    uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/azfunction-deploy.yaml@2
    with:
      AZURE_FUNCTIONAPP_NAME: "pause-subscription-manager"
      environment: development
    secrets:
      AZURE_CREDENTIALS: ${{ secrets.AZURE_CREDENTIALS }}
```

---

## PR Checks Workflows

### Validate Codeowners File

**Workflow file: [codeowners-validation.yaml](https://github.com/Andrews-McMeel-Universal/reusable_workflows/blob/main/.github/workflows/codeowners-validation.yaml)**

- Validates the syntax in the CODEOWNERS file.

```YAML Example
jobs:
  codeowners-validation:
    name: Validate CODEOWNERS file
    uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/codeowners-validation.yaml@2
```

### Lint and Format

**Workflow file: [lint-and-format.yaml](https://github.com/Andrews-McMeel-Universal/reusable_workflows/blob/main/.github/workflows/lint-and-format.yaml)**

- Runs prettier on all files. Ignores files listed in `.prettierignore`
- Runs workflow linter on all workflow files in `.github/` by default.

```YAML Example
jobs:
  lint-and-format:
    name: Lint and Format
    uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/lint-and-format.yaml@2
```

### PR Labels

**Workflow file: [pr-labels.yaml](https://github.com/Andrews-McMeel-Universal/reusable_workflows/blob/main/.github/workflows/pr-labels.yaml)**

```YAML Example
jobs:
  pr-labels:
    name: Adds PR Labels
    uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/pr-labels.yaml@2
    secrets:
      PAT_ACTION_CI: ${{ secrets.PAT_ACTION_CI }}
```

### Jira Lint

**Workflow file: [jira-lint.yaml](https://github.com/Andrews-McMeel-Universal/reusable_workflows/blob/main/.github/workflows/jira-lint.yaml)**

```YAML Example
jobs:
  jira-lint:
    name: Jira PR Linter
    uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/jira-lint.yaml@2
```

### Clear PR Caches

**Workflow file: [pr-clean-caches.yaml](https://github.com/Andrews-McMeel-Universal/reusable_workflows/blob/main/.github/workflows/pr-clean-caches.yaml)**

```YAML Example
name: Cleanup caches after PR is closed

on:
  pull_request:
    types: [closed]

jobs:
  pr-clean-caches:
    name: Clear PR Caches
    uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/pr-clean-caches.yaml@2
```

### Dependabot Automations

**Workflow file: [dependabot-automations.yaml](https://github.com/Andrews-McMeel-Universal/reusable_workflows/blob/main/.github/workflows/dependabot-automations.yaml)**

- Auto-approves and auto-merges in dependabot PRs.

```YAML Example
jobs:
  dependabot-automations:
    name: Dependabot Automations
    uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/dependabot-automations.yaml@2
```

---

## Tool Workflows

### Bump Version

**Workflow file: [bump-versions.yaml](https://github.com/Andrews-McMeel-Universal/reusable_workflows/blob/main/.github/workflows/bump-versions.yaml)**

- This workflow automatically bumps the application's version in `Chart.yaml` and the `package.json` if it exists.
  - Use the `releaseType` input to change how the version is automatically incremented.

```YAML Example
name: "Bump Version"

on:
  workflow_dispatch:
    inputs:
      releaseType:
        type: choice
        description: Type of release
        options:
          - major
          - minor
          - patch

jobs:
  bump-versions:
    name: Bump Versions
    uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/bump-versions.yaml@2
    with:
      releaseType: ${{ inputs.releaseType }}
```

---

## Contributing

New branches should always be associated with a Jira ticket. The branch should be prefixed with the issue key and a short description, like so: `jiraIssueType/DEVOPS-1234/hyphenated-issue-summary`.

### Jira Smart Commits

In scenarios where creating a separate branch for each Jira ticket is not exactly feasible, you can still trigger our automation by using what are called [smart commits](https://confluence.atlassian.com/fisheye/using-smart-commits-960155400.html).

To use Jira smart commits, you would include the Jira issue key for each commit like so: `[DEVOPS-1234], [DEVOPS-1235] Knocked out the 4 copy edits needed`

### Creating Pull Requests

Once you have committed your effort in a separate branch, you will need to raise a pull request in Github. While filling out the Pull Request, **Please** follow the pull request template format and write a brief description of any technical details and Jira tickets that are related to the PR.

The recommended title for the pull request is typically just the branch name. Again, if a single issue per branch is not feasible, including a brief title of the effort is acceptable.

You do not need to fill in the reviewers or assignees. Our CODEOWNERS automation takes care of who will need to review it. As long as a AMU software engineer reviews it and the other checks pass, they will take care of merging the pull request into staging and production.

> NOTE: On every PR, we do run tests and automatically format the code with Prettier.

> NOTE: A PR will not be able to be merged until at least 1 reviewer with write access has approved it and all tests are passing. If a PR is updated with a new commit, stale reviews will be dismissed.

---

### Creating a new Release

Once a pull request is merged into _main_, it passes all CI checks and passes QA, it will be ready for being released to staging and production.

1. Navigate to the [Releases](https://github.com/Andrews-McMeel-Universal/reusable_workflows/releases) tab
1. Click the button for "Draft a New Release" and then click "Auto-generated Release Notes".
1. If this is for a staging deployment, check `Set as a pre-release` option and make sure to add `-rc` to the end of the tag name. Otherwise, just set it to the release version.
1. Click "Publish Release"

> NOTE: We do not use the v2 pattern for version naming. We simply have the semantic release version number like this: 2
