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


# AJAX endpoints for the game
def search_champions(request):
    """AJAX endpoint to search champions as the user types"""
    if request.method == 'GET':
        query = request.GET.get('query', '').strip()
        language_code = request.LANGUAGE_CODE

        if len(query) < 2:
            return JsonResponse({'champions': []})

        # Get language
        language = Language.objects.filter(code=language_code).first()

        # Search in translations if language exists
        if language:
            champions = Champion.objects.filter(
                translations__language=language,
                translations__name__icontains=query
            ).distinct()[:10]

            results = []
            for champion in champions:
                # Get translation for this champion
                translation = ChampionTranslation.objects.filter(
                    champion=champion,
                    language=language
                ).first()

                # Use translated name if available
                name = translation.name if translation else champion.name

                # Get primary position
                primary_position = champion.positions.filter(is_primary=True).first()

                # Get translated position name
                position_name = ""
                if primary_position:
                    position_trans = PositionTranslation.objects.filter(
                        position=primary_position.position,
                        language=language
                    ).first()
                    position_name = position_trans.name if position_trans else primary_position.position.name

                # Add to results
                results.append({
                    'id': champion.id,
                    'name': name,
                    'image': f"https://wiki.leagueoflegends.com/en-us/images/thumb/{name}_OriginalSquare.png/128px-{name}_OriginalSquare.png?54659",
                    'position': position_name
                })

            return JsonResponse({'champions': results})
        else:
            # Fall back to English names
            champions = Champion.objects.filter(name__icontains=query)[:10]
            results = []
            for champion in champions:
                results.append({
                    'id': champion.id,
                    'name': champion.name,
                    'image': f"https://wiki.leagueoflegends.com/en-us/images/thumb/{champion.name}_OriginalSquare.png/128px-{champion.name}_OriginalSquare.png?54659",

                })
            return JsonResponse({'champions': results})

    return JsonResponse({'error': 'Invalid request'}, status=400)


def make_guess(request):
    """AJAX endpoint to submit a champion guess"""
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

            # Check if game is already completed
            if game.is_completed:
                return JsonResponse({'error': 'Game already completed'}, status=400)

            # Check if max attempts reached
            if game.attempts_used >= game.game_mode.max_attempts:
                return JsonResponse({'error': 'Max attempts reached'}, status=400)

            # Get the guessed champion
            try:
                guessed_champion = Champion.objects.get(id=champion_id)
            except Champion.DoesNotExist:
                return JsonResponse({'error': 'Champion not found'}, status=404)

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
                                                                                                        'user') and request.user.is_authenticated else 'Anonymous')
            }

            # If game completed, add target champion details
            if game.is_completed:
                response_data['target_champion'] = get_champion_details(game.target_champion, language)

            return JsonResponse(response_data)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

    return JsonResponse({'error': 'Invalid request method'}, status=400)


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


