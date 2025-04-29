from django.urls import path

from api.controller import champions, guess, games, game_history
from frontend.controller import index

urlpatterns = [
    path('search-champions', champions.search_champions, name='search_champions'),
    path('make-guess', guess.make_guess, name='make_guess'),
    path('new-game', games.new_game, name='new_game'),
    path('game-history', game_history.game_history, name='game_history_api'),
    path('champions', champions.champions_api, name='champions_api'),
    path('champion-details', champions.champion_details, name='champion_details_api'),

]