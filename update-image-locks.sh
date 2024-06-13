#!/usr/bin/env bash

ACR_NAME="amuappimages201"

if [[ -n $2 ]]; then
  NAMESPACES=($2)
else
  NAMESPACES=(development staging production)
fi

for NAMESPACE in "${NAMESPACES[@]}"; do
  if [[ -n $1 ]]; then
    DEPLOYMENTS="$1"
  else
    DEPLOYMENTS=$(kubectl get deploy -n "${NAMESPACE}" -o=jsonpath='{$.items[*].metadata.name}')
  fi
  for DEPLOY in ${DEPLOYMENTS}; do
    FULL_IMAGE_TAG=$(kubectl get deploy -n "${NAMESPACE}" "${DEPLOY}" -o=jsonpath='{$.spec.template.spec.containers[:1].image}')
    DEPLOYMENT_REPOSITORY=$(echo "${FULL_IMAGE_TAG}" | cut -d'/' -f2 | awk -F ':' '{print $1}')
    IMAGE_TAG=$(echo "${FULL_IMAGE_TAG}" | awk -F ':' '{print $2}')
    
    if [[ "${FULL_IMAGE_TAG}" == "${ACR_NAME}.azurecr.io"* ]]; then
      echo "Updating image lock for ${DEPLOYMENT_REPOSITORY} in namespace ${NAMESPACE}: ${FULL_IMAGE_TAG}"
      az acr repository update --name "${ACR_NAME}" --image "${DEPLOYMENT_REPOSITORY}:${IMAGE_TAG}" --write-enabled true --delete-enabled true

      IMAGE_MANIFEST=$(az acr repository show --name "${ACR_NAME}" --image "${DEPLOYMENT_REPOSITORY}:${IMAGE_TAG}" --query "digest" -o tsv)
      echo "Updating image lock for ${DEPLOYMENT_REPOSITORY} in namespace ${NAMESPACE}: ${FULL_IMAGE_TAG}"
      az acr repository update --name "${ACR_NAME}" --image "${DEPLOYMENT_REPOSITORY}@${IMAGE_MANIFEST}" --write-enabled true --delete-enabled false
    fi
  done
done