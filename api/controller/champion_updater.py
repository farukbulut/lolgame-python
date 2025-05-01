# api/controller/champion_updater.py

import os
import json
import requests
import time
from bs4 import BeautifulSoup
from django.http import JsonResponse
from django.utils.text import slugify
from django.views.decorators.csrf import csrf_exempt
from django.conf import settings
from django.db import transaction

from frontend.models import (
    Champion, ChampionTranslation, Language,
    Ability, AbilityTranslation,
    ChampionSkin, ChampionSkinTranslation
)


def create_media_directories():
    """Medya dosyaları için gerekli dizinleri oluşturur"""
    media_root = getattr(settings, 'MEDIA_ROOT', 'public')
    print(f"Media root directory: {media_root}")

    # Ana şampiyon dizini
    champion_dir = os.path.join(media_root, 'champions')
    os.makedirs(champion_dir, exist_ok=True)
    print(f"Created champion directory: {champion_dir}")

    # Alt dizinler
    subdirs = ['skins', 'abilities', 'videos', 'splash', 'icons']
    for subdir in subdirs:
        full_path = os.path.join(champion_dir, subdir)
        os.makedirs(full_path, exist_ok=True)
        print(f"Created subdirectory: {full_path}")

    return True


def get_champion_id(champion_name):
    """Şampiyon adından ID'yi alır"""
    # Bazı şampiyonlar için özel karakterleri düzeltme
    name_mapping = {
        "Kai'Sa": "kaisa",
        "Kha'Zix": "khazix",
        "Vel'Koz": "velkoz",
        "Rek'Sai": "reksai",
        "Nunu & Willump": "nunu",
        "Wukong": "monkeyking",
        "Renata Glasc": "renata",
        "Bel'Veth": "belveth",
        "K'Sante": "ksante",
        "Cho'Gath": "chogath",
        "LeBlanc": "leblanc",
        "Kog'Maw": "kogmaw",
    }

    # Varsa özel eşleştirme kullan, yoksa adı küçült ve boşlukları kaldır
    if champion_name in name_mapping:
        return name_mapping[champion_name]

    # Ad işleme: boşlukları kaldır, küçült, özel karakterleri temizle
    return slugify(champion_name).replace('-', '')


def scrape_champion_details(champion_id, lang_code):
    """Belirli bir dilde şampiyon detaylarını çeker - __NEXT_DATA__ odaklı iyileştirilmiş versiyon"""
    # Dil kodlarını eşleştir
    lang_mapping = {
        'en': 'en-us',
        'tr': 'tr-tr',
        'de': 'de-de',
        'fr': 'fr-fr',
        'es': 'es-es',
        'it': 'it-it',
        'ru': 'ru-ru',
        'pt': 'pt-br',
        'br': 'pt-br',
        'nl': 'en-gb',  # Dutch için İngilizce (UK) kullan
        'jp': 'ja-jp',
        'kr': 'ko-kr',
        'zh': 'zh-tw'
    }

    site_lang = lang_mapping.get(lang_code, f'{lang_code}-{lang_code}')
    url = f"https://www.leagueoflegends.com/{site_lang}/champions/{champion_id}/"
    print(f"Fetching data from: {url} for language: {lang_code}")

    # Belirli dil için Accept-Language header'ı ekle
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': f'{site_lang},en-US;q=0.7,en;q=0.3',
    }

    try:
        response = requests.get(url, headers=headers, timeout=30)

        if response.status_code != 200:
            print(f"HTTP error {response.status_code} when fetching {url}")
            return None

        # __NEXT_DATA__ script'ini bul
        soup = BeautifulSoup(response.text, 'html.parser')
        next_data_script = soup.find('script', id='__NEXT_DATA__')

        if not next_data_script or not next_data_script.string:
            print(f"Could not find __NEXT_DATA__ for {champion_id} in {lang_code}")
            return None

        # JSON verisini ayrıştır
        next_data = json.loads(next_data_script.string)

        # Sonuç sözlüğünü başlat
        result = {
            'name': '',
            'title': '',
            'lore': '',
            'splash_art': '',
            'icon': '',
            'abilities': [],
            'skins': []
        }

        # Champion verilerine giden yol
        if 'props' in next_data and 'pageProps' in next_data['props'] and 'page' in next_data['props']['pageProps']:
            page_data = next_data['props']['pageProps']['page']
            blades = page_data.get('blades', [])

            # Character Masthead'den temel bilgileri al
            for blade in blades:
                if blade.get('type') == 'characterMasthead':
                    result['name'] = blade.get('title', champion_id.capitalize())
                    result['title'] = blade.get('subtitle', '')

                    # Lore/hikaye al
                    if 'description' in blade and 'body' in blade['description']:
                        result['lore'] = blade['description']['body']

                    # Splash art al
                    if 'backdrop' in blade and 'background' in blade['backdrop']:
                        bg = blade['backdrop']['background']
                        if 'url' in bg:
                            result['splash_art'] = bg['url']

                    break

            # Yetenek işleme - direk JSON'dan yetenkler için groups içeriğine odaklan
            for blade in blades:
                if blade.get('type') == 'iconTab':
                    for group in blade.get('groups', []):
                        ability = {}

                        # Yetenek içeriği al
                        if 'content' in group:
                            content = group['content']
                            ability['name'] = content.get('title', '')
                            ability['key'] = content.get('subtitle', '')

                            if 'description' in content and 'body' in content['description']:
                                ability['description'] = content['description']['body']

                            # Yetenek videosu
                            if 'media' in content and 'sources' in content['media'] and len(
                                    content['media']['sources']) > 0:
                                ability['video'] = content['media']['sources'][0].get('src', '')

                        # Yetenek resmi
                        if 'thumbnail' in group and 'url' in group['thumbnail']:
                            ability['thumbnail'] = group['thumbnail']['url']

                        # Temel veriler varsa sonuçlara ekle
                        if ability.get('name') and ability.get('key'):
                            result['abilities'].append(ability)
                            print(f"Found ability in {lang_code}: {ability['name']} ({ability['key']})")

            # Skins işleme - direk JSON'dan skin verilerine odaklan
            for blade in blades:
                if blade.get('type') == 'landingMediaCarousel':
                    for group in blade.get('groups', []):
                        skin = {}
                        skin['name'] = group.get('label', '')

                        # Skin resmini al
                        if 'content' in group and 'media' in group['content'] and 'url' in group['content']['media']:
                            skin['image'] = group['content']['media']['url']

                        # İsim ve resim varsa sonuçlara ekle
                        if skin.get('name') and skin.get('image'):
                            # Default skin'i atla
                            if skin['name'] != result['name']:
                                result['skins'].append(skin)
                                print(f"Found skin in {lang_code}: {skin['name']}")

            # İkon URL'sini ayarla - önce şampiyon ID'sini kullan
            champion_id = get_champion_id(result['name'])
            result['icon'] = f"https://ddragon.leagueoflegends.com/cdn/14.19.1/img/champion/{champion_id}.png"

            print(
                f"Successfully parsed {lang_code} data for {result['name']}: {len(result['abilities'])} abilities, {len(result['skins'])} skins")

            return result

        print(f"Could not find champion data in __NEXT_DATA__ for {champion_id} in {lang_code}")
        return None

    except Exception as e:
        print(f"Error scraping champion {champion_id} in {lang_code}: {str(e)}")
        import traceback
        traceback.print_exc()
        return None


