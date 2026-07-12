# Andes Mobility — Supabase Deploy Script
# Usage: ./scripts/deploy-supabase.sh

set -euo pipefail

echo "=== Deploying Supabase ==="

# Link project
echo "Linking project..."
supabase link --project-ref "${SUPABASE_PROJECT_ID:-}"

# Push migrations
echo "Pushing database migrations..."
supabase db push

# Deploy Edge Functions
echo "Deploying Edge Functions..."
supabase functions deploy send-push-notification --no-verify-jwt
supabase functions deploy validate-device-binding --no-verify-jwt

echo "=== Supabase Deploy Complete ==="
