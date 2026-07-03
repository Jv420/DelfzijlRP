CREATE TABLE IF NOT EXISTS `delfzijlrp_job_stats` (
  `identifier` varchar(64) NOT NULL,
  `job_name` varchar(64) NOT NULL,
  `completed_tasks` int NOT NULL DEFAULT 0,
  `total_earned` int NOT NULL DEFAULT 0,
  `level` int NOT NULL DEFAULT 1,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`identifier`, `job_name`),
  KEY `job_name` (`job_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
