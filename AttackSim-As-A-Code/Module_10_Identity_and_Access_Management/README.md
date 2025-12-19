# Module 10: Identity & Access Management (IAM) - Master Guide

## 🎯 Module Overview

Identity & Access Management (IAM) is the **foundation of cloud security**. If your IAM is weak, everything else fails. This module teaches you how to implement enterprise-grade identity and access controls in AWS.

## 📚 What You'll Learn

### Core Concepts
- ✅ IAM principles (least privilege, zero trust, separation of duties)
- ✅ Users, groups, roles, and policies (how they work together)
- ✅ Permission boundaries (prevent privilege escalation)
- ✅ Cross-account access (federation, trust relationships)
- ✅ Identity federation (SAML, OIDC, external identity providers)
- ✅ Multi-account strategy (centralized identity management)
- ✅ IAM security best practices (audit, monitoring, hardening)
- ✅ Root account security (lock it down)
- ✅ AWS SSO / Identity Center (modern identity management)

### Hands-On Skills
- Create and manage IAM users, groups, and roles
- Write custom IAM policies (JSON syntax)
- Implement permission boundaries
- Set up cross-account access (roles)
- Configure MFA and temporary credentials
- Implement identity federation
- Audit IAM posture with Access Analyzer
- Monitor and detect suspicious IAM activity
- Create least-privilege policies for applications

### Real-World Scenarios
- Developer access to specific resources only
- Cross-account service deployment
- Third-party vendor access (with restrictions)
- Temporary emergency access
- Contract worker off-boarding
- Detecting and responding to compromised credentials

## 📊 Module Statistics

| Metric | Value |
|--------|-------|
| Expected Completion Time | 2-3 weeks |
| Hands-On Labs | 8-10 |
| Sub-Modules | 7 |
| AWS Services | IAM, STS, SSO, Cognito |
| Difficulty Level | Intermediate |
| Prerequisites | Module 1 (Organizations) |

## 🛣️ Learning Path

### Week 1: IAM Fundamentals
- **Day 1-2:** IAM concepts, principals, policies
- **Day 3-4:** IAM users, groups, roles creation
- **Day 5:** Hands-on lab: Create cross-account role

### Week 2: Advanced IAM
- **Day 1-2:** Permission boundaries, conditions, resource-based policies
- **Day 3-4:** Identity federation, AWS SSO setup
- **Day 5:** Hands-on lab: Federated access from external IdP

### Week 3: Security & Monitoring
- **Day 1-2:** IAM best practices, root account hardening
- **Day 3-4:** IAM Access Analyzer, CloudTrail monitoring
- **Day 5:** Capstone lab: Design least-privilege policy for production app

## 📁 Sub-Modules Included

1. **IAM Fundamentals & Architecture**
   - User management
   - Group management
   - Role management
   - Policy structure and evaluation

2. **Advanced IAM Policies**
   - Custom policy creation
   - Resource-based policies
   - Permission boundaries
   - Condition keys
   - S3 bucket policies
   - Cross-service policies

3. **Cross-Account Access & Delegation**
   - Assume role mechanics
   - Trust relationships
   - Cross-account role creation
   - Service roles and service principals

4. **Identity Federation**
   - SAML 2.0 integration
   - OIDC integration
   - AWS Single Sign-On (SSO/Identity Center)
   - External identity providers (Okta, Azure AD, etc.)

5. **Temporary Credentials & Session Management**
   - AWS STS (Security Token Service)
   - Temporary credentials best practices
   - Session duration limits
   - MFA requirements

6. **IAM Security Best Practices**
   - Root account protection
   - Least privilege principle
   - Regular access reviews
   - Access analyzer
   - Credential rotation

7. **IAM Monitoring & Incident Response**
   - CloudTrail monitoring
   - GuardDuty IAM findings
   - Access logs analysis
   - Detecting and responding to compromised credentials

## 💡 Learning Styles Supported

### For Visual Learners
- Architecture diagrams (principal → policy → resource)
- Policy evaluation flowcharts
- Trust relationship visualizations

### For Hands-On Learners
- Console-based labs (no CLI required)
- Terraform Infrastructure as Code examples
- Real-world scenarios to build and test

### For Interview Preparation
- Common IAM interview questions
- Architecture design scenarios
- Real incident response case studies
- Resume bullet points (8+ per role)

## 🎓 Role-Specific Learning Paths

### Cloud Security Analyst
- Focus: Modules 1, 2, 6, 7
- Time: 2 weeks
- Outcome: Can audit IAM, detect misconfigurations

### IAM Engineer / Identity Architect
- Focus: All modules (deep dive)
- Time: 4 weeks
- Outcome: Can design enterprise IAM architecture

### Cloud Security Engineer (Platform)
- Focus: Modules 1-5
- Time: 2-3 weeks
- Outcome: Can implement IAM for development teams

### CIS O / Security Manager
- Focus: Modules 1, 6, 7 (strategic overview)
- Time: 1 week
- Outcome: Can assess and improve IAM program

## 💰 AWS Cost Estimate

