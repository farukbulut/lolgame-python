from django.db import models
from django.utils.text import slugify


class Language(models.Model):
    code = models.CharField(max_length=5)
    name = models.CharField(max_length=50)
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = 'languages'

    def __str__(self):
        return self.name


class Champion(models.Model):
    DIFFICULTY_CHOICES = [
        ('Easy', 'Easy'),
        ('Medium', 'Medium'),
        ('Hard', 'Hard'),
    ]

    name = models.CharField(max_length=100)
    slug = models.SlugField(max_length=100, unique=True)
    title = models.CharField(max_length=100, blank=True, null=True)
    release_year = models.IntegerField(blank=True, null=True)
    difficulty = models.CharField(max_length=10, choices=DIFFICULTY_CHOICES, blank=True, null=True)
    lore = models.TextField(blank=True, null=True)
    meta_description = models.TextField(blank=True, null=True)  # Add this line
    image_main = models.CharField(max_length=255, blank=True, null=True)
    splash_art = models.CharField(max_length=255, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'champions'

    def save(self, *args, **kwargs):
        # Generate slug if it doesn't exist
        if not self.slug:
            self.slug = slugify(self.name)
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name


class ChampionTranslation(models.Model):
    champion = models.ForeignKey(Champion, on_delete=models.CASCADE, related_name='translations')
    language = models.ForeignKey(Language, on_delete=models.CASCADE)
    name = models.CharField(max_length=100)
    title = models.CharField(max_length=100, blank=True, null=True)
    lore = models.TextField(blank=True, null=True)
    meta_description = models.TextField(blank=True, null=True)  # Add this line

    class Meta:
        unique_together = ('champion', 'language')
        db_table = 'champion_translations'

    def __str__(self):
        return f"{self.champion.name} - {self.language.code}"


class Position(models.Model):
    name = models.CharField(max_length=50)

    class Meta:
        db_table = 'positions'

    def __str__(self):
        return self.name


class PositionTranslation(models.Model):
    position = models.ForeignKey(Position, on_delete=models.CASCADE, related_name='translations')
    language = models.ForeignKey(Language, on_delete=models.CASCADE)
    name = models.CharField(max_length=50)

    class Meta:
        unique_together = ('position', 'language')
        db_table = 'position_translations'

    def __str__(self):
        return f"{self.position.name} - {self.language.code}"


class ChampionPosition(models.Model):
    champion = models.ForeignKey(Champion, on_delete=models.CASCADE, related_name='positions')
    position = models.ForeignKey(Position, on_delete=models.CASCADE)
    is_primary = models.BooleanField(default=False)

    class Meta:
        db_table = 'champion_positions'

    def __str__(self):
        return f"{self.champion.name} - {self.position.name}"


class Species(models.Model):
    name = models.CharField(max_length=50)

    class Meta:
        verbose_name_plural = 'Species'
        db_table = 'species'

    def __str__(self):
        return self.name


class SpeciesTranslation(models.Model):
    species = models.ForeignKey(Species, on_delete=models.CASCADE, related_name='translations')
    language = models.ForeignKey(Language, on_delete=models.CASCADE)
    name = models.CharField(max_length=50)

    class Meta:
        unique_together = ('species', 'language')
        db_table = 'species_translations'

    def __str__(self):
        return f"{self.species.name} - {self.language.code}"


class ChampionSpecies(models.Model):
    champion = models.ForeignKey(Champion, on_delete=models.CASCADE, related_name='species')
    species = models.ForeignKey(Species, on_delete=models.CASCADE)
    is_primary = models.BooleanField(default=False)

    class Meta:
        verbose_name_plural = 'Champion species'
        db_table = 'champion_species'

    def __str__(self):
        return f"{self.champion.name} - {self.species.name}"


class Resource(models.Model):
    name = models.CharField(max_length=50)

    class Meta:
        db_table = 'resources'

    def __str__(self):
        return self.name


class ResourceTranslation(models.Model):
    resource = models.ForeignKey(Resource, on_delete=models.CASCADE, related_name='translations')
    language = models.ForeignKey(Language, on_delete=models.CASCADE)
    name = models.CharField(max_length=50)

    class Meta:
        unique_together = ('resource', 'language')
        db_table = 'resource_translations'

    def __str__(self):
        return f"{self.resource.name} - {self.language.code}"


class ChampionResource(models.Model):
    champion = models.ForeignKey(Champion, on_delete=models.CASCADE, related_name='resources')
    resource = models.ForeignKey(Resource, on_delete=models.CASCADE)

    class Meta:
        db_table = 'champion_resources'

    def __str__(self):
        return f"{self.champion.name} - {self.resource.name}"


class CombatRange(models.Model):
    name = models.CharField(max_length=50)

    class Meta:
        db_table = 'combat_ranges'

    def __str__(self):
        return self.name


class CombatRangeTranslation(models.Model):
    combat_range = models.ForeignKey(CombatRange, on_delete=models.CASCADE, related_name='translations')
    language = models.ForeignKey(Language, on_delete=models.CASCADE)
    name = models.CharField(max_length=50)

    class Meta:
        unique_together = ('combat_range', 'language')
        db_table = 'combat_range_translations'

    def __str__(self):
        return f"{self.combat_range.name} - {self.language.code}"


class ChampionCombatRange(models.Model):
    champion = models.ForeignKey(Champion, on_delete=models.CASCADE, related_name='combat_ranges')
    combat_range = models.ForeignKey(CombatRange, on_delete=models.CASCADE)
    is_primary = models.BooleanField(default=False)

    class Meta:
        db_table = 'champion_combat_ranges'

    def __str__(self):
        return f"{self.champion.name} - {self.combat_range.name}"


class Region(models.Model):
    name = models.CharField(max_length=50)
    description = models.TextField(blank=True, null=True)

    class Meta:
        db_table = 'regions'

    def __str__(self):
        return self.name


class RegionTranslation(models.Model):
    region = models.ForeignKey(Region, on_delete=models.CASCADE, related_name='translations')
    language = models.ForeignKey(Language, on_delete=models.CASCADE)
    name = models.CharField(max_length=50)
    description = models.TextField(blank=True, null=True)

    class Meta:
        unique_together = ('region', 'language')
        db_table = 'region_translations'

    def __str__(self):
        return f"{self.region.name} - {self.language.code}"


class ChampionRegion(models.Model):
    champion = models.ForeignKey(Champion, on_delete=models.CASCADE, related_name='regions')
    region = models.ForeignKey(Region, on_delete=models.CASCADE)
    is_primary = models.BooleanField(default=False)

    class Meta:
        db_table = 'champion_regions'

    def __str__(self):
        return f"{self.champion.name} - {self.region.name}"


# In your models.py file
class Ability(models.Model):
    ABILITY_KEY_CHOICES = [
        ('passive', 'Passive'),
        ('q', 'Q'),
        ('w', 'W'),
        ('e', 'E'),
        ('r', 'R'),
        ('other', 'Other')
    ]

    champion = models.ForeignKey(Champion, on_delete=models.CASCADE, related_name='abilities')
    name = models.CharField(max_length=100)
    ability_key = models.CharField(max_length=10, choices=ABILITY_KEY_CHOICES)  # Changed from max_length=1
    description = models.TextField(blank=True, null=True)
    cooldown = models.CharField(max_length=50, blank=True, null=True)
    cost = models.CharField(max_length=50, blank=True, null=True)
    damage_type = models.CharField(max_length=20, blank=True, null=True)
    image_url = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        verbose_name_plural = 'Abilities'
        db_table = 'abilities'

    def __str__(self):
        return f"{self.champion.name} - {self.get_ability_key_display()} - {self.name}"


class AbilityTranslation(models.Model):
    ability = models.ForeignKey(Ability, on_delete=models.CASCADE, related_name='translations')
    language = models.ForeignKey(Language, on_delete=models.CASCADE)
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)

    class Meta:
        unique_together = ('ability', 'language')
        db_table = 'ability_translations'

    def __str__(self):
        return f"{self.ability.name} - {self.language.code}"


