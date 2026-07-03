CREATE TABLE IF NOT EXISTS `delfzijlrp_identities` (
  `identifier` varchar(64) NOT NULL,
  `delfzijl_id` varchar(32) NOT NULL,
  `firstname` varchar(64) NOT NULL,
  `lastname` varchar(64) NOT NULL,
  `dateofbirth` varchar(16) NOT NULL,
  `sex` varchar(16) NOT NULL,
  `height` int DEFAULT NULL,
  `nationality` varchar(64) DEFAULT 'Nederlands',
  `birthplace` varchar(64) DEFAULT 'Delfzijl',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`identifier`),
  UNIQUE KEY `delfzijl_id` (`delfzijl_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_documents` (
  `id` int NOT NULL AUTO_INCREMENT,
  `identifier` varchar(64) NOT NULL,
  `document_type` varchar(32) NOT NULL,
  `document_number` varchar(64) NOT NULL,
  `issued_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `expires_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `document_number` (`document_number`),
  KEY `identifier` (`identifier`),
  KEY `document_type` (`document_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
