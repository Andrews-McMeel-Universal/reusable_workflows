# reusable_workflows

[![Lint workflows](https://github.com/Andrews-McMeel-Universal/reusable_workflows/actions/workflows/workflow-linter.yaml/badge.svg)](https://github.com/Andrews-McMeel-Universal/reusable_workflows/actions/workflows/workflow-linter.yaml)

Welcome to Reusable GitHub Workflows!

Reusable workflows can be called from other workflows to run automated tasks against different applications.
## Available Reusable Workflows


### aks-deploy.yaml

[![Test AKS Deploy](https://github.com/Andrews-McMeel-Universal/reusable_workflows-test/actions/workflows/test-aks-deploy.yaml/badge.svg)](https://github.com/Andrews-McMeel-Universal/reusable_workflows-test/actions/workflows/test-aks-deploy.yaml)

This workflow is used for deploying an application to the Azure Kubernetes Services cluster.

#### Example:
```
jobs:
  deploy:
    name: 'AKS Deployment'
    uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/aks-deploy.yaml@2.2.0
    with:
      repositoryName: ${{ github.event.repository.name }}
      environment: development
      environmentKeyVault: amu-shared
      clusterName: amuaks201
      clusterResourceGroup: AMU_AKS_201
      aksIngressFqdn: amuaks201-production-ingress.centralus.cloudapp.azure.com.
      dnsResourceGroup: AMU_DNS_RG
      chartsPath: ./deployments/charts
      dockerFilePath: .
      dockerImageName: ${{ github.event.repository.name }}
      dockerImageTag: ${{ github.sha }}
      storageAccountName: amucloudapps
      appInfoTableName: DeployedApplications

    secrets:
      azureCredentials: ${{ secrets.AZURE_CREDENTIALS }}
      registryUserName: ${{ secrets.AMUAPPIMAGES201_USERNAME }}
      registryPassword: ${{ secrets.AMUAPPIMAGES201_PASSWORD }}
      registryHostname: ${{ secrets.AMUAPPIMAGES201_HOSTNAME }}
      storageAccountKey: ${{ secrets.AMUCLOUDAPPS_KEY }}
```

### b2c-build-and-deploy.yaml
This workflow can be used to consolidate the workflows in the  https://github.com/Andrews-McMeel-Universal/azure-b2c_auth repository. This repository has it's own workflow due to the complexities involved when building the application along with the multi-product and multi-environment structure.

### purge-cdn.yaml
This workflow purges the cache in an Azure CDN.

### update-addns.yaml
This workflow updates internal Active Directory DNS.  Reads the Azure Storage Table for application information and then updates Active Directory DNS.   This workflow runs on a self hosted runner.

### updateazureapimanagement.yaml
This workflow updates Azure API Management.   Reads the Azure Storage Table for application information and then updates Azure API Management with the swagger.json Open API Spec.  This workflow should only be used for backend services, not a UI as a UI won't have an API. 

### workflow-linter.yaml
This workflow is used exclusively for linting the workflows to make sure there aren't any syntax errors. Please see more details under the testing section.


## Testing

This repository is set up with a linting workflow that runs through all workflows to make sure there are not any syntax errors.

On top of this, the https://github.com/Andrews-McMeel-Universal/reusable_workflows-test repository is used for building out test applications using the workflows to confirm that there aren't any errors during runtime.

## Contributing

Please create feature branches that are then pushed into the main branches after successful tests. Once a new release is created, please update repositories to use the latest workflow.

