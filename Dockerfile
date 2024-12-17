FROM python:3.11-slim

# Environment settings
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Create appuser
RUN addgroup --system appgroup && adduser --system --group --home /home/appuser appuser

# Set work directory
WORKDIR /app

# Pre-install basic utilities (optional)
RUN apt-get update && apt-get install -y curl build-essential && apt-get clean

# Copy requirements and install dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir --user -r requirements.txt \
    && echo "Installed Python dependencies."

# Set PATH for installed packages
ENV PATH="/home/appuser/.local/bin:${PATH}"

# Copy the project files
COPY . /app/

# Collect static files
RUN python manage.py collectstatic --noinput

# Expose port and run the application
EXPOSE 8000
CMD ["gunicorn", "--workers", "3", "--bind", "0.0.0.0:8000", "kolector.wsgi:application"]