def update_champion_abilities(champion, language, champion_details):
    """Şampiyon yeteneklerini günceller - JSON'dan gelen net veri yapısına optimize edildi"""
    updated_abilities = []

    if 'abilities' not in champion_details or not champion_details['abilities']:
        print(f"⚠️ No abilities found for {champion.name} in {language.code}")
        return updated_abilities

    print(f"Processing {len(champion_details['abilities'])} abilities for {champion.name} in {language.code}")

    # Yetenek anahtarları için standart haritalama
    key_map = {
        'PASSIVE': 'P',
        'Q': 'Q',
        'W': 'W',
        'E': 'E',
        'R': 'R'
    }

    for ability_data in champion_details['abilities']:
        ability_name = ability_data.get('name', '')
        ability_desc = ability_data.get('description', '')
        ability_key_raw = ability_data.get('key', '').upper()

        # İsim yoksa atla
        if not ability_name:
            continue

        print(f"Processing ability: {ability_name} ({ability_key_raw}) in {language.code}")

        # Yetenek anahtarını normalize et - JSON'dan gelen veriye göre daha basit
        ability_key = key_map.get(ability_key_raw, 'P')  # Varsayılan olarak P kullan

        # İngilizce dil için, ana yeteneği güncelle
        if language.code == 'en':
            try:
                ability, created = Ability.objects.update_or_create(
                    champion=champion,
                    ability_key=ability_key,
                    defaults={
                        'name': ability_name,
                        'description': ability_desc if ability_desc else ""
                    }
                )

                # Yetenek resmini indir
                if 'thumbnail' in ability_data and ability_data['thumbnail']:
                    image_url = ability_data['thumbnail']
                    image_path = f'public/champions/abilities/{champion.id}_{champion.name.lower().replace(" ", "_")}_{ability_key}.png'

                    img_downloaded = download_file(image_url, image_path)
                    if img_downloaded:
                        ability.image_url = image_path
                        ability.save(update_fields=['image_url'])
                        print(f"✓ Saved ability image: {image_path}")

                # Yetenek videosunu indir
                if 'video' in ability_data and ability_data['video']:
                    video_url = ability_data['video']
                    video_path = f'public/champions/videos/{champion.id}_{champion.name.lower().replace(" ", "_")}_{ability_key}.mp4'

                    video_downloaded = download_file(video_url, video_path)
                    print(f"Ability video download: {'✓' if video_downloaded else '×'}")

                status = 'created' if created else 'updated'
                updated_abilities.append({
                    'key': ability_key,
                    'name': ability_name,
                    'status': status,
                    'has_image': 'thumbnail' in ability_data,
                    'has_video': 'video' in ability_data
                })

                print(f"{status.capitalize()} ability: {ability_name} ({ability_key})")

            except Exception as e:
                print(f"Error updating ability {ability_name}: {e}")
                continue

        # Herhangi bir dil için (İngilizce dahil), çevirileri güncelle
        try:
            # Yeteneği bul
            try:
                ability = Ability.objects.get(champion=champion, ability_key=ability_key)
            except Ability.DoesNotExist:
                if language.code == 'en':
                    print(f"Error: Failed to find ability that should exist")
                    continue
                else:
                    # İngilizce olmayanlar için, yoksa oluştur
                    print(f"Creating missing ability {ability_name} for translation")
                    ability = Ability.objects.create(
                        champion=champion,
                        ability_key=ability_key,
                        name=ability_name,
                        description=ability_desc if ability_desc else ""
                    )

            # Çeviriyi oluştur/güncelle
            translation, created = AbilityTranslation.objects.update_or_create(
                ability=ability,
                language=language,
                defaults={
                    'name': ability_name,
                    'description': ability_desc if ability_desc else ''
                }
            )

            updated_abilities.append({
                'key': ability_key,
                'name': ability_name,
                'language': language.code,
                'status': 'translation_created' if created else 'translation_updated'
            })

            print(f"{'✓ Created' if created else '✓ Updated'} {language.code} translation for {ability_name}")

        except Exception as e:
            print(f"Error updating translation for {ability_name} in {language.code}: {e}")
            import traceback
            print(traceback.format_exc())

    return updated_abilities


