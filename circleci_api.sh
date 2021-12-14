#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2021-12-03 12:08:21 +0000 (Fri, 03 Dec 2021)
#
#  https://github.com/harisekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(dirname "${BASH_SOURCE[0]}")"

# shellcheck disable=SC1090
. "$srcdir/lib/utils.sh"

# shellcheck disable=SC1090
. "$srcdir/lib/git.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Queries the CircleCI API

Requires \$CIRCLECI_TOKEN in the environment

Can specify \$CURL_OPTS for options to pass to curl or provide them as arguments


Set up a personal access token here - may need to click 'Enable SSO' next to each token to access corporation organizations with SSO (eg. Azure AAD SSO):

    https://app.circleci.com/settings/user/tokens


API Reference:

    https://circleci.com/docs/api/v2/


Examples:


# Get currently authenticated user:

    ${0##*/} /me | jq .


# Get a project:

    ${0##*/} /project/<vcs>/<user_or_org>/<repo>

    ${0##*/} /project/github/HariSekhon/DevOps-Bash-tools | jq .


# Get a list of pipeline runs for a project:

    ${0##*/} /project/<vcs>/<user_or_org>/<repo>/pipeline

    ${0##*/} /project/github/HariSekhon/DevOps-Bash-tools/pipeline | jq .

    # just the pipelines triggered by you

    ${0##*/} /project/<vcs>/<user_or_org>/<repo>/pipeline/mine

    ${0##*/} /project/github/HariSekhon/DevOps-Bash-tools/pipeline/mine | jq .


# Get environment variables for a project:

    ${0##*/} /project/<vcs>/<user_or_org>/<repo>/envvar

    ${0##*/} /project/github/HariSekhon/DevOps-Bash-tools/envvar | jq .


# Create / replace a project environment variable:

    ${0##*/} /project/<vcs>/<user_or_org>/<repo>/envvar -X POST -d '{\"name\": \"AWS_ACCESS_KEY_ID\", \"value\": \"AKIA...\"}'

    ${0##*/} /project/github/HariSekhon/DevOps-Bash-tools/envvar -X POST -d '{\"name\": \"AWS_ACCESS_KEY_ID\", \"value\": \"AKIA...\"}' | jq .
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="/path [<curl_options>]"

url_base="https://circleci.com/api/v2"

help_usage "$@"

min_args 1 "$@"

curl_api_opts "$@"

export TOKEN="${CIRCLECI_TOKEN:-}"
export CURL_AUTH_HEADER="Circle-Token:"

url_path="${1:-}"
shift

url_path="${url_path//$url_base}"
url_path="${url_path##/}"

# for convenience of straight copying and pasting out of documentation pages

#repo=$(git_repo | sed 's/.*\///')
#
#if [ -n "$user" ]; then
#    url_path="${url_path/:owner/$user}"
#    url_path="${url_path/<owner>/$user}"
#    url_path="${url_path/\{owner\}/$user}"
#    url_path="${url_path/:username/$user}"
#    url_path="${url_path/<username>/$user}"
#    url_path="${url_path/\{username\}/$user}"
#    url_path="${url_path/:user/$user}"
#    url_path="${url_path/<user>/$user}"
#    url_path="${url_path/\{user\}/$user}"
#fi
#url_path="${url_path/:repo/$repo}"
#url_path="${url_path/<repo>/$repo}"
#url_path="${url_path/\{repo\}/$repo}"

"$srcdir/curl_auth.sh" "$url_base/$url_path" "${CURL_OPTS[@]}" "$@"
