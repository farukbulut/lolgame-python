from django.shortcuts import render, redirect
from django.http import JsonResponse
from django.utils.translation import gettext as _
from django.utils import timezone
import random
import json
import uuid
from datetime import timedelta

# Change this import to use frontend.models instead of lolgame.models
from frontend.models import GameMode, Champion, Game, Language, ChampionTranslation, PositionTranslation, Guess, User, \
    UserStat, CombatRangeTranslation, RegionTranslation, SpeciesTranslation, GenderTranslation


def main(request):
    """Home page view with game options"""
    return render(request, 'home/home.html', {
        'title': _('LoL Champion Guessing Game')
    })


def champions(request):
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

    # Choose a random champion to guess
    target_champion = random.choice(list(champions)) if champions.exists() else None

    # Get session or create new one
    session_id = request.session.get('session_id')
    if not session_id:
        session_id = str(uuid.uuid4())
        request.session['session_id'] = session_id

    # Create a new game instance
    if target_champion and game_mode:
        game = Game.objects.create(
            session_id=session_id,
            game_mode=game_mode,
            game_type='champion',
            target_champion=target_champion,
            is_completed=False
        )

        # Store the game ID in session
        request.session['game_id'] = game.id
    else:
        game = None

    # Get max attempts for this difficulty
    max_attempts = game_mode.max_attempts if game_mode else 8  # Default to medium

    return render(request, 'champion_game.html', {
        'title': _('Guess the Champion'),
        'difficulty': difficulty,
        'max_attempts': max_attempts,
        'game_id': game.id if game else None
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
                    'image': champion.image_main,
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
                    'image': champion.image_main
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

                    # Calculate new average attempts
                    total_attempts = (user_stat.average_attempts * (user_stat.games_played - 1)) + game.attempts_used
                    user_stat.average_attempts = total_attempts / user_stat.games_played
                    user_stat.save()

                # Update anonymous user stats using session
                else:
                    session_id = request.session.get('session_id')
                    if session_id:
                        # Try to get user by session_id
                        anon_user = User.objects.filter(username=f"anon_{session_id[:8]}").first()
                        if not anon_user:
                            anon_user = User.objects.create(
                                username=f"anon_{session_id[:8]}",
                                email=None,
                                password_hash=None
                            )

                        user_stat, created = UserStat.objects.get_or_create(
                            user=anon_user,
                            game_type='champion'
                        )
                        user_stat.games_played += 1
                        if is_correct:
                            user_stat.games_won += 1

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
                'feedback': prepare_guess_feedback(game.target_champion, guessed_champion, language)
            }

            # If game completed, add target champion details
            if game.is_completed:
                response_data['target_champion'] = get_champion_details(game.target_champion, language)

            return JsonResponse(response_data)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

    return JsonResponse({'error': 'Invalid request method'}, status=400)


def prepare_guess_feedback(target_champion, guessed_champion, language):
    """Compare the guessed champion with the target and prepare feedback"""
    feedback = {
        'champion_name': guessed_champion.name,
        'image': guessed_champion.image_main
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
        'image_main': champion.image_main,
        'splash_art': champion.splash_art,
        'release_year': champion.release_year,
        'gender': gender_name,
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

        # Create a new game
        game = Game.objects.create(
            session_id=session_id,
            game_mode=game_mode,
            game_type='champion',
            target_champion=target_champion,
            is_completed=False
        )

        # Store game ID in session
        request.session['game_id'] = game.id

        return JsonResponse({
            'game_id': game.id,
            'max_attempts': game_mode.max_attempts
        })

    return JsonResponse({'error': 'Invalid request'}, status=400)