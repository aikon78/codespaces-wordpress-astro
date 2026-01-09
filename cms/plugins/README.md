# Plugin WordPress Personalizzati

Questa directory contiene i plugin WordPress personalizzati per il progetto.

## Struttura

I plugin inseriti qui saranno automaticamente montati in WordPress nella directory:

```
/wp-content/plugins/custom/
```

## Creare un Nuovo Plugin

### Plugin Base

```bash
cd cms/plugins
mkdir my-custom-plugin
cd my-custom-plugin
touch my-custom-plugin.php
```

**my-custom-plugin.php**:

```php
<?php
/**
 * Plugin Name: My Custom Plugin
 * Plugin URI: https://example.com
 * Description: Custom functionality for WordPress + Astro headless
 * Version: 1.0.0
 * Author: Your Name
 * Author URI: https://example.com
 * License: GPL v2 or later
 * Text Domain: my-custom-plugin
 */

// Previene accesso diretto
if (!defined('ABSPATH')) {
    exit;
}

// Il tuo codice qui
add_action('init', function() {
    // Inizializzazione plugin
});
?>
```

## Plugin Consigliati per Headless

### 1. Custom REST Endpoints

```php
<?php
/**
 * Plugin Name: Custom REST Endpoints
 * Description: Aggiunge endpoint REST personalizzati
 */

add_action('rest_api_init', function() {
    register_rest_route('custom/v1', '/featured', [
        'methods' => 'GET',
        'callback' => function() {
            $posts = get_posts([
                'meta_key' => 'featured',
                'meta_value' => '1',
                'posts_per_page' => 5
            ]);

            return rest_ensure_response($posts);
        },
        'permission_callback' => '__return_true'
    ]);
});
?>
```

### 2. Custom Fields per REST API

```php
<?php
/**
 * Plugin Name: Expose Custom Fields
 * Description: Espone custom fields via REST API
 */

add_action('rest_api_init', function() {
    $post_types = ['post', 'page', 'your_custom_post_type'];

    foreach ($post_types as $post_type) {
        register_rest_field($post_type, 'acf_fields', [
            'get_callback' => function($object) {
                // Se usi ACF
                if (function_exists('get_fields')) {
                    return get_fields($object['id']);
                }
                return [];
            },
            'schema' => null,
        ]);
    }
});
?>
```

### 3. Custom Post Types

```php
<?php
/**
 * Plugin Name: Custom Post Types
 * Description: Registra custom post types per il progetto
 */

function register_custom_post_types() {
    // Portfolio
    register_post_type('portfolio', [
        'labels' => [
            'name' => 'Portfolio',
            'singular_name' => 'Portfolio Item'
        ],
        'public' => true,
        'show_in_rest' => true,
        'rest_base' => 'portfolio',
        'supports' => ['title', 'editor', 'thumbnail', 'excerpt'],
        'has_archive' => true,
        'rewrite' => ['slug' => 'portfolio'],
    ]);

    // Testimonials
    register_post_type('testimonial', [
        'labels' => [
            'name' => 'Testimonials',
            'singular_name' => 'Testimonial'
        ],
        'public' => true,
        'show_in_rest' => true,
        'rest_base' => 'testimonials',
        'supports' => ['title', 'editor', 'thumbnail'],
    ]);
}
add_action('init', 'register_custom_post_types');
?>
```

### 4. CORS Avanzato

```php
<?php
/**
 * Plugin Name: Advanced CORS
 * Description: Gestione CORS avanzata per headless
 */

function custom_cors_headers() {
    $allowed_origins = [
        'http://localhost:3000',
        'http://localhost:4321',
        // Aggiungi i tuoi domini
    ];

    $origin = $_SERVER['HTTP_ORIGIN'] ?? '';

    if (in_array($origin, $allowed_origins)) {
        header("Access-Control-Allow-Origin: $origin");
        header('Access-Control-Allow-Credentials: true');
        header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
        header('Access-Control-Allow-Headers: Authorization, Content-Type, X-WP-Nonce');
    }

    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        status_header(200);
        exit();
    }
}
add_action('rest_api_init', 'custom_cors_headers', 15);
?>
```

## Attivare i Plugin

1. Accedi a WordPress Admin: http://localhost:8000/wp-admin
2. Vai su Plugin → Plugin installati
3. Attiva i tuoi plugin personalizzati

## Struttura Plugin Complesso

Per plugin più complessi:

```
cms/plugins/my-plugin/
├── my-plugin.php          # File principale
├── README.md              # Documentazione
├── includes/              # Classi e logica
│   ├── class-main.php
│   ├── class-api.php
│   └── class-admin.php
├── admin/                 # Interfaccia admin
│   ├── css/
│   ├── js/
│   └── views/
└── assets/                # Risorse pubbliche
    ├── css/
    └── js/
```

## Plugin Esterni Consigliati

Installa tramite WordPress Admin:

- **Advanced Custom Fields (ACF)** - Campi personalizzati
- **WPGraphQL** - Se preferisci GraphQL a REST
- **JWT Authentication** - Autenticazione sicura
- **WP REST Filter** - Filtri avanzati per REST API
- **Yoast SEO** - SEO e metadata

## Testing

Testa i tuoi endpoint REST:

```bash
# Lista post
curl http://localhost:8000/wp-json/wp/v2/posts

# Endpoint custom
curl http://localhost:8000/wp-json/custom/v1/featured
```

## Risorse

- [Plugin Development Handbook](https://developer.wordpress.org/plugins/)
- [REST API Handbook](https://developer.wordpress.org/rest-api/)
- [Custom Post Types](https://developer.wordpress.org/reference/functions/register_post_type/)
