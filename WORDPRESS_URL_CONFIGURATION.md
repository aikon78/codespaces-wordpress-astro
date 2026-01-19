# Configurazione URL WordPress - Guida Completa

## Architettura

**PRINCIPIO FONDAMENTALE:** WordPress usa il **database** (tabella `wp_options`) come unica fonte autoritativa per il dominio.

```
┌──────────────────────────────────────────┐
│     DATABASE (FONTE AUTORITATIVA)        │
│                                          │
│  wp_options:                             │
│    siteurl = "https://example.com"       │
│    home = "https://example.com"          │
│                                          │
└──────────────────────────────────────────┘
           ↑                    ↓
           │ Scritto da         │ Letto da
           │                    │
┌──────────┴────────┐    ┌──────┴─────────┐
│  Script Setup     │    │  WordPress     │
│  • install-wp.sh  │    │  • wp-load.php │
│  • setup-url.sh   │    │  (auto)        │
└───────────────────┘    └────────────────┘
```

## Il Problema

WordPress, una volta installato su un dominio specifico, rimane "legato" a quel dominio **nel database**. Se cambiate dominio (ad es., da `localhost:8000` a Codespaces URL) senza aggiornare il database:

- ❌ Fa redirect automatico al vecchio dominio
- ❌ I link interni rimangono hardcodati al vecchio dominio
- ❌ I media/asset potrebbero non caricarsi
- ❌ Le API REST rispondono con URL sbagliati

## La Soluzione: Database Come Unica Fonte

### ✅ Cosa NON Fare

**NON usare WP_HOME e WP_SITEURL in wp-config.php:**

```php
// ❌ SBAGLIATO - Sovrascrive il database
define( 'WP_HOME', 'http://localhost:8000' );
define( 'WP_SITEURL', 'http://localhost:8000' );
```

Questo crea confusione perché wp-config sovrascrive il database ma non lo aggiorna permanentemente.

### ✅ Cosa Fare

**Configurazione corretta in wp-config.php:**

```php
// ✅ CORRETTO - Lascia che WordPress legga dal database
// NON definire WP_HOME e WP_SITEURL

// Solo gestione proxy headers per Codespaces/reverse proxy
if ( isset( $_SERVER['HTTP_X_FORWARDED_PROTO'] ) ) {
    $_SERVER['HTTPS'] = 'on';
}
if ( isset( $_SERVER['HTTP_X_FORWARDED_HOST'] ) ) {
    $_SERVER['HTTP_HOST'] = $_SERVER['HTTP_X_FORWARDED_HOST'];
}
```

### Aggiornamento Database

**Metodo 1: Script automatico (raccomandato)**

```bash
# Rileva automaticamente l'ambiente e aggiorna il DB
bash setup-wordpress-url.sh

# O specifica manualmente
WORDPRESS_URL=https://example.com bash setup-wordpress-url.sh
```

**Metodo 2: MySQL diretto**

### Scenario 1: GitHub Codespaces (Automatico)

```bash
# Il sistema rileva automaticamente il dominio Codespaces
# Non devi fare nulla, tutto funziona out-of-the-box

docker-compose up -d
# WordPress sarà disponibile su:
# https://{TUO_CODESPACE_NAME}-8000.app.github.dev
```

### Scenario 2: Sviluppo Locale

Se vuoi usare `localhost:8000` sul tuo computer:

```bash
# Modifica .env
WORDPRESS_URL=http://localhost:8000

# Riavvia i container
docker-compose up -d
```

### Scenario 3: Production (Dominio Personalizzato)

```bash
# Modifica .env
WORDPRESS_URL=https://tuosito.com

# Oppure passa direttamente al comando
WORDPRESS_URL=https://tuosito.com docker-compose up -d
```

## Se WordPress è Già Installato

Se WordPress è stato installato con un URL sbagliato e rimane legato a quel dominio:

### Opzione A: Script Automatico (Consigliato) ⭐

```bash
# Questo aggiorna automaticamente il database
make update-url

# Oppure direttamente:
bash update-wordpress-url.sh
```

Lo script:

- ✅ Legge l'URL da `.env`
- ✅ Aggiorna le opzioni `siteurl` e `home` nel database
- ✅ Pulisce la cache di WordPress

### Opzione B: Manuale via phpMyAdmin

