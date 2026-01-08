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

echo "✅ Setup iniziale completato"
echo ""
echo "Prossimo step: npm run start (dalla root del progetto) o 'npm run dev' per log e frontend" 
echo "Vedi CODESPACES.md per le istruzioni complete"
