# Hands-on — Containers

## Local run
```bash
cd /home/papaert/projects/lab/DEVSECOPS-TS-SCI
./scripts/demo_service.sh local
```

## Docker run
```bash
./scripts/demo_service.sh docker
curl -s http://localhost:8080/health
```

## Security gates
```bash
./scripts/ci_local.sh
```
