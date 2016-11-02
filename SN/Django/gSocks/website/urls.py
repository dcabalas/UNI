from django.conf.urls import include, url
from django.contrib import admin

urlpatterns = [
    url(r'^admin/', admin.site.urls),
    url(r'^store/', include('store.urls') ),
    url(r'^', include('store.urls') ),  #Bad, we must redirect, not load.
]
