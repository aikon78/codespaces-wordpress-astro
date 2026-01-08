# 🚀 Guida Rapida - Primo Avvio

Benvenuto nel progetto WordPress + Astro su GitHub Codespaces!

## ⚡ Avvio Automatico (30 secondi)

```bash
# Esegui questo comando una volta:
npm run start

# Oppure usa Make:
make start

# O lo script:
bash setup.sh
```

Tutto si avvia automaticamente:
- ✅ Database MySQL
- ✅ WordPress CMS
- ✅ Astro Frontend Dev Server

## 🌐 Accedi ai Servizi

### 1️⃣ WordPress Admin (crea contenuti qui)
- Porta: **8000**
- In VS Code: Clicca su "Port Forwarding" o "Open in Browser"
- Completa l'installazione al primo accesso

### 2️⃣ Astro Frontend (frontend in real-time)
- Porta: **3000**
- Auto-reload quando modifichi i file

### 3️⃣ phpMyAdmin (gestisci database)
- Porta: **8080**
- User: `wordpress_user`
- Pass: `wordpress_pass`

## 📝 Workflow Tipico

### 1. Aggiungere un Post in WordPress
```
http://localhost:8000/wp-admin
→ Posts → Nuovo Post
→ Titolo, contenuto, pubblica
```

### 2. Vederlo in Astro Frontend
```
http://localhost:3000/blog
→ Dovrebbe apparire automaticamente
```

### 3. Modificare il Design
```
frontend/src/components/
frontend/src/pages/
frontend/src/layouts/
→ Salva e vedi il reload in tempo reale
```

## 🛠️ Comandi Utili

```bash
# Dev mode con log Docker visibili
make dev

# Stop servizi
make docker-down

# Vedi tutti i comandi
make help

# Build per produzione
make build
```

## 📚 Documentazione Completa

- **[CODESPACES.md](CODESPACES.md)** - Guida completa GitHub Codespaces
- **[SETUP.md](SETUP.md)** - Setup dettagliato
- **[README.md](README.md)** - Overview progetto

## ❓ Problemi?

### "WordPress dice 'Sto installando...'"
- Aspetta 10-15 secondi
- Aggiorna la pagina (F5)

### "Astro non carica"
- Assicurati che `npm run start` è in esecuzione
- Porta 3000 è corretta?
- Guarda i log: `make docker-logs`

### "CORS error in console"
- Normale all'inizio
- Dovrebbe scomparire dopo il setup

## 💡 Pro Tips

1. **Hotline WordPress**: Crea contenuti che ricompaiono subito in Astro
2. **Live Preview**: Tieni aperte due finestre side-by-side
3. **Dev Tools**: Usa DevTools del browser per debuggare
4. **Git**: Tutti i file sorgente sono tracciati da Git

## 🎉 Sei Pronto!

Inizia da **WordPress Admin** e crea i tuoi primi post. Vedrai il tutto aggiornato in Astro in tempo reale!

---

Domande? Vedi [CODESPACES.md](CODESPACES.md) per la guida completa.
