CREATE TABLE IF NOT EXISTS `delfzijlrp_medical_records` (
  `id` int NOT NULL AUTO_INCREMENT,
  `patient_identifier` varchar(64) DEFAULT NULL,
  `patient_name` varchar(128) DEFAULT NULL,
  `medic_identifier` varchar(64) DEFAULT NULL,
  `medic_name` varchar(128) DEFAULT NULL,
  `record_type` varchar(64) NOT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `patient_identifier` (`patient_identifier`),
  KEY `medic_identifier` (`medic_identifier`),
  KEY `record_type` (`record_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_ambulance_duty` (
  `identifier` varchar(64) NOT NULL,
  `on_duty` tinyint(1) NOT NULL DEFAULT 0,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
