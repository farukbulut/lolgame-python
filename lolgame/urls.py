from django.contrib import admin
from django.urls import path, include
from django.conf.urls.i18n import i18n_patterns
from frontend.controller import index


# API ve dil öneki olmayan URL'ler
urlpatterns = [
    path('i18n/', include('django.conf.urls.i18n')),  # Dil değiştirme görünümü
    path('api/', include('api.urls')),
]


# Dil önekli URL'ler
urlpatterns += i18n_patterns(
    # Sayfa URL'leri için dil öneklerini kullan
    path('', index.main, name='front_home'),
    path('sampiyonlar', index.champions_page, name='champions_page'),
    path('games', index.games, name='games'),
    path('nasil-oynanir', index.how_to_play, name='how_to_play'),
    path('skor-tablosu', index.leaderboard, name='leaderboard'),  # Leaderboard URL added
    path('oyun-gecmisi', index.game_history_page, name='game_history_page'),
    path('sampiyonlar', index.champions_page, name='champions_page'),
    prefix_default_language=True
)