from django.contrib import admin
from django.http import HttpResponseRedirect
from django.urls import path, include
from django.conf.urls.i18n import i18n_patterns
from django.utils import translation

from frontend.controller import index
from lolgame import settings


def language_redirect(request):
    """
    Kullanıcıyı tarayıcı diline göre yönlendir.
    Daha detaylı tarayıcı dili tespiti ile.
    """
    # Tarayıcı dilini doğrudan HTTP başlıklarından al
    accept_language = request.META.get('HTTP_ACCEPT_LANGUAGE', '')

    if accept_language:
        # Tarayıcı dili başlığını parse et
        languages = [lang.split(';')[0].strip() for lang in accept_language.split(',')]

        # İlk dili ve alt dilleri kontrol et
        for lang in languages:
            # Tam eşleşme (örn. 'ko-KR' -> 'ko')
            if len(lang) >= 2:
                lang_prefix = lang[:2].lower()

                # Desteklenen diller listesinde mi kontrol et
                for supported_lang in [code for code, name in settings.LANGUAGES]:
                    if supported_lang == lang_prefix:
                        # Dil bulundu, bu dile yönlendir
                        return HttpResponseRedirect(f'/{lang_prefix}/')

    # Eğer tarayıcı dili tespit edilemedi veya desteklenmiyorsa, varsayılan dile yönlendir
    return HttpResponseRedirect(f'/{settings.LANGUAGE_CODE}/')


# API ve dil öneki olmayan URL'ler
urlpatterns = [
    path('', language_redirect),
    path('i18n/', include('django.conf.urls.i18n')),  # Dil değiştirme görünümü
]


# Dil önekli URL'ler
urlpatterns += i18n_patterns(
    # Sayfa URL'leri için dil öneklerini kullan
    path('', index.main, name='front_home'),
    path('games/', index.games, name='games'),
    path('nashow-to-play/', index.how_to_play, name='how_to_play'),
    path('leaderboard/', index.leaderboard, name='leaderboard'),  # Leaderboard URL added
    path('game-history/', index.game_history_page, name='game_history_page'),
    path('champions/', index.champions_page, name='champions_page'),
    path('champion/<slug:champion_slug>', index.champion_detail, name='champion_detail'),
    path('api/', include('api.urls')),

    prefix_default_language=True
)