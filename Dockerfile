FROM python:3.11-slim

# Environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV BUILD_PHASE=True

# Create appuser and group
RUN addgroup --system appgroup && adduser --system --group --home /home/appuser appuser

# Set the working directory
WORKDIR /app

# Install system dependencies for PostgreSQL
RUN apt-get update && apt-get install -y \
    libpq-dev gcc build-essential curl && \
    apt-get clean

# Install Python dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir gunicorn \
    && echo "Installed Python dependencies."

# Copy project files
COPY . /app/

# Create staticfiles directory
RUN mkdir -p /app/staticfiles && chmod -R 755 /app/staticfiles

# Collect static files
RUN python manage.py collectstatic --clear --settings=kolector.settings.prod

# Change ownership of /app to appuser
RUN chown -R appuser:appgroup /app

# Switch to the appuser
USER appuser

# Expose application port
EXPOSE 8000

# Command to start the application
CMD ["gunicorn", "--workers", "3", "--bind", "0.0.0.0:8000", "kolector.wsgi:application"]
