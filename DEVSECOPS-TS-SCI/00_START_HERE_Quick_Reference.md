# 00 — Start Here (Quick Reference)

## The goal

Build interview-ready confidence by:
- learning the concepts in plain English
- practicing with runnable demos
- producing artifacts that look like real enterprise work (runbooks, journals, implementation summaries)

## Fast path (90 minutes)

### 1) Bootstrap
```bash
cd /home/papaert/projects/lab/DEVSECOPS-TS-SCI
./scripts/bootstrap.sh
```

### 2) Run the demo service (locally + Docker)
```bash
# Local (virtual environment)
./scripts/demo_service.sh local

# Docker
./scripts/demo_service.sh docker
```

### 3) Run “pipeline gates” locally (CI-style)
```bash
./scripts/ci_local.sh
```

## Interview talk track (60 seconds)

"I build an automated assembly line for software (CI/CD — Continuous Integration / Continuous Delivery). Every change gets built, tested, and scanned for common security mistakes. I package apps into containers (Docker), run them consistently across environments, and deploy them using repeatable, reviewable configuration (Infrastructure as Code). I document every stage so new teammates and auditors can reproduce results." 

## Where to go next

- `COURSE_STRUCTURE_AND_ROADMAP.md` for the learning sequence
- `INTERVIEW_PREP/01_Acronyms_Glossary.md` to de-jargon your answers
- `DEMOS/demo-02-containerized-python-service/` for the runnable app + runbooks
- `DEMOS/demo-01-ci-devsecops-pipeline/` for enterprise pipeline patterns (templates)