def update_skin_translations(champion, language, champion_details):
    """Kostüm çevirilerini günceller - JSON'dan gelen net veri yapısına optimize edildi"""
    updated_translations = []

    if 'skins' not in champion_details or not champion_details['skins']:
        print(f"No skins found for {champion.name} in {language.code}")
        return updated_translations

    print(f"Processing {len(champion_details['skins'])} skin translations for {champion.name} in {language.code}")

    # Bu şampiyon için tüm kostümleri al
    champion_skins = ChampionSkin.objects.filter(champion=champion)

    # Kostüm isimlendirmelerini karşılaştırmayı kolaylaştıracak fonksiyon
    def normalize_skin_name(name):
        return name.lower().replace(champion.name.lower(), "").strip()

    # İngilizce kostüm adları ile kostüm nesnelerini eşleştiren bir harita oluştur
    skin_map = {}
    for skin in champion_skins:
        normalized = normalize_skin_name(skin.name)
        skin_map[normalized] = skin
        # Tam adı da ekle
        skin_map[skin.name.lower()] = skin

    for skin_data in champion_details['skins']:
        translated_name = skin_data.get('name', '')

        if not translated_name:
            continue

        # Kostüm adını normalize et
        normalized_name = normalize_skin_name(translated_name)

        # İlk olarak tam eşleşmeyi dene
        if translated_name.lower() in skin_map:
            skin = skin_map[translated_name.lower()]
        # Sonra normalize edilmiş adı dene
        elif normalized_name in skin_map:
            skin = skin_map[normalized_name]
        else:
            # Eşleşme bulunamazsa, benzerlik veya sıra indeksi ile en iyi eşleşeni bul
            best_match = None
            best_score = 0

            # Basit benzerlik kontrolü
            for en_name in skin_map:
                # Eğer çevirilen kostüm adı İngilizce kostüm adını içeriyorsa veya tam tersi
                if normalized_name in en_name or en_name in normalized_name:
                    score = len(en_name) / max(len(normalized_name), len(en_name))
                    if score > best_score:
                        best_score = score
                        best_match = skin_map[en_name]

            if best_match:
                skin = best_match
            elif champion_skins.exists():
                # Sıra numarası bazlı eşleme
                skin_index = champion_details['skins'].index(skin_data)
                if skin_index < champion_skins.count():
                    skin = champion_skins[skin_index]
                else:
                    # İlk kostümü kullan
                    skin = champion_skins.first()
            else:
                print(f"No skins found for champion, cannot create translation")
                continue

        # Çeviriyi ekle
        try:
            ChampionSkinTranslation.objects.update_or_create(
                skin=skin,
                language=language,
                defaults={
                    'name': translated_name
                }
            )
            updated_translations.append({
                'skin': skin.name,
                'translation': translated_name,
                'language': language.code
            })
            print(f"Added translation for '{skin.name}' in {language.code}: '{translated_name}'")
        except Exception as e:
            print(f"Error adding translation for {translated_name}: {str(e)}")

    return updated_translations


