import json
import uuid

from django.http import JsonResponse
from django.utils.translation import gettext as _
from frontend.models import Game, Champion, Language, User, UserStat, Guess, GameMode, CombatRangeTranslation, \
    RegionTranslation, SpeciesTranslation, ResourceTranslation, GenderTranslation, PositionTranslation


def check_champion_guess(request):
    """API endpoint to check a champion guess in the ability game"""
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

            # Target champion ve ability kontrolü
            if not game.target_champion:
                return JsonResponse({'error': _('Game has no target champion')}, status=400)

            if not game.target_ability:
                return JsonResponse({'error': _('Game has no target ability')}, status=400)

            # Check if game is already completed
            if game.is_completed:
                return JsonResponse({'error': _('Game already completed')}, status=400)

            # Get the guessed champion
            try:
                guessed_champion = Champion.objects.get(id=champion_id)
            except Champion.DoesNotExist:
                return JsonResponse({'error': _('Champion not found')}, status=404)

            # Update attempts used
            game.attempts_used += 1

            # Check if correct guess
            is_correct = (game.target_champion_id == int(champion_id))

            # ÖNEMLİ: Tahmini Guess tablosuna kaydet
            Guess.objects.create(
                game=game,
                guess_type='champion',
                champion=guessed_champion,
                guess_number=game.attempts_used
            )
            print(f"Tahmin kaydedildi: Oyun ID {game_id}, Şampiyon ID {champion_id}, Doğru mu: {is_correct}")

            # Calculate score if correct
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

                # Calculate score based on attempts used
                remaining_percentage = (
                                                   game.game_mode.max_attempts - game.attempts_used + 1) / game.game_mode.max_attempts
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

                # Kullanıcı istatistiklerini güncelle
                if hasattr(request, 'user') and request.user.is_authenticated:
                    update_user_stats(request.user, game, is_correct, score)
                else:
                    update_anonymous_user_stats(request, game, is_correct, score)
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
                # Get language for translations
                language_code = request.LANGUAGE_CODE
                language = Language.objects.filter(code=language_code).first()

                # language parametresi eklendi
                response_data['clue'] = generate_clue(game.target_champion, guessed_champion, game.attempts_used,
                                                      language)

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

    return JsonResponse({'error': _('Invalid request method')}, status=400)


