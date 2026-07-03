CREATE TABLE IF NOT EXISTS `delfzijlrp_mdt_notes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `target_identifier` varchar(64) DEFAULT NULL,
  `target_plate` varchar(16) DEFAULT NULL,
  `author_identifier` varchar(64) DEFAULT NULL,
  `author_name` varchar(128) DEFAULT NULL,
  `note_type` varchar(64) NOT NULL DEFAULT 'note',
  `note` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `target_identifier` (`target_identifier`),
  KEY `target_plate` (`target_plate`),
  KEY `author_identifier` (`author_identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_mdt_fines` (
  `id` int NOT NULL AUTO_INCREMENT,
  `target_identifier` varchar(64) NOT NULL,
  `target_name` varchar(128) DEFAULT NULL,
  `issuer_identifier` varchar(64) DEFAULT NULL,
  `issuer_name` varchar(128) DEFAULT NULL,
  `category` varchar(64) NOT NULL DEFAULT 'other',
  `reason` varchar(255) NOT NULL,
  `amount` int NOT NULL DEFAULT 0,
  `status` varchar(32) NOT NULL DEFAULT 'open',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `target_identifier` (`target_identifier`),
  KEY `issuer_identifier` (`issuer_identifier`),
  KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_mdt_audit` (
  `id` int NOT NULL AUTO_INCREMENT,
  `identifier` varchar(64) DEFAULT NULL,
  `player_name` varchar(128) DEFAULT NULL,
  `action` varchar(64) NOT NULL,
  `query` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `identifier` (`identifier`),
  KEY `action` (`action`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
