# Demo App for Image Scanning

Minimal Flask app to exercise the CI/CD image scan step (Trivy).

## Build & Run Locally
```bash
cd .RACKSPACES/demo-app
docker build -t rackspace-demo:latest .
docker run -p 8080:8080 rackspace-demo:latest
curl http://localhost:8080/health
```
