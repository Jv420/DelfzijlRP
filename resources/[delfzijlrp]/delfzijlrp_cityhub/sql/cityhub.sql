CREATE TABLE IF NOT EXISTS `delfzijlrp_cityhub_visits` (
  `identifier` varchar(64) NOT NULL,
  `visits` int NOT NULL DEFAULT 0,
  `last_visit` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
