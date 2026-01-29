# SASI - Sistema de Apoio à Seleção de Inspeções

<div align="center">

**Energy Fraud Inspection Mapping System**

Sistema web para identificação e seleção estratégica de instalações para inspeção de fraude de energia.

[![Python](https://img.shields.io/badge/Python-3.11+-blue.svg)](https://www.python.org/)
[![React](https://img.shields.io/badge/React-18+-61dafb.svg)](https://reactjs.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.109+-009688.svg)](https://fastapi.tiangolo.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16+-336791.svg)](https://www.postgresql.org/)
[![PostGIS](https://img.shields.io/badge/PostGIS-3.4+-4169E1.svg)](https://postgis.net/)

</div>

---

## 📋 Sobre o Projeto

O SASI é uma aplicação web moderna desenvolvida para apoiar analistas de fraude na identificação e seleção estratégica de instalações elétricas para inspeção. O sistema utiliza análise geoespacial para visualizar instalações suspeitas em um mapa interativo, permitindo decisões mais informadas e eficientes.

### 🎯 Objetivos

- Substituir aplicações monolíticas legadas por uma arquitetura moderna e escalável
- Fornecer visualização geográfica interativa de instalações suspeitas
- Permitir análise multi-critério através de queries principais e auxiliares
- Facilitar a seleção e priorização de alvos para inspeção
- Melhorar a eficiência operacional no combate à fraude de energia

### ✨ Funcionalidades Implementadas (Fase 1 e 2)

- ✅ Mapa base interativo do Rio Grande do Norte
- ✅ Seleção de queries principais com visualização simultânea
- ✅ Marcadores coloridos por query com diferenciação por tipo de alvo
- ✅ Sistema de cores: cada query possui cor única, com variação clara/escura para alvos fortes/regulares
- ✅ Painel resumo com contagem de instalações por query
- ✅ Popups informativos com detalhes das instalações
- ✅ API REST completa com endpoints para queries, instalações e áreas

---

## 🏗️ Arquitetura

### Stack Tecnológico

**Backend:**
- **FastAPI** - Framework web Python moderno e de alta performance
- **PostgreSQL 16+** - Banco de dados relacional
- **PostGIS 3.4+** - Extensão geoespacial para PostgreSQL
- **SQLAlchemy** - ORM para Python
- **GeoAlchemy2** - Extensão SQLAlchemy para tipos geoespaciais
- **Pydantic** - Validação de dados e serialização

**Frontend:**
- **React 18** - Biblioteca JavaScript para UI
- **Vite** - Build tool e dev server
- **Leaflet** - Biblioteca de mapas interativos open-source
- **React Leaflet** - Componentes React para Leaflet
- **Axios** - Cliente HTTP

**Infraestrutura:**
- Docker (em desenvolvimento)
- Git/GitHub para controle de versão

### Estrutura de Diretórios

```
SASI/
├── backend/                # Aplicação Python FastAPI
│   ├── src/
│   │   ├── db/            # Scripts SQL (schema, seed data)
│   │   ├── routes/        # Endpoints da API
│   │   ├── models.py      # Modelos SQLAlchemy
│   │   ├── schemas.py     # Schemas Pydantic
│   │   ├── database.py    # Configuração do banco
│   │   └── main.py        # Ponto de entrada da API
│   ├── requirements.txt   # Dependências Python
│   └── .env.example       # Exemplo de variáveis de ambiente
│
├── frontend/              # Aplicação React
│   ├── src/
│   │   ├── components/    # Componentes React
│   │   ├── services/      # Serviços (API client)
│   │   ├── App.jsx        # Componente principal
│   │   └── index.css      # Estilos globais
│   ├── package.json       # Dependências Node.js
│   └── vite.config.js     # Configuração Vite
│
├── README.md              # Este arquivo
└── SETUP_GUIDE.md         # Guia detalhado de instalação
```

---

## 🚀 Início Rápido

### Pré-requisitos

- **Python 3.11+**
- **Node.js 18+** e npm
- **PostgreSQL 16+** com extensão **PostGIS 3.4+**
- **Git**

### Instalação Rápida

```bash
# 1. Clone o repositório
git clone https://github.com/DuduRamone/sasi_antigravity.git
cd sasi_antigravity

# 2. Configure o banco de dados PostgreSQL
# Certifique-se que PostgreSQL está rodando e crie o banco

# 3. Configure o Backend
cd backend
python -m venv venv
source venv/bin/activate  # No Windows: venv\Scripts\activate
pip install -r requirements.txt

# Configure as variáveis de ambiente
cp .env.example .env
# Edite .env com suas credenciais do PostgreSQL

# Aplique o schema e dados de exemplo
psql -U postgres -d sasi2 -f src/db/schema_v2.sql
psql -U postgres -d sasi2 -f src/db/seed_sample_data_v2.sql

# Inicie o servidor backend
cd src
python main.py
# Backend rodando em http://localhost:8000

# 4. Configure o Frontend (em novo terminal)
cd frontend
npm install
npm run dev
# Frontend rodando em http://localhost:5173
```

Para instruções detalhadas, consulte **[SETUP_GUIDE.md](./SETUP_GUIDE.md)**.

---

## 📊 Modelo de Dados

### Entidades Principais

**Instalações** (`instalacoes`)
- Representa instalações elétricas com localização geográfica
- Campos: id, município, classe tarifária, latitude, longitude, geometria (Point)

**Queries Principais** (`queries_principais`)
- Consultas de análise statewide (todo RN)
- Campos: nome, descrição, **cor** (hex), ativa
- Exemplos: Alto Consumo Residencial, Variação Atípica, Classe Tarifária Inadequada

**Resultados de Queries** (`resultado_queries_principais`)
- Relação N:N entre queries e instalações
- Campos: id_query, id_instalacao, **tipo_alvo** (forte/regular), score
- **Tipo de alvo por instalação**: cada instalação possui classificação individual

**Queries Auxiliares** (`queries_auxiliares`)
- Consultas contextuais restritas a áreas específicas
- Retornam instalações ou heatmaps

### Mudanças Importantes

Na versão atual (v2), o **tipo de alvo** (forte/regular) foi movido do nível de query para o nível de **resultado por instalação**. Isso permite que uma mesma query contenha tanto alvos fortes quanto regulares, oferecendo maior flexibilidade analítica.

Cada query principal agora possui uma **cor única** em formato hexadecimal, permitindo diferenciação visual clara no mapa.

---

## 🗺️ Sistema de Cores

O sistema utiliza cores para facilitar a identificação visual:

| Query | Cor Base | Hex |
|-------|----------|-----|
| Alto Consumo Residencial | 🔵 Azul | `#3B82F6` |
| Variação Atípica | 🟢 Verde | `#10B981` |
| Classe Tarifária Inadequada | 🟠 Laranja | `#F59E0B` |
| Proximidade a Fraudes | 🔴 Vermelho | `#EF4444` |

**Variação por Tipo de Alvo:**
- **Alvos Regulares**: Tom mais escuro da cor base
- **Alvos Fortes**: Tom mais claro da cor base

---

## 🔌 API Endpoints

### Queries

```
GET  /api/queries/main                    # Lista queries principais
GET  /api/queries/main/{id}/results       # Resultados de query (GeoJSON)
GET  /api/queries/auxiliary               # Lista queries auxiliares
GET  /api/queries/auxiliary/{id}/results  # Resultados auxiliares
```

### Instalações

```
GET  /api/installations/{id}                    # Detalhes da instalação
GET  /api/installations/{id}/consumption        # Histórico de consumo
GET  /api/installations/{id}/frauds             # Fraudes registradas
GET  /api/installations/{id}/service-notes      # Notas de serviço
GET  /api/installations/{id}/status             # Status atual
PUT  /api/installations/{id}/status             # Atualizar status
```

### Áreas

```
GET  /api/areas/municipalities                     # Lista municípios
GET  /api/areas/municipalities/{name}/geometry    # Geometria do município
POST /api/areas/metrics                           # Métricas agregadas de área
```

Documentação interativa disponível em: `http://localhost:8000/docs`

---

## 📅 Roadmap de Desenvolvimento

### ✅ Fase 1 - Mapa Base e Estado Inicial (Concluída)
- [x] Estrutura do projeto (frontend + backend)
- [x] Banco PostgreSQL com PostGIS
- [x] Schema do banco de dados
- [x] Mapa base do Rio Grande do Norte
- [x] Estado vazio (sem dados sem query ativa)

### ✅ Fase 2 - Queries Principais (Concluída)
- [x] API de queries principais
- [x] Seletor de queries no sidebar
- [x] Marcadores no mapa (statewide)
- [x] Sistema de cores por query
- [x] Tipo de alvo por instalação (forte/regular)
- [x] Resumo de resultados

### 🚧 Fase 3 - Delimitação de Área (Próxima)
- [ ] Seletor de municípios
- [ ] Ferramenta de desenho de polígonos
- [ ] Restrição de visualização à área selecionada
- [ ] Atualização automática de bounds do mapa

### 📋 Fase 4 - Queries Auxiliares
- [ ] Ativação de queries auxiliares (apenas com área definida)
- [ ] Visualização de heatmap
- [ ] Controles de camadas (layer controls)

### 📋 Fase 5 - Detalhes de Instalação
- [ ] Painel/modal de detalhes
- [ ] Informações cadastrais
- [ ] Gráfico de histórico de consumo
- [ ] Histórico de notas de serviço

### 📋 Fase 6 - Análise Agregada de Área
- [ ] Cálculo de perímetro da área
- [ ] Contagem de fraudes (últimos 5 anos)
- [ ] Distribuição por classe tarifária
- [ ] Painel de métricas agregadas

### 📋 Fase 7 - Gestão de Status
- [ ] Seleção manual de instalações
- [ ] Atribuição de status (selecionada/não selecionada/verificar)
- [ ] Agrupamento por status
- [ ] Persistência de decisões

---

## 🤝 Contribuindo

Este projeto está em desenvolvimento ativo. Contribuições são bem-vindas!

### Diretrizes

1. Fork o repositório
2. Crie uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request

### Convenções de Código

- **Backend**: Siga PEP 8 para Python
- **Frontend**: Use ESLint e Prettier
- **Commits**: Mensagens claras e descritivas em português
- **SQL**: Use snake_case para nomes de tabelas e colunas

---

## 📝 Licença

Este projeto é proprietário e desenvolvido para fins específicos de combate à fraude de energia.

---

## 👥 Autores

- **Eduardo Ramon** - Desenvolvimento inicial - [@DuduRamone](https://github.com/DuduRamone)

---

## 🙏 Agradecimentos

- Equipe de análise de fraude pela validação dos requisitos
- Comunidade open-source pelas excelentes ferramentas utilizadas
- Antigravity AI Assistant pela assistência no desenvolvimento

---

## 📧 Contato

Para questões, sugestões ou suporte:
- Abra uma [Issue](https://github.com/DuduRamone/sasi_antigravity/issues)
- Entre em contato através do GitHub

---

<div align="center">

**Desenvolvido com ❤️ para combater fraude de energia**

</div>
