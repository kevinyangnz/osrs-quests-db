# Design Document



By Kevin Yang





## Purpose



Old School Runescape is a massively multiplayer online role-playing game (MMORPG). The game sees players create a character in which they can level up skills, complete quests and fight bosses. With quests being a crucial aspect of a character's progression, I've designed a database to keep track of player skill levels and quest information. This will facilitate an efficient quest completion plan for the given players.



## Scope



This database provides the necessary entities and join tables to keep track of player skill levels and quest information. With most quests having strict requirements and useful rewards, these will be tracked accordingly in my database. As the player completes quests and gains experience (xp) rewards from quests, the relevant relations will update accordingly. The database's scope includes:



* `levels`, denoting each level number a player can achieve and the xp required to reach said level
* `skills`, denoting the details of each skill the player can level up



* `quests`, conveying the details of each quest
* `quest_xp_gained`, tracking the xp gained in certain skills from completeing each quest
* `quest_prerequisites`, represents the quests the player must have completed in order to finish each quest
* `skill_prerequisites`, represents the skill level prerequisites for each quest
* `other_quest_prerequisites`, represents miscellaneous requirements for each quest



* `players`, shows basic account details for each player
* `player_skills`, denotes the skill levels for each of the 23 skills for each player
* `player_quests_completed`, records the quests that each player has completed (can also be used to find uncompleted quests)







## Entities



The database includes the following entities:



**levels**

* `level`, specifying the level number that a skill can take. TINYINT (skill levels are from 1-99, with other levels reaching up to 126), NOT NULL, UNIQUE, PRIMARY KEY
* `xp_required`, denoting the xp required to reach each skill level. INT (xp spans from 0 to 200 million), NOT NULL, UNIQUE



**skills**

* `id`, specifying the id of the skill. TINYINT (currently 23 skills, with new skills added infrequently), AUTO_INCREMENT, PRIMARY KEY
* `skill_name`, conveys the name of the skill. VARCHAR(32), Every skill must have a name and be unique. NOT NULL, UNIQUE
* `skill_type`, categorises the skill type. ENUM('Combat', 'Gathering', 'Production', 'Utility'), Every skill must be categorised. NOT NULL
* `default_xp`, INT (xp spans from 0 to 200 million), NOT NULL, DEFAULT 0 (xp for every skill except hitpoints begins at 0)
* `membership_type`, shows whether the skill is available to both membership types or only free-to-play. ENUM('Free-to-play', 'Members'), NOT NULL
* `release_date`, DATE (year, month, day), NOT NULL, DEFAULT (CURRENT_DATE)



**quests**

* `id`, SMALLINT (currently 173 quests ingame), AUTO_INCREMENT, PRIMARY KEY
* `quest_name`, VARCHAR(64), NOT NULL, UNIQUE
* `official_difficulty`, categorises official difficulty of quest. ENUM('Novice', 'Intermediate', 'Experienced', 'Master', 'Grandmaster', 'Special'), NOT NULL
* `official_length`, categorises official length of quest. ENUM('Very Short', 'Short', 'Medium', 'Long', 'Very Long'), NOT NULL,
* `quest_points_gained`, quest points is a reward from completeing quests. TINYINT (currently the most quest points gained in a single quest is 10), DEFAULT 0
* `series`, providing the name of the quest series if applicable. VARCHAR(32)
* `release_date`, DATE, NOT NULL, DEFAULT (CURRENT_DATE)
* `membership_type`, shows whether the quest is available to both membership types or only free-to-play. ENUM('Free-to-play', 'Members'), NOT NULL
* `quest_type`, shows whether the quest is a regular quest or miniquest. ENUM('Quest', 'Miniquest'), NOT NULL, DEFAULT 'Quest'



**players**

* `id`, BIGINT (hundreds of millions of accounts get made), AUTO_INCREMENT, PRIMARY KEY
* `username`, usernames can be at most 12 characters long. VARCHAR(12), NOT NULL, UNIQUE,
* `account_type`, to document the many account types the game has to offer. ENUM(
  'Main', 'Ironman', 'Ultimate Ironman', 'Hardcore Ironman', 'Group Ironman',
  'Hardcore Group Ironman', 'Unranked Group Ironman'
  ), NOT NULL, DEFAULT 'Main',
* `combat_level`, track the combat level of the player. TINYINT (3 to 126), DEFAULT 3,
* `quest_points`, track the amount of quest points owned by each player. SMALLINT (327 is the current maximum), DEFAULT 0,





## Relationships



The entity relationship diagram below depicts the relationships within the database



As shown in the diagram:

* `skill_prerequisites`, the quests, skills and levels entities can each be referenced 0 or many times in the skill_prerequisites relationship. However, each skill_prerequisites instance must each relate to only one instance of each of the levels, skills and quests entities.
* `quest_xp_gained`, the skills and quests entities can each be referenced 0 or many times in the quest_xp_gained relationship, but each instance of quest_xp_gained must relate to only one quests and one skills instance.
* `quest_prerequisites`, we have a self-referencing relationship where each quest_prerequisites instance is associated with one or many quests, while each quests instance is referenced 0 or many times in quest_prerequisites.
* `other_quest_prerequisites`, we have another self-referencing relationship where each other_quest_prerequisites instance is associated with exactly one quest, while each quests instance is associated with zero or one other_quests_prerequisites instances.
* `player_quests_completed`, the quests entity is associated with 0 to many player_quests_completed instances (each quest is completed 0 to many times), while the players entity is associated with 0 to many player_quests_completed (each player can have 0 to many quests completed). Each player_quests_completed instance relates to only one quests and one players instance.
* `player_skills`, the players entity is associated with many player_skills instances, while the skills entity is also associated with many player_skills instances. Each player_skills instance relates to one skills and one players instance, which depicts the skill levels of each player.







### Optimizations



Indexes were used to speed up the process of searching for common queries. These involved the following:

* `quest_points_search` ON `quests` (`quest_points_gained`), to quickly search for the quests that give the most quest points
* `skill_prereq_search` ON `skill_prerequisites` (`quest_id`, `skill_level_required`), to find the specific skill level requirements for each quest
* `skill_reward_search` ON `quest_xp_gained` (`skill_id`, `xp_gained`), to find the quests that give the most xp in each skill
* `player_xp_search` ON `player_skills` (`player_id`, `skill_xp`), to find which of the players' skills are the lowest or highest



### Limitations



* Some quests give 'xp lamp' rewards, where the player can choose the skill in which they receive the xp in. The current schema cannot account for this reward under the `quest_xp_gained` relation.
* Currently, we are unable to automatically update player skill xp upon completion of quests
* For future improvements, Views may be used to speed up searches on complex queries
