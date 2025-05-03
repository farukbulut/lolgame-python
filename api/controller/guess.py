
from django.http import JsonResponse

import json
import uuid

# Change this import to use frontend.models instead of lolgame.models
from frontend.models import GameMode, Champion, Game, Language, Guess, User, \
    UserStat, Ability, AbilityTranslation
from function.general import prepare_guess_feedback, get_champion_details, prepare_ability_guess_feedback, \
    get_ability_details

from django.utils.translation import gettext as _


def make_guess(request):
    """AJAX endpoint to submit a champion guess"""
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            champion_id = data.get('champion_id')
            game_id = data.get('game_id')

            if not champion_id or not game_id:
                return JsonResponse({'error': _('Missing parameters')}, status=400)

            # Get the game
            try:
                game = Game.objects.get(id=game_id)
            except Game.DoesNotExist:
                return JsonResponse({'error': _('Game not found')}, status=404)

            # Check if game is already completed
            if game.is_completed:
                return JsonResponse({'error': _('Game already completed')}, status=400)

            # Check if max attempts reached
            if game.attempts_used >= game.game_mode.max_attempts:
                return JsonResponse({'error': _('Max attempts reached')}, status=400)

            # Get the guessed champion
            try:
                guessed_champion = Champion.objects.get(id=champion_id)
            except Champion.DoesNotExist:
                return JsonResponse({'error': _('Champion not found')}, status=404)

            previous_guess = Guess.objects.filter(
                game_id=game_id,
                champion_id=champion_id
            ).exists()

            if previous_guess:
                return JsonResponse({
                    'error': _('You have already guessed this champion')
                }, status=400)

            # Create the guess
            guess_number = game.attempts_used + 1
            guess = Guess.objects.create(
                game=game,
                guess_type='champion',
                champion=guessed_champion,
                guess_number=guess_number
            )

            # Update game attempts
            game.attempts_used = guess_number

            # Check if correct guess
            is_correct = (game.target_champion_id == int(champion_id))

            # Calculate score based on difficulty and attempts
            score = 0
            if is_correct:
                # Calculate score based on difficulty and remaining attempts
                if game.game_mode.name.lower() == 'easy':
                    max_score = 20
                elif game.game_mode.name.lower() == 'medium':
                    max_score = 28
                elif game.game_mode.name.lower() == 'hard':
                    max_score = 36
                else:
                    max_score = 30  # Default score

                # Calculate score based on attempts used
                remaining_percentage = (game.game_mode.max_attempts - guess_number + 1) / game.game_mode.max_attempts
                score = int(max_score * remaining_percentage)

                # Ensure first guess gets full max score
                if guess_number == 1:
                    score = max_score

            # If correct or max attempts reached, complete the game
            if is_correct or game.attempts_used >= game.game_mode.max_attempts:
                game.is_completed = True
                game.is_won = is_correct
                game.save()

                # Update user stats if user is authenticated
                if hasattr(request, 'user') and request.user.is_authenticated:
                    user_stat, created = UserStat.objects.get_or_create(
                        user=request.user,
                        game_type='champion'
                    )
                    user_stat.games_played += 1
                    if is_correct:
                        user_stat.games_won += 1
                        user_stat.total_score += score
                        if score > user_stat.best_score:
                            user_stat.best_score = score

                    # Calculate new average attempts
                    total_attempts = (user_stat.average_attempts * (user_stat.games_played - 1)) + game.attempts_used
                    user_stat.average_attempts = total_attempts / user_stat.games_played
                    user_stat.save()

                # Update anonymous user stats using session
                else:
                    session_id = request.session.get('session_id')
                    if not session_id:
                        # Create a new session ID for anonymous users
                        session_id = str(uuid.uuid4())
                        request.session['session_id'] = session_id
                        # Force session save
                        request.session.modified = True

                    # Try to get user by session_id or create a new one
                    anon_username = f"anon_{session_id[:8]}"
                    anon_user = User.objects.filter(username=anon_username).first()
                    if not anon_user:
                        anon_user = User.objects.create(
                            username=anon_username,
                            email=None,
                            password_hash=None
                        )

                    # Set a long-lived cookie (10 years) to remember this user
                    max_age = 10 * 365 * 24 * 60 * 60  # 10 years in seconds
                    request.session.set_expiry(max_age)
                    # Force session save
                    request.session.modified = True

                    # Update user stats
                    user_stat, created = UserStat.objects.get_or_create(
                        user=anon_user,
                        game_type='champion'
                    )
                    user_stat.games_played += 1
                    if is_correct:
                        user_stat.games_won += 1
                        user_stat.total_score += score
                        if score > user_stat.best_score:
                            user_stat.best_score = score

                    # Calculate new average attempts
                    if user_stat.games_played > 0:
                        total_attempts = (user_stat.average_attempts * (
                                user_stat.games_played - 1)) + game.attempts_used
                        user_stat.average_attempts = total_attempts / user_stat.games_played
                    else:
                        user_stat.average_attempts = game.attempts_used
                    user_stat.save()
            else:
                game.save()

            # Get language for translations
            language_code = request.LANGUAGE_CODE
            language = Language.objects.filter(code=language_code).first()

            # Prepare the response data
            response_data = {
                'is_correct': is_correct,
                'game_completed': game.is_completed,
                'attempts_used': game.attempts_used,
                'max_attempts': game.game_mode.max_attempts,
                'feedback': prepare_guess_feedback(game.target_champion, guessed_champion, language),
                'score': score if is_correct else 0,
                'user': anon_username if 'anon_user' in locals() else (request.user.username if hasattr(request,
                                                                                                        'user') and request.user.is_authenticated else _(
                    'Anonymous'))
            }

            # If game completed, add target champion details
            if game.is_completed:
                response_data['target_champion'] = get_champion_details(game.target_champion, language)

            return JsonResponse(response_data)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

    return JsonResponse({'error': _('Invalid request method')}, status=400)


