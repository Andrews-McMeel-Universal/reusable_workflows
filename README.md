# reusable_workflows
Reusabe GitHub Workflows

## Summary

Reusable workflows can be called from other workflows to deploy applications to Azure Kubernetes.   There are currently 3 workflows:


### aks-deploy.yaml
The deployment workflow.   This must be ran before other workflows.   This workflow checks the code out, parses the charts.yaml and values.yaml in the application's helm charts for 
information about the application.   Reads the specified Azure KeyVaults for secrets and build arguments for the application.  Creates public dns records for the application. Creates any K8s secrets or Configmaps specified for the application.  Builds docker image for the application.   Pushes the docker image to Azure's container repository.   Then bakes the application's helm charts, and then deploys the application to Azure Kubernetes.   Upon a successful deployment, the workflow records the deployment information in Azure Storage Tables for use by subsequent workflows.

#### Example:
```
jobs:
  deploy:
    name: AKS Deployment
    uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/aks-deploy.yaml@x.x.x
    with:
      environment: development
      environmentKeyVault: amu-shared
      environmentIngress: true|false # OPTIONAL, defaults to false
      webAuthentication: true|false # OPTIONAL, defaults to false
    secrets:
      azureCredentials: ${{ secrets.AZURE_CREDENTIALS }}
      registryUserName: ${{ secrets.AMUAPPIMAGES201_USERNAME }}
      registryPassword: ${{ secrets.AMUAPPIMAGES201_PASSWORD }}
      registryHostname: ${{ secrets.AMUAPPIMAGES201_HOSTNAME }}
      storageAccountKey: ${{ secrets.AMUCLOUDAPPS_KEY }}
```

### update-addns.yaml
Updates internal Active Directory DNS.  Reads the Azure Storage Table for application information and then updates Active Directory DNS.   This workflow runs on a self hosted runner.

### updateazureapimanagement.yaml
Updates Azure API Management.   Reads the Azure Storage Table for application information and then updates Azure API Management with the swagger.json Open API Spec.  This workflow should only be used for backend services, not a UI as a UI won't have an API. 

### Contributing

Also release any workflow changes as a new release as changes may break existing workflows.

#### Using
You can call a reusable workflow with the "uses:" prefix in the calling workflow.  

Example:
uses: Andrews-McMeel-Universal/reusable_workflows/.github/workflows/aks-deploy.yaml@1.0


