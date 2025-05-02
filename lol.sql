-- MySQL için veritabanı oluştur
CREATE DATABASE lol_game CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE lol_game;

-- Diller tablosu
CREATE TABLE languages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(5) NOT NULL,  -- 'en', 'tr', 'fr', vs.
    name VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB;

-- Şampiyonlar ana tablosu (İngilizce temel veri)
CREATE TABLE champions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    slug VARCHAR(100) NOT NULL UNIQUE ,         -- İngilizce isim
    name VARCHAR(100) NOT NULL,         -- İngilizce isim
    title VARCHAR(100),                 -- İngilizce unvan
    release_year INT,
    difficulty ENUM('Easy', 'Medium', 'Hard'),
    lore TEXT,                          -- İngilizce hikaye
    image_main VARCHAR(255),
    splash_art VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Şampiyon çevirileri tablosu
CREATE TABLE champion_translations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    champion_id INT,
    language_id INT,
    name VARCHAR(100) NOT NULL,         -- Çevrilmiş isim
    title VARCHAR(100),                 -- Çevrilmiş unvan
    lore TEXT,                          -- Çevrilmiş hikaye
    meta_description TEXT,                          -- Çevrilmiş hikaye
    FOREIGN KEY (champion_id) REFERENCES champions(id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES languages(id) ON DELETE CASCADE,
    UNIQUE KEY (champion_id, language_id)
) ENGINE=InnoDB;

-- Pozisyonlar tablosu (İngilizce temel veri)
CREATE TABLE positions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL           -- 'Top', 'Jungle', 'Mid', 'ADC', 'Support'
) ENGINE=InnoDB;

-- Pozisyon çevirileri
CREATE TABLE position_translations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    position_id INT,
    language_id INT,
    name VARCHAR(50) NOT NULL,
    FOREIGN KEY (position_id) REFERENCES positions(id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES languages(id) ON DELETE CASCADE,
    UNIQUE KEY (position_id, language_id)
) ENGINE=InnoDB;

