-- ============================================
-- SASI Database Schema - Updated Version
-- Energy Fraud Inspection Map System
-- ============================================

-- Enable PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;

-- ============================================
-- Core Tables
-- ============================================

-- Table: instalacoes (installations with geospatial data)
CREATE TABLE IF NOT EXISTS instalacoes (
    id_instalacao VARCHAR(20) PRIMARY KEY,
    municipio VARCHAR(100) NOT NULL,
    latitude DECIMAL(10, 7) NOT NULL,
    longitude DECIMAL(10, 7) NOT NULL,
    classe_tarifaria VARCHAR(50),
    geom GEOMETRY(Point, 4326),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_instalacoes_geom ON instalacoes USING GIST (geom);
CREATE INDEX IF NOT EXISTS idx_instalacoes_municipio ON instalacoes (municipio);
CREATE INDEX IF NOT EXISTS idx_instalacoes_classe ON instalacoes (classe_tarifaria);

-- Table: queries_principais (main queries - NO MORE tipo_alvo here)
CREATE TABLE IF NOT EXISTS queries_principais (
    id_query SERIAL PRIMARY KEY,
    nome VARCHAR(200) NOT NULL,
    descricao TEXT,
    cor VARCHAR(7) NOT NULL, -- Hex color for this query (e.g., #FF5733)
    ativa BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_queries_principais_ativa ON queries_principais (ativa);

-- Table: resultado_queries_principais (results with tipo_alvo per installation)
CREATE TABLE IF NOT EXISTS resultado_queries_principais (
    id_query INTEGER REFERENCES queries_principais(id_query) ON DELETE CASCADE,
    id_instalacao VARCHAR(20) REFERENCES instalacoes(id_instalacao) ON DELETE CASCADE,
    tipo_alvo VARCHAR(20) NOT NULL CHECK (tipo_alvo IN ('regular', 'forte')), -- NEW: moved here
    score DECIMAL(5, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_query, id_instalacao)
);

CREATE INDEX IF NOT EXISTS idx_resultado_qp_query ON resultado_queries_principais (id_query);
CREATE INDEX IF NOT EXISTS idx_resultado_qp_instalacao ON resultado_queries_principais (id_instalacao);

-- Table: queries_auxiliares (auxiliary queries)
CREATE TABLE IF NOT EXISTS queries_auxiliares (
    id_query SERIAL PRIMARY KEY,
    nome VARCHAR(200) NOT NULL,
    descricao TEXT,
    tipo_retorno VARCHAR(20) CHECK (tipo_retorno IN ('instalacoes', 'heatmap')),
    ativa BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_queries_auxiliares_ativa ON queries_auxiliares (ativa);

-- Table: resultado_queries_auxiliares
CREATE TABLE IF NOT EXISTS resultado_queries_auxiliares (
    id_query INTEGER REFERENCES queries_auxiliares(id_query) ON DELETE CASCADE,
    id_instalacao VARCHAR(20) REFERENCES instalacoes(id_instalacao) ON DELETE CASCADE,
    intensidade DECIMAL(5, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_query, id_instalacao)
);

CREATE INDEX IF NOT EXISTS idx_resultado_qa_query ON resultado_queries_auxiliares (id_query);
CREATE INDEX IF NOT EXISTS idx_resultado_qa_instalacao ON resultado_queries_auxiliares (id_instalacao);

-- Table: historico_consumo (consumption history)
CREATE TABLE IF NOT EXISTS historico_consumo (
    id SERIAL PRIMARY KEY,
    id_instalacao VARCHAR(20) REFERENCES instalacoes(id_instalacao) ON DELETE CASCADE,
    mes_referencia DATE NOT NULL,
    consumo_kwh DECIMAL(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_historico_instalacao ON historico_consumo (id_instalacao);
CREATE INDEX IF NOT EXISTS idx_historico_data ON historico_consumo (mes_referencia);
CREATE INDEX IF NOT EXISTS idx_historico_instalacao_data ON historico_consumo (id_instalacao, mes_referencia);

-- Table: fraudes (fraud records)
CREATE TABLE IF NOT EXISTS fraudes (
    id SERIAL PRIMARY KEY,
    id_instalacao VARCHAR(20) REFERENCES instalacoes(id_instalacao) ON DELETE CASCADE,
    data_ocorrencia DATE NOT NULL,
    tipo_fraude VARCHAR(100),
    descricao TEXT,
    valor_estimado DECIMAL(12, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_fraudes_instalacao ON fraudes (id_instalacao);
CREATE INDEX IF NOT EXISTS idx_fraudes_data ON fraudes (data_ocorrencia);

-- Table: status_instalacao (installation status tracking)
CREATE TABLE IF NOT EXISTS status_instalacao (
    id SERIAL PRIMARY KEY,
    id_instalacao VARCHAR(20) REFERENCES instalacoes(id_instalacao) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL CHECK (status IN ('selecionada', 'nao_selecionada', 'verificar')),
    usuario VARCHAR(100) NOT NULL,
    observacoes TEXT,
    data_alteracao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_status_instalacao ON status_instalacao (id_instalacao);
CREATE INDEX IF NOT EXISTS idx_status_data ON status_instalacao (data_alteracao);

-- Table: municipios (municipalities with boundaries)
CREATE TABLE IF NOT EXISTS municipios (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) UNIQUE NOT NULL,
    geom GEOMETRY(MultiPolygon, 4326),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_municipios_geom ON municipios USING GIST (geom);
CREATE INDEX IF NOT EXISTS idx_municipios_nome ON municipios (nome);

-- Table: notas_servico (service notes)
CREATE TABLE IF NOT EXISTS notas_servico (
    id SERIAL PRIMARY KEY,
    id_instalacao VARCHAR(20) REFERENCES instalacoes(id_instalacao) ON DELETE CASCADE,
    data_servico DATE NOT NULL,
    tipo_servico VARCHAR(100),
    descricao TEXT,
    tecnico VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_notas_instalacao ON notas_servico (id_instalacao);
CREATE INDEX IF NOT EXISTS idx_notas_data ON notas_servico (data_servico);

-- ============================================
-- Triggers
-- ============================================

-- Trigger to auto-update geometry from lat/lng
CREATE OR REPLACE FUNCTION update_instalacao_geom()
RETURNS TRIGGER AS $$
BEGIN
    NEW.geom := ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_instalacoes_update_geom
BEFORE INSERT OR UPDATE OF latitude, longitude ON instalacoes
FOR EACH ROW
EXECUTE FUNCTION update_instalacao_geom();

-- Trigger to auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_instalacoes_updated_at
BEFORE UPDATE ON instalacoes
FOR EACH ROW
EXECUTE FUNCTION update_updated_at();

-- ============================================
-- Views
-- ============================================

-- View: Latest status for each installation
CREATE OR REPLACE VIEW v_status_atual_instalacao AS
SELECT DISTINCT ON (id_instalacao)
    id_instalacao,
    status,
    usuario,
    observacoes,
    data_alteracao
FROM status_instalacao
ORDER BY id_instalacao, data_alteracao DESC;

-- View: Installations with fraud history
CREATE OR REPLACE VIEW v_instalacoes_com_fraudes AS
SELECT 
    i.id_instalacao,
    i.municipio,
    i.classe_tarifaria,
    COUNT(f.id) as total_fraudes,
    SUM(f.valor_estimado) as valor_total_fraudes
FROM instalacoes i
LEFT JOIN fraudes f ON i.id_instalacao = f.id_instalacao
GROUP BY i.id_instalacao, i.municipio, i.classe_tarifaria;

-- ============================================
-- Comments
-- ============================================

COMMENT ON TABLE instalacoes IS 'Installation locations with geospatial coordinates';
COMMENT ON TABLE queries_principais IS 'Main queries for statewide analysis - each has unique color';
COMMENT ON TABLE resultado_queries_principais IS 'Query results with tipo_alvo per installation';
COMMENT ON TABLE queries_auxiliares IS 'Auxiliary queries for area-specific context';
COMMENT ON TABLE historico_consumo IS 'Monthly consumption history';
COMMENT ON TABLE fraudes IS 'Historical fraud records';
COMMENT ON TABLE status_instalacao IS 'Installation selection status tracking';
