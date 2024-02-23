#!/bin/bash

BUILDARGS=""
  
IFS=' ' read -r -a BUILDARGS_ARRAY <<< " --build-arg APPLICATION_NAME=reusable-test-workflow --build-arg APPLICATION_PORT=3000 --build-arg TEST_BUILD_ARG=test-build-arg"
for VAR in "${BUILDARGS_ARRAY[@]}"; do
    VAR=$(echo $VAR | sed 's|--build-arg||g') # remove prefix and trailing space
    if [ ! -z "$VAR" ]; then
        if [ -z "$BUILDARGS" ]; then
            BUILDARGS="${VAR}" # first argument
        else
            BUILDARGS="${BUILDARGS}\n${VAR}" # append each argument on a new line
        fi
    fi
done

echo "buildArguments=${BUILDARGS}"