-- Şampiyon-Pozisyon ilişkisi (many-to-many)
CREATE TABLE champion_positions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    champion_id INT,
    position_id INT,
    is_primary BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (champion_id) REFERENCES champions(id) ON DELETE CASCADE,
    FOREIGN KEY (position_id) REFERENCES positions(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Türler tablosu (İngilizce temel veri)
CREATE TABLE species (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL           -- 'Human', 'Yordle', 'Vastaya', etc.
) ENGINE=InnoDB;

-- Tür çevirileri
CREATE TABLE species_translations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    species_id INT,
    language_id INT,
    name VARCHAR(50) NOT NULL,
    FOREIGN KEY (species_id) REFERENCES species(id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES languages(id) ON DELETE CASCADE,
    UNIQUE KEY (species_id, language_id)
) ENGINE=InnoDB;

-- Şampiyon-Tür ilişkisi (many-to-many)
CREATE TABLE champion_species (
    id INT AUTO_INCREMENT PRIMARY KEY,
    champion_id INT,
    species_id INT,
    is_primary BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (champion_id) REFERENCES champions(id) ON DELETE CASCADE,
    FOREIGN KEY (species_id) REFERENCES species(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Kaynaklar tablosu (İngilizce temel veri)
CREATE TABLE resources (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL           -- 'Mana', 'Energy', 'Rage', etc.
) ENGINE=InnoDB;

-- Kaynak çevirileri
CREATE TABLE resource_translations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    resource_id INT,
    language_id INT,
    name VARCHAR(50) NOT NULL,
    FOREIGN KEY (resource_id) REFERENCES resources(id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES languages(id) ON DELETE CASCADE,
    UNIQUE KEY (resource_id, language_id)
) ENGINE=InnoDB;

-- Şampiyon-Kaynak ilişkisi (many-to-many)
CREATE TABLE champion_resources (
    id INT AUTO_INCREMENT PRIMARY KEY,
    champion_id INT,
    resource_id INT,
    FOREIGN KEY (champion_id) REFERENCES champions(id) ON DELETE CASCADE,
    FOREIGN KEY (resource_id) REFERENCES resources(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Dövüş menzilleri tablosu (İngilizce temel veri)
CREATE TABLE combat_ranges (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL           -- 'Melee', 'Ranged', 'Hybrid'
) ENGINE=InnoDB;

-- Menzil çevirileri
CREATE TABLE combat_range_translations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    combat_range_id INT,
    language_id INT,
    name VARCHAR(50) NOT NULL,
    FOREIGN KEY (combat_range_id) REFERENCES combat_ranges(id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES languages(id) ON DELETE CASCADE,
    UNIQUE KEY (combat_range_id, language_id)
) ENGINE=InnoDB;

-- Şampiyon-Menzil ilişkisi (many-to-many)
CREATE TABLE champion_combat_ranges (
    id INT AUTO_INCREMENT PRIMARY KEY,
    champion_id INT,
    combat_range_id INT,
    is_primary BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (champion_id) REFERENCES champions(id) ON DELETE CASCADE,
    FOREIGN KEY (combat_range_id) REFERENCES combat_ranges(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Bölgeler tablosu (İngilizce temel veri)
CREATE TABLE regions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,          -- 'Ionia', 'Noxus', etc.
    description TEXT                    -- İngilizce açıklama
) ENGINE=InnoDB;

-- Bölge çevirileri
CREATE TABLE region_translations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    region_id INT,
    language_id INT,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    FOREIGN KEY (region_id) REFERENCES regions(id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES languages(id) ON DELETE CASCADE,
    UNIQUE KEY (region_id, language_id)
) ENGINE=InnoDB;

-- Şampiyon-Bölge ilişkisi (many-to-many)
CREATE TABLE champion_regions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    champion_id INT,
    region_id INT,
    is_primary BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (champion_id) REFERENCES champions(id) ON DELETE CASCADE,
    FOREIGN KEY (region_id) REFERENCES regions(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Şampiyon yetenekleri (İngilizce temel veri)
CREATE TABLE abilities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    champion_id INT,
    name VARCHAR(100) NOT NULL,         -- İngilizce yetenek adı
    ability_key VARCHAR(10) NOT NULL,
    description TEXT,                   -- İngilizce açıklama
    cooldown VARCHAR(50),
    cost VARCHAR(50),
    damage_type VARCHAR(20),
    image_url VARCHAR(255),
    FOREIGN KEY (champion_id) REFERENCES champions(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Yetenek çevirileri
CREATE TABLE ability_translations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ability_id INT,
    language_id INT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    FOREIGN KEY (ability_id) REFERENCES abilities(id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES languages(id) ON DELETE CASCADE,
    UNIQUE KEY (ability_id, language_id)
) ENGINE=InnoDB;

-- Eşyalar tablosu (İngilizce temel veri)
CREATE TABLE items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,         -- İngilizce eşya adı
    cost INT,
    description TEXT,                   -- İngilizce açıklama
    image_url VARCHAR(255)
) ENGINE=InnoDB;

-- Eşya çevirileri
CREATE TABLE item_translations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT,
    language_id INT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES languages(id) ON DELETE CASCADE,
    UNIQUE KEY (item_id, language_id)
) ENGINE=InnoDB;

-- Eşya istatistikleri
CREATE TABLE item_stats (
    id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT,
    stat_name VARCHAR(50),              -- İngilizce stat adı
    value VARCHAR(50),
    FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Oyun modları (İngilizce temel veri)
CREATE TABLE game_modes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,          -- 'Easy', 'Medium', 'Hard'
    description TEXT,                   -- İngilizce açıklama
    max_attempts INT
) ENGINE=InnoDB;

-- Oyun modu çevirileri
CREATE TABLE game_mode_translations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    game_mode_id INT,
    language_id INT,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    FOREIGN KEY (game_mode_id) REFERENCES game_modes(id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES languages(id) ON DELETE CASCADE,
    UNIQUE KEY (game_mode_id, language_id)
) ENGINE=InnoDB;

-- Kullanıcılar
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    password_hash VARCHAR(255),
    language_id INT,                    -- Tercih edilen dil
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (language_id) REFERENCES languages(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Oyunlar
CREATE TABLE games (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    session_id VARCHAR(255),
    game_mode_id INT,
    game_type ENUM('champion', 'ability', 'item'),
    target_champion_id INT NULL,
    target_ability_id INT NULL,
    target_item_id INT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    is_won BOOLEAN DEFAULT FALSE,
    attempts_used INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (game_mode_id) REFERENCES game_modes(id),
    FOREIGN KEY (target_champion_id) REFERENCES champions(id) ON DELETE SET NULL,
    FOREIGN KEY (target_ability_id) REFERENCES abilities(id) ON DELETE SET NULL,
    FOREIGN KEY (target_item_id) REFERENCES items(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Tahminler
CREATE TABLE guesses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    game_id INT,
    guess_type ENUM('champion', 'ability', 'item'),
    champion_id INT NULL,
    ability_id INT NULL,
    item_id INT NULL,
    guess_number INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE,
    FOREIGN KEY (champion_id) REFERENCES champions(id) ON DELETE SET NULL,
    FOREIGN KEY (ability_id) REFERENCES abilities(id) ON DELETE SET NULL,
    FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Kullanıcı istatistikleri
CREATE TABLE user_stats (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    game_type VARCHAR(50),
    games_played INT DEFAULT 0,
    games_won INT DEFAULT 0,
    average_attempts FLOAT DEFAULT 0,
    total_score INT DEFAULT 0,
    best_score INT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Şampiyon medyası (videolar, ek resimler)
CREATE TABLE champion_media (
    id INT AUTO_INCREMENT PRIMARY KEY,
    champion_id INT,
    media_type VARCHAR(50),
    url VARCHAR(255),
    description TEXT,                   -- İngilizce açıklama
    FOREIGN KEY (champion_id) REFERENCES champions(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Medya çevirileri
CREATE TABLE media_translations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    media_id INT,
    language_id INT,
    description TEXT,
    FOREIGN KEY (media_id) REFERENCES champion_media(id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES languages(id) ON DELETE CASCADE,
    UNIQUE KEY (media_id, language_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS champion_skins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    champion_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (champion_id) REFERENCES champions (id) ON DELETE CASCADE,
    UNIQUE KEY unique_champion_skin (champion_id, name)
);

-- ChampionSkinTranslation tablosu oluşturma
CREATE TABLE IF NOT EXISTS champion_skin_translations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    skin_id INT NOT NULL,
    language_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (skin_id) REFERENCES champion_skins (id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES languages (id) ON DELETE CASCADE,
    UNIQUE KEY unique_skin_language (skin_id, language_id)
);

INSERT INTO languages (code, name, is_active) VALUES
('en', 'English', 1),
('tr', 'Türkçe', 1),
('de', 'Deutsch', 1),
('fr', 'Français', 1),
('es', 'Español', 1),
('it', 'Italiano', 1),
('ru', 'россия', 1),
('pt', 'Português', 1),
('br', 'Português', 1),
('nl', 'Nederlands', 1),
('zh', '中文', 1),
('jp', '日本語', 1),
('kr', '한국어', 1);


-- Pozisyonlar (İngilizce)
INSERT INTO positions (name) VALUES
('Top'), ('Jungle'), ('Mid'), ('Bottom'), ('Support');

-- Türler (İngilizce)
INSERT INTO species (name) VALUES
('Human'), ('Yordle'), ('Vastaya'), ('Darkin'), ('Void'), ('Ghost'),
('Golem'), ('Aspect'), ('God'), ('Demigod'), ('Brackern'), ('Demon'), ('Spirit'),
('Snake'), ('Dragon'), ('Undead'), ('Cyborg'), ('Minotaur'), ('Celestial'),
('Troll'), ('Animal'), ('Plant'), ('Magical Creature'), ('Automaton'),
('Ascended'), ('Ice Phoenix'), ('Amphibian'), ('Gargoyle'), ('Revenant'),
('Centaur'), ('Rodent'), ('Half-Tree'), ('Wind Spirit'), ('Nightmare'),
('Mutant'), ('Entity'), ('Hybrid');

-- Kaynaklar (İngilizce)
INSERT INTO resources (name) VALUES
('Mana'), ('Energy'), ('Fury'), ('Shield'), ('Blood'),
('Courage'), ('Heat'), ('Ammo'), ('Manaless'), ('Health'), ('Flow');

-- Dövüş menzilleri (İngilizce)
INSERT INTO combat_ranges (name) VALUES
('Melee'), ('Ranged'), ('Hybrid');

-- Bölgeler (İngilizce)
INSERT INTO regions (name, description) VALUES
('Ionia', 'A land of magic and balance'),
('Noxus', 'A brutal, expansionist empire'),
('Demacia', 'A kingdom of law and justice'),
('Piltover', 'The city of progress'),
('Zaun', 'The undercity of chemicals and pollution'),
('Freljord', 'A harsh, icy wilderness'),
('Shurima', 'A fallen desert empire'),
('Bilgewater', 'A lawless port city'),
('Targon', 'A sacred mountain reaching to the stars'),
('Shadow Isles', 'Islands corrupted by the Black Mist'),
('Bandle City', 'Home of the Yordles'),
('Ixtal', 'An isolated jungle realm'),
('Void', 'A nightmarish realm beyond reality'),
('Runeterra', 'The world itself'),
('Icathia', 'An ancient, fallen civilization');
-- Şampiyonlar (İngilizce)


-- 3. Tüm şampiyonların ilişkilerini ekleyelim
-- Aatrox
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (1, 4, 1); -- Darkin
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (1, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (1, 5); -- Blood
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (1, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (1, 14, 1); -- Runeterra

-- Ahri
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (2, 3, 1); -- Vastaya
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (2, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (2, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (2, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (2, 1, 1); -- Ionia

-- Akali
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (3, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (3, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (3, 2); -- Energy
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (3, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (3, 1, 1); -- Ionia

-- Akshan
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (4, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (4, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (4, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (4, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (4, 7, 1); -- Shurima

-- Alistar
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (5, 18, 1); -- Minotaur
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (5, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (5, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (5, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (5, 14, 1); -- Runeterra

-- Ambessa
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (6, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (6, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (6, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (6, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (6, 2, 1); -- Noxus

-- Amumu
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (7, 2, 1); -- Yordle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (7, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (7, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (7, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (7, 7, 1); -- Shurima

-- Anivia
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (8, 26, 1); -- Ice Phoenix
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (8, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (8, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (8, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (8, 6, 1); -- Freljord

-- Annie
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (9, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (9, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (9, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (9, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (9, 2, 1); -- Noxus

-- Aphelios
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (10, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (10, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (10, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (10, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (10, 9, 1); -- Targon

-- 11. Ashe
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (11, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (11, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (11, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (11, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (11, 6, 1); -- Freljord

-- 12. Aurelion Sol
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (12, 15, 1); -- Dragon
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (12, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (12, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (12, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (12, 9, 1); -- Targon

-- 13. Aurora
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (13, 3, 1); -- Vastaya
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (13, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (13, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (13, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (13, 6, 1); -- Freljord

-- 14. Azir
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (14, 25, 1); -- Ascended
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (14, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (14, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (14, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (14, 7, 1); -- Shurima

-- 15. Bard
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (15, 36, 1); -- Entity
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (15, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (15, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (15, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (15, 14, 1); -- Runeterra

-- 16. Bel'Veth
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (16, 5, 1); -- Void
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (16, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (16, 9); -- Manaless
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (16, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (16, 13, 1); -- Void

-- 17. Blitzcrank
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (17, 7, 1); -- Golem
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (17, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (17, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (17, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (17, 5, 1); -- Zaun

-- 18. Brand
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (18, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (18, 3, 1); -- Mid
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (18, 5, 0); -- Support (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (18, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (18, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (18, 14, 1); -- Runeterra

-- 19. Braum
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (19, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (19, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (19, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (19, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (19, 6, 1); -- Freljord

-- 20. Briar
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (20, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (20, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (20, 11); -- Flow
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (20, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (20, 2, 1); -- Noxus

-- 21. Caitlyn
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (21, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (21, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (21, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (21, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (21, 4, 1); -- Piltover

-- 22. Camille
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (22, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (22, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (22, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (22, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (22, 4, 1); -- Piltover

-- 23. Cassiopeia
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (23, 1, 1); -- Human (primary)
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (23, 14, 0); -- Snake (secondary)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (23, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (23, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (23, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (23, 2, 1); -- Noxus

-- 24. Cho'Gath
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (24, 5, 1); -- Void
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (24, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (24, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (24, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (24, 13, 1); -- Void

-- 25. Corki
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (25, 2, 1); -- Yordle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (25, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (25, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (25, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (25, 11, 1); -- Bandle City

-- 26. Darius
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (26, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (26, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (26, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (26, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (26, 2, 1); -- Noxus

-- 27. Diana
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (27, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (27, 2, 1); -- Jungle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (27, 3, 0); -- Mid (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (27, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (27, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (27, 9, 1); -- Targon

-- 28. Dr. Mundo
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (28, 35, 1); -- Mutant
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (28, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (28, 10); -- Health
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (28, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (28, 5, 1); -- Zaun

-- 29. Draven
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (29, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (29, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (29, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (29, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (29, 2, 1); -- Noxus

-- 30. Ekko
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (30, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (30, 3, 1); -- Mid
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (30, 2, 0); -- Jungle (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (30, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (30, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (30, 5, 1); -- Zaun

-- 31. Elise
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (31, 1, 1); -- Human (primary)
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (31, 37, 0); -- Hybrid (Spider, secondary)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (31, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (31, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (31, 3, 1); -- Hybrid
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (31, 10, 1); -- Shadow Isles

-- 32. Evelynn
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (32, 12, 1); -- Demon
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (32, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (32, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (32, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (32, 14, 1); -- Runeterra

-- 33. Ezreal
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (33, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (33, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (33, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (33, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (33, 4, 1); -- Piltover

-- 34. Fiddlesticks
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (34, 12, 1); -- Demon
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (34, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (34, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (34, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (34, 14, 1); -- Runeterra

-- 35. Fiora
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (35, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (35, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (35, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (35, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (35, 3, 1); -- Demacia

-- 36. Fizz
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (36, 27, 1); -- Amphibian
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (36, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (36, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (36, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (36, 8, 1); -- Bilgewater

-- 37. Galio
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (37, 28, 1); -- Gargoyle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (37, 3, 1); -- Mid
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (37, 5, 0); -- Support (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (37, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (37, 3, 1); -- Hybrid
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (37, 3, 1); -- Demacia

-- 38. Gangplank
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (38, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (38, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (38, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (38, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (38, 8, 1); -- Bilgewater

-- 39. Garen
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (39, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (39, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (39, 9); -- Manaless
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (39, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (39, 3, 1); -- Demacia

-- 40. Gnar
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (40, 2, 1); -- Yordle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (40, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (40, 3); -- Fury
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (40, 3, 1); -- Hybrid
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (40, 6, 1); -- Freljord

-- 41. Gragas
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (41, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (41, 2, 1); -- Jungle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (41, 1, 0); -- Top (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (41, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (41, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (41, 6, 1); -- Freljord

-- 42. Graves
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (42, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (42, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (42, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (42, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (42, 8, 1); -- Bilgewater

-- 43. Gwen
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (43, 23, 1); -- Magical Creature
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (43, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (43, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (43, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (43, 10, 1); -- Shadow Isles

-- 44. Hecarim
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (44, 29, 1); -- Centaur
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (44, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (44, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (44, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (44, 10, 1); -- Shadow Isles

-- 45. Heimerdinger
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (45, 2, 1); -- Yordle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (45, 3, 1); -- Mid
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (45, 1, 0); -- Top (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (45, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (45, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (45, 4, 1); -- Piltover

-- 46. Hwei
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (46, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (46, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (46, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (46, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (46, 1, 1); -- Ionia

-- 47. Illaoi
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (47, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (47, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (47, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (47, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (47, 8, 1); -- Bilgewater

-- 48. Irelia
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (48, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (48, 1, 1); -- Top
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (48, 3, 0); -- Mid (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (48, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (48, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (48, 1, 1); -- Ionia

-- 49. Ivern
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (49, 32, 1); -- Half-Tree
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (49, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (49, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (49, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (49, 1, 1); -- Ionia

-- 50. Janna
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (50, 33, 1); -- Wind Spirit
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (50, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (50, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (50, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (50, 5, 1); -- Zaun

-- 51. Jarvan IV
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (51, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (51, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (51, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (51, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (51, 3, 1); -- Demacia

-- 52. Jax
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (52, 1, 1); -- Human (mysterious)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (52, 1, 1); -- Top
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (52, 2, 0); -- Jungle (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (52, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (52, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (52, 15, 1); -- Icathia

-- 53. Jayce
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (53, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (53, 1, 1); -- Top
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (53, 3, 0); -- Mid (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (53, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (53, 3, 1); -- Hybrid
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (53, 4, 1); -- Piltover

-- 54. Jhin
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (54, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (54, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (54, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (54, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (54, 1, 1); -- Ionia

-- 55. Jinx
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (55, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (55, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (55, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (55, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (55, 5, 1); -- Zaun

-- 56. K'Sante
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (56, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (56, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (56, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (56, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (56, 7, 1); -- Shurima

-- 57. Kai'Sa
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (57, 1, 1); -- Human
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (57, 5, 0); -- Void (secondary)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (57, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (57, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (57, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (57, 13, 1); -- Void

-- 58. Kalista
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (58, 6, 1); -- Ghost
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (58, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (58, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (58, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (58, 10, 1); -- Shadow Isles

-- 59. Karma
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (59, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (59, 5, 1); -- Support
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (59, 3, 0); -- Mid (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (59, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (59, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (59, 1, 1); -- Ionia

-- 60. Karthus
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (60, 6, 1); -- Ghost
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (60, 2, 1); -- Jungle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (60, 3, 0); -- Mid (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (60, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (60, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (60, 10, 1); -- Shadow Isles

-- 61. Kassadin
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (61, 1, 1); -- Human
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (61, 5, 0); -- Void (secondary)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (61, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (61, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (61, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (61, 13, 1); -- Void

-- 62. Katarina
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (62, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (62, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (62, 9); -- Manaless
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (62, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (62, 2, 1); -- Noxus

-- 63. Kayle
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (63, 8, 1); -- Aspect
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (63, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (63, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (63, 3, 1); -- Hybrid
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (63, 3, 1); -- Demacia

-- 64. Kayn
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (64, 1, 1); -- Human
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (64, 4, 0); -- Darkin (secondary)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (64, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (64, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (64, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (64, 1, 1); -- Ionia

-- 65. Kennen
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (65, 2, 1); -- Yordle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (65, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (65, 2); -- Energy
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (65, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (65, 1, 1); -- Ionia

-- 66. Kha'Zix
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (66, 5, 1); -- Void
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (66, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (66, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (66, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (66, 13, 1); -- Void

-- 67. Kindred
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (67, 13, 1); -- Spirit
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (67, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (67, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (67, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (67, 14, 1); -- Runeterra

-- 68. Kled
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (68, 2, 1); -- Yordle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (68, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (68, 3); -- Fury
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (68, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (68, 2, 1); -- Noxus

-- 69. Kog'Maw
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (69, 5, 1); -- Void
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (69, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (69, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (69, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (69, 13, 1); -- Void

-- 70. LeBlanc
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (70, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (70, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (70, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (70, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (70, 2, 1); -- Noxus

-- 71. Lee Sin
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (71, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (71, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (71, 2); -- Energy
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (71, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (71, 1, 1); -- Ionia

-- 72. Leona
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (72, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (72, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (72, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (72, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (72, 9, 1); -- Targon

-- 73. Lillia
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (73, 13, 1); -- Spirit
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (73, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (73, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (73, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (73, 1, 1); -- Ionia

-- 74. Lissandra
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (74, 1, 1); -- Human (Ice Witch)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (74, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (74, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (74, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (74, 6, 1); -- Freljord

-- 75. Lucian
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (75, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (75, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (75, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (75, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (75, 3, 1); -- Demacia

-- 76. Lulu
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (76, 2, 1); -- Yordle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (76, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (76, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (76, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (76, 11, 1); -- Bandle City

-- 77. Lux
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (77, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (77, 3, 1); -- Mid
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (77, 5, 0); -- Support (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (77, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (77, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (77, 3, 1); -- Demacia

-- 78. Malphite
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (78, 36, 1); -- Entity (Living Rock)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (78, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (78, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (78, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (78, 12, 1); -- Ixtal

-- 79. Malzahar
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (79, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (79, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (79, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (79, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (79, 13, 1); -- Void

-- 80. Maokai
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (80, 22, 1); -- Plant (Treant)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (80, 1, 1); -- Top
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (80, 2, 0); -- Jungle (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (80, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (80, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (80, 10, 1); -- Shadow Isles

-- 81. Master Yi
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (81, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (81, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (81, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (81, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (81, 1, 1); -- Ionia

-- 82. Mel
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (82, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (82, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (82, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (82, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (82, 2, 1); -- Noxus

-- 83. Milio
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (83, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (83, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (83, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (83, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (83, 12, 1); -- Ixtal

-- 84. Miss Fortune
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (84, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (84, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (84, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (84, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (84, 8, 1); -- Bilgewater

-- 85. Mordekaiser
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (85, 6, 1); -- Ghost
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (85, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (85, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (85, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (85, 2, 1); -- Noxus

-- 86. Morgana
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (86, 8, 1); -- Aspect
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (86, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (86, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (86, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (86, 3, 1); -- Demacia

-- 87. Nami
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (87, 36, 1); -- Entity (Vastayan)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (87, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (87, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (87, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (87, 8, 1); -- Bilgewater

-- 88. Nasus
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (88, 25, 1); -- Ascended
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (88, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (88, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (88, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (88, 7, 1); -- Shurima

-- 89. Nautilus
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (89, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (89, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (89, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (89, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (89, 8, 1); -- Bilgewater

-- 90. Naafiri
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (90, 4, 1); -- Darkin
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (90, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (90, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (90, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (90, 7, 1); -- Shurima

-- 91. Neeko
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (91, 3, 1); -- Vastaya
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (91, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (91, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (91, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (91, 12, 1); -- Ixtal

-- 92. Nidalee
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (92, 1, 1); -- Human
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (92, 3, 0); -- Vastaya (secondary)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (92, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (92, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (92, 3, 1); -- Hybrid
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (92, 12, 1); -- Ixtal

-- 93. Nilah
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (93, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (93, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (93, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (93, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (93, 8, 1); -- Bilgewater

-- 94. Nocturne
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (94, 34, 1); -- Nightmare
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (94, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (94, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (94, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (94, 14, 1); -- Runeterra

-- 95. Nunu & Willump
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (95, 1, 1); -- Human (Nunu)
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (95, 23, 0); -- Magical Creature (Willump - Yeti)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (95, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (95, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (95, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (95, 6, 1); -- Freljord

-- 96. Olaf
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (96, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (96, 2, 1); -- Jungle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (96, 1, 0); -- Top (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (96, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (96, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (96, 6, 1); -- Freljord

-- 97. Orianna
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (97, 24, 1); -- Automaton
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (97, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (97, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (97, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (97, 4, 1); -- Piltover

-- 98. Ornn
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (98, 10, 1); -- Demigod
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (98, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (98, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (98, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (98, 6, 1); -- Freljord

-- 99. Pantheon
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (99, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (99, 1, 1); -- Top
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (99, 3, 0); -- Mid (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (99, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (99, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (99, 9, 1); -- Targon

-- 100. Poppy
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (100, 2, 1); -- Yordle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (100, 1, 1); -- Top
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (100, 2, 0); -- Jungle (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (100, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (100, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (100, 3, 1); -- Demacia

-- 101. Pyke
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (101, 1, 1); -- Human
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (101, 6, 0); -- Ghost (secondary)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (101, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (101, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (101, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (101, 8, 1); -- Bilgewater

-- 102. Qiyana
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (102, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (102, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (102, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (102, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (102, 12, 1); -- Ixtal

-- 103. Quinn
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (103, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (103, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (103, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (103, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (103, 3, 1); -- Demacia

-- 104. Rakan
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (104, 3, 1); -- Vastaya
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (104, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (104, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (104, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (104, 1, 1); -- Ionia

-- 105. Rammus
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (105, 23, 1); -- Magical Creature
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (105, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (105, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (105, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (105, 7, 1); -- Shurima

-- 106. Rek'Sai
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (106, 5, 1); -- Void
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (106, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (106, 3); -- Fury
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (106, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (106, 13, 1); -- Void

-- 107. Rell
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (107, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (107, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (107, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (107, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (107, 2, 1); -- Noxus

-- 108. Renata Glasc
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (108, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (108, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (108, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (108, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (108, 5, 1); -- Zaun

-- 109. Renekton
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (109, 25, 1); -- Ascended
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (109, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (109, 3); -- Fury
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (109, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (109, 7, 1); -- Shurima

-- 110. Rengar
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (110, 3, 1); -- Vastaya
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (110, 2, 1); -- Jungle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (110, 1, 0); -- Top (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (110, 3); -- Fury
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (110, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (110, 7, 1); -- Shurima

-- 111. Riven
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (111, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (111, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (111, 9); -- Manaless
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (111, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (111, 2, 1); -- Noxus

-- 112. Rumble
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (112, 2, 1); -- Yordle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (112, 1, 1); -- Top
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (112, 3, 0); -- Mid (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (112, 7); -- Heat
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (112, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (112, 11, 1); -- Bandle City

-- 113. Ryze
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (113, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (113, 3, 1); -- Mid
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (113, 1, 0); -- Top (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (113, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (113, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (113, 14, 1); -- Runeterra

-- 114. Samira
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (114, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (114, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (114, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (114, 3, 1); -- Hybrid
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (114, 2, 1); -- Noxus

-- 115. Sejuani
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (115, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (115, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (115, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (115, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (115, 6, 1); -- Freljord

-- 116. Senna
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (116, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (116, 5, 1); -- Support
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (116, 4, 0); -- Bottom (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (116, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (116, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (116, 10, 1); -- Shadow Isles

-- 117. Seraphine
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (117, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (117, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (117, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (117, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (117, 4, 1); -- Piltover
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (117, 5, 0); -- Zaun (secondary)

-- 118. Sett
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (118, 3, 1); -- Vastaya
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (118, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (118, 11); -- Flow (Grit)
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (118, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (118, 1, 1); -- Ionia

-- 119. Shaco
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (119, 12, 1); -- Demon
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (119, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (119, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (119, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (119, 14, 1); -- Runeterra

-- 120. Shen
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (120, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (120, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (120, 2); -- Energy
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (120, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (120, 1, 1); -- Ionia

-- 121. Shyvana
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (121, 1, 1); -- Human
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (121, 15, 0); -- Dragon (secondary)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (121, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (121, 1); -- Mana (Fury in dragon form)
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (121, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (121, 3, 1); -- Demacia

-- 122. Singed
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (122, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (122, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (122, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (122, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (122, 5, 1); -- Zaun

-- 123. Sion
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (123, 16, 1); -- Undead
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (123, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (123, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (123, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (123, 2, 1); -- Noxus

-- 124. Sivir
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (124, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (124, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (124, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (124, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (124, 7, 1); -- Shurima

-- 125. Skarner
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (125, 11, 1); -- Brackern
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (125, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (125, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (125, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (125, 7, 1); -- Shurima

-- 126. Smolder
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (126, 15, 1); -- Dragon
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (126, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (126, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (126, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (126, 14, 1); -- Runeterra

-- 127. Sona
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (127, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (127, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (127, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (127, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (127, 3, 1); -- Demacia

-- 128. Soraka
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (128, 19, 1); -- Celestial
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (128, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (128, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (128, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (128, 1, 1); -- Ionia

-- 129. Swain
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (129, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (129, 3, 1); -- Mid
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (129, 5, 0); -- Support (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (129, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (129, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (129, 2, 1); -- Noxus

-- 130. Sylas
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (130, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (130, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (130, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (130, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (130, 3, 1); -- Demacia

-- 131. Syndra
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (131, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (131, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (131, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (131, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (131, 1, 1); -- Ionia

-- 132. Tahm Kench
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (132, 23, 1); -- Magical Creature
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (132, 5, 1); -- Support
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (132, 1, 0); -- Top (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (132, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (132, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (132, 8, 1); -- Bilgewater

-- 133. Taliyah
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (133, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (133, 3, 1); -- Mid
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (133, 2, 0); -- Jungle (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (133, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (133, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (133, 7, 1); -- Shurima

-- 134. Talon
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (134, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (134, 3, 1); -- Mid
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (134, 2, 0); -- Jungle (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (134, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (134, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (134, 2, 1); -- Noxus

-- 135. Taric
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (135, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (135, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (135, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (135, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (135, 9, 1); -- Targon

-- 136. Teemo
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (136, 2, 1); -- Yordle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (136, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (136, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (136, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (136, 11, 1); -- Bandle City

-- 137. Thresh
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (137, 6, 1); -- Ghost
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (137, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (137, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (137, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (137, 10, 1); -- Shadow Isles

-- 138. Tristana
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (138, 2, 1); -- Yordle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (138, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (138, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (138, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (138, 11, 1); -- Bandle City

-- 139. Trundle
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (139, 20, 1); -- Troll
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (139, 1, 1); -- Top
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (139, 2, 0); -- Jungle (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (139, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (139, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (139, 6, 1); -- Freljord

-- 140. Tryndamere
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (140, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (140, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (140, 3); -- Fury
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (140, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (140, 6, 1); -- Freljord

-- 141. Twisted Fate
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (141, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (141, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (141, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (141, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (141, 8, 1); -- Bilgewater

-- 142. Twitch
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (142, 30, 1); -- Rodent
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (142, 4, 1); -- Bottom
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (142, 2, 0); -- Jungle (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (142, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (142, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (142, 5, 1); -- Zaun

-- 143. Udyr
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (143, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (143, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (143, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (143, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (143, 6, 1); -- Freljord

-- 144. Urgot
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (144, 17, 1); -- Cyborg
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (144, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (144, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (144, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (144, 5, 1); -- Zaun

-- 145. Varus
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (145, 4, 1); -- Darkin
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (145, 1, 0); -- Human (secondary)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (145, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (145, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (145, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (145, 1, 1); -- Ionia

-- 146. Vayne
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (146, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (146, 4, 1); -- Bottom
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (146, 1, 0); -- Top (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (146, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (146, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (146, 3, 1); -- Demacia

-- 147. Veigar
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (147, 2, 1); -- Yordle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (147, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (147, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (147, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (147, 11, 1); -- Bandle City

-- 148. Vel'Koz
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (148, 5, 1); -- Void
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (148, 3, 1); -- Mid
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (148, 5, 0); -- Support (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (148, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (148, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (148, 13, 1); -- Void

-- 149. Vex
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (149, 2, 1); -- Yordle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (149, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (149, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (149, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (149, 10, 1); -- Shadow Isles

-- 150. Vi
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (150, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (150, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (150, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (150, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (150, 5, 1); -- Zaun

-- 151. Viego
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (151, 6, 1); -- Ghost
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (151, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (151, 9); -- Manaless
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (151, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (151, 10, 1); -- Shadow Isles

-- 152. Viktor
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (152, 1, 1); -- Human
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (152, 17, 0); -- Cyborg (secondary)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (152, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (152, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (152, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (152, 5, 1); -- Zaun

-- 153. Vladimir
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (153, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (153, 3, 1); -- Mid
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (153, 1, 0); -- Top (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (153, 5); -- Blood
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (153, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (153, 2, 1); -- Noxus

-- 154. Volibear
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (154, 10, 1); -- Demigod
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (154, 1, 1); -- Top
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (154, 2, 0); -- Jungle (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (154, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (154, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (154, 6, 1); -- Freljord

-- 155. Warwick
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (155, 23, 1); -- Magical Creature
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (155, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (155, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (155, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (155, 5, 1); -- Zaun

-- 156. Wukong
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (156, 3, 1); -- Vastaya
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (156, 1, 1); -- Top
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (156, 2, 0); -- Jungle (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (156, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (156, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (156, 1, 1); -- Ionia

-- 157. Xayah
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (157, 3, 1); -- Vastaya
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (157, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (157, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (157, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (157, 1, 1); -- Ionia

-- 158. Xerath
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (158, 25, 1); -- Ascended
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (158, 3, 1); -- Mid
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (158, 5, 0); -- Support (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (158, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (158, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (158, 7, 1); -- Shurima

-- 159. Xin Zhao
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (159, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (159, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (159, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (159, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (159, 3, 1); -- Demacia

-- 160. Yasuo
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (160, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (160, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (160, 11); -- Flow
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (160, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (160, 1, 1); -- Ionia

-- 161. Yone
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (161, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (161, 3, 1); -- Mid
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (161, 1, 0); -- Top (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (161, 9); -- Manaless
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (161, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (161, 1, 1); -- Ionia

-- 162. Yorick
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (162, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (162, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (162, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (162, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (162, 10, 1); -- Shadow Isles

-- 163. Yuumi
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (163, 23, 1); -- Magical Creature (Cat)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (163, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (163, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (163, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (163, 11, 1); -- Bandle City

-- 164. Zac
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (164, 23, 1); -- Magical Creature
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (164, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (164, 10); -- Health
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (164, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (164, 5, 1); -- Zaun

-- 165. Zed
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (165, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (165, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (165, 2); -- Energy
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (165, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (165, 1, 1); -- Ionia

-- 166. Zeri
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (166, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (166, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (166, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (166, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (166, 5, 1); -- Zaun

-- 167. Ziggs
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (167, 2, 1); -- Yordle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (167, 3, 1); -- Mid
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (167, 4, 0); -- Bottom (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (167, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (167, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (167, 4, 1); -- Piltover

-- 168. Zilean
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (168, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (168, 5, 1); -- Support
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (168, 3, 0); -- Mid (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (168, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (168, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (168, 14, 1); -- Runeterra

-- 169. Zoe
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (169, 19, 1); -- Celestial
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (169, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (169, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (169, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (169, 9, 1); -- Targon

-- 170. Zyra
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (170, 22, 1); -- Plant
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (170, 5, 1); -- Support
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (170, 3, 0); -- Mid (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (170, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (170, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (170, 12, 1); -- Ixtal

-- 3. Tüm şampiyonların ilişkilerini ekleyelim
-- Aatrox
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (1, 4, 1); -- Darkin
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (1, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (1, 5); -- Blood
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (1, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (1, 14, 1); -- Runeterra

-- Ahri
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (2, 3, 1); -- Vastaya
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (2, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (2, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (2, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (2, 1, 1); -- Ionia

-- Akali
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (3, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (3, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (3, 2); -- Energy
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (3, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (3, 1, 1); -- Ionia

-- Akshan
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (4, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (4, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (4, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (4, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (4, 7, 1); -- Shurima

-- Alistar
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (5, 18, 1); -- Minotaur
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (5, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (5, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (5, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (5, 14, 1); -- Runeterra

-- Ambessa
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (6, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (6, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (6, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (6, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (6, 2, 1); -- Noxus

-- Amumu
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (7, 2, 1); -- Yordle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (7, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (7, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (7, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (7, 7, 1); -- Shurima

-- Anivia
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (8, 26, 1); -- Ice Phoenix
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (8, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (8, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (8, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (8, 6, 1); -- Freljord

-- Annie
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (9, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (9, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (9, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (9, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (9, 2, 1); -- Noxus

-- Aphelios
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (10, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (10, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (10, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (10, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (10, 9, 1); -- Targon

-- 11. Ashe
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (11, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (11, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (11, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (11, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (11, 6, 1); -- Freljord

-- 12. Aurelion Sol
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (12, 15, 1); -- Dragon
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (12, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (12, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (12, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (12, 9, 1); -- Targon

-- 13. Aurora
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (13, 3, 1); -- Vastaya
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (13, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (13, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (13, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (13, 6, 1); -- Freljord

-- 14. Azir
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (14, 25, 1); -- Ascended
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (14, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (14, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (14, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (14, 7, 1); -- Shurima

-- 15. Bard
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (15, 36, 1); -- Entity
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (15, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (15, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (15, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (15, 14, 1); -- Runeterra

-- 16. Bel'Veth
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (16, 5, 1); -- Void
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (16, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (16, 9); -- Manaless
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (16, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (16, 13, 1); -- Void

-- 17. Blitzcrank
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (17, 7, 1); -- Golem
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (17, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (17, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (17, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (17, 5, 1); -- Zaun

-- 18. Brand
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (18, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (18, 3, 1); -- Mid
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (18, 5, 0); -- Support (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (18, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (18, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (18, 14, 1); -- Runeterra

-- 19. Braum
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (19, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (19, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (19, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (19, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (19, 6, 1); -- Freljord

-- 20. Briar
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (20, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (20, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (20, 11); -- Flow
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (20, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (20, 2, 1); -- Noxus

-- 21. Caitlyn
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (21, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (21, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (21, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (21, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (21, 4, 1); -- Piltover

-- 22. Camille
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (22, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (22, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (22, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (22, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (22, 4, 1); -- Piltover

-- 23. Cassiopeia
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (23, 1, 1); -- Human (primary)
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (23, 14, 0); -- Snake (secondary)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (23, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (23, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (23, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (23, 2, 1); -- Noxus

-- 24. Cho'Gath
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (24, 5, 1); -- Void
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (24, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (24, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (24, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (24, 13, 1); -- Void

-- 25. Corki
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (25, 2, 1); -- Yordle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (25, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (25, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (25, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (25, 11, 1); -- Bandle City

-- 26. Darius
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (26, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (26, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (26, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (26, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (26, 2, 1); -- Noxus

-- 27. Diana
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (27, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (27, 2, 1); -- Jungle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (27, 3, 0); -- Mid (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (27, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (27, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (27, 9, 1); -- Targon

-- 28. Dr. Mundo
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (28, 35, 1); -- Mutant
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (28, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (28, 10); -- Health
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (28, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (28, 5, 1); -- Zaun

-- 29. Draven
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (29, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (29, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (29, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (29, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (29, 2, 1); -- Noxus

-- 30. Ekko
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (30, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (30, 3, 1); -- Mid
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (30, 2, 0); -- Jungle (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (30, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (30, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (30, 5, 1); -- Zaun

-- 31. Elise
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (31, 1, 1); -- Human (primary)
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (31, 37, 0); -- Hybrid (Spider, secondary)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (31, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (31, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (31, 3, 1); -- Hybrid
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (31, 10, 1); -- Shadow Isles

-- 32. Evelynn
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (32, 12, 1); -- Demon
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (32, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (32, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (32, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (32, 14, 1); -- Runeterra

-- 33. Ezreal
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (33, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (33, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (33, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (33, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (33, 4, 1); -- Piltover

-- 34. Fiddlesticks
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (34, 12, 1); -- Demon
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (34, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (34, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (34, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (34, 14, 1); -- Runeterra

-- 35. Fiora
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (35, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (35, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (35, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (35, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (35, 3, 1); -- Demacia

-- 36. Fizz
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (36, 27, 1); -- Amphibian
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (36, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (36, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (36, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (36, 8, 1); -- Bilgewater

-- 37. Galio
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (37, 28, 1); -- Gargoyle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (37, 3, 1); -- Mid
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (37, 5, 0); -- Support (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (37, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (37, 3, 1); -- Hybrid
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (37, 3, 1); -- Demacia

-- 38. Gangplank
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (38, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (38, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (38, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (38, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (38, 8, 1); -- Bilgewater

-- 39. Garen
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (39, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (39, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (39, 9); -- Manaless
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (39, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (39, 3, 1); -- Demacia

-- 40. Gnar
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (40, 2, 1); -- Yordle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (40, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (40, 3); -- Fury
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (40, 3, 1); -- Hybrid
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (40, 6, 1); -- Freljord

-- 41. Gragas
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (41, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (41, 2, 1); -- Jungle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (41, 1, 0); -- Top (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (41, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (41, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (41, 6, 1); -- Freljord

-- 42. Graves
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (42, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (42, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (42, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (42, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (42, 8, 1); -- Bilgewater

-- 43. Gwen
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (43, 23, 1); -- Magical Creature
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (43, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (43, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (43, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (43, 10, 1); -- Shadow Isles

-- 44. Hecarim
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (44, 29, 1); -- Centaur
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (44, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (44, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (44, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (44, 10, 1); -- Shadow Isles

-- 45. Heimerdinger
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (45, 2, 1); -- Yordle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (45, 3, 1); -- Mid
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (45, 1, 0); -- Top (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (45, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (45, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (45, 4, 1); -- Piltover

-- 46. Hwei
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (46, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (46, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (46, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (46, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (46, 1, 1); -- Ionia

-- 47. Illaoi
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (47, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (47, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (47, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (47, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (47, 8, 1); -- Bilgewater

-- 48. Irelia
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (48, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (48, 1, 1); -- Top
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (48, 3, 0); -- Mid (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (48, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (48, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (48, 1, 1); -- Ionia

-- 49. Ivern
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (49, 32, 1); -- Half-Tree
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (49, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (49, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (49, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (49, 1, 1); -- Ionia

-- 50. Janna
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (50, 33, 1); -- Wind Spirit
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (50, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (50, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (50, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (50, 5, 1); -- Zaun

-- 51. Jarvan IV
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (51, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (51, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (51, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (51, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (51, 3, 1); -- Demacia

-- 52. Jax
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (52, 1, 1); -- Human (mysterious)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (52, 1, 1); -- Top
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (52, 2, 0); -- Jungle (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (52, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (52, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (52, 15, 1); -- Icathia

-- 53. Jayce
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (53, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (53, 1, 1); -- Top
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (53, 3, 0); -- Mid (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (53, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (53, 3, 1); -- Hybrid
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (53, 4, 1); -- Piltover

-- 54. Jhin
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (54, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (54, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (54, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (54, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (54, 1, 1); -- Ionia

-- 55. Jinx
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (55, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (55, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (55, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (55, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (55, 5, 1); -- Zaun

-- 56. K'Sante
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (56, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (56, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (56, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (56, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (56, 7, 1); -- Shurima

-- 57. Kai'Sa
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (57, 1, 1); -- Human
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (57, 5, 0); -- Void (secondary)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (57, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (57, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (57, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (57, 13, 1); -- Void

-- 58. Kalista
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (58, 6, 1); -- Ghost
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (58, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (58, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (58, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (58, 10, 1); -- Shadow Isles

-- 59. Karma
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (59, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (59, 5, 1); -- Support
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (59, 3, 0); -- Mid (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (59, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (59, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (59, 1, 1); -- Ionia

-- 60. Karthus
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (60, 6, 1); -- Ghost
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (60, 2, 1); -- Jungle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (60, 3, 0); -- Mid (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (60, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (60, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (60, 10, 1); -- Shadow Isles

-- 61. Kassadin
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (61, 1, 1); -- Human
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (61, 5, 0); -- Void (secondary)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (61, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (61, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (61, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (61, 13, 1); -- Void

-- 62. Katarina
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (62, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (62, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (62, 9); -- Manaless
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (62, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (62, 2, 1); -- Noxus

-- 63. Kayle
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (63, 8, 1); -- Aspect
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (63, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (63, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (63, 3, 1); -- Hybrid
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (63, 3, 1); -- Demacia

-- 64. Kayn
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (64, 1, 1); -- Human
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (64, 4, 0); -- Darkin (secondary)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (64, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (64, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (64, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (64, 1, 1); -- Ionia

-- 65. Kennen
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (65, 2, 1); -- Yordle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (65, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (65, 2); -- Energy
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (65, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (65, 1, 1); -- Ionia

-- 66. Kha'Zix
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (66, 5, 1); -- Void
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (66, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (66, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (66, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (66, 13, 1); -- Void

-- 67. Kindred
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (67, 13, 1); -- Spirit
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (67, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (67, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (67, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (67, 14, 1); -- Runeterra

-- 68. Kled
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (68, 2, 1); -- Yordle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (68, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (68, 3); -- Fury
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (68, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (68, 2, 1); -- Noxus

-- 69. Kog'Maw
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (69, 5, 1); -- Void
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (69, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (69, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (69, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (69, 13, 1); -- Void

-- 70. LeBlanc
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (70, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (70, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (70, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (70, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (70, 2, 1); -- Noxus

-- 71. Lee Sin
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (71, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (71, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (71, 2); -- Energy
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (71, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (71, 1, 1); -- Ionia

-- 72. Leona
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (72, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (72, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (72, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (72, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (72, 9, 1); -- Targon

-- 73. Lillia
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (73, 13, 1); -- Spirit
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (73, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (73, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (73, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (73, 1, 1); -- Ionia

-- 74. Lissandra
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (74, 1, 1); -- Human (Ice Witch)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (74, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (74, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (74, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (74, 6, 1); -- Freljord

-- 75. Lucian
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (75, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (75, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (75, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (75, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (75, 3, 1); -- Demacia

-- 76. Lulu
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (76, 2, 1); -- Yordle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (76, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (76, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (76, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (76, 11, 1); -- Bandle City

-- 77. Lux
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (77, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (77, 3, 1); -- Mid
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (77, 5, 0); -- Support (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (77, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (77, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (77, 3, 1); -- Demacia

-- 78. Malphite
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (78, 36, 1); -- Entity (Living Rock)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (78, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (78, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (78, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (78, 12, 1); -- Ixtal

-- 79. Malzahar
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (79, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (79, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (79, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (79, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (79, 13, 1); -- Void

-- 80. Maokai
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (80, 22, 1); -- Plant (Treant)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (80, 1, 1); -- Top
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (80, 2, 0); -- Jungle (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (80, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (80, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (80, 10, 1); -- Shadow Isles

-- 81. Master Yi
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (81, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (81, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (81, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (81, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (81, 1, 1); -- Ionia

-- 82. Mel
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (82, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (82, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (82, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (82, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (82, 2, 1); -- Noxus

-- 83. Milio
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (83, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (83, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (83, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (83, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (83, 12, 1); -- Ixtal

-- 84. Miss Fortune
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (84, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (84, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (84, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (84, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (84, 8, 1); -- Bilgewater

-- 85. Mordekaiser
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (85, 6, 1); -- Ghost
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (85, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (85, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (85, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (85, 2, 1); -- Noxus

-- 86. Morgana
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (86, 8, 1); -- Aspect
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (86, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (86, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (86, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (86, 3, 1); -- Demacia

-- 87. Nami
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (87, 36, 1); -- Entity (Vastayan)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (87, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (87, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (87, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (87, 8, 1); -- Bilgewater

-- 88. Nasus
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (88, 25, 1); -- Ascended
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (88, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (88, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (88, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (88, 7, 1); -- Shurima

-- 89. Nautilus
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (89, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (89, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (89, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (89, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (89, 8, 1); -- Bilgewater

-- 90. Naafiri
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (90, 4, 1); -- Darkin
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (90, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (90, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (90, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (90, 7, 1); -- Shurima

-- 91. Neeko
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (91, 3, 1); -- Vastaya
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (91, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (91, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (91, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (91, 12, 1); -- Ixtal

-- 92. Nidalee
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (92, 1, 1); -- Human
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (92, 3, 0); -- Vastaya (secondary)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (92, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (92, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (92, 3, 1); -- Hybrid
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (92, 12, 1); -- Ixtal

-- 93. Nilah
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (93, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (93, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (93, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (93, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (93, 8, 1); -- Bilgewater

-- 94. Nocturne
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (94, 34, 1); -- Nightmare
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (94, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (94, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (94, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (94, 14, 1); -- Runeterra

-- 95. Nunu & Willump
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (95, 1, 1); -- Human (Nunu)
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (95, 23, 0); -- Magical Creature (Willump - Yeti)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (95, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (95, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (95, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (95, 6, 1); -- Freljord

-- 96. Olaf
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (96, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (96, 2, 1); -- Jungle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (96, 1, 0); -- Top (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (96, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (96, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (96, 6, 1); -- Freljord

-- 97. Orianna
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (97, 24, 1); -- Automaton
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (97, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (97, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (97, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (97, 4, 1); -- Piltover

-- 98. Ornn
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (98, 10, 1); -- Demigod
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (98, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (98, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (98, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (98, 6, 1); -- Freljord

-- 99. Pantheon
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (99, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (99, 1, 1); -- Top
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (99, 3, 0); -- Mid (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (99, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (99, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (99, 9, 1); -- Targon

-- 100. Poppy
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (100, 2, 1); -- Yordle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (100, 1, 1); -- Top
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (100, 2, 0); -- Jungle (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (100, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (100, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (100, 3, 1); -- Demacia

-- 101. Pyke
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (101, 1, 1); -- Human
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (101, 6, 0); -- Ghost (secondary)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (101, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (101, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (101, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (101, 8, 1); -- Bilgewater

-- 102. Qiyana
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (102, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (102, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (102, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (102, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (102, 12, 1); -- Ixtal

-- 103. Quinn
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (103, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (103, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (103, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (103, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (103, 3, 1); -- Demacia

-- 104. Rakan
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (104, 3, 1); -- Vastaya
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (104, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (104, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (104, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (104, 1, 1); -- Ionia

-- 105. Rammus
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (105, 23, 1); -- Magical Creature
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (105, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (105, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (105, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (105, 7, 1); -- Shurima

-- 106. Rek'Sai
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (106, 5, 1); -- Void
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (106, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (106, 3); -- Fury
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (106, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (106, 13, 1); -- Void

-- 107. Rell
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (107, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (107, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (107, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (107, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (107, 2, 1); -- Noxus

-- 108. Renata Glasc
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (108, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (108, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (108, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (108, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (108, 5, 1); -- Zaun

-- 109. Renekton
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (109, 25, 1); -- Ascended
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (109, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (109, 3); -- Fury
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (109, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (109, 7, 1); -- Shurima

-- 110. Rengar
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (110, 3, 1); -- Vastaya
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (110, 2, 1); -- Jungle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (110, 1, 0); -- Top (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (110, 3); -- Fury
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (110, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (110, 7, 1); -- Shurima

-- 111. Riven
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (111, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (111, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (111, 9); -- Manaless
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (111, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (111, 2, 1); -- Noxus

-- 112. Rumble
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (112, 2, 1); -- Yordle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (112, 1, 1); -- Top
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (112, 3, 0); -- Mid (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (112, 7); -- Heat
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (112, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (112, 11, 1); -- Bandle City

-- 113. Ryze
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (113, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (113, 3, 1); -- Mid
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (113, 1, 0); -- Top (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (113, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (113, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (113, 14, 1); -- Runeterra

-- 114. Samira
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (114, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (114, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (114, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (114, 3, 1); -- Hybrid
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (114, 2, 1); -- Noxus

-- 115. Sejuani
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (115, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (115, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (115, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (115, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (115, 6, 1); -- Freljord

-- 116. Senna
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (116, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (116, 5, 1); -- Support
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (116, 4, 0); -- Bottom (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (116, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (116, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (116, 10, 1); -- Shadow Isles

-- 117. Seraphine
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (117, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (117, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (117, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (117, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (117, 4, 1); -- Piltover
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (117, 5, 0); -- Zaun (secondary)

-- 118. Sett
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (118, 3, 1); -- Vastaya
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (118, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (118, 11); -- Flow (Grit)
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (118, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (118, 1, 1); -- Ionia

-- 119. Shaco
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (119, 12, 1); -- Demon
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (119, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (119, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (119, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (119, 14, 1); -- Runeterra

-- 120. Shen
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (120, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (120, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (120, 2); -- Energy
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (120, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (120, 1, 1); -- Ionia

-- 121. Shyvana
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (121, 1, 1); -- Human
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (121, 15, 0); -- Dragon (secondary)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (121, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (121, 1); -- Mana (Fury in dragon form)
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (121, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (121, 3, 1); -- Demacia

-- 122. Singed
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (122, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (122, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (122, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (122, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (122, 5, 1); -- Zaun

-- 123. Sion
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (123, 16, 1); -- Undead
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (123, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (123, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (123, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (123, 2, 1); -- Noxus

-- 124. Sivir
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (124, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (124, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (124, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (124, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (124, 7, 1); -- Shurima

-- 125. Skarner
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (125, 11, 1); -- Brackern
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (125, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (125, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (125, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (125, 7, 1); -- Shurima

-- 126. Smolder
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (126, 15, 1); -- Dragon
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (126, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (126, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (126, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (126, 14, 1); -- Runeterra

-- 127. Sona
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (127, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (127, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (127, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (127, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (127, 3, 1); -- Demacia

-- 128. Soraka
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (128, 19, 1); -- Celestial
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (128, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (128, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (128, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (128, 1, 1); -- Ionia

-- 129. Swain
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (129, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (129, 3, 1); -- Mid
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (129, 5, 0); -- Support (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (129, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (129, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (129, 2, 1); -- Noxus

-- 130. Sylas
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (130, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (130, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (130, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (130, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (130, 3, 1); -- Demacia

-- 131. Syndra
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (131, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (131, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (131, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (131, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (131, 1, 1); -- Ionia

-- 132. Tahm Kench
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (132, 23, 1); -- Magical Creature
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (132, 5, 1); -- Support
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (132, 1, 0); -- Top (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (132, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (132, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (132, 8, 1); -- Bilgewater

-- 133. Taliyah
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (133, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (133, 3, 1); -- Mid
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (133, 2, 0); -- Jungle (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (133, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (133, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (133, 7, 1); -- Shurima

-- 134. Talon
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (134, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (134, 3, 1); -- Mid
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (134, 2, 0); -- Jungle (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (134, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (134, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (134, 2, 1); -- Noxus

-- 135. Taric
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (135, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (135, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (135, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (135, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (135, 9, 1); -- Targon

-- 136. Teemo
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (136, 2, 1); -- Yordle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (136, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (136, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (136, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (136, 11, 1); -- Bandle City

-- 137. Thresh
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (137, 6, 1); -- Ghost
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (137, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (137, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (137, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (137, 10, 1); -- Shadow Isles

-- 138. Tristana
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (138, 2, 1); -- Yordle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (138, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (138, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (138, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (138, 11, 1); -- Bandle City

-- 139. Trundle
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (139, 20, 1); -- Troll
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (139, 1, 1); -- Top
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (139, 2, 0); -- Jungle (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (139, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (139, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (139, 6, 1); -- Freljord

-- 140. Tryndamere
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (140, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (140, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (140, 3); -- Fury
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (140, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (140, 6, 1); -- Freljord

-- 141. Twisted Fate
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (141, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (141, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (141, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (141, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (141, 8, 1); -- Bilgewater

-- 142. Twitch
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (142, 30, 1); -- Rodent
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (142, 4, 1); -- Bottom
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (142, 2, 0); -- Jungle (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (142, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (142, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (142, 5, 1); -- Zaun

-- 143. Udyr
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (143, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (143, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (143, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (143, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (143, 6, 1); -- Freljord

-- 144. Urgot
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (144, 17, 1); -- Cyborg
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (144, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (144, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (144, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (144, 5, 1); -- Zaun

-- 145. Varus
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (145, 4, 1); -- Darkin
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (145, 1, 0); -- Human (secondary)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (145, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (145, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (145, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (145, 1, 1); -- Ionia

-- 146. Vayne
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (146, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (146, 4, 1); -- Bottom
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (146, 1, 0); -- Top (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (146, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (146, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (146, 3, 1); -- Demacia

-- 147. Veigar
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (147, 2, 1); -- Yordle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (147, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (147, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (147, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (147, 11, 1); -- Bandle City

-- 148. Vel'Koz
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (148, 5, 1); -- Void
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (148, 3, 1); -- Mid
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (148, 5, 0); -- Support (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (148, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (148, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (148, 13, 1); -- Void

-- 149. Vex
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (149, 2, 1); -- Yordle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (149, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (149, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (149, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (149, 10, 1); -- Shadow Isles

-- 150. Vi
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (150, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (150, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (150, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (150, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (150, 5, 1); -- Zaun

-- 151. Viego
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (151, 6, 1); -- Ghost
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (151, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (151, 9); -- Manaless
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (151, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (151, 10, 1); -- Shadow Isles

-- 152. Viktor
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (152, 1, 1); -- Human
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (152, 17, 0); -- Cyborg (secondary)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (152, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (152, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (152, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (152, 5, 1); -- Zaun

-- 153. Vladimir
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (153, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (153, 3, 1); -- Mid
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (153, 1, 0); -- Top (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (153, 5); -- Blood
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (153, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (153, 2, 1); -- Noxus

-- 154. Volibear
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (154, 10, 1); -- Demigod
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (154, 1, 1); -- Top
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (154, 2, 0); -- Jungle (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (154, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (154, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (154, 6, 1); -- Freljord

-- 155. Warwick
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (155, 23, 1); -- Magical Creature
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (155, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (155, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (155, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (155, 5, 1); -- Zaun

-- 156. Wukong
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (156, 3, 1); -- Vastaya
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (156, 1, 1); -- Top
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (156, 2, 0); -- Jungle (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (156, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (156, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (156, 1, 1); -- Ionia

-- 157. Xayah
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (157, 3, 1); -- Vastaya
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (157, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (157, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (157, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (157, 1, 1); -- Ionia

-- 158. Xerath
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (158, 25, 1); -- Ascended
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (158, 3, 1); -- Mid
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (158, 5, 0); -- Support (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (158, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (158, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (158, 7, 1); -- Shurima

-- 159. Xin Zhao
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (159, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (159, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (159, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (159, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (159, 3, 1); -- Demacia

-- 160. Yasuo
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (160, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (160, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (160, 11); -- Flow
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (160, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (160, 1, 1); -- Ionia

-- 161. Yone
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (161, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (161, 3, 1); -- Mid
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (161, 1, 0); -- Top (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (161, 9); -- Manaless
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (161, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (161, 1, 1); -- Ionia

-- 162. Yorick
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (162, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (162, 1, 1); -- Top
INSERT INTO champion_resources (champion_id, resource_id) VALUES (162, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (162, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (162, 10, 1); -- Shadow Isles

-- 163. Yuumi
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (163, 23, 1); -- Magical Creature (Cat)
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (163, 5, 1); -- Support
INSERT INTO champion_resources (champion_id, resource_id) VALUES (163, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (163, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (163, 11, 1); -- Bandle City

-- 164. Zac
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (164, 23, 1); -- Magical Creature
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (164, 2, 1); -- Jungle
INSERT INTO champion_resources (champion_id, resource_id) VALUES (164, 10); -- Health
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (164, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (164, 5, 1); -- Zaun

-- 165. Zed
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (165, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (165, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (165, 2); -- Energy
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (165, 1, 1); -- Melee
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (165, 1, 1); -- Ionia

-- 166. Zeri
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (166, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (166, 4, 1); -- Bottom
INSERT INTO champion_resources (champion_id, resource_id) VALUES (166, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (166, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (166, 5, 1); -- Zaun

-- 167. Ziggs
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (167, 2, 1); -- Yordle
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (167, 3, 1); -- Mid
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (167, 4, 0); -- Bottom (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (167, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (167, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (167, 4, 1); -- Piltover

-- 168. Zilean
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (168, 1, 1); -- Human
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (168, 5, 1); -- Support
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (168, 3, 0); -- Mid (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (168, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (168, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (168, 14, 1); -- Runeterra

-- 169. Zoe
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (169, 19, 1); -- Celestial
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (169, 3, 1); -- Mid
INSERT INTO champion_resources (champion_id, resource_id) VALUES (169, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (169, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (169, 9, 1); -- Targon

-- 170. Zyra
INSERT INTO champion_species (champion_id, species_id, is_primary) VALUES (170, 22, 1); -- Plant
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (170, 5, 1); -- Support
INSERT INTO champion_positions (champion_id, position_id, is_primary) VALUES (170, 3, 0); -- Mid (secondary)
INSERT INTO champion_resources (champion_id, resource_id) VALUES (170, 1); -- Mana
INSERT INTO champion_combat_ranges (champion_id, combat_range_id, is_primary) VALUES (170, 2, 1); -- Ranged
INSERT INTO champion_regions (champion_id, region_id, is_primary) VALUES (170, 12, 1); -- Ixtal

 -- Türkçe pozisyon çevirileri
INSERT INTO position_translations (position_id, language_id, name) VALUES
(1, '2', 'Üst'),
(2, '2', 'Orman'),
(3, '2', 'Orta'),
(4, '2', 'Alt'),
(5, '2', 'Destek');

-- Türkçe tür çevirileri
INSERT INTO species_translations (species_id, language_id, name) VALUES
(1, '2', 'İnsan'),
(2, '2', 'Yordle'),
(3, '2', 'Vastaya'),
(4, '2', 'Darkin'),
(5, '2', 'Void'),
(6, '2', 'Hayalet'),
(7, '2', 'Golem'),
(8, '2', 'Görünüş'),
(9, '2', 'Tanrı'),
(10, '2', 'Yarı Tanrı'),
(11, '2', 'Brackern'),
(12, '2', 'İblis'),
(13, '2', 'Ruh'),
(14, '2', 'Yılan'),
(15, '2', 'Ejderha'),
(16, '2', 'Ölümsüz'),
(17, '2', 'Sibernetik'),
(18, '2', 'Minotor'),
(19, '2', 'Göksel'),
(20, '2', 'Trol'),
(21, '2', 'Hayvan'),
(22, '2', 'Bitki'),
(23, '2', 'Büyülü Yaratık'),
(24, '2', 'Otomaton'),
(25, '2', 'Yükselmiş'),
(26, '2', 'Buz Anka Kuşu'),
(27, '2', 'Amfibi'),
(28, '2', 'Gargoyle'),
(29, '2', 'Hayalet Centaur'),
(30, '2', 'Kemirgen'),
(31, '2', 'Yarı-Ağaç'),
(32, '2', 'Rüzgar Ruhu'),
(33, '2', 'Kabus'),
(34, '2', 'Mutant'),
(35, '2', 'Varlık'),
(36, '2', 'Melez');

-- Türkçe kaynak tipi çevirileri
INSERT INTO resource_translations (resource_id, language_id, name) VALUES
(1, '2', 'Mana'),
(2, '2', 'Enerji'),
(3, '2', 'Öfke'),
(4, '2', 'Kalkan'),
(5, '2', 'Kan'),
(6, '2', 'Cesaret'),
(7, '2', 'Isı'),
(8, '2', 'Cephane'),
(9, '2', 'Manasız'),
(10, '2', 'Sağlık'),
(11, '2', 'Akış');

-- Türkçe dövüş menzili çevirileri
INSERT INTO combat_range_translations (combat_range_id, language_id, name) VALUES
(1, '2', 'Yakın'),
(2, '2', 'Uzak'),
(3, '2', 'Melez');

-- Türkçe bölge çevirileri
INSERT INTO region_translations (region_id, language_id, name, description) VALUES
(1, '2', 'Ionia', 'Büyü ve denge diyarı'),
(2, '2', 'Noxus', 'Acımasız, yayılmacı bir imparatorluk'),
(3, '2', 'Demacia', 'Hukuk ve adalet krallığı'),
(4, '2', 'Piltover', 'İlerleme şehri'),
(5, '2', 'Zaun', 'Kimyasallar ve kirliliğin alt şehri'),
(6, '2', 'Freljord', 'Sert, buzlu bir vahşi arazi'),
(7, '2', 'Shurima', 'Düşmüş çöl imparatorluğu'),
(8, '2', 'Bilgewater', 'Kanunsuz bir liman şehri'),
(9, '2', 'Targon', 'Yıldızlara uzanan kutsal bir dağ'),
(10, '2', 'Shadow Isles', 'Kara Sis tarafından bozulmuş adalar'),
(11, '2', 'Bandle City', 'Yordle\'ların yuvası'),
(12, '2', 'Ixtal', 'İzole edilmiş bir orman alemi'),
(13, '2', 'Void', 'Gerçekliğin ötesindeki kabus alemi'),
(14, '2', 'Runeterra', 'Dünyanın kendisi'),
(15, '2', 'Icathia', 'Antik, düşmüş bir medeniyet');

-- Şampiyonların Türkçe çevirileri
INSERT INTO champion_translations (champion_id, language_id, name, title) VALUES
(1, '2', 'Aatrox', 'Darkin Kılıcı'),
(2, '2', 'Ahri', 'Dokuz Kuyruklu Tilki'),
(3, '2', 'Akali', 'Haydut Suikastçı'),
(4, '2', 'Akshan', 'Haydut Muhafız'),
(5, '2', 'Alistar', 'Minotaur'),
(6, '2', 'Ambessa', 'Noxus Generali'),
(7, '2', 'Amumu', 'Hüzünlü Mumya'),
(8, '2', 'Anivia', 'Buz Anka Kuşu'),
(9, '2', 'Annie', 'Karanlık Çocuk'),
(10, '2', 'Aphelios', 'İnançlıların Silahı'),
(11, '2', 'Ashe', 'Buz Okçusu'),
(12, '2', 'Aurelion Sol', 'Yıldız Yapıcı'),
(13, '2', 'Aurora', 'Kışın Öfkesi'),
(14, '2', 'Azir', 'Kumların İmparatoru'),
(15, '2', 'Bard', 'Gezgin Koruyucu'),
(16, '2', 'Bel\'Veth', 'Boşluğun İmparatoriçesi'),
(17, '2', 'Blitzcrank', 'Büyük Buhar Golemi'),
(18, '2', 'Brand', 'Yanan İntikam'),
(19, '2', 'Braum', 'Freljord\'un Kalbi'),
(20, '2', 'Briar', 'Açlığın Laneti'),
(21, '2', 'Caitlyn', 'Piltover\'ın Şerifi'),
(22, '2', 'Camille', 'Çelik Gölge'),
(23, '2', 'Cassiopeia', 'Yılanın Kucağı'),
(24, '2', 'Cho\'Gath', 'Boşluğun Dehşeti'),
(25, '2', 'Corki', 'Cesur Bombardımancı'),
(26, '2', 'Darius', 'Noxus\'un Eli'),
(27, '2', 'Diana', 'Ayın Küçümsemesi'),
(28, '2', 'Dr. Mundo', 'Zaun\'un Delisi'),
(29, '2', 'Draven', 'Şanlı Cellat'),
(30, '2', 'Ekko', 'Zamanı Kıran Çocuk'),
(31, '2', 'Elise', 'Örümcek Kraliçe'),
(32, '2', 'Evelynn', 'Acının Kucağı'),
(33, '2', 'Ezreal', 'Kaşif Dahi'),
(34, '2', 'Fiddlesticks', 'Kadim Korku'),
(35, '2', 'Fiora', 'Büyük Düellocu'),
(36, '2', 'Fizz', 'Gelgit Hilebazı'),
(37, '2', 'Galio', 'Dev'),
(38, '2', 'Gangplank', 'Tuzlu Su Belası'),
(39, '2', 'Garen', 'Demacia\'nın Gücü'),
(40, '2', 'Gnar', 'Kayıp Halka'),
(41, '2', 'Gragas', 'Ayaktakımı Kışkırtıcısı'),
(42, '2', 'Graves', 'Kanun Kaçağı'),
(43, '2', 'Gwen', 'Kutsanmış Terzi'),
(44, '2', 'Hecarim', 'Savaşın Gölgesi'),
(45, '2', 'Heimerdinger', 'Saygıdeğer Mucit'),
(46, '2', 'Hwei', 'Vizyoner'),
(47, '2', 'Illaoi', 'Kraken Rahibesi'),
(48, '2', 'Irelia', 'Bıçak Dansçısı'),
(49, '2', 'Ivern', 'Yeşil Baba'),
(50, '2', 'Janna', 'Fırtınanın Öfkesi'),
(51, '2', 'Jarvan IV', 'Demacia\'nın Örneği'),
(52, '2', 'Jax', 'Silahların Büyük Ustası'),
(53, '2', 'Jayce', 'Yarının Savunucusu'),
(54, '2', 'Jhin', 'Virtüöz'),
(55, '2', 'Jinx', 'Çılgın'),
(56, '2', 'K\'Sante', 'Nazumah\'ın Gururu'),
(57, '2', 'Kai\'Sa', 'Boşluğun Kızı'),
(58, '2', 'Kalista', 'İntikam Mızrağı'),
(59, '2', 'Karma', 'Aydınlanmış'),
(60, '2', 'Karthus', 'Ölüm Şarkıcısı'),
(61, '2', 'Kassadin', 'Boşluk Gezgini'),
(62, '2', 'Katarina', 'Uğursuz Bıçak'),
(63, '2', 'Kayle', 'Doğru'),
(64, '2', 'Kayn', 'Gölge Biçici'),
(65, '2', 'Kennen', 'Fırtınanın Kalbi'),
(66, '2', 'Kha\'Zix', 'Boşluk Yağmacısı'),
(67, '2', 'Kindred', 'Sonsuz Avcılar'),
(68, '2', 'Kled', 'Huysuz Süvari'),
(69, '2', 'Kog\'Maw', 'Uçurumun Ağzı'),
(70, '2', 'LeBlanc', 'Aldatıcı'),
(71, '2', 'Lee Sin', 'Kör Keşiş'),
(72, '2', 'Leona', 'Işıldayan Şafak'),
(73, '2', 'Lillia', 'Utangaç Çiçek'),
(74, '2', 'Lissandra', 'Buz Cadısı'),
(75, '2', 'Lucian', 'Arındırıcı'),
(76, '2', 'Lulu', 'Peri Büyücüsü'),
(77, '2', 'Lux', 'Işık Leydisi'),
(78, '2', 'Malphite', 'Monolitin Parçası'),
(79, '2', 'Malzahar', 'Boşluğun Peygamberi'),
(80, '2', 'Maokai', 'Çarpık Ağaç'),
(81, '2', 'Master Yi', 'Wuju Kılıç Ustası'),
(82, '2', 'Mel', 'Gizemli Diplomat'),
(83, '2', 'Milio', 'Nazik Alev'),
(84, '2', 'Miss Fortune', 'Ödül Avcısı'),
(85, '2', 'Mordekaiser', 'Demir Hortlak'),
(86, '2', 'Morgana', 'Düşen'),
(87, '2', 'Nami', 'Dalga Çağıran'),
(88, '2', 'Nasus', 'Kumların Bekçisi'),
(89, '2', 'Nautilus', 'Derinliklerin Devi'),
(90, '2', 'Naafiri', 'Yüz Isırığın Tazısı'),
(91, '2', 'Neeko', 'Meraklı Bukalemun'),
(92, '2', 'Nidalee', 'Vahşi Avcı'),
(93, '2', 'Nilah', 'Sınırsız Neşe'),
(94, '2', 'Nocturne', 'Sonsuz Kabus'),
(95, '2', 'Nunu ve Willump', 'Çocuk ve Yetisi'),
(96, '2', 'Olaf', 'Berserker'),
(97, '2', 'Orianna', 'Saat Leydisi'),
(98, '2', 'Ornn', 'Dağın Altındaki Ateş'),
(99, '2', 'Pantheon', 'Kırılmaz Mızrak'),
(100, '2', 'Poppy', 'Çekicin Bekçisi'),
(101, '2', 'Pyke', 'Kan Limanının Doğrayıcısı'),
(102, '2', 'Qiyana', 'Elementlerin İmparatoriçesi'),
(103, '2', 'Quinn', 'Demacia\'nın Kanatları'),
(104, '2', 'Rakan', 'Çapkın'),
(105, '2', 'Rammus', 'Zırhlı Armadillo'),
(106, '2', 'Rek\'Sai', 'Boşluk Kazıcı'),
(107, '2', 'Rell', 'Demir Bakire'),
(108, '2', 'Renata Glasc', 'Kimya Baronesi'),
(109, '2', 'Renekton', 'Kumların Kasabı'),
(110, '2', 'Rengar', 'Gurur Avcısı'),
(111, '2', 'Riven', 'Sürgün'),
(112, '2', 'Rumble', 'Mekanik Tehlike'),
(113, '2', 'Ryze', 'Rün Büyücüsü'),
(114, '2', 'Samira', 'Çöl Gülü'),
(115, '2', 'Sejuani', 'Kuzeyin Öfkesi'),
(116, '2', 'Senna', 'Kurtarıcı'),
(117, '2', 'Seraphine', 'Yıldızlara Bakan Şarkıcı'),
(118, '2', 'Sett', 'Patron'),
(119, '2', 'Shaco', 'İblis Soytarı'),
(120, '2', 'Shen', 'Alacakaranlığın Gözü'),
(121, '2', 'Shyvana', 'Yarı Ejderha'),
(122, '2', 'Singed', 'Çılgın Kimyager'),
(123, '2', 'Sion', 'Ölümsüz Savaş Makinesi'),
(124, '2', 'Sivir', 'Savaş Hanımefendisi'),
(125, '2', 'Skarner', 'Kristal Muhafız'),
(126, '2', 'Smolder', 'Genç Alev'),
(127, '2', 'Sona', 'Tellerin Üstadı'),
(128, '2', 'Soraka', 'Yıldız Çocuğu'),
(129, '2', 'Swain', 'Noxus Büyük Generali'),
(130, '2', 'Sylas', 'Zincirsiz'),
(131, '2', 'Syndra', 'Karanlık Hükümdar'),
(132, '2', 'Tahm Kench', 'Nehir Kralı'),
(133, '2', 'Taliyah', 'Taş Dokuyucu'),
(134, '2', 'Talon', 'Bıçağın Gölgesi'),
(135, '2', 'Taric', 'Valoran\'ın Kalkanı'),
(136, '2', 'Teemo', 'Çevik İzci'),
(137, '2', 'Thresh', 'Zincir Gardiyanı'),
(138, '2', 'Tristana', 'Yordle Silahşör'),
(139, '2', 'Trundle', 'Trol Kral'),
(140, '2', 'Tryndamere', 'Barbar Kral'),
(141, '2', 'Twisted Fate', 'Kart Ustası'),
(142, '2', 'Twitch', 'Veba Sıçanı'),
(143, '2', 'Udyr', 'Ruh Gezgini'),
(144, '2', 'Urgot', 'Korkunç Savaş Makinesi'),
(145, '2', 'Varus', 'İntikam Oku'),
(146, '2', 'Vayne', 'Gece Avcısı'),
(147, '2', 'Veigar', 'Küçük Kötülük Ustası'),
(148, '2', 'Vel\'Koz', 'Boşluğun Gözü'),
(149, '2', 'Vex', 'Karamsarlık'),
(150, '2', 'Vi', 'Piltover\'ın Muhafızı'),
(151, '2', 'Viego', 'Mahvolmuş Kral'),
(152, '2', 'Viktor', 'Makine Habercisi'),
(153, '2', 'Vladimir', 'Kızıl Biçici'),
(154, '2', 'Volibear', 'Amansız Fırtına'),
(155, '2', 'Warwick', 'Zaun\'un Zincirinden Kurtulmuş Öfkesi'),
(156, '2', 'Wukong', 'Maymun Kral'),
(157, '2', 'Xayah', 'İsyancı'),
(158, '2', 'Xerath', 'Yükselmiş Büyücü'),
(159, '2', 'Xin Zhao', 'Demacia\'nın Teşrifatçısı'),
(160, '2', 'Yasuo', 'Affedilmeyen'),
(161, '2', 'Yone', 'Unutulmayan'),
(162, '2', 'Yorick', 'Ruhların Çobanı'),
(163, '2', 'Yuumi', 'Büyülü Kedi'),
(164, '2', 'Zac', 'Gizli Silah'),
(165, '2', 'Zed', 'Gölgelerin Efendisi'),
(166, '2', 'Zeri', 'Zaun\'un Kıvılcımı'),
(167, '2', 'Ziggs', 'Patlayıcı Uzmanı'),
(168, '2', 'Zilean', 'Zaman Bekçisi'),
(169, '2', 'Zoe', 'Alacakaranlık Görünüşü'),
(170, '2', 'Zyra', 'Dikenlerin Yükselişi');

-- Almanca pozisyon çevirileri
INSERT INTO position_translations (position_id, language_id, name) VALUES
(1, '3', 'Oben'),
(2, '3', 'Dschungel'),
(3, '3', 'Mitte'),
(4, '3', 'Unten'),
(5, '3', 'Unterstützung');

-- Almanca tür çevirileri
INSERT INTO species_translations (species_id, language_id, name) VALUES
(1, '3', 'Mensch'),
(2, '3', 'Yordle'),
(3, '3', 'Vastaya'),
(4, '3', 'Darkin'),
(5, '3', 'Leere'),
(6, '3', 'Geist'),
(7, '3', 'Golem'),
(8, '3', 'Aspekt'),
(9, '3', 'Gott'),
(10, '3', 'Halbgott'),
(11, '3', 'Brackern'),
(12, '3', 'Dämon'),
(13, '3', 'Geist'),
(14, '3', 'Schlange'),
(15, '3', 'Drache'),
(16, '3', 'Untoter'),
(17, '3', 'Cyborg'),
(18, '3', 'Minotaurus'),
(19, '3', 'Himmlisch'),
(20, '3', 'Troll'),
(21, '3', 'Tier'),
(22, '3', 'Pflanze'),
(23, '3', 'Magisches Wesen'),
(24, '3', 'Automat'),
(25, '3', 'Aufgestiegener'),
(26, '3', 'Eisphönix'),
(27, '3', 'Amphibie'),
(28, '3', 'Gargoyle'),
(29, '3', 'Geisterhafter Zentaur'),
(30, '3', 'Nagetier'),
(31, '3', 'Halbbaum'),
(32, '3', 'Windgeist'),
(33, '3', 'Albtraum'),
(34, '3', 'Mutant'),
(35, '3', 'Wesen'),
(36, '3', 'Hybrid');

-- Almanca kaynak tipi çevirileri
INSERT INTO resource_translations (resource_id, language_id, name) VALUES
(1, '3', 'Mana'),
(2, '3', 'Energie'),
(3, '3', 'Wut'),
(4, '3', 'Schild'),
(5, '3', 'Blut'),
(6, '3', 'Mut'),
(7, '3', 'Hitze'),
(8, '3', 'Munition'),
(9, '3', 'Manalos'),
(10, '3', 'Gesundheit'),
(11, '3', 'Fluss');

-- Almanca dövüş menzili çevirileri
INSERT INTO combat_range_translations (combat_range_id, language_id, name) VALUES
(1, '3', 'Nahkampf'),
(2, '3', 'Fernkampf'),
(3, '3', 'Hybrid');

-- Almanca bölge çevirileri
INSERT INTO region_translations (region_id, language_id, name, description) VALUES
(1, '3', 'Ionia', 'Ein Land der Magie und des Gleichgewichts'),
(2, '3', 'Noxus', 'Ein brutales, expansionistisches Imperium'),
(3, '3', 'Demacia', 'Ein Königreich des Gesetzes und der Gerechtigkeit'),
(4, '3', 'Piltover', 'Die Stadt des Fortschritts'),
(5, '3', 'Zhaun', 'Die Unterstadt der Chemikalien und Verschmutzung'),
(6, '3', 'Freljord', 'Eine raue, eisige Wildnis'),
(7, '3', 'Shurima', 'Ein gefallenes Wüstenreich'),
(8, '3', 'Bilgewasser', 'Eine gesetzlose Hafenstadt'),
(9, '3', 'Targon', 'Ein heiliger Berg, der zu den Sternen reicht'),
(10, '3', 'Schatteninseln', 'Inseln, verdorben durch den Schwarzen Nebel'),
(11, '3', 'Bandle-Stadt', 'Heimat der Yordles'),
(12, '3', 'Ixtal', 'Ein isoliertes Dschungelreich'),
(13, '3', 'Leere', 'Eine alptraumhafte Welt jenseits der Realität'),
(14, '3', 'Runeterra', 'Die Welt selbst'),
(15, '3', 'Icathia', 'Eine antike, gefallene Zivilisation');

-- Şampiyonların Almanca çevirileri
INSERT INTO champion_translations (champion_id, language_id, name, title) VALUES
(1, '3', 'Aatrox', 'Die Darkin-Klinge'),
(2, '3', 'Ahri', 'Der Neunschweifige Fuchs'),
(3, '3', 'Akali', 'Die Abtrünnige Assassinin'),
(4, '3', 'Akshan', 'Der Abtrünnige Wächter'),
(5, '3', 'Alistar', 'Der Minotaurus'),
(6, '3', 'Ambessa', 'Die Noxianische Generalin'),
(7, '3', 'Amumu', 'Die Traurige Mumie'),
(8, '3', 'Anivia', 'Der Kryophönix'),
(9, '3', 'Annie', 'Das Dunkle Kind'),
(10, '3', 'Aphelios', 'Die Waffe der Gläubigen'),
(11, '3', 'Ashe', 'Die Frostbogenschützin'),
(12, '3', 'Aurelion Sol', 'Der Sternenschmied'),
(13, '3', 'Aurora', 'Der Zorn des Winters'),
(14, '3', 'Azir', 'Der Kaiser der Sande'),
(15, '3', 'Bard', 'Der Wandernde Hüter'),
(16, '3', 'Bel\'Veth', 'Die Kaiserin der Leere'),
(17, '3', 'Blitzcrank', 'Der Große Dampfgolem'),
(18, '3', 'Brand', 'Die Brennende Rache'),
(19, '3', 'Braum', 'Das Herz des Freljords'),
(20, '3', 'Briar', 'Der Fluch des Hungers'),
(21, '3', 'Caitlyn', 'Die Sheriffin von Piltover'),
(22, '3', 'Camille', 'Der Stahlschatten'),
(23, '3', 'Cassiopeia', 'Die Umarmung der Schlange'),
(24, '3', 'Cho\'Gath', 'Der Schrecken der Leere'),
(25, '3', 'Corki', 'Der Wagemutige Bombenschütze'),
(26, '3', 'Darius', 'Die Hand von Noxus'),
(27, '3', 'Diana', 'Die Verachtung des Mondes'),
(28, '3', 'Dr. Mundo', 'Der Verrückte von Zhaun'),
(29, '3', 'Draven', 'Der Ruhmreiche Scharfrichter'),
(30, '3', 'Ekko', 'Der Junge, der die Zeit zerschmetterte'),
(31, '3', 'Elise', 'Die Spinnenkönigin'),
(32, '3', 'Evelynn', 'Die Umarmung der Qual'),
(33, '3', 'Ezreal', 'Der Vermessene Entdecker'),
(34, '3', 'Fiddlesticks', 'Die Uralte Angst'),
(35, '3', 'Fiora', 'Die Großmeisterin der Duelle'),
(36, '3', 'Fizz', 'Der Gezeitenbetrüger'),
(37, '3', 'Galio', 'Der Koloss'),
(38, '3', 'Gangplank', 'Die Salzwassergeißel'),
(39, '3', 'Garen', 'Die Macht von Demacia'),
(40, '3', 'Gnar', 'Das Fehlende Bindeglied'),
(41, '3', 'Gragas', 'Der Aufwiegler'),
(42, '3', 'Graves', 'Der Gesetzlose'),
(43, '3', 'Gwen', 'Die Geheiligte Schneiderin'),
(44, '3', 'Hecarim', 'Der Schatten des Krieges'),
(45, '3', 'Heimerdinger', 'Der Verehrte Erfinder'),
(46, '3', 'Hwei', 'Der Visionär'),
(47, '3', 'Illaoi', 'Die Kraken-Priesterin'),
(48, '3', 'Irelia', 'Die Klingentänzerin'),
(49, '3', 'Ivern', 'Der Grüne Vater'),
(50, '3', 'Janna', 'Die Wut des Sturms'),
(51, '3', 'Jarvan IV', 'Das Vorbild von Demacia'),
(52, '3', 'Jax', 'Großmeister der Waffen'),
(53, '3', 'Jayce', 'Der Verteidiger von Morgen'),
(54, '3', 'Jhin', 'Der Virtuose'),
(55, '3', 'Jinx', 'Die Kanone ohne Sicherung'),
(56, '3', 'K\'Sante', 'Der Stolz von Nazumah'),
(57, '3', 'Kai\'Sa', 'Die Tochter der Leere'),
(58, '3', 'Kalista', 'Der Speer der Rache'),
(59, '3', 'Karma', 'Die Erleuchtete'),
(60, '3', 'Karthus', 'Der Todessänger'),
(61, '3', 'Kassadin', 'Der Leerwanderer'),
(62, '3', 'Katarina', 'Die Unheilvolle Klinge'),
(63, '3', 'Kayle', 'Die Gerechte'),
(64, '3', 'Kayn', 'Der Schattenschnitter'),
(65, '3', 'Kennen', 'Das Herz des Sturms'),
(66, '3', 'Kha\'Zix', 'Der Leerenräuber'),
(67, '3', 'Kindred', 'Die Ewigen Jäger'),
(68, '3', 'Kled', 'Der Reizbare Kavalier'),
(69, '3', 'Kog\'Maw', 'Der Rachen des Abgrunds'),
(70, '3', 'LeBlanc', 'Die Betrügerin'),
(71, '3', 'Lee Sin', 'Der Blinde Mönch'),
(72, '3', 'Leona', 'Die Strahlende Morgendämmerung'),
(73, '3', 'Lillia', 'Die Schüchterne Blüte'),
(74, '3', 'Lissandra', 'Die Eishexe'),
(75, '3', 'Lucian', 'Der Läuterer'),
(76, '3', 'Lulu', 'Die Feenzauberin'),
(77, '3', 'Lux', 'Die Dame des Lichts'),
(78, '3', 'Malphite', 'Splitter des Monolithen'),
(79, '3', 'Malzahar', 'Der Prophet der Leere'),
(80, '3', 'Maokai', 'Der Verdrehte Treant'),
(81, '3', 'Master Yi', 'Der Wuju-Klingenmeister'),
(82, '3', 'Mel', 'Die Arkane Diplomatin'),
(83, '3', 'Milio', 'Die Sanfte Flamme'),
(84, '3', 'Miss Fortune', 'Die Kopfgeldjägerin'),
(85, '3', 'Mordekaiser', 'Der Eiserne Wiedergänger'),
(86, '3', 'Morgana', 'Die Gefallene'),
(87, '3', 'Nami', 'Die Gezeitenruferin'),
(88, '3', 'Nasus', 'Der Hüter der Sande'),
(89, '3', 'Nautilus', 'Der Titan der Tiefen'),
(90, '3', 'Naafiri', 'Der Hund der Hundert Bisse'),
(91, '3', 'Neeko', 'Das Neugierige Chamäleon'),
(92, '3', 'Nidalee', 'Die Bestialische Jägerin'),
(93, '3', 'Nilah', 'Die Ungezügelte Freude'),
(94, '3', 'Nocturne', 'Der Ewige Albtraum'),
(95, '3', 'Nunu und Willump', 'Der Junge und Sein Yeti'),
(96, '3', 'Olaf', 'Der Berserker'),
(97, '3', 'Orianna', 'Die Dame des Uhrwerks'),
(98, '3', 'Ornn', 'Das Feuer Unter dem Berg'),
(99, '3', 'Pantheon', 'Der Unbrechbare Speer'),
(100, '3', 'Poppy', 'Hüterin des Hammers'),
(101, '3', 'Pyke', 'Der Schlitzer des Bluthafens'),
(102, '3', 'Qiyana', 'Kaiserin der Elemente'),
(103, '3', 'Quinn', 'Die Flügel von Demacia'),
(104, '3', 'Rakan', 'Der Charmeur'),
(105, '3', 'Rammus', 'Das Panzergürteltier'),
(106, '3', 'Rek\'Sai', 'Die Leeren-Tunnelgräberin'),
(107, '3', 'Rell', 'Die Eiserne Maid'),
(108, '3', 'Renata Glasc', 'Die Chem-Baronin'),
(109, '3', 'Renekton', 'Der Schlächter der Sande'),
(110, '3', 'Rengar', 'Der Stolzjäger'),
(111, '3', 'Riven', 'Die Verbannte'),
(112, '3', 'Rumble', 'Die Mechanisierte Bedrohung'),
(113, '3', 'Ryze', 'Der Runenmagier'),
(114, '3', 'Samira', 'Die Wüstenrose'),
(115, '3', 'Sejuani', 'Der Zorn des Nordens'),
(116, '3', 'Senna', 'Die Erlöserin'),
(117, '3', 'Seraphine', 'Die Sternäugige Sängerin'),
(118, '3', 'Sett', 'Der Boss'),
(119, '3', 'Shaco', 'Der Dämonische Narr'),
(120, '3', 'Shen', 'Das Auge der Dämmerung'),
(121, '3', 'Shyvana', 'Der Halbdrache'),
(122, '3', 'Singed', 'Der Verrückte Chemiker'),
(123, '3', 'Sion', 'Der Untote Moloch'),
(124, '3', 'Sivir', 'Die Kampfmeisterin'),
(125, '3', 'Skarner', 'Die Kristallwacht'),
(126, '3', 'Smolder', 'Die Junge Flamme'),
(127, '3', 'Sona', 'Meisterin der Saiten'),
(128, '3', 'Soraka', 'Das Sternenkind'),
(129, '3', 'Swain', 'Der Noxianische Großgeneral'),
(130, '3', 'Sylas', 'Der Entfesselte'),
(131, '3', 'Syndra', 'Die Dunkle Herrscherin'),
(132, '3', 'Tahm Kench', 'Der Flusskönig'),
(133, '3', 'Taliyah', 'Die Steinweberin'),
(134, '3', 'Talon', 'Der Schatten der Klinge'),
(135, '3', 'Taric', 'Der Schild von Valoran'),
(136, '3', 'Teemo', 'Der Flinke Kundschafter'),
(137, '3', 'Thresh', 'Der Kettenwächter'),
(138, '3', 'Tristana', 'Die Yordle-Kanonenführerin'),
(139, '3', 'Trundle', 'Der Trollkönig'),
(140, '3', 'Tryndamere', 'Der Barbarenkönig'),
(141, '3', 'Twisted Fate', 'Der Kartenmeister'),
(142, '3', 'Twitch', 'Die Pestratte'),
(143, '3', 'Udyr', 'Der Geistwanderer'),
(144, '3', 'Urgot', 'Der Schlachtkreuzer'),
(145, '3', 'Varus', 'Der Pfeil der Vergeltung'),
(146, '3', 'Vayne', 'Die Nachtjägerin'),
(147, '3', 'Veigar', 'Der Kleine Meister des Bösen'),
(148, '3', 'Vel\'Koz', 'Das Auge der Leere'),
(149, '3', 'Vex', 'Die Düsternis'),
(150, '3', 'Vi', 'Die Vollstreckerin von Piltover'),
(151, '3', 'Viego', 'Der Ruinierte König'),
(152, '3', 'Viktor', 'Der Maschinenherold'),
(153, '3', 'Vladimir', 'Der Purpurne Schnitter'),
(154, '3', 'Volibear', 'Der Unbarmherzige Sturm'),
(155, '3', 'Warwick', 'Der Entfesselte Zorn von Zhaun'),
(156, '3', 'Wukong', 'Der Affenkönig'),
(157, '3', 'Xayah', 'Die Rebellin'),
(158, '3', 'Xerath', 'Der Aufgestiegene Magier'),
(159, '3', 'Xin Zhao', 'Der Seneschall von Demacia'),
(160, '3', 'Yasuo', 'Der Unvergebene'),
(161, '3', 'Yone', 'Der Unvergessene'),
(162, '3', 'Yorick', 'Hirte der Seelen'),
(163, '3', 'Yuumi', 'Die Magische Katze'),
(164, '3', 'Zac', 'Die Geheimwaffe'),
(165, '3', 'Zed', 'Der Meister der Schatten'),
(166, '3', 'Zeri', 'Der Funke von Zhaun'),
(167, '3', 'Ziggs', 'Der Experte für Hexplosionen'),
(168, '3', 'Zilean', 'Der Zeitwächter'),
(169, '3', 'Zoe', 'Der Aspekt der Dämmerung'),
(170, '3', 'Zyra', 'Erhebung der Dornen');

-- Fransızca pozisyon çevirileri
INSERT INTO position_translations (position_id, language_id, name) VALUES
(1, '4', 'Haut'),
(2, '4', 'Jungle'),
(3, '4', 'Milieu'),
(4, '4', 'Bas'),
(5, '4', 'Support');

-- Fransızca tür çevirileri
INSERT INTO species_translations (species_id, language_id, name) VALUES
(1, '4', 'Humain'),
(2, '4', 'Yordle'),
(3, '4', 'Vastaya'),
(4, '4', 'Darkin'),
(5, '4', 'Néant'),
(6, '4', 'Fantôme'),
(7, '4', 'Golem'),
(8, '4', 'Aspect'),
(9, '4', 'Dieu'),
(10, '4', 'Demi-dieu'),
(11, '4', 'Brackern'),
(12, '4', 'Démon'),
(13, '4', 'Esprit'),
(14, '4', 'Serpent'),
(15, '4', 'Dragon'),
(16, '4', 'Mort-vivant'),
(17, '4', 'Cyborg'),
(18, '4', 'Minotaure'),
(19, '4', 'Céleste'),
(20, '4', 'Troll'),
(21, '4', 'Animal'),
(22, '4', 'Plante'),
(23, '4', 'Créature Magique'),
(24, '4', 'Automate'),
(25, '4', 'Ascendant'),
(26, '4', 'Phénix de Glace'),
(27, '4', 'Amphibien'),
(28, '4', 'Gargouille'),
(29, '4', 'Centaure Fantomatique'),
(30, '4', 'Rongeur'),
(31, '4', 'Mi-arbre'),
(32, '4', 'Esprit du Vent'),
(33, '4', 'Cauchemar'),
(34, '4', 'Mutant'),
(35, '4', 'Entité'),
(36, '4', 'Hybride');

-- Fransızca kaynak tipi çevirileri
INSERT INTO resource_translations (resource_id, language_id, name) VALUES
(1, '4', 'Mana'),
(2, '4', 'Énergie'),
(3, '4', 'Furie'),
(4, '4', 'Bouclier'),
(5, '4', 'Sang'),
(6, '4', 'Courage'),
(7, '4', 'Chaleur'),
(8, '4', 'Munitions'),
(9, '4', 'Sans mana'),
(10, '4', 'Santé'),
(11, '4', 'Flux');

-- Fransızca dövüş menzili çevirileri
INSERT INTO combat_range_translations (combat_range_id, language_id, name) VALUES
(1, '4', 'Corps à corps'),
(2, '4', 'À distance'),
(3, '4', 'Hybride');

-- Fransızca bölge çevirileri
INSERT INTO region_translations (region_id, language_id, name, description) VALUES
(1, '4', 'Ionia', 'Une terre de magie et d\'équilibre'),
(2, '4', 'Noxus', 'Un empire brutal et expansionniste'),
(3, '4', 'Demacia', 'Un royaume de loi et de justice'),
(4, '4', 'Piltover', 'La cité du progrès'),
(5, '4', 'Zaun', 'La sous-ville des produits chimiques et de la pollution'),
(6, '4', 'Freljord', 'Une nature sauvage rude et glacée'),
(7, '4', 'Shurima', 'Un empire désertique déchu'),
(8, '4', 'Bilgewater', 'Une ville portuaire sans loi'),
(9, '4', 'Targon', 'Une montagne sacrée atteignant les étoiles'),
(10, '4', 'Îles Obscures', 'Des îles corrompues par la Brume Noire'),
(11, '4', 'Bandle', 'Foyer des Yordles'),
(12, '4', 'Ixtal', 'Un royaume de jungle isolé'),
(13, '4', 'Néant', 'Un royaume cauchemardesque au-delà de la réalité'),
(14, '4', 'Runeterra', 'Le monde lui-même'),
(15, '4', 'Icathia', 'Une civilisation ancienne et déchue');

-- Şampiyonların Fransızca çevirileri
INSERT INTO champion_translations (champion_id, language_id, name, title) VALUES
(1, '4', 'Aatrox', 'La Lame Darkin'),
(2, '4', 'Ahri', 'Le Renard à Neuf Queues'),
(3, '4', 'Akali', 'L\'Assassin Hors-la-loi'),
(4, '4', 'Akshan', 'Le Sentinelle Rebelle'),
(5, '4', 'Alistar', 'Le Minotaure'),
(6, '4', 'Ambessa', 'La Générale Noxienne'),
(7, '4', 'Amumu', 'La Momie Triste'),
(8, '4', 'Anivia', 'Le Cryophénix'),
(9, '4', 'Annie', 'L\'Enfant des Ténèbres'),
(10, '4', 'Aphelios', 'L\'Arme des Fidèles'),
(11, '4', 'Ashe', 'L\'Archère de Givre'),
(12, '4', 'Aurelion Sol', 'Le Forgeur d\'Étoiles'),
(13, '4', 'Aurora', 'La Colère de l\'Hiver'),
(14, '4', 'Azir', 'L\'Empereur des Sables'),
(15, '4', 'Bard', 'Le Gardien Errant'),
(16, '4', 'Bel\'Veth', 'L\'Impératrice du Néant'),
(17, '4', 'Blitzcrank', 'Le Grand Golem de Vapeur'),
(18, '4', 'Brand', 'La Vengeance Ardente'),
(19, '4', 'Braum', 'Le Cœur du Freljord'),
(20, '4', 'Briar', 'La Malédiction de la Faim'),
(21, '4', 'Caitlyn', 'La Shérif de Piltover'),
(22, '4', 'Camille', 'L\'Ombre d\'Acier'),
(23, '4', 'Cassiopeia', 'L\'Étreinte du Serpent'),
(24, '4', 'Cho\'Gath', 'La Terreur du Néant'),
(25, '4', 'Corki', 'Le Bombardier Intrépide'),
(26, '4', 'Darius', 'La Main de Noxus'),
(27, '4', 'Diana', 'Le Dédain de la Lune'),
(28, '4', 'Dr. Mundo', 'Le Fou de Zaun'),
(29, '4', 'Draven', 'Le Glorieux Exécuteur'),
(30, '4', 'Ekko', 'Le Garçon qui a Brisé le Temps'),
(31, '4', 'Elise', 'La Reine des Araignées'),
(32, '4', 'Evelynn', 'L\'Étreinte de l\'Agonie'),
(33, '4', 'Ezreal', 'L\'Explorateur Prodige'),
(34, '4', 'Fiddlesticks', 'La Peur Ancestrale'),
(35, '4', 'Fiora', 'La Grande Duelliste'),
(36, '4', 'Fizz', 'Le Filou des Marées'),
(37, '4', 'Galio', 'Le Colosse'),
(38, '4', 'Gangplank', 'Le Fléau des Mers'),
(39, '4', 'Garen', 'La Puissance de Demacia'),
(40, '4', 'Gnar', 'Le Chaînon Manquant'),
(41, '4', 'Gragas', 'L\'Agitateur'),
(42, '4', 'Graves', 'Le Hors-la-loi'),
(43, '4', 'Gwen', 'La Couturière Sacrée'),
(44, '4', 'Hecarim', 'L\'Ombre de la Guerre'),
(45, '4', 'Heimerdinger', 'L\'Inventeur Vénéré'),
(46, '4', 'Hwei', 'Le Visionnaire'),
(47, '4', 'Illaoi', 'La Prêtresse du Kraken'),
(48, '4', 'Irelia', 'La Danseuse des Lames'),
(49, '4', 'Ivern', 'Le Père Vert'),
(50, '4', 'Janna', 'La Furie de la Tempête'),
(51, '4', 'Jarvan IV', 'L\'Exemple de Demacia'),
(52, '4', 'Jax', 'Grand Maître d\'Armes'),
(53, '4', 'Jayce', 'Le Défenseur de Demain'),
(54, '4', 'Jhin', 'Le Virtuose'),
(55, '4', 'Jinx', 'Le Canon Lâché'),
(56, '4', 'K\'Sante', 'La Fierté de Nazumah'),
(57, '4', 'Kai\'Sa', 'La Fille du Néant'),
(58, '4', 'Kalista', 'La Lance de la Vengeance'),
(59, '4', 'Karma', 'L\'Illuminée'),
(60, '4', 'Karthus', 'Le Chanteur de Mort'),
(61, '4', 'Kassadin', 'Le Marcheur du Néant'),
(62, '4', 'Katarina', 'La Lame Sinistre'),
(63, '4', 'Kayle', 'La Juste'),
(64, '4', 'Kayn', 'Le Faucheur des Ombres'),
(65, '4', 'Kennen', 'Le Cœur de la Tempête'),
(66, '4', 'Kha\'Zix', 'Le Faucheur du Néant'),
(67, '4', 'Kindred', 'Les Chasseurs Éternels'),
(68, '4', 'Kled', 'Le Cavalier Irascible'),
(69, '4', 'Kog\'Maw', 'La Gueule de l\'Abîme'),
(70, '4', 'LeBlanc', 'La Mystificatrice'),
(71, '4', 'Lee Sin', 'Le Moine Aveugle'),
(72, '4', 'Leona', 'L\'Aube Radieuse'),
(73, '4', 'Lillia', 'La Fleur Timide'),
(74, '4', 'Lissandra', 'La Sorcière de Glace'),
(75, '4', 'Lucian', 'Le Purificateur'),
(76, '4', 'Lulu', 'La Fée Sorcière'),
(77, '4', 'Lux', 'La Dame de Lumière'),
(78, '4', 'Malphite', 'Éclat du Monolithe'),
(79, '4', 'Malzahar', 'Le Prophète du Néant'),
(80, '4', 'Maokai', 'L\'Arbre Tordu'),
(81, '4', 'Master Yi', 'Le Spadassin Wuju'),
(82, '4', 'Mel', 'La Diplomate Arcanique'),
(83, '4', 'Milio', 'La Flamme Douce'),
(84, '4', 'Miss Fortune', 'La Chasseuse de Primes'),
(85, '4', 'Mordekaiser', 'Le Revenant de Fer'),
(86, '4', 'Morgana', 'La Déchue'),
(87, '4', 'Nami', 'L\'Aquamancienne'),
(88, '4', 'Nasus', 'Le Gardien des Sables'),
(89, '4', 'Nautilus', 'Le Titan des Profondeurs'),
(90, '4', 'Naafiri', 'Le Molosse aux Cent Morsures'),
(91, '4', 'Neeko', 'Le Caméléon Curieux'),
(92, '4', 'Nidalee', 'La Chasseresse Bestiale'),
(93, '4', 'Nilah', 'La Joie Sans Limites'),
(94, '4', 'Nocturne', 'Le Cauchemar Éternel'),
(95, '4', 'Nunu et Willump', 'Le Garçon et Son Yéti'),
(96, '4', 'Olaf', 'Le Berserker'),
(97, '4', 'Orianna', 'La Dame à la Montre'),
(98, '4', 'Ornn', 'Le Feu Sous la Montagne'),
(99, '4', 'Pantheon', 'La Lance Inébranlable'),
(100, '4', 'Poppy', 'Gardienne du Marteau'),
(101, '4', 'Pyke', 'L\'Éventreur du Port Sanglant'),
(102, '4', 'Qiyana', 'Impératrice des Éléments'),
(103, '4', 'Quinn', 'Les Ailes de Demacia'),
(104, '4', 'Rakan', 'Le Charmeur'),
(105, '4', 'Rammus', 'Le Tatou Blindé'),
(106, '4', 'Rek\'Sai', 'La Foreuse du Néant'),
(107, '4', 'Rell', 'La Vierge de Fer'),
(108, '4', 'Renata Glasc', 'La Baronne Chimique'),
(109, '4', 'Renekton', 'Le Boucher des Sables'),
(110, '4', 'Rengar', 'Le Traqueur de Fierté'),
(111, '4', 'Riven', 'L\'Exilée'),
(112, '4', 'Rumble', 'La Menace Mécanisée'),
(113, '4', 'Ryze', 'Le Mage des Runes'),
(114, '4', 'Samira', 'La Rose du Désert'),
(115, '4', 'Sejuani', 'La Furie du Nord'),
(116, '4', 'Senna', 'La Rédemptrice'),
(117, '4', 'Seraphine', 'La Chanteuse aux Yeux Étoilés'),
(118, '4', 'Sett', 'Le Patron'),
(119, '4', 'Shaco', 'Le Bouffon Démoniaque'),
(120, '4', 'Shen', 'L\'Œil du Crépuscule'),
(121, '4', 'Shyvana', 'La Demi-Dragon'),
(122, '4', 'Singed', 'Le Chimiste Fou'),
(123, '4', 'Sion', 'Le Colosse Mort-Vivant'),
(124, '4', 'Sivir', 'La Maîtresse de Bataille'),
(125, '4', 'Skarner', 'La Sentinelle de Cristal'),
(126, '4', 'Smolder', 'La Jeune Flamme'),
(127, '4', 'Sona', 'La Virtuose des Cordes'),
(128, '4', 'Soraka', 'L\'Enfant des Étoiles'),
(129, '4', 'Swain', 'Le Grand Général Noxien'),
(130, '4', 'Sylas', 'Le Déchaîné'),
(131, '4', 'Syndra', 'La Souveraine Obscure'),
(132, '4', 'Tahm Kench', 'Le Roi de la Rivière'),
(133, '4', 'Taliyah', 'La Tisseuse de Pierre'),
(134, '4', 'Talon', 'L\'Ombre de la Lame'),
(135, '4', 'Taric', 'Le Bouclier de Valoran'),
(136, '4', 'Teemo', 'L\'Éclaireur Agile'),
(137, '4', 'Thresh', 'Le Gardien des Chaînes'),
(138, '4', 'Tristana', 'La Canonnier Yordle'),
(139, '4', 'Trundle', 'Le Roi des Trolls'),
(140, '4', 'Tryndamere', 'Le Roi Barbare'),
(141, '4', 'Twisted Fate', 'Le Maître des Cartes'),
(142, '4', 'Twitch', 'Le Rat de la Peste'),
(143, '4', 'Udyr', 'Le Marcheur d\'Esprit'),
(144, '4', 'Urgot', 'Le Cuirassé'),
(145, '4', 'Varus', 'La Flèche de la Rétribution'),
(146, '4', 'Vayne', 'La Chasseuse Nocturne'),
(147, '4', 'Veigar', 'Le Petit Maître du Mal'),
(148, '4', 'Vel\'Koz', 'L\'Œil du Néant'),
(149, '4', 'Vex', 'La Moroseuse'),
(150, '4', 'Vi', 'La Justicière de Piltover'),
(151, '4', 'Viego', 'Le Roi Déchu'),
(152, '4', 'Viktor', 'Le Héraut des Machines'),
(153, '4', 'Vladimir', 'Le Faucheur Cramoisi'),
(154, '4', 'Volibear', 'L\'Orage Implacable'),
(155, '4', 'Warwick', 'La Colère Déchaînée de Zaun'),
(156, '4', 'Wukong', 'Le Roi des Singes'),
(157, '4', 'Xayah', 'La Rebelle'),
(158, '4', 'Xerath', 'Le Mage Ascendant'),
(159, '4', 'Xin Zhao', 'Le Sénéchal de Demacia'),
(160, '4', 'Yasuo', 'L\'Impardonnable'),
(161, '4', 'Yone', 'L\'Inoublié'),
(162, '4', 'Yorick', 'Berger des Âmes'),
(163, '4', 'Yuumi', 'Le Chat Magique'),
(164, '4', 'Zac', 'L\'Arme Secrète'),
(165, '4', 'Zed', 'Le Maître des Ombres'),
(166, '4', 'Zeri', 'L\'Étincelle de Zaun'),
(167, '4', 'Ziggs', 'L\'Expert en Hexplosifs'),
(168, '4', 'Zilean', 'Le Gardien du Temps'),
(169, '4', 'Zoe', 'L\'Aspect du Crépuscule'),
(170, '4', 'Zyra', 'L\'Éveil des Épines');


-- İspanyolca pozisyon çevirileri
INSERT INTO position_translations (position_id, language_id, name) VALUES
(1, '5', 'Superior'),
(2, '5', 'Jungla'),
(3, '5', 'Medio'),
(4, '5', 'Inferior'),
(5, '5', 'Soporte');

-- İspanyolca tür çevirileri
INSERT INTO species_translations (species_id, language_id, name) VALUES
(1, '5', 'Humano'),
(2, '5', 'Yordle'),
(3, '5', 'Vastaya'),
(4, '5', 'Darkin'),
(5, '5', 'Vacío'),
(6, '5', 'Fantasma'),
(7, '5', 'Gólem'),
(8, '5', 'Aspecto'),
(9, '5', 'Dios'),
(10, '5', 'Semidiós'),
(11, '5', 'Brackern'),
(12, '5', 'Demonio'),
(13, '5', 'Espíritu'),
(14, '5', 'Serpiente'),
(15, '5', 'Dragón'),
(16, '5', 'No-muerto'),
(17, '5', 'Ciborg'),
(18, '5', 'Minotauro'),
(19, '5', 'Celestial'),
(20, '5', 'Trol'),
(21, '5', 'Animal'),
(22, '5', 'Planta'),
(23, '5', 'Criatura Mágica'),
(24, '5', 'Autómata'),
(25, '5', 'Ascendido'),
(26, '5', 'Fénix de Hielo'),
(27, '5', 'Anfibio'),
(28, '5', 'Gárgola'),
(29, '5', 'Centauro Fantasmal'),
(30, '5', 'Roedor'),
(31, '5', 'Semi-Árbol'),
(32, '5', 'Espíritu del Viento'),
(33, '5', 'Pesadilla'),
(34, '5', 'Mutante'),
(35, '5', 'Entidad'),
(36, '5', 'Híbrido');

-- İspanyolca kaynak tipi çevirileri
INSERT INTO resource_translations (resource_id, language_id, name) VALUES
(1, '5', 'Maná'),
(2, '5', 'Energía'),
(3, '5', 'Furia'),
(4, '5', 'Escudo'),
(5, '5', 'Sangre'),
(6, '5', 'Valor'),
(7, '5', 'Calor'),
(8, '5', 'Munición'),
(9, '5', 'Sin maná'),
(10, '5', 'Salud'),
(11, '5', 'Flujo');

-- İspanyolca dövüş menzili çevirileri
INSERT INTO combat_range_translations (combat_range_id, language_id, name) VALUES
(1, '5', 'Cuerpo a cuerpo'),
(2, '5', 'A distancia'),
(3, '5', 'Híbrido');

-- İspanyolca bölge çevirileri
INSERT INTO region_translations (region_id, language_id, name, description) VALUES
(1, '5', 'Jonia', 'Una tierra de magia y equilibrio'),
(2, '5', 'Noxus', 'Un imperio brutal y expansionista'),
(3, '5', 'Demacia', 'Un reino de ley y justicia'),
(4, '5', 'Piltóver', 'La ciudad del progreso'),
(5, '5', 'Zaun', 'La ciudad subterránea de químicos y contaminación'),
(6, '5', 'Freljord', 'Un duro y helado páramo'),
(7, '5', 'Shurima', 'Un imperio desértico caído'),
(8, '5', 'Aguasturbias', 'Una ciudad portuaria sin ley'),
(9, '5', 'Targón', 'Una montaña sagrada que alcanza las estrellas'),
(10, '5', 'Islas de la Sombra', 'Islas corrompidas por la Niebla Negra'),
(11, '5', 'Ciudad de Bandle', 'Hogar de los Yordles'),
(12, '5', 'Ixtal', 'Un reino selvático aislado'),
(13, '5', 'Vacío', 'Un reino de pesadilla más allá de la realidad'),
(14, '5', 'Runaterra', 'El mundo mismo'),
(15, '5', 'Icathia', 'Una civilización antigua y caída');

-- Şampiyonların İspanyolca çevirileri
INSERT INTO champion_translations (champion_id, language_id, name, title) VALUES
(1, '5', 'Aatrox', 'La Espada Darkin'),
(2, '5', 'Ahri', 'El Zorro de Nueve Colas'),
(3, '5', 'Akali', 'La Asesina Renegada'),
(4, '5', 'Akshan', 'El Centinela Rebelde'),
(5, '5', 'Alistar', 'El Minotauro'),
(6, '5', 'Ambessa', 'La General Noxiana'),
(7, '5', 'Amumu', 'La Momia Triste'),
(8, '5', 'Anivia', 'El Criofénix'),
(9, '5', 'Annie', 'La Niña Oscura'),
(10, '5', 'Aphelios', 'El Arma de los Fieles'),
(11, '5', 'Ashe', 'La Arquera de Hielo'),
(12, '5', 'Aurelion Sol', 'El Forjador de Estrellas'),
(13, '5', 'Aurora', 'La Ira del Invierno'),
(14, '5', 'Azir', 'El Emperador de las Arenas'),
(15, '5', 'Bardo', 'El Guardián Errante'),
(16, '5', 'Bel\'Veth', 'La Emperatriz del Vacío'),
(17, '5', 'Blitzcrank', 'El Gran Gólem de Vapor'),
(18, '5', 'Brand', 'La Venganza Ardiente'),
(19, '5', 'Braum', 'El Corazón del Freljord'),
(20, '5', 'Briar', 'La Maldición del Hambre'),
(21, '5', 'Caitlyn', 'La Sheriff de Piltóver'),
(22, '5', 'Camille', 'La Sombra de Acero'),
(23, '5', 'Cassiopeia', 'El Abrazo de la Serpiente'),
(24, '5', 'Cho\'Gath', 'El Terror del Vacío'),
(25, '5', 'Corki', 'El Bombardero Osado'),
(26, '5', 'Darius', 'La Mano de Noxus'),
(27, '5', 'Diana', 'El Desdén de la Luna'),
(28, '5', 'Dr. Mundo', 'El Loco de Zaun'),
(29, '5', 'Draven', 'El Ejecutor Glorioso'),
(30, '5', 'Ekko', 'El Chico que Rompió el Tiempo'),
(31, '5', 'Elise', 'La Reina Araña'),
(32, '5', 'Evelynn', 'El Abrazo de la Agonía'),
(33, '5', 'Ezreal', 'El Explorador Pródigo'),
(34, '5', 'Fiddlesticks', 'El Terror Ancestral'),
(35, '5', 'Fiora', 'La Gran Duelista'),
(36, '5', 'Fizz', 'El Embaucador de las Mareas'),
(37, '5', 'Galio', 'El Coloso'),
(38, '5', 'Gangplank', 'El Azote de los Mares'),
(39, '5', 'Garen', 'El Poder de Demacia'),
(40, '5', 'Gnar', 'El Eslabón Perdido'),
(41, '5', 'Gragas', 'El Alborotador'),
(42, '5', 'Graves', 'El Forajido'),
(43, '5', 'Gwen', 'La Costurera Consagrada'),
(44, '5', 'Hecarim', 'La Sombra de la Guerra'),
(45, '5', 'Heimerdinger', 'El Inventor Venerado'),
(46, '5', 'Hwei', 'El Visionario'),
(47, '5', 'Illaoi', 'La Sacerdotisa del Kraken'),
(48, '5', 'Irelia', 'La Bailarina de las Cuchillas'),
(49, '5', 'Ivern', 'El Padre Verde'),
(50, '5', 'Janna', 'La Furia de la Tormenta'),
(51, '5', 'Jarvan IV', 'El Ejemplo de Demacia'),
(52, '5', 'Jax', 'Gran Maestro de Armas'),
(53, '5', 'Jayce', 'El Defensor del Mañana'),
(54, '5', 'Jhin', 'El Virtuoso'),
(55, '5', 'Jinx', 'La Bala Perdida'),
(56, '5', 'K\'Sante', 'El Orgullo de Nazumah'),
(57, '5', 'Kai\'Sa', 'La Hija del Vacío'),
(58, '5', 'Kalista', 'La Lanza de la Venganza'),
(59, '5', 'Karma', 'La Iluminada'),
(60, '5', 'Karthus', 'El Cantor de la Muerte'),
(61, '5', 'Kassadin', 'El Caminante del Vacío'),
(62, '5', 'Katarina', 'La Cuchilla Siniestra'),
(63, '5', 'Kayle', 'La Justa'),
(64, '5', 'Kayn', 'El Segador de las Sombras'),
(65, '5', 'Kennen', 'El Corazón de la Tempestad'),
(66, '5', 'Kha\'Zix', 'El Saqueador del Vacío'),
(67, '5', 'Kindred', 'Los Cazadores Eternos'),
(68, '5', 'Kled', 'El Jinete Cascarrabias'),
(69, '5', 'Kog\'Maw', 'La Boca del Abismo'),
(70, '5', 'LeBlanc', 'La Embaucadora'),
(71, '5', 'Lee Sin', 'El Monje Ciego'),
(72, '5', 'Leona', 'El Amanecer Radiante'),
(73, '5', 'Lillia', 'La Flor Tímida'),
(74, '5', 'Lissandra', 'La Bruja de Hielo'),
(75, '5', 'Lucian', 'El Purificador'),
(76, '5', 'Lulu', 'La Hechicera Feérica'),
(77, '5', 'Lux', 'La Dama de la Luminosidad'),
(78, '5', 'Malphite', 'Fragmento del Monolito'),
(79, '5', 'Malzahar', 'El Profeta del Vacío'),
(80, '5', 'Maokai', 'El Treant Retorcido'),
(81, '5', 'Maestro Yi', 'El Espadachín Wuju'),
(82, '5', 'Mel', 'La Diplomática Arcana'),
(83, '5', 'Milio', 'La Llama Suave'),
(84, '5', 'Miss Fortune', 'La Cazarrecompensas'),
(85, '5', 'Mordekaiser', 'El Resucitado de Hierro'),
(86, '5', 'Morgana', 'La Caída'),
(87, '5', 'Nami', 'La Mareomotriz'),
(88, '5', 'Nasus', 'El Guardián de las Arenas'),
(89, '5', 'Nautilus', 'El Titán de las Profundidades'),
(90, '5', 'Naafiri', 'El Sabueso de los Cien Mordiscos'),
(91, '5', 'Neeko', 'El Camaleón Curioso'),
(92, '5', 'Nidalee', 'La Cazadora Bestial'),
(93, '5', 'Nilah', 'La Alegría Desatada'),
(94, '5', 'Nocturne', 'La Pesadilla Eterna'),
(95, '5', 'Nunu y Willump', 'El Niño y Su Yeti'),
(96, '5', 'Olaf', 'El Berserker'),
(97, '5', 'Orianna', 'La Dama del Reloj'),
(98, '5', 'Ornn', 'El Fuego Bajo la Montaña'),
(99, '5', 'Pantheon', 'La Lanza Inquebrantable'),
(100, '5', 'Poppy', 'Guardiana del Martillo'),
(101, '5', 'Pyke', 'El Destripador del Puerto Sangriento'),
(102, '5', 'Qiyana', 'Emperatriz de los Elementos'),
(103, '5', 'Quinn', 'Las Alas de Demacia'),
(104, '5', 'Rakan', 'El Encantador'),
(105, '5', 'Rammus', 'El Armadurillo'),
(106, '5', 'Rek\'Sai', 'La Excavadora del Vacío'),
(107, '5', 'Rell', 'La Doncella de Hierro'),
(108, '5', 'Renata Glasc', 'La Baronesa Química'),
(109, '5', 'Renekton', 'El Carnicero de las Arenas'),
(110, '5', 'Rengar', 'El Acechador del Orgullo'),
(111, '5', 'Riven', 'La Exiliada'),
(112, '5', 'Rumble', 'La Amenaza Mecanizada'),
(113, '5', 'Ryze', 'El Mago Rúnico'),
(114, '5', 'Samira', 'La Rosa del Desierto'),
(115, '5', 'Sejuani', 'La Furia del Norte'),
(116, '5', 'Senna', 'La Redentora'),
(117, '5', 'Seraphine', 'La Cantante de Ojos Estrellados'),
(118, '5', 'Sett', 'El Jefe'),
(119, '5', 'Shaco', 'El Bufón Demoníaco'),
(120, '5', 'Shen', 'El Ojo del Crepúsculo'),
(121, '5', 'Shyvana', 'La Semidragona'),
(122, '5', 'Singed', 'El Químico Loco'),
(123, '5', 'Sion', 'El Coloso No-muerto'),
(124, '5', 'Sivir', 'La Maestra de la Batalla'),
(125, '5', 'Skarner', 'La Vanguardia de Cristal'),
(126, '5', 'Smolder', 'La Llama Joven'),
(127, '5', 'Sona', 'La Virtuosa de las Cuerdas'),
(128, '5', 'Soraka', 'La Hija de las Estrellas'),
(129, '5', 'Swain', 'El Gran General Noxiano'),
(130, '5', 'Sylas', 'El Desencadenado'),
(131, '5', 'Syndra', 'La Soberana Oscura'),
(132, '5', 'Tahm Kench', 'El Rey del Río'),
(133, '5', 'Taliyah', 'La Tejedora de Piedra'),
(134, '5', 'Talon', 'La Sombra de la Hoja'),
(135, '5', 'Taric', 'El Escudo de Valoran'),
(136, '5', 'Teemo', 'El Explorador Veloz'),
(137, '5', 'Thresh', 'El Carcelero de las Cadenas'),
(138, '5', 'Tristana', 'La Artillera Yordle'),
(139, '5', 'Trundle', 'El Rey Trol'),
(140, '5', 'Tryndamere', 'El Rey Bárbaro'),
(141, '5', 'Twisted Fate', 'El Maestro de las Cartas'),
(142, '5', 'Twitch', 'La Rata de la Peste'),
(143, '5', 'Udyr', 'El Caminante Espiritual'),
(144, '5', 'Urgot', 'El Acorazado'),
(145, '5', 'Varus', 'La Flecha de la Retribución'),
(146, '5', 'Vayne', 'La Cazadora Nocturna'),
(147, '5', 'Veigar', 'El Pequeño Maestro del Mal'),
(148, '5', 'Vel\'Koz', 'El Ojo del Vacío'),
(149, '5', 'Vex', 'La Melancólica'),
(150, '5', 'Vi', 'La Vigilante de Piltóver'),
(151, '5', 'Viego', 'El Rey Arruinado'),
(152, '5', 'Viktor', 'El Heraldo de las Máquinas'),
(153, '5', 'Vladimir', 'El Segador Carmesí'),
(154, '5', 'Volibear', 'La Tormenta Implacable'),
(155, '5', 'Warwick', 'La Ira Desatada de Zaun'),
(156, '5', 'Wukong', 'El Rey Mono'),
(157, '5', 'Xayah', 'La Rebelde'),
(158, '5', 'Xerath', 'El Mago Ascendido'),
(159, '5', 'Xin Zhao', 'El Senescal de Demacia'),
(160, '5', 'Yasuo', 'El Imperdonable'),
(161, '5', 'Yone', 'El Inolvidado'),
(162, '5', 'Yorick', 'Pastor de Almas'),
(163, '5', 'Yuumi', 'La Gata Mágica'),
(164, '5', 'Zac', 'El Arma Secreta'),
(165, '5', 'Zed', 'El Maestro de las Sombras'),
(166, '5', 'Zeri', 'La Chispa de Zaun'),
(167, '5', 'Ziggs', 'El Experto en Hexplosivos'),
(168, '5', 'Zilean', 'El Guardián del Tiempo'),
(169, '5', 'Zoe', 'El Aspecto del Crepúsculo'),
(170, '5', 'Zyra', 'El Resurgir de las Espinas');


-- İtalyanca pozisyon çevirileri
INSERT INTO position_translations (position_id, language_id, name) VALUES
(1, '6', 'Superiore'),
(2, '6', 'Giungla'),
(3, '6', 'Centrale'),
(4, '6', 'Inferiore'),
(5, '6', 'Supporto');

-- İtalyanca tür çevirileri
INSERT INTO species_translations (species_id, language_id, name) VALUES
(1, '6', 'Umano'),
(2, '6', 'Yordle'),
(3, '6', 'Vastaya'),
(4, '6', 'Darkin'),
(5, '6', 'Vuoto'),
(6, '6', 'Fantasma'),
(7, '6', 'Golem'),
(8, '6', 'Aspetto'),
(9, '6', 'Dio'),
(10, '6', 'Semidio'),
(11, '6', 'Brackern'),
(12, '6', 'Demone'),
(13, '6', 'Spirito'),
(14, '6', 'Serpente'),
(15, '6', 'Drago'),
(16, '6', 'Non-morto'),
(17, '6', 'Cyborg'),
(18, '6', 'Minotauro'),
(19, '6', 'Celestiale'),
(20, '6', 'Troll'),
(21, '6', 'Animale'),
(22, '6', 'Pianta'),
(23, '6', 'Creatura Magica'),
(24, '6', 'Automa'),
(25, '6', 'Asceso'),
(26, '6', 'Fenice di Ghiaccio'),
(27, '6', 'Anfibio'),
(28, '6', 'Gargoyle'),
(29, '6', 'Centauro Spettrale'),
(30, '6', 'Roditore'),
(31, '6', 'Semi-Albero'),
(32, '6', 'Spirito del Vento'),
(33, '6', 'Incubo'),
(34, '6', 'Mutante'),
(35, '6', 'Entità'),
(36, '6', 'Ibrido');

-- İtalyanca kaynak tipi çevirileri
INSERT INTO resource_translations (resource_id, language_id, name) VALUES
(1, '6', 'Mana'),
(2, '6', 'Energia'),
(3, '6', 'Furia'),
(4, '6', 'Scudo'),
(5, '6', 'Sangue'),
(6, '6', 'Coraggio'),
(7, '6', 'Calore'),
(8, '6', 'Munizioni'),
(9, '6', 'Senza Mana'),
(10, '6', 'Salute'),
(11, '6', 'Flusso');

-- İtalyanca dövüş menzili çevirileri
INSERT INTO combat_range_translations (combat_range_id, language_id, name) VALUES
(1, '6', 'Corpo a corpo'),
(2, '6', 'A distanza'),
(3, '6', 'Ibrido');

-- İtalyanca bölge çevirileri
INSERT INTO region_translations (region_id, language_id, name, description) VALUES
(1, '6', 'Ionia', 'Una terra di magia ed equilibrio'),
(2, '6', 'Noxus', 'Un impero brutale ed espansionista'),
(3, '6', 'Demacia', 'Un regno di legge e giustizia'),
(4, '6', 'Piltover', 'La città del progresso'),
(5, '6', 'Zaun', 'La città sotterranea di sostanze chimiche e inquinamento'),
(6, '6', 'Freljord', 'Una natura selvaggia dura e ghiacciata'),
(7, '6', 'Shurima', 'Un impero desertico caduto'),
(8, '6', 'Bilgewater', 'Una città portuale senza legge'),
(9, '6', 'Targon', 'Una montagna sacra che raggiunge le stelle'),
(10, '6', 'Isole dell\'Ombra', 'Isole corrotte dalla Nebbia Nera'),
(11, '6', 'Città di Bandle', 'Patria degli Yordle'),
(12, '6', 'Ixtal', 'Un regno della giungla isolato'),
(13, '6', 'Vuoto', 'Un regno da incubo oltre la realtà'),
(14, '6', 'Runeterra', 'Il mondo stesso'),
(15, '6', 'Icathia', 'Un\'antica civiltà caduta');

-- Şampiyonların İtalyanca çevirileri
INSERT INTO champion_translations (champion_id, language_id, name, title) VALUES
(1, '6', 'Aatrox', 'La Lama Darkin'),
(2, '6', 'Ahri', 'La Volpe a Nove Code'),
(3, '6', 'Akali', 'L\'Assassina Rinnegata'),
(4, '6', 'Akshan', 'La Sentinella Ribelle'),
(5, '6', 'Alistar', 'Il Minotauro'),
(6, '6', 'Ambessa', 'La Generale Noxiana'),
(7, '6', 'Amumu', 'La Mummia Triste'),
(8, '6', 'Anivia', 'La Criofenix'),
(9, '6', 'Annie', 'La Bambina Oscura'),
(10, '6', 'Aphelios', 'L\'Arma dei Fedeli'),
(11, '6', 'Ashe', 'L\'Arciere di Ghiaccio'),
(12, '6', 'Aurelion Sol', 'Il Forgiatore di Stelle'),
(13, '6', 'Aurora', 'L\'Ira dell\'Inverno'),
(14, '6', 'Azir', 'L\'Imperatore delle Sabbie'),
(15, '6', 'Bard', 'Il Custode Errante'),
(16, '6', 'Bel\'Veth', 'L\'Imperatrice del Vuoto'),
(17, '6', 'Blitzcrank', 'Il Grande Golem a Vapore'),
(18, '6', 'Brand', 'La Vendetta Ardente'),
(19, '6', 'Braum', 'Il Cuore del Freljord'),
(20, '6', 'Briar', 'La Maledizione della Fame'),
(21, '6', 'Caitlyn', 'Lo Sceriffo di Piltover'),
(22, '6', 'Camille', 'L\'Ombra d\'Acciaio'),
(23, '6', 'Cassiopeia', 'L\'Abbraccio del Serpente'),
(24, '6', 'Cho\'Gath', 'Il Terrore del Vuoto'),
(25, '6', 'Corki', 'L\'Audace Bombardiere'),
(26, '6', 'Darius', 'La Mano di Noxus'),
(27, '6', 'Diana', 'Il Disprezzo della Luna'),
(28, '6', 'Dr. Mundo', 'Il Pazzo di Zaun'),
(29, '6', 'Draven', 'Il Glorioso Carnefice'),
(30, '6', 'Ekko', 'Il Ragazzo Che Ha Infranto il Tempo'),
(31, '6', 'Elise', 'La Regina Ragno'),
(32, '6', 'Evelynn', 'L\'Abbraccio dell\'Agonia'),
(33, '6', 'Ezreal', 'L\'Esploratore Prodigio'),
(34, '6', 'Fiddlesticks', 'La Paura Ancestrale'),
(35, '6', 'Fiora', 'La Grande Duellante'),
(36, '6', 'Fizz', 'L\'Imbroglione delle Maree'),
(37, '6', 'Galio', 'Il Colosso'),
(38, '6', 'Gangplank', 'Il Flagello dei Mari'),
(39, '6', 'Garen', 'La Potenza di Demacia'),
(40, '6', 'Gnar', 'L\'Anello Mancante'),
(41, '6', 'Gragas', 'L\'Istigatore'),
(42, '6', 'Graves', 'Il Fuorilegge'),
(43, '6', 'Gwen', 'La Sarta Consacrata'),
(44, '6', 'Hecarim', 'L\'Ombra della Guerra'),
(45, '6', 'Heimerdinger', 'L\'Inventore Venerato'),
(46, '6', 'Hwei', 'Il Visionario'),
(47, '6', 'Illaoi', 'La Sacerdotessa del Kraken'),
(48, '6', 'Irelia', 'La Danzatrice delle Lame'),
(49, '6', 'Ivern', 'Il Padre Verde'),
(50, '6', 'Janna', 'La Furia della Tempesta'),
(51, '6', 'Jarvan IV', 'L\'Esempio di Demacia'),
(52, '6', 'Jax', 'Maestro d\'Armi'),
(53, '6', 'Jayce', 'Il Difensore del Domani'),
(54, '6', 'Jhin', 'Il Virtuoso'),
(55, '6', 'Jinx', 'Il Cannone Scatenato'),
(56, '6', 'K\'Sante', 'L\'Orgoglio di Nazumah'),
(57, '6', 'Kai\'Sa', 'La Figlia del Vuoto'),
(58, '6', 'Kalista', 'La Lancia della Vendetta'),
(59, '6', 'Karma', 'L\'Illuminata'),
(60, '6', 'Karthus', 'Il Cantore della Morte'),
(61, '6', 'Kassadin', 'Il Viandante del Vuoto'),
(62, '6', 'Katarina', 'La Lama Sinistra'),
(63, '6', 'Kayle', 'La Giusta'),
(64, '6', 'Kayn', 'Il Mietitore delle Ombre'),
(65, '6', 'Kennen', 'Il Cuore della Tempesta'),
(66, '6', 'Kha\'Zix', 'Il Predatore del Vuoto'),
(67, '6', 'Kindred', 'I Cacciatori Eterni'),
(68, '6', 'Kled', 'Il Cavaliere Irascibile'),
(69, '6', 'Kog\'Maw', 'La Bocca dell\'Abisso'),
(70, '6', 'LeBlanc', 'L\'Ingannatrice'),
(71, '6', 'Lee Sin', 'Il Monaco Cieco'),
(72, '6', 'Leona', 'L\'Alba Radiosa'),
(73, '6', 'Lillia', 'Il Fiore Timido'),
(74, '6', 'Lissandra', 'La Strega di Ghiaccio'),
(75, '6', 'Lucian', 'Il Purificatore'),
(76, '6', 'Lulu', 'La Fata Incantatrice'),
(77, '6', 'Lux', 'La Signora della Luminosità'),
(78, '6', 'Malphite', 'Frammento del Monolito'),
(79, '6', 'Malzahar', 'Il Profeta del Vuoto'),
(80, '6', 'Maokai', 'Il Treant Contorto'),
(81, '6', 'Master Yi', 'Lo Spadaccino Wuju'),
(82, '6', 'Mel', 'La Diplomatica Arcana'),
(83, '6', 'Milio', 'La Fiamma Gentile'),
(84, '6', 'Miss Fortune', 'La Cacciatrice di Taglie'),
(85, '6', 'Mordekaiser', 'Il Revenant di Ferro'),
(86, '6', 'Morgana', 'La Caduta'),
(87, '6', 'Nami', 'L\'Evocatrice delle Maree'),
(88, '6', 'Nasus', 'Il Custode delle Sabbie'),
(89, '6', 'Nautilus', 'Il Titano delle Profondità'),
(90, '6', 'Naafiri', 'Il Segugio dai Cento Morsi'),
(91, '6', 'Neeko', 'Il Camaleonte Curioso'),
(92, '6', 'Nidalee', 'La Cacciatrice Bestiale'),
(93, '6', 'Nilah', 'La Gioia Senza Limiti'),
(94, '6', 'Nocturne', 'L\'Incubo Eterno'),
(95, '6', 'Nunu e Willump', 'Il Ragazzo e il Suo Yeti'),
(96, '6', 'Olaf', 'Il Berserker'),
(97, '6', 'Orianna', 'La Signora dell\'Orologio'),
(98, '6', 'Ornn', 'Il Fuoco Sotto la Montagna'),
(99, '6', 'Pantheon', 'La Lancia Indistruttibile'),
(100, '6', 'Poppy', 'Custode del Martello'),
(101, '6', 'Pyke', 'Lo Squartatore del Porto Insanguinato'),
(102, '6', 'Qiyana', 'Imperatrice degli Elementi'),
(103, '6', 'Quinn', 'Le Ali di Demacia'),
(104, '6', 'Rakan', 'L\'Ammaliatore'),
(105, '6', 'Rammus', 'L\'Armadillo'),
(106, '6', 'Rek\'Sai', 'La Scavatrice del Vuoto'),
(107, '6', 'Rell', 'La Vergine di Ferro'),
(108, '6', 'Renata Glasc', 'La Baronessa Chimica'),
(109, '6', 'Renekton', 'Il Macellaio delle Sabbie'),
(110, '6', 'Rengar', 'Il Cacciatore d\'Orgoglio'),
(111, '6', 'Riven', 'L\'Esiliata'),
(112, '6', 'Rumble', 'La Minaccia Meccanizzata'),
(113, '6', 'Ryze', 'Il Mago Runico'),
(114, '6', 'Samira', 'La Rosa del Deserto'),
(115, '6', 'Sejuani', 'La Furia del Nord'),
(116, '6', 'Senna', 'La Redentrice'),
(117, '6', 'Seraphine', 'La Cantante dagli Occhi Stellati'),
(118, '6', 'Sett', 'Il Boss'),
(119, '6', 'Shaco', 'Il Giullare Demoniaco'),
(120, '6', 'Shen', 'L\'Occhio del Crepuscolo'),
(121, '6', 'Shyvana', 'La Mezzodragona'),
(122, '6', 'Singed', 'Il Chimico Pazzo'),
(123, '6', 'Sion', 'Il Colosso Non-morto'),
(124, '6', 'Sivir', 'La Signora della Battaglia'),
(125, '6', 'Skarner', 'La Vanguardia di Cristallo'),
(126, '6', 'Smolder', 'La Giovane Fiamma'),
(127, '6', 'Sona', 'La Virtuosa delle Corde'),
(128, '6', 'Soraka', 'La Figlia delle Stelle'),
(129, '6', 'Swain', 'Il Grande Generale Noxiano'),
(130, '6', 'Sylas', 'Lo Scatenato'),
(131, '6', 'Syndra', 'La Sovrana Oscura'),
(132, '6', 'Tahm Kench', 'Il Re del Fiume'),
(133, '6', 'Taliyah', 'La Tessitrice di Pietra'),
(134, '6', 'Talon', 'L\'Ombra della Lama'),
(135, '6', 'Taric', 'Lo Scudo di Valoran'),
(136, '6', 'Teemo', 'L\'Esploratore Rapido'),
(137, '6', 'Thresh', 'Il Guardiano delle Catene'),
(138, '6', 'Tristana', 'La Cannoniera Yordle'),
(139, '6', 'Trundle', 'Il Re dei Troll'),
(140, '6', 'Tryndamere', 'Il Re Barbaro'),
(141, '6', 'Twisted Fate', 'Il Maestro delle Carte'),
(142, '6', 'Twitch', 'Il Ratto della Peste'),
(143, '6', 'Udyr', 'Il Camminatore Spirituale'),
(144, '6', 'Urgot', 'La Corazzata'),
(145, '6', 'Varus', 'La Freccia della Retribuzione'),
(146, '6', 'Vayne', 'La Cacciatrice Notturna'),
(147, '6', 'Veigar', 'Il Piccolo Maestro del Male'),
(148, '6', 'Vel\'Koz', 'L\'Occhio del Vuoto'),
(149, '6', 'Vex', 'La Malinconica'),
(150, '6', 'Vi', 'La Vigilante di Piltover'),
(151, '6', 'Viego', 'Il Re in Rovina'),
(152, '6', 'Viktor', 'L\'Araldo delle Macchine'),
(153, '6', 'Vladimir', 'Il Mietitore Cremisi'),
(154, '6', 'Volibear', 'La Tempesta Implacabile'),
(155, '6', 'Warwick', 'L\'Ira Scatenata di Zaun'),
(156, '6', 'Wukong', 'Il Re Scimmia'),
(157, '6', 'Xayah', 'La Ribelle'),
(158, '6', 'Xerath', 'Il Mago Asceso'),
(159, '6', 'Xin Zhao', 'Il Siniscalco di Demacia'),
(160, '6', 'Yasuo', 'L\'Imperdonabile'),
(161, '6', 'Yone', 'L\'Indimenticato'),
(162, '6', 'Yorick', 'Pastore di Anime'),
(163, '6', 'Yuumi', 'Il Gatto Magico'),
(164, '6', 'Zac', 'L\'Arma Segreta'),
(165, '6', 'Zed', 'Il Maestro delle Ombre'),
(166, '6', 'Zeri', 'La Scintilla di Zaun'),
(167, '6', 'Ziggs', 'L\'Esperto di Hexplosivi'),
(168, '6', 'Zilean', 'Il Custode del Tempo'),
(169, '6', 'Zoe', 'L\'Aspetto del Crepuscolo'),
(170, '6', 'Zyra', 'Il Risveglio delle Spine');

-- Rusça pozisyon çevirileri
INSERT INTO position_translations (position_id, language_id, name) VALUES
(1, '7', 'Верхняя линия'),
(2, '7', 'Лес'),
(3, '7', 'Средняя линия'),
(4, '7', 'Нижняя линия'),
(5, '7', 'Поддержка');

-- Rusça tür çevirileri
INSERT INTO species_translations (species_id, language_id, name) VALUES
(1, '7', 'Человек'),
(2, '7', 'Йордл'),
(3, '7', 'Вастайя'),
(4, '7', 'Даркин'),
(5, '7', 'Бездна'),
(6, '7', 'Призрак'),
(7, '7', 'Голем'),
(8, '7', 'Аспект'),
(9, '7', 'Бог'),
(10, '7', 'Полубог'),
(11, '7', 'Бракерн'),
(12, '7', 'Демон'),
(13, '7', 'Дух'),
(14, '7', 'Змея'),
(15, '7', 'Дракон'),
(16, '7', 'Нежить'),
(17, '7', 'Киборг'),
(18, '7', 'Минотавр'),
(19, '7', 'Небесный'),
(20, '7', 'Тролль'),
(21, '7', 'Животное'),
(22, '7', 'Растение'),
(23, '7', 'Магическое Существо'),
(24, '7', 'Автомат'),
(25, '7', 'Вознесенный'),
(26, '7', 'Ледяной Феникс'),
(27, '7', 'Амфибия'),
(28, '7', 'Горгулья'),
(29, '7', 'Призрачный Кентавр'),
(30, '7', 'Грызун'),
(31, '7', 'Получеловек-полудерево'),
(32, '7', 'Дух Ветра'),
(33, '7', 'Кошмар'),
(34, '7', 'Мутант'),
(35, '7', 'Сущность'),
(36, '7', 'Гибрид');

-- Rusça kaynak tipi çevirileri
INSERT INTO resource_translations (resource_id, language_id, name) VALUES
(1, '7', 'Мана'),
(2, '7', 'Энергия'),
(3, '7', 'Ярость'),
(4, '7', 'Щит'),
(5, '7', 'Кровь'),
(6, '7', 'Храбрость'),
(7, '7', 'Жар'),
(8, '7', 'Боеприпасы'),
(9, '7', 'Без маны'),
(10, '7', 'Здоровье'),
(11, '7', 'Поток');

-- Rusça dövüş menzili çevirileri
INSERT INTO combat_range_translations (combat_range_id, language_id, name) VALUES
(1, '7', 'Ближний бой'),
(2, '7', 'Дальний бой'),
(3, '7', 'Гибридный');

-- Rusça bölge çevirileri
INSERT INTO region_translations (region_id, language_id, name, description) VALUES
(1, '7', 'Иония', 'Земля магии и равновесия'),
(2, '7', 'Ноксус', 'Жестокая, экспансионистская империя'),
(3, '7', 'Демасия', 'Королевство закона и справедливости'),
(4, '7', 'Пилтовер', 'Город прогресса'),
(5, '7', 'Заун', 'Подземный город химикатов и загрязнения'),
(6, '7', 'Фрельйорд', 'Суровая, ледяная пустошь'),
(7, '7', 'Шурима', 'Павшая пустынная империя'),
(8, '7', 'Билджвотер', 'Беззаконный портовый город'),
(9, '7', 'Таргон', 'Священная гора, достигающая звезд'),
(10, '7', 'Сумрачные острова', 'Острова, искаженные Черным Туманом'),
(11, '7', 'Бандл Сити', 'Дом Йордлов'),
(12, '7', 'Икстал', 'Изолированное джунглевое царство'),
(13, '7', 'Бездна', 'Кошмарное царство за пределами реальности'),
(14, '7', 'Рунтерра', 'Сам мир'),
(15, '7', 'Икатия', 'Древняя павшая цивилизация');

-- Şampiyonların Rusça çevirileri
INSERT INTO champion_translations (champion_id, language_id, name, title) VALUES
(1, '7', 'Атрокс', 'Клинок Даркинов'),
(2, '7', 'Ари', 'Девятихвостая Лиса'),
(3, '7', 'Акали', 'Отступница-убийца'),
(4, '7', 'Акшан', 'Страж-изгой'),
(5, '7', 'Алистар', 'Минотавр'),
(6, '7', 'Амбесса', 'Ноксианский Генерал'),
(7, '7', 'Амуму', 'Печальная Мумия'),
(8, '7', 'Анивия', 'Ледяной Феникс'),
(9, '7', 'Энни', 'Темное Дитя'),
(10, '7', 'Афелий', 'Оружие Верующих'),
(11, '7', 'Эш', 'Ледяная Лучница'),
(12, '7', 'Аурелион Сол', 'Создатель Звезд'),
(13, '7', 'Аврора', 'Гнев Зимы'),
(14, '7', 'Азир', 'Император Песков'),
(15, '7', 'Бард', 'Странствующий Хранитель'),
(16, '7', 'Бел\'Вет', 'Императрица Бездны'),
(17, '7', 'Блицкранк', 'Великий Паровой Голем'),
(18, '7', 'Бренд', 'Пылающая Месть'),
(19, '7', 'Браум', 'Сердце Фрельйорда'),
(20, '7', 'Брайар', 'Проклятие Голода'),
(21, '7', 'Кейтлин', 'Шериф Пилтовера'),
(22, '7', 'Камилла', 'Стальная Тень'),
(23, '7', 'Кассиопея', 'Объятия Змеи'),
(24, '7', 'Чо\'Гат', 'Ужас Бездны'),
(25, '7', 'Корки', 'Отважный Бомбардир'),
(26, '7', 'Дариус', 'Рука Ноксуса'),
(27, '7', 'Диана', 'Презрение Луны'),
(28, '7', 'Доктор Мундо', 'Безумец Зауна'),
(29, '7', 'Дрейвен', 'Прославленный Палач'),
(30, '7', 'Экко', 'Мальчик, Разбивший Время'),
(31, '7', 'Элиза', 'Королева Пауков'),
(32, '7', 'Эвелинн', 'Объятия Агонии'),
(33, '7', 'Эзреаль', 'Блудный Исследователь'),
(34, '7', 'Фиддлстикс', 'Древний Страх'),
(35, '7', 'Фиора', 'Великая Дуэлянтка'),
(36, '7', 'Физз', 'Морской Шутник'),
(37, '7', 'Галио', 'Колосс'),
(38, '7', 'Гангпланк', 'Гроза Соленых Вод'),
(39, '7', 'Гарен', 'Сила Демасии'),
(40, '7', 'Гнар', 'Недостающее Звено'),
(41, '7', 'Грагас', 'Буйный Бражник'),
(42, '7', 'Грейвз', 'Изгой'),
(43, '7', 'Гвен', 'Священная Швея'),
(44, '7', 'Хекарим', 'Тень Войны'),
(45, '7', 'Хеймердингер', 'Почитаемый Изобретатель'),
(46, '7', 'Хвей', 'Провидец'),
(47, '7', 'Иллаой', 'Жрица Кракена'),
(48, '7', 'Ирелия', 'Танцующая с Клинками'),
(49, '7', 'Иверн', 'Зеленый Отец'),
(50, '7', 'Жанна', 'Ярость Бури'),
(51, '7', 'Джарван IV', 'Пример Демасии'),
(52, '7', 'Джакс', 'Мастер Оружия'),
(53, '7', 'Джейс', 'Защитник Будущего'),
(54, '7', 'Джин', 'Виртуоз'),
(55, '7', 'Джинкс', 'Безбашенная Пушка'),
(56, '7', 'К\'Санте', 'Гордость Назумы'),
(57, '7', 'Кай\'Са', 'Дочь Бездны'),
(58, '7', 'Калиста', 'Копье Возмездия'),
(59, '7', 'Карма', 'Просветленная'),
(60, '7', 'Картус', 'Певец Смерти'),
(61, '7', 'Кассадин', 'Странник Бездны'),
(62, '7', 'Катарина', 'Зловещий Клинок'),
(63, '7', 'Кейл', 'Праведница'),
(64, '7', 'Каин', 'Жнец Теней'),
(65, '7', 'Кеннен', 'Сердце Бури'),
(66, '7', 'Ка\'Зикс', 'Похититель Бездны'),
(67, '7', 'Киндред', 'Вечные Охотники'),
(68, '7', 'Клед', 'Сварливый Кавалерист'),
(69, '7', 'Ког\'Мо', 'Пасть Бездны'),
(70, '7', 'ЛеБланк', 'Обманщица'),
(71, '7', 'Ли Син', 'Слепой Монах'),
(72, '7', 'Леона', 'Сияющий Рассвет'),
(73, '7', 'Лиллия', 'Застенчивый Цветок'),
(74, '7', 'Лиссандра', 'Ледяная Ведьма'),
(75, '7', 'Люциан', 'Очиститель'),
(76, '7', 'Лулу', 'Фея-Волшебница'),
(77, '7', 'Люкс', 'Леди Сияния'),
(78, '7', 'Мальфит', 'Осколок Монолита'),
(79, '7', 'Мальзахар', 'Пророк Бездны'),
(80, '7', 'Мао Кай', 'Искривленный Древень'),
(81, '7', 'Мастер Йи', 'Мечник Вуджу'),
(82, '7', 'Мэл', 'Тайный Дипломат'),
(83, '7', 'Милио', 'Нежное Пламя'),
(84, '7', 'Мисс Фортуна', 'Охотница за Головами'),
(85, '7', 'Мордекайзер', 'Железный Ревенант'),
(86, '7', 'Моргана', 'Падшая'),
(87, '7', 'Нами', 'Призывательница Приливов'),
(88, '7', 'Насус', 'Хранитель Песков'),
(89, '7', 'Наутилус', 'Титан Глубин'),
(90, '7', 'Наафири', 'Гончая Ста Укусов'),
(91, '7', 'Нико', 'Любопытный Хамелеон'),
(92, '7', 'Нидали', 'Звериная Охотница'),
(93, '7', 'Нила', 'Безграничная Радость'),
(94, '7', 'Ноктюрн', 'Вечный Кошмар'),
(95, '7', 'Нуну и Виллумп', 'Мальчик и его Йети'),
(96, '7', 'Олаф', 'Берсерк'),
(97, '7', 'Орианна', 'Леди Часовщик'),
(98, '7', 'Орн', 'Огонь Под Горой'),
(99, '7', 'Пантеон', 'Несокрушимое Копье'),
(100, '7', 'Поппи', 'Хранительница Молота'),
(101, '7', 'Пайк', 'Кровавый Потрошитель'),
(102, '7', 'Киана', 'Императрица Стихий'),
(103, '7', 'Квинн', 'Крылья Демасии'),
(104, '7', 'Рэйкан', 'Чаровник'),
(105, '7', 'Рамбл', 'Бронированный Броненосец'),
(106, '7', 'Рек\'Сай', 'Роющая Бездну'),
(107, '7', 'Релл', 'Железная Дева'),
(108, '7', 'Рената Гласк', 'Химбаронесса'),
(109, '7', 'Ренектон', 'Мясник Песков'),
(110, '7', 'Ренгар', 'Сталкер Гордости'),
(111, '7', 'Ривен', 'Изгнанница'),
(112, '7', 'Рамбл', 'Механизированная Угроза'),
(113, '7', 'Райз', 'Рунный Маг'),
(114, '7', 'Самира', 'Пустынная Роза'),
(115, '7', 'Седжуани', 'Ярость Севера'),
(116, '7', 'Сенна', 'Искупительница'),
(117, '7', 'Серафина', 'Звездноглазая Певица'),
(118, '7', 'Сетт', 'Босс'),
(119, '7', 'Шако', 'Демонический Шут'),
(120, '7', 'Шен', 'Глаз Сумерек'),
(121, '7', 'Шивана', 'Полудракон'),
(122, '7', 'Синджед', 'Безумный Химик'),
(123, '7', 'Сион', 'Нежить-колосс'),
(124, '7', 'Сивир', 'Повелительница Битвы'),
(125, '7', 'Скарнер', 'Кристаллический Авангард'),
(126, '7', 'Смолдер', 'Молодое Пламя'),
(127, '7', 'Сона', 'Мастер Струн'),
(128, '7', 'Сорака', 'Дитя Звезд'),
(129, '7', 'Свейн', 'Ноксианский Гранд-генерал'),
(130, '7', 'Сайлас', 'Раскованный'),
(131, '7', 'Синдра', 'Темная Владычица'),
(132, '7', 'Таам Кенч', 'Речной Король'),
(133, '7', 'Талия', 'Каменная Ткачиха'),
(134, '7', 'Талон', 'Тень Клинка'),
(135, '7', 'Тарик', 'Щит Валорана'),
(136, '7', 'Тимо', 'Быстрый Разведчик'),
(137, '7', 'Треш', 'Хранитель Цепей'),
(138, '7', 'Тристана', 'Йордл-канонир'),
(139, '7', 'Трандл', 'Король Троллей'),
(140, '7', 'Триндамир', 'Король Варваров'),
(141, '7', 'Твистед Фейт', 'Мастер Карт'),
(142, '7', 'Твич', 'Чумная Крыса'),
(143, '7', 'Удир', 'Духоходец'),
(144, '7', 'Ургот', 'Дредноут'),
(145, '7', 'Варус', 'Стрела Возмездия'),
(146, '7', 'Вейн', 'Ночная Охотница'),
(147, '7', 'Вейгар', 'Маленький Мастер Зла'),
(148, '7', 'Вел\'Коз', 'Око Бездны'),
(149, '7', 'Векс', 'Печальница'),
(150, '7', 'Вай', 'Страж Пилтовера'),
(151, '7', 'Виего', 'Разрушенный Король'),
(152, '7', 'Виктор', 'Глашатай Машин'),
(153, '7', 'Владимир', 'Алый Жнец'),
(154, '7', 'Волибир', 'Неумолимая Буря'),
(155, '7', 'Варвик', 'Неистовство Зауна'),
(156, '7', 'Вуконг', 'Король Обезьян'),
(157, '7', 'Шая', 'Мятежница'),
(158, '7', 'Зерат', 'Вознесенный Маг'),
(159, '7', 'Син Жао', 'Сенешаль Демасии'),
(160, '7', 'Ясуо', 'Непрощенный'),
(161, '7', 'Йоне', 'Незабытый'),
(162, '7', 'Йорик', 'Пастырь Душ'),
(163, '7', 'Юми', 'Волшебный Кот'),
(164, '7', 'Зак', 'Секретное Оружие'),
(165, '7', 'Зед', 'Мастер Теней'),
(166, '7', 'Зери', 'Искра Зауна'),
(167, '7', 'Зиггс', 'Эксперт по Взрывологии'),
(168, '7', 'Зилеан', 'Хранитель Времени'),
(169, '7', 'Зои', 'Аспект Сумерек'),
(170, '7', 'Зайра', 'Восстание Шипов');

-- Traduções de posições em português
INSERT INTO position_translations (position_id, language_id, name) VALUES
(1, '8', 'Topo'),
(2, '8', 'Selva'),
(3, '8', 'Meio'),
(4, '8', 'Inferior'),
(5, '8', 'Suporte');

-- Traduções de espécies em português
INSERT INTO species_translations (species_id, language_id, name) VALUES
(1, '8', 'Humano'),
(2, '8', 'Yordle'),
(3, '8', 'Vastaya'),
(4, '8', 'Darkin'),
(5, '8', 'Vazio'),
(6, '8', 'Fantasma'),
(7, '8', 'Golem'),
(8, '8', 'Aspecto'),
(9, '8', 'Deus'),
(10, '8', 'Semideus'),
(11, '8', 'Brackern'),
(12, '8', 'Demônio'),
(13, '8', 'Espírito'),
(14, '8', 'Serpente'),
(15, '8', 'Dragão'),
(16, '8', 'Morto-vivo'),
(17, '8', 'Ciborgue'),
(18, '8', 'Minotauro'),
(19, '8', 'Celestial'),
(20, '8', 'Troll'),
(21, '8', 'Animal'),
(22, '8', 'Planta'),
(23, '8', 'Criatura Mágica'),
(24, '8', 'Autômato'),
(25, '8', 'Ascendido'),
(26, '8', 'Fênix de Gelo'),
(27, '8', 'Anfíbio'),
(28, '8', 'Gárgula'),
(29, '8', 'Centauro Fantasmagórico'),
(30, '8', 'Roedor'),
(31, '8', 'Semi-Árvore'),
(32, '8', 'Espírito do Vento'),
(33, '8', 'Pesadelo'),
(34, '8', 'Mutante'),
(35, '8', 'Entidade'),
(36, '8', 'Híbrido');

-- Traduções de tipos de recurso em português
INSERT INTO resource_translations (resource_id, language_id, name) VALUES
(1, '8', 'Mana'),
(2, '8', 'Energia'),
(3, '8', 'Fúria'),
(4, '8', 'Escudo'),
(5, '8', 'Sangue'),
(6, '8', 'Coragem'),
(7, '8', 'Calor'),
(8, '8', 'Munição'),
(9, '8', 'Sem mana'),
(10, '8', 'Saúde'),
(11, '8', 'Fluxo');

-- Traduções de alcance de combate em português
INSERT INTO combat_range_translations (combat_range_id, language_id, name) VALUES
(1, '8', 'Corpo a corpo'),
(2, '8', 'À distância'),
(3, '8', 'Híbrido');

-- Traduções de regiões em português
INSERT INTO region_translations (region_id, language_id, name, description) VALUES
(1, '8', 'Ionia', 'Uma terra de magia e equilíbrio'),
(2, '8', 'Noxus', 'Um império brutal e expansionista'),
(3, '8', 'Demacia', 'Um reino de lei e justiça'),
(4, '8', 'Piltover', 'A cidade do progresso'),
(5, '8', 'Zaun', 'A subcidade de produtos químicos e poluição'),
(6, '8', 'Freljord', 'Uma natureza selvagem dura e gelada'),
(7, '8', 'Shurima', 'Um império desértico caído'),
(8, '8', 'Águas de Sentina', 'Uma cidade portuária sem lei'),
(9, '8', 'Targon', 'Uma montanha sagrada que alcança as estrelas'),
(10, '8', 'Ilhas das Sombras', 'Ilhas corrompidas pela Névoa Negra'),
(11, '8', 'Cidade de Bandle', 'Lar dos Yordles'),
(12, '8', 'Ixtal', 'Um reino isolado da selva'),
(13, '8', 'Vazio', 'Um reino de pesadelo além da realidade'),
(14, '8', 'Runeterra', 'O próprio mundo'),
(15, '8', 'Icathia', 'Uma antiga civilização caída');

-- Traduções de campeões em português
INSERT INTO champion_translations (champion_id, language_id, name, title) VALUES
(1, '8', 'Aatrox', 'A Lâmina Darkin'),
(2, '8', 'Ahri', 'A Raposa de Nove Caudas'),
(3, '8', 'Akali', 'A Assassina Renegada'),
(4, '8', 'Akshan', 'O Sentinela Rebelde'),
(5, '8', 'Alistar', 'O Minotauro'),
(6, '8', 'Ambessa', 'A General Noxiana'),
(7, '8', 'Amumu', 'A Múmia Triste'),
(8, '8', 'Anivia', 'A Criofênix'),
(9, '8', 'Annie', 'A Criança Sombria'),
(10, '8', 'Aphelios', 'A Arma dos Fiéis'),
(11, '8', 'Ashe', 'A Arqueira do Gelo'),
(12, '8', 'Aurelion Sol', 'O Forjador de Estrelas'),
(13, '8', 'Aurora', 'A Fúria do Inverno'),
(14, '8', 'Azir', 'O Imperador das Areias'),
(15, '8', 'Bardo', 'O Guardião Andarilho'),
(16, '8', 'Bel\'Veth', 'A Imperatriz do Vazio'),
(17, '8', 'Blitzcrank', 'O Grande Golem a Vapor'),
(18, '8', 'Brand', 'A Vingança Ardente'),
(19, '8', 'Braum', 'O Coração do Freljord'),
(20, '8', 'Briar', 'A Maldição da Fome'),
(21, '8', 'Caitlyn', 'A Xerife de Piltover'),
(22, '8', 'Camille', 'A Sombra de Aço'),
(23, '8', 'Cassiopeia', 'O Abraço da Serpente'),
(24, '8', 'Cho\'Gath', 'O Terror do Vazio'),
(25, '8', 'Corki', 'O Bombardeiro Ousado'),
(26, '8', 'Darius', 'A Mão de Noxus'),
(27, '8', 'Diana', 'O Escárnio da Lua'),
(28, '8', 'Dr. Mundo', 'O Louco de Zaun'),
(29, '8', 'Draven', 'O Carrasco Glorioso'),
(30, '8', 'Ekko', 'O Rapaz que Estilhaçou o Tempo'),
(31, '8', 'Elise', 'A Rainha Aranha'),
(32, '8', 'Evelynn', 'O Abraço da Agonia'),
(33, '8', 'Ezreal', 'O Explorador Pródigo'),
(34, '8', 'Fiddlesticks', 'O Terror Ancestral'),
(35, '8', 'Fiora', 'A Grande Duelista'),
(36, '8', 'Fizz', 'O Trapaceiro das Marés'),
(37, '8', 'Galio', 'O Colosso'),
(38, '8', 'Gangplank', 'O Flagelo das Águas'),
(39, '8', 'Garen', 'O Poder de Demacia'),
(40, '8', 'Gnar', 'O Elo Perdido'),
(41, '8', 'Gragas', 'O Badernista'),
(42, '8', 'Graves', 'O Foragido'),
(43, '8', 'Gwen', 'A Costureira Consagrada'),
(44, '8', 'Hecarim', 'A Sombra da Guerra'),
(45, '8', 'Heimerdinger', 'O Inventor Venerado'),
(46, '8', 'Hwei', 'O Visionário'),
(47, '8', 'Illaoi', 'A Sacerdotisa de Kraken'),
(48, '8', 'Irelia', 'A Dançarina das Lâminas'),
(49, '8', 'Ivern', 'O Pai Verde'),
(50, '8', 'Janna', 'A Fúria da Tempestade'),
(51, '8', 'Jarvan IV', 'O Exemplar de Demacia'),
(52, '8', 'Jax', 'Grão-Mestre das Armas'),
(53, '8', 'Jayce', 'O Defensor do Amanhã'),
(54, '8', 'Jhin', 'O Virtuoso'),
(55, '8', 'Jinx', 'O Gatilho Desajustado'),
(56, '8', 'K\'Sante', 'O Orgulho de Nazumah'),
(57, '8', 'Kai\'Sa', 'A Filha do Vazio'),
(58, '8', 'Kalista', 'A Lança da Vingança'),
(59, '8', 'Karma', 'A Iluminada'),
(60, '8', 'Karthus', 'O Cantor da Morte'),
(61, '8', 'Kassadin', 'O Andarilho do Vazio'),
(62, '8', 'Katarina', 'A Lâmina Sinistra'),
(63, '8', 'Kayle', 'A Justa'),
(64, '8', 'Kayn', 'O Ceifador das Sombras'),
(65, '8', 'Kennen', 'O Coração da Tempestade'),
(66, '8', 'Kha\'Zix', 'O Ceifador do Vazio'),
(67, '8', 'Kindred', 'Os Caçadores Eternos'),
(68, '8', 'Kled', 'O Cavaleiro Irascível'),
(69, '8', 'Kog\'Maw', 'A Boca do Abismo'),
(70, '8', 'LeBlanc', 'A Enganadora'),
(71, '8', 'Lee Sin', 'O Monge Cego'),
(72, '8', 'Leona', 'A Aurora Radiante'),
(73, '8', 'Lillia', 'A Flor Tímida'),
(74, '8', 'Lissandra', 'A Bruxa de Gelo'),
(75, '8', 'Lucian', 'O Purificador'),
(76, '8', 'Lulu', 'A Fada Feiticeira'),
(77, '8', 'Lux', 'A Senhora da Luminosidade'),
(78, '8', 'Malphite', 'Fragmento do Monólito'),
(79, '8', 'Malzahar', 'O Profeta do Vazio'),
(80, '8', 'Maokai', 'O Ente Retorcido'),
(81, '8', 'Master Yi', 'O Espadachim Wuju'),
(82, '8', 'Mel', 'A Diplomata Arcana'),
(83, '8', 'Milio', 'A Chama Gentil'),
(84, '8', 'Miss Fortune', 'A Caçadora de Recompensas'),
(85, '8', 'Mordekaiser', 'O Revenante de Ferro'),
(86, '8', 'Morgana', 'A Caída'),
(87, '8', 'Nami', 'A Conjuradora das Marés'),
(88, '8', 'Nasus', 'O Curador das Areias'),
(89, '8', 'Nautilus', 'O Titã das Profundezas'),
(90, '8', 'Naafiri', 'O Cão das Cem Mordidas'),
(91, '8', 'Neeko', 'O Camaleão Curioso'),
(92, '8', 'Nidalee', 'A Caçadora Bestial'),
(93, '8', 'Nilah', 'A Alegria Desencadeada'),
(94, '8', 'Nocturne', 'O Pesadelo Eterno'),
(95, '8', 'Nunu e Willump', 'O Menino e Seu Yeti'),
(96, '8', 'Olaf', 'O Berserker'),
(97, '8', 'Orianna', 'A Dama Mecânica'),
(98, '8', 'Ornn', 'O Fogo Sob a Montanha'),
(99, '8', 'Pantheon', 'A Lança Inquebrável'),
(100, '8', 'Poppy', 'Guardiã do Martelo'),
(101, '8', 'Pyke', 'O Estripador das Águas Sangrentas'),
(102, '8', 'Qiyana', 'Imperatriz dos Elementos'),
(103, '8', 'Quinn', 'As Asas de Demacia'),
(104, '8', 'Rakan', 'O Encantador'),
(105, '8', 'Rammus', 'O Tatu Blindado'),
(106, '8', 'Rek\'Sai', 'A Escavadora do Vazio'),
(107, '8', 'Rell', 'A Dama de Ferro'),
(108, '8', 'Renata Glasc', 'A Baronesa Química'),
(109, '8', 'Renekton', 'O Carniceiro das Areias'),
(110, '8', 'Rengar', 'O Acossador do Orgulho'),
(111, '8', 'Riven', 'A Exilada'),
(112, '8', 'Rumble', 'A Ameaça Mecanizada'),
(113, '8', 'Ryze', 'O Mago Rúnico'),
(114, '8', 'Samira', 'A Rosa do Deserto'),
(115, '8', 'Sejuani', 'A Fúria do Norte'),
(116, '8', 'Senna', 'A Redentora'),
(117, '8', 'Seraphine', 'A Cantora de Olhos Estrelados'),
(118, '8', 'Sett', 'O Chefe'),
(119, '8', 'Shaco', 'O Bobo Demoníaco'),
(120, '8', 'Shen', 'O Olho do Crepúsculo'),
(121, '8', 'Shyvana', 'A Meio-Dragão'),
(122, '8', 'Singed', 'O Químico Louco'),
(123, '8', 'Sion', 'O Colosso Morto-Vivo'),
(124, '8', 'Sivir', 'A Mestra de Batalha'),
(125, '8', 'Skarner', 'A Vanguarda de Cristal'),
(126, '8', 'Smolder', 'A Chama Jovem'),
(127, '8', 'Sona', 'A Virtuose das Cordas'),
(128, '8', 'Soraka', 'A Filha das Estrelas'),
(129, '8', 'Swain', 'O Grande General Noxiano'),
(130, '8', 'Sylas', 'O Liberto'),
(131, '8', 'Syndra', 'A Soberana Obscura'),
(132, '8', 'Tahm Kench', 'O Rei do Rio'),
(133, '8', 'Taliyah', 'A Tecelã de Pedra'),
(134, '8', 'Talon', 'A Sombra da Lâmina'),
(135, '8', 'Taric', 'O Escudo de Valoran'),
(136, '8', 'Teemo', 'O Explorador Veloz'),
(137, '8', 'Thresh', 'O Guardião das Correntes'),
(138, '8', 'Tristana', 'A Artilheira Yordle'),
(139, '8', 'Trundle', 'O Rei Troll'),
(140, '8', 'Tryndamere', 'O Rei Bárbaro'),
(141, '8', 'Twisted Fate', 'O Mestre das Cartas'),
(142, '8', 'Twitch', 'O Rato da Peste'),
(143, '8', 'Udyr', 'O Andarilho Espiritual'),
(144, '8', 'Urgot', 'O Encouraçado'),
(145, '8', 'Varus', 'A Flecha da Retribuição'),
(146, '8', 'Vayne', 'A Caçadora Noturna'),
(147, '8', 'Veigar', 'O Pequeno Mestre do Mal'),
(148, '8', 'Vel\'Koz', 'O Olho do Vazio'),
(149, '8', 'Vex', 'A Melancólica'),
(150, '8', 'Vi', 'A Defensora de Piltover'),
(151, '8', 'Viego', 'O Rei Arruinado'),
(152, '8', 'Viktor', 'O Arauto das Máquinas'),
(153, '8', 'Vladimir', 'O Ceifador Carmesim'),
(154, '8', 'Volibear', 'A Tempestade Implacável'),
(155, '8', 'Warwick', 'A Ira Desenfreada de Zaun'),
(156, '8', 'Wukong', 'O Rei Macaco'),
(157, '8', 'Xayah', 'A Rebelde'),
(158, '8', 'Xerath', 'O Mago Ascendente'),
(159, '8', 'Xin Zhao', 'O Senescal de Demacia'),
(160, '8', 'Yasuo', 'O Imperdoável'),
(161, '8', 'Yone', 'O Inesquecível'),
(162, '8', 'Yorick', 'Pastor de Almas'),
(163, '8', 'Yuumi', 'A Gata Mágica'),
(164, '8', 'Zac', 'A Arma Secreta'),
(165, '8', 'Zed', 'O Mestre das Sombras'),
(166, '8', 'Zeri', 'A Centelha de Zaun'),
(167, '8', 'Ziggs', 'O Especialista em Hexplosivos'),
(168, '8', 'Zilean', 'O Guardião do Tempo'),
(169, '8', 'Zoe', 'O Aspecto do Crepúsculo'),
(170, '8', 'Zyra', 'A Ascensão dos Espinhos');


-- Brezilya Portekizcesi pozisyon çevirileri
INSERT INTO position_translations (position_id, language_id, name) VALUES
(1, '9', 'Topo'),
(2, '9', 'Selva'),
(3, '9', 'Meio'),
(4, '9', 'Atirador'),
(5, '9', 'Suporte');

-- Brezilya Portekizcesi tür çevirileri
INSERT INTO species_translations (species_id, language_id, name) VALUES
(1, '9', 'Humano'),
(2, '9', 'Yordle'),
(3, '9', 'Vastaya'),
(4, '9', 'Darkin'),
(5, '9', 'Vazio'),
(6, '9', 'Fantasma'),
(7, '9', 'Golem'),
(8, '9', 'Aspecto'),
(9, '9', 'Deus'),
(10, '9', 'Semideus'),
(11, '9', 'Brackern'),
(12, '9', 'Demônio'),
(13, '9', 'Espírito'),
(14, '9', 'Serpente'),
(15, '9', 'Dragão'),
(16, '9', 'Morto-vivo'),
(17, '9', 'Ciborgue'),
(18, '9', 'Minotauro'),
(19, '9', 'Celestial'),
(20, '9', 'Troll'),
(21, '9', 'Animal'),
(22, '9', 'Planta'),
(23, '9', 'Criatura Mágica'),
(24, '9', 'Autômato'),
(25, '9', 'Ascendente'),
(26, '9', 'Fênix de Gelo'),
(27, '9', 'Anfíbio'),
(28, '9', 'Gárgula'),
(29, '9', 'Centauro Fantasma'),
(30, '9', 'Roedor'),
(31, '9', 'Semi-Árvore'),
(32, '9', 'Espírito do Vento'),
(33, '9', 'Pesadelo'),
(34, '9', 'Mutante'),
(35, '9', 'Entidade'),
(36, '9', 'Híbrido');

-- Brezilya Portekizcesi kaynak tipi çevirileri
INSERT INTO resource_translations (resource_id, language_id, name) VALUES
(1, '9', 'Mana'),
(2, '9', 'Energia'),
(3, '9', 'Fúria'),
(4, '9', 'Escudo'),
(5, '9', 'Sangue'),
(6, '9', 'Coragem'),
(7, '9', 'Calor'),
(8, '9', 'Munição'),
(9, '9', 'Sem mana'),
(10, '9', 'Vida'),
(11, '9', 'Fluxo');

-- Brezilya Portekizcesi dövüş menzili çevirileri
INSERT INTO combat_range_translations (combat_range_id, language_id, name) VALUES
(1, '9', 'Corpo a corpo'),
(2, '9', 'Longa distância'),
(3, '9', 'Híbrido');

-- Brezilya Portekizcesi bölge çevirileri
INSERT INTO region_translations (region_id, language_id, name, description) VALUES
(1, '9', 'Ionia', 'Uma terra de magia e equilíbrio'),
(2, '9', 'Noxus', 'Um império brutal e expansionista'),
(3, '9', 'Demacia', 'Um reino de lei e justiça'),
(4, '9', 'Piltover', 'A cidade do progresso'),
(5, '9', 'Zaun', 'A subcidade de produtos químicos e poluição'),
(6, '9', 'Freljord', 'Uma natureza selvagem dura e gelada'),
(7, '9', 'Shurima', 'Um império desértico caído'),
(8, '9', 'Águas-de-Sentina', 'Uma cidade portuária sem lei'),
(9, '9', 'Targon', 'Uma montanha sagrada que alcança as estrelas'),
(10, '9', 'Ilhas das Sombras', 'Ilhas corrompidas pela Névoa Negra'),
(11, '9', 'Cidade de Bandle', 'Lar dos Yordles'),
(12, '9', 'Ixtal', 'Um reino isolado da selva'),
(13, '9', 'Vazio', 'Um reino de pesadelo além da realidade'),
(14, '9', 'Runeterra', 'O próprio mundo'),
(15, '9', 'Icathia', 'Uma antiga civilização caída');

-- Şampiyonların Brezilya Portekizcesi çevirileri
INSERT INTO champion_translations (champion_id, language_id, name, title) VALUES
(1, '9', 'Aatrox', 'A Lâmina Darkin'),
(2, '9', 'Ahri', 'A Raposa de Nove Caudas'),
(3, '9', 'Akali', 'A Assassina Renegada'),
(4, '9', 'Akshan', 'O Sentinela Renegado'),
(5, '9', 'Alistar', 'O Minotauro'),
(6, '9', 'Ambessa', 'A General Noxiana'),
(7, '9', 'Amumu', 'A Múmia Triste'),
(8, '9', 'Anivia', 'A Criofênix'),
(9, '9', 'Annie', 'A Criança Sombria'),
(10, '9', 'Aphelios', 'A Arma dos Devotos'),
(11, '9', 'Ashe', 'A Arqueira do Gelo'),
(12, '9', 'Aurelion Sol', 'O Forjador de Estrelas'),
(13, '9', 'Aurora', 'A Fúria do Inverno'),
(14, '9', 'Azir', 'O Imperador das Areias'),
(15, '9', 'Bardo', 'O Protetor Errante'),
(16, '9', 'Bel\'Veth', 'A Imperatriz do Vazio'),
(17, '9', 'Blitzcrank', 'O Grande Golem a Vapor'),
(18, '9', 'Brand', 'A Vingança Flamejante'),
(19, '9', 'Braum', 'O Coração do Freljord'),
(20, '9', 'Briar', 'A Maldição da Fome'),
(21, '9', 'Caitlyn', 'A Xerife de Piltover'),
(22, '9', 'Camille', 'A Sombra de Aço'),
(23, '9', 'Cassiopeia', 'O Abraço da Serpente'),
(24, '9', 'Cho\'Gath', 'O Terror do Vazio'),
(25, '9', 'Corki', 'O Bombardeiro Ousado'),
(26, '9', 'Darius', 'A Mão de Noxus'),
(27, '9', 'Diana', 'O Escárnio da Lua'),
(28, '9', 'Dr. Mundo', 'O Louco de Zaun'),
(29, '9', 'Draven', 'O Carrasco Glorioso'),
(30, '9', 'Ekko', 'O Rapaz que Estilhaçou o Tempo'),
(31, '9', 'Elise', 'A Rainha Aranha'),
(32, '9', 'Evelynn', 'O Abraço da Agonia'),
(33, '9', 'Ezreal', 'O Explorador Pródigo'),
(34, '9', 'Fiddlesticks', 'O Medo Ancestral'),
(35, '9', 'Fiora', 'A Grande Duelista'),
(36, '9', 'Fizz', 'O Trapaceiro das Marés'),
(37, '9', 'Galio', 'O Colosso'),
(38, '9', 'Gangplank', 'O Flagelo dos Mares'),
(39, '9', 'Garen', 'O Poder de Demacia'),
(40, '9', 'Gnar', 'O Elo Perdido'),
(41, '9', 'Gragas', 'O Badernista'),
(42, '9', 'Graves', 'O Foragido'),
(43, '9', 'Gwen', 'A Costureira Sagrada'),
(44, '9', 'Hecarim', 'A Sombra da Guerra'),
(45, '9', 'Heimerdinger', 'O Inventor Idolatrado'),
(46, '9', 'Hwei', 'O Visionário'),
(47, '9', 'Illaoi', 'A Sacerdotisa do Kraken'),
(48, '9', 'Irelia', 'A Dançarina das Lâminas'),
(49, '9', 'Ivern', 'O Pai Verde'),
(50, '9', 'Janna', 'A Fúria da Tempestade'),
(51, '9', 'Jarvan IV', 'O Exemplo de Demacia'),
(52, '9', 'Jax', 'O Grão-mestre das Armas'),
(53, '9', 'Jayce', 'O Defensor do Amanhã'),
(54, '9', 'Jhin', 'O Virtuoso'),
(55, '9', 'Jinx', 'O Gatilho Desajustado'),
(56, '9', 'K\'Sante', 'O Orgulho de Nazumah'),
(57, '9', 'Kai\'Sa', 'A Filha do Vazio'),
(58, '9', 'Kalista', 'A Lança da Vingança'),
(59, '9', 'Karma', 'A Iluminada'),
(60, '9', 'Karthus', 'O Cantor da Morte'),
(61, '9', 'Kassadin', 'O Andarilho do Vazio'),
(62, '9', 'Katarina', 'A Lâmina Sinistra'),
(63, '9', 'Kayle', 'A Justa'),
(64, '9', 'Kayn', 'O Ceifador das Sombras'),
(65, '9', 'Kennen', 'O Coração da Tempestade'),
(66, '9', 'Kha\'Zix', 'O Ceifador do Vazio'),
(67, '9', 'Kindred', 'Os Caçadores Eternos'),
(68, '9', 'Kled', 'O Cavaleiro Raivoso'),
(69, '9', 'Kog\'Maw', 'A Boca do Abismo'),
(70, '9', 'LeBlanc', 'A Ilusionista'),
(71, '9', 'Lee Sin', 'O Monge Cego'),
(72, '9', 'Leona', 'A Aurora Radiante'),
(73, '9', 'Lillia', 'O Botão Tímido'),
(74, '9', 'Lissandra', 'A Bruxa do Gelo'),
(75, '9', 'Lucian', 'O Purificador'),
(76, '9', 'Lulu', 'A Fada Feiticeira'),
(77, '9', 'Lux', 'A Dama da Luz'),
(78, '9', 'Malphite', 'O Fragmento do Monolito'),
(79, '9', 'Malzahar', 'O Profeta do Vazio'),
(80, '9', 'Maokai', 'O Ente Retorcido'),
(81, '9', 'Master Yi', 'O Espadachim Wuju'),
(82, '9', 'Mel', 'A Diplomata Arcana'),
(83, '9', 'Milio', 'A Chama Gentil'),
(84, '9', 'Miss Fortune', 'A Caçadora de Recompensas'),
(85, '9', 'Mordekaiser', 'O Revenante de Ferro'),
(86, '9', 'Morgana', 'A Caída'),
(87, '9', 'Nami', 'A Conjuradora das Marés'),
(88, '9', 'Nasus', 'O Curador das Areias'),
(89, '9', 'Nautilus', 'O Titã das Profundezas'),
(90, '9', 'Naafiri', 'O Cão das Cem Mordidas'),
(91, '9', 'Neeko', 'O Camaleão Curioso'),
(92, '9', 'Nidalee', 'A Caçadora Bestial'),
(93, '9', 'Nilah', 'A Alegria Desencadeada'),
(94, '9', 'Nocturne', 'O Eterno Pesadelo'),
(95, '9', 'Nunu e Willump', 'O Garoto e Seu Yeti'),
(96, '9', 'Olaf', 'O Berserker'),
(97, '9', 'Orianna', 'A Donzela Mecânica'),
(98, '9', 'Ornn', 'O Fogo Sob a Montanha'),
(99, '9', 'Pantheon', 'A Lança Inquebrável'),
(100, '9', 'Poppy', 'A Guardiã do Martelo'),
(101, '9', 'Pyke', 'O Estripador das Águas Sangrentas'),
(102, '9', 'Qiyana', 'A Imperatriz dos Elementos'),
(103, '9', 'Quinn', 'As Asas de Demacia'),
(104, '9', 'Rakan', 'O Encantador'),
(105, '9', 'Rammus', 'O Tatu Blindado'),
(106, '9', 'Rek\'Sai', 'A Escavadora do Vazio'),
(107, '9', 'Rell', 'A Donzela de Ferro'),
(108, '9', 'Renata Glasc', 'A Baronesa Química'),
(109, '9', 'Renekton', 'O Carniceiro das Areias'),
(110, '9', 'Rengar', 'O Acossador do Orgulho'),
(111, '9', 'Riven', 'A Exilada'),
(112, '9', 'Rumble', 'A Ameaça Mecanizada'),
(113, '9', 'Ryze', 'O Mago Rúnico'),
(114, '9', 'Samira', 'A Rosa do Deserto'),
(115, '9', 'Sejuani', 'A Fúria do Norte'),
(116, '9', 'Senna', 'A Redentora'),
(117, '9', 'Seraphine', 'A Cantora de Olhos Estrelados'),
(118, '9', 'Sett', 'O Chefe'),
(119, '9', 'Shaco', 'O Bufão Demoníaco'),
(120, '9', 'Shen', 'O Olho do Crepúsculo'),
(121, '9', 'Shyvana', 'A Meio-Dragão'),
(122, '9', 'Singed', 'O Químico Louco'),
(123, '9', 'Sion', 'O Colosso Morto-Vivo'),
(124, '9', 'Sivir', 'A Mestra de Batalha'),
(125, '9', 'Skarner', 'A Vanguarda de Cristal'),
(126, '9', 'Smolder', 'A Chama Jovem'),
(127, '9', 'Sona', 'A Virtuose das Cordas'),
(128, '9', 'Soraka', 'A Filha das Estrelas'),
(129, '9', 'Swain', 'O Grande General Noxiano'),
(130, '9', 'Sylas', 'O Desencarcerado'),
(131, '9', 'Syndra', 'A Soberana Obscura'),
(132, '9', 'Tahm Kench', 'O Rei do Rio'),
(133, '9', 'Taliyah', 'A Tecelã de Pedra'),
(134, '9', 'Talon', 'A Sombra da Lâmina'),
(135, '9', 'Taric', 'O Escudo de Valoran'),
(136, '9', 'Teemo', 'O Explorador Veloz'),
(137, '9', 'Thresh', 'O Guardião das Correntes'),
(138, '9', 'Tristana', 'A Artilheira Yordle'),
(139, '9', 'Trundle', 'O Rei Troll'),
(140, '9', 'Tryndamere', 'O Rei Bárbaro'),
(141, '9', 'Twisted Fate', 'O Mestre das Cartas'),
(142, '9', 'Twitch', 'O Rato da Peste'),
(143, '9', 'Udyr', 'O Andarilho Espiritual'),
(144, '9', 'Urgot', 'O Encouraçado'),
(145, '9', 'Varus', 'A Flecha da Retribuição'),
(146, '9', 'Vayne', 'A Caçadora Noturna'),
(147, '9', 'Veigar', 'O Pequeno Mestre do Mal'),
(148, '9', 'Vel\'Koz', 'O Olho do Vazio'),
(149, '9', 'Vex', 'A Melancólica'),
(150, '9', 'Vi', 'A Defensora de Piltover'),
(151, '9', 'Viego', 'O Rei Destruído'),
(152, '9', 'Viktor', 'O Arauto das Máquinas'),
(153, '9', 'Vladimir', 'O Ceifador Escarlate'),
(154, '9', 'Volibear', 'A Tempestade Implacável'),
(155, '9', 'Warwick', 'A Ira Desenfreada de Zaun'),
(156, '9', 'Wukong', 'O Rei Macaco'),
(157, '9', 'Xayah', 'A Rebelde'),
(158, '9', 'Xerath', 'O Mago Ascendente'),
(159, '9', 'Xin Zhao', 'O Senescal de Demacia'),
(160, '9', 'Yasuo', 'O Imperdoável'),
(161, '9', 'Yone', 'O Inesquecível'),
(162, '9', 'Yorick', 'O Pastor de Almas'),
(163, '9', 'Yuumi', 'A Gata Mágica'),
(164, '9', 'Zac', 'A Arma Secreta'),
(165, '9', 'Zed', 'O Mestre das Sombras'),
(166, '9', 'Zeri', 'A Faísca de Zaun'),
(167, '9', 'Ziggs', 'O Especialista em Hexplosivos'),
(168, '9', 'Zilean', 'O Guardião do Tempo'),
(169, '9', 'Zoe', 'O Aspecto do Crepúsculo'),
(170, '9', 'Zyra', 'A Ascensão dos Espinhos');

-- Felemenkçe pozisyon çevirileri
INSERT INTO position_translations (position_id, language_id, name) VALUES
(1, '10', 'Boven'),
(2, '10', 'Jungle'),
(3, '10', 'Midden'),
(4, '10', 'Beneden'),
(5, '10', 'Ondersteuning');

-- Felemenkçe tür çevirileri
INSERT INTO species_translations (species_id, language_id, name) VALUES
(1, '10', 'Mens'),
(2, '10', 'Yordle'),
(3, '10', 'Vastaya'),
(4, '10', 'Darkin'),
(5, '10', 'Leegte'),
(6, '10', 'Geest'),
(7, '10', 'Golem'),
(8, '10', 'Aspect'),
(9, '10', 'God'),
(10, '10', 'Halfgod'),
(11, '10', 'Brackern'),
(12, '10', 'Demon'),
(13, '10', 'Geest'),
(14, '10', 'Slang'),
(15, '10', 'Draak'),
(16, '10', 'Ondode'),
(17, '10', 'Cyborg'),
(18, '10', 'Minotaurus'),
(19, '10', 'Hemels'),
(20, '10', 'Trol'),
(21, '10', 'Dier'),
(22, '10', 'Plant'),
(23, '10', 'Magisch Wezen'),
(24, '10', 'Automaat'),
(25, '10', 'Verhevene'),
(26, '10', 'IJsfeniks'),
(27, '10', 'Amfibie'),
(28, '10', 'Waterspuwer'),
(29, '10', 'Spookcentaur'),
(30, '10', 'Knaagdier'),
(31, '10', 'Halfboom'),
(32, '10', 'Windgeest'),
(33, '10', 'Nachtmerrie'),
(34, '10', 'Mutant'),
(35, '10', 'Entiteit'),
(36, '10', 'Hybride');

-- Felemenkçe kaynak tipi çevirileri
INSERT INTO resource_translations (resource_id, language_id, name) VALUES
(1, '10', 'Mana'),
(2, '10', 'Energie'),
(3, '10', 'Woede'),
(4, '10', 'Schild'),
(5, '10', 'Bloed'),
(6, '10', 'Moed'),
(7, '10', 'Hitte'),
(8, '10', 'Munitie'),
(9, '10', 'Manaloos'),
(10, '10', 'Gezondheid'),
(11, '10', 'Stroom');

-- Felemenkçe dövüş menzili çevirileri
INSERT INTO combat_range_translations (combat_range_id, language_id, name) VALUES
(1, '10', 'Melee'),
(2, '10', 'Afstandsaanval'),
(3, '10', 'Hybride');

-- Felemenkçe bölge çevirileri
INSERT INTO region_translations (region_id, language_id, name, description) VALUES
(1, '10', 'Ionia', 'Een land van magie en evenwicht'),
(2, '10', 'Noxus', 'Een bruut, expansionistisch rijk'),
(3, '10', 'Demacia', 'Een koninkrijk van wet en rechtvaardigheid'),
(4, '10', 'Piltover', 'De stad van vooruitgang'),
(5, '10', 'Zaun', 'De onderstad van chemicaliën en vervuiling'),
(6, '10', 'Freljord', 'Een ruwe, ijzige wildernis'),
(7, '10', 'Shurima', 'Een gevallen woestijnrijk'),
(8, '10', 'Bilgewater', 'Een wetteloze havenstad'),
(9, '10', 'Targon', 'Een heilige berg die reikt naar de sterren'),
(10, '10', 'Schaduweilanden', 'Eilanden gecorrumpeerd door de Zwarte Mist'),
(11, '10', 'Bandle Stad', 'Thuis van de Yordles'),
(12, '10', 'Ixtal', 'Een geïsoleerd junglerijk'),
(13, '10', 'Leegte', 'Een nachtmerrierijk voorbij de realiteit'),
(14, '10', 'Runeterra', 'De wereld zelf'),
(15, '10', 'Icathia', 'Een oude, gevallen beschaving');

-- Şampiyonların Felemenkçe çevirileri
INSERT INTO champion_translations (champion_id, language_id, name, title) VALUES
(1, '10', 'Aatrox', 'Het Darkin Zwaard'),
(2, '10', 'Ahri', 'De Negenstaartige Vos'),
(3, '10', 'Akali', 'De Afvallige Sluipmoordenaar'),
(4, '10', 'Akshan', 'De Afvallige Wachter'),
(5, '10', 'Alistar', 'De Minotaurus'),
(6, '10', 'Ambessa', 'De Noxiaanse Generaal'),
(7, '10', 'Amumu', 'De Treurige Mummie'),
(8, '10', 'Anivia', 'De Cryofeniks'),
(9, '10', 'Annie', 'Het Duistere Kind'),
(10, '10', 'Aphelios', 'Het Wapen van de Gelovigen'),
(11, '10', 'Ashe', 'De Vorstsschutter'),
(12, '10', 'Aurelion Sol', 'De Sterrensmid'),
(13, '10', 'Aurora', 'De Toorn van de Winter'),
(14, '10', 'Azir', 'De Keizer van het Zand'),
(15, '10', 'Bard', 'De Zwervende Verzorger'),
(16, '10', 'Bel\'Veth', 'De Keizerin van de Leegte'),
(17, '10', 'Blitzcrank', 'De Grote Stoomgolem'),
(18, '10', 'Brand', 'De Brandende Wraak'),
(19, '10', 'Braum', 'Het Hart van de Freljord'),
(20, '10', 'Briar', 'De Vloek van de Honger'),
(21, '10', 'Caitlyn', 'De Sheriff van Piltover'),
(22, '10', 'Camille', 'De Stalen Schaduw'),
(23, '10', 'Cassiopeia', 'De Omhelzing van de Slang'),
(24, '10', 'Cho\'Gath', 'De Terreur van de Leegte'),
(25, '10', 'Corki', 'De Dappere Bombardeur'),
(26, '10', 'Darius', 'De Hand van Noxus'),
(27, '10', 'Diana', 'De Hoon van de Maan'),
(28, '10', 'Dr. Mundo', 'De Gek van Zaun'),
(29, '10', 'Draven', 'De Glorieuze Beul'),
(30, '10', 'Ekko', 'De Jongen Die de Tijd Verbrijzelde'),
(31, '10', 'Elise', 'De Spinnenkonigin'),
(32, '10', 'Evelynn', 'De Omhelzing van Pijn'),
(33, '10', 'Ezreal', 'De Verkwistende Ontdekkingsreiziger'),
(34, '10', 'Fiddlesticks', 'De Oeroude Angst'),
(35, '10', 'Fiora', 'De Grote Duelliste'),
(36, '10', 'Fizz', 'De Getijdenbedrieger'),
(37, '10', 'Galio', 'De Kolos'),
(38, '10', 'Gangplank', 'De Plaag van Zout Water'),
(39, '10', 'Garen', 'De Macht van Demacia'),
(40, '10', 'Gnar', 'De Ontbrekende Schakel'),
(41, '10', 'Gragas', 'De Herrieschopper'),
(42, '10', 'Graves', 'De Outlaw'),
(43, '10', 'Gwen', 'De Geheiligde Naaister'),
(44, '10', 'Hecarim', 'De Schaduw van Oorlog'),
(45, '10', 'Heimerdinger', 'De Gerespecteerde Uitvinder'),
(46, '10', 'Hwei', 'De Visionair'),
(47, '10', 'Illaoi', 'De Priesteres van de Kraken'),
(48, '10', 'Irelia', 'De Messensdanseres'),
(49, '10', 'Ivern', 'De Groene Vader'),
(50, '10', 'Janna', 'De Woede van de Storm'),
(51, '10', 'Jarvan IV', 'Het Toonbeeld van Demacia'),
(52, '10', 'Jax', 'Grootmeester van Wapens'),
(53, '10', 'Jayce', 'De Verdediger van Morgen'),
(54, '10', 'Jhin', 'De Virtuoos'),
(55, '10', 'Jinx', 'Het Losse Kanon'),
(56, '10', 'K\'Sante', 'De Trots van Nazumah'),
(57, '10', 'Kai\'Sa', 'Dochter van de Leegte'),
(58, '10', 'Kalista', 'De Speer van Wraak'),
(59, '10', 'Karma', 'De Verlichte'),
(60, '10', 'Karthus', 'De Doodszanger'),
(61, '10', 'Kassadin', 'De Leegtewandelaar'),
(62, '10', 'Katarina', 'Het Sinistere Mes'),
(63, '10', 'Kayle', 'De Rechtvaardige'),
(64, '10', 'Kayn', 'De Maaier van Schaduwen'),
(65, '10', 'Kennen', 'Het Hart van de Storm'),
(66, '10', 'Kha\'Zix', 'De Leegtejager'),
(67, '10', 'Kindred', 'De Eeuwige Jagers'),
(68, '10', 'Kled', 'De Opvliegende Cavalier'),
(69, '10', 'Kog\'Maw', 'De Muil van de Afgrond'),
(70, '10', 'LeBlanc', 'De Bedriegster'),
(71, '10', 'Lee Sin', 'De Blinde Monnik'),
(72, '10', 'Leona', 'De Stralende Dageraad'),
(73, '10', 'Lillia', 'De Verlegen Bloesem'),
(74, '10', 'Lissandra', 'De IJsheks'),
(75, '10', 'Lucian', 'De Zuiveraar'),
(76, '10', 'Lulu', 'De Feetovenares'),
(77, '10', 'Lux', 'De Dame van Licht'),
(78, '10', 'Malphite', 'De Scherf van de Monoliet'),
(79, '10', 'Malzahar', 'De Profeet van de Leegte'),
(80, '10', 'Maokai', 'De Verwrongen Treant'),
(81, '10', 'Master Yi', 'De Wuju Bladesman'),
(82, '10', 'Mel', 'De Arcane Diplomaat'),
(83, '10', 'Milio', 'De Zachte Vlam'),
(84, '10', 'Miss Fortune', 'De Premiejager'),
(85, '10', 'Mordekaiser', 'De IJzeren Revenant'),
(86, '10', 'Morgana', 'De Gevallene'),
(87, '10', 'Nami', 'De Getijdenroeper'),
(88, '10', 'Nasus', 'De Bewaarder van het Zand'),
(89, '10', 'Nautilus', 'De Titan van de Diepten'),
(90, '10', 'Naafiri', 'De Hond van Honderd Beten'),
(91, '10', 'Neeko', 'De Nieuwsgierige Kameleon'),
(92, '10', 'Nidalee', 'De Beestachtige Jageres'),
(93, '10', 'Nilah', 'De Ongebonden Vreugde'),
(94, '10', 'Nocturne', 'De Eeuwige Nachtmerrie'),
(95, '10', 'Nunu en Willump', 'De Jongen en Zijn Yeti'),
(96, '10', 'Olaf', 'De Berserker'),
(97, '10', 'Orianna', 'De Dame van het Uurwerk'),
(98, '10', 'Ornn', 'Het Vuur Onder de Berg'),
(99, '10', 'Pantheon', 'De Onbreekbare Speer'),
(100, '10', 'Poppy', 'Bewaarder van de Hamer'),
(101, '10', 'Pyke', 'De Bloedhavenripper'),
(102, '10', 'Qiyana', 'Keizerin van de Elementen'),
(103, '10', 'Quinn', 'De Vleugels van Demacia'),
(104, '10', 'Rakan', 'De Charmeur'),
(105, '10', 'Rammus', 'De Gordeldier'),
(106, '10', 'Rek\'Sai', 'De Leegtegraver'),
(107, '10', 'Rell', 'De IJzeren Maagd'),
(108, '10', 'Renata Glasc', 'De Chem-Barones'),
(109, '10', 'Renekton', 'De Slager van het Zand'),
(110, '10', 'Rengar', 'De Trotsjager'),
(111, '10', 'Riven', 'De Bannelinge'),
(112, '10', 'Rumble', 'De Gemechaniseerde Bedreiging'),
(113, '10', 'Ryze', 'De Runemagiër'),
(114, '10', 'Samira', 'De Woestijnroos'),
(115, '10', 'Sejuani', 'De Woede van het Noorden'),
(116, '10', 'Senna', 'De Verlosser'),
(117, '10', 'Seraphine', 'De Steroogzangeres'),
(118, '10', 'Sett', 'De Baas'),
(119, '10', 'Shaco', 'De Demonische Nar'),
(120, '10', 'Shen', 'Het Oog van de Schemering'),
(121, '10', 'Shyvana', 'De Halfdraak'),
(122, '10', 'Singed', 'De Gekke Chemicus'),
(123, '10', 'Sion', 'De Ondode Kolos'),
(124, '10', 'Sivir', 'De Strijdmeesteres'),
(125, '10', 'Skarner', 'De Kristallen Voorhoede'),
(126, '10', 'Smolder', 'De Jonge Vlam'),
(127, '10', 'Sona', 'De Virtuoos van de Snaren'),
(128, '10', 'Soraka', 'Het Sterrenkind'),
(129, '10', 'Swain', 'De Grote Generaal van Noxus'),
(130, '10', 'Sylas', 'De Ontketende'),
(131, '10', 'Syndra', 'De Duistere Soeverein'),
(132, '10', 'Tahm Kench', 'De Rivierkoning'),
(133, '10', 'Taliyah', 'De Steenwever'),
(134, '10', 'Talon', 'De Schaduw van het Lemmet'),
(135, '10', 'Taric', 'Het Schild van Valoran'),
(136, '10', 'Teemo', 'De Snelle Verkenner'),
(137, '10', 'Thresh', 'De Kettingbewaarder'),
(138, '10', 'Tristana', 'De Yordle Kannonier'),
(139, '10', 'Trundle', 'De Trollenkoning'),
(140, '10', 'Tryndamere', 'De Barbarenkoning'),
(141, '10', 'Twisted Fate', 'De Kaartenmeester'),
(142, '10', 'Twitch', 'De Pestrat'),
(143, '10', 'Udyr', 'De Geestwandelaar'),
(144, '10', 'Urgot', 'Het Slagschip'),
(145, '10', 'Varus', 'De Pijl van Vergelding'),
(146, '10', 'Vayne', 'De Nachtjager'),
(147, '10', 'Veigar', 'De Kleine Meester van het Kwaad'),
(148, '10', 'Vel\'Koz', 'Het Oog van de Leegte'),
(149, '10', 'Vex', 'De Sombere'),
(150, '10', 'Vi', 'De Handhaver van Piltover'),
(151, '10', 'Viego', 'De Geruïneerde Koning'),
(152, '10', 'Viktor', 'De Herauten van Machines'),
(153, '10', 'Vladimir', 'De Scharlaken Maaier'),
(154, '10', 'Volibear', 'De Meedogenloze Storm'),
(155, '10', 'Warwick', 'De Ontketende Woede van Zaun'),
(156, '10', 'Wukong', 'De Apenkoning'),
(157, '10', 'Xayah', 'De Rebelse'),
(158, '10', 'Xerath', 'De Verheven Magiër'),
(159, '10', 'Xin Zhao', 'De Seneschalk van Demacia'),
(160, '10', 'Yasuo', 'De Onvergeeflijke'),
(161, '10', 'Yone', 'De Onvergeten'),
(162, '10', 'Yorick', 'Herder van Zielen'),
(163, '10', 'Yuumi', 'De Magische Kat'),
(164, '10', 'Zac', 'Het Geheime Wapen'),
(165, '10', 'Zed', 'De Meester van Schaduwen'),
(166, '10', 'Zeri', 'De Vonk van Zaun'),
(167, '10', 'Ziggs', 'De Hexplosieven Expert'),
(168, '10', 'Zilean', 'De Tijdbewaarder'),
(169, '10', 'Zoe', 'Het Aspect van de Schemering'),
(170, '10', 'Zyra', 'Opkomst van de Doornen');

-- Önce genders tablosunu oluştur (eğer yoksa)
CREATE TABLE IF NOT EXISTS genders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

-- Cinsiyet Çevirileri tablosunu oluştur (eğer yoksa)
CREATE TABLE IF NOT EXISTS gender_translations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    gender_id INT,
    language_id INT,
    name VARCHAR(50) NOT NULL,
    FOREIGN KEY (gender_id) REFERENCES genders(id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES languages(id) ON DELETE CASCADE,
    UNIQUE KEY (gender_id, language_id)
) ENGINE=InnoDB;

-- Şampiyon-Cinsiyet ilişkisi tablosunu oluştur (eğer yoksa)
CREATE TABLE IF NOT EXISTS champion_genders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    champion_id INT,
    gender_id INT,
    FOREIGN KEY (champion_id) REFERENCES champions(id) ON DELETE CASCADE,
    FOREIGN KEY (gender_id) REFERENCES genders(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Tüm önceki verileri temizleme (isteğe bağlı)
DELETE FROM champion_genders;
DELETE FROM gender_translations;
DELETE FROM genders;

-- Genders tablosuna cinsiyetleri ekle
INSERT INTO genders (name) VALUES ('Male'), ('Female'), ('Other');

-- İngilizce dil ID'sini al
SET @english_id = (SELECT id FROM languages WHERE code = 'en' LIMIT 1);

-- Temel cinsiyet çevirilerini ekle (İngilizce - aynı kalacak)
INSERT INTO gender_translations (gender_id, language_id, name)
VALUES
((SELECT id FROM genders WHERE name = 'Male'), @english_id, 'Male'),
((SELECT id FROM genders WHERE name = 'Female'), @english_id, 'Female'),
((SELECT id FROM genders WHERE name = 'Other'), @english_id, 'Other');

-- Şampiyonları cinsiyet ID'leriyle eşleştir
-- Male (Erkek) şampiyonlar
INSERT INTO champion_genders (champion_id, gender_id)
SELECT champions.id, (SELECT id FROM genders WHERE name = 'Male')
FROM champions
WHERE name IN (
    'Aatrox', 'Akshan', 'Alistar', 'Amumu', 'Aphelios', 'Aurelion Sol', 'Azir', 'Bard',
    'Brand', 'Braum', 'Corki', 'Darius', 'Dr. Mundo', 'Draven', 'Ekko', 'Ezreal',
    'Fizz', 'Galio', 'Gangplank', 'Garen', 'Gnar', 'Gragas', 'Graves', 'Hecarim',
    'Heimerdinger', 'Hwei', 'Ivern', 'Jarvan IV', 'Jax', 'Jayce', 'Jhin', 'K\'Sante',
    'Karthus', 'Kassadin', 'Kayn', 'Kennen', 'Kled', 'Lee Sin', 'Lucian', 'Malzahar',
    'Maokai', 'Master Yi', 'Milio', 'Mordekaiser', 'Nasus', 'Nautilus', 'Nocturne',
    'Nunu & Willump', 'Olaf', 'Ornn', 'Pantheon', 'Pyke', 'Rakan', 'Rammus', 'Renekton',
    'Rengar', 'Rumble', 'Ryze', 'Sett', 'Shaco', 'Shen', 'Singed', 'Sion', 'Smolder',
    'Swain', 'Sylas', 'Tahm Kench', 'Talon', 'Taric', 'Teemo', 'Thresh', 'Trundle',
    'Tryndamere', 'Twisted Fate', 'Twitch', 'Udyr', 'Urgot', 'Varus', 'Veigar', 'Viego',
    'Viktor', 'Vladimir', 'Volibear', 'Warwick', 'Wukong', 'Xerath', 'Xin Zhao', 'Yasuo',
    'Yone', 'Yorick', 'Zac', 'Zed', 'Ziggs', 'Zilean'
);

-- Female (Kadın) şampiyonlar
INSERT INTO champion_genders (champion_id, gender_id)
SELECT champions.id, (SELECT id FROM genders WHERE name = 'Female')
FROM champions
WHERE name IN (
    'Ahri', 'Akali', 'Ambessa', 'Anivia', 'Annie', 'Ashe', 'Aurora', 'Bel\'Veth',
    'Briar', 'Caitlyn', 'Camille', 'Cassiopeia', 'Diana', 'Elise', 'Evelynn', 'Fiora',
    'Gwen', 'Illaoi', 'Irelia', 'Janna', 'Jinx', 'Kai\'Sa', 'Kalista', 'Karma',
    'Katarina', 'Kayle', 'Lissandra', 'LeBlanc', 'Leona', 'Lillia', 'Lulu', 'Lux',
    'Mel', 'Miss Fortune', 'Morgana', 'Naafiri', 'Nami', 'Neeko', 'Nidalee', 'Nilah',
    'Orianna', 'Poppy', 'Qiyana', 'Quinn', 'Rek\'Sai', 'Rell', 'Renata Glasc', 'Riven',
    'Samira', 'Sejuani', 'Senna', 'Seraphine', 'Shyvana', 'Sivir', 'Sona', 'Soraka',
    'Syndra', 'Taliyah', 'Tristana', 'Vayne', 'Vex', 'Vi', 'Xayah', 'Yuumi', 'Zeri',
    'Zoe', 'Zyra'
);

-- Other (Diğer/Cinsiyetsiz) şampiyonlar
INSERT INTO champion_genders (champion_id, gender_id)
SELECT champions.id, (SELECT id FROM genders WHERE name = 'Other')
FROM champions
WHERE name IN (
    'Blitzcrank', 'Cho\'Gath', 'Fiddlesticks', 'Kha\'Zix', 'Kindred', 'Kog\'Maw',
    'Malphite', 'Skarner', 'Vel\'Koz'
);

SET @male_id = (SELECT id FROM genders WHERE name = 'Male');
SET @female_id = (SELECT id FROM genders WHERE name = 'Female');
SET @other_id = (SELECT id FROM genders WHERE name = 'Other');

-- Türkçe çeviriler
INSERT INTO gender_translations (gender_id, language_id, name) VALUES
(@male_id, @turkish_id, 'Erkek'),
(@female_id, @turkish_id, 'Kadın'),
(@other_id, @turkish_id, 'Diğer');

-- Almanca çeviriler
INSERT INTO gender_translations (gender_id, language_id, name) VALUES
(@male_id, @german_id, 'Männlich'),
(@female_id, @german_id, 'Weiblich'),
(@other_id, @german_id, 'Andere');

-- Fransızca çeviriler
INSERT INTO gender_translations (gender_id, language_id, name) VALUES
(@male_id, @french_id, 'Masculin'),
(@female_id, @french_id, 'Féminin'),
(@other_id, @french_id, 'Autre');

-- İspanyolca çeviriler
INSERT INTO gender_translations (gender_id, language_id, name) VALUES
(@male_id, @spanish_id, 'Masculino'),
(@female_id, @spanish_id, 'Femenino'),
(@other_id, @spanish_id, 'Otro');

-- İtalyanca çeviriler
INSERT INTO gender_translations (gender_id, language_id, name) VALUES
(@male_id, @italian_id, 'Maschile'),
(@female_id, @italian_id, 'Femminile'),
(@other_id, @italian_id, 'Altro');

-- Rusça çeviriler
INSERT INTO gender_translations (gender_id, language_id, name) VALUES
(@male_id, @russian_id, 'Мужской'),
(@female_id, @russian_id, 'Женский'),
(@other_id, @russian_id, 'Другой');

-- Portekizce çeviriler
INSERT INTO gender_translations (gender_id, language_id, name) VALUES
(@male_id, @portuguese_id, 'Masculino'),
(@female_id, @portuguese_id, 'Feminino'),
(@other_id, @portuguese_id, 'Outro');

-- Brezilya Portekizcesi çeviriler
INSERT INTO gender_translations (gender_id, language_id, name) VALUES
(@male_id, @brazilian_id, 'Masculino'),
(@female_id, @brazilian_id, 'Feminino'),
(@other_id, @brazilian_id, 'Outro');

-- Hollandaca çeviriler
INSERT INTO gender_translations (gender_id, language_id, name) VALUES
(@male_id, @dutch_id, 'Mannelijk'),
(@female_id, @dutch_id, 'Vrouwelijk'),
(@other_id, @dutch_id, 'Anders');


-- Geleneksel Çince pozisyon çevirileri (zh-tw)
INSERT INTO position_translations (position_id, language_id, name) VALUES
(1, '11', '上路'),  -- Değişiklik yok
(2, '11', '打野'),  -- Değişiklik yok
(3, '11', '中路'),  -- Değişiklik yok
(4, '11', '下路'),  -- Değişiklik yok
(5, '11', '輔助');  -- 辅助 -> 輔助 (Geleneksel)

-- Geleneksel Çince tür çevirileri (zh-tw)
INSERT INTO species_translations (species_id, language_id, name) VALUES
(1, '11', '人類'),   -- 人类 -> 人類
(2, '11', '約德爾人'), -- 约德尔人 -> 約德爾人
(3, '11', '瓦斯塔亞'), -- 瓦斯塔亚 -> 瓦斯塔亞
(4, '11', '暗裔'),   -- Değişiklik yok
(5, '11', '虛空'),   -- 虚空 -> 虛空
(6, '11', '幽靈'),   -- 幽灵 -> 幽靈
(7, '11', '傀儡'),   -- Değişiklik yok
(8, '11', '幻影'),   -- Değişiklik yok
(9, '11', '神靈'),   -- 神灵 -> 神靈
(10, '11', '半神'),  -- Değişiklik yok
(11, '11', '布拉肯'), -- Değişiklik yok
(12, '11', '惡魔'),  -- 恶魔 -> 惡魔
(13, '11', '靈魂'),  -- 灵魂 -> 靈魂
(14, '11', '蛇'),    -- Değişiklik yok
(15, '11', '龍'),    -- 龙 -> 龍
(16, '11', '不朽'),  -- Değişiklik yok
(17, '11', '機械'),  -- 机械 -> 機械
(18, '11', '牛頭人'), -- 牛头人 -> 牛頭人
(19, '11', '天神'),  -- Değişiklik yok
(20, '11', '巨魔'),  -- Değişiklik yok
(21, '11', '動物'),  -- 动物 -> 動物
(22, '11', '植物'),  -- Değişiklik yok
(23, '11', '魔法生物'), -- Değişiklik yok
(24, '11', '自動機'), -- 自动机 -> 自動機
(25, '11', '飛升者'), -- 飞升者 -> 飛升者
(26, '11', '冰鳳凰'), -- 冰凤凰 -> 冰鳳凰
(27, '11', '兩棲'),  -- 两栖 -> 兩棲
(28, '11', '石像鬼'), -- Değişiklik yok
(29, '11', '幽靈半人馬'), -- 幽灵半人马 -> 幽靈半人馬
(30, '11', '嚙齒動物'), -- 啮齿动物 -> 嚙齒動物
(31, '11', '半樹人'), -- 半树人 -> 半樹人
(32, '11', '風靈'),  -- 风灵 -> 風靈
(33, '11', '噩夢'),  -- 噩梦 -> 噩夢
(34, '11', '變異體'), -- 变异体 -> 變異體
(35, '11', '實體'),  -- 实体 -> 實體
(36, '11', '混血');  -- Değişiklik yok

-- Geleneksel Çince kaynak tipi çevirileri (zh-tw)
INSERT INTO resource_translations (resource_id, language_id, name) VALUES
(1, '11', '法力'),   -- Değişiklik yok
(2, '11', '能量'),   -- Değişiklik yok
(3, '11', '怒氣'),   -- 怒气 -> 怒氣
(4, '11', '護盾'),   -- 护盾 -> 護盾
(5, '11', '血量'),   -- Değişiklik yok
(6, '11', '勇氣'),   -- 勇气 -> 勇氣
(7, '11', '熱量'),   -- 热量 -> 熱量
(8, '11', '彈藥'),   -- 弹药 -> 彈藥
(9, '11', '無消耗'),  -- 无消耗 -> 無消耗
(10, '11', '生命值'), -- Değişiklik yok
(11, '11', '流量');  -- Değişiklik yok

-- Geleneksel Çince dövüş menzili çevirileri (zh-tw)
INSERT INTO combat_range_translations (combat_range_id, language_id, name) VALUES
(1, '11', '近戰'),   -- 近战 -> 近戰
(2, '11', '遠程'),   -- 远程 -> 遠程
(3, '11', '混合');   -- Değişiklik yok

-- Geleneksel Çince bölge çevirileri (zh-tw)
INSERT INTO region_translations (region_id, language_id, name, description) VALUES
(1, '11', '艾歐尼亞', '魔法與平衡之地'),            -- 艾欧尼亚, 魔法与平衡之地 -> 艾歐尼亞, 魔法與平衡之地
(2, '11', '諾克薩斯', '無情，擴張的帝國'),         -- 诺克萨斯, 无情，扩张的帝国 -> 諾克薩斯, 無情，擴張的帝國
(3, '11', '德瑪西亞', '秩序與正義之國'),           -- 德玛西亚, 秩序与正义之国 -> 德瑪西亞, 秩序與正義之國
(4, '11', '皮爾特沃夫', '進步之城'),              -- 皮尔特沃夫, 进步之城 -> 皮爾特沃夫, 進步之城
(5, '11', '祖安', '化學與污染的下城區'),           -- 化学与污染的下城区 -> 化學與污染的下城區
(6, '11', '弗雷爾卓德', '嚴峻，冰冷的荒野'),       -- 严峻，冰冷的荒野 -> 嚴峻，冰冷的荒野
(7, '11', '恕瑞瑪', '淪陷的沙漠帝國'),            -- 恕瑞玛, 沦陷的沙漠帝国 -> 恕瑞瑪, 淪陷的沙漠帝國
(8, '11', '比爾吉沃特', '無法無天的港口城市'),      -- 比尔吉沃特, 无法无天的港口城市 -> 比爾吉沃特, 無法無天的港口城市
(9, '11', '巨神峰', '通往星空的神聖山'),           -- 通往星空的神圣山 -> 通往星空的神聖山
(10, '11', '暗影島', '被黑霧腐蝕的群島'),          -- 暗影岛, 被黑雾腐蚀的群岛 -> 暗影島, 被黑霧腐蝕的群島
(11, '11', '班德爾城', '約德爾人的家園'),          -- 班德尔城, 约德尔人的家园 -> 班德爾城, 約德爾人的家園
(12, '11', '艾克薩爾', '與世隔絕的叢林領域'),       -- 艾克萨尔, 与世隔绝的丛林领域 -> 艾克薩爾, 與世隔絕的叢林領域
(13, '11', '虛空', '現實之外的噩夢領域'),          -- 虚空, 现实之外的噩梦领域 -> 虛空, 現實之外的噩夢領域
(14, '11', '符文之地', '世界本身'),               -- Değişiklik yok
(15, '11', '艾卡西亞', '古老，衰落的文明');        -- Değişiklik yok

INSERT INTO champion_translations (champion_id, language_id, name, title) VALUES
(1, '11', '厄薩斯', '暗裔劍魔'),
(2, '11', '阿狸', '九尾妖狐'),
(3, '11', '阿卡麗', '叛逆刺客'),
(4, '11', '阿克尚', '叛逆守衛'),
(5, '11', '亞歷斯塔', '牛頭酋長'),
(6, '11', '安貝薩', '諾克薩斯將軍'),
(7, '11', '阿木木', '哭泣的木乃伊'),
(8, '11', '艾尼維亞', '冰晶鳳凰'),
(9, '11', '安妮', '黑暗之女'),
(10, '11', '亞菲利歐', '信徒武器'),
(11, '11', '艾希', '冰霜射手'),
(12, '11', '奧瑞利安索爾', '星際龍王'),
(13, '11', '奧若拉', '冬之怒'),
(14, '11', '阿祈爾', '沙漠皇帝'),
(15, '11', '巴德', '漫遊守護者'),
(16, '11', '貝爾維斯', '虛空女皇'),
(17, '11', '布里茨', '蒸汽機器人'),
(18, '11', '布蘭德', '復仇烈焰'),
(19, '11', '布隆', '弗雷爾卓德之心'),
(20, '11', '布萊爾', '饑餓詛咒'),
(21, '11', '凱特琳', '皮爾特沃夫執法官'),
(22, '11', '卡蜜兒', '鋼鐵陰影'),
(23, '11', '卡西奧佩亞', '蛇女'),
(24, '11', '科加斯', '虛空恐懼'),
(25, '11', '庫奇', '英勇飛行員'),
(26, '11', '達瑞斯', '諾克薩斯之手'),
(27, '11', '黛安娜', '皎月之蔑視'),
(28, '11', '蒙多醫生', '祖安狂人'),
(29, '11', '德萊文', '處刑者'),
(30, '11', '艾克', '時間刺客'),
(31, '11', '伊莉絲', '蜘蛛女皇'),
(32, '11', '伊芙琳', '痛苦擁抱'),
(33, '11', '伊澤瑞爾', '探險家'),
(34, '11', '費德提克', '遠古恐懼'),
(35, '11', '菲歐拉', '大劍師'),
(36, '11', '菲茲', '潮汐捣蛋鬼'),
(37, '11', '加里奧', '正義巨像'),
(38, '11', '甘普朗克', '海洋之災'),
(39, '11', '蓋倫', '德瑪西亞之力'),
(40, '11', '納爾', '迷失之詩'),
(41, '11', '古拉加斯', '酒桶'),
(42, '11', '葛雷夫', '亡命之徒'),
(43, '11', '關', '聖裁縫'),
(44, '11', '赫卡里姆', '戰爭之影'),
(45, '11', '漢默丁格', '大發明家'),
(46, '11', '輝煌', '視覺藝術家'),
(47, '11', '伊莉奧', '海妖祭司'),
(48, '11', '伊瑞莉雅', '刀鋒舞者'),
(49, '11', '埃爾文', '綠色之父'),
(50, '11', '珍娜', '風暴使者'),
(51, '11', '嘉文四世', '德瑪西亞典範'),
(52, '11', '賈克斯', '武器大師'),
(53, '11', '杰斯', '明日守護者'),
(54, '11', '燼', '戲命師'),
(55, '11', '吉茵珂絲', '暴走重砲'),
(56, '11', '卡桑德', '納祖瑪的驕傲'),
(57, '11', '凱莎', '虛空之女'),
(58, '11', '克黎思妲', '復仇之矛'),
(59, '11', '卡爾瑪', '天啟者'),
(60, '11', '卡爾瑟斯', '死亡歌頌者'),
(61, '11', '卡薩丁', '虛空行者'),
(62, '11', '卡特蓮娜', '不祥之刃'),
(63, '11', '凱爾', '審判天使'),
(64, '11', '慨影', '闇影收割者'),
(65, '11', '凱能', '狂暴之心'),
(66, '11', '卡力斯', '虛空掠食者'),
(67, '11', '鏡爪', '永恆獵手'),
(68, '11', '克雷德', '暴躁騎士'),
(69, '11', '寇格魔', '深淵巨口'),
(70, '11', '樂芬', '詐欺師'),
(71, '11', '李星', '盲眼僧侶'),
(72, '11', '雷歐娜', '曙光女神'),
(73, '11', '莉莉亞', '害羞花靈'),
(74, '11', '麗珊卓', '冰霜女巫'),
(75, '11', '路西恩', '聖槍遊俠'),
(76, '11', '璐璐', '仙靈女巫'),
(77, '11', '拉克絲', '光明女神'),
(78, '11', '墨菲特', '巨石碎片'),
(79, '11', '馬爾札哈', '虛空先知'),
(80, '11', '茂凱', '扭曲樹人'),
(81, '11', '易大師', '無極劍聖'),
(82, '11', '梅爾', '神秘外交官'),
(83, '11', '米利歐', '溫柔之火'),
(84, '11', '好運姐', '賞金獵人'),
(85, '11', '魔鬥凱薩', '鐵鬼'),
(86, '11', '魔甘娜', '墮落天使'),
(87, '11', '娜美', '海潮喚使'),
(88, '11', '納瑟斯', '沙漠死神'),
(89, '11', '納帝魯斯', '深海泰坦'),
(90, '11', '奈菲利', '百咬獵犬'),
(91, '11', '妮可', '好奇變色龍'),
(92, '11', '奈德麗', '狂野獵手'),
(93, '11', '尼拉', '無盡喜悅'),
(94, '11', '魔腾', '永恆夢魘'),
(95, '11', '努努和威朗普', '冰雪兄弟'),
(96, '11', '歐拉夫', '狂戰士'),
(97, '11', '奧莉安娜', '發條少女'),
(98, '11', '鄂爾', '山之鍛造神'),
(99, '11', '潘森', '戰爭之矛'),
(100, '11', '波比', '鐵錘大使'),
(101, '11', '派克', '血港開膛手'),
(102, '11', '姬雅娜', '元素女帝'),
(103, '11', '葵恩', '德瑪西亞之翼'),
(104, '11', '銳空', '幻翎'),
(105, '11', '拉姆斯', '披甲龍龜'),
(106, '11', '雷珂煞', '虛空遁地獸'),
(107, '11', '銳兒', '鐵女皇'),
(108, '11', '芮娜塔', '化學女爵'),
(109, '11', '雷尼克頓', '沙漠屠夫'),
(110, '11', '雷葛爾', '傲慢獵手'),
(111, '11', '雷文', '放逐之刃'),
(112, '11', '藍寶', '機械威脅'),
(113, '11', '雷茲', '符文法師'),
(114, '11', '薩勒芬妮', '沙漠玫瑰'),
(115, '11', '史瓦妮', '北地之怒'),
(116, '11', '姍娜', '救贖者'),
(117, '11', '瑟菈紛', '星籟歌姬'),
(118, '11', '賽特', '卡戎之流'),
(119, '11', '薩科', '惡魔小丑'),
(120, '11', '慎', '暮光之眼'),
(121, '11', '希瓦娜', '半龍少女'),
(122, '11', '辛吉德', '瘋狂煉金師'),
(123, '11', '賽恩', '亡靈戰士'),
(124, '11', '希維爾', '戰爭女神'),
(125, '11', '史加納', '水晶守衛'),
(126, '11', '史摩爾', '小火龍'),
(127, '11', '索娜', '琴瑟仙女'),
(128, '11', '索拉卡', '星歌者'),
(129, '11', '斯溫', '諾克薩斯統領'),
(130, '11', '賽勒斯', '解鎖者'),
(131, '11', '星朵拉', '暗黑元首'),
(132, '11', '貪啃奇', '河流之王'),
(133, '11', '塔莉婭', '岩石編織者'),
(134, '11', '塔隆', '神行刺客'),
(135, '11', '塔里克', '瓦羅然之盾'),
(136, '11', '提摩', '迅捷斥候'),
(137, '11', '瑟雷西', '鏈魂獄獄長'),
(138, '11', '崔絲塔娜', '約德爾炮手'),
(139, '11', '特朗德', '巨魔王'),
(140, '11', '泰達米爾', '蠻族之王'),
(141, '11', '逆命', '卡牌大師'),
(142, '11', '圖奇', '瘟疫之源'),
(143, '11', '烏迪爾', '靈魂行者'),
(144, '11', '厄加特', '重裝戰士'),
(145, '11', '法洛士', '懲戒之箭'),
(146, '11', '汎', '暗夜獵手'),
(147, '11', '維迦', '邪惡小法師'),
(148, '11', '威寇茲', '虛空之眼'),
(149, '11', '薇可絲', '憂鬱'),
(150, '11', '菲艾', '皮城執法官'),
(151, '11', '維迦', '破敗之王'),
(152, '11', '維克特', '機械先驅'),
(153, '11', '弗拉迪米爾', '猩紅收割者'),
(154, '11', '弗力貝爾', '雷霆咆哮'),
(155, '11', '沃維克', '祖安怒兽'),
(156, '11', '悟空', '齊天大聖'),
(157, '11', '剎雅', '逆羽'),
(158, '11', '齊勒斯', '遠古魔導'),
(159, '11', '趙信', '德瑪西亞皇子'),
(160, '11', '犽宿', '亡魂劍客'),
(161, '11', '犽凝', '不滅劍魂'),
(162, '11', '約瑞科', '牧魂人'),
(163, '11', '悠咪', '魔法貓咪'),
(164, '11', '札克', '生化武器'),
(165, '11', '劫', '影流之主'),
(166, '11', '婕莉', '祖安電光'),
(167, '11', '希格斯', '爆破鬼才'),
(168, '11', '極靈', '時間守護者'),
(169, '11', '柔依', '暮光星靈'),
(170, '11', '婕莉', '荊棘之力');

INSERT INTO gender_translations (gender_id, language_id, name) VALUES
(@male_id, 11, '男性'),
(@female_id, 11, '女性'),
(@other_id, 11, '其他');

-- Japonca pozisyon çevirileri
INSERT INTO position_translations (position_id, language_id, name) VALUES
(1, '12', 'トップ'),
(2, '12', 'ジャングル'),
(3, '12', 'ミッド'),
(4, '12', 'ボット'),
(5, '12', 'サポート');

-- Japonca tür çevirileri
INSERT INTO species_translations (species_id, language_id, name) VALUES
(1, '12', '人間'),
(2, '12', 'ヨードル'),
(3, '12', 'ヴァスタヤ'),
(4, '12', 'ダーキン'),
(5, '12', 'ヴォイド'),
(6, '12', 'ゴースト'),
(7, '12', 'ゴーレム'),
(8, '12', 'アスペクト'),
(9, '12', '神'),
(10, '12', '半神'),
(11, '12', 'ブラッケン'),
(12, '12', '悪魔'),
(13, '12', '魂'),
(14, '12', '蛇'),
(15, '12', 'ドラゴン'),
(16, '12', '不死'),
(17, '12', 'サイバネティック'),
(18, '12', 'ミノタウロス'),
(19, '12', '天体'),
(20, '12', 'トロール'),
(21, '12', '動物'),
(22, '12', '植物'),
(23, '12', '魔法生物'),
(24, '12', 'オートマトン'),
(25, '12', '昇天者'),
(26, '12', '氷のフェニックス'),
(27, '12', '両生類'),
(28, '12', 'ガーゴイル'),
(29, '12', 'ゴーストケンタウロス'),
(30, '12', '齧歯類'),
(31, '12', '半樹木'),
(32, '12', '風の精霊'),
(33, '12', '悪夢'),
(34, '12', '変異体'),
(35, '12', '存在'),
(36, '12', 'ハイブリッド');

-- Japonca kaynak tipi çevirileri
INSERT INTO resource_translations (resource_id, language_id, name) VALUES
(1, '12', 'マナ'),
(2, '12', 'エネルギー'),
(3, '12', '怒り'),
(4, '12', 'シールド'),
(5, '12', '血液'),
(6, '12', '勇気'),
(7, '12', '熱'),
(8, '12', '弾薬'),
(9, '12', 'マナレス'),
(10, '12', '体力'),
(11, '12', 'フロー');

-- Japonca dövüş menzili çevirileri
INSERT INTO combat_range_translations (combat_range_id, language_id, name) VALUES
(1, '12', '近接'),
(2, '12', '遠距離'),
(3, '12', 'ハイブリッド');

-- Japonca bölge çevirileri
INSERT INTO region_translations (region_id, language_id, name, description) VALUES
(1, '12', 'アイオニア', '魔法とバランスの地'),
(2, '12', 'ノクサス', '無慈悲な拡張帝国'),
(3, '12', 'デマーシア', '法と正義の王国'),
(4, '12', 'ピルトーヴァー', '進歩の都市'),
(5, '12', 'ザウン', '化学と汚染の下街'),
(6, '12', 'フレヨルド', '厳しい氷の荒野'),
(7, '12', 'シュリーマ', '没落した砂漠帝国'),
(8, '12', 'ビルジウォーター', '無法の港町'),
(9, '12', 'ターゴン', '星に向かう聖なる山'),
(10, '12', 'シャドウアイル', '黒霧に汚染された島々'),
(11, '12', 'バンドルシティ', 'ヨードルの故郷'),
(12, '12', 'イクスタル', '孤立した森の領域'),
(13, '12', 'ヴォイド', '現実を超えた悪夢の領域'),
(14, '12', 'ルーンテラ', '世界そのもの'),
(15, '12', 'イカシア', '古代、没落した文明');

-- Japonca cinsiyet çevirileri
INSERT INTO gender_translations (gender_id, language_id, name) VALUES
(@male_id, 12, '男性'),
(@female_id, 12, '女性'),
(@other_id, 12, 'その他');

-- Japonca şampiyon çevirileri
INSERT INTO champion_translations (champion_id, language_id, name, title) VALUES
(1, '12', 'エイトロックス', 'ダーキンの剣'),
(2, '12', 'アーリ', '九尾の狐'),
(3, '12', 'アカリ', '孤高の暗殺者'),
(4, '12', 'アクシャン', '反逆の守護者'),
(5, '12', 'アリスター', 'ミノタウロス'),
(6, '12', 'アンベッサ', 'ノクサス将軍'),
(7, '12', 'アムム', '悲しみのミイラ'),
(8, '12', 'アニビア', '氷のフェニックス'),
(9, '12', 'アニー', '闇の少女'),
(10, '12', 'アフェリオス', '信者の武器'),
(11, '12', 'アッシュ', '氷のアーチャー'),
(12, '12', 'オレリオン・ソル', '星の鍛冶'),
(13, '12', 'オーロラ', '冬の怒り'),
(14, '12', 'アジール', '砂漠の皇帝'),
(15, '12', 'バード', '彷徨う守護者'),
(16, '12', "ベル'ヴェス", 'ヴォイドの女帝'),
(17, '12', 'ブリッツクランク', 'グレート・スチームゴーレム'),
(18, '12', 'ブランド', '燃える復讐'),
(19, '12', 'ブラウム', 'フレヨルドの心'),
(20, '12', 'ブライアー', '飢えの呪い'),
(21, '12', 'ケイトリン', 'ピルトーヴァーの保安官'),
(22, '12', 'カミール', '鋼の影'),
(23, '12', 'カシオペア', '蛇の抱擁'),
(24, '12', "コ'ガス", 'ヴォイドの恐怖'),
(25, '12', 'コーキ', '大胆なボンバーディア'),
(26, '12', 'ダリウス', 'ノクサスの手'),
(27, '12', 'ダイアナ', '月の侮蔑'),
(28, '12', 'ドクター・ムンド', 'ザウンの狂人'),
(29, '12', 'ドレイヴン', '栄光の処刑人'),
(30, '12', 'エコー', '時を砕く少年'),
(31, '12', 'エリス', '蜘蛛の女王'),
(32, '12', 'イブリン', '痛みの抱擁'),
(33, '12', 'エズリアル', '冒険家の天才'),
(34, '12', 'フィドルスティックス', '古の恐怖'),
(35, '12', 'フィオラ', '決闘の達人'),
(36, '12', 'フィズ', '潮の悪戯者'),
(37, '12', 'ガリオ', '巨像'),
(38, '12', 'ガングプランク', '海の災い'),
(39, '12', 'ガレン', 'デマーシアの力'),
(40, '12', 'ナー', '失われた環'),
(41, '12', 'グラガス', '酒樽'),
(42, '12', 'グレイブス', '無法者'),
(43, '12', 'グウェン', '聖なる裁縫師'),
(44, '12', 'ヘカリム', '戦争の影'),
(45, '12', 'ハイマーディンガー', '尊敬される発明家'),
(46, '12', 'フェイ', '視覚者'),
(47, '12', 'イラオイ', 'クラーケンの巫女'),
(48, '12', 'イレリア', '刃の舞踊手'),
(49, '12', 'アイバーン', '緑の父'),
(50, '12', 'ジャンナ', '風の怒り'),
(51, '12', 'ジャーヴァンIV世', 'デマーシアの模範'),
(52, '12', 'ジャックス', '武器の達人'),
(53, '12', 'ジェイス', '明日の守護者'),
(54, '12', 'ジン', '芸術家'),
(55, '12', 'ジンクス', '暴れん坊'),
(56, '12', "ク'サンテ", 'ナズマーの誇り'),
(57, '12', "カイ'サ", 'ヴォイドの娘'),
(58, '12', 'カリスタ', '復讐の槍'),
(59, '12', 'カルマ', '啓蒙者'),
(60, '12', 'カーサス', '死の歌い手'),
(61, '12', 'カサディン', 'ヴォイド・ウォーカー'),
(62, '12', 'カタリナ', '不吉な刃'),
(63, '12', 'ケイル', '正義'),
(64, '12', 'ケイン', '影の収穫者'),
(65, '12', 'ケネン', '嵐の心'),
(66, '12', "カ'ジックス", 'ヴォイドの略奪者'),
(67, '12', 'キンドレッド', '永遠の狩人たち'),
(68, '12', 'クレッド', '気難しい騎士'),
(69, '12', "コグ'マウ", '深淵の口'),
(70, '12', 'ルブラン', '欺瞞者'),
(71, '12', 'リー・シン', '盲目の修行僧'),
(72, '12', 'レオナ', '太陽の光'),
(73, '12', 'リリア', '恥ずかしがりや'),
(74, '12', 'リサンドラ', '氷の魔女'),
(75, '12', 'ルシアン', '浄化者'),
(76, '12', 'ルル', '妖精の魔術師'),
(77, '12', 'ラックス', '光の少女'),
(78, '12', 'マルファイト', '巨石の断片'),
(79, '12', 'マルザハー', 'ヴォイドの預言者'),
(80, '12', 'マオカイ', 'ねじれた木'),
(81, '12', 'マスター・イー', '無双剣聖'),
(82, '12', 'メル', '神秘的な外交官'),
(83, '12', 'ミリオ', '優しい炎'),
(84, '12', 'ミス・フォーチュン', '賞金稼ぎ'),
(85, '12', 'モルデカイザー', '鉄の亡霊'),
(86, '12', 'モルガナ', '堕ちた者'),
(87, '12', 'ナミ', '潮呼び'),
(88, '12', 'ナサス', '砂の番人'),
(89, '12', 'ノーチラス', '深海の巨人'),
(90, '12', 'ナーフィリ', '百噛みの猟犬'),
(91, '12', 'ニーコ', '好奇心旺盛なカメレオン'),
(92, '12', 'ニダリー', '野生の狩人'),
(93, '12', 'ニラー', '無限の喜び'),
(94, '12', 'ノクターン', '永遠の悪夢'),
(95, '12', 'ヌヌとウィルンプ', '少年と雪男'),
(96, '12', 'オラフ', 'バーサーカー'),
(97, '12', 'オリアナ', '時計仕掛けの少女'),
(98, '12', 'オーン', '山の鍛冶神'),
(99, '12', 'パンテオン', '不屈の槍'),
(100, '12', 'ポッピー', '鉄槌の守護者'),
(101, '12', 'パイク', 'ブラッド・ハーバーの切り裂き魔'),
(102, '12', 'キヤナ', '元素の女帝'),
(103, '12', 'クイン', 'デマーシアの翼'),
(104, '12', 'ラカン', '魅惑者'),
(105, '12', 'ラムス', '武装アルマジロ'),
(106, '12', "レク'サイ", 'ヴォイドの掘削者'),
(107, '12', 'レル', '鉄の乙女'),
(108, '12', 'レナータ・グラスク', '科学男爵'),
(109, '12', 'レネクトン', '砂の殺し屋'),
(110, '12', 'レンガー', '誇りの狩人'),
(111, '12', 'リヴェン', '追放者'),
(112, '12', 'ランブル', '機械の脅威'),
(113, '12', 'ライズ', 'ルーンの魔術師'),
(114, '12', 'サミラ', '砂漠のバラ'),
(115, '12', 'セジュアニ', '北方の怒り'),
(116, '12', 'セナ', '救済者'),
(117, '12', 'セラフィーン', '星を見る歌姫'),
(118, '12', 'セット', 'ボス'),
(119, '12', 'シャコ', '悪魔の道化師'),
(120, '12', 'シェン', '黄昏の目'),
(121, '12', 'シヴァーナ', '半竜'),
(122, '12', 'シンジド', '狂気の化学者'),
(123, '12', 'サイオン', '不死の戦争機械'),
(124, '12', 'シヴィア', '戦いのお姫様'),
(125, '12', 'スカーナー', 'クリスタルの守護者'),
(126, '12', 'スモルダー', '若き炎'),
(127, '12', 'ソナ', '弦の巨匠'),
(128, '12', 'ソラカ', '星の子'),
(129, '12', 'スワイン', 'ノクサス大将軍'),
(130, '12', 'サイラス', '鎖を解かれし者'),
(131, '12', 'シンドラ', '闇の支配者'),
(132, '12', 'タム・ケンチ', '川の王'),
(133, '12', 'タリヤ', '石編み'),
(134, '12', 'タロン', '刃の影'),
(135, '12', 'タリック', 'ヴァロランの盾'),
(136, '12', 'ティーモ', '俊敏なスカウト'),
(137, '12', 'スレッシュ', '鎖の看守'),
(138, '12', 'トリスターナ', 'ヨードル・ガンナー'),
(139, '12', 'トランドル', 'トロールの王'),
(140, '12', 'トリンダメア', '蛮族の王'),
(141, '12', 'トゥイステッド・フェイト', 'カードの達人'),
(142, '12', 'トゥイッチ', 'ペストラット'),
(143, '12', 'ウディア', '霊歩士'),
(144, '12', 'アーゴット', '恐るべき戦争機械'),
(145, '12', 'ヴァルス', '復讐の矢'),
(146, '12', 'ヴェイン', '夜の狩人'),
(147, '12', 'ヴェイガー', '小さな邪悪の支配者'),
(148, '12', "ヴェル'コズ", 'ヴォイドの目'),
(149, '12', 'ヴェックス', '憂鬱'),
(150, '12', 'ヴァイ', 'ピルトーヴァーの執行者'),
(151, '12', 'ヴィエゴ', '破滅の王'),
(152, '12', 'ヴィクター', '機械の使者'),
(153, '12', 'ヴラディミール', '真紅の収穫者'),
(154, '12', 'ヴォリベア', '容赦なき嵐'),
(155, '12', 'ワーウィック', 'ザウンの怒り'),
(156, '12', 'ウーコン', '猿の王'),
(157, '12', 'ザヤ', '反逆者'),
(158, '12', 'ゼラス', '昇天した魔術師'),
(159, '12', 'シン・ジャオ', 'デマーシアの執事'),
(160, '12', 'ヤスオ', '許されざる者'),
(161, '12', 'ヨネ', '忘れ得ぬもの'),
(162, '12', 'ヨリック', '霊の羊飼い'),
(163, '12', 'ユーミ', '魔法猫'),
(164, '12', 'ザック', '秘密兵器'),
(165, '12', 'ゼド', '影の支配者'),
(166, '12', 'ゼリ', 'ザウンの火花'),
(167, '12', 'ジグス', '爆破の達人'),
(168, '12', 'ジリアン', '時の番人'),
(169, '12', 'ゾーイ', '黄昏の化身'),
(170, '12', 'ザイラ', '棘の台頭');

-- Korece pozisyon çevirileri
INSERT INTO position_translations (position_id, language_id, name) VALUES
(1, '13', '탑'),
(2, '13', '정글'),
(3, '13', '미드'),
(4, '13', '바텀'),
(5, '13', '서포터');

-- Korece tür çevirileri
INSERT INTO species_translations (species_id, language_id, name) VALUES
(1, '13', '인간'),
(2, '13', '요들'),
(3, '13', '바스타야'),
(4, '13', '다르킨'),
(5, '13', '공허'),
(6, '13', '유령'),
(7, '13', '골렘'),
(8, '13', '화신'),
(9, '13', '신'),
(10, '13', '반신'),
(11, '13', '브라켄'),
(12, '13', '악마'),
(13, '13', '영혼'),
(14, '13', '뱀'),
(15, '13', '용'),
(16, '13', '불멸자'),
(17, '13', '사이버네틱'),
(18, '13', '미노타우로스'),
(19, '13', '천체'),
(20, '13', '트롤'),
(21, '13', '동물'),
(22, '13', '식물'),
(23, '13', '마법생물'),
(24, '13', '자동인형'),
(25, '13', '승천자'),
(26, '13', '얼음 불사조'),
(27, '13', '양서류'),
(28, '13', '가고일'),
(29, '13', '유령 켄타우로스'),
(30, '13', '설치류'),
(31, '13', '반수목'),
(32, '13', '바람의 정령'),
(33, '13', '악몽'),
(34, '13', '돌연변이'),
(35, '13', '존재'),
(36, '13', '혼합종');

-- Korece kaynak tipi çevirileri
INSERT INTO resource_translations (resource_id, language_id, name) VALUES
(1, '13', '마나'),
(2, '13', '기력'),
(3, '13', '분노'),
(4, '13', '보호막'),
(5, '13', '피'),
(6, '13', '용기'),
(7, '13', '열기'),
(8, '13', '탄약'),
(9, '13', '무소모'),
(10, '13', '체력'),
(11, '13', '흐름');

-- Korece dövüş menzili çevirileri
INSERT INTO combat_range_translations (combat_range_id, language_id, name) VALUES
(1, '13', '근접'),
(2, '13', '원거리'),
(3, '13', '혼합');

-- Korece bölge çevirileri
INSERT INTO region_translations (region_id, language_id, name, description) VALUES
(1, '13', '아이오니아', '마법과 균형의 땅'),
(2, '13', '녹서스', '무자비한 확장 제국'),
(3, '13', '데마시아', '법과 정의의 왕국'),
(4, '13', '필트오버', '진보의 도시'),
(5, '13', '자운', '화학과 오염의 하부도시'),
(6, '13', '프렐요드', '혹독하고 얼어붙은 황야'),
(7, '13', '슈리마', '몰락한 사막 제국'),
(8, '13', '빌지워터', '무법의 항구도시'),
(9, '13', '타곤', '별을 향한 성스러운 산'),
(10, '13', '그림자 군도', '검은 안개로 오염된 섬들'),
(11, '13', '밴들 시티', '요들의 고향'),
(12, '13', '익스탈', '고립된 정글 영역'),
(13, '13', '공허', '현실 너머의 악몽의 영역'),
(14, '13', '룬테라', '세계 그 자체'),
(15, '13', '이카시아', '고대의 몰락한 문명');

-- Korece cinsiyet çevirileri
INSERT INTO gender_translations (gender_id, language_id, name) VALUES
(@male_id, 13, '남성'),
(@female_id, 13, '여성'),
(@other_id, 13, '기타');

-- Korece şampiyon çevirileri
INSERT INTO champion_translations (champion_id, language_id, name, title) VALUES
(1, '13', '아트록스', '다르킨의 검'),
(2, '13', '아리', '구미호'),
(3, '13', '아칼리', '섬기는 암살자'),
(4, '13', '아크샨', '반항하는 파수꾼'),
(5, '13', '알리스타', '미노타우로스'),
(6, '13', '앰베사', '녹서스 장군'),
(7, '13', '아무무', '슬픈 미라'),
(8, '13', '애니비아', '얼음 불사조'),
(9, '13', '애니', '어둠의 아이'),
(10, '13', '아펠리오스', '신념의 무기'),
(11, '13', '애쉬', '서리궁수'),
(12, '13', '아우렐리온 솔', '별의 대장장이'),
(13, '13', '오로라', '겨울의 분노'),
(14, '13', '아지르', '사막의 황제'),
(15, '13', '바드', '방랑 관리인'),
(16, '13', '벨베스', '공허의 여제'),
(17, '13', '블리츠크랭크', '거대한 증기 골렘'),
(18, '13', '브랜드', '타오르는 복수'),
(19, '13', '브라움', '프렐요드의 심장'),
(20, '13', '브라이어', '기아의 저주'),
(21, '13', '케이틀린', '필트오버의 보안관'),
(22, '13', '카밀', '강철의 그림자'),
(23, '13', '카시오페아', '독사의 포옹'),
(24, '13', '초가스', '공허의 공포'),
(25, '13', '코르키', '대담한 폭격수'),
(26, '13', '다리우스', '녹서스의 손'),
(27, '13', '다이애나', '달의 경멸'),
(28, '13', '문도 박사', '자운의 광인'),
(29, '13', '드레이븐', '화려한 처형자'),
(30, '13', '에코', '시간을 달리는 소년'),
(31, '13', '엘리스', '거미 여왕'),
(32, '13', '이블린', '고통의 포옹'),
(33, '13', '이즈리얼', '탐험가 영재'),
(34, '13', '피들스틱', '고대의 공포'),
(35, '13', '피오라', '대결의 대가'),
(36, '13', '피즈', '조류의 장난꾼'),
(37, '13', '갈리오', '거상'),
(38, '13', '갱플랭크', '바다의 재앙'),
(39, '13', '가렌', '데마시아의 힘'),
(40, '13', '나르', '잃어버린 고리'),
(41, '13', '그라가스', '술취한 난동꾼'),
(42, '13', '그레이브즈', '무법자'),
(43, '13', '그웬', '신성한 재봉사'),
(44, '13', '헤카림', '전쟁의 그림자'),
(45, '13', '하이머딩거', '존경받는 발명가'),
(46, '13', '휘', '비전가'),
(47, '13', '일라오이', '크라켄의 여사제'),
(48, '13', '이렐리아', '칼날 무용수'),
(49, '13', '아이번', '녹색 아버지'),
(50, '13', '잔나', '폭풍의 분노'),
(51, '13', '자르반 4세', '데마시아의 모범'),
(52, '13', '잭스', '무기의 달인'),
(53, '13', '제이스', '미래의 수호자'),
(54, '13', '진', '기교의 대가'),
(55, '13', '징크스', '난폭한 말괄량이'),
(56, '13', '크산테', '나주마의 자존심'),
(57, '13', '카이사', '공허의 딸'),
(58, '13', '칼리스타', '복수의 창'),
(59, '13', '카르마', '깨우친 자'),
(60, '13', '카서스', '죽음의 노래꾼'),
(61, '13', '카사딘', '공허의 방랑자'),
(62, '13', '카타리나', '재앙의 검'),
(63, '13', '케일', '올바른 자'),
(64, '13', '케인', '그림자 수확자'),
(65, '13', '케넨', '폭풍의 심장'),
(66, '13', '카직스', '공허의 약탈자'),
(67, '13', '킨드레드', '영원한 사냥꾼들'),
(68, '13', '클레드', '까칠한 기수'),
(69, '13', '코그모', '심연의 아귀'),
(70, '13', '르블랑', '기만가'),
(71, '13', '리 신', '눈 먼 수도승'),
(72, '13', '레오나', '여명의 빛'),
(73, '13', '릴리아', '수줍은 꽃'),
(74, '13', '리산드라', '얼음 마녀'),
(75, '13', '루시안', '정화의 사도'),
(76, '13', '룰루', '요정 마법사'),
(77, '13', '럭스', '빛의 소녀'),
(78, '13', '말파이트', '돌 거인'),
(79, '13', '말자하', '공허의 예언자'),
(80, '13', '마오카이', '뒤틀린 나무'),
(81, '13', '마스터 이', '우주 검성'),
(82, '13', '멜', '신비한 외교관'),
(83, '13', '밀리오', '따뜻한 불꽃'),
(84, '13', '미스 포츈', '현상금 사냥꾼'),
(85, '13', '모데카이저', '철의 망령'),
(86, '13', '모르가나', '타락한 자'),
(87, '13', '나미', '파도소환사'),
(88, '13', '나서스', '사막의 관리자'),
(89, '13', '노틸러스', '심해의 거인'),
(90, '13', '나피리', '백 번 물어뜯는 그레이하운드'),
(91, '13', '니코', '호기심 많은 카멜레온'),
(92, '13', '니달리', '야생의 사냥꾼'),
(93, '13', '닐라', '무한한 기쁨'),
(94, '13', '녹턴', '영원한 악몽'),
(95, '13', '누누와 윌럼프', '소년과 설인'),
(96, '13', '올라프', '광전사'),
(97, '13', '오리아나', '시계태엽 소녀'),
(98, '13', '오른', '산 아래의 대장장이'),
(99, '13', '판테온', '불굴의 창'),
(100, '13', '뽀삐', '망치의 수호자'),
(101, '13', '파이크', '핏물 항구의 학살자'),
(102, '13', '키아나', '원소의 여제'),
(103, '13', '퀸', '데마시아의 날개'),
(104, '13', '라칸', '매혹하는 자'),
(105, '13', '람머스', '중무장 아르마딜로'),
(106, '13', '렉사이', '공허의 약탈자'),
(107, '13', '렐', '철의 처녀'),
(108, '13', '레나타 글라스크', '화학 남작'),
(109, '13', '레넥톤', '사막의 도살자'),
(110, '13', '렝가', '교만한 사냥꾼'),
(111, '13', '리븐', '추방자'),
(112, '13', '럼블', '기계 공학의 위협'),
(113, '13', '라이즈', '룬 마법사'),
(114, '13', '사미라', '사막의 장미'),
(115, '13', '세주아니', '북방의 분노'),
(116, '13', '세나', '구원자'),
(117, '13', '세라핀', '별을 바라보는 노래하는 소녀'),
(118, '13', '세트', '두목'),
(119, '13', '샤코', '악마 어릿광대'),
(120, '13', '쉔', '황혼의 눈'),
(121, '13', '쉬바나', '하프 드래곤'),
(122, '13', '신지드', '미친 화학자'),
(123, '13', '사이온', '불사의 전쟁 기계'),
(124, '13', '시비르', '전투의 여인'),
(125, '13', '스카너', '수정 경비대'),
(126, '13', '스몰더', '어린 화염'),
(127, '13', '소나', '현의 명인'),
(128, '13', '소라카', '별의 아이'),
(129, '13', '스웨인', '녹서스 대장군'),
(130, '13', '사일러스', '풀려난 자'),
(131, '13', '신드라', '어둠의 군주'),
(132, '13', '탐 켄치', '강의 왕'),
(133, '13', '탈리야', '바위술사'),
(134, '13', '탈론', '칼의 그림자'),
(135, '13', '타릭', '발로란의 방패'),
(136, '13', '티모', '날쌘 정찰병'),
(137, '13', '쓰레쉬', '사슬 감옥의 간수'),
(138, '13', '트리스타나', '요들 사수'),
(139, '13', '트런들', '트롤 왕'),
(140, '13', '트린다미어', '야만의 왕'),
(141, '13', '트위스티드 페이트', '카드의 달인'),
(142, '13', '트위치', '역병 쥐'),
(143, '13', '우디르', '정령 걷기'),
(144, '13', '우르곳', '두려운 전쟁 기계'),
(145, '13', '바루스', '복수의 화살'),
(146, '13', '베인', '어둠의 사냥꾼'),
(147, '13', '베이가', '작은 악의 지배자'),
(148, '13', '벨코즈', '공허의 눈'),
(149, '13', '벡스', '우울함'),
(150, '13', '바이', '필트오버의 집행자'),
(151, '13', '비에고', '파멸의 왕'),
(152, '13', '빅토르', '기계의 전령'),
(153, '13', '블라디미르', '진홍빛 수확자'),
(154, '13', '볼리베어', '무자비한 폭풍'),
(155, '13', '워윅', '자운의 분노'),
(156, '13', '오공', '원숭이 왕'),
(157, '13', '자야', '반항아'),
(158, '13', '제라스', '초월한 마법사'),
(159, '13', '신 짜오', '데마시아의 총독'),
(160, '13', '야스오', '용서받지 못한 자'),
(161, '13', '요네', '잊혀지지 않은 자'),
(162, '13', '요릭', '영혼의 목자'),
(163, '13', '유미', '마법 고양이'),
(164, '13', '자크', '비밀 병기'),
(165, '13', '제드', '그림자의 주인'),
(166, '13', '제리', '자운의 불꽃'),
(167, '13', '직스', '폭발물 전문가'),
(168, '13', '질리언', '시간의 수호자'),
(169, '13', '조이', '황혼의 화신'),
(170, '13', '자이라', '가시의 부활');