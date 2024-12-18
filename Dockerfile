FROM python:3.11-slim

# Environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV BUILD_PHASE=True

RUN addgroup --system appgroup && adduser --system --group --home /home/appuser appuser

WORKDIR /app

RUN apt-get update && apt-get install -y \
    libpq-dev gcc build-essential curl && \
    apt-get clean

COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir gunicorn \
    && echo "Installed Python dependencies."

COPY . /app/

RUN mkdir -p /app/staticfiles && chmod -R 755 /app/staticfiles

RUN python manage.py collectstatic --clear --settings=kolector.settings.prod

RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 8000

CMD ["gunicorn", "--workers", "3", "--bind", "0.0.0.0:8000", "kolector.wsgi:application"]
