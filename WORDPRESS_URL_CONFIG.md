# Configurazione URL WordPress

## Panoramica

Le chiamate API a WordPress sono ora completamente configurabili tramite variabili d'ambiente, supportando sviluppo locale, GitHub Codespaces e produzione.

## Configurazione

### File da modificare

**frontend/.env**:

```env
PUBLIC_WORDPRESS_URL=http://localhost:8000
```

### Esempi per Diversi Ambienti

#### Sviluppo Locale

```env
PUBLIC_WORDPRESS_URL=http://localhost:8000
```

#### GitHub Codespaces

```env
# Usa localhost (rete Docker interna)
PUBLIC_WORDPRESS_URL=http://localhost:8000
```

#### Staging

```env
PUBLIC_WORDPRESS_URL=https://staging.example.com
```

#### Produzione

```env
PUBLIC_WORDPRESS_URL=https://api.example.com
```

## Come Funziona

### Frontend (Astro)

Il file [frontend/src/lib/wordpress-api.ts](frontend/src/lib/wordpress-api.ts) usa questa logica:

1. **Variabile d'ambiente esplicita**: Se `PUBLIC_WORDPRESS_URL` è definito, usa quello
2. **Auto-detect Codespaces**: Se `PUBLIC_CODESPACE_NAME` esiste, usa `localhost:8000`
3. **Fallback locale**: Altrimenti usa `http://localhost:8000`

### Backend (WordPress CORS)

Il file [cms/cors-config.php](cms/cors-config.php) gestisce CORS automaticamente:

- Localhost sulle porte comuni (3000, 4321, 5173)
- Auto-detect URL Codespaces da `$_ENV['CODESPACE_NAME']`
- Pattern wildcard per tutti gli URL `*.app.github.dev`

## Testing

### Verifica URL in uso

Apri la console del browser quando visiti il frontend:

```
[WordPress API] Base URL: http://localhost:8000
```

### Test API manuale

```bash
# Locale
curl http://localhost:8000/wp-json/wp/v2/posts

# Con variabile personalizzata
PUBLIC_WORDPRESS_URL=https://example.com npm run dev
```

## Risoluzione Problemi

### CORS Errors

Se vedi errori CORS nella console:

1. Verifica che [cms/cors-config.php](cms/cors-config.php) sia incluso in `wp-config.php`
2. Controlla che l'origine sia nella whitelist
3. In Codespaces, verifica che `CODESPACE_NAME` sia impostato

### URL non corretto

```bash
# Verifica il valore della variabile
echo $PUBLIC_WORDPRESS_URL

# Riavvia il dev server
cd frontend
npm run dev
```

### In produzione

Assicurati di:

1. Settare `PUBLIC_WORDPRESS_URL` correttamente
2. Configurare HTTPS se necessario
3. Aggiungere il dominio frontend a `cors-config.php`

## Variabili d'Ambiente Supportate

| Variabile               | Scopo                 | Richiesto                    |
| ----------------------- | --------------------- | ---------------------------- |
| `PUBLIC_WORDPRESS_URL`  | URL base WordPress    | No (default: localhost:8000) |
| `PUBLIC_CODESPACE_NAME` | Nome Codespace (auto) | No                           |

**NOTA**: In Astro, solo le variabili che iniziano con `PUBLIC_` sono accessibili lato client.
