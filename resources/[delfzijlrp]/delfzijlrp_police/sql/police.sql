CREATE TABLE IF NOT EXISTS `delfzijlrp_police_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `officer_identifier` varchar(64) DEFAULT NULL,
  `officer_name` varchar(128) DEFAULT NULL,
  `action` varchar(64) NOT NULL,
  `target` varchar(128) DEFAULT NULL,
  `details` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `officer_identifier` (`officer_identifier`),
  KEY `action` (`action`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_police_duty` (
  `identifier` varchar(64) NOT NULL,
  `on_duty` tinyint(1) NOT NULL DEFAULT 0,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
