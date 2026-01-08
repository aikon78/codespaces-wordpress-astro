# WordPress + Astro - Guida Completa

## 📋 Panoramica

Questo progetto implementa un'architettura **Headless CMS** con:
- **Backend**: WordPress come CMS
- **Frontend**: Astro come framework frontend
- **Comunicazione**: API REST di WordPress

## 🚀 Avvio Rapido

### 1. Avviare WordPress

```bash
# Dalla root del progetto
docker-compose up -d

# O manualmente
cd cms
# Seguire le istruzioni in cms/README.md
```

Accedi a:
- **WordPress Admin**: http://localhost:8000/wp-admin
- **Database Manager**: http://localhost:8080 (phpMyAdmin)

### 2. Avviare Astro Frontend

```bash
cd frontend
npm install
npm run dev
```

Accedi a http://localhost:3000

## 📁 Struttura Progetto

```
.
├── cms/                        # WordPress CMS
│   └── README.md              # Setup WordPress
├── frontend/                   # Astro Frontend
│   ├── src/
│   │   ├── lib/
│   │   │   └── wordpress-api.ts  # Client API WordPress
│   │   ├── pages/
│   │   │   ├── index.astro       # Homepage
│   │   │   ├── about.astro       # Chi siamo
│   │   │   └── blog/
│   │   │       ├── index.astro   # Lista post
│   │   │       └── [...slug].astro # Pagina singolo post
│   │   ├── layouts/
│   │   │   └── BlogPost.astro    # Layout post
│   │   └── components/           # Componenti riutilizzabili
│   └── README.md
├── docker-compose.yml          # Orchestrazione servizi
└── README.md                   # Questo file
```

## 🔌 Integrazione API

### Client API (src/lib/wordpress-api.ts)

Il client fornisce metodi semplici per accedere a tutti i contenuti WordPress:

```typescript
import wordPressAPI from '../../lib/wordpress-api';

// Ottenere tutti i post
const posts = await wordPressAPI.getPosts();

// Post singolo per ID
const post = await wordPressAPI.getPost(1);

// Post per slug
const post = await wordPressAPI.getPostBySlug('mio-post');

// Categorie
const categories = await wordPressAPI.getCategories();

// Pagine statiche
const page = await wordPressAPI.getPageBySlug('chi-siamo');
```

### Parametri API

Puoi passare parametri a qualsiasi metodo:

```typescript
// Paginazione
const posts = await wordPressAPI.getPosts({ 
  per_page: 10, 
  page: 1 
});

// Con contenuti correlati
const posts = await wordPressAPI.getPosts({ 
  _embed: true 
});

// Filtrare per categoria
const posts = await wordPressAPI.getPosts({ 
  categories: [1, 2, 3] 
});
```

## 🛠️ Configurazione CORS

Per comunicare da `localhost:3000` a `localhost:8000`, WordPress deve avere CORS abilitato.

Aggiungi a `wp-config.php`:

```php
add_filter( 'rest_pre_serve_request', function( $served, $server, $request ) {
    $origin = get_http_origin();
    if ( $origin === 'http://localhost:3000' ) {
        header( 'Access-Control-Allow-Origin: ' . esc_url_raw( $origin ) );
        header( 'Access-Control-Allow-Credentials: true' );
        header( 'Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS' );
        header( 'Access-Control-Allow-Headers: Authorization, Content-Type' );
    }
    return $served;
}, 10, 3 );
```

## 📝 Creare Contenuti su WordPress

1. Accedi a http://localhost:8000/wp-admin
2. Crea post, categorie, tag
3. I contenuti appariranno automaticamente su Astro

## 🎨 Personalizzazione Astro

### Aggiungere React

```bash
cd frontend
npx astro add react
```

### Aggiungere Tailwind

```bash
cd frontend
npx astro add tailwind
```

### Aggiungere un Framework

```bash
cd frontend
npx astro add [vue|svelte|solid|preact]
```

## 📦 Build per Produzione

### Astro
```bash
cd frontend
npm run build
npm run preview
```

### WordPress
```bash
docker-compose -f docker-compose.prod.yml up -d
```

## 🌐 Deployment

### Frontend Astro

Supportato su:
- **Vercel**: https://vercel.com
- **Netlify**: https://netlify.com
- **GitHub Pages**: con SSG
- **Traditional Server**: con `npm run build`

### WordPress

- **Managed Hosting**: WP Engine, Kinsta
- **VPS**: DigitalOcean, Linode
- **Docker**: AWS ECS, Google Cloud Run

## 🔒 Sicurezza

1. Cambia le credenziali di default in `docker-compose.yml`
2. Abilita JWT Authentication su WordPress
3. Usa HTTPS in produzione
4. Implementa rate limiting su API

## 📚 Risorse

- [Documentazione Astro](https://docs.astro.build)
- [API REST WordPress](https://developer.wordpress.org/rest-api/)
- [Astro Content Collections](https://docs.astro.build/en/guides/content-collections/)

## 💡 Prossimi Passi

1. Personalizza il design di Astro
2. Aggiungi un form di contatto
3. Implementa commenti
4. Aggiungi funzionalità di ricerca
5. Configura sitemap e SEO
6. Implementa cache e CDN

## 🤝 Supporto

Per domande o problemi, consulta:
- [Forum Astro](https://astro.build/chat)
- [Forum WordPress](https://wordpress.org/support/)
- [Stack Overflow](https://stackoverflow.com)
