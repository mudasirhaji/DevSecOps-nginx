
# DevSecOps NGINX Project

## Security Scanning with Docker Scout

Docker Scout is used to scan Docker images for known vulnerabilities (CVEs), enforce security policies, and generate a Software Bill of Materials (SBOM).

### Prerequisites

- Docker installed and running.
- Docker Scout CLI installed.
- Docker Hub authentication.

Authenticate with Docker Hub before scanning:

```bash
docker login
```

### 1. Generate Vulnerability Report

```bash
docker scout cves $APP_NAME:$VERSION --output ./vulns.report
```

Generates a report containing identified vulnerabilities, affected packages, severity levels, and available remediation information.

### 2. Security Gate – Critical Vulnerabilities

```bash
docker scout cves $APP_NAME:$VERSION --only-severity critical --exit-code
```

The pipeline fails if critical vulnerabilities are detected, preventing the deployment of images that do not meet the configured security threshold.

### 3. Generate Software Bill of Materials (SBOM)

```bash
docker scout sbom --output $APP_NAME.sbom $APP_NAME:$VERSION
```

Generates a JSON-based SBOM containing an inventory of software packages and components included in the Docker image.

### 4. Run the Container

```bash
docker run -d -p 80:80 --name $APP_NAME $APP_NAME:$VERSION
```

## Generated Security Artifacts

The pipeline generates the following security artifacts in the project directory:

| File | Description |
|---|---|
| `vulns.report` | Vulnerability report containing CVE findings, affected packages, and severity levels. |
| `mywebapp.sbom` | JSON-based Software Bill of Materials listing the software packages and components included in the Docker image. |

### View Generated Reports

```bash
# View vulnerability report
head -80 vulns.report

# View SBOM file size
ls -lh mywebapp.sbom

# View SBOM structure
head -30 mywebapp.sbom

# List generated security artifacts
ls -lh vulns.report mywebapp.sbom
```

### Security Scanning Summary

- **Vulnerability Report:** Identifies known security vulnerabilities in the image.
- **Security Gate:** Enforces the configured vulnerability severity threshold.
- **SBOM:** Provides software supply-chain transparency by documenting the components included in the image.

