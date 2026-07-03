CREATE TABLE IF NOT EXISTS `delfzijlrp_marketplace_listings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `seller_identifier` varchar(64) NOT NULL,
  `seller_name` varchar(128) DEFAULT NULL,
  `category` varchar(32) NOT NULL DEFAULT 'other',
  `title` varchar(96) NOT NULL,
  `description` varchar(600) NOT NULL,
  `price` int NOT NULL DEFAULT 0,
  `reference_type` varchar(32) DEFAULT NULL,
  `reference_value` varchar(128) DEFAULT NULL,
  `status` varchar(32) NOT NULL DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `seller_identifier` (`seller_identifier`),
  KEY `category_status` (`category`, `status`),
  KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_marketplace_interest` (
  `id` int NOT NULL AUTO_INCREMENT,
  `listing_id` int NOT NULL,
  `buyer_identifier` varchar(64) NOT NULL,
  `buyer_name` varchar(128) DEFAULT NULL,
  `message` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `listing_id` (`listing_id`),
  KEY `buyer_identifier` (`buyer_identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
