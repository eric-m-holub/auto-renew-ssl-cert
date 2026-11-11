#!/bin/bash
#
# Usage: addtxtrecord.sh -d <domain> <value> [value ...]
#        addtxtrecord.sh --domain <domain> <value> [value ...]
#
#   addtxtrecord.sh -d ericholub.com abc123... def456...
#
# Sets the ACME challenge TXT record for <domain> (and *.<domain>) in Hostinger:
#   ericholub.com            -> _acme-challenge            in zone ericholub.com
#   securitron.ericholub.com -> _acme-challenge.securitron in zone ericholub.com
# All values are written together (certbot needs the apex and wildcard values
# present at the same time).

set -euo pipefail

usage() {
  echo "Usage: $0 -d <domain> <value> [value ...]" >&2
  exit 2
}

DOMAIN=""
VALUES=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    -d|--domain) [ "$#" -ge 2 ] || usage; DOMAIN="$2"; shift 2 ;;
    --domain=*)  DOMAIN="${1#--domain=}"; shift ;;
    -h|--help)   usage ;;
    -*)          echo "Unknown argument: $1" >&2; usage ;;
    *)           VALUES+=("$1"); shift ;;
  esac
done

[ -n "$DOMAIN" ] || usage
[ "${#VALUES[@]}" -ge 1 ] || usage

# Normalise: drop a leading "*." and a trailing "."
DOMAIN="${DOMAIN#\*.}"
DOMAIN="${DOMAIN%.}"

# Zone = last two labels; record name is relative to the zone.
ZONE="$(echo "$DOMAIN" | awk -F. 'NF>=2 {print $(NF-1)"."$NF}')"
[ -n "$ZONE" ] || { echo "Domain looks wrong: $DOMAIN" >&2; exit 2; }

if [ "$DOMAIN" = "$ZONE" ]; then
  NAME="_acme-challenge"
else
  NAME="_acme-challenge.${DOMAIN%.$ZONE}"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API_KEY="$(cat "$SCRIPT_DIR/.key")"

# Build the records array: [{"content":"v1"},{"content":"v2"}]
RECORDS=""
for value in "${VALUES[@]}"; do
  [ -n "$RECORDS" ] && RECORDS+=","
  RECORDS+="{\"content\":\"$value\"}"
done

echo "Setting TXT $NAME (zone $ZONE) to ${#VALUES[@]} value(s)"

curl --fail-with-body --silent --show-error \
  "https://developers.hostinger.com/api/dns/v1/zones/$ZONE" \
  --request PUT \
  --header 'Content-Type: application/json' \
  --header "Authorization: Bearer $API_KEY" \
  --data "{
  \"overwrite\": true,
  \"zone\": [
    {
      \"name\": \"$NAME\",
      \"records\": [$RECORDS],
      \"ttl\": 60,
      \"type\": \"TXT\"
    }
  ]
}"
