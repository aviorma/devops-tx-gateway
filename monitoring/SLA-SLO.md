# Enforcing 99.9% SLA for tx-gateway

## SLO/SLA Definition
- **SLA Target**: 99.9% monthly uptime (~43 minutes/month allowable downtime)
- **SLO Example**: P95 latency < 300ms (at least 99% of observed time)

## Alerts
- No traffic served / service down for >5m
- High 5xx rate over 10m
- P95 latency > 300ms over 10m

## Operational Practices
- Canary and progressive rollouts for production releases
- On-call with incident response runbooks
- Root cause analysis after major/breached error budgets
- Use error budgets for feature velocity/operational decisions
