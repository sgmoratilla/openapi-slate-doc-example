#!/bin/bash

set -o errexit #abort if any command fails

OUTPUT_DIR="source/includes/generated-sources"
TEMPLATES_DIR="widdershins/templates"
OPENAPI_DIR="openapi-docs"

process_openapi() {
    FILE=$1

    full_filename="${i##*/}"
    filename="${full_filename%.*}"

    echo "--> Converting ${FILE} into markdown"
    COMMAND="docker run --rm -v ${PWD}:/app -t widdershins \
    --omitHeader \
    --search false \
    --language_tabs 'shell': 'cURL' \
    --summary /app/${FILE} \
    -u /app/${TEMPLATES_DIR} \
    -o /app/${OUTPUT_DIR}/_${filename}.md"
    echo "--> Executing:"
    echo "${COMMAND}"
    eval ${COMMAND}
}

mkdir -p ${OUTPUT_DIR}

openapi_files=`ls ${OPENAPI_DIR}/*.yml`
echo "--> Processing:\n${openapi_files}"
for i in ${openapi_files}
do
    process_openapi $i
done
