-- ============================================
-- Additional Sample Data for SASI - Much more installations
-- Run this AFTER seed_sample_data_v2.sql
-- ============================================

-- Add many more installations across RN municipalities
INSERT INTO instalacoes (id_instalacao, municipio, latitude, longitude, classe_tarifaria) VALUES
-- Natal (capital) - 30 more installations
('INST011', 'Natal', -5.81, -35.21, 'Residencial'),
('INST012', 'Natal', -5.80, -35.22, 'Residencial'),
('INST013', 'Natal', -5.82, -35.19, 'Comercial'),
('INST014', 'Natal', -5.79, -35.20, 'Residencial'),
('INST015', 'Natal', -5.83, -35.21, 'Residencial'),
('INST016', 'Natal', -5.78, -35.22, 'Industrial'),
('INST017', 'Natal', -5.84, -35.20, 'Comercial'),
('INST018', 'Natal', -5.77, -35.21, 'Residencial'),
('INST019', 'Natal', -5.85, -35.19, 'Residencial'),
('INST020', 'Natal', -5.76, -35.20, 'Residencial'),
('INST021', 'Natal', -5.86, -35.22, 'Comercial'),
('INST022', 'Natal', -5.75, -35.21, 'Residencial'),
('INST023', 'Natal', -5.81, -35.23, 'Residencial'),
('INST024', 'Natal', -5.80, -35.18, 'Industrial'),
('INST025', 'Natal', -5.82, -35.24, 'Residencial'),
('INST026', 'Natal', -5.79, -35.17, 'Comercial'),
('INST027', 'Natal', -5.83, -35.23, 'Residencial'),
('INST028', 'Natal', -5.78, -35.18, 'Residencial'),
('INST029', 'Natal', -5.84, -35.24, 'Residencial'),
('INST030', 'Natal', -5.77, -35.19, 'Comercial'),
('INST031', 'Natal', -5.85, -35.23, 'Residencial'),
('INST032', 'Natal', -5.76, -35.22, 'Residencial'),
('INST033', 'Natal', -5.86, -35.18, 'Industrial'),
('INST034', 'Natal', -5.75, -35.24, 'Residencial'),
('INST035', 'Natal', -5.81, -35.19, 'Comercial'),
('INST036', 'Natal', -5.80, -35.24, 'Residencial'),
('INST037', 'Natal', -5.82, -35.17, 'Residencial'),
('INST038', 'Natal', -5.79, -35.23, 'Residencial'),
('INST039', 'Natal', -5.83, -35.18, 'Comercial'),
('INST040', 'Natal', -5.78, -35.24, 'Residencial'),

-- Mossoró - 20 installations
('INST041', 'Mossoro', -5.18, -37.35, 'Residencial'),
('INST042', 'Mossoro', -5.19, -37.34, 'Comercial'),
('INST043', 'Mossoro', -5.20, -37.33, 'Residencial'),
('INST044', 'Mossoro', -5.21, -37.32, 'Residencial'),
('INST045', 'Mossoro', -5.22, -37.35, 'Industrial'),
('INST046', 'Mossoro', -5.17, -37.34, 'Comercial'),
('INST047', 'Mossoro', -5.23, -37.33, 'Residencial'),
('INST048', 'Mossoro', -5.16, -37.32, 'Residencial'),
('INST049', 'Mossoro', -5.24, -37.35, 'Residencial'),
('INST050', 'Mossoro', -5.15, -37.34, 'Comercial'),
('INST051', 'Mossoro', -5.25, -37.33, 'Residencial'),
('INST052', 'Mossoro', -5.14, -37.32, 'Residencial'),
('INST053', 'Mossoro', -5.26, -37.35, 'Industrial'),
('INST054', 'Mossoro', -5.13, -37.34, 'Residencial'),
('INST055', 'Mossoro', -5.18, -37.31, 'Comercial'),
('INST056', 'Mossoro', -5.19, -37.36, 'Residencial'),
('INST057', 'Mossoro', -5.20, -37.30, 'Residencial'),
('INST058', 'Mossoro', -5.21, -37.36, 'Residencial'),
('INST059', 'Mossoro', -5.22, -37.31, 'Comercial'),
('INST060', 'Mossoro', -5.17, -37.36, 'Residencial'),

-- Parnamirim - 15 installations
('INST061', 'Parnamirim', -5.91, -35.27, 'Residencial'),
('INST062', 'Parnamirim', -5.92, -35.26, 'Comercial'),
('INST063', 'Parnamirim', -5.93, -35.25, 'Residencial'),
('INST064', 'Parnamirim', -5.94, -35.26, 'Industrial'),
('INST065', 'Parnamirim', -5.95, -35.27, 'Residencial'),
('INST066', 'Parnamirim', -5.90, -35.25, 'Comercial'),
('INST067', 'Parnamirim', -5.96, -35.26, 'Residencial'),
('INST068', 'Parnamirim', -5.89, -35.27, 'Residencial'),
('INST069', 'Parnamirim', -5.97, -35.25, 'Residencial'),
('INST070', 'Parnamirim', -5.88, -35.26, 'Comercial'),
('INST071', 'Parnamirim', -5.91, -35.24, 'Residencial'),
('INST072', 'Parnamirim', -5.92, -35.28, 'Industrial'),
('INST073', 'Parnamirim', -5.93, -35.24, 'Residencial'),
('INST074', 'Parnamirim', -5.94, -35.28, 'Residencial'),
('INST075', 'Parnamirim', -5.95, -35.24, 'Comercial'),

