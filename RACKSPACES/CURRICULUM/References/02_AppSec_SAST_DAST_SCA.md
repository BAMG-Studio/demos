# Application Security Testing: SAST, DAST, SCA - Complete Guide

> **Quick Reference:** SAST scans code before running. DAST tests running applications. SCA checks third-party libraries. **You need ALL THREE.**

## The Complete Picture

Think of building an application like building a car:
- **SAST** = Inspecting blueprints before assembly
- **DAST** = Test-driving the finished car
- **SCA** = Checking if parts from suppliers are safe

**You need ALL THREE for comprehensive security.**

---

## Part 1: SAST (Static Application Security Testing)

### What is SAST?

**Definition:** Analyzes source code WITHOUT running it to find vulnerabilities

**Layman's Analogy:** Like having a chef review recipes BEFORE cooking to catch food poisoning risks

### What SAST Does

- Scans for SQL injection, XSS, hardcoded passwords, buffer overflows
- Analyzes code flow (traces data from input to output)
- Provides line-by-line findings with exact locations
- Works on compiled and interpreted languages

### When It Runs

- During development (IDE plugins showing issues as you type)
- On code commit (pre-commit hooks blocking unsafe code)
- In CI/CD pipeline (before build stage gates)
- On scheduled basis (nightly scans of all code)

### SAST Strengths

✅ **Early Detection** - Catches bugs before production (cheapest time to fix)  
✅ **Comprehensive** - Analyzes all code paths (even unused code)  
✅ **Developer-Friendly** - Exact file and line numbers for fixes  
✅ **Required for Compliance** - PCI-DSS, HIPAA, SOX mandates  
✅ **Prevents Common Issues** - SQL injection, XSS, authentication flaws  

### SAST Limitations

❌ **False Positives** - Flags non-vulnerabilities (can overwhelm teams)  
❌ **Can't Find Runtime Issues** - Only sees code, not execution context  
❌ **Language-Specific** - Need different tools for Python, Java, Go, Node  
❌ **Misses Configuration Issues** - Can't detect server misconfigurations  
❌ **Requires Source Code** - Can't analyze compiled binaries  

### Popular SAST Tools

| Tool | Strengths | Cost | Best For |
|------|-----------|------|----------|
| **SonarQube** | Open-source, self-hosted, extensive language support | Free/OSS or Enterprise | Organizations wanting control |
| **Checkmarx** | Enterprise-grade, accurate, integrates SIEM | Enterprise $$$ | Fortune 500 companies |
| **Veracode** | SaaS platform, minimal setup, mobile code analysis | Enterprise $$ | Quick deployment |
| **GitHub CodeQL** | Free for public repos, ML-based, native GitHub integration | Free/Pro/Enterprise | GitHub-native teams |
| **Semgrep** | Fast, customizable rules, open-source | Free/Pro/Enterprise | Teams wanting flexibility |

### Real-World SAST Example

```python
# Vulnerable Code (SAST would flag this)
@app.route('/api/user')
def get_user():
    username = request.args.get('username')
    query = f"SELECT * FROM users WHERE username = '{username}'"  # SQL injection!
    result = db.execute(query)
    return jsonify(result)
```

**SAST Finding:**
```
[CRITICAL] SQL Injection
File: app.py, Line 4
Pattern: String interpolation in SQL query
Risk: Attacker can modify query by providing: ' OR '1'='1
Fix: Use parameterized queries
```

**Secure Version:**
```python
@app.route('/api/user')
def get_user():
    username = request.args.get('username')
    query = "SELECT * FROM users WHERE username = ?"
    result = db.execute(query, (username,))  # Safe - parameter binding
    return jsonify(result)
```

### Interview Example

"I integrated SonarQube into our GitLab CI/CD pipeline. Every PR automatically triggers SAST scanning. Critical vulnerabilities like SQL injection or hardcoded credentials block merge. Developers get inline comments showing exactly what to fix and why. This shift-left approach caught 47 vulnerabilities before production in Q1 alone—preventing potential breaches and expensive remediation."

---

## Part 2: DAST (Dynamic Application Security Testing)

### What is DAST?

**Definition:** Tests running application from outside, like an attacker would

**Layman's Analogy:** Actually eating the finished meal to see if you get sick (as opposed to SAST which inspects the recipe)

### What DAST Does

