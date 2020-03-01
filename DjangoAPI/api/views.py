from rest_framework import viewsets
from .models import User, Box
from .serializers import UserSerializer, BoxSerializer
from django.http.response import JsonResponse

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    user_class = UserSerializer

class BoxViewSet(viewsets.ModelViewSet):
    queryset = Box.objects.all()
    serializer_class = BoxSerializer
    Box_class = BoxSerializer

def lock(request, id):
    box_id = id
    box = Box.objects.get(id=box_id)
    updated_box = BoxSerializer(box, data={'locked': True}, partial=True)
    if updated_box.is_valid():
        updated_box.save()
        

def unlock(request, id):
    box_id = id
    box = Box.objects.get(id=box_id)
    updated_box = BoxSerializer(box, data={'locked': False}, partial=True)
    if updated_box.is_valid():
        updated_box.save()

def locked(request, id):
    box_id = id
    box = Box.objects.get(id=box_id)
    serializer = BoxSerializer(box) 
    return JsonResponse({'locked': serializer.data['locked']})
