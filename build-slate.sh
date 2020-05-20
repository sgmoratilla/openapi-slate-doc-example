#!/bin/sh

build_slate() {
    echo "--> Building Slate"
    COMMAND="docker run --rm -v ${PWD}:/app -t middleman \
    build \
    --clean \
    --verbose"
    echo "--> Executing:"
    echo "${COMMAND}"
    eval ${COMMAND}
}

bundle exec middleman build --clean
#build_slate
