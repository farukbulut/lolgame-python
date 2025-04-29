from django.db.models import Q
from django.http import JsonResponse

from frontend.models import Champion, Language, ChampionTranslation, PositionTranslation
from function.general import get_champion_summary, get_champion_details


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