def parse_champion_page(soup, champion_id, lang_code):
    """Parse the champion page HTML to extract data"""
    result = {}

    # Extract champion data from JavaScript
    script_tags = soup.find_all('script')
    for script in script_tags:
        if script.string and '__NEXT_DATA__' in script.get('id', ''):
            try:
                data = json.loads(script.string)
                if 'props' in data and 'pageProps' in data['props'] and 'page' in data['props']['pageProps']:
                    # Process page data to extract champion info
                    page_data = data['props']['pageProps']['page']

                    # Extract from blades if available
                    if 'blades' in page_data:
                        blades = page_data['blades']

                        # Get champion basic info
                        for blade in blades:
                            if blade.get('type') == 'characterMasthead':
                                result['name'] = blade.get('title', champion_id.capitalize())
                                result['title'] = blade.get('subtitle', '')

                                if 'description' in blade and 'body' in blade['description']:
                                    result['lore'] = blade['description']['body']

                                if 'featuredImage' in blade and 'url' in blade['featuredImage']:
                                    result['splash_art'] = blade['featuredImage']['url']

                                break

                        # Extract abilities
                        for blade in blades:
                            if blade.get('type') == 'iconTab' and 'abilities' in blade.get('header', {}).get('title',
                                                                                                             '').lower():
                                result['abilities'] = []

                                for group in blade.get('groups', []):
                                    if 'content' not in group:
                                        continue

                                    ability = {
                                        'name': group['content'].get('title', ''),
                                        'key': group['content'].get('subtitle', ''),
                                        'description': group['content'].get('description', {}).get('body', '')
                                    }

                                    # Get thumbnail
                                    if 'thumbnail' in group and 'url' in group['thumbnail']:
                                        ability['thumbnail'] = group['thumbnail']['url']

                                    # Get video
                                    if 'media' in group['content'] and 'sources' in group['content']['media']:
                                        sources = group['content']['media']['sources']
                                        if sources and len(sources) > 0:
                                            ability['video'] = sources[0].get('src', '')

                                    result['abilities'].append(ability)

                                break

                        # Extract skins
                        for blade in blades:
                            if blade.get('type') == 'landingMediaCarousel' and 'skins' in blade.get('header', {}).get(
                                    'title', '').lower():
                                result['skins'] = []

                                for group in blade.get('groups', []):
                                    if 'content' not in group or 'media' not in group['content']:
                                        continue

                                    skin = {
                                        'name': group.get('label', ''),
                                        'image': group['content']['media'].get('url', '')
                                    }

                                    if skin['name'] and skin['image']:
                                        result['skins'].append(skin)

                                break
            except Exception as e:
                print(f"Error parsing script tag: {str(e)}")

    # Use Data Dragon as fallback for missing data
    if not result.get('splash_art'):
        result['splash_art'] = f"https://ddragon.leagueoflegends.com/cdn/img/champion/splash/{champion_id}_0.jpg"

    if not result.get('icon'):
        result['icon'] = f"https://ddragon.leagueoflegends.com/cdn/latest/img/champion/{champion_id}.png"

    return result