class Item(models.Model):
    name = models.CharField(max_length=100)
    cost = models.IntegerField(blank=True, null=True)
    description = models.TextField(blank=True, null=True)
    image_url = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        db_table = 'items'

    def __str__(self):
        return self.name


class ItemTranslation(models.Model):
    item = models.ForeignKey(Item, on_delete=models.CASCADE, related_name='translations')
    language = models.ForeignKey(Language, on_delete=models.CASCADE)
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)

    class Meta:
        unique_together = ('item', 'language')
        db_table = 'item_translations'

    def __str__(self):
        return f"{self.item.name} - {self.language.code}"


class ItemStat(models.Model):
    item = models.ForeignKey(Item, on_delete=models.CASCADE, related_name='stats')
    stat_name = models.CharField(max_length=50)
    value = models.CharField(max_length=50)

    class Meta:
        db_table = 'item_stats'

    def __str__(self):
        return f"{self.item.name} - {self.stat_name}: {self.value}"


class GameMode(models.Model):
    name = models.CharField(max_length=50)
    description = models.TextField(blank=True, null=True)
    max_attempts = models.IntegerField(blank=True, null=True)

    class Meta:
        db_table = 'game_modes'

    def __str__(self):
        return self.name


class GameModeTranslation(models.Model):
    game_mode = models.ForeignKey(GameMode, on_delete=models.CASCADE, related_name='translations')
    language = models.ForeignKey(Language, on_delete=models.CASCADE)
    name = models.CharField(max_length=50)
    description = models.TextField(blank=True, null=True)

    class Meta:
        unique_together = ('game_mode', 'language')
        db_table = 'game_mode_translations'

    def __str__(self):
        return f"{self.game_mode.name} - {self.language.code}"


