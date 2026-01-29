# SASI - Sistema de Apoio à Seleção de Inspeções

Sistema de mapa interativo para otimização de inspeções de fraude de energia elétrica no Rio Grande do Norte.

![SASI Interface](https://img.shields.io/badge/Status-Phase%204%20Complete-success)
![Tech Stack](https://img.shields.io/badge/Stack-React%20%7C%20FastAPI%20%7C%20PostGIS-blue)

## 🎯 Visão Geral

O SASI é uma ferramenta de análise geoespacial que auxilia analistas a identificar e priorizar alvos para inspeções de combate à fraude de energia. O sistema combina dados cadastrais, histórico de consumo, e análises preditivas para visualizar padrões suspeitos em um mapa interativo.

### Status do Projeto

✅ **Phase 1** - Mapa base com limites do RN  
✅ **Phase 2** - Queries principais (distribuição statewide)  
✅ **Phase 3** - Seleção de área (municípios + polígonos)  
✅ **Phase 4** - Queries auxiliares (marcadores + heatmaps)  
🚧 **Phase 5** - Painel de detalhes por instalação (próximo)

---

## 🚀 Features Implementadas

### Phase 1 & 2 - Visualização Básica
- ✅ Mapa interativo do Rio Grande do Norte
- ✅ 4 queries principais com cores distintas
- ✅ Marcadores diferenciados por tipo (forte/regular)
- ✅ Popup com informações básicas da instalação
- ✅ Filtros de query ativados via checkboxes

### Phase 3 - Seleção de Área
- ✅ **Seleção por Município** - Dropdown com 4 municípios do RN
- ✅ **Desenho de Polígono** - Usando Leaflet Geoman para delimitação customizada
- ✅ Limpeza de área selecionada
- ✅ Queries auxiliares habilitadas após seleção de área

### Phase 4 - Queries Auxiliares
- ✅ **Marcadores** - Instalações filtradas por área (quadrados roxos)
- ✅ **Heatmap** - Visualização de densidade com gradiente roxo→magenta→laranja→vermelho
- ✅ 4 queries auxiliares:
  - 📍 Densidade Populacional (heatmap)
  - 🔧 Histórico de Manutenção (marcadores)
  - 📊 Consumo por Classe (heatmap)
  - ⚠️ Instalações Críticas (marcadores)

---

## 🛠️ Tech Stack

### Backend
- **FastAPI** - Framework Python assíncrono
- **PostgreSQL 17** + **PostGIS 3.4** - Banco geoespacial
- **SQLAlchemy** + **GeoAlchemy2** - ORM com suporte espacial
- **Python 3.11+**

### Frontend
- **React 18** + **Vite** - SPA moderna e rápida
- **React Leaflet** - Mapa interativo
- **Leaflet Geoman** - Desenho de polígonos
- **leaflet.heat** - Visualização de heatmaps

---

## 📦 Instalação

### Pré-requisitos

- **Node.js 18+** e **npm**
- **Python 3.11+**
- **PostgreSQL 17** com extensão **PostGIS**

### 1. Clone o Repositório

```bash
git clone https://github.com/seu-usuario/sasi.git
cd sasi
```

### 2. Backend Setup

```bash
cd backend

# Criar ambiente virtual
python -m venv venv
.\venv\Scripts\activate  # Windows
# source venv/bin/activate  # Linux/Mac

# Instalar dependências
pip install -r requirements.txt

# Configurar variáveis de ambiente
copy .env.example .env
# Edite .env com suas credenciais PostgreSQL

# Criar banco de dados
createdb -U postgres sasi2

# Executar schema
psql -U postgres -d sasi2 -f src/db/schema_v2.sql

# Popular dados de exemplo
psql -U postgres -d sasi2 -f src/db/seed_sample_data_v2.sql
psql -U postgres -d sasi2 -f src/db/seed_more_data.sql

# Iniciar servidor
cd src
python main.py
```

Backend rodará em: **http://localhost:8000**

### 3. Frontend Setup

```bash
cd frontend

# Instalar dependências
npm install

# Iniciar dev server
npm run dev
```

Frontend rodará em: **http://localhost:5173**

---

## 📖 Uso

### Workflow Básico

1. **Selecione Queries Principais**
   - Marque uma ou mais queries no painel esquerdo
   - Círculos aparecem no mapa (todo RN)
   - Cores diferentes por query
   - Tamanhos diferentes: forte (maior) vs regular (menor)

2. **Delimite Área de Interesse** (opcional)
   - **Município**: Escolha no dropdown
   - **Polígono**: Clique em "Desenhar Polígono" → use ferramentas no canto superior direito do mapa

3. **Adicione Queries Auxiliares** (requer área selecionada)
   - Marque queries auxiliares desejadas
   - **Densidade Populacional**: Heatmap roxo→vermelho
   - **Histórico de Manutenção**: Quadrados roxos
   - Etc.

4. **Interaja com Marcadores**
   - Clique em qualquer marcador para ver popup com detalhes
   - (Phase 5: painel lateral com informações completas)

---

## 🗺️ Estrutura do Projeto

```
SASI/
├── backend/
│   ├── src/
│   │   ├── db/
│   │   │   ├── schema_v2.sql           # Schema do banco
│   │   │   ├── seed_sample_data_v2.sql # Dados iniciais
│   │   │   └── seed_more_data.sql      # Dados adicionais
│   │   ├── routes/
│   │   │   ├── queries.py              # Endpoints de queries
│   │   │   ├── areas.py                # Endpoints de áreas
│   │   │   └── temp_bulk_insert.py     # Bulk insert (temp)
│   │   ├── models.py                   # Modelos SQLAlchemy
│   │   ├── schemas.py                  # Schemas Pydantic
│   │   ├── database.py                 # Conexão DB
│   │   └── main.py                     # FastAPI app
│   └── requirements.txt
├── frontend/
│   ├── src/
│   │   ├── components/
│   │   │   ├── Map/
│   │   │   │   ├── BaseMap.jsx         # Mapa base + Geoman
│   │   │   │   ├── InstallationMarkers.jsx
│   │   │   │   └── Heatmap.jsx         # Visualização heatmap
│   │   │   ├── QuerySelector/
│   │   │   │   ├── MainQuerySelector.jsx
│   │   │   │   └── AuxiliaryQuerySelector.jsx
│   │   │   └── AreaSelector/
│   │   │       └── AreaSelector.jsx    # Município + Polígono
│   │   ├── services/
│   │   │   └── api.js                  # Cliente API
│   │   ├── App.jsx                     # Componente principal
│   │   └── main.jsx
│   └── package.json
├── DATABASE_QUERIES.md                 # Documentação SQL completa
└── README.md
```

---

## 🔧 API Endpoints

### Queries Principais
- `GET /api/queries/main` - Lista queries principais
- `GET /api/queries/main/{id}/results` - Resultados de query (statewide)

### Queries Auxiliares
- `GET /api/queries/auxiliary` - Lista queries auxiliares
- `GET /api/queries/auxiliary/{id}/results?area_type=municipio&area_value=Natal` - Resultados filtrados

### Áreas
- `GET /api/areas/municipalities` - Lista municípios
- `GET /api/areas/municipalities/{nome}/geometry` - Geometria do município

Ver [`DATABASE_QUERIES.md`](./DATABASE_QUERIES.md) para queries SQL completas.

---

## 🎨 Características Visuais

### Marcadores Principais (Círculos)
- **Cor**: Cor da query (azul, verde, laranja, vermelho)
- **Tamanho**: 20px (forte) / 16px (regular)
- **Opacidade**: 100% (forte) / 85% (regular)

### Marcadores Auxiliares (Quadrados)
- **Cor**: Roxo/magenta
- **Tamanho**: 12px
- **Forma**: Quadrado (para diferenciar de principais)

### Heatmap
- **Gradiente**: Roxo → Magenta → Laranja → Vermelho
- **Raio**: 35px
- **Opacidade**: 30-100%
- **Otimizado para**: Fundos claros (OpenStreetMap)

---

## 📊 Modelo de Dados

### Tabelas Principais
- `instalacoes` - Instalações elétricas com geometria
- `queries_principais` - Definição de queries principais
- `queries_auxiliares` - Definição de queries auxiliares
- `resultado_queries_principais` - Resultados por instalação
- `resultado_queries_auxiliares` - Resultados auxiliares (com intensidade)
- `municipios` - Municípios do RN (MULTIPOLYGON)

### Queries Espaciais

**Filtro por município:**
```sql
WHERE i.municipio = 'Natal'
```

**Filtro por polígono:**
```sql
WHERE ST_Contains(ST_GeomFromGeoJSON(:polygon), i.geom)
```

---

## 🐛 Troubleshooting

### Backend não inicia
- Verifique PostgreSQL rodando: `pg_ctl status`
- Confirme extensão PostGIS: `SELECT PostGIS_version();`
- Verifique `.env` com credenciais corretas

### Frontend não conecta ao backend
- Backend deve rodar em `http://localhost:8000`
- Verifique CORS configurado corretamente em `main.py`
- Teste API: `curl http://localhost:8000/health`

### Heatmap não aparece
- Mínimo ~20 pontos necessários para visibilidade
- Área deve estar selecionada (município ou polígono)
- Query auxiliar deve ter `tipo_retorno='heatmap'`

### Polígono não desenha
- Verifique modo "Desenhar Polígono" ativado
- Controles devem aparecer no canto superior direito
- Leaflet Geoman instalado: `npm list @geoman-io/leaflet-geoman-free`

---

## 🚀 Próximos Passos (Phase 5)

- [ ] Painel lateral de detalhes da instalação
- [ ] Gráficos de histórico de consumo
- [ ] Histórico de notas de serviço
- [ ] Registro de fraudes anteriores
- [ ] Status de seleção (selecionado/verificar/não selecionado)
- [ ] Exportação de lista de inspeções

---

## 📄 Licença

Este projeto é proprietário e confidencial.

---

## 👥 Contato

Para dúvidas ou suporte, entre em contato com a equipe de desenvolvimento.

---

**Versão**: 0.4.0 (Phase 4 Complete)  
**Última atualização**: Janeiro 2026
