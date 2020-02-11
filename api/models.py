from django.db import models

class User(models.Model):
    first_name = models.CharField(max_length=50)
    last_name = models.CharField(max_length=50)
    email = models.CharField(max_length=50)
    password = models.CharField(max_length=50)

    class Meta:
        verbose_name = "User"
        verbose_name_plural = "Users"

class Box(models.Model):
    location = models.CharField(max_length=50)
    locked = models.BooleanField(default=True)
    current_owner = models.ForeignKey(User, default=None, blank=True, null=True, on_delete=models.PROTECT)

    class Meta:
        verbose_name = "Box"
        verbose_name_plural = "Boxes"
