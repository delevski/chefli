# Quick Start: Media Processing (OCR & Transcription)

## 🚀 Quick Setup (5 minutes)

### Step 1: Install Dependencies
```bash
npm install
```

### Step 2: Get Free AssemblyAI API Key
1. Go to https://www.assemblyai.com
2. Sign up (free account)
3. Copy your API key from dashboard
4. Create `.env` file in root directory:
   ```
   ASSEMBLYAI_API_KEY=your_api_key_here
   ```

### Step 3: Start Backend
```bash
npm run backend
```

### Step 4: Test It!
- **OCR**: Take/select an image → Text is automatically extracted
- **Transcription**: Record audio → Text is automatically transcribed

## ✅ What's Free?

- ✅ **OCR (Image to Text)**: 100% FREE, unlimited (Tesseract.js)
- ✅ **Audio Transcription**: 2 hours/month FREE (AssemblyAI)

## 📱 How It Works

1. **Image OCR**: 
   - User takes/selects image
   - Backend extracts text using Tesseract.js
   - Text is added to input field automatically

2. **Audio Transcription**:
   - User records audio
   - Backend transcribes using AssemblyAI
   - Text is added to input field automatically

## 🔧 Configuration

### Change Backend URL (if not localhost:3000)
Edit: `chefli_flutter/lib/services/media_processing_service.dart`
```dart
static const String baseUrl = 'http://your-backend-url.com';
```

### Change Supported Languages
Edit: `chefli_flutter/lib/features/landing/landing_screen.dart`

For OCR:
```dart
languageHints: ['eng', 'heb', 'ara'] // Add more: 'spa', 'fra', etc.
```

For Transcription:
```dart
languageCode: 'en' // Change to 'he', 'ar', 'es', etc.
```

## 🐛 Troubleshooting

**OCR not working?**
- Check backend is running: `npm run backend`
- Check image format (JPG, PNG supported)
- Check image size (max 10MB)

**Transcription not working?**
- Check API key is set: `echo $ASSEMBLYAI_API_KEY`
- Check backend logs for errors
- Check free tier limit (2 hours/month)

**Backend connection error?**
- Check backend URL matches in Flutter service
- Check backend is running on correct port
- Check CORS settings

## 📚 Full Documentation

See `MEDIA_PROCESSING_SETUP.md` for detailed setup and configuration.

## 🎉 You're Done!

Your app now supports free OCR and transcription!


