#!/bin/bash

# Port Validation Script
# Flags any port whose actual state does not match its expected state
# Output: violations only, plus final issue count

IPS_FILE="ips.txt"
OPEN_PORTS_FILE="ports_open.txt"
CLOSED_PORTS_FILE="ports_closed.txt"
TIMEOUT=3
ISSUES=0

# Returns 0 if port is responding, non-zero if not
port_is_open() {
    curl -s --connect-timeout $TIMEOUT -o /dev/null "http://${1}:${2}" 2>/dev/null
    return $?
}

while IFS= read -r ip; do
    [[ -z "$ip" || "$ip" == \#* ]] && continue

    # Ports that should be open — flag if NOT responding
    while IFS= read -r port; do
        [[ -z "$port" || "$port" == \#* ]] && continue
        port_is_open "$ip" "$port"
        if [ $? -ne 0 ]; then
            echo "VIOLATION: $ip  port $port  expected OPEN — not responding"
            ISSUES=$((ISSUES + 1))
        fi
    done < "$OPEN_PORTS_FILE"

    # Ports that should be closed — flag if IS responding
    while IFS= read -r port; do
        [[ -z "$port" || "$port" == \#* ]] && continue
        port_is_open "$ip" "$port"
        if [ $? -eq 0 ]; then
            echo "VIOLATION: $ip  port $port  expected CLOSED — is responding"
            ISSUES=$((ISSUES + 1))
        fi
    done < "$CLOSED_PORTS_FILE"

done < "$IPS_FILE"

echo ""
if [ $ISSUES -eq 0 ]; then
    echo "All ports validated — no issues found."
else
    echo "Validation complete — $ISSUES violation(s) found."
fi
