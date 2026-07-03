CREATE TABLE IF NOT EXISTS `delfzijlrp_houses` (
  `house_id` varchar(64) NOT NULL,
  `owner_identifier` varchar(64) DEFAULT NULL,
  `owned` tinyint(1) NOT NULL DEFAULT 0,
  `rented` tinyint(1) NOT NULL DEFAULT 0,
  `rent_until` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`house_id`),
  KEY `owner_identifier` (`owner_identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_house_keys` (
  `id` int NOT NULL AUTO_INCREMENT,
  `house_id` varchar(64) NOT NULL,
  `identifier` varchar(64) NOT NULL,
  `key_type` varchar(32) NOT NULL DEFAULT 'shared',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `house_key` (`house_id`, `identifier`),
  KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
