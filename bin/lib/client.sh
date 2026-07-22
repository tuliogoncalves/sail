#!/usr/bin/env bash
# Client scaffolding: copy Sail client files into a project.

copy_client() {
    echo
    if [ -d sail_builders ]; then
        echo -e "${YELLOW}Not copied. sail_builders exists!"
    else
        mkdir -p ./sail_builders
        cp -r --update=none "$SAIL_BIN/../builders/env" ./sail_builders
        cp -r --update=none "$SAIL_BIN/../builders/logs" ./sail_builders
        cp --update=none "$SAIL_BIN/../builders/README" ./sail_builders
        echo -e "\n/sail_builders/logs" >> .gitignore
        echo -e "\n/sail_builders" >> .gitignore
    fi

    echo
    if [ -f .sail.env ]; then
        echo -e "${YELLOW}Not copied. .sail.env exists!"
    else
        cp -a "$SAIL_BIN/../builders/env/.sail.env" ./.sail.env
        echo -e ".sail.env" >> .gitignore
        echo -e "${GREEN}.sail.env copied!"
    fi

    echo
    if [ -f docker-compose-dev.yml ]; then
        echo -e "${YELLOW}Not copied. docker-compose-dev.yml exists!"
    else
        cp "$SAIL_BIN/../builders/docker-compose-dev.yml" .
        echo -e "docker-compose-dev.yml" >> .gitignore
        echo -e "${GREEN}docker-compose-dev.yml copied!"
    fi

    echo
    if [ -f docker-compose-db.yml ]; then
        echo -e "${YELLOW}Not copied. docker-compose-db.yml exists!"
    else
        cp "$SAIL_BIN/../builders/docker-compose-db.yml" .
        echo -e "docker-compose-db.yml" >> .gitignore
        echo -e "${GREEN}docker-compose-db.yml copied!"
    fi

    echo
    if [ -f docker-compose-proxy.yml ]; then
        echo -e "${YELLOW}Not copied. docker-compose-proxy.yml exists!"
    else
        cp "$SAIL_BIN/../builders/docker-compose-proxy.yml" .
        echo -e "docker-compose-proxy.yml" >> .gitignore
        echo -e "${GREEN}docker-compose-proxy.yml copied!"
    fi

    echo
    if [ -f sail_make ]; then
        echo -e "${YELLOW}Not copied. sail_make.sh exists!"
    else
        cp "$SAIL_BIN/../builders/sail_make" .
        echo -e "sail_make" >> .gitignore
        echo -e "${GREEN}sail_make copied!"
    fi

    echo
    cp -r --update=none "$SAIL_BIN/../builders/common" ./sail_builders
    cp -r --update=none "$SAIL_BIN/../builders/scripts" ./sail_builders
    cp -r --update=none "$SAIL_BIN/../builders/supervisor" ./sail_builders
    echo -e "${YELLOW}builders folders copied!"

    echo
    echo -e "${YELLOW}sail client installed!"
}
