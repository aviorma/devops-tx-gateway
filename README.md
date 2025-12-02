# devops-tx-gateway

A production-ready DevOps infrastructure for a stateless HTTP RPC gateway ("tx-gateway") on Kubernetes, built for **99.9% uptime SLA**, reliability, scalability, and operational excellence.

## Overview

This repository demonstrates a complete DevOps setup for a multi-chain RPC gateway serving blockchain traffic (Ethereum, Arbitrum, Solana) to Web3 customers with:
- **Target SLA**: 99.9% uptime (~43 minutes/month allowable downtime)
- **Performance**: P95 latency < 300ms
- **Scale**: Auto-scaling from 2-30 pods based on CPU and RPS metrics
- **Global**: Multi-zone deployment for high availability

## Directory Structure

```
.
├── infra/                      # Terraform IaC for GKE clusters
│   ├── main.tf                 # GKE cluster and node pool definitions
│   ├── variables.tf            # Configurable variables for environments
│   ├── outputs.tf              # Cluster outputs (endpoint, name, etc.)
│   ├── backend.tf.example      # State backend configuration examples
│   └── terraform.tfvars.example # Example configuration file
├── helm/
│   ├── tx-gateway/             # Helm chart for the service
│   │   ├── templates/          # K8s resource templates
│   │   │   ├── deployment.yaml    # Main deployment with probes
│   │   │   ├── service.yaml       # ClusterIP service with metrics
│   │   │   ├── ingress.yaml       # External ingress with TLS
│   │   │   ├── hpa.yaml           # CPU-based autoscaling
│   │   │   ├── keda-scaledobject.yaml  # RPS-based autoscaling
│   │   │   ├── pdb.yaml           # Pod disruption budget
│   │   │   ├── networkpolicy.yaml # Network security policies
│   │   │   ├── servicemonitor.yaml # Prometheus operator integration
│   │   │   └── configmap.yaml     # nginx configuration
│   │   ├── Chart.yaml          # Helm chart metadata
│   │   └── values.yaml         # Default values
│   └── values/
│       ├── values-staging.yaml    # Staging environment config
│       └── values-production.yaml # Production environment config
├── .github/workflows/
│   └── deploy.yml              # CI/CD pipeline (build, test, deploy)
├── monitoring/
│   ├── prometheus-alerts.yaml  # Alerting rules for SLA monitoring
│   ├── grafana-dashboard.json  # Comprehensive monitoring dashboard
│   └── SLA-SLO.md              # SLA/SLO documentation
├── ARCHITECTURE.md             # Design and operations documentation
├── Dockerfile                  # nginx-based service container
└── README.md                   # This file
```

## Features

### Infrastructure (Terraform)
- ✅ GKE cluster with multi-zone deployment across 3 availability zones
- ✅ Separate staging and production environments
- ✅ Auto-scaling node pools with sensible defaults
- ✅ Proper resource tagging and labeling
- ✅ Backend state management examples (GCS, S3, Terraform Cloud)

### Kubernetes Deployment (Helm)
- ✅ Configurable replicas, resources, and environment variables
- ✅ Liveness and readiness probes for health checks
- ✅ HorizontalPodAutoscaler (CPU-based)
- ✅ KEDA ScaledObject for RPS-based autoscaling (bonus feature)
- ✅ PodDisruptionBudget to maintain availability during updates
- ✅ NetworkPolicy for security (ingress/egress controls)
- ✅ ServiceMonitor for Prometheus Operator integration (bonus)
- ✅ Pod anti-affinity for distributing pods across zones
- ✅ Prometheus metrics exporter sidecar

### CI/CD Pipeline
- ✅ Build and test Docker images on every push/PR
- ✅ Automated deployment to staging from `main` branch
- ✅ Tagged releases automatically deploy to production
- ✅ Uses `helm upgrade --install` for zero-downtime deployments

### Monitoring & Observability
- ✅ Prometheus alerts for service down, high errors, and latency
- ✅ Comprehensive Grafana dashboard with 10 panels:
  - Current RPS, Error Rate, P95 Latency, Active Pods
  - Request rate graphs, HTTP status codes breakdown
  - Latency percentiles (P50, P95, P99)
  - Pod CPU and memory usage
  - SLA compliance tracking (99.9% target)
- ✅ SLA/SLO documentation with operational practices

## Quick Start

### Prerequisites
- `terraform` >= 1.0
- `kubectl` >= 1.28
- `helm` >= 3.12
- GCP project with billing enabled (for real deployment)
- Docker (for local testing)

### 1. Infrastructure Setup (Terraform)

```bash
cd infra

# Initialize Terraform
terraform init

# Review the example configuration
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your GCP project details

# Plan the infrastructure (staging)
terraform plan -var="env=staging"

# Apply (only when ready)
terraform apply -var="env=staging"

# Get cluster credentials
gcloud container clusters get-credentials tx-gateway-team-tx-gateway-staging \
  --region us-central1 --project YOUR_PROJECT_ID
```

For production, use `-var="env=production"` and separate state management.

### 2. Application Deployment (Helm)