class User(models.Model):
    username = models.CharField(max_length=100)
    email = models.EmailField(max_length=100, blank=True, null=True)
    password_hash = models.CharField(max_length=255, blank=True, null=True)
    language = models.ForeignKey(Language, on_delete=models.SET_NULL, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'users'

    def __str__(self):
        return self.username


class Game(models.Model):
    GAME_TYPE_CHOICES = [
        ('champion', 'Champion'),
        ('ability', 'Ability'),
        ('item', 'Item'),
    ]

    user = models.ForeignKey(User, on_delete=models.SET_NULL, blank=True, null=True)
    session_id = models.CharField(max_length=255, blank=True, null=True)
    game_mode = models.ForeignKey(GameMode, on_delete=models.CASCADE)
    game_type = models.CharField(max_length=10, choices=GAME_TYPE_CHOICES)
    target_champion = models.ForeignKey(Champion, on_delete=models.SET_NULL, blank=True, null=True,
                                        related_name='games_as_target')
    target_ability = models.ForeignKey(Ability, on_delete=models.SET_NULL, blank=True, null=True,
                                       related_name='games_as_target')
    target_item = models.ForeignKey(Item, on_delete=models.SET_NULL, blank=True, null=True,
                                    related_name='games_as_target')
    is_completed = models.BooleanField(default=False)
    is_won = models.BooleanField(default=False)
    attempts_used = models.IntegerField(default=0)
    is_grey_mode = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True, blank=True, null=True)

    class Meta:
        db_table = 'games'

    def __str__(self):
        return f"Game {self.id} - {self.game_type} - {self.user.username if self.user else 'Anonymous'}"


