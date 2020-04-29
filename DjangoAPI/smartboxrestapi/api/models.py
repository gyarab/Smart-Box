from django.db import models
from django.contrib.auth.models import BaseUserManager, AbstractUser
from django.conf import settings
from django.db import IntegrityError

class UserManager(BaseUserManager):
    def create_user(self, name, email, password, is_admin=False, is_staff=False, is_active=True):
        if not email:
            raise ValueError("User must have an email")
        if not password:
            raise ValueError("User must have a password")
        if not name:
            raise ValueError("User must have a name")

        user = self.model(
            email=self.normalize_email(email)
        )
        user.username = email
        user.name = name
        user.set_password(password)
        user.admin = is_admin
        user.staff = is_staff
        user.active = is_active
        user.boxes = 'a'
        user.save()
        return user

class User(AbstractUser):
    name = models.CharField(max_length=50)
    email = models.EmailField(unique=True, blank=False)
    boxes = models.CharField(max_length=50, blank=True, default=None, null=True)
    REQUIRED_FIELDS = ['name']
    USERNAME_FIELD = 'email'

    objects = UserManager()

    class Meta:
        verbose_name = "User"
        verbose_name_plural = "Users"

class Box(models.Model):
    lattitude = models.FloatField()
    longtitude = models.FloatField()
    locked = models.BooleanField(default=True)
    name = models.CharField(max_length=50)
    current_owner = models.ForeignKey(settings.AUTH_USER_MODEL, default=None, blank=True, null=True, on_delete=models.PROTECT)

    class Meta:
        verbose_name = "Box"
        verbose_name_plural = "Boxes"
