#!/usr/bin/env bash
# templated by http://qiita.com/blackenedgold/items/c9e60e089974392878c8
usage() {
    cat <<HELP
NAME:
   $0 -- {lock with using s3 file}

SYNOPSIS:
  $0 [-h|--help]
  $0 [--verbose]

DESCRIPTION:
   lock with using s3 file

  -h  --help      Print this help.
      --verbose   Enables verbose mode.

EXAMPLE:
  lock: lock.sh --s3-lock-file s3://lock-bucket/path/deploy-dev
  unlock: lock.sh --s3-lock-file s3://lock-bucket/path/deploy-dev --unlock
HELP
}


wait_and_get_lock() {
  S3_LOCK_FILE=$1
  S3_LOCK_FILE_NAME=$(basename "${S3_LOCK_FILE}")
  EXPIRES=$(date -d '+15 minutes' --utc +'%Y-%m-%dT%H:%M:%SZ')
  touch "/tmp/${S3_LOCK_FILE_NAME}"

  NEXT_WAIT_TIME=0
  CHECK_RETRY_MAX=60

  until [ -z "$(aws s3 ls "${S3_LOCK_FILE}")" ]; do
    echo "Waiting for lockfile to be released..."
    sleep 10
    if [ $NEXT_WAIT_TIME -eq $CHECK_RETRY_MAX ]; then
      echo "Lock wait timeout exceeded. lockfile: ${S3_LOCK_FILE}"
      exit 1
    fi
    (( ++NEXT_WAIT_TIME ))
  done
  aws s3 cp "/tmp/${S3_LOCK_FILE_NAME}" "${S3_LOCK_FILE}" \
    --expires "${EXPIRES}"
}


main() {
    WAIT_MODE=true

    while [ $# -gt 0 ]; do
        case "$1" in
            --help) usage; exit 0;;
            --verbose) set -x; shift;;
            --s3-lock-file) S3_LOCK_FILE=$2; shift 2;;
            --wait) WAIT_MODE=true; shift;; 
            --unlock) WAIT_MODE=false; shift;; 
            --) shift; break;;
            -*)
                OPTIND=1
                while getopts h OPT "$1"; do
                    case "$OPT" in
                        h) usage; exit 0;;
                        *) usage; exit 0;;
                    esac
                done
                shift
                ;;
            *) break;;
        esac
    done

    if [[ ${WAIT_MODE} = true ]]; then
      wait_and_get_lock "${S3_LOCK_FILE}"
    else 
      aws s3 rm "${S3_LOCK_FILE}"
      echo "Lock file ${S3_LOCK_FILE} was removed"
    fi
}

main "$@"

