# Use the official Python image as the base image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set the working directory
WORKDIR /app

# Copy the requirements file
COPY requirements.txt /app/

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY . /app/

# Collect static files (optional)
RUN python manage.py collectstatic --noinput

# Expose port 8000
EXPOSE 8000

# Run the application with Gunicorn
CMD ["gunicorn", "--workers", "3", "--bind", "0.0.0.0:8000", "kolector.wsgi:application"]
