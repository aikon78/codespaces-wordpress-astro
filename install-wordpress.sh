#!/bin/bash
set -e

echo "🔧 Installazione/Configurazione WordPress..."

# IMPORTANTE: Deriva il dominio pubblico che verrà scritto nel database WordPress
# WordPress usa wp_options.siteurl e wp_options.home come fonte autoritativa
# wp-config.php NON deve sovrascrivere questi valori con WP_HOME/WP_SITEURL
if [ -n "$CODESPACE_NAME" ]; then
    # GitHub Codespaces - usa il dominio pubblico Codespaces
    CS_DOMAIN=${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-app.github.dev}
    WP_URL="https://${CODESPACE_NAME}-8000.${CS_DOMAIN}"
    echo "🌐 Ambiente: GitHub Codespaces"
    echo "📍 Dominio pubblico: $WP_URL"
else
    # Ambiente locale
    WP_URL="http://localhost:8000"
    echo "🌐 Ambiente: Locale"
fi

echo "📍 URL che verrà scritto nel database (wp_options): $WP_URL"

# Credenziali (usare variabili d'ambiente o generare una password robusta)
ADMIN_USER=${WP_ADMIN_USER:-admin}
ADMIN_EMAIL=${WP_ADMIN_EMAIL:-admin@example.com}
if [ -n "$WP_ADMIN_PASSWORD" ]; then
    ADMIN_PASS="$WP_ADMIN_PASSWORD"
    PASS_SOURCE="fornita da WP_ADMIN_PASSWORD (non mostrata)"
else
    ADMIN_PASS=$(openssl rand -base64 24 | tr -d '\n')
    PASS_SOURCE="generata random"
fi

# Attendi che MySQL sia pronto
echo "⏳ Attendo MySQL..."
db_attempts=0
while ! docker exec wordpress-db mysqladmin ping -h localhost -u wordpress_user -pwordpress_pass -s >/dev/null 2>&1; do
    db_attempts=$((db_attempts + 1))
    if [ $db_attempts -ge 30 ]; then
        echo "❌ MySQL non è pronto dopo l'attesa"
        exit 1
    fi
    sleep 1
done
echo "✅ MySQL pronto"

# Attendi che WordPress risponda sull'HTTP
echo "⏳ Attendo che WordPress risponda..."
wp_attempts=0
while true; do
    http_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8000")
    if [ "$http_code" = "200" ] || [ "$http_code" = "302" ]; then
        echo "✅ WordPress risponde (HTTP $http_code)"
        break
    fi
    wp_attempts=$((wp_attempts + 1))
    if [ $wp_attempts -ge 30 ]; then
        echo "❌ WordPress non risponde dopo l'attesa"
        exit 1
    fi
    sleep 2
done

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
        --data-urlencode "user_name=${ADMIN_USER}" \
        --data-urlencode "admin_email=${ADMIN_EMAIL}" \
        --data-urlencode "admin_password=${ADMIN_PASS}" \
        --data-urlencode "admin_password2=${ADMIN_PASS}" \
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
        echo "⚠️  Installazione non confermata, verifico lo stato..."
    fi

    # Verifica che l'installazione abbia realmente scritto nel DB
    if ! docker exec wordpress-db mysql -u wordpress_user -pwordpress_pass -D wordpress_db -e "SELECT COUNT(*) FROM wp_users;" >/dev/null 2>&1; then
        echo "❌ Installazione non riuscita (wp_users mancante)"
        exit 1
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
echo "� IMPORTANTE: L'URL è stato scritto nel database WordPress (wp_options)"
echo "   Questo è il reference che WordPress userà per tutti i link e redirect"
echo "🔗 URL Admin: $WP_URL/wp-admin"
echo "👤 Username: $ADMIN_USER"
if [ "$PASS_SOURCE" = "generata random" ]; then
    echo "🔑 Password generata: $ADMIN_PASS"
else
    echo "🔑 Password: fornita via WP_ADMIN_PASSWORD (non stampata)"
fi
echo ""
echo "📝 Accedi e verifica:"
echo "   - Impostazioni → Generali: controlla siteurl e home"
echo "   - Testa l'API: curl $WP_URL/wp-json/wp/v2/posts"
echo ""