def update_user_stats(user, game, is_correct, score):
    """Kayıtlı kullanıcı istatistiklerini günceller"""
    user_stat, created = UserStat.objects.get_or_create(
        user=user,
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


def update_anonymous_user_stats(request, game, is_correct, score):
    """Anonim kullanıcı istatistiklerini günceller"""
    session_id = request.session.get('session_id')
    if not session_id:
        # Create a new session ID for anonymous users
        session_id = str(uuid.uuid4())
        request.session['session_id'] = session_id
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

    # Set a long-lived cookie
    max_age = 10 * 365 * 24 * 60 * 60  # 10 years in seconds
    request.session.set_expiry(max_age)
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
        total_attempts = (user_stat.average_attempts * (user_stat.games_played - 1)) + game.attempts_used
        user_stat.average_attempts = total_attempts / user_stat.games_played
    else:
        user_stat.average_attempts = game.attempts_used
    user_stat.save()


def generate_clue(target_champion, guessed_champion, attempt_number, language=None):
    """Dil destekli ipucu oluşturma fonksiyonu"""
    # Güvenlik kontrolü - hedef şampiyon None ise boş ipucu döndür
    if not target_champion:
        return {
            'type': 'error',
            'text': _("No champion information available")
        }

    clues = []

    # Pozisyon ipucu
    target_position = target_champion.positions.filter(is_primary=True).first()
    if target_position:
        position_name = target_position.position.name
        if language:
            position_trans = PositionTranslation.objects.filter(
                position=target_position.position,
                language=language
            ).first()
            if position_trans:
                position_name = position_trans.name

        clues.append({
            'type': 'position',
            'text': _("Champion plays %s position") % position_name
        })

    # Cinsiyet ipucu
    target_gender = target_champion.gender.first()
    if target_gender:
        gender_name = target_gender.gender.name
        if language:
            gender_trans = GenderTranslation.objects.filter(
                gender=target_gender.gender,
                language=language
            ).first()
            if gender_trans:
                gender_name = gender_trans.name

        clues.append({
            'type': 'gender',
            'text': _("Champion gender is %s") % gender_name
        })

    # Kaynak ipucu
    target_resource = target_champion.resources.first()
    if target_resource:
        resource_name = target_resource.resource.name
        if language:
            resource_trans = ResourceTranslation.objects.filter(
                resource=target_resource.resource,
                language=language
            ).first()
            if resource_trans:
                resource_name = resource_trans.name

        clues.append({
            'type': 'resource',
            'text': _("Champion uses %s") % resource_name
        })

    # Tür ipucu
    target_species = target_champion.species.filter(is_primary=True).first()
    if target_species:
        species_name = target_species.species.name
        if language:
            species_trans = SpeciesTranslation.objects.filter(
                species=target_species.species,
                language=language
            ).first()
            if species_trans:
                species_name = species_trans.name

        clues.append({
            'type': 'species',
            'text': _("Champion species is %s") % species_name
        })

    # Bölge ipucu
    target_region = target_champion.regions.filter(is_primary=True).first()
    if target_region:
        region_name = target_region.region.name
        if language:
            region_trans = RegionTranslation.objects.filter(
                region=target_region.region,
                language=language
            ).first()
            if region_trans:
                region_name = region_trans.name

        clues.append({
            'type': 'region',
            'text': _("Champion is from %s") % region_name
        })

    # Çıkış yılı ipucu
    if target_champion.release_year:
        clues.append({
            'type': 'release_year',
            'text': _("Champion was released in %s") % target_champion.release_year
        })

    # Savaş menzili ipucu
    target_range = target_champion.combat_ranges.filter(is_primary=True).first()
    if target_range:
        range_name = target_range.combat_range.name
        if language:
            range_trans = CombatRangeTranslation.objects.filter(
                combat_range=target_range.combat_range,
                language=language
            ).first()
            if range_trans:
                range_name = range_trans.name

        clues.append({
            'type': 'combat_range',
            'text': _("Champion combat range is %s") % range_name
        })

    # Eğer hiç ipucu yoksa, basit bir ipucu ekle
    if not clues:
        clues.append({
            'type': 'basic',
            'text': _("Try to guess the champion that owns this ability")
        })

    # Calculate which clue to return based on attempt number
    # Simply use modulo to cycle through clues
    clue_index = (attempt_number - 1) % len(clues) if clues else 0

    return clues[clue_index]


def get_ability_game_history(request):
    """API endpoint to get previous guesses and clues for ability game"""
    if request.method == 'GET':
        game_id = request.GET.get('game_id')
        print(f"Requested game ID: {game_id}")  # Debug için log

        if not game_id:
            return JsonResponse({'error': _('Missing game_id parameter')}, status=400)

        try:
            game = Game.objects.get(id=game_id)
            print(f"Found game: {game.id}, type: {game.game_type}")  # Debug için log

            # Hedef şampiyon kontrolü
            if not game.target_champion:
                print(f"Game {game_id} has no target champion")
                return JsonResponse({'guesses': [], 'clues': []})
        except Game.DoesNotExist:
            return JsonResponse({'error': _('Game not found')}, status=404)

        # Get current language for translations
        language_code = request.LANGUAGE_CODE
        language = Language.objects.filter(code=language_code).first()
        print(f"User language: {language_code}, DB language object: {language}")

        # Get previous guesses
        guesses = Guess.objects.filter(game=game).order_by('guess_number')
        print(f"Found {guesses.count()} guesses for game {game_id}")

        # Doğrudan SQL ile tahmin sayısını kontrol et
        from django.db import connection
        with connection.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) FROM guesses WHERE game_id = %s", [game_id])
            count = cursor.fetchone()[0]
            print(f"SQL query found {count} guesses")

        # Prepare response
        guesses_data = []
        clues = []

        for i, guess in enumerate(guesses):
            if guess.champion:
                print(f"Processing guess {i + 1}: Champion {guess.champion.name}")

                # Add guess to list
                guesses_data.append({
                    'champion_id': guess.champion.id,
                    'champion_name': guess.champion.name,
                    'image': guess.champion.image_main,
                    'is_correct': game.target_champion_id == guess.champion.id,
                    'guess_number': guess.guess_number
                })

                # Generate clue if not correct
                if game.target_champion_id != guess.champion.id:
                    try:
                        clue = generate_clue(game.target_champion, guess.champion, i + 1, language)
                        clues.append(clue)
                        print(f"Generated clue: {clue}")
                    except Exception as e:
                        print(f"Error generating clue: {str(e)}")
                        clues.append({
                            'type': 'error',
                            'text': _("Error generating clue")
                        })
            else:
                print(f"Guess {i + 1} has no champion data")

        result = {
            'guesses': guesses_data,
            'clues': clues
        }
        print(f"Returning {len(guesses_data)} guesses and {len(clues)} clues")
        return JsonResponse(result)

    return JsonResponse({'error': _('Invalid request method')}, status=400)


def new_ability_game(request):
    """API endpoint to start a new ability guessing game"""
    if request.method == 'POST':
        difficulty = request.POST.get('difficulty', 'medium')
        is_grey_mode = request.POST.get('grey_mode', 'false').lower() == 'true'

        # Get game mode
        game_mode = GameMode.objects.filter(name__iexact=difficulty).first()
        if not game_mode:
            return JsonResponse({'error': _('Invalid difficulty')}, status=400)

        # Select a random champion and ability
        from frontend.controller.index import select_random_champion_and_ability
        target_champion, target_ability = select_random_champion_and_ability()

        if not target_champion or not target_ability:
            return JsonResponse({'error': _('No champions or abilities available')}, status=500)

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
            'user': current_user.username if current_user else _('Anonymous'),
            'grey_mode': is_grey_mode
        })

    return JsonResponse({'error': _('Invalid request')}, status=400)