class Guess(models.Model):
    GUESS_TYPE_CHOICES = [
        ('champion', 'Champion'),
        ('ability', 'Ability'),
        ('item', 'Item'),
    ]

    game = models.ForeignKey(Game, on_delete=models.CASCADE, related_name='guesses')
    guess_type = models.CharField(max_length=10, choices=GUESS_TYPE_CHOICES)
    champion = models.ForeignKey(Champion, on_delete=models.SET_NULL, blank=True, null=True)
    ability = models.ForeignKey(Ability, on_delete=models.SET_NULL, blank=True, null=True)
    item = models.ForeignKey(Item, on_delete=models.SET_NULL, blank=True, null=True)
    guess_number = models.IntegerField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'guesses'

    def __str__(self):
        return f"Guess {self.guess_number} for Game {self.game.id}"


class UserStat(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='stats')
    game_type = models.CharField(max_length=50)
    games_played = models.IntegerField(default=0)
    games_won = models.IntegerField(default=0)
    average_attempts = models.FloatField(default=0)
    total_score = models.IntegerField(default=0)  # New field for total score
    best_score = models.IntegerField(default=0)   # New field for best single game score

    class Meta:
        db_table = 'user_stats'

    def __str__(self):
        return f"{self.user.username} - {self.game_type} Stats"


class ChampionMedia(models.Model):
    champion = models.ForeignKey(Champion, on_delete=models.CASCADE, related_name='media')
    media_type = models.CharField(max_length=50)
    url = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)

    class Meta:
        verbose_name_plural = 'Champion media'
        db_table = 'champion_media'

    def __str__(self):
        return f"{self.champion.name} - {self.media_type}"


class MediaTranslation(models.Model):
    media = models.ForeignKey(ChampionMedia, on_delete=models.CASCADE, related_name='translations')
    language = models.ForeignKey(Language, on_delete=models.CASCADE)
    description = models.TextField(blank=True, null=True)

    class Meta:
        unique_together = ('media', 'language')
        db_table = 'media_translations'

    def __str__(self):
        return f"{self.media.champion.name} Media - {self.language.code}"

# Mevcut modeller arasına ekleyin (örneğin Species modelinden sonra)

class Gender(models.Model):
    name = models.CharField(max_length=50)  # 'Male', 'Female', 'Other' gibi

    class Meta:
        db_table = 'genders'
        verbose_name_plural = 'Genders'

    def __str__(self):
        return self.name


class GenderTranslation(models.Model):
    gender = models.ForeignKey(Gender, on_delete=models.CASCADE, related_name='translations')
    language = models.ForeignKey(Language, on_delete=models.CASCADE)
    name = models.CharField(max_length=50)

    class Meta:
        unique_together = ('gender', 'language')
        db_table = 'gender_translations'

    def __str__(self):
        return f"{self.gender.name} - {self.language.code}"


class ChampionGender(models.Model):
    champion = models.ForeignKey(Champion, on_delete=models.CASCADE, related_name='gender')
    gender = models.ForeignKey(Gender, on_delete=models.CASCADE)

    class Meta:
        db_table = 'champion_genders'

    def __str__(self):
        return f"{self.champion.name} - {self.gender.name}"

# models.py dosyasına ekleyin
class ChampionSkin(models.Model):
    champion = models.ForeignKey(Champion, on_delete=models.CASCADE, related_name='skins')
    name = models.CharField(max_length=100)  # İngilizce adı (asıl ad)
    image_url = models.CharField(max_length=255)
    source_url = models.CharField(max_length=255, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ('champion', 'name')
        db_table = 'champion_skins'  # Add this line to match your database

class ChampionSkinTranslation(models.Model):
    skin = models.ForeignKey(ChampionSkin, on_delete=models.CASCADE, related_name='translations')
    language = models.ForeignKey(Language, on_delete=models.CASCADE)
    name = models.CharField(max_length=100)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ('skin', 'language')
        db_table = 'champion_skin_translations'  # Add this line to match your database