#!/bin/bash

set -o errexit #abort if any command fails

OUTPUT_DIR="source/includes/generated-sources"
TEMPLATES_DIR="openapi-generator-templates"
OPENAPI_DIR="openapi-docs"

MARKDOWN_API_DIR=${OUTPUT_DIR}/Apis
MARKDOWN_MODELS_DIR=${OUTPUT_DIR}/Models

process_openapi() {
    FILE=$1

    echo "--> Converting ${FILE} into markdown"
    COMMAND="docker run --rm -v ${PWD}:/local openapitools/openapi-generator-cli generate
    -i /local/${FILE}
    -g markdown 
    -t /local/${TEMPLATES_DIR}
    -o /local/${OUTPUT_DIR}"
    echo "--> Executing:"
    echo "${COMMAND}"
    ${COMMAND}
}

compact_models_markdown() {
    COMPACT=$1
    OUTPUT_FILE=${OUTPUT_DIR}/_${COMPACT}-model.md
    echo "--> Joining all markdowns into one single file ${OUTPUT_FILE}"
    cat ${MARKDOWN_MODELS_DIR}/*.md > ${OUTPUT_FILE}
    rm ${MARKDOWN_MODELS_DIR}/*.md
}

rename_api_markdown() {
    echo "--> Renaming all API markdowns"
    for i in `ls ${MARKDOWN_API_DIR}/*.md`
    do
        full_filename="${i##*/}"
        filename="${full_filename%Api.*}"

        new_filename=`echo $filename |tr '[:upper:]' '[:lower:]'`
        new_fullname="${OUTPUT_DIR}/_${new_filename}-api.md"
        echo "--> Renaming ${i} into ${new_fullname}"
        mv $i ${new_fullname}
    done
}

openapi_files=`ls ${OPENAPI_DIR}/*.yml`
echo "--> Processing:\n${openapi_files}"
for i in ${openapi_files}
do
    full_filename="${i##*/}"
    extension="${full_filename##*.}"
    filename="${full_filename%.*}"

    process_openapi $i
    compact_models_markdown $filename
done

rename_api_markdown
rmdir ${MARKDOWN_API_DIR}
rmdir ${MARKDOWN_MODELS_DIR}
