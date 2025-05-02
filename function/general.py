from frontend.models import ChampionTranslation, GenderTranslation, PositionTranslation, SpeciesTranslation, \
    CombatRangeTranslation, RegionTranslation, ResourceTranslation, AbilityTranslation


def prepare_guess_feedback(target_champion, guessed_champion, language):
    """Compare the guessed champion with the target and prepare feedback"""
    champion_name = guessed_champion.name

    if language:
        translation = ChampionTranslation.objects.filter(
            champion=guessed_champion,
            language=language
        ).first()

        if translation:
            champion_name = translation.name

    feedback = {
        'champion_name': champion_name,
        'image': guessed_champion.image_main,
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

    if language:
        translation = ChampionTranslation.objects.filter(
            champion=champion,
            language=language
        ).first()

        if translation:
            name = translation.name
            title = translation.title
            lore = translation.title
    else:
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
        'image_main': champion.image_main,
        'splash_art': champion.splash_art,
        'release_year': champion.release_year,
        'gender': gender_name,
        'resource': resource_name,
        'position': position_name,
        'species': species_name,
        'combat_range': range_name,
        'region': region_name
    }


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
        'image': champion.splash_art,
        'slug': champion.slug,
        'position': position,
        'region': region,
        'gender': gender,
        'resource': resource,
        'release_year': champion.release_year,
        'difficulty': champion.difficulty
    }


def prepare_ability_guess_feedback(target_ability, guessed_ability, language):
    """Compare the guessed ability with the target and prepare feedback"""
    ability_name = guessed_ability.name

    if language:
        translation = AbilityTranslation.objects.filter(
            ability=guessed_ability,
            language=language
        ).first()

        if translation:
            ability_name = translation.name

    feedback = {
        'ability_name': ability_name,
        'image': guessed_ability.image_url,
        'key': guessed_ability.ability_key,
        'champion': guessed_ability.champion.name
    }

    # Yetenek tuşu karşılaştırması
    key_match = target_ability.ability_key == guessed_ability.ability_key
    feedback['ability_key'] = {
        'status': 'correct' if key_match else 'wrong',
        'value': guessed_ability.ability_key
    }

    # Hasar tipi karşılaştırması (eğer modelde varsa)
    if target_ability.damage_type and guessed_ability.damage_type:
        damage_match = target_ability.damage_type == guessed_ability.damage_type
        feedback['damage_type'] = {
            'status': 'correct' if damage_match else 'wrong',
            'value': guessed_ability.damage_type
        }

    # Maliyet karşılaştırması (eğer modelde varsa)
    if target_ability.cost and guessed_ability.cost:
        # Burada basitçe aynı kaynak tipini kullanıp kullanmadığını kontrol ediyoruz
        # Tam maliyet değil, sadece "mana", "energy" vb.
        cost_type_target = target_ability.cost.split()[
            0].lower() if ' ' in target_ability.cost else target_ability.cost.lower()
        cost_type_guessed = guessed_ability.cost.split()[
            0].lower() if ' ' in guessed_ability.cost else guessed_ability.cost.lower()

        cost_match = cost_type_target == cost_type_guessed
        feedback['cost_type'] = {
            'status': 'correct' if cost_match else 'wrong',
            'value': guessed_ability.cost
        }

    # Şampiyon karşılaştırması
    champ_match = target_ability.champion.id == guessed_ability.champion.id
    feedback['champion'] = {
        'status': 'correct' if champ_match else 'wrong',
        'value': guessed_ability.champion.name
    }

    # Burada daha fazla özellik karşılaştırması eklenebilir
    # ...

    return feedback


def get_ability_details(ability, language):
    """Get detailed information about an ability"""
    # İsim ve açıklamayı çeviriden al (eğer varsa)
    name = ability.name
    description = ability.description or ""

    if language:
        translation = AbilityTranslation.objects.filter(
            ability=ability,
            language=language
        ).first()

        if translation:
            name = translation.name
            description = translation.description or ""

    return {
        'id': ability.id,
        'name': name,
        'key': ability.ability_key,
        'description': description,
        'image_url': ability.image_url,
        'champion': ability.champion.name,
        'champion_id': ability.champion.id,
        'cooldown': ability.cooldown,
        'cost': ability.cost,
        'damage_type': ability.damage_type
    }

def get_ability_details(ability, language):
    """Get detailed information about an ability"""
    # İsim ve açıklamayı çeviriden al (eğer varsa)
    name = ability.name
    description = ability.description or ""

    if language:
        translation = AbilityTranslation.objects.filter(
            ability=ability,
            language=language
        ).first()

        if translation:
            name = translation.name
            description = translation.description or ""

    return {
        'id': ability.id,
        'name': name,
        'key': ability.ability_key,
        'description': description,
        'image_url': ability.image_url,
        'champion': ability.champion.name,
        'champion_id': ability.champion.id,
        'cooldown': ability.cooldown,
        'cost': ability.cost,
        'damage_type': ability.damage_type
    }