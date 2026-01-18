#!/bin/bash

# Script to display Google OAuth Redirect Origins & URIs
# Run: bash scripts/get-redirect-info.sh

echo "🔗 Google OAuth Redirect Origins & URIs"
echo "========================================"
echo ""

echo "📱 FOR ANDROID:"
echo "   ✅ No redirect origins/URIs needed"
echo "   ✅ Only need: Package Name + SHA-1"
echo "   Package Name: com.example.chefli_flutter"
echo "   SHA-1: 56:2B:F0:B5:DB:B6:6F:F0:41:6B:55:40:2F:8C:A3:5C:F0:1C:7C:6C"
echo ""

echo "🌐 FOR WEB (Flutter Web):"
echo ""
echo "   Authorized JavaScript Origins:"
echo "   - http://localhost:8080 (development)"
echo "   - https://your-production-domain.com (production - replace with your domain)"
echo ""

echo "   Authorized Redirect URIs:"
echo "   - http://localhost:8080/auth/google/callback (development)"
echo "   - https://your-production-domain.com/auth/google/callback (production - replace with your domain)"
echo ""

echo "📝 Quick Copy-Paste for Google Cloud Console:"
echo ""
echo "JavaScript Origins:"
echo "  http://localhost:8080"
echo ""
echo "Redirect URIs:"
echo "  http://localhost:8080/auth/google/callback"
echo ""

echo "📖 See GOOGLE_REDIRECT_ORIGINS.md for complete guide"
echo ""



