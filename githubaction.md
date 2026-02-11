
This GitHub Actions pipeline is designed to automate the lifecycle of the microservice application from code commit to production deployment. Below are the key decisions made to ensure security, traceability, and stability.

1. Image Tagging Strategy (Git Commit SHA)

- Immutability: The pipeline uses the short Git commit SHA (sha_short) as the image tag.
- Traceability: This ensures that every deployment can be traced back to a specific commit in the version control history.
- Consistency: Using the same SHA tag throughout the pipeline ensures that the exact image tested in the build-and-scan job is the one deployed to dev and prod.

2. Security-First Approach

- Vulnerability Scanning: A Trivy scan is integrated into the build job to check for CRITICAL and HIGH vulnerabilities before pushing the image to DockerHub.
- Secret Management: Sensitive credentials like Docker login details and Kubernetes configurations are handled using GitHub Secrets to prevent exposure.
- Least Privilege: Separate KUBE_CONFIG secrets are used for Development and Production to maintain strict environment isolation.

3. Pipeline Optimization & Flow

- Job Dependencies: The needs keyword ensures a logical flow: deploy-dev only runs after a successful build, and deploy-prod waits for both build and dev success.
- Parallel Potential: While the flow is sequential, the build-and-scan job is centralized to provide a single artifact (the Docker image) to all downstream 
  environments.
- Output Passing: Using outputs allows the unique image tag to be passed dynamically between jobs without hardcoding values.

4. Deployment Reliability

- Infrastructure Synchronisation: The pipeline runs kubectl apply -f k8s/ before updating images to ensure that ConfigMaps, Secrets, and Services are in the 
  desired state before the app starts.
- Rollout Status Verification: The pipeline uses kubectl rollout status to block until the new pods are fully healthy; if the deployment fails health checks, the 
  pipeline fails, preventing "silent" failures.
- Health Pre-flight & Post-flight: The production job includes a cluster-info check before starting and a final curl health check after completion to verify the 
  public endpoint is reachable.

5. Environment Control

- Manual Approval: The production job is linked to a GitHub Environment, which allows for a manual approval gate as required by the scenario.
- Automatic Dev Deployment: Deployments to the development environment occur automatically upon every push to the master branch, enabling rapid iteration.