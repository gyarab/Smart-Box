import requests
from rest_framework import viewsets
from .models import User, Box
from .serializers import UserSerializer, BoxSerializer
from django.http.response import JsonResponse
from django.contrib.auth import get_user_model
from django.core import serializers
from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    user_class = UserSerializer

class BoxViewSet(viewsets.ModelViewSet):
    queryset = Box.objects.all()
    serializer_class = BoxSerializer
    Box_class = BoxSerializer

@csrf_exempt
def lock(request, id):
    box_id = id
    box = Box.objects.get(id=box_id)
    token = request.headers['Authorization']
    r = requests.get('https://polar-plateau-63565.herokuapp.com/auth/users/me', headers={'Authorization': token})
    data = r.json()
    current_user_id = data['id']
    try:
        users_box = Box.objects.get(current_owner=User.objects.get(id=current_user_id))
    except:
        return JsonResponse({'nelze': 'zamknout'})
    if box == users_box:
        updated_box = BoxSerializer(box, data={'locked': True}, partial=True)
        if updated_box.is_valid():
            updated_box.save()
            return JsonResponse({'uspesne': 'zamknuto'})
    else:
        return JsonResponse({'nelze': 'zamknout'})

@csrf_exempt
def unlock(request, id):
    box_id = id
    box = Box.objects.get(id=box_id)
    token = request.headers['Authorization']
    r = requests.get('https://polar-plateau-63565.herokuapp.com/auth/users/me', headers={'Authorization': token})
    data = r.json()
    current_user_id = data['id']
    try:
        users_box = Box.objects.get(current_owner=User.objects.get(id=current_user_id))
    except:
        return JsonResponse({'nelze': 'odemknout'})
    if box == users_box:
        updated_box = BoxSerializer(box, data={'locked': False}, partial=True)
        if updated_box.is_valid():
            updated_box.save()
            return JsonResponse({'uspesne': 'odemknuto'})
    else:
        return JsonResponse({'nelze': 'odemknout'})

def locked(request, id):
    permission_classes = ()
    box_id = id
    box = Box.objects.get(id=box_id)
    serializer = BoxSerializer(box) 
    return JsonResponse({'locked': serializer.data['locked']})

@csrf_exempt
def borrow(request, id):
    box_id = id
    box = Box.objects.get(id=box_id)
    token = request.headers['Authorization']
    r = requests.get('https://polar-plateau-63565.herokuapp.com/auth/users/me', headers={'Authorization': token})
    data = r.json()
    current_user_id = data['id']
    if box.current_owner is None:
        box.current_owner = User.objects.get(id=current_user_id)
        box.save()
        return JsonResponse({'uspesne': 'pujceno'})
    else:
        return JsonResponse({'nelze': 'pujcit'})

@csrf_exempt   
def return_box(request, id):
    box_id = id
    box = Box.objects.get(id=box_id)
    token = request.headers['Authorization']
    r = requests.get('https://polar-plateau-63565.herokuapp.com/auth/users/me', headers={'Authorization': token})
    data = r.json()
    current_user_id = data['id']
    try:
        users_box = Box.objects.get(current_owner=User.objects.get(id=current_user_id))
    except:
        return JsonResponse({'nelze': 'vratit'})
    if box == users_box:
        box.current_owner = None
        box.save()
        return JsonResponse({'uspesne': 'vraceno'})
    else:
        return JsonResponse({'nelze': 'vratit'})

@csrf_exempt
def users_boxes(request):
    token = request.headers['Authorization']
    r = requests.get('https://polar-plateau-63565.herokuapp.com/auth/users/me', headers={'Authorization': token})
    data = r.json()
    current_user_id = data['id']
    try:
        queryset = Box.objects.filter(current_owner=User.objects.get(id=current_user_id))
        qs_json = serializers.serialize('json', queryset)
        return HttpResponse(qs_json, content_type='application/json')
    except:
        return JsonResponse({'nelze': 'vratit boxy'})