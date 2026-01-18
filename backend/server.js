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
import { createWorker } from 'tesseract.js';
import { setupExpressRoutes } from './instantdb-proxy.js';

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

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'InstantDB Backend Proxy is running' });
});

// Setup InstantDB proxy routes
setupExpressRoutes(app);

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

// Start server
app.listen(PORT, () => {
  console.log(`🚀 InstantDB Backend Proxy running on http://localhost:${PORT}`);
  console.log(`📡 Health check: http://localhost:${PORT}/health`);
  console.log(`\nAvailable endpoints:`);
  console.log(`  POST /api/users/create`);
  console.log(`  POST /api/users/find`);
  console.log(`  POST /api/users/find-google`);
  console.log(`  POST /api/users/create-google`);
  console.log(`  PUT  /api/users/update/:userId`);
  console.log(`  POST /api/recipes/save`);
  console.log(`  POST /api/recipes/get`);
  console.log(`  POST /api/ocr/extract-text (FREE - Tesseract.js)`);
  console.log(`  POST /api/speech/transcribe (FREE tier - AssemblyAI)`);
});


