from django.http import JsonResponse

# Change this import to use frontend.models instead of lolgame.models
from frontend.models import Game, Language, Guess, User
from function.general import get_champion_details


def game_history(request):
    """API endpoint to get user's game history with pagination"""
    if request.method == 'GET':
        # Get current user
        current_user = None
        if hasattr(request, 'user') and request.user.is_authenticated:
            current_user = request.user
        else:
            session_id = request.session.get('session_id')
            if session_id:
                anon_username = f"anon_{session_id[:8]}"
                current_user = User.objects.filter(username=anon_username).first()

        # If no user found, return empty response
        if not current_user:
            return JsonResponse({'games': [], 'has_more': False})

        # Get pagination parameters
        page = int(request.GET.get('page', 1))
        page_size = int(request.GET.get('page_size', 10))
        game_type = request.GET.get('game_type', 'champion')

        # Calculate offset
        offset = (page - 1) * page_size

        # Get games for current user
        games = Game.objects.filter(
            user=current_user,
            game_type=game_type,
            is_completed=True
        ).order_by('-created_at')[offset:offset + page_size + 1]  # Get one extra to check if there are more

        # Check if there are more results
        has_more = len(games) > page_size
        if has_more:
            games = games[:page_size]  # Remove the extra item

        # Get language for translations
        language_code = request.LANGUAGE_CODE
        language = Language.objects.filter(code=language_code).first()

        # Prepare response data
        games_data = []
        for game in games:
            # Get the target champion details
            target_champion = get_champion_details(game.target_champion, language) if game.target_champion else None

            # Get the last guess (for lost games)
            last_guess = None
            if not game.is_won:
                last_guess_obj = Guess.objects.filter(game=game).order_by('-guess_number').first()
                if last_guess_obj and last_guess_obj.champion:
                    last_guess = {
                        'name': last_guess_obj.champion.name,
                        'image': f"https://wiki.leagueoflegends.com/en-us/images/thumb/{last_guess_obj.champion.name}_OriginalSquare.png/128px-{last_guess_obj.champion.name}_OriginalSquare.png?54659",
                    }

            # Calculate score (for display only if not stored)
            score = 0
            if game.is_won:
                # Recalculate score based on game mode and attempts
                if game.game_mode.name.lower() == 'easy':
                    max_score = 24
                elif game.game_mode.name.lower() == 'medium':
                    max_score = 20
                elif game.game_mode.name.lower() == 'hard':
                    max_score = 28
                else:
                    max_score = 36

                # Calculate score based on attempts used
                remaining_percentage = (
                                                   game.game_mode.max_attempts - game.attempts_used + 1) / game.game_mode.max_attempts
                score = int(max_score * remaining_percentage)

                # Ensure first guess gets full max score
                if game.attempts_used == 1:
                    score = max_score

            # Add game details to response
            games_data.append({
                'id': game.id,
                'target_champion': target_champion,
                'last_guess': last_guess,
                'is_won': game.is_won,
                'attempts_used': game.attempts_used,
                'max_attempts': game.game_mode.max_attempts,
                'difficulty': game.game_mode.name,
                'score': score,
                'created_at': game.created_at.strftime('%Y-%m-%d %H:%M:%S')
            })

        return JsonResponse({
            'games': games_data,
            'has_more': has_more
        })

    return JsonResponse({'error': 'Invalid request method'}, status=400)