- Crawls application (finds pages, forms, APIs)
- Sends malicious inputs (SQL injection, XSS, auth bypass)
- Analyzes responses for vulnerabilities
- Simulates real attacker behavior
- Finds runtime configuration issues

### When It Runs

- In staging/test environment (NEVER production!)
- After deployment (runtime testing)
- Scheduled scans (weekly, nightly)
- Before production release (gating criteria)

### DAST Strengths

✅ **Realistic Testing** - Simulates actual attack patterns  
✅ **Language-Agnostic** - Works on any application  
✅ **Finds Runtime Issues** - Auth flaws, session problems, race conditions  
✅ **Low False Positives** - If DAST exploits it, it's definitely real  
✅ **No Source Code Required** - Black-box testing  

### DAST Limitations

❌ **Requires Running Application** - Can't test during development  
❌ **Slow** - Takes hours or days to scan thoroughly  
❌ **Incomplete Coverage** - May miss code paths not crawled  
❌ **Can Break Things** - Aggressive testing might crash app  
❌ **Difficult to Trigger Bugs** - Some vulnerabilities hard to expose  

### Popular DAST Tools

| Tool | Strengths | Cost | Best For |
|------|-----------|------|----------|
| **OWASP ZAP** | Free, open-source, active community | Free | Learning & budget-conscious teams |
| **Burp Suite** | Most capable, industry standard, extensive reporting | Free Community/$599+ Pro | Professional penetration testers |
| **Acunetix** | Automation-friendly, good accuracy | $2500+/year | Enterprise automation |
| **Nessus Web App** | Integrated with vulnerability management, Tenable ecosystem | $2400+/year | Organizations using Tenable |
| **Qualys WAAS** | SaaS platform, compliance reporting, incident response | SaaS pricing | Enterprises wanting SaaS |

### Real-World DAST Example

**Setup:**
```bash
# Start OWASP ZAP in Docker for nightly scanning
docker run -t owasp/zap2docker-stable zap-baseline.py \
  -t https://staging.example.com \
  -r /tmp/report.html
```

**What ZAP Finds:**
```
[MEDIUM] Authentication Bypass
URL: https://staging.example.com/admin
Method: POST
Finding: Changing session cookie allows access to other users' data
Evidence: Modified cookie `sessionid=12345` → `sessionid=99999` 
Result: Accessed another user's account details
Impact: Confidentiality breach
```

### Interview Example

"We use OWASP ZAP nightly in staging. It crawls our web app and APIs, attempting 50+ attack patterns. Last month it discovered an authentication bypass that SAST missed—vulnerability only appeared when specific HTTP headers were sent in a certain order. DAST found what static analysis couldn't. This is why defense-in-depth requires multiple testing layers."

---

## Part 3: SCA (Software Composition Analysis)

### What is SCA?

**Definition:** Scans third-party libraries and dependencies for known vulnerabilities

**Layman's Analogy:** Checking if ingredients you bought have been recalled (similar to food safety recall checks)

### What SCA Does

- Inventories all dependencies (creates Software Bill of Materials)
- Checks against CVE database (Common Vulnerabilities and Exposures)
- Identifies licensing risks (open-source licenses)
- Tracks transitive dependencies (dependencies of dependencies)
- Monitors for zero-days (newly discovered vulnerabilities)

### Why SCA is Critical

Modern applications are **80-90% third-party code**. Examples:
- Node.js app: 500+ npm packages
- Python app: 200+ pip packages
- Java app: 100+ Maven dependencies
- Each has its own dependencies (transitive)

**Famous Example - Log4Shell (December 2021):**
Critical vulnerability in Log4j library used by millions of applications. SCA tools immediately identified which apps were vulnerable. Without SCA, companies would still be trying to find affected systems.

### When It Runs

- During development (IDE plugins warning as you add dependencies)
- On code commit (checking before merge)
- In CI/CD pipeline (build gate)
- Continuously (monitoring for newly discovered vulnerabilities)
- On schedule (weekly/daily rescans for new CVEs)

### SCA Strengths

✅ **Fast** - Just checks versions against databases  
✅ **High Accuracy** - Detects KNOWN vulnerabilities with precision  
✅ **Easy to Fix** - Usually just update the library  
✅ **License Compliance** - Prevents legal/GPL issues  
✅ **Continuous Monitoring** - Alerts on new CVEs for existing dependencies  

