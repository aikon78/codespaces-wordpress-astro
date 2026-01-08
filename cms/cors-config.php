<?php
/**
 * WordPress CORS Configuration
 * Aggiungi questo codice a wp-config.php per abilitare CORS con Astro
 */

add_filter( 'rest_pre_serve_request', function( $served, $server, $request ) {
    $origin = get_http_origin();
    
    // Aggiungi gli URL del tuo frontend (dev e prod)
    $allowed_origins = array(
        'http://localhost:3000',
        'http://localhost:5173',
        // 'https://tuodominio.com' // Per produzione
    );
    
    if ( in_array( $origin, $allowed_origins ) ) {
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
