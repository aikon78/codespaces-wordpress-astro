#!/bin/bash
# Script per configurare l'URL di WordPress in base all'ambiente

echo "🔧 Configurazione URL WordPress..."

# Determina l'URL corretto
if [ -n "$CODESPACE_NAME" ]; then
    # GitHub Codespaces
    CS_DOMAIN=${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-app.github.dev}
    WORDPRESS_URL="https://${CODESPACE_NAME}-8000.${CS_DOMAIN}"
    ENV_NAME="GitHub Codespaces"
else
    # Sviluppo locale
    WORDPRESS_URL="http://localhost:8000"
    ENV_NAME="Locale"
fi

echo "📍 Ambiente: $ENV_NAME"
echo "🌐 URL WordPress: $WORDPRESS_URL"

# Aggiorna il database WordPress
echo "💾 Aggiornamento database..."
docker exec wordpress-db mysql -u wordpress_user -pwordpress_pass wordpress_db -e \
    "UPDATE wp_options SET option_value = '$WORDPRESS_URL' WHERE option_name IN ('siteurl', 'home');" \
    2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ URL WordPress configurato con successo!"
else
    echo "❌ Errore durante la configurazione. Assicurati che WordPress sia in esecuzione."
    exit 1
fi

# Aggiorna anche il file .env di Astro
echo "📝 Aggiornamento file .env..."
cat > /workspaces/codespaces-wordpress-astro/frontend/.env << EOF
# WordPress API Configuration
# Auto-generato da configure-wordpress-url.sh
PUBLIC_WORDPRESS_URL=$WORDPRESS_URL
EOF

echo "✅ File .env aggiornato!"
echo ""
echo "🎉 Configurazione completata!"
echo "📍 Accedi a: $WORDPRESS_URL/wp-admin"