### SCA Limitations

❌ **Only Finds Known Vulnerabilities** - Can't detect zero-days  
❌ **Dependency Hell** - Updating one library might break others  
❌ **Transitive Dependencies** - Hard to track dependencies of dependencies  
❌ **False Positives** - May flag vulnerabilities that don't affect your code  
❌ **Version Confusion** - Misidentified versions produce wrong results  

### Popular SCA Tools

| Tool | Strengths | Cost | Best For |
|------|-----------|------|----------|
| **Snyk** | Developer-friendly, excellent integrations, fix guidance | Free/Pro/$$ | Development teams |
| **Dependabot** | GitHub-native, free, automatic PRs | Free (GitHub) | GitHub-native workflows |
| **WhiteSource** | Enterprise-grade, policy enforcement, DevOps integration | Enterprise $$ | Large organizations |
| **Sonatype Nexus** | Repository security, DevOps integration | Enterprise $$ | DevOps/build pipeline |
| **JFrog Xray** | Supply chain security, artifact scanning | Enterprise $$ | Container/artifact security |

### Real-World SCA Example

**Package file (Python):**
```
Flask==2.0.1
Pillow==8.2.0      # Vulnerable version!
requests==2.26.0
```

**SCA Finding:**
```
Pillow 8.2.0 (installed) has vulnerability:
CVE-2021-34552 - Buffer overflow in PIL Image.crop()
Severity: HIGH
Fixed in: Pillow 8.3.2
Recommendation: Update to Pillow==8.3.2
Impact: Dependency update safe, no breaking changes
```

**Automated Fix:**
```
Snyk creates PR:
- Pillow 8.2.0 → 8.3.2
- Includes CVE details
- Links to security advisory
- Runs tests to verify no breakage
```

### Interview Example

"I implemented Snyk across all GitHub repos with automatic daily scanning. When vulnerabilities are discovered in dependencies, Snyk creates PRs showing CVE details, severity, and fixed version. Last month it caught a critical Pillow vulnerability. The PR included all context needed for immediate merge. SCA is essential—85% of application code is third-party libraries. If you don't monitor them, you're flying blind."

---

## Part 4: Comparison - SAST vs DAST vs SCA

| Aspect | SAST | DAST | SCA |
|--------|------|------|-----|
| **What it tests** | Your code | Running app | Third-party libraries |
| **Requires source code** | ✅ Yes | ❌ No | ✅ Yes (manifest files) |
| **When it runs** | Development | After deployment | Anytime |
| **Speed** | Fast (seconds-minutes) | Slow (hours-days) | Very fast (seconds) |
| **False positives** | High (needs tuning) | Medium | Low (database accuracy) |
| **Coverage** | All code paths | Only exercised paths | Known CVEs only |
| **Finds** | Code vulnerabilities | Runtime vulnerabilities | Library vulnerabilities |
| **Examples** | SQL injection, XSS | Auth bypass, session issues | Log4Shell, Heartbleed |
| **Fix method** | Rewrite code | Fix code/config | Update library |
| **SDLC phase** | Pre-commit, Build | Test, Production | Continuous |
| **Required for compliance** | ✅ Yes | ✅ Yes | ✅ Yes |

---

## Part 5: The Complete Strategy

### Integration Architecture

```
SAST → Catches code-level flaws (pre-deployment)
  +
SCA → Catches vulnerable dependencies (continuous)
  +
DAST → Catches runtime issues (post-deployment)
  =
Comprehensive Application Security
```

### SDLC Integration Timeline

```
Developer commits code
         ↓
Pre-commit hooks:
├── SCA: Check new dependencies
├── SAST: Scan code changes
└── License check
         ↓
GitLab/GitHub PR validation:
├── SAST: Full codebase scan
├── SCA: Full dependency scan
├── Container scan: Build artifacts
└── DAST: (optional) API scanning
         ↓
Merge if all pass
         ↓
Build & deploy to staging
         ↓
Nightly DAST full scan
         ↓
DAST results reported
         ↓
Fix issues before production
         ↓
Production deployment
         ↓
Continuous SCA monitoring
```

### Tool Implementation Sequence

**Phase 1 (Week 1-2): Foundation**
- Implement SCA (Snyk/Dependabot) - fastest ROI
- Configure pre-commit hooks
- Set baseline for existing dependencies

