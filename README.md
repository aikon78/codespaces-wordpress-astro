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

**L'URL di WordPress verrà configurato automaticamente per Codespaces.**

O manualmente:

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

## ⚙️ Architettura URL WordPress

**PRINCIPIO CHIAVE:** WordPress usa il **database** come fonte autoritativa per il dominio, non variabili d'ambiente o file di configurazione.

### Come Funziona

```
┌─────────────────────────────────────────────────────────────┐
│  DATABASE (wp_options) - FONTE AUTORITATIVA                 │
│  • wp_options.siteurl = https://example.com                 │
│  • wp_options.home = https://example.com                    │
└─────────────────────────────────────────────────────────────┘
              ↑                              ↑
              │                              │
    ┌─────────┴────────┐         ┌──────────┴──────────┐
    │ install-wordpress.sh│         │ setup-wordpress-url.sh│
    │ Scrive URL nel DB   │         │ Aggiorna URL nel DB   │
    └─────────────────────┘         └─────────────────────┘

         ↓ WordPress legge dal DB            ↓ Frontend chiama API

┌──────────────────────┐         ┌────────────────────────┐
│ wp-config.php        │         │ frontend/.env          │
│ • NO WP_HOME         │         │ PUBLIC_WORDPRESS_URL=  │
│ • NO WP_SITEURL      │         │ https://example.com    │
│ • Solo proxy headers │         └────────────────────────┘
└──────────────────────┘
```

### Workflow Cambio Dominio

1. **Prima installazione**: `install-wordpress.sh` scrive URL nel database
2. **Cambio ambiente**: `setup-wordpress-url.sh` aggiorna database
3. **Frontend**: Aggiorna `frontend/.env` con stesso URL
4. **WordPress**: Legge automaticamente dal database (nessuna modifica necessaria)

### Sviluppo Locale

```bash
# install-wordpress.sh scrive: http://localhost:8000 nel DB
docker-compose up -d
bash install-wordpress.sh
```

### GitHub Codespaces

```bash
# install-wordpress.sh auto-rileva e scrive: https://{CODESPACE_NAME}-8000.app.github.dev
bash install-wordpress.sh
# Verifica URL nel pannello PORTS
```

### Cambio Dominio (es: Codespaces → Produzione)

```bash
# 1. Aggiorna il database WordPress
export WORDPRESS_URL=https://example.com
bash setup-wordpress-url.sh

# 2. Aggiorna frontend
echo "PUBLIC_WORDPRESS_URL=https://example.com" > frontend/.env

# 3. Riavvia servizi
docker-compose restart
```

### Ambienti Supportati

| Ambiente       | URL Esempio                        | Come impostarlo                        |
| -------------- | ---------------------------------- | -------------------------------------- |
| **Locale**     | `http://localhost:8000`            | Default, nessuna configurazione        |
| **Codespaces** | `https://name-8000.app.github.dev` | Auto-rilevato da `CODESPACE_NAME`      |
| **Staging**    | `https://staging.example.com`      | `export WORDPRESS_URL=...`             |
| **Produzione** | `https://example.com`              | File `.env` + `setup-wordpress-url.sh` |

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
├── setup-wordpress-url.sh      # Script configurazione URL dinamica
├── .env.example                # Template variabili d'ambiente
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
import wordPressAPI from "@/lib/wordpress-api";

// Ottenere post
const posts = await wordPressAPI.getPosts();

// Singolo post
const post = await wordPressAPI.getPost(1);

// Post per slug
const post = await wordPressAPI.getPostBySlug("mio-post");
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

### "WordPress rimane legato a localhost"

Se WordPress continua a reindirizzare a `localhost:8000` anche dopo essere in Codespaces:

```bash
# Soluzione automatica (consigliata)
make update-url
```

Per una guida completa: [WORDPRESS_LOCALHOST_FIX.md](WORDPRESS_LOCALHOST_FIX.md)

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
