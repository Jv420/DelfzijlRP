CREATE TABLE IF NOT EXISTS `delfzijlrp_garage_states` (
  `plate` varchar(16) NOT NULL,
  `owner` varchar(64) NOT NULL,
  `garage_id` varchar(64) DEFAULT NULL,
  `stored` tinyint(1) NOT NULL DEFAULT 1,
  `impounded` tinyint(1) NOT NULL DEFAULT 0,
  `vehicle_props` longtext DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`plate`),
  KEY `owner` (`owner`),
  KEY `garage_id` (`garage_id`),
  KEY `impounded` (`impounded`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
