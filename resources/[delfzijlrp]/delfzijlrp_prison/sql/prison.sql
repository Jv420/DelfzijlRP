CREATE TABLE IF NOT EXISTS `delfzijlrp_prison_sentences` (
  `id` int NOT NULL AUTO_INCREMENT,
  `identifier` varchar(64) NOT NULL,
  `player_name` varchar(128) DEFAULT NULL,
  `issuer_identifier` varchar(64) DEFAULT NULL,
  `issuer_name` varchar(128) DEFAULT NULL,
  `reason` varchar(255) NOT NULL,
  `minutes_total` int NOT NULL DEFAULT 0,
  `minutes_remaining` int NOT NULL DEFAULT 0,
  `status` varchar(32) NOT NULL DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `released_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `identifier` (`identifier`),
  KEY `issuer_identifier` (`issuer_identifier`),
  KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_prison_tasks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `sentence_id` int NOT NULL,
  `identifier` varchar(64) NOT NULL,
  `task_id` varchar(64) NOT NULL,
  `minutes_reduced` int NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `sentence_id` (`sentence_id`),
  KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_prison_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `sentence_id` int DEFAULT NULL,
  `actor_identifier` varchar(64) DEFAULT NULL,
  `action` varchar(64) NOT NULL,
  `details` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `sentence_id` (`sentence_id`),
  KEY `actor_identifier` (`actor_identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
