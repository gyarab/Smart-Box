"""smartboxrestapi URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path
from django.conf.urls import include
from rest_framework import routers
from api.views import UserViewSet, BoxViewSet, lock, unlock, locked, borrow, return_box, users_boxes

router = routers.DefaultRouter()
router.register(r'users', UserViewSet)
router.register(r'boxes', BoxViewSet)

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include(router.urls)),
    path('box/<int:id>/lock/', lock),
    path('box/<int:id>/unlock/', unlock),
    path('box/<int:id>/borrow/', borrow),
    path('box/<int:id>/return/', return_box),
    path('box/<int:id>/locked/', locked),
    path('user/boxes/', users_boxes),
    path('auth/', include('djoser.urls')),
    path('auth/', include('djoser.urls.authtoken'))
]
