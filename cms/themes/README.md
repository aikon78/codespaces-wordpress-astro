# Temi WordPress Personalizzati

Questa directory contiene i temi WordPress personalizzati per il progetto.

## Struttura

I temi inseriti qui saranno automaticamente montati in WordPress nella directory:

```
/wp-content/themes/custom/
```

## Creare un Nuovo Tema

### Opzione 1: Tema da Zero

```bash
cd cms/themes
mkdir my-custom-theme
cd my-custom-theme

# Crea i file essenziali
touch style.css index.php functions.php
```

**style.css** (obbligatorio):

```css
/*
Theme Name: My Custom Theme
Theme URI: https://example.com
Author: Your Name
Author URI: https://example.com
Description: Custom theme for WordPress + Astro headless
Version: 1.0.0
License: GNU General Public License v2 or later
License URI: http://www.gnu.org/licenses/gpl-2.0.html
Text Domain: my-custom-theme
*/
```

**index.php** (obbligatorio):

```php
<?php
// Tema headless - redirect to frontend
header('Location: http://localhost:3000');
exit;
?>
```

### Opzione 2: Tema Starter

Puoi usare un tema starter come \_s (Underscores):

```bash
cd cms/themes
git clone https://github.com/Automattic/_s.git my-theme
cd my-theme
npm install
```

### Opzione 3: Tema Headless Specifico

Per un setup headless, considera:

```bash
cd cms/themes
git clone https://github.com/postlight/headless-wp-starter.git
```

## Attivare il Tema

1. Accedi a WordPress Admin: http://localhost:8000/wp-admin
2. Vai su Aspetto → Temi
3. Attiva il tuo tema personalizzato

## Best Practices per Headless

- Mantieni il tema minimal (WordPress è solo API)
- Usa ACF (Advanced Custom Fields) per campi personalizzati
- Registra Custom Post Types in `functions.php`
- Esponi campi custom via REST API

**Esempio functions.php per headless:**

```php
<?php
// Abilita REST API per custom fields
add_action('rest_api_init', function() {
    register_rest_field('post', 'custom_field', [
        'get_callback' => function($object) {
            return get_post_meta($object['id'], 'custom_field', true);
        },
        'schema' => null,
    ]);
});

// Registra Custom Post Type
function register_custom_post_types() {
    register_post_type('project', [
        'labels' => [
            'name' => 'Projects',
            'singular_name' => 'Project'
        ],
        'public' => true,
        'show_in_rest' => true, // Importante per REST API
        'supports' => ['title', 'editor', 'thumbnail'],
    ]);
}
add_action('init', 'register_custom_post_types');
?>
```

## Risorse

- [Theme Development Handbook](https://developer.wordpress.org/themes/)
- [REST API Handbook](https://developer.wordpress.org/rest-api/)
- [Underscores Theme](https://underscores.me/)
