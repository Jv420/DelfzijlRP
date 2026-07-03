CREATE TABLE IF NOT EXISTS `delfzijlrp_bank_accounts` (
  `identifier` varchar(64) NOT NULL,
  `iban` varchar(34) NOT NULL,
  `account_name` varchar(128) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`identifier`),
  UNIQUE KEY `iban` (`iban`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_bank_transactions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `identifier` varchar(64) NOT NULL,
  `iban` varchar(34) DEFAULT NULL,
  `type` varchar(32) NOT NULL,
  `amount` int NOT NULL DEFAULT 0,
  `counterparty_iban` varchar(34) DEFAULT NULL,
  `counterparty_name` varchar(128) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `identifier` (`identifier`),
  KEY `iban` (`iban`),
  KEY `type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
