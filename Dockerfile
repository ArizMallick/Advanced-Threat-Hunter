# Advanced Threat Hunter - Production Docker Image (ARM Compatible)
FROM python:3.11-alpine

# Metadata labels for Docker Hub
LABEL maintainer="arizhasanr30@gmail.com"
LABEL version="2.0"
LABEL description="Advanced Threat Hunter - Real-time Security Monitoring & Analysis Platform"
LABEL org.opencontainers.image.title="ath"
LABEL org.opencontainers.image.description="A Flask-based security monitoring tool for real-time threat detection and log analysis"
LABEL org.opencontainers.image.version="2.0"
LABEL org.opencontainers.image.authors="MD ARIZ HASAN"
LABEL org.opencontainers.image.url="https://github.com/ArizMallick/Advanced-Threat-Hunter"
LABEL org.opencontainers.image.source="https://github.com/ArizMallick/Advanced-Threat-Hunter"
LABEL org.opencontainers.image.licenses="MIT"

# Set working directory
WORKDIR /app

# Environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    FLASK_APP=app.py \
    FLASK_ENV=production \
    PORT=4000

# Install dependencies (minimal Alpine packages)
RUN apk add --no-cache gcc musl-dev python3-dev libffi-dev curl

# Copy requirements file
COPY requirements.txt .

# Upgrade pip and install Python dependencies
RUN python -m pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY app.py .
COPY static/ ./static/

# Create non-root user
RUN adduser -D -u 1000 appuser && \
    chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 4000

# Health check (uses curl instead of requests to avoid extra deps)
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:4000/api/health || exit 1

# Run the application
CMD ["python", "app.py"]
