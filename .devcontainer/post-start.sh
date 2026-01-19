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

# Verifica port forwarding e mostra URL corretti
echo ""
echo "✅ Servizi avviati!"
echo ""
# Il dominio pubblico è quello nel database di WordPress, non localhost
if [ -n "$CODESPACE_NAME" ]; then
	CS_DOMAIN=${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-app.github.dev}
	WP_PUBLIC="https://${CODESPACE_NAME}-8000.${CS_DOMAIN}"
	echo "📍 Accedi a:"
	echo "  - WordPress: $WP_PUBLIC"
	echo "  - WordPress Admin: $WP_PUBLIC/wp-admin"
	echo "  - Frontend Astro: $WP_PUBLIC:3000 (oppure pannello PORTS)"
	echo "  - phpMyAdmin: $WP_PUBLIC:8080 (oppure pannello PORTS)"
else
	echo "📍 Accedi a:"
	echo "  - WordPress: http://localhost:8000"
	echo "  - Frontend Astro: http://localhost:3000"
	echo "  - phpMyAdmin: http://localhost:8080"
fi
echo ""
echo "💡 Nel pannello PORTS della Codespace, i link pubblici sono generati automaticamente"
