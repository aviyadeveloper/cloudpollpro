# CloudPollPro

Educational AWS/Kubernetes infrastructure project for a real-time polling application.

## Architecture

**Infrastructure:**
- **AWS EKS**: Kubernetes cluster (v1.31) across 3 availability zones
- **RDS PostgreSQL**: 16.13 for persistent data storage
- **ECR**: Container registry for application images
- **VPC**: Isolated network with public/private subnets

**Kubernetes Resources:**
- **Redis**: Primary-replica setup for session caching and real-time features
- **External Secrets Operator**: Syncs AWS Secrets Manager to Kubernetes
- **EBS CSI Driver**: Persistent volumes for stateful workloads

## Project Structure

```
infra/
├── tf-bootstrap/     # S3 backend, IAM roles, GitHub OIDC
├── tf-main/          # VPC, EKS, RDS, ECR modules
└── scripts/          # Helper scripts for cluster management

k8s/
├── storage/          # StorageClass definitions
├── redis/            # Redis StatefulSets and services
├── secrets/          # External Secrets configuration
└── README.md         # Kubernetes architecture documentation

services/             # Application microservices (future)
```

## Setup

See [ROADMAP.md](ROADMAP.md) for implementation phases.

**Prerequisites:**
- AWS CLI configured
- kubectl installed
- Terraform >= 1.5

**Bootstrap infrastructure:**
```bash
cd infra/tf-bootstrap
terraform init
terraform apply
```

**Deploy main infrastructure:**
```bash
cd infra/tf-main
terraform init
terraform apply
```

**Configure kubectl:**
```bash
aws eks update-kubeconfig --name cloudpollpro-eks --region eu-west-3
```

## Production Considerations

⚠️ **This is an educational project.** For production use, address these items:

### Security
- [ ] **Redis Authentication**: Enable `requirepass` in ConfigMap and use Kubernetes secrets
- [ ] **Network Policies**: Restrict pod-to-pod communication to necessary paths only
- [ ] **Pod Security Standards**: Enforce restricted PSS on all namespaces
- [ ] **Secrets Encryption**: Enable encryption at rest for Kubernetes secrets (KMS)
- [ ] **RBAC**: Implement least-privilege service accounts for all workloads
- [ ] **VPC Endpoints**: Use AWS PrivateLink for S3, ECR, Secrets Manager to avoid public internet

### High Availability
- [ ] **Multi-AZ Redis**: Deploy Redis across multiple availability zones
- [ ] **RDS Multi-AZ**: Enable automatic failover for database
- [ ] **Pod Disruption Budgets**: Ensure minimum replicas during node maintenance
- [ ] **Cluster Autoscaler**: Automatically scale EKS nodes based on demand
- [ ] **Application Autoscaling**: HPA for application pods based on CPU/memory

### Observability
- [ ] **Prometheus + Grafana**: Metrics collection and dashboards
- [ ] **ELK/Loki Stack**: Centralized logging
- [ ] **Distributed Tracing**: OpenTelemetry or Jaeger for request tracing
- [ ] **CloudWatch Integration**: Export cluster metrics to CloudWatch
- [ ] **Alerting**: PagerDuty/Opsgenie integration for critical alerts

### Reliability
- [ ] **Backup Strategy**: Automated backups for RDS, Redis, and EBS volumes
- [ ] **Disaster Recovery**: Cross-region backup replication
- [ ] **Health Checks**: Proper liveness and readiness probes on all pods
- [ ] **Resource Limits**: CPU/memory limits on all containers to prevent noisy neighbors
- [ ] **Rate Limiting**: API gateway or ingress-level rate limiting

### Cost Optimization
- [ ] **Spot Instances**: Mix of on-demand and spot nodes for non-critical workloads
- [ ] **Right-sizing**: Review instance types based on actual usage
- [ ] **Idle Resource Cleanup**: Automatically delete unused EBS volumes, snapshots
- [ ] **Reserved Instances**: Commit to RIs for predictable baseline capacity

### Compliance & Governance
- [ ] **Audit Logging**: Enable CloudTrail and EKS audit logs
- [ ] **Policy Enforcement**: OPA/Kyverno for admission control policies
- [ ] **Tagging Strategy**: Consistent resource tagging for cost allocation
- [ ] **Image Scanning**: Container vulnerability scanning in CI/CD pipeline

### CI/CD & Testing
- [ ] **Branch Protection**: Require PR reviews and status checks before merging to main
- [ ] **Pre-merge Testing**: Run integration tests in ephemeral test clusters
- [ ] **Infrastructure Testing**: Use `terraform plan` in PRs, require manual approval for applies
- [ ] **Container Scanning**: Scan images for vulnerabilities before pushing to ECR (Trivy, Snyk)
- [ ] **Manifest Validation**: Use `kubeval` or `kubeconform` to validate K8s YAML syntax
- [ ] **Dry-run Deployments**: Test `kubectl apply --dry-run=server` in PRs
- [ ] **Smoke Tests**: Basic health checks after deployment (curl endpoints, check pod status)
- [ ] **Rollback Strategy**: Automated rollback on failed health checks or error rate spikes
- [ ] **Blue-Green or Canary**: Progressive deployment strategies with traffic shifting
- [ ] **Local Testing**: Use `act` (github.com/nektos/act) to test workflows locally before pushing
- [ ] **E2E Tests**: Automated browser tests (Playwright, Cypress) running against staging environment
- [ ] **Performance Testing**: Load tests before production deployment (k6, Locust)

**Current State:** Direct push to main triggers build/deploy. No pre-merge validation.

**Recommended Workflow:**
1. Feature branch with test workflow that runs validation only
2. PR with required checks: linting, unit tests, security scans, dry-run
3. Manual approval gate for production deployments
4. Automated rollback on deployment failure

## Documentation

- [Kubernetes Architecture](k8s/README.md) - Detailed K8s resource documentation with diagrams
- [Terraform Modules](infra/tf-main/README-SETUP.md) - Infrastructure module usage
- [ROADMAP.md](ROADMAP.md) - Implementation phases and progress

## License

Educational project - see institution guidelines.
