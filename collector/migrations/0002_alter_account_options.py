# Generated by Django 5.1.1 on 2024-12-11 01:41

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('collector', '0001_initial'),
    ]

    operations = [
        migrations.AlterModelOptions(
            name='account',
            options={'ordering': ['id']},
        ),
    ]