1. Vai a http://localhost:8080 (phpMyAdmin)
2. Login: `wordpress_user` / `wordpress_pass`
3. Seleziona il database `wordpress_db`
4. Vai alla tabella `wp_options`
5. Trova e modifica:
   - `siteurl` → nuovo URL
   - `home` → nuovo URL

### Opzione C: Linea di Comando

```bash
# Accedi al container MySQL
docker exec wordpress-db mysql -h db -u wordpress_user -pwordpress_pass wordpress_db

# Esegui i comandi:
UPDATE wp_options SET option_value = 'https://new-url.com' WHERE option_name = 'siteurl';
UPDATE wp_options SET option_value = 'https://new-url.com' WHERE option_name = 'home';
DELETE FROM wp_options WHERE option_name LIKE '_transient_%' OR option_name LIKE '_site_transient_%';
```

## Troubleshooting

### 🔄 Redirect infiniti a localhost

**Soluzione:**

```bash
# 1. Aggiorna l'URL
make update-url

# 2. Cancella i cookie del browser (importante!)
# 3. Usa una finestra in incognito per testare

# 4. Svuota la cache di WordPress
docker exec wordpress-cms wp cache flush
```

### ❌ WordPress restituisce "ERR_TOO_MANY_REDIRECTS"

**Cause possibili:**

- `WP_HOME` e `WP_SITEURL` hanno valori diversi
- Il database ha l'URL sbagliato
- Si sta accedendo da un dominio diverso

**Soluzione:**

```bash
# Riavvia i container per riapplicare la configurazione
docker-compose restart wordpress

# Verifica le opzioni nel database
docker exec wordpress-db mysql -h db -u wordpress_user -pwordpress_pass wordpress_db -e "SELECT option_name, option_value FROM wp_options WHERE option_name IN ('siteurl', 'home');"
```

### 🔒 SSL/HTTPS non funziona

WordPress deve sapere che sta dietro un proxy HTTPS:

```php
// In wp-config.php è già configurato automaticamente:
if ( isset( $_SERVER['HTTP_X_FORWARDED_PROTO'] ) && strpos($_SERVER['HTTP_X_FORWARDED_PROTO'], 'https') !== false ) {
    $_SERVER['HTTPS'] = 'on';
}
```

### 🌐 Media non carica

Se le immagini non si vedono:

```bash
# Aggiorna l'URL (aggiorna anche i riferimenti nei media)
make update-url

# Oppure rigenera gli URL dei media
docker exec wordpress-cms wp cache flush
docker exec wordpress-cms wp db query "UPDATE wp_posts SET post_content = REPLACE(post_content, 'http://localhost', 'https://new-url');"
```

## Differenze tra WP_HOME e WP_SITEURL

| Costante            | Uso                        | Esempio               |
| ------------------- | -------------------------- | --------------------- |
| **WP_HOME**         | URL frontend (navigazione) | `https://example.com` |
| **WP_SITEURL**      | URL backend (dashboard)    | `https://example.com` |
| **Option: siteurl** | Fallback nel database      | `https://example.com` |
| **Option: home**    | Fallback nel database      | `https://example.com` |

**Nota:** Devono essere uguali per evitare redirect.

## Per i Prossimi Setup

Per evitare questo problema in futuri setup:

```bash
# Usa lo script setup.sh che lo farà automaticamente
bash setup.sh

# Oppure assicurati di impostare l'URL prima di installare WordPress
WORDPRESS_URL=https://tuodominio.com docker-compose up -d
```

## Verifica Finale

Dopo gli aggiornamenti, verifica che tutto funzioni:

```bash
# 1. Verifica che wp-config.php abbia la giusta configurazione
grep -A 2 "WP_HOME\|WP_SITEURL" cms/wordpress/wp-config.php

# 2. Verifica le opzioni nel database
docker exec wordpress-db mysql -h db -u wordpress_user -pwordpress_pass wordpress_db \
  -e "SELECT option_name, option_value FROM wp_options WHERE option_name IN ('siteurl', 'home');"

# 3. Testa l'URL dalla dashboard WordPress
# Admin > Settings > General (URL deve corrispondere a quello configurato)
```

## Ulteriori Risorse

- [WordPress Changing Site URL](https://wordpress.org/support/article/changing-the-site-url/)
- [WordPress wp-config.php Documentation](https://developer.wordpress.org/advanced-administration/wordpress/wp-config/)
- [Docker WordPress Official Documentation](https://github.com/docker-library/wordpress)
