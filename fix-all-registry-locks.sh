#!/usr/bin/env bash

ACR_NAME="amuappimages201"
CURRENT_TS=$(date -u +%s)
if [[ -n $1 ]]; then
    REPOSITORIES=("$1")
else
    REPOSITORIES=$(az acr repository list --name "${ACR_NAME}" -o tsv)
fi

if [[ -n $2 ]]; then
    RESULTS_COUNT="$2"
else
    RESULTS_COUNT="99999"
fi

for REPOSITORY in ${REPOSITORIES}; do
    echo "Checking manifests for repository ${REPOSITORY}"
    az acr repository update --name "${ACR_NAME}" --repository "${REPOSITORY}" --write-enabled true --delete-enabled true
        while read -r MANIFEST; do
        MANIFEST_DIGEST=$(echo "${MANIFEST}" | awk '{print $1}')

        az acr repository update --name "${ACR_NAME}" --image "${REPOSITORY}@${MANIFEST_DIGEST}" --write-enabled true --delete-enabled true
        while read -r TAG; do
            az acr repository update --name "${ACR_NAME}" --image "${REPOSITORY}:${TAG}" --write-enabled true --delete-enabled true
        done < <(az acr repository show --name "${ACR_NAME}" --image "${REPOSITORY}@${MANIFEST_DIGEST}" --query "tags" -o tsv || true)
    done < <(az acr manifest metadata list --name "${REPOSITORY}" --top "${RESULTS_COUNT}" --registry "${ACR_NAME}" --query "[].{Digest:digest, DeleteEnabled:changeableAttributes.deleteEnabled, LastUpdateTime:lastUpdateTime, Tags:tags}" --orderby time_desc -o tsv || true)
done