def get_champion_from_data_dragon(champion_id, lang_code):
    """Get champion data from Data Dragon API with improved ability extraction"""
    # Map language codes
    lang_mapping = {
        'en': 'en_US',
        'tr': 'tr_TR',
        'de': 'de_DE',
        'fr': 'fr_FR',
        'es': 'es_ES',
        'it': 'it_IT',
        'ru': 'ru_RU',
        'pt': 'pt_BR',
        'br': 'pt_BR',
        'jp': 'ja_JP',
        'kr': 'ko_KR',
        'zh': 'zh_CN'
    }

    try:
        # Get the latest version
        versions_url = "https://ddragon.leagueoflegends.com/api/versions.json"
        versions_response = requests.get(versions_url, timeout=10)

        if versions_response.status_code != 200:
            latest_version = "14.19.1"  # Fallback to a recent version
            print(f"Couldn't get latest version, using fallback: {latest_version}")
        else:
            latest_version = versions_response.json()[0]
            print(f"Using Data Dragon version: {latest_version}")

        # Get champion data
        data_lang = lang_mapping.get(lang_code, 'en_US')
        url = f"https://ddragon.leagueoflegends.com/cdn/{latest_version}/data/{data_lang}/champion/{champion_id}.json"

        print(f"Fetching champion data from: {url}")
        response = requests.get(url, timeout=15)

        if response.status_code != 200:
            print(f"Data Dragon API error: HTTP {response.status_code}")
            # Try the generic champion list as fallback
            fallback_url = f"https://ddragon.leagueoflegends.com/cdn/{latest_version}/data/{data_lang}/champion.json"
            print(f"Trying fallback URL: {fallback_url}")

            fallback_response = requests.get(fallback_url, timeout=15)
            if fallback_response.status_code != 200:
                print(f"Fallback also failed: HTTP {fallback_response.status_code}")
                return None

            fallback_data = fallback_response.json()
            if 'data' not in fallback_data or champion_id not in fallback_data['data']:
                print(f"Champion {champion_id} not found in fallback data")
                return None

            # We found basic data but not detailed - create partial result
            champion_basic = fallback_data['data'][champion_id]
            result = {
                'name': champion_basic.get('name', champion_id),
                'title': champion_basic.get('title', ''),
                'splash_art': f"https://ddragon.leagueoflegends.com/cdn/img/champion/splash/{champion_id}_0.jpg",
                'icon': f"https://ddragon.leagueoflegends.com/cdn/{latest_version}/img/champion/{champion_id}.png",
                'abilities': [],
                'skins': []
            }
            print(f"Created partial data for {champion_id} from fallback")
            return result

        # Process full champion data
        data = response.json()
        if 'data' not in data or champion_id not in data['data']:
            print(f"No champion data found in API response")
            return None

        champion_data = data['data'][champion_id]

        result = {
            'name': champion_data.get('name', champion_id),
            'title': champion_data.get('title', ''),
            'lore': champion_data.get('lore', ''),
            'splash_art': f"https://ddragon.leagueoflegends.com/cdn/img/champion/splash/{champion_id}_0.jpg",
            'icon': f"https://ddragon.leagueoflegends.com/cdn/{latest_version}/img/champion/{champion_id}.png",
            'abilities': [],
            'skins': []
        }

        # Get abilities with better key mapping
        passive = champion_data.get('passive', {})
        if passive:
            result['abilities'].append({
                'name': passive.get('name', 'Passive'),
                'key': 'P',  # Explicitly use P for passive
                'description': passive.get('description', ''),
                'thumbnail': f"https://ddragon.leagueoflegends.com/cdn/{latest_version}/img/passive/{passive.get('image', {}).get('full', '')}"
            })
            print(f"Added passive ability: {passive.get('name', 'Passive')}")

        # Add QWER abilities
        ability_keys = ['Q', 'W', 'E', 'R']
        for i, spell in enumerate(champion_data.get('spells', [])):
            if i < len(ability_keys):
                key = ability_keys[i]
                result['abilities'].append({
                    'name': spell.get('name', f'Ability {key}'),
                    'key': key,
                    'description': spell.get('description', ''),
                    'thumbnail': f"https://ddragon.leagueoflegends.com/cdn/{latest_version}/img/spell/{spell.get('image', {}).get('full', '')}"
                })
                print(f"Added ability {key}: {spell.get('name', f'Ability {key}')}")

        # Get skins
        for skin in champion_data.get('skins', []):
            skin_num = skin.get('num', 0)
            skin_name = skin.get('name', f'Skin {skin_num}')

            # Skip default skin
            if skin_num == 0 and (skin_name == 'default' or skin_name == champion_data.get('name', '')):
                continue

            result['skins'].append({
                'name': skin_name,
                'image': f"https://ddragon.leagueoflegends.com/cdn/img/champion/splash/{champion_id}_{skin_num}.jpg"
            })
            print(f"Added skin: {skin_name}")

        print(
            f"Successfully extracted data for {champion_id} with {len(result['abilities'])} abilities and {len(result['skins'])} skins")
        return result

    except Exception as e:
        print(f"Error getting champion from Data Dragon: {str(e)}")
        import traceback
        traceback.print_exc()
        return None


def update_champion_story(champion, language, champion_details):
    """Şampiyon hikayesini günceller (ana tabloyu ve çeviriyi)"""
    if 'lore' in champion_details and champion_details['lore']:
        try:
            # If this is English, update the main champion record too
            if language.code == 'en':
                champion.lore = champion_details['lore']
                champion.title = champion_details.get('title', '')
                champion.save(update_fields=['lore', 'title'])
                print(f"✓ Updated main champion lore and title for {champion.name}")

            # Update or create the translation
            ChampionTranslation.objects.update_or_create(
                champion=champion,
                language=language,
                defaults={
                    'lore': champion_details.get('lore', ''),
                    'name': champion_details.get('name', champion.name),
                    'title': champion_details.get('title', '')
                }
            )
            print(f"✓ Updated champion lore translation for {champion.name} in {language.code}")
            return True
        except Exception as e:
            print(f"× Error updating story for {champion.name} in {language.code}: {str(e)}")
            return False
    return False


def update_champion_skins(champion, champion_details, is_primary=False):
    """Şampiyon kostümlerini ana tabloya ekler (sadece İngilizce)"""
    added_skins = []

    if 'skins' in champion_details and champion_details['skins'] and is_primary:
        # İngilizce dil nesnesini al
        english, _ = Language.objects.get_or_create(code='en')

        print(f"Processing {len(champion_details['skins'])} skins for {champion.name}")

        for skin_data in champion_details['skins']:
            skin_name = skin_data.get('name', '')
            skin_image = skin_data.get('image', '')

            if not skin_image or not skin_name or skin_name == champion.name:
                if skin_name == champion.name:
                    print(f"Skipping default skin: {skin_name}")
                else:
                    print(f"Skipping skin with missing data: {skin_name} - {skin_image}")
                continue

            print(f"Processing skin: {skin_name} with image: {skin_image}")

            # Create sanitized name for file paths
            sanitized_name = slugify(skin_name).replace("-", "_")
            file_path = f'public/champions/skins/{champion.id}_{champion.name.lower().replace(" ", "_")}_{sanitized_name}.jpg'

            # Download the skin image first
            download_result = download_file(skin_image, file_path)

            if download_result:
                try:
                    # Kostümü ana tabloya ekle
                    skin, created = ChampionSkin.objects.update_or_create(
                        champion=champion,
                        name=skin_name,
                        defaults={
                            'image_url': file_path  # Use local path
                        }
                    )

                    # İngilizce çeviriyi ekle - bu gerçekten gerekli mi?
                    # Ana tabloya zaten İngilizce adı ekleniyor
                    ChampionSkinTranslation.objects.update_or_create(
                        skin=skin,
                        language=english,
                        defaults={
                            'name': skin_name
                        }
                    )

                    status = 'created' if created else 'updated'
                    added_skins.append({
                        'name': skin_name,
                        'status': status,
                        'image_downloaded': download_result,
                        'image_path': file_path
                    })

                    print(f"Skin {status}: {skin_name}, image downloaded and saved to {file_path}")
                except Exception as e:
                    print(f"Error processing skin {skin_name}: {str(e)}")
                    import traceback
                    print(traceback.format_exc())
            else:
                print(f"Failed to download skin image for {skin_name}, skipping database entry")

    else:
        if 'skins' not in champion_details:
            print(f"No skins found in data for {champion.name}")
        elif not champion_details['skins']:
            print(f"Empty skins list for {champion.name}")
        elif not is_primary:
            print(f"Skipping skins for non-primary language")

    return added_skins


