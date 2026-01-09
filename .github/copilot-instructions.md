<!-- copilot-instructions.md -->

# WordPress + Astro Headless CMS - Istruzioni per lo Sviluppo

## Panoramica Progetto

Questo è un progetto headless CMS che combina:

- **Backend**: WordPress (CMS)
- **Frontend**: Astro (Framework statico/dinamico)
- **API**: REST API di WordPress per la comunicazione

## Struttura Progetto

```
/
├── cms/                           # Backend WordPress
│   ├── wordpress/                 # (ignorato in git)
│   ├── cors-config.php           # Configurazione CORS
│   ├── php.ini                    # Configurazione PHP
│   └── README.md
├── frontend/                       # Frontend Astro
│   ├── src/
│   │   ├── lib/wordpress-api.ts   # Client API
│   │   ├── pages/
│   │   │   ├── index.astro        # Homepage
│   │   │   ├── blog/              # Blog
│   │   │   └── ...
│   │   └── components/            # Componenti riutilizzabili
│   └── package.json
├── docker-compose.yml             # Orchestrazione servizi
├── setup.sh                       # Script setup automatico
├── SETUP.md                       # Guida setup
└── README.md                      # Panoramica progetto
```

## Avvio Rapido

### Opzione 1: Script Automatico

```bash
./setup.sh
```

### Opzione 2: Manuale

```bash
# 1. Avvia i servizi Docker
docker-compose up -d

# 2. Attendi che WordPress sia pronto
sleep 15

# 3. Installa e avvia Astro
cd frontend
npm install
npm run dev
```

## Sviluppo

### WordPress Admin

- URL: http://localhost:8000/wp-admin
- Crea post, categorie, media

### Astro Frontend

- URL: http://localhost:3000
- Auto-refresh quando cambi i file
- Fetch automatico da WordPress

### Database Manager

- URL: http://localhost:8080 (phpMyAdmin)
- User: `wordpress_user`
- Password: `wordpress_pass`

## API Integration

### Configurazione URL WordPress

L'URL del backend WordPress è configurabile tramite variabili d'ambiente:

**frontend/.env**:

```env
# Sviluppo locale
PUBLIC_WORDPRESS_URL=http://localhost:8000

# Produzione
PUBLIC_WORDPRESS_URL=https://your-domain.com
```

Il sistema rileva automaticamente l'ambiente:

1. Se `PUBLIC_WORDPRESS_URL` è definito, usa quello
2. Se in Codespaces, usa `localhost:8000` (rete interna Docker)
3. Altrimenti fallback a `localhost:8000`

### Client API (src/lib/wordpress-api.ts)

```typescript
import {
  getPosts,
  getPost,
  getCategories,
  getPostBySlug,
} from "@/lib/wordpress-api";

// Posts
const posts = await getPosts();
const post = await getPost(1);
const postBySlug = await getPostBySlug("my-post");

// Categories
const categories = await getCategories();
```

### Aggiungere Nuove Features API

Modifica `frontend/src/lib/wordpress-api.ts`:

```typescript
async getCustomEndpoint(params?: Record<string, any>) {
  try {
    const response = await this.client.get('/custom-endpoint', { params });
    return response.data;
  } catch (error) {
    console.error('Error:', error);
    throw error;
  }
}
```

## Build e Deployment

### Frontend

```bash
cd frontend
npm run build    # Crea build statica
npm run preview  # Anteprima locale

# Deploy su Vercel
npm run build && vercel
```

### Backend

```bash
docker-compose up -d  # Deploy su server

# Con file di produzione
docker-compose -f docker-compose.prod.yml up -d
```

## Plugin WordPress Consigliati

- **WP REST Filter** - Funzionalità REST avanzate
- **JWT Authentication** - Autenticazione API sicura
- **Advanced Custom Fields (ACF)** - Custom fields avanzati
- **WordLift** - SEO e structured data

## Configurazione CORS

WordPress è già configurato con CORS nel file `cms/cors-config.php`.

Per aggiungere altri domini:

1. Modifica `cms/cors-config.php`
2. Aggiungi il dominio a `$allowed_origins`
3. Riavvia i container: `docker-compose restart wordpress`

## Environment Variables

Copia `.env.example` a `.env`:

```bash
cp frontend/.env.example frontend/.env
```

## Troubleshooting

### WordPress non carica

```bash
docker-compose logs wordpress
docker-compose restart wordpress
```

### CORS errors

- Verifica `cms/cors-config.php`
- Assicurati che l'URL sia nella whitelist

### Astro non vede i post

- Verifica che WordPress sia online: http://localhost:8000
- Controlla la console del browser per gli errori
- Verifica i parametri API in `src/lib/wordpress-api.ts`

## Testing Locale

```bash
# Testare l'API manualmente
curl http://localhost:8000/wp-json/wp/v2/posts

# Testare il frontend
cd frontend && npm run dev
```

## SEO e Performance

- Astro genera HTML statico (molto veloce)
- Integra sitemap automaticamente
- Usa canonical URLs
- Supporta OpenGraph

## Prossimi Passi

1. Personalizza il design Astro
2. Aggiungi un form di contatto
3. Implementa commenti
4. Aggiungi search full-text
5. Configura analytics (Google Analytics, Plausible)
6. Implementa cache e CDN
7. Aggiungi autenticazione (JWT)

## Risorse Utili

- [Docs Astro](https://docs.astro.build)
- [API REST WordPress](https://developer.wordpress.org/rest-api/)
- [Docker Documentation](https://docs.docker.com)
