# Demo 02 — Containerized Python Service (DevSecOps-ready)

## What this demonstrates
- A small API service with a health endpoint
- Unit tests
- Linting (Ruff)
- Basic security checks (Bandit + pip-audit)
- Docker image build/run

## Quick start

### Local
```bash
cd /home/papaert/projects/lab/DEVSECOPS-TS-SCI
./scripts/bootstrap.sh
./scripts/demo_service.sh local

# in another terminal
curl -s http://localhost:8080/health
```

### Docker
```bash
cd /home/papaert/projects/lab/DEVSECOPS-TS-SCI
./scripts/demo_service.sh docker

curl -s http://localhost:8080/health
```

### CI-style gates (local)
```bash
cd /home/papaert/projects/lab/DEVSECOPS-TS-SCI
./scripts/ci_local.sh
```

## Key interview mapping
- CI/CD: tests and automated gates
- Containers: consistent runtime environment
- Linux: bash scripts for repeatable operations
- Documentation: runbook + implementation summary
