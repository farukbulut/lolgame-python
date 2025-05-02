from django.urls import path

from cron.controller import champion_updater

urlpatterns = [
    path('update-champions/', champion_updater.update_champions, name='update_champions'),
]