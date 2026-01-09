#!/bin/bash
set -e

echo "🔧 Installazione/Configurazione WordPress..."

# Definisci l'URL WordPress corretto
if [ -n "$CODESPACE_NAME" ]; then
    WP_URL="https://${CODESPACE_NAME}-8000.app.github.dev"
    echo "🌐 Ambiente: GitHub Codespaces"
else
    WP_URL="http://localhost:8000"
    echo "🌐 Ambiente: Locale"
fi

echo "📍 URL WordPress: $WP_URL"

# Attendi che MySQL sia pronto
echo "⏳ Attendo MySQL (10 secondi)..."
sleep 10

# Verifica se WordPress è già installato
if docker exec wordpress-db mysql -u wordpress_user -pwordpress_pass -D wordpress_db -e "SELECT 1 FROM wp_options LIMIT 1;" >/dev/null 2>&1; then
    echo "⚙️  WordPress già installato - aggiorno URL..."
    
    # Aggiorna gli URL nel database
    docker exec wordpress-db mysql -u wordpress_user -pwordpress_pass -D wordpress_db -e "
        UPDATE wp_options SET option_value='$WP_URL' WHERE option_name='siteurl';
        UPDATE wp_options SET option_value='$WP_URL' WHERE option_name='home';
    " 2>/dev/null
    
    echo "✅ URL WordPress aggiornato a: $WP_URL"
else
    echo "⚙️  WordPress non installato - procedo con l'installazione..."
    
    # Usa la API di installazione di WordPress via curl
    INSTALL_RESPONSE=$(curl -s -X POST "http://localhost:8000/wp-admin/install.php?step=2" \
        --data-urlencode "weblog_title=WordPress Headless CMS" \
        --data-urlencode "user_name=admin" \
        --data-urlencode "admin_email=admin@example.com" \
        --data-urlencode "admin_password=password123" \
        --data-urlencode "admin_password2=password123" \
        --data-urlencode "pw_weak=1" \
        --data-urlencode "Submit=Install WordPress")
    
    if echo "$INSTALL_RESPONSE" | grep -q "Success\|success"; then
        echo "✅ WordPress installato con successo!"
        
        # Aggiorna gli URL per Codespaces
        docker exec wordpress-db mysql -u wordpress_user -pwordpress_pass -D wordpress_db -e "
            UPDATE wp_options SET option_value='$WP_URL' WHERE option_name='siteurl';
            UPDATE wp_options SET option_value='$WP_URL' WHERE option_name='home';
        " 2>/dev/null
        
        echo "✅ URL configurato correttamente"
    else
        echo "⚠️  Possibile errore nell'installazione, verifico..."
    fi
fi

# Verifica finale
echo ""
echo "🔍 Verifica configurazione..."
CURRENT_URL=$(docker exec wordpress-db mysql -u wordpress_user -pwordpress_pass -D wordpress_db -e "SELECT option_value FROM wp_options WHERE option_name='siteurl';" -s -N 2>/dev/null)

if [ -n "$CURRENT_URL" ]; then
    echo "✅ WordPress configurato con URL: $CURRENT_URL"
    
    if [ "$CURRENT_URL" != "$WP_URL" ]; then
        echo "⚠️  ATTENZIONE: URL atteso ($WP_URL) diverso da quello configurato ($CURRENT_URL)"
        echo "   Aggiorno..."
        docker exec wordpress-db mysql -u wordpress_user -pwordpress_pass -D wordpress_db -e "
            UPDATE wp_options SET option_value='$WP_URL' WHERE option_name='siteurl';
            UPDATE wp_options SET option_value='$WP_URL' WHERE option_name='home';
        " 2>/dev/null
        echo "✅ URL aggiornato"
    fi
fi

echo ""
echo "✅ Installazione/Configurazione completata!"
echo ""
echo "🔗 URL Admin: $WP_URL/wp-admin"
echo "👤 Username: admin"
echo "🔑 Password: password123"
echo ""
echo "📝 Testa l'API: curl $WP_URL/wp-json/wp/v2/posts"
echo ""
