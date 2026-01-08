# WordPress + Astro Headless CMS Project

Un progetto moderno che combina **WordPress** come CMS backend con **Astro** come frontend framework.

## Struttura del Progetto

```
├── cms/                    # WordPress CMS backend
├── frontend/               # Astro frontend
├── docker-compose.yml      # Orchestrazione servizi
└── README.md              # Questo file
```

## Configurazione Rapida

### 1. Backend WordPress

```bash
cd cms
# Segui le istruzioni in cms/README.md
```

### 2. Frontend Astro

```bash
cd frontend
npm install
npm run dev
```

## API Integration

Il frontend Astro si connette al backend WordPress tramite l'API REST di WordPress disponibile su:
```
http://localhost:8000/wp-json/wp/v2/
```

## Requisiti

- Docker & Docker Compose (per il setup completo)
- Node.js 18+ (per Astro)
- npm/yarn

## Sviluppo

- **WordPress Admin**: http://localhost:8000/wp-admin
- **Frontend Astro**: http://localhost:3000

## Deployment

Vedi la documentazione in ogni cartella (cms/ e frontend/) per le istruzioni di deployment.
