#!/bin/bash

# Script to get Google OAuth configuration info for Android
# Run: bash scripts/get-google-auth-info.sh

echo "🔍 Getting Google OAuth Configuration Info for Android"
echo "======================================================"
echo ""

# Get package name from build.gradle.kts
PACKAGE_NAME=$(grep 'applicationId' chefli_flutter/android/app/build.gradle.kts | head -1 | sed 's/.*applicationId.*"\([^"]*\)".*/\1/')

if [ -z "$PACKAGE_NAME" ]; then
    PACKAGE_NAME="com.example.chefli_flutter"
fi

echo "📦 Package Name:"
echo "   $PACKAGE_NAME"
echo ""

# Get SHA-1 from debug keystore
echo "🔐 SHA-1 Certificate Fingerprint:"
echo ""

DEBUG_KEYSTORE="$HOME/.android/debug.keystore"

if [ -f "$DEBUG_KEYSTORE" ]; then
    echo "   Debug Keystore:"
    SHA1_RAW=$(keytool -list -v -keystore "$DEBUG_KEYSTORE" -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep "SHA1:" | head -1)
    if [ ! -z "$SHA1_RAW" ]; then
        # Extract SHA-1 value (format: XX:XX:XX:XX...)
        SHA1_DEBUG=$(echo "$SHA1_RAW" | awk -F'SHA1: ' '{print $2}' | awk '{print $1}')
        echo "   $SHA1_DEBUG"
    else
        echo "   Could not extract SHA-1 from debug keystore"
    fi
    echo ""
else
    echo "   ⚠️  Debug keystore not found at $DEBUG_KEYSTORE"
    echo "   Creating debug keystore..."
    keytool -genkey -v -keystore "$DEBUG_KEYSTORE" -alias androiddebugkey -storepass android -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"
    SHA1_DEBUG=$(keytool -list -v -keystore "$DEBUG_KEYSTORE" -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep -A 2 "SHA1:" | grep -oP 'SHA1:\s*\K[^:]+(:[^:]+){19}')
    if [ ! -z "$SHA1_DEBUG" ]; then
        echo "   $SHA1_DEBUG"
    fi
    echo ""
fi

# Check for release keystore
RELEASE_KEYSTORE="chefli_flutter/android/app/key.jks"
if [ -f "$RELEASE_KEYSTORE" ]; then
    echo "   Release Keystore (if configured):"
    read -p "   Enter keystore password (or press Enter to skip): " KEYSTORE_PASS
    if [ ! -z "$KEYSTORE_PASS" ]; then
        read -p "   Enter key alias (default: key): " KEY_ALIAS
        KEY_ALIAS=${KEY_ALIAS:-key}
        SHA1_RELEASE_RAW=$(keytool -list -v -keystore "$RELEASE_KEYSTORE" -alias "$KEY_ALIAS" -storepass "$KEYSTORE_PASS" 2>/dev/null | grep "SHA1:" | head -1)
        if [ ! -z "$SHA1_RELEASE_RAW" ]; then
            SHA1_RELEASE=$(echo "$SHA1_RELEASE_RAW" | awk -F'SHA1: ' '{print $2}' | awk '{print $1}')
        fi
        if [ ! -z "$SHA1_RELEASE" ]; then
            echo "   $SHA1_RELEASE"
        fi
    fi
    echo ""
fi

# Alternative: Use Gradle to get signing info
echo "📋 Getting SHA-1 using Gradle:"
cd chefli_flutter/android
./gradlew signingReport 2>&1 | grep -A 10 "Variant: debug" | grep -E "SHA1|SHA-1" || echo "   Run: cd chefli_flutter/android && ./gradlew signingReport"
cd ../..
echo ""

echo "✅ Configuration Info:"
echo "======================"
echo "Package Name: $PACKAGE_NAME"
if [ ! -z "$SHA1_DEBUG" ]; then
    echo "SHA-1 (Debug): $SHA1_DEBUG"
fi
echo ""
echo "📝 Next Steps:"
echo "1. Go to Google Cloud Console: https://console.cloud.google.com"
echo "2. Select your project (or create new)"
echo "3. Go to APIs & Services > Credentials"
echo "4. Create OAuth 2.0 Client ID (Android application)"
echo "5. Enter Package Name: $PACKAGE_NAME"
if [ ! -z "$SHA1_DEBUG" ]; then
    echo "6. Enter SHA-1: $SHA1_DEBUG"
fi
echo "7. Save and copy the Client ID"
echo "8. Add Client ID to chefli_flutter/lib/config/instantdb_config.dart"
echo ""

