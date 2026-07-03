CREATE TABLE IF NOT EXISTS `delfzijlrp_admin_reports` (
  `id` int NOT NULL AUTO_INCREMENT,
  `identifier` varchar(64) DEFAULT NULL,
  `player_name` varchar(128) DEFAULT NULL,
  `message` varchar(500) NOT NULL,
  `status` varchar(32) NOT NULL DEFAULT 'open',
  `handled_by` varchar(64) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_admin_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `staff_identifier` varchar(64) DEFAULT NULL,
  `staff_name` varchar(128) DEFAULT NULL,
  `action` varchar(64) NOT NULL,
  `target` varchar(128) DEFAULT NULL,
  `details` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `staff_identifier` (`staff_identifier`),
  KEY `action` (`action`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
