-- MySQL dump 10.13  Distrib 8.4.8, for Win64 (x86_64)
--
-- Host: localhost    Database: ludo
-- ------------------------------------------------------
-- Server version	8.4.8

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache` (
  `key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
INSERT INTO `cache` VALUES ('laravel-cache-ludo:game:room:1','a:15:{s:14:\"quick_match_id\";i:1;s:7:\"room_id\";i:1;s:7:\"game_id\";i:1;s:17:\"current_turn_seat\";i:1;s:20:\"current_turn_user_id\";i:37;s:12:\"active_seats\";a:2:{i:0;i:0;i:1;i:1;}s:10:\"dice_value\";N;s:8:\"can_roll\";b:1;s:9:\"must_move\";b:0;s:17:\"consecutive_sixes\";i:0;s:15:\"token_positions\";a:2:{s:3:\"red\";a:4:{i:0;i:-1;i:1;i:-1;i:2;i:-1;i:3;i:-1;}s:6:\"yellow\";a:4:{i:0;i:-1;i:1;i:-1;i:2;i:-1;i:3;i:-1;}}s:7:\"players\";a:2:{i:0;a:5:{s:7:\"user_id\";i:36;s:8:\"username\";s:9:\"Guest9942\";s:5:\"color\";s:3:\"red\";s:13:\"seat_position\";i:0;s:12:\"is_connected\";b:1;}i:1;a:5:{s:7:\"user_id\";i:37;s:8:\"username\";s:9:\"Guest9943\";s:5:\"color\";s:6:\"yellow\";s:13:\"seat_position\";i:1;s:12:\"is_connected\";b:1;}}s:6:\"status\";s:11:\"in_progress\";s:9:\"winner_id\";N;s:14:\"last_action_at\";s:25:\"2026-09-06T08:14:31+00:00\";}',1788768871),('laravel-cache-matchmaking:queue:2:500','a:0:{}',1788768841);
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_locks_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_locks`
--

LOCK TABLES `cache_locks` WRITE;
/*!40000 ALTER TABLE `cache_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chat_messages`
--

DROP TABLE IF EXISTS `chat_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chat_messages` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `room_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `message_type` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'text',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `chat_messages_room_id_index` (`room_id`),
  KEY `chat_messages_user_id_index` (`user_id`),
  KEY `chat_messages_room_id_id_index` (`room_id`,`id`),
  CONSTRAINT `chat_messages_ibfk_1` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chat_messages_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chat_messages`
--

LOCK TABLES `chat_messages` WRITE;
/*!40000 ALTER TABLE `chat_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `chat_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `direct_messages`
--

DROP TABLE IF EXISTS `direct_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `direct_messages` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `sender_id` bigint unsigned NOT NULL,
  `receiver_id` bigint unsigned NOT NULL,
  `type` enum('text','voice') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'text',
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `voice_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `voice_duration` int DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `direct_messages_sender_id_index` (`sender_id`),
  KEY `direct_messages_receiver_id_index` (`receiver_id`),
  CONSTRAINT `direct_messages_receiver_id_foreign` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `direct_messages_sender_id_foreign` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `direct_messages`
--

LOCK TABLES `direct_messages` WRITE;
/*!40000 ALTER TABLE `direct_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `direct_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `friends`
--

DROP TABLE IF EXISTS `friends`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `friends` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `friend_id` bigint unsigned NOT NULL,
  `status` enum('pending','accepted','blocked') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_friendship` (`user_id`,`friend_id`),
  KEY `friends_friend_id_index` (`friend_id`),
  CONSTRAINT `friends_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `friends_ibfk_2` FOREIGN KEY (`friend_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `friends`
--

