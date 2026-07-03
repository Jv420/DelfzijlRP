CREATE TABLE IF NOT EXISTS `delfzijlrp_bus_tickets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `identifier` varchar(64) NOT NULL,
  `ticket_type` varchar(32) NOT NULL DEFAULT 'single',
  `expires_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `identifier` (`identifier`),
  KEY `ticket_type` (`ticket_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_bus_rides` (
  `id` int NOT NULL AUTO_INCREMENT,
  `driver_identifier` varchar(64) NOT NULL,
  `driver_name` varchar(128) DEFAULT NULL,
  `route_id` varchar(64) NOT NULL,
  `status` varchar(32) NOT NULL DEFAULT 'active',
  `stops_done` int NOT NULL DEFAULT 0,
  `payout` int NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `completed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `driver_identifier` (`driver_identifier`),
  KEY `route_id` (`route_id`),
  KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_bus_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `identifier` varchar(64) DEFAULT NULL,
  `action` varchar(64) NOT NULL,
  `details` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `identifier` (`identifier`),
  KEY `action` (`action`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
