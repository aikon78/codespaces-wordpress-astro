#!/bin/bash
# Script per ottenere un cookie di sessione WordPress e accedere all'admin

WORDPRESS_URL="${1:-http://localhost:8000}"
USERNAME="${2:-admin}"
PASSWORD="${3:-admin123}"
COOKIE_JAR="/tmp/wp-session-cookies.txt"

echo "WordPress Admin Session Manager"
echo "================================"
echo "URL: $WORDPRESS_URL"
echo "User: $USERNAME"
echo ""

# Step 1: Fai il login
echo "[1/2] Logging in..."
curl -s "$WORDPRESS_URL/wp-login.php" \
  -X POST \
  -b "$COOKIE_JAR" \
  -c "$COOKIE_JAR" \
  -d "log=$USERNAME&pwd=$PASSWORD&wp-submit=Log+In&redirect_to=$WORDPRESS_URL/wp-admin/&testcookie=1" \
  -L > /dev/null

# Step 2: Accedi al dashboard
echo "[2/2] Accessing dashboard..."
RESPONSE=$(curl -s "$WORDPRESS_URL/wp-admin/" -b "$COOKIE_JAR")

# Verifica se il login è riuscito
if echo "$RESPONSE" | grep -q "Dashboard"; then
  echo ""
  echo "✓ Successfully logged in!"
  echo ""
  echo "You can now use these commands:"
  echo ""
  echo "  # View the dashboard:"
  echo "  curl -b $COOKIE_JAR '$WORDPRESS_URL/wp-admin/' | grep -i 'title'"
  echo ""
  echo "  # Fetch posts via API:"
  echo "  curl '$WORDPRESS_URL/index.php?rest_route=/wp/v2/posts'"
  echo ""
  echo "Cookie jar saved to: $COOKIE_JAR"
  exit 0
else
  echo ""
  echo "✗ Login failed!"
  echo ""
  echo "Check your credentials:"
  echo "  Username: $USERNAME"
  echo "  Password: $PASSWORD"
  exit 1
fi
