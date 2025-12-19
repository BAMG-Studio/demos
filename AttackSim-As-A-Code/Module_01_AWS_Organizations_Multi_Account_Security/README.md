# Module 1: AWS Organizations & Multi-Account Security Architecture

## 🎯 Welcome to Module 1!

This is the foundation module of the AWS DevSecOps/Defensive Cyber Operations course. In this module, you'll learn how to architect a secure, scalable, multi-account AWS environment from the ground up.

---

## 📚 What's in This Module?

### 1. **PRESENTATION: AWS Organizations Foundation** (8,400+ words)
   **Start here** - Comprehensive theoretical foundation covering:
   - What is AWS Organizations and why it matters
   - Management accounts vs. Member accounts
   - Organizational Units (OUs) and hierarchy
   - Service Control Policies (SCPs) - your organizational firewall
   - How SCPs prevent attacks and breaches
   - Multi-account architecture design patterns
   - Cost analysis and ROI calculation
   
   **Time:** 60-90 minutes | **Difficulty:** Beginner-Intermediate

### 2. **HANDS-ON LAB: Building Your AWS Organization** (7,200+ words)
   **Get hands-on** - Step-by-step implementation guide:
   - Step 1: Enable AWS Organizations
   - Step 2: Design OU hierarchy
   - Step 3: Create 6 member accounts
   - Step 4: Implement 3 different SCPs
   - Step 5: Test SCP enforcement
   - Step 6: Set up centralized logging
   - Step 7: Document your architecture
   - Step 8: Real-world threat scenarios
   
   **Time:** 3-4 hours | **Difficulty:** Intermediate | **Hands-On:** YES

### 3. **REAL-WORLD CASE STUDY: TechStartup Inc.** (6,500+ words)
   **Learn from others** - Enterprise implementation story:
   - The security crisis that triggered restructuring
   - 6-week implementation plan
   - SCP deployment and testing
   - Results: 100% incident prevention, 99.8% SLA improvement
   - Lessons learned and best practices
   
   **Time:** 45 minutes | **Difficulty:** Beginner-Intermediate

### 4. **SCP TEMPLATES & QUICK REFERENCE** (5,800+ words)
   **Reference guide** - Ready-to-use security policies:
   - 6 production-ready SCP templates
   - When to use each template
   - Common mistakes and fixes
   - Testing checklist
   - Best practices and decision tree
   
   **Time:** 30 minutes (reference) | **Difficulty:** Intermediate

### 5. **MODULE INDEX & PLANNING GUIDE** (This file)
   **Navigate and plan** - Study paths and assessment:
   - 3 recommended study approaches (4-12 hours)
   - 15-question self-assessment quiz
   - Portfolio building guide
   - Knowledge checklist
   - Connections to other modules
   
   **Time:** Variable | **Difficulty:** Varies

---

## ⚡ Quick Start (Choose Your Path)

### 🏃 Fast Track (4 hours total)
For experienced AWS users who want to move quickly:
1. Read PRESENTATION (30 min) - sections 1.2-2.2 only
2. Do HANDS-ON LAB (3 hours) - Steps 1-5 only
3. Scan QUICK REFERENCE (15 min) - bookmark for later

**→ Then proceed to Module 2**

### 📖 Standard Track (8 hours total)
For AWS professionals learning DevSecOps:
1. Read PRESENTATION (1.5 hours) - all sections
2. Read QUICK REFERENCE (30 min) - understand SCP templates
3. Do HANDS-ON LAB (3 hours) - all steps
4. Read CASE STUDY (45 min) - learn from TechStartup
5. Complete QUIZ (1 hour) - self-assess

**→ Then proceed to Module 2**

### 🎓 Deep Dive (12+ hours total)
For security engineers and enterprise architects:
1. Read PRESENTATION thoroughly (2 hours) - take notes
2. Read CASE STUDY (1 hour)
3. Read QUICK REFERENCE (1 hour)
4. Do HANDS-ON LAB (4 hours) - test every scenario
5. Implement in your own AWS account (2+ hours)
6. Complete QUIZ and attacks scenarios (2 hours)

**→ Then proceed to Module 2 with advanced knowledge**

---

## 🎯 Learning Outcomes

By the end of this module, you will:

✅ **Understand**
- Why multi-account AWS architecture is a security best practice
- How AWS Organizations enable centralized governance
- How Service Control Policies prevent attacks
- The difference between Detective and Preventive controls

✅ **Design**
- A secure multi-account AWS organization structure
- An appropriate OU hierarchy for your organization
- SCP policies that protect your environment
- A centralized logging and monitoring strategy

✅ **Implement**
- Create an AWS Organization with All Features enabled
- Create OUs and organize accounts
- Create and attach SCPs to different organizational units
- Set up centralized CloudTrail logging
- Test SCP enforcement

✅ **Defend**
- Prevent attackers from disabling security services
- Prevent expensive accidental resource creation
- Protect production data from unauthorized deletion
- Isolate development from production
- Contain breach impact through account segregation

