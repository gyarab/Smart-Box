from rest_framework import viewsets
from .models import User, Box
from .serializers import UserSerializer, BoxSerializer

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    user_class = UserSerializer

class BoxViewSet(viewsets.ModelViewSet):
    queryset = Box.objects.all()
    serializer_class = BoxSerializer
    Box_class = BoxSerializer
    