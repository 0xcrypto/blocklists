#!/bin/sh
# Verifies candidate blocklist domains:
#  1) DoH NS lookup -> registered (Status 0 + NS) vs NXDOMAIN (Status 3)
#  2) RDAP lookup   -> registrant org when published
set -u
ROOT="$(cd "$(dirname "$0")" && pwd)"

do_doh() {
  while IFS= read -r d; do
    case "$d" in '') continue ;; '#'*) continue ;; esac
    body=$(curl -s "https://dns.google/resolve?name=$d&type=NS")
    st=$(printf '%s' "$body" | sed -n 's/.*"Status":\([0-9][0-9]*\).*/\1/p')
    has_ns=y
    printf '%s' "$body" | grep -q '"NS"' || has_ns=n
    echo "DOH $d st=$st ns=$has_ns"
  done < "$ROOT/domains-doh.txt"
}

do_rdap() {
  while IFS= read -r d; do
    case "$d" in '') continue ;; '#'*) continue ;; esac
    body=$(curl -sL "https://rdap.org/domain/$d")
    if command -v python3 >/dev/null 2>&1; then
      org=$(printf '%s' "$body" | python3 -c '
import sys, json
try:
    d = json.load(sys.stdin)
except Exception:
    print("PARSE-FAIL"); raise SystemExit
orgs = []
def walk(ent):
    for e in ent or []:
        if "registrant" in e.get("roles", []):
            va = e.get("vcardArray")
            if va and len(va) > 1:
                for item in va[1]:
                    if item and item[0] == "fn":
                        orgs.append(item[3])
        walk(e.get("entities"))
walk(d.get("entities"))
print(" | ".join(orgs) if orgs else "no-registrant")
' 2>/dev/null)
    else
      org="no-python3"
    fi
    echo "RDAP $d $org"
  done < "$ROOT/domains-rdap.txt"
}

case "${1:-all}" in
  doh)  do_doh ;;
  rdap) do_rdap ;;
  all)  do_doh; do_rdap ;;
esac