---

## 🛠️ What You Need

### Required
- AWS Account with Organization/Management account access
- AWS CLI v2 installed and configured
- Basic AWS knowledge (IAM, services, regions)
- Text editor (VS Code, Notepad, etc.)
- 4-12 hours of learning time

### Optional
- AWS credentials configured locally
- Spreadsheet software (Excel, Google Sheets)
- Diagramming tool (Lucidchart, Draw.io, etc.)
- Second AWS account for testing (free tier eligible)

---

## 📋 Module Files Explained

```
Module_01_AWS_Organizations_Multi_Account_Security/
│
├── 01_PRESENTATION_AWS_Organizations_Foundation.md
│   └── Read FIRST - Theory and concepts
│
├── 02_DEMO_Hands_On_Lab.md
│   └── Read SECOND - Do the hands-on lab
│
├── 03_CASE_STUDY_TechStartup.md
│   └── Read THIRD - Learn from real example
│
├── 04_SCP_Templates_Quick_Reference.md
│   └── Reference while implementing - Reusable templates
│
├── 05_MODULE_INDEX_Planning_Guide.md
│   └── This file - Navigation and study plans
│
├── README.md
│   └── You are here!
│
└── (Coming Soon)
    ├── QUIZ_Assessment.md - Self-assessment questions
    └── ATTACK_SCENARIOS.md - Real threat simulations
```

---

## ✅ Pre-Module Checklist

Before starting, verify you have:

- [ ] AWS Account (preferably unused/free tier eligible)
- [ ] AWS CLI installed (`aws --version`)
- [ ] AWS credentials configured (`aws configure`)
- [ ] 4+ hours uninterrupted learning time blocked
- [ ] Quiet place to focus
- [ ] Notebook for taking notes
- [ ] Text editor open for code

---

## 🚀 Getting Started

### Step 1: Choose Your Learning Path
- **Fast Track?** → Go to Hands-On Lab (Step 2 below)
- **Standard Track?** → Go to Presentation (Step 2 below)
- **Deep Dive?** → Go to Presentation (Step 2 below)

### Step 2: Read the Presentation
Open `01_PRESENTATION_AWS_Organizations_Foundation.md` and read through it. This gives you the context for everything else.

### Step 3: Do the Hands-On Lab
Open `02_DEMO_Hands_On_Lab.md` and follow the step-by-step instructions. Actually do it - don't just read it!

### Step 4: Learn from the Case Study
Open `03_CASE_STUDY_TechStartup.md` and see how a real organization implemented this.

### Step 5: Reference the Templates
Bookmark `04_SCP_Templates_Quick_Reference.md` for when you need SCP examples.

### Step 6: Assess Your Knowledge
Complete the quiz in `05_MODULE_INDEX_Planning_Guide.md` to check your understanding.

---

## 💡 Key Concepts You'll Learn

### AWS Organizations
A service that lets you create and manage multiple AWS accounts within a centralized organization, apply policies across accounts, and aggregate billing.

**Why it matters:** Separates security domains, prevents blast radius, enables compliance.

### Organizational Units (OUs)
Logical containers for grouping accounts, allowing different policies per group.

**Why it matters:** Enables fine-grained control - strict policies for production, relaxed for development.

### Service Control Policies (SCPs)
JSON policies that define the maximum permissions available to accounts/OUs. Even admins can't bypass SCPs.

**Why it matters:** Prevents critical mistakes - attacker can't delete CloudTrail, developer can't expose data.

### Multi-Account Architecture
Separating environments (prod, dev, security, sandbox) into different AWS accounts.

**Why it matters:** Blast radius reduction, compliance, cost control, team autonomy.

---

## 🎓 How to Use This Module

### For Learning
1. **Read** the presentation to understand concepts
2. **Watch** the demo to see how it's done
3. **Study** the case study to see real examples
4. **Reference** the templates when implementing

### For Implementation
1. **Follow** the hands-on lab step-by-step
2. **Use** the SCP templates as starting points
3. **Test** everything before going to production
4. **Document** your decisions for future reference

### For Portfolio Building
1. **Screenshot** your organization structure
2. **Save** your SCP policies
3. **Collect** cost analysis
4. **Write** a summary of what you learned
5. **Prepare** to discuss this in interviews

---

## 🔗 Module Connections

### Prerequisites (should know before starting)
- Basic AWS console navigation
- Understanding of AWS regions and availability zones
- Basic IAM concepts (users, roles, policies)
- Understanding of what a VPC is

**If unsure:** Read AWS Fundamentals first, or start with AWS Academy free course

### Next Module (after completing)
**Module 2: Identity & Access Management (IAM)**
- Building on this organization, learn to manage users and permissions
- How to delegate access across accounts
- Best practices for credential management

---

## 📊 Time Investment & Return

