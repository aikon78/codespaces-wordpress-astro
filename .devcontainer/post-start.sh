#!/bin/bash

echo "🔄 Avvio servizi Docker..."

# Avvia Docker Compose
docker-compose up -d

# Attendi che WordPress sia pronto
echo "⏳ Attendo che WordPress sia pronto..."
for i in {1..30}; do
  if curl -s http://localhost:8000/wp-json/wp/v2/posts > /dev/null 2>&1; then
    echo "✅ WordPress è pronto"
    break
  fi
  sleep 2
done

# Avvia Astro se non è in esecuzione
echo ""
echo "🔄 Verifico Astro..."
if ! ps aux | grep -q '[a]stro dev'; then
	echo "⚙️  Avvio Astro dev server..."
	cd /workspaces/codespaces-wordpress-astro/frontend && nohup npm run dev > /workspaces/codespaces-wordpress-astro/frontend-dev.log 2>&1 &
	sleep 4
	echo "✅ Astro avviato"
else
	echo "✅ Astro già in esecuzione"
fi

# Verifica port forwarding
echo ""
echo "✅ Servizi avviati!"
echo ""
echo "📍 Accedi a:"
echo "  - WordPress: http://localhost:8000 (oppure porta pubblica Codespaces)"
echo "  - Frontend Astro: http://localhost:3000 (oppure porta pubblica Codespaces)"
echo "  - phpMyAdmin: http://localhost:8080 (oppure porta pubblica Codespaces)"
echo ""
echo "💡 Suggerimento: nel pannello PORTS della Codespace, fai click sui link per copiare gli URL pubblici"
