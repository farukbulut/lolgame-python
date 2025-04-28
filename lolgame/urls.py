from django.contrib import admin
from django.urls import path, include
from django.conf.urls.i18n import i18n_patterns
from frontend.controller import index

# API ve dil öneki olmayan URL'ler
urlpatterns = [
    path('admin/', admin.site.urls),
    path('i18n/', include('django.conf.urls.i18n')),  # Dil değiştirme görünümü

    # API endpoint'leri - dil öneki OLMADAN
    path('api/search-champions', index.search_champions, name='search_champions'),
    path('api/make-guess', index.make_guess, name='make_guess'),
    path('api/new-game', index.new_game, name='new_game'),
]

# Dil önekli URL'ler
urlpatterns += i18n_patterns(
    # Sadece sayfa URL'leri için dil öneklerini kullan
    path('', index.main, name='front_home'),
    path('sampiyonlar', index.champions, name='champions'),
    path('nasil-oynanir', index.how_to_play, name='how_to_play'),
    prefix_default_language=True
)