# Geliştirilmiş yetenek anahtarı normalizasyonu - Asya dillerini destekleyen versiyon
def normalize_ability_key(ability_key_raw, language_code=None):
    """Yetenek anahtarını standart forma dönüştürür (Çoklu dil desteği ile)"""

    # Önce büyük harfe çevir ve boşlukları temizle
    ability_key_raw = ability_key_raw.upper().strip()

    # P (Pasif) için kontrol - tüm dilleri kapsayacak şekilde
    passive_patterns = [
        # Latin alfabesi
        'P', 'PAS', 'PASSIVE', 'PASSIF', 'PASIF', 'PASİF', 'PASIVA', 'PASSIVA',
        # Çince (Basitleştirilmiş ve Geleneksel)
        '被动', '被動', '天賦', '天赋',
        # Japonca
        'パッシブ', 'パシブ', '受動的',
        # Korece
        '패시브', '기본지속효과',

        'パッシブ', 'パシブ', '受動的', '固有能力',
        # Rusça
        'ПАССИВНАЯ', 'ПАССИВ'
    ]

    # Q için kontrol
    q_patterns = [
        'Q', 'Q技能', 'Q技', 'Qスキル', 'Q스킬', 'К',  'Q', 'Q技能', 'Q技', 'Qスキル', 'Q스킬', 'К'
    ]

    # W için kontrol
    w_patterns = [
        'W', 'W技能', 'W技', 'Wスキル', 'W스킬', 'В'
    ]

    # E için kontrol
    e_patterns = [
        'E', 'E技能', 'E技', 'Eスキル', 'E스킬', 'Е'
    ]

    # R (Ultimate) için kontrol
    ultimate_patterns = [
        'R', 'ULT', 'ULTIMATE', 'ULTIME', 'DEFINITIVO',
        # Çince
        'R技能', 'R技', '大招', '终极技能', '終極技能',
        # Japonca
        'アルティメット', 'Rスキル', 'スキル', '必殺技',
        # Korece
        '궁극기', 'R스킬', '궁극',
        # Rusça
        'УЛЬТА', 'УЛЬТИМЕЙТ', 'Р'
    ]

    # Her bir pattern listesi için kontrol et
    for pattern in passive_patterns:
        if pattern in ability_key_raw:
            return 'P'

    for pattern in q_patterns:
        if pattern in ability_key_raw:
            return 'Q'

    for pattern in w_patterns:
        if pattern in ability_key_raw:
            return 'W'

    for pattern in e_patterns:
        if pattern in ability_key_raw:
            return 'E'

    for pattern in ultimate_patterns:
        if pattern in ability_key_raw:
            return 'R'

    # Dil bazlı pozisyonel kontrol
    # Eğer dil kodu sağlanmışsa ve anahtar sadece 1 karakterse
    if language_code and len(ability_key_raw) == 1:
        # Rusça için Кириллик karakterleri kontrol et
        if language_code in ['ru', 'ru-ru']:
            russian_map = {'К': 'Q', 'В': 'W', 'Е': 'E', 'Р': 'R'}
            if ability_key_raw in russian_map:
                return russian_map[ability_key_raw]

        # Çince için pozisyon bazlı kontrol
        if language_code in ['zh-cn', 'zh-tw', 'zh']:
            # Çince'de genellikle 1, 2, 3, 4 sıralaması kullanılır
            position_map = {'1': 'Q', '2': 'W', '3': 'E', '4': 'R'}
            if ability_key_raw in position_map:
                return position_map[ability_key_raw]

    # Hiçbir pattern eşleşmezse, kontrol et - belki sayısal değerdir
    # Bazı diller 1,2,3,4 sıralaması kullanır
    if ability_key_raw.isdigit():
        # Varsayalım ki 1=Q, 2=W, 3=E, 4=R
        position_map = {'1': 'Q', '2': 'W', '3': 'E', '4': 'R'}
        if ability_key_raw in position_map:
            return position_map[ability_key_raw]

    # Hala eşleşme yoksa, bilinmeyen yetenek
    return 'O'


