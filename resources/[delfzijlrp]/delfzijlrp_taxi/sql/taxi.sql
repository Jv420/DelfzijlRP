CREATE TABLE IF NOT EXISTS `delfzijlrp_taxi_duty` (
  `identifier` varchar(64) NOT NULL,
  `on_duty` tinyint(1) NOT NULL DEFAULT 0,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `delfzijlrp_taxi_rides` (
  `id` int NOT NULL AUTO_INCREMENT,
  `driver_identifier` varchar(64) DEFAULT NULL,
  `driver_name` varchar(128) DEFAULT NULL,
  `customer_identifier` varchar(64) DEFAULT NULL,
  `customer_name` varchar(128) DEFAULT NULL,
  `ride_type` varchar(32) NOT NULL DEFAULT 'player',
  `distance_km` decimal(10,2) NOT NULL DEFAULT 0.00,
  `fare` int NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `driver_identifier` (`driver_identifier`),
  KEY `customer_identifier` (`customer_identifier`),
  KEY `ride_type` (`ride_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
