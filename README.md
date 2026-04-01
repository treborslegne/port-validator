# port-validator

Bash and PowerShell scripts for validating network port states against expected posture across a list of target hosts.

Written for pre-production validation work — verifying that firewall rules are correctly applied before promoting an environment to production.

---

## The problem it solves

Manually checking port states across 100+ hosts against a defined expected state is slow, error-prone, and doesn't produce a clean record of what was checked. These scripts automate that process and output only violations — ports whose actual state doesn't match what it should be.

If nothing is wrong, there is no output except a final confirmation. The only noise is a problem.

---

## How it works

Three plain-text input files drive the scripts:

| File | Purpose |
|---|---|
| `ips.txt` | One target IP per line |
| `ports_open.txt` | Ports that should be responding |
| `ports_closed.txt` | Ports that should not be responding |

Lines beginning with `#` are treated as comments and ignored, so input files can be annotated without affecting script behavior.

The scripts iterate every IP against every expected-open port and every expected-closed port. Any mismatch between actual state and expected state is flagged as a violation with the IP, port, and expected state clearly labeled.

---

## Output

Clean run — no violations:
```
All ports validated — no issues found.
```

Run with violations found:
```
VIOLATION: 192.168.1.11  port 23  expected CLOSED — is responding
VIOLATION: 192.168.1.12  port 443  expected OPEN — not responding

Validation complete — 2 violation(s) found.
```

---

## Usage

**Bash**
```bash
chmod +x validate_ports.sh
./validate_ports.sh
```

**PowerShell**
```powershell
.\validate_ports.ps1
```

Scripts expect all three input files to be in the same directory.

---

## Environment notes

- Bash version uses `curl` for connection attempts with a 3-second timeout
- PowerShell version uses `Test-NetConnection` (PowerShell 5.1+)
- Intended for use against dev and pre-production environments
- A parallel execution variant is planned — see the open issue

---

## Planned improvements

- [ ] Parallel execution across IPs to reduce runtime on large host lists
- [ ] Optional timestamped output log file
- [ ] Exit code reflects violation count for CI/CD pipeline integration
