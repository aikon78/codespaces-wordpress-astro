#!/bin/bash
# Setup script per il progetto WordPress + Astro
# Supporta sia GitHub Codespaces che setup locale

echo "🚀 Setup WordPress + Astro Headless CMS"
echo "========================================"
echo ""

# Controlla se Docker è installato
if ! command -v docker &> /dev/null; then
    echo "❌ Docker non è installato. Installa Docker per continuare."
    exit 1
fi

# Controlla se Node.js è installato
if ! command -v node &> /dev/null; then
    echo "❌ Node.js non è installato. Installa Node.js 18+ per continuare."
    exit 1
fi

echo "✅ Docker è installato"
echo "✅ Node.js è installato"

# Determina l'environment
if [ ! -z "$CODESPACE_NAME" ]; then
    echo "✅ GitHub Codespaces rilevato"
else
    echo "✅ Setup locale"
fi
echo ""

# Crea cartelle WordPress
echo "📁 Creazione cartelle..."
mkdir -p cms/wordpress
echo "✅ Cartelle create"
echo ""

# Configura variabili d'ambiente per Astro
# NOTA: L'URL qui corrisponde a quello che verrà scritto nel database WordPress
echo "⚙️  Configurazione variabili d'ambiente..."
if [ ! -z "$CODESPACE_NAME" ]; then
    CS_DOMAIN=${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-app.github.dev}
    WORDPRESS_URL="https://${CODESPACE_NAME}-8000.${CS_DOMAIN}"
    
    cat > frontend/.env << EOF
# WordPress API Configuration
# IMPORTANTE: Deve corrispondere all'URL nel database WordPress (wp_options.siteurl)
PUBLIC_WORDPRESS_URL=$WORDPRESS_URL
EOF
    
    echo "✅ File .env creato: PUBLIC_WORDPRESS_URL=$WORDPRESS_URL"
else
    WORDPRESS_URL="http://localhost:8000"
    
    cat > frontend/.env << EOF
# WordPress API Configuration (Local Development)
PUBLIC_WORDPRESS_URL=$WORDPRESS_URL
EOF
    
    echo "✅ File .env creato per sviluppo locale (PUBLIC_WORDPRESS_URL=$WORDPRESS_URL)"
fi
echo ""

# Installa dipendenze Astro (se non già fatto)
echo "📦 Installazione dipendenze Astro..."
if [ ! -d "frontend/node_modules" ]; then
    cd frontend
    npm install
    cd ..
    echo "✅ Dipendenze installate"
else
    echo "✅ Dipendenze già presenti"
fi
echo ""

# Avvia i servizi Docker
echo "🐳 Avvio servizi Docker..."
docker-compose up -d
echo "⏳ Attendo che WordPress sia pronto..."

# Attesa con healthcheck
for i in {1..30}; do
  if curl -s http://localhost:8000/wp-json/wp/v2/posts > /dev/null 2>&1; then
    echo "✅ WordPress è pronto!"
    break
  fi
  echo "   Tentativo $i/30..."
  sleep 2
done

echo "✅ Servizi Docker avviati"
echo ""

echo "🎉 Setup completato!"
echo ""
echo "📍 Prossimi passi:"

if [ ! -z "$CODESPACE_NAME" ]; then
    WORDPRESS_URL="http://localhost-8000.${CODESPACE_NAME}.ame.codespaces.github.com"
    FRONTEND_URL="http://localhost-3000.${CODESPACE_NAME}.ame.codespaces.github.com"
    PHPMYADMIN_URL="http://localhost-8080.${CODESPACE_NAME}.ame.codespaces.github.com"
    echo ""
    echo "  🌐 URL GitHub Codespaces:"
    echo "    - WordPress: $WORDPRESS_URL"
    echo "    - Frontend: $FRONTEND_URL (dopo avvio)"
    echo "    - phpMyAdmin: $PHPMYADMIN_URL"
else
    echo ""
    echo "  1. Accedi a http://localhost:8000 per completare l'installazione di WordPress"
    echo "  2. Esegui: cd frontend && npm run dev"
    echo "  3. Visita http://localhost:3000 per vedere il frontend Astro"
fi

echo ""
echo "  ℹ️  Usa 'npm run dev' per avviare Astro frontend"
echo "  ℹ️  Usa 'npm run start' per avviare tutto"
echo ""
echo "📚 Documentazione:"
echo "  - CODESPACES.md - Guida GitHub Codespaces"
echo "  - SETUP.md - Guida setup dettagliata"
echo "  - README.md - Overview progetto"
