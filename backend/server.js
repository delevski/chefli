/**
 * Express Server for InstantDB Backend Proxy
 * 
 * Run this server to enable InstantDB integration with Flutter app.
 * 
 * Usage:
 *   node backend/server.js
 * 
 * The server will run on http://localhost:3000
 */

import express from 'express';
import cors from 'cors';
import multer from 'multer';
import FormData from 'form-data';
import path from 'path';
import { fileURLToPath } from 'url';
import { createWorker } from 'tesseract.js';
import { setupExpressRoutes } from './instantdb-proxy.js';

// ES Module path resolution
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3000;

// Configure multer for file uploads
const upload = multer({ 
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 } // 10MB limit
});

// Middleware
app.use(cors());
app.use(express.json());

// Serve static files from dist folder in production
const distPath = path.join(__dirname, '../dist');
if (process.env.NODE_ENV === 'production') {
  app.use(express.static(distPath));
}

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'InstantDB Backend Proxy is running' });
});

// Setup InstantDB proxy routes
setupExpressRoutes(app);

// LangChain Agent Proxy endpoint - Forward recipe generation requests to LangChain agent
app.post('/api/recipes/generate', async (req, res) => {
  try {
    const langChainUrl = process.env.LANGCHAIN_URL || 'https://ordi1985.pythonanywhere.com/generate-recipe';
    
    // Support both request formats: "menu" (comma-separated string) or "ingredients" (array)
    let requestBody;
    if (req.body.menu) {
      // Already in LangChain format
      requestBody = { menu: req.body.menu };
    } else if (req.body.ingredients) {
      // Convert array to comma-separated string
      const ingredientsList = Array.isArray(req.body.ingredients)
        ? req.body.ingredients
        : req.body.ingredients.split(',').map(ing => ing.trim()).filter(ing => ing.length > 0);
      requestBody = { menu: ingredientsList.join(',') };
    } else {
      return res.status(400).json({ 
        error: 'Invalid request format',
        message: 'Request must include either "menu" (comma-separated string) or "ingredients" (array)'
      });
    }

    console.log(`Forwarding recipe generation request to LangChain agent: ${langChainUrl}`);

    // Forward request to LangChain agent
    const response = await fetch(langChainUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(requestBody),
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`LangChain agent error: ${response.status} - ${errorText}`);
    }

    const data = await response.json();
    res.json(data);
  } catch (error) {
    console.error('LangChain Proxy Error:', error);
    res.status(500).json({ 
      error: 'Failed to generate recipe',
      details: error.message 
    });
  }
});

// OCR endpoint - Extract text from images using Tesseract.js (FREE)
app.post('/api/ocr/extract-text', upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No image file provided' });
    }

    // Parse language hints (e.g., 'eng+heb+ara' for English+Hebrew+Arabic)
    // Default to English if not provided
    const languageHints = req.body.languageHints || 'eng';
    
    // Supported languages: eng, heb, ara, spa, fra, deu, etc.
    // Multiple languages: 'eng+heb' for English and Hebrew
    
    console.log(`Processing OCR with languages: ${languageHints}`);

    // Create Tesseract worker with specified languages
    const worker = await createWorker(languageHints);
    
    // Perform OCR
    const { data: { text, confidence } } = await worker.recognize(req.file.buffer);
    
    // Clean up worker
    await worker.terminate();

    // Clean up text (remove extra whitespace)
    const cleanedText = text.trim().replace(/\n{3,}/g, '\n\n');

    res.json({
      text: cleanedText,
      confidence: confidence / 100, // Convert to 0-1 scale
      detectedLanguages: languageHints
    });
  } catch (error) {
    console.error('OCR Error:', error);
    res.status(500).json({ 
      error: 'Failed to extract text from image',
      details: error.message 
    });
  }
});

