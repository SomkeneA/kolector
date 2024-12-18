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

# Install Python dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir --user -r requirements.txt \
    && echo "Installed Python dependencies."

# Set PATH for installed user packages (for both root and appuser)
ENV PATH="/home/appuser/.local/bin:${PATH}"

# Switch to the appuser before installing gunicorn
USER appuser

# Install gunicorn as appuser
RUN pip install --no-cache-dir gunicorn

# Switch back to root to copy application files and set permissions
USER root

# Copy project files
COPY . /app/

# Create staticfiles directory with appropriate permissions
RUN mkdir -p /app/staticfiles && chmod -R 755 /app/staticfiles

# Collect static files
RUN python manage.py collectstatic --noinput --clear --settings=kolector.settings.prod

# Change ownership of /app to appuser
RUN chown -R appuser:appgroup /app

# Switch back to the appuser
USER appuser

# Expose application port
EXPOSE 8000

# Command to start the application
CMD ["gunicorn", "--workers", "3", "--bind", "0.0.0.0:8000", "kolector.wsgi:application"]
