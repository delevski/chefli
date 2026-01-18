# Media Processing Setup Guide

This guide will help you set up free OCR (image text extraction) and audio transcription features.

## ✅ What's Included

- **OCR (Image to Text)**: Uses Tesseract.js - **100% FREE**, runs locally, no API key needed
- **Audio Transcription**: Uses AssemblyAI - **FREE tier: 2 hours/month**

## 📋 Setup Instructions

### 1. Install Backend Dependencies

```bash
npm install
```

This will install:
- `multer` - For handling file uploads
- `tesseract.js` - Free OCR library (runs locally)

### 2. Set Up AssemblyAI (Free Tier)

1. **Sign up for free account**: Go to https://www.assemblyai.com
2. **Get your API key**: After signing up, go to your dashboard and copy your API key
3. **Set environment variable**:

   **Option A: Create `.env` file** (recommended)
   ```bash
   # In the root directory, create .env file
   ASSEMBLYAI_API_KEY=your_api_key_here
   ```

   **Option B: Export in terminal** (temporary)
   ```bash
   export ASSEMBLYAI_API_KEY=your_api_key_here
   ```

   **Option C: Add to server.js** (not recommended for production)
   ```javascript
   const apiKey = process.env.ASSEMBLYAI_API_KEY || 'your_api_key_here';
   ```

### 3. Update Flutter Backend URL

If your backend is not running on `localhost:3000`, update the URL in:

```dart
// chefli_flutter/lib/services/media_processing_service.dart
static const String baseUrl = 'http://localhost:3000'; // Change for production
```

For production, use your deployed backend URL:
```dart
static const String baseUrl = 'https://your-backend-url.com';
```

### 4. Start the Backend Server

```bash
npm run backend
```

Or for development with auto-reload:
```bash
npm run backend:dev
```

The server will show:
```
🚀 InstantDB Backend Proxy running on http://localhost:3000
📡 Health check: http://localhost:3000/health

Available endpoints:
  ...
  POST /api/ocr/extract-text (FREE - Tesseract.js)
  POST /api/speech/transcribe (FREE tier - AssemblyAI)
```

## 🎯 Usage

### OCR (Image to Text)

1. **In Flutter app**: Tap the camera/image icon
2. **Take or select image**: Choose from camera or gallery
3. **Automatic processing**: Text is extracted and added to the input field
4. **Supported languages**: English, Hebrew, Arabic, and 100+ more

**Language codes for OCR**:
- `eng` - English
- `heb` - Hebrew
- `ara` - Arabic
- `spa` - Spanish
- `fra` - French
- `deu` - German
- And 100+ more (see Tesseract.js docs)

**Multiple languages**: Use `eng+heb+ara` to detect multiple languages

### Audio Transcription

1. **In Flutter app**: Tap the microphone icon
2. **Record audio**: Speak your ingredients
3. **Stop recording**: Tap microphone again
4. **Automatic transcription**: Text is transcribed and added to input field

**Language codes for transcription**:
- `en` - English
- `he` - Hebrew
- `ar` - Arabic
- `es` - Spanish
- `fr` - French
- And 100+ more (see AssemblyAI docs)

## 🔧 Configuration

### Change OCR Languages

Edit `landing_screen.dart`:
```dart
final extractedText = await _mediaService.extractTextFromImage(
  imageFile,
  languageHints: ['eng', 'heb', 'ara'], // Add/remove languages
);
```

### Change Transcription Language

Edit `landing_screen.dart`:
```dart
final transcribedText = await _mediaService.transcribeAudio(
  audioFile,
  languageCode: 'en', // Change to 'he', 'ar', etc.
);
```

## 💰 Free Tier Limits

### Tesseract.js (OCR)
- ✅ **Unlimited** - Completely free, runs locally
- ✅ No API key needed
- ✅ No usage limits

### AssemblyAI (Transcription)
- ✅ **2 hours/month** - Free tier
- ✅ After free tier: $0.00025 per second (~$0.90 per hour)
- ✅ Sign up at https://www.assemblyai.com

## 🐛 Troubleshooting

### OCR Not Working

1. **Check backend is running**: `npm run backend`
2. **Check image format**: Supports JPG, PNG, GIF, WebP
3. **Check image size**: Max 10MB
4. **Check language codes**: Use valid Tesseract language codes

### Transcription Not Working

1. **Check API key**: Ensure `ASSEMBLYAI_API_KEY` is set
2. **Check backend logs**: Look for error messages
3. **Check audio format**: Supports MP3, M4A, WAV, WebM
4. **Check free tier**: Ensure you haven't exceeded 2 hours/month

### Backend Connection Error

1. **Check backend URL**: Ensure it matches in `media_processing_service.dart`
2. **Check CORS**: Backend should allow requests from Flutter app
3. **Check network**: Ensure backend is accessible

## 🔄 Alternative: Use Different Services

### OCR Alternatives

If you want to use a different OCR service:

1. **Google Cloud Vision** (1,000 images/month free)
   - Requires Google Cloud account
   - Better accuracy for complex images

2. **OCR.space** (Free tier available)
   - No API key needed for basic use
   - 5MB file size limit

### Transcription Alternatives

If you want to use a different transcription service:

1. **OpenAI Whisper API** ($5 free credits)
   - Better accuracy
   - Requires OpenAI account

2. **Google Cloud Speech-to-Text** (60 minutes/month free)
   - Requires Google Cloud account
   - Good accuracy

3. **Local Whisper** (Completely free)
   - Requires Python installation
   - Runs entirely locally

## 📚 Additional Resources

- **Tesseract.js Docs**: https://tesseract.projectnaptha.com
- **AssemblyAI Docs**: https://www.assemblyai.com/docs
- **Supported Languages**: 
  - OCR: https://github.com/naptha/tesseract.js/blob/master/docs/tesseract_lang_list.md
  - Transcription: https://www.assemblyai.com/docs/guides/supported-languages

## ✅ Testing

Test the endpoints:

```bash
# Test OCR
curl -X POST http://localhost:3000/api/ocr/extract-text \
  -F "image=@test-image.jpg" \
  -F "languageHints=eng"

# Test Transcription (requires API key)
curl -X POST http://localhost:3000/api/speech/transcribe \
  -F "audio=@test-audio.mp3" \
  -F "languageCode=en"
```

## 🎉 You're All Set!

Your app now supports:
- ✅ Extracting text from images (FREE)
- ✅ Transcribing audio to text (2 hours/month FREE)

Enjoy your free media processing features!


