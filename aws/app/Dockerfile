# INTENTIONAL: EOL base image. Debian 10 "buster" (EOL 2024-06) + Python 3.9 (EOL 2025-10).
# The full (non-slim) image carries hundreds of OS package CVEs, plus gcc so old pins build.
# (Python 3.9, not 3.8: current ddtrace needs 3.9+ for APM, App and API Protection and IAST.)
FROM python:3.9-buster

# Buster's repos moved to archive.debian.org; repoint apt so the explicit installs below work.
# INTENTIONAL: explicit OS packages frozen at their last buster version (no further fixes):
# imagemagick (many CVEs), libxml2, openssl/libssl1.1, curl/libcurl4, sudo, git.
RUN printf '%s\n' \
      'deb http://archive.debian.org/debian buster main' \
      'deb http://archive.debian.org/debian-security buster/updates main' \
      > /etc/apt/sources.list \
 && apt-get -o Acquire::Check-Valid-Until=false update \
 && apt-get install -y --no-install-recommends \
      imagemagick \
      libxml2 \
      openssl \
      curl \
      sudo \
      git \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
# INTENTIONAL: old pinned libraries; see requirements.txt for CVE notes.
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV TODO_DB=/data/todos.db
VOLUME ["/data"]
EXPOSE 5000

# Datadog tracing and application security (ddtrace-run below).
# DD_AGENT_HOST is set at `docker run` time (host Agent via host.docker.internal).
ENV DD_SERVICE=todo-app \
    DD_ENV=attack-path-lab \
    DD_VERSION=0.1.0 \
    DD_LOGS_INJECTION=true \
    DD_APPSEC_ENABLED=true \
    DD_IAST_ENABLED=true \
    DD_APPSEC_SCA_ENABLED=true

# INTENTIONAL: runs as root (no USER directive) -> container misconfiguration finding.
# Never run Flask's dev server or debug mode here; gunicorn only.
CMD ["ddtrace-run", "gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--access-logfile", "-", "app:app"]
