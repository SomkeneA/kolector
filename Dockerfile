FROM python:3.11-slim

# Environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Create appuser and group
RUN addgroup --system appgroup && adduser --system --group --home /home/appuser appuser

# Set the working directory
WORKDIR /app

# Install system dependencies for PostgreSQL
RUN apt-get update && apt-get install -y \
    libpq-dev gcc build-essential curl && \
    apt-get clean

# Install Python dependencies (GLOBAL install instead of --user)
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt \
    && echo "Installed Python dependencies."

# Copy project files
COPY . /app/

# Create staticfiles directory with appropriate permissions
RUN mkdir -p /app/staticfiles && chmod -R 755 /app/staticfiles

# Set environment variable to indicate build phase
ENV BUILD_PHASE=True

# Collect static files
RUN python manage.py collectstatic --noinput --clear --settings=kolector.settings.prod

# Change ownership of /app to appuser
RUN chown -R appuser:appgroup /app

# Switch to the appuser
USER appuser

# Expose application port
EXPOSE 8000

# Command to start the application
CMD ["gunicorn", "--workers", "3", "--bind", "0.0.0.0:8000", "kolector.wsgi:application"]
