#!/bin/bash
# Setup script per il progetto WordPress + Astro

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
echo ""

# Crea cartelle WordPress
echo "📁 Creazione cartelle..."
mkdir -p cms/wordpress
echo "✅ Cartelle create"
echo ""

# Avvia i servizi Docker
echo "🐳 Avvio servizi Docker..."
docker-compose up -d
echo "⏳ Attendo che WordPress sia pronto..."
sleep 15

echo "✅ Servizi Docker avviati"
echo ""

# Installa dipendenze Astro
echo "📦 Installazione dipendenze Astro..."
cd frontend
npm install
cd ..
echo "✅ Dipendenze installate"
echo ""

echo "🎉 Setup completato!"
echo ""
echo "📍 Prossimi passi:"
echo "  1. Accedi a http://localhost:8000 per completare l'installazione di WordPress"
echo "  2. Esegui: cd frontend && npm run dev"
echo "  3. Visita http://localhost:3000 per vedere il frontend Astro"
echo ""
echo "📚 Risorse:"
echo "  - WordPress Admin: http://localhost:8000/wp-admin"
echo "  - Database Manager: http://localhost:8080 (phpMyAdmin)"
echo "  - Astro Dev Server: http://localhost:3000"
