CREATE TABLE IF NOT EXISTS `delfzijlrp_fire_duty` (
  `identifier` varchar(64) NOT NULL,
  `on_duty` tinyint(1) NOT NULL DEFAULT 0,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_fire_incidents` (
  `id` int NOT NULL AUTO_INCREMENT,
  `identifier` varchar(64) NOT NULL,
  `incident_type` varchar(64) NOT NULL,
  `location_id` varchar(96) NOT NULL,
  `status` varchar(32) NOT NULL DEFAULT 'active',
  `payout` int NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `completed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `identifier` (`identifier`),
  KEY `incident_type` (`incident_type`),
  KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_fire_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `incident_id` int DEFAULT NULL,
  `identifier` varchar(64) DEFAULT NULL,
  `action` varchar(64) NOT NULL,
  `details` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `incident_id` (`incident_id`),
  KEY `identifier` (`identifier`),
  KEY `action` (`action`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
