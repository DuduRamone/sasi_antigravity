-- Quick script to add 60+ heatmap points
-- Run this from the backend\src directory:
-- Set the password and run: $env:PGPASSWORD='postgres'; & 'C:\Program Files\PostgreSQL\17\bin\psql.exe' -h localhost -U postgres -d sasi2 -f db/add_heatmap_points.sql

-- Clear existing auxiliary results for query 1
DELETE FROM resultado_queries_auxiliares WHERE id_query = 1;

-- Add MANY heatmap points for Natal area (query 1 = Densidade Populacional)
INSERT INTO resultado_queries_auxiliares (id_query, id_instalacao, intensidade) VALUES
-- High density cluster in central Natal
(1, 'INST011', 0.95),
(1, 'INST012', 0.92),
(1, 'INST013', 0.88),
(1, 'INST014', 0.91),
(1, 'INST015', 0.87),
(1, 'INST016', 0.90),
(1, 'INST017', 0.86),
(1, 'INST018', 0.93),
(1, 'INST019', 0.89),
(1, 'INST020', 0.85),
(1, 'INST021', 0.94),
(1, 'INST022', 0.88),
(1, 'INST023', 0.91),
(1, 'INST024', 0.87),
(1, 'INST025', 0.92),
(1, 'INST026', 0.86),
(1, 'INST027', 0.90),
(1, 'INST028', 0.84),
(1, 'INST029', 0.89),
(1, 'INST030', 0.93),
(1, 'INST031', 0.88),
(1, 'INST032', 0.85),
(1, 'INST033', 0.91),
(1, 'INST034', 0.87),
(1, 'INST035', 0.90),
(1, 'INST036', 0.86),
(1, 'INST037', 0.92),
(1, 'INST038', 0.89),
(1, 'INST039', 0.85),
(1, 'INST040', 0.88);

-- Add points for Mossoró (lower density)
INSERT INTO resultado_queries_auxiliares (id_query, id_instalacao, intensidade) VALUES
(1, 'INST041', 0.72),
(1, 'INST042', 0.68),
(1, 'INST043', 0.75),
(1, 'INST044', 0.70),
(1, 'INST045', 0.73),
(1, 'INST046', 0.69),
(1, 'INST047', 0.74),
(1, 'INST048', 0.71),
(1, 'INST049', 0.76),
(1, 'INST050', 0.72),
(1, 'INST051', 0.68),
(1, 'INST052', 0.75),
(1, 'INST053', 0.70),
(1, 'INST054', 0.73),
(1, 'INST055', 0.69),
(1, 'INST056', 0.74),
(1, 'INST057', 0.71),
(1, 'INST058', 0.76),
(1, 'INST059', 0.72),
(1, 'INST060', 0.68);

-- Add points for Parnamirim (very high density)
INSERT INTO resultado_queries_auxiliares (id_query, id_instalacao, intensidade) VALUES
(1, 'INST061', 0.98),
(1, 'INST062', 0.95),
(1, 'INST063', 0.91),
(1, 'INST064', 0.94),
(1, 'INST065', 0.90),
(1, 'INST066', 0.96),
(1, 'INST067', 0.92),
(1, 'INST068', 0.89),
(1, 'INST069', 0.97),
(1, 'INST070', 0.93),
(1, 'INST071', 0.88),
(1, 'INST072', 0.95),
(1, 'INST073', 0.91),
(1, 'INST074', 0.94),
(1, 'INST075', 0.90);

-- Add some points for Caicó (medium density)
INSERT INTO resultado_queries_auxiliares (id_query, id_instalacao, intensidade) VALUES
(1, 'INST076', 0.65),
(1, 'INST077', 0.62),
(1, 'INST078', 0.68),
(1, 'INST079', 0.64),
(1, 'INST080', 0.70),
(1, 'INST081', 0.66),
(1, 'INST082', 0.63),
(1, 'INST083', 0.69),
(1, 'INST084', 0.65),
(1, 'INST085', 0.67);

-- Verify
SELECT COUNT(*) as total_heatmap_points FROM resultado_queries_auxiliares WHERE id_query = 1;
