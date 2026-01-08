# WordPress + Astro Headless CMS Project

Un progetto moderno che combina **WordPress** come CMS backend con **Astro** come frontend framework.

## 🚀 Quick Start

### GitHub Codespaces (Consigliato)

```bash
# Tutto si avvia automaticamente!
# Il progetto gira al 100% in GitHub Codespaces
bash setup.sh
# o semplicemente
npm run start
```

**O manualmente:**
```bash
make start      # Avvia Docker + Astro dev server
make dev        # Dev mode con log
```

### Setup Locale

```bash
# 1. Assicurati di avere Docker e Node.js 18+
# 2. Esegui lo script di setup
bash setup.sh

# 3. In un altro terminale, avvia Astro
cd frontend
npm run dev
```

## Struttura del Progetto

```
.
├── .devcontainer/              # Configurazione GitHub Codespaces
│   ├── devcontainer.json
│   ├── post-create.sh
│   └── post-start.sh
├── cms/                        # WordPress CMS backend
├── frontend/                   # Astro frontend
├── docker-compose.yml          # Orchestrazione servizi
├── Makefile                    # Comandi utili
├── CODESPACES.md               # Guida GitHub Codespaces
├── SETUP.md                    # Guida setup dettagliata
└── README.md                   # Questo file
```

## ⚙️ Configurazione Rapida

### 1. Backend WordPress
- **URL**: http://localhost:8000
- **Admin**: http://localhost:8000/wp-admin
- **API REST**: http://localhost:8000/wp-json/wp/v2/

### 2. Frontend Astro
- **URL**: http://localhost:3000
- **Dev Server**: Auto-refresh quando modifichi i file

### 3. Database Manager
- **phpMyAdmin**: http://localhost:8080
- **User**: `wordpress_user`
- **Pass**: `wordpress_pass`

## 📚 Comandi Utili

```bash
# Avviare tutto
make start              # Avvia Docker + Astro

# Docker
make docker-up         # Avvia servizi Docker
make docker-down       # Arresta servizi Docker
make docker-logs       # Visualizza log

# Frontend
make build             # Build Astro
make preview           # Preview build

# Vedi tutti i comandi
make help
```

## 🔌 API Integration

Il frontend Astro si connette al backend WordPress tramite l'API REST:

```typescript
import wordPressAPI from '@/lib/wordpress-api';

// Ottenere post
const posts = await wordPressAPI.getPosts();

// Singolo post
const post = await wordPressAPI.getPost(1);

// Post per slug
const post = await wordPressAPI.getPostBySlug('mio-post');
```

## 📋 Requisiti

- **GitHub Codespaces** (tutto incluso) oppure
- **Docker & Docker Compose** (per setup locale)
- **Node.js 18+** (per Astro)

## 🌐 Deployment

### Frontend (Astro)
```bash
cd frontend
npm run build      # Build statica
npm run preview    # Anteprima locale

# Deploy su Vercel
vercel            # Segui le istruzioni
```

### Backend (WordPress)
Consulta `docker-compose.prod.yml` per il deployment in produzione su server con Docker.

## 📖 Documentazione

- **[CODESPACES.md](CODESPACES.md)** - Guida completa per GitHub Codespaces ⭐
- **[SETUP.md](SETUP.md)** - Guida dettagliata setup locale
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Come contribuire

## 🆘 Troubleshooting

### "WordPress non carica"
```bash
docker-compose logs wordpress
docker-compose restart wordpress
```

### "Astro non vede i post"
- Verifica che WordPress sia online: http://localhost:8000
- Controlla la console del browser
- Verifica i parametri API in `frontend/src/lib/wordpress-api.ts`

### CORS errors
- Verifica `cms/cors-config.php`
- Riavvia WordPress: `docker-compose restart wordpress`

## 📚 Risorse

- **[Astro Docs](https://docs.astro.build)** - Framework frontend
- **[WordPress REST API](https://developer.wordpress.org/rest-api/)** - Documentazione API
- **[GitHub Codespaces](https://docs.github.com/en/codespaces)** - Dev environment cloud
- **[Docker Docs](https://docs.docker.com)** - Container orchestration

## 📝 Note

Questo progetto è configurato per girare al 100% su GitHub Codespaces. Tutto quello che ti serve è un account GitHub!

Per contribuire o segnalare bug, consulta [CONTRIBUTING.md](CONTRIBUTING.md)
