# Runbook — Demo 02 (Containerized Python Service)

## Purpose
Provide a small, repeatable service that demonstrates:
- an application you can containerize
- CI-style quality gates
- audit-friendly commands and procedures

## Preconditions
- Linux shell
- Python 3.12+
- Docker (optional)

## Procedure

### Start locally
```bash
cd /home/papaert/projects/lab/DEVSECOPS-TS-SCI
./scripts/bootstrap.sh
./scripts/demo_service.sh local
```

### Validate
```bash
curl -s http://localhost:8080/health
```

### Run CI-style gates locally
```bash
./scripts/ci_local.sh
```

### Run with Docker
```bash
./scripts/demo_service.sh docker
```

## Troubleshooting
- Port already used: change `--port 8080` in `scripts/demo_service.sh`.
- Virtualenv missing: rerun `./scripts/bootstrap.sh`.

## Rollback
- Local: stop the process (Ctrl+C).
- Docker: container runs with `--rm`; stop with Ctrl+C.
