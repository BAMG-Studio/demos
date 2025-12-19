# Notes — Docker builder

If you see a warning about `docker-buildx` missing, Docker may fall back to the legacy builder. The demo still works.

Enterprise recommendation:
- install BuildKit/buildx and standardize builds across CI runners
- use pinned base image digests for tighter supply-chain control
