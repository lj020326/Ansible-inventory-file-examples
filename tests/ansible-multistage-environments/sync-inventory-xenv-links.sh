#!/usr/bin/env bash

## ref: https://unix.stackexchange.com/questions/573047/how-to-get-the-relative-path-between-two-directories
pnrelpath() {
  ## get the relative path between two directories
  set -- "${1%/}/" "${2%/}/" ''               ## '/'-end to avoid mismatch
  while [ "$1" ] && [ "$2" = "${2#"$1"}" ]    ## reduce $1 to shared path
  do  set -- "${1%/?*/}/"  "$2" "../$3"       ## source/.. target ../relpath
  done
  REPLY="${3}${2#"$1"}"                       ## build result
  # unless root chomp trailing '/', replace '' with '.'
  [ "${REPLY#/}" ] && REPLY="${REPLY%/}" || REPLY="${REPLY:-.}"
  echo "${REPLY}"
}

SCRIPT_DIR=$( cd "$( dirname "$0" )" && pwd )
#PROJECT_DIR=$( cd "$SCRIPT_DIR/" && git rev-parse --show-toplevel )
PROJECT_DIR="${PWD}"

#INVENTORY_DIR="${PROJECT_DIR}/inventory"
INVENTORY_DIR="./inventory"

echo "SCRIPT_DIR=${SCRIPT_DIR}"
echo "PROJECT_DIR=${PROJECT_DIR}"
echo "INVENTORY_DIR=${INVENTORY_DIR}"

ENVS="
dev
test
prod
"

IFS=$'\n'
for environment in ${ENVS}
do
  echo "Create symlinks for files in environment [$environment]"
  ENV_DIR="${INVENTORY_DIR}/${environment}"
  echo "ENV_DIR=${ENV_DIR}"
  cd ${ENV_DIR}/

  echo "Remove all existing links in ${ENV_DIR}"
  find . -type l -print -exec rm {} \;

  echo "get the relative path between $PWD and $INVENTORY_DIR directories"
  RELATIVE_PATH=$(pnrelpath "$PWD" "$INVENTORY_DIR")
  echo "RELATIVE_PATH[0]=${RELATIVE_PATH}"

  echo "Create host related links"
  ln -sf ${RELATIVE_PATH}/host_vars ./
  ln -sf ${RELATIVE_PATH}/*.yml ./

  cd group_vars

  echo "get the relative path between $PWD and $INVENTORY_DIR directories"
  RELATIVE_PATH=$(pnrelpath "$PWD" "$INVENTORY_DIR")
  echo "RELATIVE_PATH[1]=${RELATIVE_PATH}"

#  echo "ln -sf ../../group_vars/* ./"
#  ln -sf ../../group_vars/* ./

  echo "ln -sf ${RELATIVE_PATH}/group_vars/* ./"
  ln -sf ${RELATIVE_PATH}/group_vars/* ./
  rm -f all.yml

  ECHO "Create ${PWD}/all dir if does not exist"
  mkdir -p all

  cd all
  echo "get the relative path between $PWD and $INVENTORY_DIR directories"
  RELATIVE_PATH=$(pnrelpath "$PWD" "$INVENTORY_DIR")
  echo "RELATIVE_PATH[2]=${RELATIVE_PATH}"

  ln -sf ${RELATIVE_PATH}/group_vars/all.yml ./000_cross_env_vars.yml

done

echo "creating links for useful project scripts"
cd ${PROJECT_DIR}
