
# DevSecOps NGINX Project

## Security Scanning with Docker Scout

Docker Scout is used to scan the Docker image for known vulnerabilities and generate a Software Bill of Materials (SBOM).

### 1. Generate Vulnerability Report

```bash
docker scout cves $APP_NAME:$VERSION --output ./vulns.report
```

### 2. Security Gate – Critical Vulnerabilities

```bash
docker scout cves $APP_NAME:$VERSION --only-severity critical --exit-code
```

The pipeline fails if critical vulnerabilities are detected.

### 3. Generate Software Bill of Materials (SBOM)

```bash
docker scout sbom --output $APP_NAME.sbom $APP_NAME:$VERSION
```

### 4. Run the Container

```bash
docker run -d -p 80:80 --name $APP_NAME $APP_NAME:$VERSION
```

## Generated Security Artifacts

The pipeline generates the following files in the project directory:

| File | Description |
|---|---|
| `vulns.report` | Docker image vulnerability report, including CVE findings and severity levels. |
| `mywebapp.sbom` | Software Bill of Materials listing the software packages and components included in the Docker image. |

### View Generated Reports

```bash
# View vulnerability report
cat vulns.report

# View SBOM
cat mywebapp.sbom

# Check generated files
ls -lh vulns.report mywebapp.sbom
```

