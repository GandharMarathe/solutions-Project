from django.db import models

class AnimalReport(models.Model):
    name = models.CharField(max_length=100)
    contact = models.CharField(max_length=100)
    location = models.CharField(max_length=255)
    description = models.TextField()
    reported_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.location} - {self.name}"

class NGO(models.Model):
    name = models.CharField(max_length=200)
    email = models.EmailField(unique=True)
    contact_number = models.CharField(max_length=15)
    location = models.CharField(max_length=255)

    def __str__(self):
        return self.name
