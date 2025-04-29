from django.db.models import Min, Max, Q
from django.shortcuts import render
from django.http import JsonResponse
from django.utils import timezone
from django.utils.translation import gettext as _
import random
import json
import uuid

# Change this import to use frontend.models instead of lolgame.models
from frontend.models import GameMode, Champion, Game, Language, ChampionTranslation, PositionTranslation, Guess, User, \
    UserStat, CombatRangeTranslation, RegionTranslation, SpeciesTranslation, GenderTranslation, ResourceTranslation, \
    Region, Species, Resource, CombatRange, Gender, Position
from function.general import get_champion_details, prepare_guess_feedback


def main(request):
    """Home page view with game options"""
    return render(request, 'home/home.html', {
        'title': _('LoL Champion Guessing Game')
    })

def games(request):
    """Champions guessing game page"""
    # Get current language
    current_language = request.LANGUAGE_CODE

    # Get game difficulty from query parameters or default to medium
    difficulty = request.GET.get('difficulty', 'medium')

    # Get the game mode from the database
    game_mode = GameMode.objects.filter(name__iexact=difficulty).first()
    if not game_mode:
        # If game mode doesn't exist, create default game modes
        GameMode.objects.get_or_create(name='Easy', defaults={'max_attempts': 10})
        GameMode.objects.get_or_create(name='Medium', defaults={'max_attempts': 8})
        GameMode.objects.get_or_create(name='Hard', defaults={'max_attempts': 6})
        game_mode = GameMode.objects.filter(name__iexact=difficulty).first()

    # Get all champions
    champions = Champion.objects.all()

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

    # Check if there's an existing game in progress
    game_id = request.session.get('game_id')
    existing_game = None
    if game_id:
        try:
            existing_game = Game.objects.get(id=game_id)
            # Only use existing game if it's not completed and matches the requested difficulty
            if existing_game.is_completed or existing_game.game_mode.name.lower() != difficulty.lower():
                existing_game = None
        except Game.DoesNotExist:
            existing_game = None

    if existing_game:
        # Continue with existing game
        game = existing_game

        # If the game doesn't have a user assigned, assign it now
        if game.user is None and current_user:
            game.user = current_user
            game.save()
    else:
        # Choose a random champion to guess
        target_champion = random.choice(list(champions)) if champions.exists() else None

        # Create a new game instance
        if target_champion and game_mode:
            game = Game.objects.create(
                session_id=session_id,
                game_mode=game_mode,
                game_type='champion',
                target_champion=target_champion,
                is_completed=False,
                user=current_user  # Associate the game with the user
            )

            # Store the game ID in session
            request.session['game_id'] = game.id
            request.session.modified = True  # Force session save
        else:
            game = None

    # Get max attempts for this difficulty
    max_attempts = game_mode.max_attempts if game_mode else 8  # Default to medium

    # Get previous guesses if continuing a game
    previous_guesses = []
    attempts_used = 0

    if existing_game:
        guesses = Guess.objects.filter(game=existing_game).order_by('guess_number')
        attempts_used = existing_game.attempts_used

        language = Language.objects.filter(code=current_language).first()

        for guess in guesses:
            if guess.champion:
                feedback = prepare_guess_feedback(existing_game.target_champion, guess.champion, language)
                previous_guesses.append(feedback)

    # Calculate attempts left (instead of using a template filter)
    attempts_left = max_attempts - attempts_used

    # Get username
    user_name = current_user.username if current_user else None

    return render(request, 'champion_game.html', {
        'title': _('Guess the Champion'),
        'difficulty': difficulty,
        'max_attempts': max_attempts,
        'game_id': game.id if game else None,
        'attempts_used': attempts_used,
        'attempts_left': attempts_left,
        'previous_guesses': json.dumps(previous_guesses) if previous_guesses else None,
        'user_name': user_name
    })


def how_to_play(request):
    """How to play page"""
    return render(request, 'how_to_play.html', {
        'title': _('How to Play')
    })


def leaderboard(request):
    """Leaderboard page showing top scoring players"""
    # Get current language
    current_language = request.LANGUAGE_CODE
    language = Language.objects.filter(code=current_language).first()

    # Get game type from query parameters or default to 'champion'
    game_type = request.GET.get('game_type', 'champion')

    # Get difficulty filter from query parameters
    difficulty = request.GET.get('difficulty', None)

    # Get top 20 players by total score for this game type
    top_players = UserStat.objects.filter(
        game_type=game_type
    ).order_by('-total_score')[:20]

    # Get current user stats (if logged in or has a session)
    user_stat = None
    user_rank = None

    if hasattr(request, 'user') and request.user.is_authenticated:
        user_stat = UserStat.objects.filter(
            user=request.user,
            game_type=game_type
        ).first()
    else:
        session_id = request.session.get('session_id')
        if session_id:
            anon_user = User.objects.filter(username=f"anon_{session_id[:8]}").first()
            if anon_user:
                user_stat = UserStat.objects.filter(
                    user=anon_user,
                    game_type=game_type
                ).first()

    # Calculate user's rank if they have stats
    if user_stat:
        # Count how many users have a higher score
        higher_scores = UserStat.objects.filter(
            game_type=game_type,
            total_score__gt=user_stat.total_score
        ).count()
        user_rank = higher_scores + 1  # User's rank

    return render(request, 'leaderboard.html', {
        'title': _('Leaderboard'),
        'top_players': top_players,
        'user_stat': user_stat,
        'user_rank': user_rank,
        'game_type': game_type,
        'difficulty': difficulty
    })

