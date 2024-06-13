#!/usr/bin/env bash
ACR_NAME="amuappimages201"
NAMESPACES=(production)
for NAMESPACE in ${NAMESPACES[@]}; do
    DEPLOYS="puzzle-society-ui"
    # DEPLOYS=$(kubectl get deploy -o jsonpath='{.items[*].metadata.name}' -n "${NAMESPACE}" | tr ' ' '\n')
    for DEPLOY in ${DEPLOYS}; do
        DEPLOYED_TAG=$(kubectl get deployment "${DEPLOY}" -n "${NAMESPACE}" -o=jsonpath='{$.spec.template.spec.containers[:1].image}' | awk -F '/' '{print $2}')
        REPOSITORY=$(echo "${DEPLOYED_TAG}" | awk -F ':' '{print $1}')

        echo "Resetting lock for ${DEPLOY} in ${NAMESPACE} namespace"
        az acr repository update --name "${ACR_NAME}" --image "${DEPLOYED_TAG}" --write-enabled true --delete-enabled true

        MANIFEST_DIGEST=$(az acr repository show --name "${ACR_NAME}" --image "${DEPLOYED_TAG}" --query "digest" -o tsv)
        echo "Resetting lock for ${REPOSITORY}@${MANIFEST_DIGEST}"
        az acr repository update --name "${ACR_NAME}" --image "${REPOSITORY}@${MANIFEST_DIGEST}" --write-enabled true --delete-enabled true

        while read -r TAG; do
            echo "Resetting lock for ${REPOSITORY}:${TAG}"
            az acr repository update --name "${ACR_NAME}" --image "${REPOSITORY}:${TAG}" --write-enabled true --delete-enabled true
        done < <(az acr repository show --name "${ACR_NAME}" --image "${REPOSITORY}@${MANIFEST_DIGEST}" --query "tags" -o tsv)
    done
done