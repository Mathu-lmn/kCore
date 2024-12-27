CREATE TABLE IF NOT EXISTS characters (
    id INT AUTO_INCREMENT,
    identifier VARCHAR(50) NOT NULL,
    char_slot INT NOT NULL,
    citizenid VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    job JSON DEFAULT '{"name": "unemployed", "grade": 0}',
    money JSON DEFAULT '{"cash": 0, "bank": 0}',
    position JSON DEFAULT '{
        "x": -269.4,
        "y": -955.3,
        "z": 31.2,
        "heading": 205.0
    }',
    stats JSON DEFAULT '{"hunger": 100, "thirst": 100}',
    appearance JSON DEFAULT '{
        "model": "mp_m_freemode_01",
        "clothing": {},
        "genetics": {},
        "faceFeatures": {},
        "headOverlays": {}
    }',
    inventory JSON DEFAULT '{
        "maxWeight": 100,
        "rows": 10,
        "columns": 10,
        "items": []
    }',
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY unique_char (identifier, char_slot),
    UNIQUE KEY unique_citizenid (citizenid)
);


CREATE TABLE IF NOT EXISTS character_outfits (
    id INT AUTO_INCREMENT PRIMARY KEY,
    citizenid VARCHAR(50) NOT NULL,
    name VARCHAR(50) NOT NULL,
    outfit_data JSON NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (citizenid) REFERENCES characters(citizenid) ON DELETE CASCADE
);