-- ============================================
-- Sample Data for SASI - Updated Version
-- ============================================

-- Insert Main Queries (without accents, with colors)
INSERT INTO queries_principais (nome, descricao, cor, ativa) VALUES
('Alto Consumo Residencial', 'Instalacoes residenciais com consumo acima de 500 kWh/mes', '#3B82F6', true),
('Variacao Atipica', 'Instalacoes com reducao brusca de consumo nos ultimos 3 meses', '#10B981', true),
('Classe Tarifaria Inadequada', 'Instalacoes com consumo incompativel com classe tarifaria', '#F59E0B', true),
('Proximidade a Fraudes', 'Instalacoes proximas a outras com historico de fraude', '#EF4444', true);

-- Insert Auxiliary Queries
INSERT INTO queries_auxiliares (nome, descricao, tipo_retorno, ativa) VALUES
('Densidade Populacional', 'Densidade de instalacoes por area', 'heatmap', true),
('Historico de Manutencao', 'Instalacoes com historico de manutencao recente', 'instalacoes', true),
('Consumo por Classe', 'Distribuicao de consumo por classe tarifaria', 'heatmap', true),
('Instalacoes Criticas', 'Instalacoes com multiplos indicadores de risco', 'instalacoes', true);

-- Insert Municipalities (Rio Grande do Norte sample)
INSERT INTO municipios (nome, geom) VALUES
('Natal', ST_GeomFromText('MULTIPOLYGON(((-35.3 -5.7, -35.1 -5.7, -35.1 -5.9, -35.3 -5.9, -35.3 -5.7)))', 4326)),
('Mossoro', ST_GeomFromText('MULTIPOLYGON(((-37.4 -5.1, -37.2 -5.1, -37.2 -5.3, -37.4 -5.3, -37.4 -5.1)))', 4326)),
('Parnamirim', ST_GeomFromText('MULTIPOLYGON(((-35.3 -5.9, -35.2 -5.9, -35.2 -6.0, -35.3 -6.0, -35.3 -5.9)))', 4326)),
('Caico', ST_GeomFromText('MULTIPOLYGON(((-37.1 -6.4, -37.0 -6.4, -37.0 -6.5, -37.1 -6.5, -37.1 -6.4)))', 4326));

-- Insert Sample Installations
INSERT INTO instalacoes (id_instalacao, municipio, latitude, longitude, classe_tarifaria) VALUES
('INST001', 'Natal', -5.82, -35.205, 'Residencial'),
('INST002', 'Natal', -5.79, -35.21, 'Residencial'),
('INST003', 'Mossoro', -5.19, -37.34, 'Comercial'),
('INST004', 'Mossoro', -5.21, -37.32, 'Residencial'),
('INST005', 'Parnamirim', -5.92, -35.26, 'Residencial'),
('INST006', 'Parnamirim', -5.94, -35.25, 'Industrial'),
('INST007', 'Caico', -6.45, -37.08, 'Comercial'),
('INST008', 'Natal', -5.80, -35.20, 'Residencial'),
('INST009', 'Mossoro', -5.20, -37.33, 'Residencial'),
('INST010', 'Natal', -5.83, -35.22, 'Comercial');

-- Insert Query Results (NOW WITH tipo_alvo per installation)
-- Query 1: Alto Consumo Residencial
INSERT INTO resultado_queries_principais (id_query, id_instalacao, tipo_alvo, score) VALUES
(1, 'INST001', 'forte', 8.5),
(1, 'INST002', 'regular', 6.2),
(1, 'INST004', 'forte', 9.1),
(1, 'INST005', 'regular', 5.8);

-- Query 2: Variacao Atipica
INSERT INTO resultado_queries_principais (id_query, id_instalacao, tipo_alvo, score) VALUES
(2, 'INST003', 'regular', 7.0),
(2, 'INST007', 'forte', 8.8);

-- Query 3: Classe Tarifaria Inadequada
INSERT INTO resultado_queries_principais (id_query, id_instalacao, tipo_alvo, score) VALUES
(3, 'INST006', 'forte', 9.5),
(3, 'INST008', 'regular', 6.5),
(3, 'INST010', 'regular', 5.9);

-- Query 4: Proximidade a Fraudes
INSERT INTO resultado_queries_principais (id_query, id_instalacao, tipo_alvo, score) VALUES
(4, 'INST001', 'regular', 6.0),
(4, 'INST002', 'forte', 8.2),
(4, 'INST009', 'regular', 7.1);

-- Insert Auxiliary Query Results
INSERT INTO resultado_queries_auxiliares (id_query, id_instalacao, intensidade) VALUES
(1, 'INST001', 0.85),
(1, 'INST002', 0.72),
(2, 'INST003', 0.90),
(2, 'INST007', 0.65);

-- Insert Consumption History (last 12 months for some installations)
INSERT INTO historico_consumo (id_instalacao, mes_referencia, consumo_kwh) VALUES
('INST001', '2025-01-01', 650.5),
('INST001', '2024-12-01', 620.3),
('INST001', '2024-11-01', 680.7),
('INST002', '2025-01-01', 420.2),
('INST002', '2024-12-01', 450.8),
('INST002', '2024-11-01', 430.5),
('INST003', '2025-01-01', 1200.0),
('INST003', '2024-12-01', 350.5),
('INST003', '2024-11-01', 1150.3),
('INST004', '2025-01-01', 520.0),
('INST004', '2024-12-01', 510.5),
('INST004', '2024-11-01', 530.2);

-- Insert Fraud Records
INSERT INTO fraudes (id_instalacao, data_ocorrencia, tipo_fraude, descricao, valor_estimado) VALUES
('INST001', '2023-03-15', 'Manipulacao de Medidor', 'Medidor adulterado para reduzir consumo', 5200.00),
('INST009', '2022-08-20', 'Ligacao Clandestina', 'Derivacao irregular antes do medidor', 3800.00);

-- Insert Status Records
INSERT INTO status_instalacao (id_instalacao, status, usuario, observacoes) VALUES
('INST001', 'selecionada', 'analista01', 'Prioridade alta para inspecao'),
('INST003', 'verificar', 'analista02', 'Necessita confirmacao de dados');

-- Insert Service Notes
INSERT INTO notas_servico (id_instalacao, data_servico, tipo_servico, descricao, tecnico) VALUES
('INST001', '2024-11-10', 'Inspecao', 'Inspecao de rotina realizada', 'Joao Silva'),
('INST003', '2024-10-25', 'Troca de Medidor', 'Medidor substituido por suspeita de defeito', 'Maria Santos'),
('INST007', '2024-09-15', 'Leitura', 'Leitura extraordinaria solicitada', 'Carlos Oliveira');

COMMENT ON TABLE queries_principais IS 'Main queries now with unique colors, tipo_alvo moved to results';