```bash
# Validate Helm chart templates (staging)
helm template tx-gateway ./helm/tx-gateway \
  --values ./helm/values/values-staging.yaml

# Validate production config
helm template tx-gateway ./helm/tx-gateway \
  --values ./helm/values/values-production.yaml

# Deploy to staging (local testing)
helm upgrade --install tx-gateway ./helm/tx-gateway \
  --namespace tx-gateway-staging \
  --create-namespace \
  --values ./helm/values/values-staging.yaml \
  --set image.tag=latest

# Deploy to production (when ready)
helm upgrade --install tx-gateway ./helm/tx-gateway \
  --namespace tx-gateway-prod \
  --create-namespace \
  --values ./helm/values/values-production.yaml \
  --set image.tag=v1.0.0
```

### 3. CI/CD Pipeline

The GitHub Actions workflow automatically:
1. **On Pull Requests**: Builds and tests the Docker image
2. **On push to `main`**: Deploys to staging environment
3. **On version tags** (e.g., `v1.0.0`): Deploys to production

Set up required secrets in GitHub:
- `DOCKERHUB_USER` - Docker Hub username (as variable)
- `DOCKERHUB_TOKEN` - Docker Hub access token

### 4. Monitoring Setup

```bash
# Apply Prometheus alerts
kubectl apply -f monitoring/prometheus-alerts.yaml -n monitoring

# Import Grafana dashboard
# Use monitoring/grafana-dashboard.json via Grafana UI
# Dashboard includes: RPS, errors, latency, CPU, memory, SLA tracking
```

## Configuration

### Environment Differences

| Setting | Staging | Production |
|---------|---------|------------|
| Replicas | 2 | 5 |
| Max Replicas (HPA) | 4 | 20 |
| Max Replicas (KEDA) | - | 30 |
| CPU Request | 100m | 200m |
| Memory Request | 128Mi | 256Mi |
| CPU Limit | 300m | 500m |
| Memory Limit | 512Mi | 1Gi |
| PDB minAvailable | 1 | 3 |
| Ingress | Disabled | Enabled with TLS |
| KEDA | Disabled | Enabled |

### Enabling Bonus Features

**KEDA (RPS-based autoscaling)**:
```yaml
# In values-production.yaml
keda:
  enabled: true
  maxReplicas: 30
  threshold: "150"  # Scale at 150 RPS per pod
```

**Network Policies**:
```yaml
networkPolicy:
  enabled: true
```

**ServiceMonitor (Prometheus Operator)**:
```yaml
serviceMonitor:
  enabled: true
  interval: 30s
```

## Testing Locally

```bash
# Build the Docker image
docker build -t tx-gateway:local .

# Run locally
docker run -p 8080:80 tx-gateway:local

# Test the service
curl http://localhost:8080
curl http://localhost:8080/health

# Validate Helm chart
helm lint ./helm/tx-gateway

# Dry-run Helm install
helm install --dry-run --debug tx-gateway ./helm/tx-gateway \
  --values ./helm/values/values-staging.yaml
```

## Production Deployment Checklist

- [ ] Set up Terraform backend for state management (see `infra/backend.tf.example`)
- [ ] Configure separate GCP projects or workspaces for staging/production
- [ ] Apply Terraform for both environments
- [ ] Set up Prometheus and Grafana in the cluster
- [ ] Apply Prometheus alerting rules
- [ ] Import Grafana dashboard
- [ ] Configure PagerDuty/Slack/email for alert notifications
- [ ] Set up GitHub Actions secrets (DOCKERHUB_USER, DOCKERHUB_TOKEN)
- [ ] Configure kubectl contexts for cluster access
- [ ] Set up TLS certificates (cert-manager + Let's Encrypt)
- [ ] Configure DNS for production ingress
- [ ] Enable NetworkPolicy in production
- [ ] Enable ServiceMonitor if using Prometheus Operator
- [ ] Test staging deployment end-to-end
- [ ] Create runbooks for common incidents
- [ ] Set up log aggregation (e.g., Cloud Logging, ELK)

## Operational Notes

### Scaling Strategy
- **HPA** scales based on CPU utilization (default)
- **KEDA** scales based on actual RPS from Prometheus metrics (production only)
- Node auto-scaling handles cluster capacity automatically

### Deployment Strategy
- Rolling updates with PodDisruptionBudget ensure zero downtime
- Staging deployments happen automatically on `main` branch
- Production requires tagged releases for controlled promotion
- Both environments use `helm upgrade --install` for idempotent deployments

### High Availability
- Multi-zone deployment distributes pods across 3 availability zones
- Pod anti-affinity prevents co-location on same nodes
- PDB ensures minimum replicas during maintenance
- Readiness probes prevent traffic to unhealthy pods

### Security
- NetworkPolicy restricts ingress/egress traffic
- Service accounts follow least-privilege principles
- No secrets in Git (use GCP Secret Manager or Sealed Secrets)
- TLS termination at ingress with cert-manager

## Troubleshooting

```bash
# Check pod status
kubectl get pods -n tx-gateway-staging

# View pod logs
kubectl logs -n tx-gateway-staging -l app.kubernetes.io/name=tx-gateway

# Check HPA status
kubectl get hpa -n tx-gateway-staging

# Check KEDA ScaledObject (if enabled)
kubectl get scaledobject -n tx-gateway-prod

# View events
kubectl get events -n tx-gateway-staging --sort-by='.lastTimestamp'

# Test service internally
kubectl port-forward -n tx-gateway-staging svc/tx-gateway 8080:80
curl http://localhost:8080
```

## Architecture & Design

For detailed design decisions, scaling strategies, security considerations, and future improvements, see [ARCHITECTURE.md](ARCHITECTURE.md).

## License

This is a demonstration project for technical assessment purposes.
