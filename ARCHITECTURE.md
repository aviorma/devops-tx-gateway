# Architecture & Ops – Short Write-Up

## 1. High-level design
- Terraform provisions the GKE clusters (staging + production) so every infrastructure change is tracked in Git. Each environment uses its own tfvars/workspace to keep state clean.
- Helm deploys `tx-gateway`; staging vs production behavior lives in `values-staging.yaml` and `values-production.yaml` so promotion is just applying a new values file.
- CI/CD runs through GitHub Actions: build/test on every push, auto-deploy to staging from `main`, and promote to production only when a release tag is created.

## 2. Scalability & resilience
- Kubernetes HPA (CPU-based) is on by default. For bursty HTTP traffic we enable the nginx metrics exporter + KEDA so scaling decisions follow real request rate.
- Scaling up means increasing replicas, growing node pools via Terraform, or adding more clusters/regions behind a global load balancer.
- Pods are stateless, have readiness/liveness probes, and use PodDisruptionBudgets, so rolling upgrades and zone maintenance stay healthy.

## 3. Security aspects
- Secrets stay in a managed store (e.g., GCP Secret Manager or sealed-secrets) and are injected through Kubernetes secrets—no plaintext secrets in Git.
- Service accounts follow least-privilege: Terraform provisions scoped IAM roles per workload; nothing runs as cluster-admin.
- Network and ingress hardening: NetworkPolicies restrict east-west traffic, ingress is locked to expected CIDRs, and TLS/WAF/rate limiting are enforced at the edge.

## 4. If I had more time
- Break Terraform into reusable modules with automated tests/policy checks.
- Add blue/green or canary deploys plus automated rollback gates.
- Build multi-region clusters with global load balancing to raise SLA targets.
- Expand the security posture: OPA/Kyverno policies, SBOM + vuln scanning in CI, automated secret rotation, and tighter cost guardrails.
