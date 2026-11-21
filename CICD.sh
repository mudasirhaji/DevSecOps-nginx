
#!/bin/bash
set -e

APP_NAME=mywebapp
VERSION=INSECURE
IMAGE="$APP_NAME:$VERSION"
CONTAINER="$APP_NAME"

echo "======================================"
echo " Starting DevSecOps CI/CD Pipeline"
echo "======================================"

# BUILD: Cleanup old container
echo "[BUILD] Removing previous container..."
docker rm -f "$CONTAINER" 2>/dev/null || true

# BUILD: Build Docker image
echo "[BUILD] Building Docker image: $IMAGE"
docker build -t "$IMAGE" .

# SECURITY: Generate vulnerability report
echo "[SECURITY] Generating vulnerability report..."
docker scout cves "$IMAGE" --output ./vulns.report

# SECURITY: Fail pipeline if critical vulnerabilities exist
echo "[SECURITY] Checking for critical vulnerabilities..."
docker scout cves "$IMAGE" --only-severity critical --exit-code

# SECURITY: Generate SBOM
echo "[SECURITY] Generating Software Bill of Materials..."
docker scout sbom --output "$APP_NAME.sbom" "$IMAGE"

echo "[SECURITY] Security scanning completed successfully."

# TEST: Run the container
echo "[TEST] Starting application container..."
docker run -d \
    -p 80:80 \
    --name "$CONTAINER" \
    "$IMAGE"

# TEST: Verify container health
echo "[TEST] Waiting for container health..."

for i in {1..30}; do
    STATUS=$(docker inspect --format='{{.State.Health.Status}}' "$CONTAINER" 2>/dev/null || echo "unknown")

    if [ "$STATUS" = "healthy" ]; then
        echo "[SUCCESS] Container is healthy!"
        break
    fi

    if [ "$STATUS" = "unhealthy" ]; then
        echo "[ERROR] Container is unhealthy!"
        docker logs "$CONTAINER"
        exit 1
    fi

    if [ "$i" -eq 30 ]; then
        echo "[ERROR] Container health check timed out!"
        docker logs "$CONTAINER"
        exit 1
    fi

    sleep 2
done

echo "======================================"
echo " DevSecOps Pipeline Completed!"
echo " Application: http://localhost"
echo " Image: $IMAGE"
echo " Container: $CONTAINER"
echo " Vulnerability Report: ./vulns.report"
echo " SBOM: ./$APP_NAME.sbom"
echo "======================================"

