from django.urls import path
from frontend.controller import index

# Sadece sayfa URL'leri - API endpoint'leri ana urls.py'ye taşındı
urlpatterns = [
    path('', index.main, name='front_home'),
    path('game', index.champions, name='game'),
    path('sampiyonlar', index.champions, name='champions'),
    path('nasil-oynanir', index.how_to_play, name='how_to_play'),
]