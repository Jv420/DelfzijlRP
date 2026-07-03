CREATE TABLE IF NOT EXISTS `delfzijlrp_vehicle_registry` (
  `plate` varchar(12) NOT NULL,
  `owner` varchar(64) NOT NULL,
  `vin` varchar(32) NOT NULL,
  `model` varchar(64) DEFAULT NULL,
  `brand` varchar(64) DEFAULT NULL,
  `color` varchar(64) DEFAULT NULL,
  `mileage` int NOT NULL DEFAULT 0,
  `apk_until` datetime DEFAULT NULL,
  `insurance_until` datetime DEFAULT NULL,
  `insurance_type` varchar(32) DEFAULT 'WA',
  `stolen` tinyint(1) NOT NULL DEFAULT 0,
  `impounded` tinyint(1) NOT NULL DEFAULT 0,
  `damage_history` longtext DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`plate`),
  UNIQUE KEY `vin` (`vin`),
  KEY `owner` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_vehicle_keys` (
  `id` int NOT NULL AUTO_INCREMENT,
  `plate` varchar(12) NOT NULL,
  `identifier` varchar(64) NOT NULL,
  `key_type` varchar(32) NOT NULL DEFAULT 'personal',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `plate_identifier` (`plate`, `identifier`),
  KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
