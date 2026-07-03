CREATE TABLE IF NOT EXISTS `delfzijlrp_phone_settings` (
  `identifier` varchar(64) NOT NULL,
  `wallpaper` varchar(64) NOT NULL DEFAULT 'delfzijl',
  `accent` varchar(32) NOT NULL DEFAULT 'yellow',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
