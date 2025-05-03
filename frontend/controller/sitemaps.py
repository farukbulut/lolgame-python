from django.contrib.sitemaps import Sitemap
from django.urls import reverse
from frontend.models import Champion, Language
from django.conf import settings
from django.utils.timezone import now
from datetime import timedelta


class StaticViewSitemap(Sitemap):
    """Sitemap for static pages"""
    i18n = True  # This makes the sitemap multilingual
    protocol = 'https'  # veya http

    def items(self):
        # List of all static URL names with priority and change frequency
        return [
            {
                'name': 'front_home',
                'priority': 1.0,
                'changefreq': 'weekly',
            },
            {
                'name': 'games',
                'priority': 0.9,
                'changefreq': 'weekly',
            },
            {
                'name': 'how_to_play',
                'priority': 0.8,
                'changefreq': 'monthly',
            },
            {
                'name': 'leaderboard',
                'priority': 0.8,
                'changefreq': 'daily',
            },
            {
                'name': 'game_history_page',
                'priority': 0.7,
                'changefreq': 'weekly',
            },
            {
                'name': 'champions_page',
                'priority': 0.9,
                'changefreq': 'weekly',
            },
        ]

    def location(self, item):
        # Return the URL for each view name
        return reverse(item['name'])

    def priority(self, item):
        # Return the priority for this URL
        return item['priority']

    def changefreq(self, item):
        # Return the change frequency for this URL
        return item['changefreq']

    def lastmod(self, item):
        # Return a reasonable last modified date
        # Home and leaderboard are considered more frequently updated
        if item['name'] in ['front_home', 'leaderboard']:
            return now()
        elif item['name'] in ['games', 'champions_page']:
            return now() - timedelta(days=7)  # Updated weekly
        else:
            return now() - timedelta(days=30)  # Updated monthly


class ChampionSitemap(Sitemap):
    """Sitemap for champion detail pages"""
    protocol = 'https'  # veya http
    changefreq = 'monthly'
    priority = 0.7
    i18n = True  # This makes the sitemap multilingual

    def items(self):
        # Return all champions
        return Champion.objects.all()

    def location(self, obj):
        # Return the URL for each champion
        return reverse('champion_detail', kwargs={'champion_slug': obj.slug})

    def lastmod(self, obj):
        # Return the last modification date of the champion
        return obj.created_at

    def priority(self, obj):
        # Newer champions get higher priority (assuming they're more popular)
        if obj.release_year and obj.release_year >= 2020:
            return 0.8
        return 0.7