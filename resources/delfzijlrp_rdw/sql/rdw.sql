CREATE TABLE IF NOT EXISTS `delfzijlrp_rdw_registry` (
  `plate` varchar(16) NOT NULL,
  `old_plate` varchar(16) DEFAULT NULL,
  `owner` varchar(64) NOT NULL,
  `owner_name` varchar(128) DEFAULT NULL,
  `vin` varchar(32) DEFAULT NULL,
  `model` varchar(64) DEFAULT NULL,
  `vehicle_props` longtext DEFAULT NULL,
  `apk_until` datetime DEFAULT NULL,
  `insurance_type` varchar(32) DEFAULT 'none',
  `insurance_until` datetime DEFAULT NULL,
  `status` varchar(32) NOT NULL DEFAULT 'active',
  `stolen` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`plate`),
  KEY `owner` (`owner`),
  KEY `status` (`status`),
  KEY `stolen` (`stolen`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_rdw_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `plate` varchar(16) NOT NULL,
  `actor_identifier` varchar(64) DEFAULT NULL,
  `action` varchar(64) NOT NULL,
  `details` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `plate` (`plate`),
  KEY `actor_identifier` (`actor_identifier`),
  KEY `action` (`action`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_rdw_customplates` (
  `plate` varchar(16) NOT NULL,
  `owner` varchar(64) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`plate`),
  KEY `owner` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
