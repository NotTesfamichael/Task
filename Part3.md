# Part 3: Monitoring & Incident Response

## Task 3A: Monitoring Design

### 1. Key Metrics
* **Request Rate (Throughput)**: Total requests per second to the API.
* **Error Rate (Availability)**: Percentage of 5xx HTTP responses.
* **Latency (P95)**: Time taken for 95% of requests to complete.
* **Pod Restart Count**: Frequency of pod failures/restarts.
* **Redis Connection Health**: Rate of connection errors between API and Redis.

### 2. Logging
* **Structure**: JSON-formatted logs.
* **Fields**: `timestamp`, `log_level`, `request_id`, `method`, `path`, `error_message`.

### 3. Alerts
* **Critical**: Error Rate > 5% for 2 mins.
* **Warning**: P95 Latency > 1000ms for 5 mins.
* **Critical**: Pod Restarts > 5 in 10 mins.

---

## Task 3B: Incident Runbook

**Incident**: High API Error Rate (15%) & Latency (5000ms).

### 1. Initial Response
* Acknowledge alert in Slack.
* Check pod status: `kubectl get pods -l app=flask-api`
* Verify if the issue is environment-wide.

### 2. Investigation
* Check logs: `kubectl logs -l app=flask-api --tail=100 | grep -i "redis"`.
* Test connectivity: `kubectl exec -it <pod> -- nc -zv redis 6379`.
* Identify Root Cause: Check if Redis pods are running or if there are network issues between services.

### 3. Remediation
* Restart Redis: `kubectl rollout restart deployment redis`.
* Rollback: `kubectl rollout undo deployment/flask-api`.
* Escalation: Escalate if connectivity is not restored within 10 minutes.

### 4. Post-Incident
* Preserve logs and notify stakeholders.
* Notify Product and Engineering leads.