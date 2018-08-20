#!/usr/bin/env bash

set -euo pipefail

readonly PROJECT_PATH=$( cd $(dirname $0) ; cd ../; pwd -P )
readonly SCRIPT_NAME="$(basename $0)"
readonly METHOD="GET"

# Includes
source ${PROJECT_PATH}/s3/common.sh

##
# Print help and exit
# Arguments:
#   $1 int exit code
# Output:
#   string help
##
printUsageAndExitWith() {
  printf "Usage:\n"
  printf "  ${SCRIPT_NAME} [-vi] [-k key] [-s file] [-r region] resource_path\n"
  printf "  ${SCRIPT_NAME} -h\n"
  printf "Example:\n"
  printf "  ${SCRIPT_NAME} -k key -s secret -r eu-central-1 /bucket/file.ext\n"
  printf "Options:\n"
  printf "     --debug\tEnable debugging mode\n"
  printf "  -h,--help\tPrint this help\n"
  printf "  -i,--insecure\tUse http instead of https\n"
  printf "  -k,--key\tAWS Access Key ID. Default to environment variable AWS_ACCESS_KEY_ID\n"
  printf "  -r,--region\tAWS S3 Region. Default to environment variable AWS_DEFAULT_REGION\n"
  printf "  -s,--secret\tFile containing AWS Secret Access Key. If not set, secret will be environment variable AWS_SECRET_ACCESS_KEY\n"
  printf "  -t,--token\tSecurity token for temporary credentials. If not set, token will be environment variable AWS_SECURITY_TOKEN\n"
  printf "  -v,--verbose\tVerbose output\n"
  printf "     --version\tShow version\n"
  exit $1
}

##
# Parse command line and set global variables
# Arguments:
#   $@ command line
# Globals:
#   AWS_ACCESS_KEY_ID     string
#   AWS_SECRET_ACCESS_KEY string
#   AWS_REGION            string
#   AWS_SECURITY_TOKEN    string
#   RESOURCE_PATH         string
#   VERBOSE               bool
#   INSECURE              bool
#   DEBUG                 bool
##
parseCommandLine() {
  # Init globals
  AWS_REGION=${AWS_DEFAULT_REGION:-""}
  AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-""}
  AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-""}
  AWS_SECURITY_TOKEN=${AWS_SECURITY_TOKEN:-""}
  VERBOSE=false
  INSECURE=false
  DEBUG=false

  # Parse options
  local remaining=
  local secretKeyFile=
  while [[ $# > 0 ]]; do
    local key="$1"
    case ${key} in
      --version)       showVersionAndExit;;
      --debug)         DEBUG=true;;
      -h|--help)       printUsageAndExitWith 0;;
      -v|--verbose)    VERBOSE=true;;
      -i|--insecure)   INSECURE=true;;
      -r|--region)     assertArgument $@; AWS_REGION=$2; shift;;
      -k|--key)        assertArgument $@; AWS_ACCESS_KEY_ID=$2; shift;;
      -s|--secret)     assertArgument $@; secretKeyFile=$2; shift;;
      -t|--token)      assertArgument $@; AWS_SECURITY_TOKEN=$2; shift;;
      -*)              err "Unknown option $1"
                       printUsageAndExitWith ${INVALID_USAGE_EXIT_CODE};;
      *)               remaining="${remaining} \"${key}\"";;
    esac
    shift
  done

  # Set the non-parameters back into the positional parameters ($1 $2 ..)
  eval set -- ${remaining}

  # Read secret file if set
  if ! [[ -z "${secretKeyFile}" ]]; then
   AWS_SECRET_ACCESS_KEY=$(processAWSSecretFile "${secretKeyFile}")
  fi

  # Parse arguments
  if [[ $# != 1 ]]; then
    err "You need to specify the resource path to download e.g. /bucket/file.ext"
    printUsageAndExitWith ${INVALID_USAGE_EXIT_CODE}
  fi

  assertResourcePath "$1"
  RESOURCE_PATH="$1"

  if [[ -z "${AWS_REGION}" ]]; then
    err "AWS Region not specified"
    printUsageAndExitWith ${INVALID_USAGE_EXIT_CODE}
  fi
  if [[ -z "${AWS_ACCESS_KEY_ID}" ]]; then
    err "AWS Access Key ID not specified"
    printUsageAndExitWith ${INVALID_USAGE_EXIT_CODE}
  fi
  if [[ -z "${AWS_SECRET_ACCESS_KEY}" ]]; then
    err "AWS Secret Access Key not specified"
    printUsageAndExitWith ${INVALID_USAGE_EXIT_CODE}
  fi

  # Freeze globals
  readonly AWS_REGION
  readonly AWS_ACCESS_KEY_ID
  readonly AWS_SECRET_ACCESS_KEY
  readonly RESOURCE_PATH
  readonly DEBUG
  readonly VERBOSE
  readonly INSECURE
}

##
# Main routine
##
main() {
  checkEnvironment
  parseCommandLine $@
  performRequest
}

main $@
