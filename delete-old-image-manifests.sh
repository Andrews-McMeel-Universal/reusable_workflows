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
    while read -r MANIFEST; do
        MANIFEST_DIGEST=$(echo "${MANIFEST}" | awk '{print $1}')
        DELETE_ENABLED=$(echo "${MANIFEST}" | awk '{print $2}')
        UPDATED_AT=$(echo "${MANIFEST}" | awk '{print $3}' | cut -d'T' -f1)
        TAG_COUNT=$(echo "${MANIFEST}" | awk '{print $4}')
        TAGS=$(az acr repository show --name "${ACR_NAME}" --image "${REPOSITORY}@${MANIFEST_DIGEST}" --query "tags" -o tsv || true)

        if [[ "${DELETE_ENABLED}" == "False" ]]; then
            echo "Skipping manifest with digest ${MANIFEST_DIGEST} as it is locked"
            continue
        else
            echo "Deleting manifest with digest ${MANIFEST_DIGEST}"
            az acr manifest delete --name "${REPOSITORY}@${MANIFEST_DIGEST}" --registry "${ACR_NAME}" --yes
        fi

        # UPDATED_AT_TS=$(date -j -f "%Y-%m-%d" "${UPDATED_AT}" +%s)
        # DIFF_DAYS=$(( (CURRENT_TS - UPDATED_AT_TS) / (24*60*60) ))
        # if [[ ${DIFF_DAYS} -ge 90 ]]; then
            # echo "Deleting manifest with digest ${MANIFEST_DIGEST} as it is older than 90 days: ${DIFF_DAYS} days old"
        # else
        #     echo "Skipping manifest with digest ${MANIFEST_DIGEST} as it is ${DIFF_DAYS} days old"
        # fi
    done < <(az acr manifest metadata list --name "${REPOSITORY}" --top "${RESULTS_COUNT}" --registry "${ACR_NAME}" --query "[].{Digest:digest, DeleteEnabled:changeableAttributes.deleteEnabled, LastUpdateTime:lastUpdateTime, Tags:tags}" --orderby time_desc -o tsv || true)
done
