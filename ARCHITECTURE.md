# Architettura WordPress + Astro

## Principio Fondamentale

**WordPress usa il database come unica fonte autoritativa per il dominio.**

```
┌─────────────────────────────────────────────────────────────┐
│                    FONTE AUTORITATIVA                        │
│                    MySQL Database                            │
│                                                              │
│  wordpress_db.wp_options:                                    │
│    WHERE option_name = 'siteurl'                             │
│    WHERE option_name = 'home'                                │
│                                                              │
│  Esempio: https://example.com                                │
└──────────────────────────────────────────────────────────────┘
       ↑ Scrittura              ↓ Lettura
       │                        │
┌──────┴────────┐        ┌──────┴───────────────────────┐
│ Setup Scripts │        │ WordPress Core               │
│               │        │                              │
│ • install-    │        │ • wp-includes/option.php     │
│   wordpress   │        │ • get_option('siteurl')      │
│   .sh         │        │ • home_url()                 │
│               │        │ • site_url()                 │
│ • setup-      │        │                              │
│   wordpress   │        │ wp-config.php:               │
│   -url.sh     │        │ • NO WP_HOME                 │
└───────────────┘        │ • NO WP_SITEURL              │
                         │ • Solo proxy headers         │
                         └──────────────────────────────┘
                                     │
                                     │ HTTP API
                                     ↓
                         ┌──────────────────────────────┐
                         │ Frontend Astro               │
                         │                              │
                         │ frontend/.env:               │
                         │ PUBLIC_WORDPRESS_URL=        │
                         │   https://example.com        │
                         │                              │
                         │ src/lib/wordpress-api.ts     │
                         └──────────────────────────────┘
```

## Flusso di Configurazione

### 1. Prima Installazione

```bash
bash install-wordpress.sh
```

**Cosa fa:**
1. Rileva ambiente (locale vs Codespaces)
2. Determina URL pubblico:
   - Locale: `http://localhost:8000`
   - Codespaces: `https://${CODESPACE_NAME}-8000.app.github.dev`
3. **Scrive nel database** via WP-CLI:
   ```bash
   wp option update siteurl "https://example.com"
   wp option update home "https://example.com"
   ```
4. Crea file `frontend/.env` con stesso URL

### 2. Cambio Ambiente/Dominio

```bash
bash setup-wordpress-url.sh
```

**Cosa fa:**
1. Rileva nuovo ambiente o legge `WORDPRESS_URL`
2. **Aggiorna database** via MySQL:
   ```sql
   UPDATE wp_options 
   SET option_value='https://new-domain.com' 
   WHERE option_name IN ('siteurl', 'home');
   ```
3. Suggerisce di aggiornare `frontend/.env`

### 3. Riavvio (post-start.sh)

```bash
# Eseguito automaticamente in Codespaces
.devcontainer/post-start.sh
```

**Cosa fa:**
1. Avvia Docker Compose
2. Verifica che WordPress risponda
3. Mostra URL pubblici (legge da ambiente, NON dal database)
4. **NON modifica** il database

## File di Configurazione

### wp-config.php

```php
// ✅ CORRETTO - Lascia che WordPress legga dal database
// NON definire WP_HOME e WP_SITEURL

// Gestione proxy headers (Codespaces/reverse proxy)
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO'])) {
    $_SERVER['HTTPS'] = 'on';
}
if (isset($_SERVER['HTTP_X_FORWARDED_HOST'])) {
    $_SERVER['HTTP_HOST'] = $_SERVER['HTTP_X_FORWARDED_HOST'];
}
// Rimuovi porta da HTTP_HOST
$_SERVER['HTTP_HOST'] = preg_replace('/:.*/', '', $_SERVER['HTTP_HOST']);
```

**Perché NO WP_HOME/WP_SITEURL:**
- Sovrascriverebbero il database solo runtime (non permanente)
- Causerebbero inconsistenza tra configurazione e database
- Impedirebbero cambio URL via admin WordPress

### frontend/.env

```env
# Deve corrispondere al database WordPress
PUBLIC_WORDPRESS_URL=https://example.com
```

**Sincronizzazione:**
- Aggiornato da `install-wordpress.sh` (prima volta)
- Aggiornato manualmente dopo `setup-wordpress-url.sh`
- Usato da `src/lib/wordpress-api.ts` per chiamate API

### .env (root - opzionale)

```env
# NOTA: WordPress NON legge questa variabile
# È solo per documentazione e script
WORDPRESS_URL=https://example.com
```

## Risoluzione Problemi

### Redirect a dominio sbagliato

**Causa:** Database ha URL vecchio  
**Soluzione:**
```bash
bash setup-wordpress-url.sh
# Poi aggiorna frontend/.env
```

### Frontend non raggiunge API

**Causa:** `frontend/.env` ha URL diverso dal database  
**Soluzione:**
```bash
# 1. Verifica URL nel database
docker exec wordpress-db mysql -u wordpress_user -p wordpress_db \
  -e "SELECT option_value FROM wp_options WHERE option_name='siteurl';"

# 2. Aggiorna frontend/.env con stesso URL
echo "PUBLIC_WORDPRESS_URL=<url-dal-db>" > frontend/.env
```

### Porta :8000 nei redirect

**Causa:** Proxy headers Codespaces con porta esplicita  
**Soluzione:** Già gestito in wp-config.php:
```php
// Rimuovi porta da HTTP_HOST
$_SERVER['HTTP_HOST'] = preg_replace('/:.*/', '', $_SERVER['HTTP_HOST']);
// Rimuovi X-Forwarded-Port
unset($_SERVER['HTTP_X_FORWARDED_PORT']);
```

## Best Practices

### ✅ DO

- Usa `setup-wordpress-url.sh` per cambiare dominio
- Mantieni `frontend/.env` sincronizzato con database
- Verifica database per URL effettivo
- Lascia che wp-config legga dal database

### ❌ DON'T

- Non definire WP_HOME/WP_SITEURL in wp-config.php
- Non modificare URL manualmente nel database (usa script)
- Non fare affidamento su variabili d'ambiente per URL WordPress
- Non mischiare URL HTTP e HTTPS tra database e frontend

## Riferimenti

- [README.md](README.md) - Setup rapido
- [WORDPRESS_URL_CONFIGURATION.md](WORDPRESS_URL_CONFIGURATION.md) - Guida dettagliata URL
- [CODESPACES.md](CODESPACES.md) - Specifico per GitHub Codespaces
