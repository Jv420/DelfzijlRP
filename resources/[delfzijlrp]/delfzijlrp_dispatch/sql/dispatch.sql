CREATE TABLE IF NOT EXISTS `delfzijlrp_dispatch_reports` (
  `id` int NOT NULL AUTO_INCREMENT,
  `report_type` varchar(32) NOT NULL,
  `service` varchar(32) NOT NULL,
  `caller_identifier` varchar(64) DEFAULT NULL,
  `caller_name` varchar(128) DEFAULT NULL,
  `message` varchar(500) NOT NULL,
  `coords` longtext DEFAULT NULL,
  `status` varchar(32) NOT NULL DEFAULT 'open',
  `accepted_by` varchar(64) DEFAULT NULL,
  `accepted_job` varchar(32) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `service_status` (`service`, `status`),
  KEY `caller_identifier` (`caller_identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
