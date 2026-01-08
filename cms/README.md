# WordPress CMS Backend

Backend WordPress configurato come CMS headless.

## Setup Locale

### Opzione 1: Docker Compose (Consigliato)

Dalla root del progetto:
```bash
docker-compose up -d
```

Accedi a:
- **WordPress Admin**: http://localhost:8000/wp-admin
- **API REST**: http://localhost:8000/wp-json/wp/v2/

### Opzione 2: Installazione Manuale

1. Scarica WordPress da wordpress.org
2. Configura il database (MySQL/MariaDB)
3. Completa l'installazione
4. Abilita l'API REST (normalmente abilitata di default)

## Configurazione di Base

### Abilita CORS (per Astro)

Aggiungi a `wp-config.php`:
```php
// Enable CORS for Astro frontend
add_filter( 'rest_pre_serve_request', function( $served, $server, $request ) {
    $origin = get_http_origin();
    if ( $origin === 'http://localhost:3000' || $origin === 'http://localhost:5173' ) {
        header( 'Access-Control-Allow-Origin: ' . esc_url_raw( $origin ) );
        header( 'Access-Control-Allow-Credentials: true' );
        header( 'Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS' );
        header( 'Access-Control-Allow-Headers: Authorization, Content-Type' );
    }
    return $served;
}, 10, 3 );
```

## Plugin Consigliati

- **WP REST Filter**: Per funzionalità REST avanzate
- **JWT Authentication**: Per autenticazione sicura
- **Advanced Custom Fields (ACF)**: Per custom fields

## API Endpoints Principali

- `GET /wp-json/wp/v2/posts` - Tutti i post
- `GET /wp-json/wp/v2/posts/{id}` - Singolo post
- `GET /wp-json/wp/v2/categories` - Categorie
- `GET /wp-json/wp/v2/tags` - Tag
- `GET /wp-json/wp/v2/pages` - Pagine statiche

## Documentazione

Vedi https://developer.wordpress.org/rest-api/ per la documentazione completa dell'API REST.
