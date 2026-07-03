CREATE TABLE IF NOT EXISTS `delfzijlrp_businesses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(96) NOT NULL,
  `slug` varchar(96) NOT NULL,
  `business_type` varchar(32) NOT NULL DEFAULT 'other',
  `owner_identifier` varchar(64) NOT NULL,
  `balance` int NOT NULL DEFAULT 0,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`),
  KEY `owner_identifier` (`owner_identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_business_employees` (
  `id` int NOT NULL AUTO_INCREMENT,
  `business_id` int NOT NULL,
  `identifier` varchar(64) NOT NULL,
  `rank` varchar(32) NOT NULL DEFAULT 'employee',
  `salary` int NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `business_employee` (`business_id`, `identifier`),
  KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_business_invoices` (
  `id` int NOT NULL AUTO_INCREMENT,
  `business_id` int NOT NULL,
  `issuer_identifier` varchar(64) NOT NULL,
  `target_identifier` varchar(64) DEFAULT NULL,
  `target_name` varchar(128) DEFAULT NULL,
  `reason` varchar(255) NOT NULL,
  `amount` int NOT NULL DEFAULT 0,
  `paid` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `paid_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `business_id` (`business_id`),
  KEY `target_identifier` (`target_identifier`),
  KEY `paid` (`paid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
