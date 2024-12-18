from django.db import models


class Agency(models.Model):
    name = models.CharField(max_length=255, unique=True)

    def __str__(self):
        return self.name


class Client(models.Model):
    agency = models.ForeignKey(Agency, on_delete=models.CASCADE, related_name="clients")
    name = models.CharField(max_length=255, unique=True)

    def __str__(self):
        return self.name


class Consumer(models.Model):
    name = models.CharField(max_length=255)
    address = models.TextField()
    ssn = models.CharField(max_length=11, unique=True)

    def __str__(self):
        return self.name


class Account(models.Model):
    STATUS_CHOICES = [
        ("in_collection", "In Collection"),
        ("collected", "Collected"),
        ("inactive", "Inactive"),
    ]
    client = models.ForeignKey(Client, on_delete=models.CASCADE, related_name="accounts")
    consumers = models.ManyToManyField(Consumer, related_name="accounts")
    balance = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(max_length=50, choices=STATUS_CHOICES)

    def __str__(self):
        return f"Account {self.id} - Balance: {self.balance} - Status: {self.status}"

    class Meta:
        ordering = ['id']

