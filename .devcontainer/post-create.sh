#!/bin/bash
set -e

echo "🚀 Setup iniziale GitHub Codespaces"
echo "====================================="
echo ""

# Rileva se siamo in GitHub Codespaces e ottieni l'URL pubblico
if [ -n "$CODESPACE_NAME" ]; then
	CODESPACE_ENV="true"
	# In Codespaces, usa localhost per il frontend e il database WordPress
	# Il port forwarding di Codespaces si occupa di rendere localhost accessibile pubblicamente
	WORDPRESS_PUBLIC_URL="http://localhost:8000"
	# URL interno per la comunicazione tra container Docker (nome del servizio)
	WORDPRESS_INTERNAL_URL="http://wordpress:80"
	echo "🌐 Rilevato GitHub Codespaces: $CODESPACE_NAME"
	echo "📍 URL WordPress (via port forwarding): $WORDPRESS_PUBLIC_URL"
	echo "📍 URL interno (container): $WORDPRESS_INTERNAL_URL"
else
	CODESPACE_ENV="false"
	# In ambiente locale, localhost funziona perché i container hanno accesso diretto all'host
	WORDPRESS_INTERNAL_URL="http://localhost:8000"
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
# Crea il file .env con localhost (funziona sia in Codespaces che in locale)
cat > frontend/.env <<ENVEOF
# WordPress API Configuration
# Usa localhost - funziona in Codespaces grazie al port forwarding automatico
PUBLIC_WORDPRESS_URL=${WORDPRESS_PUBLIC_URL}
ENVEOF
echo "✅ File .env creato: PUBLIC_WORDPRESS_URL=${WORDPRESS_PUBLIC_URL}"
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

echo "\n--- Configurazione e Installazione WordPress ---"
# Attendo che il DB sia completamente pronto
sleep 10

# Verifico se WordPress è già installato nel DB
if docker exec wordpress-db mysql -u wordpress_user -pwordpress_pass -D wordpress_db -e "SELECT 1 FROM wp_options LIMIT 1;" >/dev/null 2>&1; then
	echo "✅ WordPress già installato - verifichiamo l'URL..."
	
	# Assicuriamoci che l'URL sia corretto (OBBLIGATORIO per evitare redirect)
	# Se siamo in Codespaces, usa l'URL pubblico, altrimenti usa localhost
	docker exec wordpress-db mysql -u wordpress_user -pwordpress_pass -D wordpress_db -e "
		UPDATE wp_options SET option_value='${WORDPRESS_PUBLIC_URL}' WHERE option_name IN ('siteurl', 'home');
		DELETE FROM wp_options WHERE option_name LIKE '%transient%';
	" >/dev/null 2>&1
	
	echo "✅ URL WordPress verificato/aggiornato a: ${WORDPRESS_PUBLIC_URL}"
else
	echo "⚙️  Installazione WordPress in corso..."
	
	# IMPORTANTE: Installa WordPress con l'URL interno prima (http://localhost:8000)
	# perché il container deve essere in grado di raggiungerlo
	INSTALL_RESPONSE=$(curl -s -X POST "http://localhost:8000/wp-admin/install.php?step=2" \
		--data-urlencode "weblog_title=WordPress Headless CMS" \
		--data-urlencode "user_name=admin" \
		--data-urlencode "admin_email=admin@example.com" \
		--data-urlencode "admin_password=password123" \
		--data-urlencode "admin_password2=password123" \
		--data-urlencode "pw_weak=1" \
		--data-urlencode "Submit=Install WordPress" 2>/dev/null || true)
	
	# Attendi per assicurarti che l'installazione sia completata
	sleep 8
	
	if docker exec wordpress-db mysql -u wordpress_user -pwordpress_pass -D wordpress_db -e "SELECT 1 FROM wp_options LIMIT 1;" >/dev/null 2>&1; then
		echo "✅ WordPress installato con successo!"
		
		# CRITICAL: Aggiorna immediatamente all'URL pubblico (per Codespaces) o locale
		# Questo è CRUCIALE perché WordPress usa questo URL per tutti i redirect e i link
		docker exec wordpress-db mysql -u wordpress_user -pwordpress_pass -D wordpress_db -e "
			UPDATE wp_options SET option_value='${WORDPRESS_PUBLIC_URL}' WHERE option_name='siteurl';
			UPDATE wp_options SET option_value='${WORDPRESS_PUBLIC_URL}' WHERE option_name='home';
			DELETE FROM wp_options WHERE option_name LIKE '%transient%';
		" >/dev/null 2>&1
		
		echo "✅ URL WordPress configurato a: ${WORDPRESS_PUBLIC_URL}"
		
		# Crea un post di esempio
		echo "📝 Creazione post di esempio..."
		docker exec wordpress-db mysql -u wordpress_user -pwordpress_pass -D wordpress_db -e "
			INSERT INTO wp_posts (
				post_author, post_date, post_date_gmt, post_content, post_title, 
				post_excerpt, post_status, comment_status, ping_status, post_name, 
				post_modified, post_modified_gmt, post_type, post_parent
			) 
			VALUES (
				1, NOW(), NOW(), 
				'<p>Benvenuto nel tuo CMS Headless con WordPress e Astro!</p><p>Questo è un post di esempio. Puoi crearne di nuovi da wp-admin.</p>',
				'Benvenuto nel CMS Headless',
				'Un post di esempio',
				'publish',
				'open',
				'open',
				'benvenuto',
				NOW(),
				NOW(),
				'post',
				0
			)
			ON DUPLICATE KEY UPDATE post_title=post_title;
		" >/dev/null 2>&1
		
		echo "✅ Post di esempio creato"
	else
		echo "⚠️  Problema nell'installazione di WordPress"
	fi
fi

# Riavvia WordPress per applicare la configurazione (IMPORTANTE)
echo "\n🔄 Riavvio WordPress per applicare la configurazione..."
docker restart wordpress-cms >/dev/null 2>&1
sleep 5

# Verifica finale che WordPress sia configurato con l'URL corretto
echo "🔍 Verifica finale della configurazione..."
FINAL_URL=$(docker exec wordpress-db mysql -u wordpress_user -pwordpress_pass -D wordpress_db -e "SELECT option_value FROM wp_options WHERE option_name='siteurl';" -s -N 2>/dev/null)
if [ "$FINAL_URL" = "$WORDPRESS_PUBLIC_URL" ]; then
	echo "✅ WordPress configurato correttamente: $FINAL_URL"
else
	echo "⚠️  ATTENZIONE: URL configurato come: $FINAL_URL (atteso: $WORDPRESS_PUBLIC_URL)"
fi

echo "\n✅ Setup iniziale completato!"
echo ""
echo "🎉 WordPress è pronto!"
echo ""
echo "📝 Credenziali:"
echo "   URL Admin: ${WORDPRESS_PUBLIC_URL}/wp-admin"
echo "   URL Frontend: ${WORDPRESS_PUBLIC_URL}"
echo "   Username: admin"
echo "   Password: password123"
echo ""
echo "🚀 Prossimi comandi:"
echo "   npm run dev    - Avvia Astro + WordPress"
echo "   npm run start  - Avvia Astro + Docker"
echo ""
echo "📚 Documentazione: Vedi CODESPACES.md"