**Phase 2 (Week 3-4): Code Analysis**
- Implement SAST (SonarQube/Semgrep)
- Configure IDE plugins
- Establish CI/CD integration

**Phase 3 (Week 5-6): Runtime Testing**
- Implement DAST (OWASP ZAP/Burp)
- Schedule nightly scans
- Create remediation process

**Phase 4 (Ongoing): Optimization**
- Tune false positive rates
- Establish SLAs for findings
- Regular tool evaluation

---

## Part 6: Policy & Enforcement

### Security Gates

**Pre-commit (MUST pass):**
- No hardcoded credentials
- No high-severity SAST findings
- No known vulnerable dependencies

**PR/MR validation (MUST pass):**
- SAST: No new critical vulnerabilities
- SCA: No new vulnerable dependencies
- License check: No prohibited licenses
- Container scan: No critical image vulnerabilities

**Pre-production (STRONGLY recommended):**
- DAST findings reviewed
- Critical/High findings remediated
- Security team sign-off

### Severity Definitions

| Severity | SAST Response | DAST Response | SCA Response |
|----------|---------------|---------------|-------------|
| **Critical** | Blocks merge | Blocks production | Blocks merge |
| **High** | Blocks merge | Immediate remediation | Blocks merge |
| **Medium** | Review required | Scheduled remediation | Auto-update if available |
| **Low** | Logged | Tracked | Auto-update if available |

---

## Interview Answer Template

**Question:** "Tell us about your approach to application security testing in your CI/CD pipeline."

**Answer:**

"In DevSecOps, I implement defense-in-depth with all three testing approaches:

**SAST** runs on code commit catching injection flaws, hardcoded secrets, authentication issues. I use SonarQube with organization-specific rules. The goal is immediate feedback to developers—not blocking, but educating.

**SCA** scans dependencies in parallel identifying vulnerable libraries. I use Snyk with automatic PRs for non-breaking updates. This prevents supply chain vulnerabilities that are increasingly common.

**DAST** runs nightly in staging simulating attacker behavior. I use OWASP ZAP's automated baseline scan, covering 50+ vulnerability patterns.

**Why all three?** SAST might miss runtime auth flaws that DAST catches. SCA catches vulnerable libraries neither SAST nor DAST would identify. Different tools, different strengths—layered defense.

**Implementation example:**
- Pre-commit: Check for secrets, new dependencies
- PR validation: Full SAST + SCA required to merge
- Staging deployment: Nightly DAST scan
- Before production: Review DAST findings, remediate critical/high
- Ongoing: SCA monitors for zero-days

**Metrics:**
- Critical issues caught before production: 47 (Year 1)
- False positive rate: <5% (after tuning)
- Average fix time: 4 hours (for developers)
- Production incidents from code vulnerabilities: 0

This comprehensive approach provides defense-in-depth—catching issues at multiple stages rather than relying on production systems to detect breaches."

---

## Implementation Checklist

- [ ] Evaluate SAST tool options (SonarQube vs Semgrep vs CodeQL)
- [ ] Set up SAST in CI/CD with PR/MR validation
- [ ] Configure IDE plugins for developer feedback
- [ ] Deploy SCA tool (Snyk or Dependabot)
- [ ] Enable automatic PR creation for dependency updates
- [ ] Establish SAST/SCA enforcement policies
- [ ] Select DAST tool (OWASP ZAP for budget, Burp for capability)
- [ ] Schedule automated DAST scans for staging
- [ ] Create remediation runbooks for findings
- [ ] Establish false positive review/tuning process
- [ ] Document policy exceptions and approvals
- [ ] Train developers on interpreting findings
- [ ] Create reporting dashboard for management

---

## Key Takeaways

> **Comprehensive application security requires all three testing types. SAST alone won't find runtime issues. DAST alone misses code flaws. SCA alone allows vulnerable dependencies. Use all three.**

1. SAST catches code-level issues early (cheapest fix timing)
2. SCA monitors third-party libraries (80-90% of modern code)
3. DAST finds runtime issues SAST can't (execution context matters)
4. Integration into CI/CD is critical (testing must be automatic)
5. False positives need management (tuning prevents alert fatigue)
6. Compliance requires all three (PCI-DSS, HIPAA, SOX all mandate)
