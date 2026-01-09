<?php
/**
 * Plugin Name: My API Extensions
 * Description: Custom REST endpoints
 */

add_action('rest_api_init', function() {
    register_rest_route('custom/v1', '/hello', [
        'methods' => 'GET',
        'callback' => function() {
            return ['message' => 'Hello from custom plugin!'];
        },
        'permission_callback' => '__return_true'
    ]);
});
