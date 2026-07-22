#!/usr/bin/env bash
# Image builders: build Docker images and copy builder Dockerfiles into projects.

builder() {
    if [ -f "$PWD/sail_builders/${DOCKERFILE}" ]; then
        cd "$PWD/sail_builders"
    else
        cd "$SAIL_BIN/../"
        define_environment

        cd "$SAIL_BIN/../builders"

        if [ ! -f "${DOCKERFILE}" ]; then
            echo
            echo "$DOCKERFILE not exists in builder folder of sail"
            echo
            echo "You must define a valid Dockerfile to build as parameter"
            echo
            exit 1
        fi
    fi

    docker buildx build --tag "$TAG" \
             --cache-from "$TAG" \
             --build-arg WWWGROUP="$WWWGROUP" \
             -f "$DOCKERFILE" \
             . "$@"

    cd "$PWD"

    exit 0
}

copy_builder() {
    echo
    if [ ! -d sail_builders ]; then
        echo -e "${GREEN}Not copied. sail_client not exists!"
    else
        cp -r --update=none "$SAIL_BIN/../builders/common" ./sail_builders
        cp -r --update=none "$SAIL_BIN/../builders/scripts" ./sail_builders
        cp -r --update=none "$SAIL_BIN/../builders/supervisor" ./sail_builders
        cp --update=none "$SAIL_BIN/../builders/${DOCKERFILE}" "./sail_builders/${DOCKERFILE}"
        echo -e "${GREEN} ${DOCKERFILE} builder copied!"
    fi

    echo

    cd "$PWD"

    exit 0
}

cmd_list_builders() {
    cd "$SAIL_BIN/../builders"
    ls -1 Dockerfile_*
    cd "$PWD"

    exit 0
}

cmd_make() {
    shift 2
    builder "$@"
}

cmd_copy_builder() {
    copy_builder "$@"
}
