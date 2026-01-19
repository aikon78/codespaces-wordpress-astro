#!/bin/bash
# Script per aggiornare l'URL di WordPress nel database
# 
# ARCHITETTURA:
# - WordPress usa wp_options.siteurl e wp_options.home come fonte autoritativa
# - wp-config.php NON deve definire WP_HOME/WP_SITEURL (lascia leggere dal DB)
# - Questo script aggiorna il database quando cambia l'ambiente
# 
# USO: Quando passi da locale → Codespaces → produzione o cambi dominio

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}WordPress URL Update (Database)${NC}"
echo "================================"
echo -e "${YELLOW}Aggiorna wp_options.siteurl e wp_options.home nel database${NC}"
echo ""

# Determina il nuovo URL basato sull'ambiente corrente
WORDPRESS_URL="${WORDPRESS_URL:-}"

if [ -z "$WORDPRESS_URL" ]; then
  if [ -n "$CODESPACE_NAME" ]; then
    CS_DOMAIN=${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-app.github.dev}
    WORDPRESS_URL="https://${CODESPACE_NAME}-8000.${CS_DOMAIN}"
    echo -e "${YELLOW}Rilevato GitHub Codespaces${NC}"
  else
    WORDPRESS_URL="http://localhost:8000"
    echo -e "${YELLOW}Usando URL di sviluppo locale${NC}"
  fi
fi

echo -e "${BLUE}Nuovo URL da configurare:${NC} ${GREEN}$WORDPRESS_URL${NC}"
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
echo -e "${YELLOW}Aggiornamento database...${NC}"

# Aggiorna il database (fonte di verità)
docker exec wordpress-db mysql -u wordpress_user -pwordpress_pass wordpress_db -e "
  UPDATE wp_options SET option_value='$WORDPRESS_URL' WHERE option_name='siteurl';
  UPDATE wp_options SET option_value='$WORDPRESS_URL' WHERE option_name='home';
  DELETE FROM wp_options WHERE option_name LIKE '%transient%';
" 2>/dev/null

echo -e "${GREEN}✓ Opzioni WordPress aggiornate${NC}"

echo ""
echo -e "${GREEN}✓ WordPress URL aggiornato con successo!${NC}"
echo ""
echo "URL di accesso:"
echo -e "  WordPress: ${GREEN}$WORDPRESS_URL${NC}"
echo -e "  Admin:     ${GREEN}$WORDPRESS_URL/wp-admin/${NC}"
echo -e "  API REST:  ${GREEN}$WORDPRESS_URL/index.php?rest_route=/wp/v2/${NC}"
echo ""
echo -e "${YELLOW}✓ Verifica nel database:${NC}"
docker exec wordpress-db mysql -u wordpress_user -pwordpress_pass wordpress_db -e "SELECT option_name, option_value FROM wp_options WHERE option_name IN ('siteurl', 'home');" 2>/dev/null | tail -2
echo ""
