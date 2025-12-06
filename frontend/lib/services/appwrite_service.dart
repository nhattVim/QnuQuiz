import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:logger/logger.dart';

/// Service for interacting with Appwrite Storage
/// Handles file uploads, downloads, and deletions
class AppwriteService {
  final _log = Logger();
  late final Client _client;
  late final Storage _storage;
  
  final String endpoint;
  final String projectId;
  final String bucketId;

  AppwriteService({
    required this.endpoint,
    required this.projectId,
    required this.bucketId,
  }) {
    _initializeClient();
    _storage = Storage(_client);
  }

  void _initializeClient() {
    _client = Client()
      ..setEndpoint(endpoint)
      ..setProject(projectId);
    
    if (kDebugMode) {
      _client.setSelfSigned(status: true);
      _log.d('Appwrite Client initialized with self-signed certificates (DEBUG MODE)');
    } else {
      _log.d('Appwrite Client initialized with standard SSL verification (PRODUCTION)');
    }
  }

  /// Upload file to Appwrite storage
  /// 
  /// [file] - The file to upload
  /// [fileName] - Optional custom file name. If not provided, generates unique name
  /// 
  /// Returns the public URL of the uploaded file
  /// 
  /// Throws [AppwriteException] if upload fails
  Future<String> uploadFile({
    required File file,
    String? fileName,
  }) async {
    try {
      final baseFileName = fileName ?? path.basename(file.path);
      final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$baseFileName';
      
      _log.d('Reading file: ${file.path}');
      final fileBytes = await file.readAsBytes();
      _log.d('File size: ${fileBytes.length} bytes');
      
      _log.i('Uploading file to Appwrite: $uniqueFileName');
      final result = await _storage.createFile(
        bucketId: bucketId,
        fileId: ID.unique(),
        file: InputFile.fromBytes(
          bytes: fileBytes,
          filename: uniqueFileName,
        ),
      );

      // Build file URL manually to ensure it's a string
      // Format: {endpoint}/storage/buckets/{bucketId}/files/{fileId}/view?project={projectId}
      final fileUrl = '$endpoint/storage/buckets/$bucketId/files/${result.$id}/view?project=$projectId';

      _log.i('File uploaded successfully. File ID: ${result.$id}, URL: $fileUrl');
      
      return fileUrl;
    } on AppwriteException catch (e) {
      _log.e('Appwrite error uploading file: ${e.message} (Code: ${e.code})');
      rethrow;
    } catch (e) {
      _log.e('Unexpected error uploading file: $e');
      rethrow;
    }
  }

  /// Upload file from bytes
  /// 
  /// [bytes] - File content as bytes
  /// [fileName] - Original file name
  /// 
  /// Returns the public URL of the uploaded file
  /// 
  /// Throws [AppwriteException] if upload fails
  Future<String> uploadFileFromBytes({
    required List<int> bytes,
    required String fileName,
  }) async {
    try {
      final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      
      _log.d('Uploading file from bytes: $uniqueFileName (${bytes.length} bytes)');
      final result = await _storage.createFile(
        bucketId: bucketId,
        fileId: ID.unique(),
        file: InputFile.fromBytes(
          bytes: bytes,
          filename: uniqueFileName,
        ),
      );

      // Build file URL manually to ensure it's a string
      // Format: {endpoint}/storage/buckets/{bucketId}/files/{fileId}/view?project={projectId}
      final fileUrl = '$endpoint/storage/buckets/$bucketId/files/${result.$id}/view?project=$projectId';

      _log.i('File uploaded successfully. File ID: ${result.$id}, URL: $fileUrl');
      
      return fileUrl;
    } on AppwriteException catch (e) {
      _log.e('Appwrite error uploading file: ${e.message} (Code: ${e.code})');
      rethrow;
    } catch (e) {
      _log.e('Unexpected error uploading file: $e');
      rethrow;
    }
  }

  /// Delete file from Appwrite storage
  /// 
  /// [fileId] - The ID of the file to delete
  /// 
  /// Throws [AppwriteException] if deletion fails
  Future<void> deleteFile(String fileId) async {
    try {
      _log.d('Deleting file: $fileId');
      await _storage.deleteFile(
        bucketId: bucketId,
        fileId: fileId,
      );
      _log.i('File deleted successfully. File ID: $fileId');
    } on AppwriteException catch (e) {
      _log.e('Appwrite error deleting file: ${e.message} (Code: ${e.code})');
      rethrow;
    } catch (e) {
      _log.e('Unexpected error deleting file: $e');
      rethrow;
    }
  }

  /// Get public file view URL by file ID
  /// 
  /// [fileId] - The ID of the file
  /// 
  /// Returns the public URL to view the file
  String getFileUrl(String fileId) {
    return _storage.getFileView(
      bucketId: bucketId,
      fileId: fileId,
    ).toString();
  }

  /// Get file download URL (with download parameter)
  /// 
  /// [fileId] - The ID of the file
  /// 
  /// Returns the download URL for the file
  String getFileDownloadUrl(String fileId) {
    return _storage.getFileDownload(
      bucketId: bucketId,
      fileId: fileId,
    ).toString();
  }

  /// List files in bucket (optional, for admin purposes)
  /// 
  /// [queries] - Optional query filters
  /// [search] - Optional search term
  /// 
  /// Returns a list of files matching the criteria
  /// 
  /// Throws [AppwriteException] if listing fails
  Future<models.FileList> listFiles({
    List<String>? queries,
    String? search,
  }) async {
    try {
      _log.d('Listing files in bucket: $bucketId');
      final result = await _storage.listFiles(
        bucketId: bucketId,
        queries: queries,
        search: search,
      );
      _log.d('Found ${result.files.length} files');
      return result;
    } on AppwriteException catch (e) {
      _log.e('Appwrite error listing files: ${e.message} (Code: ${e.code})');
      rethrow;
    } catch (e) {
      _log.e('Unexpected error listing files: $e');
      rethrow;
    }
  }
}