def game_history_page(request):
    """Game history page showing user's past games"""
    # Get current language
    current_language = request.LANGUAGE_CODE

    # Get game type from query parameters or default to 'champion'
    game_type = request.GET.get('game_type', 'champion')

    # Get current user
    current_user = None
    user_name = None

    if hasattr(request, 'user') and request.user.is_authenticated:
        current_user = request.user
        user_name = current_user.username
    else:
        session_id = request.session.get('session_id')
        if session_id:
            anon_username = f"anon_{session_id[:8]}"
            anon_user = User.objects.filter(username=anon_username).first()
            if anon_user:
                current_user = anon_user
                user_name = anon_user.username

    # Get user stats
    user_stat = None
    if current_user:
        user_stat = UserStat.objects.filter(
            user=current_user,
            game_type=game_type
        ).first()

    return render(request, 'game_history.html', {
        'title': _('Game History'),
        'game_type': game_type,
        'user_name': user_name,
        'user_stat': user_stat
    })

def champions_page(request):
    """Champions page showing all champions with filtering and sorting options"""
    # Get current language
    current_language = request.LANGUAGE_CODE
    language = Language.objects.filter(code=current_language).first()

    # Get all champions - make sure we get distinct champions
    champions = Champion.objects.all().distinct()

    # Get all available filters for dropdowns - make sure we get distinct options
    positions = Position.objects.all().distinct()
    regions = Region.objects.all().distinct()
    species = Species.objects.all().distinct()
    resources = Resource.objects.all().distinct()
    combat_ranges = CombatRange.objects.all().distinct()
    genders = Gender.objects.all().distinct()

    # Translate filter options if language exists
    positions_translated = []
    regions_translated = []
    species_translated = []
    resources_translated = []
    combat_ranges_translated = []
    genders_translated = []

    if language:
        # Positions
        for position in positions:
            translation = PositionTranslation.objects.filter(
                position=position,
                language=language
            ).first()
            positions_translated.append({
                'id': position.id,
                'name': translation.name if translation else position.name
            })

        # Regions
        for region in regions:
            translation = RegionTranslation.objects.filter(
                region=region,
                language=language
            ).first()
            regions_translated.append({
                'id': region.id,
                'name': translation.name if translation else region.name
            })

        # Species
        for sp in species:
            translation = SpeciesTranslation.objects.filter(
                species=sp,
                language=language
            ).first()
            species_translated.append({
                'id': sp.id,
                'name': translation.name if translation else sp.name
            })

        # Resources
        for resource in resources:
            translation = ResourceTranslation.objects.filter(
                resource=resource,
                language=language
            ).first()
            resources_translated.append({
                'id': resource.id,
                'name': translation.name if translation else resource.name
            })

        # Combat Ranges
        for cr in combat_ranges:
            translation = CombatRangeTranslation.objects.filter(
                combat_range=cr,
                language=language
            ).first()
            combat_ranges_translated.append({
                'id': cr.id,
                'name': translation.name if translation else cr.name
            })

        # Genders
        for gender in genders:
            translation = GenderTranslation.objects.filter(
                gender=gender,
                language=language
            ).first()
            genders_translated.append({
                'id': gender.id,
                'name': translation.name if translation else gender.name
            })
    else:
        # If no language, just use default names
        positions_translated = [{'id': p.id, 'name': p.name} for p in positions]
        regions_translated = [{'id': r.id, 'name': r.name} for r in regions]
        species_translated = [{'id': s.id, 'name': s.name} for s in species]
        resources_translated = [{'id': r.id, 'name': r.name} for r in resources]
        combat_ranges_translated = [{'id': c.id, 'name': c.name} for c in combat_ranges]
        genders_translated = [{'id': g.id, 'name': g.name} for g in genders]

    # Get min and max release years for the slider - use distinct values
    min_year = Champion.objects.aggregate(Min('release_year'))['release_year__min'] or 2009
    max_year = Champion.objects.aggregate(Max('release_year'))['release_year__max'] or timezone.now().year

    # Count unique champions
    champion_count = champions.count()

    return render(request, 'champions_page.html', {
        'title': _('Champions'),
        'positions': positions_translated,
        'regions': regions_translated,
        'species': species_translated,
        'resources': resources_translated,
        'combat_ranges': combat_ranges_translated,
        'genders': genders_translated,
        'min_year': min_year,
        'max_year': max_year,
        'champion_count': champion_count
    })