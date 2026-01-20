# Persistenza Dati in GitHub Codespaces

## 📦 Panoramica

Tutti i contenuti creati in WordPress (post, pagine, media, configurazioni) sono **persistenti** tra i rebuild del Codespace grazie all'uso di bind mount invece di volumi Docker nominati.

## 🗂️ Struttura Dati Persistenti

```
/workspaces/codespaces-wordpress-astro/
├── cms/
│   ├── db_data/              # Database MySQL (208 MB) ✅ PERSISTENTE
│   │   └── mysql/            # Dati tabelle WordPress
│   ├── wordpress/            # File WordPress (90 MB) ✅ PERSISTENTE
│   │   ├── wp-content/
│   │   │   ├── uploads/      # Media caricati
│   │   │   ├── themes/       # Temi WordPress
│   │   │   └── plugins/      # Plugin WordPress
│   │   ├── wp-config.php     # Configurazione WordPress
│   │   └── ...
│   ├── themes/               # Temi custom (versionati Git)
│   └── plugins/              # Plugin custom (versionati Git)
└── frontend/                 # Astro frontend (159 MB) ✅ PERSISTENTE
    ├── src/                  # Codice sorgente Astro
    │   ├── pages/            # Pagine e route
    │   ├── components/       # Componenti riutilizzabili
    │   └── lib/              # Librerie e utilità
    ├── node_modules/         # Dipendenze npm (persistente)
    ├── dist/                 # Build di produzione (persistente)
    └── .astro/               # Cache Astro (persistente)
```

## ✅ Cosa è Persistente

### 1. Database MySQL (`cms/db_data/`)

- ✅ Tutti i post e pagine
- ✅ Utenti e password
- ✅ Commenti
- ✅ Opzioni e configurazioni
- ✅ Categorie e tag
- ✅ URL configurati (siteurl, home)

### 2. File WordPress (`cms/wordpress/`)

- ✅ Media caricati (immagini, PDF, video)
- ✅ Temi installati via admin
- ✅ Plugin installati via admin
- ✅ File di configurazione

### 3. Temi e Plugin Custom (`cms/themes/`, `cms/plugins/`)

- ✅ Versionati in Git
- ✅ Persistenti e sincronizzati

### 4. Frontend Astro (`frontend/`)

- ✅ **Codice sorgente** (pages, components, lib) - Versionato in Git
- ✅ **node_modules** - Persistente (non versionato, ma rimane tra i rebuild)
- ✅ **Build output** (dist/) - Persistente (può essere rigenerato)
- ✅ **Cache Astro** (.astro/) - Persistente (ottimizza rebuild)
- ✅ **Configurazioni** (.env, package.json) - Versionato in Git

## 🔄 Come Funziona

### Docker Compose Configurazione

```yaml
services:
  db:
    volumes:
      # Bind mount - mappa directory workspace
      - ./cms/db_data:/var/lib/mysql

  wordpress:
    volumes:
      # Bind mount - mappa directory workspace
      - ./cms/wordpress:/var/www/html
      - ./cms/themes:/var/www/html/wp-content/themes
      - ./cms/plugins:/var/www/html/wp-content/plugins
```

**Bind Mount vs Volume Docker:**

- ❌ Volume Docker nominato = NON persistente in Codespaces (perso al rebuild)
- ✅ Bind mount (./path) = PERSISTENTE in Codespaces (salvato nel workspace)

### Frontend Astro - Persistenza Nativa

Il frontend Astro **non usa Docker** ma gira direttamente sul filesystem del Codespace. Questo significa:

- ✅ **Persistenza automatica**: Tutto il codice in `frontend/` è persistente per default
- ✅ **Git integrato**: Modifiche sincronizzate automaticamente
- ✅ **node_modules persistente**: Le dipendenze rimangono installate tra i rebuild
- ✅ **Build cache**: `.astro/` e `dist/` persistenti per build più veloci
- ✅ **Hot reload**: Modifiche immediate senza rebuild container

**Non serve configurazione Docker** per il frontend - è tutto sul workspace Codespaces!

## 🧪 Test di Persistenza

### Test 1: Crea un Post

```bash
# 1. Crea un post in WordPress Admin
# 2. Riavvia i container
docker-compose restart

# 3. Verifica che il post esista ancora
curl http://localhost:8000/wp-json/wp/v2/posts
```

### Test 2: Carica un'Immagine

