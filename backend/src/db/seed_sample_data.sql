-- ============================================
-- Sample Data for Development and Testing
-- ============================================

-- Sample Main Queries
INSERT INTO queries_principais (nome, descricao, tipo_alvo) VALUES
('Alto Consumo Residencial', 'Instalações residenciais com consumo acima de 500 kWh/mês', 'regular'),
('Padrão Irregular Comercial', 'Padrão de consumo incompatível com atividade comercial declarada', 'forte'),
('Histórico de Oscilação', 'Consumo com variação superior a 40% entre meses consecutivos', 'regular'),
('Vizinhança com Fraude', 'Instalações próximas a outras com histórico de fraude', 'forte');

-- Sample Auxiliary Queries
INSERT INTO queries_auxiliares (nome, descricao, tipo_retorno) VALUES
('Densidade Populacional', 'Mapa de calor da densidade de instalações', 'heatmap'),
('Consumo Zero Recente', 'Instalações com consumo zero nos últimos 3 meses', 'instalacao'),
('Ligações Recentes', 'Novas ligações nos últimos 6 meses', 'instalacao'),
('Área de Risco', 'Mapa de calor de fraudes históricas', 'heatmap');

-- Sample Municipalities (RN - principais cidades)
-- Note: geometries are simplified boxes for demonstration
INSERT INTO municipios (nome, geom, populacao) VALUES
('Natal', ST_GeomFromText('MULTIPOLYGON(((-35.3 -5.9, -35.1 -5.9, -35.1 -5.7, -35.3 -5.7, -35.3 -5.9)))', 4326), 890000),
('Mossoró', ST_GeomFromText('MULTIPOLYGON(((-37.4 -5.3, -37.3 -5.3, -37.3 -5.1, -37.4 -5.1, -37.4 -5.3)))', 4326), 300000),
('Parnamirim', ST_GeomFromText('MULTIPOLYGON(((-35.3 -6.0, -35.2 -6.0, -35.2 -5.9, -35.3 -5.9, -35.3 -6.0)))', 4326), 267000),
('São Gonçalo do Amarante', ST_GeomFromText('MULTIPOLYGON(((-35.4 -5.9, -35.3 -5.9, -35.3 -5.8, -35.4 -5.8, -35.4 -5.9)))', 4326), 100000);

-- Sample Installations (distributed across RN)
-- Generating sample data for Natal area
INSERT INTO instalacoes (id_instalacao, latitude, longitude, municipio, classe_tarifaria, endereco) VALUES
-- Natal
('INST001', -5.8200, -35.2050, 'Natal', 'Residencial', 'Rua Example 1, Natal'),
('INST002', -5.8100, -35.2100, 'Natal', 'Residencial', 'Rua Example 2, Natal'),
('INST003', -5.8300, -35.1950, 'Natal', 'Comercial', 'Av. Example 3, Natal'),
('INST004', -5.7900, -35.2150, 'Natal', 'Industrial', 'Distrito Industrial, Natal'),
('INST005', -5.8250, -35.2000, 'Natal', 'Residencial', 'Rua Example 5, Natal'),
-- Mossoró
('INST006', -5.1900, -37.3400, 'Mossoró', 'Residencial', 'Rua Example 6, Mossoró'),
('INST007', -5.2000, -37.3500, 'Mossoró', 'Comercial', 'Centro, Mossoró'),
('INST008', -5.1800, -37.3300, 'Mossoró', 'Residencial', 'Rua Example 8, Mossoró'),
-- Parnamirim
('INST009', -5.9200, -35.2600, 'Parnamirim', 'Residencial', 'Rua Example 9, Parnamirim'),
('INST010', -5.9100, -35.2500, 'Parnamirim', 'Comercial', 'Centro, Parnamirim');

-- Sample Query Results (Main Queries)
-- Query 1: Alto Consumo Residencial
INSERT INTO resultado_queries_principais (id_query, id_instalacao, score) VALUES
(1, 'INST001', 0.8500),
(1, 'INST002', 0.7200),
(1, 'INST005', 0.6800),
(1, 'INST009', 0.9100);

-- Query 2: Padrão Irregular Comercial (forte)
INSERT INTO resultado_queries_principais (id_query, id_instalacao, score) VALUES
(2, 'INST003', 0.8800),
(2, 'INST007', 0.9200);

-- Query 3: Histórico de Oscilação
INSERT INTO resultado_queries_principais (id_query, id_instalacao, score) VALUES
(3, 'INST006', 0.7500),
(3, 'INST008', 0.6200);

-- Sample Consumption History
INSERT INTO historico_consumo (id_instalacao, data_referencia, consumo) VALUES
-- INST001 - Padrão alto
('INST001', '2025-12-01', 620.50),
('INST001', '2025-11-01', 580.30),
('INST001', '2025-10-01', 640.80),
('INST001', '2025-09-01', 595.20),
('INST001', '2025-08-01', 610.40),
-- INST002 - Padrão normal
('INST002', '2025-12-01', 220.50),
('INST002', '2025-11-01', 210.30),
('INST002', '2025-10-01', 240.80),
-- INST003 - Padrão comercial irregular
('INST003', '2025-12-01', 1200.00),
('INST003', '2025-11-01', 450.00),
('INST003', '2025-10-01', 1350.00),
('INST003', '2025-09-01', 500.00);

-- Sample Fraud History
INSERT INTO fraudes (id_instalacao, data_fraude, tipo_fraude, valor_recuperado, observacoes) VALUES
('INST003', '2023-03-15', 'Ligação Clandestina', 15000.00, 'Identificado by-pass no medidor'),
('INST007', '2022-08-20', 'Manipulação de Medidor', 8500.00, 'Medidor adulterado');

-- Sample Service Notes
INSERT INTO notas_servico (id_instalacao, numero_nota, data_nota, tipo_servico, descricao, status) VALUES
('INST003', 'NS-2023-001', '2023-03-15', 'Inspeção de Fraude', 'Constatada ligação irregular', 'Concluída'),
('INST003', 'NS-2023-050', '2023-04-02', 'Regularização', 'Substituição de medidor e regularização', 'Concluída'),
('INST001', 'NS-2025-120', '2025-11-10', 'Leitura', 'Leitura de rotina', 'Concluída');

-- Sample Status Assignments
INSERT INTO status_instalacao (id_instalacao, status, usuario, observacoes) VALUES
('INST001', 'verificar', 'analista.silva', 'Consumo elevado, necessita inspeção de campo'),
('INST003', 'selecionado', 'analista.santos', 'Prioridade alta - reincidência'),
('INST002', 'nao_selecionado', 'analista.silva', 'Consumo justificado por número de moradores');

COMMENT ON SEQUENCE queries_principais_id_query_seq IS 'Auto-incremento para IDs de queries principais';