def prepare_guess_feedback(target_champion, guessed_champion, language):
    """Compare the guessed champion with the target and prepare feedback"""
    feedback = {
        'champion_name': guessed_champion.name,
        'image': f"https://wiki.leagueoflegends.com/en-us/images/thumb/{guessed_champion.name}_OriginalSquare.png/128px-{guessed_champion.name}_OriginalSquare.png?54659",
    }

    # Release year comparison
    if target_champion.release_year and guessed_champion.release_year:
        if target_champion.release_year == guessed_champion.release_year:
            status = 'correct'
        elif target_champion.release_year > guessed_champion.release_year:
            status = 'high'  # Target year is higher
        else:
            status = 'low'  # Target year is lower

        feedback['release_year'] = {
            'status': status,
            'value': guessed_champion.release_year
        }

        # Gender comparison - YENİ EKLENEN KOD
    target_gender = target_champion.gender.first()
    guessed_gender = guessed_champion.gender.first()

    if target_gender and guessed_gender:
        gender_match = target_gender.gender_id == guessed_gender.gender_id

        # Get translated gender name
        gender_name = guessed_gender.gender.name
        if language:
            gender_trans = GenderTranslation.objects.filter(
                gender=guessed_gender.gender,
                language=language
            ).first()
            if gender_trans:
                gender_name = gender_trans.name

        feedback['gender'] = {
            'status': 'correct' if gender_match else 'wrong',
            'value': gender_name
        }

    # Position comparison
    target_positions = target_champion.positions.filter(is_primary=True).first()
    guessed_positions = guessed_champion.positions.filter(is_primary=True).first()

    # Resource comparison - YENİ EKLENEN
    target_resource = target_champion.resources.first()
    guessed_resource = guessed_champion.resources.first()

    if target_resource and guessed_resource:
        resource_match = target_resource.resource_id == guessed_resource.resource_id

        # Get translated resource name
        resource_name = guessed_resource.resource.name
        if language:
            resource_trans = ResourceTranslation.objects.filter(
                resource=guessed_resource.resource,
                language=language
            ).first()
            if resource_trans:
                resource_name = resource_trans.name

        feedback['resource'] = {
            'status': 'correct' if resource_match else 'wrong',
            'value': resource_name
        }

    if target_positions and guessed_positions:
        position_match = target_positions.position_id == guessed_positions.position_id

        # Get translated position name
        position_name = guessed_positions.position.name
        if language:
            position_trans = PositionTranslation.objects.filter(
                position=guessed_positions.position,
                language=language
            ).first()
            if position_trans:
                position_name = position_trans.name

        feedback['position'] = {
            'status': 'correct' if position_match else 'wrong',
            'value': position_name
        }

    # Species comparison
    target_species = target_champion.species.filter(is_primary=True).first()
    guessed_species = guessed_champion.species.filter(is_primary=True).first()

    if target_species and guessed_species:
        species_match = target_species.species_id == guessed_species.species_id

        # Get translated species name
        species_name = guessed_species.species.name
        if language:
            species_trans = SpeciesTranslation.objects.filter(
                species=guessed_species.species,
                language=language
            ).first()
            if species_trans:
                species_name = species_trans.name

        feedback['species'] = {
            'status': 'correct' if species_match else 'wrong',
            'value': species_name
        }

    # Combat range comparison
    target_range = target_champion.combat_ranges.filter(is_primary=True).first()
    guessed_range = guessed_champion.combat_ranges.filter(is_primary=True).first()

    if target_range and guessed_range:
        range_match = target_range.combat_range_id == guessed_range.combat_range_id

        # Get translated range name
        range_name = guessed_range.combat_range.name
        if language:
            range_trans = CombatRangeTranslation.objects.filter(
                combat_range=guessed_range.combat_range,
                language=language
            ).first()
            if range_trans:
                range_name = range_trans.name

        feedback['combat_range'] = {
            'status': 'correct' if range_match else 'wrong',
            'value': range_name
        }

    # Region comparison
    target_region = target_champion.regions.filter(is_primary=True).first()
    guessed_region = guessed_champion.regions.filter(is_primary=True).first()

    if target_region and guessed_region:
        region_match = target_region.region_id == guessed_region.region_id

        # Get translated region name
        region_name = guessed_region.region.name
        if language:
            region_trans = RegionTranslation.objects.filter(
                region=guessed_region.region,
                language=language
            ).first()
            if region_trans:
                region_name = region_trans.name

        feedback['region'] = {
            'status': 'correct' if region_match else 'wrong',
            'value': region_name
        }

    return feedback


def get_champion_details(champion, language):
    """Get detailed information about a champion"""
    # Get champion translation if available
    name = champion.name
    title = champion.title
    lore = champion.lore

    if language:
        translation = ChampionTranslation.objects.filter(
            champion=champion,
            language=language
        ).first()

        if translation:
            name = translation.name
            title = translation.title
            lore = translation.lore

    # Get champion resource - YENİ EKLENEN
    resource = champion.resources.first()
    resource_name = resource.resource.name if resource else ""

    if language and resource:
        resource_trans = ResourceTranslation.objects.filter(
            resource=resource.resource,
            language=language
        ).first()
        if resource_trans:
            resource_name = resource_trans.name

    # Get champion gender - YENİ EKLENEN KOD
    gender = champion.gender.first()
    gender_name = gender.gender.name if gender else ""

    if language and gender:
        gender_trans = GenderTranslation.objects.filter(
            gender=gender.gender,
            language=language
        ).first()
        if gender_trans:
            gender_name = gender_trans.name
    # Get primary position, species, combat range, and region
    position = champion.positions.filter(is_primary=True).first()
    species = champion.species.filter(is_primary=True).first()
    combat_range = champion.combat_ranges.filter(is_primary=True).first()
    region = champion.regions.filter(is_primary=True).first()

    # Get translations for attributes
    position_name = position.position.name if position else ""
    species_name = species.species.name if species else ""
    range_name = combat_range.combat_range.name if combat_range else ""
    region_name = region.region.name if region else ""

    if language:
        if position:
            position_trans = PositionTranslation.objects.filter(
                position=position.position,
                language=language
            ).first()
            if position_trans:
                position_name = position_trans.name

        if species:
            species_trans = SpeciesTranslation.objects.filter(
                species=species.species,
                language=language
            ).first()
            if species_trans:
                species_name = species_trans.name

        if combat_range:
            range_trans = CombatRangeTranslation.objects.filter(
                combat_range=combat_range.combat_range,
                language=language
            ).first()
            if range_trans:
                range_name = range_trans.name

        if region:
            region_trans = RegionTranslation.objects.filter(
                region=region.region,
                language=language
            ).first()
            if region_trans:
                region_name = region_trans.name

    return {
        'id': champion.id,
        'name': name,
        'title': title,
        'lore': lore,
        'image_main': f"https://wiki.leagueoflegends.com/en-us/images/thumb/{name}_OriginalSquare.png/128px-{name}_OriginalSquare.png?54659",
        'splash_art': f"https://ddragon.leagueoflegends.com/cdn/img/champion/splash/{name}_0.jpg",
        'release_year': champion.release_year,
        'gender': gender_name,
        'resource': resource_name,
        'position': position_name,
        'species': species_name,
        'combat_range': range_name,
        'region': region_name
    }