| Investment | Hours | ROI |
|-----------|-------|-----|
| Study time | 4-12 | Foundational architecture knowledge |
| Hands-on implementation | 3-4 | Functional multi-account AWS environment |
| Portfolio projects | 2-4 | Resume-worthy accomplishment |
| **Total** | **9-20** | **Enterprise-grade security architecture** |

**Resume impact:** ⭐⭐⭐⭐⭐ (Very high - employers love this)

---

## ⚠️ Important Notes

### AWS Costs
- AWS Organizations itself: **FREE**
- CloudTrail (logging): ~$5-20/month
- Additional accounts: Pay only for resources used
- **Estimated monthly cost:** $100-200 for full implementation
- **Cost control through this module:** Prevented $50K+ loss (SCP benefit)

### Accounts
- You need ONE management account (you probably have this)
- You'll create 4-6 member accounts (can be in free tier)
- Member accounts can be deleted later if needed

### Time Commitment
- **Minimum:** 4 hours (fast track)
- **Recommended:** 8 hours (standard track)
- **Comprehensive:** 12+ hours (deep dive)

---

## ❓ FAQ

**Q: Do I need an AWS account to do this?**  
A: Yes, but you can use the free tier. Organizations itself is free. Create test accounts as needed.

**Q: Can I do this alone or do I need a team?**  
A: You can do this alone. In real companies, you'd collaborate, but for learning, solo is fine.

**Q: What if I make a mistake?**  
A: SCPs are the guard rails! Mistakes are prevented or easy to undo. Don't worry.

**Q: How long does this stay relevant?**  
A: AWS Organizations has been stable for 5+ years. This knowledge is long-lived.

**Q: Will this help me get a job?**  
A: Yes! Enterprise multi-account architecture is a job requirement for DevSecOps/cloud security roles.

**Q: Can I delete my organization if I don't like it?**  
A: Yes, but it takes 30 days to disable. For learning, just leave it or delete accounts one by one.

---

## 🏆 Success Criteria

You've successfully completed this module when:

- [ ] Can explain AWS Organizations to a non-technical person
- [ ] Can design a multi-account structure for a company
- [ ] Can create OUs and accounts in your AWS account
- [ ] Can create and attach SCPs
- [ ] Can test that SCPs work
- [ ] Can explain why this matters for security
- [ ] Scored 70%+ on the self-assessment quiz
- [ ] Created portfolio-ready documentation

---

## 📞 Getting Help

### If you get stuck:
1. **Reread** the relevant section
2. **Check** the case study for examples
3. **Reference** the quick guide for templates
4. **Read** AWS documentation (links provided)
5. **Check** CloudTrail logs for error messages

### Common issues:
- **Can't create organization?** → Check prerequisites
- **SCP not blocking action?** → Verify attachment and syntax
- **High costs?** → Check for running instances in expensive regions
- **CloudTrail not logging?** → Verify trail creation and S3 permissions

---

## 🚀 Ready to Start?

### Next Steps:

1. **Choose your learning path** (Fast/Standard/Deep Dive)
2. **Open the presentation** (01_PRESENTATION_*.md)
3. **Read for 30 minutes** to understand concepts
4. **Open the hands-on lab** (02_DEMO_*.md)
5. **Follow the steps** exactly as written
6. **Test everything** before considering complete
7. **Take screenshots** for your portfolio
8. **Review the case study** to see it all in context

---

## 📈 Course Progression

**You are here:** Module 1 - AWS Organizations (Foundation)

```
Module 1: AWS Organizations ← YOU ARE HERE
    ↓
Module 2: Identity & Access Management (IAM)
    ↓
Module 3: Threat Detection & Monitoring (GuardDuty, CloudTrail)
    ↓
Module 4: Configuration & Compliance (Config, Security Hub)
    ↓
Module 5: Data Protection & Encryption (KMS, Secrets Manager)
    ↓
Module 6: Application Security & WAF
    ↓
Module 7: Attack Simulation-As-A-Code (Purple Team)
    ↓
Module 8: Incident Response & Automation (Capstone)
```

---

## 📝 Quick Links

- [AWS Organizations Documentation](https://docs.aws.amazon.com/organizations/)
- [Service Control Policies](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html)
- [AWS Security Best Practices](https://aws.amazon.com/architecture/security-identity-compliance/)
- [Prowler - AWS Security Tool](https://prowler.pro/)

---

## ✨ Final Thoughts

This module teaches you how to build the **foundation** of enterprise AWS security. Everything you learn here - organizational structure, policy-based controls, centralized logging - will apply to every module that follows.

It might seem like just "account management," but it's actually **the most important module** because without it, you have no security. With it, you have layered, preventive security that catches mistakes before they happen.

**Your goal:** Learn this deeply so you can architect it confidently in production.

---

**Module Status:** 🟢 READY TO START  
**Estimated Completion:** 4-12 hours  
**Next Module:** Identity & Access Management (IAM)  
**Portfolio Value:** ⭐⭐⭐⭐⭐ Very High

---

**Ready to begin? Open `01_PRESENTATION_AWS_Organizations_Foundation.md` and let's get started!** 🚀

