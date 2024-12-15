from .base import *

DEBUG = False

ALLOWED_HOSTS = ['your-production-domain.com', '3.131.184.104']

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'kolector_db',
        'USER': 'kolector_user',
        'PASSWORD': 'Zaggyzalor0#',
        'HOST': '127.0.0.1',
        'PORT': '5432',
    }
}

# CORS settings for production
CORS_ALLOWED_ORIGINS = [
   "http://kolector.s3-website.us-east-2.amazonaws.com",
    "https://kolector.s3-website.us-east-2.amazonaws.com",
]

# Additional production settings
SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
