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
update-url:
	@bash update-wordpress-url.sh