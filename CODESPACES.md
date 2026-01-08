# 🚀 Guida GitHub Codespaces - WordPress + Astro

## Avvio Automatico

Il progetto è configurato per avviarsi automaticamente in GitHub Codespaces. Alla creazione dello spazio:

1. ✅ Le dipendenze Astro vengono installate automaticamente
2. ✅ I servizi Docker vengono avviati automaticamente all'apertura

## Primo Avvio Manuale

Se desideri riavviare manualmente tutto:

```bash
# Dalla root del progetto
npm run start
```

Oppure manualmente:

```bash
# Avvia WordPress e database
docker-compose up -d

# Avvia Astro frontend
cd frontend && npm run dev
```

## Accesso ai Servizi

Una volta avviato, puoi accedere a:

### WordPress (CMS)
- URL: **WordPress Editor**: http://localhost:8000
- **WordPress Admin**: http://localhost:8000/wp-admin
- **API REST**: http://localhost:8000/wp-json/wp/v2/

**Credenziali Iniziali** (da completare al primo accesso):
- Username: `wordpress`
- Email: `admin@example.com`

### Astro Frontend
- URL: http://localhost:3000
- Auto-reload quando modifichi i file

### Database Manager (phpMyAdmin)
- URL: http://localhost:8080
- Utente: `wordpress_user`
- Password: `wordpress_pass`

## Workflow di Sviluppo

### 1. Aggiungere Contenuti in WordPress

```bash
# Accedi a WordPress Admin
http://localhost:8000/wp-admin

# Crea:
# - Post (blog)
# - Pagine statiche
# - Categorie
# - Allegati/Immagini
```

### 2. Accedere ai Dati in Astro

```typescript
// In frontend/src/lib/wordpress-api.ts
// Esempi di utilizzo:

import wordPressAPI from '@/lib/wordpress-api';

// Ottenere tutti i post
const posts = await wordPressAPI.getPosts();

// Singolo post
const post = await wordPressAPI.getPost(1);

// Post per slug
const post = await wordPressAPI.getPostBySlug('mio-post');

// Categorie
const categories = await wordPressAPI.getCategories();

// Pagine
const page = await wordPressAPI.getPageBySlug('chi-siamo');
```

### 3. Componenti Astro

```bash
# I componenti sono in:
frontend/src/components/

# Esempio di utilizzo in una pagina:
# frontend/src/pages/index.astro
```

## Build e Test

### Testare in Locale

```bash
# Frontend
cd frontend
npm run dev        # Dev server
npm run build      # Build statica
npm run preview    # Anteprima build

# WordPress API
curl http://localhost:8000/wp-json/wp/v2/posts
```

### Fare il Deploy

#### Frontend (Astro)
```bash
cd frontend
npm run build

# Su Vercel
npm install -g vercel
vercel

# Su Netlify
# Connetti il repo a Netlify direttamente
```

#### Backend (WordPress)
Configurare il deploy su un server Docker in produzione usando `docker-compose.prod.yml`

## Comandi Utili

```bash
# Visualizzare log dei container
docker-compose logs -f wordpress

# Arrestare servizi
docker-compose down

# Riavviare servizi
docker-compose restart

# Pulire tutto (attenzione: cancella i dati)
docker-compose down -v

# Installare una dipendenza Astro
cd frontend
npm install nome-pacchetto
```

## Problemi Comuni

### "Connection refused" su WordPress

```bash
# Verifica che i container siano avviati
docker-compose ps

# Se non sono avviati:
docker-compose up -d

# Attendi qualche secondo e riprova
```

### Modifiche Astro non ricaricate

```bash
# Ferma il dev server (Ctrl+C)
# Riavvia:
cd frontend && npm run dev
```

### CORS errors

Verifica che `cms/cors-config.php` contenga il dominio Codespace. Di solito è già configurato, ma se necessario:

```bash
# Modifica cms/cors-config.php
# Aggiungi il dominio alla whitelist
# Riavvia: docker-compose restart wordpress
```

### Accesso ai file WordPress

I file di WordPress sono in `cms/wordpress/`. Puoi modificarli direttamente per aggiungere plugin/temi.

## Struttura Progetto Codespaces

```
.
├── .devcontainer/
│   ├── devcontainer.json          # Configurazione Codespaces
│   ├── post-create.sh             # Script post-creazione
│   └── post-start.sh              # Script post-avvio
├── cms/                           # WordPress
│   ├── wordpress/                 # (ignorato in git)
│   ├── cors-config.php            # Configurazione CORS
│   └── php.ini                    # Configurazione PHP
├── frontend/                      # Astro
│   ├── src/
│   │   ├── lib/
│   │   │   └── wordpress-api.ts   # Client API
│   │   ├── pages/
│   │   ├── components/
│   │   └── layouts/
│   └── package.json
├── docker-compose.yml             # Orchestrazione
└── CODESPACES.md                  # Questo file
```

## Prossimi Passi Suggeriti

1. **Personalizzare il Design**
   - Modifica componenti in `frontend/src/components/`
   - Aggiungi stylesheet in `frontend/src/styles/`

2. **Aggiungere un Blog**
   - Crea pagine post con `frontend/src/pages/blog/[...slug].astro`
   - Fetch post da WordPress API

3. **Implementare Ricerca**
   - Aggiungi endpoint custom in WordPress
   - Integra in Astro con client API

4. **SEO e Performance**
   - Astro genera HTML statico (molto veloce)
   - Aggiungi sitemap: `npm install @astrojs/sitemap`
   - Configura og:image nelle pagine

5. **Autenticazione** (opzionale)
   - Per form commenti o accesso utente
   - Usa JWT Authentication plugin WordPress

## Risorse Utili

- **Astro**: https://docs.astro.build
- **WordPress API**: https://developer.wordpress.org/rest-api/
- **Docker**: https://docs.docker.com
- **GitHub Codespaces**: https://docs.github.com/en/codespaces

---

**Domande?** Consulta il file `README.md` o la documentazione ufficiale dei progetti utilizzati.
