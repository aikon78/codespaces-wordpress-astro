#!/bin/bash
set -e

echo "🚀 Setup iniziale GitHub Codespaces"
echo "====================================="
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

echo "\n--- Verifico node_modules in frontend ---"
if [ ! -d frontend/node_modules ] || [ -z "$(ls -A frontend/node_modules 2>/dev/null)" ]; then
	echo "⚠️  node_modules mancante/vuoto — reinstallo dipendenze..."
	cd frontend && npm install --no-audit && cd ..
else
	echo "✅ node_modules esistente"
fi

echo "\n--- Attendo che WordPress sia pronto (60 secondi max) ---"
for i in {1..60}; do
	if curl -s http://localhost:8000/ >/dev/null 2>&1; then
		echo "✅ WordPress pronto!"
		break
	fi
	echo "⏳ Tentativo $i/60: WordPress non ancora pronto..."
	sleep 1
done

echo "\n--- Installo WordPress via WP-CLI se necessario ---"
# Attendo che il DB sia pronto
sleep 10

# Verifico se WordPress è già installato
if docker exec wordpress-db mysql -u wordpress_user -pwordpress_pass -D wordpress_db -e "SELECT 1 FROM wp_options LIMIT 1;" >/dev/null 2>&1; then
	echo "✅ WordPress già installato"
else
	echo "⚙️  Installazione WordPress via WP-CLI..."
	docker exec -w /var/www/html wordpress-cms php wp-cli.phar core install --allow-root \
		--url='http://localhost:8000' \
		--title='WordPress Codespaces' \
		--admin_user='admin' \
		--admin_password='admin123' \
		--admin_email='admin@example.com' \
		--skip-email || echo "⚠️  Installazione WP parziale (potrebbe essere già installato)"
fi

echo "✅ Setup iniziale completato"
echo ""
echo "Prossimo step: npm run start (dalla root del progetto) o 'npm run dev' per log e frontend" 
echo "Vedi CODESPACES.md per le istruzioni complete"
