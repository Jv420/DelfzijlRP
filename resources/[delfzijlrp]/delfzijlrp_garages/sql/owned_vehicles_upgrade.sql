-- Delfzijl RP garages upgrade voor ESX owned_vehicles

ALTER TABLE owned_vehicles
    ADD COLUMN IF NOT EXISTS garage VARCHAR(60) DEFAULT 'centrum',
    ADD COLUMN IF NOT EXISTS stored TINYINT(1) DEFAULT 1,
    ADD COLUMN IF NOT EXISTS tracker TINYINT(1) DEFAULT 0,
    ADD COLUMN IF NOT EXISTS tracker_label VARCHAR(80) DEFAULT NULL,
    ADD COLUMN IF NOT EXISTS last_position LONGTEXT DEFAULT NULL;

CREATE INDEX IF NOT EXISTS idx_owned_vehicles_owner ON owned_vehicles(owner);
CREATE INDEX IF NOT EXISTS idx_owned_vehicles_plate ON owned_vehicles(plate);
CREATE INDEX IF NOT EXISTS idx_owned_vehicles_garage ON owned_vehicles(garage);
