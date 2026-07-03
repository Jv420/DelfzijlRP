CREATE TABLE IF NOT EXISTS `delfzijlrp_kadaster_properties` (
  `property_id` varchar(64) NOT NULL,
  `cadastral` varchar(64) NOT NULL,
  `owner_identifier` varchar(64) DEFAULT NULL,
  `co_owner_identifier` varchar(64) DEFAULT NULL,
  `status` varchar(32) NOT NULL DEFAULT 'available',
  `rented` tinyint(1) NOT NULL DEFAULT 0,
  `rent_until` datetime DEFAULT NULL,
  `purchase_price` int NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`property_id`),
  UNIQUE KEY `cadastral` (`cadastral`),
  KEY `owner_identifier` (`owner_identifier`),
  KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_kadaster_keys` (
  `id` int NOT NULL AUTO_INCREMENT,
  `property_id` varchar(64) NOT NULL,
  `identifier` varchar(64) NOT NULL,
  `key_type` varchar(32) NOT NULL DEFAULT 'shared',
  `expires_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `property_key` (`property_id`, `identifier`),
  KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_kadaster_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `property_id` varchar(64) NOT NULL,
  `actor_identifier` varchar(64) DEFAULT NULL,
  `action` varchar(64) NOT NULL,
  `details` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `property_id` (`property_id`),
  KEY `actor_identifier` (`actor_identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