# Add endpoint for resetting/starting new game
def new_game(request):
    """AJAX endpoint to start a new game"""
    if request.method == 'POST':
        difficulty = request.POST.get('difficulty', 'medium')

        # Get game mode
        game_mode = GameMode.objects.filter(name__iexact=difficulty).first()
        if not game_mode:
            return JsonResponse({'error': 'Invalid difficulty'}, status=400)

        # Choose a random champion
        champions = Champion.objects.all()
        if not champions.exists():
            return JsonResponse({'error': 'No champions available'}, status=500)

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

    return JsonResponse({'error': 'Invalid request'}, status=400)


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


def champions_api(request):
    """API endpoint to get champions with filtering and sorting"""
    if request.method == 'GET':
        # Get current language
        current_language = request.LANGUAGE_CODE
        language = Language.objects.filter(code=current_language).first()

        # Base query - ensure we're getting distinct champions
        champions_query = Champion.objects.all()

        # Apply filters
        # Position filter
        position_id = request.GET.get('position')
        if position_id and position_id != '' and position_id.isdigit():
            champions_query = champions_query.filter(
                positions__position_id=position_id
            )

        # Region filter
        region_id = request.GET.get('region')
        if region_id and region_id != '' and region_id.isdigit():
            champions_query = champions_query.filter(
                regions__region_id=region_id
            )

        # Species filter
        species_id = request.GET.get('species')
        if species_id and species_id != '' and species_id.isdigit():
            champions_query = champions_query.filter(
                species__species_id=species_id
            )

        # Resource filter
        resource_id = request.GET.get('resource')
        if resource_id and resource_id != '' and resource_id.isdigit():
            champions_query = champions_query.filter(
                resources__resource_id=resource_id
            )

        # Combat range filter
        combat_range_id = request.GET.get('combat_range')
        if combat_range_id and combat_range_id != '' and combat_range_id.isdigit():
            champions_query = champions_query.filter(
                combat_ranges__combat_range_id=combat_range_id
            )

        # Gender filter
        gender_id = request.GET.get('gender')
        if gender_id and gender_id != '' and gender_id.isdigit():
            champions_query = champions_query.filter(
                gender__gender_id=gender_id
            )

        # Release year range filter
        min_year = request.GET.get('min_year')
        max_year = request.GET.get('max_year')
        if min_year and min_year.isdigit():
            champions_query = champions_query.filter(release_year__gte=int(min_year))
        if max_year and max_year.isdigit():
            champions_query = champions_query.filter(release_year__lte=int(max_year))

        # Search by name or title
        search_query = request.GET.get('search', '').strip()
        if search_query and language:
            # Search in translations
            champions_query = champions_query.filter(
                Q(translations__language=language, translations__name__icontains=search_query) |
                Q(translations__language=language, translations__title__icontains=search_query) |
                Q(translations__language=language, translations__lore__icontains=search_query)
            )
        elif search_query:
            # Search in default names
            champions_query = champions_query.filter(
                Q(name__icontains=search_query) |
                Q(title__icontains=search_query) |
                Q(lore__icontains=search_query)
            )

        # Make sure we have distinct champions
        champions_query = champions_query.distinct()

        # Get all champion IDs first to avoid duplicates later
        champion_ids = champions_query.values_list('id', flat=True)

        # Get all champions for these IDs
        champions_query = Champion.objects.filter(id__in=champion_ids)

        # Apply sorting
        sort_by = request.GET.get('sort_by', 'name')
        sort_dir = request.GET.get('sort_dir', 'asc')

        # Always work with Python list for consistent sorting
        champions_list = list(champions_query)

        if sort_by == 'name':
            # For name sorting, sort in Python to properly handle translations
            if language:
                # Get translations for all champions
                translations = {}
                for champion in champions_list:
                    trans = ChampionTranslation.objects.filter(
                        champion=champion,
                        language=language
                    ).first()
                    translations[champion.id] = trans.name if trans else champion.name

                # Sort by translated name
                champions_list.sort(
                    key=lambda c: translations.get(c.id, c.name).lower(),
                    reverse=(sort_dir == 'desc')
                )
            else:
                # Sort by default name
                champions_list.sort(
                    key=lambda c: c.name.lower(),
                    reverse=(sort_dir == 'desc')
                )
        elif sort_by == 'release_year':
            # Sort by release year
            if sort_dir == 'asc':  # Eski -> Yeni (küçük -> büyük yıl)
                # None değerleri en sona koy, sonra yılları küçükten büyüğe sırala
                champions_list.sort(
                    key=lambda c: (c.release_year is None, c.release_year or 0)
                )
            else:  # sort_dir == 'desc' - Yeni -> Eski (büyük -> küçük yıl)
                # None değerleri en sona koy, sonra yılları büyükten küçüğe sırala
                champions_list.sort(
                    key=lambda c: (c.release_year is None, -1 * (c.release_year or 0))
                )
        elif sort_by == 'difficulty':
            difficulty_order = {
                'Easy': 1,
                'Medium': 2,
                'Hard': 3,
                None: 4  # Handle None values
            }

            champions_list.sort(
                key=lambda c: difficulty_order.get(c.difficulty, 4),
                reverse=(sort_dir == 'desc')
            )

        # Pagination
        page = int(request.GET.get('page', 1))
        page_size = int(request.GET.get('page_size', 20))
        total_items = len(champions_list)
        total_pages = (total_items + page_size - 1) // page_size

        start_idx = (page - 1) * page_size
        end_idx = min(start_idx + page_size, total_items)

        paginated_champions = champions_list[start_idx:end_idx]

        # Process champions for response
        champions_data = []
        for champion in paginated_champions:
            champions_data.append(get_champion_summary(champion, language))

        return JsonResponse({
            'champions': champions_data,
            'total_pages': total_pages,
            'current_page': page,
            'total_items': total_items
        })

    return JsonResponse({'error': 'Invalid request method'}, status=400)


