CREATE TABLE IF NOT EXISTS `delfzijlrp_crimeplus_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `identifier` varchar(64) DEFAULT NULL,
  `incident_type` varchar(64) NOT NULL,
  `location_id` varchar(96) DEFAULT NULL,
  `reward` varchar(255) DEFAULT NULL,
  `coords` longtext DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `identifier` (`identifier`),
  KEY `incident_type` (`incident_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_crimeplus_cooldowns` (
  `location_id` varchar(96) NOT NULL,
  `expires_at` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`location_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
