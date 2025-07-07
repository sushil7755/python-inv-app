# Stage 1: install Python, dependencies, and build Python packages
FROM python:3.11-alpine AS builder

# Install build tools and required system libs
RUN apk add --no-cache \
      build-base \
      libffi-dev \
      openssl-dev \
      musl-dev

WORKDIR /app

# Copy only dependency info for layer caching
COPY requirements.txt .

# Upgrade pip and install dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Stage 2: runtime image with only necessary runtime files
FROM python:3.11-alpine

WORKDIR /app

# Copy installed packages from builder
COPY --from=builder /usr/local /usr/local

# Copy application code
COPY . .

# Create non-root user for better security
RUN adduser -D appuser && chown -R appuser /app
USER appuser

# Expose the relevant port (adjust to your app, e.g. 80 or 5000)
EXPOSE 80

# Default command to run your Python app
CMD ["python", "app.py"]