def update_champion_media(champion, champion_details):
    """Şampiyon ana resimlerini günceller - öncelikle ikon sorununa odaklanır"""
    updated_media = {}

    # =================== ICON HANDLING ===================
    # Force icon download regardless of previous attempts
    champion_id = get_champion_id(champion.name)

    # Create multiple possible icon paths to try
    icon_urls = [
        # Use primary Data Dragon URL (most reliable)
        f"https://ddragon.leagueoflegends.com/cdn/14.19.1/img/champion/{champion_id}.png",

        # Try alternative version
        f"https://ddragon.leagueoflegends.com/cdn/13.1.1/img/champion/{champion_id}.png",

        # Try latest version
        f"https://ddragon.leagueoflegends.com/cdn/latest/img/champion/{champion_id}.png",

        # Try Wiki format
        f"https://wiki.leagueoflegends.com/en-us/images/thumb/{champion_id.capitalize()}_OriginalSquare.png/128px-{champion_id.capitalize()}_OriginalSquare.png",

        # Try alternative Wiki format for complex names
        f"https://wiki.leagueoflegends.com/en-us/images/thumb/{champion.name.replace(' ', '_')}_OriginalSquare.png/128px-{champion.name.replace(' ', '_')}_OriginalSquare.png"
    ]

    # Ensure icon_path includes champion ID for uniqueness
    icon_path = f'public/champions/icons/{champion.id}_{champion.name.lower().replace(" ", "_")}_icon.png'

    # Try each URL until one succeeds
    icon_downloaded = False
    successful_url = None

    for url in icon_urls:
        print(f"Trying to download icon from: {url}")

        try:
            # Skip verify for SSL issues
            response = requests.get(url, stream=True, timeout=30, verify=False)

            if response.status_code == 200:
                # Ensure directory exists
                os.makedirs(os.path.dirname(icon_path), exist_ok=True)

                # Write file to disk
                with open(icon_path, 'wb') as f:
                    for chunk in response.iter_content(8192):
                        f.write(chunk)

                # Verify file was downloaded correctly
                if os.path.exists(icon_path) and os.path.getsize(icon_path) > 0:
                    icon_downloaded = True
                    successful_url = url
                    print(f"✓ Successfully downloaded icon: {os.path.getsize(icon_path)} bytes")
                    break
                else:
                    print(f"× Icon file is empty: {icon_path}")
            else:
                print(f"× HTTP error {response.status_code} for {url}")

        except Exception as e:
            print(f"× Error downloading from {url}: {e}")

    # If download successful, update database
    if icon_downloaded:
        updated_media['icon'] = {
            'url': successful_url,
            'path': icon_path,
            'downloaded': True
        }

        try:
            # Explicitly update the image_main field
            champion.image_main = icon_path
            champion.save(update_fields=['image_main'])
            print(f"✓ Updated champion.image_main: {icon_path}")

            # Double-check the update was successful
            refreshed_champion = Champion.objects.get(id=champion.id)
            print(f"✓ Verified database update: image_main = {refreshed_champion.image_main}")
        except Exception as e:
            print(f"× Error updating database: {e}")
    else:
        print(f"× Failed to download icon for {champion.name} after trying all sources")

    # =================== SPLASH ART HANDLING ===================
    # Continue with splash art download
    if 'splash_art' in champion_details and champion_details['splash_art']:
        splash_url = champion_details['splash_art']
        splash_path = f'public/champions/splash/{champion.id}_{champion.name.lower().replace(" ", "_")}_splash.jpg'

        print(f"Downloading splash art from: {splash_url}")
        try:
            # Skip verify for SSL issues
            response = requests.get(splash_url, stream=True, timeout=30, verify=False)

            if response.status_code == 200:
                # Ensure directory exists
                os.makedirs(os.path.dirname(splash_path), exist_ok=True)

                # Write file to disk
                with open(splash_path, 'wb') as f:
                    for chunk in response.iter_content(8192):
                        f.write(chunk)

                # Verify file was downloaded correctly
                if os.path.exists(splash_path) and os.path.getsize(splash_path) > 0:
                    updated_media['splash_art'] = {
                        'url': splash_url,
                        'path': splash_path,
                        'downloaded': True
                    }

                    # Update database
                    champion.splash_art = splash_path
                    champion.save(update_fields=['splash_art'])
                    print(f"✓ Updated champion splash art: {splash_path}")
                else:
                    print(f"× Splash art file is empty: {splash_path}")
            else:
                print(f"× HTTP error {response.status_code} for splash art")

        except Exception as e:
            print(f"× Error downloading splash art: {e}")

    return updated_media


