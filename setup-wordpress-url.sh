#!/bin/bash
# Script per configurare l'URL di WordPress dinamicamente
# Supporta: localhost, Codespaces, e domini personalizzati

set -e

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}WordPress URL Configuration Script${NC}"
echo "===================================="
echo ""

# Determina l'URL di WordPress
WORDPRESS_URL="${WORDPRESS_URL:-}"

if [ -z "$WORDPRESS_URL" ]; then
  # Se non impostato, prova a rilevarlo
  if [ -n "$CODESPACE_NAME" ]; then
    # Siamo in GitHub Codespaces
    WORDPRESS_URL="https://${CODESPACE_NAME}-8000.app.github.dev:8000"
    echo -e "${YELLOW}Rilevato GitHub Codespaces${NC}"
  else
    # Default locale
    WORDPRESS_URL="http://localhost:8000"
    echo -e "${YELLOW}Usando URL di sviluppo locale${NC}"
  fi
fi

echo -e "${BLUE}WordPress URL configurato come:${NC} ${GREEN}$WORDPRESS_URL${NC}"
echo ""

# Verifica che WordPress sia online
echo "Verifica che WordPress sia online..."
max_attempts=30
attempt=1

while [ $attempt -le $max_attempts ]; do
  if docker exec wordpress-cms curl -s http://localhost/index.php > /dev/null 2>&1; then
    echo -e "${GREEN}✓ WordPress è online${NC}"
    break
  fi
  
  echo "Tentativo $attempt/$max_attempts..."
  sleep 1
  attempt=$((attempt + 1))
done

if [ $attempt -gt $max_attempts ]; then
  echo -e "${RED}✗ Timeout: WordPress non si è avviato${NC}"
  exit 1
fi

echo ""
echo "Configurazione di WordPress..."

# Usa wp-cli per configurare l'URL
docker exec -e HTTP_HOST=localhost wordpress-cms \
  php /var/www/html/wp-cli.phar option update siteurl "$WORDPRESS_URL" --allow-root 2>/dev/null

docker exec -e HTTP_HOST=localhost wordpress-cms \
  php /var/www/html/wp-cli.phar option update home "$WORDPRESS_URL" --allow-root 2>/dev/null

echo -e "${GREEN}✓ Opzioni update: siteurl e home${NC}"

echo ""
echo -e "${GREEN}✓ WordPress configurato con successo!${NC}"
echo ""
echo "URL di accesso:"
echo -e "  WordPress: ${GREEN}$WORDPRESS_URL${NC}"
echo -e "  Admin:     ${GREEN}$WORDPRESS_URL/wp-admin/${NC}"
echo -e "  API REST:  ${GREEN}$WORDPRESS_URL/index.php?rest_route=/wp/v2/${NC}"
echo ""
echo "Credenziali:"
echo "  Username: admin"
echo "  Password: admin123"
echo ""