-- Caicó - 15 installations
('INST076', 'Caico', -6.44, -37.09, 'Residencial'),
('INST077', 'Caico', -6.45, -37.08, 'Comercial'),
('INST078', 'Caico', -6.46, -37.07, 'Residencial'),
('INST079', 'Caico', -6.44, -37.10, 'Residencial'),
('INST080', 'Caico', -6.45, -37.09, 'Industrial'),
('INST081', 'Caico', -6.46, -37.08, 'Comercial'),
('INST082', 'Caico', -6.47, -37.07, 'Residencial'),
('INST083', 'Caico', -6.43, -37.10, 'Residencial'),
('INST084', 'Caico', -6.48, -37.09, 'Residencial'),
('INST085', 'Caico', -6.42, -37.08, 'Comercial'),
('INST086', 'Caico', -6.49, -37.07, 'Residencial'),
('INST087', 'Caico', -6.41, -37.10, 'Residencial'),
('INST088', 'Caico', -6.44, -37.06, 'Industrial'),
('INST089', 'Caico', -6.45, -37.11, 'Residencial'),
('INST090', 'Caico', -6.46, -37.06, 'Comercial');

-- Add results for Query 1 (Alto Consumo Residencial) - MANY installations
INSERT INTO resultado_queries_principais (id_query, id_instalacao, tipo_alvo, score) VALUES
(1, 'INST011', 'regular', 6.5),
(1, 'INST012', 'forte', 8.7),
(1, 'INST013', 'regular', 5.9),
(1, 'INST014', 'forte', 9.2),
(1, 'INST015', 'regular', 6.8),
(1, 'INST016', 'forte', 8.9),
(1, 'INST017', 'regular', 6.1),
(1, 'INST018', 'forte', 9.5),
(1, 'INST019', 'regular', 5.7),
(1, 'INST020', 'forte', 8.4),
(1, 'INST041', 'regular', 6.3),
(1, 'INST042', 'forte', 8.8),
(1, 'INST043', 'regular', 6.6),
(1, 'INST044', 'forte', 9.1),
(1, 'INST061', 'regular', 6.4),
(1, 'INST062', 'forte', 8.6),
(1, 'INST076', 'regular', 6.2),
(1, 'INST077', 'forte', 9.3);

-- Add results for Query 2 (Variação Atípica) - MANY installations
INSERT INTO resultado_queries_principais (id_query, id_instalacao, tipo_alvo, score) VALUES
(2, 'INST021', 'regular', 7.2),
(2, 'INST022', 'forte', 8.9),
(2, 'INST023', 'regular', 6.8),
(2, 'INST024', 'forte', 9.4),
(2, 'INST025', 'regular', 7.1),
(2, 'INST045', 'forte', 8.7),
(2, 'INST046', 'regular', 6.9),
(2, 'INST047', 'forte', 9.2),
(2, 'INST063', 'regular', 7.3),
(2, 'INST064', 'forte', 8.8),
(2, 'INST078', 'regular', 7.0),
(2, 'INST079', 'forte', 9.1);

-- Add results for Query 3 (Classe Tarifária Inadequada)
INSERT INTO resultado_queries_principais (id_query, id_instalacao, tipo_alvo, score) VALUES
(3, 'INST026', 'regular', 6.7),
(3, 'INST027', 'forte', 9.0),
(3, 'INST028', 'regular', 6.5),
(3, 'INST029', 'forte', 8.9),
(3, 'INST030', 'regular', 6.8),
(3, 'INST048', 'forte', 9.3),
(3, 'INST049', 'regular', 6.6),
(3, 'INST050', 'forte', 8.8),
(3, 'INST065', 'regular', 6.9),
(3, 'INST066', 'forte', 9.1),
(3, 'INST080', 'regular', 6.4),
(3, 'INST081', 'forte', 9.2);

-- Add results for Query 4 (Proximidade a Fraudes)
INSERT INTO resultado_queries_principais (id_query, id_instalacao, tipo_alvo, score) VALUES
(4, 'INST031', 'regular', 7.4),
(4, 'INST032', 'forte', 8.6),
(4, 'INST033', 'regular', 7.1),
(4, 'INST034', 'forte', 9.4),
(4, 'INST035', 'regular', 7.2),
(4, 'INST051', 'forte', 8.9),
(4, 'INST052', 'regular', 7.0),
(4, 'INST053', 'forte', 9.3),
(4, 'INST067', 'regular', 7.3),
(4, 'INST068', 'forte', 8.7),
(4, 'INST082', 'regular', 7.1),
(4, 'INST083', 'forte', 9.0);

-- Add some auxiliary query results
INSERT INTO resultado_queries_auxiliares (id_query, id_instalacao, intensidade) VALUES
(1, 'INST011', 0.88),
(1, 'INST012', 0.75),
(1, 'INST021', 0.82),
(1, 'INST041', 0.79),
(2, 'INST031', 0.91),
(2, 'INST032', 0.68),
(2, 'INST061', 0.85);

COMMENT ON TABLE instalacoes IS 'Now contains 90 installations across 4 municipalities';