```bash
# 1. Carica un'immagine in Media Library
# 2. Verifica che sia salvata
ls -lh cms/wordpress/wp-content/uploads/

# 3. Riavvia i container
docker-compose restart

# 4. L'immagine è ancora presente
ls -lh cms/wordpress/wp-content/uploads/
```

### Test 3: Rebuild Completo

```bash
# 1. Ferma e rimuovi tutti i container
docker-compose down

# 2. Riavvia
docker-compose up -d

# 3. Tutti i dati sono ancora presenti
make wp-check
```

### Test 4: Modifiche Frontend Astro

```bash
# 1. Modifica un file Astro
echo "<!-- Test persistenza -->" >> frontend/src/pages/index.astro

# 2. Verifica la modifica
tail -1 frontend/src/pages/index.astro

# 3. Riavvia il Codespace (o simula rebuild)
# Le modifiche rimangono permanenti ✅

# 4. Verifica node_modules persistente
ls frontend/node_modules | wc -l
# Se > 0, le dipendenze sono persistenti
```

## 📊 Dimensioni Tipiche

| Componente                          | Dimensione  | Descrizione                    |
| ----------------------------------- | ----------- | ------------------------------ |
| `cms/db_data/`                      | ~200-500 MB | Cresce con contenuti WordPress |
| `cms/wordpress/`                    | ~80-200 MB  | Base WordPress + upload        |
| `frontend/`                         | ~150-200 MB | Codice + node_modules + build  |
| `frontend/node_modules/`            | ~120-150 MB | Dipendenze npm                 |
| `cms/wordpress/wp-content/uploads/` | Variabile   | Media caricati                 |

## ⚠️ Importante

### Cosa NON è Versionato in Git

Per evitare di appesantire il repository, questi file sono in `.gitignore`:

```gitignore
# Database - persistente ma non versionato
cms/db_data/

# WordPress core - persistente ma non versionato
cms/wordpress/

# Temi e plugin CUSTOM - versionati
!cms/themes/
!cms/plugins/
```

### Backup Consigliato

Anche se i dati sono persistenti in Codespaces, è consigliato fare backup periodici:

```bash
# Backup database
docker exec wordpress-db mysqldump -u wordpress_user -pwordpress_pass wordpress_db > backup.sql

# Backup completo
tar -czf wordpress-backup.tar.gz cms/db_data cms/wordpress
```

## 🔍 Verifica Persistenza

```bash
# Comando rapido
make wp-check

# Verifica dettagliata
du -sh cms/db_data cms/wordpress
ls -lh cms/wordpress/wp-content/uploads/
docker exec wordpress-db mysql -u wordpress_user -pwordpress_pass wordpress_db -e "SELECT COUNT(*) FROM wp_posts;"
```

## 🚀 Migrazione da Volume a Bind Mount

Il progetto è stato aggiornato per usare bind mount. Se hai un Codespace esistente:

1. **Backup automatico**: Lo script ha già migrato i dati
2. **Nuova configurazione**: `docker-compose.yml` usa bind mount
3. **Nessuna azione richiesta**: Tutto funziona automaticamente

## 📝 Note Tecniche

### GitHub Codespaces Storage

- **Workspace**: 32 GB persistenti per default
- **Docker volumes**: Temporanei, persi al rebuild
- **Bind mounts**: Persistenti, mappati sul workspace

### Prestazioni

- Bind mount ha prestazioni simili ai volumi Docker
- In Codespaces, entrambi sono veloci (storage SSD)
- Nessun impatto negativo sulle performance

## 🆘 Risoluzione Problemi

### Database vuoto dopo restart

```bash
# Verifica che la directory esista
ls -la cms/db_data

# Se vuota, reinstalla WordPress
make wp-install
```

### Uploads non visibili

```bash
# Verifica permessi
docker exec wordpress-cms chown -R www-data:www-data /var/www/html/wp-content/uploads

# Riavvia
docker-compose restart wordpress
```

### Troppo spazio utilizzato

```bash
# Pulisci revisioni vecchie in WordPress Admin
# Oppure ottimizza database
docker exec wordpress-db mysqlcheck -u root -proot_password --optimize wordpress_db
```

## ✅ Conclusione

Con la configurazione attuale:

- ✅ Tutti i contenuti WordPress sono persistenti
- ✅ Nessuna perdita di dati al rebuild
- ✅ Backup facile (directory filesystem)
- ✅ Performance ottimali
- ✅ Sincronizzazione automatica in Codespaces
