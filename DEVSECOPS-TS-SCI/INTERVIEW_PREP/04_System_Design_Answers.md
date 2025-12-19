# System design answers (plain English)

## Design: enterprise pipeline platform (hundreds of apps)
- Provide a “golden pipeline” template (one standard workflow)
- Allow app teams to supply only a few inputs (build command, test command, image name)
- Enforce consistent security gates (SAST/SCA/IaC scan, image scan)
- Centralize artifact storage and logging
- Require approvals for production + immutable releases

## Design: Kubernetes deployment model
- Namespace per environment
- RBAC (Role-Based Access Control) per team
- GitOps controller (Argo CD/Flux) to sync desired state from Git
- Observability baseline (metrics, logs, alerts)
