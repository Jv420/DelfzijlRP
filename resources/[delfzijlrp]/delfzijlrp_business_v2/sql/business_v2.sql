CREATE TABLE IF NOT EXISTS `delfzijlrp_businesses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `kvk_number` varchar(32) NOT NULL,
  `name` varchar(128) NOT NULL,
  `business_type` varchar(32) NOT NULL DEFAULT 'other',
  `owner_identifier` varchar(64) NOT NULL,
  `balance` int NOT NULL DEFAULT 0,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `kvk_number` (`kvk_number`),
  KEY `owner_identifier` (`owner_identifier`),
  KEY `business_type` (`business_type`)
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
  `target_identifier` varchar(64) DEFAULT NULL,
  `target_name` varchar(128) DEFAULT NULL,
  `amount` int NOT NULL DEFAULT 0,
  `description` varchar(255) NOT NULL,
  `status` varchar(32) NOT NULL DEFAULT 'open',
  `due_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `business_id` (`business_id`),
  KEY `target_identifier` (`target_identifier`),
  KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_business_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `business_id` int NOT NULL,
  `actor_identifier` varchar(64) DEFAULT NULL,
  `action` varchar(64) NOT NULL,
  `details` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `business_id` (`business_id`),
  KEY `actor_identifier` (`actor_identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
