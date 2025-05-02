import json
import uuid

from django.http import JsonResponse

from frontend.controller.index import select_random_champion_and_ability
from frontend.models import User, GameMode, Language, Game, Champion


# api/controller/ability_game.py - Hata düzeltilmiş versiyon

import json
import uuid
from django.http import JsonResponse
from django.utils.translation import gettext as _
from frontend.models import Game, Champion, Language, User, UserStat


def check_champion_guess(request):
    """API endpoint to check a champion guess in the ability game"""
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            champion_id = data.get('champion_id')
            game_id = data.get('game_id')

            if not champion_id or not game_id:
                return JsonResponse({'error': 'Missing parameters'}, status=400)

            # Get the game
            try:
                game = Game.objects.get(id=game_id)
            except Game.DoesNotExist:
                return JsonResponse({'error': 'Game not found'}, status=404)

            # Target champion ve ability kontrolü
            if not game.target_champion:
                return JsonResponse({'error': 'Game has no target champion'}, status=400)

            if not game.target_ability:
                return JsonResponse({'error': 'Game has no target ability'}, status=400)

            # Check if game is already completed
            if game.is_completed:
                return JsonResponse({'error': 'Game already completed'}, status=400)

            # Get the guessed champion
            try:
                guessed_champion = Champion.objects.get(id=champion_id)
            except Champion.DoesNotExist:
                return JsonResponse({'error': 'Champion not found'}, status=404)

            # Update attempts used
            game.attempts_used += 1

            # Check if correct guess
            is_correct = (game.target_champion_id == int(champion_id))

            # Calculate score if correct - *** MOVED UP HERE BEFORE GAME COMPLETION ***
            score = 0
            if is_correct:
                # Calculate score based on difficulty and attempts
                if game.game_mode.name.lower() == 'easy':
                    max_score = 20
                elif game.game_mode.name.lower() == 'medium':
                    max_score = 28
                elif game.game_mode.name.lower() == 'hard':
                    max_score = 36
                else:
                    max_score = 28  # Default score

                # Add bonus for grey mode if enabled
                if game.is_grey_mode:
                    max_score += 3

                # Calculate score based on attempts used
                remaining_percentage = (game.game_mode.max_attempts - game.attempts_used + 1) / game.game_mode.max_attempts
                score = int(max_score * remaining_percentage)

                # Ensure first guess gets full max score
                if game.attempts_used == 1:
                    score = max_score

            # Game is completed if champion is guessed correctly or max attempts reached
            game_completed = is_correct or game.attempts_used >= game.game_mode.max_attempts

            if game_completed:
                # Mark game as completed if either condition is met
                game.is_completed = True
                game.is_won = is_correct
                game.save()

                # Update user stats if user is authenticated
                if hasattr(request, 'user') and request.user.is_authenticated:
                    user_stat, created = UserStat.objects.get_or_create(
                        user=request.user,
                        game_type='ability'
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
                        game_type='ability'
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

            # Prepare response
            response_data = {
                'is_correct': is_correct,
                'game_completed': game_completed,
                'attempts_used': game.attempts_used,
                'max_attempts': game.game_mode.max_attempts,
                'score': score
            }

            # Add clue if incorrect and not game over
            if not is_correct and not game_completed:
                response_data['clue'] = generate_clue(game.target_champion, guessed_champion, game.attempts_used)

            # If game is completed and player lost, include target champion/ability data
            if game_completed and not is_correct:
                # Get language for translations
                language_code = request.LANGUAGE_CODE
                language = Language.objects.filter(code=language_code).first()

                response_data['target_champion'] = {
                    'id': game.target_champion.id,
                    'name': game.target_champion.name,
                    'image': game.target_champion.image_main
                }

                response_data['target_ability'] = {
                    'key': game.target_ability.ability_key,
                    'name': game.target_ability.name
                }

            return JsonResponse(response_data)

        except Exception as e:
            import traceback
            print(traceback.format_exc())
            return JsonResponse({'error': str(e)}, status=500)

    return JsonResponse({'error': 'Invalid request method'}, status=400)


def generate_clue(target_champion, guessed_champion, attempt_number):
    """Generate a clue based on the target champion and current attempt number"""
    # Güvenlik kontrolü - hedef şampiyon None ise boş ipucu döndür
    if not target_champion:
        return {
            'type': 'error',
            'text': "No champion information available"
        }

    clues = []

    # Add position clue
    target_position = target_champion.positions.filter(is_primary=True).first()
    if target_position:
        clues.append({
            'type': 'position',
            'text': f"Champion plays {target_position.position.name} position"
        })

    # Add gender clue
    target_gender = target_champion.gender.first()
    if target_gender:
        clues.append({
            'type': 'gender',
            'text': f"Champion gender is {target_gender.gender.name}"
        })

    # Add resource clue
    target_resource = target_champion.resources.first()
    if target_resource:
        clues.append({
            'type': 'resource',
            'text': f"Champion uses {target_resource.resource.name}"
        })

    # Add species clue
    target_species = target_champion.species.filter(is_primary=True).first()
    if target_species:
        clues.append({
            'type': 'species',
            'text': f"Champion species is {target_species.species.name}"
        })

    # Add region clue
    target_region = target_champion.regions.filter(is_primary=True).first()
    if target_region:
        clues.append({
            'type': 'region',
            'text': f"Champion is from {target_region.region.name}"
        })

    # Add release year clue
    if target_champion.release_year:
        clues.append({
            'type': 'release_year',
            'text': f"Champion was released in {target_champion.release_year}"
        })

    # Add range clue
    target_range = target_champion.combat_ranges.filter(is_primary=True).first()
    if target_range:
        clues.append({
            'type': 'combat_range',
            'text': f"Champion combat range is {target_range.combat_range.name}"
        })

    # Eğer hiç ipucu yoksa, basit bir ipucu ekle
    if not clues:
        clues.append({
            'type': 'basic',
            'text': f"Try to guess the champion that owns this ability"
        })

    # Calculate which clue to return based on attempt number
    # Simply use modulo to cycle through clues
    clue_index = (attempt_number - 1) % len(clues) if clues else 0

    return clues[clue_index]


def new_ability_game(request):
    """API endpoint to start a new ability guessing game"""
    if request.method == 'POST':
        difficulty = request.POST.get('difficulty', 'medium')
        is_grey_mode = request.POST.get('grey_mode', 'false').lower() == 'true'

        # Get game mode
        game_mode = GameMode.objects.filter(name__iexact=difficulty).first()
        if not game_mode:
            return JsonResponse({'error': 'Invalid difficulty'}, status=400)

        # Select a random champion and ability
        target_champion, target_ability = select_random_champion_and_ability()

        if not target_champion or not target_ability:
            return JsonResponse({'error': 'No champions or abilities available'}, status=500)

        # Get session or create new one
        session_id = request.session.get('session_id')
        if not session_id:
            session_id = str(uuid.uuid4())
            request.session['session_id'] = session_id
            request.session.modified = True

        # Get or create user
        current_user = None
        if hasattr(request, 'user') and request.user.is_authenticated:
            current_user = request.user
        else:
            # Try to get anonymous user by session_id or create a new one
            anon_username = f"anon_{session_id[:8]}"
            anon_user = User.objects.filter(username=anon_username).first()
            if not anon_user:
                anon_user = User.objects.create(
                    username=anon_username,
                    email=None,
                    password_hash=None
                )
            current_user = anon_user

        # Create a new game
        game = Game.objects.create(
            session_id=session_id,
            game_mode=game_mode,
            game_type='ability',
            target_champion=target_champion,
            target_ability=target_ability,
            is_completed=False,
            user=current_user,
            is_grey_mode=is_grey_mode
        )

        # Store game ID in session
        request.session['game_id'] = game.id
        request.session.modified = True

        return JsonResponse({
            'game_id': game.id,
            'max_attempts': game_mode.max_attempts,
            'user': current_user.username if current_user else 'Anonymous',
            'grey_mode': is_grey_mode
        })

    return JsonResponse({'error': 'Invalid request'}, status=400)