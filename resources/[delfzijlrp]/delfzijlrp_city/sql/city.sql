CREATE TABLE IF NOT EXISTS `delfzijlrp_city_treasury` (
  `id` int NOT NULL DEFAULT 1,
  `balance` int NOT NULL DEFAULT 500000,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `delfzijlrp_city_treasury` (`id`, `balance`) VALUES (1, 500000);

CREATE TABLE IF NOT EXISTS `delfzijlrp_city_permits` (
  `id` int NOT NULL AUTO_INCREMENT,
  `identifier` varchar(64) NOT NULL,
  `person_name` varchar(128) DEFAULT NULL,
  `permit_type` varchar(64) NOT NULL,
  `status` varchar(32) NOT NULL DEFAULT 'pending',
  `reason` varchar(255) DEFAULT NULL,
  `approved_by` varchar(64) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `identifier` (`identifier`),
  KEY `permit_type` (`permit_type`),
  KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_city_reports` (
  `id` int NOT NULL AUTO_INCREMENT,
  `identifier` varchar(64) DEFAULT NULL,
  `person_name` varchar(128) DEFAULT NULL,
  `report_type` varchar(64) NOT NULL,
  `description` varchar(500) NOT NULL,
  `status` varchar(32) NOT NULL DEFAULT 'open',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `identifier` (`identifier`),
  KEY `report_type` (`report_type`),
  KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_city_taxes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `identifier` varchar(64) NOT NULL,
  `person_name` varchar(128) DEFAULT NULL,
  `tax_type` varchar(64) NOT NULL,
  `amount` int NOT NULL DEFAULT 0,
  `description` varchar(255) NOT NULL,
  `status` varchar(32) NOT NULL DEFAULT 'open',
  `due_at` datetime DEFAULT NULL,
  `paid_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `identifier` (`identifier`),
  KEY `tax_type` (`tax_type`),
  KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_city_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `actor_identifier` varchar(64) DEFAULT NULL,
  `action` varchar(64) NOT NULL,
  `amount` int DEFAULT 0,
  `details` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `actor_identifier` (`actor_identifier`),
  KEY `action` (`action`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
