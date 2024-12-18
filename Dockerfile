# Stage 1: Build stage
FROM python:3.11-slim as builder

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpq-dev gcc build-essential curl && \
    apt-get clean

# Set working directory
WORKDIR /app

# Copy dependencies and install them
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy only necessary files
COPY . /app/

# Collect static files
RUN python manage.py collectstatic --noinput --clear --settings=kolector.settings.prod

# Stage 2: Runtime stage
FROM python:3.11-slim

# Create appuser and group
RUN addgroup --system appgroup && adduser --system --group --home /home/appuser appuser

# Set working directory
WORKDIR /app

# Copy files from the build stage
COPY --from=builder /app /app

# Change ownership of /app
RUN chown -R appuser:appgroup /app

# Switch to the appuser
USER appuser

# Expose application port
EXPOSE 8000

# Command to start the application
CMD ["gunicorn", "--workers", "3", "--bind", "0.0.0.0:8000", "kolector.wsgi:application"]