| Service | Monthly Cost | Annual Cost | Notes |
|---------|------------|-----------|-------|
| IAM Users (10) | $0 | $0 | Always free |
| IAM Roles (20) | $0 | $0 | Always free |
| IAM Policies | $0 | $0 | Always free |
| AWS SSO | $0-4 | $0-48 | Free tier, then per user |
| CloudTrail | $2 | $24 | API logging |
| Access Analyzer | $0.02/million | $0.24/million | Per policy checked |
| **TOTAL** | **$2.02** | **$24.24** | **Essentially free!** |

**Note:** IAM itself is free. Costs come from optional services (CloudTrail, SSO, Analyzer).

## ✅ Success Metrics

By the end of this module, you should be able to:

- [ ] Explain IAM policy evaluation logic (principal, action, resource, condition)
- [ ] Design least-privilege policies for applications
- [ ] Set up cross-account access with trust relationships
- [ ] Implement identity federation with external IdP
- [ ] Configure AWS SSO for user provisioning
- [ ] Audit IAM security posture using Access Analyzer
- [ ] Detect and respond to compromised credentials
- [ ] Design IAM strategy for 100+ account organization
- [ ] Write comprehensive IAM policies for any use case
- [ ] Pass IAM security interview questions

## 🚀 Quick Start

**New to this module?** Start here:
1. Read: `01_IAM_Fundamentals_Architecture.md` (1.5 hours)
2. Do: First hands-on lab (users, groups, roles)
3. Read: `02_Advanced_IAM_Policies.md` (2 hours)
4. Do: Policy creation lab

## 📚 Complete File List

```
Module_10_Identity_and_Access_Management/
├── README.md (this file)
├── 01_IAM_Fundamentals_Architecture.md (5,000+ words)
├── 02_Advanced_IAM_Policies.md (6,000+ words)
├── 03_Cross_Account_Access_and_Delegation.md (5,000+ words)
├── 04_Identity_Federation_and_SSO.md (6,000+ words)
├── 05_Temporary_Credentials_and_Sessions.md (4,000+ words)
├── 06_IAM_Security_Best_Practices.md (5,000+ words)
├── 07_IAM_Monitoring_and_Incident_Response.md (5,000+ words)
└── PORTFOLIO_Interview_Resume.md (3,000+ words)
```

**Total Content:** 39,000+ words, 8 comprehensive guides

## 🎯 Key Takeaways

After completing this module:

- ✅ **Know:** How IAM works (policy evaluation, role assumption, federation)
- ✅ **Can Do:** Design and implement IAM for large organizations
- ✅ **Can Test:** Validate IAM security using Access Analyzer
- ✅ **Can Respond:** Handle IAM security incidents
- ✅ **Can Explain:** IAM architecture to security teams and executives

## 🔗 Connection to Other Modules

- **Module 1:** Foundation (multi-account structure)
- **Module 2 (this one):** Access control for that structure
- **Module 11:** Detection of IAM misuse
- **Module 12:** Compliance of IAM policies
- **Module 16:** Responding to IAM incidents

## 📖 How to Use This Module

**Option 1: Self-Study** (Recommended)
- Read guides sequentially
- Complete labs after each section
- Reference guides as needed
- Estimated time: 3 weeks, 10-15 hrs/week

**Option 2: Fast Track** (1 week)
- Focus on Sections 1, 2, 3 only
- Skip federation (Module 4) initially
- Complete core labs
- Return to federation later

**Option 3: Deep Dive** (4 weeks)
- Read everything
- Complete all 10 labs
- Build production IAM architecture
- Create portfolio project

## 🏆 Portfolio Projects

After completing this module, choose one:

1. **Design Enterprise IAM Architecture**
   - Multi-account structure
   - Federated identity
   - Least-privilege policies
   - Documentation

2. **Build Automated IAM Audit Solution**
   - Access Analyzer automation
   - CloudTrail analysis
   - Policy review process
   - Remediation playbooks

3. **Implement Identity Federation**
   - External IdP integration
   - Just-in-time provisioning
   - Temporary credential workflow
   - Documentation

## ❓ FAQ

**Q: Do I need CLI experience?**
A: No! This module uses AWS Console primarily. CLI shown in examples but not required.

**Q: Is IAM actually this important?**
A: YES! 80% of cloud breaches involve compromised credentials. IAM is critical.

**Q: How long until I'm "IAM expert"?**
A: 3-4 weeks of intensive study, then 1-2 years of practical experience to be true expert.

**Q: What's the difference between IAM, SSO, and identity federation?**
A: **IAM** = AWS internal user/role management
**SSO** = Single sign-on (same credentials for multiple apps)
**Federation** = Trust external identity provider
Module 4 explains all three!

## 🚀 Next Steps

1. **Start Now:** Read `01_IAM_Fundamentals_Architecture.md`
2. **This Week:** Complete sections 1-2 with labs
3. **Next Week:** Sections 3-4 (cross-account, federation)
4. **Week 3:** Sections 5-7 (advanced topics)
5. **Capstone:** Build portfolio project

---

**Ready to master IAM? Let's go! 🚀**

This is the foundation of cloud security. Everything else depends on getting this right.
