from django.urls import path

from api.controller import champions, guess, games, game_history, ability_game

urlpatterns = [
    path('search-champions', champions.search_champions, name='search_champions'),
    path('make-guess', guess.make_guess, name='make_guess'),
    path('new-game', games.new_game, name='new_game'),
    path('game-history', game_history.game_history, name='game_history_api'),
    path('champions', champions.champions_api, name='champions_api'),
    path('champion-details', champions.champion_details, name='champion_details_api'),

    path('user-stats', game_history.user_stats, name='user_stats_api'),  # Add this line
    path('new-ability-game', games.new_ability_game, name='new_ability_game'),
    path('make-ability-guess', guess.make_ability_guess, name='make_ability_guess'),
    path('check-champion-guess', ability_game.check_champion_guess, name='check_champion_guess'),
    path('new-ability-game', ability_game.new_ability_game, name='new_ability_game'),
    path('get-ability-game-history', ability_game.get_ability_game_history, name='get-ability-game-history'),
]