def download_file(url, filepath):
    """URL'den dosyayı belirtilen yola indirir - Geliştirilmiş hata kontrolü"""
    try:
        if not url or url.strip() == '':
            print(f"× Empty URL for {filepath}")
            return False

        # Create directory if needed
        directory = os.path.dirname(filepath)
        if not os.path.exists(directory):
            os.makedirs(directory, exist_ok=True)

        # Skip if already exists
        if os.path.exists(filepath) and os.path.getsize(filepath) > 0:
            print(f"✓ File already exists: {filepath}")
            return True

        print(f"Downloading: {url}")

        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
            'Referer': 'https://www.leagueoflegends.com/'
        }

        # Try with retries
        for attempt in range(3):
            try:
                # Disable SSL verification for some sites
                response = requests.get(url, stream=True, headers=headers, timeout=30, verify=False)

                if response.status_code == 200:
                    with open(filepath, 'wb') as f:
                        for chunk in response.iter_content(8192):
                            f.write(chunk)

                    # Verify downloaded properly
                    if os.path.exists(filepath) and os.path.getsize(filepath) > 0:
                        print(f"✓ Downloaded: {os.path.getsize(filepath)} bytes to {filepath}")
                        return True
                    else:
                        print(f"× Empty file: {filepath}")
                else:
                    print(f"× HTTP error {response.status_code} for {url}")

                # Retry after delay
                time.sleep(1)

            except Exception as e:
                print(f"× Download error (attempt {attempt + 1}/3): {e}")
                time.sleep(2)

        return False

    except Exception as e:
        print(f"× Download error: {e}")
        return False


@csrf_exempt
def update_champions(request):
    """API endpoint to update champions, their stories, skins and abilities"""
    if request.method != 'POST':
        return JsonResponse({'error': 'Only POST method is allowed'}, status=405)

    # Parse request parameters
    data = json.loads(request.body) if request.body else {}
    champion_names = data.get('champions', [])
    languages = data.get('languages', ['en', 'tr', 'de', 'fr', 'es'])
    debug_mode = data.get('debug', True)

    if debug_mode:
        print(f"Starting update for champions: {champion_names if champion_names else 'all'}")
        print(f"Languages: {languages}")

    # Create media directories
    create_media_directories()

    # Get champions to update
    if champion_names:
        champions = Champion.objects.filter(name__in=champion_names)
    else:
        champions = Champion.objects.all()[:5]  # Limit for testing

    results = []
    error_count = 0

    # Process each champion
    for champion in champions:
        champion_result = {
            'name': champion.name,
            'languages': {},
            'error': None,
            'skins': [],
            'abilities': [],
            'media': {}
        }

        try:
            # Get champion ID
            champion_id = get_champion_id(champion.name)
            if debug_mode:
                print(f"\n=== Processing champion: {champion.name} (ID: {champion_id}) ===")

            # Process each language
            for lang_code in languages:
                try:
                    # Get language object
                    language, _ = Language.objects.get_or_create(code=lang_code)

                    # Scrape champion data for this language
                    champion_details = scrape_champion_details(champion_id, lang_code)

                    if champion_details:
                        # Process with transaction
                        with transaction.atomic():
                            # If this is English, update core champion data
                            if lang_code == 'en':
                                # Update media (icons/splash art)
                                champion_result['media'] = update_champion_media(champion, champion_details)

                                # Update abilities
                                abilities = update_champion_abilities(champion, language, champion_details)
                                champion_result['abilities'].extend(abilities)

                                # Update skins
                                skins = update_champion_skins(champion, champion_details, is_primary=True)
                                champion_result['skins'].extend(skins)

                                # Update story/lore
                                story_updated = update_champion_story(champion, language, champion_details)
                                champion_result['story_updated'] = story_updated

                                champion_result['languages']['en'] = {
                                    'status': 'success',
                                    'skin_count': len(skins),
                                    'ability_count': len(abilities) // 2,  # Each ability counted twice
                                    'media_updated': bool(champion_result['media']),
                                    'story_updated': story_updated
                                }
                            else:
                                # Update translations only
                                story_updated = update_champion_story(champion, language, champion_details)
                                skin_translations = update_skin_translations(champion, language, champion_details)
                                ability_translations = update_champion_abilities(champion, language, champion_details)

                                champion_result['languages'][lang_code] = {
                                    'status': 'success',
                                    'story_updated': story_updated,
                                    'skin_translations': len(skin_translations),
                                    'ability_translations': len(ability_translations)
                                }

                        print(f"✓ Successfully processed {lang_code} data for {champion.name}")
                    else:
                        champion_result['languages'][lang_code] = {
                            'status': 'failed',
                            'error': f'Could not fetch data for {lang_code}'
                        }
                        error_count += 1
                        print(f"× Failed to get {lang_code} data for {champion.name}")

                except Exception as e:
                    champion_result['languages'][lang_code] = {
                        'status': 'error',
                        'error': str(e)
                    }
                    error_count += 1
                    print(f"× Error processing {lang_code} for {champion.name}: {e}")
                    import traceback
                    print(traceback.format_exc())

                # Add delay between languages
                time.sleep(1)

        except Exception as e:
            champion_result['error'] = str(e)
            error_count += 1
            print(f"× Error processing champion {champion.name}: {e}")
            import traceback
            print(traceback.format_exc())

        results.append(champion_result)

        # Add delay between champions
        time.sleep(2)

    return JsonResponse({
        'success': error_count == 0,
        'champions_updated': len(results),
        'error_count': error_count,
        'results': results
    })