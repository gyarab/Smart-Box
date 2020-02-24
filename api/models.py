from django.db import models
from django.contrib.auth.models import BaseUserManager, AbstractUser

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
        user.name = name
        user.set_password(password)
        user.admin = is_admin
        user.staff = is_staff
        user.active = is_active
        user.save(using=self._db)
        return user

class User(AbstractUser):
    name = models.CharField(max_length=50)
    email = models.EmailField(unique=True, blank=False)
    REQUIRED_FIELDS = ['name']
    USERNAME_FIELD = 'email'

    objects = UserManager()

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