LOCK TABLES `friends` WRITE;
/*!40000 ALTER TABLE `friends` DISABLE KEYS */;
/*!40000 ALTER TABLE `friends` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `game_moves`
--

DROP TABLE IF EXISTS `game_moves`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `game_moves` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `game_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `token_id` tinyint NOT NULL,
  `dice_value` tinyint NOT NULL,
  `from_pos` int DEFAULT NULL,
  `to_pos` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `is_kill` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `game_moves_game_id_index` (`game_id`),
  KEY `game_moves_user_id_index` (`user_id`),
  CONSTRAINT `game_moves_ibfk_1` FOREIGN KEY (`game_id`) REFERENCES `games` (`id`) ON DELETE CASCADE,
  CONSTRAINT `game_moves_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `game_moves`
--

LOCK TABLES `game_moves` WRITE;
/*!40000 ALTER TABLE `game_moves` DISABLE KEYS */;
/*!40000 ALTER TABLE `game_moves` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `games`
--

DROP TABLE IF EXISTS `games`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `games` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `room_id` bigint unsigned NOT NULL,
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'playing',
  `winner_id` bigint unsigned DEFAULT NULL,
  `started_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `ended_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `games_room_id_index` (`room_id`),
  KEY `games_winner_id_index` (`winner_id`),
  CONSTRAINT `games_ibfk_1` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE CASCADE,
  CONSTRAINT `games_ibfk_2` FOREIGN KEY (`winner_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `games`
--

LOCK TABLES `games` WRITE;
/*!40000 ALTER TABLE `games` DISABLE KEYS */;
INSERT INTO `games` VALUES (1,1,'in_progress',NULL,'2026-09-06 03:14:03',NULL,'2026-09-06 03:14:03');
/*!40000 ALTER TABLE `games` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_batches`
--

LOCK TABLES `job_batches` WRITE;
/*!40000 ALTER TABLE `job_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint unsigned NOT NULL,
  `reserved_at` int unsigned DEFAULT NULL,
  `available_at` int unsigned NOT NULL,
  `created_at` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `league_division_members`
--

DROP TABLE IF EXISTS `league_division_members`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `league_division_members` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `league_division_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `points_in_division` int NOT NULL DEFAULT '0',
  `final_rank` int DEFAULT NULL,
  `result` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `joined_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ldm_div_user_unique` (`league_division_id`,`user_id`),
  KEY `ldm_div_pts_idx` (`league_division_id`,`points_in_division`),
  KEY `ldm_user_created_idx` (`user_id`,`created_at`),
  CONSTRAINT `league_division_members_league_division_id_foreign` FOREIGN KEY (`league_division_id`) REFERENCES `league_divisions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `league_division_members_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `league_division_members`
--

LOCK TABLES `league_division_members` WRITE;
/*!40000 ALTER TABLE `league_division_members` DISABLE KEYS */;
/*!40000 ALTER TABLE `league_division_members` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `league_divisions`
--

DROP TABLE IF EXISTS `league_divisions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `league_divisions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `league_season_id` bigint unsigned NOT NULL,
  `league_tier_id` bigint unsigned NOT NULL,
  `division_number` int NOT NULL DEFAULT '1',
  `max_players` int NOT NULL DEFAULT '30',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `league_divisions_league_season_id_foreign` (`league_season_id`),
  KEY `league_divisions_league_tier_id_foreign` (`league_tier_id`),
  CONSTRAINT `league_divisions_league_season_id_foreign` FOREIGN KEY (`league_season_id`) REFERENCES `league_seasons` (`id`) ON DELETE CASCADE,
  CONSTRAINT `league_divisions_league_tier_id_foreign` FOREIGN KEY (`league_tier_id`) REFERENCES `league_tiers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `league_divisions`
--

LOCK TABLES `league_divisions` WRITE;
/*!40000 ALTER TABLE `league_divisions` DISABLE KEYS */;
/*!40000 ALTER TABLE `league_divisions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `league_seasons`
--

DROP TABLE IF EXISTS `league_seasons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `league_seasons` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `season_number` int NOT NULL,
  `starts_at` timestamp NOT NULL,
  `ends_at` timestamp NOT NULL,
  `status` enum('upcoming','active','completed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `league_seasons`
--

LOCK TABLES `league_seasons` WRITE;
/*!40000 ALTER TABLE `league_seasons` DISABLE KEYS */;
INSERT INTO `league_seasons` VALUES (1,1,'2026-08-30 10:31:14','2026-09-06 10:31:14','active','2026-08-30 10:31:14','2026-08-30 10:31:14');
/*!40000 ALTER TABLE `league_seasons` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `league_tiers`
--

DROP TABLE IF EXISTS `league_tiers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `league_tiers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tier_order` int NOT NULL,
  `min_points` int NOT NULL,
  `max_points` int DEFAULT NULL,
  `icon_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `league_tiers`
--

LOCK TABLES `league_tiers` WRITE;
/*!40000 ALTER TABLE `league_tiers` DISABLE KEYS */;
/*!40000 ALTER TABLE `league_tiers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leagues`
--

DROP TABLE IF EXISTS `leagues`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `leagues` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `min_points` int NOT NULL,
  `max_points` int NOT NULL,
  `icon_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tier_order` int NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leagues`
--

LOCK TABLES `leagues` WRITE;
/*!40000 ALTER TABLE `leagues` DISABLE KEYS */;
/*!40000 ALTER TABLE `leagues` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=44 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'0001_01_01_000001_create_cache_table',1),(2,'2026_08_09_043034_create_chat_messages_table',1),(3,'2026_08_09_043034_create_failed_jobs_table',1),(4,'2026_08_09_043034_create_friends_table',1),(5,'2026_08_09_043034_create_game_moves_table',1),(6,'2026_08_09_043034_create_games_table',1),(7,'2026_08_09_043034_create_job_batches_table',1),(8,'2026_08_09_043034_create_jobs_table',1),(9,'2026_08_09_043034_create_personal_access_tokens_table',1),(10,'2026_08_09_043034_create_room_players_table',1),(11,'2026_08_09_043034_create_rooms_table',1),(12,'2026_08_09_043034_create_store_items_table',1),(13,'2026_08_09_043034_create_transactions_table',1),(14,'2026_08_09_043034_create_user_inventory_table',1),(15,'2026_08_09_043034_create_users_table',1),(16,'2026_08_09_043034_create_wallets_table',1),(17,'2026_08_09_043037_add_foreign_keys_to_chat_messages_table',1),(18,'2026_08_09_043037_add_foreign_keys_to_friends_table',1),(19,'2026_08_09_043037_add_foreign_keys_to_game_moves_table',1),(20,'2026_08_09_043037_add_foreign_keys_to_games_table',1),(21,'2026_08_09_043037_add_foreign_keys_to_room_players_table',1),(22,'2026_08_09_043037_add_foreign_keys_to_rooms_table',1),(23,'2026_08_09_043037_add_foreign_keys_to_transactions_table',1),(24,'2026_08_09_043037_add_foreign_keys_to_user_inventory_table',1),(25,'2026_08_09_043037_add_foreign_keys_to_wallets_table',1),(26,'2026_08_09_100000_add_country_code_to_users_table',1),(27,'2026_08_09_110000_add_google_id_and_auth_provider_to_users_table',1),(28,'2026_08_09_120000_add_metadata_to_users_table',1),(29,'2026_08_09_130000_add_profile_fields_to_users_table',2),(30,'2026_08_09_140000_create_leagues_table',2),(31,'2026_08_09_150000_add_entry_fee_to_transactions_type_enum',2),(32,'2026_08_09_160000_create_direct_messages_table',3),(33,'2026_08_09_140000_create_league_tiers_table',4),(34,'2026_08_09_140001_create_league_seasons_table',4),(35,'2026_08_09_140002_create_league_divisions_table',4),(36,'2026_08_09_140003_create_league_division_members_table',4),(37,'2026_08_10_160000_create_tournaments_table',4),(38,'2026_08_10_160001_create_tournament_levels_table',4),(39,'2026_08_10_160002_create_tournament_participants_table',4),(40,'2026_08_10_160003_create_tournament_matches_table',4),(41,'2026_08_26_000001_modify_result_in_league_division_members_table',4),(42,'2026_08_29_160000_add_message_type_to_chat_messages_table',4),(43,'2026_08_30_171000_add_room_id_id_composite_index_to_chat_messages_table',4);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint unsigned NOT NULL,
  `name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  KEY `personal_access_tokens_expires_at_index` (`expires_at`)
) ENGINE=InnoDB AUTO_INCREMENT=63 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
INSERT INTO `personal_access_tokens` VALUES (6,'App\\Models\\User',2,'guest_token','2505c86cfb9686758d2a21a684fe802a9353fe1b91cf3c837fd3566f89fbc40f','[\"*\"]',NULL,NULL,'2026-08-10 10:31:35','2026-08-10 10:31:35'),(7,'App\\Models\\User',1,'guest_token','0c3cba500748438823452aa11cc71d289c9f608682362c75e21652b7449496e7','[\"*\"]',NULL,NULL,'2026-08-10 10:34:00','2026-08-10 10:34:00'),(9,'App\\Models\\User',4,'auth_token','0f7e5f08ff53bd31ceea40f3e7d3f81966950144a16b956b15894820ab4b2115','[\"*\"]',NULL,NULL,'2026-08-10 10:53:38','2026-08-10 10:53:38'),(10,'App\\Models\\User',4,'auth_token','be81ed71c3bab2a912823e7b588115a2b55a37641347a7850c9b45a4e77d4899','[\"*\"]',NULL,NULL,'2026-08-10 10:54:48','2026-08-10 10:54:48'),(13,'App\\Models\\User',5,'guest_token','08590580b932fc250244c82cde4649c9328e82cc69883ca3fec6fed307da8de2','[\"*\"]','2026-08-15 08:58:42',NULL,'2026-08-15 03:39:33','2026-08-15 08:58:42'),(15,'App\\Models\\User',6,'guest_token','24d3b241a405fb7d76dfdcee3a4791fcac3d725109ad9e5b96cf20c2af90092d','[\"*\"]','2026-08-15 09:11:30',NULL,'2026-08-15 09:11:29','2026-08-15 09:11:30'),(17,'App\\Models\\User',7,'guest_token','bf4072961baec5c5fb8b611be8b272f88b887e80ed4aeb5f6dbe44da6fc4d238','[\"*\"]','2026-08-15 09:54:52',NULL,'2026-08-15 09:51:28','2026-08-15 09:54:52'),(18,'App\\Models\\User',8,'guest_token','e7da2112470f42c28ca7553d1740a5a98dfc964a8f3d16136933178b16684a19','[\"*\"]','2026-08-23 09:30:59',NULL,'2026-08-23 04:07:41','2026-08-23 09:30:59'),(20,'App\\Models\\User',9,'guest_token','a59f09d22e2997c618f47b17c75c0ef4cf2bfd7325e0d7ce167254df68b9c103','[\"*\"]','2026-08-23 11:17:18',NULL,'2026-08-23 10:37:59','2026-08-23 11:17:18'),(21,'App\\Models\\User',10,'guest_token','1927b25c9b93299f5544ebacd39a0ec8539360da562702dc2227296cb7a1bdee','[\"*\"]','2026-08-23 11:26:03',NULL,'2026-08-23 11:25:57','2026-08-23 11:26:03'),(22,'App\\Models\\User',11,'guest_token','ada0df020fb91321b5993159fe18bc1d475104e8f5ef4c4a354d8e2a8dbc3df1','[\"*\"]','2026-08-26 10:14:37',NULL,'2026-08-26 10:14:22','2026-08-26 10:14:37'),(23,'App\\Models\\User',12,'guest_token','ddd4bc3c3f9b8ae4a9078e1f0539940a2e66d89e096c9cf76fa5c34a7a97a711','[\"*\"]','2026-08-28 03:06:50',NULL,'2026-08-28 03:04:58','2026-08-28 03:06:50'),(24,'App\\Models\\User',13,'guest_token','fde324c8530d2de77aadbf6f0b632656fa8370541d4b03b93028ea06102198fd','[\"*\"]','2026-08-29 00:29:35',NULL,'2026-08-28 12:37:20','2026-08-29 00:29:35'),(25,'App\\Models\\User',14,'guest_token','d428c5081ec339b0754f25b65f04f547995ed119aa5aefdf78474ba057dba2cc','[\"*\"]','2026-08-29 00:59:38',NULL,'2026-08-29 00:59:31','2026-08-29 00:59:38'),(26,'App\\Models\\User',15,'guest_token','293bcc83b857493200db9ff2d75bd8b5b4d9bb5833a0d3caf1103b17b6ec9508','[\"*\"]','2026-08-29 02:15:29',NULL,'2026-08-29 01:35:04','2026-08-29 02:15:29'),(27,'App\\Models\\User',16,'guest_token','290ac1d7c8051dfd14ede5322702920fb835c57642935544de09bafd1618f05c','[\"*\"]','2026-08-29 04:22:32',NULL,'2026-08-29 02:50:57','2026-08-29 04:22:32'),(28,'App\\Models\\User',17,'guest_token','ddb2935e2564c432132dc6cee59f1d01b2d53fc12ed256749f4ad67aa75778c8','[\"*\"]','2026-08-29 05:05:44',NULL,'2026-08-29 05:05:38','2026-08-29 05:05:44'),(29,'App\\Models\\User',18,'guest_token','8b01327f2b6196131ddf2aaeb319aa9fde560857e4bd6ab835ad3aab945c9aa6','[\"*\"]','2026-08-29 05:25:12',NULL,'2026-08-29 05:25:07','2026-08-29 05:25:12'),(30,'App\\Models\\User',19,'guest_token','093921a11671fdf01f3ca8b5e95f56ce2987b62f33ee7b65b5ab100d9c5840fc','[\"*\"]','2026-08-29 05:40:35',NULL,'2026-08-29 05:40:31','2026-08-29 05:40:35'),(31,'App\\Models\\User',20,'guest_token','fd995c197a6d93782f12a9f8353020f726a2d532e19c0120dece53b216b7f034','[\"*\"]','2026-08-29 06:26:20',NULL,'2026-08-29 06:26:08','2026-08-29 06:26:20'),(32,'App\\Models\\User',21,'guest_token','e21cc5610c3188748dddf6ccc0ce7af0371a67c1cd7d16546b1c7bf7f5c4bc06','[\"*\"]','2026-08-29 06:38:38',NULL,'2026-08-29 06:38:33','2026-08-29 06:38:38'),(33,'App\\Models\\User',22,'guest_token','b8579be140458bf044138ffe55cea2670edc3ec556c910308a872268b2253cd3','[\"*\"]','2026-08-29 08:00:16',NULL,'2026-08-29 06:54:20','2026-08-29 08:00:16'),(34,'App\\Models\\User',23,'guest_token','d8f8abdde3495bfacaf5dc2fd4ba875ec88e4dbff9c2bc92cfe2f30195ed9a54','[\"*\"]','2026-08-29 09:37:58',NULL,'2026-08-29 09:32:41','2026-08-29 09:37:58'),(35,'App\\Models\\User',24,'guest_token','1e4d97a50024c66c68659d6190304de2ef454ea6c164da08ed763884ba4b2cca','[\"*\"]','2026-08-29 11:10:03',NULL,'2026-08-29 09:42:09','2026-08-29 11:10:03'),(36,'App\\Models\\User',25,'guest_token','2d2c970a0afdc28d32a0415c761f64029c6b2012ccca0a8c5de0a4012c50320b','[\"*\"]',NULL,NULL,'2026-08-30 03:12:51','2026-08-30 03:12:51'),(37,'App\\Models\\User',26,'guest_token','caa9e5bd7d5df37152d364c09f5f24628d9e854e45d73d21f6e0f9461346e7ca','[\"*\"]','2026-08-30 04:24:38',NULL,'2026-08-30 04:09:31','2026-08-30 04:24:38'),(38,'App\\Models\\User',27,'guest_token','801f801d5d24ec4786a6948c74e8d0206880bb481b8b61d035ca40785a182d3b','[\"*\"]','2026-08-30 04:38:29',NULL,'2026-08-30 04:28:10','2026-08-30 04:38:29'),(39,'App\\Models\\User',28,'guest_token','f8980104583595036dbc9c8c5ba370cf8148f5d5223977c926c31f9dd52752e6','[\"*\"]','2026-08-30 04:56:42',NULL,'2026-08-30 04:56:34','2026-08-30 04:56:42'),(40,'App\\Models\\User',29,'guest_token','06b6ed611f979754dc7b0be299c39cdfe887b1eebd479753e30dbfc22e5db2f4','[\"*\"]','2026-08-30 05:35:23',NULL,'2026-08-30 05:35:16','2026-08-30 05:35:23'),(41,'App\\Models\\User',30,'guest_token','14838bd7d5d1a00927551d6f988987f642c764ced230b5b262152b3a9abd6d51','[\"*\"]','2026-08-30 06:31:13',NULL,'2026-08-30 06:13:57','2026-08-30 06:31:13'),(42,'App\\Models\\User',31,'guest_token','7f6ea3f44b82de10da2504411280a2fb721059d3804ee8a9c9fbee04b0dc344c','[\"*\"]','2026-08-30 07:12:24',NULL,'2026-08-30 07:11:57','2026-08-30 07:12:24'),(43,'App\\Models\\User',32,'guest_token','4511c6d0ccbaea698dcc102b02b7ce3c8fae14ffc3618b00afebf03dfefe3c8f','[\"*\"]','2026-08-30 08:58:01',NULL,'2026-08-30 08:52:47','2026-08-30 08:58:01'),(44,'App\\Models\\User',33,'guest_token','73d16a230ad1c779b019e35d11c8540b8bc6df71ca778e80dc3f5b64b9a10d7a','[\"*\"]','2026-08-30 11:04:26',NULL,'2026-08-30 10:30:54','2026-08-30 11:04:26'),(45,'App\\Models\\User',34,'guest_token','f41262aa67f08455065e4e3a77b41aa6648675f21cb56e5e4f3a0c81b3689a5f','[\"*\"]','2026-09-06 02:27:17',NULL,'2026-09-06 02:27:01','2026-09-06 02:27:17'),(46,'App\\Models\\User',35,'guest_token','fe848c3e1737ce30e349fd22fda1a45f02e05c99955ce3948a834ad5df8aef85','[\"*\"]','2026-09-06 02:27:22',NULL,'2026-09-06 02:27:03','2026-09-06 02:27:22'),(51,'App\\Models\\User',36,'guest_token','2eacda62dbbe2fd0c6c8becfd7392cac32f41efba8bc6aaf5009bebdd0099d0b','[\"*\"]','2026-09-06 03:28:15',NULL,'2026-09-06 03:28:02','2026-09-06 03:28:15'),(52,'App\\Models\\User',37,'guest_token','aa167233872458fa9669778932242622da8a05169a19e5640785ba2fbb0ebc5e','[\"*\"]','2026-09-06 03:28:19',NULL,'2026-09-06 03:28:05','2026-09-06 03:28:19'),(53,'App\\Models\\User',38,'guest_token','3e66648e406783f2774b7bb334764f16e4150fab0127b0e27cb1bbbbfbaf837e','[\"*\"]','2026-09-06 03:32:24',NULL,'2026-09-06 03:32:17','2026-09-06 03:32:24'),(55,'App\\Models\\User',40,'guest_token','ac869dd07e5c77eeee28cff027b847d057e10b43b0d1fcdbfcf87993970022a0','[\"*\"]','2026-09-06 04:30:13',NULL,'2026-09-06 04:21:36','2026-09-06 04:30:13'),(56,'App\\Models\\User',39,'guest_token','17b50523e5186830436a402297475742b12542d52d12e54753ff3322ef147c03','[\"*\"]','2026-09-06 04:30:41',NULL,'2026-09-06 04:29:09','2026-09-06 04:30:41'),(57,'App\\Models\\User',41,'guest_token','85436ab492a700ffaee3fcdaf010369ec274150aecfe8f1e10edeac54f2a5473','[\"*\"]','2026-09-12 05:55:14',NULL,'2026-09-12 05:55:09','2026-09-12 05:55:14'),(59,'App\\Models\\User',42,'guest_token','baff5b70eac26223c28f70f456a8e619066a2650455fd514d8072910c93096e8','[\"*\"]','2026-09-13 02:13:38',NULL,'2026-09-13 02:11:36','2026-09-13 02:13:38'),(60,'App\\Models\\User',43,'guest_token','6c795f333a27922f935e6af33be98f883162e82913f202d4b2ef31fe462f3414','[\"*\"]','2026-09-19 02:51:21',NULL,'2026-09-19 02:42:55','2026-09-19 02:51:21'),(61,'App\\Models\\User',44,'guest_token','0bbb5a214e48932f97c160a86ed9c96525ceb316824c79e0185742316dcd729d','[\"*\"]','2026-09-19 03:57:19',NULL,'2026-09-19 03:37:27','2026-09-19 03:57:19'),(62,'App\\Models\\User',45,'guest_token','efdcb5e6114f139c2af57e3c8ee37c1c6319f9c1f24acf5f80481b060a315ede','[\"*\"]','2026-09-24 14:06:06',NULL,'2026-09-24 14:02:59','2026-09-24 14:06:06');
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `room_players`
--

DROP TABLE IF EXISTS `room_players`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `room_players` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `room_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `seat_position` tinyint NOT NULL,
  `color` enum('red','green','yellow','blue') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_ready` tinyint(1) DEFAULT '0',
  `joined_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_room_color` (`room_id`,`color`),
  UNIQUE KEY `unique_room_seat` (`room_id`,`seat_position`),
  KEY `room_players_user_id_index` (`user_id`),
  CONSTRAINT `room_players_ibfk_1` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE CASCADE,
  CONSTRAINT `room_players_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `room_players`
--

LOCK TABLES `room_players` WRITE;
/*!40000 ALTER TABLE `room_players` DISABLE KEYS */;
INSERT INTO `room_players` VALUES (1,1,36,1,'red',1,'2026-09-06 03:14:03'),(2,1,37,2,'yellow',1,'2026-09-06 03:14:03');
/*!40000 ALTER TABLE `room_players` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rooms`
--

DROP TABLE IF EXISTS `rooms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rooms` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `room_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('public','private') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'public',
  `max_players` tinyint DEFAULT '4',
  `entry_fee` bigint DEFAULT '0',
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'waiting',
  `created_by` bigint unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `room_code` (`room_code`),
  KEY `rooms_created_by_index` (`created_by`),
  CONSTRAINT `rooms_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rooms`
--

LOCK TABLES `rooms` WRITE;
/*!40000 ALTER TABLE `rooms` DISABLE KEYS */;
INSERT INTO `rooms` VALUES (1,'FKGZXU','public',2,500,'playing',36,'2026-09-06 03:14:02','2026-09-06 08:14:02');
/*!40000 ALTER TABLE `rooms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `store_items`
--

DROP TABLE IF EXISTS `store_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `store_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('avatar','dice_skin','board_theme') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `price` bigint NOT NULL,
  `currency_type` enum('coins','diamonds') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `store_items`
--

LOCK TABLES `store_items` WRITE;
/*!40000 ALTER TABLE `store_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `store_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tournament_levels`
--

DROP TABLE IF EXISTS `tournament_levels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tournament_levels` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tournament_id` bigint unsigned NOT NULL,
  `level` tinyint unsigned NOT NULL,
  `reward_coins` bigint NOT NULL DEFAULT '0',
  `reward_diamonds` bigint NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `tournament_levels_tournament_id_foreign` (`tournament_id`),
  CONSTRAINT `tournament_levels_tournament_id_foreign` FOREIGN KEY (`tournament_id`) REFERENCES `tournaments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tournament_levels`
--

LOCK TABLES `tournament_levels` WRITE;
/*!40000 ALTER TABLE `tournament_levels` DISABLE KEYS */;
/*!40000 ALTER TABLE `tournament_levels` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tournament_matches`
--

DROP TABLE IF EXISTS `tournament_matches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tournament_matches` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tournament_id` bigint unsigned NOT NULL,
  `level` tinyint unsigned NOT NULL,
  `room_id` bigint unsigned NOT NULL,
  `player1_id` bigint unsigned NOT NULL,
  `player2_id` bigint unsigned NOT NULL,
  `winner_id` bigint unsigned DEFAULT NULL,
  `status` enum('waiting','in_progress','completed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'waiting',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `tournament_matches_tournament_id_foreign` (`tournament_id`),
  KEY `tournament_matches_room_id_foreign` (`room_id`),
  KEY `tournament_matches_player1_id_foreign` (`player1_id`),
  KEY `tournament_matches_player2_id_foreign` (`player2_id`),
  KEY `tournament_matches_winner_id_foreign` (`winner_id`),
  CONSTRAINT `tournament_matches_player1_id_foreign` FOREIGN KEY (`player1_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `tournament_matches_player2_id_foreign` FOREIGN KEY (`player2_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `tournament_matches_room_id_foreign` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE CASCADE,
  CONSTRAINT `tournament_matches_tournament_id_foreign` FOREIGN KEY (`tournament_id`) REFERENCES `tournaments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `tournament_matches_winner_id_foreign` FOREIGN KEY (`winner_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tournament_matches`
--

LOCK TABLES `tournament_matches` WRITE;
/*!40000 ALTER TABLE `tournament_matches` DISABLE KEYS */;
/*!40000 ALTER TABLE `tournament_matches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tournament_participants`
--

DROP TABLE IF EXISTS `tournament_participants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tournament_participants` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tournament_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `current_level` tinyint unsigned NOT NULL DEFAULT '1',
  `highest_level_reached` tinyint unsigned NOT NULL DEFAULT '1',
  `status` enum('active','completed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `joined_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tournament_participants_tournament_id_user_id_unique` (`tournament_id`,`user_id`),
  KEY `tournament_participants_user_id_foreign` (`user_id`),
  CONSTRAINT `tournament_participants_tournament_id_foreign` FOREIGN KEY (`tournament_id`) REFERENCES `tournaments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `tournament_participants_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tournament_participants`
--

LOCK TABLES `tournament_participants` WRITE;
/*!40000 ALTER TABLE `tournament_participants` DISABLE KEYS */;
/*!40000 ALTER TABLE `tournament_participants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tournaments`
--

DROP TABLE IF EXISTS `tournaments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tournaments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mode` enum('classic','quick') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'classic',
  `entry_fee` bigint NOT NULL,
  `currency_type` enum('coins','diamonds') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'coins',
  `prize_pool` bigint NOT NULL DEFAULT '0',
  `max_level` tinyint unsigned NOT NULL DEFAULT '6',
  `status` enum('active','closed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tournaments`
--

LOCK TABLES `tournaments` WRITE;
/*!40000 ALTER TABLE `tournaments` DISABLE KEYS */;
/*!40000 ALTER TABLE `tournaments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transactions`
--

DROP TABLE IF EXISTS `transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transactions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `type` enum('win','loss','purchase','topup','gift','entry_fee') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `currency_type` enum('coins','diamonds') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` bigint NOT NULL,
  `reference_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `transactions_user_id_index` (`user_id`),
  CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transactions`
--

LOCK TABLES `transactions` WRITE;
/*!40000 ALTER TABLE `transactions` DISABLE KEYS */;
INSERT INTO `transactions` VALUES (1,36,'entry_fee','coins',-500,'1','2026-09-06 03:14:02'),(2,37,'entry_fee','coins',-500,'1','2026-09-06 03:14:03');
/*!40000 ALTER TABLE `transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_inventory`
--

DROP TABLE IF EXISTS `user_inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_inventory` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `item_id` bigint unsigned NOT NULL,
  `is_equipped` tinyint(1) DEFAULT '0',
  `purchased_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_item` (`user_id`,`item_id`),
  KEY `user_inventory_item_id_index` (`item_id`),
  CONSTRAINT `user_inventory_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_inventory_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `store_items` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_inventory`
--

LOCK TABLES `user_inventory` WRITE;
/*!40000 ALTER TABLE `user_inventory` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `device_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `google_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `auth_provider` enum('guest','email','google') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'email',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `remember_token` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gender` enum('male','female','unspecified') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'unspecified',
  `dob` date DEFAULT NULL,
  `country` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bio` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name_change_count` tinyint NOT NULL DEFAULT '0',
  `name_change_reset_at` timestamp NULL DEFAULT NULL,
  `league_points` int NOT NULL DEFAULT '0',
  `rank` int DEFAULT NULL,
  `country_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `level` int DEFAULT '1',
  `xp` int DEFAULT '0',
  `is_guest` tinyint(1) DEFAULT '0',
  `metadata` json DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `device_id` (`device_id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `phone` (`phone`),
  UNIQUE KEY `users_google_id_unique` (`google_id`)
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'1ef2625a7070a5bd99c3bda2554f8f36','Guest8348',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-08-10 10:13:43','2026-08-10 10:13:43'),(2,'test-device-flutter-001','Guest9931',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-08-10 10:31:35','2026-08-10 10:31:35'),(3,'e979e23fafc430b1a664b1e41158017e','Guest6827',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,1,1,NULL,1,0,1,NULL,1,'2026-08-10 10:38:16','2026-08-10 15:42:28'),(4,NULL,'newuser99','newuser99@test.com',NULL,'email',NULL,'$2y$12$1B9W/ufNxoHH79jN.cTcQuRnVE5mdb2UpdXmtPge/Btj0pq3wYgaS',NULL,NULL,'unspecified',NULL,'PK',NULL,0,NULL,0,NULL,'+92',1,0,0,NULL,1,'2026-08-10 10:53:38','2026-08-10 10:53:38'),(5,'476b88f52db99a47de092e782d355729','Guest9852',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-08-15 03:19:42','2026-08-15 03:19:42'),(6,'ff633c63f643102d42383aabe82e09ac','Guest1433',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-08-15 09:07:12','2026-08-15 09:07:12'),(7,'ed28ec79fb46459d8ee4668f3d4e79a3','Guest5101',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-08-15 09:44:00','2026-08-15 09:44:00'),(8,'b5254e5348dfe3ea0c9ca4e0dfdacf87','Guest3055',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-08-23 04:07:40','2026-08-23 04:07:40'),(9,'7fba533811e88eb46dd61687a9961711','Guest8126',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-08-23 10:37:56','2026-08-23 10:37:56'),(10,'cb2d510232072ec3c60124ca994e4ad7','Guest1099',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-08-23 11:25:57','2026-08-23 11:25:57'),(11,'79370bc7f8242fc8be2b88ae146daf7e','Guest9234',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-08-26 10:14:19','2026-08-26 10:14:19'),(12,'4e40ca6ad105baddfedd524736bb4418','Guest2328',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-08-28 03:04:55','2026-08-28 03:04:55'),(13,'56228e1b0d2f7dd5dbe2a0f557f57533','Guest7982',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-08-28 12:37:16','2026-08-28 12:37:16'),(14,'e168447edd088954886c4bfbb168d907','Guest5176',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-08-29 00:59:31','2026-08-29 00:59:31'),(15,'b06af4ca1a8be89f05e97f9a0992322f','Guest4303',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-08-29 01:35:04','2026-08-29 01:35:04'),(16,'4422bae99b1fab926ee4423b97d2fdc3','Guest8581',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-08-29 02:50:57','2026-08-29 02:50:57'),(17,'86b2478e478fd0a46991629126f6c1ad','Guest5899',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-08-29 05:05:38','2026-08-29 05:05:38'),(18,'dfc303b72a3e4546ea326ced6c953d82','Guest6308',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-08-29 05:25:07','2026-08-29 05:25:07'),(19,'37dd2c01535e80431f3a2804a783d171','Guest1963',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-08-29 05:40:31','2026-08-29 05:40:31'),(20,'0a3a08257948c63f30bcfc5482b97c0f','Guest5423',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-08-29 06:26:06','2026-08-29 06:26:06'),(21,'25bb7085d855c78124c48764badf8959','Guest7620',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-08-29 06:38:33','2026-08-29 06:38:33'),(22,'d3792693e3fa1ab073b8f08f494d76b1','Guest7775',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-08-29 06:54:18','2026-08-29 06:54:18'),(23,'7bb8e3308d4363cbc07bb57f55305e9f','Guest1567',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-08-29 09:32:41','2026-08-29 09:32:41'),(24,'84e95151c0e56ef25a9c2cffc170a036','Guest5217',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-08-29 09:42:09','2026-08-29 09:42:09'),(25,'6bcbf86f8cd0d624e16167f4d5c837dc','Guest7172',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-08-30 03:12:45','2026-08-30 03:12:45'),(26,'04256c16bd0d7dfb91c30f5015b942f7','Guest9671',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-08-30 04:09:28','2026-08-30 04:09:28'),(27,'f6c712ceee45ba3c97763104dc8ba524','Guest1922',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-08-30 04:28:10','2026-08-30 04:28:10'),(28,'f02923aec2b8b8fc0df115c0cba2991d','Guest2476',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-08-30 04:56:34','2026-08-30 04:56:34'),(29,'96bdee6d0a0d385ce4d29e91854baf0e','Guest1992',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-08-30 05:35:15','2026-08-30 05:35:15'),(30,'ebed086fbbc79d11abe59d0f598e40b9','Guest9143',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-08-30 06:13:56','2026-08-30 06:13:56'),(31,'26166805176f68b9b5d00918673fd990','Guest7543',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-08-30 07:11:57','2026-08-30 07:11:57'),(32,'7829a2526e29d46722f12ba93ad0b9ef','Guest9938',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-08-30 08:52:43','2026-08-30 08:52:43'),(33,'0a0b69c49e1de83d073eaf99a1614090','Guest9939',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-08-30 10:30:52','2026-08-30 10:30:52'),(34,'671dc7b3c3bd5329538459eef0bab443','Guest9940',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-09-06 02:26:59','2026-09-06 02:26:59'),(35,'7284dfb254796474a0229d550ee509c8','Guest9941',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-09-06 02:27:03','2026-09-06 02:27:03'),(36,'52d58c90dde195f85085926007885276','Guest9942',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-09-06 03:11:02','2026-09-06 03:11:02'),(37,'cdfd5d726efdec70500ec50d9d17d3df','Guest9943',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-09-06 03:11:47','2026-09-06 03:11:47'),(38,'faefabc3c52f0ad30acaaebd1ca34bfb','Guest9944',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-09-06 03:32:16','2026-09-06 03:32:16'),(39,'c609f1f99aa4d17ccff8686719a042c3','Guest9945',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-09-06 04:18:12','2026-09-06 04:18:12'),(40,'ec5810ad1046b5cbbbb3d9f741fd74a9','Guest9946',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-09-06 04:21:35','2026-09-06 04:21:35'),(41,'2294951e0435b89cca0daf83dad10ff6','Guest9947',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-09-12 05:55:08','2026-09-12 05:55:08'),(42,'b88b4bc9c89f75f85fa0872dc7ecffca','Guest9948',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-09-13 02:11:17','2026-09-13 02:11:17'),(43,'e595682cfe9e8b88b948359cc26eba07','Guest9949',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-09-19 02:42:54','2026-09-19 02:42:54'),(44,'72c45eb04f6253ed26167d0140e27d22','Guest9950',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-09-19 03:37:27','2026-09-19 03:37:27'),(45,'f8fec35b7391acc45f5f58e63fa921fb','Guest9951',NULL,NULL,'email',NULL,NULL,NULL,NULL,'unspecified',NULL,NULL,NULL,0,NULL,0,NULL,NULL,1,0,1,NULL,1,'2026-09-24 14:02:57','2026-09-24 14:02:57');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wallets`
--

DROP TABLE IF EXISTS `wallets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wallets` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `coins_balance` bigint DEFAULT '0',
  `diamonds_balance` bigint DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `wallets_user_id_index` (`user_id`),
  CONSTRAINT `wallets_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wallets`
--

LOCK TABLES `wallets` WRITE;
/*!40000 ALTER TABLE `wallets` DISABLE KEYS */;
INSERT INTO `wallets` VALUES (1,1,500,10,'2026-08-10 10:13:43','2026-08-10 10:13:43'),(2,2,500,10,'2026-08-10 10:31:35','2026-08-10 10:31:35'),(3,3,500,10,'2026-08-10 10:38:16','2026-08-10 10:38:16'),(4,4,1000,10,'2026-08-10 10:53:38','2026-08-10 10:53:38'),(5,5,500,10,'2026-08-15 03:19:43','2026-08-15 03:19:43'),(6,6,500,10,'2026-08-15 09:07:12','2026-08-15 09:07:12'),(7,7,500,10,'2026-08-15 09:44:00','2026-08-15 09:44:00'),(8,8,500,10,'2026-08-23 04:07:40','2026-08-23 04:07:40'),(9,9,500,10,'2026-08-23 10:37:56','2026-08-23 10:37:56'),(10,10,500,10,'2026-08-23 11:25:57','2026-08-23 11:25:57'),(11,11,500,10,'2026-08-26 10:14:19','2026-08-26 10:14:19'),(12,12,500,10,'2026-08-28 03:04:56','2026-08-28 03:04:56'),(13,13,500,10,'2026-08-28 12:37:17','2026-08-28 12:37:17'),(14,14,500,10,'2026-08-29 00:59:31','2026-08-29 00:59:31'),(15,15,500,10,'2026-08-29 01:35:04','2026-08-29 01:35:04'),(16,16,500,10,'2026-08-29 02:50:57','2026-08-29 02:50:57'),(17,17,500,10,'2026-08-29 05:05:38','2026-08-29 05:05:38'),(18,18,500,10,'2026-08-29 05:25:07','2026-08-29 05:25:07'),(19,19,500,10,'2026-08-29 05:40:31','2026-08-29 05:40:31'),(20,20,500,10,'2026-08-29 06:26:06','2026-08-29 06:26:06'),(21,21,500,10,'2026-08-29 06:38:33','2026-08-29 06:38:33'),(22,22,500,10,'2026-08-29 06:54:18','2026-08-29 06:54:18'),(23,23,500,10,'2026-08-29 09:32:41','2026-08-29 09:32:41'),(24,24,500,10,'2026-08-29 09:42:09','2026-08-29 09:42:09'),(25,25,500,10,'2026-08-30 03:12:45','2026-08-30 03:12:45'),(26,26,500,10,'2026-08-30 04:09:28','2026-08-30 04:09:28'),(27,27,500,10,'2026-08-30 04:28:10','2026-08-30 04:28:10'),(28,28,500,10,'2026-08-30 04:56:34','2026-08-30 04:56:34'),(29,29,500,10,'2026-08-30 05:35:15','2026-08-30 05:35:15'),(30,30,500,10,'2026-08-30 06:13:56','2026-08-30 06:13:56'),(31,31,500,10,'2026-08-30 07:11:57','2026-08-30 07:11:57'),(32,32,500,10,'2026-08-30 08:52:43','2026-08-30 08:52:43'),(33,33,500,10,'2026-08-30 10:30:52','2026-08-30 10:30:52'),(34,34,500,10,'2026-09-06 02:26:59','2026-09-06 02:26:59'),(35,35,500,10,'2026-09-06 02:27:03','2026-09-06 02:27:03'),(36,36,0,10,'2026-09-06 03:11:03','2026-09-06 03:14:02'),(37,37,0,10,'2026-09-06 03:11:47','2026-09-06 03:14:03'),(38,38,500,10,'2026-09-06 03:32:16','2026-09-06 03:32:16'),(39,39,500,10,'2026-09-06 04:18:12','2026-09-06 04:18:12'),(40,40,500,10,'2026-09-06 04:21:36','2026-09-06 04:21:36'),(41,41,500,10,'2026-09-12 05:55:08','2026-09-12 05:55:08'),(42,42,500,10,'2026-09-13 02:11:18','2026-09-13 02:11:18'),(43,43,5000,10,'2026-09-19 02:42:54','2026-09-19 07:47:53'),(44,44,500,10,'2026-09-19 03:37:27','2026-09-19 03:37:27'),(45,45,50000,10,'2026-09-24 14:02:57','2026-09-24 19:04:42');
/*!40000 ALTER TABLE `wallets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'ludo'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-25  0:09:19
