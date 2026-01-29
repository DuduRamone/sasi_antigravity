-- ============================================
-- SASI - Energy Fraud Inspection Map System
-- Database Schema with PostGIS
-- ============================================

-- Enable PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;

-- ============================================
-- INSTALAÇÕES (Installations)
-- ============================================
CREATE TABLE instalacoes (
    id_instalacao VARCHAR(50) PRIMARY KEY,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    geom GEOMETRY(Point, 4326) NOT NULL,
    municipio VARCHAR(100) NOT NULL,
    classe_tarifaria VARCHAR(50),
    endereco TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Spatial index for fast geographic queries
CREATE INDEX idx_instalacoes_geom ON instalacoes USING GIST(geom);
CREATE INDEX idx_instalacoes_municipio ON instalacoes(municipio);
CREATE INDEX idx_instalacoes_classe ON instalacoes(classe_tarifaria);

-- ============================================
-- QUERIES PRINCIPAIS (Main Queries)
-- ============================================
CREATE TABLE queries_principais (
    id_query SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    tipo_alvo VARCHAR(20) NOT NULL CHECK (tipo_alvo IN ('regular', 'forte')),
    ativa BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_queries_principais_ativa ON queries_principais(ativa);

-- ============================================
-- RESULTADO QUERIES PRINCIPAIS
-- ============================================
CREATE TABLE resultado_queries_principais (
    id_query INTEGER REFERENCES queries_principais(id_query) ON DELETE CASCADE,
    id_instalacao VARCHAR(50) REFERENCES instalacoes(id_instalacao) ON DELETE CASCADE,
    score DECIMAL(5, 4),
    data_calculo TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_query, id_instalacao)
);

CREATE INDEX idx_resultado_qp_query ON resultado_queries_principais(id_query);
CREATE INDEX idx_resultado_qp_instalacao ON resultado_queries_principais(id_instalacao);

-- ============================================
-- QUERIES AUXILIARES (Auxiliary Queries)
-- ============================================
CREATE TABLE queries_auxiliares (
    id_query SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    tipo_retorno VARCHAR(20) NOT NULL CHECK (tipo_retorno IN ('instalacao', 'heatmap')),
    ativa BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_queries_auxiliares_ativa ON queries_auxiliares(ativa);

-- ============================================
-- RESULTADO QUERIES AUXILIARES
-- ============================================
CREATE TABLE resultado_queries_auxiliares (
    id_query INTEGER REFERENCES queries_auxiliares(id_query) ON DELETE CASCADE,
    id_instalacao VARCHAR(50) REFERENCES instalacoes(id_instalacao) ON DELETE CASCADE,
    intensidade DECIMAL(5, 4),
    data_calculo TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_query, id_instalacao)
);

CREATE INDEX idx_resultado_qa_query ON resultado_queries_auxiliares(id_query);
CREATE INDEX idx_resultado_qa_instalacao ON resultado_queries_auxiliares(id_instalacao);

-- ============================================
-- HISTÓRICO DE CONSUMO (Consumption History)
-- ============================================
CREATE TABLE historico_consumo (
    id SERIAL PRIMARY KEY,
    id_instalacao VARCHAR(50) REFERENCES instalacoes(id_instalacao) ON DELETE CASCADE,
    data_referencia DATE NOT NULL,
    consumo DECIMAL(10, 2) NOT NULL,
    demanda DECIMAL(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_historico_instalacao ON historico_consumo(id_instalacao);
CREATE INDEX idx_historico_data ON historico_consumo(data_referencia);
CREATE INDEX idx_historico_instalacao_data ON historico_consumo(id_instalacao, data_referencia);

-- ============================================
-- FRAUDES (Fraud History)
-- ============================================
CREATE TABLE fraudes (
    id SERIAL PRIMARY KEY,
    id_instalacao VARCHAR(50) REFERENCES instalacoes(id_instalacao) ON DELETE CASCADE,
    data_fraude DATE NOT NULL,
    tipo_fraude VARCHAR(100),
    valor_recuperado DECIMAL(12, 2),
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_fraudes_instalacao ON fraudes(id_instalacao);
CREATE INDEX idx_fraudes_data ON fraudes(data_fraude);

-- ============================================
-- STATUS INSTALAÇÃO (Installation Status)
-- ============================================
CREATE TABLE status_instalacao (
    id SERIAL PRIMARY KEY,
    id_instalacao VARCHAR(50) REFERENCES instalacoes(id_instalacao) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL CHECK (status IN ('selecionado', 'nao_selecionado', 'verificar')),
    usuario VARCHAR(100) NOT NULL,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    observacoes TEXT
);

CREATE INDEX idx_status_instalacao ON status_instalacao(id_instalacao);
CREATE INDEX idx_status_data ON status_instalacao(data_atualizacao);

-- ============================================
-- MUNICÍPIOS (Municipalities - RN boundaries)
-- ============================================
CREATE TABLE municipios (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    geom GEOMETRY(MultiPolygon, 4326) NOT NULL,
    populacao INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_municipios_geom ON municipios USING GIST(geom);
CREATE INDEX idx_municipios_nome ON municipios(nome);

-- ============================================
-- NOTAS DE SERVIÇO (Service Notes)
-- ============================================
CREATE TABLE notas_servico (
    id SERIAL PRIMARY KEY,
    id_instalacao VARCHAR(50) REFERENCES instalacoes(id_instalacao) ON DELETE CASCADE,
    numero_nota VARCHAR(50) NOT NULL,
    data_nota DATE NOT NULL,
    tipo_servico VARCHAR(100),
    descricao TEXT,
    status VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notas_instalacao ON notas_servico(id_instalacao);
CREATE INDEX idx_notas_data ON notas_servico(data_nota);

-- ============================================
-- TRIGGER: Update geom from lat/lon
-- ============================================
CREATE OR REPLACE FUNCTION update_geom_from_coordinates()
RETURNS TRIGGER AS $$
BEGIN
    NEW.geom = ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_instalacoes_update_geom
BEFORE INSERT OR UPDATE ON instalacoes
FOR EACH ROW
EXECUTE FUNCTION update_geom_from_coordinates();

-- ============================================
-- TRIGGER: Update updated_at timestamp
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_instalacoes_updated_at
BEFORE UPDATE ON instalacoes
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- VIEWS: Helpful views for common queries
-- ============================================

-- View: Latest status per installation
CREATE VIEW v_status_atual_instalacao AS
SELECT DISTINCT ON (id_instalacao)
    id_instalacao,
    status,
    usuario,
    data_atualizacao,
    observacoes
FROM status_instalacao
ORDER BY id_instalacao, data_atualizacao DESC;

-- View: Installations with fraud count
CREATE VIEW v_instalacoes_com_fraudes AS
SELECT 
    i.id_instalacao,
    i.municipio,
    i.classe_tarifaria,
    i.geom,
    COUNT(f.id) as total_fraudes,
    MAX(f.data_fraude) as data_ultima_fraude
FROM instalacoes i
LEFT JOIN fraudes f ON i.id_instalacao = f.id_instalacao
GROUP BY i.id_instalacao, i.municipio, i.classe_tarifaria, i.geom;

COMMENT ON TABLE instalacoes IS 'Unidades consumidoras com localização geográfica';
COMMENT ON TABLE queries_principais IS 'Definição de queries principais que geram alvos estaduais';
COMMENT ON TABLE queries_auxiliares IS 'Definição de queries auxiliares aplicadas em áreas específicas';
COMMENT ON TABLE historico_consumo IS 'Histórico mensal de consumo das instalações';
COMMENT ON TABLE fraudes IS 'Registro de fraudes detectadas';
COMMENT ON TABLE status_instalacao IS 'Status de seleção definido pelo analista';
COMMENT ON TABLE municipios IS 'Limites geográficos dos municípios do RN';
