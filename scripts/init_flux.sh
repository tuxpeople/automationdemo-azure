#!/usr/bin/env bash
# See: https://stackoverflow.com/a/246128
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
DOMAIN="$(grep reverse_fqdn terraform/main.tf | cut -d'"' -f2 | sed 's/\.$//')"
KEY="~/.ssh/id_rsa_github"
