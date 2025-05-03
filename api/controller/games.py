from django.http import JsonResponse
import random
import uuid

# Change this import to use frontend.models instead of lolgame.models
from frontend.models import GameMode, Champion, Game, User, Ability
from django.utils.translation import gettext as _

def new_game(request):
    """AJAX endpoint to start a new game"""
    if request.method == 'POST':
        difficulty = request.POST.get('difficulty', 'medium')

        # Get game mode
        game_mode = GameMode.objects.filter(name__iexact=difficulty).first()
        if not game_mode:
            return JsonResponse({'error': _('Invalid difficulty')}, status=400)

        # Choose a random champion
        champions = Champion.objects.all()
        if not champions.exists():
            return JsonResponse({'error': _('No champions available')}, status=500)

        target_champion = random.choice(list(champions))

        # Get session or create new one
        session_id = request.session.get('session_id')
        if not session_id:
            session_id = str(uuid.uuid4())
            request.session['session_id'] = session_id
            request.session.modified = True  # Force session save

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
            game_type='champion',
            target_champion=target_champion,
            is_completed=False,
            user=current_user  # Associate the game with the user
        )

        # Store game ID in session
        request.session['game_id'] = game.id
        request.session.modified = True  # Force session save

        return JsonResponse({
            'game_id': game.id,
            'max_attempts': game_mode.max_attempts,
            'user': current_user.username if current_user else 'Anonymous'
        })

    return JsonResponse({'error': _('Invalid request')}, status=400)

def new_ability_game(request):
    """AJAX endpoint to start a new ability guessing game"""
    if request.method == 'POST':
        difficulty = request.POST.get('difficulty', 'medium')
        is_grey_mode = request.POST.get('grey_mode', 'false').lower() == 'true'

        # Get game mode
        game_mode = GameMode.objects.filter(name__iexact=difficulty).first()
        if not game_mode:
            return JsonResponse({'error': _('Invalid difficulty')}, status=400)

        # Choose a random ability
        abilities = Ability.objects.all()
        if not abilities.exists():
            return JsonResponse({'error': _('No abilities available')}, status=500)

        target_ability = random.choice(list(abilities))

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

    return JsonResponse({'error': _('Invalid request')}, status=400)