<?php
/**
 * WordPress CORS Configuration
 * Aggiungi questo codice a wp-config.php per abilitare CORS con Astro
 */

add_filter( 'rest_pre_serve_request', function( $served, $server, $request ) {
    $origin = get_http_origin();
    
    // Lista di URL frontend consentiti
    $allowed_origins = array(
        'http://localhost:3000',        // Astro dev
        'http://localhost:5173',        // Vite dev
        'http://localhost:4321',        // Astro alternative port
    );
    
    // Auto-detect GitHub Codespaces frontend URL
    if ( isset( $_ENV['CODESPACE_NAME'] ) ) {
        $codespace_name = $_ENV['CODESPACE_NAME'];
        $allowed_origins[] = "https://{$codespace_name}-3000.app.github.dev";
        $allowed_origins[] = "https://{$codespace_name}-4321.app.github.dev";
    }
    
    // Supporta pattern wildcard per Codespaces (più flessibile)
    $is_codespace_origin = preg_match('/^https:\/\/.*\.app\.github\.dev$/', $origin);
    
    if ( in_array( $origin, $allowed_origins ) || $is_codespace_origin ) {
        header( 'Access-Control-Allow-Origin: ' . esc_url_raw( $origin ) );
        header( 'Access-Control-Allow-Credentials: true' );
        header( 'Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS' );
        header( 'Access-Control-Allow-Headers: Authorization, Content-Type' );
    }
    
    return $served;
}, 10, 3 );

// Abilita il REST API per i post personalizati
add_filter( 'rest_api_enabled', '__return_true' );
add_filter( 'rest_jsonp_enabled', '__return_true' );
