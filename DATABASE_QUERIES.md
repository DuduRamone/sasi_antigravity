# SASI - Documentação do Banco de Dados

## Visão Geral

Este documento detalha todas as queries SQL utilizadas no sistema SASI, organizadas por funcionalidade.

## Estrutura do Banco de Dados

### Tabelas Principais

1. **instalacoes** - Instalações elétricas
2. **queries_principais** - Queries de análise principal (statewide)
3. **queries_auxiliares** - Queries de contexto (filtered by area)
4. **resultado_queries_principais** - Resultados das queries principais
5. **resultado_queries_auxiliares** - Resultados das queries auxiliares
6. **municipios** - Municípios do RN com geometrias
7. **fraudes** - Histórico de fraudes detectadas
8. **historico_consumo** - Histórico de consumo por instalação
9. **notas_servico** - Notas de serviço e manutenção
10. **status_instalacao** - Status de seleção para inspeção

---

## Queries Utilizadas no Sistema

### 1. GET Main Queries (Lista de Queries Principais)

**Endpoint**: `GET /api/queries/main`

```sql
SELECT 
    id_query,
    nome,
    descricao,
    cor,
    ativa,
    created_at
FROM queries_principais
WHERE ativa = true
ORDER BY nome;
```

**Propósito**: Retorna todas as queries principais ativas para seleção no frontend.

---

### 2. GET Main Query Results (Resultados de Query Principal)

**Endpoint**: `GET /api/queries/main/{query_id}/results`

```sql
SELECT 
    i.id_instalacao,
    i.municipio,
    i.classe_tarifaria,
    i.latitude,
    i.longitude,
    ST_AsGeoJSON(i.geom) as geom_json,
    r.tipo_alvo,
    r.score
FROM instalacoes i
JOIN resultado_queries_principais r ON i.id_instalacao = r.id_instalacao
WHERE r.id_query = :query_id;
```

**Propósito**: Retorna todas as instalações que aparecem numa query principal específica (STATEWIDE - sem filtro de área).

**Retorno**: GeoJSON FeatureCollection com propriedades:
- `id_instalacao`
- `municipio`
- `classe_tarifaria`
- `tipo_alvo` (forte/regular)
- `score`
- `query_id`
- `query_nome`
- `query_cor`

---

### 3. GET Municipalities (Lista de Municípios)

**Endpoint**: `GET /api/areas/municipalities`

```sql
SELECT 
    id,
    nome,
    created_at
FROM municipios
ORDER BY nome;
```

**Propósito**: Retorna lista de municípios para seleção de área.

---

### 4. GET Municipality Geometry (Geometria do Município)

**Endpoint**: `GET /api/areas/municipalities/{nome}/geometry`

```sql
SELECT 
    id,
    nome,
    ST_AsGeoJSON(geom) as geom_json
FROM municipios
WHERE nome = :nome;
```

**Propósito**: Retorna a geometria de um município específico (usado para zoom, NÃO para desenhar no mapa).

---

### 5. GET Auxiliary Queries (Lista de Queries Auxiliares)

**Endpoint**: `GET /api/queries/auxiliary`

```sql
SELECT 
    id_query,
    nome,
    descricao,
    tipo_retorno,
    ativa,
    created_at
FROM queries_auxiliares
WHERE ativa = true
ORDER BY nome;
```

**Propósito**: Retorna todas as queries auxiliares disponíveis.

**tipo_retorno**: 'instalacoes' ou 'heatmap'

---

### 6. GET Auxiliary Query Results - Municipality (Resultados por Município)

**Endpoint**: `GET /api/queries/auxiliary/{query_id}/results?area_type=municipio&area_value={nome}`

```sql
SELECT 
    i.id_instalacao,
    i.municipio,
    i.classe_tarifaria,
    i.latitude,
    i.longitude,
    ST_AsGeoJSON(i.geom) as geom_json,
    r.intensidade
FROM instalacoes i
JOIN resultado_queries_auxiliares r ON i.id_instalacao = r.id_instalacao
WHERE r.id_query = :query_id
AND i.municipio = :municipio;
```

**Propósito**: Retorna resultados de query auxiliar FILTRADOS por município.

---

### 7. GET Auxiliary Query Results - Polygon (Resultados por Polígono)

**Endpoint**: `GET /api/queries/auxiliary/{query_id}/results?area_type=poligono&area_value={geojson}`

```sql
SELECT 
    i.id_instalacao,
    i.municipio,
    i.classe_tarifaria,
    i.latitude,
    i.longitude,
    ST_AsGeoJSON(i.geom) as geom_json,
    r.intensidade
FROM instalacoes i
JOIN resultado_queries_auxiliares r ON i.id_instalacao = r.id_instalacao
WHERE r.id_query = :query_id
AND ST_Contains(ST_GeomFromGeoJSON(:polygon), i.geom);
```

**Propósito**: Retorna resultados de query auxiliar FILTRADOS por polígono desenhado.

---

### 8. POST Area Metrics (Métricas da Área Selecionada)

**Endpoint**: `POST /api/areas/metrics`

#### Para Município:

