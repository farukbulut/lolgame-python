from django.db.models import Min, Max, Q
from django.shortcuts import render, redirect
from django.http import JsonResponse
from django.urls import reverse
from django.utils import timezone
from django.utils.translation import gettext as _
import random
import json
import uuid

# Change this import to use frontend.models instead of lolgame.models
from frontend.models import GameMode, Champion, Game, Language, ChampionTranslation, PositionTranslation, Guess, User, \
    UserStat, CombatRangeTranslation, RegionTranslation, SpeciesTranslation, GenderTranslation, ResourceTranslation, \
    Region, Species, Resource, CombatRange, Gender, Position, ChampionSkinTranslation, AbilityTranslation, Ability
from function.general import get_champion_details, prepare_guess_feedback


def main(request):
    """Home page view with game options"""
    return render(request, 'home/home.html', {
        'title': _('Main Site Title'),
        'seo_desc': _('Main Site Desc')
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
        'title': _('Game Page Title'),
        'seo_desc': _('Game Page Desc'),
        'difficulty': difficulty,
        'difficulty_title': _(difficulty),
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
        'title': _('HowToPlay Page Title'),
        'seo_desc': _('HowToPlay Page Desc')
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
        'title': _('Leaderboard Page Title'),
        'seo_desc': _('Leaderboard Page Desc'),
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
        'title': _('GameHistory Page Title'),
        'seo_desc': _('GameHistory Page Desc'),
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
        'title': _('Champions Page Title'),
        'seo_desc': _('Champions Page Desc'),
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

def champion_detail(request, champion_slug):
    """Champion detail page showing abilities, skins, and other information with SEO improvements"""
    # Get current language
    current_language = request.LANGUAGE_CODE
    language = Language.objects.filter(code=current_language).first()

    try:
        # Get champion by slug
        champion = Champion.objects.get(slug=champion_slug)
    except Champion.DoesNotExist:
        # If champion doesn't exist, redirect to champions page
        return redirect('champions_page')

    # Get champion details with translations
    champion_data = get_champion_details(champion, language)

    # Define the ability key order
    ability_key_order = ['P', 'Q', 'W', 'E', 'R']

    # Get champion abilities with translations, sorted in P, Q, W, E, R order
    abilities = []
    champion_abilities = champion.abilities.all()

    # Sort abilities in the proper order
    for key in ability_key_order:
        for ability in champion_abilities:
            if ability.ability_key == key:
                ability_data = {
                    'key': ability.ability_key,
                    'name': ability.name,
                    'description': ability.description,
                    'image_url': ability.image_url,
                    'video_url': f'/public/champions/videos/{champion.id}_{champion.name.lower().replace(" ", "_")}_{ability.ability_key}.mp4'
                }

                # Get translation if available
                if language:
                    ability_trans = AbilityTranslation.objects.filter(
                        ability=ability,
                        language=language
                    ).first()
                    if ability_trans:
                        ability_data['name'] = ability_trans.name
                        ability_data['description'] = ability_trans.description

                abilities.append(ability_data)
                break

    # Get champion skins with translations
    skins = []
    for skin in champion.skins.all():
        skin_data = {
            'id': skin.id,
            'name': skin.name,
            'image_url': skin.image_url
        }

        # Get translation if available
        if language:
            skin_trans = ChampionSkinTranslation.objects.filter(
                skin=skin,
                language=language
            ).first()
            if skin_trans:
                skin_data['name'] = skin_trans.name

        skins.append(skin_data)

    # Get or generate SEO meta description
    meta_description = ""
    if language:
        # Try to get translated meta description
        translation = ChampionTranslation.objects.filter(
            champion=champion,
            language=language
        ).first()

        if translation and translation.meta_description:
            meta_description = translation.meta_description
        else:
            # Generate meta description based on lore if available
            if translation and translation.lore:
                meta_description = translation.lore[:160] + "..." if len(translation.lore) > 160 else translation.lore
            elif champion_data['lore']:
                meta_description = champion_data['lore'][:160] + "..." if len(champion_data['lore']) > 160 else \
                champion_data['lore']
            else:
                # Fallback description
                meta_description = f"{champion_data['name']} {champion_data['title']} - League of Legends champion details, abilities, and skins."
    else:
        # Fallback to English description if no translation
        if champion.meta_description:
            meta_description = champion.meta_description
        elif champion.lore:
            meta_description = champion.lore[:160] + "..." if len(champion.lore) > 160 else champion.lore
        else:
            meta_description = f"{champion.name} {champion.title} - League of Legends champion details, abilities, and skins."

    # Prepare canonical URL (important for SEO)
    canonical_url = request.build_absolute_uri(reverse('champion_detail', kwargs={'champion_slug': champion.slug}))

    # Prepare structured data (JSON-LD) for better SEO
    structured_data = {
        "@context": "https://schema.org",
        "@type": "VideoGame",
        "character": {
            "@type": "Person",
            "name": champion_data['name'],
            "description": champion_data['lore'] if champion_data['lore'] else "",
            "image": champion_data['splash_art']
        },
        "name": "League of Legends",
        "publisher": "Riot Games"
    }

    return render(request, 'champion_detail.html', {
        'champion': champion_data,
        'abilities': abilities,
        'skins': skins,
        'meta_description': meta_description,
        'canonical_url': canonical_url,
        'structured_data': json.dumps(structured_data)
    })


def ability_game(request):
    """Ability guessing game page - new version"""
    # Get current language
    current_language = request.LANGUAGE_CODE

    # Get game difficulty from query parameters or default to medium
    difficulty = request.GET.get('difficulty', 'medium')
    is_grey_mode = request.GET.get('grey_mode', 'false').lower() == 'true'

    # Get the game mode from the database
    game_mode = GameMode.objects.filter(name__iexact=difficulty).first()
    if not game_mode:
        # If game mode doesn't exist, create default game modes
        GameMode.objects.get_or_create(name='Easy', defaults={'max_attempts': 10})
        GameMode.objects.get_or_create(name='Medium', defaults={'max_attempts': 8})
        GameMode.objects.get_or_create(name='Hard', defaults={'max_attempts': 6})
        game_mode = GameMode.objects.filter(name__iexact=difficulty).first()

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
            # Only use existing game if it's not completed, matches the requested difficulty,
            # is an ability game, and matches the grey mode setting
            if (existing_game.is_completed or
                    existing_game.game_mode.name.lower() != difficulty.lower() or
                    existing_game.game_type != 'ability' or
                    existing_game.is_grey_mode != is_grey_mode):
                existing_game = None
        except Game.DoesNotExist:
            existing_game = None

    # Variables to pass to template
    target_champion_id = None
    target_ability_key = None
    ability_image = None
    clues = []

    if existing_game:
        # Continue with existing game
        game = existing_game
        attempts_used = game.attempts_used

        # Get target champion and ability info
        target_champion = game.target_champion
        target_ability = game.target_ability

        # Güvenlik kontrolleri
        if not target_champion or not target_ability:
            # Eğer hedef şampiyon veya yetenek yoksa, yeni oyun başlat
            existing_game = None
            game = None
            attempts_used = 0
        else:
            # Get ability image
            ability_image = target_ability.image_url if target_ability else "/static/img/ability_placeholder.png"

            # Set target values
            target_champion_id = target_champion.id if target_champion else None
            target_ability_key = target_ability.ability_key if target_ability else None

            # Get existing clues
            clues = get_existing_clues(game)

    # Eğer mevcut oyun yoksa veya geçersizse, yeni bir oyun başlat
    if not existing_game:
        # Choose a random champion and one of their abilities
        target_champion, target_ability = select_random_champion_and_ability()

        if target_champion and target_ability:
            # Create a new game instance
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

            # Store the game ID in session
            request.session['game_id'] = game.id
            request.session.modified = True  # Force session save

            # Set variables for template
            ability_image = target_ability.image_url if target_ability else "/static/img/ability_placeholder.png"
            target_champion_id = target_champion.id
            target_ability_key = target_ability.ability_key
            attempts_used = 0
        else:
            # Hiçbir şampiyon ya da yetenek bulunamadıysa hata mesajı döndür
            game = None
            attempts_used = 0
            # Buraya bir hata mesajı ekleyebilirsiniz

    # Get max attempts for this difficulty
    max_attempts = game_mode.max_attempts if game_mode else 8  # Default to medium

    # Calculate attempts left
    attempts_left = max_attempts - attempts_used

    # Get username
    user_name = current_user.username if current_user else None

    # Önce yetenek resminin geçerli olduğunu kontrol et
    if ability_image is None or not ability_image.strip():
        ability_image = "/static/img/ability_placeholder.png"

    return render(request, 'ability_game.html', {
        'title': _('Ability Game Page Title'),
        'seo_desc': _('Ability Game Page Description'),
        'difficulty': difficulty,
        'difficulty_title': _(difficulty),
        'is_grey_mode': is_grey_mode,
        'max_attempts': max_attempts,
        'game_id': game.id if game else None,
        'attempts_used': attempts_used,
        'attempts_left': attempts_left,
        'ability_image': ability_image,
        'target_champion_id': target_champion_id,
        'target_ability_key': target_ability_key,
        'initial_clues': json.dumps(clues) if clues else '[]',
        'user_name': user_name
    })

def select_random_champion_and_ability():
    """Select a random champion and one of their abilities"""
    # Get all champions that have abilities
    champions_with_abilities = Champion.objects.filter(abilities__isnull=False).distinct()

    if not champions_with_abilities.exists():
        return None, None

    # Select a random champion
    target_champion = random.choice(list(champions_with_abilities))

    # Get all abilities for this champion
    abilities = Ability.objects.filter(champion=target_champion)

    if not abilities.exists():
        return target_champion, None

    # Select a random ability
    target_ability = random.choice(list(abilities))

    return target_champion, target_ability


def get_existing_clues(game):
    """Get existing clues for a game in progress"""
    # In a real implementation, you would store clues in the database
    # For now, we'll return an empty list
    return []

def games_menu(request):
    """Games menu page showing all available games"""
    return render(request, 'games_menu.html', {
        'title': _('Games Menu Page Title'),
        'seo_desc': _('Games Menu Page Description')
    })