class AppwriteConstants {
  // Appwrite configuration
  static const String endpoint = 'https://sgp.cloud.appwrite.io/v1';
  static const String projectId = '6933db5d003dd17c7e08';
  static const String bucketId = '6933dd860009f1a2e0be';
  
  // File size limits (in bytes)
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB
  static const int maxVideoSize = 50 * 1024 * 1024; // 50MB
  static const int maxAudioSize = 20 * 1024 * 1024; // 20MB
  
  // Allowed file types
  static const List<String> allowedImageTypes = [
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/gif',
    'image/webp',
  ];
  
  static const List<String> allowedVideoTypes = [
    'video/mp4',
    'video/webm',
    'video/ogg',
    'video/quicktime',
  ];
  
  static const List<String> allowedAudioTypes = [
    'audio/mpeg',
    'audio/mp3',
    'audio/wav',
    'audio/ogg',
    'audio/webm',
  ];
}

