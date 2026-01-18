import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

/// Service for processing media files (OCR and transcription)
/// Uses free services: Tesseract.js for OCR and AssemblyAI for transcription
class MediaProcessingService {
  // Update this URL to match your backend
  // For production, use your deployed backend URL
  static const String baseUrl = 'http://localhost:3000';
  
  /// Extract text from an image using OCR
  /// 
  /// [imageFile] - The image file to process
  /// [languageHints] - Optional list of language codes (e.g., ['eng', 'heb', 'ara'])
  ///   Supported codes: eng (English), heb (Hebrew), ara (Arabic), spa (Spanish), etc.
  ///   Multiple languages can be combined: 'eng+heb' for English and Hebrew
  /// Returns the extracted text as a string
  Future<String> extractTextFromImage(
    File imageFile, {
    List<String>? languageHints,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/ocr/extract-text'),
      );

      // Add image file
      final imageStream = http.ByteStream(imageFile.openRead());
      final imageLength = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'image',
        imageStream,
        imageLength,
        filename: p.basename(imageFile.path),
      );
      request.files.add(multipartFile);

      // Add language hints if provided
      // Format: 'eng+heb+ara' for multiple languages
      if (languageHints != null && languageHints.isNotEmpty) {
        request.fields['languageHints'] = languageHints.join('+');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final extractedText = jsonData['text'] as String? ?? '';
        
        if (extractedText.isEmpty) {
          throw Exception('No text found in image');
        }
        
        return extractedText;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to extract text from image');
      }
    } catch (e) {
      throw Exception('Error extracting text from image: $e');
    }
  }

  /// Transcribe audio to text
  /// 
  /// [audioFile] - The audio file to transcribe
  /// [languageCode] - Language code (e.g., 'en' for English, 'he' for Hebrew, 'ar' for Arabic)
  ///   See AssemblyAI docs for full list: https://www.assemblyai.com/docs/guides/supported-languages
  /// Returns the transcribed text as a string
  Future<String> transcribeAudio(
    File audioFile, {
    String? languageCode,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/speech/transcribe'),
      );

      // Add audio file
      final audioStream = http.ByteStream(audioFile.openRead());
      final audioLength = await audioFile.length();
      final multipartFile = http.MultipartFile(
        'audio',
        audioStream,
        audioLength,
        filename: p.basename(audioFile.path),
      );
      request.files.add(multipartFile);

      // Add language code if provided (defaults to 'en' on server)
      if (languageCode != null) {
        request.fields['languageCode'] = languageCode;
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final transcribedText = jsonData['text'] as String? ?? '';
        
        if (transcribedText.isEmpty) {
          throw Exception('No speech detected in audio');
        }
        
        return transcribedText;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to transcribe audio');
      }
    } catch (e) {
      throw Exception('Error transcribing audio: $e');
    }
  }
}


