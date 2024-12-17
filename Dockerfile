FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN addgroup --system appgroup && adduser --system --group --home /home/appuser appuser

WORKDIR /app

RUN apt-get update && apt-get install -y curl build-essential && apt-get clean

COPY requirements.txt /app/
RUN pip install --no-cache-dir --user -r requirements.txt \
    && echo "Installed Python dependencies."

ENV PATH="/home/appuser/.local/bin:${PATH}"

COPY . /app/

RUN mkdir -p /app/staticfiles && chmod -R 755 /app/staticfiles

RUN python manage.py collectstatic --noinput --clear --settings=kolector.settings.prod

RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 8000
CMD ["gunicorn", "--workers", "3", "--bind", "0.0.0.0:8000", "kolector.wsgi:application"]
