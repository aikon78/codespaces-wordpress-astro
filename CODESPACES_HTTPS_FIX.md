# Configurazione Automatica HTTPS per GitHub Codespaces

## Problema Risolto

WordPress configurato con URL `https://` dietro il proxy di GitHub Codespaces causava errori 502 quando il proxy non inviava gli header corretti per HTTPS.

## Soluzioni Implementate

### 1. Configurazione HTTPS Automatica in Docker Compose

**File:** `docker-compose.yml`

Aggiunta configurazione nella variabile `WORDPRESS_CONFIG_EXTRA`:

```php
// GitHub Codespaces HTTPS support
if (isset($_SERVER['HTTP_HOST']) && strpos($_SERVER['HTTP_HOST'], 'app.github.dev') !== false) {
    $_SERVER['HTTPS'] = 'on';
    define('FORCE_SSL_ADMIN', true);
}
```

Questa configurazione:

- ✅ Rileva automaticamente quando WordPress è eseguito su Codespaces
- ✅ Forza HTTPS per l'area admin
- ✅ Imposta correttamente `$_SERVER['HTTPS']` per evitare loop di redirect
- ✅ Viene applicata automaticamente ad ogni rebuild

### 2. Script di Configurazione URL Automatico

**File:** `.devcontainer/configure-wordpress-url.sh`

Script autonomo che:

- Rileva l'ambiente (Codespaces vs Locale)
- Configura l'URL corretto nel database WordPress
- Aggiorna il file `.env` di Astro
- Può essere eseguito manualmente in qualsiasi momento

**Utilizzo:**

```bash
# Manuale
bash .devcontainer/configure-wordpress-url.sh

# Tramite Makefile
make update-url
```

### 3. Integrazione in Post-Start Hook

**File:** `.devcontainer/post-start.sh`

Modificato per configurare automaticamente l'URL ad ogni avvio del Codespace:

```bash
if [ -n "$CODESPACE_NAME" ]; then
    echo "🔧 Configurazione URL WordPress per Codespaces..."
    CS_DOMAIN=${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-app.github.dev}
    WP_PUBLIC="https://${CODESPACE_NAME}-8000.${CS_DOMAIN}"

    docker exec wordpress-db mysql -u wordpress_user -pwordpress_pass wordpress_db -e \
        "UPDATE wp_options SET option_value = '$WP_PUBLIC' WHERE option_name IN ('siteurl', 'home');" \
        2>/dev/null

    echo "✅ URL WordPress configurato: $WP_PUBLIC"
fi
```

### 4. Integrazione in Setup Script

**File:** `setup.sh`

Lo script di setup ora configura automaticamente l'URL durante il primo avvio.

## Comportamento

### Su GitHub Codespaces

1. **Avvio Container:** `docker-compose up` applica automaticamente la configurazione HTTPS
2. **Post-Start Hook:** Configura l'URL nel database: `https://CODESPACE_NAME-8000.app.github.dev`
3. **Astro Frontend:** `.env` configurato con lo stesso URL
4. **Risultato:** Tutto funziona immediatamente con HTTPS

### In Locale

1. **Avvio Container:** Nessuna modifica HTTPS (non necessaria)
2. **URL:** `http://localhost:8000`
3. **Risultato:** Setup standard per sviluppo locale

## Test

```bash
# Verifica URL nel database
docker exec wordpress-db mysql -u wordpress_user -pwordpress_pass wordpress_db \
  -e "SELECT option_value FROM wp_options WHERE option_name IN ('siteurl', 'home');"

# Verifica file .env
cat frontend/.env

# Test manuale configurazione
make update-url
```

## Risoluzione Problemi

### Errore 502 su wp-admin

```bash
# Riavvia WordPress
docker-compose restart wordpress

# Riconfigura URL
make update-url
```

### URL errato nel database

```bash
# Esegui lo script di configurazione
make update-url
```

### WordPress non riconosce HTTPS

Verifica che `docker-compose.yml` contenga la configurazione HTTPS:

```yaml
WORDPRESS_CONFIG_EXTRA: |
  // ... altre configurazioni ...
  // GitHub Codespaces HTTPS support
  if (isset($_SERVER['HTTP_HOST']) && strpos($_SERVER['HTTP_HOST'], 'app.github.dev') !== false) {
      $_SERVER['HTTPS'] = 'on';
      define('FORCE_SSL_ADMIN', true);
  }
```

## Comandi Utili

```bash
# Setup completo
make setup

# Riconfigura URL
make update-url

# Riavvia WordPress
docker-compose restart wordpress

# Verifica log WordPress
make wp-logs

# Pulisci e ricomincia
make docker-clean && make setup
```

## File Modificati

- ✅ `docker-compose.yml` - Configurazione HTTPS automatica
- ✅ `.devcontainer/post-start.sh` - Hook post-avvio
- ✅ `.devcontainer/configure-wordpress-url.sh` - Script dedicato (nuovo)
- ✅ `setup.sh` - Configurazione durante setup
- ✅ `Makefile` - Comando `make update-url`

## Manutenzione

Queste configurazioni sono **automatiche** e non richiedono intervento manuale. Ogni volta che:

- Rebuildi il Codespace
- Riavvii i container
- Esegui `make setup`

L'URL viene configurato automaticamente in base all'ambiente.
