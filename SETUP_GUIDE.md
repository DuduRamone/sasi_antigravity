# SASI - Guia de Configuração Inicial

Este guia detalha os passos para configurar o ambiente de desenvolvimento do zero.

## Passo 1: Instalar PostgreSQL com PostGIS

### Windows

1. Baixe o instalador do PostgreSQL em: https://www.postgresql.org/download/windows/
2. Execute o instalador (versão 14 ou superior recomendada)
3. Durante a instalação:
   - Defina uma senha para o usuário `postgres` (anote esta senha!)
   - Porta padrão: `5432`
   - Locale: Portuguese, Brazil
4. Quando a instalação terminar, o **Stack Builder** será aberto automaticamente
5. No Stack Builder:
   - Selecione sua instalação do PostgreSQL
   - Navegue até **Spatial Extensions**
   - Selecione **PostGIS** (versão mais recente)
   - Complete a instalação

### Verificar Instalação

Abra o **pgAdmin 4** (instalado junto com PostgreSQL) ou abra o terminal e execute:

```bash
psql --version
# Deve mostrar: psql (PostgreSQL) 14.x ou superior
```

## Passo 2: Criar o Banco de Dados

### Opção A: Usando pgAdmin (Visual)

1. Abra pgAdmin 4
2. Conecte ao servidor local (senha definida na instalação)
3. Clique com botão direito em "Databases" → "Create" → "Database"
4. Nome: `sasi`
5. Owner: `postgres`
6. Clique em "Save"

### Opção B: Usando terminal (psql)

```bash
# Windows PowerShell
# Certifique-se de estar no diretório onde o PostgreSQL foi instalado
# Exemplo: C:\Program Files\PostgreSQL\14\bin

.\psql.exe -U postgres
# Digite sua senha quando solicitado

# No prompt do psql:
CREATE DATABASE sasi;
\q
```

## Passo 3: Executar Schema do Banco

```bash
# Navegue até a pasta do projeto
cd C:\Users\eduar\Desktop\SASI

# Execute o schema
psql -U postgres -d sasi -f backend\src\db\schema.sql
# Digite sua senha quando solicitado

# Execute os dados de exemplo
psql -U postgres -d sasi -f backend\src\db\seed_sample_data.sql
```

### Verificar se deu certo

```bash
psql -U postgres -d sasi

# Dentro do psql:
\dt
# Deve listar todas as tabelas criadas

SELECT COUNT(*) FROM instalacoes;
# Deve retornar 10 (10 instalações de exemplo)

\q
```

## Passo 4: Configurar Backend Python

### Instalar Python

Se não tiver Python instalado:
1. Baixe em: https://www.python.org/downloads/
2. Execute o instalador
3. **IMPORTANTE**: Marque "Add Python to PATH"
4. Versão recomendada: 3.10 ou superior

### Configurar Ambiente Virtual

```bash
# Navegue até a pasta do backend
cd C:\Users\eduar\Desktop\SASI\backend

# Crie o ambiente virtual
python -m venv venv

# Ative o ambiente virtual
.\venv\Scripts\activate
# Você verá (venv) no início da linha do terminal

# Instale as dependências
pip install -r requirements.txt
```

### Configurar Variáveis de Ambiente

1. Copie o arquivo de exemplo:
```bash
copy .env.example .env
```

2. Abra `.env` em um editor de texto e ajuste:
```env
DATABASE_URL=postgresql://postgres:SUA_SENHA_AQUI@localhost:5432/sasi
CORS_ORIGINS=http://localhost:5173
API_PORT=8000
DEBUG=True
```

**IMPORTANTE**: Substitua `SUA_SENHA_AQUI` pela senha do PostgreSQL que você definiu na instalação.

### Executar o Backend

```bash
# Certifique-se de estar na pasta backend com venv ativado
cd src
python main.py
```

Você deve ver:
```
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
INFO:     Started reloader process
INFO:     Started server process
INFO:     Waiting for application startup.
INFO:     Application startup complete.
```

Teste abrindo no navegador: http://localhost:8000/docs
Você verá a documentação interativa da API (Swagger UI).

## Passo 5: Configurar Frontend React

### Instalar Node.js