// Speech-to-Text endpoint - Transcribe audio using AssemblyAI (FREE tier: 2 hours/month)
app.post('/api/speech/transcribe', upload.single('audio'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No audio file provided' });
    }

    const languageCode = req.body.languageCode || 'en'; // Default to English
    const apiKey = process.env.ASSEMBLYAI_API_KEY;

    if (!apiKey) {
      return res.status(500).json({ 
        error: 'AssemblyAI API key not configured',
        message: 'Please set ASSEMBLYAI_API_KEY environment variable. Get free API key at https://www.assemblyai.com'
      });
    }

    console.log(`Transcribing audio with language: ${languageCode}`);

    // Step 1: Upload audio file to AssemblyAI
    const formData = new FormData();
    formData.append('file', req.file.buffer, {
      filename: req.file.originalname || 'audio.mp3',
      contentType: req.file.mimetype || 'audio/mpeg',
    });

    const uploadResponse = await fetch('https://api.assemblyai.com/v2/upload', {
      method: 'POST',
      headers: {
        'authorization': apiKey,
        ...formData.getHeaders(), // Include form-data headers
      },
      body: formData,
    });

    if (!uploadResponse.ok) {
      const errorText = await uploadResponse.text();
      throw new Error(`Upload failed: ${errorText}`);
    }

    const { upload_url } = await uploadResponse.json();

    // Step 2: Start transcription job
    const transcriptResponse = await fetch('https://api.assemblyai.com/v2/transcript', {
      method: 'POST',
      headers: {
        'authorization': apiKey,
        'content-type': 'application/json',
      },
      body: JSON.stringify({
        audio_url: upload_url,
        language_code: languageCode,
        punctuate: true,
        format_text: true,
      }),
    });

    if (!transcriptResponse.ok) {
      const errorText = await transcriptResponse.text();
      throw new Error(`Transcription start failed: ${errorText}`);
    }

    const { id } = await transcriptResponse.json();

    // Step 3: Poll for transcription results
    let transcriptResult;
    let attempts = 0;
    const maxAttempts = 60; // Max 60 seconds wait time

    while (attempts < maxAttempts) {
      const checkResponse = await fetch(`https://api.assemblyai.com/v2/transcript/${id}`, {
        headers: {
          'authorization': apiKey,
        },
      });

      if (!checkResponse.ok) {
        throw new Error(`Status check failed: ${checkResponse.statusText}`);
      }

      transcriptResult = await checkResponse.json();
      
      if (transcriptResult.status === 'completed') {
        break;
      } else if (transcriptResult.status === 'error') {
        throw new Error(transcriptResult.error || 'Transcription failed');
      }
      
      // Wait 1 second before checking again
      await new Promise(resolve => setTimeout(resolve, 1000));
      attempts++;
    }

    if (transcriptResult.status !== 'completed') {
      throw new Error('Transcription timed out');
    }

    res.json({
      text: transcriptResult.text || '',
      confidence: 1.0, // AssemblyAI doesn't provide per-word confidence in basic tier
      languageCode: transcriptResult.language_code || languageCode
    });
  } catch (error) {
    console.error('Transcription Error:', error);
    res.status(500).json({ 
      error: 'Failed to transcribe audio',
      details: error.message 
    });
  }
});

// SPA catch-all route - serve index.html for all non-API routes (must be after all API routes)
if (process.env.NODE_ENV === 'production') {
  app.get('*', (req, res) => {
    res.sendFile(path.join(distPath, 'index.html'));
  });
}

// Start server
app.listen(PORT, () => {
  console.log(`🚀 InstantDB Backend Proxy running on http://localhost:${PORT}`);
  console.log(`📡 Health check: http://localhost:${PORT}/health`);
  if (process.env.NODE_ENV === 'production') {
    console.log(`🌐 Serving webapp from: ${distPath}`);
  }
  console.log(`\nAvailable endpoints:`);
  console.log(`  POST /api/users/create`);
  console.log(`  POST /api/users/find`);
  console.log(`  POST /api/users/find-google`);
  console.log(`  POST /api/users/create-google`);
  console.log(`  PUT  /api/users/update/:userId`);
  console.log(`  POST /api/recipes/save`);
  console.log(`  POST /api/recipes/get`);
  console.log(`  POST /api/recipes/generate (LangChain Agent Proxy)`);
  console.log(`  POST /api/ocr/extract-text (FREE - Tesseract.js)`);
  console.log(`  POST /api/speech/transcribe (FREE tier - AssemblyAI)`);
});


