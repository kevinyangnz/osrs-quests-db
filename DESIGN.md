# Design Document



By Kevin Yang





## Purpose



Old School Runescape is a massively multiplayer online role-playing game (MMORPG). The game sees players create a character in which they can level up skills, complete quests and fight bosses. With quests being a crucial aspect of a character's progression, I've designed a database to keep track of player skill levels and quest information. This will facilitate an efficient quest completion plan for the given players.



## Scope



This database provides the necessary entities and join tables to keep track of player skill levels and quest information. With most quests having strict requirements and useful rewards, these will be tracked accordingly in my database. As the player completes quests and gains experience (xp) rewards from quests, the relevant relations will update accordingly. The database's scope includes:



* levels, denoting each level number a player can achieve and the xp required to reach said level
* skills, denoting the details of each skill the player can level up



* quests, conveying the details of each quest
* quest\_xp\_gained, tracking the xp gained in certain skills from completeing each quest
* quest\_prerequisites, represents the quests the player must have completed in order to finish each quest
* skill\_prerequisites, represents the skill level prerequisites for each quest
* other\_quest\_prerequisites, represents miscellaneous requirements for each quest



* players, shows basic account details for each player
* player\_skills, denotes the skill levels for each of the 23 skills for each player
* player\_quests\_completed, records the quests that each player has completed (can also be used to find uncompleted quests)







## Entities



The database includes the following entities:



**levels**

* `level`, specifying the level number that a skill can take. TINYINT (skill levels are from 1-99, with other levels reaching up to 126), NOT NULL, UNIQUE, PRIMARY KEY
* `xp\_required`, denoting the xp required to reach each skill level. INT (xp spans from 0 to 200 million), NOT NULL, UNIQUE



**skills**

* `id`, specifying the id of the skill. TINYINT (currently 23 skills, with new skills added infrequently), AUTO\_INCREMENT, PRIMARY KEY
* `skill\_name`, conveys the name of the skill. VARCHAR(32), Every skill must have a name and be unique. NOT NULL, UNIQUE
* `skill\_type`, categorises the skill type. ENUM('Combat', 'Gathering', 'Production', 'Utility'), Every skill must be categorised. NOT NULL
* `default\_xp`, INT (xp spans from 0 to 200 million), NOT NULL, DEFAULT 0 (xp for every skill except hitpoints begins at 0)
* `membership\_type`, shows whether the skill is available to both membership types or only free-to-play. ENUM('Free-to-play', 'Members'), NOT NULL
* `release\_date`, DATE (year, month, day), NOT NULL, DEFAULT (CURRENT\_DATE)



**quests**

* `id`, SMALLINT (currently 173 quests ingame), AUTO\_INCREMENT, PRIMARY KEY
* `quest\_name`, VARCHAR(64), NOT NULL, UNIQUE
* `official\_difficulty`, categorises official difficulty of quest. ENUM('Novice', 'Intermediate', 'Experienced', 'Master', 'Grandmaster', 'Special'), NOT NULL
* `official\_length`, categorises official length of quest. ENUM('Very Short', 'Short', 'Medium', 'Long', 'Very Long'), NOT NULL,
* `quest\_points\_gained`, quest points is a reward from completeing quests. TINYINT (currently the most quest points gained in a single quest is 10), DEFAULT 0
* `series`, providing the name of the quest series if applicable. VARCHAR(32)
* `release\_date`, DATE, NOT NULL, DEFAULT (CURRENT\_DATE)
* `membership\_type`, shows whether the quest is available to both membership types or only free-to-play. ENUM('Free-to-play', 'Members'), NOT NULL
* `quest\_type`, shows whether the quest is a regular quest or miniquest. ENUM('Quest', 'Miniquest'), NOT NULL, DEFAULT 'Quest'



**players**

* `id`, BIGINT (hundreds of millions of accounts get made), AUTO\_INCREMENT, PRIMARY KEY
* `username`, usernames can be at most 12 characters long. VARCHAR(12), NOT NULL, UNIQUE,
* `account\_type`, to document the many account types the game has to offer. ENUM(
  'Main', 'Ironman', 'Ultimate Ironman', 'Hardcore Ironman', 'Group Ironman',
  'Hardcore Group Ironman', 'Unranked Group Ironman'
  ), NOT NULL, DEFAULT 'Main',
* `combat\_level`, track the combat level of the player. TINYINT (3 to 126), DEFAULT 3,
* `quest\_points`, track the amount of quest points owned by each player. SMALLINT (327 is the current maximum), DEFAULT 0,





## Relationships



The entity relationship diagram below depicts the relationships within the database



As shown in the diagram:

* `skill\_prerequisites`, the quests, skills and levels entities can each be referenced 0 or many times in the skill\_prerequisites relationship. However, each skill\_prerequisites instance must each relate to only one instance of each of the levels, skills and quests entities.
* `quest\_xp\_gained`, the skills and quests entities can each be referenced 0 or many times in the quest\_xp\_gained relationship, but each instance of quest\_xp\_gained must relate to only one quests and one skills instance.
* `quest\_prerequisites`, we have a self-referencing relationship where each quest\_prerequisites instance is associated with one or many quests, while each quests instance is referenced 0 or many times in quest\_prerequisites.
* `other\_quest\_prerequisites`, we have another self-referencing relationship where each other\_quest\_prerequisites instance is associated with exactly one quest, while each quests instance is associated with zero or one other\_quests\_prerequisites instances.
* `player\_quests\_completed`, the quests entity is associated with 0 to many player\_quests\_completed instances (each quest is completed 0 to many times), while the players entity is associated with 0 to many player\_quests\_completed (each player can have 0 to many quests completed). Each player\_quests\_completed instance relates to only one quests and one players instance.
* `player\_skills`, the players entity is associated with many player\_skills instances, while the skills entity is also associated with many player\_skills instances. Each player\_skills instance relates to one skills and one players instance, which depicts the skill levels of each player.







### Optimizations



Indexes were used to speed up the process of searching for common queries. These involved the following:

* `quest\_points\_search` ON `quests` (`quest\_points\_gained), to quickly search for the quests that give the most quest points
* `skill\_prereq\_search` ON `skill\_prerequisites` (`quest\_id`, `skill\_level\_required`), to find the specific skill level requirements for each quest
* `skill\_reward\_search` ON `quest\_xp\_gained` (`skill\_id`, `xp\_gained`), to find the quests that give the most xp in each skill
* `player\_xp\_search` ON `player\_skills` (`player\_id`, `skill\_xp`), to find which of the players' skills are the lowest or highest



### Limitations



* Some quests give 'xp lamp' rewards, where the player can choose the skill in which they receive the xp in. The current schema cannot account for this reward under the `quest\_xp\_gained` relation.
* Currently, we are unable to automatically update player skill xp upon completion of quests
* For future improvements, Views may be used to speed up searches on complex queries
