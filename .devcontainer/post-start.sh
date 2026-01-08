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

echo ""
echo "✅ Servizi avviati!"
echo "📍 Accedi a:"
echo "  - WordPress: http://localhost-8000.$(echo $CODESPACE_NAME).ame.codespaces.githubusercontent.com"
echo "  - Frontend: http://localhost-3000.$(echo $CODESPACE_NAME).ame.codespaces.githubusercontent.com (quando avviato)"
echo "  - phpMyAdmin: http://localhost-8080.$(echo $CODESPACE_NAME).ame.codespaces.githubusercontent.com"
