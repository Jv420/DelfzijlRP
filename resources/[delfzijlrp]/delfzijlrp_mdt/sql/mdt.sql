CREATE TABLE IF NOT EXISTS `delfzijlrp_mdt_notes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `author_identifier` varchar(64) NOT NULL,
  `author_job` varchar(32) NOT NULL,
  `target_type` varchar(32) NOT NULL,
  `target_value` varchar(128) NOT NULL,
  `title` varchar(128) NOT NULL,
  `body` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `target` (`target_type`, `target_value`),
  KEY `author_job` (`author_job`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_mdt_fines` (
  `id` int NOT NULL AUTO_INCREMENT,
  `author_identifier` varchar(64) NOT NULL,
  `target_identifier` varchar(64) DEFAULT NULL,
  `target_name` varchar(128) DEFAULT NULL,
  `fine_type` varchar(32) NOT NULL DEFAULT 'other',
  `reason` varchar(255) NOT NULL,
  `amount` int NOT NULL DEFAULT 0,
  `paid` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `target_identifier` (`target_identifier`),
  KEY `paid` (`paid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