Se não tiver Node.js instalado:
1. Baixe em: https://nodejs.org/
2. Execute o instalador (versão LTS recomendada)
3. Aceite as opções padrão

### Verificar Instalação

```bash
node --version
# Deve mostrar: v18.x.x ou superior

npm --version
# Deve mostrar: 9.x.x ou superior
```

### Instalar Dependências

```bash
# Abra um NOVO terminal (deixe o backend rodando no outro)
cd C:\Users\eduar\Desktop\SASI\frontend

# Instale as dependências
npm install
```

Isso pode levar alguns minutos na primeira vez.

### Executar o Frontend

```bash
# Ainda na pasta frontend
npm run dev
```

Você deve ver:
```
  VITE v5.x.x  ready in xxx ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: use --host to expose
  ➜  press h to show help
```

## Passo 6: Testar a Aplicação

1. Abra o navegador em: http://localhost:5173/
2. Você deve ver o mapa do RN com uma mensagem de estado vazio
3. No painel lateral, selecione uma ou mais queries principais
4. Os marcadores devem aparecer no mapa

### Solução de Problemas

**Problema: "Erro ao carregar queries principais"**
- Verifique se o backend está rodando (http://localhost:8000/docs deve abrir)
- Verifique se o banco de dados está rodando
- Verifique as credenciais no arquivo `.env`

**Problema: Marcadores não aparecem**
- Abra o Console do navegador (F12)
- Verifique se há erros de API
- Teste a API diretamente em http://localhost:8000/docs

**Problema: "Module not found" no frontend**
- Delete a pasta `node_modules` e execute `npm install` novamente

**Problema: Erro de conexão com PostgreSQL**
- Verifique se o serviço PostgreSQL está rodando
- Windows: Abra "Serviços" e procure por "postgresql-x64-14"
- Se não estiver rodando, clique com botão direito → Iniciar

## Estrutura de Pastas Criada

```
SASI/
├── backend/
│   ├── src/
│   │   ├── db/
│   │   │   ├── schema.sql
│   │   │   └── seed_sample_data.sql
│   │   ├── routes/
│   │   │   ├── __init__.py
│   │   │   ├── queries.py
│   │   │   ├── installations.py
│   │   │   └── areas.py
│   │   ├── database.py
│   │   ├── models.py
│   │   ├── schemas.py
│   │   └── main.py
│   ├── venv/                  # Criado após setup
│   ├── .env                   # Criado por você
│   ├── .env.example
│   ├── .gitignore
│   └── requirements.txt
├── frontend/
│   ├── src/
│   │   ├── components/
│   │   │   ├── Map/
│   │   │   │   ├── BaseMap.jsx
│   │   │   │   └── InstallationMarkers.jsx
│   │   │   └── QuerySelector/
│   │   │       └── MainQuerySelector.jsx
│   │   ├── services/
│   │   │   └── api.js
│   │   ├── App.jsx
│   │   ├── index.css
│   │   └── main.jsx
│   ├── node_modules/          # Criado após npm install
│   ├── .gitignore
│   ├── index.html
│   ├── package.json
│   └── vite.config.js
└── README.md
```

## Próximos Passos

Agora que Phase 1 e Phase 2 estão implementados e funcionando, você pode:

1. **Testar funcionalidades atuais**:
   - Navegação do mapa
   - Seleção de queries principais
   - Visualização de marcadores

2. **Preparar para Phase 3**:
   - Seleção por município
   - Desenho de polígonos

3. **Personalizar dados**:
   - Adicione mais instalações em `seed_sample_data.sql`
   - Crie suas próprias queries principais

## Comandos Rápidos

```bash
# Iniciar backend
cd C:\Users\eduar\Desktop\SASI\backend
.\venv\Scripts\activate
cd src
python main.py

# Iniciar frontend (em outro terminal)
cd C:\Users\eduar\Desktop\SASI\frontend
npm run dev

# Acessar banco de dados
psql -U postgres -d sasi

# Reinstalar dependências do frontend
cd C:\Users\eduar\Desktop\SASI\frontend
rm -r node_modules
npm install
```

---

**Suporte**: Em caso de dúvidas ou problemas, verifique os logs do backend e do console do navegador.