def make_ability_guess(request):
    """AJAX endpoint to submit an ability guess"""
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            ability_id = data.get('ability_id')
            ability_key = data.get('ability_key')  # Yetenek anahtarını al (P, Q, W, E, R)
            game_id = data.get('game_id')

            if not game_id:
                return JsonResponse({'error': _('Missing parameters')}, status=400)

            # Get the game
            try:
                game = Game.objects.get(id=game_id)
            except Game.DoesNotExist:
                return JsonResponse({'error': _('Game not found')}, status=404)

            # Hedef yeteneği kontrol et
            if not game.target_ability:
                return JsonResponse({'error': _('Game has no target ability')}, status=400)

            # Eğer yetenek ID yerine yetenek anahtarı (P, Q, W, E, R) kullanıldıysa
            is_correct = False
            if ability_key:
                is_correct = (game.target_ability.ability_key == ability_key)
            elif ability_id:
                is_correct = (game.target_ability.id == int(ability_id))
            else:
                return JsonResponse({'error': _('Missing ability_id or ability_key')}, status=400)

            # Oyunu tamamlandı olarak işaretle
            game.is_completed = True
            game.is_won = is_correct
            game.save()

            # Doğru dilde yetenek adını getir
            language_code = request.LANGUAGE_CODE
            language = Language.objects.filter(code=language_code).first()

            ability_name = game.target_ability.name

            # Eğer dil varsa, yetenek adının çevirisini bul
            if language:
                ability_translation = AbilityTranslation.objects.filter(
                    ability=game.target_ability,
                    language=language
                ).first()

                if ability_translation and ability_translation.name:
                    ability_name = ability_translation.name

            # Sonuç verisini hazırla
            response_data = {
                'is_correct': is_correct,
                'target_ability': {
                    'key': game.target_ability.ability_key,
                    'name': ability_name  # Çevrilmiş yetenek adı
                }
            }

            return JsonResponse(response_data)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

    return JsonResponse({'error': _('Invalid request method')}, status=400)