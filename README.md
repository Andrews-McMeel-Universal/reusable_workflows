# Reusable Workflows

Reusable workflows can be called from other workflows within repositories to perform a variety of tasks. We use them to automate deployments, PR-related checks, update APIs, etc.

---

## Getting Started

Whenever calling the reusable workflows, you need to make sure the `uses:` option contains the path to the reusable workflow repo, `Andrews-McMeel-Universal/reusable_workflows/.github/workflows/` along with the workflow name. If the workflow requires any inputs to be passed in, make sure to include those under either the `with:` and `secrets:` sections.

When referencing workflows, you can specify either a tag or a branch from this repository. For example, you can use the `2.2.3` release to get a static copy of the workflows at that point, `Andrews-McMeel-Universal/reusable_workflows/.github/workflows/aks-deploy.yaml@2.2.3` or to specify a branch, `Andrews-McMeel-Universal/reusable_workflows/.github/workflows/aks-deploy.yaml@DEVOPS-fix-aks-deploy-bug`

> NOTE: You can call multiple reusable workflows within a single workflow file.

---

## Development and Testing

```bash
git clone https://github.com/Andrews-McMeel-Universal/reusable_workflows.git
```

We primarily test workflows with the [reusable_workflows-test](https://github.com/Andrews-McMeel-Universal/reusable_workflows-test) repository. You can test and link the respective workflow tests with PRs by doing the following:

1. Create a branch in the `reusable_workflows` repository
2. Create a branch that matches the name of the branch in the `reusable_workflows` repository in the `reusable_workflows-test` repository.
3. Create or update the workflow in the `reusable_workflows-test` repository to reference the branch name.
4. Push your changes to the branch and trigger (through whatever workflow triggers you have set up) the workflow's GitHub action.
5. Click on the workflow's GitHub action tab on the left side of the "Actions" page.
6. Click the ellipsis button at the top right of the workflow's GitHub action page and click "Create status badge"
7. Specify the branch you've set up in the repository and copy the markdown URL.
8. Once you've successfully run the workflow, paste the markdown URL in the reusable_workflows PR for merging in the workflow changes. The end result should look something like this PR: https://github.com/Andrews-McMeel-Universal/reusable_workflows/pull/18

---

## Available workflows

Depending on the app, you will want to use a combination of different workflows. For example, for a Kubernetes-based application, you would want to use the `aks-deploy.yaml` to deploy the application to the Azure Kubernetes Service cluster along with a few PR checking workflows like, `codeowners-validation.yaml`, `pr-labels.yaml`, and `lint-and-format.yaml`.

To get an idea of what workflows a specific application might need, you can reference the template repository that is closely related to the app. For example, for a Kubernetes-based Ruby on Rails application, you can reference [k8sapp_ruby_template](https://github.com/Andrews-McMeel-Universal/k8sapp_ruby_template)

### Azure Kubernetes Service Deploy

Workflow file: `aks-deploy.yaml`

AKS deployment workflow.

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

Example:

```YAML
jobs:
  deploy:
    name: AKS Deployment
    uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/aks-deploy.yaml@x.x.x
    with:
      environment: development
      environmentIngress: true|false # If set to true, the environment name will be prepended to the application hostname.
    secrets:
      azureClusterName: ${{ secrets.AKS_CLUSTER_NAME }}
      azureCredentials: ${{ secrets.AZURE_CREDENTIALS }}
      registryHostName: ${{ secrets.AMUAPPIMAGES201_HOSTNAME }}
      registryUserName: ${{ secrets.AMUAPPIMAGES201_USERNAME }}
      registryPassword: ${{ secrets.AMUAPPIMAGES201_PASSWORD }}
      storageAccountKey: ${{ secrets.AMUCLOUDAPPS_KEY }}
```

### WordPress Site Deploy

Workflow file: `wpe-deploy.yaml`

Deploys the WordPress site to WPEngine

Example:

```YAML
jobs:
  deploy:
    name: WP Engine Deployment
    uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/wpe-deploy.yaml@x.x.x
    with:
      WPE_ENV_NAME: appnamedev
      SOURCE_PATH: "wp-content/themes/appname"
      PUBLISH_PATH: "wp-content/themes/appname"
      environment: development
    secrets:
      WPENGINE_ED25514: ${{ secrets.WPENGINE_ED25514 }}
```

### Update Boley DNS

Workflow file: `update-addns.yaml`

Updates internal Active Directory DNS.

- Reads the Azure Storage Table for application information and then updates Active Directory DNS.

> NOTE: This workflow runs on a self hosted runner.

Example:

```YAML
jobs:
  update-boley-dns:
    name: Update Boley DNS
    uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/update-addns.yaml@x.x.x
    with:
      environment: staging
    secrets:
      domainController: ${{ secrets.BOLEY_DC }}
      storageAccountKey: ${{ secrets.AMUCLOUDAPPS_KEY }}
```

### Update Azure API Management

Workflow file: `update-azureapimanagement.yaml`

Updates Azure API Management.

- Reads the Azure Storage Table for application information and then updates Azure API Management with the swagger.json Open API Spec.

> NOTE: This workflow should only be used for backend services, not a UI as a UI won't have an API.

Example:

```YAML
jobs:
  update-azure-api-management:
    name: Update Azure API Management
    uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/update-azureapimanagement.yaml@x.x.x
    with:
      environment: development  # This is required
      apiId: gocomics-user-info-service-api  # Defaults to "[REPOSITORY_NAME]-api"
      apiServiceName: amudevelopmentapi101  # Defaults to the resource with a "environment" tag matching the environment input set above.
      apiServiceResourceGroup: AMU_DEV_RG  # Defaults to the resource with a "environment" tag matching the environment input set above.
    secrets:
      azurePassword: ${{ secrets.AMU_DEPLOY_PASSWORD }}  # Only set if the API service is in the fdickinson tenant
      azureSubscription: ${{ secrets.AMU_PAY_AS_YOU_GO_SUBSCRIPTION_ID }}  # Only set if the API service is in the fdickinson tenant
      azureCredentials: ${{ secrets.AZURE_CREDENTIALS }}  # Only set if the API service is NOT in the fdickinson tenant
      storageAccountKey: ${{ secrets.AMUCLOUDAPPS_KEY }}
```

### Purge CDN

Workflow file: `purge-cdn.yaml`

Purges the Azure CDN cache for a specific CDN endpoint

Example:

```YAML
jobs:
  purge-cdn:
    name: Purge CDN
    uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/purge-cdn.yaml@x.x.x
    with:
      environment: staging  # This is required
      cdnResourceGroup: AMU_Games_RG  # Defaults to the resource with a "environment" tag matching the environment input set above.
      cdnProfile: production-games  # Defaults to the resource with a "environment" tag matching the environment input set above.
      cdnEndpoint: appname-game  # Defaults to the resource with a "repository-name" tag matching the GitHub repository name.
    secrets:
      azureCredentials: ${{ secrets.AZURE_CREDENTIALS }}
```

### Validate Codeowners File

Workflow file: `codeowners-validation.yaml`

Validates the syntax in the CODEOWNERS file.

> NOTE: It is recommended to use this workflow with the `pr-labels.yaml` and `lint-and-format.yaml` workflows.

Example:

```YAML
jobs:
  codeowners-validation:
    name: Validate CODEOWNERS file
    uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/codeowners-validation.yaml@x.x.x
```

### Bump Version

Workflow file: `bump-versions.yaml`

This workflow automatically bumps the application's version in `Chart.yaml` and the `package.json` if it exists. Use the `releaseType` input to change how the version is automatically incremented.

Example:

```YAML
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
    uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/bump-versions.yaml@x.x.x
    with:
      releaseType: ${{ inputs.releaseType }}
```

### B2C Build and Deploy

Workflow file: `b2c-build-and-deploy.yaml`

- Builds the B2C assets
- Uploads the B2C assets

Example:

```YAML
jobs:
  b2c-build-and-deploy:
   uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/b2c-build-and-deploy.yaml@x.x.x
   with:
      environment: development
      azureB2CProductName: appname
      azureB2CDomain: developmentamub2c.onmicrosoft.com
   secrets:
    azureCredentials: ${{ secrets.AZURE_CREDENTIALS }}
    storageAccountKey: ${{ secrets.AMUCLOUDAPPS_KEY }}
    azureB2CClientId: ${{ secrets.B2C_CLIENT_ID }}
    azureB2CClientSecret: ${{ secrets.B2C_CLIENT_SECRET }}
```

### Lint and Format

Workflow file: `lint-and-format.yaml`

- Runs prettier on all files. Ignores files listed in `.prettierignore`
- Runs workflow linter on all workflow files in `.github/` by default.

> NOTE: It is recommended to use this workflow with the `pr-labels.yaml` and `codeowners-validation.yaml` workflows.

Example:

```YAML
jobs:
  lint-and-format:
    name: Lint and Format
    uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/lint-and-format.yaml@x.x.x
```

### PR Labels

Workflow file: `pr-labels.yaml`

> NOTE: It is recommended to use this workflow with the `codeowners-validation.yaml` and `lint-and-format.yaml` workflows.

Example:

```YAML
jobs:
  pr-labels:
    name: Adds PR Labels
    uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/pr-labels.yaml@x.x.x
    secrets:
      PAT_ACTION_CI: ${{ secrets.PAT_ACTION_CI }}
```

### Jira Lint

Workflow file: `jira-lint.yaml`

> NOTE: It is recommended to use this workflow with the `codeowners-validation.yaml`, `lint-and-format.yaml`, and `pr-labels.yaml` workflows.

Example:

```YAML
jobs:
  jira-lint:
    name: Jira PR Linter
    uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/jira-lint.yaml@x.x.x
```

### Clear PR Caches

Workflow file: `pr-clean-caches.yaml`

Example:

```YAML
name: Cleanup caches after PR is closed

on:
  pull_request:
    types: [closed]

jobs:
  pr-clean-caches:
    name: Clear PR Caches
    uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/pr-clean-caches.yaml@x.x.x
```

### Dependabot Automations

Workflow file: `dependabot-automations.yaml`

Auto-approves and auto-merges in dependabot PRs.

```YAML
jobs:
  dependabot-automations:
    name: Dependabot Automations
    uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/dependabot-automations.yaml@x.x.x
```

---

## Repository Synchronization

This repository is not currently set up to synchronize with any other repositories due to its very specific repository structure.

---

## Contributing

### Issue per Branch

For any code changes in this repo, we ask that you create a branch per Jira Issue. This is a general best practice and promotes smaller/incremental changes that are easily deployed and debugged. Our default branch naming pattern for this is the following:

```
jiraIssueType/AMUPRODUCT-1234/hyphenated-issue-summary
```

To illustrate this, if a simple copy change was raised by the product owner in JIRA. The issueType would be "maintenance" and we will use the example issue key: CAN-1234

### Jira Smart Commits

Our projects are managed in Jira, and we use [smart commits](https://confluence.atlassian.com/fisheye/using-smart-commits-960155400.html) to link actions in GitHub to the relevant ticket in Jira, triggering automations that update ticket statuses.

Smart commits are created by referencing the Jira issue key, such as `JIRA-1234`, in a commit, branch name, or PR description. If needed, multiple smart commits can be referenced at once.

### Branches

For any code changes in this repo, we prefer a single branch per Jira issue. This is a general best practice and promotes incremental changes that are easily deployed and debugged.

Our branch naming pattern is `jiraIssueType/JIRA-1234/hyphenated-issue-summary`.

### Pull Requests

Open a pull request when your changes are ready to merge into staging. Follow the PR template and write a brief description, and add relevant links, including the Jira issue key.

You do not need to fill in the reviewers or assignees. Our CODEOWNERS automation takes care of who will need to review it. An AMU software engineer will review it and handle merging it once it's ready.

---

## Deployment & Releases

Detailed information about how to prepare an app to deploy to K8s is here: (https://amuniversal.atlassian.net/l/c/AV1H0Sbf)

### Reviewers and Supportive information

You do not need to fill in the reviewers or assignees. Our CODEOWNERS automation takes care of who will need to review it. As long as a AMU software engineer reviews it and the other checks pass, we will take care of merging the pull request into staging and production.

### Relevant Links

Jira Release: <https://amuniversal.atlassian.net/projects/AMUPRODUCTJIRAKEY/versions/12711/tab/release-report-all-issues>

### Creating an Official Release

Once a pull request is merged into _main_, it passes all CI checks and passes QA, it will be ready for being released to staging and production.

> The AMU software engineer **must** create a tagged version.

1. Navigate to the [product releases in github](https://github.com/Andrews-McMeel-Universal/AMUPRODUCTJIRAKEY/releases)
2. Click the button for "Draft a New Release" and then click "Auto-generated Release Notes".
   > NOTE: We do not use the `vx.x.x` pattern for version naming. We simply have the semantic release version number like this: `x.x.x`
3. If this is for a staging deployment, check `Set as a pre-release` option and make sure to add `-rc` to the end of the tag name/
4. Click "Publish Release"
