# Linee guida per il contributo

## Branches
- `main` - Branch principale (stable)
- `develop` - Development branch

## Come contribuire

1. Crea un branch dal `develop`: `git checkout -b feature/descrizione`
2. Fai i cambiamenti
3. Esegui i test: `npm run build`
4. Commit: `git commit -m "feat: descrizione"`
5. Push: `git push origin feature/descrizione`
6. Apri una Pull Request

## Commit messages

- `feat:` - Nuove funzionalità
- `fix:` - Bug fixes
- `docs:` - Documentazione
- `style:` - Formatting
- `refactor:` - Refactoring
- `test:` - Test

## Testing

```bash
# Build frontend
cd frontend && npm run build

# Test locale
npm run dev
```

## Pull Request

Includi:
- Descrizione dei cambiamenti
- Link ai related issues
- Screenshot se applicabile
