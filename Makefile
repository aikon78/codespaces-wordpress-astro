.PHONY: help setup start dev stop logs build preview docker-up docker-down

help:
	@echo "📚 Comandi disponibili:"
	@echo ""
	@echo "Setup & Avvio:"
	@echo "  make setup         - Setup completo (Docker + Astro)"
	@echo "  make start         - Avvia tutto (Docker + Astro dev server)"
	@echo "  make dev           - Dev mode con log Docker"
	@echo ""
	@echo "Docker:"
	@echo "  make docker-up     - Avvia servizi Docker"
	@echo "  make docker-down   - Arresta servizi Docker"
	@echo "  make docker-logs   - Visualizza log Docker"
	@echo "  make docker-clean  - Cancella tutto (⚠️ perde dati)"
	@echo ""
	@echo "Frontend (Astro):"
	@echo "  make frontend-dev  - Astro dev server"
	@echo "  make build         - Build Astro"
	@echo "  make preview       - Preview build"
	@echo ""
	@echo "Utilità:"
	@echo "  make wp-logs       - Log WordPress"
	@echo "  make db-logs       - Log Database"
	@echo "  make update-url    - Aggiorna URL WordPress nel database"
	@echo "  make wp-install    - Installa/Reinstalla WordPress"
	@echo "  make wp-check      - Verifica stato WordPress"
	@echo ""

setup:
	@bash setup.sh

start: docker-up
	@cd frontend && npm run dev

dev: docker-up
	@echo "🔄 Dev mode avviato (Ctrl+C per fermare)"
	@echo ""
	@echo "🌐 Frontend:  http://localhost:3000"
	@echo "🔗 WordPress: http://localhost:8000"
	@echo ""
	@cd frontend && npm run dev

docker-up:
	@echo "🐳 Avvio Docker Compose..."
	@docker-compose up -d
	@echo "⏳ Attendo che WordPress sia pronto..."
	@sleep 10
	@echo "✅ Docker Compose avviato"

docker-down:
	@echo "🛑 Arresto Docker Compose..."
	@docker-compose down
	@echo "✅ Docker Compose arrestato"

docker-clean:
	@echo "⚠️  Pulizia totale (cancella dati)..."
	@docker-compose down -v
	@rm -rf cms/wordpress
	@echo "✅ Pulizia completata"

docker-logs:
	@docker-compose logs -f

wp-logs:
	@docker-compose logs -f wordpress

db-logs:
	@docker-compose logs -f db

frontend-dev: docker-up
	@cd frontend && npm run dev

build:
	@cd frontend && npm run build
	@echo "✅ Build completato"

preview: build
	@cd frontend && npm run preview

install:
	@echo "📦 Installazione dipendenze..."
	@npm install
	@cd frontend && npm install
	@echo "✅ Installazione completata"

wp-install:
	@echo "🔧 Installazione WordPress..."
	@bash ./install-wordpress.sh

wp-check:
	@echo "🔍 Verifica stato WordPress..."
	@if docker exec wordpress-db mysql -u wordpress_user -pwordpress_pass wordpress_db -e "SHOW TABLES LIKE 'wp_options';" 2>/dev/null | grep -q wp_options; then \
		echo "✅ WordPress è installato"; \
		docker exec wordpress-db mysql -u wordpress_user -pwordpress_pass wordpress_db -e "SELECT option_value FROM wp_options WHERE option_name IN ('siteurl', 'home');" 2>/dev/null; \
	else \
		echo "❌ WordPress NON è installato"; \
		echo "   Esegui: make wp-install"; \
	fi
update-url:
	@bash .devcontainer/configure-wordpress-url.sh