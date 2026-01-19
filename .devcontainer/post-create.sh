#!/bin/bash
set -e

echo "🚀 Setup iniziale GitHub Codespaces"
echo "====================================="
echo ""

# Rileva se siamo in GitHub Codespaces e ottieni l'URL pubblico corretto
# IMPORTANTE: L'URL pubblico deve corrispondere al dominio salvato nel database WordPress (wp_options)
if [ -n "$CODESPACE_NAME" ]; then
	CODESPACE_ENV="true"
	# In Codespaces, deriva il dominio pubblico che WordPress ha nel DB
	CS_DOMAIN=${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-app.github.dev}
	WORDPRESS_PUBLIC_URL="https://${CODESPACE_NAME}-8000.${CS_DOMAIN}"
	# URL interno per readiness check: localhost funziona perché i port forwarding interni
	WORDPRESS_INTERNAL_CHECK="http://localhost:8000"
	echo "🌐 Rilevato GitHub Codespaces: $CODESPACE_NAME"
	echo "📍 Dominio pubblico (dal DB): $WORDPRESS_PUBLIC_URL"
	echo "📍 Check interno: $WORDPRESS_INTERNAL_CHECK"
else
	CODESPACE_ENV="false"
	# In ambiente locale, localhost è l'URL sia interno che pubblico
	WORDPRESS_PUBLIC_URL="http://localhost:8000"
	echo "🌐 Ambiente locale"
	echo "📍 URL WordPress: $WORDPRESS_PUBLIC_URL"
fi

echo ""

# Crea cartelle necessarie
mkdir -p cms/wordpress

echo "📦 Preparazione frontend..."
# Se la cartella frontend non esiste o è vuota, scaffolda un progetto Astro minimale
if [ ! -d frontend ] || [ -z "$(ls -A frontend 2>/dev/null)" ]; then
	echo "⚙️  Frontend mancante o vuoto — scaffold di un progetto Astro minimale..."
	mkdir -p frontend/src/pages frontend/src/lib

	cat > frontend/package.json <<'EOF'
{
	"name": "frontend",
	"private": true,
	"scripts": {
		"dev": "astro dev --hostname 0.0.0.0",
		"build": "astro build",
		"preview": "astro preview"
	},
	"devDependencies": {
		"astro": "^3.7.0"
	}
}
EOF

	cat > frontend/src/pages/index.astro <<'EOF'
---
// Pagina minimale generata automaticamente
---
<!doctype html>
<html>
	<head>
		<meta charset="utf-8" />
		<meta name="viewport" content="width=device-width, initial-scale=1" />
		<title>Astro Frontend (scaffold)</title>
	</head>
	<body>
		<h1>Astro frontend scaffold</h1>
		<p>Progetto generato automaticamente per Codespaces.</p>
	</body>
</html>
EOF

	cat > frontend/src/lib/wordpress-api.ts <<'EOF'
export async function getPosts() {
	return [];
}
EOF

	echo "📦 Installazione dipendenze frontend (npm install)..."
	(cd frontend && npm install --silent)
else
	echo "⏭️ Frontend esistente, salto il scaffold."
fi

echo "\n--- Configurazione variabili d'ambiente frontend ---"
# Crea il file .env per il frontend con l'URL che verrà scritto nel DB WordPress
# IMPORTANTE: install-wordpress.sh scriverà questo URL nel database (wp_options.siteurl/home)
# Il frontend deve usare lo stesso URL per chiamare le API WordPress
cat > frontend/.env <<ENVEOF
# WordPress API Configuration
# IMPORTANTE: Questo URL corrisponde al dominio salvato nel database WordPress (wp_options.siteurl)
# WordPress usa il database come fonte autoritativa, non variabili d'ambiente
PUBLIC_WORDPRESS_URL=${WORDPRESS_PUBLIC_URL}
ENVEOF
echo "✅ File .env creato: PUBLIC_WORDPRESS_URL=${WORDPRESS_PUBLIC_URL}"
if [ ! -d frontend/node_modules ] || [ -z "$(ls -A frontend/node_modules 2>/dev/null)" ]; then
	echo "⚠️  node_modules mancante/vuoto — reinstallo dipendenze..."
	cd frontend && npm install --no-audit && cd ..
else
	echo "✅ node_modules esistente"
fi

echo "\n--- Avvio servizi Docker (docker-compose up -d) ---"
docker-compose up -d

echo "\n--- Configurazione e Installazione WordPress ---"
bash ./install-wordpress.sh

echo "\n✅ Setup iniziale completato!"
echo ""
echo "🎉 WordPress è pronto!"
echo ""
echo "📋 ARCHITETTURA: WordPress usa il database come fonte autoritativa per l'URL"
echo "   • URL salvato nel DB: wp_options.siteurl e wp_options.home"
echo "   • install-wordpress.sh ha scritto: ${WORDPRESS_PUBLIC_URL}"
echo "   • wp-config.php NON sovrascrive il database (legge da DB)"
echo "   • Frontend legge da: frontend/.env (PUBLIC_WORDPRESS_URL)"
echo ""
echo "🔗 URL WordPress: ${WORDPRESS_PUBLIC_URL}"
echo "🔗 URL Admin: ${WORDPRESS_PUBLIC_URL}/wp-admin"
echo "👤 Credenziali admin: admin / admin123"
echo ""
echo "🚀 Prossimi comandi:"
echo "   npm run dev    - Avvia Astro in dev"
echo "   docker-compose down - Ferma i servizi"
echo ""
echo "📚 Documentazione: Vedi CODESPACES.md"
