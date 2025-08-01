-- Written in MySQL



/* === Relations for levels and skills === */

-- Show the XP required to reach each level 
CREATE TABLE `levels` (
    `level` TINYINT NOT NULL UNIQUE,
    `xp_required` INT NOT NULL UNIQUE,
    PRIMARY KEY(`level`)
);

-- Show the skills available
CREATE TABLE `skills` (
    `id` TINYINT AUTO_INCREMENT,
    `skill_name` VARCHAR(32) NOT NULL UNIQUE,
    `skill_type` ENUM('Combat', 'Gathering', 'Production', 'Utility') NOT NULL,
    `default_xp` INT NOT NULL DEFAULT 0,
    `membership_type` ENUM('Free-to-play', 'Members') NOT NULL,
    `release_date` DATE NOT NULL DEFAULT (CURRENT_DATE),
    PRIMARY KEY(`id`) 
);


/* === Relations for quests, prerequisites and rewards === */

-- Represent the quests and miniquests available 
CREATE TABLE `quests` (
    `id` SMALLINT AUTO_INCREMENT,
    `quest_name` VARCHAR(64) NOT NULL UNIQUE,
    `official_difficulty` ENUM(
        'Novice', 'Intermediate', 'Experienced', 'Master', 'Grandmaster', 'Special'
        ) NOT NULL,
    `official_length` ENUM(
        'Very Short', 'Short', 'Medium', 'Long', 'Very Long'
        ) NOT NULL,
    `quest_points_gained` TINYINT DEFAULT 0, 
    `series` VARCHAR(32),
    `release_date` DATE NOT NULL DEFAULT (CURRENT_DATE),
    `membership_type` ENUM('Free-to-play', 'Members') NOT NULL,  
    `quest_type` ENUM('Quest', 'Miniquest') NOT NULL DEFAULT 'Quest',
    PRIMARY KEY(`id`)
);

-- Represent the xp gained from completeing each quest per skill
CREATE TABLE `quest_xp_gained` (
    `quest_id` SMALLINT,
    `skill_id` TINYINT,
    `xp_gained` MEDIUMINT,
    PRIMARY KEY(`quest_id`, `skill_id`),
    FOREIGN KEY(`quest_id`) REFERENCES `quests`(`id`) ON DELETE CASCADE,
    FOREIGN KEY(`skill_id`) REFERENCES `skills`(`id`) ON DELETE RESTRICT
);


-- Represent the quest prerequisites for each quest
CREATE TABLE `quest_prerequisites` (
    `quest_id` SMALLINT,
    `quest_prereq_id` SMALLINT,
    PRIMARY KEY(`quest_id`, `quest_prereq_id`),
    FOREIGN KEY(`quest_id`) REFERENCES `quests`(`id`) ON DELETE CASCADE,
    FOREIGN KEY(`quest_prereq_id`) REFERENCES `quests`(`id`) ON DELETE CASCADE
);

-- Represent the skill prerequisites for each quest
CREATE TABLE `skill_prerequisites` (
    `quest_id` SMALLINT,
    `skill_prereq_id` TINYINT,
    `skill_level_required` TINYINT,
    PRIMARY KEY(`quest_id`, `skill_prereq_id`),
    FOREIGN KEY(`quest_id`) REFERENCES `quests`(`id`) ON DELETE CASCADE,
    FOREIGN KEY(`skill_prereq_id`) REFERENCES `skills`(`id`) ON DELETE RESTRICT,
    FOREIGN KEY(`skill_level_required`) REFERENCES `levels`(`level`) ON DELETE RESTRICT
);

-- Represent other quest requirements 
CREATE TABLE `other_quest_prerequisites` (
    `quest_id` SMALLINT,
    `combat_level` TINYINT DEFAULT 0,
    `quest_points` SMALLINT DEFAULT 0,
    PRIMARY KEY(`quest_id`),
    FOREIGN KEY(`quest_id`) REFERENCES `quests`(`id`) ON DELETE CASCADE
);



/* === Relations for player details, stats and quests completed === */

-- Portray player details
CREATE TABLE `players` (
    `id` BIGINT AUTO_INCREMENT,
    `username` VARCHAR(12) NOT NULL UNIQUE,
    `account_type` ENUM(
        'Main', 'Ironman', 'Ultimate Ironman', 'Hardcore Ironman', 'Group Ironman',
        'Hardcore Group Ironman', 'Unranked Group Ironman'
        ) NOT NULL DEFAULT 'Main',
    `combat_level` TINYINT DEFAULT 3,
    `quest_points` SMALLINT DEFAULT 0,
    PRIMARY KEY(`id`)
);

-- Portray the XP in each skill per player
CREATE TABLE `player_skills` (
    `player_id` BIGINT,
    `skill_id` TINYINT, 
    `skill_xp` INT NOT NULL DEFAULT 0,
    PRIMARY KEY(`player_id`, `skill_id`),
    FOREIGN KEY(`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE,
    FOREIGN KEY(`skill_id`) REFERENCES `skills`(`id`) ON DELETE CASCADE
);

-- Portray the player quests completed
CREATE TABLE `player_quests_completed` (
    `player_id` BIGINT,
    `quest_id` SMALLINT,
    PRIMARY KEY(`player_id`, `quest_id`),
    FOREIGN KEY(`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE,
    FOREIGN KEY(`quest_id`) REFERENCES `quests`(`id`) ON DELETE CASCADE
);



/* === Create indexes for common lookups === */

-- Find the quests that give the most quest points
CREATE INDEX `quest_points_search` ON `quests` (`quest_points_gained`);

-- Find the specific skill requirements for each quest
CREATE INDEX `skill_prereq_search` ON `skill_prerequisites` (`quest_id`, `skill_level_required`);

-- Find the skill xp gained for each quest
CREATE INDEX `skill_reward_search` ON `quest_xp_gained` (`skill_id`, `xp_gained`);

-- Find which player skills are the lowest or highest
CREATE INDEX `player_xp_search` ON `player_skills` (`player_id`, `skill_xp`);


