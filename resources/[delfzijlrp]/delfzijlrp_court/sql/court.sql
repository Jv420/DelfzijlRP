CREATE TABLE IF NOT EXISTS `delfzijlrp_court_cases` (
  `id` int NOT NULL AUTO_INCREMENT,
  `case_number` varchar(64) NOT NULL,
  `case_type` varchar(32) NOT NULL DEFAULT 'other',
  `title` varchar(128) NOT NULL,
  `description` text DEFAULT NULL,
  `suspect_identifier` varchar(64) DEFAULT NULL,
  `suspect_name` varchar(128) DEFAULT NULL,
  `created_by` varchar(64) DEFAULT NULL,
  `status` varchar(32) NOT NULL DEFAULT 'open',
  `verdict` text DEFAULT NULL,
  `fine_amount` int NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `case_number` (`case_number`),
  KEY `suspect_identifier` (`suspect_identifier`),
  KEY `status` (`status`),
  KEY `case_type` (`case_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_court_hearings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `case_id` int NOT NULL,
  `scheduled_at` datetime NOT NULL,
  `duration_minutes` int NOT NULL DEFAULT 30,
  `location` varchar(128) DEFAULT 'Rechtbank Delfzijl',
  `notes` text DEFAULT NULL,
  `created_by` varchar(64) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `case_id` (`case_id`),
  KEY `scheduled_at` (`scheduled_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_court_notes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `case_id` int NOT NULL,
  `author_identifier` varchar(64) DEFAULT NULL,
  `author_name` varchar(128) DEFAULT NULL,
  `note` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `case_id` (`case_id`),
  KEY `author_identifier` (`author_identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