def get_champion_summary(champion, language):
    """Get a summary of champion data for the API response"""
    # Get champion translation if available
    name = champion.name
    title = champion.title or ""

    if language:
        translation = ChampionTranslation.objects.filter(
            champion=champion,
            language=language
        ).first()

        if translation:
            name = translation.name
            title = translation.title or ""

    # Get primary position
    position = None
    primary_position = champion.positions.filter(is_primary=True).first()
    if primary_position:
        position_name = primary_position.position.name

        if language:
            position_trans = PositionTranslation.objects.filter(
                position=primary_position.position,
                language=language
            ).first()

            if position_trans:
                position_name = position_trans.name

        position = position_name

    # Get primary region
    region = None
    primary_region = champion.regions.filter(is_primary=True).first()
    if primary_region:
        region_name = primary_region.region.name

        if language:
            region_trans = RegionTranslation.objects.filter(
                region=primary_region.region,
                language=language
            ).first()

            if region_trans:
                region_name = region_trans.name

        region = region_name

    # Get gender
    gender = None
    champion_gender = champion.gender.first()
    if champion_gender:
        gender_name = champion_gender.gender.name

        if language:
            gender_trans = GenderTranslation.objects.filter(
                gender=champion_gender.gender,
                language=language
            ).first()

            if gender_trans:
                gender_name = gender_trans.name

        gender = gender_name

    # Get resource
    resource = None
    champion_resource = champion.resources.first()
    if champion_resource:
        resource_name = champion_resource.resource.name

        if language:
            resource_trans = ResourceTranslation.objects.filter(
                resource=champion_resource.resource,
                language=language
            ).first()

            if resource_trans:
                resource_name = resource_trans.name

        resource = resource_name

    return {
        'id': champion.id,
        'name': name,
        'title': title,
        'image': f"https://ddragon.leagueoflegends.com/cdn/img/champion/splash/{name}_0.jpg",
        'position': position,
        'region': region,
        'gender': gender,
        'resource': resource,
        'release_year': champion.release_year,
        'difficulty': champion.difficulty
    }


def champion_details(request):
    """API endpoint to get detailed information about a specific champion"""
    if request.method == 'GET':
        champion_id = request.GET.get('id')

        if not champion_id or not champion_id.isdigit():
            return JsonResponse({'error': 'Invalid champion ID'}, status=400)

        # Get champion
        try:
            champion = Champion.objects.get(id=champion_id)
        except Champion.DoesNotExist:
            return JsonResponse({'error': 'Champion not found'}, status=404)

        # Get current language
        current_language = request.LANGUAGE_CODE
        language = Language.objects.filter(code=current_language).first()

        # Get champion details
        champion_data = get_champion_details(champion, language)

        return JsonResponse({'champion': champion_data})

    return JsonResponse({'error': 'Invalid request method'}, status=400)