CREATE TABLE IF NOT EXISTS `delfzijlrp_anwb_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `mechanic_identifier` varchar(64) DEFAULT NULL,
  `mechanic_name` varchar(128) DEFAULT NULL,
  `plate` varchar(16) DEFAULT NULL,
  `action` varchar(64) NOT NULL,
  `details` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `mechanic_identifier` (`mechanic_identifier`),
  KEY `plate` (`plate`),
  KEY `action` (`action`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_anwb_duty` (
  `identifier` varchar(64) NOT NULL,
  `on_duty` tinyint(1) NOT NULL DEFAULT 0,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
