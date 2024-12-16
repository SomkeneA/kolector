FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Create user and group
RUN addgroup --system appgroup && adduser --system --group appuser

# Set up working directory and permissions
WORKDIR /app
RUN chown -R appuser:appgroup /app

# Install dependencies as root first
COPY requirements.txt /app/
RUN pip install --no-cache-dir --user -r requirements.txt

# Copy project files
COPY . /app/
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Collect static files
RUN python manage.py collectstatic --noinput

# Expose the port
EXPOSE 8000

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD curl -f http://localhost:8000/ || exit 1

# Run the app
CMD ["gunicorn", "--workers", "3", "--bind", "0.0.0.0:8000", "kolector.wsgi:application"]
