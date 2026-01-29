-- ============================================
-- Additional Heatmap Data for Auxiliary Queries
-- Add this to seed_more_data.sql or run separately
-- ============================================

-- Add many more auxiliary results for heatmap visualization
-- Query 1 (Densidade Populacional) - tipo_retorno='heatmap'

-- Natal region - high density cluster
INSERT INTO resultado_queries_auxiliares (id_query, id_instalacao, intensidade) VALUES
(1, 'INST013', 0.92),
(1, 'INST014', 0.88),
(1, 'INST015', 0.85),
(1, 'INST016', 0.91),
(1, 'INST017', 0.87),
(1, 'INST018', 0.84),
(1, 'INST019', 0.90),
(1, 'INST020', 0.86),
(1, 'INST022', 0.89),
(1, 'INST023', 0.83),
(1, 'INST024', 0.92),
(1, 'INST025', 0.88),
(1, 'INST026', 0.85),
(1, 'INST027', 0.91),
(1, 'INST028', 0.87),
(1, 'INST029', 0.84),
(1, 'INST030', 0.90),
(1, 'INST031', 0.86),
(1, 'INST032', 0.89),
(1, 'INST033', 0.83),
(1, 'INST034', 0.92),
(1, 'INST035', 0.88),
(1, 'INST036', 0.85),
(1, 'INST037', 0.91),
(1, 'INST038', 0.87),
(1, 'INST039', 0.84),
(1, 'INST040', 0.90);

-- Mossoró region - medium density
INSERT INTO resultado_queries_auxiliares (id_query, id_instalacao, intensidade) VALUES
(1, 'INST042', 0.72),
(1, 'INST043', 0.68),
(1, 'INST044', 0.75),
(1, 'INST045', 0.70),
(1, 'INST046', 0.73),
(1, 'INST047', 0.69),
(1, 'INST048', 0.74),
(1, 'INST049', 0.71),
(1, 'INST050', 0.76),
(1, 'INST051', 0.72),
(1, 'INST052', 0.68),
(1, 'INST053', 0.75),
(1, 'INST054', 0.70),
(1, 'INST055', 0.73);

-- Parnamirim region - high density
INSERT INTO resultado_queries_auxiliares (id_query, id_instalacao, intensidade) VALUES
(1, 'INST062', 0.95),
(1, 'INST063', 0.88),
(1, 'INST064', 0.91),
(1, 'INST065', 0.87),
(1, 'INST066', 0.93),
(1, 'INST067', 0.89),
(1, 'INST068', 0.86),
(1, 'INST069', 0.92),
(1, 'INST070', 0.88),
(1, 'INST071', 0.85),
(1, 'INST072', 0.90),
(1, 'INST073', 0.87),
(1, 'INST074', 0.94),
(1, 'INST075', 0.91);

-- Query 3 (Consumo por Classe) - also heatmap type
INSERT INTO resultado_queries_auxiliares (id_query, id_instalacao, intensidade) VALUES
(3, 'INST011', 0.78),
(3, 'INST012', 0.82),
(3, 'INST013', 0.75),
(3, 'INST041', 0.80),
(3, 'INST042', 0.76),
(3, 'INST043', 0.79),
(3, 'INST061', 0.84),
(3, 'INST062', 0.81),
(3, 'INST063', 0.77);

COMMENT ON TABLE resultado_queries_auxiliares IS 'Now contains heatmap data for Densidade Populacional and Consumo por Classe';