```sql
-- Perímetro
SELECT ST_Perimeter(geom::geography) / 1000 as perimetro_km
FROM municipios
WHERE nome = :nome;

-- Total de Instalações
SELECT COUNT(*) as total
FROM instalacoes
WHERE municipio = :nome;

-- Total de Fraudes (5 anos)
SELECT COUNT(DISTINCT f.id_instalacao) as total_fraudes
FROM fraudes f
JOIN instalacoes i ON f.id_instalacao = i.id_instalacao
WHERE i.municipio = :nome
AND f.data_fraude >= :data_inicio;

-- Distribuição por Classe Tarifária
SELECT 
    COALESCE(classe_tarifaria, 'Não Classificado') as classe_tarifaria,
    COUNT(*) as count
FROM instalacoes
WHERE municipio = :nome
GROUP BY classe_tarifaria
ORDER BY count DESC;
```

#### Para Polígono:

```sql
-- Perímetro
SELECT ST_Perimeter(ST_GeomFromGeoJSON(:polygon)::geography) / 1000 as perimetro_km;

-- Total de Instalações
SELECT COUNT(*) as total
FROM instalacoes
WHERE ST_Contains(ST_GeomFromGeoJSON(:polygon), geom);

-- Total de Fraudes (5 anos)
SELECT COUNT(DISTINCT f.id_instalacao) as total_fraudes
FROM fraudes f
JOIN instalacoes i ON f.id_instalacao = i.id_instalacao
WHERE ST_Contains(ST_GeomFromGeoJSON(:polygon), i.geom)
AND f.data_fraude >= :data_inicio;

-- Distribuição por Classe Tarifária
SELECT 
    COALESCE(classe_tarifaria, 'Não Classificado') as classe_tarifaria,
    COUNT(*) as count
FROM instalacoes
WHERE ST_Contains(ST_GeomFromGeoJSON(:polygon), geom)
GROUP BY classe_tarifaria
ORDER BY count DESC;
```

---

## Queries de Dados Cadastrais (Para Fases Futuras)

### GET Installation Details (Detalhes da Instalação)

```sql
SELECT 
    i.*,
    ST_AsGeoJSON(i.geom) as geom_json
FROM instalacoes i
WHERE i.id_instalacao = :id_instalacao;
```

### GET Consumption History (Histórico de Consumo)

```sql
SELECT 
    mes_referencia,
    consumo_kwh
FROM historico_consumo
WHERE id_instalacao = :id_instalacao
ORDER BY mes_referencia DESC
LIMIT 12;
```

### GET Service Notes (Notas de Serviço)

```sql
SELECT 
    data_servico,
    tipo_servico,
    descricao,
    tecnico
FROM notas_servico
WHERE id_instalacao = :id_instalacao
ORDER BY data_servico DESC;
```

### GET Fraud History (Histórico de Fraudes)

```sql
SELECT 
    data_ocorrencia,
    tipo_fraude,
    descricao,
    valor_estimado
FROM fraudes
WHERE id_instalacao = :id_instalacao
ORDER BY data_ocorrencia DESC;
```

---

## Índices Recomendados

```sql
-- Índices espaciais (PostGIS)
CREATE INDEX idx_instalacoes_geom ON instalacoes USING GIST (geom);
CREATE INDEX idx_municipios_geom ON municipios USING GIST (geom);

-- Índices de FK
CREATE INDEX idx_resultado_principais_query ON resultado_queries_principais(id_query);
CREATE INDEX idx_resultado_principais_instalacao ON resultado_queries_principais(id_instalacao);
CREATE INDEX idx_resultado_auxiliares_query ON resultado_queries_auxiliares(id_query);
CREATE INDEX idx_resultado_auxiliares_instalacao ON resultado_queries_auxiliares(id_instalacao);

-- Índices de busca
CREATE INDEX idx_instalacoes_municipio ON instalacoes(municipio);
CREATE INDEX idx_fraudes_data ON fraudes(data_fraude);
CREATE INDEX idx_historico_mes ON historico_consumo(mes_referencia);
```

---

## Fluxo de Dados

### Workflow Principal:

1. **Usuário seleciona Query Principal** →  Query 2 (Main Query Results)
2. **Marcadores aparecem no mapa statewide** (sem filtro)
3. **Usuário seleciona Área** (município ou polígono)
4. **Usuário seleciona Queries Auxiliares** → Query 6 ou 7 (Auxiliary Results filtered)
5. **Marcadores auxiliares aparecem APENAS na área selecionada**

### Regras de Negócio:

- **Main Queries**: SEMPRE statewide (todo RN)
- **Auxiliary Queries**: SEMPRE filtradas pela área selecionada
- **Área**: NÃO aparece visualmente no mapa (apenas usada para filtro)
- **Polígono**: Desenhado com Leaflet.draw, salvo como GeoJSON, usado para filtro espacial

---

## Tecnologias Utilizadas

- **PostgreSQL 16+** com **PostGIS 3.4+**
- **SQLAlchemy** (ORM)
- **GeoAlchemy2** (extensão geoespacial)
- **FastAPI** (backend)
- **React + Leaflet** (frontend)
