#!/usr/bin/env bash

# sets $branch, $tag, $rest
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            # -b|--branch) branch="$2" ;;
            # -t|--tag) tag="$2" ;;
            -w|--workflow) workflow="$2" ;;
            *) break ;;
        esac
        shift 2
    done
    rest=("$@")
}

v2api() {
    command curl -sSfL -H "Accept: application/json" -H "Circle-Token: $CIRCLE_TOKEN" "$@"
}

not_finished_workflow_ids() {
    local -r workflow_name="$1"
    local -r api_url="https://circleci.com/api/v1/project/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME?circle-token=$CIRCLE_TOKEN&limit=100"

    curl -X GET -H "Accept: application/json" "$api_url" | \
        jq -r \
        --arg workflow_name "$workflow_name" \
        --arg my_build_num "$CIRCLE_BUILD_NUM" \
        '.[] | select(.status | test(\"running|pending|queued\") and .workflows.workflow_name == $workflow_name) and .build_num != $my_build_num | .workflow_id'
}

parse_args

# e.g. 2020-04-01T10:46:48Z
readonly created_at_of_my_workflow="$(v2api -X GET "https://circleci.com/api/v2/workflow/$CIRCLE_WORKFLOW_ID" | jq -r '.created_at')"

# Lock
while true; do
    ok="ok"

    # repeat until there is no workflow that has not been finished yet except me
    while read workflow_id; do
        ok="ng"
        created_at="$(api_call -X GET "https://circleci.com/api/v2/workflow/$workflow_id" | jq -r '.created_at')"

        if [[ "$(ruby -r 'time' -e 'puts Time.parse(ARGV[0]) < Time.parse(ARGV[1])' "$created_at_of_my_workflow" "$created_at")" == "true" ]]; then
            # cancel myself because this workflow has been *old*
            echo "Canceling myself..."
            exec circleci step halt
        fi
    done < <(not_finished_workflow_ids "$workflow")

    if [[ "$ok" == "ok" ]]; then
        break
    else
        echo "Retrying in 5 seconds..."
        sleep 5
    fi
done

echo "Acquired lock"

exec "${rest[@]}"
