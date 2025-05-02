from django.contrib import admin
from django.http import HttpResponseRedirect
from django.urls import path, include
from django.conf.urls.i18n import i18n_patterns
from django.utils import translation
from django.views.generic import TemplateView
from django.contrib.sitemaps.views import sitemap

from frontend.controller import index
from frontend.controller.sitemaps import StaticViewSitemap, ChampionSitemap
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


# Create a dictionary of sitemaps
sitemaps = {
    'static': StaticViewSitemap,
    'champions': ChampionSitemap,
}

# API ve dil öneki olmayan URL'ler
urlpatterns = [
    path('', language_redirect),

    path("robots.txt", TemplateView.as_view(template_name="robots.txt", content_type="text/plain")),
    path("ads.txt", TemplateView.as_view(template_name="ads.txt", content_type="text/plain")),
    path('i18n/', include('django.conf.urls.i18n')),  # Dil değiştirme görünümü
    path('cron/', include('cron.urls')),
    # Add the sitemap URL
    path('sitemap.xml', sitemap, {'sitemaps': sitemaps}, name='django.contrib.sitemaps.views.sitemap'),
    path('sitemap-<section>.xml', sitemap, {'sitemaps': sitemaps}, name='django.contrib.sitemaps.views.sitemap'),

]


# Dil önekli URL'ler
urlpatterns += i18n_patterns(
    # Sayfa URL'leri için dil öneklerini kullan
    path('', index.main, name='front_home'),
    path('games/', index.games, name='games'),
    path('ability-game/', index.ability_game, name='ability_game'),
    path('games-menu/', index.games_menu, name='games_menu'),  # Yeni oyun menüsü URL'si
    path('how-to-play/', index.how_to_play, name='how_to_play'),  # Fixed URL pattern
    path('leaderboard/', index.leaderboard, name='leaderboard'),
    path('game-history/', index.game_history_page, name='game_history_page'),
    path('champions/', index.champions_page, name='champions_page'),
    path('champion/<slug:champion_slug>', index.champion_detail, name='champion_detail'),
    path('api/', include('api.urls')),

    prefix_default_language=True
)