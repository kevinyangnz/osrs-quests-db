/* === Commonly run SELECT queries  === */

-- Find all the incompleted quests from the given player_id
SELECT `quests`.`id`, `quests`.`quest_name` FROM `quests` 
WHERE `quests`.`id` NOT IN (
    SELECT `quest_id` FROM `player_quests_completed`
    WHERE `player_id` = 50
);

-- Find the skill the specified player has the lowest xp in
SELECT * FROM `player_skills` 
WHERE `player_id` = 445
ORDER BY `skill_xp` ASC
LIMIT 1;

-- Find all quests that the specified player meets the quest requirements for
SELECT * FROM `quests`
WHERE `id` NOT IN (
    SELECT DISTINCT `quest_id` FROM `quest_prerequisites`
    WHERE `quest_prereq_id` NOT IN (
        SELECT `quest_id` FROM `player_quests_completed` 
        WHERE `player_id` = 239
    )
) AND
`id` NOT IN (
    SELECT `quest_id` FROM `player_quests_completed` 
    WHERE `player_id` = 239
);


-- Find the quests that give the most xp in specific skills
SELECT `quest_name` FROM `quests`
WHERE `id` IN (
    SELECT `quest_id` FROM `quest_xp_gained` 
    WHERE `skill_id` = (
        SELECT `id` FROM `skills`
        WHERE `skill_name` = 'Agility'
    )
    ORDER BY `xp_gained` DESC
)


-- Find the quests that give the most Agility xp, ordered from highest to lowest
SELECT `quest_name`, `skill_name`, `xp_gained` FROM `quests`
JOIN `quest_xp_gained` AS `gained` ON `quests`.`id` = `gained`.`quest_id`
JOIN `skills` ON `gained`.`skill_id` = `skills`.`id`
WHERE `skill_name` = 'Agility'
ORDER BY `xp_gained` DESC;



/* === Commonly run INSERTIONS and UPDATES  === */

-- Adding the first 5 levels
INSERT INTO `levels` (`level`, `xp_required`)
VALUES 
    (1, 0),
    (2, 83),
    (3, 174),
    (4, 276),
    (5, 388);

-- Adding a new skill
INSERT INTO `skills` (`skill_name`, `skill_type`, `membership_type`)
VALUES ('Sailing', 'Utility', 'Members');

-- Adding a new quest (Dragon Slayer I)
INSERT INTO `quests` (
    `id`, `quest_name`, `official_difficulty`, `official_length`, `quest_points_gained`,
    `series`, `release_date`, `membership_type`, `quest_type`
)
VALUES (
    17, 'Dragon Slayer I', 'Experienced', 'Medium', 2,
    'Dragonkin', '2001-09-23', 'Free-to-play', 'Quest'
);

-- Adding quest xp gained (from Dragon Slayer I)
INSERT INTO `quest_xp_gained` (`quest_id`, `skill_id`, `xp_gained`)
VALUES 
    (17, 4, 18650),
    (17, 7, 18650);

-- Adding a new player
INSERT INTO `players` (`username`, `account_type`, `combat_level`, `quest_points`)
VALUES ('Settled', 'Ultimate Ironman', 126, 327);

-- Updating the players' skill level (gz)
UPDATE `player_skills`
SET `skill_xp` = 13034431
WHERE `player_id` = 244
AND `skill_id` = 22;

